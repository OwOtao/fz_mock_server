local class = require("third.class.NewClass")
local FightCommons = require("app.FightSystem.FightCommons")
local Desc = require("app.FightSystem.FightBuff.Desc")
local LogSystem = require("app.models.LogSystem.LogSystem")
local FightBuffConstants = require("app.FightSystem.FightBuff.Constants")
local IBuffExecutor = require("app.FightSystem.FightBuff.IBuffExecutor")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")
local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local function print(...)
    return LogSystem:logWithTab("BuffExecutor:", ...)
end

local BuffExecutor = {}

function BuffExecutor:create()
    return BuffExecutor.new()
end

function BuffExecutor:setBuffSystem(buffSystem)
    self.__buffSystem = buffSystem
end

function BuffExecutor:setAttacker(attacker)
    self.__attacker = attacker
end

--@desc: buff持有者
--@author:Seven
--@time:2022-08-16 16:55:53
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function BuffExecutor:setTarget(target)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__target = target
end

function BuffExecutor:setAddActiveZhaoCDMap(addActiveZhaoCDMap)
    self.__addActiveZhaoCDMap = addActiveZhaoCDMap
end

function BuffExecutor:setAddBuffPrintText(addBuffPrintText)
    self.__addBuffPrintText = addBuffPrintText
end

function BuffExecutor:getAddBuffPrintText()
    return self.__addBuffPrintText
end

function BuffExecutor:setUnmountWeapon(bool)
    self.__unmountWeapon = bool
end

function BuffExecutor:setChangeWeapon(b)
    self.__changeWeapon = b
end

function BuffExecutor:setEffectArray(effectArray)
    self.__effectArray = effectArray
end

--[[
    @desc: 添加buff动画效果 
    author:TangJian
    time:2022-08-17 15:06:24
    --@buffAnimEffect: {{eventName, animName},{eventName, animName}}
    @return:
]]
function BuffExecutor:appendBuffAnimEffect(buffAnimEffect)
    if self.__buffAnimEffects == nil then
        self.__buffAnimEffects = {}
    end
    if buffAnimEffect ~= nil then
        table.insert(self.__buffAnimEffects, buffAnimEffect)
    end
end

function BuffExecutor:showAddSuccessText()
    -- buff添加的时候打印文本
    if type(self.__addBuffPrintText) == "string" and self.__addBuffPrintText ~= "" then
        self.__target:printDesces({Desc:create(self.__addBuffPrintText, {{"$BsN", self.__target:getAttr("name")}})})
    end
end

function BuffExecutor:attackExecute(attackExecutor)
    -- buff转移
    self:transferBuff()

    -- 主动技能cd时间处理
    self:activeSkillBuffCDAdd()

    -- 卸下武器
    self:unmountWeapon()

    -- 切换武器
    self:changeWeapon()

    self:addOneOffEffect(attackExecutor)

    if #self.__addCurrAttrArray > 0 then
        --@desc 这里只有效果120类型的处理

        local EffectChangeAttrModel = require("app.FightSystem.FightRole.AttackSystem.AttackModel.EffectChangeAttrModel")

        local DoChangeCharacterModel = require("app.FightSystem.FightRole.AttackSystem.AttackModel.DoChangeCharacterModel")

        --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.DoChangeCharacterModel#DoChangeCharacterModel]
        local doChangeModel = DoChangeCharacterModel:create(self.__target)

        for i = 1, #self.__addCurrAttrArray do
            --@RefType [src.app.FightSystem.FightBuff.ActiveEffect#ActiveEffect]
            local attrEffect = self.__addCurrAttrArray[i]

            -- 获取加属性值
            local addAttrName, addAttrValue = attrEffect.attrName, attrEffect.attrValue

            attackExecutor:addDoCharacterAttrChange(self.__target:getId(), addAttrName, addAttrValue)

            --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.EffectChangeAttrModel#EffectChangeAttrModel]
            local effectChange = EffectChangeAttrModel:create()
            effectChange:setCharacterSystem(self.__target:getCharacterSystem())
            effectChange:setAttackerId(self.__target:getId())
            effectChange:setTargetId(self.__target:getId())
            effectChange:setEffectOwnerId(self.__target:getId())
            effectChange:setEffectId(attrEffect.effectId)
            effectChange:setChangeAttrName(addAttrName)
            effectChange:setChangeValue(addAttrValue)

            local defender = self.__target:getTarget()
            if defender then
                effectChange:setDefenderId(defender:getId())
            end
            doChangeModel:addEffectChangeAttr(effectChange)
        end

        doChangeModel:doCharacterCombFinishPrintDesc()
        doChangeModel:doAnyCharacterCombFinishPopText()
    end
end

function BuffExecutor:dispatch()
    self.__addCurrAttrArray = {}
    self.__addActiveZhaoCDMap = {}
    self.__transferBuff = {}

    local effectArraySize = table.getn(self.__effectArray)
    local i = 1
    while i <= effectArraySize do
        local effect = self.__effectArray[i]
        local effectType = effect:getType()
        if effectType == FightBuffConstants.EffectType.AddCurrAttr then
            local attrName, attrValue = effect:getAddAttr()
            local effectId = effect:getId()
            table.insert(self.__addCurrAttrArray, {effectId = effectId, attrName = attrName, attrValue = attrValue})
            table.remove(self.__effectArray, i)
            i = i - 1
            effectArraySize = effectArraySize - 1
        elseif effectType == FightBuffConstants.EffectType.TransferBuff then
            if self.__attacker then
                local buffIdArray = self.__buffSystem:getRoleBuffIdArray(self.__target:getId())
                local transferBuffIdArray = {}
                for _, buffId in ipairs(buffIdArray) do
                    local buff = self.__buffSystem:getBuff(buffId)
                    if effect:needTransferBuff(buff:getId(), buff:getClass()) then
                        table.insert(transferBuffIdArray, buffId)
                    end
                end

                for i = 1, effect:getTransferBuffTimes() do
                    effect:transferBuff()
                    if #transferBuffIdArray > 0 then
                        local transferBuffId = table.remove(transferBuffIdArray, FightUtil:random(1, #transferBuffIdArray))
                        table.insert(self.__transferBuff, {fromRoleId = self.__target:getId(), toRoleId = self.__attacker:getId(), buffId = transferBuffId})
                        BuffSystemUtil:log("转移buff:", transferBuffId)
                    end
                end
            end
            table.remove(self.__effectArray, i)
            i = i - 1
            effectArraySize = effectArraySize - 1
        elseif effectType == FightBuffConstants.EffectType.AddActiveZhaoRemainCD then
            local addActiveZhaoCD = self.__addActiveZhaoCDMap[effect:getAddActiveZhaoCDType()]
            if addActiveZhaoCD == nil then
                addActiveZhaoCD = {activeZhaoType = effect:getAddActiveZhaoCDType(), activeZhaoIds = effect:getAddActiveZhaoCDIds(), addCD = effect:getAddActiveZhaoValue(), 
                CDLimitValue = function(coolTime)
                    return effect:getAddActiveZhaoCDLimit(coolTime)
                end}
            else
                addActiveZhaoCD.addCD = addActiveZhaoCD.addCD + effect:getAddActiveZhaoValue()
            end
            BuffSystemUtil:log("effectType == FightBuffConstants.EffectType.AddActiveZhaoRemainCD:", effect)
            self.__addActiveZhaoCDMap[effect:getAddActiveZhaoCDType()] = addActiveZhaoCD
            table.remove(self.__effectArray, i)
            i = i - 1
            effectArraySize = effectArraySize - 1
        elseif effectType == FightBuffConstants.EffectType.UnmountWeapon then
            self.__unmountWeapon = true
            self.__unmountWeaponState = effect:getWeaponState()
            table.remove(self.__effectArray, i)
            i = i - 1
            effectArraySize = effectArraySize - 1
        elseif effectType == FightBuffConstants.EffectType.ChangeWeapon then
            self.__changeWeapon = true
            self.__changeWeaponInfo = {
                switchType = effect:getConditionType(),
                switchConditionLogicalSymbol = effect:getConditionMethod(),
                switchConditionValue = effect:getConditionValue(),
                switchFailTextId = effect:getConditionFailedText()
            }
            table.remove(self.__effectArray, i)
            i = i - 1
            effectArraySize = effectArraySize - 1
        end
        i = i + 1
    end
end

-- 转移buff
function BuffExecutor:transferBuff()
    for i, transferBuff in ipairs(self.__transferBuff) do
        self.__buffSystem:transferBuff(transferBuff.fromRoleId, transferBuff.toRoleId, transferBuff.buffId)
    end
end

-- 主动技能cd时间处理
function BuffExecutor:activeSkillBuffCDAdd()
    BuffSystemUtil:log("BuffExecutor:activeSkillBuffCDAdd:", self.__addActiveZhaoCDMap)
    -- BuffSystemUtil:log("BuffExecutor:self.__target:getPrepSkills():", #self.__target:getPrepSkills())
    if MapIsEmpty(self.__addActiveZhaoCDMap) == false then
        for activeSkillType, addActiveZhaoCDData in pairs(self.__addActiveZhaoCDMap) do
            for k, activeSkill in pairs(self.__target:getPrepAcitveSkills()) do
                BuffSystemUtil:log("activeSkill:", k)

                local addCD = addActiveZhaoCDData.addCD
                local CDLimitValue = addActiveZhaoCDData.CDLimitValue(activeSkill:getCoolDownTime())
                BuffSystemUtil:log("改变主动技能CD:", "当前修改cd值：",addCD, "cd上限值：",CDLimitValue)

                local activeZhaoIds = addActiveZhaoCDData.activeZhaoIds

                BuffSystemUtil:log("改变主动技能CD activeSkillType, activeSkill:getType():", activeSkillType, activeSkill:getType())

                if  activeSkillType == "all" or (activeSkillType == "used" and activeSkill:getCD() > 0) or (activeSkillType == "class" and table.contains(activeZhaoIds, tostring(activeSkill:getType()))) or
                            (activeSkillType == "skill" and table.contains(activeZhaoIds, tostring(activeSkill:getId())))
                     then
                        local cd = activeSkill:getCD() + addCD
                        cd = math.max(cd, 0)
                        cd = math.min(cd, CDLimitValue)
                        self.__target:setActiveSkillCd(activeSkill:getId(), cd)
                        BuffSystemUtil:log("改变主动技能CD：", k, cd, activeSkill:getCD())
                    end
            end
        end
    end
end

-- 卸下武器
function BuffExecutor:unmountWeapon()
    if not self.__unmountWeapon then
        return
    end

    if self.__target:weaponIsEmptyHand() then
        return
    end

    self.__target:beUnmountWeapon(self.__unmountWeaponState)
end

-- 切换武器
function BuffExecutor:changeWeapon()
    if not self.__changeWeapon then
        return
    end

    local switchType = self.__changeWeaponInfo.switchType
    local switchConditionLogicalSymbol = self.__changeWeaponInfo.switchConditionLogicalSymbol
    local switchConditionValue = self.__changeWeaponInfo.switchConditionValue
    local switchFailTextId = self.__changeWeaponInfo.switchFailTextId

    self.__target:switchWeapon(switchType, switchConditionLogicalSymbol, switchConditionValue, switchFailTextId)
end

function BuffExecutor:addOneOffEffect(attackExecutor)
    if self.__buffAnimEffects == nil or table.getn(self.__buffAnimEffects) <= 0 then
        return
    end

    local skillAttack = attackExecutor:getSkillAttack()

    for _, v in ipairs(self.__buffAnimEffects) do
        local info = {
            eventName = v[1],
            animId = v[2],
            targetId = self.__target:getId()
        }

        skillAttack:addOneOffEffect(info)
    end
end

return class("BuffExecutor", {IBuffExecutor}, BuffExecutor)
000000000
--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
    效果功能执行：被添加Buff的角色，所有使用中主动招式冷却CD>0的指定条件主动招式，当前剩余CD时间同时增加或者减少N秒。

    * 只有主动招式剩余冷却CD>0、且符合主动使用条件正在战斗中使用的主动招式会受影响。
    * effectTypeParam配置指定的主动招式类型，配置格式：影响主动类型#参数@参数@参数。影响主动类型有：
      * 影响主动类型填 `all` = 影响任意主动，参数固定填0
      * 影响主动类型填 `class` = 按类型影响，参数填1(攻击)或者2(释放)，对应主动的招式类型（表[武功主动招式组合].activeType），参数可填多个用@间隔，符合参数配置都受影响。
      * 影响主动类型填 `skill` = 按指定主动ID影响，参数填主动招式ID（表[武功主动招式组合].activeId），可填多个用@间隔，符合参数配置都受影响。
    * argsParam配置总Buff表效果伤害ID，伤害ID公式返回值为影响CD时间。
      * ID读取 总Buff表效果伤害.xlsx 的 id

]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

local ActiveSkillCdUpdateViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.ActiveSkillCdUpdateViewEvent")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect12 = {}

function BuffEffect12:create()
    return BuffEffect12.new():__init()
end

function BuffEffect12:__init()
    self.__isInit = false

    self.__isCalcValueInit = false

    return self
end

function BuffEffect12:updateEffectValue()
    if self.__isInit == false then
        if self.__basicEffect:getEffectTypeParam() == nil then
            error("效果编号：" .. self.__basicEffect:getId() .. "，effectTypeParam 不可为空")
        end

        local effectTypeParams = string.split(self.__basicEffect:getEffectTypeParam(), "#")

        --@desc 影响类型
        self.__classifyType = effectTypeParams[1]

        if self.__classifyType ~= "all" and self.__classifyType ~= "used" then
            self.__matchMap = {}

            local conditionArgs = string.split(effectTypeParams[2], "@")

            for _, v in ipairs(conditionArgs) do
                self.__matchMap[tostring(v)] = true
            end
        end

        self._CDlimitValue = 0
        
        if effectTypeParams[3] == "cd" then
            self._CDlimitValue = 0
        elseif effectTypeParams[3] == "num" then
            self._CDlimitValue = tonumber(effectTypeParams[4])
        elseif effectTypeParams[3] == "fm" then
            self._CDlimitValue = BuffEffectDamageCalculatorFactory:create(effectTypeParams[4], self.__buff):getDamage()
        end

        --@desc 计算公式id
        self.__calclatorId = self.__basicEffect:getArgsParam()

        self.__isInit = true
    end

    self.__value = BuffEffectDamageCalculatorFactory:create(self.__calclatorId, self.__buff):getDamage()
end

function BuffEffect12:makeEffectOnAdd()
    if self.__isCalcValueInit == false then
        self:updateEffectValue()
        self.__isCalcValueInit = true
    end

    local activeSkills = self:__getActiveSkills()

    if table.getn(activeSkills) <= 0 then
        return
    end

    for _, activeSkill in ipairs(activeSkills) do
        --@RefType [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
        activeSkill = activeSkill

        local cdLimit = activeSkill:getCoolDownTime()

        if self._CDlimitValue ~= 0 then
            cdLimit = self._CDlimitValue
        end

        local nowCD = activeSkill:getCD()

        local newCD = Helper:getRange(nowCD + self.__value, 0, cdLimit)

        if newCD ~= nowCD then
            activeSkill:setCD(newCD)

            local owner = self.__buff:getBuffOwner()
            local updateViewEvent = ActiveSkillCdUpdateViewEvent:create(owner:getId(), activeSkill:getId(), nowCD, newCD)

            owner:getFight():notifyVeiwEvent(updateViewEvent)
        end
    end
end

function BuffEffect12:makeEffectOnRemove()
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect12:makeEffectOnTransfer(buffEffect)
end

function BuffEffect12:__isMatch(cond)
    return self.__matchMap[tostring(cond)]
end

function BuffEffect12:__getActiveSkills()
    local list = {}

    if self.__classifyType == "all" then
        self:__walkPrepActiveSkills(
            function(activeSkill)
                table.insert(list, activeSkill)
            end
        )
    elseif self.__classifyType == "used" then
        self:__walkPrepActiveSkills(
            function(activeSkill)
                --@RefType [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
                activeSkill = activeSkill

                if activeSkill:getCD() > 0 then
                    table.insert(list, activeSkill)
                end
            end
        )
    elseif self.__classifyType == "class" then
        self:__walkPrepActiveSkills(
            function(activeSkill)
                --@RefType [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
                activeSkill = activeSkill

                if self:__isMatch(activeSkill:getActiveType()) then
                    table.insert(list, activeSkill)
                end
            end
        )
    elseif self.__classifyType == "skill" then
        self:__walkPrepActiveSkills(
            function(activeSkill)
                --@RefType [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
                activeSkill = activeSkill

                if self:__isMatch(activeSkill:getId()) then
                    table.insert(list, activeSkill)
                end
            end
        )
    else
        error("效果：" .. self.__basicEffect:getId() .. " ，类型12 ，未知主动招式类型 .. " .. tostring(self.__classifyType))
    end

    return list
end

function BuffEffect12:__walkPrepActiveSkills(func)
    local prepActiveSkills = self.__buff:getBuffOwner():getPrepAcitveSkills()

    if table.getn(prepActiveSkills) <= 0 then
        return
    end

    for _, prepActiveSkill in ipairs(prepActiveSkills) do
        func(prepActiveSkill)
    end
end

return newClass("BuffEffect12", {ABuffEffect}, BuffEffect12)
000000000
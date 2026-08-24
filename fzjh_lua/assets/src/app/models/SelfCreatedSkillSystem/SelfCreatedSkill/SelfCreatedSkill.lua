local NewClass = require("third.class.NewClass")
local assertIsInstance = require("third.assertIsInstance.assertIsInstance")
local ISelfCreatedSkill = require("app.models.SelfCreatedSkillSystem.ISelfCreatedSkill")
local SelfCreatedZhao = require("app.models.SelfCreatedSkillSystem.SelfCreatedZhao.SelfCreatedZhao")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local SelfCreatedDsc = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedDsc.SelfCreatedDsc")
local SkillUniverse = require("app.models.SelfCreatedSkillSystem.SkillUniverse")
local SelfCreatedZhaoOld = require("app.models.SelfCreatedSkillSystem.SelfCreatedZhao.SelfCreatedZhaoOld")
local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SelfCreatedSkill = {}

function SelfCreatedSkill:create(data)
    local p = SelfCreatedSkill.new(data)
    p._data = SelfCreatedSkillManager:getSkill(p:getTemplateId())
    p._selfCreatedDsc = SelfCreatedDsc:create()
    p._selfCreatedDsc:setSkill(p)
    p:__initSkillUniverse()

    return p
end

function SelfCreatedSkill:getId()
    return self.id
end

function SelfCreatedSkill:getTemplateId()
    return self.templateId
end

function SelfCreatedSkill:getType()
    return SKILL_TYPE_SELFCREATE
end

function SelfCreatedSkill:getOutputType()
    return self.outputType
end

function SelfCreatedSkill:getName()
    return self.name
end

function SelfCreatedSkill:getColorId()
    return self.colorId
end

function SelfCreatedSkill:getPropId()
    return self.prop
end

function SelfCreatedSkill:getUnlocks()
    return self.unlocks
end

function SelfCreatedSkill:getFirstType()
    return tonumber(SkillClassifyManager:getClassifyFirstType(tostring(self._data.skillType)))
end

function SelfCreatedSkill:getSecondType()
    return tonumber(SkillClassifyManager:getClassifySecondType(tostring(self._data.skillType)))
end

function SelfCreatedSkill:getThirdType()
    return tonumber(SkillClassifyManager:getClassifyThirdType(tostring(self._data.skillType)))
end

function SelfCreatedSkill:getWeapontypeText()
    return self._data.weapontypeText
end

function SelfCreatedSkill:__initSkillUniverse()
    local exp = self.exp
    local zhaos = self.zhaos
    if type(exp) == "number" and exp > 0 then
        local newZhaos = {}
        local minZhaoIndex = 1
        local minZhaoNeedLv = 9999
        local skillLv = Skill:getLv(exp)
        for i, zhaoData in ipairs(zhaos) do
            local zhao = SelfCreatedZhao:create(zhaoData)
            local zhaoNeedLv = zhao:getGrade()
            if skillLv >= zhaoNeedLv then
                table.insert(newZhaos, zhaoData)
            end

            if zhaoNeedLv < minZhaoNeedLv then
                minZhaoNeedLv = zhaoNeedLv
                minZhaoIndex = i
            end
        end

        if MapIsEmpty(newZhaos) == false then
            zhaos = newZhaos
        else
            zhaos = {zhaos[1]}
        end
    end
    self._skillUniverse = SkillUniverse:create(zhaos)
end

local zhaosCache = {}
function SelfCreatedSkill:getZhaos()
    local retZhaos = zhaosCache[self.zhaos]

    if retZhaos == nil then
        local zhaos = {}
        for i, zhaoData in ipairs(self.zhaos) do
            local zhao = SelfCreatedZhao:create(zhaoData)
            self:setSkillUniverseValue(zhao)
            table.insert(zhaos, zhao)
        end

        retZhaos = zhaos
        zhaosCache[self.zhaos] = retZhaos
    end

    return retZhaos
end

function SelfCreatedSkill:getZhaoByIndex(zhaoIndex)
    local zhaoData = self.zhaos[zhaoIndex]
    if MapIsEmpty(zhaoData) then
        assert(nil, "招式数据不存在   zhaoIndex = " .. zhaoIndex)
    end

    local zhao = SelfCreatedZhao:create(zhaoData)
    self:setSkillUniverseValue(zhao)

    return zhao
end

function SelfCreatedSkill:getZhaoNum()
    return #self.zhaos
end

function SelfCreatedSkill:setSkillUniverseValue(zhao)
    zhao:setSkillUniverseValue("attack", self._skillUniverse:getUniverseValue("attack"))
    zhao:setSkillUniverseValue("hit", self._skillUniverse:getUniverseValue("hit"))
    -- zhao:setSkillUniverseValue("parry",self._skillUniverse:getUniverseValue("parry"))
    -- zhao:setSkillUniverseValue("defense",self._skillUniverse:getUniverseValue("defense"))
    -- zhao:setSkillUniverseValue("dodge",self._skillUniverse:getUniverseValue("dodge"))
    -- zhao:setSkillUniverseValue("speed",self._skillUniverse:getUniverseValue("speed"))
    -- zhao:setSkillUniverseValue("recovery",self._skillUniverse:getUniverseValue("recovery"))
    -- zhao:setSkillUniverseValue("blood",self._skillUniverse:getUniverseValue("blood"))
end

--获取武学全效等级
function SelfCreatedSkill:getAllEffectLv()
    local needLvList = {}
    local zhaos = self:getZhaos()
    if not MapIsEmpty(zhaos) then
        for i, zhao in ipairs(zhaos) do
            local needLv = zhao:getGrade()
            table.insert(needLvList, needLv)
        end
    end

    table.sort(needLvList)

    local minAutoZhaoNum = SelfCreatedSkillManager:getParamsById("complete_general_num")
    return assert(needLvList[minAutoZhaoNum], "武学招式不足" .. minAutoZhaoNum)
end

--@desc 获取攻击性能
function SelfCreatedSkill:getAttack()
    local attack = 0
    local zhaos = self:getZhaos()
    if not MapIsEmpty(zhaos) then
        for i, zhao in ipairs(zhaos) do
            attack = attack + zhao:getAttack()
        end
        attack = attack / #zhaos
    end

    return attack
end

--@desc 获取命中性能
function SelfCreatedSkill:getHit()
    local hit = 0
    local zhaos = self:getZhaos()
    if not MapIsEmpty(zhaos) then
        for i, zhao in ipairs(zhaos) do
            hit = hit + zhao:getHit()
        end
        hit = hit / #zhaos
    end

    return hit
end

--@desc 获取防御性能
function SelfCreatedSkill:getDefense()
    local defense = 0
    local zhaos = self:getZhaos()
    if not MapIsEmpty(zhaos) then
        for i, zhao in ipairs(zhaos) do
            defense = defense + zhao:getDefense()
        end
        defense = defense / #zhaos
    end

    return defense
end

--@desc 获取招架性能
function SelfCreatedSkill:getParry()
    local parry = 0
    local zhaos = self:getZhaos()
    if not MapIsEmpty(zhaos) then
        for i, zhao in ipairs(zhaos) do
            parry = parry + zhao:getParry()
        end
        parry = parry / #zhaos
    end

    return parry
end

--@desc 获取攻速性能
function SelfCreatedSkill:getAttackSpeed()
    local attackSpeed = 0
    local zhaos = self:getZhaos()
    if not MapIsEmpty(zhaos) then
        for i, zhao in ipairs(zhaos) do
            attackSpeed = attackSpeed + zhao:getAttackSpeed()
        end
        attackSpeed = attackSpeed / #zhaos
    end

    return attackSpeed
end

--@desc 获取闪避性能
function SelfCreatedSkill:getDodge()
    local dodge = 0
    local zhaos = self:getZhaos()
    if not MapIsEmpty(zhaos) then
        for i, zhao in ipairs(zhaos) do
            dodge = dodge + zhao:getDodge()
        end
        dodge = dodge / #zhaos
    end

    return dodge
end

--@desc 获取气血性能
function SelfCreatedSkill:getBlood()
    local blood = 0
    local zhaos = self:getZhaos()
    if not MapIsEmpty(zhaos) then
        for i, zhao in ipairs(zhaos) do
            blood = blood + zhao:getBlood()
        end
        blood = blood / #zhaos
    end

    return blood
end

--@desc 获取回复性能
function SelfCreatedSkill:getRecovery()
    local recovery = 0
    local zhaos = self:getZhaos()
    if not MapIsEmpty(zhaos) then
        for i, zhao in ipairs(zhaos) do
            recovery = recovery + zhao:getRecovery()
        end
        recovery = recovery / #zhaos
    end

    return recovery
end

function SelfCreatedSkill:getDsc()
    local dsc = self._selfCreatedDsc:getSkillDsc()
    return dsc
end

function SelfCreatedSkill:getCreatingSkillDsc()
    local dsc = self._selfCreatedDsc:getCreatingSkillDsc()
    return dsc
end

function SelfCreatedSkill:getCreatedSkillDsc()
    local dsc = self._selfCreatedDsc:getCreatedSkillDsc()
    return dsc
end

function SelfCreatedSkill:getAttackLevel()
    return self._selfCreatedDsc:getAttackLevel()
end

function SelfCreatedSkill:getHitLevel()
    return self._selfCreatedDsc:getHitLevel()
end

function SelfCreatedSkill:getDefenseLevel()
    return self._selfCreatedDsc:getDefenseLevel()
end

function SelfCreatedSkill:getParryLevel()
    return self._selfCreatedDsc:getParryLevel()
end

function SelfCreatedSkill:getAttackSpeedLevel()
    return self._selfCreatedDsc:getAttackSpeedLevel()
end

function SelfCreatedSkill:getDodgeLevel()
    return self._selfCreatedDsc:getDodgeLevel()
end

function SelfCreatedSkill:getBloodLevel()
    return self._selfCreatedDsc:getBloodLevel()
end

function SelfCreatedSkill:getRecoveryLevel()
    return self._selfCreatedDsc:getRecoveryLevel()
end

function SelfCreatedSkill:getSkillTypeName()
    return SelfCreatedSkillConstants.SkillThirdName[self:getThirdType()]
end

function SelfCreatedSkill:getSkillTuJianIndex()
    return SelfCreatedSkillConstants.SkillThirdTuJianIndex[self:getThirdType()]
end

function SelfCreatedSkill:getNameAffixId()
    return self._data.suffix
end

function SelfCreatedSkill:getTypeId()
    return self._data.typeId
end

function SelfCreatedSkill:getHuaZhiAnim()
    return self._data.huazhianim
end

function SelfCreatedSkill:getHuaZhiText()
    return self._data.huazhitext
end

--门派目录
function SelfCreatedSkill:getFamilyList()
    return self._data.familyList
end

function SelfCreatedSkill:getMethods()
    return self._data.methods
end

function SelfCreatedSkill:getWxclassify()
    return self._data.wxclassify
end

function SelfCreatedSkill:getBaseZhaos()
    if self._baseZhaos == nil then
        self._baseZhaos = {}
        local zhaoStrs = tostring(self._data.baseZhaos)
        if zhaoStrs == nil then
            return {}
        end
        print("zhaoStrs = ", zhaoStrs)
        local ids = string.split(zhaoStrs, "#")
        for i, id in ipairs(ids) do
            local index = self:getZhaoNum() + i

            local zhaoData = SelfCreatedSkillManager:getLiLianZhaoRuleMap(id)
            if MapIsEmpty(zhaoData) then
                print("招式为空  id = ", id)
                return {}
            end

            local name = zhaoData.name
            local colorId = zhaoData.colorId
            local dscId = zhaoData.dscId
            local quality = zhaoData.quality
            local useType = zhaoData.useType
            local templateId = zhaoData.templateId
            local atkAffixs = {}
            local defAffixs = {}
            local affixIdStr = zhaoData.affix
            if affixIdStr and affixIdStr ~= 0 then
                local affixIds = string.split(affixIdStr, ",")
                for i, affixId in ipairs(affixIds) do
                    local affixMap = SelfCreatedSkillManager:getLiLianAffaixMap(affixId)
                    if affixMap then
                        local affixData = {
                            effectId = affixMap.affixId,
                            value1 = affixMap.effect1,
                            value2 = affixMap.effect2,
                            value3 = affixMap.effect3,
                            needLv = affixMap.needLv
                        }

                        if i <= 3 then
                            table.insert(atkAffixs, affixData)
                        else
                            table.insert(defAffixs, affixData)
                        end
                    end
                end
            end

            local zhaoData = {
                index = index,
                name = name,
                colorId = colorId,
                dscId = dscId,
                quality = quality,
                useType = useType,
                templateId = templateId,
                atkAffixs = atkAffixs,
                defAffixs = defAffixs
            }
            local zhao = SelfCreatedZhaoOld:create(zhaoData)
            table.insert(self._baseZhaos, zhao)
        end
    end
    return self._baseZhaos
end

--@desc: 新版战斗自创武学可使用的招式不足时，提供基本招式
--@author:LvBin
--@time:2022-03-22 12:08:46
--@return
function SelfCreatedSkill:getNewFightBaseZhaos()
    if self._newFightbaseZhaos == nil then
        self._newFightbaseZhaos = {}
        local zhaoStrs = tostring(self._data.baseZhaos)
        if zhaoStrs == nil then
            return {}
        end
        local ids = string.split(zhaoStrs, "#")
        for i, id in ipairs(ids) do
            local index = self:getZhaoNum() + i

            local zhaoData = SelfCreatedSkillManager:getLiLianZhaoRuleMap(id)
            if MapIsEmpty(zhaoData) then
                print("招式为空  id = ", id)
                return {}
            end

            local name = zhaoData.name
            local colorId = zhaoData.colorId
            local dscId = zhaoData.dscId
            local quality = zhaoData.quality
            local useType = zhaoData.useType
            local templateId = zhaoData.templateId
            local atkAffixs = {}
            local defAffixs = {}
            local affixIdStr = zhaoData.affix
            if affixIdStr and affixIdStr ~= 0 then
                local affixIds = string.split(affixIdStr, ",")
                for i, affixId in ipairs(affixIds) do
                    local affixMap = SelfCreatedSkillManager:getLiLianAffaixMap(affixId)
                    if affixMap then
                        local affixData = {
                            effectId = affixMap.affixId,
                            value1 = affixMap.effect1,
                            value2 = affixMap.effect2,
                            value3 = affixMap.effect3,
                            needLv = affixMap.needLv
                        }

                        if i <= 3 then
                            table.insert(atkAffixs, affixData)
                        else
                            table.insert(defAffixs, affixData)
                        end
                    end
                end
            end

            local zhaoData = {
                index = index,
                name = name,
                colorId = colorId,
                dscId = dscId,
                quality = quality,
                useType = useType,
                templateId = templateId,
                atkAffixs = atkAffixs,
                defAffixs = defAffixs
            }
            local zhao = SelfCreatedZhao:create(zhaoData)
            table.insert(self._newFightbaseZhaos, zhao)
        end
    end
    return self._newFightbaseZhaos
end

function SelfCreatedSkill:getWeapontype()
    local weaponType = {}
    local weapontypeStr = self._data.weapontype
    if weapontypeStr == 0 or weapontypeStr == nil then
        weaponType = {}
    else
        local array = string.split(weapontypeStr, ",")
        for i, v in ipairs(array) do
            table.insert(weaponType, v)
        end
    end

    return weaponType
end

function SelfCreatedSkill:getParryType()
    return self._data.parryType
end

function SelfCreatedSkill:getConditionType_1()
    return self._data.conditionType_1
end

function SelfCreatedSkill:getConditionId_1()
    return self._data.ConditionId_1
end

function SelfCreatedSkill:getLogic_1()
    return self._data.Logic_1
end

function SelfCreatedSkill:getConditonValue_1()
    return self._data.conditonValue_1
end

function SelfCreatedSkill:getStandAnim()
    return self._data.standAnim
end

function SelfCreatedSkill:getJumpForwardAnim()
    return self._data.jumpForwardAnim
end

function SelfCreatedSkill:getJumpBackwardAnim()
    return self._data.jumpBackwardAnim
end

function SelfCreatedSkill:getMultiEq()
    return self._data.multiEq
end

function SelfCreatedSkill:getActionid()
    return self._data.actionid
end

function SelfCreatedSkill:getFramenumber()
    return self._data.framenumber
end

function SelfCreatedSkill:getSuffix1()
    return self._data.suffix1
end

function SelfCreatedSkill:getSuffix2()
    return self._data.suffix2
end

------------------------------------------------------------------------------------------------------------------
-- 直接用于新版战斗的数据

function SelfCreatedSkill:getSkillType()
    if self._data.skillType == nil then
        assert(false, "自创武学类型未填写")
    end
    return {tostring(self._data.skillType)}
end

function SelfCreatedSkill:getWeaponTypes()
    local weaponTypes = {}
    local list = string.split(self._data.weaponTypes, "#")
    if MapIsEmpty(list) == false then
        for _, __weapon in ipairs(list) do
            table.insert(weaponTypes, __weapon)
        end
    else
        assert(false, "武学 id :" .. self:getId() .. " 的 weaponTypes 解析错误")
    end

    return weaponTypes
end

function SelfCreatedSkill:getBattleJoinAnim()
    return self._data.battleJoinAnim
end

function SelfCreatedSkill:getBattleIdleAnim()
    return self._data.battleIdleAnim
end

function SelfCreatedSkill:getBattleRunAnim()
    return self._data.battleRunAnim
end

function SelfCreatedSkill:getBattleBackAnim()
    return self._data.battleBackAnim
end

function SelfCreatedSkill:getParryClass()
    return self._data.parryClass
end

function SelfCreatedSkill:getDodgeClass()
    return self._data.dodgeClass
end

function SelfCreatedSkill:getAttackAverage()
    local attackAverageValue = 0
    local sumValue = 0
    local count = 0
    local skillLv = Skill:getLv(self.exp)

    local attackZhaos = self:getAttackZhaos()
    for i, zhao in ipairs(attackZhaos) do
        local needLv = zhao:getGrade()
        if skillLv >= needLv then
            sumValue = sumValue + zhao:getAttack()
            count = count + 1
        end
    end

    return sumValue / count
end

--@desc 自创武学等级低于武学全效等级，需要用基本招式填充招式列表
function SelfCreatedSkill:getAttackZhaos()
    local skillLv = Skill:getLv(self.exp)
    local zhaos = self:getZhaos()

    if skillLv < self:getAllEffectLv() then
        local baseZhaos = self:getNewFightBaseZhaos()
        zhaos = table.mergeArray(zhaos, baseZhaos)
    end

    return zhaos
end

------------------------------------------------------------------------------------------------------------------

return NewClass("SelfCreatedSkill", {ISelfCreatedSkill}, SelfCreatedSkill)
00000000000000
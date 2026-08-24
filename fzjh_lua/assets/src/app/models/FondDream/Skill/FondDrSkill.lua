local FondDrSkill = {}
local BaseSkill = require("app.models.skill.BaseSkill")
local inherit = require("third.inherit.inherit")

local FondDrSkill = {}

function FondDrSkill:create(skillId)
    local p = {}
    local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")
    p._skill = BasicSkillManager:getBasicSkill(skillId)
    setmetatable(p, {
        __index = function(tb, key)
            if FondDrSkill[key] == nil then
                return nil
            end

            return FondDrSkill[key](tb)
        end
    })

    return inherit({}, p, BaseSkill)
end

-- 武学编号
function FondDrSkill:id()
    return self._skill:getId()
end

-- 类型
function FondDrSkill:type()
    return self._skill:getType()
end

-- 武学名称
function FondDrSkill:name()
    return self._skill:getNameColor()..self._skill:getName().."NOR"
end

function FondDrSkill:_NoColorName()
    return self._skill:getName()
end

-- 描述
function FondDrSkill:dsc()
    return self._skill:getDsc()
end

-- 准备方式
function FondDrSkill:methods()
    local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")
    local secondTypes = self._skill:getClassifySecondTypes()
    local methods = {}
    local filterTab = {}
    for _, secondType in ipairs(secondTypes) do
        if not filterTab[secondType] then
            filterTab[secondType] = true  
            local method = SkillClassifyManager:getOldMethodTransFromClassifySecondType(secondType)
            table.insert(methods,method)
        end
    end
    
    return methods
end

function FondDrSkill:multiEq()
    local multiEq = 0
    local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")
    local SkillConst = require("app.models.skill.SkillConst")
    local firstTypes = self._skill:getClassifyFirstTypes()
    local isBqs = {}
    for _, firstType in ipairs(firstTypes) do
        if firstType == SkillConst.SkillFirstType.BING_QI then
            table.insert(isBqs,firstType)            
        end
    end

    if #isBqs > 1 then
        multiEq = 1
    end
    
    return multiEq
end

function FondDrSkill:wxclassify()
    local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")
    local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
    local thirdTypes = self._skill:getClassifyThirdTypes()
    local wxclassify = {}
    for _, thirdType in ipairs(thirdTypes) do
        table.insert(wxclassify,SelfCreatedSkillConstants.SkillThirdTuJianIndex[thirdType])
    end
    return wxclassify
end

-- -- 招式列表
function FondDrSkill:zhaoList()
    return self._skill:getActiveZhaos()
end

-- -- 招式列表
function FondDrSkill:weapontype()
    local weapontypes = self._skill:getWeaponTypes()
    local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")
    local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")
    local retWeapontype = {}
    for i,weapontypeId in ipairs(weapontypes) do
        if tostring(weapontypeId) ~= tostring(BattleConstConf:get("emptyHandedId")) then
            table.insert(retWeapontype,WeaponTypesResManager:getWeaponInfo(weapontypeId).secondUseType)
        end
    end
    
    return retWeapontype
end

local autoSkillsCache = {}
function FondDrSkill:autoSkills()
    --@desc 非攻击武学，没有被动招式组合
    if self._skill:isAttackSkill() == false then
        return {}
    end
    
    local retAutoSkills = autoSkillsCache[self]

    if retAutoSkills == nil then
        retAutoSkills = {}
        local autoZhaoCombs = self._skill:getAutoZhaoCombs()

        for i,autoZhaoComb in ipairs(autoZhaoCombs) do
            local animResIds = {}
            local zhaoinfoList = autoZhaoComb:getAtkList()
            for i,zhaoinfo in ipairs(zhaoinfoList) do
                table.insert(animResIds,zhaoinfo:getAnimResId())
            end
            local retAutoSkill = {
                id = autoZhaoComb:getZhaoId(),
                skillText = autoZhaoComb:getZhaoIdText().."："..autoZhaoComb:getZhaoName(),
                lv = autoZhaoComb:getLv(),
                action = autoZhaoComb:getActionText(),
                animResIds = animResIds
            }
            table.insert(retAutoSkills,retAutoSkill)
        end

        table.sort(retAutoSkills, function(a, b)
            if not a.lv then
                return false
            elseif not b.lv then
                return true
            elseif a.lv == b.lv then
                return a.id < b.id
            else
                return a.lv < b.lv
            end
        end)

        autoSkillsCache[self] = retAutoSkills
    end
    return retAutoSkills
end

function FondDrSkill:getWeaponTypes()
    return self._skill:getWeaponTypes()
end

--入场动画
function FondDrSkill:getBattleJoinAnim()
    return self._skill:getBattleJoinAnim()
end
--待机动画
function FondDrSkill:getBattleIdleAnim()
    return self._skill:getBattleIdleAnim()
end

--攻击前跳动画
function FondDrSkill:getBattleRunAnim()
    return self._skill:getBattleRunAnim()
end

--攻击后跳动画
function FondDrSkill:getBattleBackAnim()
    return self._skill:getBattleBackAnim()
end

-- 内力
-- function FondDrSkill:neili()
--     return 0
-- end

-- -- 闪避
-- function FondDrSkill:dodge()
--     return 0
-- end

-- -- 招架
-- function FondDrSkill:parry()
--     return 90
-- end

-- function FondDrSkill:potEfficiency()
--     local zhaoNum = #self._data.zhaos
--     return SelfCreatedSkillManager:getConsumeZhaoRateMap(zhaoNum).potEfficiency
-- end

-- -- 伤害倍率
-- function FondDrSkill:damRate()
--     return SelfCreatedSkillManager:getParamsById("transform_damRate")
-- end

-- -- 攻击倍率
-- function FondDrSkill:powerAtkRate()
--     return SelfCreatedSkillManager:getParamsById("transform_powerAtkRate")
-- end

-- -- 攻击速度
-- function FondDrSkill:atkSpd()
--     return 0
-- end

-- -- 武学等级
-- function FondDrSkill:wxlevel()
--     return 1
-- end

-- -- 
-- function FondDrSkill:levelScore()
--     return 1
-- end

-- -- 站立动画
-- function FondDrSkill:standAnim()
--     return self._newSkill:getStandAnim()
-- end

-- -- 
-- function FondDrSkill:jumpBackwardAnim()
--     return self._newSkill:getJumpBackwardAnim()
-- end



-- -- 招架技能
-- function FondDrSkill:parrySkills()
--     return {
--         [1] = {
--             ["textColor"] = "默认",
--             ["action"] = "$n躲开了$N的攻击",
--             ["id"] = 1,
--         },
--     }
-- end

-- local autoSkillsCache = {}
-- function FondDrSkill:autoSkills()
--     local autoSkills = autoSkillsCache[self]

--     if autoSkills == nil then
--         autoSkills = self.autoZhaos
--         local exp = self._data.exp
--         if type(exp) == "number" and exp > 0 then
--             local currSkillLv = Skill:getLv(exp)
--             local allEffectLv = self.allEffectLv
--             local baseZhaos = self.baseZhaos
--             if currSkillLv < allEffectLv and MapIsEmpty(baseZhaos) == false then
--                 autoSkills = table.mergeArray(baseZhaos, autoSkills)
--             end
--         end
--         autoSkillsCache[self] = autoSkills
--     end
--     return autoSkills
-- end

-- local baseZhaosCache = {}
-- function FondDrSkill:baseZhaos()
--     local baseZhaos = baseZhaosCache[self]

--     if baseZhaos == nil then
--         baseZhaos = self._newSkill:getBaseZhaos()
--         local newSkillanim = assert(require("script.skill.newSkillanim").Sheet1)
--         for k, zhao in pairs(baseZhaos) do
--             if #self.weapontype == 0 then
--                 -- 无需额外初始化
--             else
--                 local anims = {}

--                 for i, anim in ipairs(zhao.anims) do
--                     local tab = {}

--                     for index, value in ipairs(self.weapontype) do
--                         local weaponTypeNum = string.sub(value, -1)
--                         local newAnimId = anim.anim .. weaponTypeNum

--                         local newSkillanimParam = newSkillanim[newAnimId]
--                         local hitPos = newSkillanimParam["location"]
--                         local offset = newSkillanimParam["offset"]

--                         tab[value] = {
--                             anim = newAnimId,
--                             hitPos = hitPos,
--                             offset = offset,
--                             speed = anim.speed
--                         }
--                     end
--                     table.insert(anims, tab)
--                 end

--                 zhao.anims = anims
--             end
--         end

--         table.sort(baseZhaos, function(a, b)
--             if not a.lv then
--                 return false
--             elseif not b.lv then
--                 return true
--             elseif a.lv == b.lv then
--                 return a.id < b.id
--             else
--                 return a.lv < b.lv
--             end
--         end)

--         baseZhaosCache[self] = baseZhaos
--     end
--     return baseZhaos
-- end

-- --

-- function FondDrSkill:actionid()
--     return self._newSkill:getActionid()
-- end

-- function FondDrSkill:hitRate()
--     return SelfCreatedSkillManager:getParamsById("transform_hitRate")
-- end

-- function FondDrSkill:jumpForwardAnim()
--     return self._newSkill:getJumpForwardAnim()
-- end

-- function FondDrSkill:learn()
--     local potEfficiency = SelfCreatedSkillManager:getConsumeZhaoRateMap(#self._data.zhaos).potEfficiency

--     return {
--         ["potEfficiency"] = potEfficiency,
--     }
-- end

-- function FondDrSkill:factors()
--     return {
--     ["neili"] = self.neili,
--     ["atk"] = self.atk,
--     ["powerAtkRate"] = self.powerAtkRate,
--     ["HpRate"] = self.HpRate,
--     ["dodge"] = self.dodge,
--     ["powerDamRate"] = self.powerDamRate,
--     ["atkSpd"] = self.atkSpd,
--     ["def"] = self.def,
--     ["hitRate"] = self.hitRate,
--     ["parry"] = self.parry,
--     }
-- end

-- function FondDrSkill:def()
--     return 87
-- end

-- function FondDrSkill:atk()
--     return SelfCreatedSkillManager:getParamsById("transform_atk")
-- end

-- function FondDrSkill:HpRate()
--     return -0
-- end

-- function FondDrSkill:powerDamRate()
--     return SelfCreatedSkillManager:getParamsById("transform_powerDamRate")
-- end

-- function FondDrSkill:framenumber()
--     return self._newSkill:getFramenumber()
-- end

-- function FondDrSkill:useSkills()
--     return {
--     -- [1] = {
--     --     ["name"] = "真武除邪",
--     --     ["requirement"] = {
--     --     }
--     -- }
--     }
-- end

-- function FondDrSkill:Logic_1()
--     return "大于等于"
-- end
-- function FondDrSkill:conditonValue_1()
--     return 400
-- end
-- function FondDrSkill:conditionType_2()
--     return "属性"
-- end

-- function FondDrSkill:conditionType_1()
--     return "技能"
-- end
-- function FondDrSkill:conditonValue_2()
--     return 1000
-- end
-- function FondDrSkill:ConditionId_2()
--     return "neiliMax"
-- end
-- function FondDrSkill:Logic_1()
--     return "大于等于"
-- end
-- function FondDrSkill:conditonValue_1()
--     return 400
-- end
-- function FondDrSkill:conditionType_2()
--     return "属性"
-- end
-- function FondDrSkill:ConditionId_3()
--     return "hamagong"
-- end
-- function FondDrSkill:Logic_3()
--     return "大于等于"
-- end
-- function FondDrSkill:Logic_2()
--     return "大于等于"
-- end
return FondDrSkill
0
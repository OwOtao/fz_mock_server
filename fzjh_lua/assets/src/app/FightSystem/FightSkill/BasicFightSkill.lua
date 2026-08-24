--[[
    author:Seven
    time:2022-11-23 20:04:15
    desc: 战斗中使用的武学基础类
]]
--[[
    战斗武学基类
]]
local class = require("third.class.NewClass")

local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local NormalSkillBattleQuality = require("app.FightSystem.FightSkill.NormalSkillBattleQuality")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local SKILL_THIRD_TYPE = SkillConst.SkillThirdType

local FightCommons = require("app.FightSystem.FightCommons")

local HIT_POS = FightCommons.HIT_POS

local BasicFightSkill = {
    --@desc 等级
    __level = nil,
    __parryClass = {},
    __dodgeClass = {}
}

--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function BasicFightSkill:create(id)
    return BasicFightSkill.new():__init(id)
end

function BasicFightSkill:__init(id)
    --@RefType [src.app.models.skill.BasicSkill.BasicSkill#BasicSkill]
    self.__basicSkill = BasicSkillManager:getBasicSkill(id)

    for _, hitPos in pairs(HIT_POS) do
        self.__parryClass[hitPos] = {}
        self.__dodgeClass[hitPos] = {}
    end

    local parryClass = self.__basicSkill:getParryClass()
    if parryClass ~= 0 then
        local classes = BasicSkillManager:getBasicSkillParryClasses(parryClass)
        for _, v in ipairs(classes) do
            table.insert(self.__parryClass[v:getHitPos()], v)
        end
    end

    local dodgeClass = self.__basicSkill:getDodgeClass()
    if dodgeClass ~= 0 then
        local classes = BasicSkillManager:getBasicSkillDodgeClasses(dodgeClass)
        for _, v in ipairs(classes) do
            if self.__dodgeClass[v:getHitPos()] == nil then
                assert(false, "武学id: " .. self.__id .. "添加parry class出错，没有该对应部位：" .. v:getHitPos())
            end
            table.insert(self.__dodgeClass[v:getHitPos()], v)
        end
    end

    return self
end

function BasicFightSkill:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

function BasicFightSkill:getId()
    return self.__basicSkill:getId()
end

function BasicFightSkill:getName()
    return self.__basicSkill:getName()
end

function BasicFightSkill:getType()
    return self.__basicSkill:getType()
end

function BasicFightSkill:getDsc()
    return self.__basicSkill:getDsc()
end

function BasicFightSkill:getNameColor()
    return self.__basicSkill:getNameColor()
end

function BasicFightSkill:getSkillTypes()
    return self.__basicSkill:getSkillType()
end

--@desc: 该值为skillDamageAttrConf配置对应id，0为特殊值，该武学不生效，使用时注意
--@author:Seven
--@time:2025-02-27 17:00:58
function BasicFightSkill:getAutoZhaoAtkDamageClass()
    return self.__basicSkill:getAutoZhaoAtkDamageClass()
end

--@desc: 该值为skillDamageAttrConf配置对应id，0为特殊值，该武学不生效，使用时注意
--@author:Seven
--@time:2025-02-27 17:00:58
function BasicFightSkill:getZhaoJiaDefDamageClass()
    return self.__basicSkill:getZhaoJiaDefDamageClass()
end

function BasicFightSkill:getZhaoJiaDefDamageParam()
    return self.__basicSkill:getZhaoJiaDefDamageParam()
end

function BasicFightSkill:__isfirstTypeSkill(firstType)
    for _, classifyId in ipairs(self.__basicSkill:getSkillType()) do
        local skillFirstType = SkillClassifyManager:getClassifyFirstType(classifyId)
        if skillFirstType == nil then
            assert(false, "武学 id：" .. self:getId() .. "武学类型：" .. classifyId .. "无法获取武学第一分类信息，请检查是否填写正确。")
        end

        if firstType == skillFirstType then
            return true
        end
    end

    return false
end

function BasicFightSkill:isAttackSkill()
    if self:isBingQiSkill() or self:isQuanJiaoSkill() then
        return true
    end

    return false
end

function BasicFightSkill:isBingQiSkill()
    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.BING_QI) then
        return true
    end

    return false
end

function BasicFightSkill:isQuanJiaoSkill()
    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.QUAN_JIAO) then
        return true
    end

    return false
end

function BasicFightSkill:isNeiGongSkill()
    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.NEI_GONG) then
        return true
    end

    return false
end

function BasicFightSkill:isDodgeSkill()
    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.QING_GONG) then
        return true
    end

    return false
end

function BasicFightSkill:isParrySkill()
    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.ZHAO_JIA) then
        return true
    end

    return false
end

--@desc: 是否可用的武器类型
--@author:Seven
--@time:2021-05-27 20:30:39
--@weapon_type: 武器类型（子类型）
function BasicFightSkill:isUseWeaponType(weapon_type)
    if MapIsEmpty(self.__basicSkill:getWeaponTypes()) then
        return false
    end

    for _, t_weapon in ipairs(self.__basicSkill:getWeaponTypes()) do
        if tonumber(t_weapon) == tonumber(weapon_type) then
            return true
        end
    end

    return false
end

function BasicFightSkill:getBattleJoinAnim()
    return self.__basicSkill:getBattleJoinAnim()
end

function BasicFightSkill:getBattleIdleAnim()
    return self.__basicSkill:getBattleIdleAnim()
end

function BasicFightSkill:getBattleRunAnim()
    return self.__basicSkill:getBattleRunAnim()
end

function BasicFightSkill:getBattleBackAnim()
    return self.__basicSkill:getBattleBackAnim()
end

--@desc: 获取格挡信息
--@author:Seven
--@time:2021-06-07 16:09:15
--@hit_pos: [src.app.FightSystem.FightCommons#FightCommons.HIT_POS]
--@return [src.app.FightSystem.FightSkill.NormalFightParryClass#NormalFightParryClass]
function BasicFightSkill:getParryClass(hit_pos)
    local parry_array = self.__parryClass[hit_pos]

    if MapIsEmpty(parry_array) then
        assert(false, "武学id：" .. self.__id .. " 格挡资源对应部位 ： " .. hit_pos .. " 为空。")
    end

    if table.getn(parry_array) > 1 then
        local index = FightUtil:random(1, #parry_array)
        return parry_array[index]
    else
        return parry_array[1]
    end
end

function BasicFightSkill:getParryClasses()
    return self.__parryClass
end

--@desc: 获取闪避信息
--@author:Seven
--@time:2021-06-07 16:10:38
--@hit_pos: [src.app.FightSystem.FightCommons#FightCommons.HIT_POS]
--@return [src.app.FightSystem.FightSkill.NormalFightDodgeClass#NormalFightDodgeClass]
function BasicFightSkill:getDodgeClass(hit_pos)
    local dodge_array = self.__dodgeClass[hit_pos]

    if MapIsEmpty(dodge_array) then
        assert(false, "武学id：" .. self.__id .. " 闪避资源对应部位 ： " .. hit_pos .. " 为空。")
    end

    if #dodge_array > 1 then
        local index = FightUtil:random(1, #dodge_array)
        return dodge_array[index]
    else
        return dodge_array[1]
    end
end

function BasicFightSkill:getDodgeClasses()
    return self.__dodgeClass
end

--@desc: 获取武学用的主动技能id列表
--@author:Seven
--@time:2021-06-24 14:54:03
function BasicFightSkill:getActiveZhaos()
    return self.__basicSkill:getActiveZhaos()
end

function BasicFightSkill:getBattleQualityClass()
    if self.__battleQualityClass == nil then
        self.__battleQualityClass = NormalSkillBattleQuality:create(self.__basicSkill:getBattleQuality())
    end

    return self.__battleQualityClass
end

--@region 动态属性
function BasicFightSkill:setLevel(lv)
    if lv <= 0 then
        assert(false, "BasicFightSkill 技能等级不可小于1 ！value:" .. lv)
    end

    self.__level = lv
end

function BasicFightSkill:getLevel()
    if self.__level == nil then
        error("BasicFightSkill " .. self.__basicSkill:getName() .. " 没有设置等级")
    end

    return self.__level
end
--@endregion

-- 获取转换后的武学类型一
function BasicFightSkill:getClassifyFirstTypes()
    local array = {}
    for _, classifyId in ipairs(self.__basicSkill:getSkillType()) do
        local skillFirstType = SkillClassifyManager:getClassifyFirstType(classifyId)
        if skillFirstType == nil then
            assert(false, "武学 id：" .. self:getId() .. "武学类型：" .. classifyId .. "无法获取武学第一分类信息，请检查是否填写正确。")
        end

        table.insert(array, skillFirstType)
    end

    return array
end

--@desc 获取转换后的武学类型二
function BasicFightSkill:getClassifySecondTypes()
    local array = {}
    for _, classifyId in ipairs(self.__basicSkill:getSkillType()) do
        local skillSecondType = SkillClassifyManager:getClassifySecondType(classifyId)
        if skillSecondType == nil then
            assert(false, "武学 id：" .. self:getId() .. "武学类型：" .. classifyId .. "无法获取武学第二分类信息，请检查是否填写正确。")
        end
        table.insert(array, skillSecondType)
    end
    return array
end

--@desc 获取转换后的武学类型三
function BasicFightSkill:getClassifyThirdTypes()
    local array = {}
    for _, classifyId in ipairs(self.__basicSkill:getSkillType()) do
        local skillThirdType = SkillClassifyManager:getClassifyThirdType(classifyId)
        if skillThirdType == nil then
            assert(false, "武学 id：" .. self:getId() .. "武学类型：" .. classifyId .. "无法获取武学第三分类信息，请检查是否填写正确。")
        end
        table.insert(array, skillThirdType)
    end
    return array
end

function BasicFightSkill:getWeaponTypes()
    return self.__basicSkill:getWeaponTypes()
end

--@desc: 获取随机武功被动招式组合对象
--@author:Seven
--@time:2022-12-03 16:58:32
--@return [src.app.FightSystem.FightSkill.AutoZhao.BasicFightAutoZhaoCombination#BasicFightAutoZhaoCombination]
function BasicFightSkill:getAttackZhaoComb()
    local random_list = self:__getMatchCombList()

    if MapIsEmpty(random_list) then
        assert(false, "BasicFightSkill:getAttackAutoZhaoComb 技能id:" .. self:getId() .. "，等级lv:" .. self:getLevel() .. " 无法获取可用招式组合！")
    end

    local index = FightUtil:random(1, table.getn(random_list))

    return random_list[index]
end

function BasicFightSkill:__getMatchCombList()
    local max_lv = self:getLevel()

    local list = {}

    self:__walkAllAutoZhaoComb(
        function(comb)
            --@RefType [src.app.FightSystem.FightSkill.AutoZhao.BasicFightAutoZhaoCombination#BasicFightAutoZhaoCombination]
            local comb = comb

            if comb:getLevel() <= max_lv then
                table.insert(list, comb)
            end
        end
    )

    return list
end

--@desc: 获取武功被动招式组合对象列表
--@author:Seven
--@time:2022-12-03 16:58:54
function BasicFightSkill:getAutoZhaoCombs()
    if self.__combList == nil then
        local BasicFightAutoZhaoCombination = require("app.FightSystem.FightSkill.AutoZhao.BasicFightAutoZhaoCombination")
        self.__combList = {}
        local list = BasicSkillManager:getBasicSkillAutoZhaoCombinations(self:getId())

        for _, v in ipairs(list) do
            table.insert(self.__combList, BasicFightAutoZhaoCombination:create(v, self.__character, self))
        end

        table.sort(
            self.__combList,
            function(a, b)
                return a:getZhaoId() < b:getZhaoId()
            end
        )
    end

    return self.__combList
end

function BasicFightSkill:__walkAllAutoZhaoComb(func)
    for _, v in ipairs(self:getAutoZhaoCombs()) do
        func(v)
    end
end

--@desc: 获取符合最高等级的招式comb
--@author:LvBin
--@time:2022-01-11 17:44:19
--@return [src.app.FightSystem.FightSkill.AutoZhao.BasicFightAutoZhaoCombination#BasicFightAutoZhaoCombination]
function BasicFightSkill:getAutoZhaoCombByLvMax()
    local list = self:__getMatchCombList()

    return list[table.getn(list)]
end

function BasicFightSkill:isFamily(familyId)
    -- 如果为空，则不属于任意门派
    if table.getn(self.__basicSkill:getFamilies()) <= 0 then
        return false
    end

    for _, id in ipairs(self.__basicSkill:getFamilies()) do
        if id == familyId then
            return true
        end
    end

    return false
end

return class("BasicFightSkill", {}, BasicFightSkill)
00000000000
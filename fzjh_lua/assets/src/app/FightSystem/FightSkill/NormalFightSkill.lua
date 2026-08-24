--[[
    战斗武学基类
]]
local class = require("third.class.NewClass")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local AutoZhaoCombination = require("app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination")

local NormalSkillBattleQuality = require("app.FightSystem.FightSkill.NormalSkillBattleQuality")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local SKILL_THIRD_TYPE = SkillConst.SkillThirdType

local FightCommons = require("app.FightSystem.FightCommons")

local HIT_POS = FightCommons.HIT_POS

--@desc 存放被动技能对应的招式组合
local d_zhaoComb = {}

--@region 初始化 资源信息
local initAutoZhaoCombRes = function()
    local zhaoComb_res = require("script.newbattle.demo.autoZhaoComb")["被动招式"]

    for _, comb_data in pairs(zhaoComb_res) do
        if comb_data.skillId == nil then
            assert(false, "武功被动招式组合填写错误：[id: " .. comb_data.id .. "] 所属武学ID未填写")
        end

        if d_zhaoComb[comb_data.skillId] == nil then
            d_zhaoComb[comb_data.skillId] = {}
        end

        table.insert(d_zhaoComb[comb_data.skillId], comb_data)
    end
end
initAutoZhaoCombRes()
--@endregion

local NormalFightSkill = {
    __id = 0,
    --@Deprecated (后续要废除，非必要不要使用)
    __type = 2,
    --@desc 武学描述
    __dsc = "",
    --@desc 武学名颜色
    __nameColor = "",
    __name = "拳",
    --@desc 入场动画，0 表示没有
    __battleJoinAnim = 0,
    --@desc 站立动画（待机动画，非攻击动画为0）
    __battleIdleAnim = 0,
    --@desc 跳跃动画（攻击准备动画。非攻击动画为0）
    __battleRunAnim = 0,
    --@desc 跳回动画（返回动画，非攻击动画为0）
    __battleBackAnim = 0,
    --@desc 该武学在招架时对应的class，根据攻击部位获取
    __parryClass = {},
    --@desc 该武学在闪避时对应的class，根据攻击部位获取
    __dodgeClass = {},
    --@desc 武学类型（对应 SkillClassifyManager 的武学分类）
    __skillType = {},
    __weaponTypes = {},
    --@desc 主动技能id列表：[]
    __activeZhaos = {},
    __battleQuality = 100,
    __level = 0,
    __families = {}
}

--@desc: 创建方法
--@author:Seven
--@time:2021-05-29 14:37:37
--@return [src.app.FightSystem.FightSkill.NormalFightSkill#NormalFightSkill]
function NormalFightSkill:create()
    return NormalFightSkill.new()
end

function NormalFightSkill:ctor()
    for _, hitPos in pairs(HIT_POS) do
        self.__parryClass[hitPos] = {}
        self.__dodgeClass[hitPos] = {}
    end
end

function NormalFightSkill:getId()
    return self.__id
end

function NormalFightSkill:getName()
    return self.__name
end

function NormalFightSkill:getType()
    return self.__type
end

function NormalFightSkill:getDsc()
    return self.__dsc
end

function NormalFightSkill:getNameColor()
    return self.__nameColor
end

function NormalFightSkill:__isfirstTypeSkill(firstType)
    for _, classifyId in ipairs(self.__skillType) do
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

function NormalFightSkill:isAttackSkill()
    if self:isBingQiSkill() or self:isQuanJiaoSkill() then
        return true
    end

    return false
end

function NormalFightSkill:isBingQiSkill()
    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.BING_QI) then
        return true
    end

    return false
end

function NormalFightSkill:isQuanJiaoSkill()
    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.QUAN_JIAO) then
        return true
    end

    return false
end

function NormalFightSkill:isNeiGongSkill()
    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.NEI_GONG) then
        return true
    end

    return false
end

function NormalFightSkill:isDodgeSkill()
    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.QING_GONG) then
        return true
    end

    return false
end

function NormalFightSkill:isParrySkill()
    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.ZHAO_JIA) then
        return true
    end

    return false
end

--@desc: 是否可用的武器类型
--@author:Seven
--@time:2021-05-27 20:30:39
--@weapon_type: 武器类型（子类型）
function NormalFightSkill:isUseWeaponType(weapon_type)
    if MapIsEmpty(self.__weaponTypes) then
        return false
    end

    for _, t_weapon in ipairs(self.__weaponTypes) do
        if tonumber(t_weapon) == tonumber(weapon_type) then
            return true
        end
    end

    return false
end

function NormalFightSkill:getBattleJoinAnim()
    return self.__battleJoinAnim
end

function NormalFightSkill:getBattleIdleAnim()
    return self.__battleIdleAnim
end

function NormalFightSkill:getBattleRunAnim()
    return self.__battleRunAnim
end

function NormalFightSkill:getBattleBackAnim()
    return self.__battleBackAnim
end

function NormalFightSkill:addParryClass(hit_pos, parry_class)
    if self.__parryClass[hit_pos] == nil then
        assert(false, "武学id: " .. self.__id .. "添加parry class出错，没有该对应部位：" .. hit_pos)
    end

    table.insert(self.__parryClass[hit_pos], parry_class)
end

--@desc: 获取格挡信息
--@author:Seven
--@time:2021-06-07 16:09:15
--@hit_pos: [src.app.FightSystem.FightCommons#FightCommons.HIT_POS]
--@return [src.app.FightSystem.FightSkill.NormalFightParryClass#NormalFightParryClass]
function NormalFightSkill:getParryClass(hit_pos)
    local parry_array = self.__parryClass[hit_pos]

    if MapIsEmpty(parry_array) then
        assert(false, "武学id：" .. self.__id .. " 格挡资源对应部位 ： " .. hit_pos .. " 为空。")
    end

    if #parry_array > 1 then
        local index = FightUtil:random(1, #parry_array)
        return parry_array[index]
    else
        return parry_array[1]
    end
end

function NormalFightSkill:getParryClasses()
    return self.__parryClass
end

function NormalFightSkill:addDodgeClass(hit_pos, dodge_class)
    if self.__dodgeClass[hit_pos] == nil then
        assert(false, "武学id: " .. self.__id .. "添加dodge class出错，没有该对应部位：" .. hit_pos)
    end
    table.insert(self.__dodgeClass[hit_pos], dodge_class)
end

--@desc: 获取闪避信息
--@author:Seven
--@time:2021-06-07 16:10:38
--@hit_pos: [src.app.FightSystem.FightCommons#FightCommons.HIT_POS]
--@return [src.app.FightSystem.FightSkill.NormalFightDodgeClass#NormalFightDodgeClass]
function NormalFightSkill:getDodgeClass(hit_pos)
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

function NormalFightSkill:getDodgeClasses()
    return self.__dodgeClass
end

--@desc: 获取武学用的主动技能id列表
--@author:Seven
--@time:2021-06-24 14:54:03
function NormalFightSkill:getActiveZhaos()
    return self.__activeZhaos
end

function NormalFightSkill:loadFromRes(res_data)
    self.__id = res_data.id

    self.__name = assert(res_data.name, "武学 id : " .. res_data.id .. "武学名字未填")

    self.__type = assert(res_data.type, "武学 id : " .. res_data.id .. "武学类型未填")

    self.__battleQuality = assert(res_data.battleQuality, "武学 id : " .. res_data.id .. "武学战斗属性品质未填")

    self.__dsc = assert(res_data.dsc, "武学 id : " .. res_data.id .. "武学描述未填")

    self.__nameColor = assert(res_data.nameColor, "武学 id : " .. res_data.id .. "武学颜色未填")

    self.__battleJoinAnim = assert(tonumber(res_data.battleJoinAnim), "武学 id : " .. res_data.id .. "入场动画填写错误")
    self.__battleIdleAnim = assert(tonumber(res_data.battleIdleAnim), "武学 id : " .. res_data.id .. "待机（站立）动画填写错误")
    self.__battleRunAnim = assert(tonumber(res_data.battleRunAnim), "武学 id : " .. res_data.id .. "跳跃（攻击准备）动画填写错误")
    self.__battleBackAnim = assert(tonumber(res_data.battleBackAnim), "武学 id : " .. res_data.id .. "跳回（返回）动画填写错误")

    local skillTypeList = string.split(res_data.skillType, "#")
    if MapIsEmpty(skillTypeList) == false then
        for _, skillClassifyId in ipairs(skillTypeList) do
            table.insert(self.__skillType, skillClassifyId)
        end
    else
        assert(false, "武学 id :" .. res_data.id .. " 的 skillType 解析错误")
    end

    if res_data.weaponTypes then
        local list = string.split(res_data.weaponTypes, "#")
        if MapIsEmpty(list) == false then
            for _, __weapon in ipairs(list) do
                table.insert(self.__weaponTypes, __weapon)
            end
        else
            assert(false, "武学 id :" .. res_data.id .. " 的 weaponTypes 解析错误")
        end
    end

    if res_data.activeZhaos ~= nil then
        local actId_list = string.split(res_data.activeZhaos, "#")
        for i, v in ipairs(actId_list) do
            table.insert(self.__activeZhaos, v)
        end
    end

    if self:__isfirstTypeSkill(SKILL_FIRST_TYPE.BING_QI) and self:__isfirstTypeSkill(SKILL_FIRST_TYPE.QUAN_JIAO) then
        assert(false, "武学技能 id : " .. res_data.id .. "武学类型不可有兵器与拳脚共存")
    end

    self.__battleQualityClass = NormalSkillBattleQuality:create(self.__battleQuality)

    if res_data ~= nil then
        self.__families = string.split(res_data.familyId, "#")
    end
end

function NormalFightSkill:getBattleQualityClass()
    return self.__battleQualityClass
end

--@region 动态属性
function NormalFightSkill:setLevel(lv)
    if lv <= 0 then
        assert(false, "NormalFightSkill 技能等级不可小于1 ！value:" .. lv)
    end

    self.__level = lv
end

function NormalFightSkill:getLevel()
    return self.__level
end
--@endregion

-- 获取转换后的武学类型一
function NormalFightSkill:getClassifyFirstTypes()
    local array = {}
    for _, classifyId in ipairs(self.__skillType) do
        local skillFirstType = SkillClassifyManager:getClassifyFirstType(classifyId)
        if skillFirstType == nil then
            assert(false, "武学 id：" .. self:getId() .. "武学类型：" .. classifyId .. "无法获取武学第一分类信息，请检查是否填写正确。")
        end

        table.insert(array, skillFirstType)
    end

    return array
end

--@desc 获取转换后的武学类型二
function NormalFightSkill:getClassifySecondTypes()
    local array = {}
    for _, classifyId in ipairs(self.__skillType) do
        local skillSecondType = SkillClassifyManager:getClassifySecondType(classifyId)
        if skillSecondType == nil then
            assert(false, "武学 id：" .. self:getId() .. "武学类型：" .. classifyId .. "无法获取武学第二分类信息，请检查是否填写正确。")
        end
        table.insert(array, skillSecondType)
    end
    return array
end

--@desc 获取转换后的武学类型三
function NormalFightSkill:getClassifyThirdTypes()
    local array = {}
    for _, classifyId in ipairs(self.__skillType) do
        local skillThirdType = SkillClassifyManager:getClassifyThirdType(classifyId)
        if skillThirdType == nil then
            assert(false, "武学 id：" .. self:getId() .. "武学类型：" .. classifyId .. "无法获取武学第三分类信息，请检查是否填写正确。")
        end
        table.insert(array, skillThirdType)
    end
    return array
end

function NormalFightSkill:getWeaponTypes()
    return self.__weaponTypes
end

--@desc: 获取随机武功被动招式组合对象
--@author:LvBin
--@time:2022-01-11 17:33:25
--@return [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination#AutoZhaoCombination]
function NormalFightSkill:getAttackAutoZhaoComb()
    local random_list = self:__getMatchCombResList()

    if MapIsEmpty(random_list) then
        assert(false, "NormalFightSkill:getAttackAutoZhaoComb 技能id:" .. self:getId() .. "，等级lv:" .. self:getLevel() .. " 无法获取可用招式组合！")
    end

    local index = FightUtil:random(1, #random_list)

    local comb_res = random_list[index]

    --@RefType[src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination#AutoZhaoCombination]
    local zhao_comb = AutoZhaoCombination:create()

    zhao_comb:loadFromRes(comb_res)

    return zhao_comb
end

--[[
    @desc: 获得满足出招条件的被动招式资源信息
    author:Seven
    time:2021-06-27 01:04:31
    --@skill_id:
	--@skill_lv: 
    @return:
]]
function NormalFightSkill:__getMatchCombResList()
    local skill_id = self:getId()

    local skill_lv = self:getLevel()

    local skillCombs_res = d_zhaoComb[skill_id]

    if MapIsEmpty(skillCombs_res) then
        assert(false, "技能id：" .. tostring(skill_id) .. ",没有该技能id对应的招式组合")
    end

    local list = {}
    for _, info in ipairs(skillCombs_res) do
        if info.lv <= skill_lv then
            table.insert(list, info)
        end
    end

    table.sort(
        list,
        function(a, b)
            return a.zhaoId < b.zhaoId
        end
    )

    return list
end

--@desc: 获取武功被动招式组合对象列表
--@author:LvBin
--@time:2022-01-11 17:32:21
--@return [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination#AutoZhaoCombination]
function NormalFightSkill:getAutoZhaoCombs()
    local skill_id = self:getId()

    local skillComb_res = d_zhaoComb[skill_id]

    if MapIsEmpty(skillComb_res) then
        assert(false, "技能id：" .. tostring(skill_id) .. ",没有该技能id对应的招式组合")
    end

    local zhao_combs = {}

    for i, v in ipairs(skillComb_res) do
        --@RefType[src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination#AutoZhaoCombination]
        local zhao_comb = AutoZhaoCombination:create()
        zhao_comb:loadFromRes(v)
        table.insert(zhao_combs, zhao_comb)
    end

    return zhao_combs
end

--@desc: 获取符合最高等级的招式comb
--@author:LvBin
--@time:2022-01-11 17:44:19
--@return [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination#AutoZhaoCombination]
function NormalFightSkill:getAutoZhaoCombByLvMax()
    local skill_id = self:getId()

    local skill_lv = self:getLevel()

    local list = self:__getMatchCombResList()

    local comb_res = list[#list]

    --@RefType[src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination#AutoZhaoCombination]
    local zhao_comb = AutoZhaoCombination:create()

    zhao_comb:loadFromRes(comb_res)

    return zhao_comb
end

function NormalFightSkill:isFamily(familyId)
    -- 如果为空，则不属于任意门派
    if table.getn(self.__families) <= 0 then
        return false
    end

    for _, id in ipairs(self.__families) do
        if id == familyId then
            return true
        end
    end

    return false
end

function NormalFightSkill:getSkillTypes()
    return self.__skillType
end

return class("NormalFightSkill", {}, NormalFightSkill)
00
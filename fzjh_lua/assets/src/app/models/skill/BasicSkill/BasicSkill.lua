--[[
    author:Seven
    time:2022-09-19 16:43:59
    desc: 新版武学基础类
]]
local newClass = require("third.class.NewClass")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local SKILL_THIRD_TYPE = SkillConst.SkillThirdType

local BasicSkill = {}

function BasicSkill:create(res)
    local p = BasicSkill.new()
    p:__init(res)
    return p
end

function BasicSkill:__init(res)
    self.__res = res
    assert(self.__res.name, "武学 id : " .. self.__res.name .. "武学名字未填")
    assert(self.__res.type, "武学 id : " .. self.__res.id .. "武学类型未填")
    assert(self.__res.battleQuality, "武学 id : " .. self.__res.id .. "武学战斗属性品质未填")
    assert(self.__res.dsc, "武学 id : " .. self.__res.id .. "武学描述未填")
    assert(self.__res.nameColor, "武学 id : " .. self.__res.id .. "武学颜色未填")

    assert(tonumber(self.__res.battleJoinAnim), "武学 id : " .. self.__res.id .. "入场动画填写错误")
    assert(tonumber(self.__res.battleIdleAnim), "武学 id : " .. self.__res.id .. "待机（站立）动画填写错误")
    assert(tonumber(self.__res.battleRunAnim), "武学 id : " .. self.__res.id .. "跳跃（攻击准备）动画填写错误")
    assert(tonumber(self.__res.battleBackAnim), "武学 id : " .. self.__res.id .. "跳回（返回）动画填写错误")

    if BasicSkill.IsFirstTypeSkill(self:getId(), self:getSkillType(), SKILL_FIRST_TYPE.BING_QI) and BasicSkill.IsFirstTypeSkill(self:getId(), self:getSkillType(), SKILL_FIRST_TYPE.QUAN_JIAO) then
        assert(false, "武学技能 id : " .. self.__res.id .. "武学类型不可有兵器与拳脚共存")
    end
end

--@desc: static function 判断是否武学一类型
--@author:Seven
--@time:2022-09-19 18:10:41
--@id: 武学id
--@firstType: 武学一类型
--@return: true | false
function BasicSkill.IsFirstTypeSkill(id, skillTypes, firstType)
    for _, classifyId in ipairs(skillTypes) do
        local skillFirstType = SkillClassifyManager:getClassifyFirstType(tostring(classifyId))
        if skillFirstType == nil then
            assert(false, "武学 id：" .. id .. "武学类型：" .. classifyId .. "无法获取武学第一分类信息，请检查是否填写正确。")
        end

        if firstType == skillFirstType then
            return true
        end
    end

    return false
end

--@desc: 判断武学分类id是否为攻击武学分类
--@author:Seven
--@time:2022-09-20 17:14:33
--@classifyId: 武学分类id
function BasicSkill.IsAttackType(classifyId)
    local skillFirstType = SkillClassifyManager:getClassifyFirstType(tostring(classifyId))
    
    if skillFirstType == SKILL_FIRST_TYPE.QUAN_JIAO or skillFirstType == SKILL_FIRST_TYPE.BING_QI then
        return true
    end

    return false
end

--@desc 武学ID
function BasicSkill:getId()
    return self.__res.id
end

--@desc 名称颜色
function BasicSkill:getNameColor()
    return self.__res.nameColor
end

--@desc 武功名称
function BasicSkill:getName()
    return self.__res.name
end

--@desc 武学类型
function BasicSkill:getSkillType()
    if self.__skillTypes then
        return self.__skillTypes
    end

    self.__skillTypes = {}

    local skillTypes = string.split(self.__res.skillType, "#")
    if MapIsEmpty(skillTypes) == false then
        for _, skillClassifyId in ipairs(skillTypes) do
            table.insert(self.__skillTypes, skillClassifyId)
        end
    else
        assert(false, "武学 id :" .. self.__res.id .. " 的 skillType 解析错误")
    end
    return self.__skillTypes
end

function BasicSkill:getClassifyFirstTypes()
    local array = {}
    for _, classifyId in ipairs(self:getSkillType()) do
        local skillFirstType = SkillClassifyManager:getClassifyFirstType(classifyId)
        if skillFirstType == nil then
            assert(false, "武学 id：" .. self:getId() .. "武学类型：" .. classifyId .. "无法获取武学第一分类信息，请检查是否填写正确。")
        end

        table.insert(array, skillFirstType)
    end

    return array
end

function BasicSkill:getClassifySecondTypes()
    local array = {}
    for _, classifyId in ipairs(self:getSkillType()) do
        local skillSecondType = SkillClassifyManager:getClassifySecondType(classifyId)
        if skillSecondType == nil then
            assert(false, "武学 id：" .. self:getId() .. "武学类型：" .. classifyId .. "无法获取武学第二分类信息，请检查是否填写正确。")
        end
        table.insert(array, skillSecondType)
    end
    return array
end

function BasicSkill:getClassifyThirdTypes()
    local array = {}
    for _, classifyId in ipairs(self:getSkillType()) do
        local skillThirdType = SkillClassifyManager:getClassifyThirdType(classifyId)
        if skillThirdType == nil then
            assert(false, "武学 id：" .. self:getId() .. "武学类型：" .. classifyId .. "无法获取武学第三分类信息，请检查是否填写正确。")
        end
        table.insert(array, skillThirdType)
    end
    return array
end

--@desc 原武功表武学类型
--@Deprecated (后续要废除，非必要不要使用)
function BasicSkill:getType()
    return self.__res.type
end

--@desc 武功描述
function BasicSkill:getDsc()
    return self.__res.dsc
end

--@desc 对应可使用兵器类型
function BasicSkill:getWeaponTypes()
    if self.__weponTypes == nil then
        local weaponTypes = {}
        if self.__res.weaponTypes then
            local list = string.split(self.__res.weaponTypes, "#")
            if MapIsEmpty(list) == false then
                for _, __weapon in ipairs(list) do
                    table.insert(weaponTypes, __weapon)
                end
            else
                assert(false, "武学 id :" .. self.__res.id .. " 的 weaponTypes 解析错误")
            end
        end
        self.__weponTypes = weaponTypes
    end
    
    return self.__weponTypes
end

--@desc 武学入场动画
function BasicSkill:getBattleJoinAnim()
    return tonumber(self.__res.battleJoinAnim)
end

--@desc 武学待机动画
function BasicSkill:getBattleIdleAnim()
    return tonumber(self.__res.battleIdleAnim)
end

--@desc 武学攻击前跳动画
function BasicSkill:getBattleRunAnim()
    return tonumber(self.__res.battleRunAnim)
end

--@desc 武学攻击后跳动画
function BasicSkill:getBattleBackAnim()
    return tonumber(self.__res.battleBackAnim)
end

--@desc 武学招架系列
function BasicSkill:getParryClass()
    return self.__res.parryClass
end

--@desc 武学轻功系列
function BasicSkill:getDodgeClass()
    return self.__res.dodgeClass
end

--@desc 武学携带主动招式
function BasicSkill:getActiveZhaos()
    local activeZhaos = {}
    if self.__res.activeZhaos ~= nil then
        local actId_list = string.split(self.__res.activeZhaos, "#")
        for i, v in ipairs(actId_list) do
            table.insert(activeZhaos, v)
        end
    end

    return activeZhaos
end

--@desc 武学战斗属性品质
function BasicSkill:getBattleQuality()
    return self.__res.battleQuality
end

--@desc 所属门派ID
function BasicSkill:getFamilies()
    local families = {}
    if self.__res.familyId ~= nil then
        families = string.split(self.__res.familyId, "#")
    end
    return families
end

function BasicSkill:getAutoZhaoAtkDamageClass()
    return tostring(self.__res.autoZhaoAtkDamageClass)
end

function BasicSkill:getZhaoJiaDefDamageClass()
    return tostring(self.__res.zhaoJiaDefDamageClass)
end

function BasicSkill:getZhaoJiaDefDamageParam()
    return self.__res.zhaoJiaDefDamageParam
end

return newClass("BasicSkill", {}, BasicSkill)
0000000000000
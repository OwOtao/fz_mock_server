--[[
    author:Seven
    time:2023-03-16 17:43:38
    desc: 该类用于统计攻击禁止使用的相关功能
]]
local newClass = require("third.class.NewClass")

-- methods 值 → 禁用类型ID 映射（模块级常量，只创建一次）
-- 对应表[武功主动招式组合].主动招式使用对应准备武学类型;methods
local METHODS_BAN_TYPE_MAP = {
    [1] = 11, [5] = 11,  -- 武学攻击准备位
    [2] = 12,             -- 武学内功准备位
    [3] = 13,             -- 武学轻功准备位
    [4] = 14              -- 武学招架准备位
}

local BanSkillAttackFuncMap = {}

function BanSkillAttackFuncMap:create()
    return BanSkillAttackFuncMap.new()
end

function BanSkillAttackFuncMap:ctor()
    self.__indexId = 10

    self.__banAutoArray = {}

    self.__banActiveMap = {
        --@desc 任意主动类型
        ["0"] = {},
        --@desc 1=主动招式攻击类
        ["1"] = {},
        --@desc 2=主动招式释放类
        ["2"] = {},
        --@desc 11=武学攻击准备位的主动（methods=1或5）
        ["11"] = {},
        --@desc 12=武学内功准备位的主动（methods=2）
        ["12"] = {},
        --@desc 13=武学轻功准备位的主动（methods=3）
        ["13"] = {},
        --@desc 14=武学招架准备位的主动（methods=4）
        ["14"] = {}
    }
end

function BanSkillAttackFuncMap:__getNewId()
    self.__indexId = self.__indexId + 1
    return self.__indexId
end

function BanSkillAttackFuncMap:__getActiveBanArray(activeType)
    local array = self.__banActiveMap[tostring(activeType)]

    if array == nil then
        error(" BanSkillAttackFuncMap:__getActiveBanArray activeType 错误：" .. tostring(activeType))
    end

    return array
end

function BanSkillAttackFuncMap:addBanActiveSkill(activeType, tips)
    local info = {
        id = self:__getNewId(),
        activeType = activeType,
        tip = tips
    }

    table.insert(self:__getActiveBanArray(activeType), info)

    return info.id
end

function BanSkillAttackFuncMap:removeBanActiveSkill(activeType, indexId)
    local removeIndex

    for i, v in ipairs(self:__getActiveBanArray(activeType)) do
        if v.id == indexId then
            removeIndex = i
            break
        end
    end

    local removeInfo = table.remove(self:__getActiveBanArray(activeType), removeIndex)

    return removeInfo
end

function BanSkillAttackFuncMap:isBanActiveSkill(activeType)
    local array = self:__getActiveBanArray("0")

    if table.getn(array) <= 0 then
        array = self:__getActiveBanArray(activeType)
    end

    if table.getn(array) <= 0 then
        return false
    end

    local info = array[1]

    return true, info.tip
end

-- 静态方法：根据 methods 值获取对应的禁用类型ID
function BanSkillAttackFuncMap.getMethodsBanTypeId(methods)
    return METHODS_BAN_TYPE_MAP[methods]
end

function BanSkillAttackFuncMap:addBanAutoSkill(tips)
    local info = {
        id = self:__getNewId(),
        tips = tips
    }
    table.insert(self.__banAutoArray, info)
    return info.id
end

function BanSkillAttackFuncMap:isBanAutoSkill()
    if table.getn(self.__banAutoArray) <= 0 then
        return false
    end

    local info = self.__banAutoArray[1]

    return true, info.tip
end

function BanSkillAttackFuncMap:removeBanAutoAttack(id)
    local removeIndex

    for i, v in ipairs(self.__banAutoArray) do
        if v.id == id then
            removeIndex = i
            break
        end
    end

    local removeInfo = table.remove(self.__banAutoArray, removeIndex)

    return removeInfo
end

return newClass("BanSkillAttackFuncMap", {}, BanSkillAttackFuncMap)
0000000000000000
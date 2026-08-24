--[[
    武器分类管理.xlsx

    关联武器类型、皮肤模组、匹配武学类型等信息。
]]
local weaponTypesRes = require("script.newbattle.demo.weaponTypesRes")["武器分类"]
local weaponAndItem = {}
local weaponFirstTypeForSkillPrepType = {}

local WeaponTypesResManager = {}

--@desc: 初始化武器分类 与武器物品间的关系
--@author:Seven
--@time:2021-05-29 17:27:41
local function initWeaponAndItemRelation()
    for id, weapon_res in pairs(weaponTypesRes) do
        weaponAndItem[weapon_res.firstType .. "|" .. weapon_res.secondTypeId] = weapon_res
    end
end

initWeaponAndItemRelation()

--@desc: 初始化武器对应的武学准备类型（角色武学准备的类型跟武器第一类型绑定是绑定关系）
--@author:Seven
--@time:2022-10-10 15:56:11
local function initWeaponFirstTypeToPrepSkill()
    for id, weapon_res in pairs(weaponTypesRes) do
        if weaponFirstTypeForSkillPrepType[weapon_res.firstType] ~= nil then
            if weaponFirstTypeForSkillPrepType[weapon_res.firstType] ~= weapon_res.autoChooseSkill then
                assert(false, "武器一类型只能绑定一种武学准备类型，请检查资源")
            end
        else
            weaponFirstTypeForSkillPrepType[weapon_res.firstType] = weapon_res.autoChooseSkill
        end
    end
end

initWeaponFirstTypeToPrepSkill()

function WeaponTypesResManager:getWeaponInfo(id)
    local res = weaponTypesRes[tostring(id)]

    if res == nil then
        assert(false, "没有该武器分类信息 id:" .. id)
    end

    return res
end

function WeaponTypesResManager:getEmptyHandedId()
    return weaponAndItem["空手|1"]
end

function WeaponTypesResManager:getWeaponResIdByTypeAndType2(type, type2)
    local res = self:getWeaponInfoByTypeAndType2(type, type2)

    return res.id
end

function WeaponTypesResManager:getWeaponInfoByTypeAndType2(type, type2)
    local res = weaponAndItem[type .. "|" .. type2]

    if res == nil then
        assert(false, "武器一类型：" .. type .. "和武器二类型：" .. type2 .. " 无法找到武器分类对应的相关信息")
    end

    return res
end

function WeaponTypesResManager:itemIsWeaponType(type, type2)
    if type == nil or type2 == nil then
        return false
    end

    return weaponAndItem[type .. "|" .. type2] ~= nil
end

--@desc: 根据武器物品id获取武器相关资源信息id（仅仅适用与物品表中的武器）
--@author:Seven
--@time:2021-06-23 14:24:09
--@weapon_item_id: 武器物品id
function WeaponTypesResManager:getWeaponResId(weapon_item_id)
    local item = Item:getOneItemByKey(weapon_item_id)

    if item == nil then
        assert(false, " WeaponTypesResManager:getWeaponResId 没有该物品：" .. weapon_item_id)
    end

    local res = weaponAndItem[item:getItemAttr("type") .. "|" .. item:getCurrWeaponType2()]

    if res == nil then
        assert(false, "物品id：" .. weapon_item_id .. "无法找到武器分类对应的相关信息")
    end

    return res.id
end

function WeaponTypesResManager:getWeaponResIdByItem(item)
    if item == nil then
        assert(false, " WeaponTypesResManager:getWeaponResId 没有该物品：" .. item:getId())
    end

    local res = weaponAndItem[item:getItemAttr("type") .. "|" .. item:getCurrWeaponType2()]

    if res == nil then
        assert(false, "物品id：" .. item:getId() .. "无法找到武器分类对应的相关信息")
    end

    return res.id
end

function WeaponTypesResManager:getWeaponFirstTypeForSkillPrepType()
    return weaponFirstTypeForSkillPrepType
end

function WeaponTypesResManager:getSecondTypeNameBySecondUseType(secondUseType)
    if secondUseType == nil then
        assert(false, " WeaponTypesResManager:getSecondTypeNameBySecondUseType 参数异常：" .. secondUseType)
    end

    for id, weapon_res in pairs(weaponTypesRes) do
        if secondUseType == weapon_res.secondUseType then
            return weapon_res.secondTypeName
        end
    end

    assert(false, "武学调用兵器二级类型:" .. secondUseType .. "不存在")
end

function WeaponTypesResManager:getAllSecondTypeNameByFirstType(firstType)
    if firstType == nil then
        assert(false, " WeaponTypesResManager:getAllSecondTypeNameByFirstType 参数异常：" .. firstType)
    end

    local secondTypeName = {}
    for id, weapon_res in pairs(weaponTypesRes) do
        if firstType == weapon_res.firstType then
            table.insert(secondTypeName, weapon_res.secondTypeName)
        end
    end

    if MapIsEmpty(secondTypeName) then
        assert(false, "该武器一级分类:" .. firstType .. "资源不存在")
    end
    
    return secondTypeName
end

return WeaponTypesResManager
0000
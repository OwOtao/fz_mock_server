local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local WeaponPrepareTrigger = {}
--[[
    准备武器触发（暂无）
    参数1;arg1
        判断条件目标（自己/目标）
    参数2;arg2
        满足条件的武器子类型，用于判断与当前目标准备的武器类型是否一致(多个用【#】进行间隔)
    参数3;arg3
        满足条件时生效的效果id
]]

function WeaponPrepareTrigger:create(effect)
    local p = WeaponPrepareTrigger.new()
    p:init(effect)
    return p
end

function WeaponPrepareTrigger:checkArg1()
    local value = self.__effect:getArg1()

    if value == EffectCheckConst.EffectTargetValue.Owner or value == EffectCheckConst.EffectTargetValue.Target then
        return true
    end

    return false, "arg1值异常，目标值填写错误，arg1:"..tostring(value)
end

function WeaponPrepareTrigger:checkArg2()
    local value = self.__effect:getArg2()

    local map = {["daofa"] = "刀", ["jianfa"] = "剑", ["anqi"] = "暗器", ["gunfa"] = "棍", ["bianfa"] = "鞭", ["shuangchi"] = "双持", ["qinfa"] = "乐器"}

    local weaponList = string.split(value, "#")

    local isTrue = true

    for i, v in ipairs(weaponList) do
        local result = false

        for value, wtype in pairs(map) do
            
            if string.find(v, value) then
                local subType = string.gsub(v, value, "")
                local subTypeMap = Item.ITEM_TYPE[wtype]

                for __, _subType in pairs(subTypeMap) do
                    if subType == _subType then
                        result = true
                    end
                end
            end
        end

        if result == false then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg2值异常，武器子类型找不到，arg2:"..tostring(value)
end

function WeaponPrepareTrigger:checkArg3()
    local value = self.__effect:getArg3()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end

    return false, "arg3值异常，触发效果找不到，arg3:"..tostring(value)
end

return newClass("WeaponPrepareTrigger", {BaseCheck}, WeaponPrepareTrigger)
00000000
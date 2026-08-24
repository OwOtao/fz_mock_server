local SkillEffectCheckError = {}

local skillEffectMap = require("script.skill.activeZhao").Effect

local errorInfo = {}

local function isEffectId(effectId)
    if effectId == "CHIXIE" or effectId == "KONGSHOU" then
        return true
    end

    if skillEffectMap[effectId] then
        return true
    end

    return false
end

function SkillEffectCheckError:checkError(effect)
    self:__checkArgValueIsEffectId(effect)
    self:__checkArgValueIsTrue(effect)
end

function SkillEffectCheckError:getErrorInfo()
    return errorInfo
end

function SkillEffectCheckError:__checkArgValueIsEffectId(effect)
    local argValueCheck = {
        ["效果关联"] = function()
            if effect:getArg2() then
                local values = string.split(effect:getArg2(), ";")
                for i, value in ipairs(values) do
                    local effectIds = string.split(value, " or ")
                    for __, effectId in ipairs(effectIds) do
                        if effectId and tonumber(effectId) == nil then
                            if not isEffectId(effectId) then
                                table.insert(errorInfo, effect:getId().."效果关联参数arg2配置异常，异常数据："..effectId.."，参数："..effect:getArg2())
                            end
                        end
                    end
                end
            else
                table.insert(errorInfo, effect:getId().."效果关联参数arg2为空")
            end
            
            if effect:getArg3() then
                if not isEffectId(effect:getArg3()) then
                    table.insert(errorInfo, effect:getId().."效果关联参数arg3配置异常，参数："..effect:getArg3())
                end
            else
                table.insert(errorInfo, effect:getId().."效果关联参数arg3为空")
            end
        end,

        ["延时生效"] = function()
            if effect:getArg1() then
                if not isEffectId(effect:getArg1()) then
                    table.insert(errorInfo, effect:getId().."延时生效参数arg1配置异常，参数："..effect:getArg1())
                end
            else
                table.insert(errorInfo, effect:getId().."延时生效参数arg1为空")
            end
        end,

        ["效果切换"] = function()
            if effect:getArg1() then
                if not isEffectId(effect:getArg1()) then
                    table.insert(errorInfo, effect:getId().."效果切换参数arg1配置异常，参数："..effect:getArg1())
                end
            else
                table.insert(errorInfo, effect:getId().."效果切换参数arg1为空")
            end

            if effect:getArg3() then
                if not isEffectId(effect:getArg3()) then
                    table.insert(errorInfo, effect:getId().."效果切换参数arg3配置异常，参数："..effect:getArg3())
                end
            else
                table.insert(errorInfo, effect:getId().."效果切换参数arg3为空")
            end
        end,

        ["监控角色属性"] = function()
            if effect:getArg2() then
                local effectIds = string.split(effect:getArg2(), "#")
                for i, effectId in ipairs(effectIds) do
                    if not isEffectId(effectId) then
                        table.insert(errorInfo, effect:getId().."监控角色属性参数arg2配置异常，异常数据："..effectId.."，参数："..effect:getArg2())
                    end
                end
            else
                table.insert(errorInfo, effect:getId().."监控角色属性参数arg2为空")
            end
        end,

        ["标记触发"] = function()
            if effect:getArg1() then
                if not isEffectId(effect:getArg1()) then
                    table.insert(errorInfo, effect:getId().."标记触发参数arg1配置异常，参数："..effect:getArg1())
                end
            else
                table.insert(errorInfo, effect:getId().."标记触发参数arg1为空")
            end
        end,

        ["被动命中触发"] = function()
            if effect:getArg2() then
                if not isEffectId(effect:getArg2()) then
                    table.insert(errorInfo, effect:getId().."被动命中触发参数arg2配置异常，参数："..effect:getArg2())
                end
            else
                table.insert(errorInfo, effect:getId().."被动命中触发参数arg2为空")
            end
        end,

        ["招架触发"] = function()
            if not effect:getArg2() then
                table.insert(errorInfo, effect:getId().."招架触发 参数arg2为空")
            end
        end,

		["招架无效果触发"] = function()
            if not effect:getArg1() or not effect:getArg2() or not effect:getArg3() then
                table.insert(errorInfo, effect:getId().."招架无效果触发 参数异常")
            end
        end,

        ["属性条件触发"] = function()
            if effect:getArg2() then
                if not isEffectId(effect:getArg2()) then
                    table.insert(errorInfo, effect:getId().."属性条件触发参数arg2配置异常，参数："..effect:getArg2())
                end
            else
                table.insert(errorInfo, effect:getId().."属性条件触发参数arg2为空")
            end
        end,

        ["受击触发"] = function()
            if effect:getArg2() then
                if not isEffectId(effect:getArg2()) then
                    table.insert(errorInfo, effect:getId().."受击触发参数arg2配置异常，参数："..effect:getArg2())
                end
            else
                table.insert(errorInfo, effect:getId().."受击触发参数arg2为空")
            end
        end,

        ["闪避触发"] = function()
            if effect:getArg2() then
                if not isEffectId(effect:getArg2()) then
                    table.insert(errorInfo, effect:getId().."闪避触发参数arg2配置异常，参数："..effect:getArg2())
                end
            else
                table.insert(errorInfo, effect:getId().."闪避触发参数arg2为空")
            end
        end,

        ["无指定效果时触发"] = function()
            if effect:getArg2() then
                local effectIds = string.split(effect:getArg2(), " or ")
                for __, effectId in ipairs(effectIds) do
                    if effectId and tonumber(effectId) == nil then
                        if not isEffectId(effectId) then
                            table.insert(errorInfo, effect:getId().."无指定效果时触发参数arg2配置异常，异常数据："..effectId.."，参数："..effect:getArg2())
                        end
                    end
                end
            else
                table.insert(errorInfo, effect:getId().."无指定效果时触发参数arg2为空")
            end
            
            if effect:getArg3() then
                if not isEffectId(effect:getArg3()) then
                    table.insert(errorInfo, effect:getId().."无指定效果时触发参数arg3配置异常，参数："..effect:getArg3())
                end
            else
                table.insert(errorInfo, effect:getId().."无指定效果时触发参数arg3为空")
            end
        end,

        ["使用主动技能"] = function()
            if effect:getArg1() then
                if not isEffectId(effect:getArg1()) then
                    table.insert(errorInfo, effect:getId().."使用主动技能参数arg1配置异常，参数："..effect:getArg1())
                end
            else
                table.insert(errorInfo, effect:getId().."使用主动技能参数arg1为空")
            end
        end,
        
        ["主动碎盾"] = function()
            if effect:getArg2() then
                if not isEffectId(effect:getArg2()) then
                    table.insert(errorInfo, effect:getId().."主动碎盾参数arg2配置异常，参数："..effect:getArg2())
                end
            else
                table.insert(errorInfo, effect:getId().."主动碎盾参数arg2为空")
            end
        end,

		["效果判断触发"] = function()
			local arg2 = effect:getArg2()
            if arg2 then
                if string.find(arg2,"or") and string.find(arg2,"and") then
                    table.insert(errorInfo, effect:getId().."效果判断触发参数arg2配置异常，不能同时配置 and 和 or 。参数："..arg2)
                end
            else
                table.insert(errorInfo, effect:getId().."效果判断触发 参数arg2为空")
            end
        end,
    }

    if argValueCheck[effect:getType()] then
        argValueCheck[effect:getType()]()
    end
end

function SkillEffectCheckError:__checkArgValueIsTrue(effect)
    local effectParams = effect:getEffectParams()
    
    Helper:GetValueFromScript(effect:getArg1(), effectParams)
    Helper:GetValueFromScript(effect:getArg2(), effectParams)
    Helper:GetValueFromScript(effect:getArg3(), effectParams)
    Helper:GetValueFromScript(effect:getDuration(), effectParams)
end


return SkillEffectCheckError0000000
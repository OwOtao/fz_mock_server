local Module = require("third.module.Module")
local RoleModule = class("RoleModule", Module)

function RoleModule:ctor()
    -- 模块名
    self._name = "RoleModule"

    self._observableModule = self:addSubModuleWithPath("app.models.role.module.observable.RoleObservableModule")
    self._roleAttrModule = self:addSubModuleWithPath("app.models.role.module.attr.RoleAttrModule")

    -- 角色属性模块
    
    self:addSubModuleWithPath("app.models.role.module.RoleDefaultModule")

    self:addSubModuleWithPath("app.models.role.module.", "RoleModule_", "GetBaseAttr_", "GetDefault")
    self:addSubModuleWithPath("app.models.role.module.", "RoleModule_", "Buff")
    self:addSubModuleWithPath("app.models.role.module.", "RoleModule_", "GetBaseAttr_", "GetAtk")
    self:addSubModuleWithPath("app.models.role.module.", "RoleModule_", "GetBaseAttr_", "GetDef")
    self:addSubModuleWithPath("app.models.role.module.", "RoleModule_", "GetBaseAttr_", "GetFangHu")
    self:addSubModuleWithPath("app.models.role.module.", "RoleModule_", "GetBaseAttr_", "GetDodge")
    self:addSubModuleWithPath("app.models.role.module.", "RoleModule_", "GetBaseAttr_", "GetParry")
    self:addSubModuleWithPath("app.models.role.module.", "RoleModule_", "GetBaseAttr_", "GetDamage")
    self:addSubModuleWithPath("app.models.role.module.", "RoleModule_", "GetAttr_", "GetEffectAttr")
    self:addSubModuleWithPath("app.models.role.module.", "RoleModule_", "GetAttr_", "GetTotalAttr")
end

-- 获取基础属性
function RoleModule:getBaseAttr(target, name)
    local success, value = self:callFuncWithChainOfResponsibility("getBaseAttr", target, name)
    if success then
        return value
    end
    return target[name]
end

local AttrValueRule = {
    ["secStr"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["secDex"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["secCon"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["secInt"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["str"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["dex"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["con"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["int"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["currStr"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["currDex"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["currCon"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["currInt"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["qiMax"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["neiliMax"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["effectStr"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["effectDex"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["effectCon"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["effectInt"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["atk"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
    ["def"] = function (value)
        if value < 0 then
            value = 0
        end
        return value
    end,
}

-- 获取最终属性
function RoleModule:getFinalAttr(target, attrName)
    local value = target:getBaseAttr(attrName)

    if type(value) ~= "number" then
        return value
    end

    -- 属性加成 #TODO 此处getBuffAttr获取的是以前的加成，后续跟进处理
    value = value + self:callFuncAndSum("getBuffAttr", target, attrName)
    
    if target._buffManager ~= nil then
        value = value + target._buffManager:getEffecetValue(attrName)
        value = value * (Helper:getDef(target:getBaseAttr(attrName .. "Scale"), 1) + Helper:getDef(target._buffManager:getEffecetValue(attrName .. "Scale"), 0))
    end

    if AttrValueRule[attrName] ~= nil then
        value = AttrValueRule[attrName](value)
    end
    
    return value
end

-- 设置属性
function RoleModule:setAttr(target, name, var)
    target[name] = var
    target:dispatchEvent("setAttr", name, var)

    target:checkAttr(name) -- add by XiaoZhiWei 2017/02/24 17:33:15 检查属性关联变化
    if (User ~= nil and target == User:getRole()) or User == nil then -- add by XiaoZhiWei 2017/04/20 10:31:19 只有角色需要做此修复
        target:checkActiveZhaoIsDeblocking() -- add by XiaoZhiWei 2017/02/24 17:33:27 检查招式的解锁条件
    end
end

-- 获取属性
function RoleModule:getAttr(target, name)
    return target[name]
end

-- 获取属性值（取值为数字类型的属性值）
function RoleModule:getNumAttr(target, name)
    local attr = target:getFinalAttr(name)
    if type(attr) == "number" then
        if attr > 0 and attr < 1 then
            attr = 1
        end
        attr = Helper:mathFloor(attr)
    else
        return 0
    end
    return attr
end

-- 添加属性（只用于数字类型）
function RoleModule:addAttr(target, name, var)

    local attr = target[name]
    local attrType = type(attr)
    if attr and attrType == "number" and type(var) == attrType then
        -- 回复气血上限类药品
        do
            if name == "qiPercent" and var > 1 then
                local currQiMax = target:getCurrQiMax()
                local qiMax = target:getFinalAttr("qiMax")
                local currQiPercent = target:getAttr("qiPercent")
                local percent = (currQiMax + var) / qiMax
                var = percent - currQiPercent
            end
        end


        local addValue = var

        if addValue > 0 then
            addValue = addValue + Helper:getDef(target:getFinalAttr(name.."Recover"),0)
        end

        target[name] = attr + addValue
        target:dispatchEvent("addAttr", name, var)
        
        target:checkAttr(name)
        
        target:dispatchEvent("AttrChangeAfterEvent", {role = target, attrName = name})
    else
        -- assert(false, "function Role_Attr:addAttr("..tostring(name)..", "..tostring(var).."), type(var) = "..type(var)..", attrType = "..attrType)
        if PRINT_MODE == 1 then
            print("function Role_Attr:addAttr(" .. tostring(name) .. ", " .. tostring(var) .. "), type(var) = " .. type(var) .. ", attrType = " .. attrType)
        end
    end

end

function RoleModule:addBuff(target, buffid)
    if target._buffManager ~= nil then
        target._buffManager:addBuff(buffid)
    end
end

function RoleModule:removeBuff(target, buffid)
    if target._buffManager ~= nil then
        target._buffManager:removeBuff(buffid)
    end
end

-- 获得角色描述
function RoleModule:getDsc(target, role, isNeedAgeDesc, isNeedLookDesc, isNeedQiDesc)
    local ok, ret = self:callFuncWithChainOfResponsibility("getDsc", target, role, isNeedAgeDesc, isNeedLookDesc, isNeedQiDesc)
    assert(ok)
    return ret
end

-- @desc 副本战斗结束, 设置角色属性
function RoleModule:acceptMapFightResult(target, role, fightType)
    local ok, ret = self:callFuncWithChainOfResponsibility("acceptMapFightResult", target, role,fightType)
    assert(ok)
    return ret
end

-- 属性检测, 还可以拆
function RoleModule.checkAttr(module, self, name)
    -- 判断能否检测
    if module:canCheckAttr(self, name) == false then
        return
    end

    if name == "int" or name == "secInt" then
        self.currInt = self.int + self:getFinalAttr("secInt")
    end
    if name == "con" or name == "secCon" then
        self.currCon = self.con + self:getFinalAttr("secCon")
    end
    if name == "str" or name == "secStr" then
        self.currStr = self.str + self:getFinalAttr("secStr")
    end
    if name == "dex" or name == "secDex" then
        self.currDex = self.dex + self:getFinalAttr("secDex")
    end

    local ok = module:callFuncWithChainOfResponsibility("checkAttr", self, name)
    assert(ok)

    -- 非打坐状态内力不能超过最大值（打坐能够超出）
    if not self:isInCurrState(ROLE_CURR_STATE_DAZUO) then
        if name == "neili" and self.neili > self.neiliMax * 2 then
            self.neili = self.neiliMax * 2
        end
    end
end

-- 判断能否检测属性
function RoleModule:canCheckAttr(target, name)
    if target.AttrModifyId == "zhang" then
        -- add by XiaoZhiWei 2017/06/10 16:01:16 章作之不需要做属性检查
        return false
    else
    end

    --@desc 属性自身检查,能小于0的属性列表
    local attrList = {
        zhengqi = true,
        pijuan = true,
        officialAchievement = true,
    }
    -- print(name)
    if attrList[name] ~= true and type(target[name]) == "number" and target[name] < 0 then
        self:setAttr(target, name, 0)
        return false
    end
    return true
end

-- 角色属性初始化, 用来通过公式矫正角色属性
function RoleModule:initAttr(target)
    self:callFuncWithChainOfResponsibility("initAttr", target)
end

-- 可观测事件对象
function RoleModule:getObservable(target)
    return self._observableModule:getObservable(target)
end

-- 发送事件
function RoleModule:dispatchEvent(target, name, ...)
    self._observableModule:dispatchEvent(target, name, ...)
end

-- 初始化属性监控
function RoleModule:initAttrMonitor(target)
    self:callFuncWithChainOfResponsibility("initAttrMonitor", target)
end

-- 监控属性值变化
function RoleModule:watchAttrChange(target, attrName, onChange)
    return self._roleAttrModule:watchAttrChange(target, attrName, onChange)
end

-- 监控属性最终值变化
function RoleModule:watchFinalAttrChange(target, attrName, onChange)
    return self._roleAttrModule:watchFinalAttrChange(target, attrName, onChange)
end

function RoleModule:watchFinalAttrChangeWithDependMap(target, attrDependMap, attrWatchMap)
    return self._roleAttrModule:watchFinalAttrChangeWithDependMap(target, attrDependMap, attrWatchMap)
end

--@desc 监控角色所有属性变化
function RoleModule:watchAllFinalAttrChange(target, onChange)
	return self._roleAttrModule:watchAllFinalAttrChange(target, onChange)
end

return RoleModule
0000000
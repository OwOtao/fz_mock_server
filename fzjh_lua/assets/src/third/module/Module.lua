local Module = class("Module")

local log = function(...)
    -- if PRINT_MODE == 1 then
    --     print("Module:", ...)
    -- end
end

function Module:ctor()
    -- 模块名
    self._name = "Module"

    -- 附着对象
    self._target = nil

    -- 子模块
    self._subModules = nil
end

function Module:attach(target)
    assert(target ~= nil)

    if self._subModules ~= nil then
        for i = 1, #self._subModules do
            self._subModules[i]:attach(target)
        end
    end

    self._target = target
    if self.onAttach then
        self:onAttach(target)
    end
end

function Module:getName()
    return self._name
end

-- 通过require路径添加子模块
function Module:addSubModuleWithPath(...)
    local subModulePath = table.concat({...})

    local subModule = self:getSubModule(subModulePath)
    if subModule then
        log("子模块存在:", subModulePath)
        self:printInfo()
        return subModule
    end

    local subModule = require(subModulePath).new()
    return self:addSubModule(subModule)
end

-- 添加子模块
function Module:addSubModule(subModule)
    if self._subModules == nil then
        self._subModules = {}
    end

    if PRINT_MODE == 1 then
        print("添加模块:", subModule:getName(), self)
    end

    if self._target then
        subModule:attach(self._target)
    end

    table.insert(self._subModules, subModule)
    return subModule
end

-- 判断子模块是否存在
function Module:getSubModule(subModulePath)
    if self._subModules == nil then
        return nil
    end

    for i = 1, #self._subModules do
        local subModule = self._subModules[i]
        if subModule == subModulePath then
            return subModule
        end
    end
    return nil
end

-- 责任链方式调用子模块方法, 从后加入的子模块->先加入的子模块, 返回 true 表示处理, 后续子模块方法便不会继续调用, 返回 false 表示交给后续子模块调用
-- 子方法返回的第一个参数应该为 true 或 false
function Module:callFuncWithChainOfResponsibility(name, ...)
    if self._subModules ~= nil then
        local retParams = nil

        for i = #self._subModules, 1, -1 do
            local subModule = self._subModules[i]
            local func = subModule[name]
            if func ~= nil then -- 没有通过type判断是否为方法, 为了性能, 可判断是否为function
                retParams = {func(subModule, ...)}
                
                if DEBUG_MODE == 1 then
                    log("retParams", unpack(retParams))
                end

                if retParams ~= nil and retParams[1] == true then
                    break
                end
            end
        end
        if retParams ~= nil and #retParams > 0 then
            return unpack(retParams)
        else
            return false
        end
    end

    error("没有子模块")
end

-- 调用子模块方法, 并且累加返回结果
function Module:callFuncAndSum(name, ...)
    if self._subModules ~= nil then
        local sum = 0
        for i = #self._subModules, 1, -1 do
            local subModule = self._subModules[i]
            local func = subModule[name]
            if func ~= nil then -- 没有通过type判断是否为方法, 为了性能, 可判断是否为function
                sum = sum + func(subModule, ...)
            end
        end
        return sum
    end

    error("没有子模块")
end

-- 合并子模块表
function Module:getMergeMap(name)
    local map = {}

    if self[name] ~= nil then
        table.mergeToLeft(map, self[name])
    end

    if self._subModules ~= nil then
        for i = #self._subModules, 1, -1 do
            local subModule = self._subModules[i]
            if subModule[name] ~= nil then
                table.mergeToLeft(map, subModule[name])
            end
        end
    end

    return map
end

-- 合并子模块数组
function Module:getCombineArray(name)
    local array = {}

    if self[name] ~= nil then
        table.appendArray(array, self[name])
    end

    if self._subModules ~= nil then
        for i = #self._subModules, 1, -1 do
            local subModule = self._subModules[i]
            if subModule[name] ~= nil then
                table.appendArray(array, subModule[name])
            end
        end
    end

    return array
end

-- 打印Moduel信息
function Module:printInfo()
    for k, v in pairs(self._subModules) do
        print(k, v, v:getName())
    end
end
return Module
0000000000000
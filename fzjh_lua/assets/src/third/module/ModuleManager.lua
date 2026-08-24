local ModuleManager = {}

local function log(...)
    if PRINT_MODE == 1 then
        print("ModuleManager:", ...)
    end
end

-- 给target添加路径为modulePath的模块
function ModuleManager:addModule(target, modulePath)
    log("addModule", target, modulePath)

    local module = self:getModule(target, modulePath)
    if type(module) == "table" then
        log("已经添加过模块: " .. modulePath)
        return module
    end

    local module = require(modulePath).new()
    module._modulePath = modulePath

    self:addMethodToTarget(target)
    local modules = self:getTargetModules(target)
    table.insert(modules, module)

    -- 附加到target
    module:attach(target)

    return module
end

-- 移除模块, 参数同上
function ModuleManager:removeModule(target, modulePath)
    local modules = self:getTargetModules(target)

    for i = #modules, 1, -1 do
        if modules[i]._modulePath == modulePath then
            table.remove(modules, i)
        end
    end
end

-- 获得target上附加的模块
function ModuleManager:getModule(target, modulePath)
    local modules = self:getTargetModules(target)
    for i = 1, #modules do
        if modules[i]._modulePath == modulePath then
            return modules[i]
        end
    end
    return nil
end

-- 获取指定target上面的模块集合
function ModuleManager:getTargetModules(target)
    if target.__module == nil then
        target.__module = {
            __isNotSerializable = true, -- 不需要序列化,
            __ignore_table_cover = true, -- 不需要覆盖
            modules = {}
        }
    end

    return target.__module.modules
end

-- 给指定target添加模块调用方法
function ModuleManager:addMethodToTarget(target)
    target.callModuleFunc = ModuleManager.callModuleFunc
    target.addSubModuleTo = ModuleManager.addSubModuleTo
end

function ModuleManager.callModuleFunc(target, name, ...)
    local modules = ModuleManager:getTargetModules(target)
    -- log("callModuleFunc", target, name)
    -- log("#modules", #modules)

    for i = #modules, 1, -1 do
        local module = modules[i]
        if module[name] ~= nil then
            return module[name](module, target, ...)
        end
    end

    log("can't find method", name)

    return nil
end

function ModuleManager.addSubModuleTo(target, moduleName, sudModulePath)
    local modules = ModuleManager:getTargetModules(target)
    log("addSubModuleTo", target, name)
    log("#modules", #modules)

    for i = #modules, 1, -1 do
        local module = modules[i]
        log("module:getName()", module:getName())
        log("moduleName", moduleName)
        if module:getName() == moduleName then
            module:addSubModuleWithPath(sudModulePath)
            return
        end
    end

    log("can't find method", name)

    return nil
end

return ModuleManager
000000
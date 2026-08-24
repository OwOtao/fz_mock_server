local TableProxy = require("third.tableProxy.TableProxy")
local Helper = {}

-- 包含并且加密
function requireWithEncrypt(name)
    local v = require(name)
    if type(v) == "table" then
        local encryptTb = TableProxy:createDataValidationTableRecursive(v)
        package.loaded[name] = encryptTb
        return encryptTb 
    end
    return v
end

-- 创建防修改table
function createEncryptTable(t)
    return TableProxy:createEncryptedTable(t)
end

-- 递归创建防修改table
function createEncryptTableWithRecursive(t)
    return TableProxy:createEncryptedTableRecursive(t)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/15 21:38:42
-- @desc 克隆可以过滤
function cloneWithIgnore(object, ignoreNameArray)
    local tmpObject = nil
    local tmps = {}
    
    -- 临时存储忽略变量 add by TangJian 2017/03/15 21:50:40
    for i, varName in ipairs(ignoreNameArray) do
        tmps[varName] = object[varName]
        object[varName] = nil
    end
    
    -- 克隆 add by TangJian 2017/03/15 21:50:56
    tmpObject = clone(object)
    
    -- 还原 add by TangJian 2017/03/15 21:51:00
    for i, varName in ipairs(ignoreNameArray) do
        object[varName] = tmps[varName]
        tmpObject[varName] = tmps[varName]
    end
    return tmpObject
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 全局方法
function isTable(v)
    return type(v) == "table"
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/16 16:02:22
-- @desc 得到权重大小
function getWeightArray(parts, offsetRate)
    if offsetRate == nil then
        offsetRate = 25
    end
    local offset = math.floor((1 / parts) * offsetRate)
    local partBeginArray = {}
    table.insert(partBeginArray, 0)
    for i = 1, parts - 1 do
        local standard = math.floor(100 / parts) * i
        table.insert(partBeginArray, math.random(standard - offset, standard + offset))
    end
    table.insert(partBeginArray, 100)
    table.sort(partBeginArray)
    -- local totalWeight = 0
    local partWeightArray = {}
    for i = 1, parts do
        local weight = (partBeginArray[i + 1] - partBeginArray[i])
        table.insert(partWeightArray, weight)
    -- totalWeight = totalWeight + weight
    end
    -- assert(totalWeight == 100)
    return partWeightArray
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到一个随机的数组
function getRandomArray(array)
    local randomArray = {}
    while #array > 0 do
        local randomIndex = math.random(1, #array)
        table.insert(randomArray, array[randomIndex])
        table.remove(array, randomIndex)
    end
    return randomArray
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc switch
function switch(caseCode, witchTable, ...)
    local ret = witchTable[caseCode]
    if ret == nil then
        ret = witchTable["default"]
    end
    if type(ret) == "function" then
        return ret(...)
    end
    return ret
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 函数固定间隔时间调用
local doFuncWithInterval_funcList = {}
function DoFuncWithInterval(name, func, internal)
    if PRINT_MODE == 1 then
        assert(name and type(func) == "function" and type(internal) == "number")
    end
    if doFuncWithInterval_funcList[name] == nil then
        doFuncWithInterval_funcList[name] =
            {
                time = 0,
                func = func
            }
    end
    local fl = doFuncWithInterval_funcList[name]
    local currTime = GetTime()
    local duration = currTime - fl.time
    if duration >= internal then
        fl.time = currTime
        func(duration)
    end
end

function Helper:clearIntervalFunc(name)
    if doFuncWithInterval_funcList[name] then
        doFuncWithInterval_funcList[name] = nil
    end
end

-- 节点单例
-- Node 全局添加
local classDefNodeGetInstance_NodeId = 1
function Helper:classDefNodeGetInstance(_class)
    assert(_class)
    
    local NodeId = classDefNodeGetInstance_NodeId
    classDefNodeGetInstance_NodeId = classDefNodeGetInstance_NodeId + 1
    
    local l_class = _class
    l_class.getInstance = function(self)
        local runningScene = cc.Director:getInstance():getRunningScene()
        if runningScene then
            local Node = runningScene:getChildByTag(NodeId)
            if Node == nil then
                Node = l_class:create()
                Node:setTag(NodeId)
                runningScene:addChild(Node)
            end
            Node:setGlobalZOrder(1)
            Node:maxZ()
            return Node
        end
        return nil
    end
    
    l_class.destroyInstance = function(self)
        local instance = l_class:getInstance()
        instance:removeFromParent()
    end
end

-- 所有子节点执行相同动作
function Helper:callChildren(parent, callback)
    local function _callChildren(parent, callback)
        local children = parent:getChildren()
        for key, var in pairs(children) do
            callback(var)
            _callChildren(var, callback)
        end
    end
    return _callChildren(parent, callback)
end

-- UI
function Helper:convertUI(root)
    -- local function convertTextToLabel(node)
    -- 	local string = node:getString()
    -- 	local fontSize = node:getFontSize()
    -- 	local fontName = node:getFontName()
    -- 	return node
    -- end
    self:callChildren(root,
        function(child)
            local childType = tolua.type(child)
            -- print("child:getName() = "..child:getName())
            -- print("childType = "..childType)
            -- if childType == "ccui.Text" then
            -- 	child = convertTextToLabel(child)
            -- end
            root[child:getName()] = child
        end)
end

---------------根据节点区分
-- 所有子节点执行相同动作
function Helper:callChildrenByParent(parent, callback)
    local function _callChildren(parent, callback)
        local children = parent:getChildren()
        
        if parent:getName() == "Layer" then
            parent = parent:getParent()
        end
        
        for key, var in pairs(children) do
            callback(parent, var)
            _callChildren(var, callback)
        end
    end
    return _callChildren(parent, callback)
end
--UI
function Helper:convertUIByParent(root)
    self:callChildrenByParent(root,
        function(parent, child)
            parent[child:getName()] = child
        end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得节点树桩结构
function Helper:setNodeTree(root)
    local function _callChildren(parent, callback)
        local children = parent:getChildren()
        for k, child in pairs(children) do
            callback(parent, child)
            _callChildren(child, callback)
        end
    end
    _callChildren(root,
        function(parent, child)
            parent[child:getName()] = child
        end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc
function Helper:callChildrenParent(parent, callback)
    local function _callChildren(parent, callback)
        local children = parent:getChildren()
        
        for key, var in pairs(children) do
            callback(parent, var)
            _callChildren(var, callback)
        end
    end
    return _callChildren(parent, callback)
end
--UI
function Helper:convertUIParent(root)
    self:callChildrenParent(root,
        function(parent, child)
            parent[child:getName()] = child
        end)
end

function Helper:getChildTable(root)
    local children = root:getChildren()
end

-- 得到反方向
function Helper:getOppositeDirection(direction)
    local direction2OppositeDirection =
        {
            center = "center",
            left = "right",
            leftUp = "rightDown",
            up = "down",
            rightUp = "leftDown",
            right = "left",
            rightDown = "leftUp",
            down = "up",
            leftDown = "rightUp"
        }
    return assert(direction2OppositeDirection[direction], "direction = " .. direction)
end

function Helper:getDirectionVec2(direction)
    local direction2Vec2 =
        {
            center = cc.p(0, 0),
            left = cc.p(-1, 0),
            leftUp = cc.p(-1, 1),
            up = cc.p(0, 1),
            rightUp = cc.p(1, 1),
            right = cc.p(1, 0),
            rightDown = cc.p(1, -1),
            down = cc.p(0, -1),
            leftDown = cc.p(-1, -1)
        }
    return assert(direction2Vec2[direction], "direction = " .. direction)
end

-- 得到唯一Id
local onlyId = 1
function Helper:getOnlyId()
    
    onlyId = onlyId + 1
    return onlyId
end

-- 时间转换
-- 秒转时分秒
function Helper:sec2timeDsc(sec)
    local min = sec / 60
    local hour = min / 60
    min = min % 60
    sec = sec % 60
    return math.floor(hour), math.floor(min), math.floor(sec)
end

-- 时间转换
-- 秒转天时分秒
function Helper:sec3timeDsc(sec)
    local day = math.floor((sec / (24 * 60 * 60)))
    local hour = math.floor((sec / (60 * 60)) % 24)
    local minute = math.floor((sec / 60) % 60)
    local second = math.floor(sec % 60)
    
    return day, hour, minute,second
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc table覆盖
function Helper:tableCover(srcTb, object)
    local lookup_table = {}
    local function _tableCover(srcTb, object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        elseif object.__ignore_table_cover then -- table忽略覆盖
            return srcTb
        end        
        
        if type(srcTb) == "table" or type(srcTb) == "userdata" then
        else
            srcTb = {}
        end

        lookup_table[object] = srcTb

        for key, value in pairs(object) do
            if key ~= "ignoreCloneTb" then
                srcTb[_tableCover(nil, key)] = _tableCover(srcTb[key], value)
            end
        end
        -- return setmetatable(srcTb, getmetatable(object)) 
        return srcTb     
    end
    return _tableCover(srcTb, Helper:getDef(object, {}))
end




-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得范围内的值
function Helper:getRange(value, min, max)
    if value == nil then
    elseif min and value < min then
        value = min
    elseif max and value > max then
        value = max
    end
    return value
end
getRange = Helper.getRange

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得默认值
function Helper:getDef(value, default)
    if default == nil then
        print(debug.traceback(), "Helper:getDef, default is nil!!!")
        return value
    end

    if type(value) ~= type(default) then
        value = default
    end
    return value
end

-- 判断数字是否为nan
function Helper:isNan(double)
    if type(double) ~= "number" then
        return false
    end
    
    local str = tostring(double)
    return str == "1.#INF" or str == "nan" or str == "-1.#IND"
-- return YXHelper:isNan(double)
end

-- 函数相关 -------------------------------------------------------
function Helper:callFunc(func, ...)
    if type(func) == "function" then
        return func(...)
    end
    return nil
end

-- 函数定义 -------------------------------------------------------
-- get and set
function Helper:classDefSetAndGetWithTable(class, tb)-- funcName = {funcName, varName, default, min, max}
    assert(class)
    local function classDefSetAndGet(class, funcName, varName, default, min, max)
        if varName == nil then
            varName = "_" .. funcName
        end
        
        class["set" .. funcName] = function(obj, var)
            if var and min and var < min then
                var = min
            elseif var and max and var > max then
                var = max
            end
            obj[varName] = var
        end
        class["get" .. funcName] = function(obj)
            if obj[varName] == nil then
                obj[varName] = default
            end
            return obj[varName]
        end
    end
    
    for k, v in pairs(tb) do
        classDefSetAndGet(class, k, v[1], v[2], v[3], v[4], v[5])
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/22 17:46:34
-- @desc 函数定义
-- @param tb = {varName = {funcName, varName, default, min, max}}
function defVars(obj, params)
    assert(type(obj) == "table", [[type(obj) == "table"]])
    assert(type(params) == "table", [[type(params) == "table"]])
    
    if type(obj) ~= "table" then
        print([[type(obj) ~= "table"]])
        return
    end
    local function _defVar(varName, funcName, default, min, max)
        assert(type(varName) == "string", [[type(varName) == "string"]])
        assert(type(funcName) == "string", [[type(funcName) == "string"]])
        
        obj["set" .. funcName] = function(self, var)
            if var and min and var < min then
                var = min
            elseif var and max and var > max then
                var = max
            end
            self[varName] = var
        end
        obj["get" .. funcName] = function(self)
            if self[varName] == nil then
                if clone then
                    self[varName] = clone(default)
                else
                    self[varName] = default
                end
            end
            return self[varName]
        end
    end
    for k, v in pairs(params) do
        if type(v) == "table" then
            local varName, funcName, default, min, max = k, v[1], v[2], v[3], v[4]
            if funcName == nil then
                obj[k] = default
            else
                _defVar(varName, funcName, default, min, max)
            end
        else
            obj[k] = v
        end
    end
end

-- 打印
function Helper:print_lua_table(lua_table, indent)
    -- if true then
    --  return
    -- end
    -- if PRINT_MODE == 1 then
    --     else
    --     return
    -- end
    local function _print_lua_table(lua_table, indent)
        if lua_table == nil then
            -- print(debug.traceback(("table is nil")))
            return
        end
        
        indent = indent or 0
        
        for k, v in pairs(lua_table) do
            if type(k) == "string" then
                k = string.format("%q", k)
            end
            
            local szSuffix = ""
            if type(v) == "table" then
                szSuffix = "{"
            end
            
            local szPrefix = string.rep("    ", indent)
            
            local formatting = szPrefix .. "[" .. k .. "]" .. " = " .. szSuffix
            
            if type(v) == "table" then
                print(formatting)
                _print_lua_table(v, indent + 1)
                print(szPrefix .. "},")
            else
                local szValue = ""
                if type(v) == "string" then
                    szValue = string.format("%q", v)
                else
                    szValue = tostring(v)
                end
                print(formatting .. szValue .. ",")
            end
        end
    end
    return _print_lua_table(lua_table, indent)
end

-- 打印
function Helper:print_lua_table_string(lua_table, indent)
    -- if true then
    -- 	return
    -- end
    -- if PRINT_MODE == 1 then
    --     else
    --     return
    -- end
    local errList = {}
    local print = function(str)
        table.insert(errList, str)
    end
    local lookup_table = {}
    local function _print_lua_table(lua_table, indent)
        if lua_table == nil or lookup_table[lua_table] == true then
            -- print(debug.traceback(("table is nil")))
            return
        end
        lookup_table[lua_table] = true

        indent = indent or 0
        
        for k, v in pairs(lua_table) do
            k = tostring(k)
            if type(k) == "string" then
                k = string.format("%q", k)
            end
            
            local szSuffix = ""
            if type(v) == "table" then
                szSuffix = "{"
            end
            
            local szPrefix = string.rep("    ", indent)
            
            local formatting = szPrefix .. "[" .. k .. "]" .. " = " .. szSuffix
            
            if type(v) == "table" then
                print(formatting)
                _print_lua_table(v, indent + 1)
                print(szPrefix .. "},")
            else
                local szValue = ""
                if type(v) == "string" then
                    szValue = string.format("%q", v)
                else
                    szValue = tostring(v)
                end
                print(formatting .. szValue .. ",")
            end
        end
    end
    local ret =  _print_lua_table(lua_table, indent)

    return table.concat(errList, "")
    -- return ret
end

-- 将10万以内的数字转换成中文
function Helper:numberCast(num)
    if not num then
        return
    end
    local tab =
        {
            ["1"] = "一",
            ["2"] = "二",
            ["3"] = "三",
            ["4"] = "四",
            ["5"] = "五",
            ["6"] = "六",
            ["7"] = "七",
            ["8"] = "八",
            ["9"] = "九"
        }
    local sNum = tostring(num)
    local str, fNum = "", 1
    for i = #sNum, 1, -1 do
        local key = string.sub(sNum, fNum, #sNum - i + 1)
        if key == "0" then
            str = str .. "零"
        else
            if i == 5 then
                str = str .. tab[key] .. "万"
            elseif i == 4 then
                str = str .. tab[key] .. "千"
            elseif i == 3 then
                str = str .. tab[key] .. "百"
            elseif i == 2 then
                str = str .. tab[key] .. "十"
            else
                str = str .. tab[key]
            end
        end
        fNum = fNum + 1
    end
    
    while string.find(str, "零零") ~= nil do
        str = string.gsub(str, "零零", "零")
    end
    
    while string.sub(str, #str - 2, #str) == "零" do
        str = string.sub(str, 1, #str - 3)
    end
    if str == "一十" then
        str = "十"
    end

    if type(num) == "number" and num >= 10 and num < 20 then
        str = string.gsub(str, "一十", "十")
    end
    
    return str
end

-- 执行字符串脚本
local GetValueFromeScriptMap = {}
-- setmetatable(GetValueFromeScriptMap, {__mode = "kv"})
function Helper:GetValueFromScript(inputScript, param)    
    local scriptFunc = GetValueFromeScriptMap[inputScript]

    if not scriptFunc then

        -- 判断输入脚本是否合法 add by TangJian 2018/01/22 20:59:24
        if inputScript == nil then
            return nil
        elseif type(inputScript) ~= "string" then
            return inputScript
        end

        -- 判断table是否为空 add by TangJian 2018/01/22 21:00:04
        if type(param) ~= "table" or next(param) == nil then
            param = nil
        end
        
        -- 判断table是否为空 
        local tempScript = ""
        if param then
            tempScript = "local paramTb = ...\n" -- 接收参数table                        
            do -- 遍历赋值参数                
                for k, v in pairs(param) do
                    tempScript = tempScript .. "local " .. k .. " = " .. "paramTb." .. k .. "\n"
                end                
            end
        end
        
        -- 整合输入脚本
        if string.find(inputScript, "return ") then
            tempScript = tempScript .. inputScript
        else
            tempScript = tempScript .. "return " .. inputScript
        end
        
        local errorMsg = ""
        scriptFunc, errorMsg = loadstring(tempScript)
        if type(scriptFunc) == "function" then
            GetValueFromeScriptMap[inputScript] = scriptFunc
            return scriptFunc(param)
        else
            print("出错!!!!!", "输入字符：", inputScript, "错误日志：",errorMsg)
            return nil
        end
    else
        return scriptFunc(param)
    end
end

-- 分析字符串方法中的变量并且获取变量表
local getVarNameMapFromStringCache = {}
local getVarNameMapFromStringEmpty = {}
function Helper:getVarNameMapFromString(s)
    if s == nil then
        return getVarNameMapFromStringEmpty
    end

    local varNameMap = getVarNameMapFromStringCache[s]
    if varNameMap then
        print("cache in")
        return varNameMap
    else
        varNameMap = {}
        for varName in string.gmatch(s, "[%a_][%w_]*") do
            varNameMap[varName] = true
            print(varName)
        end
        getVarNameMapFromStringCache[s] = varNameMap
        return varNameMap
    end
end

-- 一些全局方法定义..
function isTrue(b)
    if b == 1 or b == true then
        return true
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得当天开始时间
function Helper:getDayTime(time)
    -- add by XiaoZhiWei 2019/03/18 20:09:21 修复夏令时的影响
    time = time - (Helper:date("%H", time) * 3600 + Helper:date("%M", time) * 60 + Helper:date("%S", time))

    -- add by XiaoZhiWei 2019/03/19 10:38:18 处理两个时间跨夏令时调整的情况
    if time >= 0 and os.date("*t", time).isdst then
        time = time + 3600
    end


    return time
    -- return time - (Helper:date("%H", time) * 3600 + Helper:date("%M", time) * 60 + Helper:date("%S", time))
end

--@desc: 获取今天剩余的时间
--@author:Liang SongQiang
--@time:2018-05-03 17:50:42
--@time: 现在时间
function Helper:getTodayRemainingTime( time )
    return tonumber(Helper:getDayTime(time) + 86400) - time
end

-- 比较时间差，返回天数
function Helper:diffWithDate(time1, time2)
    -- add by XiaoZhiWei 2019/03/19 10:38:18 处理两个时间跨夏令时调整的情况
    local t1 = Helper:date("%Y%m%d", time1)
    local t2 = Helper:date("%Y%m%d", time2)
    return self:getDaysBetweenTwoDate2(t2, t1)

    -- 向上取整，处理时间差精度问题
    -- return (math.ceil(Helper:getDayTime(math.floor(Helper:getDef(time1, 0))) - Helper:getDayTime(math.floor(Helper:getDef(time2, 0))))) / (24 * 3600)
end

-- 获取时间差，返回秒数
function Helper:diffWithSecond(time1, time2)
    if not time1 or type(time1) ~= "number" then
        time1 = 0
    end
    
    if not time2 or type(time2) ~= "number" then
        time2 = 0
    end
    return time1 - time2
end

--@desc 根据秒数,返回 00:00:00 格式字符串
function Helper:getTimeString(time)
    local hours = math.floor(time / 3600)
    local minutes = math.floor((time % 3600) / 60)
    local seconds = math.floor(time % 60)
    if(hours < 10) then hours = "0"..hours end
    if(minutes < 10) then  minutes = "0"..minutes end
    if(seconds < 10) then seconds = "0"..seconds end 
    return ""..hours..":"..minutes..":"..seconds
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/07 18:03:30
-- @desc 将年月日字符串格式的日期转换成时间戳 (仅支持 20160201 的日期格式)
function Helper:getTimeStampWithStringDate(stringDate, startTime)
    if stringDate == nil or string.len(stringDate) ~= 8 or tonumber(stringDate) == nil or type(startTime) ~= "number" then
        if PRINT_MODE == 1 then
            print("Helper:getTimeStampWithStringDate(stringDate, startTime)", stringDate, startTime)
        end
        return 0
    end
    
    local year = tonumber(string.sub(stringDate, 1, 4))
    local month = tonumber(string.sub(stringDate, 5, 6))
    local day = tonumber(string.sub(stringDate, 7, 8))
    local hour = Helper:getDef(startTime, 0)-- 默认开始时间
    
    
    local retTime = (os.time({year = year, month = month, day = day, hour = hour}) - self:getTimeZone())
    
    if os.date("*t", retTime).isdst then
        return retTime + 3600
    else
        return retTime
    end
end

-----------------------------------------------------------------------------------------------------------
--@desc: 将年月日时分秒字符串格式的日期转换成时间戳
--@author:LvBin
--@time:2026-03-20 17:54:28
--@return
function Helper:getTimeStampWithFullStringDate(stringDate)
    if stringDate == nil or string.len(stringDate) ~= 14 or tonumber(stringDate) == nil then
		print("Helper:getTimeStampWithStringDate(stringDate, startTime)", stringDate)
        return 0
    end
    
    local year = tonumber(string.sub(stringDate, 1, 4))
    local month = tonumber(string.sub(stringDate, 5, 6))
    local day = tonumber(string.sub(stringDate, 7, 8))
	local hour = tonumber(string.sub(stringDate, 9, 10))
    local min = tonumber(string.sub(stringDate, 11, 12))
    local sec = tonumber(string.sub(stringDate, 13, 14))

    local retTime = (os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec}) - self:getTimeZone())
    
    if os.date("*t", retTime).isdst then
        return retTime + 3600
    else
        return retTime
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/10 22:44:02
-- @desc 计算本地时区到中国时区的时间差
function Helper:getTimeZone()
    local function get_timezone()
        local now = os.time()
        -- if os.date("*t", now).isdst then
        --     now = now + 3600
        -- else
        --     now = now
        -- end
        return os.difftime(now, os.time(os.date("!*t", now)))
    end
    
    local localTimeZone = get_timezone()
    return 28800 - localTimeZone --计算出服务端时区与客户端时区差值
end

-----------------------------------------------------------------------------------------------------------
-- @author LiJie
-- @time 2016/11/21 15:56:47
-- @desc 根据提供的两个日期，返回中间间隔的天数（返回的天数中只包括提供的两个日期这两天中的一天，比如：20161121 20161120  是 1天）日期格式20160101
function Helper:getDaysBetweenTwoDate(dateBefore, datelate)
    -- add by XiaoZhiWei 2017/11/06 16:48:43 向下取整,解决海外签到的整数问题
    return self:mathFloor(self:diffWithDate(self:getTimeStampWithStringDate(dateBefore, 12), self:getTimeStampWithStringDate(datelate, 12))) 
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/10/08 18:14:48
-- @params 
-- @desc 根据提供的两个日期，返回中间间隔的天数（返回的天数中只包括提供的两个日期这两天中的一天，比如：20161121 20161120  是 1天）日期格式20160101 
-- 注: 算法调整,避免夏令时的影响
function Helper:getDaysBetweenTwoDate2(dateBefore, datelate)
    if type(dateBefore) ~= "string" or type(datelate) ~= "string" and string.len(dateBefore) ~= 8 and string.len(datelate) ~= 8 then
        return 0
    end
    local startYear = tonumber(string.sub(dateBefore, 1, 4))
    local endYear = tonumber(string.sub(datelate, 1, 4))

    local startMonth = tonumber(string.sub(dateBefore, 5, 6))
    local endMonth = tonumber(string.sub(datelate, 5, 6))

    local startDays = tonumber(string.sub(dateBefore, 7, 8))
    local endDays = tonumber(string.sub(datelate, 7, 8))

    local totaldays = endDays - startDays
    local mc = (endYear - startYear) * 12 + endMonth - startMonth --月数差
    for i=0, mc - 1 do
        totaldays = totaldays + os.date("%d",os.time({year=startYear,month=i+startMonth + 1,day=0}))
    end

    return totaldays
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @desc 计算时间差 返回 年 月 日 时 分 秒
function Helper:getExpiredTime(time1, time2)
    local expiredTime = self:diffWithSecond(time1, time2)
    local year, month, day, hour, minute, second = 0, 0, 0, 0, 0, 0
    if expiredTime > 0 then
        year = math.floor(expiredTime / (12 * 30 * 24 * 60 * 60))
        month = math.floor((expiredTime / (30 * 24 * 60 * 60)) % 12)
        day = math.floor((expiredTime / (24 * 60 * 60)) % 30)
        hour = math.floor((expiredTime / (60 * 60)) % 24)
        minute = math.floor((expiredTime / 60) % 60)
        second = math.floor(expiredTime % 60)
    end
    return year, month, day, hour, minute, second
end

-----------  日期类判断
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/02 19:04:43
-- @desc 获取两个时间的相隔周数
function Helper:getIntervalWeek(endTime, startTime)
    if startTime == nil or endTime == nil then
        if PRINT_MODE == 1 then
            error("传入的参数错误, startTime = "..tostring(startTime).."; endTime = "..tostring(endTime))
        end
        return 0
    end
    local retCount = 0
    local totalDays = self:diffWithDate(endTime, startTime) -- add by XiaoZhiWei 2018/05/02 20:41:12 相隔总天数
    local residueDays = totalDays % 7 -- add by XiaoZhiWei 2018/05/02 20:09:13 与7取余的剩余天数
    -- 间隔大于7天
    if totalDays >= 7 then
        retCount = self:mathFloor(totalDays / 7) -- add by XiaoZhiWei 2018/05/02 20:12:03 与7取模得到周数
    else
    end


    local startWeekdy = tonumber(self:date("%w",startTime))
    local endWeekdy = tonumber(self:date("%w",endTime))
    -- add by XiaoZhiWei 2018/05/02 20:08:32 开始日期不是周日,并且 剩余天数 加上 开始天序数 大于7天,代表是下一周
    if startWeekdy ~= 0 and startWeekdy + residueDays > 7 then
        retCount = retCount + 1
    -- add by XiaoZhiWei 2018/05/02 20:11:23 开始日期是周日, 并且 开始天序数 不是周日,也代表是下一周
    elseif startWeekdy == 0 and endWeekdy > 0 then
        retCount = retCount + 1
    end
    return retCount
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/02 19:06:49
-- @desc 获取两个时间的相隔月数
function Helper:getIntervalMonth(endTime, startTime)
    if startTime == nil or endTime == nil then
        if PRINT_MODE == 1 then
            error("传入的参数错误, startTime = "..tostring(startTime).."; endTime = "..tostring(endTime))
        end
        return 0
    end
    local startMonth, startYear = Helper:date("%m", startTime), Helper:date("%Y", startTime)
    local endMonth, endYear = Helper:date("%m", endTime), Helper:date("%Y", endTime)
    return (endYear - startYear) * 12 + (endMonth - startMonth)
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/02 19:01:38
-- @desc 判断是否是本周
function Helper:isThisWeek(endTime, startTime)
    return self:getIntervalWeek(endTime, startTime) == 0 or false
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/02 19:03:03
-- @desc 判断是否是本月
function Helper:isThisMonth(endTime, startTime)
    return self:getIntervalMonth(endTime, startTime) == 0 or false
end

------------------------


-- 屏蔽词
local Trie = require("third.tree.Trie")
local baseMaskOffTrie = Trie:create()
local MaskWordsConfig = require("app.models.Const.MaskWordsConfig")
local baseMaskWords = MaskWordsConfig:getBaseMaskWords()
if MapIsEmpty(baseMaskWords) == false then
    for i, v in ipairs(baseMaskWords) do
        baseMaskOffTrie:add(v)
    end
end

--基础屏蔽词库
function Helper:isMaskOff(str)
    local index, word = baseMaskOffTrie:findInStr(str)
    return index > 0, word
end

-- 获取随机名字
function Helper:getRandomName(sex)
    local xing, nanMing, nvMing, ciKu = {}, {}, {}, {}
    ciKu = {"黑衣人", "店小二", "蒙面人", "李先生", "小贩", "家丁", "铁匠", "游客", "仆人", "白发老者", "马夫", "书生", "衙役", "尹志平", "阿朱", "段誉", "胡斐", "苗人凤", "苗若兰", "慕容博", "男孩", "女孩", "田青文", "无名剑客", "小孩", "药铺伙计", "壮汉", "阿碧", "巴天石", "茶博士", "茶客", "茶客", "茶客", "陈玄风", "陈玄风", "陈玄风", "程瑶迦", "程瑶迦", "程瑶迦", "大汉", "大汉", "大汉", "邓百川", "邓百川", "邓百川", "地痞", "地痞", "地痞", "丁典", "丁典", "丁典", "风波恶", "风波恶", "风波恶", "冯阿三", "冯阿三", "冯阿三", "公冶乾", "公冶乾", "公冶乾", "苟读", "苟读", "苟读", "郭靖", "郭靖", "郭靖", "郝大通", "郝大通", "郝大通", "洪七公", "洪七公", "洪七公", "侯通海", "侯通海", "侯通海", "黄蓉", "黄蓉", "黄蓉", "伙计", "伙计", "伙计", "脚夫", "脚夫", "脚夫", "教书先生", "教书先生", "教书先生", "鸠摩智", "鸠摩智", "鸠摩智", "菊友", "菊友", "菊友", "康广陵", "康广陵", "康广陵", "梁子翁", "梁子翁", "梁子翁", "凌霜华", "凌霜华", "凌霜华", "凌退思", "凌退思", "凌退思", "流氓", "流氓", "流氓", "马青雄", "马青雄", "马青雄", "梅超风", "梅超风", "梅超风", "梅剑", "梅剑", "梅剑", "木人", "木人", "木人", "木婉清", "木婉清", "木婉清", "慕容复", "慕容复", "慕容复", "农夫", "农夫", "农夫", "欧阳克", "欧阳克", "欧阳克", "钱青健", "钱青健", "钱青健", "曲三", "曲三", "曲三", "扫地僧", "扫地僧", "扫地僧", "僧人", "僧人", "僧人", "沙通天", "沙通天", "沙通天", "山贼", "山贼", "山贼", "沈青刚", "沈青刚", "沈青刚", "石清露", "石清露", "石清露", "苏星河", "苏星河", "苏星河", "唐门弟子", "唐门弟子", "唐门弟子", "王语嫣", "王语嫣", "王语嫣", "吴领军", "吴领军", "吴领军", "吴青烈", "吴青烈", "吴青烈", "小沙弥", "小沙弥", "小沙弥", "薛慕华", "薛慕华", "薛慕华", "学子", "学子", "学子", "丫鬟", "丫鬟", "丫鬟", "严妈妈", "严妈妈", "严妈妈", "幽草", "幽草", "幽草", "阿洪", "阿洪", "阿胜", "阿胜", "阿紫", "阿紫", "安提督", "安提督", "白世镜", "白世镜", "包惜弱", "包惜弱", "宝树", "宝树", "宝象和尚", "宝象和尚", "鲍千灵", "鲍千灵", "本参", "本参", "本观", "本观", "本相", "本相", "本因", "本因", "婢女", "婢女", "波罗星", "波罗星", "博尔忽", "博尔忽", "博尔术", "博尔术", "卜垣", "卜垣", "补锅匠", "补锅匠", "不平道人", "不平道人", "蔡威", "蔡威", "曹猛", "曹猛", "曹云奇", "曹云奇", "曾铁鸥", "曾铁鸥", "常伯志", "常伯志", "常赫志", "常赫志", "车夫", "车夫", "陈高波", "陈高波", "陈孤雁", "陈孤雁", "陈家洛", "陈家洛", "陈禹", "陈禹", "程灵素", "程灵素", "程青霜", "程青霜", "赤老温", "赤老温", "出尘子", "出尘子", "褚轰", "褚轰", "褚万里", "褚万里", "船夫", "船夫", "崔百泉", "崔百泉", "崔百胜", "崔百胜", "崔绿华", "崔绿华", "大智禅师", "大智禅师", "单伯山", "单伯山", "单季山", "单季山", "单叔山", "单叔山", "单小山", "单小山", "单正", "单正", "当铺老板", "当铺老板", "刀白凤", "刀白凤", "道童", "道童", "德布", "德布", "狄修", "狄修", "狄云", "狄云", "店伴", "店伴", "丁春秋", "丁春秋", "丁勉", "丁勉", "都史", "都史", "毒蛇", "毒蛇", "杜希孟", "杜希孟", "端木元", "端木元", "段天德", "段天德", "段延庆", "段延庆", "段正淳", "段正淳", "段正明", "段正明", "峨眉弟子", "峨眉弟子", "范百龄", "范百龄", "范帮主", "范帮主", "范骅", "范骅", "范禹", "范禹", "费彬", "费彬", "冯衡", "冯衡", "冯坦", "冯坦", "冯铁匠", "冯铁匠", "凤南天", "凤南天", "凤七", "凤七", "凤一鸣", "凤一鸣", "符敏仪", "符敏仪", "福康安", "福康安", "傅思归", "傅思归", "盖运聪", "盖运聪", "甘宝宝", "甘宝宝", "高根明", "高根明", "高管家", "高管家", "高升泰", "高升泰", "葛光佩", "葛光佩", "耿天霜", "耿天霜", "公孙大娘", "公孙大娘", "龚光杰", "龚光杰", "古笃诚", "古笃诚", "古若般", "古若般", "谷虚道长", "谷虚道长", "官兵", "官兵", "管家", "管家", "郭啸天", "郭啸天", "郭玉堂", "郭玉堂", "过彦之", "过彦之", "哈赤大师", "哈赤大师", "哈大霸", "哈大霸", "海兰弼", "海兰弼", "韩宝驹", "韩宝驹", "韩小莹", "韩小莹", "何思豪", "何思豪", "何望海", "何望海", "和里布", "和里布", "赫连铁树", "赫连铁树", "忽都虎", "忽都虎", "胡夫人", "胡夫人", "胡一刀", "胡一刀", "花铁干", "花铁干", "华赫艮", "华赫艮", "华筝", "华筝", "黄眉和尚", "黄眉和尚", "黄希节", "黄希节", "黄药师", "黄药师", "慧方", "慧方", "慧观", "慧观", "慧净", "慧净", "慧真", "慧真", "姬晓峰", "姬晓峰", "贾老者", "贾老者", "江湖豪客", "江湖豪客", "江湖人士", "江湖人士", "江琴", "江琴", "姜师叔", "姜师叔", "姜铁山", "姜铁山", "姜文", "姜文", "姜小铁", "姜小铁", "蒋调侯", "蒋调侯", "进香客", "进香客", "静智大师", "静智大师", "菊剑", "菊剑", "柯镇恶", "柯镇恶", "空心菜", "空心菜", "枯木", "枯木", "枯荣长老", "枯荣长老", "邝宝官", "邝宝官", "来福儿", "来福儿", "兰剑", "兰剑", "蓝秦", "蓝秦", "老乞丐", "老乞丐", "黎夫人", "黎夫人", "李春来", "李春来", "李教头", "李教头", "李傀儡", "李傀儡", "李莫愁", "李莫愁", "李萍", "李萍", "李秋水", "李秋水", "李四", "李四", "李廷豹", "李廷豹", "李员外", "李员外", "李沅芷", "李沅芷", "连诚诀", "连诚诀", "梁长老", "梁长老", "灵智上人", "灵智上人", "令狐冲", "令狐冲", "刘乘风", "刘乘风", "刘鹤真", "刘鹤真", "刘玄处", "刘玄处", "刘瑛姑", "刘瑛姑", "刘元鹤", "刘元鹤", "刘之余", "刘之余", "刘竹庄", "刘竹庄", "聋哑婆婆", "聋哑婆婆", "鲁坤", "鲁坤", "陆乘风", "陆乘风", "陆冠英", "陆冠英", "陆天抒", "陆天抒", "陆无双", "陆无双", "吕文德", "吕文德", "吕小妹", "吕小妹", "麻雀", "麻雀", "马春花", "马春花", "马大鸣", "马大鸣", "马夫人", "马夫人", "马行空", "马行空", "马五德", "马五德", "马钰", "马钰", "梅念笙", "梅念笙", "孟师叔", "孟师叔", "梦姑", "梦姑", "木华黎", "木华黎", "木文察", "木文察", "慕容景岳", "慕容景岳", "慕容巡捕", "慕容巡捕", "穆贵妃", "穆贵妃", "南兰", "南兰", "南仁通", "南仁通", "南希仁", "南希仁", "倪不大", "倪不大", "倪不小", "倪不小", "年轻妇人", "年轻妇人", "聂钺", "聂钺", "努儿海", "努儿海", "欧阳峰", "欧阳峰", "欧阳公政", "欧阳公政", "胖妇人", "胖妇人", "胖丐", "胖丐", "胖商人", "胖商人", "胖子", "胖子", "彭连虎", "彭连虎", "平阿四", "平阿四", "平工头", "平工头", "平婆婆", "平婆婆", "平四", "平四", "朴者和尚", "朴者和尚", "戚芳", "戚芳", "戚长发", "戚长发", "齐伯涛", "齐伯涛", "祁六三", "祁六三", "强盗", "强盗", "乔峰", "乔峰", "乔寨主", "乔寨主", "秦红棉", "秦红棉", "秦耐之", "秦耐之", "琴儿", "琴儿", "穷汉", "穷汉", "丘处机", "丘处机", "裘千丈", "裘千丈", "曲傻姑", "曲傻姑", "全冠清", "全冠清", "全金发", "全金发", "任通武", "任通武", "容子矩", "容子矩", "阮士忠", "阮士忠", "阮星竹", "阮星竹", "瑞婆婆", "瑞婆婆", "赛总管", "赛总管", "桑飞虹", "桑飞虹", "桑昆", "桑昆", "桑土公", "桑土公", "沙千里", "沙千里", "商宝震", "商宝震", "商老太", "商老太", "商人", "商人", "上官", "上官", "上官铁生", "上官铁生", "上香客", "上香客", "少林老僧", "少林老僧", "蛇皮张", "蛇皮张", "射雕英雄传", "射雕英雄传", "神山上人", "神山上人", "神音", "神音", "沈城", "沈城", "尸体", "尸体", "狮鼻子", "狮鼻子", "石嫂", "石嫂", "石双英", "石双英", "石万嗔", "石万嗔", "史登达", "史登达", "史松", "史松", "室里", "室里", "守城官兵", "守城官兵", "瘦商人", "瘦商人", "书店老板", "书店老板", "书记", "书记", "术赤", "术赤", "水岱", "水岱", "水福", "水福", "水笙", "水笙", "说书人", "说书人", "司空玄", "司空玄", "司马林", "司马林", "司徒雷", "司徒雷", "嵩山弟子", "嵩山弟子", "嵩山派高级弟子", "嵩山派高级弟子", "宋长老", "宋长老", "苏辙", "苏辙", "孙不二", "孙不二", "孙伏虎", "孙伏虎", "孙刚峰", "孙刚峰", "孙均", "孙均", "太皇太后", "太皇太后", "谭公", "谭公", "谭婆", "谭婆", "谭青", "谭青", "汤沛", "汤沛", "汤祖德", "汤祖德", "唐不平", "唐不平", "唐光雄", "唐光雄", "桃红", "桃红", "陶百岁", "陶百岁", "陶子安", "陶子安", "天狼子", "天狼子", "天龙八部", "天龙八部", "天山童姥", "天山童姥", "天竺僧人", "天竺僧人", "田伯光", "田伯光", "田归农", "田归农", "铁木真", "铁木真", "同桌后生", "同桌后生", "童怀道", "童怀道", "拖雷", "拖雷", "完颜阿古打", "完颜阿古打", "完颜洪烈", "完颜洪烈", "完颜洪熙", "完颜洪熙", "万圭", "万圭", "万震山", "万震山", "汪铁鹗", "汪铁鹗", "汪啸风", "汪啸风", "王处一", "王处一", "王罕", "王罕", "王剑杰", "王剑杰", "王剑英", "王剑英", "王铁匠", "王铁匠", "王维", "王维", "王秀才", "王秀才", "王仲萍", "王仲萍", "尉迟连", "尉迟连", "文醉翁", "文醉翁", "乌老大", "乌老大", "无尘道长", "无尘道长", "无青子", "无青子", "无崖子", "无崖子", "吴光胜", "吴光胜", "吴坎", "吴坎", "吴长风", "吴长风", "五毒教弟子", "五毒教弟子", "武馆学徒", "武馆学徒", "武将", "武将", "西灵道人", "西灵道人", "西夏宫女", "西夏宫女", "奚长老", "奚长老", "相国夫人", "相国夫人", "项长老", "项长老", "萧红叶", "萧红叶", "萧远山", "萧远山", "小翠", "小翠", "小龙女", "小龙女", "谢不当", "谢不当", "心砚", "心砚", "辛双清", "辛双清", "熊元献", "熊元献", "虚远", "虚远", "虚竹", "虚竹", "徐长老", "徐长老", "徐铮", "徐铮", "许卓诚", "许卓诚", "玄慈", "玄慈", "玄寂", "玄寂", "玄苦", "玄苦", "玄难", "玄难", "玄生", "玄生", "玄痛", "玄痛", "薛鹊", "薛鹊", "雪山飞狐", "雪山飞狐", "血刀老祖", "血刀老祖", "哑梢公", "哑梢公", "言达平", "言达平", "阎基", "阎基", "杨宾", "杨宾", "杨康", "杨康", "杨铁心", "杨铁心", "姚伯当", "姚伯当", "耶律洪基", "耶律洪基", "耶律莫哥", "耶律莫哥", "耶律涅鲁古", "耶律涅鲁古", "耶律重元", "耶律重元", "野狗", "野狗", "叶二娘", "叶二娘", "一灯大师", "一灯大师", "易大彪", "易大彪", "易吉", "易吉", "殷吉", "殷吉", "殷仲翔", "殷仲翔", "游骥", "游骥", "游驹", "游驹", "游坦之", "游坦之", "右书僮", "右书僮", "于管家", "于管家", "于光豪", "于光豪", "余婆婆", "余婆婆", "余鱼同", "余鱼同", "余兆兴", "余兆兴", "鱼贩头子", "鱼贩头子", "俞朝奉", "俞朝奉", "渔人", "渔人", "郁光标", "郁光标", "袁紫衣", "袁紫衣", "缘根", "缘根", "岳不群", "岳不群", "岳老三", "岳老三", "云岛主", "云岛主", "云中鹤", "云中鹤", "札木合", "札木合", "摘星子", "摘星子", "张阿生", "张阿生", "张飞雄", "张飞雄", "张管家", "张管家", "张九", "张九", "张全祥", "张全祥", "张三", "张三", "张十五", "张十五", "张姓老者", "张姓老者", "张总管", "张总管", "赵半山", "赵半山", "赵钱孙", "赵钱孙", "赵洵", "赵洵", "哲罗星", "哲罗星", "者勒米", "者勒米", "郑三娘", "郑三娘", "止清", "止清", "智光大师", "智光大师", "中年武师", "中年武师", "钟阿四", "钟阿四", "钟灵", "钟灵", "钟四嫂", "钟四嫂", "钟万仇", "钟万仇", "钟小二", "钟小二", "钟兆能", "钟兆能", "钟兆文", "钟兆文", "钟兆英", "钟兆英", "周伯通", "周伯通", "周隆", "周隆", "周圻", "周圻", "周铁鹤", "周铁鹤", "周云阳", "周云阳", "朱聪", "朱聪", "朱丹臣", "朱丹臣", "诸保昆", "诸保昆", "竹剑", "竹剑", "卓不凡", "卓不凡", "宗雄", "宗雄", "宗赞王子", "宗赞王子", "祖千秋", "祖千秋", "左书僮", "左书僮", "左子穆", "左子穆", "阿曼", "阿庆嫂", "安抚使吕文德", "八卦弟子", "巴郎星", "巴泰", "巴颜法师", "白寒枫", "白寒松", "白虎门裨将", "白马啸西风", "白髯老头", "白髯老者", "豹组武士", "鲍大楚", "蝙蝠", "镖师", "宾客", "采花子", "采石人", "采药道长", "菜园管事", "岑其斯", "曾柔", "茶馆小二", "茶客甲", "茶客乙", "茶先生", "察合台", "柴房管家", "车尔库", "陈达海", "陈珂", "陈奇", "陈有德", "成不忧", "程药发", "澄观", "澄行", "澄和", "澄寂", "澄坚", "澄净", "澄灵", "澄灭", "澄明", "澄尚", "澄识", "澄思", "澄心", "澄信", "澄意", "澄欲", "澄知", "澄志", "赤裸男人", "仇好石", "仇星星", "厨师", "从不弃", "崔老夫人", "崔莺莺", "崔永英", "崔志方", "翠花", "村民", "村长", "达摩祖师", "打手", "打铁僧", "大黄牛", "大狼狗", "丹青生", "刀客", "道尘禅师", "道成禅师", "道果禅师", "道觉禅师", "道品禅师", "道士", "道相禅师", "道象禅师", "道一禅师", "道正禅师", "登山客", "登山老者", "邓八公", "邓炳春", "狄水清", "地保", "丁坚", "丁同", "毒郎中", "杜立德", "渡厄", "渡劫", "渡难", "段无畏", "对喀纳", "多隆", "峨眉高级弟子", "法定长老", "法门长老", "樊一翁", "樊子发", "范先生", "方阿七", "方安", "方碧琳", "方大洪", "方人智", "方先生", "方怡", "方丈", "房志起", "风际中", "风清扬", "封不平", "冯难敌", "冯锡范", "冯正东", "妇人", "富商", "丐帮弟子", "高丽商人", "高则成", "歌妓", "公平子", "公孙绿萼", "公孙巡捕", "公孙止", "公子哥", "狗子", "顾月儿", "关安基", "归二娘", "归辛树", "归钟", "龟奴", "郭海", "韩一枫", "行痴", "行颠", "行人", "行者", "何红药", "何铁手", "何员外", "黑白子", "红娘", "洪人雄", "侯人英", "猴子", "虎组武士", "护林僧兵", "护院", "华伯斯基", "华山女弟子", "华山派弟子", "华山派高级弟子", "黄河帮帮众", "黄真", "黄钟公", "霍都", "霍元龙", "饥饿的老人", "吉人通", "纪晓芙", "妓女", "贾人达", "简管家", "简长老", "江百胜", "江湖好手", "江湖剑客", "江上游", "江耀亭", "焦木", "焦木和尚", "戒律堂弟子", "戒律堂首座", "金背蜈蚣", "金国高手", "金国人", "金线蜈蚣", "锦衣童子", "锦衣卫士", "静道师太", "静迦师太", "静虚师太", "静玄师太", "静照师太", "九难", "九尾蝎", "鹫组武士", "绝情谷弟子", "绝情谷高级弟子", "空空儿", "孔小天", "邝天雄", "劳德诺", "老大娘", "老夫子", "老和尚", "老虎", "老李", "老农", "老僧", "老鼠", "老吴", "老秀才", "乐厚", "黎生", "李白", "李公子", "李管事", "李家护卫", "李家下人", "李克先", "李明霞", "李三", "李铁嘴", "李通玄", "李文秀", "李西华", "李小琪", "李笑红", "李永福", "李知府", "李自成", "梁发", "林朝英", "林平之", "林无敌", "凌霜", "刘方", "刘夫人", "刘良华", "刘能", "刘芹", "刘显", "刘秀娘", "刘一舟", "刘镇远", "刘正风", "流氓头", "流星巡捕", "柳玄风", "柳之焕", "龙组武士", "卢一峰", "鲁连荣", "鲁有脚", "陆柏", "陆大有", "陆高轩", "鹿鼎记", "路边小贩", "罗汉堂弟子", "罗汉堂首座", "罗人杰", "落魄公子", "吕葆中", "吕留良", "吕毅中", "绿衣弟子", "绿衣僮儿", "绿衣小僮", "马宝", "马博仁", "马超兴", "马房管事", "马家骏", "马喇", "马齐", "马佑", "马贼", "卖唱女", "毛文珠", "茅十八", "梅庄弟子", "媒婆", "孟竹", "米思翰", "米为义", "蜜蜂", "妙手郎中", "灭绝师太", "明教弟子", "莫大", "莫大先生", "莫声谷", "莫协志", "木房管事", "木匠", "沐剑声", "慕容弟子", "慕容高级弟子", "穆念慈", "穆守财", "男弟子", "南北行掌柜", "南宫巡捕", "尼姑", "年轻少妇", "宁强盗", "宁中则", "农妇", "女弟子", "欧阳巡捕", "牌童", "潘秀达", "胖头陀", "彭长老", "平民男子", "平民女子", "平威", "平一指", "菩斯曲蛇", "菩斯曲蛇王", "齐洛诺夫", "齐元凯", "齐云敖", "祁清彪", "乔三槐", "樵夫", "樵子", "青城弟子", "青龙门裨将", "青面汉子", "青年", "青云", "清微道长", "清虚道长", "裘千尺", "裘千仞", "裘逸", "曲非烟", "曲洋", "全强盗", "犬组武士", "人面蜘蛛", "任我行", "任盈盈", "日月神教弟子", "柔儿", "桑斯", "沙天江", "傻姑", "山贼小头目", "上官虹", "上官巡捕", "烧饭僧", "少林僧人", "少林武僧", "申人俊", "神雕", "神秘女子", "神秘商人", "盛皮罗客商", "施戴子", "施令威", "拾荒者", "食尸蝎", "史伯威", "史定安", "史青山", "史叔刚", "史叔猛", "史仲俊", "士兵", "侍女", "守备", "守寺僧兵", "守园道长", "瘦丐", "书斋管事", "双儿", "水房管事", "司空茂", "司徒伯雷", "司徒鹤", "司徒巡捕", "嵩山刀客", "嵩山剑客", "嵩山派弟子", "宋兵", "宋青书", "宋远桥", "苏合", "苏鲁克", "苏梦清", "苏普", "苏州少女", "苏州知府", "酸儒文人", "酸秀才", "孙剥皮", "孙大成", "孙大娘", "孙婆婆", "孙思克", "踏青少女", "谭处端", "谭友纪", "汤若望", "汤英鹄", "唐方", "唐晶", "唐老太太", "唐亮", "唐门高级弟子", "唐猛", "唐甜", "唐无火", "唐无情", "桃干仙", "桃根仙", "桃花仙", "桃实仙", "桃叶仙", "桃枝仙", "腾蛇", "挑夫", "铁匠铺伙计", "铁算盘", "铁掌帮弟子", "童儿", "童子", "秃笔翁", "瓦尔拉齐", "万大平", "王道士", "王动海", "王夫人", "王公子", "王合计", "王坏水", "王坚", "王教头", "王进宝", "王绝", "王琪", "王乞儿", "王嫂", "王潭", "王铁手", "王五", "王武通", "王小二", "王心研", "王员外", "王志坦", "韦春芳", "韦春花", "韦小宝", "卫周祚", "窝阔台", "无根道人", "无量剑弟子", "无名居士", "吴古贤", "吴学究", "蜈蚣", "五毒教徒", "五符", "武当弟子", "武当高级弟子", "武敦儒", "武馆老管家", "武馆老中医", "武林高手", "武林人士", "武林中人", "武器店老板", "武三通", "武修文", "西奥图三世", "西门巡捕", "西夏兵", "喜来福", "戏子", "夏天", "向大年", "逍遥子", "萧之羽", "小桂子", "小和尚", "小红娘", "小猴", "小混混", "小痞子", "小玄子", "笑莫问", "心溪", "辛友清", "新郎", "新娘", "星宿派弟子", "星宿派高级弟子", "虚通", "许灵仁", "许雪亭", "玄悲大师", "玄慈大师", "玄定", "玄苦大师", "玄难大师", "玄痛大师", "玄武门裨将", "玄烨", "玄真", "玄真道人", "薛老板", "薛镇海", "学堂老先生", "雪儿", "丫环", "哑仆", "颜垣", "扬州女孩", "杨过", "杨磊石", "杨万萧", "杨永福", "养花女", "药店老板", "鹞组武士", "耶律齐", "迎宾楼老板", "幽兰", "游方道人", "于八", "于人豪", "余沧海", "余人彦", "余小星", "俞岱岩", "渔夫", "玉林", "玉亭亭", "狱卒", "元义方", "月老", "岳灵珊", "岳熊", "云强盗", "云素梅", "杂货铺老板", "杂役僧", "杂役院执事", "张伯东", "张不四", "张风", "张继", "张灵儿", "张三丰", "张生", "张松溪", "张玉恒", "长安城守卫", "掌药道长", "赵教头", "赵良栋", "赵灵珠", "赵无双", "赵志敬", "甄有庆", "镇东镖局镖师", "知客道长", "知客僧", "执法僧兵", "制香道长", "智净", "智空", "智深", "中年道士", "钟镇", "周教头", "周芷若", "朱夫人", "朱雀门裨将", "朱熹", "朱宇", "竹人", "庄夫人", "庄廷龙", "庄允城", "紫云巡捕", "左冷禅"}
    xing = {"安", "柏", "鲍", "毕", "曹", "岑", "昌", "常", "丁", "酆", "傅", "郝", "赫", "华", "姜", "解", "雷", "廉", "吕", "马", "聂", "潘", "彭", "史", "汤", "陶", "滕", "邬", "许", "严", "应", "杭", "喻", "李", "仇", "卢", "项", "江", "万", "堪", "黎", "席", "经", "车", "贾", "裘", "支", "费", "祁", "屈", "纪", "鄂", "田", "尹", "阎", "蔡", "粱", "罗", "咎", "夏", "禹", "高", "管", "穆", "汪", "骆", "周", "袁", "姚", "由", "吴", "钮", "惠", "刘", "诸", "甄", "荀", "张", "孟", "於", "俞", "景", "唐", "石", "吉", "薛", "魏", "符", "包", "羊", "宓", "程", "荣", "詹", "家", "崔", "封", "钱", "洪", "左", "贺", "邵", "邢", "燕", "鹿", "方", "韩", "戚", "范", "冯", "谢", "施", "任", "段", "魏", "柳", "鲁", "裴", "卫", "沈", "陆", "邹", "苏", "王", "孔", "翟", "秦", "何", "韦", "卓", "蒋", "窦", "苗", "郑", "陈", "翁", "牧", "贲", "孙", "牟", "郁", "颜", "闵", "莫", "庞", "樊", "蔺", "嵇", "邱", "向", "楼", "缪", "龚", "温", "褚", "柯", "宋", "徐", "虞", "韶", "郜", "宗", "凌", "郦", "霍", "宣", "狄", "叶", "卜", "元", "单", "邓", "白", "慕", "巫", "廖", "沙", "武", "仲", "柳", "唐", "叶", "方", "连", "宁", "祖", "齐", "阮", "童", "浑", "秋", "尤", "于", "章", "支", "朱", "诸", "顾", "房", "董", "余", "侯", "宫", "伍", "杨", "赵", "乔", "佟", "萧", "占", "干", "雍", "糜", "全", "葛", "苻", "权", "祝", "皮", "庾", "曲", "赖", "瞿", "牛", "资", "公冶", "伯赏", "轩辕", "长孙", "司马", "鲜于", "欧阳", "司空", "单于", "夏侯", "上官", "皇甫", "南宫", "诸葛", "巫马", "阳佟", "太叔", "东方", "尉迟", "呼延", "慕容", "宇文", "淳于", "子车", "闾丘", "东郭", "归海", "赫连", "司空", "乐正", "濮阳", "西门", "百里", "司徒", "令狐", "左丘", "公西", "谷粱", "拓跋", "赵", "钱", "孙", "李", "周", "吴", "郑", "王", "冯", "陈", "卫", "蒋", "沈", "韩", "杨", "朱", "秦", "许", "何", "吕", "张", "孔", "曹", "严", "华", "金", "魏", "陶", "姜", "戚", "谢", "章", "云", "苏", "潘", "葛", "范", "彭", "鲁", "韦", "昌", "马", "苗", "方", "俞", "任", "袁", "柳", "史", "唐", "费", "岑", "薛", "雷", "贺", "倪", "汤", "滕", "殷", "罗", "毕", "郝", "乐", "傅", "齐", "康", "伍", "余", "元", "顾", "孟", "平", "黄", "穆", "萧", "尹", "姚", "邵", "堪", "汪", "狄", "明", "成", "戴", "宋", "庞", "熊", "纪", "舒", "屈", "项", "祝", "董", "粱", "杜", "蓝", "席", "季", "贾", "江", "童", "颜", "郭", "梅", "盛", "林", "刁", "钟", "徐", "高", "夏", "蔡", "田", "樊", "胡", "凌", "霍", "万", "支", "柯", "管", "卢", "莫", "房", "解", "应", "宗", "丁", "邓", "洪", "包", "诸", "左", "石", "崔", "吉", "龚", "程", "裴", "陆", "荣", "翁", "荀", "惠", "甄", "魏", "封", "段", "巫", "乌", "焦", "牧", "秋", "伊", "仇", "甘", "武", "刘", "景", "詹", "束", "龙", "叶", "司", "韶", "郜", "蒲", "赖", "卓", "蒙", "乔", "姬", "冉", "温", "庄", "柴", "慕", "习", "向", "易", "廖", "文", "越", "师", "巩", "聂", "敖", "冷", "简", "曾", "沙", "关", "游", "万", "欧阳", "太史", "端木", "上官", "司马", "东方", "独孤", "南宫", "万俟", "闻人", "夏侯", "诸葛", "尉迟", "公羊", "赫连", "澹台", "皇甫", "宗政", "濮阳", "公冶", "太叔", "申屠", "公孙", "慕容", "仲孙", "钟离", "长孙", "宇文"}
    nanMing = {"之玉", "越泽", "锦程", "修杰", "烨伟", "尔曼", "立辉", "致远", "天思", "友绿", "聪健", "修洁", "访琴", "初彤", "谷雪", "平灵", "源智", "烨华", "振家", "越彬", "乞", "子轩", "伟宸", "晋鹏", "觅松", "海亦", "戾", "嵩", "邑", "瑛", "鸿", "卿", "裘", "契", "涛", "疾", "驳", "凛", "逊", "鹰", "威", "紊", "阁", "康", "焱", "城", "承誉", "祥", "虔", "胜", "穆", "豁", "匪", "霆", "凡", "枫", "豪", "铭", "罡", "扬", "垣", "师", "翼", "秋", "傥", "雨珍", "浩宇", "嘉熙", "志泽", "苑博", "念波", "峻熙", "俊驰", "聪展", "南松", "问旋", "黎昕", "谷波", "凝海", "靖易", "芷烟", "渊思", "煜祺", "乐驹", "风华", "箴", "睿渊", "博超", "天磊", "夜白", "初晴", "雍", "达", "乾", "鑫", "萧", "鲂", "冥", "翰", "丑", "隶", "钧", "坤", "荆", "蹇", "骁", "沅", "剑", "勒", "筮", "磬", "戎", "翎", "函", "嚣", "炳", "耷", "惮", "鞯", "擎", "烙", "呈靖", "遥", "斩", "颤", "孱", "续", "岩", "奄", "秋白", "瑾瑜", "鹏飞", "弘文", "伟泽", "迎松", "雨泽", "鹏笑", "诗云", "白易", "远航", "笑白", "映波", "代桃", "晓啸", "智宸", "晓博", "靖琪", "十八", "君浩", "绍辉", "冷安", "盼旋", "博", "鹤", "绯", "匕", "奎", "仰", "霸", "乌", "邴", "败", "捕", "糜", "汲", "涔", "班", "悲", "臻", "厉", "栾", "井", "伊", "储", "羿", "富", "稀", "松", "寇", "碧", "珩", "靳", "鞅", "弼", "焦", "天德", "铁身", "老黑", "半邪", "半山", "一江", "冰安", "皓轩", "子默", "熠彤", "青寒", "烨磊", "愚志", "飞风", "问筠", "旭尧", "妙海", "平文", "冷之", "尔阳", "天宇", "正豪", "文博", "明辉", "行恶", "哲瀚", "子骞", "泽洋", "灵竹", "幼旋", "百招", "不斜", "擎汉", "千万", "高烽", "大开", "不正", "伟帮", "如豹", "三德", "三毒", "连虎", "十三", "酬海", "天川", "一德", "复天", "牛青", "羊青", "大楚", "傀斗", "老五", "老九", "定帮", "自中", "开山", "似狮", "无声", "一手", "严青", "老四", "不可", "随阴", "大有", "中恶", "延恶", "百川", "世倌", "连碧", "岱周", "擎苍", "思远", "嘉懿", "鸿煊", "笑天", "晟睿", "强炫", "寄灵", "听白", "鸿涛", "孤风", "青文", "盼秋", "怜烟", "浩然", "明杰", "昊焱", "伟诚", "剑通", "鹏涛", "鑫磊", "醉薇", "尔蓝", "靖仇", "成风", "豪英", "若风", "难破", "德地", "无施", "追命", "成协", "人达", "亿先", "不评", "成威", "成败", "难胜", "人英", "忘幽", "世德", "世平", "广山", "德天", "人雄", "人杰", "不言", "难摧", "世立", "老三", "若之", "成危", "元龙", "成仁", "若剑", "难敌", "浩阑", "士晋", "铸海", "人龙", "伯云", "老头", "南风", "擎宇", "浩轩", "煜城", "博涛", "问安", "烨霖", "佑天", "明雪", "书芹", "半雪", "伟祺", "从安", "寻菡", "秋寒", "谷槐", "文轩", "立诚", "立果", "明轩", "楷瑞", "炎彬", "鹏煊", "幼南", "沛山", "不尤", "道天", "剑愁", "千筹", "广缘", "天奇", "道罡", "远望", "乘风", "剑心", "道之", "乘云", "绝施", "冥幽", "天抒", "剑成", "士萧", "文龙", "一鸣", "剑鬼", "半仙", "万言", "剑封", "远锋", "天与", "元正", "世开", "不凡", "断缘", "中道", "绝悟", "道消", "断秋", "远山", "蓝血", "无招", "无极", "鬼神", "满天", "飞扬", "醉山", "溪堂", "懿轩", "雅阳", "鑫鹏", "文昊", "松思", "水云", "山柳", "荣轩", "绮彤", "沛白", "慕蕊", "觅云", "鹭洋", "立轩", "金鑫", "健柏", "建辉", "鹤轩", "昊强", "凡梦", "代丝", "远侵", "一斩", "一笑", "一刀", "行天", "无血", "无剑", "无敌", "万怨", "万天", "万声", "万恶", "万仇", "天问", "天寿", "送终", "山河", "三问", "如花", "灭龙", "聋五", "绝义", "绝山", "剑身", "浩天", "非笑", "恶天", "断天", "仇血", "仇天", "沧海", "不二", "碧空", "半鬼", "海", "文涛", "刚", "纲", "晓刚", "洪纲", "浩", "俊", "泽", "博", "思", "海", "振", "宇", "嘉", "彦", "明", "梓", "文", "瑞", "金", "家", "天", "佳", "清", "云", "立", "志", "宏", "奕", "铭", "建", "一", "健", "晨", "卓", "承", "涵", "哲", "永", "皓", "润", "林", "雨", "昊", "智", "景", "恒", "启", "睿", "玉", "伟", "学", "圣", "旭", "致", "远", "宇", "泽", "博", "铭", "浩", "涵", "杰", "轩", "瑞", "启峰", "独毅", "涛", "然", "文", "睿", "豪", "清", "楠", "源", "润", "明", "霖", "宏", "洋", "哲", "恒", "乐", "钦", "林", "俊", "鑫", "潇", "天", "华", "宁", "阳", "皓", "立", "贤", "翔", "袁龙", "航", "旭", "江", "渊", "瑜", "君", "成", "锋", "山", "俊", "驰", "烨", "磊", "天", "佑", "斌", "远", "航", "荣", "轩", "擎", "苍", "弘", "文", "鑫", "磊", "博", "超", "君", "浩", "鹏", "涛", "健", "柏", "明", "杰", "立", "诚", "昊", "天", "思", "聪", "展", "鹏", "笑", "志", "强", "炫", "明", "松", "思", "源", "智", "渊", "思", "淼", "晓", "啸", "天", "宇", "浩", "然", "文", "轩", "鹭", "洋", "振", "家", "乐", "驹", "晓", "博", "文", "博", "昊", "焱", "立", "果", "金", "鑫", "锦", "程", "嘉", "熙", "鹏", "飞", "子", "默", "思", "远", "浩", "轩", "语", "堂", "聪", "健"}
    nvMing = {"醉易", "紫萱", "紫霜", "紫南", "紫菱", "紫蓝", "紫翠", "紫安", "姿", "芷天", "芷容", "芷巧", "芷卉", "芷荷", "芷", "芝", "之桃", "筝", "真", "珍", "贞", "元霜", "元绿", "元槐", "元枫", "语雪", "语山", "语蓉", "语琴", "语海", "语芙", "语儿", "语蝶", "雨雪", "雨文", "雨梅", "雨莲", "雨兰", "幼丝", "幼枫", "又菡", "友梅", "友儿", "映萱", "映安", "迎梦", "迎波", "婴", "易巧", "亦丝", "亦巧", "忆雪", "忆文", "忆梅", "忆枫", "以丹", "依丝", "夜玉", "夜梦", "夜春", "雁荷", "雁风", "雅彤", "雅琴", "寻梅", "寻冬", "雪珍", "雪瑶", "雪旋", "雪卉", "秀", "笑旋", "笑蓝", "笑翠", "晓亦", "晓夏", "向梦", "香萱", "香岚", "夏真", "夏山", "夏兰", "惜雪", "惜蕊", "惜灵", "问夏", "问蕊", "问梅", "雯", "纹", "菀", "莞", "宛", "桐", "彤", "听筠", "听枫", "天曼", "愫", "素", "涑", "思松", "思菱", "水瑶", "水彤", "姝", "书竹", "书易", "诗桃", "诗双", "诗珊", "诗蕊", "山菡", "山蝶", "弱", "若雁", "若菱", "若", "如风", "如冬", "如波", "蓉", "秋柔", "清", "青雪", "青曼", "青枝", "巧蕊", "千亦", "千柔", "千柳", "绮琴", "绮梅", "莆", "萍", "平萱", "平露", "颦", "沛儿", "盼烟", "凝雁", "凝安", "念之", "念柏", "茗", "敏", "妙之", "妙梦", "妙柏", "娩", "梦之", "梦桃", "梦琪", "梦露", "梦凡", "曼容", "曼荷", "曼寒", "曼安", "绿真", "凌文", "凌青", "凌波", "怜阳", "怜珊", "冷雪", "冷荷", "乐萱", "乐天", "乐松", "乐枫", "斓", "澜", "蓝", "兰", "静芙", "靖柏", "寄真", "寄文", "寄琴", "惠", "荟", "幻天", "幻珊", "寒天", "寒凝", "寒梦", "寒荷", "涵易", "涵菱", "含玉", "含烟", "含灵", "含蕾", "海云", "海冬", "涫", "谷蕊", "谷兰", "飞珍", "飞槐", "访云", "访烟", "访天", "访风", "凡阳", "凡旋", "凡梅", "凡灵", "凡蕾", "尔丝", "尔柳", "尔芙", "尔白", "孤菱", "沛萍", "梦柏", "从阳", "绿海", "白梅", "秋烟", "访旋", "元珊", "凌旋", "依珊", "寻凝", "幻柏", "雨寒", "寒安", "芙", "怀绿", "书琴", "水香", "向彤", "曼冬", "璎", "姒", "苠", "淇", "绮", "怜梦", "安珊", "映阳", "思天", "初珍", "冷珍", "海安", "从彤", "灵珊", "夏彤", "映菡", "青筠", "易真", "幼荷", "冷霜", "凝旋", "夜柳", "紫文", "凡桃", "醉蝶", "从云", "冰萍", "小萱", "白筠", "依云", "元柏", "丹烟", "雁", "念云", "易蓉", "青易", "友卉", "若山", "涵柳", "映菱", "依凝", "怜南", "水儿", "从筠", "千秋", "代芙", "之卉", "幻丝", "书瑶", "含之", "雪珊", "海之", "寄云", "盼海", "谷梦", "襄", "雁兰", "晓灵", "向珊", "宛筠", "笑南", "梦容", "寄柔", "静枫", "尔容", "沛蓝", "宛海", "迎彤", "梦易", "惜海", "灵阳", "念寒", "紫", "芯", "沂", "衣", "荠", "莺", "萤", "采梦", "夜绿", "又亦", "怡", "苡", "悒", "梦山", "醉波", "慕晴", "安彤", "荧", "半烟", "翠桃", "书蝶", "寻云", "冰绿", "山雁", "南莲", "夜梅", "翠阳", "芷文", "茈", "南露", "向真", "又晴", "香", "又蓝", "绫", "灵", "雅旋", "千儿", "玲", "听安", "凌蝶", "向露", "从凝", "雨双", "依白", "樱", "颜", "以筠", "含巧", "艳", "晓瑶", "忆山", "以莲", "冰海", "盼芙", "冰珍", "颖", "盈", "半双", "以冬", "千凝", "琦", "笑阳", "香菱", "友蕊", "若云", "天晴", "笑珊", "凡霜", "南珍", "晓霜", "芷云", "谷芹", "芷蝶", "雨柏", "之云", "靖巧", "寄翠", "涵菡", "雁卉", "涵山", "念薇", "忻", "芸", "笙", "芳", "绮兰", "迎蕾", "秋荷", "代天", "采波", "丝", "诗兰", "谷丝", "凝琴", "凝芙", "尔风", "觅双", "忆灵", "水蓝", "书蕾", "访枫", "涵双", "初阳", "从梦", "凝天", "秋灵", "湘", "笑槐", "灵凡", "冰夏", "听露", "翠容", "绮晴", "静柏", "天亦", "冷玉", "以亦", "盼曼", "乐蕊", "凡柔", "曼凝", "沛柔", "迎蓉", "映真", "采文", "曼文", "新筠", "碧玉", "秋柳", "白莲", "亦玉", "幻波", "忆之", "孤丝", "妙竹", "傲柏", "元风", "易烟", "怀蕊", "萃", "寻桃", "映之", "小玉", "尔槐", "翠", "萝", "听荷", "赛君", "闭月", "不愁", "羞花", "紫寒", "夏之", "飞薇", "如松", "白安", "秋翠", "夜蓉", "傲晴", "凝丹", "凌瑶", "初曼", "夜安", "安荷", "青柏", "向松", "绿旋", "芷珍", "凌晴", "新儿", "亦绿", "雁丝", "惜霜", "紫青", "冰双", "映冬", "代萱", "梦旋", "毒娘", "紫萍", "冰真", "幻翠", "向秋", "海蓝", "凌兰", "如柏", "千山", "半凡", "雁芙", "白秋", "平松", "代梅", "香之", "梦寒", "小蕊", "慕卉", "映梦", "绿蝶", "芹", "凌翠", "夜蕾", "含双", "慕灵", "碧琴", "夏旋", "冷雁", "乐双", "念梦", "静丹", "之柔", "新瑶", "亦旋", "雪巧", "中蓝", "莹芝", "一兰", "清涟", "盛男", "竺", "洙", "凝莲", "雪莲", "依琴", "绣连", "友灵", "醉柳", "秋双", "珠", "绮波", "寄瑶", "冰蝶", "孤丹", "半梅", "友菱", "飞双", "醉冬", "寡妇", "沛容", "南晴", "太兰", "紫易", "从蓉", "友易", "衫", "尔竹", "莛", "琳", "巧荷", "寻双", "珊", "芷雪", "又夏", "梦玉", "安梦", "凝荷", "凤", "外绣", "忆曼", "不平", "凝蝶", "以寒", "安南", "思山", "嫣", "芫", "若翠", "曼青", "小珍", "青荷", "代容", "孤云", "慕青", "寄凡", "元容", "丹琴", "寒珊", "飞雪", "妙芙", "碧凡", "思柔", "雁桃", "丹南", "雁菡", "翠丝", "幻梅", "海莲", "宛秋", "问枫", "靖雁", "蛟凤", "大凄", "傻姑", "金连", "梦安", "碧曼", "代珊", "惜珊", "元冬", "葶", "芮", "青梦", "书南", "绮山", "白桃", "从波", "访冬", "含卉", "平蝶", "海秋", "沛珊", "沁", "飞兰", "凝云", "亦竹", "梦岚", "寒凡", "傲柔", "凌丝", "觅风", "平彤", "念露", "翠彤", "秋玲", "安蕾", "若蕊", "灵萱", "含雁", "思真", "盼山", "香薇", "碧萱", "夏柳", "白风", "安双", "凌萱", "盼夏", "幻巧", "怜寒", "傲儿", "冰枫", "如萱", "妖丽", "元芹", "涵阳", "涵蕾", "以旋", "高丽", "灭男", "代玉", "可仁", "可兰", "可愁", "可燕", "妙彤", "易槐", "小凝", "妙晴", "冰薇", "涵柏", "语兰", "小蕾", "忆翠", "听云", "觅海", "静竹", "初蓝", "迎丝", "幻香", "含芙", "夏波", "冰香", "凌香", "妙菱", "访彤", "凡雁", "紫真", "书双", "问晴", "惜萱", "白萱", "靖柔", "凡白", "晓曼", "曼岚", "雁菱", "雨安", "谷菱", "夏烟", "问儿", "青亦", "夏槐", "含蕊", "迎南", "又琴", "冷松", "安雁", "飞荷", "踏歌", "秋莲", "盼波", "以蕊", "盼兰", "之槐", "飞柏", "孤容", "白玉", "傲南", "山芙", "夏青", "雁山", "曼梅", "如霜", "沛芹", "丹萱", "翠霜", "玉兰", "汝燕", "不乐", "不悔", "可冥", "若男", "素阴", "元彤", "从丹", "曼彤", "惋庭", "起眸", "香芦", "绿竹", "雨真", "乐巧", "亚男", "小之", "如曼", "山槐", "谷蓝", "笑容", "香露", "白薇", "凝丝", "雨筠", "秋尽", "婷冉", "冰凡", "亦云", "芙蓉", "天蓝", "沉鱼", "东蒽", "飞丹", "涵瑶", "雁开", "以松", "南烟", "傲霜", "香旋", "觅荷", "幼珊", "无色", "凤灵", "新竹", "半莲", "媚颜", "紫雪", "寒香", "幼晴", "宛菡", "采珊", "凝蕊", "无颜", "莫言", "初兰", "冷菱", "妙旋", "梨愁", "友琴", "水蓉", "尔岚", "怜蕾", "怀蕾", "惜天", "谷南", "雪兰", "语柳", "夏菡", "巧凡", "映雁", "之双", "梦芝", "傲白", "觅翠", "如凡", "傲蕾", "傲旋", "以柳", "从寒", "双双", "无春", "紫烟", "飞凤", "紫丝", "思卉", "初雪", "向薇", "落雁", "凡英", "海菡", "白晴", "映天", "静白", "雨旋", "安卉", "依柔", "半兰", "灵雁", "雅蕊", "初丹", "寒云", "念烟", "代男", "笑卉", "曼云", "飞莲", "幻竹", "晓绿", "寄容", "小翠", "小霜", "语薇", "芷蕾", "谷冬", "血茗", "天荷", "问丝", "沛凝", "翠绿", "寒松", "思烟", "雅寒", "以南", "碧蓉", "绮南", "白凡", "安莲", "访卉", "元瑶", "水风", "凡松", "友容", "访蕊", "若南", "涵雁", "雪一", "怀寒", "幻莲", "碧菡", "绿蕊", "如雪", "珊珊", "念珍", "莫英", "朝雪", "茹嫣", "老太", "曼易", "宛亦", "映寒", "谷秋", "诗槐", "如之", "水桃", "又菱", "迎夏", "幻灵", "初夏", "晓槐", "代柔", "忆安", "迎梅", "夜云", "傲安", "雨琴", "听芹", "依玉", "冬寒", "绿柏", "梦秋", "千青", "念桃", "苑睐", "夏蓉", "诗蕾", "友安", "寻菱", "绮烟", "若枫", "凝竹", "听莲", "依波", "飞松", "依秋", "绿柳", "元菱", "念芹", "如彤", "香彤", "涵梅", "映容", "平安", "赛凤", "书桃", "梦松", "以云", "映易", "小夏", "元灵", "天真", "晓蕾", "问玉", "问薇", "笑晴", "亦瑶", "半芹", "幼萱", "凡双", "夜香", "阑香", "阑悦", "溪灵", "冥茗", "丹妗", "妙芹", "飞飞", "觅山", "沛槐", "太英", "惋清", "太清", "灵安", "觅珍", "依风", "若颜", "觅露", "问柳", "以晴", "山灵", "晓兰", "梦菡", "思萱", "半蕾", "紫伊", "山兰", "初翠", "岂愈", "海雪", "向雁", "冬亦", "柏柳", "青枫", "宝莹", "宝川", "若灵", "冷梅", "艳一", "梦槐", "依霜", "凡之", "忆彤", "英姑", "清炎", "绮露", "醉卉", "念双", "小凡", "尔琴", "冬卉", "初柳", "天玉", "千愁", "稚晴", "怀曼", "雪曼", "雪枫", "缘郡", "雁梅", "雅容", "雁枫", "灵寒", "寻琴", "慕儿", "雅霜", "含莲", "曼香", "慕山", "书兰", "凡波", "又莲", "沛春", "语梦", "青槐", "新之", "含海", "觅波", "嫣然", "善愁", "善若", "善斓", "千雁", "白柏", "雅柏", "冬灵", "平卉", "不弱", "不惜", "灵槐", "海露", "白梦", "尔蓉", "芷珊", "迎曼", "问兰", "又柔", "雪青", "傲之", "绿兰", "听兰", "冰旋", "白山", "荧荧", "迎荷", "丹彤", "海白", "谷云", "以菱", "以珊", "雪萍", "千兰", "大娘", "思枫", "白容", "翠芙", "寻雪", "冰岚", "新晴", "绿蓉", "傲珊", "安筠", "怀亦", "安寒", "青丝", "灵枫", "芷蕊", "寻真", "以山", "菲音", "寒烟", "易云", "夜山", "映秋", "唯雪", "嫣娆", "梦菲", "凤凰", "一寡", "幻然", "颜演", "白翠", "傲菡", "妙松", "忆南", "醉蓝", "碧彤", "水之", "怜菡", "雅香", "雅山", "丹秋", "盼晴", "听双", "冷亦", "依萱", "静槐", "冰之", "曼柔", "夏云", "凌寒", "夜天", "小小", "如南", "寻绿", "诗翠", "丹翠", "从蕾", "忆丹", "傲薇", "宛白", "幻枫", "晓旋", "初瑶", "如蓉", "海瑶", "代曼", "靖荷", "采枫", "书白", "凝阳", "孤晴", "如音", "傲松", "书雪", "怜翠", "雪柳", "安容", "以彤", "翠琴", "安萱", "寄松", "雨灵", "新烟", "妙菡", "雪晴", "友瑶", "丹珍", "白凝", "孤萍", "寒蕾", "妖妖", "藏花", "葵阴", "幻嫣", "幻悲", "若冰", "藏鸟", "又槐", "夜阑", "灭绝", "藏今", "凌柏", "向雪", "丹雪", "无心", "夜雪", "幻桃", "念瑶", "白卉", "飞绿", "怀梦", "幼菱", "芸遥", "芷波", "灵波", "一凤", "尔蝶", "问雁", "一曲", "问芙", "涔雨", "宫苴", "尔云", "秋凌", "灵煌", "寒梅", "灵松", "安柏", "晓凡", "冰颜", "行云", "觅儿", "天菱", "舞仙", "念真", "代亦", "飞阳", "迎天", "摇伽", "菲鹰", "惜萍", "安白", "幻雪", "友桃", "飞烟", "沛菡", "水绿", "天薇", "依瑶", "夏岚", "晓筠", "若烟", "寄风", "思雁", "乐荷", "雨南", "乐蓉", "易梦", "凡儿", "翠曼", "静曼", "魂幽", "茹妖", "香魔", "幻姬", "凝珍", "怜容", "惜芹", "笑柳", "太君", "莫茗", "忆秋", "代荷", "尔冬", "山彤", "盼雁", "山晴", "乐瑶", "灵薇", "盼易", "听蓉", "宛儿", "从灵", "如娆", "南霜", "元蝶", "忆霜", "冬云", "访文", "紫夏", "新波", "千萍", "凤妖", "水卉", "靖儿", "青烟", "千琴", "问凝", "如冰", "半梦", "怀莲", "傲芙", "静蕾", "艳血", "绾绾", "绝音", "若血", "若魔", "虔纹", "涟妖", "雪冥", "邪欢", "冰姬", "四娘", "二娘", "三娘", "老姆", "黎云", "青旋", "语蕊", "代灵", "紫山", "傲丝", "听寒", "秋珊", "代云", "代双", "晓蓝", "茗茗", "天蓉", "南琴", "寻芹", "诗柳", "冬莲", "问萍", "忆寒", "尔珍", "新梅", "白曼", "一一", "安波", "醉香", "紫槐", "傲易", "冰菱", "访曼", "冷卉", "乐儿", "幼翠", "孤兰", "绮菱", "觅夏", "三颜", "千风", "碧灵", "雨竹", "平蓝", "尔烟", "冬菱", "笑寒", "冰露", "诗筠", "鸣凤", "沛文", "易文", "绿凝", "雁玉", "梦曼", "凌雪", "怜晴", "傲玉", "柔", "幻儿", "书萱", "绮玉", "诗霜", "惜寒", "惜梦", "乐安", "以蓝", "之瑶", "夏寒", "妍", "丹亦", "凌珍", "问寒", "访梦", "新蕾", "书文", "平凡", "如天", "怀柔", "语柔", "芾", "宛丝", "南蕾", "迎海", "代芹", "巧曼", "代秋", "慕梅", "幼蓉", "亦寒", "莹", "冬易", "丹云", "丹寒", "丹蝶", "代真", "翠梅", "翠风", "翠柏", "翠安", "从霜", "从露", "初之", "初柔", "初露", "初蝶", "采萱", "采蓝", "采白", "冰烟", "冰彤", "冰巧", "斌", "傲云", "凝冬", "雁凡", "书翠", "千凡", "半青", "惜儿", "曼凡", "乐珍", "新柔", "翠萱", "飞瑶", "幻露", "梦蕊", "安露", "晓露", "白枫", "怀薇", "雁露", "梦竹", "盼柳", "沛岚", "夜南", "香寒", "山柏", "雁易", "静珊", "雁蓉", "千易", "笑萍", "从雪", "书雁", "曼雁", "晓丝", "念蕾", "雅柔", "采柳", "易绿", "向卉", "惜文", "冰兰", "尔安", "语芹", "晓山", "秋蝶", "曼卉", "凝梦", "向南", "念文", "冰蓝", "听南", "慕凝", "如容", "亦凝", "乐菱", "怀蝶", "惜筠", "冬萱", "初南", "含桃", "语风", "白竹", "夏瑶", "雅绿", "怜雪", "从菡", "访波", "安青", "觅柔", "雅青", "白亦", "宛凝", "安阳", "苞络", "雅", "雅", "静", "梦", "洁", "璐", "惠", "茜", "冰", "漫", "妮", "语", "嫣", "倩", "雪", "香", "怡", "灵", "芸", "倩", "雪", "玉", "珍", "茹", "雪", "美", "琳", "欢", "馨", "璇", "雨", "嘉", "娅", "楠", "可", "馨", "月", "婵", "嫦", "曦", "静", "香", "凌", "薇", "依", "娜", "瑶", "婕", "蕊", "慧", "淑", "颖", "乐", "姗", "怡", "钰", "彤", "雯", "瑜", "诗", "琪", "萱", "雁", "莲", "歆", "瑶", "怡", "涵", "婷", "慧", "瑶", "颖", "清", "月", "雯", "洁", "妍", "岚", "玲", "丹", "菲", "萍", "媛", "琳", "怡", "玉", "宁", "娜", "珊", "璇", "彤", "佳", "萱", "欣", "璐", "雅", "琪", "茹", "梦", "倩", "文", "萌", "君", "茜", "乐", "如", "钰", "静", "敏", "洋", "云", "莹", "雪", "瑾", "芸", "心", "佳", "思", "雪", "梦", "怡", "雅", "海", "美", "雨", "欣", "子", "钰", "诗", "金", "嘉", "涵", "慧", "琳", "婷", "敏", "若", "淑", "奕", "楚", "雯", "清", "梓", "文", "晨", "丽", "丹", "佩", "惠", "月", "玉", "婉", "晓", "玲", "倩", "紫", "秋", "洁", "小", "明", "一", "媛", "瑞", "静", "爱", "颖", "梦", "琪", "慕", "尔", "岚", "怜", "梦", "紫", "寒", "雁", "玉", "依", "珊", "芷", "巧", "盼", "烟", "翠", "安", "如", "南", "念", "丹", "琴", "亦", "丝", "若", "凡", "灵", "小", "蕾", "千", "柳", "云", "冰", "珍"}
    if PRINT_MODE == 1 then
        print("ciKu = " .. tostring(#ciKu))
        print("xing = " .. tostring(#xing))
        print("nanMing = " .. tostring(#nanMing))
        print("nvMing = " .. tostring(#nvMing))
    end
    
    local retXing = xing[math.random(1, #xing)]
    local retMing
    if sex == "male" or sex == "男" then
        retMing = nanMing[math.random(1, #nanMing)]
    elseif sex == "female" or sex == "女" then
        retMing = nvMing[math.random(1, #nvMing)]
    end

    local name = retXing .. retMing

    if self:isMaskOff(name) then
        return self:getRandomName(sex)
    else
        return name
    end
    
end

--获取名字的性
function Helper:getXingByName(name)
    local retXing = ""
    local xing = {"安", "柏", "鲍", "毕", "曹", "岑", "昌", "常", "丁", "酆", "傅", "郝", "赫", "华", "姜", "解", "雷", "廉", "吕", "马", "聂", "潘", "彭", "史", "汤", "陶", "滕", "邬", "许", "严", "应", "杭", "喻", "李", "仇", "卢", "项", "江", "万", "堪", "黎", "席", "经", "车", "贾", "裘", "支", "费", "祁", "屈", "纪", "鄂", "田", "尹", "阎", "蔡", "粱", "罗", "咎", "夏", "禹", "高", "管", "穆", "汪", "骆", "周", "袁", "姚", "由", "吴", "钮", "惠", "刘", "诸", "甄", "荀", "张", "孟", "於", "俞", "景", "唐", "石", "吉", "薛", "魏", "符", "包", "羊", "宓", "程", "荣", "詹", "家", "崔", "封", "钱", "洪", "左", "贺", "邵", "邢", "燕", "鹿", "方", "韩", "戚", "范", "冯", "谢", "施", "任", "段", "魏", "柳", "鲁", "裴", "卫", "沈", "陆", "邹", "苏", "王", "孔", "翟", "秦", "何", "韦", "卓", "蒋", "窦", "苗", "郑", "陈", "翁", "牧", "贲", "孙", "牟", "郁", "颜", "闵", "莫", "庞", "樊", "蔺", "嵇", "邱", "向", "楼", "缪", "龚", "温", "褚", "柯", "宋", "徐", "虞", "韶", "郜", "宗", "凌", "郦", "霍", "宣", "狄", "叶", "卜", "元", "单", "邓", "白", "慕", "巫", "廖", "沙", "武", "仲", "柳", "唐", "叶", "方", "连", "宁", "祖", "齐", "阮", "童", "浑", "秋", "尤", "于", "章", "支", "朱", "诸", "顾", "房", "董", "余", "侯", "宫", "伍", "杨", "赵", "乔", "佟", "萧", "占", "干", "雍", "糜", "全", "葛", "苻", "权", "祝", "皮", "庾", "曲", "赖", "瞿", "牛", "资", "公冶", "伯赏", "轩辕", "长孙", "司马", "鲜于", "欧阳", "司空", "单于", "夏侯", "上官", "皇甫", "南宫", "诸葛", "巫马", "阳佟", "太叔", "东方", "尉迟", "呼延", "慕容", "宇文", "淳于", "子车", "闾丘", "东郭", "归海", "赫连", "司空", "乐正", "濮阳", "西门", "百里", "司徒", "令狐", "左丘", "公西", "谷粱", "拓跋", "赵", "钱", "孙", "李", "周", "吴", "郑", "王", "冯", "陈", "卫", "蒋", "沈", "韩", "杨", "朱", "秦", "许", "何", "吕", "张", "孔", "曹", "严", "华", "金", "魏", "陶", "姜", "戚", "谢", "章", "云", "苏", "潘", "葛", "范", "彭", "鲁", "韦", "昌", "马", "苗", "方", "俞", "任", "袁", "柳", "史", "唐", "费", "岑", "薛", "雷", "贺", "倪", "汤", "滕", "殷", "罗", "毕", "郝", "乐", "傅", "齐", "康", "伍", "余", "元", "顾", "孟", "平", "黄", "穆", "萧", "尹", "姚", "邵", "堪", "汪", "狄", "明", "成", "戴", "宋", "庞", "熊", "纪", "舒", "屈", "项", "祝", "董", "粱", "杜", "蓝", "席", "季", "贾", "江", "童", "颜", "郭", "梅", "盛", "林", "刁", "钟", "徐", "高", "夏", "蔡", "田", "樊", "胡", "凌", "霍", "万", "支", "柯", "管", "卢", "莫", "房", "解", "应", "宗", "丁", "邓", "洪", "包", "诸", "左", "石", "崔", "吉", "龚", "程", "裴", "陆", "荣", "翁", "荀", "惠", "甄", "魏", "封", "段", "巫", "乌", "焦", "牧", "秋", "伊", "仇", "甘", "武", "刘", "景", "詹", "束", "龙", "叶", "司", "韶", "郜", "蒲", "赖", "卓", "蒙", "乔", "姬", "冉", "温", "庄", "柴", "慕", "习", "向", "易", "廖", "文", "越", "师", "巩", "聂", "敖", "冷", "简", "曾", "沙", "关", "游", "万", "欧阳", "太史", "端木", "上官", "司马", "东方", "独孤", "南宫", "万俟", "闻人", "夏侯", "诸葛", "尉迟", "公羊", "赫连", "澹台", "皇甫", "宗政", "濮阳", "公冶", "太叔", "申屠", "公孙", "慕容", "仲孙", "钟离", "长孙", "宇文"}

    local xing1 = self:stringSubChinese(name,2)
    local xing2 = self:stringSubChinese(name,1)
    print("获取名字的性",xing1,xing2)
    for i,v in ipairs(xing) do
        if xing1 == v then
           retXing = xing[i]

           return retXing
        end
    end

    for i,v in ipairs(xing) do
        if xing2 == v then
           retXing = xing[i]

           return retXing
        end
    end

end

--截取中文字符
function Helper:stringSubChinese(nickname,len)
    if nickname==nil then
        return ""
    end
    local lengthUTF_8 = #(string.gsub(nickname, "[\128-\191]", ""))
    if lengthUTF_8 <= len then
        return nickname
    else
        local matchStr = "^"
        for var=1, len do
            matchStr = matchStr..".[\128-\191]*"
        end
        local str = string.match(nickname, matchStr)
        return string.format("%s",str);
    end
end

-- 判断是不是中文, 其中包含了中文字符..需要另外去除
function Helper:isChinese(str)
    -- if str == nil or str == "" then
    --     return false
    -- end
    -- local strLen = string.len(str)
    -- if strLen % 3 ~= 0 then
    --     return false
    -- end
    -- for i = 1, strLen do
    --     local byte = string.byte(str, i)
    --     if byte < 128 then -- byte小于128为英文字符
    --         return false
    --     else
    --         end
    -- end
    -- return true

    local ss = {}  
    local k = 1  
    -- print(#s)
    -- print(string.len(s))
    local isTrue = false
    while true do  
        if k > #str then break end  
        local c = string.byte(str,k)  
        if not c then break end  
        if c<192 then  
            -- if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then  
            --     table.insert(ss, string.char(c))  
            -- end  
            k = k + 1
            isTrue = false
        elseif c<224 then  
            k = k + 2
            isTrue = false
        elseif c<240 then  
            if c>=228 and c<=233 then  
                local c1 = string.byte(str,k+1)  
                local c2 = string.byte(str,k+2)  
                if c1 and c2 then  
                    local a1,a2,a3,a4 = 128,191,128,191  
                    if c == 228 then a1 = 184  
                        isTrue = false
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165  
                        isTrue = false
                    end  
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then  
                        isTrue = true
                        -- table.insert(ss, string.char(c,c1,c2))  
                    else
                        isTrue = false
                    end 
                else
                    isTrue = false
                end  
            else
                isTrue = false
            end  
            k = k + 3  
        elseif c<248 then  
            k = k + 4  
            isTrue = false
        elseif c<252 then  
            k = k + 5  
            isTrue = false
        elseif c<254 then  
            k = k + 6  
            isTrue = false
        end  
        -- add by XiaoZhiWei 2018/06/15 16:18:24 如果名字前面部分任何地方存在非法字符,则不能取
        if isTrue == false then
            break
        end
    end  
    return isTrue
end

-- 处理请求响应文本 -----------（注：所有trans检查的请求需保证status必需为200才能调用此方法）
function Helper:getResponseData(str, status)
    if status == 200 then
        if not str or string.len(str) <= 0 then
            return false, "请检查网络链接"
        end
        local list = assert(json.decode(str))
        if MapIsEmpty(list) then
            return false, "数据解析错误"
        end
        if PRINT_MODE == 1 then
            print("MapIsEmpty = " .. tostring(MapIsEmpty(list.data)))
            print("list.errcode = " .. tostring(list.errcode == 0))
        end
        if list.errcode == 0 then
            if not list.data then
                
                end
            return true, list.data
        end
        
        if not list.errmsg then
            list.errmsg = "操作失败"
        end
        
        return false, list.errmsg
    else
        return false, "网络请求失败"
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 19:53:22
-- @desc 得到随机参数
function Helper:getRandomParam(...)
    local inputList = {...}
    local randomList = {}
    for i, v in ipairs(inputList) do
        randomList[i] =
            {
                id = i,
                weight = 1
            }
    end
    local index = self:RandomByWeight(randomList, "weight", "id")
    return inputList[index]
end

-- 获取随机ID结果 参数列表
function Helper:RandomIndexByPercent(...)
    local inputList = {...}
    local randomList = {}
    for i, v in ipairs(inputList) do
        randomList[i] =
            {
                percent = v,
                id = i
            }
    end
    return self:RandomByWeight(randomList, "percent", "id")
end

-- 传递一个字符串获取随机序号 （字符串可用逗号隔开）
function Helper:RandomIndexByPercentWithString(str)
    if str == nil or string.len(str) <= 0 then
        return nil
    end
    local inputList = string.split(str, ";")
    local randomList = {}
    for i, v in ipairs(inputList) do
        randomList[i] =
            {
                percent = tonumber(v),
                id = i
            }
    end
    return self:RandomByWeight(randomList, "percent", "id")
end

-- 权重
-- list 为用随机的数组
-- weightName, 数组中的table中, 用来作为权重的变量名
-- returnName, 从数组中获得的随机项的属性, 如果为空, 则返回该项在数组中的位置
function Helper:RandomByWeight(list, weightName, returnName)
    local randomList = {}
    local totalWeight = 0
    for k, v in pairs(list) do
        local weight, id
        if returnName == nil or returnName == "" then
            id = k
        else
            id = v[returnName]
        end
        if weightName == nil or weightName == "" then
            weight = v
        else
            weight = tonumber(v[weightName])
        end
        weight = math.floor(weight * 1000)
        assert(id and weight)
        table.insert(randomList, {id = id, weight = weight})
        totalWeight = totalWeight + weight
    end
    local randomValue = math.random(1, totalWeight)-- 前开后闭
    for i, v in ipairs(randomList) do
        local weight = v.weight
        if weight > 0 then -- 大于0才做处理
            randomValue = randomValue - weight
            if randomValue <= 0 then
                return v.id
            end
        else -- 小于等于0的不能被随机到
            end
    end
    -- assert(nil, "function RandomByWeight(list, weightName, returnName)")
    return nil
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/08 14:58:35
-- @desc 从字符串中随意获取一个值,多个值之间用封号隔开
function Helper:getRandomString(str)
    if type(str) ~= "string" then
        return
    end
    local list = string.split(str, ";")
    return list[math.random(1, #list)]
end

-- 将数字转换为字符串, 并带有正负符号
function Helper:numberToStringWithPlus(num)
    local result = ""
    if num == nil or type(num) ~= "number" then
        return "+0"
    end
    if num >= 0 then
        result = "+"
    else
        result = "-"
    end
    return result .. tostring(math.abs(num))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/09 16:30:15
-- @desc 向下去整 注:公式计算出来结果为整数时,向下取整会少1. 这是一个bug
function Helper:mathFloor(num)
    if num == nil or type(num) ~= "number" then
        return num
    elseif self:isNan(num) == true then
        return 0
    else
        return math.floor(num + 0.000000000001)
    end
end

-- 打印
function Helper:print_lua_table_ChunWai(lua_table, indent)
    -- if true then
    --  return
    -- end
    local function _print_lua_table(lua_table, indent)
        if lua_table == nil then
            print("table is nil")
            return
        end
        
        indent = indent or 0
        
        for k, v in pairs(lua_table) do
            if type(k) == "string" then
                k = string.format("%q", k)
            end
            
            local szSuffix = ""
            if type(v) == "table" then
                szSuffix = "{"
            end
            
            local szPrefix = string.rep("    ", indent)
            
            local formatting = szPrefix .. "[" .. k .. "]" .. " = " .. szSuffix
            
            if type(v) == "table" then
                print(formatting)
                _print_lua_table(v, indent + 1)
                print(szPrefix .. "},")
            else
                local szValue = ""
                if type(v) == "string" then
                    szValue = string.format("%q", v)
                else
                    szValue = tostring(v)
                end
                print(formatting .. szValue .. ",")
            end
        end
    end
    return _print_lua_table(lua_table, indent)
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/10 17:28:54
-- @desc 纠正os.date 方法 防止时区修改
function Helper:date(str, time)
    if str == nil or time == nil or type(time) ~= "number" then
        assert(nil, "出错了格式不对")
        return
    end
    
    return os.date(str, time + self:getTimeZone())
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/12 11:45:01
-- @desc 在区域内将item摆放成矩阵
function Helper:foreachItemInMatrixArea(areaSize, itemSize, countX, countY, edgeGapX, edgeGapY, callback, directionX, directionY)
    switch(directionX, {[1] = 1, [-1] = -1, default = 1});
    switch(directionY, {[1] = 1, [-1] = -1, default = 1});
    
    callback = Helper:getDef(callback, function() end)
    local gapX = (areaSize.width - edgeGapX * 2 - countX * itemSize.width) / (countX - 1)
    local gapY
    if countY == 1 then
        gapY = 0
    else
        gapY = (areaSize.height - edgeGapY * 2 - countY * itemSize.height) / (countY - 1)
    end
    local index = 1
    for iy = 1, countY do
        for ix = 1, countX do
            local x = edgeGapX + (ix - 1) * (gapX + itemSize.width) + itemSize.width / 2
            local y = areaSize.height - (edgeGapY + (iy - 1) * (gapY + itemSize.height) + itemSize.height / 2)
            
            if directionX == -1 then
                x = areaSize.width - x
            end
            
            callback(index, ix, iy, x, y)
            index = index + 1
        end
    end
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/13 14:51:51
-- @desc 调试模式和打印模式开启的情况下,该方法负责打印方法的参数信息及参数基本格式检查
function Helper:checkParamsWithDebug(funcName, params, checkParams)
    local printLog = function(...)
        print(...)
    end
    
    if PRINT_MODE ~= 1 then
        printLog = function() end
    end
    
    local str = ""
    if type(params) == "table" then
        for k, v in pairs(params) do
            str = str .. tostring(v) .. "   "
        end
        printLog(funcName, str)
    else
        printLog(funcName, str)
        printLog("Helper:checkParamsWithDebug(funcName, params, checkParams)", "第二个参数params不是一个table类型")
    end
    
    local result = true
    if type(checkParams) == "table" then
        for k, v in pairs(checkParams) do
            if type(v) == "string" then
                if type(params[k]) == v then
                    printLog("类型一致", params[k], v)
                else
                    printLog("类型不对", params[k], v)
                    if result == true then
                        result = false
                    end
                end
            elseif type(v) == "function" then
                if v(params[k]) == true then
                    printLog("格式正确", params[k])
                else
                    printLog("格式错误", params[k])
                end
                if result == true then
                    result = v(params[k])
                end
            end
        end
    else
        printLog("Helper:checkParamsWithDebug(funcName, params, checkParams)", "第三个参数checkParams不是一个table类型")
    end
    
    if result == false and DEBUG_MODE == 1 then
        assert(nil)
    end
    
    return result
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/13 21:04:06
-- @desc 调试模式和打印模式开启的情况下,该方法负责打印方法的参数信息及参数基本格式检查 提升版
function Helper:checkParamsError(funcName, count, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
    if count < 1 or (arg1 == nil and arg2 == nil) or ((arg1 ~= nil and arg2 ~= nil and arg1 ~= "") and type(arg1) == arg2) then
        else
        if DEBUG_MODE == 1 then
            print(funcName, "参数1和参数2有错误,参数不是预期所需的类型", arg1, arg2)
        -- assert(nil)
        end
        return true
    end
    if count < 2 or (arg3 == nil and arg4 == nil) or ((arg3 ~= nil and arg4 ~= nil and arg3 ~= "") and type(arg3) == arg4) then
        else
        if DEBUG_MODE == 1 then
            print(funcName, "参数3和参数4有错误,参数不是预期所需的类型", arg2, arg4)
        -- assert(nil)
        end
        return true
    end
    if count < 3 or (arg5 == nil and arg6 == nil) or ((arg5 ~= nil and arg6 ~= nil and arg5 ~= "") and type(arg5) == arg6) then
        else
        if DEBUG_MODE == 1 then
            print(funcName, "参数5和参数6有错误,参数不是预期所需的类型", arg5, arg6)
        -- assert(nil)
        end
        return true
    end
    if count < 4 or (arg7 == nil and arg8 == nil) or ((arg7 ~= nil and arg8 ~= nil and arg7 ~= "") and type(arg7) == arg8) then
        else
        if DEBUG_MODE == 1 then
            print(funcName, "参数7和参数8有错误,参数不是预期所需的类型", arg7, arg8)
        -- assert(nil)
        end
        return true
    end
    if count < 5 or (arg9 == nil and arg10 == nil) or ((arg9 ~= nil and arg10 ~= nil and arg9 ~= "") and type(arg9) == arg10) then
        else
        if DEBUG_MODE == 1 then
            print(funcName, "参数9和参数10有错误,参数不是预期所需的类型", arg9, arg10)
        -- assert(nil)
        end
        return true
    end
    if count < 6 or (arg11 == nil and arg12 == nil) or ((arg11 ~= nil and arg12 ~= nil and arg11 ~= "") and type(arg11) == arg12) then
        else
        if DEBUG_MODE == 1 then
            print(funcName, "参数11和参数12有错误,参数不是预期所需的类型", arg11, arg12)
        -- assert(nil)
        end
        return true
    end
    if count < 7 or (arg13 == nil and arg14 == nil) or ((arg13 ~= nil and arg14 ~= nil and arg13 ~= "") and type(arg13) == arg14) then
        else
        if DEBUG_MODE == 1 then
            print(funcName, "参数13和参数14有错误,参数不是预期所需的类型", arg17, arg14)
        -- assert(nil)
        end
        return true
    end
    if count < 8 or (arg15 == nil and arg16 == nil) or ((arg15 ~= nil and arg16 ~= nil and arg15 ~= "") and type(arg15) == arg16) then
        else
        if DEBUG_MODE == 1 then
            print(funcName, "参数15和参数16有错误,参数不是预期所需的类型", arg15, arg16)
        -- assert(nil)
        end
        return true
    end
    if count < 9 or (arg17 == nil and arg18 == nil) or ((arg17 ~= nil and arg18 ~= nil and arg17 ~= "") and type(arg17) == arg18) then
        else
        if DEBUG_MODE == 1 then
            print(funcName, "参数17和参数18有错误,参数不是预期所需的类型", arg17, arg18)
            assert(nil)
        end
        return true
    end
    if count < 10 or (arg19 == nil and arg20 == nil) or ((arg19 ~= nil and arg20 ~= nil and arg19 ~= "") and type(arg19) == arg20) then
        else
        if DEBUG_MODE == 1 then
            print(funcName, "参数19和参数20有错误,参数不是预期所需的类型", arg19, arg20)
        -- assert(nil)
        end
        return true
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 14:37:44
-- @desc 根据中文比较名比较数字大小
function Helper:compareTwoNumberWithCN(num1, num2, logic)
    if num1 == nil or tonumber(num1) == nil then
        return false
    elseif num2 == nil or tonumber(num2) == nil then
        return true
    else
        return switch(logic,
            {
                ["小于"] = function() return tonumber(num1) < tonumber(num2) end,
                ["小于等于"] = function() return tonumber(num1) <= tonumber(num2) end,
                ["等于"] = function() return tonumber(num1) == tonumber(num2) end,
                ["大于等于"] = function() return tonumber(num1) >= tonumber(num2) end,
                ["大于"] = function() return tonumber(num1) > tonumber(num2) end,
                ["default"] = false
            })
    end
end

function try(func)
    local retMsg = nil
    local ret, msg = xpcall(func, function(msg)
        retMsg = msg
        print(debug.traceback(3, msg))
    end)
    return ret, retMsg
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/31 21:08:22
-- @desc 概率
function Helper:percentFunc(percent, func)
    if percent >= math.random(1, 100) then
        if type(func) == "function" then
            func()
        end
        return true
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/21 16:42:05
-- @desc 获取叶子节点
function Helper:getLeaf(obj, path) 
    if type(obj) == "table" and type(path) == "string" and #path > 0 then
    else
        return nil
    end

    local args = string.split(path, ".")
    if #args == 1 then      
        if obj[path] == nil then
            return nil
        else
            return obj, path
        end
    elseif #args > 1 then       
        local parent = obj
        local varName 
        for i = 1, #args do
            if i == #args then
                varName = args[i]
            else            
                parent = parent[args[i]]

                -- 路径中有元素为空
                if parent == nil or type(parent) ~= "table" then
                    return nil
                end
            end                     
        end

        if parent[varName] == nil then
            return nil
        else
            return parent, varName
        end
    else        
        return nil
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/15 11:11:12
-- @desc 获取指定节点的值
function Helper:getLeafValue(obj, path)
    local parent, childName = self:getLeaf(obj, path)
    if parent ~= nil then
        return parent[childName]
    else
        return nil
    end
end

function Helper:changeNumberDateToStringDate( ... )
    local list = { ... }
    local strList = {"年","月","日","时","分","秒"}
    local str = ""
    local hasStr = false
    for k,v in pairs(list) do 
        if (tonumber(v) ~= 0 and hasStr == false) or hasStr == true then
            str = str .. tostring(v) .. strList[k] 
            hasStr = true
        end
    end
    return str
end

--@desc: 将时间戳转换成中文格式
--@author:Liang SongQiang
--@time:2019-01-15 19:47:31
--@time: 时间戳
--@return X年X月X日 X时X分X秒
function Helper:getTimeStrCNFormat(time)
    local date = os.date("*t",time)

    return date.year.."年"..date.month.."月"..date.day.."日"..date.hour.."时"..date.min.."分"..date.sec.."秒"
end

--@desc: 将当前时间转换成中文格式
--@timeStr: 时间字符串 格式：20251016145959
--@return X年X月X日 X时X分X秒
function Helper:getTimeStrToCN(timeStr)
    -- 格式：20251016145959 -> x年x月x日x时x分x秒
    local timeStr = tostring(timeStr)
    local year = string.sub(timeStr, 1, 4)
    local month = string.sub(timeStr, 5, 6)
    local day = string.sub(timeStr, 7, 8)
    local hour = string.sub(timeStr, 9, 10)
    local min = string.sub(timeStr, 11, 12)
    local sec = string.sub(timeStr, 13, 14)
    return year .. "年" .. month .. "月" .. day .. "日" .. hour .. "时" .. min .. "分" .. sec .. "秒"
end

--@desc 检查是否需要记住物品的ONLYID
function Helper:isNeedToRememberOnlyId(itemType)
    local tb = {
        ["剑"] = true,
        ["刀"] = true,
        ["棍"] = true,
        ["鞭"] = true,
        ["暗器"] = true,
        ["神器"] = true,
    }

    return tb[itemType]
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/28 22:07:20
-- @desc 计算方法执行的时间差
function Helper:getFuncDiffTime(func)
    if type(func) ~= "function" then
        return 0
    end
    local st = GetLocalTime()
    func()
    return GetLocalTime() - st 
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/10 18:46:46
-- @params 
-- @desc 拆分房间名和占位符
local ITEM_TYPE_BLANK = 1
local ITEM_TYPE_ROOM = 2
local otherStr = {["▏"]=true, ["\n"]=true,["—"] = true, ["╲"] = true, ["　"] = true, [" "] = true, ["╱"] = true, ["＠"] = true}
function Helper:splitMapData(str)
    local mapLines = {}
    local mapLine = {}
    local roomName = "" -- 房间名称
    local spaceString = "" -- 占位符
    local mapRoomNamePosArray = {}
    local roomNameCount = 0
    local index = 0

    local strTb = string.splitUTF8(str)
    for i,v in ipairs(strTb) do
        index = index + string.len(v)
        if otherStr[v] then


            -- 判断是否需要添加房间名
            if string.len(roomName) > 0 then
                if PRINT_MODE == 1 then
                    -- print("roomNameCount = "..tostring(roomNameCount).."roomName = "..tostring(roomName))
                end
                table.insert(mapLine, {type = ITEM_TYPE_ROOM, text = roomName})
                roomName = ""

                -- 房间名位置
                roomNameCount = roomNameCount + 1
                table.insert(mapRoomNamePosArray, {x = #mapLines, y = #mapLine, index = index})
            end

            -- 判断是否需要换行
            if v == "\n" then
                if string.len(spaceString) > 0 then
                    if PRINT_MODE == 1 then
                        -- print("spaceString = "..tostring(spaceString))
                    end
                    table.insert(mapLine, {type = ITEM_TYPE_BLANK, text = spaceString})
                    spaceString = ""
                end
                if PRINT_MODE == 1 then
                    -- print("增加行")
                end
                table.insert(mapLines, mapLine)
                mapLine = {}
            else
                -- 连接占位符
                spaceString = spaceString..v
                -- table.insert(mapLine, {type = ITEM_TYPE_BLANK, text = v})
            end
            if PRINT_MODE == 1 then
                -- print("占位符号:"..v)
            end
        else

            -- 判断是否需要添加占位符
            if string.len(spaceString) > 0 then
                -- print("spaceString = "..tostring(spaceString))
                table.insert(mapLine, {type = ITEM_TYPE_BLANK, text = spaceString})
                spaceString = ""
            end

            -- 连接房间名
            if PRINT_MODE == 1 then
                -- print("名字符号:"..v)
            end
            roomName = roomName..v
            -- table.insert(roomName, v)
        end
    end

    -- 最后一次判断,是否有遗留的符号需要添加
    if string.len(roomName) > 0 then
        table.insert(mapLine, {type = ITEM_TYPE_ROOM, text = roomName})
        roomName = ""

        -- 房间名位置
        roomNameCount = roomNameCount + 1
        table.insert(mapRoomNamePosArray, {x = #mapLines, y = #mapLine, index = index})
    elseif string.len(spaceString) > 0 then
        spaceString = ""
        table.insert(mapLine, {type = ITEM_TYPE_BLANK, text = spaceString})
    end

    table.insert(mapLines, mapLine)
    return mapLines, mapRoomNamePosArray
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/10 18:45:28
-- @params 
-- @desc 从房间id数据中得到房间id数组
function Helper:getRoomIdArray(roomIdData)
    local idStr = roomIdData
    idStr = string.gsub(idStr, "\n", ",")
    idStr = string.gsub(idStr, ",", "\",\n\"")
    -- idStr = string.gsub(idStr, ",", "\",\r\"")
    idStr = string.gsub(idStr, "\"{", "{")
    idStr = string.gsub(idStr, "{", "{\"")
    idStr = string.gsub(idStr, "}\"", "}")
    idStr = string.gsub(idStr, "}", "\"}")  
    idStr = "return {\""..idStr.."\"}"
    idStr = string.gsub(idStr, [["}"}]], [["}}]])
    if PRINT_MODE == 1 then
        print("idStr = "..tostring(idStr))
    end

    local idArray = assert(loadstring(idStr))()
    return idArray
end

local function Setnew(tab)
    local set = {}
    for _, v in ipairs(tab) do
        set[v] = true
    end
    return set
end

--取并集
function Helper:arrayUnion(array,array1)
    local ret = {}

    for k,v in pairs(array) do
        ret[v] = true
    end

    for k,v in pairs(array1) do
        ret[v] = true
    end

    return table.keys(ret)

end

--取交集
function Helper:arrayIntersection(array,array1)
    array = Setnew(array)
    array1 = Setnew(array1)

    local ret = {}
    for k , v in pairs(array) do
        ret[k] = array1[k]
    end

    return table.keys(ret)    
end

function Helper:changeNumZeroToTenForCN(num)
    num = tonumber(num)
    if type(num) ~= "number" and (num < 0 or num > 10) then
        assert(false,"数字转换出错，只支持转换 0 ~ 10 ")
    end

    local tab = { [0] = "零","壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾"}

    return tab[num]
end

--去掉字符串中空格
function Helper:deleteSpaceFromStr(str)
    if type(str) ~= "string" then
        return ""
    end
    local tab = string.getChars(str)

    if tab ~= nil and type(tab) == "table" then
		for i = #tab,1,-1 do 
			if tab[i] == " " or string.byte(tab[i]) == 32 then
				table.remove(tab,i)
			end
		end
		if #tab == 0 then
			return ""
		end
		
        local finalStr = ""
        for k,v in pairs(tab) do 
            finalStr = finalStr .. v
        end
        return finalStr
       
    else
        return ""
	end
end

function Helper:getNoColorStr(str)

	for _, v in pairs(GetColorList()) do
		local s, e = string.find(str, v.id)
		if s ~= nil and e ~= nil then
			str = string.gsub(str,v.id,"")
		end
	end

	return str
end

--[[
    2020法定节假日
    劳动节   5月1日~5月5日
    端午节	6月25日~6月27日
    中秋节，国庆节	10月1日~10月8日
]]
function Helper:isHoliday(time)
    time = Helper:getDef(time,GetTime())
    local tab = {
        [2020] = {
            [5] = {1,2,3,4,5},
            [6] = {25,26,27},
            [10] = {1,2,3,4,5,6,7,8},
        },
        [2022] = {
            [1] = {1,2,3,31},
            [2] = {1,2,3,4,5,6},
            [4] = {3,4,5,30},
            [5] = {1,2,3,4},
            [6] = {3,4,5},
            [9] = {10,11,12},
            [10] = {1,2,3,4,5,6,7},
            [12] = {31}
        },
        [2023] = {
            [1] = {1,2,21,22,23,24,25,26,27},
            [4] = {29,30},
            [5] = {1,2,3},
            [6] = {22,23,24},
            [9] = {29,30},
            [10] = {1,2,3,4,5,6},
            [12] = {29,30,31},
        },
        [2024] = {
            [1] = {1}
        }
    }
    local Y = tonumber(Helper:date("%Y",time))
    local m = tonumber(Helper:date("%m",time))
    local d = tonumber(Helper:date("%d",time))
    
    print(Y,m,d)

    if type(tab[Y]) == "table" and type(tab[Y][m]) == "table" then
        for i,v in ipairs(tab[Y][m]) do
            if v == d then
                return true
            end
        end
    end

    return false
end

--未成年人禁止游戏时间
function Helper:isForbidDay(time)
    time = Helper:getDef(time,GetTime())
    local tab = {
        [2022] = {
            [4] = {2},
            [5] = {7},
            [10] = {8,9},
        },
        [2023] = {
            [1] = {28,29},
            [4] = {23},
            [5] = {6},
            [6] = {25},
            [10] = {7,8}
        }
    }
    local Y = tonumber(Helper:date("%Y",time))
    local m = tonumber(Helper:date("%m",time))
    local d = tonumber(Helper:date("%d",time))
    
    print(Y,m,d)

    if type(tab[Y]) == "table" and type(tab[Y][m]) == "table" then
        for i,v in ipairs(tab[Y][m]) do
            if v == d then
                return true
            end
        end
    end

    return false
end

--@desc: 保留小数点后几位
--@author:Seven_L
--@time:2020-04-21 14:45:42
--@nNum: 目标数字
--@n: 保留的位数
function Helper:preciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum
    end
    n = n or 0
    n = Helper:mathFloor(n)
    if n < 0 then
        n = 0
    end
    local nDecimal = 10 ^ n
    local nTemp = Helper:mathFloor(nNum * nDecimal)
    local nRet = nTemp / nDecimal
    return nRet
end

--@desc: 四舍五入精确到第几位小数
--@author:LvBin
--@time:2023-03-27 11:40:12
--@nNum:
	--@n: 
--@return
function Helper:roundPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" or n < 0 then
        return nNum
    end

    local nDecimal = 10 ^ n

    nNum = string.format("%."..n.."f",math.floor(nNum * nDecimal + 0.5) / nDecimal)

    nNum = tonumber(nNum)

    return nNum
end


--@desc: 根据方向索引获取反方向
--@author:Liang SongQiang
--@time:2019-06-11 15:46:48
function Helper:getNegativeDirectionByIndex(dirIndex)
    dirIndex = dirIndex or 0

    local dir =
        switch(
        tostring(dirIndex),
        {
            ["0"] = "2",
            ["1"] = "3",
            ["2"] = "0",
            ["3"] = "1",
            ["4"] = "6",
            ["5"] = "7",
            ["6"] = "4",
            ["7"] = "5",
            ["8"] = "8",
        }
    )
    return dir
end

--@desc: 获取方向索引对应的字符串
--@author:Liang SongQiang
--@time:2019-06-11 15:48:57
function Helper:getDirectionStringByIndex(dirIndex)
    dirIndex = dirIndex or 0

    local dir =
        switch(
        tostring(dirIndex),
        {
            ["0"] = "up",
            ["1"] = "right",
            ["2"] = "down",
            ["3"] = "left",
            ["4"] = "leftUp",
            ["5"] = "rightUp",
            ["6"] = "rightDown",
            ["7"] = "leftDown",
            ["8"] = "center",
        }
    )

    return dir
end

--四舍五入取整
function Helper:getRoundNumber(num)
    if num == nil or type(num) ~= "number" then
        return num
    elseif self:isNan(num) == true then
        return 0
    end

    if num - self:mathFloor(num) >= 0.5 then
        return self:mathFloor(num + 1)
    else
        return self:mathFloor(num)
    end
end

function Helper:getActiveTime(timeArray,timeSection)
    local totalTime = 0

    local SegmentTree = require("third.tree.SegmentTree")
    --@RefType [SegmentTree]
    local seTree = SegmentTree:create(0, 2147483647, 0)
    for _, timeInfo in ipairs(timeArray) do
        seTree:update(timeInfo.startTime, timeInfo.finishTime - 1, 1)
    end

    totalTime = seTree:sum(timeSection.startTime, timeSection.finishTime - 1)

    return totalTime
end

--@desc: 根据年月日时分秒获取时间戳
--@author:LvBin
--@time:2022-09-21 15:02:41
--@timeData: 
--@return
function Helper:getTimeStampWithData(timeData)
    local year = tonumber(timeData[1])
    local month = tonumber(timeData[2])
    local day = tonumber(timeData[3])
    local hour = tonumber(timeData[4])
    local min = tonumber(timeData[5])
    local sec = tonumber(timeData[6])

    if year == nil or month == nil or day == nil or hour == nil or min == nil or sec == nil then
        assert(year,"----------Helper:getTimeStampWithData---------参数有误") 
    end
    
    local retTime = (os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec}) - Helper:getTimeZone())
    
    if os.date("*t", retTime).isdst then
        return retTime + 3600
    else
        return retTime
    end
end

return Helper
00000000000000
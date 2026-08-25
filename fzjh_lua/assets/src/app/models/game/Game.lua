TableProxy = require("third.tableProxy.TableProxy")
MainPerformanceAnalysisSystem = require("third.PerformanceAnalysis.PerformanceAnalysisSystem"):create()

local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")

local ErrmsgRecord = require("app.models.Record.ErrmsgRecord.ErrmsgRecord")

local printLogEnabled = false -- 用来控制是否启用当前文件中的打印日志 add by TangJian 2017/03/27 19:54:01

local old_print = print
if printLogEnabled == true then
    function print(...)
        old_print([[collectgarbage("count") = ]], collectgarbage("count"))
        return old_print(...)
    end
end

-- 使用未被修改的迭代器
local pairs = pairs
local ipairs = ipairs

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/24 12:23:34
-- @desc 得到当前所有通过require载入过的文件返回的table为key的数组
local function getAllPackageLoadedMap()
    local count = 0
    local map = {}
    
    -- 不清除载入过的包
    for k, v in pairs(package.loaded) do
        if type(v) == "table" then
            map[v] = true
            count = count + 1
        end
    end
    
    -- 不清除全局变量
    for k, v in pairs(_G) do
        if type(v) == "table" then
            map[v] = true
            count = count + 1
        end
    end
    
    -- print("count = ", count)
    
    return map
end

local cleanTableDepthMax = 3
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 19:53:07
-- @desc 清理table
function cleanTable(root, lookup_table, depth)
    local depth = 0

    if lookup_table == nil then -- add
        lookup_table = getAllPackageLoadedMap()-- 防止已经载入的模块被清除
    end
    local function _cleanTable(tb)
        local objType = type(tb)
        if objType == "table" then
        else
            return nil
        end
        
        -- 记录清理过的table add by TangJian 2016/11/24 12:33:01
        if lookup_table[tb] then
            return
        end
        lookup_table[tb] = true

        depth = depth + 1

        if depth < cleanTableDepthMax then
            for k, v in pairs(tb) do
                tb[k] = _cleanTable(tb[k])-- 只清理table类型变量 add by TangJian 2016/11/24 12:33:03
            end
        end

        depth = depth - 1
        return nil
    end
    return _cleanTable(root)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 游戏类, 包含游戏逻辑部分的初始化, 载入, 开始 等方法
local Game =
    {
        _global = {}, -- game开始后, 记录所有全局变量
        _globalCount = 0, -- 全局变量数目 add by TangJian 2016/11/08 19:49:54
        _requires = {}, -- 包含过的模块 add by TangJian 2016/11/08 19:49:44


        _currFrame = 0, -- 当前帧数

        __schedulerHandleList = {}, -- 全局调度器列表

        __logicLoop = nil, -- 全局主逻辑循环
        __renderLoop = nil, -- 全局主渲染循环
    }

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化
function Game:init(func)
    log, logt = require("app.extends.PrintLog")()-- 日志模块 add by TangJian 2016/11/14 20:07:53
    -- log, logt = function() end, function() end
    self:cleanRequire()-- 清除require的模块
    self:recordRequire()-- 记录require的模块
    self:cleanGlobal()-- 清除全局变量
    self:recordGlobal()-- 记录全局变量
    
    Loader = require("app.models.loader.Loader")-- 载入模块 add by TangJian 2016/11/14 20:07:52
    
    -- 垃圾回收设置
    collectgarbage("restart")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 200)
    
    -- 载入配置
    self:setAnimationInterval()
    self:load(func)
end

-- 获取当前帧数
function Game:getCurrFrame()
    return self._currFrame
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 清理所有全局变量
function Game:cleanGlobal()
    cleanTable(self._global)
    self._global = nil
    self._global = {}
    self._globalCount = 0
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 记录全局变量
function Game:recordGlobal()
    cc.exports = {}
    setmetatable(cc.exports, {
        __newindex = function(_, name, value)
            _G[name] = value
        end,
        
        __index = function(_, name)
            return _G[name]
        end
    })
    
    -- 为_G保存变量
    setmetatable(_G, {
        __newindex = function(_, name, value)
            local gvalue = rawget(_G, name)
            if gvalue == nil then
                if self._global[name] == nil then
                    self._globalCount = self._globalCount + 1
                end
                self._global[name] = value
                if printLogEnabled then
                    logt("定义全局变量", "name = " .. tostring(name) .. ", value = " .. tostring(value), "\n", "当前全局变量数目: " .. tostring(self._globalCount))
                end
            else
                assert(value ~= nil, "全局变量", name, "不能清空")
                return rawset(_G, name, value)
            end
        end,
        __index = function(_, name)
            local value = rawget(_G, name)
            if value == nil then
                return self._global[name]
            else
                return value
            end
        end
    })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 禁用全局变量定义
function Game:disableGlobal()
    cc.exports = {}
    setmetatable(cc.exports, {
        __newindex = function(_, name, value)
            local gvalue = rawget(_G, name)
            if gvalue == nil then
                if self._global[name] == nil then
                    self._globalCount = self._globalCount + 1
                end
                
                self._global[name] = value
                if printLogEnabled then
                    logt("定义全局变量", "name = " .. tostring(name) .. ", value = " .. tostring(value), "\n", "当前全局变量数目: " .. tostring(self._globalCount))
                end
            else
                assert(value ~= nil, "全局变量", name, "不能清空")
                return rawset(_G, name, value)
            end
        end,
        
        __index = function(_, name)
            return _G[name]
        end
    })
    
    -- 为_G保存变量
    setmetatable(_G, {
        __newindex = function(_, name, value)
            local gvalue = rawget(_G, name)
            if gvalue == nil then
                if self._global[name] == nil then
                    if DEBUG_MODE == 1 then
                        error(tostring(name) .. " 不能被定义为全局变量. 如果需要定义请使用 cc.exports." .. tostring(name))
                    end
                    self._globalCount = self._globalCount + 1
                end
                self._global[name] = value
                if printLogEnabled then
                    logt("定义全局变量", "name = " .. tostring(name) .. ", value = " .. tostring(value), "\n", "当前全局变量数目: " .. tostring(self._globalCount))
                end
            else
                assert(value ~= nil, "全局变量", name, "不能清空")
                return rawset(_G, name, value)
            end
        end,
        __index = function(_, name)
            local value = rawget(_G, name)
            if value == nil then
                return self._global[name]
            else
                return value
            end
        end
    })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 记录所有后来require的模块
local oldRequire = nil
function Game:recordRequire()
    if oldRequire == nil then
        oldRequire = require
        require = function(path)
            if path == nil then
                error([[path == nil]])
            else
                if package.loaded[path] == nil then
                    if printLogEnabled then
                        logt("require模块", "path = " .. tostring(path), ", 第一次")
                    end
                    self._requires[path] = 1
                else
                    if self._requires[path] == nil then
                        if printLogEnabled then
                            logt("require引擎模块", "path = " .. tostring(path))
                        end
                    else
                        self._requires[path] = self._requires[path] + 1
                        if printLogEnabled then
                            print("path = ", path)
                            print("self._requires[path] = ", self._requires[path])
                            logt("require模块", "path = " .. tostring(path), ", 第", self._requires[path], "次")
                        end
                    end
                end
            end
            
            return oldRequire(path)
        -- local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10
        -- local preBarbageCount, aftBarbageCount, changeBarbageCount = Game:getMemoryChangeValue(function()
        --     arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 = oldRequire(path)
        -- end)
        -- print("path = " .. path .. " preBarbageCount, aftBarbageCount, changeBarbageCount = ", preBarbageCount, aftBarbageCount, changeBarbageCount)
        -- return arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 清除包含
function Game:cleanRequire()
    for path, v in pairs(self._requires) do
        if printLogEnabled then
            print([[Game:cleanRequire()]])
            log("path = ", path)
        end
        cleanTable(package.loaded[path])
        package.loaded[path] = nil
    end
    cleanTable(self._requires)
    self._requires = nil
    self._requires = {}
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/27 20:15:22
-- @desc 获得内存变化值
function Game:getMemoryChangeValue(func)
    local pre = collectgarbage("count")
    func()
    local aft = collectgarbage("count")
    
    return pre, aft, aft - pre
end

local blockAsyncFuncCount = 0
local inBlockAsyncFunc = false
--[[
    @desc: 
    author:TangJian
    time:2022-04-12 16:16:06
    --@name: 方法名，用于标识
	--@asyncFunc: 需要放到协程中执行的方法
	--@inRootFunc: 是否在根方法中
    @return:
]]
function Game:addBlockAsyncFunc(name, asyncFunc, inRootFunc)
    CoroutineStack:push(name, asyncFunc)
end

function Game:setLogicLoop(func)
    assert(type(func) == "function", "func must be a function")
    self.__logicLoop = func
end

function Game:setRenderLoop(func)
    assert(type(func) == "function", "func must be a function")
    self.__renderLoop = func
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 载入
function Game:load(func)
    cc.Texture2D:setDefaultAlphaPixelFormat(0)

    -- 载入基本模块 add by TangJian 2017/03/27 18:54:46
    Loader:loadBase()
    
    local newScene = cc.Director:getInstance():getRunningScene()

    local hasGetedWebTime = false

    self:schedule(function(elapsed)
        if hasGetedWebTime then
            WEB_TIME = WEB_TIME + elapsed
            SetTime(tonumber(WEB_TIME))
        end
    end, 0)

    -- 全局刷新时间
    newScene:schedule(
        function(elapsed)
            -- 帧数加1
            self._currFrame = self._currFrame + 1
            
            -- 如果阻塞协程池有任务，则先执行完成阻塞协程池任务
            if CoroutineStack:resume() then
                -- if self.__waitingLayer == nil then
                --     self.__waitingLayer = WaitingLayer:create()

                --     -- 阻止触控
                --     self.__waitingLayer:swallow()

                --     newScene:addChild(self.__waitingLayer)
                -- end
            else
                -- if self.__waitingLayer then
                --     self.__waitingLayer:removeFromParent()
                --     self.__waitingLayer = nil
                -- end

                if self.__logicLoop then
                    self.__logicLoop(elapsed)
                end
            end

            if self.__renderLoop then
                self.__renderLoop(elapsed)
            end
        end,
        0
    )

    self:getWebTime(function (time)
        -- 初始化时间
        SetTime(tonumber(time))
        HttpManagerEx:setWebTime(time)

        hasGetedWebTime = true

        if self:isOpenShiMing() == true then
            -- 全局刷新时间
            newScene:schedule(
                function()
                    self:MonitorScreenTime()
                end,
                10
            )
        end

        -- 记录错误信息
        SetDebugFunc(
        function(errmsg)
            print(errmsg)
            print(debug.traceback())


            if self.buttonPopLayer == nil then
                Collection:setLoadErrmsgSuccessFunc(function()
                    PopText("您已成功提交反馈,我们的技术人员会以最快的速度处理,感谢您对我们游戏的大力支持!")
                    HttpManagerEx:uploadLocalUserData("fankui", function(status, errcode, errmsg, data, isEncrypted)
                        if status == 200 and errcode == 0 then
                            ButtonPopLayer:createCustomInRunningScene("反馈已提交,请关闭游戏", "关闭",
                            function()
                                cc.Director:getInstance():endToLua()
                            end)
                            return true
                        end
                    end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
                end)
                Collection:recordLoadErrmsg(errmsg)
                self.buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("游戏载入出现了异常!", "提交反馈",
                function()
                    Collection:uploadLoadErrmsg()
                    local fullPath = cc.FileUtils:getInstance():fullPathForFilename("../app.lst")
                    if fullPath == nil or fullPath == "" then
                        return
                    end
                    local jsonData = json.decode(cc.FileUtils:getInstance():getStringFromFile(fullPath))
                    jsonData.version = 0
                    cc.FileUtils:getInstance():writeStringToFile(json.encode(jsonData), fullPath)
                end)
                -- self.buttonPopLayerbuttonPopLayer:setErrorText("11111")
            end
        end)
        
        -- 禁止定义全局变量 add by TangJian 2017/03/27 18:55:03
        self:disableGlobal()
        
        Game:getWebConfig()  -- 初始化设置新包检查的状态  

        -- 载入自定义模块 add by TangJian 2017/03/27 18:54:33
        Loader:loadCustom(func)
    end)
                    
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/22 15:00:24
-- @desc IOS 帧率设置
local function setAnimationIntervalIos(state)
    local interval = 60
    if state == "Low" then
        interval = 30
    elseif state == "Normal" then
        interval = 60
    else
        state = "Normal"
        interval = 60
    end
    cc.Director:getInstance():setAnimationInterval(1 / interval)
    cc.UserDefault:getInstance():setStringForKey("AnimationInterval", state)

    return interval
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/22 15:07:38
-- @desc ANDROID 设置帧率
local function setAnimationIntervalAndroid(game, state)
    local interval = 30
    if state == "Low" then
        interval = 24
        game:setGameVoice("N")
    elseif state == "Normal" then
        interval = 30
    elseif state == "High" then
        interval = 60
    else
        state = "Normal"
        interval = 30
    end
    cc.Director:getInstance():setAnimationInterval(1 / interval)
    cc.UserDefault:getInstance():setStringForKey("AnimationInterval", state)
    return interval
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置帧率
function Game:setAnimationInterval(animationInterval)
    if animationInterval == nil then
        animationInterval = cc.UserDefault:getInstance():getStringForKey("AnimationInterval")
    end
    if device.platform == "ios" then
        self.__viewFPS = setAnimationIntervalIos(animationInterval)
    elseif device.platform == "android" then
        self.__viewFPS = setAnimationIntervalAndroid(self, animationInterval)
    elseif device.platform == "windows" then
        self.__viewFPS = setAnimationIntervalAndroid(self, animationInterval)
    else
        cc.Director:getInstance():setAnimationInterval(1 / 60)
        self.__viewFPS = 60
    end
end

function Game:getViewFPS()
    return self.__viewFPS
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/27 10:28:45
-- @desc 游戏声音开关
function Game:setGameVoice(state)
    if state == nil then
        state = cc.UserDefault:getInstance():getStringForKey("voice")
    end
    if state == "Y" then
        else
        -- add by XiaoZhiWei 2017/02/27 10:32:11 关闭声音的同时需要停止音效
        if Audio ~= nil then
            Audio:stopAllEffects()
        end
        state = "N"
    end
    cc.UserDefault:getInstance():setStringForKey("voice", state)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 开始游戏
function Game:start(callback)
    local newScene = cc.Scene:create()
    cc.Director:getInstance():replaceScene(newScene)
    
    -- 全局DoTween
    DoTween = require("third.dotween.DoTween"):create()

    -- 延时载入资源
    newScene:runAction(cc.Sequence:create(cc.DelayTime:create(0), cc.CallFunc:create(
        function()
            -- 开始游戏
            Game:init(
                function()
                    Game:updatePayInfo()
                    
                    -- 记录错误信息
                    SetDebugFunc(
                    function(errmsg)
                        -- Collection:recordErrmsg(errmsg)

                        local msg = errmsg
                        local traceback_msg = debug.traceback()
                        print(msg)
                        print(traceback_msg)

                        ErrmsgRecord:addErrmsg(msg .. " ; " ..traceback_msg)
                    end)    
                    
                    HttpManagerEx:getToken(function(status, errcode, errmsg, data, isEncrypt)
                        if status == 200 then
                            if errcode == 0 then
                                T_TOKEN = Helper:getDef(data.token, "")

                                -- 显示菜单界面
                                local ControllLayer = require("app.views.layer.ControllLayer")
                                local controllLayer = ControllLayer:getInstance()
    
                                MainControllLayer = controllLayer -- add by XiaoZhiWei 2017/09/27 16:52:22 全局单例实例赋值

                                User:init()
                                local BiWu = require("app.models.BiWu.BiWu")
                                BiWu:initfightAllData()
                                BiWu:initfightWeekAllData()

                                Task:init()

                                FILE_IS_LOADING = true
    
                                Helper:getDef(callback, function() end)()
    
    
                                local menuLayer = controllLayer:getLayer("MenuLayer")

                                GameChannelContext:showMailBindLayer(menuLayer)
                                
                                -- 设置开始游戏按钮的回调方法
                                menuLayer:setStartGameFunc(function()
                                    local GameStart = require("app.models.game.GameStart")
                                    GameStart:start_game()
                                end)
                                return true
                            elseif errcode == 615 then
                               
                                local ControllLayer = require("app.views.layer.ControllLayer")
                                local controllLayer = ControllLayer:getInstance()
                                MainControllLayer = controllLayer

                                local menuLayer = controllLayer:getLayer("MenuLayer")

                                PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
                                    layer:setPopText("")
                                    layer:showLayer()
                                end)
                                
                                controllLayer:delayFunc(2,function()
                                    local layer = require("app.views.layer.CommunityLayer.CommunityLayer"):getInstance()
                                    layer:setUrl(data.url)
                                    layer:setOnPauseCallback(function()
                                        SdkMethod:exit()
                                    end)
                                    layer:setButtonBackVisible(false)
                                    layer:setTitle("维护公告")
                                    layer:show()
                                end)
                                
                                return true
                            end
                        end
                    end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
                    
                end)
        end)))
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 重新开始
function Game:restart(callback)
    -- 清理逻辑循环和渲染循环方法
    self.__logicLoop = nil
    self.__renderLoop = nil
    self.__waitingLayer = nil

    -- 取消所有全局调度器
    self:unscheduleAll()

    -- MainPerformanceAnalysisSystem:hook()
    -- 释放资源
    if Resource then
        Resource:releaseRes()
    end

    --需更新下物品记录
    Record:submitLog()
    
    self:start(function()
        if type(callback) == "function" then
            callback()
        end
    end)
end

function Game:schedule(func, ft)
    local handle = scheduler.scheduleGlobal(func, ft)
    table.insert(self.__schedulerHandleList, handle)
    return handle
end

function Game:unschedule(handle)
    scheduler.unscheduleGlobal(handle)
    for i = #self.__schedulerHandleList, 1, -1 do
        if handle == self.__schedulerHandleList[i] then
            table.remove(self.__schedulerHandleList, i)
            break
        end
    end
end

function Game:unscheduleAll()
    for i, handle in ipairs(self.__schedulerHandleList) do
        scheduler.unscheduleGlobal(handle)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/29 11:28:09
-- @desc 释放内存
function Game:freeMemorySmart()               
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

-- 更新自动释放纹理
function Game:cleanUnuseAutoReleaseTextures(ft)
    if cc.Director:getInstance():getTextureCache().cleanUnuseAutoReleaseTextures then 
        cc.Director:getInstance():getTextureCache():cleanUnuseAutoReleaseTextures(ft)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得网络时间
function Game:getWebTime(func)
    HttpManagerEx:getTime(function(status, errcode, errmsg, data, isEncrypt)
        if status == 200 and errcode == 0 and data.time ~= nil then
            SetTime(tonumber(data.time))            
            func(WEB_TIME)
            return true
        else
            PopText(errmsg)
        end
    end, false, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

function Game:updatePayInfo()
    --@region 提供支付接口使用，不要注释
    local userId = User:getUserId()
    DataBase:setData("userid", userId, false)
    DataBase:setData("hotver", UpdateManager:getVersion(), false)
    if self:getPlatformId() == "android" then
    else
        Game:setUserId(userId)
    end
    --@endregion
    require("app.models.Pay.IosPurchaseCheck"):updatePurchase()
end

local newPackageList = {
        ["1.5.09"] = false,
        default = true
}
function Game:isNewPackage()
    local ret = newPackageList[self:getVersion()]
    if ret == nil then
        ret = true
    end
    return ret
end

function Game:getIdfv()
    return SdkMethod:getIdfv()
end

local platformName = ""
function Game:getPlatformId()
    if platformName == "" then
        platformName = SdkMethod:getPlatformName()
    end
    return platformName
end

function Game:getDevInfo()
    return SdkMethod:getDevInfo()
end

function Game:getVersion()
    return SdkMethod:getVersion()
end

function Game:getHotVersion()
    return UpdateManager:getVersion()
end

function Game:getPackageId()
    if Game:getPlatformId() == "android" then
        return ""    
    elseif Game:getPlatformId() == "ios" then
        if self:isNewPackage() == true then
            return cpp.Game:getInstance():getPackageId()
        else
            return ""
        end
    elseif Game:getPlatformId() == "windows" then
        return ""
    elseif Game.getPlatformId ~= nil then
        return Game:getPlatformId()
    end
    error("function Game:getPackageId()")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/26 16:51:11
-- @desc 获取头信息
function Game:getChannelId()
    if Game:getPlatformId() == "android" then
        local channel = cpp.Game:getInstance():getChannelId()   
        if channel == "null" or channel == nil then
            return "taptap_2"
        end
        return channel
    elseif Game:getPlatformId() == "ios" then
        if self:isNewPackage() == true then
            return cpp.Game:getInstance():getChannelId()
        else
            return "ios"
        end
    elseif Game:getPlatformId() == "windows" then
        return ""
    elseif Game.getPlatformId ~= nil then
        return Game:getPlatformId()
    end
    error("function Game:getPackageId()")    
end

function Game:setChannelId(channelId)
    if self:isNewPackage() == true then
        return cpp.Game:getInstance():setChannelId(channelId)
    else
    end
end

function Game:setTime(time)
    if self:getPlatformId() == "android" then
        return YXHelper:setWebTime(time)
    elseif self:getPlatformId() == "ios" then
        if self:isNewPackage() == true then
            return cpp.Game:getInstance():setTime(time)
        else
        end
    elseif self:getPlatformId() == "test" then
        if self:isNewPackage() == true then
            return cpp.Game:getInstance():setTime(time)
        else
        end
    else
    end
end

function Game:getTime()
    if self:isNewPackage() == true then
        return cpp.Game:getInstance():getTime()
    else
    end
end

function Game:setUserId(userId)
    if self:isNewPackage() == true then
        return cpp.Game:getInstance():setUserId(userId)
    else
    end
end

function Game:getUserId()
    if self:isNewPackage() == true then
        return cpp.Game:getInstance():getUserId() 
    else
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/22 10:19:12
-- @desc 获取请求地址
function Game:getDomain()
    if self.domain == nil then
        if device.platform == "windows" then
            if WConfig == nil or WConfig.url == nil or WConfig.port == nil then
                self.domain = UpdateManager:getDomain()
            else
                self.domain = "http://"..WConfig.url..":".. WConfig.port.."/"
            end
        else
            self.domain = UpdateManager:getDomain()
        end
    end

    return self.domain
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/30 13:08:20
-- @desc 获取副本偶遇开关状态 true 开启 false 关闭 (注: 这是版本开关,和状态开关(离线模式)无关)
function Game:isOpenEncounter()
    -- add by XiaoZhiWei 2017/07/18 18:24:54 如果角色是标记为作弊,则直接关闭偶遇系统
    if User:getRoleAttr("role_is_cheat") == true then
        return false
    end

    local openMap = 
    {
        default = true
    }

    local platform = self:getPlatformId()
    local version = self:getVersion()
    if platform == "ios" or platform == "android" then
        return switch(version, openMap)
        -- return openMap[version]
        -- if version == "1.0" or version == "1.1" then
        --     return true
        -- else
        --     return false
        -- end
        -- if version == "1.2.0" or version == "1.3.0" or version == "1.3.0" then
        --     return true
        -- else
        --     return false
        -- end
    elseif platform == "windows" then
        return true
    elseif platform == "test" then
        return true
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/30 14:11:26
-- @desc 获取 官方客服号码
function Game:getKFQQ()
    return "800041109"
end

-- 应华为渠道要求,删除官方客服相关信息
function Game:isOpenKFQQ()
    local list = {
        ["huawei"] = true
    }
    return list[Game:getChannelId()] == true and true or false
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/06 08:41:55
-- @desc 是否开启服务器切换
function Game:isOpenSwitchServer()
    local platform = self:getPlatformId()
    local version = self:getVersion()
    if platform == "ios" then
        if version ~= "1.5.09" then
            return true
        else
            return false
        end
    elseif platform == "android" then
        if version ~= '1.13.0' and (self:getChannelId() == "taptap" or self:getChannelId() == "taptap_2" or self:getChannelId() == "taptap_3" or self:getChannelId() == "taptap_4") then
            return true
        end
        return false
    elseif platform == "windows" then
        return true
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/07 15:01:45
-- @desc 判断是否是测试环境
function Game:isTesting()
    if self:getPackageId() == "test" then
        return true
    end

    -- add by XiaoZhiWei 2017/07/07 15:03:31 根据请求地址判断是否是测试环境
    if string.find(self:getDomain(), "http://fzjh.test.xiaohoutiaotiao.com") or string.find(self:getDomain(), "http://fzjh.test.helloyanming.com") then
        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/03/29 11:50:38
-- @desc 是否新包审核
-- 结构：
-- ["oppo"] = {
--     ["1.8.0"] = false,
--     ["1.9.0"] = true,
-- }
local PackageChecklist = {}

-- UPLTV广告接口是否开启
-- 结构 ： 
-- ["1.13.0"] = {
--     ["taptap"] = true,
--     ["taptap_2"] = true,
--     ["shoutan"] = true,
--     ["m233"] = true,
-- }
local UPLAdsList = {}

-- 是否开启微信分享功能
-- 结构：
-- ["4399"] = true,
local WeiXinSHareList = {}

-- 分享链接列表
-- 结构：
-- ["taptap"] = "http://fzjh.xiaohoutiaotiao.com/", 
local FenXiangList = {}

-- 是否开启实名认证
-- 结构：
--  ["taptap"] = true,
local ShiMingList = {}

-- 是否使用AES加密算法
-- 结构：
--  ["IsAesEncrypt"] = true,
local IsAesEncrypt = nil

function Game:getWebConfig()
    HttpManagerEx:getWebConfig(function(status, errcode, errmsg, data, isEncrypt)
        print(status, errcode, errmsg, data, isEncrypt)
        Helper:print_lua_table(data)
        if status == 200 and errcode == 0 then
            PackageChecklist = data["PackageChecklist"]
            UPLAdsList = data["UPLAdsList"]
            WeiXinSHareList = data["WeiXinSHareList"]
            FenXiangList = data["FenXiangList"]
            ShiMingList = data["ShiMingList"]
            IsAesEncrypt = data["IsAesEncrypt"]
        end
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/15 15:28:45
-- @desc 是否开启微信分享功能
function Game:isOpenWeiXinShare()
    return switch(CURR_DEVICE_CHANNEL, WeiXinSHareList)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/09 18:55:56
-- @params 
-- @desc 分享链接列表
function Game:getFenXiangURL()
    return switch(CURR_DEVICE_CHANNEL, FenXiangList)
end

function Game:isCheckNewPackage()
    -- if true then
    --     return NEED_CHECK_AND_IS_OPEN
    -- end

    if MapIsEmpty(PackageChecklist[CURR_DEVICE_CHANNEL]) == false then
        if PackageChecklist[CURR_DEVICE_CHANNEL][self:getVersion()] == true then
            return NEED_CHECK_AND_IS_OPEN
        else
            return NEED_CHECK_AND_NOT_OPEN
        end
    else
        return NOT_NEED_CHECK
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/30 15:59:25
-- @params 
-- @desc UPLTV广告接口是否开启
function Game:isOpenUPLTVAds()
    if MapIsEmpty(UPLAdsList[self:getVersion()]) == false then
        return Helper:getDef(UPLAdsList[self:getVersion()][CURR_DEVICE_CHANNEL], false)
    else
        return false
    end
end

function Game:isOpenShiMing()
    if NAMEAUTH ~= nil and NAMEAUTH == false then
        return false
    end

    local isOpen = GameChannelContext:isOpenShiMing()
    if isOpen == false then
        return false
    end

    return switch(self:getChannelId(), ShiMingList)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/07/04 20:24:18
-- @params 
-- @desc 是否需要试用新的加密方式
function Game:isNeedNewEncript()
    if IsAesEncrypt ~= nil then
        return IsAesEncrypt == true and true or false
    end

    return GameChannelContext:isNeedNewEncript()
end

function Game:openPayLayer(callback)
    if self:getChannelId() == "shoutan" then
        return
    end
    
    if device.platform == "android" then
        if self:getChannelId() == "huawei" or self:getChannelId() == "oppo" or self:getChannelId() == "yyb" or self:getChannelId() == "yyb2" then
            callback()
            return
        else
        end
        -----------------------------------------------------------------------------------------------------------
        -- @author XiaoZhiWei
        -- @time 2017/02/21 09:45:42
        -- @desc  判断是否绑定邮箱
        Account:getEmail(
        function(eventName, errmsg, email, isBind, isLogout)
            if eventName == "有邮箱" then
                -- isBind 为true的时候 才是已绑定邮箱
                if isBind == true then
                    callback()
                    return
                else
                end
            elseif eventName == "找不到帐号" then
            elseif eventName == "无邮箱" then
            else
            end
            PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
        end)
    elseif device.platform == "ios" then
        callback()
    elseif device.platform == "windows" then
        callback()
    else
    end
end

function Game:MonitorScreenTime(time)
    if SCREEN_TIME_OPEN ~= true then
        return
    end

    if WEB_TIME > 0 and not self._isShowWarmPromp then
        local AntiAddictionSystem = require("app.models.AntiAddictionSystem.AntiAddictionSystem")
        local currTime = GetTime()
        AntiAddictionSystem:setTime(currTime)

        local isOpen = AntiAddictionSystem:isOpen()
        if isOpen == false then
            local Hour = tonumber(Helper:date("%H",currTime))
            local Minute = tonumber(Helper:date("%M",currTime))
            if not self.isShowRemainTime and Hour == 20 and Minute >= 50 then
                PopupLayerController:showLayer("PopWindowsLayer", function(layer)
                    local title = "确定"
                    local text = "还有"..tostring(Helper:getRange(60 - Minute,1,10)).."分钟就到达21：00，根据未成年人防沉迷的规定，届时您将无法登录游戏，请合理安排游戏时间，享受健康生活。"
                    local canHide = true
                    local func = function()
                        layer:hide()
                    end
                    self.isShowRemainTime = true
                    layer:showLayer(title,text,canHide,func)
                end)
            end
        else
            PopupLayerController:showLayer("WarmPromptLayer", function(layer)
                self._isShowWarmPromp = true
                layer:showLayer()
            end)
        end
    end
end

return Game
0000000
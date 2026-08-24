-- 界面控制器,用来控制界面切换

local ControllLayer = class("ControllLayer", LayerEx)

-- 控制层所管理的所有层
local layers = {} --

local switchs = {
    -- 切换配置
    fromto = {
        -- 切换索引 当前层名 +　切换到的层名
        animType = "MoveAnim", -- 动画类型
        animDuration = 0.3,
        -- 动画持续时间
        animDirection = 1, -- 动画方向 1为正向 -1为反向
        animPreFunc = nil, -- 动画开始前调用
        animAftFunc = nil -- 动画完成后调用
    }
}

-- 创建控制层
function ControllLayer:create()
    local p = ControllLayer:new()
    p:init()
    return p
end

function ControllLayer:ctor()
    self:initLayerStack()

    local BackgroundLayer = require("app.views.layer.Background.BackgroundLayer")
    --@RefType [BackgroundLayer]
    self.__backgroundLayer = BackgroundLayer:create()
    self.__backgroundLayer:setLocalZOrder(-1)
    self.__backgroundLayer:addTo(self)
    self.__backgroundLayer:setVisible(true)
end

-- 初始化
function ControllLayer:init()
    self._layers = layers -- 层次
    self._switchs = switchs --
    self.__isSwitching = false

    self._isUpdateLayer = true

    self._defaultSwitch = {
        -- 默认切换方式
        animType = "MoveAnim",
        animDuration = 0.3,
        animDirection = 1,
        animPreFunc = nil,
        animAftFunc = nil
    }

    self:preLoad() -- 预加载所有层
    self:initLayerStack() -- 初始化层栈队列

    -- self:getLayer("BackLayer")

    self:getLayer("TitleLayer")
    self:getLayer("PrintLayer")

    self:pushLayer("MainLayer")
end

--[[
    @desc: 判断层是否正在切换中
    author:TangJian
    time:2022-02-12 14:46:07
    @return:
]]
function ControllLayer:isSwitching()
    return self.__isSwitching
end

function ControllLayer:pauseUpdate()
    self._isUpdateLayer = false
end

function ControllLayer:resumeUpdate()
    self._isUpdateLayer = true
end

function ControllLayer:isUpdate()
    return self._isUpdateLayer
end

-- 预加载所有层
function ControllLayer:preLoad()
    -- for k, v in pairs(self._layers) do
    -- 	self:getLayer(k)
    -- end
end

-- 初始化LayerStack
function ControllLayer:initLayerStack()
    self._layerStack = {}

    self.__removeStack = {} -- add by XiaoZhiWei 2018/09/06 15:23:29 记录需要清理的界面 (暂定20秒清理间隔)
end

--　压入层
function ControllLayer:pushLayer(name, switch)
    if PRINT_MODE == 1 then
        print("ControllLayer:pushLayer(" .. tostring(name) .. ", " .. tostring(switch) .. ")")
    end

    local layerStack = self._layerStack
    local maxn = #layerStack
    if maxn > 0 then
        local fromLayerName = layerStack[maxn]
        local toLayerName = name
        if fromLayerName == toLayerName then
            if PRINT_MODE == 1 then
                print("不能切换到相同层")
            end
            -- 刷新层, tangjian 20160728
            self:getLayer(fromLayerName):pauseSelfAndChildren()
            self:getLayer(toLayerName):resumeSelfAndChildren()
            return false
        end
        if maxn > 999 then -- 最多记录999层, tangjian 20160728
            if PRINT_MODE == 1 then
                print("压入层数过多, 自动移除第一条记录")
            end
            table.remove(layerStack, 1)
        end
        -- 切换层
        if self:switchLayer(fromLayerName, toLayerName, switch) then
            table.insert(layerStack, name)
        end
    elseif maxn == 0 then
        if self:switchLayer(nil, name, switch) then
            table.insert(layerStack, name)
        end
    else
        assert("压入层出问题!!")
    end
end

function ControllLayer:popLayer(switch, name)
    local layerStack = self._layerStack
    local maxn = #layerStack
    if maxn == 1 then
        if PRINT_MODE == 1 then
            print("已经没有层可以弹出")
        end
    elseif maxn > 1 then
        local fromLayerName = layerStack[maxn]
        if name == nil or name == fromLayerName then
            local toLayerName = layerStack[maxn - 1]
            -- -- 切换层
            -- if switch == nil then
            -- 	switch = {animDirection = -1}
            -- end
            if self:switchLayer(fromLayerName, toLayerName, switch) then
                table.remove(layerStack, #layerStack)
            end
        end
    end
    --Audio:stopMusic()
end

function ControllLayer:getCurrLayer()
    return self._layerStack[#self._layerStack]
end

-- @desc 获取Layer, 不自动创建
function ControllLayer:getLayerWithoutCreate(name)
    return self[name]
end

function ControllLayer:getLayer(name)
    local layer = self[name]
    if layer == nil then
        if PRINT_MODE == 1 then
            print("getLayer name = " .. tostring(name))
        end
        for k, v in pairs(self._layers) do
            if PRINT_MODE == 1 then
                print(k)
            end
        end
        local layerName = assert(self._layers[name], name)
        local LayerClass = require(layerName)
        self[name] = LayerClass:create()
        layer = self[name]
        -- layer:hide() -- 在创建之后都默认设置为隐藏
        layer:addTo(self)
        layer.ControllLayer = self
    end

    -- add by XiaoZhiWei 2018/09/04 10:44:06 在创建的时候就记录在需移除的列表中
    do
        if MapIsEmpty(self.__removeStack) then
            table.insert(self.__removeStack, name)
        else
            for i, v in ipairs(self.__removeStack) do
                if name == v then
                    break
                end
                if i == #self.__removeStack then
                    table.insert(self.__removeStack, name)
                end
            end
        end
    end

    return layer
end

function ControllLayer:removeLayer(name)
    local layer = self[name]
    if layer then
        if layer.onRemove ~= nil and type(layer.onRemove) == "function" then
            layer:onRemove()
        end
        layer:removeFromParent()
        if self.__tempSkinIdMap then
            self.__tempSkinIdMap[name] = nil
        end
        self[name] = nil
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/26 10:36:37
-- @desc 页面是否已被销毁
function ControllLayer:isLayerRemoved(name)
    assert(self._layers[name], "名字不是页面名,请检查是否填错参数. name == " .. tostring(name))
    return self[name] == nil and true or false
end

function ControllLayer:getLayerZ(name)
    local layer = self:getLayer(name)
    if layer then
        return layer:getLocalZOrder()
    end
    return 0
end

function ControllLayer:getSwitch(fromLayerName, toLayerName)
    if PRINT_MODE == 1 then
        print("ControllLayer:getSwitch(" .. tostring(fromLayerName) .. ", " .. tostring(toLayerName) .. ")")
    end
    if fromLayerName == nil then
        fromLayerName = ""
    end
    if toLayerName == nil then
        toLayerName = ""
    end
    local switch = self._switchs[tostring(fromLayerName) .. tostring(toLayerName)]
    if type(switch) == "string" then
        return self:getSwitch(switch)
    end
    if type(switch) == "table" then
        local maxn = #switch
        if maxn == 0 then -- map
            return switch
        end
        -- array, 后面覆盖前面的
        local tmpSwitch = {}
        for i = 1, maxn do
            if type(switch[i]) == "table" then
                Helper:tableCover(tmpSwitch, switch[i])
            else
                Helper:tableCover(tmpSwitch, self:getSwitch(switch[i]))
            end
        end
        return tmpSwitch
    end
    return self._defaultSwitch
end

function ControllLayer:switchLayer(fromLayerName, toLayerName, switch)
    if PRINT_MODE == 1 then
        print("function ControllLayer:switchLayer(" .. tostring(fromLayerName) .. ", " .. tostring(toLayerName) .. ")")
    end

    do --
        if fromLayerName ~= nil then
            local fromLayer = self:getLayer(fromLayerName)
            if fromLayer ~= nil and type(fromLayer.onSwitch) == "function" then
                if fromLayer:onSwitch(toLayerName) == false then
                    return false
                end
            end
        end
    end

    ----------------------------------------------------------
    ------    友盟接入
    if fromLayerName and toLayerName then
        Mob.beginLogPageView(toLayerName)
        Mob.endLogPageView(fromLayerName)
    elseif fromLayerName == nil and toLayerName then
        Mob.beginLogPageView(toLayerName)
    else
    end

    do --
        -- 内存检测清理
        -- collectgarbage("collect")
        -- print([[collectgarbage("count")]]..collectgarbage("count"))
        switch = Helper:tableCover(clone(self:getSwitch(fromLayerName, toLayerName)), switch)
        --NEEDTOCHECK
        switch = Helper:tableCover(clone(self._defaultSwitch), switch)
    end

    if fromLayerName and toLayerName then
        self:playSwitchAnim(fromLayerName, toLayerName, switch)
    else
        local toLayer = self:getLayer(toLayerName)
        toLayer:resumeSelfAndChildren()
        toLayer:move(cc.p(0, 0))

        -- 执行动画前后的函数
        if PRINT_MODE == 1 then
            print("执行动画前后的函数 type(switch) = " .. type(switch))
        end
        if type(switch) == "table" then
            Helper:callFunc(switch.animPreFunc, self)
            Helper:callFunc(switch.animAftFunc, self)
        end
    end
    return true
end

function ControllLayer:playSwitchAnim(fromLayerName, toLayerName, switch)
    -- 取出switch中的参数
    local animType, animDuration, animDirection = switch.animType, switch.animDuration, switch.animDirection
    if PRINT_MODE == 1 then
        print("animType = " .. tostring(animType))
    end

    local animCallBack = function(eventType)
        if eventType == "preAnim" then
            self.__isSwitching = true

            Helper:callFunc(switch.animPreFunc, self, fromLayerName, toLayerName, switch)
            self:showTouchSwallowLayer() -- 显示触摸屏蔽层
            self:pauseUpdate()
        elseif eventType == "aftAnim" then
            self:resumeUpdate()
            self:hideTouchSwallowLayer() -- 隐藏触摸屏蔽层
            Helper:callFunc(switch.animAftFunc, self, fromLayerName, toLayerName, switch)

            if toLayerName == "MainLayer" then
                local unRemoveLayer = {
                    ["MainLayer"] = true,
                    ["BackLayer"] = true,
                    ["TitleLayer"] = true,
                    ["PrintLayer"] = true,
                    ["ZhuDongTaskLayer"] = true,
                    ["MainTaskPresenter"] = true,
                    ["AttrLayer"] = true,
                    ["FistFootMenuPresenter"] = true
                }
                -- 当回到主界面的时候,所有载入过的界面均可清除
                for i, v in pairs(self.__removeStack) do
                    if unRemoveLayer[v] then
                    else
                        self:removeLayer(v)
                    end
                end
                self.__removeStack = {}
            end

            -- 智能释放内存 add by TangJian 2017/03/29 15:28:28
            Game:freeMemorySmart()

            self.__isSwitching = false
        end
    end

    if animType == "MoveAnim" then
        self:MoveAnim(fromLayerName, toLayerName, animDuration, animDirection, animCallBack)
    elseif animType == "MoveAndFadeAnim" then
        self:MoveAndFadeAnim(fromLayerName, toLayerName, animDuration, animDirection, animCallBack)
    elseif animType == "fadeAnim" then
        self:fadeAnim(fromLayerName, toLayerName, animDuration, animDirection, animCallBack)
    end
end

-- 切换动画 --------------------------------------------------------
function ControllLayer:initAnimLayer(obj)
    obj:setVisible(true)
    obj:setOpacity(255)
    obj:setCascadeOpacityEnabled(true)
    obj:callAllChild(
        function(child)
            child:setCascadeOpacityEnabled(true)
        end
    )
end

local gapDuration = 1 / 24
function ControllLayer:baseSwitchAnim(fromLayerName, toLayerName, layerInit, fromActionCreator, toActionCreator, callBack)
    local fromLayer = self:getLayer(fromLayerName)
    local toLayer = self:getLayer(toLayerName)

    self:initAnimLayer(fromLayer)
    self:initAnimLayer(toLayer)

    callBack("preAnim")

    layerInit(fromLayer, toLayer)

    self:__updateLayerSkin(toLayer, toLayerName)

    toLayer:resumeSelfAndChildren()

    self:uniqueDelayFunc(
        "delayFunc" .. fromLayerName,
        gapDuration,
        function()
            local fromTag = fromLayer:getActionTagByName("Switch")

            local action =
                cc.Sequence:create(
                fromActionCreator(),
                cc.DelayTime:create(gapDuration),
                cc.CallFunc:create(
                    function()
                    end
                )
            )
            action:setTag(fromTag)
            fromLayer:setVisible(true)

            fromLayer:stopActionByTag(fromTag)
            fromLayer:runAction(action)
        end
    )

    self:uniqueDelayFunc(
        "delayFunc" .. toLayerName,
        gapDuration,
        function()
            local toTag = toLayer:getActionTagByName("Switch")
            if self.__backgroundLayer then
                self.__backgroundLayer:switchTo(toLayerName)
            end

            local action =
                cc.Sequence:create(
                toActionCreator(),
                cc.DelayTime:create(gapDuration),
                cc.CallFunc:create(
                    function()
                        fromLayer:pauseSelfAndChildren()
                        fromLayer:move(cc.p(0, display.height * 2))
                        fromLayer:setVisible(false)
                        toLayer:setVisible(true)
                        callBack("aftAnim")
                    end
                )
            )
            action:setTag(toTag)
            toLayer:setVisible(true)

            toLayer:stopActionByTag(toTag)
            toLayer:runAction(action)
        end
    )
end

function ControllLayer:MoveAnim(fromLayerName, toLayerName, duration, direction, callBack)
    if duration == nil then
        duration = 0.3
    end
    if direction == nil then
        direction = 1
    end

    if direction > 0 then
        self:baseSwitchAnim(
            fromLayerName,
            toLayerName,
            function(fromLayer, toLayer)
                fromLayer:move(cc.p(0, 0))
                toLayer:move(cc.p(display.width, 0))
            end,
            function()
                return cc.MoveTo:create(duration, cc.p(-display.width, 0))
            end,
            function()
                return cc.MoveTo:create(duration, cc.p(0, 0))
            end,
            callBack
        )
    else
        self:baseSwitchAnim(
            fromLayerName,
            toLayerName,
            function(fromLayer, toLayer)
                fromLayer:move(cc.p(0, 0))
                toLayer:move(cc.p(-display.width, 0))
            end,
            function()
                return cc.MoveTo:create(duration, cc.p(display.width, 0))
            end,
            function()
                return cc.MoveTo:create(duration, cc.p(0, 0))
            end,
            callBack
        )
    end
end

function ControllLayer:MoveAndFadeAnim(fromLayerName, toLayerName, duration, direction, callBack)
    if duration == nil then
        duration = 0.3
    end
    if direction == nil then
        direction = 1
    end

    if direction > 0 then
        self:baseSwitchAnim(
            fromLayerName,
            toLayerName,
            function(fromLayer, toLayer)
                fromLayer:move(cc.p(0, 0))
                toLayer:move(cc.p(display.width, 0))
            end,
            function()
                return cc.FadeOut:create(duration)
            end,
            function()
                return cc.MoveTo:create(duration, cc.p(0, 0))
            end,
            callBack
        )
    else
        self:baseSwitchAnim(
            fromLayerName,
            toLayerName,
            function(fromLayer, toLayer)
                fromLayer:move(cc.p(0, 0))
                toLayer:move(cc.p(-display.width, 0))
            end,
            function()
                return cc.FadeOut:create(duration)
            end,
            function()
                return cc.MoveTo:create(duration, cc.p(0, 0))
            end,
            callBack
        )
    end
end

function ControllLayer:fadeAnim(fromLayerName, toLayerName, duration, direction, callBack)
    if duration == nil then
        duration = 0.3
    end
    if direction == nil then
        direction = 1
    end

    local fromLayer = self:getLayer(fromLayerName)
    local toLayer = self:getLayer(toLayerName)
    self:initAnimLayer(fromLayer)
    self:initAnimLayer(toLayer)

    callBack("preAnim")

    fromLayer:move(cc.p(0, 0))
    toLayer:move(cc.p(display.width, 0))
    self:__updateLayerSkin(toLayer, toLayerName)
    toLayer:resumeSelfAndChildren()

    local fromTag = fromLayer:getActionTagByName("Switch")
    local toTag = toLayer:getActionTagByName("Switch")

    local fromAction =
        cc.Sequence:create(
        cc.FadeOut:create(duration),
        cc.CallFunc:create(
            function()
                fromLayer:move(cc.p(0, display.height))
                fromLayer:setVisible(false)
                fromLayer:pauseSelfAndChildren()
            end
        )
    )
    fromAction:setTag(fromTag)
    if self.__backgroundLayer then
        self.__backgroundLayer:switchTo(toLayerName)
    end

    toLayer:setVisible(true)
    toLayer:move(cc.p(0, 0))
    toLayer:setOpacity(0)
    local toAction =
        cc.Sequence:create(
        cc.FadeIn:create(duration),
        cc.CallFunc:create(
            function()
                callBack("aftAnim")
            end
        )
    )
    toAction:setTag(toTag)

    fromLayer:stopActionByTag(fromTag)
    fromLayer:runAction(fromAction)
    toLayer:stopActionByTag(toTag)
    toLayer:runAction(toAction)
end

function ControllLayer:__updateLayerSkin(layer, layerName)
    if layer.updateLayerSkinUI == nil then
        return
    end

    if self.__tempSkinIdMap == nil then
        self.__tempSkinIdMap = {}
    end

    local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")
    local currentSkinId = HouseSkin:getSkinId()
    if self.__tempSkinIdMap[layerName] == currentSkinId then
        return
    end
    self.__tempSkinIdMap[layerName] = currentSkinId
    local skin_config = HouseSkin:getSkinConfigFromLayerName(layerName)
    layer:updateLayerSkinUI(skin_config)
end

Helper:classDefNodeGetInstance(ControllLayer)
return ControllLayer
0000000000000000
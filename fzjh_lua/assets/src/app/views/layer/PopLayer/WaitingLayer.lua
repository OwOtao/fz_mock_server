local WaitingLayer = class("WaitingLayer", ccui.Widget)

function WaitingLayer:create()
    local p = WaitingLayer.new()
    return p
end

function WaitingLayer:createInRunningScene()
    local waitingLayer = nil
    local runningScene = cc.Director:getInstance():getRunningScene()
    if runningScene then
        waitingLayer = WaitingLayer:create()
        -- 添加到当前scene
        runningScene:addChild(waitingLayer)

        -- 显示
        waitingLayer:show()
    end
    return waitingLayer
end

function WaitingLayer:ctor()
    self:init()
end

function WaitingLayer:init()
    self._UI = require("Layer/PopUI/WaitingUI").create()["root"]
    self._UI:addTo(self)

    Helper:convertUI(self) -- 获得所有子节点
end

--[[
    @desc: 设置等待界面文本显示
    author:TangJian
    time:2022-03-15 14:36:16
    --@text: 文本
    @return:
]]
function WaitingLayer:setText(text)
    self.Text_center:setString(text)
end

function WaitingLayer:show()
    -- 设置为置顶
    self:setGlobalZOrder(1)
    self:maxZ()

    self:setVisible(true)
    self:setCascadeOpacity(0)
    self.__delayActionTag = nil

    if DEBUG_MODE == 1 then
        self.__delayActionTag =
            self:delayFunc(
            0,
            function()
                self:setCascadeOpacity(255)
            end
        )
    else
        self.__delayActionTag =
            self:delayFunc(
            0.5,
            function()
                self:setCascadeOpacity(255)
            end
        )
    end
end

-- 屏蔽触控
function WaitingLayer:swallow()
    -- 设置为置顶
    self:setGlobalZOrder(1)
    self:maxZ()

    self:setVisible(true)
    self:setCascadeOpacity(0)
end

function WaitingLayer:hideAndStopAction()
    self:stopAllActions()
    self:setCascadeOpacity(0)
end

function WaitingLayer:hideAndRemoveSelf()
    self:removeFromParent()
end

function WaitingLayer:showPanelWait()
    self.Panel_1:setVisible(true)
end

function WaitingLayer:hidePanelWait()
    self.Panel_1:setVisible(false)
end

function WaitingLayer:setClickBackgroundFunc(callback)
    self.Panel_back:releaseFunc(function()
        if callback then
            callback()
        end
    end)
end

return WaitingLayer
0000
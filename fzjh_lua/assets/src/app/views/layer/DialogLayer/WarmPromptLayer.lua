local WarmPromptLayer = class("WarmPromptLayer", cc.Layer)

function WarmPromptLayer:create()
    local p = WarmPromptLayer:new()
    p:init()
    return p
end

function WarmPromptLayer:init()
    self._UI = require("app.views.ui.Dialog.WarmPromptUI"):create()
    self._UI:addTo(self)
end

function WarmPromptLayer:showLayer()
    self:setTextTital()
    self:setTextDesc()
    self:setTextName()
    self:setButtonClose()
    self._UI:showUI()
end

function WarmPromptLayer:setTextTital()
    self._UI:setTextTital("温馨提醒")
end

function WarmPromptLayer:setTextDesc()
    self._UI:setTextDesc("      根据国家新闻出版署规定，游戏公司需要针对未成年人过度使用甚至沉迷网络游戏问题，进一步严格管理措施，在坚决防止未成年人沉迷网络游戏，切实保护未成年人身心健康。\n      故此所有网络游戏企业仅可在周五、周六、周日和法定节假日每日20时至21时向未成年人提供1小时服务，其他时间均不得以任何形式向未成年人提供网络游戏服务。\n      在此准则下，《放置江湖》在周一至周四内，将禁止未成年人登录本游戏，并且在周五至周日的20时至21时，开放给予未成年人登录游戏，希望未成年人专注学习，努力学习。") 
end

function WarmPromptLayer:setTextName()
    self._UI:setTextName("放置江湖开发组")
end

function WarmPromptLayer:setButtonClose()
    self._UI:setButtonClose("关闭",function()
        self:hideLayer()
        cc.Director:getInstance():endToLua()
    end)
end

function WarmPromptLayer:hideLayer()
    PopupLayerController:hideLayer(
        "WarmPromptLayer",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(WarmPromptLayer)
return WarmPromptLayer
000000000
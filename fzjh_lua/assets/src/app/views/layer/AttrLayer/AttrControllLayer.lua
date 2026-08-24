local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local AttrControllLayer = class("AttrControllLayer", require("app.views.base.ControllLayer"))

local layers = {
    --
    _TableLayer = "app.views.ui.AttrUI.TableUI",
    _AttrLayer = "app.views.layer.AttrLayer.AttrLayer",
    _JiangHuLayer = "app.views.ui.AttrUI.JiangHuAttrUI",
    _BagLayer = "app.views.ui.AttrUI.BagUI"
}

local switchs = {
    ["反向动画"] = {animDirection = -1},
    ["高亮"] = {
        animPreFunc = function(self, fromLayerName, toLayerName)
            Audio:playEffect("xiaoAnNiu")
            local TableLayer = self:getLayer("_TableLayer")
            if not toLayerName then
                toLayerName = "_AttrLayer"
            end

            TableLayer:lightTable(toLayerName)
            self:getLayer(toLayerName):updateSkin(self._skin_config)

            if fromLayerName == "_BagLayer" then
                print("I come from BagLayer")

                if self:getLayer("_BagLayer").__currShowPanel ~= nil then
                    self:getLayer("_BagLayer").__currShowPanel:hideLayer()
                    self:getLayer("_BagLayer").__currShowPanel = nil
                end

                self:getLayer("_BagLayer"):itemDescHide()
                self:getLayer("_BagLayer"):ButtonHelp()
                PopupLayerController:hideLayer(
                    "BagDescLayer",
                    function(layer)
                        layer:hideLayer()
                    end,
                    0
                )
            end
        end
    },
    _AttrLayer = "高亮",
    _JiangHuLayer = "高亮",
    _BagLayer = "高亮",
    _AttrLayer_JiangHuLayer = "高亮",
    _AttrLayer_BagLayer = "高亮",
    _JiangHuLayer_BagLayer = "高亮",
    _JiangHuLayer_AttrLayer = {"反向动画", "高亮"},
    _BagLayer_JiangHuLayer = {"反向动画", "高亮"},
    _BagLayer_AttrLayer = {"反向动画", "高亮"}
}

function AttrControllLayer:create()
    local p = AttrControllLayer:new()
    p:init()
    return p
end

function AttrControllLayer:ctor()
    self:initLayerStack()
end

function AttrControllLayer:init()
    self._layers = layers
    self._switchs = switchs

    self._defaultSwitch = {
        -- 默认切换方式
        animType = "MoveAnim",
        animDuration = 0.3,
        animDirection = 1,
        animPreFunc = nil,
        animAftFunc = nil
    }

    self.__isFirstUpdateSkin = true
end

function AttrControllLayer:onAwake()
    local tableLayer = self:getLayer("_TableLayer")
    tableLayer:setLocalZOrder(10)

    local textNode = tableLayer:getUINode("Text_roleAttr")
    textNode:setString("人物属性")
    textNode:setTouchEnabled(true)
    textNode:releaseFunc(
        function()
            self:pushLayer("_AttrLayer")
        end
    )

    local textNode = tableLayer:getUINode("Text_jianghuAttr")
    textNode:setString("江湖属性")
    textNode:setTouchEnabled(true)
    textNode:releaseFunc(
        function()
            self:pushLayer("_JiangHuLayer")
        end
    )

    local textNode = tableLayer:getUINode("Text_bag")
    textNode:setString("背包")
    textNode:setTouchEnabled(true)
    textNode:releaseFunc(
        function()
            self:pushLayer("_BagLayer")
        end
    )

    self:pushLayer("_AttrLayer")
end

function AttrControllLayer:update(ft)
    local layer = self:getCurrLayer()
    if layer then
        layer:update(ft)
    end
end

function AttrControllLayer:onEnable()
    local layer = self:getCurrLayer()
    if layer == nil or layer.onResume == nil then
        return
    end
    layer:onResume()
end

-- 开始切换
function AttrControllLayer:onSwitch(toLayerName)
    if toLayerName == "SelectMapLayer" then
        return RoleTaskControllor:clickMapLayer(
            nil,
            function()
                MainControllLayer:popLayer()
            end,
            function()
                MainControllLayer:pushLayer("MainLayer")
            end
        )
    end
    return true
end

function AttrControllLayer:updateLayerSkinUI(skin_config)
    if skin_config == nil or type(skin_config) ~= "table" then
        return
    end

    self._skin_config = skin_config

    self:getLayer("_TableLayer"):updateSkin(skin_config)

    local layerName = self:getCurrLayer()

    if layerName then
        self:getLayer(layerName):updateSkin(self._skin_config)
    end
end

function AttrControllLayer:hideBagLayer()
	local layerName = self:getCurrLayer()

	if layerName == "_BagLayer" then
		local layer = self:getLayer(layerName)
		layer:hideCurrShowPanel()
	end
end

Helper:classDefNodeGetInstance(AttrControllLayer)
return AttrControllLayer
000000000
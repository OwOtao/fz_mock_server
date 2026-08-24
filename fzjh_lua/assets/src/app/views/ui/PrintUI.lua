local Resource = require("app.Resource")

local PrintUI = class("PrintUI", cc.Layer)

function PrintUI:create()
    local p = PrintUI:new()
    p:init()
    return p
end

function PrintUI:init()
    self._round = require("Layer/PrintUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUI(self) -- 获得所有子节点

    self:initRichText()
end

function PrintUI:initRichText()
    local x, y = self.Panel_print:getPosition()
    local size = self.Panel_print:getContentSize()

    if self.RichText_print then
        self.RichText_print:removeFromParent()
        self.RichText_print = nil
    end

    local richTextScroll = ExtRichTextScroll:create()
    self.Panel_print:getParent():addChild(richTextScroll)
    richTextScroll:move(cc.p(x, y))
    richTextScroll:setSize(size)
    richTextScroll:setDirection(kCCScrollViewDirectionVertical)
    richTextScroll:getRichText():setVerticalSpace(5)
    self.RichText_print = richTextScroll

    self.RichText_print:setBounceEnabled(true)
end

function PrintUI:registerRichPrint()
    RegisterRichPrint("main", self, self.print)
end

local textColor = cc.c3b(102, 153, 153)
function PrintUI:print(str, verticalSpace)
    local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
    if textHeight >= 8888 then
        self:initRichText()
    end

    self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
    if verticalSpace ~= nil and type(verticalSpace) == "number" then
        self.RichText_print:pushBackNewLine(verticalSpace)
    else
        self.RichText_print:pushBackNewLine()
    end
end

function PrintUI:updateSkinUI(layerName, skinId)
    local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")

    local print_layer_config = nil
    if skinId then
        print_layer_config = HouseSkin:getPrintLayerConfigBySkinId(layerName, skinId)
    else
        print_layer_config = HouseSkin:getPrintLayerConfig(layerName)
    end
    self.Image_print:loadTexture(print_layer_config.OutputPrintBg, 0)
end

-----------------------------------------------------------------------------------------------------------
-- @author LiJie
-- @time 2016/11/15 11:40:05
-- @desc 增加输出了隐藏的一个渐变动画
function PrintUI:show(isPlayAction)
    local currLayerName = MainControllLayer:getCurrLayer()

    self:updateSkinUI(currLayerName)

    if isPlayAction == true then
        self:stopAllActions()
        local pointY = self:getPositionY()
        local pointX = self:getPositionX()
        self:setVisible(true)
        self:setPosition(cc.p(pointX, pointY - 600))
        self:setCascadeOpacity(0)
        local action = cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.3, cc.p(pointX, pointY)), cc.FadeIn:create(0.3)))
        self:runAction(action)
    else
        self:setCascadeOpacity(255)
        self:setVisible(true)
    end
end
function PrintUI:hide(isPlayAction)
    if isPlayAction == true then
        self:stopAllActions()
        self:setCascadeOpacity(255)
        local pointY = self:getPositionY()
        local pointX = self:getPositionX()
        local action =
            cc.Sequence:create(
            cc.Spawn:create(cc.MoveTo:create(0.3, cc.p(pointX, pointY - 600)), cc.FadeOut:create(0.3)),
            cc.CallFunc:create(
                function()
                    self:setVisible(false)
                end
            ),
            cc.MoveTo:create(0, cc.p(pointX, pointY))
        )
        self:runAction(action)
    else
        self:setVisible(false)
    end
end
function PrintUI:setPanelVisible(loop)
    print("*****************************************************************************")
    if loop == nil or loop == false then
        self.Panel_1:setVisible(false)
    else
        self.Panel_1:setVisible(true)
    end
end
function PrintUI:setPanleReleaseFunc(func)
    if func == nil or type(func) ~= "function" then
        return
    end
    self.Panel_1:releaseFunc(func)
end

return PrintUI
0000
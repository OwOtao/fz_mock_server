local DetialWithButtonPopLayer = class("DetialWithButtonPopLayer", cc.Layer)

function DetialWithButtonPopLayer:create()
    local p = DetialWithButtonPopLayer:new()
    p:init()
    return p
end

function DetialWithButtonPopLayer:init()
    self._UI = require("Layer/Dialog/DetialWithButtonPopUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    -- Helper:convertUIParent(self)

    self:setBackFunc(
        function()
            self:hideLayer()
        end
    )
end

function DetialWithButtonPopLayer:setBtnFun(name, func)
    if name == nil then
        self.Button_OK:setVisible(false)
        return
    end
    self.Button_OK.Text_Name:setString(name)
    self.Button_OK:releaseFunc(
        function()
            func()
        end
    )
    self.Button_OK:setVisible(true)
end

function DetialWithButtonPopLayer:showLayer(name, type, dsc, btnName, func)
    self.Panel_Detial.Text_desc:setVisible(false)

    self:initRichText()

    self:setDetial(name, type, dsc)

    self:setBtnFun(btnName, func)

    self:show()
end

function DetialWithButtonPopLayer:hideLayer()
    PopupLayerController:hideLayer(
        "DetialWithButtonPopLayer",
        function(layer)
            layer:hide()
        end
    )
end

function DetialWithButtonPopLayer:setDetial(name, type, dsc)
    self.Panel_Detial.Text_name:setString("")
    self.Panel_Detial.Text_Type:setString("")

    if name == nil then
        print("DetialWithButtonPopLayer:setDetial 数据有问题")
        return
    end

    self.Panel_Detial.Text_name:setString(name)
    self.Panel_Detial.Text_Type:setString(Helper:getDef(type, ""))

    self:print(dsc)
end

--@desc: 设置描述框的对齐方式
--@author:Liang SongQiang
--@time:2018-05-22 21:29:31
--@h_type:
function DetialWithButtonPopLayer:setTextHorizontalAlignment(h_type)
    self.Panel_Detial.Text_desc:setTextHorizontalAlignment(h_type)
end

function DetialWithButtonPopLayer:setBackFunc(func)
    self.Panel_Back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end


function DetialWithButtonPopLayer:initRichText()
    local x, y = self.Panel_Detial.Text_desc:getPosition()
    local size = self.Panel_Detial.Text_desc:getContentSize()

    if self.RichText_Print then
        self.RichText_Print:removeFromParent()
        self.RichText_Print = nil
    end

    local richTextScroll = ExtRichTextScroll:create()
    self.Panel_Detial.Text_desc:getParent():addChild(richTextScroll)
    richTextScroll:setAnchorPoint(0.5, 0.5)
    richTextScroll:move(cc.p(x, y))
    richTextScroll:setSize(size)
    richTextScroll:setDirection(kCCScrollViewDirectionVertical)
    richTextScroll:getRichText():setVerticalSpace(5)
    self.RichText_Print = richTextScroll
    self.RichText_Print:setBounceEnabled(false)
    self.RichText_Print:setTouchEnabled(true)
end

function DetialWithButtonPopLayer:print(str, verticalSpace)
    if str == "" then
        return
    end
    local textColor = cc.c3b(102, 153, 153)
    local textHeight = self.RichText_Print:getRichText():getNewContentSizeHeight()
    if textHeight >= 1000 then
        self:initRichText()
    end

    self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)

    if verticalSpace ~= nil and type(verticalSpace) == "number" then
        self.RichText_Print:pushBackNewLine(verticalSpace)
    else
        self.RichText_Print:pushBackNewLine()
    end
    self:delayFunc(0.05,function ()
        self.RichText_Print:jumpToTop()
    end)
    
end

Helper:classDefNodeGetInstance(DetialWithButtonPopLayer)
return DetialWithButtonPopLayer
000
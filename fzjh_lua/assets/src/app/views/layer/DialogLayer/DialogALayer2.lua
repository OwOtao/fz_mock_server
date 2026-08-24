local DialogALayer2 = class("DialogALayer2", LayerEx)

function DialogALayer2:create()
    local p = DialogALayer2:new()
    p:init()
    return p
end

function DialogALayer2:init()
    local UI = require("Layer/Dialog/Dialog7UI.lua").create()["root"]
    UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setShowAndHideAnimType(1)

    self.Text_title:setVisible(false)
    self.Text_title_1:setVisible(false)
    self.Panel_2.Text_desc_9:setVisible(false)
    self.Text_desc_3:setVisible(false)
    self.Text_desc_4:setVisible(false)
    self.Text_desc_5:setVisible(false)

    self.Image_Goods:setVisible(false)

    self.Text_desc_1:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self.Text_desc_1:setTextColor({r = 212, g = 212, b = 212})
    self.Text_desc_1:setFontSize(48)

    self.Text_desc_1:setPosition(540.00, 1384.63)

    self.Text_title_2:setPositionX(540)
    self.Text_title_3:setPositionX(540)
    self.Text_title_2:ignoreContentAdaptWithSize(true)
    self.Text_title_3:ignoreContentAdaptWithSize(true)

    self.Button_close:setVisible(false)
end

function DialogALayer2:hideLayer()
    PopupLayerController:hideLayer(
        "DialogALayer2",
        function(layer)
            layer:hide()
        end
    )
end

function DialogALayer2:showLayer(str)
    self.Text_desc_1:setString(str)
    for i = 1, 2 do
        self["Button_" .. i]:setVisible(false)
    end
    self.Text_title_2:setVisible(false)
    self.Text_title_3:setVisible(false)
    self:show()
end

function DialogALayer2:setButton1(name, func, tips)
    if name == nil then
        return
    end

    if tips ~= nil then
        self.Text_title_2:setVisible(true)
        self.Text_title_2:setString(tips)
    end

    self.Button_1:setVisible(true)
    self.Button_1.Text_button_1Name:setString(name)
    self.Button_1:releaseFunc(
        function()
            self:hideLayer()
            if func ~= nil then
                func()
            end
        end
    )
end

function DialogALayer2:setButton2(name, func, tips)
    if name == nil then
        return
    end

    if tips ~= nil then
        self.Text_title_3:setVisible(true)
        self.Text_title_3:setString(tips)
    end

    self.Button_2:setVisible(true)
    self.Button_2.Text_button_2Name:setString(name)
    self.Button_2:releaseFunc(
        function()
            self:hideLayer()
            if func ~= nil then
                func()
            end
        end
    )
end

Helper:classDefNodeGetInstance(DialogALayer2)
return DialogALayer2
00000000
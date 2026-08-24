local DialogOLayer = class("DialogOLayer", LayerEx)

function DialogOLayer:create()
    local p = DialogOLayer:new()
    p:init()
    return p
end

function DialogOLayer:init()
    self._UI = require("Layer/Dialog/Dialog16UI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUI(self)

    self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)
end

function DialogOLayer:hideLayer()
    PopupLayerController:hideLayer("DialogOLayer",function(layer)
        layer:hide()
    end)
end

function DialogOLayer:showLayer()
    self:show()
end

function DialogOLayer:setTitle(text)
    self.Text_title:setString(text)
end

function DialogOLayer:setTalentTypeText(text)
    self.Text_skillDsc:setColor({r = 208, g = 208, b = 208})
    self.Text_skillDsc:setString(text)
end

function DialogOLayer:setTalentDsc(text)
    self.Text_detailDsc:setString(text)
end

function DialogOLayer:setButton(name,func)
    if name == false or name == nil then
        self.Button_1:setVisible(false)
        return
    end

    self.Text_buttonName1:setString(name)
    self.Button_1:setVisible(true)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
        self:hideLayer()
    end)
end

function DialogOLayer:setDesc1(desc)
    if desc == nil or desc == "" then
        self.Text_desc1:setVisible(false)
        return
    end
    self.Text_desc1:setVisible(true)
    self.Text_desc1:setString(desc)
end

function DialogOLayer:setDesc2(desc)
    if desc == nil or desc == "" then
        self.Text_desc2:setVisible(false)
        return
    end
    self.Text_desc2:setVisible(true)
    self.Text_desc2:setString(desc)
end

function DialogOLayer:setDesc3(desc)
    if desc == nil or desc == "" then
        self.Text_desc3:setVisible(false)
        return
    end
    self.Text_desc3:setVisible(true)
    self.Text_desc3:setString(desc)
end

function DialogOLayer:setDesc4(desc)
    if desc == nil or desc == "" then
        self.Text_desc4:setVisible(false)
        return
    end
    self.Text_desc4:setVisible(true)
    self.Text_desc4:setString(desc)
end

Helper:classDefNodeGetInstance(DialogOLayer)
return DialogOLayer
0000
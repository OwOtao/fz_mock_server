local DreamTalentInfoLayer = class("DreamTalentInfoLayer", LayerEx)

function DreamTalentInfoLayer:create()
    local p = DreamTalentInfoLayer:new()
    p:init()
    return p
end

function DreamTalentInfoLayer:init()
    self._UI = require("Layer/DreamWorldUI/DreamTalentInfoUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUI(self)

    self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)
end

function DreamTalentInfoLayer:hideLayer()
    PopupLayerController:hideLayer("DreamTalentInfoLayer",function(layer)
        layer:hide()
    end)
end

function DreamTalentInfoLayer:showLayer()
    self:show()
end

function DreamTalentInfoLayer:setTitle(text)
    self.Text_title:setString(text)
end

function DreamTalentInfoLayer:setTalentTypeText(text)
    self.Text_skillDsc:setString(text)
end

function DreamTalentInfoLayer:setTalentDsc(text)
    self.Text_detailDsc:setString(text)
end

function DreamTalentInfoLayer:setUnlockButton(name,func)
    if name == "" or name == nil then
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

function DreamTalentInfoLayer:setDesc1(desc)
    if desc == nil or desc == "" then
        self.Text_desc1:setVisible(false)
        return
    end
    self.Text_desc1:setVisible(true)
    self.Text_desc1:setString(desc)
end

function DreamTalentInfoLayer:setDesc2(desc)
    if desc == nil or desc == "" then
        self.Text_desc2:setVisible(false)
        return
    end
    self.Text_desc2:setVisible(true)
    self.Text_desc2:setString(desc)
end

function DreamTalentInfoLayer:setDesc3(desc)
    if desc == nil or desc == "" then
        self.Text_desc3:setVisible(false)
        return
    end
    self.Text_desc3:setVisible(true)
    self.Text_desc3:setString(desc)
end

Helper:classDefNodeGetInstance(DreamTalentInfoLayer)
return DreamTalentInfoLayer
0000000000000
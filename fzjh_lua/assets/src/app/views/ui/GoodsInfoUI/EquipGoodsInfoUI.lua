local EquipGoodsInfoUI = class("EquipGoodsInfoUI", LayerEx)

local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")

function EquipGoodsInfoUI:create()
    local p = EquipGoodsInfoUI:new()
    p:init()
    return p
end

function EquipGoodsInfoUI:init()
    self._UI = require("Layer/GoodsInfo/EquipGoodsInfoUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function EquipGoodsInfoUI:showUI()
    self:show()
end

function EquipGoodsInfoUI:hideUI()
    self:hide()
end

function EquipGoodsInfoUI:setTitle(text)
    self.Text_title:setString(text)
end

function EquipGoodsInfoUI:setNodeText(nodeName,text)
	if self[nodeName] then
		self[nodeName]:setString(text)
	end
end

function EquipGoodsInfoUI:setPanelWeaponAttrisVisible(isVisible)
	self.Panel_weaponAttr:setVisible(isVisible)
end

function EquipGoodsInfoUI:setButtonBackVisible(bool)
    self.Button_back:setVisible(bool)
end

function EquipGoodsInfoUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function EquipGoodsInfoUI:setAttributePanel(index,name,desc,func)
    local panel = self.Panel_weaponAttr["Panel_"..tostring(index)]
    if panel then
        -- Helper:convertUIByParent(panel)
		panel.Text_name:setString(name)
		panel.Text_Info:setString(desc)
        panel:releaseFunc(function()
            panel.Image_8:setVisible(false)
            self.Panel_desc:setVisible(true)

            self:setTipsPanelBackFunc(function()
                panel.Image_8:setVisible(true)
                self.Panel_desc:setVisible(false)
            end)

            if func then
                func()
            end
        end)
    end
end

function EquipGoodsInfoUI:setTipsPanelBackFunc(func)
    self.Panel_desc:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function EquipGoodsInfoUI:setTipsDesc_1Text(text)
    self.Panel_desc.Image_desc.Text_desc1:setString(Helper:getDef(text,""))
end

function EquipGoodsInfoUI:setTipsDesc_2Text(text)
    self.Panel_desc.Image_desc.Text_desc2:setString(Helper:getDef(text,""))
end

function EquipGoodsInfoUI:setTipsDesc_3Text(text)
    self.Panel_desc.Image_desc.Text_Val:setString(Helper:getDef(text,""))
end

Helper:classDefNodeGetInstance(EquipGoodsInfoUI)

return EquipGoodsInfoUI
0000000000000000
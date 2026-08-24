local BagUpgradeUI = class("BagUpgradeUI", LayerEx)

function BagUpgradeUI:create()
    local p = BagUpgradeUI:new()
    p:init()
    return p
end

function BagUpgradeUI:init()
    self._UI = require("Layer/AttrUI/BagUpgradeUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUI(self)

    self:setVisible(false)
end

function BagUpgradeUI:showUI()
    self:show()
end

function BagUpgradeUI:hideUI()
    self:hide()
end

function BagUpgradeUI:setButton1Func(func)
	self.Button_1:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end		
	end)
end

function BagUpgradeUI:setButton2Func(func)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function BagUpgradeUI:setButtonclose(func)
	self.Button_close:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function BagUpgradeUI:setButton1Name(name)
    self.Text_button_1Name:setString(name)
end

function BagUpgradeUI:setButton2Name(name)
    self.Text_button_2Name:setString(name)
end

function BagUpgradeUI:setTextTitle(str)
    self.Text_title:setString(str)
end

function BagUpgradeUI:setTextDesc1(str)
    self.Text_desc_1:setString(str)
end

function BagUpgradeUI:setTextDesc2(str)
    self.Text_desc_2:setString(str)
end

return BagUpgradeUI
000000000000
--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-08-16 14:28:58
--]]
local MakeMaskUI = class("MakeMaskUI", LayerEx)

function MakeMaskUI:create()
	local p = MakeMaskUI:new()
	p:init()
	return p
end

function MakeMaskUI:init()
    self._round = require("Layer/HomelandUI/MakeMaskUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function MakeMaskUI:showUI()
	self:show()
end

function MakeMaskUI:hideUI()
	self:hide()
end

function MakeMaskUI:setTextTitle(text)
	self.Text_1:setString(text)
end

function MakeMaskUI:setTextSpNum(text)
	self.Text_2:setString(text)
end

function MakeMaskUI:setTextPayNum(text)
	self.Text_4:setString(text)
end

function MakeMaskUI:setTitle1Name(name)
	self.Image_kuangTitle1.Text_name:setString(name)
end

function MakeMaskUI:setPanelbg1Visible(bool)
	self.Image_kuangTitle1.Panel_bg:setVisible(bool)
end

function MakeMaskUI:setTitle1Func(func)
	self.Image_kuangTitle1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MakeMaskUI:setTitle2Name(name)
	self.Image_kuangTitle2.Text_name:setString(name)
end

function MakeMaskUI:setPanelbg2Visible(bool)
	self.Image_kuangTitle2.Panel_bg:setVisible(bool)
end

function MakeMaskUI:setTitle2Func(func)
	self.Image_kuangTitle2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MakeMaskUI:setRuleFunc(func)
	self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MakeMaskUI:setButton1Visible(visible)
    self.Button_1:setVisible(visible)
end

function MakeMaskUI:setButton1(name,func)
    self.Button_1.Text_name:setString(name)
	self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MakeMaskUI:setButton2(name,func)
    self.Button_2.Text_name:setString(name)
	self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MakeMaskUI:createPanelTitle()
    local panel = self.Panel_title:clone()
    
    Helper:convertUIByParent(panel)

    return panel
end

function MakeMaskUI:addItemToTitleList(item)
    self.ListView_title:pushBackCustomItem(item)
end

function MakeMaskUI:removeAllTitleItems()
    self.ListView_title:removeAllItems()
end

function MakeMaskUI:creatPanelListMask()
    local panel = self.Panel_ListMask:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function MakeMaskUI:createPanelMask()
    local panel = self.Panel_mask:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function MakeMaskUI:createPanelPayMask()
    local panel = self.Panel_payMask:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function MakeMaskUI:showPanelRule()
    self.Panel_infoBg:setVisible(true)
end

function MakeMaskUI:hidePanelRule()
    self.Panel_infoBg:setVisible(false)
end

function MakeMaskUI:getPanelInfoBg()
    return self.Panel_infoBg
end

function MakeMaskUI:createPanelText()
    local panel = self.Panel_Text:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function MakeMaskUI:createRulerInfoText()
    local text = self.Text_ruler:clone()

    Helper:convertUIByParent(text)

    return text
end

function MakeMaskUI:addItemToRuleInfoList(item)
    self.Panel_infoBg.ListView_rulerInfo:pushBackCustomItem(item)
end

function MakeMaskUI:removeAllRuleInfoItems()
    self.Panel_infoBg.ListView_rulerInfo:removeAllItems()
end

function MakeMaskUI:addItemToRuleList(item)
    self.Panel_infoBg.ListView_info:pushBackCustomItem(item)
end

function MakeMaskUI:removeAllRuleItems()
    self.Panel_infoBg.ListView_info:removeAllItems()
end

function MakeMaskUI:setPanelRuleFunc(func)
	self.Panel_infoBg:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MakeMaskUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return MakeMaskUI00000000
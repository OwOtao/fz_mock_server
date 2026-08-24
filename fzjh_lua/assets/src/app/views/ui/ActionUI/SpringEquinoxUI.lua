local SpringEquinoxUI = class("SpringEquinoxUI", cc.Layer)

function SpringEquinoxUI:create()
    local p = SpringEquinoxUI:new()
    p:init()
    return p
end

function SpringEquinoxUI:init()
	local UI = require("Layer/ActionUI/SpringEquinoxUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self:hide()
end

function SpringEquinoxUI:showUI()
	self:show()
end

function SpringEquinoxUI:hideUI()
	self:hide()
end

function SpringEquinoxUI:initPanelItems(items)
	if MapIsEmpty(items) == false then
		for index,item in ipairs(items) do
			if self.Image_Bg["Panel_item_"..index] then
				self.Image_Bg["Panel_item_"..index]:setVisible(true)
				self.Image_Bg["Panel_item_"..index].Text_name:setString(item.name)
				self.Image_Bg["Panel_item_"..index].Image_img:loadTexture(item.img)
				self.Image_Bg["Panel_item_"..index].Text_num:setString(item.num)
				self.Image_Bg["Panel_item_"..index]:releaseFunc(function()
					if item.func then
						item.func()
					end
				end)
			end
		end
	end
end

function SpringEquinoxUI:initListView(info)
	self.ListView_item:removeAllItems()
	
	if MapIsEmpty(info) == false then
		for index,levelInfo in ipairs(info) do
			local panel = self:__clonePanel()
			self:__initPanel(panel,levelInfo)
			self.ListView_item:pushBackCustomItem(panel)
		end
	end
end

function SpringEquinoxUI:setButton1Name(btnName)
	btnName = Helper:getDef(btnName,"")
	self.Button_1.Text_buttonName:setString(btnName)
end

function SpringEquinoxUI:setButton1Func(btnFunc)
	btnFunc = Helper:getDef(btnFunc,EMPTY_FUNC)
	self.Button_1:releaseFunc(function()
		btnFunc()
	end)
end

function SpringEquinoxUI:setText1(text)
	text = Helper:getDef(text,"")
	self.Text_1:setString(text)
end

function SpringEquinoxUI:setText2(text)
	text = Helper:getDef(text,"")
	self.Text_2:setString(text)
end

function SpringEquinoxUI:setText_desc(desc)
	desc = Helper:getDef(desc,"")
	self.Text_desc:setString(desc)
end

function SpringEquinoxUI:setText_title(title)
	title = Helper:getDef(title,"")
	self.Text_title:setString(title)
end

function SpringEquinoxUI:setButtonBackFunc(func)
	self.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function SpringEquinoxUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function SpringEquinoxUI:__clonePanel()
	local panel = self.Panel_item:clone()
	Helper:convertUIByParent(panel)
	return panel
end

function SpringEquinoxUI:__initPanel(panel,panelInfo)
	panel.Text_1:setString(panelInfo.text1)
	panel.Text_2:setString(panelInfo.text2)
	panel.Button_1.Text_buttonName:setString(panelInfo.btnName)
	panel.Button_1:setTouchEnabled(panelInfo.enabled)
	panel.Button_1:loadTextureNormal(panelInfo.texture)
	panel.Button_1:releaseFunc(function()
		if panelInfo.func then
			panelInfo.func()
		end
	end)
end

function SpringEquinoxUI:__initPanelInfo(panel,desc)
	panel.Text_info:setString(desc)
end

return SpringEquinoxUI

000000000000000
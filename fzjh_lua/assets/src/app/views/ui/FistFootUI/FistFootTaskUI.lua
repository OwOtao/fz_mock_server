local FistFootTaskUI = class("FistFootTaskUI", LayerEx)

function FistFootTaskUI:create()
	local p = FistFootTaskUI:new()
	p:init()
	return p
end

function FistFootTaskUI:init()
    self._round = require("Layer/FistFootUI/FistFootTaskUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function FistFootTaskUI:setPanelTitleFunc(index,callback)
    self.Panel_title["Panel_"..index]:releaseFunc(function()
		if callback then
			callback()
		end
	end)
end

function FistFootTaskUI:setPanelTitleName(index,name)
    self.Panel_title["Panel_"..index].Text_name:setString(name)
end

function FistFootTaskUI:setLightTitle(index)
    self.Panel_title.Panel_1.Text_name:setTextColor({r = 155, g = 155, b = 155})
    self.Panel_title.Panel_2.Text_name:setTextColor({r = 155, g = 155, b = 155})
    self.Panel_title.Panel_3.Text_name:setTextColor({r = 155, g = 155, b = 155})

    self.Panel_title["Panel_"..index].Text_name:setTextColor({r = 255, g = 255, b = 255})
end

function FistFootTaskUI:setLightTask(index)
    for i,item in ipairs(self.ListView_task:getItems()) do
        item.Image_light:setVisible(false)
    end

    self.ListView_task:getItem(index - 1).Image_light:setVisible(true)
end

function FistFootTaskUI:setListViewTask(array)
    self.ListView_task:removeAllItems()
    for i,v in ipairs(array) do
        local button = self.Button_task:clone()
        Helper:convertUIByParent(button)

        if v.isState == 1 then
            button.Pnl_cd:setVisible(false)
            button.Pnl_able:setVisible(false)
            button.Pnl_Disable:setVisible(true)
            button.Image_di:loadTexture(v.diImage,0)
            button.Pnl_Disable.Text_condition:setString(v.condition)
        elseif v.isState == 2 then
            button.Pnl_cd:setVisible(false)
            button.Pnl_able:setVisible(true)
            button.Pnl_Disable:setVisible(false)
            button.Image_di:loadTexture(v.diImage,0)
            button.Pnl_able.Text_name:setString(v.name)
            button.Pnl_able.Text_reward1:setString(v.reward1)
            button.Pnl_able.Text_reward2:setString(v.reward2)
            button.Pnl_able.Text_time:setString(v.time)
        elseif v.isState == 3 then
            button.Pnl_cd:setVisible(true)
            button.Pnl_able:setVisible(false)
            button.Pnl_Disable:setVisible(false)
            button.Image_di:loadTexture(v.diImage,0)
            button.Pnl_cd.Text_name:setString(v.name)
            button.Pnl_cd.Text_reward1:setString(v.reward1)
            button.Pnl_cd.Text_reward2:setString(v.reward2)
            button.Pnl_cd.Text_time:setString(v.time)
        end

        button:releaseFunc(function()
            if v.func then
                v.func()
            end
        end)

        self.ListView_task:pushBackCustomItem(button)
    end
    
    self.ListView_task:jumpToTop()
end

function FistFootTaskUI:setButtonStart(func)
	self.Button_start:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function FistFootTaskUI:setText1(text)
	self.Text_1:setString(text)
end

function FistFootTaskUI:setText2(text)
	self.Text_2:setString(text)
end

function FistFootTaskUI:setText3(text)
	self.Text_3:setString(text)
end

function FistFootTaskUI:setNotTaskVisible(bool)
	self.Text_notTask:setVisible(bool)
end

return FistFootTaskUI00000000000000
local TeacherBuildDonateUI = class("TeacherBuildDonateUI", LayerEx)

function TeacherBuildDonateUI:create()
	local p = TeacherBuildDonateUI:new()
	p:init()
	return p
end

function TeacherBuildDonateUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherBuildDonateUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherBuildDonateUI:setTextLv(text)
	self.Text_lv:setString(text)
end

function TeacherBuildDonateUI:setTextExp(text)
	self.Text_exp:setString(text)
end

function TeacherBuildDonateUI:setTextDonateNum(text)
	self.Image_1.Text_donateNum:setString(text)
end

function TeacherBuildDonateUI:setPercent(percent)
	self.LoadingBar:setPercent(percent)
end

function TeacherBuildDonateUI:setListViewDonateList(array)
    self.ListView_task:removeAllItems()
    for i,v in ipairs(array) do
        if v.state == 0 then
            local button = self.Panel_donate:clone()

            Helper:convertUIByParent(button)
            
            button.Text_name:setString(v.title)
            
            button.Text_openText:setString(v.openText)

            button:releaseFunc(function()
                if v.func then
                    v.func()
                end
            end)

            self.ListView_task:pushBackCustomItem(button)
        else
            local button = self.Button_task:clone()

            Helper:convertUIByParent(button)
            
            button.Text_name:setString(v.title)
            
            button.Text_num:setString(v.num)
            
            button.Button_donate:releaseFunc(function()
                if v.func then
                    v.func()
                end
            end)

            self.ListView_task:pushBackCustomItem(button)
        end

    end
    
    self.ListView_task:jumpToTop()
end

function TeacherBuildDonateUI:setButtonItems(func)
	self.Button_items:releaseFunc(function()
		if func then
			func()
		end
	end)
end


return TeacherBuildDonateUI00
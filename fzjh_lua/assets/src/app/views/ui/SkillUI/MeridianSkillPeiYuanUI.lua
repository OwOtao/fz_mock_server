local MeridianSkillPeiYuanUI = class("MeridianSkillPeiYuanUI", LayerEx)

function MeridianSkillPeiYuanUI:create()
	local p = MeridianSkillPeiYuanUI:new()
	p:init()
	return p
end

function MeridianSkillPeiYuanUI:init()
    self.__round = require("Layer/SkillUI/MeridianSkillUI.lua").create()['root']
    self.__round:addTo(self)

    Helper:convertUIByParent(self)
end

function MeridianSkillPeiYuanUI:showUI()
    self:setVisible(true)
end

function MeridianSkillPeiYuanUI:hideUI()
    self:setVisible(false)
end

function MeridianSkillPeiYuanUI:setTitle(text)
    self.Text_title:setString(text)
end

function MeridianSkillPeiYuanUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function MeridianSkillPeiYuanUI:setTextLeftTip(text)
    self.Text_selectLeft:setString(text)
end

function MeridianSkillPeiYuanUI:setTextRightTip(text)
    self.Text_selectRight:setString(text)
end

function MeridianSkillPeiYuanUI:setTextLeftName(text)
    self.Image_left.Text_name:setString(text)
end

function MeridianSkillPeiYuanUI:setTextRightName(text)
    self.Image_right.Text_name:setString(text)
end

function MeridianSkillPeiYuanUI:setLeftListView(array)
    for i,v in ipairs(array) do
        local panel = self.Panel_leftList.ListView_list:getItem(i - 1)
        if panel == nil then
            panel = self.Panel_name:clone()
            self.Panel_leftList.ListView_list:pushBackCustomItem(panel)
        end

        Helper:convertUIByParent(panel)

        panel.Text_name:setString(v.name)

        panel:releaseFunc(function()
            v.func()
        end)
    end

    for i = #array + 1, #self.Panel_leftList.ListView_list:getItems() do
		self.Panel_leftList.ListView_list:removeLastItem()
	end
end

function MeridianSkillPeiYuanUI:setRightListView(array)
    for i,v in ipairs(array) do
        local panel = self.Panel_rightList.ListView_list:getItem(i - 1)
        if panel == nil then
            panel = self.Panel_name:clone()
            self.Panel_rightList.ListView_list:pushBackCustomItem(panel)
        end

        Helper:convertUIByParent(panel)

        panel.Text_name:setString(v.name)

        panel:releaseFunc(function()
            v.func()
        end)
    end

    for i = #array + 1, #self.Panel_rightList.ListView_list:getItems() do
		self.Panel_rightList.ListView_list:removeLastItem()
	end
end

function MeridianSkillPeiYuanUI:showImprintingDetail()
    self.Panel_itemDesc:setVisible(true)
end

function MeridianSkillPeiYuanUI:hideImprintingDetail()
    self.Panel_itemDesc:setVisible(false)
end

function MeridianSkillPeiYuanUI:setImprintingDetail(data)
    self.Panel_itemDesc.Text_name:setString(data.name)
    self.Panel_itemDesc.Text_type:setString(data.type)
    self.Panel_itemDesc.Text_desc:setString(data.text)
end

function MeridianSkillPeiYuanUI:setTextLeftSpeed(text)
    self.Text_speedLeft:setString(text)
end

function MeridianSkillPeiYuanUI:setTextRightSpeed(text)
    self.Text_speedRight:setString(text)
end

function MeridianSkillPeiYuanUI:setButtonLeft(name,func)
    self.Button_left.Text_buttonName:setString(name)
    self.Button_left:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function MeridianSkillPeiYuanUI:setButtonRight(name,func)
    self.Button_right.Text_buttonName:setString(name)
    self.Button_right:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end


return MeridianSkillPeiYuanUI000000000
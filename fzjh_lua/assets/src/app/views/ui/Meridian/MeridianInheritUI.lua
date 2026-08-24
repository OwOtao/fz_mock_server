local MeridianInheritUI = class("MeridianInheritUI", LayerEx)

function MeridianInheritUI:create()
	local p = MeridianInheritUI:new()
	p:init()
	return p
end

function MeridianInheritUI:init()
    self.__round = require("Layer/MeridianUI/MeridianInheritUI.lua").create()['root']

	self.__round:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function MeridianInheritUI:showUI()
    self:setVisible(true)
end

function MeridianInheritUI:hideUI()
    self:setVisible(false)
end

function MeridianInheritUI:setTextTitle(text)
	self.Panel_category.Text_Title:setString(text)
end

function MeridianInheritUI:setBackButtonFunc(func)
    self.Panel_category.Button_return:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MeridianInheritUI:setInheritButtonName(text)
    self.Button_inherit.Text_buttonName:setString(text)
end

function MeridianInheritUI:setInheritButtonFunc(func)
    self.Button_inherit:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MeridianInheritUI:createTitlePanel()
	local row = self.Panel_back_title:clone()
	Helper:convertUIByParent(row)
	return row
end

function MeridianInheritUI:createImprintingPanel()
	local row = self.Panel_imprinting:clone()
	Helper:convertUIByParent(row)
	return row
end

function MeridianInheritUI:createSelectImprintingPanel()
	local row = self.Panel_imprinting_0:clone()
	Helper:convertUIByParent(row)
	return row
end

function MeridianInheritUI:createSelectText1()
	return self.Text_desc:clone()
end

function MeridianInheritUI:createSelectText2()
	return self.Text_desc1:clone()
end

function MeridianInheritUI:removeTitleListViewAllItems()
    self.Image_tab.ListView_tab:removeAllItems()
end

function MeridianInheritUI:insertTitleToListView(panel)
    self.Image_tab.ListView_tab:pushBackCustomItem(panel)
end

function MeridianInheritUI:getTitleItems()
    return self.Image_tab.ListView_tab:getItems()
end

function MeridianInheritUI:getTitleItem(index)
    return self.Image_tab.ListView_tab:getItem(index)
end

function MeridianInheritUI:setImprintingListVisible(visible)
    return self.ListView_titlelistArea:setVisible(visible)
end

function MeridianInheritUI:getImprintingItem(index)
    return self.ListView_titlelistArea:getItem(index)
end

function MeridianInheritUI:getImprintingItems()
    return self.ListView_titlelistArea:getItems()
end

function MeridianInheritUI:removeImprintingLastItem()
    self.ListView_titlelistArea:removeLastItem()
end

function MeridianInheritUI:insertImprintingToListView(item)
    self.ListView_titlelistArea:pushBackCustomItem(item)
end

function MeridianInheritUI:removeYinJiListViewAllItems()
    self.ListView_yinji:removeAllItems()
end

function MeridianInheritUI:insertYinJiToListView(panel)
    self.ListView_yinji:pushBackCustomItem(panel)
end

function MeridianInheritUI:setPanelBgVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_bg:setVisible(visible)
end

function MeridianInheritUI:setPanelBgFunc(func)
    self.Panel_bg:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MeridianInheritUI:setImprintingPanelVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_itemDesc:setVisible(visible)
end

function MeridianInheritUI:setTextImprintingName(text)
    self.Panel_itemDesc.Image_back.Panel_title.Text_name:setString(text)
end

function MeridianInheritUI:setTextImprintingType(text)
    self.Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(text)
end

function MeridianInheritUI:setTextImprintingTypeColor(color)
    self.Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setColor(color)
end

function MeridianInheritUI:setTextImprintingDesc(text)
    self.Panel_itemDesc.Image_back.TextField_desc:setString(text)
end

function MeridianInheritUI:setImprintingButtonName(text)
    self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString(text)
end

function MeridianInheritUI:setImprintingButtonFunc(func)
	self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MeridianInheritUI:showImprintingPanel(callFunc)
	local Panel_itemDesc = self.Panel_itemDesc
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(300, 1710))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(300, 1540)),
			cc.FadeIn:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
                if callFunc then
                    callFunc()
                end
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
end


function MeridianInheritUI:hideImprintingPanel(callFunc)
	local Panel_itemDesc = self.Panel_itemDesc
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(300, 1540))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(300, 1710)),
			cc.FadeOut:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
				Panel_itemDesc:setVisible(false)
				if callFunc then
                    callFunc()
                end
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
end

return MeridianInheritUI000
local MeridianImprintingUI = class("MeridianImprintingUI", LayerEx)

function MeridianImprintingUI:create()
	local p = MeridianImprintingUI:new()
	p:init()
	return p
end

function MeridianImprintingUI:init()
    self.__round = require("Layer/MeridianUI/MeridianImprintingUI.lua").create()['root']

	self.__round:addTo(self)

    Helper:convertUIByParent(self)

    self:initRichText()

    self:setVisible(false)
end

function MeridianImprintingUI:showUI()
    self:setVisible(true)
end

function MeridianImprintingUI:hideUI()
    self:setVisible(false)
end

function MeridianImprintingUI:setTextMeridianLv(text)
	self.Text_MeridianLv_num:setString(text)
end

function MeridianImprintingUI:setTextZhenQiNum(text)
	self.Text_zhenqi_num:setString(text)
end

function MeridianImprintingUI:setUseButtonVisible(visible)
	visible = Helper:getDef(visible,false)
	self.Button_use:setVisible(visible)
end

function MeridianImprintingUI:setUseButtonFunc(func)
    self.Button_use:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MeridianImprintingUI:createTitlePanel()
	local row = self.Panel_back_title:clone()
	Helper:convertUIByParent(row)
	return row
end

function MeridianImprintingUI:createImprintingPanel()
	local row = self.Panel_imprinting:clone()
	Helper:convertUIByParent(row)
	return row
end

function MeridianImprintingUI:removeTitleListViewAllItems()
    self.Image_tab.ListView_tab:removeAllItems()
end

function MeridianImprintingUI:insertTitleToListView(panel)
    self.Image_tab.ListView_tab:pushBackCustomItem(panel)
end

function MeridianImprintingUI:getTitleItems()
    return self.Image_tab.ListView_tab:getItems()
end

function MeridianImprintingUI:getTitleItem(index)
    return self.Image_tab.ListView_tab:getItem(index)
end

function MeridianImprintingUI:setImprintingListVisible(visible)
    return self.ListView_titlelistArea:setVisible(visible)
end

function MeridianImprintingUI:getImprintingItem(index)
    return self.ListView_titlelistArea:getItem(index)
end

function MeridianImprintingUI:getImprintingItems()
    return self.ListView_titlelistArea:getItems()
end

function MeridianImprintingUI:removeImprintingLastItem()
    self.ListView_titlelistArea:removeLastItem()
end

function MeridianImprintingUI:insertImprintingToListView(item)
    self.ListView_titlelistArea:pushBackCustomItem(item)
end

function MeridianImprintingUI:initRichText()
	local x, y = self.Image_help.Panel_talk:getPosition()
	local size = self.Image_help.Panel_talk:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Image_help.Panel_talk:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Image_help.Panel_talk:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)
end

function MeridianImprintingUI:print(str)
	if str == "" then
		return
	end

	if self.RichText_print == nil then
		return
	end
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 36)

	self.RichText_print:pushBackNewLine()
end

function MeridianImprintingUI:setPanelBgVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_bg:setVisible(visible)
end

function MeridianImprintingUI:setPanelBgFunc(func)
    self.Panel_bg:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MeridianImprintingUI:setImprintingPanelVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_itemDesc:setVisible(visible)
end

function MeridianImprintingUI:setTextImprintingName(text)
    self.Panel_itemDesc.Image_back.Panel_title.Text_name:setString(text)
end

function MeridianImprintingUI:setTextImprintingType(text)
    self.Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(text)
end

function MeridianImprintingUI:setTextImprintingLv(text)
    self.Panel_itemDesc.Image_back.Panel_title.Text_lv:setString(text)
end

function MeridianImprintingUI:setTextImprintingTypeColor(color)
    self.Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setColor(color)
end

function MeridianImprintingUI:setTextImprintingDesc(text)
    self.Panel_itemDesc.Image_back.TextField_desc:setString(text)
end

function MeridianImprintingUI:setTextImprintingSpeed(text)
    self.Panel_itemDesc.Image_back.Text_speed:setString(text)
end

function MeridianImprintingUI:setImprintingButtonName(text)
    self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString(text)
end

function MeridianImprintingUI:setImprintingButtonFunc(func)
	self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MeridianImprintingUI:showImprintingPanel(callFunc)
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


function MeridianImprintingUI:hideImprintingPanel(callFunc)
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

return MeridianImprintingUI00000000000
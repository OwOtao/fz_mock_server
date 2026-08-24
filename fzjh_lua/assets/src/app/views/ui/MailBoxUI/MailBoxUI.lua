local MailBoxUI = class("MailBoxUI", LayerEx)

function MailBoxUI:create()
	local p = MailBoxUI:new()
	p:init()
	return p
end

function MailBoxUI:init()
    self._UI = require("Layer/MailBoxUI/MailBoxUI.lua").create()['root']
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setVisible(false)
end

function MailBoxUI:showUI()
    self.Text_tital:setString("江湖邮驿")
    self:show()
end

function MailBoxUI:initRichTextItem1()
	if self.RichText_Print1 then
		self.RichText_Print1:getRichText():removeFromParent()
	end
	
	local x, y = self.Panel_Show1.Text_email:getPosition()
	local size = self.Panel_Show1.Text_email:getContentSize()
	
	self.RichText_Print1 = ExtRichTextScroll:create()
	self.RichText_Print1:setAnchorPoint( 0.5 , 0.5 )
	self.Panel_Show1.Text_email:getParent():addChild(self.RichText_Print1)
	self.RichText_Print1:move(cc.p(x, y))
	self.RichText_Print1:setSize(size)
	self.RichText_Print1:setVerticalSpace(8)
	self.RichText_Print1:setDirection(kCCScrollViewDirectionVertical)
end

function MailBoxUI:initRichTextItem2()
	if self.RichText_Print2 then
		self.RichText_Print2:getRichText():removeFromParent()
	end
	
	local x, y = self.Panel_Show2.Text_email:getPosition()
	local size = self.Panel_Show2.Text_email:getContentSize()
	
	self.RichText_Print2 = ExtRichTextScroll:create()
	self.RichText_Print2:setAnchorPoint( 0.5 , 0.5 )
	self.Panel_Show2.Text_email:getParent():addChild(self.RichText_Print2)
	self.RichText_Print2:move(cc.p(x, y))
	self.RichText_Print2:setSize(size)
	self.RichText_Print2:setVerticalSpace(8)
	self.RichText_Print2:setDirection(kCCScrollViewDirectionVertical)
end

local textColor = cc.c3b(255, 255, 255)
function MailBoxUI:initRichText(node,str)
	if not node then
        return
    end
    node:getRichText():removeAllElement()
    node:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 36)
	node:setTouchEnabled(true)
	self:delayFunc(0.1,function ()
		node:jumpToTop()
	end)
end

function MailBoxUI:hideUI()
    self.ListView_email:removeAllItems()
    self:hide()
end

function MailBoxUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function MailBoxUI:setEmailNum(text)
    self.Text_emailNum:setString(text)
end

function MailBoxUI:setNotEmailTextIsVisible(isbool)
    self.Text_notEmail:setVisible(isbool)
end

function MailBoxUI:refreshListViewItemTextTime(index,text)
    local item = self.ListView_email:getItem(index)
    if item then
        item.Text_time:setString(text)
    end
end

function MailBoxUI:refreshListViewItemIsNew(index,isNew,image)
    local item = self.ListView_email:getItem(index)
    if item then
        item.Image_isNew:setVisible(isNew)
        if image then
            item.Image_1:loadTexture(image,0)
        end
    end
end

function MailBoxUI:removeListViewItem(index)
    self.ListView_email:removeItem(index)
end

function MailBoxUI:setEmailListView(array)
    self.ListView_email:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self.Panel_email:clone()
        Helper:convertUIByParent(panel)

        panel.Image_1:loadTexture(v["image"],0)
        panel.Image_isNew:setVisible(v["isNew"])
        panel.Text_name:setString(v["title"])
        panel.Button_delete:releaseFunc(function()
            if v["deleteFunc"] then
                v["deleteFunc"]()
            end
        end)
        panel:releaseFunc(function()
            if v["func"] then
                v["func"]()
            end
        end)

        self.ListView_email:pushBackCustomItem(panel)
    end
    self.ListView_email:jumpToTop()
end

function MailBoxUI:setButtonAllLinQuEnabled(isbool)
    self.Button_linqu:setEnabled(isbool)
end

function MailBoxUI:setButtonDeleteReadEnabled(isbool)
    self.Button_deleteRead:setEnabled(isbool)
end

function MailBoxUI:setButtonAllLinQu(func)
    self.Button_linqu:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MailBoxUI:setButtonDeleteRead(func)
    self.Button_deleteRead:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MailBoxUI:initPanelShow1(data)
    self.Panel_Show1:setVisible(true)
    self:initRichTextItem1()
    self.Panel_Show1.Text_emailName:setString(data["title"])
    self:initRichText(self.RichText_Print1,data["contents"])
    self.Panel_Show1.Button_linqu:setEnabled(data["buttonStata"])
    self.Panel_Show1.Button_linqu:releaseFunc(function()
        data["buttonFunc"](function()
            self.Panel_Show1:setVisible(false)
        end)
    end)
    self.Panel_Show1.Button_close:releaseFunc(function()
        self.Panel_Show1:setVisible(false)
    end)

    self.Panel_Show1.ListView_item:removeAllItems()
    for i,v in ipairs(data["showList"]) do
        local panel = self.Panel_Show1.Panel_1:clone()
        Helper:convertUIByParent(panel)

        panel.Text_name:setString(v["name"])
        panel.Text_num:setString(v["num"])
        panel.Text_state:setString(v["stateText"])

        self.Panel_Show1.ListView_item:pushBackCustomItem(panel)
    end
end

function MailBoxUI:initPanelShow2(data)
    self.Panel_Show2:setVisible(true)
    self:initRichTextItem2()
    self.Panel_Show2.Text_emailName:setString(data["title"])
    self:initRichText(self.RichText_Print2,data["contents"])
    self.Panel_Show2.Button_linqu:setEnabled(data["buttonStata"])
    self.Panel_Show2.Button_linqu:releaseFunc(function()
        data["buttonFunc"]()
    end)
    self.Panel_Show2.Button_close:releaseFunc(function()
        self.Panel_Show2:setVisible(false)
    end)
end

function MailBoxUI:initPanelShowAllItem(data)
    self.Panel_ShowAllItem:setVisible(true)
    self.Panel_ShowAllItem.Text_needWeight:setString(data["needWeight"])
    self.Panel_ShowAllItem.Text_currWeight:setString(data["currWeight"])
    self.Panel_ShowAllItem.Button_linqu:releaseFunc(function()
        data["buttonFunc"]()
        self.Panel_ShowAllItem:setVisible(false)
    end)
    self.Panel_ShowAllItem.Button_close:releaseFunc(function()
        self.Panel_ShowAllItem:setVisible(false)
    end)

    self.Panel_ShowAllItem.ListView_item:removeAllItems()
    for i,v in ipairs(data["showList"]) do
        local panel = self.Panel_ShowAllItem.Panel_item:clone()
        Helper:convertUIByParent(panel)

        panel.Text_name:setString(v["name"])
        panel.Text_num:setString(v["num"])

        self.Panel_ShowAllItem.ListView_item:pushBackCustomItem(panel)
    end
end

function MailBoxUI:initPanelTip(data)
    self.Panel_tip:setVisible(true)
    self.Panel_tip.Text_desc:setString(data["desc"])
    self.Panel_tip.Button_confirm:releaseFunc(function()
        data["buttonFunc"](function()
            self.Panel_tip:setVisible(false)
        end)
    end)
    self.Panel_tip.Button_close:releaseFunc(function()
        self.Panel_tip:setVisible(false)
    end)
end

function MailBoxUI:initPanelDesc(desc)
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_desc:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self.Panel_desc.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			dialog:show(desc)
			dialog:setPanelBack(function()
				self.Panel_desc.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			self.Panel_desc.Image_7:setVisible(true)
		end
	end)
end

function MailBoxUI:popText(text)
    PopText(text)
end

return MailBoxUI0
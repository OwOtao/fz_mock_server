local XuanBingDongBagUI = class("XuanBingDongBagUI", LayerEx)

function XuanBingDongBagUI:create()
	local p = XuanBingDongBagUI:new()
	p:init()
	return p
end

function XuanBingDongBagUI:init()
    self._UI = require("Layer/ShenBing/XuanBingDongBagUI.lua").create()['root']

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:__initDescBackFunc()

    self.Image_tab.ListView_tab:setScrollBarEnabled(false)
end

function XuanBingDongBagUI:showUI()
    self:setVisible(true)
end

function XuanBingDongBagUI:hideUI()
    self:setVisible(false)
end

function XuanBingDongBagUI:setButtonBack(func)
    self.Image_title.Button_back:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function XuanBingDongBagUI:setTextTitle(text)
    self.Image_title.Text_title:setString(text)
end

function XuanBingDongBagUI:setButton_1Text(text)
    self.Image_1.Text_1:setString(text)
end

function XuanBingDongBagUI:setButton_1Texture(texture)
    self.Image_1:loadTexture(texture)
end

function XuanBingDongBagUI:setButton_1TouchEnabled(enbale)
    self.Image_1:setTouchEnabled(enbale)
end

function XuanBingDongBagUI:setButton_1Func(func)
    self.Image_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function XuanBingDongBagUI:setButton_2Text(text)
    self.Image_2.Text_1:setString(text)
end

function XuanBingDongBagUI:setButton_2Texture(texture)
    self.Image_2:loadTexture(texture)
end

function XuanBingDongBagUI:setButton_2TouchEnabled(enbale)
    self.Image_2:setTouchEnabled(enbale)
end

function XuanBingDongBagUI:setButton_2Func(func)
    self.Image_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function XuanBingDongBagUI:setText_2(text)
    self.Text_2:setString(text)
end

-- 物品描述显示
function XuanBingDongBagUI:itemDescShow(anim)
    self.Panel_Dsc_back.Panel_itemDesc:setTouchEnabled(true)
    local panel = self.Panel_Dsc_back.Panel_itemDesc
    self.Panel_Dsc_back:setVisible(true)
    self:setLocalZOrder(1000)
    panel:setVisible(true)
    local actionTag = panel:getActionTagByName("move")
    panel:stopActionByTag(actionTag)
    panel:move(cc.p(380, 1710))
    local action =
        cc.Sequence:create(
        cc.Spawn:create(cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1540)), cc.FadeIn:create(UI_ANIM_DURATION)),
        cc.CallFunc:create(
            function()
            end
        )
    )
    action:setTag(actionTag)
    panel:runAction(action)
end

-- 物品描述隐藏
function XuanBingDongBagUI:itemDescHide(anim)
    self.Panel_Dsc_back.Panel_itemDesc:setTouchEnabled(false)
    Helper:callChildrenByParent(
        self.Panel_Dsc_back.Panel_itemDesc,
        function(parent, child)
            child:setTouchEnabled(false)
        end
    )
    local panel = self.Panel_Dsc_back.Panel_itemDesc
    local actionTag = panel:getActionTagByName("move")
    panel:stopActionByTag(actionTag)
    panel:setCascadeOpacityEnabled(true)
    panel:callAllChild(
        function(child)
            child:setCascadeOpacityEnabled(true)
        end
    )
    local action =
        cc.Sequence:create(
        cc.Spawn:create(cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1710)), cc.FadeOut:create(UI_ANIM_DURATION)),
        cc.CallFunc:create(
            function()
                self:setLocalZOrder(0)
                self.Panel_Dsc_back:setVisible(false)
            end
        )
    )
    action:setTag(actionTag)
    panel:runAction(action)
end

function XuanBingDongBagUI:initItemDescPanel(itemInfo)
    local itemDesc = self.Panel_Dsc_back.Panel_itemDesc
    itemDesc.Image_back:setTouchEnabled(true)
    itemDesc.Image_back.Image_button:setTouchEnabled(true)
    itemDesc.Image_back.Image_button_info:setTouchEnabled(true)
    itemDesc.Image_back.Panel_title.Text_name:setColor(cc.c3b(208, 208, 208))
    itemDesc.Image_back.Panel_title.Text_name:setString(itemInfo.text1)
    itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(itemInfo.text2)
    itemDesc.Image_back.TextField_desc:setString(itemInfo.text3)
    itemDesc.Image_back.Image_button.Text_chuan:setString(itemInfo.btnName)

    itemDesc.Image_back.Image_button_info:releaseFunc(function()
        if itemInfo.func1 then
            itemInfo.func1()
        end
    end)

    itemDesc.Image_back.Image_button:releaseFunc(function()
        if itemInfo.func2 then
            itemInfo.func2()
        end
    end)
end

function XuanBingDongBagUI:initItemList(list)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(list) == false then
        for i, v in ipairs(list) do
            local item = self:__cloneListView_1Item()
            self:__initListView_1Item(item, v)
            self.ListView_item:pushBackCustomItem(item)
        end

        self.ListView_item:jumpToTop()
    end
end

function XuanBingDongBagUI:initTypeListView(list)
    self.Image_tab.ListView_tab:removeAllItems()

    if MapIsEmpty(list) == false then
        for i, v in ipairs(list) do
            local item = self:__cloneListView_2Item()
            self:__initListView_2Item(item, v)
            self.Image_tab.ListView_tab:pushBackCustomItem(item)
        end
    end
end

function XuanBingDongBagUI:__cloneListView_1Item()
    local row = self.Panel_item:clone()
    Helper:convertUIByParent(row)
    row:setVisible(true)
    row:setTouchEnabled(true)
    row.Image_tiao.Text_1:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Text_2:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Text_3:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)

    return row
end

function XuanBingDongBagUI:__initListView_1Item(panel,panelInfo)
    if MapIsEmpty(panelInfo) == false then
        panel.Image_tiao.Text_1:setColor(cc.c3b(208, 208, 208))
        panel.Image_tiao.Text_1:setString(panelInfo.text1)
        panel.Text_2:setString(panelInfo.text2)
        panel.Text_3:setString(panelInfo.text3)
        panel.Text_3:setPositionX(panelInfo.posX)
        panel.Panel_dian:setVisible(panelInfo.visible)
        panel:releaseFunc(
            function()
                if panelInfo.func then
                    panelInfo.func()
                end
            end
        )
    end
end

function XuanBingDongBagUI:__cloneListView_2Item()
    local item = self.Panel_typeItem:clone()
    Helper:convertUIByParent(item)
    return item
end

function XuanBingDongBagUI:__initListView_2Item(item, itemInfo)
    if MapIsEmpty(itemInfo) == false then
        item.Image_1:setVisible(itemInfo.visible)
        item.Text_1:setString(itemInfo.text1)
        item:releaseFunc(
            function()
                if itemInfo.func then
                    itemInfo.func()
                end
            end
        )
    end
end

function XuanBingDongBagUI:__initDescBackFunc()
    self.Panel_Dsc_back.Panel_Detail_Back:releaseFunc(
        function()
            self:itemDescHide(true)
        end
    )
end

return XuanBingDongBagUI0000000
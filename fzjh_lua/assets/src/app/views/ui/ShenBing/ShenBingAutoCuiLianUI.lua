local ShenBingAutoCuiLianUI = class("ShenBingAutoCuiLianUI", LayerEx)

function ShenBingAutoCuiLianUI:create()
	local p = ShenBingAutoCuiLianUI:new()
	p:init()
	return p
end

function ShenBingAutoCuiLianUI:init()
    self._UI = require("Layer/ShenBing/ShenBingAutoCuiLianUI.lua").create()['root']

    self._UI:addTo(self)

    Helper:convertUIByParent(self)
end

function ShenBingAutoCuiLianUI:showUI()
    self:setVisible(true)
end

function ShenBingAutoCuiLianUI:hideUI()
    self:setVisible(false)
end

function ShenBingAutoCuiLianUI:setTextTitle(text)
    self.Text_title:setString(text)
end

function ShenBingAutoCuiLianUI:setPanelrow(index,data)
    self.Image_kuang["Panel_row"..index].Text_title:setString(data.name)
    self.Image_kuang["Panel_row"..index].Text_num:setString(data.num)
end

function ShenBingAutoCuiLianUI:setButtonsTouchEnabled(canTouch)
    local items = self.Image_kuang.ListView_item:getItems()
    for i,item in ipairs(items) do
        item.ButtonItem1:setTouchEnabled(canTouch)
        item.ButtonItem2:setTouchEnabled(canTouch)
        item.ButtonItem3:setTouchEnabled(canTouch)
        item.ButtonItem4:setTouchEnabled(canTouch)
        item.Image_select1.Text_selectName:setTouchEnabled(canTouch)
    end
    self.Button_confirm:setTouchEnabled(canTouch)
    self.Button_cancel:setTouchEnabled(canTouch)
end


function ShenBingAutoCuiLianUI:setTextCuiLianNum(text)
    self.Image_kuang.Text_cuiLianNum:setString(text)
end

function ShenBingAutoCuiLianUI:setTextCostJingNum(text)
    self.Image_kuang.Text_costJingNum:setString(text)
end

function ShenBingAutoCuiLianUI:setListViewItem(array)
    self.Image_kuang.ListView_item:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:__createPanelItem(v) 

        self.Image_kuang.ListView_item:pushBackCustomItem(panel)
    end

    local items = self.Image_kuang.ListView_item:getItems()
    for i,item in ipairs(items) do
        item:setLocalZOrder(#array + 1 - i)
    end
end

function ShenBingAutoCuiLianUI:refreshListViewItemButton(array)
    for index,v in ipairs(array) do
        local panel = self.Image_kuang.ListView_item:getItem(index-1)

        self:__setButtonRow(panel.ButtonItem1,v.buttonData1)

        self:__setButtonRow(panel.ButtonItem2,v.buttonData2)

        self:__setButtonRow(panel.ButtonItem3,v.buttonData3)

        self:__setButtonRow(panel.ButtonItem4,v.buttonData4)
    end
end

function ShenBingAutoCuiLianUI:refreshPanelItemNum(index,num)
    local panel = self.Image_kuang.ListView_item:getItem(index-1)
    
    panel.Text_itemNum:setString(num)
end

function ShenBingAutoCuiLianUI:refreshPanelItemSelectName(index,name)
    local panel = self.Image_kuang.ListView_item:getItem(index-1)
    
    panel.Image_select1.Text_selectName:setString(name)
end

function ShenBingAutoCuiLianUI:showPanelItemImageSelecet2(index,data)
    local panel = self.Image_kuang.ListView_item:getItem(index-1)
    
    panel.Image_select2:setVisible(true)

    panel.Image_select2.Text_name:setString(data.name)

    panel.Image_select2.Text_selectName1:setString(data.selectName1)

    panel.Image_select2.Text_selectName1:releaseFunc(function()
        panel.Image_select2:setVisible(false)
        data.selectFunc1()
    end)

    panel.Image_select2.Text_selectName2:setString(data.selectName2)

    panel.Image_select2.Text_selectName2:releaseFunc(function()
        panel.Image_select2:setVisible(false)
        data.selectFunc2()
    end)

    panel.Image_select2.Text_selectName3:setString(data.selectName3)

    panel.Image_select2.Text_selectName3:releaseFunc(function()
        panel.Image_select2:setVisible(false)
        data.selectFunc3()
    end)
end

function ShenBingAutoCuiLianUI:hidePanelItemImageSelecet2(index)
    local panel = self.Image_kuang.ListView_item:getItem(index-1)

    panel.Image_select2:setVisible(false)
end

function ShenBingAutoCuiLianUI:__createPanelItem(data)
    local panel = self.Panel_item:clone()

    Helper:convertUIByParent(panel)

    panel.Text_subTitle:setString(data.subTitle)
    
    panel.Text_itemNum:setString(data.itemNum)

    self:__setButtonRow(panel.ButtonItem1,data.buttonData1)

    self:__setButtonRow(panel.ButtonItem2,data.buttonData2)

    self:__setButtonRow(panel.ButtonItem3,data.buttonData3)

    self:__setButtonRow(panel.ButtonItem4,data.buttonData4)

    panel.Image_select1.Text_selectName:setString(data.selectName)

    panel.Image_select1.Text_selectName:releaseFunc(function()
        if data.selectFunc then
            data.selectFunc()
        end
    end)

    panel.Image_select2:setVisible(false)

    return panel
end

function ShenBingAutoCuiLianUI:__setButtonRow(row,data)
    row:loadTextureNormal(data.image)

    row:setTitleText(data.title)

    row:setTitleColor(data.titleColor)

    row:releaseFuncTotally(function()
        data.beganFunc()
    end,function()
        data.endedFunc()
    end,function()
        data.canceledFunc()
    end)
end

function ShenBingAutoCuiLianUI:setPanelBack(func)
    self.Panel_back:releaseFunc(function()
        if func then
            func()
        end
    end)
end


function ShenBingAutoCuiLianUI:setButtonConfirm(name,func)
    self.Button_confirm.Text_ButtonName:setString(name)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ShenBingAutoCuiLianUI:setButtonCancel(name,func)
    self.Button_cancel.Text_ButtonName:setString(name)
    self.Button_cancel:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return ShenBingAutoCuiLianUI000000000000
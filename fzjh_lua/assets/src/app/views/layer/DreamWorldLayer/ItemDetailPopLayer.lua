local ItemDetailPopLayer = class("ItemDetailPopLayer", LayerEx)

function ItemDetailPopLayer:create()
    local p = ItemDetailPopLayer:new()
    p:init()
    return p
end

function ItemDetailPopLayer:init()
    self._UI = require("Layer.Dialog.ItemDetailPopUI.lua").create()['root']
	self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setPanelBack()
end

function ItemDetailPopLayer:hideLayer()
    PopupLayerController:hideLayer("ItemDetailPopLayer",function (layer)
        layer:hide()
    end)
end

function ItemDetailPopLayer:showLayer(title,popList)
    self:setTitleText(title)
    self:initPopList(popList)
    self:show()
end

function ItemDetailPopLayer:initPopList(popList)
    self.ListView_1:removeAllItems()
    if MapIsEmpty(popList) then
        return
    end
   
    for i, v in ipairs(popList) do
        local item = Item:getOneItemByKey(v.itemId)

        if item ~= nil then
            local panel = self.ListView_1:getItem(i - 1)
            if panel == nil then
                panel = self.ItemInfoPanel:clone()
            end
            
            Helper:convertUIByParent(panel)

            panel.Text_Name:setColor({r = 184, g = 184, b = 184})

            panel.Text_Count:setColor({r = 184, g = 184, b = 184})

            panel.Text_Name:setString(Helper:getNoColorStr(item.name))

            panel.Text_Count:setString(v.count)
            
            self.ListView_1:pushBackCustomItem(panel)
        end
    end

    local row_count = #self.ListView_1:getItems()
    if row_count - #popList > 0  then
        for i=row_count-1,#popList,-1 do
            self.ListView_1:removeItem(i)
        end
    end
end

function ItemDetailPopLayer:setTitleText(title)
    self.Text_title:setString(title)
end

function ItemDetailPopLayer:setPanelBack(func)
    self.Panel_back:releaseFunc(function()
        if func then
            func()
        end
		self:hideLayer()
	end)
end

Helper:classDefNodeGetInstance(ItemDetailPopLayer)
return  ItemDetailPopLayer0000000000
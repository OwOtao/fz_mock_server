local ShowDetailListLayer = class("ShowDetailListLayer", LayerEx)

function ShowDetailListLayer:create()
    local p = ShowDetailListLayer:new()
    p:init()
    return p
end

function ShowDetailListLayer:init()
    local UI = require("Layer/Dialog/ShowDetailLIstUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)

    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

function ShowDetailListLayer:hideLayer()
    PopupLayerController:hideLayer(
        "ShowDetailListLayer",
        function(layer)
            layer:hide()
        end
    )
end

function ShowDetailListLayer:showLayer(title, showList)
    self:setTitle(title)
    self:showList(showList)
    self:show()
end

function ShowDetailListLayer:setTitle(title)
    title = Helper:getDef(title, "")

    self.Text_Title:setString(title)
end

function ShowDetailListLayer:showList(showList)
    self.ListView_Detail:removeAllItems() 
    for index, text in ipairs(showList) do
        local isNewView = index % 2 == 1 or true and false

        local textListView
        if isNewView then
            textListView = self.ListView_Item:clone()
            Helper:convertUIByParent(textListView)
            self.ListView_Detail:pushBackCustomItem(textListView)
        else
            textListView = self.ListView_Detail:getItem(math.ceil(index / 2) - 1)
        end

        local textItem = self.Text_Item:clone()
        textItem:setString(text)
        textListView:pushBackCustomItem(textItem)
    end
end

Helper:classDefNodeGetInstance(ShowDetailListLayer)
return ShowDetailListLayer
0
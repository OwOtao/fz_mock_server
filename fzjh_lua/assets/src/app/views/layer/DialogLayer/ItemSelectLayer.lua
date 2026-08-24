local ItemSelectLayer = class("ItemSelectLayer", cc.Layer)

function ItemSelectLayer:create()
    local p = ItemSelectLayer:new()
    p:init()
    return p
end

function ItemSelectLayer:init()
    self._UI = require("Layer/Dialog/ItemSelectUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setBack()
end

function ItemSelectLayer:showLayer()
    self:show()
end

function ItemSelectLayer:hideLayer()
    self:hide()
end

function ItemSelectLayer:setTitle(text)
    if text == nil then
        text = ""
    end

    self.Text_Title:setString(text)
end

--@desc: 设置列表数据
--@author:Liang SongQiang
--@time:2018-01-27 24:24:40
--@list:
function ItemSelectLayer:setList(list)
    self.Item_List:removeAllItems()
    local mod, remainder = math.modf(#list / 2)

    if math.ceil(remainder) == 1 then
        mod = mod + 1
    end

    local pList = {}
    for i = 1, mod do
        local panel = self.Panel_List:clone()
        Helper:convertUIByParent(panel)
        panel.Button_Left:setVisible(false)
        panel.Button_Right:setVisible(false)
        panel.Button_Left.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        panel.Button_Right.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        table.insert(pList, panel)
    end

    for index, data in ipairs(list) do
        local pListIndex = math.ceil(index / 2)
        local panel = pList[pListIndex]

        if index % 2 == 1 then
            panel.Button_Left:setVisible(true)
            panel.Button_Left.Text_name:setString(data.name)
            panel.Button_Left:releaseFunc(function ()
                self.btnFucn(data.itemId)
            end)
        elseif index % 2 == 0 then
            panel.Button_Right:setVisible(true)
            panel.Button_Right.Text_name:setString(data.name)
            panel.Button_Right:releaseFunc(function ()
                self.btnFucn(data.itemId)
            end)
        else
            assert(false,"代码有问题！！")
        end
    end

    for i,panel in ipairs(pList) do
        self.Item_List:pushBackCustomItem(panel)
    end
end

--@desc: 给选择按钮点击事件
--@author:Liang SongQiang
--@time:2018-01-27 10:43:49
--@func:
function ItemSelectLayer:setBtnClickFunc(func)
    self.btnFucn = func
end

function ItemSelectLayer:setBack()
    self.Panel_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "ItemSelectLayer",
                function(layer)
                    layer:hideLayer()
                end
            )
        end
    )
end

Helper:classDefNodeGetInstance(ItemSelectLayer)
return ItemSelectLayer
000000000000000
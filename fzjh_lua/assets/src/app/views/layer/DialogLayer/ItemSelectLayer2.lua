--@SuperType [src.app.views.base.LayerEx#LayerEx]
local ItemSelectLayer2 = class("ItemSelectLayer2", LayerEx)

function ItemSelectLayer2:create()
    local p = ItemSelectLayer2:new()
    p:init()
    return p
end

function ItemSelectLayer2:init()
    self._UI = require("Layer/Dialog/ItemSelectUI2.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setBack()
    
    self:setShowAndHideAnimType(self.ShowAndHideAnimType.FAST)
end

function ItemSelectLayer2:setBack()
    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

function ItemSelectLayer2:hideLayer()
    PopupLayerController:hideLayer(
        "ItemSelectLayer2",
        function(layer)
            layer:hide()
        end
    )
end

function ItemSelectLayer2:showLayer()
    self:show()
end

function ItemSelectLayer2:setTitle(text)
    if text == nil then
        text = ""
    end

    self.Text_Title:setString(text)
end

function ItemSelectLayer2:setDesc(text)
    if text == nil then
        text = ""
    end

    self.Text_desc:setString(text)
end

function ItemSelectLayer2:setList(list)
    --[[
        list = {
            {
                id = xx,
                name = xx,
                desc = xxxxxx
            },
            {
                id = xx,
                name = xx,
                desc = xxxxxx
            }
        }
    ]]
    self.ListView_Btn:removeAllItems()

    for i, data in ipairs(list) do
        local panel = self:createButton()

        panel.Button.Text_Name:setString(data.name)

        if data.desc ~= nil then
            panel.Text_Desc:setString(data.desc)
            panel.Text_Desc:setVisible(true)
        else
            panel.Text_Desc:setVisible(false)
        end

        panel.Button:releaseFunc(
            function()
                if self.btnFucn ~= nil and type(self.btnFucn) == "function" then
                    self.btnFucn(data.id)
                end
            end
        )

        self.ListView_Btn:pushBackCustomItem(panel)
    end
end

function ItemSelectLayer2:createButton()
    local panel = self.Panel_Btn:clone()

    Helper:convertUIByParent(panel)

    panel.Button.Text_Name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
    return panel
end

--@desc: 给选择按钮点击事件
--@author:Liang SongQiang
--@time:2018-01-27 10:43:49
function ItemSelectLayer2:setBtnClickFunc(func)
    self.btnFucn = func
end

Helper:classDefNodeGetInstance(ItemSelectLayer2)
return ItemSelectLayer2
0000
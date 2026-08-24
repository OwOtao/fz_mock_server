local ChuWuXiangReplaceLayer = class("ChuWuXiangReplaceLayer", LayerEx)

--@RefType [app.models.HomelandModel.FurnitureModel.StorageBox#StorageBox]
local StorageBox = require("app.models.HomelandModel.FurnitureModel.StorageBox")

local MAX_COUNT = StorageBox.getCanBuyMaxCount()

function ChuWuXiangReplaceLayer:create()
    local p = ChuWuXiangReplaceLayer:new()
    p:init()
    return p
end

function ChuWuXiangReplaceLayer:init()
    local UI = require("Layer/HomelandUI/ChuWuXiangReplaceUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)

    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

function ChuWuXiangReplaceLayer:hideLayer()
    PopupLayerController:hideLayer(
        "ChuWuXiangReplaceLayer",
        function(layer)
            layer._currRow = nil
            layer._currIndex = nil
            layer:hide()
        end
    )
end

--@desc: 成功购买后的回调
--@author:Liang SongQiang
--@time:2018-10-11 10:27:16
function ChuWuXiangReplaceLayer:setBuySuccessCallBack(callback)
    if type(callback) ~= "function" then
        return
    end

    self._successCallback = callback
end

--@author:Liang SongQiang
--@time:2018-10-10 21:01:43
--@chapman:[app.models.Chapman.CkChapman#CkChapman]
--@currIndex: 当前选中的index
function ChuWuXiangReplaceLayer:showLayer(chapman, currIndex)
    self._chapman = chapman

    self._currIndex = currIndex

    self:createListPanel()

    self:setButton()

    self:show()
end

function ChuWuXiangReplaceLayer:setName(name)
    self.Text_Name:setTextColor {r = 197, g = 197, b = 197}
    name = name or ""

    self.Text_Name:setString(name)
end

function ChuWuXiangReplaceLayer:setPrice(price)
    price = price or ""
    self.Text_price:setString(price)
end

function ChuWuXiangReplaceLayer:setDesc(desc)
    desc = desc or ""

    self.Text_Desc:setString(desc)
end

function ChuWuXiangReplaceLayer:setType(itemType)
    itemType = itemType or ""
    self.Text_Type:setString(itemType)
end

function ChuWuXiangReplaceLayer:setAffirm(desc)
    self.Text_affirm:setTextColor {r = 255, g = 255, b = 255}
    desc = desc or ""
    self.Text_affirm:setString(desc)
end

function ChuWuXiangReplaceLayer:setListPanelTitle(name)
    name = name or ""
    self.Panel_Replace.Text_Title:setString(name)
end

function ChuWuXiangReplaceLayer:createListPanel()
    local num = self._chapman:getNowBoxNum()

    if num < MAX_COUNT then
        self.Panel_Replace:setVisible(false)
        return
    end

    self.Panel_Replace:setVisible(true)
    local list = self._chapman:getNowBoxList()

    for index, item in ipairs(list) do
        local row = self.Panel_Replace.ListView_Replace:getItem(index - 1)

        if row == nil then
            row = self:createListRow()
            self.Panel_Replace.ListView_Replace:pushBackCustomItem(row)
        end

        row.Text_Name:setString(item.name)

        row.Text_Name:setTextColor {r = 135, g = 135, b = 136}

        row.Image_tiao:setVisible(false)

        row:releaseFunc(
            function()
                if self._currRow ~= nil then
                    self._currRow.Text_Name:setFontSize(50)
                    self._currRow.Text_Name:setTextColor {r = 135, g = 135, b = 136}
                    self._currRow.Image_tiao:setVisible(false)
                end

                row.Text_Name:setFontSize(53)
                row.Text_Name:setTextColor {r = 211, g = 209, b = 69}
                row.Image_tiao:setVisible(true)
                self._currRow = row

                self._replaceIndex = index
            end
        )
    end

    local itemCount = #list
    local listCount = #self.Panel_Replace.ListView_Replace:getItems()
    if listCount - itemCount > 0 then
        for i = listCount - 1, itemCount, -1 do
            self.Panel_Replace.ListView_Replace:removeItem(i)
        end
    end
end

function ChuWuXiangReplaceLayer:createListRow()
    local row = self.Panel_Row:clone()
    Helper:convertUIByParent(row)
    return row
end

function ChuWuXiangReplaceLayer:setButton()
    self.Button_1:releaseFunc(
        function()
            if self._chapman:getNowBoxNum() >= MAX_COUNT and self._replaceIndex == nil then
                PopText("你的储物箱数量已达上限，请选择要替换的储物箱。")
                return
            end

            if self._chapman:getNowBoxNum() >= MAX_COUNT and self._chapman:checkIsReplaceSameItem(self._currIndex, self._replaceIndex) then
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

                local dialog = DialogALayer:getInstance()

                dialog:show("当前储物箱已满，购买同名储物箱并不会扩展储存空间，请确认是否要购买？")

                dialog:setButton1("确定", function()
                    self._chapman:buyAndRelace(
                        self._currIndex,
                        self._replaceIndex,
                        function()
                            self:hideLayer()
                        end
                    )
                end)

                dialog:setButton2("取消", function()
                    dialog:hide()
                end)

                dialog:setWeChatVisible(false)
                return
            end

            self._chapman:buyAndRelace(
                self._currIndex,
                self._replaceIndex,
                function()
                    self:hideLayer()
                end
            )
        end
    )

    self.Button_2:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

Helper:classDefNodeGetInstance(ChuWuXiangReplaceLayer)
return ChuWuXiangReplaceLayer
0000
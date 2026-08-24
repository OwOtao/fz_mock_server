--@SuperType [app.views.base.LayerEx#LayerEx]
local ChuWuXiangSalesLayer = class("ChuWuXiangSalesLayer", LayerEx)

local PRICE_UINIT_NAME = {
    money = "碎银",
    yinpiao = "银票"
}

function ChuWuXiangSalesLayer:create()
    local p = ChuWuXiangSalesLayer:new()
    p:init()
    return p
end

function ChuWuXiangSalesLayer:init()
    self._UI = require("Layer/MapUI/MapBagUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

end

function ChuWuXiangSalesLayer:hideLayer()
    PopupLayerController:hideLayer(
        "ChuWuXiangSalesLayer",
        function(layer)

            if layer._handle then
                layer:unschedule(layer._handle)
            end

            layer:hide()
        end
    )
end

function ChuWuXiangSalesLayer:showLayer(chapman)
    --@RefType [app.models.Chapman.CkChapman#CkChapman]
    self._chapman = chapman

    self:createLeftList()

    self:initButtons()

    self:refresh()

    self._handle = self:schedule(function ()
        if self._chapman and self._chapman:getNeedRefresh() == true then
            self:refresh()
        end
    end,0.05)

    self:show()
end

function ChuWuXiangSalesLayer:refresh()
    self:createRightList()

    self:setMoney()

    self:refreshWeight()
end

function ChuWuXiangSalesLayer:refreshWeight()
    self.Text_desc1:setString("仓库容量")
    local role = User:getRole()
    local ckLimit = #role:getckItems() .. "/" .. role:getAttr("ckLimit")
    self.Text_weight:setString(ckLimit)
end

function ChuWuXiangSalesLayer:createLeftList()
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local items = role:getItems()

    for index, item in ipairs(items) do
        local row = self.ListView_1:getItem(index - 1)

        if not row then
            row = self.Panel_item1:clone()
            self.ListView_1:pushBackCustomItem(row)
            Helper:convertUIByParent(row)
        end

        local itemAttr = Item:getOneItemByKey(item.itemId)

        row.Text_name:setTextColor({r = 255, g = 255, b = 255})
        if item.count > 1 then
            row.Text_name:setString(itemAttr.name .. " X" .. item.count)
        else
            row.Text_name:setString(itemAttr.name)
        end

        row:releaseFunc(
            function()
                PopText("此处不可出售道具。")
            end
        )
    end

    local itemCount = #items
    local listCount = #self.ListView_1:getItems()
    if listCount - itemCount > 0 then
        local removePosition = listCount - itemCount
        for i = listCount - 1, itemCount, -1 do
            self.ListView_1:removeItem(i)
        end
    end
end

--@desc 创建销售列表
function ChuWuXiangSalesLayer:createRightList()
    local sellItems = self._chapman:getSellerItems()

    for index, sellItem in ipairs(self._chapman:getSellerItems()) do
        local row = self.ListView_2:getItem(index - 1)

        if not row then
            row = self.Panel_item2:clone()
            self.ListView_2:pushBackCustomItem(row)
            Helper:convertUIByParent(row)
        end

        row.Text_name:setString(sellItem.name)

        row.Text_num:setString(sellItem.price .. " " .. PRICE_UINIT_NAME[sellItem.unit])

        row:releaseFunc(
            function()
                PopupLayerController:showLayer(
                    "ChuWuXiangReplaceLayer",
                    function(layer)
                        layer:setName(sellItem.name)

                        local desc = sellItem.desc

                        local addCount = sellItem.addCount

                        desc = desc .. "购买后可让仓库容量上限+" .. addCount

                        layer:setDesc(desc)

                        layer:setType("储物箱")

                        layer:setPrice("售价：" .. sellItem.price .. PRICE_UINIT_NAME[sellItem.unit])

                        layer:setAffirm("你确定购买"..sellItem.name.."吗？")

                        layer:showLayer(self._chapman,index)
                    end
                )
            end
        )
    end

    local itemCount = #sellItems
    local listCount = #self.ListView_2:getItems()
    if listCount - itemCount > 0 then
        local removePosition = listCount - itemCount
        for i = listCount - 1, itemCount, -1 do
            self.ListView_2:removeItem(i)
        end
    end
end

function ChuWuXiangSalesLayer:initButtons()
    local createBtn = function()
        local roleButton = Resource:getUIByName("Button_4")
        Helper:convertUI(roleButton)
        roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
        return roleButton
    end
    local button_right = createBtn()
    self:addChild(button_right)
    button_right:move(cc.p(810, 200))
    button_right:setVisible(true)
    button_right.Text_buttonName:setString("确定")
    button_right:releaseFunc(
        function()
            Audio:playEffect("xiaoAnNiu")
            self:hideLayer()
        end
    )
end

function ChuWuXiangSalesLayer:setMoney()
    local text = ""

    local unitName = PRICE_UINIT_NAME[self._chapman:getSellerUnit()] or "银票"

    text = text .. unitName .. "：" .. self._chapman:getNowPoint()

    self.Text_money:setVisible(true)

    self.Text_money:setString(text)
end

Helper:classDefNodeGetInstance(ChuWuXiangSalesLayer)
return ChuWuXiangSalesLayer
0000000000
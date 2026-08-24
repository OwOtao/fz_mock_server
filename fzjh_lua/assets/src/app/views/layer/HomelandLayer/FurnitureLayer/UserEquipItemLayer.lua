local UserEquipItemLayer = class("UserEquipItemLayer", cc.Layer)

--@RefType [app.models.ShenBing.ShenBingDesc#ShenBingDesc]
local ShenBingDesc = require("app.models.ShenBing.ShenBingDesc")
local HomeLandDesc = require("app.models.HomelandModel.HomelandDesc")

function UserEquipItemLayer:create()
    local p = UserEquipItemLayer:new()
    p:init()
    return p
end

function UserEquipItemLayer:init()
    self._UI = require("Layer/ShenBing/XuanBingDong.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self.Panel_item:setVisible(false)
    self.Panel_Dsc_back:setVisible(false)
    self.Text_NeiLi:setVisible(false)
    self.Text_Gold:setVisible(false)
    self.Button_FangRu:setVisible(false)
end

--@desc:显示列表
--@author:Liang SongQiang
--@time:2018-06-11 21:08:00
--@data:对方悬兵洞、藏衣阁数据
--@collectSocre:武藏积分
--@userId: 对方的mid
function UserEquipItemLayer:showLayer(itemList, collectSocre, userId)
    self.Text_desc:move(cc.p(540,1650))
    self.Text_desc:setString(HomeLandDesc:getQiangBiDesc(ShenBingDesc:getCollectScore(collectSocre)))
    self.itemIdList = {}

    self:initList(itemList)

    self:showItemList()
    self:show()
end

--@desc: 服务器数据
--@author:Liang SongQiang
--@time:2018-06-11 21:22:55
function UserEquipItemLayer:initList(itemList, userId)
    if MapIsEmpty(itemList) then
        return
    end

    for k, v in pairs(itemList) do
        if v.total > 1 then
            print("========================================", v.itemId, v.total)
            v.total = 1
        end

        local isShenBing = string.find(v.itemId, "weapon_")
        if isShenBing then
        else
            table.insert(self.itemIdList, {itemId = v.itemId, update_time = v.update_time})
        end
    end
end

function UserEquipItemLayer:showItemList()
    if MapIsEmpty(self.itemIdList) then
        self.ListView_item:removeAllItems()
        return
    end
    local listViewItems = self.ListView_item:getItems()
    local removeCount = 0
    if #listViewItems > #self.itemIdList then
        removeCount = #listViewItems - #self.itemIdList
    end

    table.sort(
        self.itemIdList,
        function(a, b)
            return a.update_time < b.update_time
        end
    )

    for i,v in ipairs(self.itemIdList) do
        local itemAttr = Item:getOneItemByKey(v.itemId)

        if itemAttr then
            local row = self.ListView_item:getItem(i - 1)

            if not row then
                row = self:getItemPanel()
                self.ListView_item:pushBackCustomItem(row)
            end
            row.Image_tiao.Text_name:setColor(cc.c3b(208, 208, 208))
            row.Image_tiao.Text_name:setString(itemAttr.name)
            row.Item_count:setString("伤害力+" .. tostring(Helper:mathFloor(itemAttr.damage)))
            row.Item_type:setString(itemAttr.type)
            row:releaseFunc(
                function()
                    -- PopText("点击:"..itemAttr.name)
                    self:clickOneItem(v, itemAttr)
                end
            )
        else
            print("itemAttr 不存在。。。。。。。。。",v.itemId)
        end

    end


    if removeCount > 0 then
        local removeIndex = #self.itemIdList
        for i = #listViewItems - 1, removeIndex, -1 do
            self.ListView_item:removeItem(i)
        end
    end
end


function UserEquipItemLayer:clickOneItem(item, itemAttr)
    if not item and type(item) ~= "table" then
        print("item 传值出错")
        return
    end

    local itemDesc = self.Panel_Dsc_back.Panel_itemDesc

    self.Panel_Dsc_back.Panel_Detail_Back:releaseFunc(
        function()
            self:itemDescHide(true)
        end
    )

    self:itemDescShow(true)
    itemDesc.Image_back.Panel_title.Text_name:setColor(cc.c3b(208, 208, 208))
    itemDesc.Image_back.TextField_desc:setString(itemAttr:getDsc())
    itemDesc.Image_back.Panel_title.Text_name:setString(itemAttr.name)
    local wpType = itemAttr.wpType or itemAttr.type
    itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(wpType)
    itemDesc.Image_back.Image_button:setTouchEnabled(true)
    itemDesc.Image_back:setTouchEnabled(true)
    --弹出框 神兵从悬兵洞 取下 按钮
    itemDesc.Image_back.Image_button:setVisible(false)

    ---弹出框 神器详情
    itemDesc.Image_back.Image_button_info:setTouchEnabled(true)
    itemDesc.Image_back:setTouchEnabled(true)
    itemDesc.Image_back.Image_button_info:releaseFunc(
        function()
            self:itemDescHide(true)

            local ItemDescInfo = require("app.models.item.ItemDescInfo")
            local weaponInfo = ItemDescInfo:getNormalWeaponDescInfo(itemAttr, false)

            PopupLayerController:showLayer(
                "WeaponDescInfoPresenter",
                function(layer)
                    layer:setData(weaponInfo)
                    layer:showLayer()
                end
            )
        end
    )
end

--@desc: 创建list的item
--@author:Liang SongQiang
--@time:2018-02-27 10:18:19
function UserEquipItemLayer:getItemPanel()
    local row = self.Panel_item:clone()
    Helper:convertUIByParent(row)
    row:setVisible(true)
    row:setTouchEnabled(true)
    row.Image_tiao.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Item_count:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Item_type:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)

    return row
end

-- 物品描述显示
function UserEquipItemLayer:itemDescShow(anim)
    self.Panel_Dsc_back.Panel_itemDesc:setTouchEnabled(true)
    self.Is_show = true
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
function UserEquipItemLayer:itemDescHide(anim)
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
                self.Is_show = false
                self:setLocalZOrder(0)
                self.Panel_Dsc_back:setVisible(false)
            end
        )
    )
    action:setTag(actionTag)
    panel:runAction(action)
end

return UserEquipItemLayer
0000
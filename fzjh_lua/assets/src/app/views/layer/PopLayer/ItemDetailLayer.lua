local ItemDetailLayer = class("ItemDetailLayer", cc.Layer)

function ItemDetailLayer:create()
    local p = ItemDetailLayer:new()
    p:init()
    return p
end

local _item = {}

function ItemDetailLayer:init()
    self._UI = require("Layer/PopUI/ItemDetailUI").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self:setItemDescTwo()
    self:setRightBtn()
    self:setLeftBtn()
    self:setItemDescSize()
    self:setItemType()
    self:setBack()
end

--@desc: 弹出窗口
--@author:Liang SongQiang
--@time:2018-01-05 15:58:19
--@itemData: item 信息
--@func: show的动画播放完后执行的函数
function ItemDetailLayer:showLayer(itemData, func)
    self.Panel_bg:setVisible(true)

    _item = itemData
    self.Panel_ItemDetail.Image_back.Panel_title.Text_name:setColor(cc.c3b(208, 208, 208))
    self.Panel_ItemDetail.Image_back.Panel_title.Text_name:setString(_item.name)

    self:setLayerSize()

    local Panel_ItemDetail = self.Panel_ItemDetail
    Panel_ItemDetail:setVisible(true)
    local actionTag = Panel_ItemDetail:getActionTagByName("move")
    Panel_ItemDetail:stopActionByTag(actionTag)
    Panel_ItemDetail:move(cc.p(380, 1710))
    local startTime = GetTime()
    local action =
        cc.Sequence:create(
        cc.Spawn:create(cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1540)), cc.FadeIn:create(UI_ANIM_DURATION)),
        cc.CallFunc:create(
            function()
                Panel_ItemDetail:setTouchEnabled(true)
                if func and type(func) == "function" then
                    func()
                end
            end
        )
    )
    action:setTag(actionTag)
    Panel_ItemDetail:runAction(action)
end

--@desc: 隐藏弹窗
--@author:Liang SongQiang
--@time:2018-01-08 11:46:53
function ItemDetailLayer:hideLayer()
    self.Panel_ItemDetail:setTouchEnabled(false)
    local Panel_ItemDetail = self.Panel_ItemDetail
    local actionTag = Panel_ItemDetail:getActionTagByName("move")
    Panel_ItemDetail:stopActionByTag(actionTag)
    Panel_ItemDetail:move(cc.p(380, 1540))
    local action =
        cc.Sequence:create(
        cc.Spawn:create(cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380.00, 1710.00)), cc.FadeOut:create(UI_ANIM_DURATION)),
        cc.CallFunc:create(
            function()
                Panel_ItemDetail:setVisible(false)
                self.Panel_bg:setVisible(false)
            end
        )
    )
    action:setTag(actionTag)
    Panel_ItemDetail:runAction(action)
end

--@desc: 设置描述框高度和字体大小
--@author:Liang SongQiang
--@time:2018-01-05 17:46:21
--@sizeTable: {font = 42,contentSize = 201.91}
function ItemDetailLayer:setItemDescSize(sizeTable)
    if sizeTable == nil then
        sizeTable = {}
    end
    local fontSize = tonumber(sizeTable.font) or 42
    local contentSize = tonumber(sizeTable.contentSize) or 201.91
    self.Panel_ItemDetail.Image_back.TextField_desc:setContentSize({width = 610.6300, height = contentSize})
    self.Panel_ItemDetail.Image_back.TextField_desc:setFontSize(fontSize)
end

--@desc: 设置描述信息
--@author:Liang SongQiang
--@time:2018-01-05 17:36:11
--@text: 描述信息
function ItemDetailLayer:setItemDesc(text)
    if text == nil then
        text = ""
    end

    if type(text) ~= "string" then
        assert(false, "ItemDetailLayer:setItemDesc() : arg1 type is wrong,check the code")
        return
    end

    self.Panel_ItemDetail.Image_back.TextField_desc:setString(text)
end

--@desc: 设置描述框下面的特殊描述标题
--@author:Liang SongQiang
--@time:2018-01-05 17:51:24
function ItemDetailLayer:setItemDescTwo(text)
    if text == nil then
        text = ""
    end

    if type(text) ~= "string" then
        assert(false, "ItemDetailLayer:setItemDesc() : arg1 type is wrong,check the code")
        return
    end

    self.Panel_ItemDetail.Image_back.Text_desc2:setString(text)
end

--@desc: 显示itemType
--@author:Liang SongQiang
--@time:2018-01-12 15:56:17
function ItemDetailLayer:setItemType(itemType)
    if not itemType then
        itemType = ""
    end
    self.Panel_ItemDetail.Image_back.Panel_title.Text_type:setString(itemType)
end

local componentMargin = 5

--@desc: 设置描述界面的size
--@author:Liang SongQiang
--@time:2018-01-05 15:57:15
function ItemDetailLayer:setLayerSize()
    local childs = self.Panel_ItemDetail.Image_back:getChildren()


    --@desc 标题
    local Panel_title = self.Panel_ItemDetail.Image_back.Panel_title
    --@desc 距离顶部21像素
    local tHeight = Panel_title:getContentSize().height + 21

    --@desc 物品描述
    local TextField_desc = self.Panel_ItemDetail.Image_back.TextField_desc
    --@desc 距离标题panel的像素为10
    local tfHeight = TextField_desc:getContentSize().height + 10

    --@desc 物品特殊描述
    local Text_desc2 = self.Panel_ItemDetail.Image_back.Text_desc2
    --@desc 距离物品描述panel的像素为10
    local tdHeight = Text_desc2:getContentSize().height + 10

    --@desc 列表描述
    local ListView_Detial = self.Panel_ItemDetail.Image_back.ListView_Detial
    local listHeight = 0
    --@desc 距离物品特殊描述panel的像素为10
    for i, v in ipairs(ListView_Detial:getItems()) do
        if i < 4 then
            listHeight = listHeight + v:getContentSize().height + ListView_Detial:getItemsMargin()
            ListView_Detial:setContentSize(610.63, listHeight)
        else
            ListView_Detial:setClippingEnabled(true)
            ListView_Detial:setContentSize(610.63, listHeight + 20)
            break
        end
    end
    listHeight = ListView_Detial:getContentSize().height + 10

    --@desc 按钮panel
    local Panel_Button = self.Panel_ItemDetail.Image_back.Panel_Button
    local btnHeight = Panel_Button:getContentSize().height + 25
    --@desc 按钮panel 应该固定在底部
    Panel_Button:setPosition(0, 5)

    local ImageHeight = tHeight + tfHeight + tdHeight + listHeight + btnHeight
    if ImageHeight < 668 then
        ImageHeight = 668
    end
    local Image_back = self.Panel_ItemDetail.Image_back
    Image_back:setContentSize(644, ImageHeight)

    Panel_title:setPosition(0, ImageHeight - tHeight)

    TextField_desc:setPosition(20, ImageHeight - tHeight - tfHeight)

    Text_desc2:setPosition(20, ImageHeight - tHeight - tfHeight - tdHeight)

    ListView_Detial:setPosition(20, ImageHeight - tHeight - tfHeight - tdHeight - listHeight)
end

--@desc: 添加Row 到ListView
--@author:Liang SongQiang
--@time:2018-01-05 17:20:45
function ItemDetailLayer:addRowToListView(row)
    if row == nil then
        return
    end
    self.Panel_ItemDetail.Image_back.ListView_Detial:pushBackCustomItem(row)
end

--@desc: 获取材料类型的Panel UI
--@author:Liang SongQiang
--@time:2018-01-05 17:19:03
function ItemDetailLayer:getRowOfMedicinals()
    local row = self.Panel_3:clone()
    Helper:convertUIByParent(row)
    return row
end

--@desc: 清空list
--@author:Liang SongQiang
--@time:2018-01-08 17:17:50
function ItemDetailLayer:clearListView()
    self.Panel_ItemDetail.Image_back.ListView_Detial:setContentSize(0, 0)
    self.Panel_ItemDetail.Image_back.ListView_Detial:removeAllItems()
end

--@desc: 设置右边按钮背景图片
--@author:Liang SongQiang
--@time:2018-01-05 18:25:13
--@path: 图片路径
function ItemDetailLayer:setRightBtnImage(path)
    path = path or "Image/UI/AttrUI/xiaoanniu.png"
    self.Panel_ItemDetail.Image_back.Panel_Button.RightBtn:loadTexture(path, 0)
end

--@desc: 设置左边按钮背景图片
--@author:Liang SongQiang
--@time:2018-01-05 18:25:13
--@path: 图片路径
function ItemDetailLayer:setLeftBtnImage(path)
    path = path or "Image/UI/AttrUI/xiaoanniu.png"
    self.Panel_ItemDetail.Image_back.Panel_Button.LeftBtn:loadTexture(path, 0)
end

--@desc: 设置右边btn
--@author:Liang SongQiang
--@time:2018-01-05 16:39:37
function ItemDetailLayer:setRightBtn(name, clickFun)
    if clickFun == nil or name == nil or name == "" then
        self.Panel_ItemDetail.Image_back.Panel_Button.RightBtn:setVisible(false)
        return
    end

    if type(clickFun) ~= "function" then
        assert(false, "setRightBtn arg2 : clickFun type is wrong,check the code!")
        return
    end

    self.Panel_ItemDetail.Image_back.Panel_Button.RightBtn.Text_Right:setString(name)
    self.Panel_ItemDetail.Image_back.Panel_Button.RightBtn:setVisible(true)
    self.Panel_ItemDetail.Image_back.Panel_Button.RightBtn:releaseFunc(
        function()
            clickFun(_item)
        end
    )
end

--@desc: 设置左边btn
--@author:Liang SongQiang
--@time:2018-01-05 16:39:37
function ItemDetailLayer:setLeftBtn(name, clickFun)
    if clickFun == nil or name == nil or name == "" then
        self.Panel_ItemDetail.Image_back.Panel_Button.LeftBtn:setVisible(false)
        return
    end

    if type(clickFun) ~= "function" then
        assert(false, "setLeftBtn() arg2 : clickFun type is wrong,check the code!")
        return
    end

    self.Panel_ItemDetail.Image_back.Panel_Button.RightBtn.Text_Left:setString(name)
    self.Panel_ItemDetail.Image_back.Panel_Button.LeftBtn:setVisible(true)
    self.Panel_ItemDetail.Image_back.Panel_Button.LeftBtn:releaseFunc(
        function()
            clickFun(_item)
        end
    )
end

function ItemDetailLayer:setBack()
    self.Panel_bg:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "ItemDetailLayer",
                --@layer: [app.views.layer.PopLayer.ItemDetailLayer#ItemDetailLayer]
                function(layer)
                    layer:hideLayer()
                end
            )
        end
    )

    self.Panel_ItemDetail.Image_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "ItemDetailLayer",
                --@layer: [app.views.layer.PopLayer.ItemDetailLayer#ItemDetailLayer]
                function(layer)
                    layer:hideLayer()
                end
            )
        end
    )
end

Helper:classDefNodeGetInstance(ItemDetailLayer)
return ItemDetailLayer
00
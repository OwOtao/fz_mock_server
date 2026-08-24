--新神兵铁匠  藏衣阁界面

local CangYiGe = class("CangYiGe", cc.Layer)
--@RefType [src.app.models.ShenBing.CangYiGeModel#CangYiGeModel]
local CangYiGeModel = require("app.models.ShenBing.CangYiGeModel")

function CangYiGe:create()
    local p = CangYiGe:new()
    p:init()
    return p
end

function CangYiGe:init()
    self._UI = require("Layer/ShenBing/XuanBingDong.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self.Panel_item:setVisible(false)
    self.Panel_Dsc_back:setVisible(false)
end

local _currCollectType
local CKTYPE = "cangyige"
function CangYiGe:show(inRoom, desc)
    if inRoom then
        self._inRoom = true
        self:setTitleText(desc)
    else
        self._inRoom = false
        self:setTitleText()
    end

    if not CangYiGeModel:getInstance():isInit() then
        CangYiGeModel:getInstance():getListFromServer(
            function()
                self:setNeiLiAndGold()
                self:__showItemList()
                self:ButtonAddShenBing()
            end
        )
    else
        self:setNeiLiAndGold()
        self:__showItemList()
        self:ButtonAddShenBing()
    end
end

function CangYiGe:setTitleText(text)
    if not text then
        text = "这里是藏衣阁，这里空气干燥，周遭全是紫檀木所铸衣柜，可用来存放衣服饰品。"
    end

    self.Text_desc:setString(text)
end

function CangYiGe:__dealWithShowItemsData()
    local _show_item_infos = {}

    local xItems = CangYiGeModel:getInstance():getCangYiGeList()

    if MapIsEmpty(xItems) == false then
        local needRemoveItems = {}
        for _, itemData in ipairs(xItems) do
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local itemAttr = Item:getOneItemByKey(itemData.itemId)

            if itemAttr == nil then
                goto __continue__
            end

            local _item_info = {}
            _item_info._color = cc.c3b(208, 208, 208)
            _item_info._name = itemAttr.name
            _item_info._protect = "保护力+" .. tostring(Helper:mathFloor(itemAttr.protect))
            _item_info._type = itemAttr.type
            _item_info._func = function()
                self:clickOneItem(itemData, itemAttr)
            end
            table.insert(_show_item_infos, _item_info)

            ::__continue__::
        end
    end

    return _show_item_infos
end

function CangYiGe:__initPanelInfo(panel, panelInfo)
    if MapIsEmpty(panelInfo) == false then
        panel.Image_tiao.Text_name:setColor(panelInfo._color)
        panel.Image_tiao.Text_name:setString(panelInfo._name)
        panel.Item_count:setString(panelInfo._protect)
        panel.Item_type:setString(panelInfo._type)
        panel:releaseFunc(
            function()
                if panelInfo._func then
                    panelInfo._func()
                end
            end
        )
    end
end

function CangYiGe:__showItemList()
    self.ListView_item:setVisible(false)

    self.ListView_item:setSwallowTouches(false)

    local showItemsInfo = self:__dealWithShowItemsData()
    if MapIsEmpty(showItemsInfo) then
        self.ListView_item:removeAllItems()
        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end
        return
    end

    local roleItemNum = #showItemsInfo
    local listSize = self.ListView_item:getContentSize()
    local itemSize = self.Panel_item:getContentSize()
    local itemsMargin = self.ListView_item:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height / (itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

    self.ListView_item:setItemHeight(itemSize.height)

    self.ListView_item:setItemInitFunc(
        function(item, info)
            self:__initPanelInfo(item, info)
        end
    )

    self.ListView_item:setItemCreateFunc(
        function()
            return self:getItemPanel()
        end
    )

    self.ListView_item:showListView(showItemsInfo, itemMaxCount)

    self.ListView_item:setVisible(true)

    if isSchedule then
        if self._lastContentPos then
            if self._lastContentPos.y > self.ListView_item:getInnerContainerPosition().y then
                self.ListView_item:setInnerContainerPosition(self._lastContentPos)
            end
        else
            self.ListView_item:jumpToTop()
        end

        local isTrue = self.ListView_item:refreshReuseItems()
        while isTrue do
            isTrue = self.ListView_item:refreshReuseItems()
        end

        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end

        self.listViewSchedule =
            self:schedule(
            function()
                self.ListView_item:refreshReuseItems()
                self._lastContentPos = self.ListView_item:getLastInnerContainerPosition()
            end
        )
    end
end

function CangYiGe:clickOneItem(item, itemAttr)
    if not item or type(item) ~= "table" then
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
    itemDesc.Image_back.TextField_desc:setString(itemAttr:getDsc())
    itemDesc.Image_back.Panel_title.Text_name:setColor(cc.c3b(208, 208, 208))
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
            local armorInfo = ItemDescInfo:getArmorDescInfo(itemAttr)

            PopupLayerController:showLayer(
                "ArmorDescInfoPresenter",
                function(layer)
                    layer:setData(armorInfo)
                    layer:showLayer()
                end
            )
        end
    )
end

--@desc 出库
function CangYiGe:rightListFunc(item, func)
    CangYiGeModel:getInstance():outItem(
        item.itemId,
        function()
            self:uploadUserCollectScore()

            if func then
                func()
            end
        end
    )
end

--@desc 入库
function CangYiGe:leftListFunc(item, func)
    CangYiGeModel:getInstance():putItem(
        item,
        function()
            self:uploadUserCollectScore()
            if func then
                func()
            end
        end
    )
end

function CangYiGe:ButtonAddShenBing()
    self.Button_FangRu:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
    self.Button_FangRu:releaseFunc(
        function()
            if self.listViewSchedule then
                self:unschedule(self.listViewSchedule)
                self.listViewSchedule = nil
            end
            PopupLayerController:showLayer(
                "NewShenBingBagLayer",
                function(layer)
                    layer:btnLeftClickFunc()

                    layer:setConditionPushRightFunc(
                        function(item) --从左向右放
                            if User:getRole():checkItemIsEquip(item.onlyid) == true then
                                PopText("请先将防具脱下")
                                return false
                            end

                            if CangYiGeModel:getInstance():queryItemCount(item.itemId) > 0 then
                                PopText("同一件装备只能收藏一件")
                                return false
                            end

                            local itemAttr = Item:getOneItemByKey(item.itemId)
                            if itemAttr and itemAttr.shoucang ~= 1 then
                                PopText("该防具不能收藏")
                                return false
                            end
                            return true
                        end
                    )

                    layer:setConditionPushLeftFunc(
                        function(item) --从右向左放
                            if User:getRole():checkCanBuyThings(item.itemId, 1) == false then
                                PopText("背包空间不足")
                                return false
                            end

                            return true
                        end
                    )

                    layer:btnRightClickFunc(
                        function()
                            self:__showItemList()
                            self:setNeiLiAndGold()
                            layer:destory()
                        end,
                        "确定"
                    )

                    local function setRightItems()
                        local xItems = CangYiGeModel:getInstance():getCangYiGeList()
                        if not MapIsEmpty(xItems) then
                            local rightItemsInfo = {}
                            for index, itemData in ipairs(xItems) do
                                local data = {
                                    itemId = itemData.itemId,
                                    update_time = itemData.update_time
                                }

                                local itemInfo = Item:getOneItemByKey(itemData.itemId)

                                data.name = itemInfo.name

                                table.insert(rightItemsInfo, data)
                            end

                            layer:setRightItemsInfo(rightItemsInfo)
                        else
                            layer:setRightItemsInfo()
                        end
                    end

                    local function setLeftItems()
                        local bItems =
                            User:getRole():getItems(
                            function(item)
                                local itemData = Item:getOneItemByKey(item.itemId)
                                local list = {
                                    ["head"] = true,
                                    ["cloth"] = true,
                                    ["pants"] = true,
                                    ["belt"] = true,
                                    ["hand"] = true,
                                    ["shoes"] = true,
                                    ["necklace"] = true,
                                    ["ring"] = true,
                                    ["yaozhui"] = true
                                }
                                if itemData.equipPart ~= nil and itemData.equipPart ~= "" then
                                    if list[itemData.equipPart] == true then
                                        return true
                                    end
                                end
                                return false
                            end
                        )

                        if not MapIsEmpty(bItems) then
                            local leftItemsInfo = {}
                            for i, itemData in ipairs(bItems) do
                                local data = {
                                    onlyid = itemData.id,
                                    itemId = itemData.itemId
                                }

                                local itemInfo = Item:getOneItemByKey(itemData.itemId)

                                data.name = itemInfo.name

                                table.insert(leftItemsInfo, data)
                            end
                            layer:setLeftItemsInfo(leftItemsInfo)
                        else
                            layer:setLeftItemsInfo()
                        end
                    end

                    setRightItems()

                    setLeftItems()

                    layer:setAfterPushFunc(
                        function()
                            setRightItems()
                            setLeftItems()
                        end
                    )

                    layer:setOutGoingCKFunc(
                        function(item, func)
                            self:leftListFunc(item, func)
                        end
                    )

                    layer:setBePutCKFunc(
                        function(item, func)
                            self:rightListFunc(item, func)
                        end
                    )

                    layer:refreshUI()
                    layer:setRightName("藏衣阁")
                    layer:showLayer()
                end
            )
        end
    )
end

--设置内力和金钱数值
function CangYiGe:setNeiLiAndGold()
    local role = User:getRole()
    local neili, neiliMax = math.ceil(role:getAttr("neili")), math.ceil(role:getFinalAttr("neiliMax"))
    local gold = role:getAttr("gold")
    _currCollectType = ShenBingDesc:getRoleCollectDesc(User:getRole())
    self.Text_NeiLi:setString("『内力』" .. tostring(neili) .. "/" .. tostring(neiliMax))
    self.Text_Gold:setString("『收藏评价』" .. _currCollectType)
end

function CangYiGe:getItemPanel()
    local row = self.Panel_item:clone()
    Helper:convertUIByParent(row)
    row:setVisible(true)
    row:setTouchEnabled(true)
    row.Image_tiao.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Item_count:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Item_type:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)

    return row
end

function CangYiGe:setItemBack(state, row)
    if type(state) ~= "boolean" then
        return
    end
    if not row then
        local index = self.ListView_item:getCurSelectedIndex()
        row = self.ListView_item:getItem(index)
    end
    row.Image_back:setVisible(state)
end

-- 物品描述显示
function CangYiGe:itemDescShow(anim)
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
function CangYiGe:itemDescHide(anim)
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

--计算藏衣阁中兵器的收藏积分
function CangYiGe:addCangYiGeScore(flag, itemId)
    local itemAttr = Item:getOneItemByKey(itemId)
    if itemAttr and itemAttr.shoucang == 1 then
        if flag == "add" then
            User:getRole():addAttr("armorScore", tonumber(itemAttr.wuzang))
        elseif flag == "sub" then
            User:getRole():addAttr("armorScore", 0 - tonumber(itemAttr.wuzang))
        end
        --collectScore
        if tonumber(User:getRole():getAttr("weaponScore")) + tonumber(User:getRole():getAttr("armorScore")) > tonumber(User:getRole():getAttr("collectScore")) then
            User:getRole():setAttr("collectScore", tonumber(User:getRole():getAttr("weaponScore")) + tonumber(User:getRole():getAttr("armorScore")))
        end
    end
end

function CangYiGe:onResume()
    local list = {
        ["android"] = true
    }
    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    if titleLayer then
        titleLayer:setTipFunc(
            function(func)
                if list[device.platform] ~= nil and (list[device.platform] == true or list[device.platform][CURR_DEVICE_CHANNEL] == true) then
                    local DialogKlayer = require("app.views.layer.DialogLayer.ShenBingGuiZe")
                    local dialog = DialogKlayer:getInstance()
                    dialog:hide()
                    local str =
                        "CYN藏衣阁规则：\n藏衣阁可将珍贵稀有的衣服饰品放入其中，同种衣服饰品只能放入一件，珍贵稀有的衣服饰品会提升收藏评价。\n注：普通衣物不可放入藏衣阁\n \n悬兵洞规则：\n悬兵洞可将珍贵稀有的兵器放入其中，同种兵器只能放入一把，珍贵稀有的兵器会提升收藏评价，神兵也可放入悬兵洞、但没有收藏评价。\n注：普通兵器不可放入悬兵洞\n \n悬兵洞与藏衣室内的道具可进行传承，神兵系统在传承后会直接开启。"

                    dialog:showLayer("收藏规则", str, func)
                else
                    local DialogKlayer = require("app.views.layer.DialogLayer.DialogKLayer")
                    local dialog = DialogKlayer:getInstance()
                    dialog:hide()
                    local str =
                        "藏衣阁规则：\n藏衣阁可将珍贵稀有的衣服饰品放入其中，同种衣服饰品只能放入一件，珍贵稀有的衣服饰品会提升收藏评价。\n注：普通衣物不可放入藏衣阁\n \n悬兵洞规则：\n悬兵洞可将珍贵稀有的兵器放入其中，同种兵器只能放入一把，珍贵稀有的兵器会提升收藏评价，神兵也可放入悬兵洞、但没有收藏评价。\n注：普通兵器不可放入悬兵洞\n \nHIY悬兵洞与藏衣室内的道具可进行传承，神兵系统在传承后会直接开启。"

                    dialog:showLayer("收藏规则", str, func)
                end
            end
        )
    end
end

function CangYiGe:onPause()
    if self.listViewSchedule then
        self:unschedule(self.listViewSchedule)
        self.listViewSchedule = nil
    end
end

-- id = "weapon_"..tostring(Helper:getDef(User:getRole():getAttr("forgeCount"),0))       forgeCount  是锻造的次数
local test = {
    id = "weapon_0",
    name = "花花",
    nameColor = 0,
    type = "剑",
    wpType = "神兵",
    damage = 0,
    yindu = 0,
    rendu = 0,
    weight = 0,
    effctNum = 0,
    naijiu = 100,
    wanhaodu = 100,
    effct1 = "",
    effct2 = "",
    effct3 = "",
    typeDesc = "",
    lookDesc = "",
    equipDesc = "",
    getoffDesc = "",
    status = 0,
    canEquip = 1
}
local shenBingItems = {}

function CangYiGe:testGetShenbing()
    shenBingItems[1] = test
    return shenBingItems
end

function CangYiGe:uploadUserCollectScore()
    if self._inRoom then
        local nowDsc = ShenBingDesc:getCollectScore(CangYiGeModel:getInstance():getUserCollectScore())

        if _currCollectType ~= nowDsc then
            --@RefType [app.models.HomelandModel.HomelandDesc#HomelandDesc]
            local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
            local text = HomelandDesc:getCangYiShiDesc(nowDsc)
            self:setTitleText(text)
        end
    end
end

Helper:classDefNodeGetInstance(CangYiGe)
return CangYiGe
0000000
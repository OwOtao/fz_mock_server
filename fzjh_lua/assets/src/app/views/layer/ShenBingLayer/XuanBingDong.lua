local XuanBingDong = class("XuanBingDong", cc.Layer)
--@RefType [app.models.Poison.PoisonUtil#PoisonUtil]
local PoisonUtil = require("app.models.Poison.PoisonUtil")
--@RefType [app.models.ShenBing.DuanZao.ShenBingDuanZao#ShenBingDuanZao]
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")

function XuanBingDong:create()
    local p = XuanBingDong:new()
    p:init()
    return p
end

local _currCollectType

function XuanBingDong:init()
    self._UI = require("Layer/ShenBing/XuanBingDong.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self.Panel_item:setVisible(false)
    self.Panel_Dsc_back:setVisible(false)
end

local CKTYPE = "xuanbingdong"
local xItems = {}
--@desc 修复数据库中有两把一样的武器所使用ItemId 缓存表
local tempItemIds = {}
function XuanBingDong:show(inRoom, desc)
    xItems = {}
    tempItemIds = {}
    if inRoom then
        self._inRoom = true
        self:setTitleText(desc)
    else
        self._inRoom = false
        self:setTitleText()
    end
    self:getListFromServer()
end

function XuanBingDong:getListFromServer()
    HttpManagerEx:getCkItemsList(
        CKTYPE,
        User:getRole().sCk_ver[CKTYPE],
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    User:getRole().sCk_ver[CKTYPE] = data.ver
                    self:initItemsList(data.list)
                    self:setNeiLiAndGold()
                    self:__showItemList()
                    self:ButtonAddShenBing()
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                print("get CkItemsList error", errcode, status)
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
    return true
end

function XuanBingDong:initItemsList(serverItemList)
    User:getRole():setAttr("weaponScore", 0)
    --['shenbin1'=>['total'=>1, 'info'=>[], 'itemId'=>'shenbin1']]

    if MapIsEmpty(serverItemList) then
        return
    end

    local role = User:getRole()

    for k, v in pairs(serverItemList) do
        if v.total > 1 then
            print("========================================", v.itemId, v.total)
            v.total = 1
        end

        if v.total == 1 then
            local temp = {}
            temp.itemId = v.itemId
            temp.update_time = v.update_time

            if v.info and v.info ~= "" then
                temp.info = v.info
                --@desc 删除背包内有一把跟同ID的神兵
                if role:getItemCount(v.itemId) > 0 then
                    role:addItemCount(v.itemId, -1)
                end
            end

            local baseInfo = ShenBingDuanZao:getWeaponBaseInfo(v.itemId)
            if baseInfo == nil and v.info ~= nil and v.info ~= "" then
                ShenBingDuanZao:getNewShenBingWeapen(v.info)
                role:addAttr("forgeCount", 1)
            elseif baseInfo ~= nil and (v.info == nil or v.info == "") then
                if role:getItemCount(v.itemId) > 0 then
                    role:addItemCount(v.itemId, -1)
                end
            end

            if not tempItemIds[temp.itemId] then
                self:addXuanBingDongScore("add", temp.itemId)
                table.insert(xItems, temp)
                tempItemIds[temp.itemId] = true
            end
        end
    end
end

function XuanBingDong:__initPanelInfo(panel,panelInfo)
    if MapIsEmpty(panelInfo) == false then
        panel.Image_tiao.Text_name:setColor(cc.c3b(208, 208, 208))
        panel.Image_tiao.Text_name:setString(panelInfo._show_name)
        panel.Item_count:setString(panelInfo._show_damage)
        panel.Item_type:setString(panelInfo._show_type)
        panel:releaseFunc(
            function()
                if panelInfo._show_func then
                    panelInfo._show_func()
                end
            end
        )
    end
end

function XuanBingDong:__dealWithShowItemsData()
    local _show_item_infos = {}

    if MapIsEmpty(xItems) == false then
        table.sort(
            xItems,
            function(a, b)
                local a_time = 0

                local b_time = 0

                if type(a.update_time) == "number" then
                    a_time = a.update_time
                end

                if type(b.update_time) == "number" then
                    b_time = b.update_time
                end
                
                return a_time < b_time
            end
        )

        local needRemoveItems = {}
        
        for index, itemData in ipairs(xItems) do
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()
            
            local itemAttr = Item:getOneItemByKey(itemData.itemId)
            if itemAttr then
                local _item_info = {}

                if itemAttr.wpType == "神兵" then
                    _item_info._show_name = itemAttr.nameColor .. itemAttr.name
                else
                    _item_info._show_name = itemAttr.name
                end

                _item_info._show_damage = "伤害力+" .. tostring(Helper:mathFloor(itemAttr:getWeaponDamage(role)))

                _item_info._show_type = itemAttr.type

                _item_info._show_func = function()
                    self:clickOneItem(itemData, itemAttr)
                end

                table.insert(_show_item_infos,_item_info)
            else
                if DEBUG_MODE == 1 then
                    print("itemAttr is nil", itemData.itemId)
                end
                table.insert(needRemoveItems, index)
                HttpManagerEx:outGoingCkItems(
                    {itemId = itemData.itemId},
                    CKTYPE,
                    User:getRole().sCk_ver[CKTYPE],
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                local role = User:getRole()
                                role.sCk_ver[CKTYPE] = data.ver
                            else
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end
                )
            end
        end

        if not MapIsEmpty(needRemoveItems) then
            for _, index in ipairs(needRemoveItems) do
                table.remove(xItems, index)
            end
        end
    end

    return _show_item_infos
end

function XuanBingDong:__showItemList()
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
    local itemMaxCount = Helper:mathFloor(listSize.height/(itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

    self.ListView_item:setItemHeight(itemSize.height)

    self.ListView_item:setItemInitFunc(function(item,info)
        self:__initPanelInfo(item,info)
    end)

    self.ListView_item:setItemCreateFunc(function()
        return self:getItemPanel()
    end)

    self.ListView_item:showListView(showItemsInfo,itemMaxCount)

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

        self.listViewSchedule = self:schedule(function()
            self.ListView_item:refreshReuseItems()
            self._lastContentPos = self.ListView_item:getLastInnerContainerPosition()
        end)
    end
end

--@desc 列表渲染
function XuanBingDong:showItemList()
    self.ListView_item:setSwallowTouches(false)

    local listViewItems = self.ListView_item:getItems()
    local removeCount = 0
    if #listViewItems > #xItems then
        removeCount = #listViewItems - #xItems
    end

    table.sort(
        xItems,
        function(a, b)
            local a_time = 0

            local b_time = 0

            if type(a.update_time) == "number" then
                a_time = a.update_time
            end

            if type(b.update_time) == "number" then
                b_time = b.update_time
            end
            
            return a_time < b_time
        end
    )

    if not MapIsEmpty(xItems) then
        local needRemoveItems = {}
        for index, itemData in ipairs(xItems) do
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local itemAttr = Item:getOneItemByKey(itemData.itemId)
            if itemAttr then
                local row = self.ListView_item:getItem(index - 1)

                if not row then
                    row = self:getItemPanel()
                    self.ListView_item:pushBackCustomItem(row)
                end
                row.Image_tiao.Text_name:setColor(cc.c3b(208, 208, 208))
                if itemAttr.wpType == "神兵" then
                    row.Image_tiao.Text_name:setString(itemAttr.nameColor .. itemAttr.name)
                else
                    row.Image_tiao.Text_name:setString(itemAttr.name)
                end
                row.Item_count:setString("伤害力+" .. tostring(Helper:mathFloor(itemAttr:getWeaponDamage(role))))
                row.Item_type:setString(itemAttr.type)
                row:releaseFunc(
                    function()
                        -- PopText("点击:"..itemAttr.name)
                        self:clickOneItem(itemData, itemAttr)
                    end
                )
            else
                if DEBUG_MODE == 1 then
                    print("itemAttr is nil", itemData.itemId)
                end
                table.insert(needRemoveItems, index)
                HttpManagerEx:outGoingCkItems(
                    {itemId = itemData.itemId},
                    CKTYPE,
                    User:getRole().sCk_ver[CKTYPE],
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                local role = User:getRole()
                                role.sCk_ver[CKTYPE] = data.ver
                            else
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end
                )
            end
        end

        if not MapIsEmpty(needRemoveItems) then
            for _, index in ipairs(needRemoveItems) do
                table.remove(xItems, index)
            end
        end
    end

    if removeCount > 0 then
        local removeIndex = #xItems
        for i = #listViewItems - 1, removeIndex, -1 do
            self.ListView_item:removeItem(i)
        end
    end
end

function XuanBingDong:clickOneItem(item, itemAttr)
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
    local wpType = itemAttr.wpType or itemAttr:getItemShowType()
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
            PopupLayerController:showLayer(
                "ShenBingInfo",
                function(layer)
                    layer:show()
                    layer:setShenBingInfo(itemAttr)
                end
            )
        end
    )
end

--@desc 出库
function XuanBingDong:rightListFunc(item, func)
    PopupLayerController:showLayer("GlobalShadeLayer",function(layer)
        layer:showLayer()
    end)
    HttpManagerEx:outGoingCkItems(
        {itemId = item.itemId},
        CKTYPE,
        User:getRole().sCk_ver[CKTYPE],
        function(status, errcode, errmsg, data)
            local result = false
            if status == 200 then
                if errcode == 0 then
                    --@RefType [app.models.role.Role#Role]
                    local role = User:getRole()
                    role.sCk_ver[CKTYPE] = data.ver

                    local _, roleItem = role:addItemCount(data.itemId, data.total, nil, nil, "神兵出库")
                    item.onlyid = roleItem.id

                    for i, v in ipairs(xItems) do
                        if v.itemId == item.itemId then
                            table.remove(xItems, i)
                            break
                        end
                    end

                    tempItemIds[item.itemId] = false
                    local itemAttr = Item:getOneItemByKey(item.itemId)
                    if itemAttr and itemAttr.shoucang == 1 then
                        role:addAttr("collectScore", 0 - tonumber(itemAttr.wuzang))
                    end
                    self:addXuanBingDongScore("sub", item.itemId)
                    self:uploadUserCollectScore()
                    if DEBUG_MODE == 1 then
                        print("===================收藏评分=======================", role:getAttr("collectScore"))
                    end

                    if func then
                        func()
                    end
                    result = true
                elseif errcode == -1 then
                    --@RefType [app.models.role.Role#Role]
                    local role = User:getRole()
                    role.sCk_ver[CKTYPE] = data.ver
                    PopText("网络异常，请重试。")
                    result = true
                else
                    PopText(errmsg)
                    result = true
                end
            else
                PopText(errmsg)
                result = false
            end
            PopupLayerController:hideLayer("GlobalShadeLayer",function ( layer )
                layer:hideLayer()
            end)
            return result
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

--@desc 入库
function XuanBingDong:leftListFunc(item, func)
    local itemId = item.itemId
    local info = item.info
    PopupLayerController:showLayer("GlobalShadeLayer",function(layer)
        layer:showLayer()
    end)
    HttpManagerEx:bePutCkItems(
        {itemId = itemId, info = info},
        CKTYPE,
        User:getRole().sCk_ver[CKTYPE],
        function(status, errcode, errmsg, data)
            local result = false
            if status == 200 then
                if errcode == 0 then
                    --@RefType [app.models.role.Role#Role]
                    local role = User:getRole()
                    role.sCk_ver[CKTYPE] = data.ver

                    role:addItemCount(itemId, -1, nil, item.onlyid, "神兵入库")

                    local temp = {}
                    temp.itemId = itemId
                    if info then
                        temp.info = info
                    end

                    temp.update_time = data.update_time

                    table.insert(xItems, temp)

                    if not tempItemIds[item.itemId] then
                        tempItemIds[item.itemId] = true
                        local itemAttr = Item:getOneItemByKey(item.itemId)
                        if itemAttr and itemAttr.shoucang == 1 then
                            role:addAttr("collectScore", tonumber(itemAttr.wuzang))
                        end
                        self:addXuanBingDongScore("add", item.itemId)
                        self:uploadUserCollectScore()
                        if DEBUG_MODE == 1 then
                            print("===================收藏评分=======================", role:getAttr("collectScore"))
                        end

                        if func then
                            func()
                        end
                    else
                        print("有错，库中已有一把，不应该运行到此处。")
                    end
                    result = true
                elseif errcode == -1 then
                    local role = User:getRole()
                    role.sCk_ver[CKTYPE] = data.ver
                    PopText("网络异常，请重试。")
                    result = true
                else
                    PopText(errmsg)
                    result = false
                end
            else
                PopText(errmsg)
                result = false
            end
            PopupLayerController:hideLayer("GlobalShadeLayer",function ( layer )
                layer:hideLayer()
            end)
            return result
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function XuanBingDong:ButtonAddShenBing()
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
                    --@RefType [app.models.role.Role#Role]
                    local role = User:getRole()

                    layer:btnLeftClickFunc()

                    layer:setConditionPushRightFunc( function(item)
                        if User:getRole():checkItemIsEquip(item.onlyid) == true then
                            PopText("请先将武器脱下")
                            return false
                        end

                        if User:getRole():checkIsPrepareWeapon(item.onlyid) == true then
                            PopText("请先将武器取消准备")
                            return false
                        end

                        local itemData = Item:getOneItemByKey(item.itemId)

                        if itemData and itemData.wpType ~= "神兵" and itemData.shoucang ~= 1 then
                            PopText("该武器不能收藏")
                            return false
                        end

                        if tempItemIds[item.itemId] == true then
                            PopText("一把兵器悬兵洞只能收藏一把")
                            return false
                        end

                        if PoisonUtil:checkWeaponIsPoison(item.onlyid) then
                            PopText("淬毒的兵器无法放入悬兵洞")
                            return false
                        end

                        if item.type ~= "神兵" and item.wanhaodu == 0 then
                            PopText("破损的兵器无法放入悬兵洞")
                            return false
                        elseif item.type == "神兵" then
                            if itemData.wanhaodu == 0 then
                                PopText("破损的兵器无法放入悬兵洞")
                                return false
                            end
                        end

                        return true
                    end)

                    layer:setConditionPushLeftFunc(function(item)
                        if User:getRole():checkCanBuyThings(item.itemId, 1) == false then
                            PopText("背包空间不足")
                            return false
                        end

                        local items =
                            User:getRole():getItems(
                            function(item)
                                if item.type == "神兵" then
                                    return true
                                end
                                return false
                            end
                        )

                        --@desc 背包中神兵数量
                        local itemAttr = Item:getOneItemByKey(item.itemId)
                        if itemAttr.wpType == "神兵" and #items ~= 0 then
                            PopText("背包中只能同时存在一把神兵")
                            return false
                        end

                        return true
                    end)

                    layer:btnRightClickFunc(
                        function(leftList, rightList)
                            self:__showItemList()
                            self:setNeiLiAndGold()
                            layer:destory()
                        end,
                        "确定"
                    )

                    local function setRightItems()
                        if not MapIsEmpty(xItems) then
                            local rightItemsInfo = {}
                            for index, itemData in ipairs(xItems) do
                                local data = {
                                    itemId = itemData.itemId,
                                    update_time = itemData.update_time,
                                }
    
                                local itemInfo = Item:getOneItemByKey(itemData.itemId)
    
                                data.name = itemInfo.name

                                if itemInfo.wpType == "神兵" then
                                    data.name = itemInfo.nameColor..itemInfo.name
                                end
    
                                if itemData.info then
                                    data.info = itemData.info
                                end
    
                                table.insert(rightItemsInfo, data)
                            end
    
                            layer:setRightItemsInfo(rightItemsInfo)
                        else
                            layer:setRightItemsInfo()
                        end
                    end

                    local function setLeftItems()
                         --@desc 人物背包中的武器
                        local bItems =
                            User:getRole():getItems(
                            function(item)
                                local itemData = Item:getOneItemByKey(item.itemId)
                                if itemData ~= nil and itemData.equipPart == "weapon" then
                                    return true
                                else
                                    return false
                                end
                            end
                        )

                        if not MapIsEmpty(bItems) then
                            local leftItemsInfo = {}
                            for i, itemData in ipairs(bItems) do
                                local data = {
                                    onlyid = itemData.id,
                                    itemId = itemData.itemId,
                                    type = itemData.type,
                                    wanhaodu = itemData.wanhaodu,
                                }
                                
                                local itemInfo = Item:getOneItemByKey(itemData.itemId)

                                data.name = itemInfo.name

                                if itemData.type == "神兵" then
                                    data.name = itemInfo.nameColor..itemInfo.name
                                    local info = ShenBingDuanZao:getWeaponBaseInfo(itemData.itemId)
                                    data.info = info
                                end

                                table.insert(leftItemsInfo, data)
                            end
                            layer:setLeftItemsInfo(leftItemsInfo)
                        else
                            layer:setLeftItemsInfo()
                        end
                    end

                    setRightItems()

                    setLeftItems()

                    layer:setAfterPushFunc(function()
                        setRightItems()
                        setLeftItems()
                    end)

                    layer:setOutGoingCKFunc(function(item, func)
                        self:leftListFunc(item, func)
                    end)

                    layer:setBePutCKFunc(function(item, func)
                        self:rightListFunc(item, func)
                    end)

                    layer:refreshUI()

                    layer:setRightName("悬兵洞")
                    layer:showLayer()
                end
            )
        end
    )
end

--设置内力和金钱数值
function XuanBingDong:setNeiLiAndGold()
    local role = User:getRole()
    local neili, neiliMax = math.ceil(role:getAttr("neili")), math.ceil(role:getFinalAttr("neiliMax"))
    local gold = role:getAttr("gold")

    _currCollectType = ShenBingDesc:getRoleCollectDesc(User:getRole())

    self.Text_NeiLi:setString("『内力』" .. tostring(neili) .. "/" .. tostring(neiliMax))
    self.Text_Gold:setString("『收藏评价』" .. _currCollectType)
end

--@desc: 创建list的item
--@author:Liang SongQiang
--@time:2018-02-27 10:18:19
function XuanBingDong:getItemPanel()
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
function XuanBingDong:itemDescShow(anim)
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
function XuanBingDong:itemDescHide(anim)
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

function XuanBingDong:onResume()
    -- self:setNeiLiAndGold()
    -- self:getSellerItems()
    -- PopText("进入玄兵洞")
    local list = {
        ["android"] = true
        -- ["ios"] = {},
        -- ["fzjh"] = {},
    }
    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    if titleLayer then
        titleLayer:setTipFunc(
            function(func)
                if
                    list[device.platform] ~= nil and
                        (list[device.platform] == true or list[device.platform][CURR_DEVICE_CHANNEL] == true)
                 then
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
    self.Text_desc:setString("这里是悬兵洞，上悬诸多挂钩以悬兵之用，洞内温热，旁边还有一口水池，是放置兵器的好地方。")
end

function XuanBingDong:onPause()
    if self.listViewSchedule then
        self:unschedule(self.listViewSchedule)
        self.listViewSchedule = nil
    end
end

--计算玄兵洞中兵器的收藏积分
function XuanBingDong:addXuanBingDongScore(flag, itemId)
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()
    local itemAttr = Item:getOneItemByKey(itemId)
    if itemAttr and itemAttr.shoucang == 1 then
        if flag == "add" then
            role:addAttr("weaponScore", tonumber(itemAttr.wuzang))
        elseif flag == "sub" then
            role:addAttr("weaponScore", 0 - tonumber(itemAttr.wuzang))
        end
        --collectScore
        if
            tonumber(role:getAttr("weaponScore")) + tonumber(role:getAttr("armorScore")) >
                tonumber(role:getAttr("collectScore"))
         then
            role:setAttr("collectScore", tonumber(role:getAttr("weaponScore")) + tonumber(role:getAttr("armorScore")))
        end
    end
end

function XuanBingDong:setTitleText(text)
    if not text then
        text = "这里是玄兵古洞，里面传来阵阵的捶打声似乎在锻造着什么。隐隐的透着一股肃杀的气息。"
    end

    self.Text_desc:setString(text)
end

function XuanBingDong:uploadUserCollectScore()
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local fq = role:getHomelandAttr("fq")

    if MapIsEmpty(fq) then
        return
    end

    local mid = fq.mid

    local nowScore = Helper:getDef(role:getAttr("collectScore"), 1)
    -- local preScore = Helper:getDef(role:getAttr("preCollectScore"), 1)
    if self._inRoom then
        local nowDsc = ShenBingDesc:getCollectScore(nowScore)

        if _currCollectType ~= nowDsc then
            --@RefType [app.models.HomelandModel.HomelandDesc#HomelandDesc]
            local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
            local text = HomelandDesc:getCangJianShiDesc(nowDsc)
            self:setTitleText(text)
        end
    end
    local UserMap = require("app.models.map.UserMap")
    UserMap:updateMapExtraAttr(mid,{collectScore = nowScore},0)
end

return XuanBingDong
0000000
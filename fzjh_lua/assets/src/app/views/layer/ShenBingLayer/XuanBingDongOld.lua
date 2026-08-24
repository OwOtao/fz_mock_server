--新神兵铁匠   悬兵洞界面
local XuanBingDongOld = class("XuanBingDongOld", cc.Layer)
local PoisonUtil = require("app.models.Poison.PoisonUtil")
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
function XuanBingDongOld:create()
    local p = XuanBingDongOld:new()
    p:init()
    return p
end

function XuanBingDongOld:init()
    self._UI = require("Layer/ShenBing/XuanBingDong.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self.Panel_item:setVisible(false)
    self.Panel_Dsc_back:setVisible(false)
    self.XuanBIngBag = {} --初始化悬兵洞 物品放入
end
function XuanBingDongOld:show(dataList)
    self:ButtonAddShenBing()
    -- self:ButtonBack()
    self:getSellerItems(dataList)
    self:setNeiLiAndGold()
end

--设置内力和金钱数值
function XuanBingDongOld:setNeiLiAndGold()
    if PRINT_MODE == 1 then
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    end
    local role = User:getRole()
    local neili, neiliMax = math.ceil(role:getAttr("neili")), math.ceil(role:getFinalAttr("neiliMax"))
    local gold = role:getAttr("gold")
    self.Text_NeiLi:setString("『内力』" .. tostring(neili) .. "/" .. tostring(neiliMax))
    self.Text_Gold:setString("『收藏评价』" .. ShenBingDesc:getRoleCollectDesc(User:getRole()))
end

-- --返回按钮
-- function XuanBingDongOld:ButtonBack()
-- 	self.Image_titleShenBing.Button_back:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BACKBUTTON)
-- 	self.Image_titleShenBing.Button_back:releaseFunc(function()
-- 		self.Panel_Dsc_back:setVisible(false)
-- 		PopupLayerController:hideLayer("ShenBingInfo",function(layer)
-- 			layer:hide()
-- 		end)
-- 		-- self:hide()
-- 		MainControllLayer:popLayer()
-- 	end)
-- end
function XuanBingDongOld:ButtonAddShenBing()
    self.Button_FangRu:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
    self.Button_FangRu:releaseFunc(
        function()
            PopupLayerController:showLayer(
                "NewShenBingBagLayer",
                function(layer)
                    layer:btnLeftClickFunc()

                    layer:btnRightClickFunc(
                        function(leftList, rightList)
                            -- self.XuanBIngBag = rightList
                            -- self.XuanBIngBag= {}
                            -- for k,v in pairs(self.rightList) do
                            -- 	local tab = {
                            -- 		itemId = k,
                            -- 		count = 1,
                            -- 		web_id = v
                            -- 	}
                            -- 	table.insert(self.XuanBIngBag,tab)
                            -- end
                            self:showItemList()
                            self:setNeiLiAndGold()
                            layer:destory()
                        end,
                        "确定"
                    )

                    layer:setCondiPushRightList(
                        function(leftList, rightList, item) --从左向右放
                            if User:getRole():checkItemIsEquip(item.id) == true then
                                PopText("请先将武器脱下")
                                return false
                            end
                            local itemData = Item:getOneItemByKey(item.itemId)

                            if itemData and itemData.wpType ~= "神兵" and itemData.shoucang ~= 1 then
                                PopText("该武器不能收藏")
                                return false
                            end
                            if self.rightList[item.itemId] ~= nil then
                                PopText("一把兵器悬兵洞只能收藏一把")
                                return false
                            end
                            print("--------------------------------------------", item.id)
                            if PoisonUtil:checkWeaponIsPoison(item.id) == false then
                            else
                                PopText("淬毒的兵器无法放入悬兵洞")
                                return false
                            end
                            if item.type ~= "神兵" and item.wanhaodu == 0 then
                                PopText("破损的兵器无法放入悬兵洞")
                                return false
                            else
                                if itemData.wanhaodu == 0 then
                                    PopText("破损的兵器无法放入悬兵洞")
                                    return false
                                else
                                    return true
                                end
                            end
                            return true
                        end
                    )
                    layer:setCondiPushLeftList(
                        function(leftList, rightList, item) --从右向左放
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
                            local itemAttr = Item:getOneItemByKey(item.itemId)
                            if itemAttr.wpType == "神兵" and #items ~= 0 then
                                PopText("背包中只能同时存在一把神兵")
                                return false
                            else
                            end
                            return true
                        end
                    )
                    local items =
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

                    for k, itemData in pairs(items) do
                        layer:pushItemToLeftList(
                            itemData,
                            function(item, func)
                                self:setBagLeftFunc(item, func)
                            end,
                            function(item, func)
                                self:setBagRightFunc(item, func)
                            end
                        )
                    end

                    if MapIsEmpty(self.XuanBIngBag) ~= true then
                        for i, itemData in ipairs(self.XuanBIngBag) do
                            layer:pushItemToRightList(
                                itemData,
                                function(item, func)
                                    self:setBagRightFunc(item, func)
                                end,
                                function(item, func)
                                    self:setBagLeftFunc(item, func)
                                end
                            )
                        end

                    -- for itemId,web_id in pairs(self.rightList) do
                    -- 	local data = {
                    -- 		itemId = itemId,
                    -- 		web_id = web_id,
                    -- 	}
                    -- 	layer:pushItemToRightList(data,function(item, func)
                    -- 		self:setBagRightFunc(item,func)
                    -- 	end,function(item, func)
                    -- 	self:setBagLeftFunc(item, func)
                    -- end)
                    -- end
                    end
                    layer:setRightName("悬兵洞")
                    layer:showLayer()
                end
            )
        end
    )
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/24 10:55:20
-- @desc 设置背包点击左边的方法
function XuanBingDongOld:setBagLeftFunc(item, func)
    local baseinfo = nil
    local isShenbing = string.find(item.itemId, "weapon_")
    if isShenbing ~= nil then
        baseinfo = ShenBingDuanZao:getWeaponBaseInfo(item.itemId)
    end
    HttpManagerEx:uploadClientData(
        "xuanbingdong",
        {itemId = item.itemId, info = baseinfo},
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    data = Helper:getDef(data, {})

                    User:getRole():addItemCount(item.itemId, -1, nil, item.id)

                    local temp = {}
                    temp.itemId = item.itemId
                    if item.info then
                        temp.info = item.info
                    end

                    table.insert(self.XuanBIngBag, temp)

                    self.rightList[item.itemId] = data.id
                    local itemData = Item:getOneItemByKey(item.itemId)
                    if itemData and itemData.shoucang == 1 then
                        User:getRole():addAttr("collectScore", tonumber(itemData.wuzang))
                    end
                    self:addXuanBingDongScore("add", item.itemId)
                    if DEBUG_MODE == 1 then
                        print("===================收藏评分=======================", User:getRole():getAttr("collectScore"))
                    end
                    if func then
                        func()
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/24 10:55:20
-- @desc 设置背包点击右边的方法
function XuanBingDongOld:setBagRightFunc(item, func)
    local tab = {id = self.rightList[item.itemId], state = "1"}
    HttpManagerEx:updateDataState(
        tab,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local _, itemAttr = User:getRole():addItemCount(item.itemId, 1)
                    item.id = itemAttr.id

                    for i, v in ipairs(self.XuanBIngBag) do
                        if v.itemId == item.itemId then
                            table.remove(self.XuanBIngBag, i)
                            break
                        end
                    end

                    self.rightList[item.itemId] = nil

                    local itemData = Item:getOneItemByKey(item.itemId)
                    if itemData and itemData.shoucang == 1 then
                        User:getRole():addAttr("collectScore", 0 - tonumber(itemData.wuzang))
                    end
                    self:addXuanBingDongScore("sub", item.itemId)
                    if DEBUG_MODE == 1 then
                        print("===================收藏评分=======================", User:getRole():getAttr("collectScore"))
                    end
                    if func then
                        func()
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

-- -- 列表渲染
-- function XuanBingDongOld:setListView(row, list)
-- 	if not row then
-- 		return
-- 	end
-- 	local items = list:getItems()
-- 	local index = list:getIndex(row) + 1
-- 	for k, v in pairs(items) do
-- 		if k == index then
-- 			self:setItemBack(true, v)
-- 		else
-- 			self:setItemBack(false, v)
-- 		end
-- 	end
-- end

-- 获取已放入悬兵洞的神兵
function XuanBingDongOld:showItemList()
    self.ListView_item:setSwallowTouches(false)
    local listViewItems = self.ListView_item:getItems()
    local removeCount = 0
    local bagItems = self.XuanBIngBag -- 从放入界面取到神兵集

    if #listViewItems > #bagItems then
        removeCount = #listViewItems - #bagItems
    end

    -- local bagItems --获取已放入的全部神兵
    -- local bagItems = self:testGetShenbing()
    if MapIsEmpty(bagItems) then
    else
        --背包排序。可装备的物品排在前面，已经装备的排在可装备的前面.然后再根据他的id来排序
        -- bagItems = self:sortTable(bagItems)\
        local needRemoveItems = {}
        for i, v in ipairs(bagItems) do
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local itemAttr = Item:getOneItemByKey(v.itemId)

            if itemAttr then
                local row = self.ListView_item:getItem(i - 1)
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
                        self:clickOneItem(v, itemAttr)
                    end
                )
            else
                if DEBUG_MODE == 1 then
                    print("itemAttr is nil", v.itemId)
                end
                table.insert(needRemoveItems, i)
            end
        end

        if not MapIsEmpty(needRemoveItems) then
            for _, index in ipairs(needRemoveItems) do
                if self.rightList[self.XuanBIngBag[index].itemId] then
                    self.rightList[self.XuanBIngBag[index].itemId] = nil
                end
                table.remove(self.XuanBIngBag, index)
            end
        end
    end

    if removeCount > 0 then
        local removeIndex = #bagItems
        for i = #listViewItems - 1, removeIndex, -1 do
            self.ListView_item:removeItem(i)
        end
    end
end

function XuanBingDongOld:clickOneItem(item, itemAttr)
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
-- 物品描述显示
function XuanBingDongOld:itemDescShow(anim)
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
function XuanBingDongOld:itemDescHide(anim)
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

function XuanBingDongOld:getItemPanel()
    local row = self.Panel_item:clone()
    Helper:convertUIByParent(row)
    row:setVisible(true)
    row:setTouchEnabled(true)
    row.Image_tiao.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Item_count:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Item_type:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)

    return row
end

-- function XuanBingDongOld:setItemBack(state, row)
-- 	if type(state) ~= "boolean" then
-- 		return
-- 	end
-- 	if not row then
-- 		local index = self.ListView_item:getCurSelectedIndex()
-- 		row = self.ListView_item:getItem(index)
-- 	end
-- 	row.Image_back:setVisible(state)
-- end
function XuanBingDongOld:getSellerItems(dataList)
    if DEBUG_MODE == 1 then
        Helper:print_lua_table(dataList)
    end
    self:setRightList(dataList)
    self.Panel_Dsc_back:setVisible(false)
    self:setVisible(true)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/23 18:10:48
-- @desc 已经放入玄兵洞的物品
function XuanBingDongOld:setRightList(items)
    self.rightList = {}
    self.XuanBIngBag = {}
    if MapIsEmpty(items) == true then
        return
    end
    local role = User:getRole()
    role:setAttr("weaponScore", 0)
    for k, v in pairs(items) do
        if v.itemId ~= nil then
            if self.rightList[v.itemId] == nil then
                self.rightList[v.itemId] = k

                if v.info ~= nil then
                    if role:getItemCount(v.itemId) > 0 then
                        role:addItemCount(v.itemId, -1)
                    end
                end

                local baseInfo = ShenBingDuanZao:getWeaponBaseInfo(v.itemId)
                if baseInfo == nil and v.info ~= nil then
                    ShenBingDuanZao:getNewShenBingWeapen(v.info)
                    role:addAttr("forgeCount", 1)
                elseif baseInfo ~= nil and v.info == nil then
                    if role:getItemCount(v.itemId) > 0 then
                        role:addItemCount(v.itemId, -1)
                    end
                end

                local tab = {
                    itemId = v.itemId,
                    count = 1,
                    web_id = k,
                    info = v.info
                }
                table.insert(self.XuanBIngBag, tab)
                self:addXuanBingDongScore("add", v.itemId)
            end
        end
    end
    -- for k,v in pairs(self.rightList) do
    -- 	local tab = {
    -- 		itemId = k,
    -- 		count = 1,
    -- 		web_id = v
    -- 	}
    -- 	table.insert(self.XuanBIngBag,tab)
    -- end

    self:showItemList()
end

--计算玄兵洞中兵器的收藏积分
function XuanBingDongOld:addXuanBingDongScore(flag, itemId)
    local itemAttr = Item:getOneItemByKey(itemId)
    if itemAttr and itemAttr.shoucang == 1 then
        if flag == "add" then
            User:getRole():addAttr("weaponScore", tonumber(itemAttr.wuzang))
        else
            User:getRole():addAttr("weaponScore", 0 - tonumber(itemAttr.wuzang))
        end
         --collectScore
        if
            tonumber(User:getRole():getAttr("weaponScore")) + tonumber(User:getRole():getAttr("armorScore")) >
                tonumber(User:getRole():getAttr("collectScore"))
         then
            User:getRole():setAttr(
                "collectScore",
                tonumber(User:getRole():getAttr("weaponScore")) + tonumber(User:getRole():getAttr("armorScore"))
            )
        end
    end
end

function XuanBingDongOld:onResume()
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

function XuanBingDongOld:testGetShenbing()
    shenBingItems[1] = test
    shenBingItems[2] = test
    shenBingItems[3] = test
    return shenBingItems
end

Helper:classDefNodeGetInstance(XuanBingDongOld)
return XuanBingDongOld
0
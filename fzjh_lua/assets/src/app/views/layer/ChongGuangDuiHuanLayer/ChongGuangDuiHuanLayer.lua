--@desc 2019-01-12 14:45:52 原重光兑换界面

local ChongGuangDuiHuanLayer = class("ChongGuangDuiHuanLayer", LayerEx)

local config = {
    -- --[[
    --     titleName = ""
    --    exchangeItems = 
    --     {
    --         [itemId（可兑换的物品ID）] = {
    --             --@desc 用列表，按顺序遍历
    --             {
    --                 itemId = xx,(需要的物品ID)
    --                 count = xx,(需拥有的物品数量)
    --             },

    --         }
    --     }
    -- ]]
    -- titleName = "集字兑好礼",
    -- --@desc 兑换消耗物品的Flag
    -- exChangeItemFlag = {
    --     ["2019xcjzwp001"] = "2019xcjz1",
    --     ["2019xcjzwp002"] = "2019xcjz2",
    --     ["2019xcjzwp003"] = "2019xcjz3",
    --     ["2019xcjzwp004"] = "2019xcjz4",
    --     ["2019xcjzwp005"] = "2019xcjz5",
    -- },
    -- exchangeItems = {
    --     {
    --         --@desc 可兑换的物品Id
    --         exchangItemId = "2019jizibox1",
    --         --@desc 传承标记
    --         flag = "2019jzb1",
    --         --@desc 可兑换次数
    --         num = 11,
    --         --@desc 兑换需要消耗的物品
    --         needItems = {
    --             --@desc 用列表，按顺序遍历
    --             {
    --                 itemId = "2019xcjzwp001",
    --                 count = 1
    --             },
    --             {
    --                 itemId = "2019xcjzwp002",
    --                 count = 1
    --             }
    --         }
    --     },
    --     {
    --         --@desc 可兑换的物品Id
    --         exchangItemId = "2019jizibox2",
    --         --@desc 传承标记
    --         flag = "2019jzb2",
    --         --@desc 可兑换次数
    --         num = 11,
    --         --@desc 兑换需要消耗的物品
    --         needItems = {
    --             --@desc 用列表，按顺序遍历
    --             {
    --                 itemId = "2019xcjzwp003",
    --                 count = 1
    --             },
    --             {
    --                 itemId = "2019xcjzwp004",
    --                 count = 1
    --             }
    --         }
    --     },
    --     {
    --         --@desc 可兑换的物品Id
    --         exchangItemId = "2019jizibox3",
    --         --@desc 传承标记
    --         flag = "2019jzb3",
    --         --@desc 可兑换次数
    --         num = 11,
    --         --@desc 兑换需要消耗的物品
    --         needItems = {
    --             --@desc 用列表，按顺序遍历
    --             {
    --                 itemId = "2019xcjzwp001",
    --                 count = 1
    --             },
    --             {
    --                 itemId = "2019xcjzwp002",
    --                 count = 1
    --             },
    --             {
    --                 itemId = "2019xcjzwp003",
    --                 count = 1
    --             },
    --             {
    --                 itemId = "2019xcjzwp004",
    --                 count = 1
    --             },
    --         }
    --     },
    --     {
    --         --@desc 可兑换的物品Id
    --         exchangItemId = "2019jizibox4",
    --         --@desc 传承标记
    --         flag = "2019jzb4",
    --         --@desc 可兑换次数
    --         num = 1,
    --         --@desc 兑换需要消耗的物品
    --         needItems = {
    --             --@desc 用列表，按顺序遍历
    --             {
    --                 itemId = "2019xcjzwp001",
    --                 count = 1
    --             },
    --             {
    --                 itemId = "2019xcjzwp002",
    --                 count = 1
    --             },
    --             {
    --                 itemId = "2019xcjzwp003",
    --                 count = 1
    --             },
    --             {
    --                 itemId = "2019xcjzwp004",
    --                 count = 1
    --             },
    --             {
    --                 itemId = "2019xcjzwp005",
    --                 count = 1
    --             },
    --         }
    --     },
    -- }
}

function ChongGuangDuiHuanLayer:create()
    local p = ChongGuangDuiHuanLayer:new()
    p:init()
    return p
end

function ChongGuangDuiHuanLayer:init()
    self.UI = require("Layer/ChongGuangDuiHuanUI/ChongGuangDuiHuanUI.lua").create()["root"]
    self.UI:addTo(self)
    Helper:convertUIByParent(self) -- 获得所有子节点
    self:setVisible(false)
    self.Button_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

function ChongGuangDuiHuanLayer:showLayer(action)
    Helper:print_lua_table(action)
    HttpManagerEx:checkGoodsValid({"yuhuiling"}, function(status, errcode, errmsg, data)
        if 200 == status and 0 == errcode then
            for k,v in pairs(data) do 
                if "yuhuiling" == v.itemId and v.number > 0 then 
                    self.yuhuilingBuff = true 
                end
            end
            local timeStartStr =Helper:getTimeStrCNFormat(action["start"])
            local timeEndStr = Helper:getTimeStrCNFormat(action["end"])
            -- local timeEndStr = Helper:date("%Y年%m月%d日%H点%M分%S秒", action["end"])

            local detail_desc_list = action.detail_desc

            local str = ""

            for i,desc in ipairs(detail_desc_list) do
                desc = string.gsub(desc,"#start#",timeStartStr)
                desc = string.gsub(desc,"#end#",timeEndStr)
                str = str .. desc .. "\n"
            end

            self:clearExChangeTimes()
            self:setName(action.name)
            self:setDesc(str)
            self:showPanelList()
            self:show()
        else
            PopText("网络请求出错,请换个网络环境再试!")
        end
    end, IS_SHOW_WAITING)
    
end

function ChongGuangDuiHuanLayer:hideLayer()
    PopupLayerController:hideLayer(
        "ChongGuangDuiHuanLayer",
        function(layer)
            layer:hide()
        end
    )
end

function ChongGuangDuiHuanLayer:setConfig(config_data)
    config = config_data
end

function ChongGuangDuiHuanLayer:setName(name)
    self.Text_Name:setString(tostring(name))
end

function ChongGuangDuiHuanLayer:setDesc(desc)
    local richText = self:getChildByTag(10001)
    if richText == nil then
        richText = ExtRichTextScroll:create()
        richText:setSize({width = 1047.31, height = 281.47})
        richText:move(cc.p(17.10, 1474.23))
        richText:setTag(10001)
        self:addChild(richText)
        richText:setVerticalSpace(5)
        richText:setDirection(kCCScrollViewDirectionVertical)
    else
        richText:getRichText():removeAllElement()
    end
    richText:pushBackText(desc, cc.c3b(208, 208, 208), 255, Resource:getFontPath("default"), 36)
    self:delayFunc(0.1,function ()
        richText:jumpToTop()
    end)
   
end

function ChongGuangDuiHuanLayer:showPanelList()
    local list_data = Helper:getDef(config.exchangeItems, {})
    local role = User:getRole()

    for index, item_data in ipairs(list_data) do
        local panel = self.ListView_Items:getItem(index - 1)
        if panel == nil then
            panel = self:createPanelItem()
            self.ListView_Items:pushBackCustomItem(panel)
        end

        local exchangItemName = Helper:getDef(role:getOneItemByKey(item_data.exchangItemId).name, "")

        self:setPanelTitle(panel, exchangItemName)

        panel.Text_Title:releaseFunc(function ()
            local showTextList = Helper:getDef(item_data.showTextList,{})

            PopupLayerController:showLayer("ShowDetailListLayer",function (layer )

                layer:showLayer("打开【"..exchangItemName.."】可随机获得以下道具之一：",showTextList)
            end)
        end)

        local hasChangeCount = role:getInheritFlag(item_data.flag)

        local remainCount = math.max(item_data.num - hasChangeCount, 0)

        self:setPanelSubText(panel, "可兑换" .. remainCount .. "次")

        self:setItemCount(panel, item_data.needItems)

        self:setTextEnableOutline(panel)

        self:setPanelButonFunc(
            panel,
            function()
                local role = User:getRole()

                if remainCount == 0 then
                    PopText("兑换次数不足，兑换失败。")
                    return
                end

                local isChange = false

                local exChangItemFlag = config.exChangeItemFlag
             
                for _, needItem in ipairs(item_data.needItems) do
                    --@desc 需要消耗的物品
                    local item = role:getOneItemByKey(needItem.itemId)

                    local needCount = needItem.count

                    local hasCount = role:getItemCount(item.id)

                    if exChangItemFlag[item.id] == nil then
                        assert(false, "兑换需消耗的物品flag没有配置，" .. item.id)
                    end

                    local flagCount = role:getInheritFlag(exChangItemFlag[item.id])
                    if flagCount ~= hasCount then
                        PopText("缺少"..item.name.."，兑换失败。")
                        return
                    end

                    if needCount > hasCount then
                        PopText("缺少"..item.name.."，兑换失败。")
                        isChange = false
                        break
                    else
                        isChange = true
                    end
                end

                if isChange == true then
                    --保底判断
                    local isGuaranteedBonusItem = self:isGuaranteedBonusFun(item_data.exchangItemId)
                    local exchange_item = role:getOneItemByKey(item_data.exchangItemId)
                    local currExchangItemId,currExchangItemName = item_data.exchangItemId,exchange_item.name
                    if isGuaranteedBonusItem then 
                        currExchangItemId = isGuaranteedBonusItem
                        local guaranteedBonusItem = role:getOneItemByKey(currExchangItemId)
                        currExchangItemName = guaranteedBonusItem.name
                    end

                    if role:checkCanBuyTwoOrMoreThings({[currExchangItemId] = 1}) == false then
                        return
                    end

                    PopupLayerController:showLayer(
                        "GlobalShadeLayer",
                        function(layer)
                            layer:showLayer()
                            layer:setPopText("你正在干别的事情。")
                        end
                    )

                    HttpManagerEx:addCurrencyNumber({["jiaozi"] =50 },"DailyTies_weekxzzy","weekact", function(status, errcode, errmsg, data)
                        if 200 == status and 0 == errcode then
                            if MapIsEmpty(data.currency) == false then
                                for currency,valueData in pairs(data.currency) do
                                    if valueData.value > 0 then 
                                        --增加XX新货币，共拥有XX新货币。
                                        PopText("增加"..tostring(valueData.value)..role:getCHAttrName(currency).."，共拥有"..tostring(valueData.count)..role:getCHAttrName(currency))
                                    end
                                    if valueData.desc ~= nil and valueData.desc ~= ""  then
                                        PopText(valueData.desc)
                                    end
                                end
                            end


                            for _, needItem in ipairs(item_data.needItems) do
                                role:addItemCount(needItem.itemId, -needItem.count)
    
                                local item = role:getOneItemByKey(needItem.itemId)
    
                                role:setInheritFlag(
                                    exChangItemFlag[item.id],
                                    math.max(role:getInheritFlag(exChangItemFlag[item.id]) - needItem.count, 0)
                                )
    
                                PopText("您消耗了" .. item.name .. " X" .. needItem.count)
                            end
    
                            
                            --保底处理
                            self:guaranteedBonusFun(item_data.exchangItemId)
    
                            role:addItemCount(currExchangItemId, 1)
    
                            role:setInheritFlag(
                                item_data.flag,
                                math.min(role:getInheritFlag(item_data.flag) + 1, item_data.num)
                            )
    
                            PopText("您获得了" .. currExchangItemName .. " X1")
    
                             --周活经验潜能奖励
                            if MapIsEmpty(item_data.attrRewards) == false then 
                                for attrName,addAttrNum in pairs(item_data.attrRewards) do
                                    local addValue = addAttrNum
                                    if self.yuhuilingBuff then 
                                        local buffAddValue = role:getDayFlag("yuhuiling_"..attrName)
                                        local addNum = YUHUILING_BUFF * addAttrNum 
                                        if addNum > YUHUILING_NUM_LIMIT - buffAddValue then 
                                            addNum = math.max(YUHUILING_NUM_LIMIT - buffAddValue,0)
                                        end
                                        role:setDayFlag("yuhuiling_"..attrName,buffAddValue + addNum)
                                        addValue = addValue + addNum
                                    end
                                    role:addAttr(attrName,addValue)
                                    PopText("您获得了"..role:getCHAttrName(attrName)..tostring(addValue))
                                end
                            end
    
                            self:showPanelList()

                        else
                            PopText("网络请求出错,请换个网络环境再试!")
                        end
                        PopupLayerController:hideLayer(
                            "GlobalShadeLayer",
                            function(layer)
                                layer:hideLayer()
                            end
                        )
                    end, IS_SHOW_WAITING)


                else
                    -- PopText("您所拥有的兑换物品数量不足。")
                end
            end
        )
    end

    local items_count = #self.ListView_Items:getItems()

    local data_count = #list_data

    if items_count > data_count then
        for i = items_count, data_count + 1, -1 do
            self.ListView_Items:removeItem(i - 1)
        end
    end
end

function ChongGuangDuiHuanLayer:createPanelItem()
    local panel = self.Panel_Item:clone()

    Helper:convertUIByParent(panel)

    return panel
end

--@desc: 设置panel控件的标题
--@author:Liang SongQiang
--@time:2019-01-12 16:30:29
--@panel: panel控件
--@title: 标题
function ChongGuangDuiHuanLayer:setPanelTitle(panel, title)
    panel.Text_Title:setString(title)
end

function ChongGuangDuiHuanLayer:setPanelSubText(panel, desc)
    panel.Text_Sub:setString(desc)
end

function ChongGuangDuiHuanLayer:setPanelButonFunc(panel, func)
    func = Helper:getDef(func, EMPTY_FUNC)
    panel.Button:releaseFunc(
        function()
            func()
        end
    )
end

function ChongGuangDuiHuanLayer:setTextEnableOutline(panel)
    panel.Button.Text_Name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
end

function ChongGuangDuiHuanLayer:setItemCount(panel, item_datas)
    item_datas = Helper:getDef(item_datas, {})

    local role = User:getRole()

    local richText = panel:getChildByTag(10000)

    if richText == nil then
        richText = self:createSubRichText(panel)
    end

    richText:getRichText():removeAllElement()
    local desc = ""
    for index, item_data in ipairs(item_datas) do
        local isNewLine = (index % 2) == 0 or true and false

        local item = role:getOneItemByKey(item_data.itemId)

        local itemName = item.name

        local needCount = item_data.count

        local hasCount = role:getItemCount(item.id)

        local hasCountStr = tostring(hasCount)
        if hasCount >= needCount then
            hasCountStr = "HIG" .. hasCount .. "NOR"
        else
            hasCountStr = "HIR" .. hasCount .. "NOR"
        end

        desc = desc .. itemName .. "(" .. hasCountStr .. "/" .. needCount .. ")"

        if isNewLine then
            desc = desc .. "\n"
        elseif desc ~= "" then
            desc = desc .. "    "
        end
    end
    
    self:delayFunc(0.2,function ()
        richText:pushBackText(desc, cc.c3b(255, 255, 255), 255, Resource:getFontPath("default"), 38)
    end)
end

function ChongGuangDuiHuanLayer:createSubRichText(panel)
    local richText = ExtRichTextScroll:create()

    panel:addChild(richText)

    richText:setSize({width = 640, height = 163})

    richText:setTag(10000)

    richText:move(cc.p(37, 19))

    richText:setVerticalSpace(5)
    
    richText:setDirection(kCCScrollViewDirectionVertical)

    return richText
end


--保底奖励相关
function ChongGuangDuiHuanLayer:isGuaranteedBonusFun(itemId)
    if "2020weekzj03" == itemId then 
        local role = User:getRole()
        local gameTimes = role:getInheritFlag("weekxzzy_gameTimes")     
        if gameTimes >=3 then
            local exChangItemId = "2020weekzjbd04"
            return exChangItemId
        end
    end
    return false
end

function ChongGuangDuiHuanLayer:guaranteedBonusFun(itemId)
    if "2020weekzj03" == itemId then 
        local role = User:getRole()
        local gameTimes = role:getInheritFlag("weekxzzy_gameTimes")     
        if gameTimes >=3 then
            role:setInheritFlag("weekxzzy_gameTimes",0)
            local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")
            ActivityCalendarUtils:getSpecialTitle("weekxzzy")
        else
            role:setInheritFlag("weekxzzy_gameTimes",gameTimes + 1)
        end
    end
end

function ChongGuangDuiHuanLayer:clearExChangeTimes()
    local list_data = Helper:getDef(config.exchangeItems, {})
    local role = User:getRole()
    local activity_times = role:getInheritFlag("hztc_activity_times")
    local currTimes = 33

    if activity_times < currTimes then
        for index, item_data in pairs(list_data) do
            role:setInheritFlag(item_data.flag, 0)
        end
        role:setInheritFlag("hztc_activity_times",currTimes)
    end
end

Helper:classDefNodeGetInstance(ChongGuangDuiHuanLayer)
return ChongGuangDuiHuanLayer
00000000
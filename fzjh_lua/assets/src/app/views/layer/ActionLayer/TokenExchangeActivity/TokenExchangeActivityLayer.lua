--@desc 2019-01-12 14:45:52 原重光兑换界面
local TokenExchangeActivityUtils = require("app.views.layer.ActionLayer.TokenExchangeActivity.TokenExchangeActivityUtils")
local TokenExchangeActivityLayer = class("TokenExchangeActivityLayer", LayerEx)

local config = {
}

function TokenExchangeActivityLayer:create()
    local p = TokenExchangeActivityLayer:new()
    p:init()
    return p
end

function TokenExchangeActivityLayer:init()
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

function TokenExchangeActivityLayer:showLayer(action)
    Helper:print_lua_table(action)
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

    self:setName(action.name)
    self:setDesc(str)
    self:showPanelList()
    self:show()
        
end

function TokenExchangeActivityLayer:hideLayer()
    PopupLayerController:hideLayer(
        "TokenExchangeActivityLayer",
        function(layer)
            layer:hide()
        end
    )
end

function TokenExchangeActivityLayer:setConfig()
    local role = User:getRole()
    local exchangeFlag = role:getInheritFlag("xinwu_Exchange_act")
    local exchangeStage,exchangeIndex = 1,1

    if exchangeFlag == 0  then
        exchangeStage = 1
    else
        exchangeFlag = string.split(exchangeFlag,";")
        exchangeStage,exchangeIndex = tonumber(exchangeFlag[1]),tonumber(exchangeFlag[2])
    end

    config = TokenExchangeActivityUtils:getConfig()
    TokenExchangeActivityUtils:sortTable(config)
    for i = 1,#config do
        config[i].rewardIndex = i
        if exchangeIndex > i then
            config[i].isReward = true
        end
    end
end

function TokenExchangeActivityLayer:setName(name)
    self.Text_Name:setString(tostring(name))
end

function TokenExchangeActivityLayer:setDesc(desc)
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

function TokenExchangeActivityLayer:showPanelList()
    self:setConfig()

    local list_data = Helper:getDef(config, {})

    local role = User:getRole()

    TokenExchangeActivityUtils:sortTable(list_data)

    for index, item_data in ipairs(list_data) do
        local panel = self.ListView_Items:getItem(index - 1)
        if panel == nil then
            panel = self:createPanelItem()
            self.ListView_Items:pushBackCustomItem(panel)
        end
        local exchangItemName = item_data.rewardName

        self:setPanelTitle(panel, exchangItemName)

        local exchangeFlag = role:getInheritFlag("xinwu_Exchange_act")

        local exchangeStage,exchangeIndex

        if exchangeFlag == 0  then
            exchangeStage,exchangeIndex = 1,1
        else
            exchangeFlag = string.split(exchangeFlag,";")
            exchangeStage,exchangeIndex = tonumber(exchangeFlag[1]),tonumber(exchangeFlag[2])
        end

        local needItemAttr = role:getOneItemByKey(item_data.needItemId)

        self:setPanelSubText(panel, "消耗"..item_data.needItemNum.."个"..needItemAttr.name.."兑换")

        self:setRewardInfo(panel, item_data.rewardText)

        self:setTextEnableOutline(panel)

        local isExchange = false

        if exchangeStage > item_data.rewardStage then
            isExchange = true
        elseif exchangeStage == item_data.rewardStage and exchangeIndex > item_data.rewardIndex then
            isExchange = true
        end

        self:setPanelButonFunc(
            panel,isExchange,
            function()
                if isExchange then
                    PopText("该奖励已兑换。")
                    return
                end

                if exchangeStage <= item_data.rewardStage and exchangeIndex < item_data.rewardIndex then
                    PopText("上一份奖励未兑换，当前奖励兑换失败。")
                    return
                end

                if role:checkCanBuyTwoOrMoreThings(item_data.rewardInfo,false) == false then
                    PopText("背包空间不足，兑换失败。")
                    return
                end

                if role:getItemCount(item_data.needItemId) < item_data.needItemNum then
                    PopText(needItemAttr.name.."不足，兑换失败。")
                    return
                end

                role:addItemCount(item_data.needItemId,0-item_data.needItemNum)
            
                if needItemAttr then
                    PopText("消耗"..needItemAttr.name.." X"..tostring(item_data.needItemNum))
                end

                for itemId, num in pairs(item_data.rewardInfo) do
                    local rewardItemAttr = role:getOneItemByKey(itemId)

                    if rewardItemAttr then
                        PopText("获得"..rewardItemAttr.name.." X"..tostring(num))
                    end

                    role:addItemCount(itemId,tonumber(num))
                end

                if item_data.maxIndexInStage then
                    --默认下阶段
                    role:setInheritFlag("xinwu_Exchange_act",tostring(item_data.rewardStage + 1)..";"..tostring(item_data.rewardIndex + 1))
                else
                    role:setInheritFlag("xinwu_Exchange_act",tostring(item_data.rewardStage)..";"..tostring(item_data.rewardIndex + 1))
                end

                item_data.isReward = true

                self:showPanelList()
                
            end 
        )
    end

    local items_count = #self.ListView_Items:getItems()

    if items_count > #list_data then
        for i = items_count, #list_data + 1, -1 do
            self.ListView_Items:removeItem(i - 1)
        end
    end

    self.ListView_Items:jumpToTop()
end

function TokenExchangeActivityLayer:createPanelItem()
    local panel = self.Panel_Item:clone()

    Helper:convertUIByParent(panel)

    return panel
end

--@desc: 设置panel控件的标题
--@author:Liang SongQiang
--@time:2019-01-12 16:30:29
--@panel: panel控件
--@title: 标题
function TokenExchangeActivityLayer:setPanelTitle(panel, title)
    panel.Text_Title:setString(title)
end

function TokenExchangeActivityLayer:setPanelSubText(panel, desc)
    panel.Text_Sub:setString(desc)
end

function TokenExchangeActivityLayer:setPanelButonFunc(panel, isExchange, func)
    if isExchange then
        panel.Button:loadTextureNormal("Image/UI/TaskUI/anniuhui.png",0)
    else
        panel.Button:loadTextureNormal("Image/UI/TaskUI/anniu.png",0)
    end
    func = Helper:getDef(func, EMPTY_FUNC)
    panel.Button:releaseFunc(
        function()
            func()
        end
    )
end

function TokenExchangeActivityLayer:setTextEnableOutline(panel)
    panel.Button.Text_Name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
end

function TokenExchangeActivityLayer:setRewardInfo(panel, rewardText)
    local richText = panel:getChildByTag(10000)

    if richText == nil then
        richText = self:createSubRichText(panel)
    end

    richText:getRichText():removeAllElement()
    
    local desc = "HIW"..rewardText
    
    richText:pushBackText(desc, cc.c3b(208, 208, 208), 255, Resource:getFontPath("default"), 38)

    self:delayFunc(0.2,function()
        richText:jumpToTop()
    end)

end

function TokenExchangeActivityLayer:createSubRichText(panel)
    local richText = ExtRichTextScroll:create()

    panel:addChild(richText)

    richText:setSize({width = 640, height = 163})

    richText:setTag(10000)

    richText:move(cc.p(37, 19))

    richText:setVerticalSpace(5)
    
    richText:setDirection(kCCScrollViewDirectionVertical)

    return richText
end

Helper:classDefNodeGetInstance(TokenExchangeActivityLayer)
return TokenExchangeActivityLayer
0
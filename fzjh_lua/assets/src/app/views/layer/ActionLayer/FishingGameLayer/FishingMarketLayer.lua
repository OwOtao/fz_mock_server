--鱼市界面
local FishingMarketLayer = class("FishingMarketLayer", cc.Layer)
local FishingGameUtil = require("app.models.Action.Fishing.FishingGameUtil")

function FishingMarketLayer:create()
	local p = FishingMarketLayer:new()
	p:init()
	return p
end

function FishingMarketLayer:init()
	self._UI = require("Layer/ActionUI/FishingGame/FishMarketUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

	self:setButtonBack()
    self:initRichText()
    self:initRichText2()
end

local fishList = {
    {
        str = "koifish",
        id = "101"
    },
    {
        str = "redfish",
        id = "102"
    },
    {
        str = "greenfish",
        id = "103"
    },
    {
        str = "blackfish",
        id = "104"
    },
    {
        str = "shrimp",
        id = "105"
    }
    }

function FishingMarketLayer:showLayer(funcType,shoppingFishList)
    if funcType == "exchangeFish" then  --兑换物品
        self:initAwardList()
    elseif funcType == "shoppingFish" then  --兑换金钱
        self:initPricesShopList(shoppingFishList)
    end
	self:setHaveDsc()
	self:show()
end

function FishingMarketLayer:setButtonBack()
	self.Button_5:releaseFunc(function()
		PopupLayerController:hideLayer("FishingMarketLayer", function(layer)
            layer:hide()
        end)
	end)
end

function FishingMarketLayer:initRichText()
	if self.rich_text ~= nil then
        self.rich_text:removeFromParent()
	end

	local x, y = self.Text_haveDsc:getPosition()
    local size = self.Text_haveDsc:getContentSize()

    self.rich_text = ExtRichTextScroll:create()

    self.Text_haveDsc:getParent():addChild(self.rich_text)
    self.rich_text:move(cc.p(x, y))
    self.rich_text:setSize(size)
    self.rich_text:setAnchorPoint(cc.p(0.5, 0.5))
    self.rich_text:setDirection(kCCScrollViewDirectionVertical)
    self.rich_text:getRichText():setVerticalSpace(20)
    self.rich_text:setTouchEnabled(false)
end

function FishingMarketLayer:setHaveDsc()
    local role = User:getRole()
    local fishTab = role:getInheritFlag("周活钓鱼玩法结果")
    local text = ""
    for i,v in ipairs(fishList) do
        local fishId = v.id
        local fishName = FishingGameUtil:getFishAttr(fishId).fishname
        local num = 0
        if type(fishTab)=="table" and fishTab[fishId] and type(fishTab[fishId]) == "number" then
            num = fishTab[fishId]
        end
        text = text..fishName.."X"..num.."  "
    end

    self.Text_haveDsc:setString("")
	self:initRichText()

	local textColor = cc.c3b(255, 255, 255)
    self.rich_text:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 46)
end

function FishingMarketLayer:initRichText2(panel)
    if panel == nil then
        panel = self.Panel_4
    end

	local x, y = panel.Text_dsc:getPosition()
    local size = panel.Text_dsc:getContentSize()

    self.rich_text2 = ExtRichTextScroll:create()

    panel.Text_dsc:getParent():addChild(self.rich_text2)
    self.rich_text2:move(cc.p(x, y))
    self.rich_text2:setSize(size)
    self.rich_text2:setAnchorPoint(cc.p(0.5, 0.5))
    self.rich_text2:setDirection(kCCScrollViewDirectionVertical)
    self.rich_text2:getRichText():setVerticalSpace(20)
    self.rich_text2:setTouchEnabled(false)
end

function FishingMarketLayer:setText_dsc(panel,text)
    panel.Text_dsc:setString("")
	self:initRichText2(panel)

	local textColor = cc.c3b(255, 255, 255)
    self.rich_text2:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 40)
end

function FishingMarketLayer:initAwardList()
	self.ListView_rewardList:removeAllItems()
	local awardList = FishingGameUtil:getAwardList()
    Helper:print_lua_table(awardList)
    for i,v in ipairs(awardList) do
        local panel = self:createPanel(v)
        
        self.ListView_rewardList:pushBackCustomItem(panel)
    end
end

function FishingMarketLayer:createPanel(awardAttr)
	local panel = self.Panel_4:clone()
	Helper:convertUIByParent(panel)
    
    panel.Text_name:setString(awardAttr.awardname)
    
    local needConsume = {} --需要消耗的物品列表
    local text = "消耗："
    for k,v in ipairs(fishList) do
        local fishName = FishingGameUtil:getFishAttr(v.id).fishname
        local num = tonumber(awardAttr[v.str]) or 0

        if num > 0 then
            needConsume[v.id] = num
            text = text..fishName.."X"..num.."  "
        end
    end

    self:setText_dsc(panel,text)
    panel:releaseFunc(function()
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(awardAttr.dec,"确定要兑换吗？")
        dialog:setRichText(awardAttr.dec)
        dialog:setButton1("确定", function()
            local result = true
            if not MapIsEmpty(needConsume) then
                for fishId ,num in pairs(needConsume) do
                    if FishingGameUtil:cheakFishIsEnough(fishId,num) == false then
                        result = false
                        break
                    end 
                end
            end
            if result == false then
                PopText("数量不足，无法兑换")
                return
            end

            local role = User:getRole()
            local extraAwardId = awardAttr.awardid
            print("奖励策略id  extraAwardId = ",extraAwardId)
            local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(
                extraAwardId,
                role:getAttr("exp"),
                role:getFinalAttr("luck"),
                role:getKongfu()
            )

            local estRewardList = {
                ["属性"] = {},
                ["物品"] = {}
            }

            if not MapIsEmpty(rewardArray) then
                for i, reward in ipairs(rewardArray) do
                    if reward.type == "物品" then
                        estRewardList["物品"][reward.id] = tonumber(reward.value)
                    elseif reward.type == "属性" then
                        estRewardList["属性"][reward.id] = tonumber(reward.value)
                    else
                        if DEBUG_MODE == 1 then
                            assert(false, "奖励策略奖励类型填写错误")
                        end
                    end
                end
            end
            --@desc 判断背包是否已满
            if not role:checkCanBuyTwoOrMoreThings(estRewardList["物品"]) then
                return false
            end

            --兑换消耗鱼类
            if not MapIsEmpty(needConsume) then
                for fishId ,num in pairs(needConsume) do
                    FishingGameUtil:fishExchange(fishId,num)
                end
            end

            self:setHaveDsc()

            local attrTab = estRewardList["属性"]
            local itemTab = estRewardList["物品"]
            if not MapIsEmpty(attrTab) then
                for attr,attrValue in pairs(attrTab) do
                    role:addAttr(attr,attrValue)
                    PopText("获得" .. role:getCHAttrName(attr) ..tostring(attrValue))
                end
            end
            if not MapIsEmpty(itemTab) then
                for itemId,itemValue in pairs(itemTab) do
                    local item = Item:getOneItemByKey(itemId)
                    if item then
                        local name = item.name
                        role:addItemCount(itemId, itemValue)
                        PopText("获得".. name.." x " .. itemValue)
                    else
                        assert(false,"物品不存在  itemId = "..itemId)
                    end
                end
            end
        end)
        dialog:setButton2("取消", function()
        end)
        dialog:setWeChatVisible(false)
    end)
	return panel
end
----------------------------------------
----卖鱼换钱
----------------------------------------
function FishingMarketLayer:initPricesShopList(shoppingFishList)
    self.ListView_rewardList:removeAllItems()
    local goodsInfoList = FishingGameUtil:getShopFishList()

    for i,v in pairs(goodsInfoList) do
        local isShopping=false
        for index,fishId in ipairs(shoppingFishList) do 
            if tonumber(fishId)==tonumber(v.id) then 
                isShopping=true
                break
            end
        end
        if isShopping then 
            local panel = self:createPricesShopPanel(v)
            self.ListView_rewardList:pushBackCustomItem(panel)
        end
    end
end

function FishingMarketLayer:createPricesShopPanel(goodsInfo)
    local panel = self.Panel_4:clone()
    Helper:convertUIByParent(panel)
    
    panel.Text_name:setString(goodsInfo.fishname)
    local fishPriceType="碎银"
    local text=""

    text="售卖"..goodsInfo.fishname.."可得："..tostring(goodsInfo.fishPrice)..fishPriceType
    panel.Text_dsc:setString(text)
    panel.Text_dsc:setColor(cc.c3b(255,255,255))
    panel:releaseFunc(function()
        if User:getRole():getDayFlag("卖鱼换钱次数")>=5 then 
            PopText("少侠，我这鱼篮装不下咯，明日再来吧。")
            return 
        end
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show()
        dialog:setRichText("渔夫：出售"..goodsInfo.fishname.."可获得"..tostring(goodsInfo.fishPrice)..fishPriceType.."，是否确定出售？")
        dialog:setButton1("确定", function()
            local result = true
            print("goodsInfo.id:",goodsInfo.id)
            if FishingGameUtil:cheakFishIsEnough(tostring(goodsInfo.id),1) == false then
                result = false
            end 
            if result == false then
                PopText("数量不足，无法出售")
                return
            end

            local role = User:getRole()

            --扣除鱼类数量
            FishingGameUtil:fishExchange(tostring(goodsInfo.id),1)

            self:setHaveDsc()
            PopText("你卖了"..goodsInfo.fishname.."，得到了"..tostring(goodsInfo.fishPrice)..fishPriceType.."。")
            role:addAttr("money",goodsInfo.fishPrice)
            RichPrint("main","YEL渔夫：多谢少侠，这些碎银你拿好。")
            RichPrint("main","你卖了"..goodsInfo.fishname.."，得到了"..tostring(goodsInfo.fishPrice)..fishPriceType.."。")
            role:setDayFlag("卖鱼换钱次数", role:getDayFlag("卖鱼换钱次数")+1)
        end)
        dialog:setButton2("取消", function()
            RichPrint("main","YEL渔夫：少侠可以把钓到鱼卖给我啊。")
        end)
        dialog:setWeChatVisible(false)
    end)
    return panel
end

Helper:classDefNodeGetInstance(FishingMarketLayer)
return FishingMarketLayer00000000000000
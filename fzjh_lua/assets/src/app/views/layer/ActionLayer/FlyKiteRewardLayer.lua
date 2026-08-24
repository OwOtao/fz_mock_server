--
-- Author: TanQinJian
-- Date: 2020-06-11 17:40:39
--
--
local FlyKiteRewardLayer = class("FlyKiteRewardLayer", cc.Layer)
local FishingGameUtil = require("app.models.Action.Fishing.FishingGameUtil")

function FlyKiteRewardLayer:create()
	local p = FlyKiteRewardLayer:new()
	p:init()
	return p
end

function FlyKiteRewardLayer:init()
	self._UI = require("Layer/ActionUI/FishingGame/FishMarketUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

	self:setButtonBack()
    self:initRichText()
    self:initRichText2()
end

function FlyKiteRewardLayer:showLayer()
    self:initAwardList()
	self:setHaveDsc()
	self:show()
end

function FlyKiteRewardLayer:setButtonBack()
	self.Button_5:releaseFunc(function()
		PopupLayerController:hideLayer("FlyKiteRewardLayer", function(layer)
            layer:hide()
        end)
	end)
end

function FlyKiteRewardLayer:initRichText()
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

function FlyKiteRewardLayer:setHaveDsc()
    local role = User:getRole()
    local num = role:getInheritFlag("weekhztc_liquan")
    local text = ""
    self.Text_haveDsc:setString("风鸢礼券 X"..tostring(num).."张")
	self:initRichText()
	self.Text_title:setString("风鸢兑换")
	local textColor = cc.c3b(255, 255, 255)
    self.rich_text:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 46)
end

function FlyKiteRewardLayer:initRichText2(panel)
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

function FlyKiteRewardLayer:setText_dsc(panel,text)
    panel.Text_dsc:setString("")
	self:initRichText2(panel)

	local textColor = cc.c3b(255, 255, 255)
    self.rich_text2:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 40)
end

function FlyKiteRewardLayer:initAwardList()
	self.ListView_rewardList:removeAllItems()
	local awardList = FishingGameUtil:getKiteRewardList()
    Helper:print_lua_table(awardList)
    for i,v in ipairs(awardList) do
        local panel = self:createPanel(v)
        
        self.ListView_rewardList:pushBackCustomItem(panel)
    end
end

function FlyKiteRewardLayer:createPanel(awardAttr)
	local panel = self.Panel_4:clone()
	Helper:convertUIByParent(panel)
    
    local needLiquan = awardAttr.number
    panel.Text_name:setString(awardAttr.awardname)
    
    local text = "消耗风鸢礼券："..tostring(needLiquan).."张"
    

    self:setText_dsc(panel,text)
    panel:releaseFunc(function()
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(awardAttr.dec,"确定要兑换吗？")
        dialog:setRichText(awardAttr.dec)
        dialog:setButton1("确定", function()
        	local role = User:getRole()
            local liquanNum = role:getInheritFlag("weekhztc_liquan")
            if liquanNum < needLiquan then 
            	PopText("数量不足，无法兑换")
            	return
            end

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

            role:setInheritFlag("weekhztc_liquan",role:getInheritFlag("weekhztc_liquan") - needLiquan)

            --记录消费的礼券
            local logTab = {}
            logTab["风鸢礼券"] = -needLiquan
            local Record = require("app.models.Record.Record")
            Record:addLog(Record.LOG_TYPE.ACTION_FLAG,logTab,"kite")

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

Helper:classDefNodeGetInstance(FlyKiteRewardLayer)
return FlyKiteRewardLayer00000000000000
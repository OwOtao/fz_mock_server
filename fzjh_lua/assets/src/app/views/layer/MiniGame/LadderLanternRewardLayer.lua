--
-- Author: TanQinJian
-- Date: 2019-10-30 14:21:56
--
--鱼市界面
local LadderLanternRewardLayer = class("LadderLanternRewardLayer", LayerEx)
local LadderLanternPaperUtil = require("app.models.LadderLantern.LadderLanternPaperUtil")

function LadderLanternRewardLayer:create()
	local p = LadderLanternRewardLayer:new()
	p:init()
	return p
end

function LadderLanternRewardLayer:init()
	self._UI = require("Layer/ActionUI/FishingGame/FishMarketUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	
	self.Text_title:setString("纸签兑换")
	self:setButtonBack()
    self:initRichText()
    self:initRichText2()
end

function LadderLanternRewardLayer:showLayer()
    LadderLanternPaperUtil:fixPaperData()
	self:setHaveDsc()
	self:initAwardList()
	self:show()
end

function LadderLanternRewardLayer:setButtonBack()
	self.Button_5:releaseFunc(function()
		PopupLayerController:hideLayer("LadderLanternRewardLayer", function(layer)
            layer:hide()
        end)
	end)
end

function LadderLanternRewardLayer:initRichText()
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

function LadderLanternRewardLayer:setHaveDsc()
    local role = User:getRole()
    local paperData = role:getInheritFlag("纸签数据")
    local text = ""
    if paperData == 0 then 
        paperData = {}
    end
    local allPaper = LadderLanternPaperUtil:getAllPaper()
    for index,paperInfo in pairs(allPaper) do
        local num = 0
        if paperData[tostring(paperInfo.id)] then 
            num = paperData[tostring(paperInfo.id)]
        end
        text = text..paperInfo.paperName.."X"..num.."  "
    end

    self.Text_haveDsc:setString("")
	self:initRichText()

	local textColor = cc.c3b(255, 255, 255)
    self.rich_text:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 46)
end

function LadderLanternRewardLayer:initRichText2(panel)
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

function LadderLanternRewardLayer:setText_dsc(panel,text)
    panel.Text_dsc:setString("")
	self:initRichText2(panel)

	local textColor = cc.c3b(255, 255, 255)
    self.rich_text2:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 40)
end

function LadderLanternRewardLayer:initAwardList()
	self.ListView_rewardList:removeAllItems()
	local awardList = LadderLanternPaperUtil:getAllReward()
    Helper:print_lua_table(awardList)
    for i,v in pairs(awardList) do
        local panel = self:createPanel(v)
        self.ListView_rewardList:pushBackCustomItem(panel)
    end
end

function LadderLanternRewardLayer:createPanel(awardAttr)
	local panel = self.Panel_4:clone()
	Helper:convertUIByParent(panel)
    
    panel.Text_name:setString(awardAttr.awardname)
    local text = "消耗："
    local paperNeedInfo =string.split(awardAttr.paperNeed,";")
    local needPaperTab = {}
    for index,needInfo in ipairs(paperNeedInfo) do 
    	local needTab = string.split(needInfo,",")
    	local paper = LadderLanternPaperUtil:getPaperInfo(tonumber(needTab[1]))
    	local needNum = needTab[2]
    	needPaperTab[needTab[1]] = tonumber(needTab[2])
    	text = text..paper.paperName.."X"..needNum.."  "
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
		    if MapIsEmpty(needPaperTab) then 
		    	print("LadderLanternRewardLayer:createPanel 检查纸签奖励获取条件")
		    	return 
		    end

		    for paperId, needNum in pairs(needPaperTab) do
		        if LadderLanternPaperUtil:checkPaperIsEnough(paperId,needNum) == false then
		            result = false
		            break
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

            --兑换消耗纸签
            if not MapIsEmpty(needPaperTab) then
                for paperId ,needNum in pairs(needPaperTab) do
                    LadderLanternPaperUtil:setRolePaperData(tonumber(paperId),-tonumber(needNum))
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


Helper:classDefNodeGetInstance(LadderLanternRewardLayer)
return LadderLanternRewardLayer000
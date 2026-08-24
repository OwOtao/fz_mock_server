local HeroFeastRewardsLayer = class("HeroFeastRewardsLayer", LayerEx)
local HeroFeastModel = require("app.models.Action.HeroFeast.HeroFeastModel")

function HeroFeastRewardsLayer:create()
	local p = HeroFeastRewardsLayer:new()
	p:init()
	return p
end
function HeroFeastRewardsLayer:init()
	local UI = require("Layer/ActionUI/HeroFeast/HeroFeastRewardsUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setVisible(false)
	self:setPanelBack()
	self:setButtonJump()
    self.currRewardTimes = nil --当前页面是第几次奖励
end

function HeroFeastRewardsLayer:showLayer(actionId)
    self.currRewardTimes = 1

	self:setActionTime(actionId)

end

function HeroFeastRewardsLayer:setActionTime(actionId)
	self.actionId = actionId
	HttpManagerEx:getActionState(actionId,nil,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
			self.Text_desc:setString("活动分为两阶段。第一阶段（2月4日~2月10日）可从年货盗匪身上获取年货、准备英雄宴席举办需要的食材。第二阶段（2月11日~2月24日），除夕至大年初六每日可举办一场宴席，会有神秘江湖人士与你共度春节，还可领取相应奖励。奖励内容将会保留至2月24日，逾时将会被移除，请及时领取。活动详情请见公告。")
			self:setNowPanelAndNextPanel()
			self:setRewardPanel()
			self:initHeadAndRewards()
			self:show()
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end

function HeroFeastRewardsLayer:setPanelBack()
	self.Button_back:releaseFunc(function()
		self:hideLayer()
	end)
end

function HeroFeastRewardsLayer:setButtonJump()
	self.Button_jump:releaseFunc(function()
		PopupLayerController:showLayer(
            "HeroFeastThreePhaseLayer",
            function(layer)
                layer:showLayer()
            end
        )
	end)
end

function HeroFeastRewardsLayer:hideLayer()
    self:hide()
    self:destroyInstance()
end

function HeroFeastRewardsLayer:setNowPanelAndNextPanel()
    self._nowPanel = clone(self.Panel_kuang.Panel_1)
    self._nextPanel = clone(self.Panel_kuang.Panel_2)
end

function HeroFeastRewardsLayer:setRewardPanel(tag)
	if tag == nil then
        self:initPanel(self._nowPanel)
	elseif tag == "left" then
		self._nextPanel:setPosition(-400,215)
		self:initPanel(self._nextPanel)
	elseif tag == "right" then
		self._nextPanel:setPosition(1200,215)
        self:initPanel(self._nextPanel)
	end 
	self:createActionByTag(tag)

    self:setLeftButton()
    self:setRightButton()
end

function HeroFeastRewardsLayer:createActionByTag(tag)
	self.Panel_right:setTouchEnabled(false)
	self.Panel_left:setTouchEnabled(false)
	-- self.Button_TotalPrize:setTouchEnabled(false)
	local movePos 
	if tag == "left" then
		movePos = cc.p(1200,215)
	elseif tag == "right" then
		movePos = cc.p(-400,215)
	else
		self.Panel_right:setTouchEnabled(true)
		self.Panel_left:setTouchEnabled(true)
		-- self.Button_TotalPrize:setTouchEnabled(true)
		return 
	end
	local time = 0.5
	local action = nil

	if false then
		action = cc.Sequence:create(cc.Spawn:create(cc.CallFunc:create(function()
			self._nowPanel:runAction(cc.MoveTo:create(time, movePos))
		end),cc.CallFunc:create(function()
			self._nextPanel:runAction(cc.MoveTo:create(time, cc.p(400,215)) )
		end)),cc.CallFunc:create(function()
        	local tmpPanel = self._nextPanel
        	self._nextPanel = self._nowPanel
        	self._nowPanel = tmpPanel
		end))

	else
		action = cc.Sequence:create(cc.Spawn:create(cc.CallFunc:create(function()
				self._nowPanel:runActionWithName("move", 
					YXEaseAction:create( cc.Spawn:create(
							cc.MoveTo:create(time, movePos) ,
							cc.FadeOut:create(time)
						),  Expo_EaseOut ) )
	        end),cc.CallFunc:create(function()

				self._nextPanel:runActionWithName("move", 
					YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(time, cc.p(400,215)) ,
						cc.FadeIn:create(time)
					),  Expo_EaseIn ) )

	        end)),cc.CallFunc:create(function()
	        	local tmpPanel = self._nextPanel
	        	self._nextPanel = self._nowPanel
	        	self._nowPanel = tmpPanel
	        end)

		)
	end
	self:runActionWithName("move", action)
	self:delayFunc(time,function()
		self.Panel_right:setTouchEnabled(true)
		self.Panel_left:setTouchEnabled(true)
	end)
end

function HeroFeastRewardsLayer:setLeftButton()
	if self.currRewardTimes <= 1 then
		self.Panel_left:releaseFunc(function()
		end)
	else
		self.Panel_left:releaseFunc(function()
            self.currRewardTimes = self.currRewardTimes - 1
			self:setRewardPanel("left")
			self:initHeadAndRewards()
		end)
	end
end

function HeroFeastRewardsLayer:setRightButton()
	if self.currRewardTimes >= 7 then
		self.Panel_right:releaseFunc(function()
		end)
	else
		self.Panel_right:releaseFunc(function()
            self.currRewardTimes = self.currRewardTimes + 1
			self:setRewardPanel("right")
			self:initHeadAndRewards()
		end)
	end
end

--渲染当前panel
function HeroFeastRewardsLayer:initPanel(Panel)
    local currRewardList  = self:getCurrRewardList()
    Panel.Text_Tital1:setString(currRewardList.name)
    Panel.Text_desc1:setString(currRewardList.introText)
    Panel.Text_date:setString(currRewardList.day)
end

--获得当前页面的渲染数据
function HeroFeastRewardsLayer:getCurrRewardList()
    local currRewardTimes = self.currRewardTimes
    local data = HeroFeastModel:getHeroFeastDataByTime(currRewardTimes)
    
    return data
end

--初始化头像和奖励
function HeroFeastRewardsLayer:initHeadAndRewards()	
	self.Image_head:loadTexture("Image/UI/AttrUI/mianju/shenmiman.png")
	self.Image_head1:loadTexture("Image/UI/AttrUI/mianju/shenmiwoman.png")
	self.Button_Reward:setEnabled(false)
	self.Button_Reward1:setEnabled(false)

	self.Text_desc2:setString("  宴席未举行，可能参加宴席的有：")
	local role = User:getRole()
	local flag = role:getInheritFlag("2021英雄宴奖励")
	if DEBUG_MODE ==1 then
		Helper:print_lua_table(flag)
	end
	local currRewardTimes = tostring(self.currRewardTimes)
	if type(flag) == "table" and flag[currRewardTimes] then
		local wineId = flag[currRewardTimes].wineId
		local currRewardList  = self:getCurrRewardList()
		Helper:print_lua_table(currRewardList)
		local heroIdStr = currRewardList[wineId]
		local heroIdList = string.split(heroIdStr,";")
		local heroId1 = heroIdList[1]
		local heroId2 = heroIdList[2]
		local nameText = ""
		if heroId1 then
			local heroAttr = HeroFeastModel:getHeroAttr(heroId1)
			local awardId = heroAttr.award
			nameText = heroAttr.name
			self.Image_head:loadTexture(heroAttr.pic)
			if flag[currRewardTimes].isReceive1 == false then
				self.Button_Reward:setEnabled(true)
				self.Button_Reward:releaseFunc(function()
					if self:checkBagIsEnough(awardId) then
						self:getRewards(awardId)
						flag[currRewardTimes].isReceive1 = true
						self:initHeadAndRewards()
					end
				end)
			end
		end
		if heroId2 then
			local heroAttr = HeroFeastModel:getHeroAttr(heroId2)
			local awardId = heroAttr.award
			nameText = nameText.."和"..heroAttr.name
			self.Image_head1:loadTexture(heroAttr.pic)

			if flag[currRewardTimes].isReceive2 == false then
				self.Button_Reward1:setEnabled(true)
				self.Button_Reward1:releaseFunc(function()
					if self:checkBagIsEnough(awardId) then
						self:getRewards(awardId)
						flag[currRewardTimes].isReceive2 = true
						self:initHeadAndRewards()
					end
				end)
			end
		else
			
		end
		self:setButtonAndHeadPos(heroId1,heroId2)
		self.Text_desc2:setString(  "宴席已结束，"..nameText.."来参加你的宴席，对你盛情招待表示感谢，留下了一份答谢礼。")
	else
		self:setButtonAndHeadPos()
    end
end

function HeroFeastRewardsLayer:setButtonAndHeadPos(heroId1,heroId2)
	if (heroId1 and heroId2) or (not heroId1 and not heroId2) then
		self.Button_Reward1:setVisible(true)
		self.Image_di1:setVisible(true)
		self.Image_head1:setVisible(true)
		self.Image_frame1:setVisible(true)

		self.Image_di:setPosition(308,457) 
		self.Image_head:setPosition(308,457)
		self.Image_frame:setPosition(308,457)
		self.Button_Reward:setPosition(309,181)
		self.Image_di1:setPosition(772,457)
		self.Image_head1:setPosition(772,457)
		self.Image_frame1:setPosition(772,457)
		self.Button_Reward1:setPosition(771,181)
	else
		self.Button_Reward1:setVisible(false)
		self.Image_di1:setVisible(false)
		self.Image_head1:setVisible(false)
		self.Image_frame1:setVisible(false)

		self.Image_di:setPosition(540,457) 
		self.Image_head:setPosition(540,457)
		self.Image_frame:setPosition(540,457)
		self.Button_Reward:setPosition(540,181)
	end
end

--检查背包能否放的下
function HeroFeastRewardsLayer:checkBagIsEnough(awardId)
	if awardId == nil then
		return false
	end
	local role = User:getRole()
	local rewardArray=RewardManager:getRewardArrayWithRewardScheme(awardId,role:getAttr("exp"), role:getFinalAttr("luck"), role:getKongfu())
	local itemTab = {}
	for i, reward in ipairs(rewardArray) do
		if reward.type == "物品" then
			if itemTab[reward.id] then
				itemTab[reward.id] = itemTab[reward.id] + reward.value
			else
				itemTab[reward.id] = reward.value
			end
		end
	end

	if role:checkCanBuyTwoOrMoreThings(itemTab) == true then
		return true
	end

	return false
end

--领取奖励
function HeroFeastRewardsLayer:getRewards(awardId)
    if awardId == nil then
		return
	end
	local role = User:getRole()
	local rewardArray=RewardManager:getRewardArrayWithRewardScheme(awardId,role:getAttr("exp"), role:getFinalAttr("luck"), role:getKongfu())
	for i, reward in ipairs(rewardArray) do
		if reward.type == "物品" then
			role:addItemCount(reward.id, reward.value)
			PopText("获得 " .. Item:getOneItemByKey(reward.id).name .. " x " .. reward.value)
		elseif reward.type == "属性" then
			if type(role:getCHAttrName(reward.id)) == "string" then
				PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
			end
			role:addAttr(reward.id, reward.value) 
		end
	end

end

Helper:classDefNodeGetInstance(HeroFeastRewardsLayer)

return HeroFeastRewardsLayer000000000
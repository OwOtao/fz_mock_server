local LaBaChongZhiChouJiangLayer = class("LaBaChongZhiChouJiangLayer", LayerEx)

--位置
local posList = {
    [1] = {
        x = 210,
        y = 573
    },
    [2] = {
        x = 750,
        y = 573
    },
    [3] = {
        x = 210,
        y = 358
    },
    [4] = {
        x = 750,
        y = 358
    },
    [5] = {
        x = 210,
        y = 143
    },
    [6] = {
        x = 750,
        y = 143
    },
    -- [7] = {
    --     x = 250,
    --     y = 200
    -- },
    -- [8] = {
    --     x = 750,
    --     y = 200
    -- },
}

-- local StoreLayer = require("app.views.layer.StoreLayer.StoreLayer")
function LaBaChongZhiChouJiangLayer:create()
	local p = LaBaChongZhiChouJiangLayer:new()
	p:init()
	return p
end

function LaBaChongZhiChouJiangLayer:init()
	local UI = require("Layer/ActionUI/LaBaChongZhiChouJiangUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

	self.Button_close:releaseFunc(function()
		self:hide()
		self:destroyInstance()  --  弹出类窗口,隐藏时删除自身
	end)
	
	self.Panel_ItemInfo:releaseFunc(
        function()
            self.Panel_ItemInfo:setVisible(false)
        end
	)
end

function LaBaChongZhiChouJiangLayer:showLayer(action)

	local timeStartStr =Helper:getTimeStrCNFormat(action["start"])
    local timeEndStr = Helper:getTimeStrCNFormat(action["end"])

    local detail_desc_list = action.detail_desc

    local str = ""

    for i,desc in ipairs(detail_desc_list) do
        desc = string.gsub(desc,"#start#",timeStartStr)
        desc = string.gsub(desc,"#end#",timeEndStr)
        str = str .. desc .. "\n"
    end

	self.actionId = action.id
	self:setDesc(str)
	self:setTextStr()
	self.Text_title:setString(action.name)
	self:getNultiFestivalGiftList()
	self:show()
end

function LaBaChongZhiChouJiangLayer:setDesc(desc)
    local richText = self:getChildByTag(10001)
	if richText == nil then
		local x, y = self.Text_5:getPosition()
		local size = self.Text_5:getContentSize()
        richText = ExtRichTextScroll:create()
		richText:setSize(size)
		richText:setAnchorPoint(0.5,0.5)
        richText:move(cc.p(x, y))
        richText:setTag(10001)
        self:addChild(richText)
        richText:setVerticalSpace(5)
        richText:setDirection(kCCScrollViewDirectionVertical)
    else
        richText:getRichText():removeAllElement()
	end
	richText:setTouchEnabled(false)
    richText:pushBackText(desc, cc.c3b(208, 208, 208), 255, Resource:getFontPath("default"), 42)
end

function LaBaChongZhiChouJiangLayer:getNultiFestivalGiftList()--初始化界面
	HttpManagerEx:getYuanbaoLotteryList(function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 then
			if errcode == 0 then
				self.dailyTimes = data.lottery_daily_times --今日已抽奖次数
				self.dailyLimitTimes = data.lottery_limit
				self.removeYb = data.removeYb
				self.currYb = data.yuanbao
				self:setDailyTimesText(data.lottery_daily_times)
				self:setAllTimesText(data.lottery_total_times)
				self:setRewardPanel(data) --初始化奖励界面
				self:setButtonTotalPrize(data)--设置抽奖按钮
				self:setshowAllRewardList(data.lottery_items)
			else
				PopText(errmsg)
			end
		end
	end, IS_SHOW_WAITING)
end

function LaBaChongZhiChouJiangLayer:setDailyTimesText(times)
	self.Text_todaySign:setString("本日抽奖次数："..tostring(times))
end

function LaBaChongZhiChouJiangLayer:setAllTimesText(times)
	self.Text_totalSign:setString("历史抽奖次数："..tostring(times))
end

function LaBaChongZhiChouJiangLayer:setRewardPanel(data)
	self.Panel_1.Panel_kuang:removeAllChildren()
    for k, v in ipairs(data.list) do
        local panel = self:createPanel(v)
        panel:addTo(self.Panel_1.Panel_kuang)
        panel:setPosition(posList[k].x,posList[k].y)
    end
end
function LaBaChongZhiChouJiangLayer:createPanel(list)
    list = Helper:getDef(list,{})
	local panel = self:clonePanel()
	self:setPanel(panel,list)
	return panel
end

function LaBaChongZhiChouJiangLayer:clonePanel()
	local panel = self.Panel_item:clone()
	Helper:convertUIByParent(panel)
	panel.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	return panel
end

function LaBaChongZhiChouJiangLayer:setPanel(panel,list)
	if not panel then
		return
	end
	list = Helper:getDef(list,{})
	panel.Image_zhuzi:loadTexture(list.icon,0)
	panel.Text_name:setString(list.name)
	if list.nameDes == nil then
		panel.Text_NameDdes:setVisible(false)
	end
	panel.Text_num:setString(tostring(list.number))
	panel:releaseFunc(function()
			self.Panel_ItemInfo:maxZ()
		
			self.Panel_ItemInfo:setVisible(true)
		
			self.Panel_ItemInfo.Image_back.Panel_title.Text_name:setString(list.name)
		
			self.Panel_ItemInfo.Image_back.Panel_title.Text_zhuangbei:setString(list.itemType)
		
			self.Panel_ItemInfo.Image_back.Text_desc:setString(list.dsc1)
	end)
end

function LaBaChongZhiChouJiangLayer:setTextStr()
	self.Text_3:setVisible(false)
	local richText = self:getChildByTag(10002)
	if richText == nil then
		local x, y = self.Text_3:getPosition()
		local size = self.Text_3:getContentSize()
        richText = ExtRichTextScroll:create()
		richText:setSize(size)
		richText:setAnchorPoint(0.5,0.5)
        richText:setPosition(x,y)
		richText:setTag(10002)
		richText:setScrollBarEnabled(false)
		self.Text_3:getParent():addChild(richText)
        richText:setVerticalSpace(5)
        richText:setDirection(kCCScrollViewDirectionVertical)
    else
        richText:getRichText():removeAllElement()
	end
	richText:setTouchEnabled(true)

	richText:pushBackText("点击查看RED所有奖励NOR>>", cc.c3b(94, 129, 154), 255, Resource:getFontPath("default"), 42)

	richText:releaseFunc(function()
		self.RewardsShowPanel:maxZ()
		self.RewardsShowPanel:setVisible(true)
	end)
end

--展示奖励池
function LaBaChongZhiChouJiangLayer:setshowAllRewardList(list)
	if MapIsEmpty(list) == false then
		for i, v in ipairs(list) do
			local item_panel = self.RewardsShowPanel.ListView_1:getItem(i - 1)
			local listView = self.RewardsShowPanel.ListView_1
			if item_panel == nil then
				item_panel = self.RewardsShowPanel.ItemInfoPanel:clone()
				listView:pushBackCustomItem(item_panel)
			end
			
			Helper:convertUIByParent(item_panel)
			
			item_panel.Text_Name:setColor({r = 184, g = 184, b = 184})

			item_panel.Text_Count:setColor({r = 184, g = 184, b = 184})

			item_panel.Text_Pr:setColor({r = 184, g = 184, b = 184})

			item_panel.Text_Name:setString(Helper:getNoColorStr(v.name))

			item_panel.Text_Count:setString(v.num)

			item_panel.Text_Pr:setString(v.prob)
		end

		local row_count = #self.RewardsShowPanel.ListView_1:getItems()
		if row_count - #list > 0  then
			for i=row_count-1,#list,-1 do
				self.RewardsShowPanel.ListView_1:removeItem(i)
			end
		end
	end

	self.RewardsShowPanel.ListView_1:setTouchEnabled(false)

	self.RewardsShowPanel:releaseFunc(
        function()
            self.RewardsShowPanel:setVisible(false)
        end
    )
end

function LaBaChongZhiChouJiangLayer:checkCanLottery()
	if self.dailyTimes and self.dailyLimitTimes and self.dailyTimes > self.dailyLimitTimes then
		PopText("当日抽奖次数已达上限，少侠可明天再来。")
		return false
	end

	if self.currYb < self.removeYb then
		PopText("元宝不足。")
		return false
	end

	local role = User:getRole()
	if role:getAttr("weight") - #role:getItems()  < 3 then
		PopText("背包空间不足，请及时清理。")
		return false
	end

	return true
end

-- @desc 设置抽奖按钮
function LaBaChongZhiChouJiangLayer:setButtonTotalPrize(data)
    local role = User:getRole()

	self.Button_TotalPrize:releaseFunc(function()
		if self:checkCanLottery() then
			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			local dialog = DialogALayer:getInstance()
			dialog:hide()
			local text = "本日已抽奖"..tostring(self.dailyTimes).."次，本次抽奖将扣除"..tostring(self.removeYb).."元宝，是否确定抽奖。"

			if self.dailyTimes == 0 then
				text = "本日尚未抽奖，本次抽奖免费，是否确定抽奖。"
			end
			
			dialog:show(text)
			dialog:setButton1("确定",function()
				HttpManagerEx:doYuanbaoLottery(function(status, errcode, errmsg, data, isEncrypted)
					if status == 200 then
						if errcode == 0 then
							if self.removeYb > 0 then
								PopText("消耗"..tostring(self.removeYb).."元宝")
							end
							self.dailyTimes = data.lottery_daily_times --今日已抽奖次数
							self.dailyLimitTimes = data.lottery_limit
							self.removeYb = data.removeYb
							self.currYb = data.yuanbao
							self:setDailyTimesText(data.lottery_daily_times)
							self:setAllTimesText(data.lottery_total_times)
							self:getReward(data)
						else
							PopText(errmsg)
						end
					end
				end, IS_SHOW_WAITING)
			end)
			dialog:setButton2("取消",function()end)
			dialog:setWeChatVisible(false)
		end
    end)
end

function LaBaChongZhiChouJiangLayer:getReward(data)
	for k,reward in pairs(data) do
		if MapIsEmpty(reward) == false and reward.itemId ~= nil then
			local item = User:getRole():getOneItemByKey(reward.itemId)
			if item ~= nil then
				User:getRole():addItemCount(reward.itemId,reward.number)
				PopText("获得物品 "..item.name.."X"..tostring(reward.number))		
			else
				PopText("获得 "..reward.name.."X"..tostring(reward.number))	
			end
		end
	end
end

Helper:classDefNodeGetInstance(LaBaChongZhiChouJiangLayer)

return LaBaChongZhiChouJiangLayer0000000000
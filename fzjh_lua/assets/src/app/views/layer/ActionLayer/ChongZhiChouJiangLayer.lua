local ChongZhiChouJiangLayer = class("ChongZhiChouJiangLayer", LayerEx)
-- local StoreLayer = require("app.views.layer.StoreLayer.StoreLayer")
function ChongZhiChouJiangLayer:create()
	local p = ChongZhiChouJiangLayer:new()
	p:init()
	return p
end

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


function ChongZhiChouJiangLayer:init()
	local UI = require("Layer/ActionUI/ChongZhiChouJiangUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

	self:setButtonCloseAndGoToPay()
	
	self.Button_1:releaseFunc(function ()
		self:getNultiFestivalGiftList("Y")
	end)

	self.Panel_ItemInfo:releaseFunc(
        function()
            self.Panel_ItemInfo:setVisible(false)
        end
    )
end

function ChongZhiChouJiangLayer:showLayer(action)

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
	self.Text_title:setString(action.name)
	self:getNultiFestivalGiftList()
	self:show()
end

function ChongZhiChouJiangLayer:setDesc(desc)
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

function ChongZhiChouJiangLayer:setRewardPanel(data)
    self.Panel_1.Panel_kuang:removeAllChildren()
    for k, v in ipairs(data.list) do
        local panel = self:createPanel(v)
        panel:addTo(self.Panel_1.Panel_kuang)
        panel:setPosition(posList[k].x,posList[k].y)
    end
end
function ChongZhiChouJiangLayer:createPanel(list)
    list = Helper:getDef(list,{})
	local panel = self:clonePanel()
	self:setPanel(panel,list)
	return panel
end

function ChongZhiChouJiangLayer:clonePanel()
	local panel = self.Panel_item:clone()
	Helper:convertUIByParent(panel)
	return panel
end

function ChongZhiChouJiangLayer:setPanel(panel,list)
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


-- @desc 设置关闭按钮和去充值
function ChongZhiChouJiangLayer:setButtonCloseAndGoToPay()
	self.Button_close:releaseFunc(function()
		self:hide()
		self:destroyInstance()  --  弹出类窗口,隐藏时删除自身
	end)
	self.Button_toPay:releaseFunc(function()
		MainControllLayer:pushLayer("StoreLayer")
		local StoreLayer=MainControllLayer:getLayer("StoreLayer")
		StoreLayer:showWithAction(function()
			self:getNultiFestivalGiftList()
			self:show()
		end)
		self:hide()
	end)
end

function ChongZhiChouJiangLayer:setRefresh(str)
	self.Text_1:setString(str)
end

-- @desc 初始化界面
function ChongZhiChouJiangLayer:getNultiFestivalGiftList(isRefresh)--初始化界面
	Order:checkOrderInfoWithUserid() --检查是否有订单未处理成功, 后台静默处理,无任何交互
	isRefresh = Helper:getDef(isRefresh,"N")
	HttpManagerEx:getPayLotteryGiftList(isRefresh,function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 then
			if errcode == 0 then
				self:setLoadingBar(data)--设置充值进度条
				self:setRewardPanel(data) --初始化奖励界面
				self:setButtonTotalPrize(data)--设置抽奖按钮
				self:setshowAllRewardList(data.lottery_items)
				self:setRefresh("花费"..data.removeYb.."元宝刷新当前奖励池")
				if tonumber(data.costYb) > 0 then
					PopText("元宝 -"..data.costYb)
				end

			else
				PopText(errmsg)
			end
		end
	end, IS_SHOW_WAITING)
end

--展示奖励池
function ChongZhiChouJiangLayer:setshowAllRewardList(list)
	self.Text_3:releaseFunc(function()	
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

				item_panel.Text_Name:setString(Helper:getNoColorStr(v.name))

				item_panel.Text_Count:setString(v.number)
			end
	
			local row_count = #self.RewardsShowPanel.ListView_1:getItems()
			if row_count - #list > 0  then
				for i=row_count-1,#list,-1 do
					self.RewardsShowPanel.ListView_1:removeItem(i)
				end
			end
		end 

		self.RewardsShowPanel:maxZ()
		self.RewardsShowPanel:setVisible(true)
	end)

	self.RewardsShowPanel:releaseFunc(
        function()
            self.RewardsShowPanel:setVisible(false)
        end
    )
end



-- @desc 设置充值进度条
function ChongZhiChouJiangLayer:setLoadingBar(data)
	if MapIsEmpty(data) == true then
		return
	end
	local num = data.lottery_times --今日已抽奖次数
	local limitcount = data.lottery_limit --抽奖限制次数

    self.LoadingBar.Text_TotalDayName:setString(num.."/"..limitcount)
	self.LoadingBar:setPercent((num/limitcount)*100)
end

-- @desc 设置抽奖按钮
function ChongZhiChouJiangLayer:setButtonTotalPrize(data)
    local role = User:getRole()
    local count = data.lottery_valid_times  --剩余抽奖次数
    local num = data.lottery_times --今日已抽奖次数
	if count < 1 then
		self.Button_TotalPrize:setEnabled(false)
	else
		self.Button_TotalPrize:setEnabled(true)
	end
    self.Button_TotalPrize:releaseFunc(function()
		if #role:getItems() + 2 <= role:getAttr("weight") then
			self:receiveReward(data.order_id)
		else
			PopText("背包格子不足！")
		end
    end)
end

function ChongZhiChouJiangLayer:receiveReward(order_id)
	HttpManagerEx:getPayLotteryGift(order_id,function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 and errcode == 0 then
			self:getReward(data)
			self:getNultiFestivalGiftList()
		else
			PopText(errmsg)
			self.Button_TotalPrize:setTouchEnabled(true)
		end
	end,IS_SHOW_WAITING)
end

function ChongZhiChouJiangLayer:getReward(data)
	local list = data
	for k,v in pairs(list) do 
		if v.itemId ~= nil then
			local item = User:getRole():getOneItemByKey(v.itemId)
			if item ~= nil then
				User:getRole():addItemCount(v.itemId,v.number)
				PopText("获得物品 "..item.name.."X"..tostring(v.number))		
			else
				PopText("获得 "..v.name.."X"..tostring(v.number))	
			end
		end
	end
	
end


Helper:classDefNodeGetInstance(ChongZhiChouJiangLayer)

return ChongZhiChouJiangLayer000
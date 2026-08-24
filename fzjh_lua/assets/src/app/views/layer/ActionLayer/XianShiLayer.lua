local XianShiLayer = class("XianShiLayer", LayerEx)

function XianShiLayer:create()
	local p = XianShiLayer:new()
	p:init()
	return p
end

function XianShiLayer:init()
	local UI = require("Layer/ActionUI/XianShiLiBaoUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self.surplusTime = 0		-- 礼包到期时间
	self.surplusCount = 0		-- 礼包剩余购买次数

	self:setBack()
	self:setButton()

	-- 更新剩余时间
	self:schedule(
	function(dt)
		self:UpdateTimeAndCount(dt)
	end, 1)
end

function XianShiLayer:setBack()
	self.Panel_back:releaseFunc(function()
		if self.Image_help:isVisible() == true then
			self:hidePopDsc()
		else
			self.Button_confirm_0:setVisible(false)
			self:hide()
			self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
		end
	end)
end

-- 更新时间
function XianShiLayer:UpdateTimeAndCount(dt)
	local overTime = self.surplusTime
	local currTime = GetTime()
	--local endTime = Helper:getTimeStampWithStringDate("20170212",0)
	if currTime >= overTime then
		self.Text_Time:setString("活动已经结束")
		self.Text_Count:setString("剩余0个")
		self.Text_Count:setString("")
		return
	end
	local year, month, day, hour, minute, second = Helper:getExpiredTime(overTime, currTime)

	if month ~= 0 then
		self.Text_Time:setString(month .. "月" .. day .. "天" .. hour .. "小时" .. minute .. "分" .. second .. "秒")
	else
		self.Text_Time:setString(day .. "天" .. hour .. "小时" .. minute .. "分" .. second .. "秒")
	end

	self.Text_Count:setString("剩余" .. self.surplusCount .. "个")
	-- self.Text_Count:setString("次数不限")
end

-- 获取限时礼包状态
function XianShiLayer:getState()
	self.Button_confirm_0:setVisible(true)

	-- data.baoxiang
	-- {
	--     "list": {
	--         "jiu106":2,
	--         "chunjie502":1,
	--         "qiannengdan":8,
	--         "jingxinwan":6,
	--         "dundifu":10,
	--         "jiu107":4
	--     },
	--     "time": {
	--         "start": "TIMESTAMP",
	--         "end": "TIMESTAMP"
	--     },
	--     "price": {
	--         "original": 3680,
	--         "total": 688
	--     },
	--     "beyond": "535%",
	--     "limit": 12,
	--     "left": 10
	-- }

	-- 醉梦生	jiu106	2
	-- 武功秘典	chunjie504	1
	-- 潜能丹	qiannengdan	6
	-- 静心丸	jingxinwan	5
	-- 掘金铲	juejinchan	1
	-- 清风醉	jiu107	4
	-- 真气丹	jingmai101	4
	-- 渡元丹	jingmai105	1
	-- 道具原始价格	3680元宝
	-- 道具总价	688元宝
	-- 道具限定购买数量	24
	-- 道具超值额度	535%

	self.surplusTime = 0
    self.surplusCount = 0

    -- 道具列表
	self.itemList = {}
	-- 原价
	self.originalPrice = 0
	-- 折后价格
	self.discountPrice = 0
	-- 优惠价格
	self.discount = 0
	-- 购买上限
	self.limit = 0

	-- 武功秘典*1	2000	chunjie504	1
	-- 天香玉露*5	250	tianxiangyulu1	5
	-- 福禄寿酒*1	500	zuoyouhubo1	1
	-- 清风醉*4	400	jiu107	4
	-- 洗颜水*1	50	xiyanshui	1
	-- 潜能丹*5	300	qiannengdan	5
	-- 真气丹*6	180	jingmai101	6
	-- 静心丸*5	250	jingxinwan	5
	-- 总价值	3930


	local list = {
		-- chunjie504 = 1,
		-- tianxiangyulu1 = 5,
		-- menpaicanye3 = 1,
		-- jingmai103 = 10,
		-- jiu106 = 2,
		-- qiannengdan = 5,
		-- jingmai101 = 5,	
		-- jingxinwan = 5,

		-- jingmai102 = 1,
		-- zuoyouhubo2 = 2,
		-- jiu107 = 1,
		chunjie504 = 1,
		menpaicanye3 = 1,
		jingmai103 = 15,
		jiu106 = 2,
		jiu107 = 2,
		qiannengdan = 5,
		jingmai101 = 5,
		jingxinwan = 5

	}
	local price = {
		original = 3975,
		total =  688
	}
	self.flag = true
	local beyond = 578
	local limit = 15
	local currDate = tonumber(Helper:date("%Y%m%d",GetTime()))
	if currDate < 20171001 then
		list = {
			chunjie504 = 1,
			tianxiangyulu1 = 5,
			jingmai102 = 1,
			zuoyouhubo2 = 2,
			jiu107 = 1,
			jiu106 = 2,
			qiannengdan = 5,
			jingmai101 = 5,	
			jingxinwan = 5,
		}
		price = {
			original = 3800,
			total =  688
		}
		self.flag = false
		beyond = 552
		limit = 12
	end
	HttpManagerEx:getNewYearFestivalState(3,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
            	if data ~= nil and data.is_open == 1 and data.status == 1 then
        			self.surplusTime = data["end"]
        			self.surplusCount = data.left

        			-- self.itemList = list
        			self.itemList = {}
        			for k,v in pairs(list) do
        				local item = Item:getOneItemByKey(k)
        				table.insert(self.itemList, createSafeTable("player.xianshilibao.items."..k, {itemId = k, count = v, name = item.name}, function(role, valueName, valueFrom, valueTo)
							Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
						end))
        			end

        			self.originalPrice = price.original

        			self.discountPrice = price.total

        			self.discount = beyond

        			self.limit = limit

        			self.Button_confirm_0.Text_confirmName:setString("原价" .. self.originalPrice .. "元宝")
        			self.Button_confirm.Text_confirmName:setString(self.discountPrice .. "元宝")
        			self.Text_Discount:setString("道具超值额度\n" .. self.discount .. "%")
        			self.Text_5:setString("活动期间,购买限时礼包后\n可获得超值奖励(限" .. self.limit .. "次)")
        			--self.Text_5:setString("活动期间,购买限时礼包后\n可获得超值奖励")
        			self:initItemList()
        			-- self:show()

            	end
            else
                --PopText(errmsg)
            end
    	end
	end, IS_SHOW_WAITING)
end

-- 初始化礼包道具列表
function XianShiLayer:initItemList()
	if  MapIsEmpty(self.itemList) == true then
		return
	end

	local index = 0

	for i = 1,#self.itemList, 2 do
		self:createPanel(index, self.itemList[i], self.itemList[i + 1])
		index = index + 1
	end

	-- 移除多余的panel
	for i = index + 1,#self.ListView_titlelistArea:getItems() do
		self.ListView_titlelistArea:removeLastItem()
	end
end

function XianShiLayer:createPanel(index, item1, item2)
	local listItems = self.ListView_titlelistArea:getItems()

	local panel
	if #listItems > index then
		panel = self.ListView_titlelistArea:getItem(index)
	else
		panel = self.Panel_Item:clone()
		Helper:convertUIByParent(panel)
		self.ListView_titlelistArea:pushBackCustomItem(panel)
	end

	local function initPanel(itemData, panel)
		if itemData == nil then
			panel:setVisible(false)
			return
		end

		local ImagePath =
		{
			xiyanshui = "Image/UI/StoreUI/xiyanshui.png",
			zuoyouhubo1 = "Image/UI/StoreUI/juhuajiu100.png",
			tianxiangyulu1 = "Image/UI/StoreUI/tianxiangyulu.png",
			jiu106 = "Image/UI/StoreUI/juhuajiu100.png",
	        chunjie502 = "Image/UI/StoreUI/shuxiang.png",
	        chunjie504 = "Image/UI/StoreUI/shuxiang.png",
	        qiannengdan = "Image/UI/StoreUI/zhuzi.png",
	        jingxinwan = "Image/UI/StoreUI/jiingxinwan.png",
	        dundifu = "Image/UI/StoreUI/dundifu.png",
	        jiu107 = "Image/UI/StoreUI/juhuajiu100.png",
	        juejinchan = "Image/UI/StoreUI/juejinchan.png",
	        jingmai101 = "Image/UI/StoreUI/xuanhuangziqingdan.png",
        	jingmai105 = "Image/UI/StoreUI/jiuzhuanjindan.png",
        	jingmai102 = "Image/UI/StoreUI/dabuwan.png",    --dabuwan.png
        	menpaicanye3 = "Image/UI/StoreUI/canye.png",
        	jingmai103 = "Image/UI/StoreUI/jiuzhuanjindan.png"
		}

		local textColor = cc.c4b(255, 255, 255, 255)
		local outlineColor = cc.c4b(0, 0, 0, 255)

		panel:setVisible(true)
		panel.Text_name:setString(itemData.name)
		panel.Text_num:setString("X" .. itemData.count)

		panel.Text_name:setColor(textColor)
		panel.Text_num:setColor(textColor)

		panel.Text_name:enableOutline(outlineColor, 5)
		panel.Text_num:enableOutline(outlineColor, 5)

		panel.Image_zhuzi:loadTexture(ImagePath[itemData.itemId])
	end

	initPanel(item1, panel.Panel_item_1)
	initPanel(item2, panel.Panel_item_2)
end

function XianShiLayer:setButton()
	self.Button_confirm:releaseFunc(function()
		-- 检测背包空间 不足不能购买
		local role = User:getRole()

		local weight = role:getAttr("weight")
		local items = role:getAttr("items")

		local currTime = GetTime()
		local endTime = Helper:getTimeStampWithStringDate("20171001",0)
		if currTime >= endTime and self.flag == false then
			PopText("新的限时礼包已经上架了！")
			self:getState()
			return
		end

		if self.surplusCount == 0 then
			PopText("礼包已经卖完了")
			return
		end

		if  MapIsEmpty(self.itemList) == true then
			PopText("购买失败")
			return
		end

		-- 4个道具需要4个背包空位
		if weight - #items < #self.itemList then
			PopText("背包剩余空间不足 无法购买")
			return
		end

		PopYuanBaoBuyItemLayer("xianshilibao", function(eventType)
                if eventType == "success" then
                	for i,v in ipairs(self.itemList) do
                		role:addItemCount(v.itemId, v.count)
                		PopText("获得 " .. v.name .. " X" .. v.count)
                	end
					self:getState()
                end
            end)
	end)

	self.Button_point:releaseFunc(function()
		local XianShiPointLayer = require("app.views.layer.ActionLayer.XianShiPointLayer")
		XianShiPointLayer:getInstance():showLayer()
	end)
end

Helper:classDefNodeGetInstance(XianShiLayer)

return XianShiLayer000000000
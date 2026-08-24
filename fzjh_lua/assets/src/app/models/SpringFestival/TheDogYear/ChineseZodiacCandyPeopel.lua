-----------------------------------------------------------生肖糖人----------------------------------------------------------------------------
local ChineseZodiacCandyPeopel = {
	weightList = {},
	result = 0,
}

local rewardList = {
	[1] = {
		itemId = "item204_24",
		rate = 1,
		name1 = "鼠",
		name2 = "老鼠",
		special = 0, 
	},
	[2] = {
		itemId = "item204_25",
		rate = 1,
		name1 = "牛",
		name2 = "牛",
		special = "HIY$N竟在糖人转盘处抽中了糖人（牛）！运气着实不错。", 
	},
	[3] = {
		itemId = "item204_26",	
		rate = 1,
		name1 = "虎",
		name2 = "老虎",
		special = "HIY$N竟在糖人转盘处抽中了糖人（虎）！运气着实不错。", 
	},
	[4] = {
		itemId = "item204_27",
		rate = 1,
		name1 = "兔",
		name2 = "兔子",
		special = 0,  
	},
	[5] = {
		itemId = "item204_28",
		rate = 1,
		name1 = "龙",
		name2 = "腾龙",
		special = "HIY$N竟在糖人转盘处抽中了糖人（龙）！当真是令人羡慕不已！",  
	},
	[6] = {
		itemId = "item204_29",
		rate = 1,
		name1 = "蛇",
		name2 = "蛇",
		special = 0,  
	},
	[7] = {
		itemId = "item204_30",
		rate = 1,
		name1 = "马",
		name2 = "马",
		special = 0,  
	},
	[8] = {
		itemId = "item204_31",
		rate = 1,
		name1 = "羊",
		name2 = "山羊",
		special = 0,  
	},
	[9] = {
		itemId = "item204_32",
		rate = 1,
		name1 = "猴",
		name2 = "猴子",
		special = 0,  
	},
	[10] = {
		itemId = "item204_33",
		rate = 1,
		name1 = "鸡",
		name2 = "鸡",
		special = 0,  
	},
	[11] = {
		itemId = "item204_34",
		rate = 1,
		name1 = "狗",
		name2 = "狗",
		special = "HIY$N竟在糖人转盘处抽中了糖人（狗）！当真是令人羡慕不已！",  
	},
	[12] = {
		itemId = "item204_35",
		rate = 1,
		name1 = "猪",
		name2 = "猪",
		special = 0,  
	}	
}
function ChineseZodiacCandyPeopel:start(func)
	self.successFunc = func
	self:setMapLayerExitButton()
	self:initWeightList()
	self:getResult()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 17:10:31
-- @desc 生成随机概率列表
function ChineseZodiacCandyPeopel:initWeightList()
	self.weightList = {}
	for k ,list in pairs(rewardList) do 
		if list.rate ~= nil then
			table.insert(self.weightList,list.rate)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 17:18:06
-- @desc 随机结果
function ChineseZodiacCandyPeopel:getResult()
	print("*************************************************************************")
	self.result = Helper:RandomByWeight(self.weightList)
	local resultList = rewardList[self.result]
	assert(resultList,"随机结果:"..tostring(self.result))
	local resultText = {
		[1] = {
			time = 3,
			text = function()
				local str = "你拨动了糖人转盘的指针，指针飞快地转着，最后指向了..$name1"
				return string.gsub(str,"$name1",resultList.name1)
			end,
		},
		[2] = {
			time = 4.5,
			text = function()
				local str = "糖人师傅见状，拿起糖勺在光滑的石板上龙飞凤舞地勾勒出了一只$name2的模样。"
				return string.gsub(str,"$name2",resultList.name2)
			end,
		},
		[3] = {
			time = 6,
			text = function()
				local str = "糖人师傅拿起一根竹签，插在糖人上，用铲刀将糖人铲起交到了你的手上。"
				self:getReward()
				if resultList.special ~= 0 then
					str = str .. "\nYEL糖人师傅：少侠真是好运气啊，竟能转到这HIY$NNORYEL，想必少侠新年必能行大运，发大财。"
					str = string.gsub(str,"$N",resultList.name1)
				end
				return str
			end,
		},
	}
	for k,textList in ipairs(resultText) do 
		self.maplayer:delayFunc(textList.time,function()
			RichPrint("main",textList.text())
		end)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 17:32:56
-- @desc 领取奖励
function ChineseZodiacCandyPeopel:getReward()
	local resultList = rewardList[self.result]
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()

	if User:getRole():addItemCount(resultList.itemId,1) == true then
	else
		if DEBUG_MODE == 1 then
			print("-------------------背包空间不足-----------------")
		end
		self.maplayer._currMap:dropItem(self.maplayer._currRoom.id,resultList.itemId,1)
	end
	local itemData = Item:getOneItemByKey(resultList.itemId)
	if itemData ~= nil then
		PopText("获得物品"..itemData.name.."X 1")
	end

	local candyData = role:getAttr("candyData")

	local _flag = role:getInheritFlag("十二糖人奖励")

	if type(candyData) == "table" and _flag < 1 then
		local tempData = {}
		for i,v in ipairs(candyData) do
			tempData[v] = true
		end

		if not tempData[self.result] then
			table.insert( candyData,self.result )
			tempData[self.result] = true
			local isGet = false
			for i=1,12 do
				if tempData[i] then
					isGet = true
				else
					isGet = false
					break
				end
			end
	
			if isGet then
				if role:checkCanBuyTwoOrMoreThings({["tangrendaoju1"] = 1}) then
					role:addItemCount("tangrendaoju1",1)
					local item = Item:getOneItemByKey("tangrendaoju1")
					if item ~= nil then
						PopText("获得物品"..item.name.."X 1")
					end
				else
					self.maplayer._currMap:dropItem(self.maplayer._currRoom.id,"tangrendaoju1",1)
				end
				role:setInheritFlag("十二糖人奖励",1)
			end
		end
	end

	if resultList.special ~= 0 then
		local str = string.gsub(resultList.special,"$N",User:getRole():getName())
		FubenClient:setValue("PopText", str)

	end
	self.mapRoleLayer:exitButtonFunc(true)
	self.mapRoleLayer:statusButtonFunc(true)
	self.maplayer:setUnmoveRoom(false)
	self.maplayer:setNPCTouchEnabled(false)
	self.maplayer._currMap:setCanLeave(true)
	if self.successFunc then
		self.successFunc()
		self.successFunc = nil
	end
	User:getRole():setFlag("PVP活动状态","空闲中")
end

function ChineseZodiacCandyPeopel:setMapLayerExitButton()
	self.maplayer = MainControllLayer:getLayer("MapLayer")
	self.mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
	self.mapRoleLayer:exitButtonFunc(false,function()
		RichPrint("main","YEL糖人师傅：少侠请耐心等待会吧。")
	end)
	self.mapRoleLayer:statusButtonFunc(false,function()
		RichPrint("main","YEL糖人师傅：少侠请耐心等待会吧。")
	end)
	self.maplayer:setUnmoveRoom(true,function()
		RichPrint("main","YEL糖人师傅：少侠请耐心等待会吧。")
	end)
	self.maplayer:setNPCTouchEnabled(true,function()
		RichPrint("main","YEL糖人师傅：少侠请耐心等待会吧。")
	end)
	self.maplayer._currMap:setCanLeave(false)
	User:getRole():setFlag("PVP活动状态","忙碌")
end
return ChineseZodiacCandyPeopel0000000
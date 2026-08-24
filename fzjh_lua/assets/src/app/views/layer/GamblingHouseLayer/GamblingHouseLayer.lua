-- 赌场界面
local GamblingHouseLayer = class("GamblingHouseLayer", LayerEx)

function GamblingHouseLayer:create()
	local p = GamblingHouseLayer:new()
	p:init()
	return p
end

-- 下注类型
local wagerType =
{
	large = 1,
	small = 2,
	oddnumber = 3,
	evennumber = 4,
}

function GamblingHouseLayer:init()
	self._UI = require("Layer/GamblingHouseUI/GamblingHouseUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

	-- self:setBackEnabled(false)
	self:setShowAndHideAnimType("ROLL")
	self:setBack()
	self:setButton()
	self:RefreshUI()

	-- 赌注
	self.wager = 0
	-- 下注类型
	self.wagerType = 0

	self.startTime = 0

	-- 骰子状态 0 准备摇第一个骰子 1 准备摇第二个骰子 2 准备摇第三个骰子 3 结束
	self.diceState = 0

	self.dice1Num = 6
	self.dice2Num = 6
	self.dice3Num = 6

	-- 气势值
	self.powerVal = 0

	self.winFunc = nil
end

function GamblingHouseLayer:showLayer(func, desc)
	if func == nil then
		func = function()
		end
	end

	if desc == nil then
		desc = ""
	end

	self.winFunc = func

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self.Text_desc1:setString(desc)

	self.diceState = 3
	self.wager = 0
	self.wagerType = 0
	self:changeUI(true)
	self:RefreshUI()
	self:show()
end

function GamblingHouseLayer:setButton()
	self.Button_large:releaseFunc(function()
		if self.wagerType ~= wagerType.large then
			if User:getRoleAttr("money") < 100 then
				PopText("碎银不足")
				return
			end
			self.wagerType = wagerType.large
			self.wager = 100
			RichPrint("main", "YEL庄家:这少侠豪情盖天，决定押大" .. 100 .. "碎银")
			self:RefreshUI()
		end
	end)

	self.Button_small:releaseFunc(function()
		if self.wagerType ~= wagerType.small then
			if User:getRoleAttr("money") < 100 then
				PopText("碎银不足")
				return
			end
			self.wagerType = wagerType.small
			self.wager = 100
			RichPrint("main", "YEL庄家:这少侠豪情盖天，决定押小" .. 100 .. "碎银")
			self:RefreshUI()
		end
	end)

	self.Button_oddnumber:releaseFunc(function()
		if self.wagerType ~= wagerType.oddnumber then
			if User:getRoleAttr("money") < 100 then
				PopText("碎银不足")
				return
			end
			self.wagerType = wagerType.oddnumber
			self.wager = 100
			RichPrint("main", "YEL庄家:这少侠豪情盖天，决定押单" .. 100 .. "碎银")
			self:RefreshUI()
		end
	end)

	self.Button_evennumber:releaseFunc(function()
		if self.wagerType ~= wagerType.evennumber then
			if User:getRoleAttr("money") < 100 then
				PopText("碎银不足")
				return
			end
			self.wagerType = wagerType.evennumber
			self.wager = 100
			RichPrint("main", "YEL庄家:这少侠豪情盖天，决定押双" .. 100 .. "碎银")
			self:RefreshUI()
		end
	end)

	-- 开局
	self.Button_start:releaseFunc(function()
		self:dice()
	end)

	-- 加注
	self.Button_add:releaseFunc(function()
		if self.wagerType == 0 then
			PopText("你还没下注呢")
			return
		end
		self:addwager()
		self:RefreshUI()
	end)

	-- 气势
	self.Button_power:releaseFunc(function()
		self:addPower()
	end)

	-- 押注
	self.Button_play:releaseFunc(function()
		if self.diceState < 3 then
			return
		end
		self.wager = 0
		self.wagerType = 0
		self:changeUI(true)
		self:RefreshUI()
	end)

end

-- 赌注加倍
function GamblingHouseLayer:addwager()
	local role = User:getRole()
	local money = role:getAttr("money")
	local wager = self.wager
	if wager >= 5000 then
		PopText("不能再加注了!")
	end
	if wager == 0 then
		wager = 100
	else
		wager = wager * 2
	end

	if wager >= 5000 then
		wager = 5000
	end

	if money < wager then
		PopText("碎银不足")
		return
	end

	local str = "大"
	if self.wagerType == wagerType.large then
		str = "大"
	elseif self.wagerType == wagerType.small then
		str = "小"
	elseif self.wagerType == wagerType.oddnumber then
		str = "单"
	elseif self.wagerType == wagerType.evennumber then
		str = "双"
	end
	RichPrint("main", "YEL庄家:这少侠豪情盖天，决定押" .. str .. wager .. "碎银")

	self.wager = wager
end

-- 增加气势
function GamblingHouseLayer:addPower()
	if self.diceState >= 3 then
		return
	end

	self.powerVal = self.powerVal + 1
	local name = User:getRole():getAttr("name")
	if self.wagerType == wagerType.large then
		RichPrint("main", "YEL" .. name .. ": 大!!")
	elseif self.wagerType == wagerType.small then
		RichPrint("main", "YEL" .. name .. ": 小!!")
	elseif self.wagerType == wagerType.oddnumber then
		RichPrint("main", "YEL" .. name .. ": 单!!")
	elseif self.wagerType == wagerType.evennumber then
		RichPrint("main", "YEL" .. name .. ": 双!!")
	end
	print("气势值 = " .. self.powerVal)
end

-- 刷新UI
function GamblingHouseLayer:RefreshUI()
	self.Button_large.Text_button_1_Name:setString("买大")
	self.Button_small.Text_button_1_Name:setString("买小")
	self.Button_oddnumber.Text_button_1_Name:setString("买单")
	self.Button_evennumber.Text_button_1_Name:setString("买双")

	if self.wagerType == wagerType.large then
		self.Button_large.Text_button_1_Name:setString("买大\n" .. self.wager)
	elseif self.wagerType == wagerType.small then
		self.Button_small.Text_button_1_Name:setString("买小\n" .. self.wager)
	elseif self.wagerType == wagerType.oddnumber then
		self.Button_oddnumber.Text_button_1_Name:setString("买单\n" .. self.wager)
	elseif self.wagerType == wagerType.evennumber then
		self.Button_evennumber.Text_button_1_Name:setString("买双\n" .. self.wager)
	end

	self.Button_num1.Text_button_1_Name:setString(Helper:numberCast(self.dice1Num))
	self.Button_num2.Text_button_1_Name:setString(Helper:numberCast(self.dice2Num))
	self.Button_num3.Text_button_1_Name:setString(Helper:numberCast(self.dice3Num))
end

-- 开始摇骰子
function GamblingHouseLayer:dice()
	if self.wager == 0 or self.wagerType == 0 then
		PopText("你还没下注")
		return
	end

	local role = User:getRole()
	role:addAttr("money", - self.wager)
	PopText("碎银 -  " .. self.wager)

	RichPrint("main", "YEL庄家:押大押小，买定离手，开!!")

	self:changeUI(false)

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	-- 重置数据
	self.powerVal = 0
	self.diceState = 0
	self.startTime = GetTime()
	-- 减速摇骰子
	self.slowDice = 0
	self.slowDiceMax = 0
	self._handle = self:schedule(function (ft)
		self:update(ft)
	end,1/10)
end

function GamblingHouseLayer:update(ft)
	local currTime = GetTime()

	if self.diceState == 0 then
		self.dice1Num = self:randDice()
		self.dice2Num = self:randDice()
		self.dice3Num = self:randDice()

		if currTime - self.startTime >= 2 then
			self.diceState = self.diceState + 1
		end

	elseif self.diceState == 1 then
		self.dice2Num = self:randDice()
		self.dice3Num = self:randDice()

		if currTime - self.startTime >= 6 then
			self:diceChange()
			self.diceState = self.diceState + 1
		end

	elseif self.diceState == 2 then

		-- 时间越久摇骰子越慢
		self.slowDice = self.slowDice + 1
		if self.slowDice >= self.slowDiceMax then
			self.slowDice = 0
			self.slowDiceMax = self.slowDiceMax + 0.1
			self.dice3Num = self:randDice()
		end

		if currTime - self.startTime >= 10 then
			self.diceState = self.diceState + 1
			self:changeDice()
			self:balance()

			if self._handle ~= nil then
				self:unschedule(self._handle)
				self._handle = nil
			end
		end

	end
	self:RefreshUI()
end

-- 根据气势改变骰子
function GamblingHouseLayer:changeDice()
	if self.dice1Num + self.dice2Num == 2 or self.dice1Num + self.dice2Num == 12 then
		return
	end
	if self.powerVal >= 20 then
		if self.wagerType == wagerType.large then
			self.dice3Num = 4
		elseif self.wagerType == wagerType.small then
			self.dice3Num = 3
		elseif self.wagerType == wagerType.oddnumber then
			self.dice3Num = 1
		elseif self.wagerType == wagerType.evennumber then
			self.dice3Num = 2
		end
	end
end

-- 判定输赢结果
function GamblingHouseLayer:balance()
	local count = self.dice1Num + self.dice2Num + self.dice3Num
	local flag = false
	if count == 3 or count == 18 then
		RichPrint("main", "YEL庄家: 豹子，庄家通吃！")
		return
	end

	-- 买大 11-17
	if self.wagerType == wagerType.large then
		if count >= 11 and count <= 17 then
			flag = true
			RichPrint("main", "YEL庄家: " .. Helper:numberCast(self.dice1Num) .. Helper:numberCast(self.dice2Num) .. Helper:numberCast(self.dice3Num).. "，大!")
		else
			RichPrint("main", "YEL庄家: " .. Helper:numberCast(self.dice1Num) .. Helper:numberCast(self.dice2Num) .. Helper:numberCast(self.dice3Num).. "，小!")
		end

	-- 买小 4-10
	elseif self.wagerType == wagerType.small then
		if count >= 4 and count <= 10 then
			flag = true
			RichPrint("main", "YEL庄家: " .. Helper:numberCast(self.dice1Num) .. Helper:numberCast(self.dice2Num) .. Helper:numberCast(self.dice3Num).. "，小!")
		else
			RichPrint("main", "YEL庄家: " .. Helper:numberCast(self.dice1Num) .. Helper:numberCast(self.dice2Num) .. Helper:numberCast(self.dice3Num).. "，大!")
		end
	-- 买单
	elseif self.wagerType == wagerType.oddnumber then
		if count %2 == 1 then
			flag = true
			RichPrint("main", "YEL庄家: " .. Helper:numberCast(self.dice1Num) .. Helper:numberCast(self.dice2Num) .. Helper:numberCast(self.dice3Num).. "，单!")
		else
			RichPrint("main", "YEL庄家: " .. Helper:numberCast(self.dice1Num) .. Helper:numberCast(self.dice2Num) .. Helper:numberCast(self.dice3Num).. "，双!")
		end

	-- 买双
	elseif self.wagerType == wagerType.evennumber then
		if count %2 == 0 then
			flag = true
			RichPrint("main", "YEL庄家: " .. Helper:numberCast(self.dice1Num) .. Helper:numberCast(self.dice2Num) .. Helper:numberCast(self.dice3Num).. "，双!")
		else
			RichPrint("main", "YEL庄家: " .. Helper:numberCast(self.dice1Num) .. Helper:numberCast(self.dice2Num) .. Helper:numberCast(self.dice3Num).. "，单!")
		end
	end

	-- 领取奖励
	if flag == true then
		local role = User:getRole()
		local wager = self.wager
		if wager >= 5000 then
			wager = 5000
		end
		role:addAttr("money", wager * 2)
		PopText("碎银 + " .. wager * 2)
		self.winFunc()
	end
end

function GamblingHouseLayer:randDice()
	return math.random(1,6)
end

-- 减低玩家获胜几率
function GamblingHouseLayer:diceChange()
	if self.wagerType == wagerType.large then
		self.dice2Num = Helper:RandomIndexByPercentWithString("6;6;6;5;5;5")
	elseif self.wagerType == wagerType.small then
		self.dice2Num = Helper:RandomIndexByPercentWithString("5;5;5;6;6;6")
	elseif self.wagerType == wagerType.oddnumber then
		if self.dice1Num % 2 == 1 then
			self.dice2Num = Helper:RandomIndexByPercentWithString("4;4;4;4;4;5")
		elseif self.dice1Num % 2 == 0 then
			self.dice2Num = Helper:RandomIndexByPercentWithString("5;4;4;4;4;4")
		end
	elseif self.wagerType == wagerType.evennumber then
		if self.dice1Num % 2 == 0 then
			self.dice2Num = Helper:RandomIndexByPercentWithString("4;4;4;4;4;5")
		elseif self.dice1Num % 2 == 1 then
			self.dice2Num = Helper:RandomIndexByPercentWithString("5;4;4;4;4;4")
		end
	end
end

function GamblingHouseLayer:changeUI(flag)
	self.Button_large:setVisible(flag)
	self.Button_small:setVisible(flag)
	self.Button_oddnumber:setVisible(flag)
	self.Button_evennumber:setVisible(flag)
	self.Button_start:setVisible(flag)
	self.Button_add:setVisible(flag)

	self.Button_num1:setVisible(not flag)
	self.Button_num3:setVisible(not flag)
	self.Button_num2:setVisible(not flag)
	self.Button_power:setVisible(not flag)
	self.Button_play:setVisible(not flag)
end


function GamblingHouseLayer:setBack()
	self.Panel_back:releaseFunc(function()
		if self.diceState >= 3 then
			PopupLayerController:hideLayer("GamblingHouseLayer", function(layer)
				self:hide()
			end)
		end
	end)
end

Helper:classDefNodeGetInstance(GamblingHouseLayer)

return GamblingHouseLayer000000
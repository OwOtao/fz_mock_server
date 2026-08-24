local BiWu = require("app.models.BiWu.BiWu")
local BiWuWatchUI = require("app.views.ui.BiWuUI.BiWuWatchUI")


local BiWuWatchLayer = class("BiWuWatchLayer",cc.Layer)

function BiWuWatchLayer:create()
	local p = BiWuWatchLayer:new()
	p:init()
	return p
end

function BiWuWatchLayer:init()
	local BiWuWatchUI = BiWuWatchUI:create()
	self._UI = BiWuWatchUI
	BiWuWatchUI:addTo(self)

	self:setTextJingLi()
	self:setTextMoney()
	self:setButtonBack()
	self:setDesc()
	self:setButtonCancelWatch()

	self:schedule(function ()
		self:update()
	end,1)

	self._isStopGuanZhan = false
end

function BiWuWatchLayer:show()
	self:setVisible(true)
	-----如果是切换存档应该初始化输出框
	if BiWu:isChangFIleIsTrue("BiWuWatchLayer") == true then
		self._UI:initRichText()
		BiWu._changeFileBiWuWatcherLayer = nil
	end
	self._isStopGuanZhan = false

	self:printChanllengeMsg()
end
---------------------------------
--设置精力  or 潜能？
function BiWuWatchLayer:setTextJingLi()
	-- local jing = User:getRole():getAttr("jing")
	local jing = User:getRole():getAttr("pot")
	self._UI:setTextJingLi(math.ceil(jing))
end

--设置金钱
function BiWuWatchLayer:setTextMoney()
	local money = User:getRole():getAttr("money")
	self._UI:setTextMoney(math.ceil(money))
end
---退出
function BiWuWatchLayer:setButtonBack( )
	self._UI:setButtonBack(function ()
		MainControllLayer:popLayer()
		BiWu._isShowMainLayer = true
	end)
end

--动画
function BiWuWatchLayer:runBackImage(func)
	-- local Size = self._UI.Sprite_bottom:getContentSize()
	-- self._UI.Sprite_bottom:runAction(cc.Sequence:create(
	-- 				cc.MoveTo:create(0.2,cc.p(Size.width/2,-Size.height)),
	-- 		 		cc.MoveTo:create(0.2,cc.p(Size.width/2,0))
	-- 		 	))
	-- if func then
	-- 	func()
	-- end
end


function BiWuWatchLayer:printChanllengeMsg()
	--进入观看界面，向服务器查询是否有对战结果，有的话，一条一条打印出来
	self:delayFunc(1,function ()
		BiWu:getChanllengeMsg(function()
			local fightAllData = BiWu:getfightAllData()
			--对战信息不为空，则开始打印信息
			if fightAllData and fightAllData.watchFightResultMsg then
				for i=1,#fightAllData.watchFightResultMsg do
					-- local biWuWatchLayer = MainControllLayer:getLayer("BiWuiwuatchLayer")
					self:delayFunc(1,function()
						self._UI:print(fightAllData.watchFightResultMsg[i])
					end)
				end
			end
		end)
	end)
	
end
-----取消观战的时间 收益 提示
function BiWuWatchLayer:cancelWatchNotice()
	local fightAllData = BiWu:getfightAllData()
	local currTime = GetTime()
	local year, month, day, hour, minute, second = 0, 0, 0, 0, 0, 0
	local popTimeStr = ""
	local popRewardStr = ""
	local beginTime = ""
	local endTime = ""
	-------观战开始和结束时间
	if fightAllData.current_time and fightAllData.expired_time then
		year, month, day, hour, minute, second = Helper:getExpiredTime(currTime,fightAllData.current_time) 
		if tonumber(second)<10 then
			second = "0"..tostring(second)
		end
		-- minute = minute + 1
		if tonumber(minute)<10 then
			minute = "0"..tostring(minute)
		end
		-- beginTime = hour..":"..minute..":"..second
		beginTime = hour.."小时"..minute.."分钟"

		year, month, day, hour, minute, second = Helper:getExpiredTime(fightAllData.expired_time,currTime) 
		if tonumber(second)<10 then
			second = "0"..tostring(second)
		end
		if tonumber(minute)<10 then
			minute = "0"..tostring(minute)
		end
		-- endTime = hour..":"..minute..":"..second
		endTime = hour.."小时"..minute.."分钟"

		popTimeStr = "已观战"..beginTime.."\n距离观战结束"..endTime
	end
--观战收益
	if fightAllData.watchTotalPot ~= nil and fightAllData.watchTotalMoney ~= nil and tonumber(fightAllData.watchTotalPot) > 0 and tonumber(fightAllData.watchTotalMoney) > 0 then
		popRewardStr = "获得潜能"..fightAllData.watchTotalPot.."\n消耗银两"..fightAllData.watchTotalMoney
	end

	return popTimeStr , popRewardStr
end
---取消观战按钮
function BiWuWatchLayer:setButtonCancelWatch( )
	self._UI:setButtonCancelWatch(function ()
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		local popTimeStr,popRewardStr = self:cancelWatchNotice()
		dialog:show(popTimeStr.."\n"..popRewardStr,"RED正在观战，取消观战无法获得收益")
		dialog._UI.Text_desc:setFontSize(60)
		dialog:setButton1("是", function()
			User:getRole():stopGuanZhan(function()
				-----取消观战失败，手动停止，并退出界面
			end,function ()
				---------------在这里，保存结束观看的时间
				local fightAllData = BiWu:getfightAllData()
				fightAllData.stopWatchTime = nil
				fightAllData.watchFid = nil
				BiWu:savefightAllData(fightAllData)
			end)
			MainControllLayer:popLayer()
			BiWu._isShowMainLayer = true
		end)
		dialog:setButton2("否")
	end)
end
function BiWuWatchLayer:setDesc()
	local str = BiWu:getwatchStageDesc()
	self._UI:setDesc(str)
end

---停止观战的条件
-- 1、钱不够
-- -- 2、每2小时触发上台，上台挑战成功则观战停止，如果上台挑战失败则继续挂机

---超出最大观看收益时间
function BiWuWatchLayer:isOverTime()

	---从本地获取数据，
	local fightAllData = BiWu:getfightAllData()
	---必须在观看阶段，才能判断时间是否超出最大收益时间
	if fightAllData.watchFid then
		if MapIsEmpty(fightAllData) or fightAllData.expired_time == nil  then
			-- if PRINT_MODE == 1 then
			-- ---如果是没有数据，从新向服务器访问，告诉开始观看
			-- 	PopText("如果是没有数据，从新向服务器访问，告诉开始观看")
			-- end
			-- BiWu:sendBiWuWatch(function ()
			-- 	--开始计算收益
			-- 	local fightAllData = BiWu:getfightAllData()
			-- 	if fightAllData.watchFid and fightAllData.current_time and  fightAllData.expired_time then
			-- 		User:getRole():startGuanZhan(fightAllData.watchFid, fightAllData.current_time, fightAllData.expired_time)
			-- 	else
			-- 		if 	PRINT_MODE == 1 then
			-- 			PopText("进入观看时候，获取watchfid失败")
			-- 		end
			-- 	end
			-- end)
		else
			local currTime = GetTime()
			if tonumber(currTime) - tonumber(fightAllData.expired_time) < 0 then
				return false  --还没达到最大收益时间
			else
				return true  --达到了
			end
		end
	else
		return false
	end
end

function BiWuWatchLayer:update()

	local currTime = Helper:date("%H", GetTime())
	self:printFightText(currTime)
	---c超过最长观看时间 或者钱不够了        						   -- 新增 当时间达到23点时 也自动退
	if self:isOverTime() == true or self:canConsumeMoney() == false or currTime == "23" then  ---canConsumeMoney

		----------防止死循环
		if self._isStopGuanZhan == false then
			if PRINT_MODE ==1 then
				print("self:isOverTime() ="..tostring(self:isOverTime()).."  self:canConsumeMoney()="..tostring(self:canConsumeMoney()).."self._isStopGuanZhan ="..tostring(self._isStopGuanZhan))
			end
			self._isStopGuanZhan = true
			-----不能观战的提示
			if self:canConsumeMoney() == false then
				PopText("你的金钱不足以你继续观战")
				BiWu._isWatchNoMoney = true

			elseif currTime == "23" then
				PopText("天色已晚，比武擂台暂时关闭，可明日再来观战")
				BiWu._isWatchNoTime = true

			else
				PopText("你观战时间过长，你休息后再来")
				BiWu._isWatchNoTime = true
			end
			---告诉服务器退出观看
				---停止观战
			User:getRole():stopGuanZhan(function ()
				-----正常退出的情况
				MainControllLayer:popLayer()
				BiWu._isShowMainLayer = true
			end,function ()
				---------失败的处理
				MainControllLayer:popLayer()
				BiWu._isShowMainLayer = true
			end)
		end

	else
		--计算收益  实时计算，退出也算，直到时间超过八小时或者没有钱去消耗
		--调用计算收益的公式
		self:countWatchReward()
	end

	---刷新界面
	self:refresh()
end


---
function BiWuWatchLayer:refresh()
	self:setTextJingLi()
	self:setTextMoney()

end
-----能得到收益，计算收益，并打印文本
function BiWuWatchLayer:countWatchReward()
	local role =User:getRole()
	---j计算收益
	local pot,money = role:updateGuanZhan()
	local str = BiWu:getwatchRewardText()

	if pot and money and tonumber(pot) > 0  then
		str = string.gsub(str,"$E",tostring(pot))
		str = string.gsub(str,"$M",tostring(money))

		self._UI:print(str)
		self._UI:print("HIC你一共获得"..tostring(pot).."潜能，消耗"..tostring(money).."碎银。")
	end
end



--30秒计算一次
function BiWuWatchLayer:canGetWatchRewardInTime()
	if not self._useTime then
		self._useTime = GetTime()
	end
	local time = 30
	-- if DEBUG_MODE == 1 then
	-- 	time = 5
	-- end
	if GetTime() - self._useTime > time then
		self._useTime = GetTime()
		return true
	else
		return false
	end
end

--没有基本等级限制
-- 限制1、基本XX奖励不能超过当前等级
-- 限制2、基本XX奖励不能超过500级的奖励
-- 限制3、没有学过的基本XX不会被奖励


---观战消耗的金钱数量
-- 钱在碎银25+正负1~9随机
function BiWuWatchLayer:canConsumeMoney()
	local role = User:getRole()
	local money = role:getAttr("money")
	local figure = 25+math.random(-9, 9)
	if money > figure then
		return true
	else
		return false
	end
end

-----------------------------------------------------------------------------------------------------------------------------------


----打印战斗信息
function BiWuWatchLayer:printFightText(time)
	--	超过23点 不打印信息
	if time == "23" then
		return
	end

	--输出打印信息
	local str = BiWu:getOnefightMsgList()
	if str == nil then
	else
		self._UI:print(str)
	end
end

function BiWuWatchLayer:onResume()
	Audio:setMusicVolume(0.5)
end
Helper:classDefNodeGetInstance(BiWuWatchLayer)

return  BiWuWatchLayer
00000000
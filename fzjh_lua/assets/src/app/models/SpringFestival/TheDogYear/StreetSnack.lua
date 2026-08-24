--------------------------------------------------------------------街内小吃------------------------------------------------------------------
local StreetSnack = {
	successFunc = function()

	end,
	failedFunc = function()

	end,
	num = 0, --前方排队人数
	stage = 1, --等待阶段或者制作阶段
	time = 0,--游戏计时
	levelTime = 0,--随机离开时间
	levelTimeCount = 0,--随机离开时间计数
}

local DogYearSpringFestival = require("app.models.SpringFestival.DogYearSpringFestival")
--开始排队文本
local start_text = "你走到小摊等待队伍的最后方，开始等待了起来，你前面还有$N个人。"

--离队文本
local level_text = "前方一位顾客似乎耐不住等待，直接离开了，你前方还有$N名客人正在等待。"

--等待结束文本
local start_make_text = "你走到摊位面前，小贩热情地向你说起他们家的小吃。"

local MAP_ROOM_NUM = 3 --人数节点
local WAIT_STAGE = 1 --等待阶段
local MADE_STAGE = 2 --制作阶段
local LOG_WAIT_INFO_TIME = 3--固定输出排队信息的时间
local ROLE_LEVEL_TIME = 5--间隔时间队伍中必定有一人离开
local RANDOM_LEVEL_RATE = 50 --随机离队时间发成概率
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 13:27:13
-- @desc 游戏开始
function StreetSnack:start()
	if DogYearSpringFestival:getDogYearSpringFestivalState() == false then
		PopText("新年活动已经结束")
		return
	end
	self:setMapLayerExitButton()
	self:setRoleNum()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 15:58:40
-- @desc 结束游戏
function StreetSnack:finish()
	RichPrint("main","你离开了等待的队伍。")
	if self.handle ~= nil then
		self.maplayer._currMap:unSchedule(self.handle)
		self.handle = nil
	end
	self.failedFunc()
end


function StreetSnack:setMapLayerExitButton()
	local func = function(str,buttonName)
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show(str)
		dialog:setBack(false)
		dialog:setButton1(buttonName , function()
				self.mapRoleLayer:exitButtonFunc(true)
				self.maplayer:setUnmoveRoom(false)
				self.maplayer._currMap:setCanLeave(true)
				self:finish()
		end)
		dialog:setButton2("取消",function()
			if self.handle ~= nil then
				self.maplayer._currMap:resumeSchedule(self.handle) 
			end
		end)
	end
	self.maplayer = MainControllLayer:getLayer("MapLayer")
	self.mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
	self.mapRoleLayer:exitButtonFunc(false,function()
		if self.handle ~= nil then
			self.maplayer._currMap:pauseSchedule(self.handle) 
		end
		func("离开副本会导致任务失败","离开")
		self.maplayer:quit()
	end)
	self.maplayer:setUnmoveRoom(true,function()
		if self.handle ~= nil then
			self.maplayer._currMap:pauseSchedule(self.handle) 
		end
		func("移动会导致任务失败，是否放弃任务","放弃")
	end)
	self.maplayer._currMap:setCanLeave(false)
	User:getRole():setFlag("PVP活动状态","忙碌")
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 13:45:51
-- @desc 设置需要等待的人数
function StreetSnack:setRoleNum()
	-- if MapIsEmpty() == true then
	-- 	error("！！！！！！！")
	-- end
	if self.maplayer._currRoom.playList == nil then
		error("！！！！！！！")
	end
	local roomRoleNum = #self.maplayer._currRoom.playList
	local hour = tonumber(Helper:date("%H",GetTime()))
	if roomRoleNum > MAP_ROOM_NUM then
		self.num = roomRoleNum
	else
		if hour >= 0 and hour < 1 then
			self.num = math.random(7,9)
		elseif hour >= 1 and hour < 4 then
			self.num = math.random(0,5)
		elseif hour >= 4 and hour < 8 then
			self.num = math.random(0,5)
		elseif hour >= 8 and hour < 11 then
			self.num = math.random(1,5)
		elseif hour >= 11 and hour < 12 then
			self.num = math.random(0,5)
		elseif hour >= 12 and hour < 13 then
			self.num = math.random(8,11)
		elseif hour >= 13 and hour < 18 then
			self.num = math.random(1,5)
		elseif hour >= 18 and hour < 20 then
			self.num = math.random(10,13)
		elseif hour >= 20 and hour < 22 then
			self.num = math.random(4,7)
		elseif hour >= 22 and hour < 24 then
			self.num = math.random(3,5)
		end
	end
	if DEBUG_MODE == 1 then
		print("------------当前房间玩家数量：",roomRoleNum,"------------------最终需要等待人数--------------------",self.num,"----------当前时间-----------",hour)
	end
	if self.num ~= 0 then
		local str = string.gsub(start_text,"$N",tostring(self.num))
		RichPrint("main",str)
		self.stage = WAIT_STAGE
		self.levelTime = math.random(1,10)
	else
		self.stage = MADE_STAGE
	end
	self:setSchedule()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 13:27:22
-- @desc 设置游戏结果回调
function StreetSnack:setResultCallFunc(successFunc,failedFunc)
	if type(successFunc) == "function" then
		self.successFunc = successFunc
	end
	if type(failedFunc) == "function" then
		self.failedFunc = failedFunc
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 14:22:02
-- @desc 时间调度
function StreetSnack:setSchedule()
	self.handle = self.maplayer._currMap:setSchedule(function()
		if self.stage == WAIT_STAGE then
			self.time = self.time + 1
			self.levelTimeCount = self.levelTimeCount + 1
			if DEBUG_MODE == 1 then
				print("-------------------------------等待时间----------------------------------",self.time)
				print(self.time % LOG_WAIT_INFO_TIME,self.time % ROLE_LEVEL_TIME,self.levelTimeCount,self.levelTime)
			end
			if self.time % LOG_WAIT_INFO_TIME == 0 then
				self:logQueueText()
			end
			if self.time % ROLE_LEVEL_TIME == 0 then
				self:logLevelText(1)
			end
			if self.levelTimeCount >= self.levelTime then
				self:randomLevel()
			end
		end
	end,1.0)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 14:58:45
-- @desc 输出当前排队信息的文本
function StreetSnack:logQueueText()
	local str = ""
	if self.num >= 20 then
		str = "你往前看去，前方还有X名顾客，看来还需等待很久。"
	elseif self.num < 20 and self.num >= 15 then
		str = "你往前看去，前方还有X名顾客，看来还需等待不少时间。"
	elseif self.num < 15 and self.num >= 10 then
		str = "你往前看去，前方还有X名顾客，看来还需等待一段时间。"
	elseif self.num < 10 and self.num >= 5 then
		str = "你往前看去，前方还有X名顾客，看来还需等待一些时间。"
	elseif self.num < 5 and self.num >= 1 then
		str = "你往前看去，前方还有X名顾客，看来用不了多久了。"
	end
	str = string.gsub(str,"X",tostring(self.num))
	RichPrint("main",str)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 15:04:39
-- @desc 固定时间离队输出文本
function StreetSnack:logLevelText(flag)
	self.num = self.num - 1
	local str = string.gsub(level_text,"$N",tostring(self.num))
	if flag == 1 then
		str = string.gsub("最前方的顾客已经购买完毕，你的前面还有$N名顾客正在等待。","$N",tostring(self.num))
	end
	if self.num == 0 then
		self:srateMake()
	else
		RichPrint("main",str)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 15:13:05
-- @desc 随机离队事件
function StreetSnack:randomLevel()
	self.levelTime = math.random(1,100)
	self.levelTimeCount = 0
	if math.random(1,100) >= RANDOM_LEVEL_RATE then
		self:logLevelText(2)
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 15:10:44
-- @desc 开始制作
function StreetSnack:srateMake()
	self.stage = MADE_STAGE
	RichPrint("main",start_make_text)
	if self.handle ~= nil then
		self.maplayer._currMap:unSchedule(self.handle)
		self.handle = nil
	end
	self.mapRoleLayer:exitButtonFunc(true)
	self.maplayer:setUnmoveRoom(false)
	self.maplayer._currMap:setCanLeave(true)
	self.successFunc()
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 14:28:54
-- @desc 
return StreetSnack00000000000000
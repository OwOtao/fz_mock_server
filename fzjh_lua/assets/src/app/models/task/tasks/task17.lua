local LiLianTaskHelper = require("app.models.task.LiLianTaskHelper")
local TASK_ID = "task17"
local nanYangRes = LiLianTaskHelper:getTaskConfigInfo(TASK_ID)

local function getTaskConfig(confVer)
	return LiLianTaskHelper:getTaskConfigInfo(TASK_ID, confVer)
end

local task =
{
	id = TASK_ID,

	-- 显示
	buttonA = "taskButton14a",
	buttonB = "taskButton14b",

	-- 数据
	type = "主线任务", -- 任务类型
	name = "南阳匪贼", -- 任务名称
	jindu= "fb11",		 -- 需要江湖进度
	flag = "追击任务", -- 任务标记
	desc = {},	--任务描述
	warnText = "需通关“声震武林卷”第一章才能接取该主动任务",

	coolDown = 0, 			-- 冷却时间

	defaultMapId = "fb11",	-- 默认地图索引
	
	coolDown = 0, -- 冷却时间
    Decline = {},  --任务奖励改变次数
	score = {},    --任务改变比例
	texttime = {},  --任务文本改变次数
	rewardtim = {},  --任务次数额外奖励;
	reward = "",      --任务次数额外奖励;
    rate = nil,     --获得额外奖励 概率
	taskitem =nil,   --获得额外奖励 物品
	addExpBuffName = "addNanyangExp", --经验加成buff
	zhuXianCondition = -- 主线任务条件
	{
		time = 5,		-- 时间
		-- map = "fb01",		-- 地图
		-- roomId = "fb01_04",	-- 房间
		-- step = 2,		--房间刷怪范围
		mapRoom =
		{
			fb11={roomId = "fb11_13",step= 1},
		},
		buttonColor = {r = 28,g = 76,b = 163},	-- 按钮颜色
		npcList = 	-- 人物列表
		{

		},
		-- action = "kill",	--击杀
		-- zCount = 2,	-- 完成总次数
		-- dCount = 1, -- 当天完成次数
		canAbandon = true,	-- 任务能否放弃（true 可以 false 不能）
	},

	zhuXianReward = 	--奖励列表
	{
		{
			type = "属性",
			name = "exp",
			value = function(lv, exp, fy, sklv, confVer)
				local taskConfig = getTaskConfig(confVer)
				return math.floor(Formula:getFormula("jingyan1")(exp, fy, sklv, taskConfig.jobreward1,lv))
			end
		},
		{
			type = "属性",
			name = "pot",
			value = function(lv, exp, fy, sklv, confVer)
				local taskConfig = getTaskConfig(confVer)
				return math.floor(Formula:getFormula("qianneng1")(exp, fy, sklv, taskConfig.jobreward2))
			end
		},
		{
			type = "属性",
			name = "yueli",
			value = function(lv, exp, fy, sklv, confVer)
				return getTaskConfig(confVer).jobreward4
			end
		},
		-- {
		-- 	type = "物品",
		-- 	name = "tie111",
		-- 	value = 1
		-- },
		-- {
		-- 	type = "物品",
		-- 	name = "lababaoxiang1",
		-- 	value = 1
		-- },
	},	
	dayReward = {
		{
			--@desc 每日标记 task yinpiao day
			_flag = "typd17",
			--@desc 每日最大奖励次数
			_count = 3,
			
			_type = "yinpiao",

			--@count 今日已领取次数
			value = function (self,count,isDispatchTask,confVer)
				--完成次数
				local countTimes = count + 1 
				return LiLianTaskHelper:getYinPiaoCount(countTimes, getTaskConfig(confVer))
			end,

			condi = function ()
				local role = User:getRole()

				local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
				if HomelandUtil:sysIsOpen(false) == false then
					return
				end

				return true
			end
		},
		{
			--@desc 每日标记 task yinpiao day
			_flag = "typd17_pijuan",
			--@desc 每日最大奖励次数
			_count = 3,
			
			_type = "pijuan",

			value = function (self,count,isDispatchTask)
				if isDispatchTask then
					return 1
				else
					return 3
				end
			end,

			condi = function ()
				return true
			end
		}
	}
}

task.desc = string.split(nanYangRes["text"], ";")
task.texttime =  string.split(nanYangRes["texttime"], ";") 

function task:getDynamicDailyMaxCount(confVer)
	return getTaskConfig(confVer).maxtime
end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/03/30 11:48:15
-- -- @desc 获取任务奖励 (继承自父类,子类实现方法体)
function task:getSpecialReward(confVer)
	local rewards = {}

	local role = User:getRole()

	local taskConfig = getTaskConfig(confVer)
	local taskitem = Helper:getDef(string.split(taskConfig["taskitem"], ";"),{})
	local rate = string.split(taskConfig["rate"], ";")

	if MapIsEmpty(taskitem) == false then
		--@desc 记录飞贼任务奖励次数
		local dayFlagName = "南阳匪贼任务奖励"
		
		if role:getDayFlag(dayFlagName) >= 3 then
			
			PopText("您今日获得的宝箱已到上限。")
		else
			local itemId = taskitem[role:getDayFlag(dayFlagName) + 1]
	
			local percent = rate[role:getDayFlag(dayFlagName) + 1]
	
			if itemId ~= nil and math.random(1, 100) <= tonumber(percent) * 100 then
				local reward = {
					type = "物品",
					name = itemId,
					value = 1,
					dayFlagName = dayFlagName,
					dayFlagValue = 1
				}
	
				table.insert(rewards, reward)
			end
		end
	end

	return rewards
end

function task:getTaskReward()
	
	if  GetTime() > Helper:getTimeStampWithStringDate("20210211", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20210226", 0) then
		local tab = {
			shop_id = "zhounianqin_jf",
			number = 60,
			type = "nanyang"
		}

	 	HttpManagerEx:addCurrency(tab,function(status, errcode, errmsg, data)
	        if status == 200 then
	            if errcode == 0 then
	            	if data.number > 0 then
	                	PopText("新春礼券+"..tostring(data.number))
	                end
	            else
	                PopText(errmsg)
	            end
	        end
	    end, IS_SHOW_WAITING)
	end


	if  GetTime() > Helper:getTimeStampWithStringDate("20210201", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20210208", 0) then
		local num = 60
		local addType="nanyang"
       	HttpManagerEx:addZhounianJifen(addType,num,function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if data.number > 0 then
                        PopText("小年礼券+"..tostring(data.number))
                    end
                else
                    PopText(errmsg)
                end
            end
        end, IS_SHOW_WAITING)
	end

	do
		local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")

		if LimitedTimeExperience:checkTaskIsOpen("nanyang") then
			LimitedTimeExperience:setRole(User:getRole())
			LimitedTimeExperience:finishTaskByTaskType("nanyang")
		end
	end
end

--额外处理
function task:extraFunc()
	local records = {10001,10002,10003,10004}
	for k,recordId in ipairs(records) do
		local record = AchievementSystem:getRecordById(recordId)
		AchievementSystem:add(record)
	end
end

-- 加密版本
task.isEncrypted = true
return task
0000000000000000
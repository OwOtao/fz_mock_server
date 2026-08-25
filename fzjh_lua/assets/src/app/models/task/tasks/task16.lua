local LiLianTaskHelper = require("app.models.task.LiLianTaskHelper")
local TASK_ID = "task16"
local feiZeiRes = LiLianTaskHelper:getTaskConfigInfo(TASK_ID)

local function getTaskConfig(confVer)
	return LiLianTaskHelper:getTaskConfigInfo(TASK_ID, confVer)
end

local task =
{
	id = TASK_ID,

	-- 显示
	buttonA = "taskButton10a",
	buttonB = "taskButton10b",

	-- 数据
	type = "主线任务", -- 任务类型
	name = "飞贼横行", -- 任务名称
	jindu= "fb10",		 -- 需要江湖进度
	desc = {},	--任务文本描述
	warnText = "需通关“鹊起无名卷”第十章才能接取该主动任务",
	coolDown = 0, -- 冷却时间
    Decline = {},  --任务奖励改变次数
	score = {},    --任务改变比例
	texttime = {},  --任务文本改变次数
	rewardtim = {},  --任务次数额外奖励;
	reward = "",      --任务次数额外奖励;
	rate = "",     --获得额外奖励 概率
	taskitem ="",   --获得额外奖励 物品
	addExpBuffName = "addFeizeiExp",--经验加成buff
	zhuXianCondition = -- 主线任务条件
	{
		time = 5,		-- 时间
		-- map = "fb01",		-- 地图
		-- roomId = "fb01_04",	-- 房间
		-- step = 2,		--房间刷怪范围
		mapRoom =
		{
			fb01={roomId = "fb01_27",step= 2},
			fb02={roomId = "fb02_16",step= 2},
			fb03={roomId = "fb03_10",step= 2},
			fb04={roomId = "fb04_38",step= 2},
			fb05={roomId = "fb05_14",step= 2},
			fb06={roomId = "fb06_15",step= 2},
			fb07={roomId = "fb07_25",step= 2},
			fb08={roomId = "fb08_30",step= 2},
			fb09={roomId = "fb09_12",step= 2},
			fb10={roomId = "fb10_26",step= 2},
			fb11={roomId = "fb11_06",step= 2},
			fb12={roomId = "fb12_06",step= 2},
			fb13={roomId = "fb13_24",step= 2},
			fb14={roomId = "fb14_09",step= 2},
			fb15={roomId = "fb15_46",step= 2},
			fb16={roomId = "fb16_20",step= 2},
			fb17={roomId = "fb17_36",step= 2},
			fb18={roomId = "fb18_13",step= 2},
			fb19={roomId = "fb19_29",step= 2},
			fb20={roomId = "fb20_19",step= 2},
			fb21={roomId = "fb21_24",step= 2},
			fb22={roomId = "fb22_16",step= 2},
			fb23={roomId = "fb23_50",step= 2},
			fb24={roomId = "fb24_06",step= 2},
			fb25={roomId = "fb25_27",step= 2},
			fb26={roomId = "fb26_26",step= 2},
			fb27={roomId = "fb27_16",step= 2},
			fb28={roomId = "fb28_11",step= 2},
			fb29={roomId = "fb29_54",step= 2},
			fb30={roomId = "fb30_17",step= 2},
			fb31={roomId = "fb31_04",step= 2},
			fb32={roomId = "fb32_09",step= 2},
			fb33={roomId = "fb33_04",step= 2},
			fb34={roomId = "fb34_06",step= 2},
			fb35={roomId = "fb35_26",step= 2},
			fb36={roomId = "fb36_33",step= 2},
			fb37={roomId = "fb37_103",step= 1},
			fb38={roomId = "fb38_25",step= 2},
			fb39={roomId = "fb39_46",step= 2},
			fb40={roomId = "fb40_07",step= 2}
		},
		buttonColor = {r = 28,g = 76,b = 163},	-- 按钮颜色
		npcList = 	-- 人物列表
		{
			feizei =
			{
				count = 3,	-- 任务添加数量
				action = "kill"	-- 动作
			}
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
		}
	},

	dayReward = {
		{
			--@desc 每日标记 task yinpiao day
			_flag = "typd16",
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
			_flag = "typd16_pijuan",
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
	},

}

task.desc = string.split(feiZeiRes["text"], ";")
task.texttime =  string.split(feiZeiRes["texttime"], ";") 

function task:getDynamicDailyMaxCount(confVer)
	return getTaskConfig(confVer).maxtime
end

function task:getSpecialReward(confVer)
	local rewards = {}
	
	local role = User:getRole()
	
	local taskConfig = getTaskConfig(confVer)
	local taskitem = Helper:getDef(string.split(taskConfig["taskitem"], ";"),{})
	local rate = string.split(taskConfig["rate"], ";")

	if MapIsEmpty(taskitem) == false then
		--@desc 记录飞贼任务奖励次数
		local dayFlagName = "飞贼任务奖励"

		if role:getDayFlag(dayFlagName) >= 3 then
			PopText("您今日获得失窃的包裹已到上限。")
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

--@desc 主动任务属性奖励
function task:getBuff(confVer)
	local tasks = User:getRoleAttr("tasks")

	local roleTask = tasks[self.id]

	local count = roleTask.dCount + 1

	local taskConfig = getTaskConfig(confVer)
	local score_list = string.split(taskConfig["score"], ";")

	local decline_list = string.split(taskConfig["Decline"], ";")

	local buff = 1
	if MapIsEmpty(decline_list) == false then
		for i,v in ipairs(decline_list) do
			if count >= tonumber(v) then
				buff = Helper:getDef(tonumber(score_list[i]),1)
			end
		end
	end

	return buff
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/30 11:48:15
-- @desc 获取任务奖励 (继承自父类,子类实现方法体)
function task:getTaskReward()
	-- 去除师门贡献奖励
	-- HttpManagerEx:addDevotePoint(3, 0, function(status, errcode, errmsg, data)
 --        if status == 200 then
 --            if errcode == 0 then
 --                RichPrint("main", "获得奖励：师门贡献点 + 50")
 --            else
 --                -- PopText(errmsg)
 --            end
 --        end
 --    end, IS_SHOW_WAITING)
 
	if  GetTime() > Helper:getTimeStampWithStringDate("20210211", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20210226", 0) then
		local tab = {
			shop_id = "zhounianqin_jf",
			number = 60,
			type = "feizei"
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
		local addType="feizei"
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

		if LimitedTimeExperience:checkTaskIsOpen("feizei") then
			LimitedTimeExperience:setRole(User:getRole())
			LimitedTimeExperience:finishTaskByTaskType("feizei")
		end
	end
end


-- 加密版本
task.isEncrypted = true
return task
0000
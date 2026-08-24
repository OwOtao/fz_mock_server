local task =
{
	id = "task17",

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
		cCount = 3, -- 当天可完成次数
		canAbandon = true,	-- 任务能否放弃（true 可以 false 不能）
	},

	zhuXianReward = 	--奖励列表
	{
		{
			type = "属性",
			name = "exp",
			value = function(lv, exp, fy, sklv)
				return math.floor(Formula:getFormula("jingyan1")(exp, fy, sklv, 5760,lv))
			end
		},
		{
			type = "属性",
			name = "pot",
			value = function(lv, exp, fy, sklv)
				return math.floor(Formula:getFormula("qianneng1")(exp, fy, sklv, 5760))
			end
		},
		{
			type = "属性",
			name = "yueli",
			value = 5
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

			value = 50,

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

local res = require("script.others.Activetask")
local zhuDongList =  res["主动任务"]
local feizeiList = zhuDongList["2"]
task.desc = string.split(feizeiList["text"], ";")
task.texttime =  string.split(feizeiList["texttime"], ";") 
task.Decline =  string.split(feizeiList["Decline"], ";") 
task.score =  string.split(feizeiList["score"], ";") 
task.taskitem = Helper:getDef(string.split(feizeiList["taskitem"], ";"),{})  
task.rate = string.split(feizeiList["rate"], ";") 


-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/03/30 11:48:15
-- -- @desc 获取任务奖励 (继承自父类,子类实现方法体)
function task:getSpecialReward()
	local rewards = {}
	
	local role = User:getRole()
	
	local taskitem = Helper:getDef(string.split(feizeiList["taskitem"], ";"),{})

	if MapIsEmpty(taskitem) == false then
		--@desc 记录飞贼任务奖励次数
		local dayFlagName = "南阳匪贼任务奖励"
		
		if role:getDayFlag(dayFlagName) >= 3 then
			
			PopText("您今日获得的宝箱已到上限。")
		else
			local itemId = taskitem[role:getDayFlag(dayFlagName) + 1]
	
			local percent = self.rate[role:getDayFlag(dayFlagName) + 1]
	
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

	-- local role = User:getRole()
	-- -- local roleTask = self:getRoleTask(self.id)
	-- local x = math.random( 1, 100 )
	-- local taskitem = Helper:getDef(string.split(feizeiList["taskitem"], ";"),{})  
	-- if MapIsEmpty(taskitem) == true then
	-- else
	-- 	local value = taskitem[role:getDayFlag("南阳匪贼任务奖励") + 1]		-- add by XiaoZhiWei 2017/12/01 21:41:29 物品ID
	-- 	local percent = self.rate[role:getDayFlag("南阳匪贼任务奖励") + 1]	-- add by XiaoZhiWei 2017/12/01 21:41:34 概率
	-- 	if value ~= nil and x <= tonumber(percent) *100 then
	-- 		if role:checkCanBuyTwoOrMoreThings({[value] = 1}) ~= true then
	-- 			-- PopText("背包剩余容量不足，无法获取奖励")
	-- 			return
	-- 		else
	-- 		end
	-- 		role:addItemCount(value, 1)
	-- 		PopText("获得虎威山寨宝箱  X 1")
	-- 		role:setDayFlag("南阳匪贼任务奖励", role:getDayFlag("南阳匪贼任务奖励") + 1)
	-- 	end

	-- 	if role:getDayFlag("南阳匪贼任务奖励") >= 3  then
	-- 		PopText("您今日获得的宝箱已到上限。")
	-- 	end
	-- end
	-- return 1
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
00000000000000
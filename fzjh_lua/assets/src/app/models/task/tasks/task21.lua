

local res = require("script.others.Activetask")
local zhuDongList =  res["主动任务"]
local gusiList = zhuDongList["5"]

local task =
{
	id = "task21",

	-- 显示
	buttonA = "taskButton21a",
	buttonB = "taskButton21b",

	-- 数据
	type = "主线任务", -- 任务类型
	name = "古寺失窃", -- 任务名称
	jindu= "fb25",		 -- 需要江湖进度
	desc = {},	--任务描述
	warnText = "需通关“柳玄风卷上”第五章才能接取该主动任务",

	coolDown = 0, -- 冷却时间

    Decline = {},  --任务奖励改变次数
	score = {},    --任务改变比例
	texttime = nil,  --任务文本改变次数
	rewardtim = {},  --任务次数额外奖励;
	reward = "",      --任务次数额外奖励;
	flag = "追捕主动任务", --任务标记
	defaultMapId = "fb25",

	zhuXianCondition = -- 主线任务条件
	{
		time = 5,		-- 时间
		-- map = "fb01",		-- 地图
		-- roomId = "fb01_04",	-- 房间
		-- step = 2,		--房间刷怪范围
		mapRoom =
		{
			fb25={roomId = "fb25_34",step = 0}
		},
		buttonColor = {r = 28,g = 76,b = 163},	-- 按钮颜色
		npcList = 	-- 人物列表
		{
			-- feizei =
			-- {
			-- 	count = 1,	-- 任务添加数量
			-- 	action = "kill"	-- 动作
			-- }
		},
		-- action = "talk",	--交谈
		-- zCount = 2,	-- 完成总次数
		-- dCount = 1, -- 当天完成次数
		cCount = 1, -- 当天可完成次数
		canAbandon = true,	-- 任务能否放弃（true 可以 false 不能）
	},

	zhuXianReward = 	--奖励列表
	{
		{
			type = "属性",
			name = "exp",
			value = function(lv, exp, fy, sklv)
				return math.floor(Formula:getFormula("jingyan1")(exp, fy, sklv, gusiList["jobreward1"],lv))
			end
		},
		{
			type = "属性",
			name = "pot",
			value = function(lv, exp, fy, sklv)
				return math.floor(Formula:getFormula("qianneng1")(exp, fy, sklv, gusiList["jobreward2"]))
			end
		},
	},
	dayReward = {
		{
			--@desc 每日标记 task yinpiao day
			_flag = "typd21",
			--@desc 每日最大奖励次数
			_count = 1,
			
			_type = "yinpiao",

			value = function (self,count)
				local role = User:getRole()
				local luck = role:getFinalAttr("luck")

				return math.floor(math.min(luck*1.5+40,200))
			end,

			condi = function (self)
				local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
				if HomelandUtil:sysIsOpen(false) == false then
					return
				end

				return true
			end
		},
		{
			--@desc 每日标记 task yinpiao day
			_flag = "typd21_pijuan",
			--@desc 每日最大奖励次数
			_count = 1,
			
			_type = "pijuan",

			value = function (self,count,isDispatchTask)
				if isDispatchTask then 
					return 10
				else
					return 20
				end
			end,

			condi = function ()
				return true
			end
		}
	}

}
--缉拿任务 根据江湖进度 从xuan1 ~ xuanXXX 中获取物品

task.desc = string.split(gusiList["text"], ";")
task.Decline =  string.split(gusiList["Decline"], ";") 
task.score =  string.split(gusiList["score"], ";") 

function task:getTaskReward()
	if GetTime() > Helper:getTimeStampWithStringDate("20210211", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20210226", 0) then
		local tab = {
			shop_id = "zhounianqin_jf",
			number = 80,
			type = "gusishiqie"
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
		local num = 120
		local addType="gusishiqie"
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

		if LimitedTimeExperience:checkTaskIsOpen("gusi") then
			LimitedTimeExperience:setRole(User:getRole())
			LimitedTimeExperience:finishTaskByTaskType("gusi")
		end
	end
end

-- 加密版本
task.isEncrypted = true
return task
000
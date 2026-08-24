local task =
{
	id = "task15",

	-- 显示
	buttonA = "taskButton15a",
	buttonB = "taskButton14b",

	-- 数据
	type = "主线任务", -- 任务类型
	name = "江湖历练", -- 任务名称
	jindu= "fb15",		 -- 需要江湖进度
	tasklevel = 1, -- 任务等级，初始为1最高为5
	taskType = "",    --历练随机任务类型：(江湖送信;缉拿恶徒;南阳匪乱;飞贼横行)
	needTime = 0 ,    --历练随机任务需要完成次数
	num = nil,
	desc = {},	--任务描述
	warnText = "需通关“声震武林卷”第五章才能接取该主动任务",
    last_dCount =0,  --保存历练随机任务之前完成次数
	coolDown = 0, 			-- 冷却时间

	-- defaultMapIndex = 11,	-- 默认地图索引

	zhuXianCondition = -- 主线任务条件
	{
		time = 5,		-- 时间
		-- map = "fb01",		-- 地图
		-- roomId = "fb01_04",	-- 房间
		-- step = 2,		--房间刷怪范围
		mapRoom =
		{
		},
		buttonColor = {r = 28,g = 76,b = 163},	-- 按钮颜色
		npcList = 	-- 人物列表
		{

		},
		-- action = "kill",	--击杀
		-- zCount = 2,	-- 完成总次数
		-- dCount = 1, -- 当天完成次数
		cCount = 5, -- 当天可完成次数
		canAbandon = true,	-- 任务能否放弃（true 可以 false 不能）
	},

	zhuXianReward = 	--奖励列表
	{
		{
			type = "物品",
			name = "lilianbaoxiang1",
			value = 1
		},
	},
}

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/03/30 11:48:15
-- -- @desc 获取任务奖励 (继承自父类,子类实现方法体)
function task:getTaskReward()
	-- HttpManagerEx:addDevotePoint(2, function(status, errcode, errmsg, data)
 --        if status == 200 then
 --            if errcode == 0 then
 --                RichPrint("main", "获得奖励：师门贡献点 + 50")   
 --            else
 --                -- PopText(errmsg)
 --            end
 --        end
 --    end, IS_SHOW_WAITING)
 	local tab = {
 		shop_id = "zhounianqin_jf",
 		number = 30
	 }	
	if GetTime() > Helper:getTimeStampWithStringDate("20170706", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20170721", 0) then
	 	HttpManagerEx:addCurrency(tab,function(status, errcode, errmsg, data)
	        if status == 200 then
	            if errcode == 0 then
	            	if data.number > 0 then
	                	PopText("周年庆积分+"..tostring(data.number))  
	                end
	            else
	                PopText(errmsg)
	            end
	        end
	    end, IS_SHOW_WAITING)
	end
end

--额外处理
function task:extraFunc()
	local recordId = 5006
	local record = AchievementSystem:getRecordById(recordId)
	AchievementSystem:add(record)
end

-- 加密版本
task.isEncrypted = true
return task
0000000000000
local task =
{
	id = "task20",

	-- 显示
	buttonA = "taskButton17a",
	buttonB = "taskButton17b",

	-- 数据
	type = "主线任务", -- 任务类型
	name = "缉拿恶徒", -- 任务名称
	jindu= "fb15",		 -- 需要江湖进度
	desc = {},	--任务描述
	warnText = "需通关“声震武林卷”第五章才能接取该主动任务",

	coolDown = 0, -- 冷却时间

    Decline = nil,  --任务奖励改变次数
	score = nil,    --任务改变比例
	texttime =nil,  --任务文本改变次数
	rewardtime = nil,  --任务次数额外奖励;
	reward = "",      --任务次数额外奖励;
	itemId = nil,
	textId = nil ,
	rate = "",     --获得额外奖励 概率
	taskitem ="",   --获得额外奖励 物品
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
			-- feizei =
			-- {
			-- 	count = 1,	-- 任务添加数量
			-- 	action = "kill"	-- 动作
			-- }
		},
		-- action = "talk",	--交谈
		-- zCount = 2,	-- 完成总次数
		-- dCount = 1, -- 当天完成次数
		cCount = 50, -- 当天可完成次数
		canAbandon = true,	-- 任务能否放弃（true 可以 false 不能）
	},

	zhuXianReward = 	--奖励列表
	{
		{
			type = "属性",
			name = "pot",
			value = function(lv, exp, fy, sklv)
				return math.floor(Formula:getFormula("qianneng1")(exp, fy, sklv, 750))
			end
		},
		{
			type = "属性",
			name = "money",
			value = function(lv, exp, fy, sklv)
				return math.floor(Formula:getFormula("suiyin1")(exp, fy, sklv, 200))
			end
		},
	},

	dayReward = {
		{
			--@desc 每日标记 task yinpiao day
			_flag = "typd20",
			--@desc 每日最大奖励次数
			_count = 3,
			
			_type = "yinpiao",

			value = function (self,count)
				local result = 50

				return result + count * 10
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
			_flag = "typd20_pijuan",
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
local feizeiList = zhuDongList["4"]
task.desc = string.split(feizeiList["text"], ";")
task.texttime =  string.split(feizeiList["texttime"], ";") 
task.Decline =  string.split(feizeiList["Decline"], ";") 
task.score =  string.split(feizeiList["score"], ";") 
task.rewardtime = string.split(feizeiList["rewardtime"], ";") 
task.rate = string.split(feizeiList["rate"], ";") 
task.taskitem = Helper:getDef(string.split(feizeiList["taskitem"], ";"),{})  
function task:getSpecialReward()

	local rewards = {}
	
	local role = User:getRole()
	
	local taskitem = Helper:getDef(string.split(feizeiList["taskitem"], ";"),{})

	if MapIsEmpty(taskitem) == false then
		--@desc 记录飞贼任务奖励次数
		local dayFlagName = "缉拿任务奖励"
		
		if role:getDayFlag(dayFlagName) >= 3 then
			
			PopText("您今日获得的活缉凶宝箱已到上限。")
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


	-- local rewardBuff = 1
	-- local role = User:getRole()
	-- local roleTask = self:getRoleTask(self.id)

	-- -- 结算奖励时，清空当前主动任务物品的值
	-- task.itemId = nil
	
	-- local x = math.random( 1, 10 )
	-- local taskitem = Helper:getDef(string.split(feizeiList["taskitem"], ";"),{})  
	-- if MapIsEmpty(taskitem) == true then
	-- else
	-- 	local value = taskitem[role:getDayFlag("缉拿任务奖励") + 1]		-- add by XiaoZhiWei 2017/12/01 21:41:29 物品ID
	-- 	local percent = self.rate[role:getDayFlag("缉拿任务奖励") + 1]	-- add by XiaoZhiWei 2017/12/01 21:41:34 概率
	-- 	if value ~= nil and x <= tonumber(percent) *10 then
	-- 		if role:checkCanBuyTwoOrMoreThings({[value] = 1}) ~= true then
	-- 			-- PopText("背包剩余容量不足，无法获取奖励")
	-- 			return
	-- 		else
	-- 		end
	-- 		role:addItemCount(value, 1)
	-- 		PopText("获得急公好义宝箱  X 1")
	-- 		role:setDayFlag("缉拿任务奖励", role:getDayFlag("缉拿任务奖励") + 1)
	-- 		if role:getDayFlag("缉拿任务奖励") >= 3 then
	-- 		else
	-- 			return self:dealRewardMagnification(rewardBuff)
	-- 		end
	-- 	end

	-- 	if role:getDayFlag("缉拿任务奖励") >= 3  then
	-- 		PopText("您今日获得的活缉凶宝箱已到上限。")
	-- 	end
	-- end
	
	-- return self:dealRewardMagnification(rewardBuff)
end
-- -----------------------------------------------------------------------------------------------------------
-- -- @author GaoHanZheng
-- -- @time 2017/07/24 17:06:51
-- -- @desc 奖励倍数
-- function task:dealRewardMagnification(rewardBuff)
-- 	local roleTask = self:getRoleTask(self.id)
-- 	local count = roleTask.dCount + 1 --加上当前一次，共完成的任务次数
-- 	-- if count > 30 then
-- 	-- 	rewardBuff = (1 - (count - 30) * 0.05) * rewardBuff --超过30次每次奖励递减5%
-- 	-- end
-- 	local score = string.split(feizeiList["score"], ";") 
-- 	local Decline = string.split(feizeiList["Decline"], ";") 
-- 	if MapIsEmpty(Decline) == true then
-- 		print("主动任务配置 江湖送信 reward为nil")
-- 	else
-- 		for k,v in pairs(Decline) do
-- 			-- 缉拿任务完成第3次或第5次奖励一个宝箱, 每天最多2次
-- 			if count >= tonumber(v)  then
-- 				rewardBuff = Helper:getDef(  tonumber(score[k]),0)
-- 			end
	
-- 	   end
-- 	end 
-- 	return Helper:getRange(rewardBuff, 0)
-- end

--@desc 主动任务属性奖励
function task:getBuff()
	local tasks = User:getRoleAttr("tasks")

	local roleTask = tasks[self.id]

	local count = roleTask.dCount + 1

	local score_list = string.split(feizeiList["score"], ";")

	local decline_list = string.split(feizeiList["Decline"], ";")

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
    --     if status == 200 then
    --         if errcode == 0 then
    --             RichPrint("main", "获得奖励：师门贡献点 + 50")
    --         else
    --             -- PopText(errmsg)
    --         end
    --     end
    -- end, IS_SHOW_WAITING)

	if GetTime() > Helper:getTimeStampWithStringDate("20210211", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20210226", 0) then
		local tab = {
			shop_id = "zhounianqin_jf",
			number = 30,
			type = "jinaetu"
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
		local num = 30
		local addType="jinaetu"
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

		if LimitedTimeExperience:checkTaskIsOpen("jina") then
			LimitedTimeExperience:setRole(User:getRole())
			LimitedTimeExperience:finishTaskByTaskType("jina")
		end
	end
end

function task:setSpecialTask()
	self:setTaskDesc()
	-- self:setTaskTime()
end

--缉拿任务 根据江湖进度 从xuan1 ~ xuanXXX 中获取物品
local wantedItemId =
{
	{mapId = "fb01" , index = 1},
	{mapId = "fb02" , index = 2},
	{mapId = "fb03" , index = 4},
	{mapId = "fb04" , index = 6},
	{mapId = "fb05" , index = 8},
	{mapId = "fb06" , index = 9},
	{mapId = "fb07" , index = 11},
	{mapId = "fb08" , index = 12},
	{mapId = "fb09" , index = 14},
	{mapId = "fb10" , index = 16},
	{mapId = "fb11" , index = 17},
	{mapId = "fb12" , index = 18},
	{mapId = "fb13" , index = 19},
	{mapId = "fb14" , index = 20},
	{mapId = "fb15" , index = 21},
	{mapId = "fb16" , index = 23},
	{mapId = "fb17" , index = 24},
	{mapId = "fb18" , index = 26},
	{mapId = "fb19" , index = 27},
	{mapId = "fb20" , index = 29},
	{mapId = "fb21" , index = 30},
	{mapId = "fb22" , index = 31},
	{mapId = "fb23" , index = 32},
	{mapId = "fb24" , index = 33},
	{mapId = "fb25" , index = 35},
	{mapId = "fb26" , index = 37},
	{mapId = "fb27" , index = 39},
	{mapId = "fb28" , index = 40},
	{mapId = "fb29" , index = 41},
	{mapId = "fb30" , index = 42},
	{mapId = "fb31" , index = 43},
	{mapId = "fb32" , index = 45},
	{mapId = "fb33" , index = 46},
	{mapId = "fb34" , index = 47},
	{mapId = "fb35" , index = 48},
	{mapId = "fb36" , index = 48},
	{mapId = "fb37" , index = 48},
}

function task:setTaskDesc()
	-- local progress = User:getRoleAttr("jindu")
	-- if progress == 0 then
	-- 	progress = 1
	-- end
	local role = User:getRole()
	--缉拿任务 根据江湖进度 从xuan1 ~ xuanXXX 中获取物品

	--根据江湖进度获物品
	local function getWantedItemId()
		local random_range = 0
		local item_index

		for i=#wantedItemId,1,-1 do
			if Map:getMapState(wantedItemId[i].mapId) == MAP_STATE.COMPLETE then
				random_range = wantedItemId[i].index
				break
			end
		end

		print("获得悬赏公告范围1~" .. random_range)
		item_index = math.random(1, random_range)
		local itemId = "xuan" .. tostring(item_index)
		 
		for v=1,item_index do
			--遍历当前背包是否已有告示，删除它
			local items  = User:getRole():getItemsWithItemId("xuan" .. v)
			if MapIsEmpty(items) == false then
				local itemNun = role:getItemCount("xuan" .. v)
				if itemNun > 0 then
					if tostring(role:getFlag("主动任务物品"))  == "xuan" .. v  then
						role:addItemCount("xuan" .. v ,-itemNun)
						role:addItemCount("xuan" .. v ,1)
					else
						role:addItemCount("xuan" .. v ,-itemNun)
					end
				end
			end
		end
		
		return itemId, item_index
	end

	local itemId, id = getWantedItemId()
	local itemCount = 1

	if role:getFlag("主动任务物品")== "nil" then
		task.itemId = nil
		task.textId = nil
	end

	if task.textId == nil then
		task.textId = id
	end  
	if task.itemId == nil then
		task.itemId = itemId
	end

	
	local items  = role:getItemsWithItemId(role:getFlag("主动任务物品"))
	if MapIsEmpty(items) == true then
		if role:checkCanBuyThings(task.itemId,itemCount) then 
			role:addItemCount(task.itemId , itemCount)
			Statistics:recordItemCount(task.itemId , itemCount) -- 用于统计
			role:setFlag("主动任务物品",task.itemId)
			
			--规避配置表中物品为空情况
			if Item:getOneItemByKey(task.itemId ) == nil or Item:getOneItemByKey(task.itemId ).name ==nil or Item:getOneItemByKey(task.itemId ).dsc ==nil then
				return
			end

			PopText("你获得了 "..Item:getOneItemByKey(task.itemId ).name)
			RichPrint("main", Item:getOneItemByKey(task.itemId ).dsc) 
		end
	else
		task.itemId = role:getFlag("主动任务物品")
		PopText("你已经获得过 "..Item:getOneItemByKey(role:getFlag("主动任务物品") ).name)
	end
	
	
end

-- 加密版本
task.isEncrypted = true
return task
00000000
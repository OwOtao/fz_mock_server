local LiLianTaskHelper = require("app.models.task.LiLianTaskHelper")
local TASK_ID = "task19"
local songXinRes = LiLianTaskHelper:getTaskConfigInfo(TASK_ID)

local function getTaskConfig(confVer)
	return LiLianTaskHelper:getTaskConfigInfo(TASK_ID, confVer)
end

local task =
{
	id = TASK_ID,

	-- 显示
	buttonA = "taskButton16a",
	buttonB = "taskButton16b",

	-- 数据
	type = "主线任务", -- 任务类型
	name = "江湖送信", -- 任务名称
	jindu= "fb10",		 -- 需要江湖进度
	desc = nil,	--任务描述
	warnText = "需通关“鹊起无名卷”第十章才能接取该主动任务",

    
	coolDown = 0, -- 冷却时间
    Decline = nil,  --任务奖励改变次数
	score = nil,    --任务改变比例
	texttime = nil,  --任务文本改变次数
	rewardtim = nil,  --任务次数额外奖励;
	reward = "",      --任务次数额外奖励;
	firstReward = "",
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
		},
		-- action = "talk",	--交谈
		-- zCount = 2,	-- 完成总次数
		-- dCount = 1, -- 当天完成次数
		canAbandon = true,	-- 任务能否放弃（true 可以 false 不能）
	},

	zhuXianReward = 	--奖励列表
	{
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
			name = "money",
			value = function(lv, exp, fy, sklv, confVer)
				local taskConfig = getTaskConfig(confVer)
				return math.floor(Formula:getFormula("suiyin1")(exp, fy, sklv, taskConfig.jobreward3))
			end
		},
	},

	dayReward = {
		{
			--@desc 每日标记 task yinpiao day
			_flag = "typd19",
			--@desc 每日最大奖励次数
			_count = 1,
			
			_type = "yinpiao",

			--@count 今日已领取次数
			value = function (self,count,isDispatchTask,confVer)
				--完成次数
				local countTimes = count + 1 
				return LiLianTaskHelper:getYinPiaoCount(countTimes, getTaskConfig(confVer))
			end,

			condi = function ()
				local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
				if HomelandUtil:sysIsOpen(false) == false then
					return
				end

				return true
			end
		},
		{
			--@desc 每日标记 task yinpiao day
			_flag = "typd19_pijuan",
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

task.desc = string.split(songXinRes["text"], ";")
task.texttime =  string.split(songXinRes["texttime"], ";") 

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
		local dayFlagName = "信使任务奖励"
		
		if role:getDayFlag(dayFlagName) >= 3 then
			
			PopText("您今日获得的信使宝箱已到上限。")
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
			type = "songxin"
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
		local addType="songxin"
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

		if LimitedTimeExperience:checkTaskIsOpen("songxin") then
			LimitedTimeExperience:setRole(User:getRole())
			LimitedTimeExperience:finishTaskByTaskType("songxin")
		end
	end
end

function task:setSpecialTask()
	self:setTaskDesc()
	-- self:setTaskTime()
end


function task:setTaskDesc()
	-- local progress = User:getRoleAttr("jindu")
	local role = User:getRole()
	-- if progress == 0 then
	-- 	progress = 1
	-- end
	
	--送信输出文本
	local letterText =
	{
		[100] = "驿丞：朱帆在金牛武馆，你快些去吧。",
		[101] = "驿丞：李先生在金牛武馆，你快些去吧。",
		[102] = "驿丞：秋月在金牛武馆，你快些去吧。",
		[103] = "驿丞：妙真在衡阳城，你快些去吧。",
		[104] = "驿丞：汪恒在衡阳城，你快些去吧。",
		[105] = "驿丞：茶博士在衡阳城，你快些去吧。",
		[106] = "驿丞：王厨子在衡阳城，你快些去吧。",
		[107] = "驿丞：王铁牛在牛家村，你快些去吧。",
		[108] = "驿丞：李忠在牛家村，你快些去吧。",
		[109] = "驿丞：老渔翁在牛家村，你快些去吧。",
		[110] = "驿丞：严石楼在荆州城南，你快些去吧。",
		[111] = "驿丞：李二牛在荆州城南，你快些去吧。",
		[112] = "驿丞：钟石头在荆州城南，你快些去吧。",
		[113] = "驿丞：李麻子在华山村，你快些去吧。",
		[114] = "驿丞：王小二在华山村，你快些去吧。",
		[115] = "驿丞：李四在华山村，你快些去吧。",
		[116] = "驿丞：青云在逍遥林，你快些去吧。",
		[117] = "驿丞：苟读在逍遥林，你快些去吧。",
		[118] = "驿丞：汪云在黄河北边，你快些去吧。",
		[119] = "驿丞：沈青钢在黄河帮内，你快些去吧。",
		[120] = "驿丞：王绝在黄河北边，你快些去吧。",
		[121] = "驿丞：鲍通明在黄河北边，你快些去吧。",
		[122] = "驿丞：店小二在黄河，你快些去吧。",
		[123] = "驿丞：李通玄在青城山，你快些去吧。",
		[124] = "驿丞：莫子悠在青城山，你快些去吧。",
		[125] = "驿丞：薛子叹在青城山，你快些去吧。",
		[126] = "驿丞：武器店老板在金陵城，你快些去吧。",
		[127] = "驿丞：穆守财在金陵城，你快些去吧。",
		[128] = "驿丞：秦方好在金陵城，你快些去吧。",
		[129] = "驿丞：仇好石在扬州城,你快些去吧。",
		[130] = "驿丞：杨万萧在扬州城,你快些去吧。",
		[131] = "驿丞：笑莫问在扬州城,你快些去吧。",
		[132] = "驿丞：何员外在扬州城,你快些去吧。",
		[133] = "驿丞：韩一枫在南阳城,你快些去吧。",
		[134] = "驿丞：船夫在南阳城,你快些去吧。",
		[135] = "驿丞：大汉在南阳城,你快些去吧。",
		[136] = "驿丞：江耀亭在汝州城,你快些去吧。",
		[137] = "驿丞：店小二在汝州城,你快些去吧。",
		[138] = "驿丞：云奇在嵩山,你快些去吧。",
		[139] = "驿丞：李长生在嵩山,你快些去吧。",
		[140] = "驿丞：乐厚在嵩山,你快些去吧。",
		[141] = "驿丞：智远在嵩山,你快些去吧。",
		[142] = "驿丞：觉寂在少林寺,你快些去吧。",
		[143] = "驿丞：觉欲在少林寺,你快些去吧。",
		[144] = "驿丞：觉志在少林寺,你快些去吧。",
		[145] = "驿丞：慧觉禅师在少林寺,你快些去吧。",
		[146] = "驿丞：慧相禅师在少林寺,你快些去吧。",
		[147] = "驿丞：赵良栋在苏州城,你快些去吧。",
		[148] = "驿丞：王公子在苏州城,你快些去吧。",
		[149] = "驿丞：李友贤在苏州城,你快些去吧。",
		[150] = "驿丞：谢文韵在苏州城,你快些去吧。",
		[151] = "驿丞：司马瑞在慕容山庄,你快些去吧。",
		[152] = "驿丞：刘远在慕容山庄,你快些去吧。",
		[153] = "驿丞：颜奇在慕容山庄,你快些去吧。",
		[154] = "驿丞：吕一山在华山,你快些去吧。",
		[155] = "驿丞：宋思明在华山,你快些去吧。",
		[156] = "驿丞：魏思明在华山,你快些去吧。",
		[157] = "驿丞：樊一翁在绝情谷,你快些去吧。",
		[158] = "驿丞：黄真在襄阳城,你快些去吧。",
		[159] = "驿丞：王迩在武当山,你快些去吧。",
		[160] = "驿丞：张三在武当山,你快些去吧。",
		[161] = "驿丞：王不谓在武当山,你快些去吧。",
		[162] = "驿丞：唐不离在唐家堡,你快些去吧。",
		[163] = "驿丞：唐西在唐家堡,你快些去吧。",
		[164] = "驿丞：唐啼在唐家堡,你快些去吧。",
		[165] = "驿丞：闵爽在峨眉山,你快些去吧。",
		[166] = "驿丞：柳柔在峨眉山,你快些去吧。",
		[167] = "驿丞：谢依依在峨眉山,你快些去吧。",
		[168] = "驿丞：茶博士在长安城,你快些去吧。",
		[169] = "驿丞：吴学究在长安城,你快些去吧。",
		[170] = "驿丞：李青峰在长安城,你快些去吧。",
		[171] = "驿丞：马老板在武功镇,你快些去吧。",
		[172] = "驿丞：顾清流在终南山,你快些去吧。",
		[173] = "驿丞：齐志明在终南山,你快些去吧。",
		[174] = "驿丞：李先生在终南山,你快些去吧。",
		[175] = "驿丞：潘秀达在五毒教,你快些去吧。",
		[176] = "驿丞：洪血衣在五毒教,你快些去吧。",
		[177] = "驿丞：白髯老者在五毒教,你快些去吧。",
		[178] = "驿丞：任千山在大理,你快些去吧。",
		[179] = "驿丞：李安在大理,你快些去吧。",
		[180] = "驿丞：李大妈在大理,你快些去吧。",
		[181] = "驿丞：王大妈在大理,你快些去吧。",
		[182] = "驿丞：瑛姑在一灯居,你快些去吧。",
		[183] = "驿丞：真如在一灯居,你快些去吧。",
		[184] = "驿丞：真言在一灯居,你快些去吧。",
		[185] = "驿丞：真慧在一灯居,你快些去吧。",
		[186] = "驿丞：黄眉大师在万劫谷,你快些去吧。",
		[187] = "驿丞：宋思量在无量山,你快些去吧。",
		[188] = "驿丞：吴光胜在无量山,你快些去吧。",
		[189] = "驿丞：郁光标在无量山,你快些去吧。",
		[190] = "驿丞：葛光佩在无量山,你快些去吧。",
		[191] = "驿丞：段正淳在天龙寺,你快些去吧。",
		[192] = "驿丞：菊剑在灵鹫宫,你快些去吧。",
		[193] = "驿丞：兰剑在灵鹫宫,你快些去吧。",
		[194] = "驿丞：竹剑在灵鹫宫,你快些去吧。",
		[195] = "驿丞：梅剑在灵鹫宫,你快些去吧。",
	}
	
	--送信 根据江湖进度 从xin100 ~ xinXXX 中获取物品
	local letterItemId =
	{
		{mapId = "fb01",itemIndex = 132},
		{mapId = "fb16",itemIndex = 150},
		{mapId = "fb22",itemIndex = 158},
		{mapId = "fb26",itemIndex = 170},
		{mapId = "fb31",itemIndex = 181},
		{mapId = "fb36",itemIndex = 195},
		-- [1]  = 132,
		-- [16] = 150,
		-- [22] = 158,
		-- [26] = 170,
		-- [31] = 181,
		-- [36] = 195
	}
	--根据江湖进度获取送信物品
	local function getLetterItemId()
		local random_index = 0
		local item_index
		for i=#letterItemId,1,-1 do
			if Map:getMapState(letterItemId[i].mapId) == MAP_STATE.COMPLETE then
				random_index = letterItemId[i].itemIndex 
				break
			end
		end
		
		-- for k,v in pairs(letterItemId) do
		-- 	if k <= progress then
		-- 		p = k
		-- 	end
		-- end

		item_index = math.random(100, random_index)
		local str = "xin" .. tostring(item_index)

		for v=100,random_index do
			--遍历当前背包是否已有告示，删除它
			local items  = User:getRole():getItemsWithItemId("xin" .. v)
			if MapIsEmpty(items) == false then
				local itemNun = role:getItemCount("xin" .. v)
				if itemNun > 0 then
					if tostring(role:getFlag("主动任务物品"))  == "xin" .. v  then
						role:addItemCount("xin" .. v ,-itemNun)
						role:addItemCount("xin" .. v ,1)
					else
						role:addItemCount("xin" .. v ,-itemNun)
					end
				end
			end
		end
		return str, item_index
	end

	local itemId, id = getLetterItemId()
	local itemCount = 1

	User:setRoleAttr("letterTime", GetTime())


	--增加能否获取物品的判断 7/22
	-- if not self:addItemCount(itemId, itemCount) then
	-- 	self:dropItem(environment.currRoomId, itemId)
	-- 	return
	-- end
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
	
	local items  = User:getRole():getItemsWithItemId(	role:getFlag("主动任务物品"))
	if MapIsEmpty(items) == true then
		if role:checkCanBuyThings(task.itemId,itemCount) then 
			role:addItemCount(task.itemId , itemCount)
			Statistics:recordItemCount(task.itemId , itemCount) -- 用于统计
			role:setFlag("主动任务物品",task.itemId)
			PopText("你获得了 "..Item:getOneItemByKey(task.itemId ).name)
		end
	else

		task.itemId = role:getFlag("主动任务物品")
		PopText("你已经获得过 "..Item:getOneItemByKey(role:getFlag("主动任务物品") ).name)
	end


end

-- function task:setTaskTime()
-- 	local interval =  result.arg2
-- 	interval = math.random(200, interval)  --获取随机值
-- 	print("送信时间随机最大值:" .. result.arg2 .. "随机值" .. interval)
-- 	task.letterInterval = interval
-- end

-- 加密版本
task.isEncrypted = true
return task
000000000
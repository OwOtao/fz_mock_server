local LiLianTaskHelper = require("app.models.task.LiLianTaskHelper")
local TASK_ID = "task18"
local feizeiList = LiLianTaskHelper:getTaskConfigInfo(TASK_ID)

local function getTaskConfig(confVer)
	return LiLianTaskHelper:getTaskConfigInfo(TASK_ID, confVer)
end

local task =
{
	id = TASK_ID,

	-- 显示
	buttonA = "taskButton18a",
	buttonB = "taskButton18a",

	-- 数据
	type = "主线任务", -- 任务类型
	name = "腊八施粥", -- 任务名称
	jindu= "fb15",		 -- 需要江湖进度
	desc = {},	--任务文本描述
	warnText = "需通关“声震武林卷”第五章才能接取该主动任务",
    
	coolDown = 0, -- 冷却时间
    Decline = {},  --任务奖励改变次数
	score = {},    --任务改变比例
	texttime = nil,  --任务文本改变次数
	rewardtim = {},  --任务次数额外奖励;
	reward = "",      --任务次数额外奖励;

	-- flag = "腊八施粥", --任务标记
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
			feizei =
			{
			
			}
		},
		-- action = "kill",	--击杀
		-- zCount = 2,	-- 完成总次数
		-- dCount = 1, -- 当天完成次数
		cCount = 1, -- 当天可完成次数
		canAbandon = true,	-- 任务能否放弃（true 可以 false 不能）
	},

	zhuXianReward = 	--奖励列表
	{
		-- {
		-- 	type = "属性",
		-- 	name = "exp",
		-- 	value = function(lv, exp, fy, sklv)
		-- 		return math.floor(Formula:getFormula("jingyan1")(exp, fy, sklv, Helper:getDef(feizeiList["jobreward1"],0)))
		-- 	end
		-- },
		-- {
		-- 	type = "属性",
		-- 	name = "pot",
		-- 	value = function(lv, exp, fy, sklv)
		-- 		return math.floor(Formula:getFormula("jingyan1")(exp, fy, sklv,Helper:getDef(feizeiList["jobreward2"],0)))
		-- 	end
		-- },
		-- {
		-- 	type = "属性",
		-- 	name = "money",
		-- 	value = function(lv, exp, fy, sklv)
		-- 		return math.floor(Formula:getFormula("suiyin1")(exp, fy, sklv, Helper:getDef(feizeiList["jobreward3"],0)))
		-- 	end
		-- },
		{
			type = "物品",
			name = "lababaoxiang1",
			value = 1
		},
	},

}
if type(feizeiList) ~= "table" then
	print("Activetask 资源有问题")
end
task.desc = string.split(Helper:getDef(feizeiList["text"],""), ";")

-- end
local familyRewardId ={
	["官府"] = "labashimenli1",-- labashimenli1	官府        
	["少林派"] = "labashimenli2",-- labashimenli2	少林派
	["全真教"] = "labashimenli3",-- labashimenli3	全真教
	["天龙寺"] = "labashimenli4",-- labashimenli4	天龙寺
	["丐帮"] = "labashimenli5",-- labashimenli5	丐帮
	["峨眉派"] = "labashimenli6",-- labashimenli6	峨眉派
	["武当派"] = "labashimenli7",-- labashimenli7	武当派
	["华山宗"] = "labashimenli8",-- labashimenli8	华山宗
	["昆仑派"] = "labashimenli9",-- labashimenli9	昆仑派
	["五毒教"] = "labashimenli10",-- labashimenli10	五毒教
	["铁掌帮"] = "labashimenli11",-- labashimenli11	铁掌帮
	["日月神教"] = "labashimenli12",-- labashimenli12	日月神教
	["雪山寺"] = "labashimenli13",-- labashimenli13	雪山寺
	["星宿派官府"] = "labashimenli14",-- labashimenli14	星宿派
	["白驼山"] = "labashimenli15",-- labashimenli15	白驼山
	["慕容山庄"] = "labashimenli16",-- labashimenli16	慕容山庄
	["明教"] = "labashimenli17",-- labashimenli17	明教
	["唐门"] = "labashimenli18",-- labashimenli18	唐门
	["桃花岛"] = "labashimenli19",-- labashimenli19	桃花岛
	["古墓派"] = "labashimenli20",-- labashimenli20	古墓派
	["崆峒派"] = "labashimenli21",-- labashimenli21	崆峒派
	["海鲸帮"] = "labashimenli22",-- labashimenli22	海鲸帮
	["幽冥教"] = "labashimenli23",-- labashimenli23    幽冥教
	["天山派"] = "labashimenli24",-- labashimenli24	天山派
	["落月山庄"] = "labashimenli25",-- labashimenli25	落月山庄
}
function task:setSpecialTask()
	self:setTaskDesc()
end
function task:setTaskDesc()
	-- User:getRole():setInheritFlag("腊八施粥",1)
	-- RichPrint("main" ,"施粥长老正在浮云寺寺门处等着少侠，快快前去吧。")
end

function task:getDynamicDailyMaxCount(confVer)
	return getTaskConfig(confVer).maxtime
end

function task:getSpecialReward(confVer)
	local role = User:getRole()
	local roleTask = self:getRoleTask(self.id)
	local familyName = role:getFamilyName() --XX门派   没有门派就江湖浪人
	local day  = roleTask.dCount + 1  --完成次数
	if day ==7 and familyRewardId[familyName] ~= nil then
        
		local items  = User:getRole():getItemsWithItemId(familyRewardId[familyName])
		if MapIsEmpty(items) == true then
			role:addItemCount(task.itemId , 1)
			PopText("你获得了 "..Item:getOneItemByKey(task.itemId ).name)
		end
	end
	return 1
end

-- 加密版本
task.isEncrypted = true
return task
000000000000000
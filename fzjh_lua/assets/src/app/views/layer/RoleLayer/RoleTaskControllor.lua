local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local AsyncFunction = require("third.async.AsyncFunction")

--[[
	要注意ifelse的判断顺序   有优先级别的
	关系图: (———— : 互斥关系,不能同时进行)
		练功 ———— 闭关 ———— 研读 
		闭关 ———— 练功 ———— 研读 
		研读 ———— 练功 ———— 闭关 
		挂机
		打坐 ———— 观战 ———— 调息
		观战 ———— 打坐 
		调息 ———— 打坐 
		师门任务 ———— 主动任务
		主动任务 ———— 师门任务
		空闲
]]
local RoleTaskControllor = {}

local CNlist = 
{
	[ROLE_CURR_STATE_GUAJI] = "挂机",
	[ROLE_CURR_STATE_DAZUO] = "打坐",
	[ROLE_CURR_STATE_LIANGONG] = "练功",
	[ROLE_CURR_STATE_BIGUAN] = "闭关",
	[ROLE_CURR_STATE_GUANZHAN] = "观战",
	[ROLE_CURR_STATE_READ] = "研读",
	[ROLE_CURR_STATE_TEACHERGUAJI] = "师门挂机",
	[ROLE_CURR_STATE_XIULIAN] = "修炼",   --修炼可视为为高级练功 相关干系与练功等同 但修炼与练功互斥
	-- [ROLE_CURR_STATE_LIANJINGHUAQI] = "炼气",
}

local stopList = {
    [ROLE_CURR_STATE_GUAJI] = function()
		local ok, msg = User:getRole():getHangUpSystem():manualStopHangUpTask(User:getRole():getHangUpSystem():getCurrHangUpTaskId())
		return ok, msg
    end,
    [ROLE_CURR_STATE_DAZUO] = function()
        User:getRole():stopDaZuo()
        return true
    end,
    [ROLE_CURR_STATE_LIANGONG] = function()
        local lianGongSystem = User:getRole():getLianGongSystem()
        local ok, msg = AsyncFunction:asyncAwaitWithCallback(lianGongSystem.stopLianGongOnline, lianGongSystem, "callback",nil)
        return ok, msg
    end,
    [ROLE_CURR_STATE_BIGUAN] = function()
        User:getRole():stopBiGuan()
        return true
    end,
    [ROLE_CURR_STATE_GUANZHAN] = function()
        User:getRole():stopGuanZhan()
        return true
    end,
    [ROLE_CURR_STATE_READ] = function()
        User:getRole():stopRead()
        return true
    end,
    [ROLE_CURR_STATE_TEACHERGUAJI] = function()
        User:getRole():stopTeacherGuaJiTask()
        return true
    end,
	[ROLE_CURR_STATE_XIULIAN] = function()
		local xiuLianSystem = User:getRole():getXiuLianSystem()
        local ok, msg = AsyncFunction:asyncAwaitWithCallback(xiuLianSystem.stopXiuLianOnline, xiuLianSystem, "callback",nil)
        return ok, msg
    end
}


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/29 16:41:33
-- @desc 取消支线类任务 主动任务及进入副本时判断使用
--[[
	提示内容: 正在进行其他动作（XX/XX/XX）,是否取消
			取消动作将无法继续获得收益
	按钮1 : 是
	按钮2: 否
]]
function RoleTaskControllor:cancelTaskLayer(role, func1, func2, statusList)
	if role == nil then
		return
	end
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)

	local stateMap = {}
	if MapIsEmpty(statusList) == false then
		for k, v in ipairs(statusList) do
			if role:isInCurrState(v) == true then
				stateMap[v] = true
			end
		end
	else
		stateMap = role:getRoleCurrStateMap()
	end

	local str = "正在进行其他动作（"
	
	for state,boole in pairs(stateMap) do
		str = str .. tostring(CNlist[state]) .. "/"
	end

	str = string.sub(str, 1, #str - 1)
	str = str .. "）,是否取消"

	local dialog = DialogALayer:getInstance()
	dialog:show(str,"取消动作将无法继续获得收益")
	dialog:setButton1("取消", function()
        local success = true
        local errmsg = ""
        for state,boole in pairs(stateMap) do
            local ok, msg = AsyncFunction:asyncAwait(function()
                return switch(state, stopList)
            end)
            if ok == false then
                success = false
                errmsg = msg
                break
            end
        end
        if success then
            func1()
        else
            PopText(errmsg)
        end
	end)
	dialog:setButton2("返回", function()
		func2()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/31 11:53:14
-- @desc 取消支线类任务带分身符选项
--[[
	提示内容: 正在XX
		取消动作将无法继续获得收益
	按钮1 : 取消XX
	按钮2: 分身符
	按钮3: 返回
]]
function RoleTaskControllor:cancelTaskWithFSLayer(role, func1, func2, func3)
	if role == nil then
		return
	end
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	func3 = Helper:getDef(func3, EMPTY_FUNC)

	local str, currState = "", 0
	local stateList = role:getRoleCurrStateMap()
	for state,boole in pairs(stateList) do
		if CNlist[state] ~= nil then
			str = CNlist[state]
			currState = state
			break
		end
	end

	local dialog = DialogALayer:getInstance()
	dialog:show("正在"..str.."，是否取消".. str, "取消动作将无法继续获得收益")
	dialog:setButton1("取消".. str, function()
        local ok, msg = AsyncFunction:asyncAwait(function()
            return switch(currState, stopList)
        end)
        if ok then
            func1()
        else
            PopText(msg)
        end
	end)
	dialog:setButton2("分身符", function()
		local item = Item:getOneItemByKey("fenshenfu")
		if item then
			item:storeItemUse(function()
				func2()
			end)
		end
	end)
	dialog:setButton3("返回", function() 
		func3()
	end)
	dialog:setBack(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/29 16:41:27
-- @desc 取消主动任务
--[[
	提示内容: 正在进行其他主动任务，是否取消    
		取消动作将无法继续获得收益
	按钮1 : 是
	按钮2: 否
]]
function RoleTaskControllor:cancelZhuXianLayer(role, func1, func2)
	if role == nil then
		return
	end
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	local dialog = DialogALayer:getInstance()
	dialog:show("正在进行其他主动任务，是否取消" ,"取消动作将无法继续获得收益")
	dialog:setButton1("取消", function()
		-- if role:getTask(role:getAttr("currTaskId")).state == TASK_STATE_TO_SUBMIT then
		-- 	PopText("待提交的任务不能取消")
		-- 	return
		-- end
		-- local currTaskId = role:getAttr("currTaskId")
		-- local cancelSuccess = true
		-- if currTaskId == nil then
		-- 	role:removeRoleCurrState(ROLE_CURR_STATE_ZHUDONG)
		-- else
		-- 	local task = Task:getTask(currTaskId)
		-- 	cancelSuccess = task:cancelTask()
		-- 	-- -- 主动任务 切换取消时不会继续随机到同一个npc
		-- 	-- if task.id == "task19" or task.id == "task20" then
		-- 	-- 	User:getRole():addItemCount(User:getRole():getFlag("主动任务物品"), -1)
		-- 	-- 	User:getRole():setFlag("主动任务物品","nil")
		-- 	-- end
		-- end
		local cancelSuccess = role:getLiLianTaskSystem():cancelZhuDongTask(role:getAttr("currTaskId"))
		if cancelSuccess then 
			func1()
		end
	end)
	dialog:setButton2("返回", function()
		-- dialog:hide()
		func2()
	end)
	dialog:setBack(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/31 11:54:58
-- @desc 取消调息任务
--[[
	提示内容: 正在调息中，可使用醒身丸立即结束调息并获得真气    
	按钮1 : 使用醒身丸
	按钮2: 取消调息
	按钮3: 返回
]]
function RoleTaskControllor:cancelTiaoXiLayer(role, func1, func2, func3)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	func3 = Helper:getDef(func3, EMPTY_FUNC)
	local dialog = DialogALayer:getInstance()
	dialog:show("正在调息中，可使用醒身丸立即结束调息并获得真气", "取消动作将无法继续获得收益")
	dialog:setButton1("使用醒身丸", function()
		if role:stopPranayama() then
			func1()
		end
	end)
	dialog:setButton2("取消调息", function()
		role:cancelPranayama()
		func2()
	end)
	dialog:setButton3("返回", function()
		dialog:hide()
		func3()
	end)
	dialog:setBack(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/31 11:56:39
-- @desc 取消调息任务带分身符选项
--[[
	提示内容: 正在调息中，可使用醒身丸立即结束调息并获得真气    
	按钮1 : 使用醒身丸
	按钮2: 分身符
	按钮3: 取消调息
]]
function RoleTaskControllor:cancelTiaoXiWithFSLayer(role, func1, func2, func3)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	func3 = Helper:getDef(func3, EMPTY_FUNC)
	local dialog = DialogALayer:getInstance()
	dialog:show("正在调息中，可使用醒身丸立即结束调息并获得真气", "取消动作将无法继续获得收益")
	dialog:setButton1("使用醒身丸", function()
		role:stopPranayama()
		func1()
	end)
	dialog:setButton2("分身符", function()
		local item = Item:getOneItemByKey("fenshenfu")
		if item then
			item:storeItemUse(function()
				func2()
			end)
		end
	end)
	dialog:setButton3("取消调息", function()
		role:cancelPranayama()
		func3()
	end)
	dialog:setBack(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/31 16:44:12
-- @desc 取消闭关
function RoleTaskControllor:cancelBiGuanLayer(role, func1, func2)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	local dialog = DialogALayer:getInstance()
	dialog:show("正在闭关领悟内功，是否取消闭关", "取消动作将无法继续获得收益")
	dialog:setButton1("出关", function()
		role:stopBiGuan()
		func1()
	end)
	dialog:setButton2("返回", function()
		func2()
	end)
	dialog:setBack(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/01 19:08:10
-- @desc 取消练功
function RoleTaskControllor:cancelLianGongLayer(role, func1, func2)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)

	local titleText = "正在练功，是否结束练功"
	local tipText = "取消动作将无法继续获得收益"
	local buttonName = "结束练功"
	local isFinish = role:getLianGongSystem():checkLianGongIsFinish()
	if isFinish then
		titleText = "已完成练功，是否进行结算"
		tipText = "已完成练功，点击完成结算收益"
		buttonName = "完成练功"
	end

	local dialog = DialogALayer:getInstance()
	dialog:show(titleText, tipText)
	dialog:setButton1(buttonName, function()
		role:getLianGongSystem():stopLianGongOnline(function(ok, msg)
			if ok then
				func1()

				if msg then
					PopText(msg)
				end
			else
				PopText(msg)
			end
		end)
	end)
	dialog:setButton2("返回", function()
		func2()
	end)
	dialog:setBack(false)
end

--@desc: 取消修炼
--@author:LvBin
--@time:2022-04-09 18:06:38
--@role:
	--@func1:
	--@func2: 
--@return
function RoleTaskControllor:cancelXiuLianLayer(role, func1, func2)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)

	local titleText = "正在修炼，是否结束修炼"
	local tipText = "取消动作将无法继续获得收益"
	local buttonName = "结束修炼"
	local isFinish = role:getXiuLianSystem():checkXiuLianIsFinish()
	if isFinish then
		titleText = "已完成修炼，是否进行结算"
		tipText = "已完成修炼，点击完成结算收益"
		buttonName = "完成修炼"
	end

	local dialog = DialogALayer:getInstance()
	dialog:show(titleText, tipText)
	dialog:setButton1(buttonName, function()
		role:getXiuLianSystem():stopXiuLianOnline(function(ok, msg)
			if ok then
				func1()

				if msg then
					PopText(msg)
				end
			else
				PopText(msg)
			end
		end)
	end)
	dialog:setButton2("返回", function()
		func2()
	end)
	dialog:setBack(false)
end

--@desc: 取消练功，能使用分身符
--@author:LvBin
--@time:2022-04-09 18:16:01
--@role:
	--@func1:
	--@func2:
	--@func3: 
--@return
function RoleTaskControllor:cancelLianGongWithFSLayer(role, func1, func2, func3)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	func3 = Helper:getDef(func3, EMPTY_FUNC)
	local isFinish = role:getLianGongSystem():checkLianGongIsFinish()

	if isFinish then
		self:cancelLianGongLayer(role)
	else
		local dialog = DialogALayer:getInstance()
		dialog:show("正在练功，是否结束练功", "取消动作将无法继续获得收益")
		dialog:setButton1("结束练功", function()
			role:getLianGongSystem():stopLianGongOnline(function(ok, msg)
				if ok then
					func1()

					if msg then
                        PopText(msg)
                    end
				else
					PopText(msg)
				end
			end)
		end)
		dialog:setButton2("分身符", function()
			local item = Item:getOneItemByKey("fenshenfu")
			if item then
				item:storeItemUse(function()
					func2()
				end)
			end
		end)
		dialog:setButton3("返回", function()
			func3()
		end)
		dialog:setBack(false)
	end
end

--@desc: 取消修炼，能使用分身符
--@author:LvBin
--@time:2022-04-09 18:18:19
--@role:
	--@func1:
	--@func2:
	--@func3: 
--@return
function RoleTaskControllor:cancelXiuLianWithFSLayer(role, func1, func2, func3)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	func3 = Helper:getDef(func3, EMPTY_FUNC)
	local isFinish = role:getXiuLianSystem():checkXiuLianIsFinish()

	if isFinish then
		self:cancelXiuLianLayer(role)
	else
		local dialog = DialogALayer:getInstance()
		dialog:show("正在修炼，是否结束修炼", "取消动作将无法继续获得收益")
		dialog:setButton1("结束修炼", function()
			role:getXiuLianSystem():stopXiuLianOnline(function(ok, msg)
				if ok then
					func1()

					if msg then
                        PopText(msg)
                    end
				else
					PopText(msg)
				end
			end)
		end)
		dialog:setButton2("分身符", function()
			local item = Item:getOneItemByKey("fenshenfu")
			if item then
				item:storeItemUse(function()
					func2()
				end)
			end
		end)
		dialog:setButton3("返回", function()
			func3()
		end)
		dialog:setBack(false)
	end
end

--@desc: 取消师门挂机
--@author:Liang SongQiang
--@time:2019-06-06 01:04:44
function RoleTaskControllor:cancelShiMenGuaJiLayer(role, func1, func2)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	local dialog = DialogALayer:getInstance()
	dialog:show("正在进行师门挂机，是否结束", "取消动作将无法继续获得收益")
	dialog:setButton1("结束挂机", function()
		role:stopTeacherGuaJiTask()
		func1()
	end)
	dialog:setButton2("返回", function()
		func2()
	end)
	dialog:setBack(false)
end

function RoleTaskControllor:cancelGuaJiLayer(role, func1, func2)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	local dialog = DialogALayer:getInstance()
	dialog:show("正在进行挂机，是否结束", "取消动作将无法继续获得收益")
	dialog:setButton1("结束挂机", function()
		role:stopGuaji()
		func1()
	end)
	dialog:setButton2("返回", function()
		func2()
	end)
	dialog:setBack(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/01 11:00:44
-- @desc 师门任务
function RoleTaskControllor:stateInShiMenLayer(func)
	func()
	-- func = Helper:getDef(func, EMPTY_FUNC)
	-- local dialog = DialogALayer:getInstance()
	-- dialog:show("正在进行师门任务")
	-- dialog:setButton1("分身符", function()
	-- 	local item = Item:getOneItemByKey("fenshenfu")
	-- 	if item then
	-- 		item:storeItemUse(function()
	-- 			func()
	-- 		end)
	-- 	end
	-- end)
	-- dialog:setButton2("返回")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/01 15:01:57
-- @desc 取消打坐
function RoleTaskControllor:cancelDaZuoLayer(role, func1, func2)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	local dialog = DialogALayer:getInstance()
	dialog:show("正在打坐，是否停止打坐", "取消动作将无法继续获得收益")
	dialog:setButton1("取消打坐", function()
		role:stopDaZuo()
		func1()
	end)
	dialog:setButton2("返回", function()
		func2()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/02 11:55:16
-- @desc 取消观战
function RoleTaskControllor:cancelGuanZhanLayer(role, func1, func2)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	local dialog = DialogALayer:getInstance()
	dialog:show("正在观战，是否停止观战", "取消动作将无法继续获得收益")
	dialog:setButton1("取消观战", function()
		role:stopGuanZhan()
		func1()
	end)
	dialog:setButton2("返回", function()
		func2()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/02 16:17:17
-- @desc 取消研读
function RoleTaskControllor:cancelYanDuLayer(role, func1, func2)
	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	local dialog = DialogALayer:getInstance()
	dialog:show("正在研读，是否取消研读", "取消动作将无法继续获得收益")
	dialog:setButton1("取消研读", function()
		role:stopRead()
		func1()
	end)
	dialog:setButton2("返回", function()
		func2()
	end)
	dialog:setBack(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/29 16:34:08
-- @desc 点击主线任务
function RoleTaskControllor:clickZhuXianTask(func, taskId)
	if taskId == nil then
		return
	end
	func = Helper:getDef(func, EMPTY_FUNC)
	local role = User:getRole()
	if role:isInCurrState(ROLE_CURR_STATE_SHIMEN) then
		return
	elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		if taskId ~= "task15" then
			self:cancelLianGongLayer(role)
		else
			func()
		end
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		if taskId ~= "task15" then
			self:cancelXiuLianLayer(role)
		else
			func()
		end
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		if taskId ~= "task15" then
			self:cancelTiaoXiLayer(role)
		else
			func()
		end
	elseif role:isInCurrState(ROLE_CURR_STATE_GUAJI) or role:isInCurrState(ROLE_CURR_STATE_DAZUO) or role:isInCurrState(ROLE_CURR_STATE_BIGUAN) 
		or role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) or role:isInCurrState(ROLE_CURR_STATE_READ) or role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		if taskId ~= "task15" then
			self:cancelTaskLayer(role, func,nil,{ROLE_CURR_STATE_GUAJI,ROLE_CURR_STATE_DAZUO, ROLE_CURR_STATE_BIGUAN, ROLE_CURR_STATE_GUANZHAN, ROLE_CURR_STATE_READ,ROLE_CURR_STATE_TEACHERGUAJI})
		else
			func()
		end
	elseif role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) then
		if role:getAttr("currTaskId")~= nil and role:getAttr("currTaskId") ~= taskId and taskId ~= "task15" then
			self:cancelZhuXianLayer(role, func)
		else
			func()
		end
	else
		func()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/29 16:31:03
-- @desc 点击挂机任务
function RoleTaskControllor:clickGuaJiLayer(func)
	func = Helper:getDef(func, EMPTY_FUNC)
	local role = User:getRole()

	if role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) then
		self:cancelZhuXianLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		self:cancelLianGongWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		-- self:cancelShiMenGuaJiLayer(role)
		self:cancelTaskWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self:cancelTiaoXiWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_BIGUAN) or role:isInCurrState(ROLE_CURR_STATE_DAZUO) or role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) or role:isInCurrState(ROLE_CURR_STATE_READ) then
		self:cancelTaskWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_SHIMEN) then
		self:stateInShiMenLayer(func)
	else
		func()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/31 14:41:50
-- @desc 点击练功任务
function RoleTaskControllor:clickLianGongLayer(skillId, startFunc, cancelFunc, stopBiGuan, stopLianGong, stopXiuLian)
	if skillId == nil then
		return
	end
	startFunc = Helper:getDef(startFunc, EMPTY_FUNC)
	cancelFunc = Helper:getDef(cancelFunc, EMPTY_FUNC)
	stopBiGuan = Helper:getDef(stopBiGuan, EMPTY_FUNC)
	stopLianGong = Helper:getDef(stopLianGong, EMPTY_FUNC)
	stopXiuLian = Helper:getDef(stopXiuLian, EMPTY_FUNC)
	local role = User:getRole()
	if role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) then
		self:cancelZhuXianLayer(role, cancelFunc,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
		self:cancelBiGuanLayer(role, stopBiGuan,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG) and role:getLianGongSystem():getSkillId() ~= skillId then
		self:cancelLianGongLayer(role, stopLianGong,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianLayer(role, stopXiuLian,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_READ) then
		self:cancelYanDuLayer(role,cancelFunc,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self:cancelTiaoXiWithFSLayer(role, cancelFunc, startFunc, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_GUAJI) or role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) 
		or role:isInCurrState(ROLE_CURR_STATE_DAZUO) or role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		self:cancelTaskWithFSLayer(role, cancelFunc, startFunc, cancelFunc)
	else
		startFunc()
	end

end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/02 16:45:04
-- @desc 点击闭关任务
function RoleTaskControllor:clickBiGuanLayer(skillId, startFunc, cancelFunc, stopBiGuan, stopLianGong,stopXiuLian)
	if skillId == nil then
		return
	end
	startFunc = Helper:getDef(startFunc, EMPTY_FUNC)
	cancelFunc = Helper:getDef(cancelFunc, EMPTY_FUNC)
	stopBiGuan = Helper:getDef(stopBiGuan, EMPTY_FUNC)
	stopLianGong = Helper:getDef(stopLianGong, EMPTY_FUNC)
	stopXiuLian = Helper:getDef(stopXiuLian, EMPTY_FUNC)
	local role = User:getRole()
	if role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) then
		self:cancelZhuXianLayer(role, cancelFunc,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		self:cancelLianGongLayer(role, stopLianGong,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianLayer(role, stopXiuLian,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_BIGUAN) and role:getFlag("当前武功") ~= skillId then
		self:cancelBiGuanLayer(role, stopBiGuan,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_READ) then
		self:cancelYanDuLayer(role,cancelFunc,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self:cancelTiaoXiWithFSLayer(role, cancelFunc, startFunc, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_GUAJI) or role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) or 
		role:isInCurrState(ROLE_CURR_STATE_DAZUO) or role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		self:cancelTaskWithFSLayer(role, cancelFunc, startFunc, cancelFunc)
	else
		startFunc()
	end

end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/31 18:01:35
-- @desc 进入副本
function RoleTaskControllor:clickMapLayer(role, enterFunc, cancelFunc)
	local result = false
	role = Helper:getDef(role, User:getRole())

	if role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		self:cancelLianGongLayer(role,enterFunc, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianLayer(role,enterFunc, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self:cancelTiaoXiLayer(role,enterFunc, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_DAZUO) or role:isInCurrState(ROLE_CURR_STATE_BIGUAN) or role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) or role:isInCurrState(ROLE_CURR_STATE_READ)  then
		self:cancelTaskLayer(role, enterFunc, cancelFunc, {ROLE_CURR_STATE_DAZUO, ROLE_CURR_STATE_BIGUAN, ROLE_CURR_STATE_GUANZHAN, ROLE_CURR_STATE_READ})
	else
		result = true
	end
	return result
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/31 18:17:13
-- @desc 点击打坐任务
function RoleTaskControllor:clickDaZuoLayer(func)
	func = Helper:getDef(func, EMPTY_FUNC)
	local role = User:getRole()
	
	if role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) then
		self:cancelZhuXianLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self:cancelTiaoXiLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) then
		self:cancelGuanZhanLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		self:cancelLianGongWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_BIGUAN) or role:isInCurrState(ROLE_CURR_STATE_READ) 
		or role:isInCurrState(ROLE_CURR_STATE_GUAJI) or role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		self:cancelTaskWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_SHIMEN) then
		self:stateInShiMenLayer(func)
	else
		func()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/01 14:59:24
-- @desc 点击观战任务
function RoleTaskControllor:clickGuanZhanLayer(func)
	func = Helper:getDef(func, EMPTY_FUNC)
	local role = User:getRole()
	if role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) then
		func()
	elseif role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) then
		self:cancelZhuXianLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
		self:cancelDaZuoLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		self:cancelLianGongWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self:cancelTiaoXiWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_GUAJI) or role:isInCurrState(ROLE_CURR_STATE_BIGUAN) 
		or role:isInCurrState(ROLE_CURR_STATE_READ) or role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		self:cancelTaskWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_SHIMEN) then
		self:stateInShiMenLayer(func)
	else
		func()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/01 15:18:34
-- @desc 点击研读任务
function RoleTaskControllor:clickYanDuLayer(startFunc, cancelFunc)
	startFunc = Helper:getDef(startFunc, EMPTY_FUNC)
	cancelFunc = Helper:getDef(cancelFunc, EMPTY_FUNC)
	local role = User:getRole()
	if role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) then
		self:cancelZhuXianLayer(role, nil, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
		self:cancelBiGuanLayer(role, cancelFunc, cancelFunc) -- add by XiaoZhiWei 2017/08/01 19:07:27 都是刷新界面
	elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		self:cancelLianGongLayer(role, cancelFunc, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianLayer(role, cancelFunc, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self:cancelTiaoXiWithFSLayer(role, cancelFunc, startFunc, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_GUAJI) or role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) or role:isInCurrState(ROLE_CURR_STATE_DAZUO) 
		or role:isInCurrState(ROLE_CURR_STATE_READ) or role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		self:cancelTaskWithFSLayer(role, cancelFunc, startFunc, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_SHIMEN) then
		self:stateInShiMenLayer(startFunc)
	else
		startFunc()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/02 10:18:28
-- @desc 点击调息任务
function RoleTaskControllor:clickTiaoXiLayer(func)
	func = Helper:getDef(func, EMPTY_FUNC)
	local role = User:getRole()

	if role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) then
		self:cancelZhuXianLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
		self:cancelDaZuoLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		self:cancelLianGongWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_GUAJI) or role:isInCurrState(ROLE_CURR_STATE_BIGUAN)
		or role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) or role:isInCurrState(ROLE_CURR_STATE_READ) or role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		self:cancelTaskWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_SHIMEN) then
		self:stateInShiMenLayer(func)
	else
		func()
	end
end

-- @desc 点击论剑
function RoleTaskControllor:clickLunJianLayer(role, enterFunc, cancelFunc)
	local result = false
	role = Helper:getDef(role, User:getRole()) 

	if role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		self:cancelLianGongLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self:cancelTiaoXiLayer(role)
	--与观战不冲突 or role:isInCurrState(ROLE_CURR_STATE_GUANZHAN)
	elseif role:isInCurrState(ROLE_CURR_STATE_DAZUO) or role:isInCurrState(ROLE_CURR_STATE_BIGUAN)  or role:isInCurrState(ROLE_CURR_STATE_READ)  then
		self:cancelTaskLayer(role, enterFunc, cancelFunc, {ROLE_CURR_STATE_DAZUO, ROLE_CURR_STATE_BIGUAN, ROLE_CURR_STATE_READ})
	else
		result = true
	end
	return result
end

-----------------------------------------------------------------------------------------------------------
-- @desc 师门挂机任务
function RoleTaskControllor:clickTeacherGuaJiTaskLayer(func)
	func = Helper:getDef(func, EMPTY_FUNC)
	local role = User:getRole()
	local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")
	if role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		PopText("不能同时进行多个师门挂机任务")
	elseif TeacherGuaJiTaskUtil:cheakTaskStateIsSubmit() == true then
		PopText("有师门任务奖励未领取！")
	elseif role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) then
		self:cancelZhuXianLayer(role)
	elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		self:cancelLianGongWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_GUAJI) then
		-- self:cancelGuaJiLayer(role)
		self:cancelTaskWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self:cancelTiaoXiWithFSLayer(role, nil, func)
	elseif role:isInCurrState(ROLE_CURR_STATE_BIGUAN) or role:isInCurrState(ROLE_CURR_STATE_DAZUO) or role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) or role:isInCurrState(ROLE_CURR_STATE_READ) then
		self:cancelTaskWithFSLayer(role, nil, func)
	-- elseif role:isInCurrState(ROLE_CURR_STATE_SHIMEN) then
	-- 	self:stateInShiMenLayer(func)
	else
		func()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @desc 点击修炼
function RoleTaskControllor:clickXiuLianLayer(skillId, startFunc, cancelFunc, stopBiGuan, stopLianGong)
	if skillId == nil then
		return
	end
	startFunc = Helper:getDef(startFunc, EMPTY_FUNC)
	cancelFunc = Helper:getDef(cancelFunc, EMPTY_FUNC)
	stopBiGuan = Helper:getDef(stopBiGuan, EMPTY_FUNC)
	stopLianGong = Helper:getDef(stopLianGong, EMPTY_FUNC)
	local role = User:getRole()
	if role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) then
		self:cancelZhuXianLayer(role, cancelFunc,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
		self:cancelBiGuanLayer(role, stopBiGuan,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG)  then
		self:cancelLianGongLayer(role, stopLianGong,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		self:cancelXiuLianLayer(role, nil,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_READ) then
		self:cancelYanDuLayer(role,cancelFunc,cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self:cancelTiaoXiWithFSLayer(role, cancelFunc, startFunc, cancelFunc)
	elseif role:isInCurrState(ROLE_CURR_STATE_GUAJI) or role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) 
		or role:isInCurrState(ROLE_CURR_STATE_DAZUO) or role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		self:cancelTaskWithFSLayer(role, cancelFunc, startFunc, cancelFunc)
	else
		startFunc()
	end

end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/29 02:50:20
-- @desc 任务刷新方法
function RoleTaskControllor:update()
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()

	--@desc 挂机已改吧，该代码无需再次运行
	--[[
		-- add by XiaoZhiWei 2017/04/05 20:24:29 挂机收益前移,情况: 在离线状态下,挂机和练功如果同时进行时,需先计算经验和潜能的收益,再计算练功.否则离线提升的经验和潜能不会参与到练功离线收益计算内
		-- 挂机
		if role:isInCurrState(ROLE_CURR_STATE_GUAJI) then
			-- role:guaJi()
			-- local Task = require("app.models.task.Task")
			Task:update(ft)
		end
	]]
	if role:getHangUpSystem():isHangUping() then
		role:setGamingTime()
	end

	-- 观战
	--print("role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) = "..tostring(role:isInCurrState(ROLE_CURR_STATE_GUANZHAN)))
	if role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) then
		role:updateGuanZhan()
	end

	-- 打坐
	if role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
		role:daZuo()
	end

	-- 练功
	if role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		-- role:lianGong()
		-- role:getLianGongSystem():updata()
		role:setGamingTime()
	end

	-- 闭关
	if role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
		role:biGuan()
	end

	-- 调息
	if role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		role:pranayama()
	end

	-- 研读
	if role:isInCurrState(ROLE_CURR_STATE_READ) then
		role:read()
	end

	-- 师门挂机
	if role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
		role:updateTeacherGuaJiTask()
	end

	-- 修炼
	if role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		-- role:getXiuLianSystem():updata()
		role:setGamingTime()
		-- role:xiuLian()
	end

	-- 师门建筑日常挂机
	role:getTeacherBuildSystem():refreshGamingTime()

	-- 拳脚系统日常挂机
	role:getFistFootSystem():refreshGamingTime()

	role:deleteItemByTypeFromItemsAndCkItems("神书")

	--@RefType [app.models.HomelandModel.MapMeetModel.OuYuModel#OuYuModel]
	local OuYuModel = require("app.models.HomelandModel.MapMeetModel.OuYuModel")
	OuYuModel:checkTaskNeedClear()

	-- 空闲状态或者主动任务状态
	if role:isInCurrState(ROLE_CURR_STATE_IDLE) == true or role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) == true then
		-- 这两个状态下,并且间隔时间大于1分钟,则代表是离线状态
		if GetTime() - role:getFlag("游戏时间") > 60 then
			role:setGamingTime(role:getFlag("游戏时间") + 1)
		else
			role:setGamingTime()
		end
	end
end

return RoleTaskControllor00000000000
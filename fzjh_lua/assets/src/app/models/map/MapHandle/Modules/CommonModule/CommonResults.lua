--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local CommonResults = class("CommonResults", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 条件结果的方法
CommonResults.doResult = {
	["玩家丢弃榜文"] = function(map, result, environment)
		local itemid = ""
		local player = User:getRole()
		for i = 1, 50 do
			itemid = "xuan" .. i
			local itemAttr = player:getItem(itemid)
			print("itemAttr =" .. type(itemAttr))
			if itemAttr ~= nil then
				player:addItemCount(itemid, - 1)
				PopText("损失榜文")
			end
		end
	end,
	
	-- 改变房间状态
	["房间属性设置"] = function(map, result, environment)
		local roomId = result.arg2
		local value = result.arg3
		local room = map:getRoomById(roomId)
		
		if PRINT_MODE == 1 then
			print("roomId = " .. roomId)
			print("value = " .. value)
		end
		
		if room then
			if value == "可见" then
				room.visible = true
			elseif value == "不可见" then
				room.visible = false
			elseif value == "可进" then
				room.enterable = true
			elseif value == "不可进" then
				room.enterable = false
			end
		end
		
		if PRINT_MODE == 1 then
			print("after")
		end
	end,
	
	["阻止玩家移动"] = function(map, result, environment)
		return "阻止玩家移动"
	end,
	

	["交谈奖励"] = function(map, result, environment)
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		print(result.arg3, result.arg2)
		TeacherTask:dealHaiJingTalkResult(result.arg3, result.arg2, map, environment.currRole, map:getCurrRoomId())
	end,
	
	["地图角色属性倍率设置"] = function(map, result, environment)
		local roleId = result.arg2
		local settingRole = map:getRole(roleId)
		
		if settingRole:getAttr("onlyId") == User:getRoleAttr("onlyId") then
			assert(false, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 傻逼错误，这个结果不能对玩家使用")
			return
		end
		
		--result.arg2 设置的倍率
		local alterAttrList = {"str", "con", "int", "dex", "neiliMax", "neili", "qiMax", "qi"}
		
		if settingRole.buffFactor == nil then
			
			settingRole.buffFactor = 1
			
			settingRole.originAttr = {}
			settingRole.originAttr['exp'] = settingRole:getAttr('exp')
			for i, v in ipairs(alterAttrList) do
				settingRole.originAttr[v] = settingRole:getFinalAttr(v)
			end
			
			--装备的武功
			settingRole.originSkill = {}
			for k, v in pairs(settingRole.skillPrepare) do
				settingRole.originSkill[k] = settingRole.skills[v].exp
			end
		end
		
		assert(false, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 地图角色全属性倍率设置 没有设置参数")
		settingRole.buffFactor = tonumber(result.arg3)
		
		--所有属性翻k倍
		local factor = settingRole.buffFactor
		
		for i, v in ipairs(alterAttrList) do
			settingRole:setAttr(v, settingRole.originAttr[v] * factor)
		end
		--装备的武功
		for k, v in pairs(settingRole.skillPrepare) do
			settingRole.skills[v].exp = settingRole.originSkill[k] * factor
		end
	end,
	
	
	["地图角色属性倍率变化"] = function(map, result, environment)
		local roleId = result.arg2
		local settingRole = map:getRole( roleId )

		--result.arg3 要加减的倍率
		if settingRole:getAttr("onlyId") == User:getRoleAttr("onlyId") then
			assert( false , "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 傻逼错误，这个结果不能对玩家使用" )
			return
		end

		local alterAttrList = { "str" , "con" , "int" , "dex", "neiliMax" , "neili" , "qiMax" , "qi" }
		if settingRole.buffFactor == nil then
			settingRole.buffFactor = 1.0

			settingRole.originAttr = {}
			settingRole.originAttr['exp'] = settingRole:getAttr( 'exp' )
			for i,v in ipairs(alterAttrList) do
				settingRole.originAttr[v] = settingRole:getFinalAttr( v )
			end

			--装备的武功
			settingRole.originSkill = {}
			for k,v in pairs( settingRole.skillPrepare ) do

				settingRole.originSkill[k]= settingRole.skills[v].exp
			end
		end

		assert( true , "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 地图角色全属性倍率设置 没有设置参数" )
		local deltak = result.arg3
		settingRole.buffFactor = settingRole.buffFactor - tonumber( deltak )

		--所有属性翻k倍
		local factor = settingRole.buffFactor
		if factor <= 0 then
			factor = 0.1
		end
		print( "地图角色属性倍率变化 当前factor=" .. factor  )

		settingRole:setAttr( 'exp' , settingRole.originAttr['exp'] )
		for i,v in ipairs(alterAttrList) do
			print( "地图角色属性倍率变化 " .. v .. " = " .. (settingRole.originAttr[v] * factor) )

			settingRole[v] = settingRole.originAttr[v] * factor
		end
		--装备的武功
		for k,v in pairs( settingRole.skillPrepare ) do
			print( "地图角色武功属性倍率变化 " .. k .. ":"..v.." = " .. (settingRole.originSkill[k] * factor) )

			settingRole.skills[v].exp = settingRole.originSkill[k] * factor
		end
	end,
	
	["地图角色满状态"] = function(map, result, environment)
		local roleId = result.arg2
		local settingRole = map:getRole(roleId)
		
		print("################################################# 地图角色满状态")
		
		settingRole:setFlag("是否死亡", nil) -- 满状态的时候 标记去除 add by XiaoZhiWei 2016-12-22
		
		settingRole:setAttr("qiPercent", 1)
		settingRole:setAttr("qi", settingRole:getCurrQiMax())
		settingRole:setAttr("neili", settingRole:getFinalAttr("neiliMax"))
	end,
	
	["随机结果"] = function(map, result, environment)
		--arg2 = 结果;结果;结果;结果
		--arg3 = 权重1;权重2;权重3;权重4
		local result_strs = result.arg2
		local weight_strs = result.arg3
		
		print("随机结果 " .. tostring(result_strs) .. "  " .. tostring(weight_strs))
		
		if result_strs == nil or result_strs == "" then
			return
		end
		
		--解开results
		result_strs = string.split(result_strs, ";")
		
		--判断weight是否为空，为空则默认为1
		local weights = {}
		if weight_strs == nil or weight_strs == "" then
			for i, result_str in ipairs(result_strs) do
				table.insert(weights, 1)
			end
		else
			weight_strs = string.split(weight_strs, ";")
			for i, weight_str in ipairs(weight_strs) do
				if weight_str ~= nil and weight_str ~= "" then
					table.insert(weights, tonumber(weight_str))
				end
			end
		end
		
		--计算总重
		local totalweight = 0
		for i, v in ipairs(weights) do
			weights[i] = math.ceil(weights[i] * 1000) --通通乘以1000,避免表里设计了小数点
			totalweight = totalweight + weights[i]
		end
		
		local rand_num = math.random(0, totalweight)
		print("随机结果 " .. rand_num .. "/" .. totalweight)
		local currweight = 0
		for i = 1, #weights, 1 do
			if rand_num >= currweight and rand_num < currweight + weights[i] then
				print(" -------- currweight=" .. currweight .. "  weights[i]=" .. weights[i])
				--命中
				local result_str = string.gsub(result_strs[i], ",", ";") -- add by XiaoZhiWei 2017/08/30 17:08:01 添加支持结果集填写,用逗号隔开
				
				print("随机结果：" .. result_str)
				return map:doNoRoleResults(result_str, environment)
			end
			currweight = currweight + weights[i]
		end
		
		
		print("ERROR: 随机结果居然没有随机到")
	end,
	
	["结果集"] = function(map, result, environment)
		--按顺序结果arg2中的结果
		--arg2 = 结果;结果;结果;结果
		local result_strs = result.arg2
		
		if result_strs == nil or result_strs == "" then
			return
		end
		
		return map:doNoRoleResults(result_strs, environment)
	end,
	
	["躲避暗器"] = function(map, result, environment)
		--arg2 = 人物名称
		--arg3 = 暗器名称
		--arg4 = 持续时间
		--arg5 = 伤害百分比
		--arg6 = 成功结果
		--arg7 = 失败结果
		local qi = User:getRoleAttr("qi")
		if qi <= 0 then
			if MainControllLayer:getCurrLayer() == "MapLayer" then
				MainControllLayer:getLayer("MapLayer"):quit()
			end
			return
		end
		
		local attackerName = tostring(result.arg2)
		local anqiName = tostring(result.arg3)
		local interval = tonumber(result.arg4)
		local damagePercent = tonumber(result.arg5)
		local succResult = result.arg6
		local failedResult = result.arg7
		
		print("############ 躲避暗器 roleid=" .. environment.currRole.id .. " arg1=" .. result.id .. " " .. attackerName .. " interval=" .. tostring(interval))
		if succResult then
			print(" succResult=" .. succResult)
		end
		
		if failedResult then
			print(" failedResult=" .. failedResult)
		end
		
		local DialogDodgeLayer = require("app.views.layer.MapLayer.DialogDodgeLayer")
		
		local dodgeLayer = DialogDodgeLayer:createInRunningScene()
		if dodgeLayer:isAvail() == false then
			print("dodgeLayer is now busy")
			return
		end
		
		dodgeLayer:reinit()
		dodgeLayer:setAttackerName(attackerName)
		dodgeLayer:setAnqiName(anqiName)
		dodgeLayer:setRole(User:getRole())
		dodgeLayer:setTime(interval)
		dodgeLayer:setDamagePercent(damagePercent)
		dodgeLayer:setSuccResult(succResult)
		dodgeLayer:setFailedResult(failedResult)
		dodgeLayer:setResultCallback(
		function(isSucc)
			--结果
			print("dodgeLayer callback isSuc= " .. tostring(isSucc))
			if isSucc == true then
				if succResult ~= nil and succResult ~= "" then
					--print( "doNoRoleResults callback succResult= " .. type(succResult) .. " " .. succResult )
					map:doNoRoleResults(succResult, environment)
				end
			else
				-- false
				if succResult ~= nil and succResult ~= "" then
					--print( "doNoRoleResults callback failedResult= " .. type(failedResult) .. " " .. failedResult )
					map:doNoRoleResults(failedResult, environment)
				end
				
				local qi = User:getRoleAttr("qi")
				if isSucc == false and qi <= 0 then
					User:addRoleAttr("dead", 1)
					User:setRoleAttr("deadReason", anqiName)
					
					PopText("你被" .. attackerName .. "的" .. anqiName .. '打败了')
					
					if MainControllLayer:getCurrLayer() == "MapLayer" then
						MainControllLayer:getLayer("MapLayer"):quit()
					end
					return
				end
			end
			
		end)
		
		dodgeLayer:show()
	end,
	
	
	["躲避流光"] = function(map, result, environment)
		local interval = tonumber(result.arg2)
		local damagePercent = tonumber(result.arg3)
		local succResult = result.arg4
		local failedResult = result.arg5
		
		PopupLayerController:showLayer("NewDialogDodgeLayer", function(layer)
			if layer:isAvail() == false then
				print("dodgeLayer is now busy")
				return
			end
			
			layer:reinit()
			-- 设置文本
			layer:setDodgeTexts(
			{
				["up"] = {"你身形陡然纵起，凌空一跃，伸手试图接下$w。", "你身体向上笔直纵身，跃起数丈，尝试接下$w。"},
				["down"] = {"你飘然向下一闪，身体贴向$w，试图将其拦下。"},
				["left"] = {"你身体晃动，向左移动数步，尝试接下$w。。", "你身随意转，向左一闪，举手伸向$w。"},
				["right"] = {"你向右，侧身一摆。", "你足不点地，向右窜开。"},
				["still"] = {"你停留在原地，什么也没做！", "你尚未回过神来！"}
			})
			
			layer:setSuccTexts(
			{
				"你飞快转身，十分轻松地躲过了流光！",
				"你身形飘忽，犹如鬼魅一般，十分利索地躲过了流光！",
				"你长袖一拂，身子悄然而动，流光擦着你的身体而过，你并无受到多大伤害！",
				"你反应极快，身随意动，电光火石之间躲过了流光的攻击！",
				"只见你单足轻点地面，身体向前挺出数丈，流光已然落空！",
			})
			
			layer:setHurtTexts(
			{
				"你虽然反应极快，但流光还是擦伤了你，你受到了$z点伤害！",
				"流光来势甚猛，你躲闪不及，受到了$z点伤害！",
				"你一个躲避不及，还是被流光所击中，受到了$z点伤害！",
				"你身法虽快，却未曾快过这流光，你受到了$z点伤害！",
			})
			
			layer:setFireTexts(
			{
				"$N向你的$d发射了一道$w，快闪开！",
				"$N向你的头部发射了一道$w，快下蹲！流光飞至一半，却不知为何转向向你的$d打来！",
			})
			
			layer:setToFireTexts({"下身", "头部", "右侧", "左侧"})
			layer:setToDodgeTexts({"上跳", "下蹲", "左闪", "右闪"})
			layer:setBtnName({"跳起", "下蹲", "左闪", "右闪"})
			
			layer:setAttackerName("星光")
			layer:setAnqiName("流光")
			layer:setTime(interval)
			layer:setDamagePercent(damagePercent)
			layer:setResultCallback(function(isSucc)
				if isSucc == true then
					if succResult then
						map:doNoRoleResults(succResult, environment)
					end
				else
					if failedResult then
						map:doNoRoleResults(failedResult, environment)
					end
				end
			end)
			
			layer:show()
		end)
	end,
	

	
	["追踪计时停止"] = function(map, result, environment)
		print("追踪计时停止###############停止计时")
		if map.comingAfterBoss == nil or map.comingAfterBoss.status == "over" then
			return
		end
		
		if map.comingAfterBoss.delayFuncHandle ~= nil then
			environment.mapLayer:stopActionByTag(map.comingAfterBoss.delayFuncHandle)
			map.comingAfterBoss.delayFuncHandle = nil
		end
		
		map.comingAfterBoss = nil
		print("################################## comingAfterBoss 停止计时")
	end,
	
	
	["追踪计时开启"] = function(map, result, environment)
		--arg2 单步时间
		--arg3 起始距离
		--arg4 失败距离
		local stepTime = tonumber(result.arg2)
		local startSteps = result.arg3
		local failedSteps = result.arg4
		local succResult = result.arg5
		local failedResult = result.arg6
		local bossName = result.arg7
		
		print("################################## 计时 stepTime=" .. tostring(stepTime))
		
		local function comingAfterBossStepfunc()
			if map.comingAfterBoss ~= nil and map.comingAfterBoss.status ~= "over" then
				print("comingAfterBossStepfunc 计时 bossName=" .. tostring(map.comingAfterBoss.bossName))
				local ret = map:comingAfterBoss_changeDistacne(1, map.comingAfterBoss.bossName)
				
				if ret == true then
					map.comingAfterBoss.delayFuncHandle = environment.mapLayer:delayFunc(stepTime, comingAfterBossStepfunc, environment)
				else
					if map.comingAfterBoss.delayFuncHandle ~= nil then
						environment.mapLayer:stopActionByTag(map.comingAfterBoss.delayFuncHandle)
						map.comingAfterBoss.delayFuncHandle = nil
					end
				end
			end
		end
		if map.comingAfterBoss == nil or map.comingAfterBoss.status == "over" then
			map.comingAfterBoss = {}
			
			map.comingAfterBoss.stepTime = stepTime
			map.comingAfterBoss.startSteps = startSteps
			map.comingAfterBoss.failedSteps = failedSteps
			map.comingAfterBoss.succResult = succResult
			map.comingAfterBoss.failedResult = failedResult
			
			map.comingAfterBoss.currSteps = startSteps
			
			map.comingAfterBoss.status = "start"
			map.comingAfterBoss.bossName = bossName
			print("################################## 计时开启成功=" .. tostring(stepTime))
			map.comingAfterBoss.delayFuncHandle = environment.mapLayer:delayFunc(stepTime, comingAfterBossStepfunc)
		end
	end,
	
	["开启计时器"] = function(map, result, environment)
		--arg2 时间
		--arg3 计时器名字
		local timerTime = tonumber(result.arg2)
		local timerName = result.arg3
		local resultStrs = result.arg4
		local timerFlag = false 		--计时器是否完成
		
		if map.timerMap == nil then
			map.timerMap = {}
		end
		
		local timer = {}
		if map.timerMap[timerName] == nil then
			map.timerMap[timerName] = timer
			print("创建计时器: " .. tostring(timerName))
		else
			timer = map.timerMap[timerName]
			print("计时器已存在" .. timerName .. "重置时间")
			if timer.delayFuncHandle ~= nil then
				environment.mapLayer:stopActionByTag(map.timerMap[timerName].delayFuncHandle)
				map.timerMap[timerName].delayFuncHandle = nil
			end
			map.timerMap[timerName].flag = false
		end
		
		timer.time = timerTime
		timer.name = timerName
		timer.flag = timerFlag
		timer.sTime = GetTime()
		timer.resultStrs = resultStrs
		timer.backTime = Helper:getDef(BACKGROUND_TIME, 0) 
		
		
		print("开启计时器:" .. tostring(timerName) .. ":" .. tostring(timerTime))
		
		local function TimerOver()
			timer.flag = true
			
			environment.mapLayer:stopActionByTag(map.timerMap[timerName].delayFuncHandle)
			map.timerMap[timerName].delayFuncHandle = nil
			print("计时器已完成" .. tostring(timerName))
			
			if timer.resultStrs ~= nil then
				map:doNoRoleResults(timer.resultStrs, environment)
			end
		end
		
		map.timerMap[timerName].delayFuncHandle = environment.mapLayer:delayFunc(timerTime, TimerOver)
		
	end,
	
	["离BOSS距离"] = function(map, result, environment)
		--arg2 距离变化
		--arg3 BOSS人名
		local delta = result.arg2
		local bossName = result.arg3
		
		if map.comingAfterBoss == nil or map.comingAfterBoss.status == "over" then
			print("离BOSS距离false delta=" .. delta)
			return false
		end
		
		if map.comingAfterBoss.status == "failed" then
			local failedResult = map.comingAfterBoss.failedResult
			
			print("你已经失败了 failed")
			if map.comingAfterBoss.delayFuncHandle ~= nil then
				environment.mapLayer:stopActionByTag(map.comingAfterBoss.delayFuncHandle)
				map.comingAfterBoss.delayFuncHandle = nil
			end
			map.comingAfterBoss = nil
			
			map:doNoRoleResults(failedResult, environment)
			
			return
		end
		
		map:comingAfterBoss_changeDistacne(delta, bossName, environment)
	end,
	
	["开启特殊计时器"] = function(map, result, environment)
		--arg2 时间
		--arg3 计时器名字
		--arg5 移动，离开，点击其他人物的提示信息
		local ControllLayer = require("app.views.layer.ControllLayer")
		local controllLayer = ControllLayer:getInstance()
		local MapRoleLayer = controllLayer:getLayer("MapRoleLayer")
		MapRoleLayer:statusButtonFunc(false,function ()
			map:doNoRoleResults(result.arg5, environment)
        end)
		MapRoleLayer:exitButtonFunc(false, function()
			map:doNoRoleResults(result.arg5, environment)
		end)
		map.__MapLayer:setUnmoveRoom(true, function()
			map:doNoRoleResults(result.arg5, environment)
		end)
		map.__MapLayer:setNPCTouchEnabled(true, function()
			map:doNoRoleResults(result.arg5, environment)
		end)
		local timerTime = tonumber(result.arg2)
		local timerName = result.arg3
		local resultStrs = result.arg4
		local timerFlag = false 		--计时器是否完成
		
		if map.timerMap == nil then
			map.timerMap = {}
		end
		
		local timer = {}
		if map.timerMap[timerName] == nil then
			map.timerMap[timerName] = timer
			print("创建计时器: " .. tostring(timerName))
		else
			timer = map.timerMap[timerName]
			print("计时器已存在" .. timerName .. "重置时间")
			if timer.delayFuncHandle ~= nil then
				environment.mapLayer:stopActionByTag(map.timerMap[timerName].delayFuncHandle)
				map.timerMap[timerName].delayFuncHandle = nil
			end
			map.timerMap[timerName].flag = false
		end
		
		timer.time = timerTime
		timer.name = timerName
		timer.flag = timerFlag
		timer.sTime = GetTime()
		timer.resultStrs = resultStrs
		timer.backTime = Helper:getDef(BACKGROUND_TIME, 0)
		
		
		print("开启计时器:" .. tostring(timerName) .. ":" .. tostring(timerTime))
		
		local function TimerOver()
			timer.flag = true
			MapRoleLayer:statusButtonFunc(true)
			MapRoleLayer:exitButtonFunc(true)
			map.__MapLayer:setUnmoveRoom(false)
			map.__MapLayer:setNPCTouchEnabled(false)
			environment.mapLayer:stopActionByTag(map.timerMap[timerName].delayFuncHandle)
			map.timerMap[timerName].delayFuncHandle = nil
			print("计时器已完成" .. tostring(timerName))
			
			if timer.resultStrs ~= nil then
				map:doNoRoleResults(timer.resultStrs, environment)
			end
		end
		
		map.timerMap[timerName].delayFuncHandle = environment.mapLayer:delayFunc(timerTime, TimerOver)
	end,
	
	["计时器文本输出"] = function(map, result, environment)
		--[[			
			result.arg2  输出内容
			result.arg3  计时器名称
		]]
		local timerName = result.arg3
		local logText = result.arg2
		if type(timerName) ~= "string" or type(logText) ~= "string" then
			if DEBUG_MODE == 1 then
				print("result.arg1 == 计时器文本输出,timerName:", timerName, type(timerName), "logText:", logText, type(logText))
			end
			return
		end
		if map.timerMap == nil then
			print("没有名称为" .. timerName .. "的计时器")
			return
		end
		local timer = map.timerMap[timerName]
		if timer == nil then
			if DEBUG_MODE == 1 then
				print("没有名称为" .. timerName .. "的计时器")
			end
			return
		end
		if timer.flag == true then
			if DEBUG_MODE == 1 then
				print("计时器" .. timerName .. "已经执行完毕")
			end
			return
		end
		print("计时器剩余时间")
		local time =  math.max(math.floor(timer.time + timer.sTime + Helper:getDef(BACKGROUND_TIME - timer.backTime, 0) - GetTime()), 0)
		logText = string.gsub(logText, "$T", tostring(time))
		RichPrint("main", logText)
	end,
	
	["停止计时器"] = function(map, result, environment)
		local timerName = result.arg2
		
		print("停止计时器:" .. tostring(timerName))
		if map.timerMap == nil or map.timerMap[timerName] == nil then
			print("停止计时器:" .. tostring(timerName) .. "失败")
			return
		end
		
		if map.timerMap[timerName].delayFuncHandle ~= nil then
			print("停止计时器:" .. tostring(timerName) .. "成功")
			environment.mapLayer:stopActionByTag(map.timerMap[timerName].delayFuncHandle)
			map.timerMap[timerName].delayFuncHandle = nil
			map.timerMap[timerName].flag = true
		end
	end,
	
	["停止特殊计时器"] = function(map, result, environment)
		local timerName = result.arg2
		
		print("停止计时器:" .. tostring(timerName))
		if map.timerMap == nil or map.timerMap[timerName] == nil then
			print("停止计时器:" .. tostring(timerName) .. "失败")
			return
		end
		
		if map.timerMap[timerName].delayFuncHandle ~= nil then
			print("停止计时器:" .. tostring(timerName) .. "成功")
			local ControllLayer = require("app.views.layer.ControllLayer")
			local controllLayer = ControllLayer:getInstance()
			local MapRoleLayer = controllLayer:getLayer("MapRoleLayer")
			MapRoleLayer:statusButtonFunc(true)
			MapRoleLayer:exitButtonFunc(true)
			map.__MapLayer:setUnmoveRoom(false)
			map.__MapLayer:setNPCTouchEnabled(false)
			environment.mapLayer:stopActionByTag(map.timerMap[timerName].delayFuncHandle)
			map.timerMap[timerName].delayFuncHandle = nil
			map.timerMap[timerName].flag = true
		end
	end,
	
	["文本动画"] = function(map, result, environment)
		local text = string.split(result.arg2, "|")
		local resultsStrs = result.arg3
		local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
		local teacherAnimationLayer = TeacherAnimationLayer:getInstance()
		local sexStr="他"
		if User:getRoleAttr("inherit").sex=="女" then 
			sexStr="她"
		end
		for i, v in ipairs(text) do
			text[i] = string.gsub(text[i], "$IN", User:getRoleAttr("inherit").name)
			text[i] = string.gsub(text[i], "$S", sexStr)
		end
		
		teacherAnimationLayer:setVisible(false)
		teacherAnimationLayer:createTextFromArray(text)
		teacherAnimationLayer:show(function()
			if resultsStrs ~= nil then
				map:doNoRoleResults(resultsStrs, environment)
			end
		end)
	end,
	
	["完成传承剧情"] = function(map, result, environment)
		environment.mapLayer:delayFunc(1, function()
			User:getRoleAttr("inherit").isFinish = true
			map.__MapLayer:quit()
			PopupLayerController:showLayer("InheritConfirmLayer", function(layer)
				layer:show()
				layer:showDesc()	
			end)
		end)
	end,
	
	["弹出选项框"] = function(map, result, environment)
		local title = result.arg2   				--标题
		local btn1Text = result.arg3				--按钮1文字
		local btn2Text = result.arg4				--按钮2文字
		local resultsStrs1 = result.arg5
		local resultsStrs2 = result.arg6

		title = string.gsub(title, "#mz", environment.currRole.name)
		--@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
		local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
		title = HomelandDesc:subChengHuText(title)
		
		local StringUtil = require("app.extends.StringUtil")
		title = StringUtil:replaceNpcName(title,map)

		print(btn1Text .. btn2Text .. resultsStrs1 .. resultsStrs2)
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show(title)
		dialog:setWeChatVisible(false)
		dialog:setRichText(title)
		dialog:setButton1(btn1Text, function()
			map:doNoRoleResults(resultsStrs1, environment)
		end)
		
		dialog:setButton2(btn2Text, function()
			dialog:hide()
			map:doNoRoleResults(resultsStrs2, environment)
		end)
	end,
	
	["弹出对话框"] = function(map, result, environment)
		local problem = result.arg2						-- 问题
		local desc = result.arg3						-- 对话描述
		local answer = string.split(result.arg4, "|")	-- 回答
		local resultsStrs1 = result.arg5
		local resultsStrs2 = result.arg6
		local resultsStrs3 = result.arg7
		
		PopupLayerController:showLayer("InheritEventLayer", function(layer)
			layer:setTalk(problem, desc, answer)
			layer:show()
			
			if resultsStrs1 then
				layer:setButton1(function()
					map:doNoRoleResults(resultsStrs1, environment)
				end)
			end
			
			if resultsStrs2 then
				layer:setButton2(function()
					map:doNoRoleResults(resultsStrs2, environment)
				end)
			end
			
			if resultsStrs3 then
				layer:setButton3(function()
					map:doNoRoleResults(resultsStrs3, environment)
				end)
			end
		end)
	end,

	
	["获得潜能"] = function(map, result, environment)
		local role = User:getRole()
		local pot = role:getPotFromExp()
		
		PopText("潜能 + " .. tostring(pot))
		role:addAttr("pot", pot)
		map:richPrintText(role, "pot", pot)
	end,

	
	["使用奇遇道具"] = function(map, result, environment)
		--每天限10次奇遇
		local itemtype = result.arg2 -- 奇遇道具类型 1.醉梦生 2.清风醉 3.十里香
		local resultsStrs = result.arg3
		local role = User:getRole()
		print("使用奇遇道具" .. itemtype)
		
		--奇遇道具使用事件限制
		role:setFlag("奇遇道具使用时间", GetTime())
		
		-- 获得奖励
		local qiyujingCount = User:getRoleAttr("qiyujingCount")
		
		-- 随机奖励
		local probability = {}
		
		if itemtype == "醉梦生" then
			if qiyujingCount < 13 then
				probability = {15, 34, 31, 20}
			else
				probability = {0, 34, 46, 20}
			end
		elseif itemtype == "清风醉" then
			probability = {1600, 1333, 1142, 1000, 888, 800, 727, 666, 2500, 1666, 1250, 1000, 833, 714, 1000}
		elseif itemtype == "十里香" then
			probability = {1600, 1333, 1142, 1000, 888, 800, 727, 666, 2000, 1333, 1000, 800, 666, 571, 1000}
		end
		
		local max = 0
		for i, v in ipairs(probability) do
			max = max + v
		end
		
		local num = math.random(1, max)
		local count = 0
		local rewardType
		for i, v in ipairs(probability) do
			count = count + v
			if num <= count then
				rewardType = i
				break
			end
		end
		
		print("奇遇道具 " .. itemtype)
		print("随机数" .. tostring(num))
		print("奖励类型" .. tostring(rewardType))
		
		-- 显示文本
		-- 显示文本
		local text =
		{
			["醉梦生"] =
			{
				[1] =
				{
					{[1] = 0, [2] = "HIY你拔出醉梦生的塞子，不禁陶醉于酒香之中。"},
					{[1] = 1, [2] = "CYN一双大手拍了拍你的肩膀，你转头一看，竟是一位慈眉善目的老者。"},
					{[1] = 1, [2] = "BLU老者：这佳酿我远隔三里之外都闻得到。"},
					{[1] = 0.5, [2] = "BLU你将酒瓶递给老者。老者也不客气，将酒一饮而尽。"},
					{[1] = 0.5, [2] = "BLU老者：痛快，看见少侠如此豪爽，不给点什么反显得老夫太过小气。"},
					{[1] = 0.5, [2] = "BLU老者双手在你周身穴道点了数下。你感觉体内血液沸腾，慌忙闭眼运气，待到平复睁眼，老者已没了踪迹。"},
				},
				[2] =
				{
					{[1] = 0, [2] = "HIY你拔出醉梦生的塞子，酒香飘散开去。"},
					{[1] = 1, [2] = "CYN只见一消瘦男子慌张向你跑来，将一个青色包裹胡乱塞到你手里。"},
					{[1] = 1, [2] = "BLU你正想说点什么，却发现男子早已跑远。"},
					{[1] = 0.5, [2] = "BLU片刻后又有两个怒气冲冲的大汉跑近，环视四周。又朝着同一个方向追去。"},
					{[1] = 0.5, [2] = "BLU四下一片寂静，你打开包裹，竟是满满一包黄金。"},
				},
				[3] =
				{
					{[1] = 0, [2] = "HIY你拔出醉梦生的塞子，不禁陶醉于酒香之中。"},
					{[1] = 1, [2] = "CYN一双大手拍了拍你的肩膀，你转头一看，竟是一位慈眉善目的老者。"},
					{[1] = 1, [2] = "YEL老者：这佳酿我远隔三里之外都闻得到。"},
					{[1] = 0.5, [2] = "BLU你将酒瓶递给老者。老者也不客气，将酒一饮而尽。"},
					{[1] = 0.5, [2] = "YEL老者：痛快，看见少侠如此豪爽，不给点什么反显得老夫太过小气。这有几颗老夫收藏多年的丹药，你拿去吧。"},
					{[1] = 0.5, [2] = "BLU说罢，老者从怀中取出颗丹药交给你，便摇摇晃晃远去了。"},
				},
				[4] =
				{
					{[1] = 0, [2] = "HIY你拔出醉梦生的塞子，不禁陶醉于酒香之中。"},
					{[1] = 1, [2] = "CYN耳边似有丝竹之音，转头一看，竟是位妙龄女子。"},
					{[1] = 1, [2] = "BLU与女子浅谈几句，甚是投缘，于是倾倒美酒，同女子共饮。"},
					{[1] = 0.5, [2] = "BLU伴着清风，琴声，与佳人把酒言欢，实是人生幸事。"},
					{[1] = 0.5, [2] = "BLU与女子交谈良久，酒尽声停。"},
					{[1] = 0.5, [2] = "YEL女子：这颗丹药是我无意中获得的，还望少侠收下"},
					{[1] = 0.5, [2] = "RED你接过丹药，女子便欠身离去。"},
				},
			},
			["清风醉"] =
			{
				[1] =
				{
					{[1] = 0, [2] = "HIY你打开了清风醉的瓶盖，酒香四溢。"},
					{[1] = 1, [2] = "CYN强盗：要命的话就快将这几锭碎银收下。"},
					{[1] = 1, [2] = "YEL后背似有一利器顶触。"},
					{[1] = 0.5, [2] = "BLU你虽然很是费解，但也只能收下碎银。"},
					{[1] = 0.5, [2] = "YEL强盗：哈哈哈，既然你收下了洒家的银子，这笔买卖也算是敲定了，快把你怀中的酒掏出来。"},
					{[1] = 0.5, [2] = "BLU你以廉价的价钱将酒卖给了强盗。"},
				},
				[2] =
				{
					{[1] = 0, [2] = "HIY你打开了清风醉的瓶盖，酒香四溢。"},
					{[1] = 1, [2] = "CYN你突然看到一位教头装扮的人走了过来。"},
					{[1] = 1, [2] = "YEL王教头：这位朋友，你这酒莫非是清风醉，可否分某一杯？？"},
					{[1] = 0.5, [2] = "BLU你与他一见如故，举杯共饮。"},
					{[1] = 0.5, [2] = "YEL王教头：哈哈，今日能与少侠共饮，真乃幸事也，某家无以为报，便打套拳助助兴吧。"},
					{[1] = 0.5, [2] = "BLU王教头打了一套通臂拳，你观看之后略有所悟。"},
				},
				[3] =
				{
					{[1] = 0, [2] = "HIY你打开了清风醉的瓶盖，酒香四溢。"},
					{[1] = 1, [2] = "CYN忽然看到远方有一道士骑着一头青牛向你猛冲过来。"},
					{[1] = 1, [2] = "BLU来势凶猛，你狼狈躲避，竟将怀中的清风醉摔碎。"},
					{[1] = 0.5, [2] = "YEL道士：实在是不好意思，这有颗我炼制的丹药，算是赔偿了。。。"},
					{[1] = 0.5, [2] = "BLU话音未落，道士便已看不见身影。"},
				},
			},
			["十里香"] =
			{
				[1] =
				{
					{[1] = 0, [2] = "HIY你打开了十里香的瓶盖，酒香四溢。"},
					{[1] = 1, [2] = "CYN忽看到一人躺在路边，连忙将他扶起"},
					{[1] = 1, [2] = "YEL路人：好渴。。。"},
					{[1] = 0.5, [2] = "BLU路人将酒一饮而尽，颤颤巍巍的取出一点银两"},
					{[1] = 0.5, [2] = "YEL路人：救命之恩无以为报，这有几两薄银，还望少侠收下。。。少侠小心背后。"},
					{[1] = 0.5, [2] = "WHT你急忙转身，身后却空无一物，再转身，那路人已没了踪影。"},
				},
				[2] =
				{
					{[1] = 0, [2] = "HIY你打开了十里香的瓶盖，酒香四溢。"},
					{[1] = 1, [2] = "CYN忽见一小和尚与女童迎面走来"},
					{[1] = 1, [2] = "YEL女童：喂，这酒如此香醇，婆婆我要了，拿来。"},
					{[1] = 0.5, [2] = "BLU说罢，酒壶便已被女童抓在手中。"},
					{[1] = 0.5, [2] = "YEL女童：小和尚把这酒喝了，你不喝我便逼你喝。"},
					{[1] = 0.5, [2] = "BLU女童边说边与小和尚动手，两人一招一式都透漏出丝丝武学真谛。你从中获益良多。"},
				},
				[3] =
				{
					{[1] = 0, [2] = "HIY你打开了十里香的瓶盖，酒香四溢。"},
					{[1] = 1, [2] = "CYN眼见一衣衫褴褛的老者向你走来。"},
					{[1] = 1, [2] = "YEL年老长者：少侠这酒我劝你还是不喝为好，虽酒气香腻似是佳酿，但却是劣质的假酒，让小老尝一口便知。"},
					{[1] = 0.5, [2] = "BLU老者似清抿一口，品味一番，摇了摇头。"},
					{[1] = 0.5, [2] = "YEL老者：小老眼拙，这确实是难得佳酿，这有颗丹药算是打扰你酒兴的赔偿"},
					{[1] = 0.5, [2] = "BLU你接过酒瓶与丹药，却发现瓶中滴酒未剩，刚想与老者理论一番，却发现老者早已无影无踪，只能默默收好丹药，自认倒霉。"},
				},
			},
		}
		role:setFlag("PVP活动状态", "忙碌")
		local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
		MapRoleLayer:statusButtonFunc(
		    false,
		    function ()
		        PopText("酒香四溢，让你忘乎所以。")
		    end
		)
		MapRoleLayer:exitButtonFunc(
		    false,
		    function()
		        PopText("酒香四溢，让你忘乎所以。")
		    end
		)
		map.__MapLayer:setUnmoveRoom(
		    true,
		    function()
		        PopText("酒香四溢，让你忘乎所以。")
		    end
		)
		map:setCanLeave(false)
		map.__MapLayer:setNPCTouchEnabled(
		    true,
		    function()
		        PopText("酒香四溢，让你忘乎所以。")
		    end
		)
		local delay = 0
		if itemtype == "醉梦生" then
			if rewardType == 1 then
				--1,精力上限的数值为100点，最大13次
				User:addRoleAttr("qiyujingCount", 1)
				
				--按顺序弹出文本
				for i, v in ipairs(text[itemtype] [1]) do
					delay = delay + v[1]
					environment.mapLayer:delayFunc(delay, function()
						RichPrint("main", v[2])
					end)
				end
				
				environment.mapLayer:delayFunc(delay + 0.5, function()
					PopText("精力上限 + 100")
					map:richPrintText(User:getRole(), "jingMax", 100)
				end)
				
			elseif rewardType == 2 then
				-- 2,黄金1800
				User:addRoleAttr("gold", 1800)
				
				--按顺序弹出文本
				for i, v in ipairs(text[itemtype] [2]) do
					delay = delay + v[1]
					environment.mapLayer:delayFunc(delay, function()
						RichPrint("main", v[2])
					end)
				end
				
				environment.mapLayer:delayFunc(delay + 0.5, function()
					PopText("黄金 + 1800")
					map:richPrintText(User:getRole(), "gold", 1800)
				end)
				
			elseif rewardType == 3 then
				-- 3,五颗精力丹，每颗精力丹增加50点精力
				for i = 1, 5 do
					if not map:addItemCount("tianxiangyulu1", 1) then
						map:dropItem(environment.currRoomId, "tianxiangyulu1")
					else
						role:addItemCount("tianxiangyulu1", 1)
						Statistics:recordItemCount("tianxiangyulu1", 1) -- 用于统计
					end
				end
				
				--按顺序弹出文本
				for i, v in ipairs(text[itemtype] [3]) do
					delay = delay + v[1]
					environment.mapLayer:delayFunc(delay, function()
						RichPrint("main", v[2])
					end)
				end
				
				environment.mapLayer:delayFunc(delay + 0.5, function()
					PopText("你获得了 天香玉露")
				end)
				
			elseif rewardType == 4 then
				-- 4,内力丹=300内力上限
				if not map:addItemCount("putizi1", 1) then
					map:dropItem(environment.currRoomId, "putizi1")
				else
					role:addItemCount("putizi1", 1)
					Statistics:recordItemCount("putizi1", 1) -- 用于统计
				end
				
				--按顺序弹出文本
				for i, v in ipairs(text[itemtype] [4]) do
					delay = delay + v[1]
					environment.mapLayer:delayFunc(delay, function()
						RichPrint("main", v[2])
					end)
				end
				
				environment.mapLayer:delayFunc(delay + 0.5, function()
					PopText("你获得了 菩提子")
				end)
			end
		else
			if rewardType <= 8 then
				--奖励碎银
				local rewardCount = {}
				if itemtype == "清风醉" then
					rewardCount = {25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000}
				elseif itemtype == "十里香" then
					rewardCount = {10000, 12000, 14000, 16000, 18000, 20000, 22000, 24000}
				end
				
				local role = User:getRole()
				local money = rewardCount[rewardType]
				
				role:addAttr("money", money)
				
				--按顺序弹出文本
				for i, v in ipairs(text[itemtype] [1]) do
					delay = delay + v[1]
					environment.mapLayer:delayFunc(delay, function()
						RichPrint("main", v[2])
					end)
				end
				
				environment.mapLayer:delayFunc(delay + 0.5, function()
					PopText("碎银 + " .. money)
					map:richPrintText(role, "money", money)
				end)
				
			elseif rewardType <= 14 then
				--奖励潜能
				local rewardCount = {}
				if itemtype == "清风醉" then
					rewardCount = {10000, 15000, 20000, 25000, 30000, 35000}
				elseif itemtype == "十里香" then
					rewardCount = {4000, 6000, 8000, 10000, 12000, 14000}
				end
				
				local role = User:getRole()
				local pot = rewardCount[rewardType - 8]
				
				role:addAttr("pot", pot)
				
				--按顺序弹出文本
				for i, v in ipairs(text[itemtype] [2]) do
					delay = delay + v[1]
					environment.mapLayer:delayFunc(delay, function()
						RichPrint("main", v[2])
					end)
				end
				
				environment.mapLayer:delayFunc(delay + 0.5, function()
					PopText("潜能 + " .. pot)
					map:richPrintText(role, "pot", pot)
				end)
			elseif rewardType <= 15 then
				--奖励天香玉露
				local rewardCount = {1}
				
				local count = rewardCount[rewardType - 14]
				
				--按顺序弹出文本
				for i, v in ipairs(text[itemtype] [3]) do
					delay = delay + v[1]
					environment.mapLayer:delayFunc(delay, function()
						RichPrint("main", v[2])
					end)
				end
				
				for i = 1, count do
					if not map:addItemCount("tianxiangyulu1", 1) then
						map:dropItem(environment.currRoomId, "tianxiangyulu1")
					else
						role:addItemCount("tianxiangyulu1", 1)
						Statistics:recordItemCount("tianxiangyulu1", 1) -- 用于统计
					end
				end
				
				environment.mapLayer:delayFunc(delay + 0.5, function()
					PopText("你获得了 天香玉露")
				end)
			end
		end
		
		environment.mapLayer:delayFunc(delay + 1, function()
			role:setFlag("PVP活动状态", "空闲中")
			map.__MapLayer:setUnmoveRoom(false)
			map.__MapLayer:setNPCTouchEnabled(false)
			MapRoleLayer:statusButtonFunc(true)
			MapRoleLayer:exitButtonFunc(true)
			map:setCanLeave(true)
			
			if resultsStrs ~= nil then
				map:doNoRoleResults(resultsStrs, environment)
			end
		end)

	end,
	
	["获得孤儿"] = function(map, result, environment)
		-- 随机孤儿类型
		local type = math.random(1, 4)
		local inherit = User:getRoleAttr("inherit")
		-- 标记为已领养
		User:setRoleAttr("isHaveOrphan", true)
		User:getRole():setFlag("传承开始", 0)
		inherit.isSetName = false
		inherit.isFinish = false
		
		inherit.type = type
		inherit.intimacy = 0			-- 亲密度
		inherit.age = 8 				-- 年龄
		inherit.endurance = 100 		-- 疲劳
		inherit.zhengqi = 0 			-- 正邪值
		inherit.addAttr = 0 			-- 培养增加的属性和
		inherit.eventCount = 1
		inherit.sex = User:getRoleAttr("sex")
		if inherit.sex == "男" then
			if type == 1 then 				-- 男 胖
				inherit.physique = 4 		-- 体质
				inherit.noema = 2 			-- 心智
				inherit.morality = 3 		-- 德行
				inherit.temperament = 1 	-- 气质
				
			elseif type == 2 then			-- 男 瘦
				inherit.physique = 5 		-- 体质
				inherit.noema = 5 			-- 心智
				inherit.morality = 3 		-- 德行
				inherit.temperament = 3 	-- 气质
				
			elseif type == 3 then			-- 男 顽皮
				inherit.physique = 5 		-- 体质
				inherit.noema = 3 			-- 心智
				inherit.morality = 2 		-- 德行
				inherit.temperament = 2 	-- 气质
				
			elseif type == 4 then			-- 男 文弱
				inherit.physique = 1 		-- 体质
				inherit.noema = 3 			-- 心智
				inherit.morality = 5 		-- 德行
				inherit.temperament = 4 	-- 气质
			end
		elseif inherit.sex == "女" then
			if type == 1 then 				-- 女 活泼
				inherit.physique = 3 		-- 体质
				inherit.noema = 3 			-- 心智
				inherit.morality = 4 		-- 德行
				inherit.temperament = 4 	-- 气质
				
			elseif type == 2 then			-- 女 文静
				inherit.physique = 1 		-- 体质
				inherit.noema = 4 			-- 心智
				inherit.morality = 5 		-- 德行
				inherit.temperament = 5 	-- 气质
				
			elseif type == 3 then			-- 女 呆萌
				inherit.physique = 1 		-- 体质
				inherit.noema = 2 			-- 心智
				inherit.morality = 4 		-- 德行
				inherit.temperament = 5 	-- 气质
				
			elseif type == 4 then			-- 女 泼辣
				inherit.physique = 5 		-- 体质
				inherit.noema = 3 			-- 心智
				inherit.morality = 3 		-- 德行
				inherit.temperament = 2 	-- 气质
			end
		end
		
		local desc =
		{
			[1] =
			{
				"$S生于孤家集，",
				"$S生于孤家集附近的牛家村，",
				"$S生于孤家集附近的李家村，",
				"$S生于孤家集附近的王家村，",
				"$S生于孤家集附近的云来村，",
				"$S生于孤家集附近的七里屯，",
				"$S生于孤家集附近的刘家庄，",
				"$S生于孤家集附近的裕丰村，",
				"$S生于孤家集附近的钟山村，",
				"$S生于孤家集附近的新马庄，",
				"$S生于孤家集附近的黄金屯，",
				"$S生于孤家集附近的九里村，",
				"$S生于孤家集附近的云家庄，",
				"$S生于孤家集附近的莫家庄，",
				"$S生于孤家集附近的衡水村，",
				"$S生于孤家集附近的新庄村，",
				"$S生于孤家集附近的永乐屯，",
				"$S生于孤家集附近的长富屯，",
				"$S生于孤家集附近的万丰屯，",
				"$S生于孤家集附近的天兴屯，",
			},
			
			[2] =
			{
				"五岁时父母外出务工再也没有回来，从此被幽冥教收养。",
				"父母在$S两岁时抛下了$S，因此被幽冥教收养。",
				"四岁时父母无故失踪，因此被幽冥教收养。",
				"三岁时父母在修山路时因意外掉落山崖，因而被幽冥教收养。",
				"$S的父母在$S四岁时候将$S交给幽冥教抚养，没想到数年后竟然双双病亡。",
				"$S的父母在四岁时离奇失踪，是幽冥教收养了$S。",
				"$S的父母在$S两岁时就离家出走，没有再回来，是幽冥教收养了$S。",
				"$S的父母在$S三岁的时候因一场瘟疫身亡，是幽冥教将其捡回并治好了$S。",
				"两岁时随父母回娘家省亲，双亲被一伙蒙面人杀害，幸好幽冥教路过，将其救下。",
				"三岁时$S的父母无故失踪，幽冥教收留了$S。",
				"四岁的$S被父母所抛弃，是幽冥教收养了$S。",
				"五岁时$S的父母因一场瘟疫而亡，碰巧幽冥教路过，救下了$S。",
				"$S的父母在四岁的时候离$S而去，是幽冥教救下了$S。",
				"$S的父母在$S五岁时被强盗所杀，恰好幽冥教路过，将强盗杀死，救下了$S。",
				"$S三岁的时候家中起火，父母皆被烧死，唯有$S活了下来。",
				"$S四岁时外出玩耍，回家却见父母倒于血泊之中，幽冥教收养了$S。",
				"$S的父母在$S两岁那年因一场瘟疫而亡，是幽冥教收养了$S。",
				"$S的父母在$S三岁那年无故失踪，幽冥教收留了$S，",
				"$S的父母在$S三岁的时候抛下了$S，是幽冥教收养了$S。",
				"$S一出生就没有了父母，被幽冥教抚养长大，",
				"$S的父母在$S四岁时在一场火灾中离世，是幽冥教收养了$S，",
				"$S的父母在$S五岁时被山贼所杀，是幽冥教收养了$S，",
				"$S的父母在$S两岁时将$S托付给幽冥教，为此$S一直耿耿于怀，",
				"$S的父母在$S两岁时候因一场瘟疫而亡，是幽冥教收养了$S。",
				"$S刚出生时，$S的父母就遗弃了$S，是幽冥教收养了$S，",
				"在$S三岁那年，强盗洗劫了$S所在的村庄，村中只剩$S一人，被人幽冥教收养，",
				"在$S四岁那年，家中起火，父母皆被烧死，唯有$S活了下来。",
				"在$S五岁那年，$S的父母因为一场意外丧命，是幽冥教收留了$S，",
				"在$S四岁那年，村中水井被人投毒，$S的父母不幸罹难，幽冥教收留了$S，",
				"在$S三岁那年，$S的父母因为家贫而遗弃了$S，是幽冥教收养了$S，",
				
			},
			[3] =
			{
				"在机缘巧合下于$T跟随你逃出孤家集并为你所领养。"
			}
			
			
		}
		local descStr = ""
		for i, v in ipairs(desc) do
			descStr = descStr .. v[math.random(1, #v)]
		end
		local sex = "它"
		if inherit.sex == "男" then
			sex = "他"
		elseif inherit.sex == "女" then
			sex = "她"
		end
		local tiemDesc = Helper:numberCast(Helper:date("%y", GetTime())) .. "年" .. Helper:numberCast(Helper:date("%m", GetTime())) .. "月" .. Helper:numberCast(Helper:date("%d", GetTime())) .. "日"
		inherit.desc = string.gsub(descStr, "$S", sex)
		inherit.desc = string.gsub(inherit.desc, "$T", tiemDesc)
	end,
	
	["论道驳斥"] = function(map, result, environment)
		local title = result.arg2	  			--标题
		local btn1Text = result.arg3			--按钮1文字
		local btn2Text = "容我三思"				--按钮2文字
		local parentName = result.arg4			--养父名字
		
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local Inherit = require("app.models.inherit.Inherit")
		local role = User:getRole()
		if Map:getMapState("fb35") ~= MAP_STATE.COMPLETE then
			RichPrint("main", "YEL" .. parentName .. "：你江湖阅历尚浅，还是再去历练一番吧。")
			return
		end
		
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show(title)
		dialog:setRichText(title)
		dialog:setButton1(btn1Text, function()
			Inherit:lundao()
			environment.currRole.caozuo = false
		end)
		
		dialog:setButton2(btn2Text, function()
			dialog:hide()
		end)
	end,
	
	["传承请教"] = function(map, result, environment)
		-- 传承角色请教
		if string.find(environment.currRole.id, "inherit") ~= nil then
			if Map:getMapState("fb35") ~= MAP_STATE.COMPLETE then
				RichPrint("main", "YEL" .. environment.currRole.name .. "：你江湖阅历尚浅，还是再去历练一番吧。")
			else


				PopupLayerController:showLayer("InheritConsultLayer", function(layer)


					layer:showLayer(environment.currRole,map:getPlayer())
				end)
			end
		end
	end,
	
	
	["物品合成"] = function(map, result, environment)
		-- 材料
		local materials = string.split(result.arg2, ";")

		-- 策略奖励
		local rewardSchemeId = result.arg3

		-- 初始化策略
		local dropSchemeIdArray = {}
		if type(rewardSchemeId) == "string" then
			dropSchemeIdArray = string.split(rewardSchemeId, ";")
		end

		-- 合成成功调用的结果
		local resultsStrs = result.arg4

		-- 文本数组
		local textArray = result.arg5
		if textArray ~= nil then
			if type(textArray) == "string" then
				textArray = string.split(textArray, ";")
			end
		end

		-- 文本显示延迟
		local delay = 0

		local materialsMap = {}

		local role = User:getRole()

		if not MapIsEmpty(materials) then
			for k,v in pairs(materials) do
				v = string.gsub(v, "{", "")
				v = string.gsub(v, "}", "")

				local material = string.split(v, ",")
				if #material < 2 then
					print("物品合成 材料解析错误")
					return
				end
				material[2] = tonumber(material[2])
				table.insert(materialsMap, material)
			end

			if not MapIsEmpty(materialsMap) then
				local flag = true

				for k,v in pairs(materialsMap) do
					if role:getItem(v[1]) == nil or role:getItemCount(v[1]) < v[2] then
						flag = false
						PopText("材料不足，制作失败")
						break
					end
				end

				if flag == true then
					-- 消耗材料
					for k,v in pairs(materialsMap) do
						role:addItemCount(v[1], -v[2])
					end

					-- 显示文本
					if not MapIsEmpty(textArray) then
						for k,v in pairs(textArray) do
							environment.mapLayer:delayFunc(delay, function()
								RichPrint("main", v)
							end)
							delay = delay + 1
						end
					end

					-- 获取策略奖励
					if #dropSchemeIdArray > 0 then
						for i, rewardSchemeId in ipairs(dropSchemeIdArray) do
							local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(rewardSchemeId, role:getAttr("exp"), role:getFinalAttr("luck"), role:getKongfu())
							for i, reward in ipairs(rewardArray) do
								if reward.type == "物品" then

									environment.mapLayer:delayFunc(delay, function()
										PopText("获得了 " .. role:getOneItemByKey(reward.id).name)
									end)

									if not map:addItemCount(reward.id, reward.value) then
										for i=1,reward.value do
											map:dropItem(environment.currRoomId, reward.id)
										end

									else
										role:addItemCount(reward.id, reward.value)
										Statistics:recordItemCount(reward.id, reward.value) -- 用于统计
									end
								elseif reward.type == "属性" then
									if type(role:getCHAttrName(reward.id)) == "string" then
										environment.mapLayer:delayFunc(delay, function()
											PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
										end)
									end
									role:addAttr(reward.id, reward.value)
									map:richPrintText(role, reward.id, reward.value)
								else
									error()
								end
							end
						end
					end

					if resultsStrs ~= nil then
						map:doNoRoleResults( resultsStrs , environment )
					end
				end
			end
		else
			print("物品合成 解析错误")
		end
	end,
	
	["答题"] = function(map, result, environment)
		local role = User:getRole()
		-- 答对的调用
		local resultsStrs1 = result.arg2
		-- 答错的调用
		local resultsStrs2 = result.arg3
		
		-- 答题上限
		local count = result.arg4
		
		-- 月卡用户每日答题上限
		if role:yueKaIsValid() == true then
			count = result.arg5
		end
		
		-- 答题上限之后的处理
		local resultsStrs3 = result.arg6
		
		
		if role:getDayFlag("每日答题次数") >= count then
			if resultsStrs3 ~= nil then
				map:doNoRoleResults(resultsStrs3, environment)
			end
			return
		end
		
		role:setDayFlag("每日答题次数", role:getDayFlag("每日答题次数") + 1)
		
		local qaCollectList = role:getAttr("qaCollect")
		qaCollectList = Helper:getDef(qaCollectList, {})
		qaCollectList.totalCount = Helper:getDef(qaCollectList.totalCount, 0) + 1
		role:setAttr("qaCollect", qaCollectList)
		User:getRole():setFlag("PVP活动状态", "忙碌")
		PopupLayerController:showLayer("QALayer", function(layer)
			layer:showLayer(
			function()
				if resultsStrs1 ~= nil then
					map:doNoRoleResults(resultsStrs1, environment)
					
					qaCollectList.successCount = Helper:getDef(qaCollectList.successCount, 0) + 1
					role:setAttr("qaCollect", qaCollectList)
				end
				User:getRole():setFlag("PVP活动状态", "空闲中")
				HttpManagerEx:updateDailyPoint(1, 10, function(status, errcode, errmsg, data)
					if status == 200 then
						if errcode == 0 then
							PopText("活动积分 + " .. 10)
						else
							PopText(errmsg)
						end
					else
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING)
			end,
			function()
				if resultsStrs2 ~= nil then
					map:doNoRoleResults(resultsStrs2, environment)
					
					qaCollectList.failedCount = Helper:getDef(qaCollectList.failedCount, 0) + 1
					role:setAttr("qaCollect", qaCollectList)
				end
				User:getRole():setFlag("PVP活动状态", "空闲中")
			end
			)
		end)
	end,
	
	["机关锁"] = function(map, result, environment)
		-- arg2标题名称， arg3标题内容 arg4正确输入 arg5正确输入后的条件结果 arg6错误输入后的条件结果
		local title = result.arg2
		local desc = result.arg3
		local password = tonumber(result.arg4)
		-- 正确的调用
		local resultsStrs1 = result.arg5
		-- 错误的调用
		local resultsStrs2 = result.arg6
		PopupLayerController:showLayer("PasswordLockLayer", function(layer)
			layer:showLayer(title, desc, password,
			function()
				if resultsStrs1 ~= nil then
					map:doNoRoleResults(resultsStrs1, environment)
				end
			end,
			function()
				if resultsStrs2 ~= nil then
					map:doNoRoleResults(resultsStrs2, environment)
				end
			end
			)
		end)
	end,
	
	["攀岩"] = function(map, result, environment)
		-- arg1 攀岩
		-- arg2 标题;描述
		-- arg3 时间间隔
		-- arg4 次数
		-- arg5 按钮UP提示文本;按钮down文本;按钮left文本;按钮right文本
		-- arg6 成功结果
		-- arg7 失败结果
		-- arg8 按钮文本
		local textMap = string.split(result.arg2, ";")
		local title = textMap[1]
		local desc = textMap[2]
		local interval = tonumber(result.arg3)
		local count = tonumber(result.arg4)
		local strs = result.arg5
		-- 正确的调用
		local resultsStrs1 = result.arg6
		-- 错误的调用
		local resultsStrs2 = result.arg7
		
		local btnText = result.arg8
		
		PopupLayerController:showLayer("ClimbingLayer", function(layer)
			if btnText then
				layer:setButtonName(btnText)
			end
			layer:showLayer(title, desc, interval, count, strs,
			function()
				if resultsStrs1 ~= nil then
					map:doNoRoleResults(resultsStrs1, environment)
				end
			end,
			function()
				if resultsStrs2 ~= nil then
					map:doNoRoleResults(resultsStrs2, environment)
				end
			end)
		end)
	end,
	

	
	["副本跳转"] = function(map, result, environment)
		local role = User:getRole()
		local fbId = result.arg2 					-- 副本ID
		local roomId = result.arg3 					-- 房间ID
		local pr = tonumber(result.arg4) 			-- 概率
		local timeZone = result.arg7				-- 时间区域
		local resultsStrs1 = result.arg5 			-- 跳转成功
		local resultsStrs2 = result.arg6 			-- 跳转失败
		local resultsStrs3 = result.arg8 			-- 不在限定的时间内跳转 00:00 ~ 05:00
		local resultsStrs4 = result.arg9 			-- 跳转CD中
		local coldTime = tonumber(result.arg10)		-- 冷却时间
		local refreshMap = tonumber(result.arg11)	-- 是否刷新要跳转的副本  0 不刷新 1 刷新
		local maplayer = map.__MapLayer
		
		if refreshMap == nil then
			refreshMap = 1
		end

		local function mapJump()
			local currTime = GetTime()
			
			if role:getTimeLimitFlag("副本跳转" .. fbId .. roomId) ~= 0 then
				print("副本跳转" .. fbId .. roomId .. " 冷却时间中")
				if resultsStrs4 ~= nil then
					map:doNoRoleResults(resultsStrs4, environment)
				end
				return
			end
			
			if timeZone ~= nil then
				print("时间区域timeZone = " .. timeZone)
				local times = string.split(timeZone, ";")
				if MapIsEmpty(times) ~= true then
					local hour = tonumber(Helper:date("%H", currTime))
					local time1 = tonumber(times[1])
					local time2 = tonumber(times[2])
					print("当前时间 = " .. hour .. " " .. time1 .. "~" .. time2)
					if time1 > time2 and(hour >= time1 or hour < time2) then
					elseif time1 < time2 and(hour >= time2 or hour < time1) then
					else
						print("副本跳转" .. fbId .. roomId .. " 不在限定的时间内跳转")
						if resultsStrs3 ~= nil then
							map:doNoRoleResults(resultsStrs3, environment)
						end
						return
					end
				end
			end
			
			-- 概率跳转
			if math.random(1, 100) > pr then
				print("副本跳转" .. fbId .. roomId .. " 随机进入失败")
				if resultsStrs2 ~= nil then
					map:doNoRoleResults(resultsStrs2, environment)
				end
				return
			end
			
			role:setTimeLimitFlag("副本跳转" .. fbId .. roomId, 1, coldTime)
			print("副本跳转" .. fbId .. roomId .. " 跳转成功")
			if resultsStrs1 ~= nil then
				map:doNoRoleResults(resultsStrs1, environment)
			end
			
			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			local dialog = DialogALayer:getInstance()
			dialog:hide()
			dialog:delayFunc(0.1, function()
				-- add by XiaoZhiWei 2017/09/27 16:25:01 跳转前先断开链接
				-- FubenClient:disconnect()
		
				local map = User:getRole():getMapById(fbId)
				User:setRoleAttr("currMapId", map.id)
				if refreshMap == 1 then
					print("副本跳转 刷新副本 " .. map.id)
					map = User:getRole():initMapById(map.id)
				elseif refreshMap == 2 then
					--@desc 副本跳转自然刷新
					local lastTime = role:getFlag(map.id)
	
					if lastTime == 0 and map._isComingIn == nil then
						print("副本跳转 第一次进入副本 初始化 " .. map.id)
						map = User:getRole():initMapById(map.id)
						-- role:setFlag(map.id, GetTime())
					elseif (lastTime ~= 0 and GetTime() - lastTime >= MAP_REFRESH_INTERVAL) or map._isComingIn == nil then
						print("副本跳转 超过副本时间 或者游戏重新启动 初始化 " .. map.id)
						map = User:getRole():initMapById(map.id)
					else
						print("副本跳转 直接进入副本" .. map.id)
					end
				else
					if map._isComingIn ~= true then
						map = User:getRole():initMapById(map.id)
					else
						print("副本跳转 直接进入副本" .. map.id)
					end
				end
	
				map:setCallBackAndConnect(function()
					maplayer:setMap(map)
					maplayer:replaceRoom(roomId)
					maplayer.ControllLayer:pushLayer("MapLayer")
					map:setCurrRoomId(roomId)
					map._isComingIn = true
				end)
			end)
			map.__MapLayer.TotalMapBtn_IsInit = false
			map.__MapLayer:quit(false)
		end

		HttpManagerEx:getConfigFuben(
            fbId,
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        if data.status == 1 then
                            mapJump()
                        else
                            PopText("此章节暂未开放，敬请期待")
                        end
                    else
                        PopText(errmsg)
                    end
                end
            end,
            IS_SHOW_WAITING
		)

	end,
	
	["增强NPC属性"] = function(map, result, environment)
		local role = User:getRole()
		local npcId = result.arg2
		local buff = tonumber(result.arg3)
		print("增强NPC属性 " .. npcId .. " buff " .. buff)
		role:setMapNpcBuff(npcId, buff)
		
		local mapRolelist = map:getRoles()
		for k, v in pairs(mapRolelist) do
			map:npcAttrModify(v)
		end
	end,
	
	-- add by XiaoZhiWei 2017/06/06 10:05:50
	["佣兵NPC属性变化"] = function(map, result, environment)
		local player = User:getRole()
		local npcId = result.arg2
		local attrName = result.arg3
		local value = result.arg4
		player:setMapNpcAttr(npcId, attrName, value)
		
		local mapRolelist = map:getRoles()
		for k, v in pairs(mapRolelist) do
			map:npcAttrModify(v)
		end
	end,
	
	["更换npc装备"] = function(map, result, environment)
		local role = User:getRole()
		local npcId = result.arg2
		local itemId = result.arg3
		print("更换npc装备 " .. npcId .. " itemId " .. itemId)
		role:setMapNpcEquips(npcId, itemId)
		
		local mapRolelist = map:getRoles()
		for k, v in pairs(mapRolelist) do
			map:npcAttrModify(v)
		end
	end,
	
	-- add by XiaoZhiWei 2017/04/22 10:02:30
	["增加NPC武功等级"] = function(map, result, environment)
		local player = User:getRole()
		local npcId = result.arg2
		local addLv = Helper:getDef(result.arg3, 0)
		if npcId == nil or type(addLv) ~= "number" then
			return
		end
		player:addMapNpcSkillLv(npcId, addLv)
		
		local mapRolelist = map:getRoles()
		for k, v in pairs(mapRolelist) do
			map:npcAttrModify(v)
		end
	end,
	
	-- add by XiaoZhiWei 2017/04/25 19:56:44
	["增加NPC招式熟练度"] = function(map, result, environment)
		local player = User:getRole()
		local npcId = result.arg2
		local addExp = Helper:getDef(result.arg3, 0)
		player:addMapNpcZhaoExp(npcId, addExp)
		
		local mapRolelist = map:getRoles()
		for k, v in pairs(mapRolelist) do
			map:npcAttrModify(v)
		end
	end,
	
	-- add by XiaoZhiWei 2017/04/26 01:37:40
	["添加NPC武功招式"] = function(map, result, environment)
		local player = User:getRole()
		local npcId = result.arg2
		local zhaoId = result.arg3
		
		player:addMapNpcZhao(npcId, zhaoId)
		local mapRolelist = map:getRoles()
		for k, v in pairs(mapRolelist) do
			map:npcAttrModify(v)
		end
	end,
	
	["领取俸禄"] = function(map, result, environment)
		local role = User:getRole()
		if role:getDayFlag("每日俸禄") ~= 0 then
			PopText("你已经领过俸禄了，明日再来！")
			return
		end
		HttpManagerEx:getFenLu(function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data then
						role:setAttr("officialType", data.guanzhi)
						role:setAttr("officialAchievement", data.zhengji)
						role:setDayFlag("每日俸禄", 1)
						print("领取俸禄")
						-- 翰林院编修：每日可领取俸禄=角色等级*100碎银；
						-- 庶吉士：每日可领取俸禄=角色等级*80碎银；
						-- 推官：每日可领取俸禄=角色等级*50碎银
						if data.guanzhi == 0 then
							PopText("因政绩考评太差，你已被罢官，不能领取俸禄！")
							return
						end
						local money = 0
						local yueli = 0
						local yinpiao = data.yinpiao
						local meiyu = data.meiyu
						if data.guanzhi == 1 then
							money = role:getLv() * 100
							yueli = 5
						elseif data.guanzhi == 2 then
							money = role:getLv() * 80
							yueli = 4
						elseif data.guanzhi == 3 then
							money = role:getLv() * 50
							yueli = 3
						end
						
						if data.is_normal == "N" then
							money = math.floor(money / 2)
						end
						
						PopText("碎银 + " .. money)
						role:addAttr("money", money)
						
						PopText("江湖阅历 + " .. yueli)
						role:addAttr("yueli", yueli)
						
						if meiyu and meiyu ~= 0 then
							PopText("江湖美誉 + " .. meiyu)
						end

						if yinpiao and yinpiao ~= 0 then
							PopText("银票 + ".. yinpiao)
						end
					end
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end,
	
	["辞官"] = function(map, result, environment)
		HttpManagerEx:officialResignation(function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					print("辞官成功")
					local role = User:getRole()
					role:setAttr("officialType", 0)
					role:setAttr("officialAchievement", 0)
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end,
	
	["改变政绩"] = function(map, result, environment)
		local zhengji = result.arg2
		-- 默认取20
		if zhengji == nil then
			zhengji = 20
		end
		
		local role = User:getRole()
		local officialType = role:getAttr("officialType")
		if officialType ~= 0 and officialType ~= nil then
			HttpManagerEx:uploadOfficialAchievement(zhengji, officialType, function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then
						if data then
							local role = User:getRole()
							if role:getAttr("officialType") ~= 0 then
								role:setAttr("officialAchievement", data.zhengji)
							end
						end
					else
						PopText(errmsg)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end
	end,
	
	["自定义文本动画"] = function(map, result, environment)
		-- pushBackPanelList 参数
		-- CustomLayer:pushBackPanelList(type, str, fontSize, vA, hA, height, actionType, interval, func)
		-- type text:文本 btn：按钮 empty:空的,用于间隔 shade:阴影 return:返回
		-- str  文本
		-- fontSize 大小
		-- vA 文本垂直显示方式
		-- hA 文本水平显示方式
		-- cc.TEXT_ALIGNMENT_CENTER	= 1	居中
		-- cc.TEXT_ALIGNMENT_LEFT  	= 0	靠左
		-- cc.TEXT_ALIGNMENT_RIGHT 	= 2	靠右
		-- cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM   	= 2 靠底部
		-- cc.VERTICAL_TEXT_ALIGNMENT_CENTER   	= 1	居中
		-- cc.VERTICAL_TEXT_ALIGNMENT_TOP  		= 0	靠顶部
		-- height 高度
		-- actionType 动画类型 Fade 渐显 Empty直接显示
		-- interval 间隔
		-- func 回调
		local resultsStrs1 = result.arg2 -- 结束调用的结果集
		local list = {}
		for i = 3, 999 do
			if result["arg" .. i] then
				table.insert(list, result["arg" .. i])
			else
				break
			end
		end
		local CustomLayer = require("app.views.layer.PopLayer.PopLayer")
		CustomLayer:getInstance():showLayer()
		for i, v in ipairs(list) do
			local strMap = string.split(v, ";")
			for i, v in ipairs(strMap) do
				if v == "nil" then
					strMap[i] = nil
				end
			end
			local type = strMap[1]
			local str = strMap[2]
			local fontSize = strMap[3]
			local vA = strMap[4]
			local hA = strMap[5]
			local height = strMap[6]
			local actionType = strMap[7]
			local interval = strMap[8]
			CustomLayer:getInstance():pushBackPanelList(type, str, fontSize, vA, hA, height, actionType, interval)
		end
		CustomLayer:getInstance():pushBackPanelList("return", "", nil, nil, nil, nil, nil, 0, function()
			if resultsStrs1 ~= nil then
				map:doNoRoleResults(resultsStrs1, environment)
			end
		end, 0)
		CustomLayer:getInstance():startShow()
	end,
	
	["治疗暗疾"] = function(map, result, environment)
		local resultsStrs1 = result.arg2 	-- 成功
		local resultsStrs2 = result.arg3 	-- 失败
		local role = User:getRole()
		
		PopupLayerController:showLayer("MeridianDiseaseLayer", function(layer)
			layer:showLayer(
			function()
				if resultsStrs1 ~= nil then
					map:doNoRoleResults(resultsStrs1, environment)
				end
			end,
			function()
				if resultsStrs2 ~= nil then
					map:doNoRoleResults(resultsStrs2, environment)
				end
			end
			)
		end)
	end,
	
	["挂机类条件结果"] = function(map, result, environment)
		-- add by XiaoZhiWei 2017/07/27 16:58:45 挂机类条件结果
		map:pushScheduleResult(result.arg2, environment, result.arg3)
	end,
	
	["更新副本跟随者信息"] = function(map, result, environment)
		local key, value = result.arg2, result.arg3
		local changeMap =
		{
			["NPC列表"] = "npcList",
			["房间列表"] = "roomList",
			["标记"] = "key",
			["标记值"] = "value",
		}
		if key == nil or changeMap[key] == nil then
		else
			key = changeMap[key]
			if key == "npcList" then
				if value == nil then
					value = {}
				else
					value = string.split(value, ",")
				end
				
			elseif key == "roomList" then
				if string.len(value) >= 1 then
					local list = string.split(value, ",")
					local roomList = {}
					for i, v in ipairs(list) do
						roomList[v] = true
					end
					value = roomList
				else
					value = {}
				end
			else
			end
			map:updateFollowInfo(key, value)
			map:refreshFollowRoles(environment.currRoomId)
		end
	end,
	
	["设置副本追随者信息"] = function(map, result, environment)
		local npcList, roomList, key, value = {}, {}
		local npcStr, roomsStr = result.arg2, result.arg3
		key = result.arg4
		value = result.arg5
		
		if npcStr ~= nil then
			npcList = string.split(npcStr, ",")
		end
		
		if roomsStr ~= nil then
			local list = string.split(roomsStr, ",")
			for i, v in ipairs(list) do
				roomList[v] = true
			end
		end
		
		map:setFollowInfo(npcList, roomList, key, value)
		map:refreshFollowRoles(environment.currRoomId)
	end,
	
	["添加副本追随者"] = function(map, result, environment)
		local npcIds = result.arg2
		if npcIds == nil then
		else
			local currNpcList = map:getFollowInfoByKey("npcList")
			local npcList = string.split(npcIds, ",")
			if MapIsEmpty(currNpcList) == true then
			else
				for i, v in ipairs(currNpcList) do
					table.insert(npcList, math.random(1, #npcList), v)
				end
			end
			map:updateFollowInfo("npcList", npcList)
			-- Helper:print_lua_table(npcList)
			map:refreshFollowRoles(environment.currRoomId)
		end
	end,
	
	["移除副本追随者"] = function(map, result, environment)
		local npcIds = result.arg2
		local currNpcList = map:getFollowInfoByKey("npcList")
		local _currNpcList = clone(currNpcList)
		if npcIds ~= nil then
			local npcList = string.split(npcIds, ",")
			local list = {}
			if MapIsEmpty(currNpcList) == true then
			else
				for j, npcId in pairs(npcList) do
					for i, v in pairs(_currNpcList) do
						if npcId == v then
							table.remove(_currNpcList, i)
							break
						end
					end
				end
			end
			map:updateFollowInfo("npcList", _currNpcList)
			-- Helper:print_lua_table(_currNpcList)
			map:refreshFollowRoles(environment.currRoomId)
		end
	end,
	
	["替换副本追随者"] = function(map, result, environment)
		local npcIds = result.arg2
		local changeNpcIds = result.arg3
		local currNpcList = map:getFollowInfoByKey("npcList")
		local _currNpcList = clone(currNpcList)
		local npcList = {}
		local changeNpcList = {}
		if npcIds ~= nil then
			npcList = string.split(npcIds, ",")
		end
		
		if changeNpcIds ~= nil then
			changeNpcList = string.split(changeNpcIds, ",")
		end
		local list = changeNpcList
		if MapIsEmpty(_currNpcList) == true then
		else
			for j, npcId in ipairs(npcList) do
				for i, v in pairs(_currNpcList) do
					if npcId == v then
						_currNpcList[i] = list[j]
						break
					end
				end
			end
		end
		map:updateFollowInfo("npcList", _currNpcList)
		-- Helper:print_lua_table(_currNpcList)
		map:refreshFollowRoles(environment.currRoomId)
	end,
	
	["随机追随者设置"] = function(map, result, environment)
		local npcStrs, count, weights = Helper:getDef(result.arg2, ""), Helper:getDef(result.arg3, 0), Helper:getDef(result.arg4, "")
		if npcStrs == "" or count == 0 then
		else
			local npcList = string.split(npcStrs, ",")
			local list = {}
			local index
			for i = 1, count do
				if string.len(weights) > 1 then
					index = Helper:RandomIndexByPercentWithString(weights)
					table.insert(list, npcList[index])
				else
					index = math.random(1, #npcList)
					table.insert(list, npcList[index])
				end
				table.remove(npcList, index)--若随机到同一个index则显示的npc会小于count个
			end
			map:setFollowInfo(list)
			map:refreshFollowRoles(map:getCurrRoomId())
		end
	end,
	
	["设置副本概率事件"] = function(map, result, environment)
		--[[			概率大小
			触发事件
			次数上限
			保底次数
			排除列表
		]]
		local name, percent, resultId, pType, failRstId, timesLimit, minTimes, exceptList = result.arg2, result.arg3, result.arg4, result.arg5, result.arg6, result.arg7, result.arg8, {}
		if result.arg9 ~= nil then
			local list = string.split(result.arg9, ",")
			for i, v in ipairs(list) do
				exceptList[v] = true
			end
		end
		map:setMapProbabilityResult(name, pType, percent, resultId, failRstId, timesLimit, minTimes, exceptList, environment)
	end,
	
	["变化副本概率事件"] = function(map, result, environment)
		local name, percent, resultId, pType, failRstId, timesLimit, minTimes, exceptList = result.arg2, result.arg3, result.arg4, result.arg5, result.arg6, result.arg7, result.arg8, {}
		if result.arg9 ~= nil then
			local list = string.split(result.arg9, ",")
			for i, v in ipairs(list) do
				exceptList[v] = true
			end
		end
		
		local updateList =
		{
			["pType"] = pType,
			["percent"] = percent,
			["resultId"] = resultId,
			["failRstId"] = failRstId,
			["timesLimit"] = timesLimit,
			["minTimes"] = minTimes,
			["exceptList"] = exceptList,
		}
		
		for k, v in pairs(updateList) do
			map:updateMapProbabilityResult("add", name, k, v)
		end
	end,
	
	["更新副本概率事件"] = function(map, result, environment)
		map:updateMapProbabilityResult("update", result.arg2, result.arg3, result.arg4)
	end,
	
	["取消副本概率事件"] = function(map, result, environment)
		local nameStrs = Helper:getDef(result.arg2, "")
		local list = string.split(nameStrs, ",")
		for k, name in pairs(list) do
			map:cancelMapProbabilityResult(name)
		end
	end,
	
	["弹出按钮选择框"] = function(map, result, environment)
		local text = result.arg2
		local buttonTextList = string.split(Helper:getDef(result.arg3, ""), ",")
		local resultIdList = string.split(Helper:getDef(result.arg4, ""), ",")
		
		local list = {}
		for i, buttonText in ipairs(buttonTextList) do
			local data = {}
			data.name = buttonText
			data.index = i
			table.insert(list, data)
		end

		PopupLayerController:showLayer("ItemSelectAutoFitLayer",function ( layer )
			layer:setBtnClickFunc(
				function ( index )
					layer:hideLayer()

					local resultId = resultIdList[index]

					if resultId ~= nil and resultId ~= "" then
						map:doNoRoleResults(resultId, environment)
					else
						if PRINT_MODE == 1 then
							print("这个按钮没有设置结果")
						end
					end
				end
			)
			layer:setList(list)
			layer:setTitle(text)
			layer:showLayer()
		end)
	end,
	
	["材料兑换"] = function(map, result, environment)

		local roleStr = result.arg2--"请问打算兑换哪一种淬炼材料？如意可等额兑换任意一种淬炼材料。"
		local cailiaoID = result.arg3--"cuilianruyi"--
		local item=Item:getOneItemByKey(cailiaoID)
		local duihuanList =string.split(Helper:getDef(result.arg4, ""), ",") --{"cuiliancailiao1","cuiliancailiao2","cuiliancailiao3","cuiliancailiao4","cuiliancailiao5","cuiliancailiao6","cuiliancailiao7","cuiliancailiao8"}--
		local ratioList = string.split(Helper:getDef(result.arg5, ""), ",")--{"1","1","1","1","1","1","1","1"}--
		PopupLayerController:showLayer("GoodsShowLayer",function(layer)
			layer:showLayer(item.name,roleStr,cailiaoID,duihuanList,ratioList)  --标题，NPC文本，兑换货币，兑换列表，兑换比率
		end)
	end,

	["弹出按钮选择框大"] = function(map, result, environment)
		local text = result.arg2
		local btnList = string.split(Helper:getDef(result.arg3, ""), ",")
		local list = string.split(Helper:getDef(result.arg4, ""), ",")
		local funcList = {}
		for i = 1, 5 do
			funcList[i] = function()
				if list[i] ~= nil then
					map:doNoRoleResults(list[i], environment)
				end
			end
		end
		
		local ChooseButtonBigLayer = require("app.views.layer.DialogLayer.ChooseButtonBigLayer")
		local layer = ChooseButtonBigLayer:getInstance()
		layer:initLayer(text, btnList[1], funcList[1], btnList[2], funcList[2], btnList[3], funcList[3], btnList[4], funcList[4], btnList[5], funcList[5])
	end,
	
	["元宝消耗"] = function(map, result, environment)
		-- "goumaiyinqi"
		PopYuanBaoBuyItemLayer(result.arg2, function(eventType)
			if eventType == "success" then
				PopText("元宝 - " .. tostring(50))
				map:doNoRoleResults(result.arg3, environment)
			end
		end)
	end,
	
	["时间段判断"] = function(map, result, environment)
		local timeList = string.split(Helper:getDef(result.arg2, ""), ";")
		local onTimeList = Helper:getDef(result.arg3, "")
		local errList = Helper:getDef(result.arg4, "")
		local time = tonumber(Helper:date("%H", GetTime()))
		local isNOTime = true
		local list
		for i, v in ipairs(timeList) do
			list = string.split(Helper:getDef(v, ""), ",")
			
			if PRINT_MODE == 1 then
				print("时间段判断的arg2参数:", list[1], list[2])
				print("时间段判断的arg3参数:", onTimeList)
				print("时间段判断的arg4参数:", errList)
			end
			if type(tonumber(list[1])) == "number" and type(tonumber(list[2])) == "number" then
				if time >= tonumber(list[1]) and time < tonumber(list[2]) and onTimeList ~= "" then
					map:doNoRoleResults(onTimeList, environment)
					isNOTime = false
					return			
				end
			else
				print("时间段判断的arg2参数 list[1]或list[2]不为number")
			end
		end
		if isNOTime and errList ~= "" then
			map:doNoRoleResults(errList, environment)
		end
		
	end,
	
	["送礼条件结果"] = function(map, result, environment)
	    local ZhongQiuRequireList = string.split(Helper:getDef(result.arg2, "") ,";")
		local resultList = string.split(Helper:getDef(result.arg3, "") ,";")
		local defresult = result.arg4
		local role = User:getRole()
		
	    local isSuc = false
		for i,v in ipairs(ZhongQiuRequireList) do
		    local ZhongQiuRequire = string.split(v ,",")
			if PRINT_MODE == 1  then
				print("送礼条件结果result.arg2 中参数：",ZhongQiuRequire[1],ZhongQiuRequire[2])
			end
			if   ZhongQiuRequire[1] == nil or ZhongQiuRequire[2] == nil then
				return
			end

			--@desc 解决如果物品可堆叠，会发生无法送礼的情况
			local itemAttr = Item:getOneItemByKey(ZhongQiuRequire[1])
			if itemAttr == nil then
				return
			end
			local count = 0
			if itemAttr.type == "淬炼材料" or itemAttr.type == "锻造材料" then
				count = role:getSmeltBoxItemCount(ZhongQiuRequire[1])
			else
				count = role:getItemCount(ZhongQiuRequire[1])
			end
			
			
			if count >= tonumber(ZhongQiuRequire[2])  then
				if PRINT_MODE == 1  then
					print("送礼条件结果result.arg3 中参数：",resultList[i])
				end
                if resultList[i] == nil then
					return
			    end 
			    role:addItemCount(ZhongQiuRequire[1] ,- tonumber(ZhongQiuRequire[2]))
				map:doNoRoleResults(resultList[i],environment)
				isSuc = true
				return
			end	
		end
		if isSuc ~= true  then
			if not defresult then
				-- RichPrint("main","我不接受你的物品！")
		    	PopText("我不接受你的物品！")
			else
				map:doNoRoleResults(defresult,environment)
			end			
			return
		end
	end,
	
	["是否佩戴面具"] = function(map, result, environment)
		local player = User:getRole()
		local ret = false
		do
			-- add by XiaoZhiWei 2017/09/25 17:04:06 兼容老版本,判断头部是否佩戴面具
			local equips = Helper:getDef(player:getAttr("equips"), {})
			if MapIsEmpty(equips) == false and MapIsEmpty(equips.head) == false then
				local headItemId = equips.head.itemId
				if headItemId ~= nil then
					local itemAttr = Item:getOneItemByKey(headItemId)
					if MapIsEmpty(itemAttr) == false and itemAttr.type == "面具" then
						ret = true
					else
						if PRINT_MODE == 1 and MapIsEmpty(itemAttr) == true then
							print("获取不到物品的基本信息,请确认资源是否正确. itemId == ", headItemId)
						end
					end
				end
			end
		end
		
		do
			-- add by XiaoZhiWei 2017/09/25 17:03:59 判断信物
			local portrait = player:getPortraitId() --信物
			if portrait ~= nil and portrait ~= "" then
				ret = true
			end
		end
		
		if ret == true then
			map:doNoRoleResults(result.arg2, environment)
		else
			map:doNoRoleResults(result.arg3, environment)
		end
	end,
	
	["面具对应文本"] = function(map, result, environment)
		local role = User:getRole()
		local portrait = Item:getOneItemByKey(role:getPortraitId())					
		print(portrait)	
		local miaohuitext = require("script.others.miaohuitext").Sheet1
		if portrait ~= nil then
			if miaohuitext[portrait.id] ~= nil then
				print(miaohuitext[portrait.id])
				local text = miaohuitext[portrait.id].text
				print(text)
				RichPrint("main", text)
			end
		else
			RichPrint("main", "YEL莫啸：咦？没有面具？ 算了算了，今天我大发慈悲，进去吧。")			
		end
	end,
	
	-- ["面具文本输出"] = function(map, result, environment)
	-- 	local role = User:getRole()
	-- 	if result.arg2 ~= nil then
	-- 		local portraitId = role:getPortraitId()
	-- 		local item = Item:getOneItemByKey(portraitId)
	-- 		if item and item.maskName ~= nil and item.maskName ~= "" then
	-- 			local text = string.gsub(result.arg2, "$S", item.maskName)	
	-- 			RichPrint("main", text)
	-- 		elseif Item:getOneItemByKey(role:getEquipByName("head").itemId).maskName ~= nil and Item:getOneItemByKey(role:getEquipByName("head").itemId).maskName ~= "" then
	-- 			local text = string.gsub(result.arg2, "$S", Item:getOneItemByKey(role:getEquipByName("head").itemId).maskName)	
	-- 			RichPrint("main", text)
	-- 		end
	-- 	end
	-- end,
	
	["调查问卷"] = function(map, result, environment)
		--[[ 
			参数1：调查问卷
			参数2：调查内容：游戏内容调查
			参数3：题库内容   1;2;3;4;5;6;7
			参数4：结果1;结果2
			参数5：全部题目做完之后的条件结果
			参数6：每日问卷做完次数
			参数7：是否每次答完后关闭界面 （0 | 1，可选，默认为0）
		]]
		local role = User:getRole()
		local dayCount = Helper:getDef(tonumber(result.arg6), - 1)
		
		if dayCount ~= - 1 then
			if role:getDayFlag("调查问卷" .. result.arg2) > dayCount then
				PopText("今日问卷已超过" .. dayCount .. "次")
				return
			end
		end
		
		local qs = require("app.models.QAModel.qs")
		local questions = {}		
		if result.arg3 then
			questions = string.split(result.arg3, ";")
		end
		
		local doCurrResults = {}
		if result.arg4 then
			doCurrResults = string.split(result.arg4, ";")
		end
		
		qs:initQuestionMap(questions, doCurrResults)
		
		local qsLayer = require("app.views.layer.QALayer.QSLayer")
		qsLayer:getInstance():showLayer(result.arg2, {isHide = Helper:getDef(tonumber(result.arg7), 0), fprize = Helper:getDef(result.arg6, "")})
	end,
	
	-- ["调查问卷"] = function(map, result, environment)
	-- 	local func = result.arg2
	-- 	print("----------------------------------------",result.arg2,type(func),type(func) == "function")
	-- 	if type(func) == "function" then
	-- 		func()
	-- 	end
	-- end,



	["时间日期判断"] = function(map, result, environment)
		local dateStr = assert(result.arg2,"时间日期判断,参数二没有")
		local resultStr = assert(result.arg3,"时间日期判断,参数三没有")
		local failedResult = result.arg4
		local dateList = string.split(dateStr,";")
		local resultList = string.split(resultStr,";")
		assert(#dateList == #resultList,"填写的日期数量与条件结果集的数量不一致")
		local currDate = Helper:date("%Y%m%d",GetTime())
		for k,date in pairs(dateList) do 
			if date == currDate then
				if resultList[k] then
					map:doNoRoleResults(resultList[k],environment)
					-- RichPrint("main",resultList[k])
					return
				else
					if DEBUG_MODE == 1 then
						print("条件结果集",k,"不存在")
					end
				end
				return
			end
		end
		map:doNoRoleResults(failedResult,environment)
	end,

	["神兵重铸"] = function(map, result, environment)
		local player = User:getRole()
        local shenBingweapon = player:getItems(function(item)
			return item.type == "神兵"
		end)

		local isCanMake = false

        if #shenBingweapon > 0 then
			local shenBing = player:getDefaultShenBing()

			if not shenBing then
				PopText("您还没有装上默认神兵，无法进行操作")
				return
			end

			do	--bug导致特殊材料神兵typeDesc不存在，直接不能重铸
				if not shenBing.typeDesc then
					PopText("神兵"..shenBing.name.."数据异常，请联系客服！")
					return
				end
			end

			local roleName = environment.currRole.name
			local roleType = 1
			
			if roleName == "干将" then
				roleType = 1
			elseif roleName == "莫邪" then
				roleType =2
			end

			local npcDuanZaoType = {
				[1]={"剑","刀","棍","乐器"},
				[2]={"鞭","双持","暗器"}
			}
	
			local specialDuanZaoCaiLiao = {["tie102"] = "千年神木",["tie103"] = "海底金母",["tie104"] = "寒丝羽竹"}
	
			local npcPrint={
				[1]="：你这把武器……唔，当初打造时所用的材料特异，恕在下没法重铸。",
				[2]="：你这武器没法重铸。"
			}

        	local duanZaoItems = shenBing.duanzaoitems

        	for id,v in pairs(specialDuanZaoCaiLiao) do
				if duanZaoItems.itemId == id then
					RichPrint("main",roleName..npcPrint[roleType])
        			return
				end
        	end

        	for i,v in pairs(npcDuanZaoType[roleType]) do 
        		if shenBing.type == v then 
        			isCanMake = true
					break
		        end
		    end

	    	if isCanMake == true then
		     	PopupLayerController:showLayer(
			            "ShenBingRemakeLayer",
			            function(layer)
							layer:setRole(player)
							layer:setNpcType(roleType)
							layer:setCurrWeapon(shenBing)
							layer:setCanRemakeList(npcDuanZaoType[roleType])
							layer:setSpecialDuanZaoCaiLiaoList(specialDuanZaoCaiLiao)
			                layer:showLayer() 
			            end
			        ) 
		    else
				RichPrint("main",roleName.."：阁下的神兵，恕在下无法重铸。")
		    end
        else
        	PopText("你没有神兵，谈何重铸！")
        end
	end,

	["物品选择获得"] = function(map, result, environment)
		--@RefType [src.app.models.role.Role#Role]
		local role = User:getRole()
		local bgItem = role:getItems(function (item)
			return item.itemId == result.arg4
		end)

		if MapIsEmpty(bgItem) then
			PopText(result.arg5)
			return
		end
		
		local itemListStr = result.arg3
		local itemIdList = string.split(itemListStr,";")

		local list = {}
		local data = {}
		for _,itemId in ipairs(itemIdList) do
			data = {}
			--@RefType [src.app.models.item.BaseItem#BaseItem]
			local item = Item:getOneItemByKey(itemId)
			local name = item:getNcname(item.name)
			data.name = name
			data.itemId = itemId
			table.insert(list,data)
		end

		PopupLayerController:showLayer("ItemSelectLayer",function ( layer )
			layer:setBtnClickFunc(
				function ( itemId )
					local item = Item:getOneItemByKey(itemId)
					local name = item:getNcname(item.name)

					--@RefType [src.app.views.layer.DialogLayer.DialogALayer#DialogALayer]
					local dialog = require("app.views.layer.DialogLayer.DialogALayer"):getInstance()

					dialog:show("你确定选择"..name.."吗?")

					dialog:setButton1("确定",function ()
						if role:checkCanBuyTwoOrMoreThings({[itemId] = 1}) then
							role:addItemCount(bgItem[1].itemId,-1)
	
							role:addItemCount(itemId,1)
	
							PopText("你获得了"..item.name.." X 1")
							PopupLayerController:hideLayer("ItemSelectLayer",function ( hideLayer )
								hideLayer:hideLayer()
							end,removeTime)
						end
					end)

					dialog:setButton2("取消",function ()
					end)

					dialog:setWeChatVisible(false)

				end
			)
			layer:setList(list)
			layer:setTitle(result.arg2)
			layer:showLayer()
		end)
	end,

	["面具兑换"] = function(map, result, environment)
		--[[
			arg2 = 兑换的物品ID,
			arg3 = 兑换面具列表，
			arg4 = 成功兑换文本,
		]]

		if PRINT_MODE == 1 then
			print("==================== 面具兑换，传入参数：======================")
			Helper:print_lua_table(result)
			print("===============================================================")
		end

		if not result.arg2 or type(result.arg2) ~= "string" then
			print("面具兑换：参数2填写错误")
			return
		end

		if not result.arg3 or type(result.arg3) ~= "string" then
			print("面具兑换：参数3填写错误")
			return
		end

		
		--@RefType [src.app.models.role.Role#Role]
		local role = User:getRole()
		local bagItem = role:getItem(result.arg2)
		if not bagItem then
			PopText("你没有可兑换的物品")
			return
		end
		
		local selectList = string.split(result.arg3,";")

		PopupLayerController:showLayer("DecorativeSelectLayer",function ( layer )
			if result.arg4 then
				layer:setSuccessText(result.arg4)
			end
			layer:showLayer(selectList,result.arg2)
		end)
	end,

	["扣除物品"] = function(map, result, environment)
		local itemList = {}
		print("==============================result.arg2result.arg2====================================")
		print(result.arg2)
		print(result.arg3)
		if not result.arg2 or not result.arg3 then
			return
		end
		local resultList = string.split(result.arg3,";")
		for k,v in pairs(string.split(result.arg2,";")) do
			local itemNUm = string.split(v,",")
			local tab = {
				itemId = itemNUm[1],
				number = itemNUm[2],
				result = resultList[k]
			} 
			table.insert(itemList,tab)
		end
		local needDo = false
		local role = User:getRole()
		for k,v in pairs(itemList) do 
			local itemAttr = role:getOneItemByKey(v.itemId)
			if itemAttr then
				local count = role:getItemCount(v.itemId)
				if count > 0 then
					local number = 0
					if v.number == nil or v.number == "" then
						v.number = count
						print("v.number1:",v.number)
					else
						v.number = tonumber(v.number)
						print("v.number2:",v.number)
					end
					if v.number >= count then
						role:addItemCount(v.itemId,0-v.number)
						PopText(itemAttr.name.."-"..tostring(v.number))
						needDo = true
						map:doNoRoleResults(v.result,environment)
					end
				end
			end
		end
		if needDo == true and result.arg4 then
			map:doNoRoleResults(result.arg4,environment)
		else
			PopText("你没有我要的物品")
		end
	end,

	["增加周年庆积分"] = function(map, result, environment)
		local num = result.arg2
		local addType=result.arg3
		local tab = {
			shop_id = "zhounianqin_jf",
			number = num,
			type = addType
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
	end,

	["周年礼券增加"] = function(map, result, environment)
		local num = result.arg2
		local addType=result.arg3
       	HttpManagerEx:addZhounianJifen(addType,num,function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if data.number > 0 then
                        PopText("七夕礼券+"..tostring(data.number))
                    end
                else
                    PopText(errmsg)
                end
            end
        end, IS_SHOW_WAITING)
	end,
	["物品详情界面"] = function(map, result, environment)
		local itemId = result.arg2	--物品Id
		local text_price = result.arg3	--展示文本
		local button_confirm_name = result.arg4	--确定按钮名字
		local button_close_name = result.arg5	--取消按钮名字
		local confirm = result.arg6	--确定执行的条件结果集
		local close = result.arg7	--取消执行的条件结果集
		local isShowNum = result.arg8 --是否显示已经拥有的数量
		local tipsStr = result.arg9  --显示功能提示文本
		local itemData = Item:getOneItemByKey(itemId)

		local textList = {
		Text_tital = itemData.name,
		Text_type = itemData:getItemShowType(),
		Text_dsc = itemData.dsc,
		Text_price = text_price,
		Text_affirm = tipsStr or "确定购买"..itemData.name.."吗？",
		Text_havenum = isShowNum == 1 and "已拥有:".. User:getRole():getItemTotalCount(itemData.id)..itemData.unit or "",
	}

	PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
		layer:showLayer(textList,function()
		end)
		layer:setButton_confirm(button_confirm_name, function()
			map:doNoRoleResults(confirm,environment)
		end)
		layer:setButton_close(button_close_name, function()
			map:doNoRoleResults(close,environment)
		end)
	end)
	end,
	["丁典传功"] = function(map, result, environment)
		if User:getRole():getDayFlag("benrichuangong") ~= 1 and User:getRole():getInheritFlag("szjwb") ~= 1 then
			local skillType = {"shenzhaojing003", "shenzhaojing002", "shenzhaojing001"}
			local role = User:getRole()
			local isHavaSZJ = false
			local currSZJSkillID
			local showText = ""
			for i, v in ipairs(skillType) do
				local szjSkill = role:getSkill(v)
				if szjSkill ~= nil then
					isHavaSZJ = true
					currSZJSkillID = v
					break
				end
			end
			if isHavaSZJ == false then
				currSZJSkillID = "shenzhaojing001"
				showText = "获得神秘武功入神"
				isHavaSZJ = true
			end

			if isHavaSZJ == true then
				local Skill = require("app.models.skill.Skill")
				local szjSkill = role:getSkill(currSZJSkillID)
				if not szjSkill then
					szjSkill = {id = "shenzhaojing001", exp = 0}
				end
				local skill = Skill:getSkill(currSZJSkillID)
				local totalInt = role:getFinalAttr("currInt")
				local currLv = role:getSkillLv(currSZJSkillID, szjSkill.exp)
				local addLv = 80 + math.random(1, 2) * math.random(65, 130)
				local isShowLayer = false

				-- 1.5 * (200 + 总悟性) *潜能转化效率（potEfficiency）* (200+总悟性)/200
				if currLv + addLv >= role:getSkillLvLimit(currSZJSkillID) then
					if currSZJSkillID == "shenzhaojing001" then
						role:removeSkill("shenzhaojing001")
						showText = "神秘武功入神升级为坐照"
						isShowLayer = true
						role:addSkillLv("shenzhaojing002", 1)
						role:setDayFlag("benrichuangong", 1)
						role:setInheritFlag("chuangongcishu", role:getInheritFlag("chuangongcishu") + 1)
						map:doNoRoleResults(result.arg2, environment)
					elseif currSZJSkillID == "shenzhaojing002" then
						local name = Skill:getSkill("shenzhaojing003").name
						if role:getAttr("inheritCount") > 0 then
							local itemId = "szjdj2"
							local itemNum = 1
							HttpManagerEx:checkItemIsCanUse(
								itemId,
								itemNum,
								function(status, errcode, errmsg, data)
									if status == 200 then
										if errcode == 0 then
											role:removeSkill("shenzhaojing002")
											
											showText = "获得武功"..name
											role:addSkillLv("shenzhaojing003", 1)
											role:addItemCount("szjdj2", -1)
											role:setInheritFlag("szjwb", 1)
											role:setDayFlag("benrichuangong", 1)
											role:setInheritFlag("chuangongcishu", role:getInheritFlag("chuangongcishu") + 1)
											map:doNoRoleResults(result.arg3, environment)
											PopupLayerController:showLayer(
												"ShenZhaoChuanGongLayer",
												function(layer)
													layer:showLayer(2, showText)
												end
											)
											return true
										else
											PopText(errmsg)
										end
									else
										PopText(errmsg)
										return false
									end
								end,
								IS_SHOW_WAITING,
								HTTP_MANAGER_RETRY_TYPE_RETRY
							)
						else
							PopText("进阶"..name.."需要更高武学，请传承后再来!")
							role:addSkillLv("shenzhaojing002", addLv)
							role:setDayFlag("benrichuangong", 1)
							role:setInheritFlag("chuangongcishu", role:getInheritFlag("chuangongcishu") + 1)
							isShowLayer = true
						end
					end
				else
					role:addSkillLv(currSZJSkillID, addLv)
					showText = showText.. "武功" .. tostring(skill.name) .. "等级+" .. tostring(addLv)
					isShowLayer = true
					role:setDayFlag("benrichuangong", 1)
					role:setInheritFlag("chuangongcishu", role:getInheritFlag("chuangongcishu") + 1)
					map:doNoRoleResults(result.arg2, environment)
				end
				if isShowLayer == true then
					PopupLayerController:showLayer(
						"ShenZhaoChuanGongLayer",
						function(layer)
							layer:showLayer(1, showText)
						end
					)
				end
			end
		end
	end,

	--arg2 物品id arg3--有真物品操作  arg4 --假物品  arg5 --数量不足情况  arg6 需要数量
	["网络物品检测"] = function(map, result, environment)
 		local itemId = result.arg2
		local itemNum = Helper:getDef(result.arg6, 0) --需要数量
		local role = User:getRole()		
		local itemCount = role:getItemCount(itemId)
		
		if itemCount > itemNum then
			HttpManagerEx:detectionGoods(
			itemId,
			function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 and tonumber(data.numbers) > 0 then
						if tonumber(data.numbers) > itemNum then
							map:doNoRoleResults(result.arg3,environment)
						else
							map:doNoRoleResults(result.arg5,environment)
						end
					else
						map:doNoRoleResults(result.arg4,environment) 							
						print("errmsg", errmsg, "errcode", errcode)
					end
				else
					PopText(errmsg)
				end
			end,
			IS_SHOW_WAITING)
		else
			map:doNoRoleResults(result.arg5,environment) 
		end
	end,

	["网络物品消耗"] = function(map, result, environment)--arg2 物品id arg3--有真物品操作  arg4 --假物品  arg5 --无  arg6 --消耗物品数量
 		local renwuItemId=result.arg2
		local role=User:getRole()
		local itemNum = 1
		if result.arg6 ~= nil then
			itemNum = result.arg6
		end

		if role:getItem(renwuItemId)~=nil then 
			HttpManagerEx:checkItemIsCanUse(
			renwuItemId,
			itemNum,
			function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then
						print("正确")
						map:doNoRoleResults(result.arg3,environment) 
					else
						PopText(errmsg)
						map:doNoRoleResults(result.arg4,environment) 							
						print("errmsg", errmsg, "errcode", errcode)
					end
				else
					PopText(errmsg)
				end
			end,
			IS_SHOW_WAITING)
		else
			map:doNoRoleResults(result.arg5,environment) 
		end

	end,

	["多条文本输出"] = function(map, result, environment)
		local textStr = assert(result.arg2,"多条文本输出,参数二没有")
		local timeStr = assert(result.arg3,"多条文本输出,参数三没有")
		local tipStr = assert(result.arg4,"多条文本输出,参数四没有")
		local resultStr = assert(result.arg5,"多条文本输出,参数五没有")
		local textList = string.split(textStr,";")
		local timeList = string.split(timeStr,";")
		assert(#textList == #timeList,"文本个数与时间间隔个数不一致")
		local time = 0 

		--不能退出，移动以及不接受PVP邀请
		local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
		local mapLayer  = MainControllLayer:getLayer("MapLayer")
		mapRoleLayer:statusButtonFunc(false,function()
			PopText(tipStr)
		end)
		mapRoleLayer:exitButtonFunc(false,function()
			PopText(tipStr)
		end)
		mapLayer:setUnmoveRoom(true,function()
			PopText(tipStr)
		end)
		map:setCanLeave(false)
		User:getRole():setFlag("PVP活动状态","忙碌")
		for k,t in pairs(timeList) do 
			time = time + tonumber(t)
			mapLayer:delayFunc(time,function()
				if textList[k] then
					RichPrint("main",textList[k])
				end
				if k == # timeList then
					User:getRole():setFlag("PVP活动状态","空闲中")
					mapLayer:setUnmoveRoom(false)
					mapRoleLayer:statusButtonFunc(true)
					mapRoleLayer:exitButtonFunc(true)
					map:setCanLeave(true)
					map:doNoRoleResults(resultStr,environment)
				end
			end)
		end
	end,
	["阴阳交换"] = function(map, result, environment)
		local role = User:getRole()
		local npc = environment.currRole
		if role:isInCurrState(ROLE_CURR_STATE_LIANGONG) or role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
			RichPrint("main", "YEL"..npc.name.."：小友，阴阳替换本就处于九死一生，不能同时进行练功或闭关，还是准备好后再来寻我把。")
			return
		end

		if role:getSkillLv("changshengjueyin") > 0 or role:getSkillLv("changshengjueyang") > 0 then
			local currTime = GetTime()
			local lastTime = role:getFlag("阴阳交换时间")
			if type(tonumber(lastTime)) == "number" and (currTime - lastTime) > 172800 then
				local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
				local dialog = DialogALayer:getInstance()
				dialog:hide()
				dialog:show(npc.name.."：若要阴阳互换，需要逆转经脉，过程九死一生，但通过特定丹药护体方可保全，小友，准备好阴阳交替了吗？")
				dialog:setButton1("替换", function()
					dialog:hide()
					HttpManagerEx:getActionTimes("YinYangHuHuang",function(status, errcode, errmsg, data)
						if status == 200 then
							if errcode == 0 then
								if tonumber(data.num) == 0 then
									dialog:show(npc.name.."：小友，看在你我之缘，这枚丹药就当小老儿赠你，确定进行阴阳交替吗？")
								else
									dialog:show(npc.name.."：小友，看在你我之缘，我可再次帮你替换阴阳，但丹药制作费可要小友承担，本次需花费"..data.remove.."元宝，确定进行阴阳交替吗？")
									dialog:setRichText(npc.name.."：小友，看在你我之缘，我可再次帮你替换阴阳，但丹药制作费可要小友承担，本次RED需花费"..data.remove.."元宝NOR，确定进行阴阳交替吗？")
								end

								dialog:setButton1("确定", function()
									HttpManagerEx:submitAction("YinYangHuHuang",1,function(status, errcode, errmsg, data)
										if status == 200 then
											if errcode == 0 then
												local text = {}
												if role:getSkillLv("changshengjueyin") > 0 and role:getSkillLv("changshengjueyang") == 0 then
													role:addSkillExp("changshengjueyang", role:getSkillExp("changshengjueyin"))
													role:removeSkill("changshengjueyin")
													text = {
														npc.name.."从腰间取出一个巴掌大小的锦盒，未等你看清就从中取出了一颗丹药送入了你的口中。",
														"丹药入口，肺腑之间横生出一股暖流，随后"..npc.name.."迅速拂过膻中至关元几个穴位，促使丹药催发之气周护心脉。",
														"以阴逆阳本不顺万物之道，如由死复生，"..npc.name.."初将功力注入时，你只觉全身气力尽数抽干，一呼一吸间如扼脖颈，顿生胸闷。",
														npc.name.."早知阴阳逆转当有此种苦楚，见你面色发胀已在生死一刻，双指迅速拂过大包一穴。一股气息重新灌入体内，犹获新生。",
													}
												elseif role:getSkillLv("changshengjueyang") > 0 and role:getSkillLv("changshengjueyin") == 0 then
													role:addSkillExp("changshengjueyin", role:getSkillExp("changshengjueyang"))
													role:removeSkill("changshengjueyang")
													text = {
														npc.name.."从腰间取出一个巴掌大小的锦盒，未等你看清就从中取出了一颗丹药送入了你的口中。",
														"丹药不知是何所制，在"..npc.name.."拂击大杼至命门时如寒冰流窜，刺骨刺穴，当下让你动弹不得。",
														"以阳变阴，似即置生于死，虽顺和阴阳之道，虚死实生。",
														npc.name.."一边运功加助冰寒之力，一边又迅速催动气息与之相撞，冰寒火热间如剔去一根根经脉重塑，引得头痛难忍。",
														"直至阳息退却，"..npc.name.."方收回功力，拂向神庭，气脉既平，疼痛减缓，才发现眼前昏花处渐渐清晰起来。"
													}
												else
													print("此处有bug")
													return
												end
												
												role:setFlag("阴阳交换时间",GetTime())

												PopupLayerController:showLayer(
													"GlobalShadeLayer",
													function(layer)
														layer:showLayer()
														layer:setPopText("此时无法动弹。")
													end
												)



												local TIME = 2

												local i = 1
												map:setSchedule(function (tag)
													RichPrint("main", text[i])
													if i == #text then
														RichPrint("main", "YEL"..npc.name.."：少侠阴阳交替已成，你可以尝试调动内力查看一二。")
														PopupLayerController:hideLayer(
															"GlobalShadeLayer",
															function(layer)
																layer:hideLayer()
															end
														)
													end
													i = i + 1
												end,2,0,#text)
											else
												PopText(errmsg)
												print(errcode,errmsg)
											end
										else
											PopText(errmsg)
										end
									end, IS_SHOW_WAITING)
								end)
								dialog:setButton2("取消", function()
							end)
							dialog:setWeChatVisible(false)

							else
								PopText(errmsg)
							end
						end
					end,
					IS_SHOW_WAITING)
				end)
				dialog:setButton2("算了", function()
					RichPrint("main","YEL"..npc.name.."：无妨，如想进行阴阳交替寻我便可。")
				end)
				dialog:setWeChatVisible(false)
			else
				local cdTime = lastTime + 172800 - currTime
				local hour, min,sec = Helper:sec2timeDsc(cdTime)
                local text = hour.."小时"..min.."分钟"..sec.."秒"
				RichPrint("main","YEL"..npc.name.."：小友，这阴阳替换可不能过于频繁，如要再次替换，需待"..text.."才可。")
			end
		else
			RichPrint("main","YEL"..npc.name.."：小友，若机缘碰巧你研习了长生诀想进行阴阳替换时来寻我，老夫自当助你一力。")
		end
	end,

	["洗髓加点"] = function(map, result, environment)
		local AttrPointRemovePresenters = require("app.presenters.AttrPointRemove.AttrPointRemovePresenters"):create()
		local AttrPointRemoveLayer = PopupLayerController:getLayer("AttrPointRemoveLayer")
		local AttrPointRemove = require("app.models.AttrPointRemove.AttrPointRemove")
		AttrPointRemovePresenters:setDataModel(AttrPointRemove)
		AttrPointRemovePresenters:setViewModel(AttrPointRemoveLayer)
		AttrPointRemovePresenters:setRole(User:getRole())
		AttrPointRemovePresenters:showLayer()
	end,

	["拜师"] = function(map, result, environment)
		local player = User:getRole()
        local teacher = Npc:getNpc(result.arg2)
		local confirmStrs = result.arg3
		local cancelStrs = result.arg4

		if player:hasFamily() then
			player:obApprentice(teacher)
		else
			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			local dialog = DialogALayer:getInstance()

			dialog:hide()
			dialog:show(
				"你确定要加入【" .. teacher:getFamilyName() .. "】吗?\n拜入【" .. teacher:getFamilyName() .. "】将无法拜入其他门派。",
				"师父: " .. teacher.name
			)
			dialog:setButton1(
				"决定了",
				function()
					player:obApprentice(teacher)
					map:doNoRoleResults(confirmStrs, environment)
				end
			)

			dialog:setButton2(
				"再想想",
				function()
					dialog:hide()
					map:doNoRoleResults(cancelStrs, environment)
				end
			)
			dialog:setWeChatVisible(false)
		end
    end,

    ["称号判断"] = function(map, result, environment)
        local role = User:getRole()
        local basicTitleId = result.arg2
        if not basicTitleId then
        	print("策划配置有问题 ","result.arg2:",result.arg2)
        end
        if role:hasBasicTitle(basicTitleId) then 
        	map:doNoRoleResults(result.arg3,environment)
        else
        	map:doNoRoleResults(result.arg4,environment)
        end
    end,

    ["多送礼条件结果"] = function(map, result, environment) --礼物为多个物品
    	if not result.arg2 then 
    		print("多送礼条件结果 result.arg2 为空")
    	end
	    local requireList = string.split(Helper:getDef(result.arg2, "") ,";")
		local role = User:getRole()
		
	    local isSuc = true
		for i,v in ipairs(requireList) do
		    local itemInfo = string.split(v ,",")
			if  itemInfo[1] == nil or itemInfo[2] == nil then
				print("多送礼条件结果 配置格式不对")
				return
			end
			local itemAttr = Item:getOneItemByKey(itemInfo[1])
			if itemAttr == nil then
				print("多送礼条件结果 物品不存在",itemInfo[1])
				return
			end
			local count = 0
			if itemAttr.type == "淬炼材料" or itemAttr.type == "锻造材料" then
				count = role:getSmeltBoxItemCount(itemInfo[1])
			else
				count = role:getItemCount(itemInfo[1])
			end
			if count < tonumber(itemInfo[2])  then
				isSuc = false
				break
			end	
		end

		if isSuc then 
			for i,v in ipairs(requireList) do
			    local itemInfo = string.split(v ,",")
				role:addItemCount(itemInfo[1] ,- tonumber(itemInfo[2]))
			end
			map:doNoRoleResults(result.arg3,environment)
		else
			map:doNoRoleResults(result.arg4,environment)
		end
	end,

	["副本休息"] = function(map, result, environment)
		local currXiangLuId = result.arg2 --香炉id
		local currXiangId = result.arg3--当前燃香id
		local bedValue =result.arg4 --当前床恢复精力值
		local XiangLuModel = require("app.models.HomelandModel.XiangLuModel")
        XiangLuModel:bedRestFun(bedValue,currXiangLuId,currXiangId)
	end,

	["副本疲倦值文本提示"] = function(map, result, environment)
		local role = User:getRole() 
		local pijuan = role:getAttr("pijuan")
		local pijuanLevelDesc = {
			[1] = "你此时只觉精神饱满，浑身上下有着用不完的力气。",  --大于0，小于80
			[2] = "你打了个哈欠，眨了眨干涩的眼睛，不由感觉到了一丝疲倦。", --大于等于80，小于160
			[3] = "你长长地打了个哈欠，又伸了一个懒腰，只觉倦意如潮水般向你涌来。", --大于等于160，小于等于200
		}

		local pijuanLevel = 1
		if pijuan >= 160 then
			pijuanLevel = 3
		elseif pijuan >= 80 then 
			pijuanLevel = 2
		end

		RichPrint("main", pijuanLevelDesc[pijuanLevel])
	end,

	["梦境前置完成"] = function(map, result, environment)
		--arg1 梦境前置完成 arg2 副本ID arg3 房间ID
		local role = User:getRole()
		local mid,roomId = role:getHouseId()
		local userId = User:getUserId()

		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()

		local function entryUserMap()
			local UserMap = require("app.models.map.UserMap")
			UserMap:getUserMap(mid, userid, function(map,isSuccess)
				if isSuccess == false then
					return
				end
				map._isComingIn = true

				local titleLayer = MainControllLayer:getLayer("TitleLayer")
				local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
				mapRoleLayer:onResume()
				titleLayer:hide(true)

				dialog:delayFunc(1,
				function(obj)
					map:setCallBackAndConnect(function()
						local mapLayer = MainControllLayer:getLayer("MapLayer")
						mapLayer:setMap(map)
						local roomId = map.entryDreamDefaultlRoom		
						MainControllLayer:pushLayer("MapLayer")
						mapLayer:teleportRoom(roomId)
						MessageCenter:notify("EnterMap",{map=map})
					end)
				end)
			end)
		end

		local function entryOtherMap()
			dialog:delayFunc(0.1, function()			
				local map = role:getMapById(mid)

				local lastTime = role:getFlag(map.id)
				if map._isComingIn == true and lastTime ~= 0 and GetTime() - lastTime < MAP_REFRESH_INTERVAL then 
				else
					map = role:initMapById(map.id)
					map._isComingIn = true
				end

				map:setCallBackAndConnect(function()
					local mapLayer = MainControllLayer:getLayer("MapLayer")
					mapLayer:setMap(map)
					mapLayer:teleportRoom(roomId)
					mapLayer.ControllLayer:pushLayer("MapLayer")
				end)
			end)
		end

		if mid == nil then 
			mid = result.arg2
			roomId = result.arg3
			entryOtherMap()
		else
			entryUserMap()
		end

	end,

	["周公之术突破"] = function(map, result, environment)
		local role = User:getRole()
		local success = role:breakZhouGongZhiShuLvLimit()
		if success then
			map:doNoRoleResults(result.arg2, environment)
		else
			map:doNoRoleResults(result.arg3, environment)
		end
	end,


	["领取梦境丢失武学"] = function(map,result,environment)
  
        HttpManagerEx:getDreamRewardSkill(function(status, errcode, errmsg, data)
			if status == 200 and errcode == 0 then
                if data and MapIsEmpty(data) == false then
					local role = map:getPlayer()
					local IsReceive = false
                    local successReceive = result.arg2

                    for k, skillId in pairs(data) do
							if role:getSkill(skillId) then 

                            else
								role:addSkillExp(skillId,1)
								IsReceive = true
                            end
					end
					if IsReceive == true then
						map:doNoRoleResults(successReceive, environment)
					else
						local noLossSkill = result.arg3
						map:doNoRoleResults(noLossSkill, environment)  
					end	
				else
					local noLossSkill = result.arg3
					map:doNoRoleResults(noLossSkill, environment)  
                end
            else
                PopText(errmsg)
            end
        end, IS_SHOW_WAITING)
	end,
	["碧云心法转换成手心劫"] = function(map, result, environment)
        local succResult = result.arg2
		local failedResult = result.arg3
        local role = User:getRole()
        local skillExp = role:getSkillExp("biyunxinfa")
        local canye1 = role:getZhaoShuXiang("biluohuangquancanye")
        local canye2 = role:getZhaoShuXiang("yunqilongxiangcanye")

        if skillExp <= 0 then
            PopText("你未学习碧云心法，无需进修。")
            map:doNoRoleResults(failedResult, environment)
            return
        end

		local maxExp = role:conversionSkillExpAndLv("exp", role:getLv())
        local addExp = Helper:getRange(math.min(skillExp,  maxExp - role:getSkillExp("shouxinjie")), 0)
        
        role:addSkillExp("shouxinjie", addExp)
        role:addSkillZhaoExp("xinzhongci",role:getSkillZhaoExp("biluohuangquan"))
        role:addSkillZhaoExp("zhijiansha",role:getSkillZhaoExp("yunqilongxiang"))
        if canye1 ~= nil and canye1.count >= 0 then
            role:addItemCount("xinzhongcicanye",canye1.count)
            PopText("获得"..role:getOneItemByKey("xinzhongcicanye").name.."X"..tostring(canye1.count))
        end

        if canye2 ~= nil and canye2.count >= 0 then
            role:addItemCount("zhijianshacanye",canye2.count)
            PopText("获得"..role:getOneItemByKey("zhijianshacanye").name.."X"..tostring(canye2.count))
		end
		
        map:doNoRoleResults(succResult, environment)
	end,
	["梦呓商人"] = function(map, result, environment)
        PopupLayerController:showLayer("DreamStoreLayer", function(layer)
			layer:showLayer()
		end)
    end,

	["答题系统"] = function(map, result, environment)
        local activity_id  = result.arg2
		if not activity_id then
			print("------------答题系统:活动id未配置")
			return
		end

		PopupLayerController:showLayer("QuestionAndAnswerPresenters",function(layer)
			layer:setActionId(activity_id)
			layer:showLayer()
		end)
    end,

	["传承武学记录"] = function(map, result, environment)
		PopupLayerController:showLayer("recordAndLearnSKillsPresenters",function(layer)
			layer:showLayer(1)
		end)
    end,

	["传承武学放入"] = function(map, result, environment)
		-- PopupLayerController:showLayer("recordAndLearnSKillsPresenters",function(layer)
		-- 	layer:showLayer(2)
		-- end)
    end,

	["传承武学学习"] = function(map, result, environment)
		PopupLayerController:showLayer("recordAndLearnSKillsPresenters",function(layer)
			layer:showLayer(2)
		end)
    end,
	["观摩棋局"] = function(map, result, environment)
		local function checkFondDrIsOpen()
			if Game:isTesting() == true then
				return true
			end
			
			if Game:getVersion() == "1.13.0" or Game:getVersion() == "1.13.1" or Game:getVersion() == "1.7" then
				return false
			end
			return true
		end

		if checkFondDrIsOpen() == false then
			PopText("此功能尚未开启，会在后续更新中开放。")
			return 
		end

		local function getFondDreamRoleData()
			local drSystem = require("app.models.FondDream.FondDreamSystem"):create(User:getRole())
			HttpManagerEx:getFondDreamRoleData(
				function(status, errcode, errmsg, data)
					if status == 200 then
						if errcode == 0 then
							MainControllLayer:getLayer("PrintLayer"):initRichText()
							
							--@desc 有数据，接上次数据继续未完梦境
							local role = drSystem:createDreamRoleWithData(data)
							local floorNum = role.dreamWorld.cFloor
							PopupLayerController:showLayer(
								"DreamEntryLayer",
								function(layer)
									layer:showLayer(MAP_TYPE.FONDDREAMMAP,
										function()
											drSystem:enterMap(floorNum, role)
										end
									)
								end
							)
							return true
						elseif errcode == 2 then
							PopupLayerController:showLayer("ChessboardLayer",
								function(layer)
									layer:showLayer()
								end
							)
							return true
						elseif errcode == 3 then
							PopText(errmsg)
							return true
						else
							PopText(errmsg)
							return false
						end
					else
						PopText(errmsg)
						return false
					end
				end,
				IS_SHOW_WAITING,
				HTTP_MANAGER_RETRY_TYPE_RETRY
			)
		end
		
		HttpManagerEx:checkFondDreamRoleDataIsOverdue(User:getRole():getTrimData(),
		function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					RichPrint("main","本次刷新前没继续棋局闯荡，现对上次棋局玩法进行奖励结算：")
					RewardManager2:receiveRewardIsOverdue(data.reward,User:getRole(),User:getRole():getCurrMap())
				elseif errcode == 2 then
					getFondDreamRoleData()
				elseif errcode == -2 then
					getFondDreamRoleData()
				else
					PopText(errmsg)
				end
			end
		end, IS_SHOW_WAITING)
    end,

	["手艺人剧情文本输出"] = function(map, result, environment)
        if type(result.arg2) ~= "string" or result.arg2 == "" then
            print("手艺人剧情文本输出 格式不对或为空")
            return
        end

        local role = User:getRole()
        local name = role:getFlag("21手艺人手艺人剧情名字")

        if string.find(result.arg2,";") == nil then
            local str = string.gsub( result.arg2, "$name", name)
            RichPrint("main", str)
            return
        end

        local text = string.split(result.arg2,";")
        
        local delay = 0.2

        for i, str in pairs(text) do
            str = string.gsub( str, "$name", name)

			environment.mapLayer:delayFunc(delay, function()
				RichPrint("main", str)
			end)

			delay = delay + 0.2
		end
    end,

	["墨璃珠奖励领取"] = function(map, result, environment)
        local num = result.arg2
		local addType = result.arg3

		if type(num) ~= "number" or num <= 0 then
			assert(false,"墨璃珠奖励领取 arg2 值错误"..tostring(num))
			return
		end

		local role = User:getRole()

        HttpManagerEx:addCurrencyNumber({["molizhu"] = num },addType,nil, function(status, errcode, errmsg, data)
			if 200 == status and 0 == errcode then
				if MapIsEmpty(data.currency) == false then
					for currency,valueData in pairs(data.currency) do
						if valueData.value > 0 then 
							PopText("获得"..tostring(valueData.value)..role:getCHAttrName(currency))
						end
						if valueData.desc ~= nil and valueData.desc ~= ""  then
							PopText(valueData.desc)
						end
					end
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
    end,

	["手艺人奖励补领"] = function(map, result, environment)
		local role = User:getRole()
		local shouyirenStart = role:getInheritFlag("shouyiren_start")

		if shouyirenStart == 999 then
			RichPrint("main", "秦高松：少侠，老夫已为你推算过了，不可再算。")
			return 
		end

		local config = {	--补领规则
			[0] = 0,
			[1] = 20,
			[2] = 40,
			[3] = 60,
			[4] = 80,
			[5] = 100,
		}
        local num = config[shouyirenStart]
		local addType = "workmanship_replace"

		if type(num) ~= "number" or num <= 0 then
			RichPrint("main", "秦高松：老夫现在还不能少侠推算，时机未到，时机未到。")
			return
		end

        HttpManagerEx:addCurrencyNumber({["molizhu"] = num },addType,nil, function(status, errcode, errmsg, data)
			if 200 == status and 0 == errcode then
				if MapIsEmpty(data.currency) == false then
					for currency,valueData in pairs(data.currency) do
						if valueData.value > 0 then 
							PopText("获得"..tostring(valueData.value)..role:getCHAttrName(currency))
						end
						if valueData.desc ~= nil and valueData.desc ~= ""  then
							PopText(valueData.desc)
						end
					end
				end

				--设置999为已领取值
				role:setInheritFlag("shouyiren_start",999)
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
    end,

	["特殊事件记录"] =function(map, result, environment)
		--arg1特殊事件记录  arg2 事件id  arg3 事件参数
        local eventType = result.arg2
		local eventParam = result.arg3

		if eventType then
			local eventRecord = require("app.models.eventRecord.EventRecord")
			eventRecord:recordEvent(eventType,eventParam)
		end
    end,

	["武学上限突破奖励"] = function(map, result, environment)
        HttpManagerEx:martialUpgradeAddCurrency(User:getRole():getCurrencyVersion(), 1, function(status, errcode, errmsg, data)
			if 200 == status and 0 == errcode then
				if MapIsEmpty(data.reward) == false then
					for __,rewardInfo in pairs(data.reward) do
						if rewardInfo.num > 0 then
							PopText("获得"..tostring(rewardInfo.name).."X"..tostring(rewardInfo.num))
						end
					end
				end

				if data.currencyVersion then
					User:getRole():setCurrencyVersion(data.currencyVersion)
				end

				if data.msg then
					PopText(data.msg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
    end,
	
	["续卷商人"] = function(map, result, environment)
		local npc = environment.currRole
		local name = npc.name
		PopupLayerController:showLayer("XuJuanStorePresent",function(layer)
			layer:showLayer()
			layer:setNpcName(name)
		end)
    end,

	["网络物品兑换网络物品"] = function(map, result, environment)
		if not result.arg2 then
			print("---网络物品兑换网络物品 result.arg2 有误")
			return
		end

		if not result.arg3 then
			print("---网络物品兑换网络物品 result.arg3 有误")
			return
		end

		local role = map:getPlayer()
		local exchangeInfo = string.split(result.arg2, ",")
		local targetInfo = string.split(result.arg3, ",")
		local targetItemId, targetItemNum = targetInfo[1], tonumber(targetInfo[2])  --目标物品Id
		local exchangeItemId, exchangeItemNum = exchangeInfo[1], tonumber(exchangeInfo[2])
		local button_confirm_name = "兑换" --确定按钮名字
		local button_close_name = "不了"   --取消按钮名字
		local itemData = role:getOneItemByKey(targetItemId)
		local exchange_itemName = role:getOneItemByKey(exchangeItemId).name

		local textList = {
		Text_tital = itemData.name,
		Text_type = itemData:getItemShowType(),
		Text_dsc = itemData.dsc,
		Text_price = "兑换需要："..exchange_itemName.. "X".. exchangeItemNum,
		Text_affirm = "RAN确定兑换"..itemData.name.. "X".. targetItemNum.."吗？",
		}

		local function confirmBtnFunc()
			if role:getItemCount(exchangeItemId) < exchangeItemNum then
				map:doNoRoleResults(result.arg5, environment)
				return
			end

			local exchangeItems = {{id = exchangeItemId, num = exchangeItemNum}}
			local targetItems = {{id = targetItemId, num = targetItemNum}}
	
			if role:checkCanBuyTwoOrMoreThings({[targetItemId] = targetItemNum},true) then
				if MapIsEmpty(exchangeItems) == false and MapIsEmpty(targetItems) == false then
					HttpManagerEx:specialItemExchange(exchangeItems,targetItems,function(status, errcode, errmsg, data)
						if status == 200 then
							if errcode == 0 then
								role:addItemCount(exchangeItemId, -exchangeItemNum)

								Helper:print_lua_table(data.targetItems)
		
								for index, itemInfo in ipairs(data.targetItems) do
									role:addItemCount(itemInfo.id, itemInfo.num)
									local itemAttr = role:getOneItemByKey(itemInfo.id)
									PopText("获得"..itemAttr.name.."X"..itemInfo.num)
								end
	
								map:doNoRoleResults(result.arg4, environment)
							elseif errcode == 1 then --非法
								map:doNoRoleResults(result.arg5, environment)
							elseif errcode == 2 then --达到上限
								map:doNoRoleResults(result.arg6, environment)
							end
						else
							PopText(errmsg)
						end
					end,IS_SHOW_WAITING)
				else
					print("数据异常")
				end
			end
		end

		PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
			layer:showLayer(textList,function()
			end)
			layer:setButton_confirm(button_confirm_name, function()
				confirmBtnFunc()
			end)
			layer:setButton_close(button_close_name, function()
				map:doNoRoleResults(result.arg5, environment)
			end)
		end)
	end,

	["网络物品兑换普通物品"] = function(map, result, environment)
		if not result.arg2 then
			print("---网络物品兑换普通物品 result.arg2 有误")
			return
		end

		if not result.arg3 then
			print("---网络物品兑换普通物品 result.arg3 有误")
			return
		end

		local role = map:getPlayer()
		local exchangeLimit = result.arg7 --兑换上限
		local exchangeInfo = string.split(result.arg2, ",")
		local targetInfo = string.split(result.arg3, ",")
		local targetItemId, targetItemNum = targetInfo[1], tonumber(targetInfo[2])  --目标物品Id
		local exchangeItemId, exchangeItemNum = exchangeInfo[1], tonumber(exchangeInfo[2])
		local exchangeNum = role:getInheritFlag("tianjiling_"..targetItemId)

		if exchangeLimit and exchangeNum >= exchangeLimit then
			map:doNoRoleResults(result.arg6, environment)
			return
		end

		local button_confirm_name = "兑换" --确定按钮名字
		local button_close_name = "不了"   --取消按钮名字
		local itemData = role:getOneItemByKey(targetItemId)
		local exchange_itemName = role:getOneItemByKey(exchangeItemId).name

		local textList = {
		Text_tital = itemData.name,
		Text_type = itemData:getItemShowType(),
		Text_dsc = itemData.dsc,
		Text_price = "兑换需要："..exchange_itemName.. "X".. exchangeItemNum,
		Text_affirm = "RAN确定兑换"..itemData.name.. "X".. targetItemNum.."吗？",
		}

		local function confirmBtnFunc()
			if role:getItemCount(exchangeItemId) < exchangeItemNum then
				map:doNoRoleResults(result.arg5, environment)
				return
			end
	
			if role:checkCanBuyTwoOrMoreThings({[targetItemId] = targetItemNum},true) then
				HttpManagerEx:checkItemIsCanUse(
                        exchangeItemId, exchangeItemNum,
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
									role:addItemCount(exchangeItemId, -exchangeItemNum)
									role:addItemCount(targetItemId, targetItemNum)
									PopText("获得"..itemData.name.."X"..targetItemNum)
									role:setInheritFlag("tianjiling_"..targetItemId, exchangeNum + 1)
	
									map:doNoRoleResults(result.arg4, environment)
                                else
                                    map:doNoRoleResults(result.arg5, environment)
                                end
                            else
                                PopText(errmsg)
                            end
                        end,
                IS_SHOW_WAITING)
			end
		end

		PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
			layer:showLayer(textList,function()
			end)
			layer:setButton_confirm(button_confirm_name, function()
				confirmBtnFunc()
			end)
			layer:setButton_close(button_close_name, function()
				map:doNoRoleResults(result.arg5, environment)
			end)
		end)
	end,
	
	["完成拳脚系统前置任务"] = function(map, result, environment)
		local results = result.arg2
		local player = User:getRole()
		player:getFistFootSystem():createFistInfo(function(isOk,msg)
			if isOk then
				map:doNoRoleResults(results, environment)
			else
				PopText(msg)
			end
			
		end)
	end,
	["更新拳脚系统标记"] = function(map, result, environment)
		local addFlags = string.split(result.arg2,";") --添加标记列表
		local deleteFlags = string.split(result.arg3,";") --删除标记列表
		local results = result.arg4

		local player = User:getRole()
		
		player:getFistFootSystem():updataFistFlag(
			addFlags,
			deleteFlags,	
			function(isOk,msg)
				if isOk then
					map:doNoRoleResults(results, environment)
				else
					PopText(msg)
				end
			end
		)
		
	end,
	["更新师门日常标记"] = function(map, result, environment)
		local addFlags = string.split(result.arg2,";") --添加标记列表
		local deleteFlags = string.split(result.arg3,";") --删除标记列表
		local results = result.arg4

		local player = User:getRole()
		
		player:getTeacherBuildSystem():updataTeacherBuildFlag(
			addFlags,
			deleteFlags,	
			function(isOk,msg)
				if isOk then
					map:doNoRoleResults(results, environment)
				else
					PopText(msg)
				end
			end
		)
		
	end,
	["散人提升门外武学准备条件"] = function(map, result, environment)
		local player = User:getRole()

		if not player:isYouXia() then
			PopText("你并非散人，无缘传授你相应功法")
			return
		end

		HttpManagerEx:getYouXiaMcmrestrictUpgradeCondition(
			player:getFamilyId(),
			player:getCurrencyVersion(),
			function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then
						local mcmrestrictLevel = require("script.others.mcmrestrictLevel")["1"]

						local mcmrestrictId = data.id

						local mcmrestrictData = mcmrestrictLevel[tostring(mcmrestrictId)]
						
						if mcmrestrictData == nil then
							PopText("散人升级心法数据异常")
							return	
						end

						local count = mcmrestrictData.count

						local mcmrestrictLv = mcmrestrictData.mcmrestrict
						
						local unlockcondition = mcmrestrictData.unlockcondition

						local unlockconditionText = ""

						for i,v in ipairs(unlockcondition) do
							local itemId = v[1]
							
							local itemCount = v[2]

							unlockconditionText = unlockconditionText..itemCount.."点"..Role:getCHAttrName(itemId).."，"
						end

						local showText = "需要消耗"..unlockconditionText.."即可掌握使用需要门派心法"..mcmrestrictLv.."级的武学，掌握后同时只能装备"..count.."门符合条件的武学。少侠是否需要学习？"

						local dialog = require("app.views.layer.DialogLayer.DialogALayer"):getInstance()
						dialog:hide()
						dialog:show(showText)
						dialog:setButton1("确定",function()
							HttpManagerEx:youxiaUpgradeMcmrestrict(
								player:getFamilyId(), player:getCurrencyVersion(),
								function(status, errcode, errmsg, data)
									if status == 200 then
										if errcode == 0 then
											local mcmrestrictId = data.id

											player:setAttr("mcmrestrictId", mcmrestrictId)

											if data.currencyVersion then
												player:setCurrencyVersion(data.currencyVersion)
											end

											PopText("已掌握"..count.."门"..mcmrestrictLv.."等级心法需求的武学使用方式")
										else
											PopText(errmsg)
										end
									else
										PopText(errmsg)
									end
									return true
								end,
							IS_SHOW_WAITING)
						end)
						dialog:setButton2("取消",function ()
						end)

						dialog:setWeChatVisible(false)
					else
						PopText(errmsg)
					end
				else
					PopText(errmsg)
				end
				return true
			end,
		IS_SHOW_WAITING)
	end,
	
	["武学进阶"] = function(map, result, environment)
		local player = User:getRole()

		PopupLayerController:showLayer("SkillUpgradePresent", function(layer)
			layer:showLayer(player,environment.currRole.name)
		end)
	end,
	["兑换妙法秘录补丁20250123"] = function (map,result,environment)
		--@desc 线上修复bug【1006746】, 只仅限于这次修复，后续不再使用
		local exchangeInfo = string.split(result.arg2, ",")

		local exchangeItemId, exchangeItemNum = exchangeInfo[1], tonumber(exchangeInfo[2])
		
		local role = map:getPlayer()

		local targetItemId = "wxtranstwxplus"

		local targetItemNum = 1

		local inheritFlag = "tianjiling_" .. targetItemId

		local flagValue = role:getInheritFlag(inheritFlag)

		local __doChange = function()
			local itemData = role:getOneItemByKey(targetItemId)

			local function confirmBtnFunc()
				if role:getItemCount(exchangeItemId) < exchangeItemNum then
					map:doNoRoleResults(result.arg4, environment)
					return
				end

				if role:checkCanBuyTwoOrMoreThings({[targetItemId] = targetItemNum}, true) then
					HttpManagerEx:checkItemIsCanUse(
						exchangeItemId,
						exchangeItemNum,
						function(status, errcode, errmsg, data)
							if status == 200 then
								if errcode == 0 then
									role:addItemCount(exchangeItemId, -exchangeItemNum)
									role:addItemCount(targetItemId, targetItemNum)

									PopText("获得" .. itemData.name .. "X" .. targetItemNum)

									if flagValue == 0 then
										role:setInheritFlag(inheritFlag, 1)
									end

									local Record = require("app.models.Record.Record")
									Record:submitLog()

									map:doNoRoleResults(result.arg3, environment)
								else
									map:doNoRoleResults(result.arg4, environment)
								end
							else
								PopText(errmsg)
							end
						end,
						IS_SHOW_WAITING
					)
				end
			end

			local button_confirm_name = "兑换" --确定按钮名字

			local button_close_name = "不了" --取消按钮名字

			local exchange_itemName = role:getOneItemByKey(exchangeItemId).name

			local textList = {
				Text_tital = itemData.name,
				Text_type = itemData:getItemShowType(),
				Text_dsc = itemData.dsc,
				Text_price = "兑换需要：" .. exchange_itemName .. "X" .. exchangeItemNum,
				Text_affirm = "RAN确定兑换" .. itemData.name .. "X" .. targetItemNum .. "吗？"
			}

			PopupLayerController:showLayer(
				"ShoppingDialogLayer",
				function(layer)
					layer:showLayer(
						textList,
						function()
						end
					)
					layer:setButton_confirm(
						button_confirm_name,
						function()
							confirmBtnFunc()
						end
					)
					layer:setButton_close(
						button_close_name,
						function()
							map:doNoRoleResults(result.arg4, environment)
						end
					)
				end
			)
		end

		if flagValue == 0 then
			__doChange()
		elseif flagValue == 1 then
			local isHased = false
			HttpManagerEx:getwxtranstwxplushasGainAfter202501231500(
				function(status, errcode, errmsg, data)
					if status == 200 then
						if errcode == 1 then
							__doChange()
						elseif errcode == 0 then
							map:doNoRoleResults(result.arg5, environment)
						end
					else
						PopText(errmsg)
					end
				end,
				IS_SHOW_WAITING
			)
		else
			PopText("兑换次数据异常")
		end
	end
}

CommonResults.doResult["躲避高级暗器"] =CommonResults.doResult["躲避暗器"]
CommonResults.doResult["停止计时"] = CommonResults.doResult["追踪计时停止"]

CommonResults.doResult["网络物品兑换普通物品周期限制"] = function(map, result, environment)
	if not result.arg2 then
		print("---网络物品兑换普通物品周期限制 result.arg2 有误")
		return
	end

	if not result.arg3 then
		print("---网络物品兑换普通物品周期限制 result.arg3 有误")
		return
	end

	local role = map:getPlayer()
	local exchangeInfo = string.split(result.arg2, ",") -- 消耗的物品
	local exchangeItemId, exchangeItemNum = exchangeInfo[1], tonumber(exchangeInfo[2]) 

	local targetInfo = string.split(result.arg3, ",")
	local targetItemId, targetItemNum = targetInfo[1], tonumber(targetInfo[2])  --目标物品Id

	local periodLimittaginfo
	local periodLimitTag
	local periodLimitNum
	if result.arg4 then
		periodLimittaginfo = string.split(result.arg4, ",") --周期限制的标识和次数
		periodLimitTag = periodLimittaginfo[1] --周期限制的标识
		periodLimitNum = tonumber(periodLimittaginfo[2]) --周期限制的次数
	end

	local periodcount = nil
	if periodLimitTag then
		periodcount = role:getInheritTimeStatusTags(periodLimitTag)
		if periodcount < 0 then
			role:setInheritTimeStatusTags(periodLimitTag, 0)
			periodcount = 0
		end
		if periodcount >= periodLimitNum then
			map:doNoRoleResults(result.arg8, environment)
			return 
		end
	end
	
	local totalLimitexchangcountInfo
	local totalLimitTag
	local totalLimitNum
	if result.arg5 then
		totalLimitexchangcountInfo = string.split(result.arg5, ",") --总的限制的标识和次数
		totalLimitTag = totalLimitexchangcountInfo[1] --总的限制的标识
		totalLimitNum = tonumber(totalLimitexchangcountInfo[2]) --总的限制的次数
	end

	local totalcount = nil
	if totalLimitTag then
		totalcount = role:getInheritRoleStatusTags(totalLimitTag)
		if totalcount < 0 then
			role:setInheritRoleStatusTags(totalLimitTag, 0)
			totalcount = 0
		end
		if totalcount >= totalLimitNum then
			map:doNoRoleResults(result.arg8, environment)
			return 
		end
	end


	local button_confirm_name = "兑换" --确定按钮名字
	local button_close_name = "不了"   --取消按钮名字
	local itemData = role:getOneItemByKey(targetItemId)
	local exchange_itemName = role:getOneItemByKey(exchangeItemId).name

	local textList = {
	Text_tital = itemData.name,
	Text_type = itemData:getItemShowType(),
	Text_dsc = itemData.dsc,
	Text_price = "兑换需要："..exchange_itemName.. "X".. exchangeItemNum,
	Text_affirm = "RAN确定兑换"..itemData.name.. "X".. targetItemNum.."吗？",
	}

	local function confirmBtnFunc()
		if role:getItemCount(exchangeItemId) < exchangeItemNum then
			map:doNoRoleResults(result.arg7, environment)
			return
		end

		if role:checkCanBuyTwoOrMoreThings({[targetItemId] = targetItemNum},true) then
			HttpManagerEx:checkItemIsCanUse(
					exchangeItemId, exchangeItemNum,
					function(status, errcode, errmsg, data)
						if status == 200 then
							if errcode == 0 then
								role:addItemCount(exchangeItemId, -exchangeItemNum)
								role:addItemCount(targetItemId, targetItemNum)
								PopText("获得"..itemData.name.."X"..targetItemNum)

								if periodcount then
									role:setInheritTimeStatusTags(periodLimitTag, periodcount + 1)
								end

								if totalcount then
									role:setInheritRoleStatusTags(totalLimitTag, totalcount + 1)
								end

								map:doNoRoleResults(result.arg6, environment)
							else
								map:doNoRoleResults(result.arg7, environment)
							end
						else
							PopText(errmsg)
						end
					end,
			IS_SHOW_WAITING)
		end
	end

	PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
		layer:showLayer(textList,function()
		end)
		layer:setButton_confirm(button_confirm_name, function()
			confirmBtnFunc()
		end)
		layer:setButton_close(button_close_name, function()
			map:doNoRoleResults(result.arg7, environment)
		end)
	end)


end

CommonResults.doResult["妙法密录兑换限制20250930补丁"] = function(map, result, environment)
	if not result.arg2 then
		print("---妙法密录兑换限制20250930补丁 result.arg2 有误")
		return
	end

	if not result.arg3 then
		print("---妙法密录兑换限制20250930补丁 result.arg3 有误")
		return
	end

	local role = map:getPlayer()
	local exchangeInfo = string.split(result.arg2, ",") -- 消耗的物品
	local exchangeItemId, exchangeItemNum = exchangeInfo[1], tonumber(exchangeInfo[2]) 

	local targetInfo = string.split(result.arg3, ",")
	local targetItemId, targetItemNum = targetInfo[1], tonumber(targetInfo[2])  --目标物品Id

	local periodLimittaginfo
	local periodLimitTag
	local periodLimitNum
	if result.arg4 then
		periodLimittaginfo = string.split(result.arg4, ",") --周期限制的标识和次数
		periodLimitTag = periodLimittaginfo[1] --周期限制的标识
		periodLimitNum = tonumber(periodLimittaginfo[2]) --周期限制的次数
	end

	local periodcount = nil
	if periodLimitTag then
		periodcount = role:getInheritTimeStatusTags(periodLimitTag)
		if periodcount < 0 then
			role:setInheritTimeStatusTags(periodLimitTag, 0)
			periodcount = 0
		end
		if periodcount >= periodLimitNum then
			map:doNoRoleResults(result.arg8, environment)
			return 
		end
	end
	
	local totalLimitexchangcountInfo
	local totalLimitTag
	local totalLimitNum
	if result.arg5 then
		totalLimitexchangcountInfo = string.split(result.arg5, ",") --总的限制的标识和次数
		totalLimitTag = totalLimitexchangcountInfo[1] --总的限制的标识
		totalLimitNum = tonumber(totalLimitexchangcountInfo[2]) --总的限制的次数
	end

	local totalcount = nil
	if totalLimitTag then
		totalcount = role:getInheritRoleStatusTags(totalLimitTag)
		if totalcount < 0 then
			role:setInheritRoleStatusTags(totalLimitTag, 0)
			totalcount = 0
		end
		if totalcount >= totalLimitNum then
			map:doNoRoleResults(result.arg8, environment)
			return 
		end
	end

	local button_confirm_name = "兑换" --确定按钮名字
	local button_close_name = "不了"   --取消按钮名字
	local itemData = role:getOneItemByKey(targetItemId)
	local exchange_itemName = role:getOneItemByKey(exchangeItemId).name

	local textList = {
		Text_tital = itemData.name,
		Text_type = itemData:getItemShowType(),
		Text_dsc = itemData.dsc,
		Text_price = "兑换需要："..exchange_itemName.. "X".. exchangeItemNum,
		Text_affirm = "RAN确定兑换"..itemData.name.. "X".. targetItemNum.."吗？",
	}

	local function confirmBtnFunc()
		if role:getItemCount(exchangeItemId) < exchangeItemNum then
			map:doNoRoleResults(result.arg7, environment)
			return
		end

		if role:checkCanBuyTwoOrMoreThings({[targetItemId] = targetItemNum},true) then
			HttpManagerEx:checkItemIsCanUse(
					exchangeItemId, exchangeItemNum,
					function(status, errcode, errmsg, data)
						if status == 200 then
							if errcode == 0 then
								role:addItemCount(exchangeItemId, -exchangeItemNum)
								role:addItemCount(targetItemId, targetItemNum)
								PopText("获得"..itemData.name.."X"..targetItemNum)

								if periodcount then
									role:setInheritTimeStatusTags(periodLimitTag, periodcount + 1)
								end

								if totalcount then
									role:setInheritRoleStatusTags(totalLimitTag, totalcount + 1)
								end

								map:doNoRoleResults(result.arg6, environment)
							else
								map:doNoRoleResults(result.arg7, environment)
							end
						else
							PopText(errmsg)
						end
					end,
			IS_SHOW_WAITING)
		end
	end

	PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
		layer:showLayer(textList,function()
		end)
		layer:setButton_confirm(button_confirm_name, function()
			HttpManagerEx:getwxtranstwxplushasGainAfter202509291500(
				function(status, errcode, errmsg, data)
					if status == 200 then
						if errcode == 1 then
							confirmBtnFunc()
						elseif errcode == 0 then
							if periodcount then
								role:setInheritTimeStatusTags(periodLimitTag, periodcount + 1)
							end

							map:doNoRoleResults(result.arg8, environment)
						end
					else
						PopText(errmsg)
					end
				end,
				IS_SHOW_WAITING
			)
		end)
		layer:setButton_close(button_close_name, function()
			map:doNoRoleResults(result.arg7, environment)
		end)
	end)
end

return CommonResults00
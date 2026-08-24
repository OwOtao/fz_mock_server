local BiWu = require("app.models.BiWu.BiWu")
local BiWuMainUI = require("app.views.ui.BiWuUI.BiWuMainUI")
local Item = require("app.models.item.Item")
local BiWuPrintUI = require("app.views.ui.BiWuUI.BiWuPrintUI")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local BiWuMainLayer = class("BiWuMainLayer",cc.Layer)

function BiWuMainLayer:create()
	local p = BiWuMainLayer:new()
	p:init()
	return p
end

function BiWuMainLayer:init()
	local BiWuMainUI = BiWuMainUI:create()
	self._UI = BiWuMainUI
	BiWuMainUI:addTo(self)

	--进图exitLayer的标识
	self._isToExit = nil

	---设置能打印战斗信息
	BiWu._inMainlayerCanPrintFightMesg = true

	--控制界面跳转
	BiWu.layerStatus = "mainLayer"

	-----用来控制打印战斗结果信息的层
	self._node = cc.Node:create()
	self:addChild(self._node)


------1秒输出一句话
	self:schedule(function ()
		self:update()
	end,1)

	
	self:setButtonWatch()
	self:setDesc()
	self:backButton()
	self:showStatusBar()
end

--进入界面的时候就先判断是挑战还是上台
function BiWuMainLayer:onResume()

	------在显示mainlayer界面之前，停止之前打印战斗信息，重新开始
	self._node:stopAllActions()

	---进入界面之前，情况输出框
	self._UI:initRichText()
	Audio:setMusicVolume(1)
	self:refreshUI()
	BiWu._isPrintTiaoZhanMesg = false
end
---
function BiWuMainLayer:show()

	self._isInitRichText = false

	BiWu._isPrintTiaoZhanMesg = false

	self:showStatusBar()
	self:refreshUI()

	---设置能打印战斗信息
	BiWu._inMainlayerCanPrintFightMesg = true


	local fightAllData = BiWu:getfightAllData()
	--刷新今天上台的次数
	if fightAllData and fightAllData.left_times and fightAllData.left_times >= 0 then
		self:setTimesNumber(true,fightAllData.left_times)
	else
		self:setTimesNumber(true,0)
	end

	local currTime = GetTime()
	local role = User:getRole()
	if role:isInCurrState(ROLE_CURR_STATE_GUANZHAN)  then

		--当前时间超过 23点 强制关闭正在观战 并且让 按钮变成 “观战 ”  
		if Helper:date("%H", currTime) == "23" then
			role:stopGuanZhan(function()
				-----取消观战失败，手动停止，并退出界面
			end,function ()
				---------------在这里，保存结束观看的时间
				local fightAllData = BiWu:getfightAllData()
				fightAllData.stopWatchTime = nil
				fightAllData.watchFid = nil
				BiWu:savefightAllData(fightAllData)
			end)
		
			BiWu._isShowMainLayer = true
			self._UI:setButtonWatchName("观战")
		else
			self._UI:setButtonWatchName("正在观战")
		end
	else
		self._UI:setButtonWatchName("观战")
	end

	-----如果是切换存档应该初始化输出框
	if BiWu:isChangFIleIsTrue("BiWuMainLayer") == true then
		self._UI:initRichText()
		BiWu._changeFileBiWuMainLayer = nil
	end
end

--动画
function BiWuMainLayer:runBackImage()
	-- local Size = self._UI.Sprite_bottom:getContentSize()
	-- self._UI.Sprite_bottom:runAction(cc.Sequence:create(
	-- 				cc.MoveTo:create(0.2,cc.p(Size.width/2,-Size.height)),
	-- 		 		cc.MoveTo:create(0.2,cc.p(Size.width/2,0))
	-- 		 	))
	-- if func then
	-- 	func()
	-- end
end

----观看人数
function BiWuMainLayer:setPeopleNumber(num,type)
	self._UI:setPeopleNumber(num,type,nil)
end
----在线人数的统计
function BiWuMainLayer:setTiaoZhanTime(num,type)
	self._UI:setTiaoZhanTime(num,type,nil)
end
----设置擂主名字
function BiWuMainLayer:setMaster(name,type,data)
	self._UI:setMaster(name,type,data)
end


----进入观看界面  判断时间如果超过收益时间，给提示，不加收益了
function BiWuMainLayer:goToWatchLayer()
	local fightAllData = BiWu:getfightAllData()
	---- 如果已经在观战，不访问服务器
	local role = User:getRole()
	-- if fightAllData and fightAllData.watchFid then
	if	role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) then

		--当前时间超过 23点 强制关闭正在观战 并且让 按钮变成 “观战 ” 
		local  currTime = GetTime()
		if Helper:date("%H", currTime) == "23" then
			role:stopGuanZhan(function()
				-----取消观战失败，手动停止，并退出界面
			end,function ()
				---------------在这里，保存结束观看的时间
				local fightAllData = BiWu:getfightAllData()
				fightAllData.stopWatchTime = nil
				fightAllData.watchFid = nil
				BiWu:savefightAllData(fightAllData)
			end)
		    return 
		end

		MainControllLayer:pushLayer("BiWuWatchLayer")
		local biWuWatchLayer = MainControllLayer:getLayer("BiWuWatchLayer")
		biWuWatchLayer:show()
		local str = BiWu:getmainLayerToWatchLayerText()
		biWuWatchLayer._UI:print(str)

		--隐藏状态栏
		self:hideStatusBar()
	else
		---点击观战告诉服务器进入观看状态
		BiWu:sendBiWuWatch(function ()

			--当前时间超过 23点  无法进入观战页面
			local  currTime = GetTime()
			if Helper:date("%H", currTime) == "23" then
				return 
			end

			MainControllLayer:pushLayer("BiWuWatchLayer")
			local biWuWatchLayer = MainControllLayer:getLayer("BiWuWatchLayer")
			biWuWatchLayer:show()
			local str = BiWu:getmainLayerToWatchLayerText()
			biWuWatchLayer._UI:print(str)

			--开始观战
			local fightAllData = BiWu:getfightAllData()
			role:startGuanZhan(fightAllData.watchFid, fightAllData.current_time, fightAllData.expired_time)
			--隐藏状态栏
			self:hideStatusBar()
		end,function()
			--------异常不然进入观战界面，不开始观战,提示就够了
		end)
	end

end
---观看  取消打坐  观看时间8小时   关卡收益最大一小时  一天三次  又在打坐又在挂机
function BiWuMainLayer:setButtonWatch()
	self._UI:setButtonWatch(nil,function()

		---控制声音的音量
		Audio:setMusicVolume(0.5)


		local role = User:getRole()
		local fightAllData = BiWu:getfightAllData()

		---金钱不够，不让进入
		local money = role:getAttr("money")
		local figure = 25 + math.random(-9, 9)
		if money < figure then
			local str = BiWu:getwatchNoMoneyText()
			PopText("你的金钱不够进入观战台")
			self._UI:print(str)
			return
		end

		local  currTime = GetTime()
		if Helper:date("%H", currTime) == "23" then
			PopText("天色已晚，比武擂台暂时关闭，大侠可明日再来")
		    return 
		end
		
		if  role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) then 
			self:goToWatchLayer()
		else
			self:isBiGuanGuaJiLianGong()
		end
		Audio:playEffect("xiaoAnNiu")
	end)
end

--判断是否在挂机、闭关、练功。如果是，用分身符进行
function BiWuMainLayer:isBiGuanGuaJiLianGong()
	----判断能不能观战，不能观战不让进入，能观战，才购买分身符
	BiWu:getCanGuanZhan(function()
	
		RoleTaskControllor:clickGuanZhanLayer(function()
			self:goToWatchLayer()
		end)
	end,
	---------errcode == 2 正在观战的情况处理
	function ()
		self:goToWatchLayer()
	end)
end


----进入exitLayer  访问服务器获取战斗id
function BiWuMainLayer:goToExitLayer()

	Audio:stopMusic()
	Audio:playMusic("biwu_tiaozhan_2")

	----测试用
	-- if DEBUG_MODE == 1 then
	-- 	User:getRole():setAttr("exp",tonumber(10000))
	-- end

	-- 论剑增加 lunjian_级别_是否传承 统计每日论剑
	local role = User:getRole()
	local inherit
	if User:getRoleAttr("inheritCount") > 0 then
		inherit = "inherit"
	else
		inherit = "unInherit"
	end
    local role_lv = "lunjian_"..role:getLv().."_"..inherit
	--访问服务器并保存战斗fid

	BiWu:sendBiWuJoinFight(
	function ()

		----上台要做的一些属性
		self:beforeGoToExitLayerAndTiaoZhanDo()

		--上台以后，标识当前状态，如果此时退出游戏就是canel状态
		local fightAllData = BiWu:getfightAllData()
		fightAllData.result = "cancel"

		--------------在战斗失败后，应该计算这次上台胜利的人数，并清空一次战斗记录的信息,  在上台的时候也应该清空一次战斗的信息
		do
			---上台的时候清空回合数,如果是金蝉脱壳且不跨天就不清空
			local isToday = false
			print("上次战斗时间：",fightAllData.oneFight.startTime)
			if fightAllData.oneFight.startTime then
				if Helper:diffWithDate(GetTime(), fightAllData.oneFight.startTime) < 1 then
					isToday = true
				end
			else
				--战斗数据没有开始时间数据，默认金蝉脱壳不跨天
				isToday = true
			end
			if isToday and (fightAllData.cardId == 8 or fightAllData.cardName == "DWT金蝉脱壳") then
				print("金蝉脱壳未跨天，战斗数据不需要重置")
			else
				fightAllData.current_cnt = 0
				-----上台清空一次战斗的信息
				BiWu:clearOneFightData()
				print("战斗数据重置")
				--记录上场时间
				fightAllData.oneFight.startTime = GetTime()			
				
				-- 异常退出时在入场时就把 本场人气 清零  ，金蝉脱壳时不清空 
				if  fightAllData.add_renqi and fightAllData.add_renqi > 0  then
					fightAllData.add_renqi = 0
				end
			end
		end

		--一个文件保存战斗状态
		BiWu:savefightAllData(fightAllData)

			--t
		HttpManagerEx:resetActiveTask(role_lv, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if DEBUG_MODE == 1 then
					print("每日论剑玩家等级传承信息上传服务器成功！")
					end
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)	

		--控制界面跳转
		BiWu.layerStatus = "exitLayer"
		MainControllLayer:pushLayer("BiWuExitLayer")
		local biWuExitLayer = MainControllLayer:getLayer("BiWuExitLayer")
		biWuExitLayer:show()
		---显示第几回合
		biWuExitLayer:runActionBoutLayer()
		-- biWuExitLayer:printText()

		---隐藏状态栏
		self:hideStatusBar()
	end)
	


end
---上台  访问服务器，告诉 上台了  先判断获取的剩余次数，如果小于等于 0  ，则获取上台需要的元宝
---如果这次战斗失败，直接变成挑战

function BiWuMainLayer:setButtonStage(str)
	---上台必须停止观战
	----停止观战需要访问服务器
	local role = User:getRole()
	local fightAllData = BiWu:getfightAllData()

	---判断是上台还是挑战
	self._UI:setButtonStage(str,function()
		if DEBUG_MODE == 1 then
		else
			if Map:getMapState("fb15") ~= MAP_STATE.COMPLETE then
				PopText("少侠功夫太浅，需通过“声震武林卷”第五章的考验才能上的此台！")
				return
			end
		end
		-- Audio:playEffect("xiaoAnNiu")
		-- PopText("上台观看watchid  ="..tostring(fightAllData.watchFid))
		if role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) then
			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			local dialog = DialogALayer:getInstance()
			dialog:show("正在观看，上台/挑战必须取消观战，是否确定？")
			dialog:setButton1("是", function()
					--取消观战
					role:stopGuanZhan(function ()

						if User:getRole():getAttr( "qiPercent" ) < 0.5 or
							User:getRole():getAttr( "qi" ) < User:getRole():getCurrQiMax() * 0.5 then
							PopText( "你气血不足，腿有点发软，稍事休息再来吧" )
							return
						end

						----上台要做的一些属性,     2016/09/23  改到请求服务器成功后再清空输出框，控制输出等
						-- self:beforeGoToExitLayerAndTiaoZhanDo()

						if str == "上台" then
							self:goToExitLayer()
						else
							self:tiaoZhanFunc()
						end
					----上台取消观战失败的处理,取消观战失败，应该清除这次观战的记录。重新开始
					end,function ()
							PopText("网络错误，取消观战失败")
					end)
				end)
			dialog:setButton2("否")
		else
			----上台要做的一些属性  2016/09/23  改到请求服务器成功后再清空输出框，控制输出等
			-- self:beforeGoToExitLayerAndTiaoZhanDo()
			if User:getRole():getAttr( "qiPercent" ) < 0.5 or
				User:getRole():getAttr( "qi" ) < User:getRole():getCurrQiMax() * 0.5 then
				PopText( "你气血不足，腿有点发软，稍事休息再来吧" )
				return
			end

			if str == "上台" then
				self:goToExitLayer()
			else
				self:tiaoZhanFunc()
			end
		end
	end)
end

----上台需要做的一些事情
function BiWuMainLayer:beforeGoToExitLayerAndTiaoZhanDo()
	local role = User:getRole()
	BiWu._inMainlayerCanPrintFightMesg = false
	----清空输出框
	self._UI:initRichText()
	----克隆角保存到fightAllData
	BiWu:cloneRoleSaveToFightAllData(role)
end
-----挑战按钮 的实现
function BiWuMainLayer:tiaoZhanFunc()


	local params =
	{
		fid =nil ,
	}
	--能战斗的一个标志
	-- BiWu.fightMark = 0
	local fightAllData = BiWu:getfightAllData()

	if fightAllData.fid == nil then
		PopText("加入战斗时候，fid获取失败了")
		return
	else
		params.fid = fightAllData.fid

		--访问服务器，匹配对手
		BiWu:sendBiWuFight( 4 , params , function()

			----上台要做的一些属性
			self:beforeGoToExitLayerAndTiaoZhanDo()

			Audio:stopMusic()

			-- Audio:playEffect("biwu_tiaozhan_2")

			local role =User:getRole()
			----打完之后，如果还是是失败的，继续挑战
			--直接战斗
			if fightAllData.user then

				do
					--战斗以后，标识当前状态，如果此时退出游戏就是run状态
					local fightAllData = BiWu:getfightAllData()
					fightAllData.result = "run"
					--一个文件保存战斗状态
					BiWu:savefightAllData(fightAllData)
				end

				--初始化统计数据
				BiWu:initFightData()
				-- BiWu:fight(role,role)

				local player = Helper:tableCover(Role:create(), fightAllData.user)

				player:setAttr("qi",fightAllData.qi)    -- 气血
				player:setAttr("qiMax",fightAllData.qiMax)  -- 最大气血
				player:setAttr("neili",fightAllData.neili)   -- 内力
				player:setAttr("neiliMax",fightAllData.neiliMax)-- 最大内力
				BiWu:savefightAllData(fightAllData)

				----之前是直接战斗，现在先跳转到printUI然后再战斗
				-- BiWu:fight(role,player)
				local biWuPrintUI = BiWuPrintUI:getInstance()
				--local Text = BiWu:_getBattleReplyText()
				--biWuPrintUI:printText(Text)
				--能战斗的一个标志
				biWuPrintUI:clearPaneItem()
				BiWu.fightMark = 0
				biWuPrintUI:show("挑战",MainControllLayer)
				biWuPrintUI:tiaoZhan()

			else
				if PRINT_MODE ==1 then
					PopText("挑战时候，获取对手数据失败")
				end
			end
		end,
		--网络请求失败，设置挑战时间为nil，就可以重新上台了
		function()
			local fightAllData = BiWu:getfightAllData()
			fightAllData.fightExpired_time = nil

			BiWu:savefightAllData(fightAllData)
			BiWu:getBiWuFightEnd()
		end,
		-------网络请求超时的处理
		function ()
			
		end)
	end



end
---上台次数
function BiWuMainLayer:setTimesNumber(type,num)
	self._UI:setTimesNumber(type,num,nil)
end

--描述  这里的描述是否和startlayer的描述一样
function BiWuMainLayer:setDesc()
	local str =BiWu:getStartLayerDescText()
	self._UI:setDesc(str)
end


---离开
function BiWuMainLayer:backButton()
	self._UI:backButton(function()
		--下台时清零本场人气
		local fightAllData = BiWu:getfightAllData()
		fightAllData.day_renqi = 0
		MainControllLayer:popLayer()
	end)
end

function BiWuMainLayer:update()
	self:refreshUI()
	self:printFightText()
	self:printCanNotWatchText()
end


-----在观看界面观战。自动停止时候，应该在主界面打印提示信息
function BiWuMainLayer:printCanNotWatchText()
	if BiWu._isWatchNoMoney == true then
		BiWu._isWatchNoMoney = nil
		local str = BiWu:getwatchNoMoneyText()
		if str then
			self._UI:print(str)
		end
	end
	if BiWu._isWatchNoTime == true then
		BiWu._isWatchNoTime = nil
		local str = BiWu:getwatchTimeOverText()
		if  str then
			self._UI:print(str)
		end
	end
end

-----控制输出打印信息，刷新当前观看人数、剩余次数、擂主的显显示与否、上台还是挑战
--如果是中途推退出的，默认失败。是挑战还是上台？
function BiWuMainLayer:refreshUI()

	---每一秒读取文件，浪费资源
	local fightAllData = BiWu:getfightAllData()
	local currTime = GetTime()


	---若果是挑战失败，应该继续挑战，但是如果是挑战成功了。应该直接跳转到 ExitLayer 界面
	if fightAllData.result == "win" and fightAllData.fightType == 4 then
		--上台以后，标识当前状态，如果此时退出游戏就是canel状态
		local fightAllData = BiWu:getfightAllData()
		fightAllData.result = "cancel"
		--一个文件保存战斗状态
		BiWu:savefightAllData(fightAllData)
		--控制界面跳转
		BiWu.layerStatus = "exitLayer"
		MainControllLayer:pushLayer("BiWuExitLayer")
		local biWuExitLayer = MainControllLayer:getLayer("BiWuExitLayer")


		local text = BiWu:getBattleWinText()

		--显示第几回合
		-- biWuExitLayer:runActionBoutLayer()

		biWuExitLayer:show(text)
		self:hideStatusBar()
	end


	--time 是服务器给的  挑战过期时间 只有失败才会挑战，取消、逃跑都是重新上台
	if fightAllData and fightAllData.fightExpired_time and currTime < fightAllData.fightExpired_time and fightAllData.result == "lose" then
		self:setButtonStage("挑战")

		--把服务器获取的角色的名字加上来
		if fightAllData.user and fightAllData.user.name and fightAllData.challengeData then
			self:setMaster(fightAllData.user.name,true,fightAllData.challengeData)
			-- self:setMaster(fightAllData.user.name,true,fightAllData.user)
		else
			if PRINT_MODE == 1 then
				PopText("设置擂主，获取擂主信息出错")
			end
		end
		self:setTimesNumber(false,0)

		---显示剩余挑战时间
		-- local currTime =fightAllData.fightCurrent_time
		local currTime =GetTime()
		local year, month, day, hour, minute, second =Helper:getExpiredTime(fightAllData.fightExpired_time,currTime)
		-- fightAllData.fightCurrent_time = fightAllData.fightCurrent_time + 1 
		-- BiWu:savefightAllData(tb)
		if tonumber(second)<10 then
			second = "0"..tostring(second)
		end
		if second==60 then
			second="00"
			minute=minute+1
		end
		local str = tostring(minute)..":"..tostring(second)
		if PRINT_MODE ==1 then
			print("fightAllData.fightExpired_time ="..tostring(fightAllData.fightExpired_time).."currTime="..tostring(currTime))
			print("时间 ：="..str)
		end
		---打开时间倒计时，关闭在线人数的显示
		self._UI:setPeopleNumber(nil,false,nil)
		self._UI:setTiaoZhanTime(str,true,nil)

	else
		self:setButtonStage("上台")
		self:setMaster(nil,false,nil)
		--刷新今天上台的次数
		if fightAllData and fightAllData.left_times and fightAllData.left_times >= 0 then
			self:setTimesNumber(true,fightAllData.left_times)
		else
			self:setTimesNumber(true,0)
		end

		-- -- 异常退出时在入场时就把 本场人气 清零  ，金蝉脱壳时不清空 
		-- if fightAllData and fightAllData.add_renqi and fightAllData.add_renqi > 0  and fightAllData.cardName ~= "DWT金蝉脱壳" then
		-- 	fightAllData.add_renqi = 0
		-- 	BiWu:savefightAllData(fightAllData)
		-- end

		---关闭时间倒计时
		self._UI:setTiaoZhanTime(nil,false,nil)

		if fightAllData.watch_cnt == nil or fightAllData.watch_cnt == 0 then
			self._UI:setPeopleNumber(5,true,nil)
		else
			self._UI:setPeopleNumber(fightAllData.watch_cnt,true,nil)
		end
	end

	----控制状态栏的显示与否
	if BiWu._isShowMainLayer == true then
		self:showStatusBar()
		-- PopText("if BiWu._isShowMainLayer == true then")
		BiWu._isShowMainLayer = false
	else
		-- self._UI.Button_Stage:setVisible(false)
	end

	local role = User:getRole()
	if role:isInCurrState(ROLE_CURR_STATE_GUANZHAN) then 
		if Helper:date("%H", currTime) == "23" then
			self._UI:setButtonWatchName("观战")
		else
			self._UI:setButtonWatchName("正在观战")
		end
		
	else
		self._UI:setButtonWatchName("观战")
	end
end

---打印战斗新结果，谁打赢了谁
function BiWuMainLayer:printFightResultMesg()
	local fightAllData = BiWu:getfightAllData()
	local currTime = GetTime()
	local  str = ""
	local num = #fightAllData.oneFight.tiaoZhanMesg
	for i=1,num do
		local action = cc.Sequence:create(cc.DelayTime:create(i), cc.CallFunc:create(
		    function()
		        str = fightAllData.oneFight.tiaoZhanMesg[i]
		        if str == nil then
		        else
		        	---打印之前的战斗信息
		        	self._UI:print("HIY"..str)
		        end
		        -----最后一句输出后，打印战斗奖励信息
		        if i == num then
		        	self:printFightResult()
		        end
		    end))
		self._node:runAction(action)
	end
end

---------打印战斗奖励信息结果，得到了多少银两
function BiWuMainLayer:printFightResult()
	---显示剩余挑战时间
	local currTime =GetTime()
	local fightAllData = BiWu:getfightAllData()
	local year, month, day, hour, minute, second =Helper:getExpiredTime(fightAllData.fightExpired_time,currTime)
	if fightAllData.opponentMenPaiName and fightAllData.oneFight.peopleNum  and fightAllData.oneFight.allMoney then
		self._UI:print("HIW本次最高挑战人数："..tostring(fightAllData.oneFight.peopleNum))
		self._UI:print("HIY还剩"..minute.."分"..second.."秒".."挑战"..fightAllData.opponentMenPaiName)
		self._UI:print("HIC此次擂台总共赢得"..math.floor(fightAllData.oneFight.allMoney).."银两")
	end
end

----打印战斗信息
function BiWuMainLayer:printFightText()
	--	超过23点不打印信息
	local currTime =GetTime()
	if Helper:date("%H", currTime) == "23" then
		return
	end

	----进入exitlayer 就不打印了。只有上台界面才打印
	if self._UI.Button_Stage.Text_buttonName:getString() == "上台" and BiWu._inMainlayerCanPrintFightMesg == true then
		local str = BiWu:getOnefightMsgList()
		if str == nil then
		else
			self._UI:print(str)
		end
	elseif  self._UI.Button_Stage.Text_buttonName:getString() == "挑战" and BiWu._inMainlayerCanPrintFightMesg == true then
		if BiWu._isPrintTiaoZhanMesg == false then
			self:printFightResultMesg()
			BiWu._isPrintTiaoZhanMesg = true
		end
	else
	end

end

---------------------------
--点击状态栏的实现
function BiWuMainLayer:showStatusBar()
		local MapRoleLayer = require("app.views.layer.MapLayer.MapRoleLayer")
		local mapRoleLayer = MapRoleLayer:getInstance()
		MessageCenter:notify("EnterBiWu")
  		mapRoleLayer:show()
  		mapRoleLayer:onResume()
  		mapRoleLayer:setVisible(true)
  		mapRoleLayer:setTitle("擂台旁")
		mapRoleLayer:getBiWuMainLayerMark(self._UI,true)
  		mapRoleLayer:exitButtonFunc(false,function()
  			--退出这个界面，。隐藏mapRoleLayer
  			MainControllLayer:popLayer()
  			mapRoleLayer:onPause()
  			mapRoleLayer:hide()
  			mapRoleLayer:setVisible(false)
			-- PopText("mapRoleLayer"..tostring(mapRoleLayer:isVisible()))   
			PopupLayerController:hideLayer("BagDescLayer",function(layer)
				layer:hideLayer()
			end,0)
  		end)
end
--隐藏状态栏的实现
function BiWuMainLayer:hideStatusBar()
		local MapRoleLayer = require("app.views.layer.MapLayer.MapRoleLayer")
  		local mapRoleLayer = MapRoleLayer:getInstance()
		--退出这个界面，。隐藏mapRoleLayer
		mapRoleLayer:hide(true)
		mapRoleLayer:setVisible(false)
		mapRoleLayer:getBiWuMainLayerMark(self._UI,false)
end
Helper:classDefNodeGetInstance(BiWuMainLayer)

return  BiWuMainLayer
00000
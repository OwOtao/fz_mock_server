local BiWu = require("app.models.BiWu.BiWu")
local BiWuExitUI = require("app.views.ui.BiWuUI.BiWuExitUI")
local BiWuPrintUI = require("app.views.ui.BiWuUI.BiWuPrintUI")

local BiWuExitLayer = class("BiWuExitLayer", LayerEx)

------用来保存创建好的Panelitem
local CallBackFunc = nil


function BiWuExitLayer:createInRunningScene()
	local layer = BiWuExitLayer:getInstance()

	return layer
end

function BiWuExitLayer:create()
	local p = BiWuExitLayer:new()
	p:init()
	return p
end

function BiWuExitLayer:init()
	local BiWuExitUI = BiWuExitUI:create()
	self._UI = BiWuExitUI

	BiWuExitUI:addTo(self)

	self._textLayer = cc.Node:create()
	self._boutLayer = cc.Node:create()

	self._boutLayer:setContentSize({width = 1080,height = 1920})
	-- self._boutLayer:setOpacity(255)
	self:addChild(self._textLayer)
	self:addChild(self._boutLayer)
	self:setButtonBattle()
	-- self:setButtonProvoke()
	self:setButtonByeBye()
	self:setChengHaoName()
	self:setMoney()
	self:setExp()
	-- self:setImageHead()

	----记录文本动画是否播放完
	self._animationTextOver = nil

	-----记录第几回合的层
	self._isShowBoutLayerOver = nil

	----- @author LiJie  多次点击激战，不再显示文本
	self._againBattl = nil

	self.Panel_itemArry = {}

	self.index = 1

	self.distance = 0
end

function BiWuExitLayer:show(text)
	self.distance = 0
	self.index = 1
	CallBackFunc = nil
	self:setVisible(true)
	self:controlShow()
	self:hideButtons()
	self:clearPaneItem()
	---------只启用一个update
	if self._handle == nil then
		self._handle = self:schedule(function()
			self:update()
		end,0.5)
	end

	---显示第几回合
	self._isShowBoutLayerOver = nil
	self:printText(text)

	--上台次数的刷新，上台一次，保存数据
	BiWu:getBiWuFightTimes()


	self:setChengHaoName()
	self:setMoney()
	self:setExp()
	self:setPeopleNumber()

	---刷新血 内力状态
	self:setQiXueNeiLiPersent()
end

function BiWuExitLayer:clearPaneItem()
	for i,v in ipairs(self.Panel_itemArry) do
		self.Panel_itemArry[i]:removeFromParent()
		self.Panel_itemArry[i] = nil
	end
	self.Panel_itemArry = {}
end

----人气值
function BiWuExitLayer:setPeopleNumber()
	local fightAllData = BiWu:getfightAllData()
	if MapIsEmpty(fightAllData) and fightAllData.renqi ~= nil then
		---如果是没有数据
		if PRINT_MODE ==1 then
			PopText("exitLayer人气数量没有获取成功")
end
	else
		-- self._UI:setPeopleNumber(fightAllData.renqi,nil)
		-- 原本显示当前人气总值，现改为本场人气变化值和当天人气最大值
		self._UI:setPeopleNumber(fightAllData.add_renqi,nil)
		self._UI:setPeopleMaxNumber(fightAllData.day_renqi,nil)
		
	end
end

-----设置气血状态  在初始化调用一次  战斗调用后要调用
function BiWuExitLayer:setQiXueNeiLiPersent()
	local QiPercent, CurrQiPercent, NlPercent = BiWu:countQiXueNeiLiPersent()
	self._UI:setQiXueNeiLiPersent(QiPercent, CurrQiPercent, NlPercent)
end

---称号、名字
function BiWuExitLayer:setChengHaoName()
	local role = User:getRole()

	local chenghao = role:getChengHaoColorName()
	local name = role:getName()
	self._UI:setChengHaoName(chenghao,name,nil)
end


----设置金钱
function BiWuExitLayer:setMoney()
	local role = User:getRole()
	local money = role:getAttr("money")
	self._UI:setMoney(money,nil)
end

----设置经验
function BiWuExitLayer:setExp()
	local role = User:getRole()
	local exp = role:getAttr("exp")
	self._UI:setExp(exp,nil)
end
-----------------------------------------开始匹配对手 POST fight/{fight_type} 1挑衅，2邀战，3告辞 4 挑战
local  params =
{
	fid = nil,
}

-- 邀战
function BiWuExitLayer:setButtonBattle()

	self._UI:setButtonBattle("邀战",function ()
		--添加打完三十六局判断
		-- local fightAllData = BiWu:getfightAllData()
        -- if fightAllData.current_cnt and fightAllData.current_cnt >= 36 then 
		-- 	PopText("你已经打完三十六回合！请点击告辞下台！")
		-- 	return
		-- end

		self._animationTextOver = false
		if self._againBattl == true then
			---多次激战，不再弹出文本
		else
			local battleText = BiWu:_getBattleText()
			local arry = BiWu:createTextFromArray(self._textLayer, self._UI.Panel_item, battleText)
			for i,v in ipairs(arry) do
				table.insert(self.Panel_itemArry,arry[i])
			end
		end
		self:controlShow()

		self:hideButtonsAim()
		CallBackFunc = function()
			self:delayFunc(1,function()
				-- ---获取加入战斗时候访问服务器保存的fid，发送给服务器
				local fightAllData = BiWu:getfightAllData()
				if fightAllData.fid == nil then
					PopText("加入战斗时候，网络连接失败,请重新上台")
					self._animationTextOver = true
					self:controlShow(self._animationTextOver)
					self:showButtonsAim()

					------加入战斗失败，退出这个界面
					MainControllLayer:popLayer()
					BiWu._isShowMainLayer = true

					----控制在mainlayer界面能不能打印
					BiWu._inMainlayerCanPrintFightMesg = true
					BiWu._isPrintTiaoZhanMesg = false
					self._againBattl = nil 
					return
				else
					-- 访问服务器，匹配对手
					BiWu:sendBiWuFight(2, {fid = fightAllData.fid},function()
						local biWuPrintUI = BiWuPrintUI:getInstance()

						biWuPrintUI:clearPaneItem()
						biWuPrintUI:battleButton()
						
						----
						biWuPrintUI:setExitLayer(self)
						biWuPrintUI:show("激战",MainControllLayer)

						-- 能战斗的一个标志
						BiWu.fightMark = 0

						-----清空自己的数据
						self:clearPaneItem()
					end,
					function()
						PopText("加入战斗时候，网络连接失败")
						self._animationTextOver = true
						-- @author LiJie   多次点击激战，不让多次显示文本
						self._againBattl = true 
						self:controlShow(self._animationTextOver)
						self:showButtonsAim()
					end,
					--------请求服务器超时，邀战处理
					function ()
						----直接跳到mainlayer界面
						------加入战斗失败，退出这个界面
						MainControllLayer:popLayer()
						BiWu._isShowMainLayer = true
						----控制在mainlayer界面能不能打印
						BiWu._inMainlayerCanPrintFightMesg = true
						BiWu._isPrintTiaoZhanMesg = false
						-- @author LiJie   多次点击激战，不让多次显示文本
						self._againBattl = nil
					end)
				end
			end)
		end
	end)
end



---挑衅
function BiWuExitLayer:setButtonProvoke()
	-- self._UI:setButtonProvoke("挑衅",function ()
	-- 	self._animationTextOver = false
	-- 	local provokeText = BiWu:_getProvokeText()
	-- 	local arry = BiWu:createTextFromArray(self._textLayer, self._UI.Panel_item, provokeText, textArrayIndex)
	-- 	for i,v in ipairs(arry) do
	-- 		table.insert(self.Panel_itemArry,arry[i])
	-- 	end
	-- 	self:controlShow()

	-- 	self:hideButtonsAim()
	-- 	CallBackFunc = function()
	-- 		self:delayFunc(1,function ()
	-- 			---获取加入战斗时候访问服务器保存的fid，发送给服务器
	-- 			local fightAllData = BiWu:getfightAllData()
	-- 			if fightAllData.fid == nil then
	-- 				PopText("加入战斗时候，fid获取失败")
	-- 				self._animationTextOver = true
	-- 				self:controlShow(self._animationTextOver)
	-- 				self:showButtonsAim()
	-- 				return
	-- 			else
	-- 				params.fid = fightAllData.fid
	-- 				--访问服务器，匹配对手
	-- 				BiWu:sendBiWuFight(1,params,function ()
	-- 					local biWuPrintUI = BiWuPrintUI:getInstance()
	-- 					biWuPrintUI:provokeButton()
	-- 					biWuPrintUI:setExitLayer(self)
	-- 					biWuPrintUI:show("挑衅",MainControllLayer)

	-- 					--能战斗的一个标志
	-- 					BiWu.fightMark = 0

	-- 				end,
	-- 				function()
	-- 					self:showButtonsAim()
	-- 				end
	-- 				)

	-- 			end
	-- 		end)

	-- 	end
	-- end)
end

---告辞
function BiWuExitLayer:setButtonByeBye()
	self._UI:setButtonByeBye("告辞",function ()
		self._animationTextOver = false
		local byebyeText  = BiWu:_getByeByeText()
		local arry = BiWu:createTextFromArray(self._textLayer, self._UI.Panel_item, byebyeText)
		for i,v in ipairs(arry) do
			table.insert(self.Panel_itemArry,arry[i])
		end
		self:controlShow()
		----- @author LiJie 清空记录，下次进入界面打印文本
		self._againBattl = nil

		self:hideButtonsAim()
		CallBackFunc = function()
			-- ---获取加入战斗时候访问服务器保存的fid，发送给服务器,如果检测没有fid，应该退出这个界面，重新再mainlayer界面获取fid
			local fightAllData = BiWu:getfightAllData()
			if fightAllData.fid == nil then
				PopText("加入战斗时候，网络连接获取失败，请重新上台")
				self._animationTextOver = true
				self:controlShow(self._animationTextOver)
				self:showButtonsAim()
				Audio:playMusic("biwu_leitai",true)

				------加入战斗失败，退出这个界面
				MainControllLayer:popLayer()
				BiWu._isShowMainLayer = true

				----控制在mainlayer界面能不能打印
				BiWu._inMainlayerCanPrintFightMesg = true
				BiWu._isPrintTiaoZhanMesg = false

				return
			else
				--访问服务器，匹配对手
				BiWu:sendBiWuFight(3, { fid = fightAllData.fid },function ()
					---延迟两秒直接退出这个界面
					self:delayFunc(1,function()
						MainControllLayer:popLayer()
						Audio:playMusic("biwu_leitai",true)
						BiWu._isShowMainLayer = true

						-----点击告辞后，卡牌id清空，名字清空，不然，卡牌效果还在
						local fightAllData = BiWu:getfightAllData()
						fightAllData.cardId = nil
						fightAllData.cardName = nil
						--清零当前场次人气变化值(本场人气)
                        fightAllData.add_renqi = 0 

						BiWu:savefightAllData(fightAllData)
						
						----控制在mainlayer界面能不能打印
						BiWu._inMainlayerCanPrintFightMesg = true
						BiWu._isPrintTiaoZhanMesg = false
					end)
				end,function()
					------加入战斗失败，退出这个界面
					MainControllLayer:popLayer()
					Audio:playMusic("biwu_leitai",true)
					BiWu._isShowMainLayer = true

					----控制在mainlayer界面能不能打印
					BiWu._inMainlayerCanPrintFightMesg = true
					BiWu._isPrintTiaoZhanMesg = false
				end,--------请求服务器超时，邀战处理
				function ()
					----直接跳到mainlayer界面
					------加入战斗失败，退出这个界面
					MainControllLayer:popLayer()
					BiWu._isShowMainLayer = true
					----控制在mainlayer界面能不能打印
					BiWu._inMainlayerCanPrintFightMesg = true
					BiWu._isPrintTiaoZhanMesg = false
				end)
			end
		end
	end)
end

function BiWuExitLayer:controlShow(type)

	if type == false or not type then
		self._UI.Panel_back:setVisible(false)
	else
		self._UI.Panel_back:setVisible(true)
	end
end
--------------------------------------------------------------------------------------
--进入界面先显示动画文本，完事之后，在显示按钮之类的
function BiWuExitLayer:printText(text)
	----记录文本动画播放的过程是否完毕
	self._animationTextOver = false
	self.Panel_itemArry = {}

	local ExitLayerText --- = BiWu:getDefaultText()
	-- local ExitLayerText = BiWu:getBattleWinText()
	if text then
		ExitLayerText = text
	else
		----如果打了两次战斗，上一个对手存在才输出打赢了谁谁
		local fightAllData = BiWu:getfightAllData()
		if fightAllData.allBattleName and# fightAllData.allBattleName >= 2 then
			ExitLayerText = BiWu:getdefaultTextExistLastBattle()
		else
			-- ExitLayerText = BiWu:getBattleWinText()
			ExitLayerText = BiWu:getDefaultText()
		end

		---如果是武馆管家赶走的擂主，这次上台显示的文本, 打赏换人的文本
		if BiWu._guanJiaThrowOutBattle == true or fightAllData.cardId == 3 or fightAllData.cardName == "NOR打赏换人" then
			ExitLayerText = BiWu:getdefaultTextWUGuanGuanJiaBattle()
			BiWu._guanJiaThrowOutBattle = nil
		end
		----金蝉脱壳的文本
		if fightAllData.cardId == 8 or fightAllData.cardName == "NOR金蝉脱壳" then
			ExitLayerText = BiWu:getdefaultTextJinChanTuoQiao()
		end
		---如果上一次战斗的时间距离现在的时间超过一天 ，则：显示普通文本
		local currTime = GetTime()
		if fightAllData.fightOverTime and Helper:diffWithDate(currTime, fightAllData.fightOverTime) >= 1 then
			ExitLayerText = BiWu:getDefaultText()
		end
	end
	--Panel_item  Panel_back.Image_help
	self.Panel_itemArry = BiWu:createTextFromArray(self._textLayer, self._UI.Panel_item, ExitLayerText)

	CallBackFunc = function()
		self._animationTextOver = true
		self:controlShow(self._animationTextOver)
		self:showButtonsAim()
		-----执行属性界面的动画
		self._UI:runActionRoleAttr()
	end
end

function BiWuExitLayer:printTextForData(text)
	self._animationTextOver = false
	self.Panel_itemArry = {}
	--local ExitLayerText = BiWu:getExitLayerText()
	--Panel_itemArry = BiWu:createText(self._textLayer,self._UI.Panel_item,ExitLayerText)

	local ExitLayerText = BiWu:getDefaultText()
	--Panel_item  Panel_back.Image_help
	self.Panel_itemArry = BiWu:createTextFromArray(self._textLayer, self._UI.Panel_item, ExitLayerText)

	CallBackFunc = function()
		self._animationTextOver = true
		self:controlShow(self._animationTextOver)
		self:showButtonsAim()
	end
end

--显示按钮
function BiWuExitLayer:showButtons()
	local Button_Battle = self._UI.Button_Battle
	local Button_Provoke = self._UI.Button_Provoke
	local Button_ByeBye = self._UI.Button_ByeBye

	Button_Battle:setVisible(true)
	Button_Provoke:setVisible(false)
	Button_ByeBye:setVisible(true)
end

--隐藏按钮
function BiWuExitLayer:hideButtons()
	local Button_Battle = self._UI.Button_Battle
	local Button_Provoke = self._UI.Button_Provoke
	local Button_ByeBye = self._UI.Button_ByeBye

	Button_Battle:setVisible(false)
	Button_Provoke:setVisible(false)
	Button_ByeBye:setVisible(false)
end

--@desc: 设置按钮可交互状态
--@author:LvBin
--@time:2022-05-31 14:57:33
--@return
function BiWuExitLayer:setButtonsTouchEnabled(boole)
	local Button_Battle = self._UI.Button_Battle
	local Button_Provoke = self._UI.Button_Provoke
	local Button_ByeBye = self._UI.Button_ByeBye

	Button_Battle:setTouchEnabled(boole)
	Button_Provoke:setTouchEnabled(boole)
	Button_ByeBye:setTouchEnabled(boole)
end

--显示按钮动画
function BiWuExitLayer:showButtonsAim()
	local Button_Battle = self._UI.Button_Battle
	local Button_Provoke = self._UI.Button_Provoke
	local Button_ByeBye = self._UI.Button_ByeBye

	self:showButtons()

	self:setButtonsTouchEnabled(true)

	Button_Battle:setOpacity( 0 )
	Button_Provoke:setOpacity( 0 )
	Button_ByeBye:setOpacity( 0 )


	local animDuration = 0.25
	Button_Battle:setPosition(cc.p(540 + 300, Button_Battle:getPositionY()))
	Button_Provoke:setPosition(cc.p(540 - 300, Button_Provoke:getPositionY()))
	Button_ByeBye:setPosition(cc.p(540 + 300, Button_ByeBye:getPositionY()))

	Button_Battle:runAction(
		YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(animDuration, cc.p( 540.0000 , Button_Battle:getPositionY()) ) ,
						cc.FadeIn:create(animDuration)
					),  Sine_EaseOut ) )

	Button_Provoke:runAction(
		YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(animDuration, cc.p( 540.0000 , Button_Provoke:getPositionY()) ) ,
						cc.FadeIn:create(animDuration)
					),  Sine_EaseOut ) )

	Button_ByeBye:runAction(
		YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(animDuration, cc.p( 540.0000 , Button_ByeBye:getPositionY()) ) ,
						cc.FadeIn:create(animDuration)
					),  Sine_EaseOut ) )
end

--隐藏按钮动画
function BiWuExitLayer:hideButtonsAim()
	local Button_Battle = self._UI.Button_Battle
	local Button_Provoke = self._UI.Button_Provoke
	local Button_ByeBye = self._UI.Button_ByeBye

	self:setButtonsTouchEnabled(false)
	local animDuration = 0.25
	Button_Battle:runAction(
		YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(animDuration, cc.p( 540.0000 + 300 , Button_Battle:getPositionY()) ) ,
						cc.FadeOut:create(animDuration)
					),  Sine_EaseOut ) )

	Button_Provoke:runAction(
		YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(animDuration, cc.p( 540.0000 - 300, Button_Provoke:getPositionY()) ) ,
						cc.FadeOut:create(animDuration)
					),  Sine_EaseOut ) )

	Button_ByeBye:runAction(
		YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(animDuration, cc.p( 540.0000 + 300, Button_ByeBye:getPositionY()) ) ,
						cc.FadeOut:create(animDuration)
					),  Sine_EaseOut ) )
end

-----显示第几回合
function BiWuExitLayer:showBoutLayer()

	local fightAllData = BiWu:getfightAllData()

	local bout = 1
	-- PopText("fightAllData.current_cnt ="..tostring(fightAllData.current_cnt))
	if fightAllData.current_cnt and fightAllData.current_cnt ~= 0 then --and fightAllData.current_cnt ~= 0
		bout = fightAllData.current_cnt
	-----服务器没处理好，自己加一
		bout = bout + 1
	end
	------如果卡牌是巧舌如簧  则回合数加一,下次战斗还是显示服务器给的
	-- if fightAllData.cardId == 4 or fightAllData.cardName == "DWT巧舌如簧" and fightAllData.result == "win" then
	-- 	if PRINT_MODE ==1 then
	-- 		PopText("fightAllData.cardId = "..tostring(fightAllData.cardName))
	-- 	end
	-- 	bout = bout + 1
	-- end


	----删除所有的子节点
	if self._boutLayer:getChildren() then
		self._boutLayer:removeAllChildren()
	end
	local text = ccui.Text:create()
	-----------用Helper里的显示十万以内的字
	local figure = Helper:numberCast(bout)

	local str = "第"..tostring(figure).."回合"
	text:setFontName("Font/HYCFS.ttf")
	text:setAnchorPoint(0.5000, 0.5000)
	text:setString(str)
	text:setPosition(540.0000, 1200.0000)
	text:setFontSize(90)
	text:setColor(cc.c3b(255, 165, 0))
	text:setVisible(true)
	self._boutLayer:addChild(text)

end

function BiWuExitLayer:runActionBoutLayer()
	---先显示第几回合
	self:showBoutLayer()

	self._boutLayer:setOpacity(0)
	self._boutLayer:runAction(
		cc.Sequence:create(
			cc.FadeIn:create(0.5),
			cc.DelayTime:create( 3 ) ,
			cc.FadeOut:create(0.5)
			, cc.CallFunc:create(function()
					self._isShowBoutLayerOver = true
					self._boutLayer:removeAllChildren()
				end)))

end

function BiWuExitLayer:update()
	--self:controlShow(self._animationTextOver)
	self:refreshUI()

	if self._isShowBoutLayerOver ~= nil then
			--文本动画
		if self.Panel_itemArry[self.index] then
			BiWu:runActionText(self.Panel_itemArry[self.index], self.index, 5, self.distance,false)
			--保存上一个文本出现的高度
			self.distance = self.distance + self.Panel_itemArry[self.index]:getRichText():getNewContentSizeHeight()
			self.index = self.index + 1
		else
			-- self:unschedule(self._handle)
			--显示按钮等其界面其他元素
			if CallBackFunc then
				CallBackFunc()
				CallBackFunc = nil
			end
			self:controlShow(self._animationTextOver)

		end
	end
end

function BiWuExitLayer:refreshUI()
	---对话完，告辞，立马回到MainLayer
	local fightAllData = BiWu:getfightAllData()

	---两种情况回到mainlayer界面，一种是告辞  二种 战斗失败  逃跑也回到这个界面  胜利去exitlayer
	if BiWu.layerStatus == "mainLayer" or (fightAllData.result == "lose") or (fightAllData.result == "run" and BiWu.fightMark == 2) then
		MainControllLayer:popLayer()
		BiWu._isShowMainLayer = true
		self:unschedule( self._handle)
		self._handle = nil
	end
end


--胜利的情况，设置自己的气血和内力回复到上限
function BiWuExitLayer:setMineQiNeiMax()
	local role = User:getRole()
	local qiMax = role:getCurrQiMax() -- role:getFinalAttr("qiMax") 获得当前血量上限
	local neiliMax = role:getFinalAttr("neiliMax")
	local neili = role:getAttr("neili")

	role:setAttr("qi",qiMax)
	if tonumber(neili) < tonumber(neiliMax) then
		role:setAttr("neili",tonumber(neiliMax))
	end

	BiWu:cloneRoleSaveToFightAllData(role)
end



----头像的设置
-- function BiWuExitLayer:setImageHead()
-- 	self._UI:setImageHead()
-- end
Helper:classDefNodeGetInstance(BiWuExitLayer)
return  BiWuExitLayer
0000000
-- 生死簿
local LifeDeathBookLayer = class("LifeDeathBookLayer", LayerEx)

local LifeDeathBook = require("script.others.livediebook")["生死簿"]

function LifeDeathBookLayer:create()
	local p = LifeDeathBookLayer:new()
	p:init()
	return p
end

function LifeDeathBookLayer:init()
	self._UI = require("Layer/PopUI/LifeDeathBookUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setShowAndHideAnimType("ROLL")

	self:setBack()
	self:setButton()
end

function LifeDeathBookLayer:initData()
	-- 总次数
	self.totalCount = 0

	-- 正确次数
	self.rightCount = 0

	-- 错误次数
	self.errorCount = 0

	-- 答案结果
	self.result = ""

	self.NpcName = ""
end

function LifeDeathBookLayer:getQuestion()
	self:updateText()
	self.Panel_play.Text_desc_1:setString("")

	local totalNum = 0
	for k,v in pairs(LifeDeathBook) do
		totalNum = totalNum + 1
	end

	-- 获取问题
	local randNum = math.random(1, totalNum)
	local index = 1
	for i,v in pairs(LifeDeathBook) do
		if index == randNum then
			self.NpcName = v.name
			break
		end
		index = index + 1
	end

	randNum = math.random(1, totalNum)
	index = 1
	for i,v in pairs(LifeDeathBook) do
		if index == randNum then
			self.result = v.result
			print("正确答案是 " .. v.result)
			self.Panel_play.Text_desc:setString(v.event)
			break
		end
		index = index + 1
	end

	-- 重置按钮位置
	self.Panel_play.Button_1:setPosition(cc.p(540, 700))
	self.Panel_play.Button_2:setPosition(cc.p(540, 850))
	self.Panel_play.Button_3:setPosition(cc.p(540, 1000))
	self:showButtonAim({self.Panel_play.Button_3, self.Panel_play.Button_2, self.Panel_play.Button_1}, 0)
end

function LifeDeathBookLayer:showLayer(func1, func2, func3, func4)
	if func1 == nil then
		func1 = function()
		end
	end
	self.func1 = func1

	if func2 == nil then
		func2 = function()
		end
	end
	self.func2 = func2

	if func3 == nil then
		func3 = function()
		end
	end
	self.func3 = func3

	if func4 == nil then
		func4 = function()
		end
	end
	self.func4 = func4

	self.Panel_start:setVisible(true)
	self.Panel_play:setVisible(false)
	self.Panel_play.Button_leave:setVisible(false)
	self:show()
end

function LifeDeathBookLayer:start()
	self.Panel_start:setVisible(false)
	self.Panel_play:setVisible(true)
	self:initData()
	self:getQuestion()
end

function LifeDeathBookLayer:setBack()
	self.Panel_back:releaseFunc(function()
		--self:hide()
	end)
end

-- 检测是否结束答题 10题答完
function LifeDeathBookLayer:nextQuestion()
	self:updateText()
	self.Panel_play.Text_desc:setString("")
	self:showButtonAim({self.Panel_play.Button_3, self.Panel_play.Button_2, self.Panel_play.Button_1}, 1)

	if self.totalCount >= 10 or self.errorCount >= 3 then

		if self.errorCount == 0 then
			self.Panel_play.Text_desc_1:setString("YEL崔判官：嗯，做的很好，我很满意，这是你的奖励。")
		elseif self.errorCount == 1 then
			self.Panel_play.Text_desc_1:setString("YEL崔判官：差一点就完美了，日后还需多加努力才是，这是你的奖励，拿去吧。")
		elseif self.errorCount == 2 then
			self.Panel_play.Text_desc_1:setString("YEL崔判官：做的不错，若能再认真些就好了，这是你的奖励，拿去吧。")
		elseif self.errorCount == 3 then
			self.Panel_play.Text_desc_1:setString("HIR崔判官：唉，你太让我失望了，做事如此不认真，如何能够处理好这生死大事。")
		end

		self.Panel_play.Button_leave:setVisible(true)

		local points =
		{
			[0] = 480,
			[1] = 200,
			[2] = 100,
			[3] = 0,
		}
		local role = User:getRole()
		--答题的时候判断是否带面具
		local mianju = role:getPortraitId()
		local effectData = 1
		local need = 0
		if mianju == "mianju1069" or mianju == "mianju1070" or mianju == "mianju1151" then
			effectData = 1.25
			need = 1 
		end
		if  GetTime() > Helper:getTimeStampWithStringDate("20210820", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20210903", 0) then 
			effectData=effectData+0.25
		end
		local point = points[self.errorCount]*effectData
		HttpManagerEx:addDeadCurrency(2, point, need, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data.number > 0 then
						PopText("冥币 + " .. data.number .. "亿")
					end
					-- role:setDayFlag("生死簿玩法", role:getDayFlag("生死簿玩法") + 1)
					role:setFlag("生死簿玩法", role:getFlag("生死簿玩法") + 1)
					role:setFlag("生死簿结束时间",GetTime())
					if self.errorCount == 0 then
						self.func1()
					elseif self.errorCount == 1 then
						self.func2()
					elseif self.errorCount == 2 then
						self.func3()
					elseif self.errorCount == 3 then
						self.func4()
					end
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)

	else
		self:delayFunc(1, function()
			self:getQuestion()
		end)
	end
end

function LifeDeathBookLayer:updateText()
	self.Panel_play.Text_surplusCount:setString("『剩余次数』" .. Helper:numberCast(10 - self.totalCount))
	self.Panel_play.Text_errorCount:setString("『错判』" .. Helper:numberCast(self.errorCount))
end

function LifeDeathBookLayer:setButton()
	-- 打入地狱
	self.Panel_play.Button_1:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self.totalCount = self.totalCount + 1
		if self.result == "打入地狱" then
			print("回答正确")
			self.Panel_play.Text_desc_1:setString("HIC崔判官：做的不错，还需继续努力才是。")
			self.rightCount = self.rightCount + 1
		else
			print("回答错误")
			self.Panel_play.Text_desc_1:setString("RED崔判官：生死之事岂可儿戏，这次错误便算了，日后你还需更加认真才是。")
			self.errorCount = self.errorCount + 1
		end

		self:nextQuestion()
	end)

	-- 阳寿未尽
	self.Panel_play.Button_2:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self.totalCount = self.totalCount + 1
		if self.result == "阳寿未尽" then
			print("回答正确")
			self.Panel_play.Text_desc_1:setString("HIC崔判官：做的不错，还需继续努力才是。")
			self.rightCount = self.rightCount + 1
		else
			print("回答错误")
			self.Panel_play.Text_desc_1:setString("RED崔判官：生死之事岂可儿戏，这次错误便算了，日后你还需更加认真才是。")
			self.errorCount = self.errorCount + 1
		end

		self:nextQuestion()
	end)

	-- 寿终入簿
	self.Panel_play.Button_3:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self.totalCount = self.totalCount + 1
		if self.result == "寿终入簿" then
			print("回答正确")
			self.Panel_play.Text_desc_1:setString("HIC崔判官：做的不错，还需继续努力才是。")
			self.rightCount = self.rightCount + 1
		else
			print("回答错误")
			self.Panel_play.Text_desc_1:setString("RED崔判官：生死之事岂可儿戏，这次错误便算了，日后你还需更加认真才是。")
			self.errorCount = self.errorCount + 1
		end

		self:nextQuestion()
	end)

	-- 开始游戏
	self.Panel_start.Button_confirm:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self:start()
	end)

	-- 离开
	self.Panel_start.Button_leave:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		PopupLayerController:hideLayer("LifeDeathBookLayer", function(layer)
			self:hide()
		end, 0)
	end)

	self.Panel_play.Button_leave:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		PopupLayerController:hideLayer("LifeDeathBookLayer", function(layer)
			self:hide()
		end, 0)
	end)
end

-- 显示按钮动画
function LifeDeathBookLayer:showButtonAim(btnList, isInOut)
	if MapIsEmpty(btnList) == true then
		return
	end

	local animDuration = 0.25
	local function buttonAnim(button, dir, isInOut)
		local x = button:getPositionX()
		local y = button:getPositionY()
		local offsetsXY = {{-250, 0}, {250, 0}, {-250, 0}}
		button:setOpacity(isInOut * 255)

		if isInOut == 0 then
			button:setTouchEnabled(true)
			button:setPosition(button:getPositionX() + offsetsXY[dir][1], button:getPositionY() + offsetsXY[dir][2])
			button:runAction(YXEaseAction:create( cc.Spawn:create(
				cc.MoveTo:create(animDuration, cc.p(x, y) ) ,
				cc.FadeIn:create(animDuration)
			),  Sine_EaseOut ))
		else
			button:setTouchEnabled(false)
			button:runAction(YXEaseAction:create( cc.Spawn:create(
				cc.MoveTo:create(animDuration, cc.p( button:getPositionX() - offsetsXY[dir][1], button:getPositionY() - offsetsXY[dir][2]) ) ,
				cc.FadeOut:create(animDuration)
			),  Sine_EaseOut ))
		end
	end

	local index = 1
	for k,v in pairs(btnList) do
		buttonAnim(v, index, isInOut)
		index = index + 1
	end
end

--	每周刷新生死簿

Helper:classDefNodeGetInstance(LifeDeathBookLayer)

return LifeDeathBookLayer00000000000
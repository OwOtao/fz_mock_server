-- add by XiaoZhiWei 2017/09/13 19:21:48 未调用

-- -- 抽签界面
-- local DrawLotteryLayer = class("DrawLotteryLayer", LayerEx)

-- local DrawLottery = require("script.others.livediebook")["抽签"]

-- function DrawLotteryLayer:create()
-- 	local p = DrawLotteryLayer:new()
-- 	p:init()
-- 	return p
-- end

-- function DrawLotteryLayer:init()
-- 	self._UI = require("Layer/PopUI/DrawLotteryUI.lua").create()['root']
-- 	self._UI:addTo(self)

-- 	Helper:convertUIByParent(self)
-- 	self:setShowAndHideAnimType("ROLL")

-- 	self:setButton()
-- end

-- -- 开始抽签
-- function DrawLotteryLayer:start()
-- 	self.Text_desc:setString("你闭目静心，诚心祈祷，手拿签筒慢慢摇着....")
-- 	self.Button_draw:setVisible(false)
-- 	self.Button_leave:setVisible(false)
-- 	self.Button_stop:setVisible(true)

-- 	local animOffset = 5
-- 	local interval = 0.111

-- 	local action = cc.RepeatForever:create(
-- 	cc.Sequence:create(
-- 	cc.MoveBy:create(interval, cc.p(0, animOffset + 3)),
-- 	cc.MoveBy:create(interval, cc.p(0, -(animOffset + 3))),
-- 	cc.MoveBy:create(interval, cc.p(0, animOffset)),
-- 	cc.MoveBy:create(interval, cc.p(0, -animOffset)),
-- 	cc.MoveBy:create(interval, cc.p(0, animOffset)),
-- 	cc.MoveBy:create(interval, cc.p(0, -animOffset))))

-- 	self.Text_desc:runAction(action)
-- end

-- -- 停止抽签
-- function DrawLotteryLayer:stop()
-- 	self.Text_desc:stopAllActions()
-- 	self.Button_stop:setVisible(false)
-- 	self.Button_divination:setVisible(true)

-- 	local count = 0
-- 	for k,v in pairs(DrawLottery) do
-- 		count = count + 1
-- 	end

-- 	local randNum = math.random(1, count)
-- 	local index = 1
-- 	for k,v in pairs(DrawLottery) do
-- 		if index == randNum then
-- 			self.lottery = v
-- 		end
-- 		index = index + 1
-- 	end
-- 	self.Text_desc:setString("一根长签掉落在地上，签上数字为：" .. self.lottery.num)
-- end

-- -- 解签
-- function DrawLotteryLayer:decrypt()
-- 	self.Button_divination:setVisible(false)
-- 	self.Button_leave:setVisible(true)
-- 	self.Text_desc:setString("楚巡：" .. self.lottery.text)
-- end

-- function DrawLotteryLayer:showLayer()
-- 	self:show()
-- end

-- function DrawLotteryLayer:initData()
-- 	self.lottery = nil
-- end

-- function DrawLotteryLayer:setButton()
-- 	self.Button_draw:releaseFunc(function()
-- 		Audio:playEffect("xiaoAnNiu")
-- 		self:start()
-- 	end)

-- 	self.Button_leave:releaseFunc(function()
-- 		Audio:playEffect("xiaoAnNiu")
-- 		self:hide(function()
-- 			self:removeFromParent(true)
-- 		end)
-- 	end)

-- 	self.Button_stop:releaseFunc(function()
-- 		Audio:playEffect("xiaoAnNiu")
-- 		self:stop()
-- 	end)

-- 	self.Button_divination:releaseFunc(function()
-- 		Audio:playEffect("xiaoAnNiu")
-- 		self:decrypt()
-- 	end)
-- end

-- Helper:classDefNodeGetInstance(DrawLotteryLayer)

-- return DrawLotteryLayer0000000
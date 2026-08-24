cc.FileUtils:getInstance():purgeCachedEntries()

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

-- 设置错误日志回调方法
local debugCallback = nil
function SetDebugFunc(func)
	debugCallback = func
end

-- 错误日志回调
__G__TRACKBACK__ = function(msg)
	local msg = debug.traceback(msg, 3)
	if debugCallback then
		debugCallback(msg)
	else
		print(msg)
		print(debug.traceback())
	end
	-- print(msg)
	return msg
end

-- 创建回调
function MainScene:onCreate()
	local status, msg = xpcall(
	function()
		self:startGame()
	end, __G__TRACKBACK__)
	if not status then
		print(msg)
		print(debug.traceback())
	end
end

-- local onlyId = 0
-- function cc.Node:delayFunc(delay, func)
--     if delay == nil or delay < 0 then
--         func(self)
--         return
--     end
-- 	onlyId = onlyId + 1
--     local actionTag = onlyId
--     local action = cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(
--         function()
--             func(self)
--         end))
--     action:setTag(actionTag)
--     self:runAction(action)
--     return actionTag
-- end

-- 开始游戏
function MainScene:startGame()
	--记录是否登录
	cc.UserDefault:getInstance():setStringForKey("inGame", "Y")

	if device.platform == "android" then
		self:startGameForAndroid()
	elseif device.platform == "ios" then
		self:startGameForIOS()
	elseif device.platform == "windows" then
		self:startGameForAndroid()
	else
	end

	-- local leftRoleAnim = assert(YXSkeletonAnimation:createWithFile("Anim/gongfu1/gongfu.skel", "Anim/gongfu1/gongfu.atlas", 1), "动画初始化出错")
	-- leftRoleAnim:addTo(self)
	-- leftRoleAnim:setPosition(cc.p(500, 500))

	-- local rightRoleAnim = assert(YXSkeletonAnimation:createWithFile("Anim/gongfu1/gongfu.skel", "Anim/gongfu1/gongfu.atlas", 1), "动画初始化出错")
	-- rightRoleAnim:addTo(self)
	-- rightRoleAnim:setPosition(cc.p(600, 500))
	-- rightRoleAnim:setAnimation(0, "Kenpo/Tctf/stand", true) 
	-- rightRoleAnim:setScaleX(-1)
	
	-- leftRoleAnim:setAnimation(0, "Kenpo/Tctf/Tcdq_1", true)

	-- leftRoleAnim:registerSpineEventHandler(function(event)
	-- 	-- print("event", ...) 
	-- 	for k, v in pairs(event.eventData) do
	-- 		print(k, v)
	-- 	end

	-- 	rightRoleAnim:setAnimation(0, "zBeifen/barehand-hurt-" .. event.eventData.stringValue, false)
	-- end, 5)

	-- self:onUpdate(function()
	-- 	local boneData = leftRoleAnim:getBonePosition("AttackPosition")
	-- 	-- print(boneData.x, boneData.y)

	-- 	rightRoleAnim:setPosition(cc.p(500 + boneData.x, 500 + boneData.y))
	-- end)


	-- local animationEvents = leftRoleAnim:getAnimEvents("Kenpo/Tctf/Tcdq_1")
	-- print("animationEvents:", animationEvents)

	-- for k, v in pairs(animationEvents) do
	-- 	print(k, v)

	-- 	for k, v in pairs(v) do
	-- 		print(k, v)
	-- 	end
	-- end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/15 17:40:40
-- @desc IOS平台启动流程
function MainScene:startGameForIOS()
	local GameAdvice = require("app.views.GameAdvice")
	local gameAdvice = GameAdvice:create()
	
	self:addChild(gameAdvice)
	gameAdvice:setOpacity(0)	
	local action =
		cc.Sequence:create(
			cc.FadeIn:create(0.5),
			cc.DelayTime:create(2),
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function ()
				Game = require("app.models.game.Game")
				Game:start(function()
				end) -- 开始游戏
			end),
			cc.RemoveSelf:create()	
		)
	gameAdvice:runAction(action)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/15 17:35:17
-- @desc 安卓平台启动流程
function MainScene:startGameForAndroid()
	-- 如果不是从我们的应用进入游戏, 则踢出游戏
	if device.platform == "android" then
		if string.find(cc.FileUtils:getInstance():getWritablePath(), "com.iplay.assistant") 
		or string.find(cc.FileUtils:getInstance():getWritablePath(), "sandbox") then
			cc.Director:getInstance():endToLua()
			return
		end
	end
	local info = SdkMethod:getDevInfo()
	local jsonInfo = json.decode(info)
	
	if jsonInfo.app_channel == "4399" then
		local action =
		cc.Sequence:create(
			-- cc.FadeIn:create(0.5),
			cc.DelayTime:create(0),
			-- cc.FadeOut:create(0.5),
			cc.CallFunc:create(function ()
				Game = require("app.models.game.Game")
				Game:start(function()
				end) -- 开始游戏
			end)
			-- cc.RemoveSelf:create()	
		)
		self:runAction(action)
	else 
		local action =
		cc.Sequence:create(
			cc.FadeIn:create(0.5),
			cc.DelayTime:create(2),
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function ()
				Game = require("app.models.game.Game")
				Game:start(function()
				end) -- 开始游戏
			end)
			-- cc.RemoveSelf:create()	
		)
		local GameAdvice = require("app.views.GameAdvice")
		local gameAdvice = GameAdvice:create()
		self:addChild(gameAdvice)
		gameAdvice:runAction(action)
	end
end

return MainScene
0000000
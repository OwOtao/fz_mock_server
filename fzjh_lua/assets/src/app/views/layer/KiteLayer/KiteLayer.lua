-- 放风筝界面
local KiteLayer = class("KiteLayer", LayerEx)

-- 上升高度描述
local heightUpDesc =
{
	[1] = "CYN你正在放线，风筝稳步上升，离你已有数丈之遥。",
	[8] = "CYN你正在放线，风托着风筝稳步上升，越飞越高。",
	[15] = "CYN你正在放线，风筝乘着风越飞越高，离你原来越远。",
	[20] = "CYN你正在放线，风筝飞向高处，你已经很难看清它的图案了。",
	[25] = "CYN你正在放线，风筝向高处飞去，在你眼中越来越小。",
	[30] = "CYN你正在放线，风筝越飞越远，在你眼里它只有铜钱大小了。",
	[35] = "CYN你正在放线，风筝飞得越来越高，轮廓也越来越模糊了。",
	[45] = "CYN你正在放线，风筝的轮廓你已经看不到了，渐渐地成了一个黑点。",
	[52] = "CYN你正在放线，空中的黑点越来越小，若是再高一些，只怕是看不到了。",
	[60] = "CYN你正在放线，黑点消失了！你手中的风筝线也断了，风筝不知飘往了何处。",
}

-- 下降高度描述
local heightDownDesc =
{
	[1] = "CYN你尝试收线，风筝已经飞得很低了，再低就飞不了了，再点一次可以收回风筝。",
	[7] = "CYN你正在收线，风筝缓缓从高处缓缓降落，离你约有数丈之遥。",
	[14] = "CYN你正在收线，在你控制之下，风筝飞的越来越低。",
	[19] = "CYN你正在收线，风筝从高处降落，风筝上的图案越来越清晰。",
	[24] = "CYN你正在收线，风筝在你的控制下，缓缓下降，你抬头可以看到风筝上的图案了。",
	[29] = "CYN你正在收线，风筝缓缓下降，在你眼中越来越大。",
	[34] = "CYN你正在收线，风筝的轮廓越来越清晰，你隐约看到风筝的图案了。",
	[44] = "CYN你正在收线，黑点逐渐清晰，隐约能看见风筝的轮廓。",
	[51] = "CYN你正在收线，空中的黑点变大了一些。",
	[59] = "CYN你正在收线，高空中的黑点似乎变大了一些。",
}

-- 风筝状态文本
local stateDesc =
{
	[0] = "HIW风筝并无任何偏转，飞的十分漂亮。",
	[1] = "CYN风筝稍稍向$x偏转，不过依旧十分稳当。 ",
	[2] = "CYN风筝此时向$x倾斜着，不过飞得还算稳当。",
	[3] = "YEL风筝往$x倾倒，飞得十分不稳，你需要控制一下了！",
	[4] = "YEL风筝在风中颠簸，向$x翻着跟头，快做些什么！",
	[5] = "RED风筝在风中颠簸，向$x翻着跟头，就快要不行了！",
	[6] = "HIY风筝摇摇欲坠，已经控制不了！",
}

-- 风力描述
local windyDesc =
{
	[1] = "CYN一阵微风吹过	$x也随之向$s偏了偏。",
	[2] = "GRN一阵轻风吹过	$x向$s一偏。",
	[3] = "YEL一阵疾风吹过	$x向$s猛地一偏。",
	[4] = "HIY一阵大风吹过	吹得$x往$s颤抖不已。",
	[5] = "HIR一阵狂风吹过	吹得$x朝$s在空中翻了几圈。",
}

-- 不同高度的风力间隔
local windLevel =
{
	[1] = 6,
	[2] = 5.5,
	[3] = 5,
	[4] = 4.5,
	[5] = 4,
}

local rewardDesc =
{
	[0] = "CYN你的风筝在低空飞行，没什么人看你，还是将风筝放高一些吧。",
	[15] = "CYN你的风筝飞的十分平稳，这让你怡然自得。",
	[25] = "HIC你的风筝飞的十分漂亮，让不少人赞叹不已，这让你十分开心。",
	[35] = "HIY你将风筝放得高高地，引来了周围人的关注，纷纷称赞你的手法高超 ",
	[45] = "RAN你的风筝放的又高又好，孩子们高兴地纷纷看向你的风筝，欢声笑语充斥着你的周围。",
	[55] = "HIR你的风筝在高空飞行，仿佛是你手中用长线牵着的一头雄鹰，在空中自由翱翔，令围观群众拍手叫好。",
	[60] = "HIR你的风筝越飞越远，在空中逐渐变成了一个小黑点，高空上阵阵罡风袭来，你手上的长线左右摆动，引得四下惊叹连连。",
}

local overDesc = "风筝放飞高空，你也不由得心情大好，别忘了寻找刘鹤君兑换奖励。"

local rewardList = {
	[1] = {
		itemId = "",
		rewardType = "物品",
	},
	[2] = {
		itemId = "",
		rewardType = "物品",
	},
	[3] = {
		itemId = "",
		rewardType = "物品",
	},
	[4] = {
		itemId = "",
		rewardType = "物品",
	},
}
function KiteLayer:create()
	local p = KiteLayer:new()
	p:init()
	return p
end

function KiteLayer:init()
	self._UI = require("Layer/KiteUI/KiteUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

	-- self:setBackEnabled(false)
	self:setShowAndHideAnimType("ROLL")
	self:setBack()
end

-- 初始化基本数据
function KiteLayer:initData()
	self:initRichText()

	-- 风筝状态
	self.kiteState = 0

	-- 风筝上升下降状态 1 上升中 0 静止 -1 下降
	self.UpDownState = 0

	-- 按一次上下移动一丈，1秒内完成，0.1秒移动0.1丈
	self.moveCount = 0

	-- 记录上下移动时间
	self.moveTime = 0

	-- 风筝方向 1右 2左
	self.kiteDirection = 0

	-- 风筝高度
	self.kiteHeight = 1

	-- 风筝最高的高度
	self.kiteBestHeight = 1

	-- 放飞总时间
	self.totalTime = 0

	-- 放风筝过程中高度潜能奖励
	self.potReward=0

	-- 放风筝过程中高度经验奖励
	self.expReward=0

	-- 上次刮风时间
	self.windyTime = 0

	-- 刮风间隔
	self.windyInterval = 0

	-- 开始时间
	self.startTime = GetTime()

	-- 领取奖励次数
	self.rewardTimes = 0

	-- 耐力
	self.endurance = 100

	-- 耐力条
	self:setEnduranceBar()

	-- 放线收线文本显示时间 每2秒显示一次
	self.showTextTime = 0

	-- 上一次显示文本，每2秒再显示一次
	self.showText = ""

	-- 是否游戏结束
	self.isOver = false

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	local text =
	{
		[1] = "HIW你在风筝上写上了自己的愿望，你用手托着风筝用力一掷，风筝顺着你投掷的方向飞了出去，稳稳地飞在了天上。",
		[2] = "HIW你在风筝上写上了自己的愿望，你运起内力汇于手掌，用力一掷，风筝似箭一般冲了出去，随后稳稳地飞在了天上。"
	}

	self:print(text[math.random(1,2)])

	self:showButtonAnimation({self.Panel_play.Button_up, self.Panel_play.Button_down, self.Panel_play.Button_left, self.Panel_play.Button_right}, 0)

	self._handle = self:schedule(function (ft)
		self:update(ft)
	end,1/10)

	Audio:playEffect("windyFly", false)
	Audio:playEffect("windyContinued", true)
end

-- 初始化输出框
function KiteLayer:initRichText()
	local x, y = self.Panel_play.Text_desc_1:getPosition()
	local size = self.Panel_play.Text_desc_1:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_play.Text_desc_1:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_play.Text_desc_1:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)
end

function KiteLayer:print(str, verticalSpace)
	if str == "" then
		return
	end
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 36)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end

-- 根据当前高度方向输出文本
function KiteLayer:printHeightDesc()
	local str = ""
	if self.UpDownState == 1 then
		for i,v in pairs(heightUpDesc) do
			if self.kiteHeight == tonumber(i) then
				print(self.kiteHeight .. " == " .. tonumber(i))
				str = v
				break
			end
		end
	elseif self.UpDownState == -1 then
		for i,v in pairs(heightDownDesc) do
			if self.kiteHeight == tonumber(i) then
				print(self.kiteHeight .. " == " .. tonumber(i))
				str = v
				break
			end
		end
	end

	if str ~= "" then
		self.showText = str
		self:print(str)
		self.showTextTime = GetTime()
	end
end

-- 更新文本
function KiteLayer:updateText()
	local currTime = GetTime()
	local totalTime = math.ceil((currTime - self.startTime))
	if totalTime <= 0 then
		totalTime = 0
	end
	self.totalTime=totalTime
	self.Panel_play.Text_time:setString("『放飞时间』 " .. totalTime .. "秒")

	self.Panel_play.Text_height:setString("『高度』 " .. self.kiteHeight .. "丈")

	local dir = ""
	if self.kiteDirection == 1 then
		dir = "右"
	elseif self.kiteDirection == 2 then
		dir = "左"
	end
	local str = string.gsub(stateDesc[self.kiteState], "$x", dir)
	self.Panel_play.Text_desc_1_0:setString(str)
end

-- 更新风筝高度
function KiteLayer:updateHeight()
	local currTime = GetTime()

	--放风筝上升体力消耗速度因子
	local fly_tili_cost_factor = 0.1
	-- 上升速度
	local upSpeed =
	{
		[1] = 10 * fly_tili_cost_factor,
		[2] = 15 * fly_tili_cost_factor,
		[3] = 20 * fly_tili_cost_factor,
		[4] = 25 * fly_tili_cost_factor,
		[5] = 30 * fly_tili_cost_factor,
		[6] = 50 * fly_tili_cost_factor,
	}
	-- 下降速度
	local downSpeed =
	{
		[1] = 75,
		[2] = 70,
		[3] = 65,
		[4] = 60,
		[5] = 55,
		[6] = 50,
	}
	local speedLevel = math.ceil(self.kiteHeight / 10)
	if speedLevel <= 0 then
		speedLevel = 1
	elseif speedLevel >= 6 then
		speedLevel = 6
	end

	if self.UpDownState == 0 then
		-- 静止
	elseif self.UpDownState == 1 then
		-- 上升
		local rate = 0.5 + ( 1 * self.endurance / 100)
		self.endurance = self.endurance - (currTime - self.moveTime) * upSpeed[speedLevel] * rate
		if self.endurance < 0 then
			self.endurance = 0
			self.UpDownState = 0
			local desc =
			{
				[1] = "HIB风筝停在高处不动了，你可能需要收线才能放的更高。",
				[2] = "HIB风筝勉强维持住了现有的高度，纵是你放线似乎也不能飞得再高了。"
			}
			self.showText = desc[math.random(1,2)]
			--self:print(self.showText)
		end

		self:setEnduranceBar()
		if currTime - self.moveTime >= 0.05 then
			self:printHeightDesc()
			self.kiteHeight = self.kiteHeight + 0.12
			self.kiteHeight = tonumber(string.format("%.1f", self.kiteHeight))
			self.moveTime = self.moveTime + 0.05
		end
	elseif self.UpDownState == -1 then
		-- 下降
		local rate = 1.5 - ( 1 * self.endurance / 100)
		self.endurance = self.endurance + (currTime - self.moveTime) * downSpeed[speedLevel] * rate
		if self.endurance >= 100 then
			self.endurance = 100
		end
		self:setEnduranceBar()

		if currTime - self.moveTime >= 0.05 then
			self.kiteHeight = self.kiteHeight - 0.1
			self.moveTime = self.moveTime + 0.05
			self.kiteHeight = tonumber(string.format("%.1f", self.kiteHeight))

			if self.kiteHeight < 1 then
				self.moveCount = 0
				self.kiteHeight = 1
				self.UpDownState = 0
			end

			self:printHeightDesc()
		end
	end

	if currTime - self.showTextTime >= 2 then
		self.showTextTime = GetTime()
		if self.showText ~= "" then
			self:print(self.showText)
		end
	end

	if self.kiteHeight >= 60 then
		self.kiteHeight = 60
	end

	if self.kiteHeight > self.kiteBestHeight then
		self.kiteBestHeight = self.kiteHeight
	end

	if self.kiteHeight >= 60 then
		self.UpDownState = 0
		self:gameOver("HIW黑点消失在你的视线之中，你手中的风筝线也断了，风筝随着风飞向了远方，再不见踪迹..")
	end

end

-- 刮风
function KiteLayer:windy()
	--测试不刮风
	if self._testWindyClose then
		return
	end

	-- 高度小于五不刮风
	if self.kiteHeight < 5 then
		return
	end

	local randomHeight = 30
	if self._testRandomHeight then
		randomHeight = self._testRandomHeight
	end

	local currTime = GetTime()
	if currTime - self.windyTime >= self.windyInterval then
		self.windyTime = GetTime()

		if self.kiteDirection == 0 then
			self.kiteDirection = math.random(1,2)
		end

		local power = math.floor(self.kiteHeight / 10) < 1 and 1 or math.floor(self.kiteHeight / 10)

		self.windyInterval = math.random(randomHeight, windLevel[power] * 10) / 10

		self.kiteState = self.kiteState + power
		if self.kiteState >= 6 then
			self.kiteState = 6
			self:gameOver("HIW风筝摇摆不定，终是控制不住，从空中坠落！")
		end

		local str = windyDesc[power]

		if self.kiteDirection == 1 then
			str = string.gsub(str, "$s", "右")
		elseif self.kiteDirection == 2 then
			str = string.gsub(str, "$s", "左")
		end
		if self.kiteHeight >= 45 then
			str = string.gsub(str, "$x", "黑点")
		else
			str = string.gsub(str, "$x", "风筝")
		end

		self:print(str)
	end
end

-- 获得奖励
function KiteLayer:getReward()
	local rewardHeight = 
	{
		["attrs"] = {
			---  exp,pot
			[0]  = {0,0},
			[15] = {75,150},
			[25] = {150,300},
			[35] = {225,450},
			[45] = {750,1500},
			[55] = {1500,3000},
			[60] = {7500,7500},
		}
	}

	local rewardLevel = {0,15,25,35,45,55,60}

	local attrsReward = rewardHeight["attrs"]
	local level,desc = 0,""
	for i,v in pairs(attrsReward) do
		if self.kiteHeight >= i then
			level = math.max(level,i)
		end
	end
	desc = rewardDesc[level]
	local exp,pot = attrsReward[level][1],attrsReward[level][2]
	
	if DEBUG_MODE == 1 then 
		exp = exp * 10
		pot = pot * 10
	end

	local role = User:getRole()

	local POTMAX,EXPMAX= 12900,10200

	local function buffValueFun(attr_name,add_value)
		if self.haveYuHuiLing ~= true then 
			return 0
		end 
		local currBuffValue = role:getDayFlag("yuhuiling_"..attr_name)
		local addBuffValue = add_value * YUHUILING_BUFF
		if addBuffValue > YUHUILING_NUM_LIMIT - currBuffValue then 
            addBuffValue = math.max(YUHUILING_NUM_LIMIT - currBuffValue,0)
        end
        if addBuffValue > 0 then 
        	role:setDayFlag("yuhuiling_"..attr_name,currBuffValue + addBuffValue)
        end
        return addBuffValue
	end	

	local function addAttrRewards(attr_name,total_value,add_value,max_value)
		if total_value >= max_value then 
			return 
		end
		
		local buffAdd = buffValueFun(attr_name,add_value)
		if buffAdd > 0 then 
			role:addAttr(attr_name ,buffAdd)
		end

		if total_value + add_value > max_value then 
			add_value = max_value - total_value
		end

		if add_value > 0 then
			role:addAttr(attr_name ,add_value)
			PopText("获得"..role:getCHAttrName(attr_name).." " .. math.floor(add_value + buffAdd))
		end
	end

	if rewardLevel[self.rewardTimes + 1] and self.kiteHeight >= rewardLevel[self.rewardTimes + 1] then
		self.rewardTimes = self.rewardTimes + 1
		-- 奖励上限
		addAttrRewards("pot",self.potReward,pot,POTMAX)
		self.potReward = self.potReward + pot

		addAttrRewards("exp",self.expReward,exp,EXPMAX)
		self.expReward = self.expReward + exp
		
		self:print(desc)
	end
end

-- 更新
function KiteLayer:update(ft)
	self:windy()
	self:updateHeight()
	if self.flyKiteType ~="shiwan" then
		self:getReward()
	end
	self:updateText()
end

function KiteLayer:showLayer(haveYuHuiLing)  --分为试玩和正式
	self.flyKiteType="normal"
	User:getRole():setFlag("PVP活动状态","忙碌")
	self.Panel_start:setVisible(true)
	self.Panel_play:setVisible(false)
	self.Panel_over:setVisible(false)
	self.haveYuHuiLing = haveYuHuiLing
	self:setButtons()
	self:show()
	self:startGame()
	
end

function KiteLayer:showTestLayer()
	self.flyKiteType="shiwan"
	User:getRole():setFlag("PVP活动状态","忙碌")
	self.Panel_start:setVisible(false)
	self.Panel_play:setVisible(false)
	self.Panel_over:setVisible(false)
	self:setButtons()
	self:show()
	self:startGame("shiwan")
end

-- 开始游戏
function KiteLayer:startGame(flyType)
	local role =User:getRole()
	if self.flyKiteType ~="shiwan" then 
		role:setDayFlag("weekhztc",role:getDayFlag("weekhztc") + 1 )
	end

	self.Panel_start:setVisible(false)
	self.Panel_play:setVisible(true)
	self.Panel_over:setVisible(false)
	self:initData()
end

-- 游戏结束
function KiteLayer:gameOver(desc)
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	if self.isOver then
		return
	end

	if desc == nil then
		desc = "游戏结束"
	end

	local role = User:getRole()

	if DEBUG_MODE == 1 then 
		self.kiteBestHeight = 20 + self.kiteBestHeight
	end

	local liquanNum = 0
	if self.flyKiteType ~= "shiwan" then 
		local rewardNum = self:__getHeightLiquanRewardNum()

		if rewardNum > 0 then
			role:setInheritFlag("weekhztc_liquan", role:getInheritFlag("weekhztc_liquan") + rewardNum)
			liquanNum = liquanNum + rewardNum
		end

		if role:getInheritFlag("weekhztc_gameTimes") >= 15 then 
			role:setInheritFlag("weekhztc_liquan", role:getInheritFlag("weekhztc_liquan") + 1)
			role:setInheritFlag("weekhztc_gameTimes", 0)
			liquanNum = liquanNum + 1
	    	local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")
	    	ActivityCalendarUtils:getSpecialTitle("weekhztc")
		else
			role:setInheritFlag("weekhztc_gameTimes", role:getInheritFlag("weekhztc_gameTimes") + 1)
		end

		self:__getQiXiLiQuan()
	end

	local str_text = ""
	str_text = "最高高度：" .. self.kiteBestHeight .. "丈"

	if liquanNum > 0 then 
		str_text = "最高高度：" .. self.kiteBestHeight .. "丈，本次获得"..tostring(liquanNum).."张风鸢礼券"
		--记录获得的风鸢礼券
		local logTab = {}
		logTab["风鸢礼券"] = liquanNum
		local Record = require("app.models.Record.Record")
    	Record:addLog(Record.LOG_TYPE.ACTION_FLAG,logTab,"kite")
	end

	self.Panel_over.Text_height:setString(str_text)
	
	if self.flyKiteType =="shiwan" then
		self.Panel_over.Text_height:setString("最高高度：" .. self.kiteBestHeight .. "丈")
	end
	self.Panel_over.Text_desc:setString(desc)

	self:delayFunc(1, function()
		Audio:stopAllEffects()
		self.Panel_over:setVisible(true)
	end)
	User:getRole():setFlag("PVP活动状态","空闲中")
	self.isOver = true
end

function KiteLayer:getDayReward(score)
	local function getRewardList(score,flyType)
		if score >= 0 and score < 10 then
			local reward = {
				[1] = {
					{
						itemId = "breathVal",
						number = 1000,
						type = "属性",
						name = "真气"
					}
				},
				[2] = {
					{
						itemId = "jing",
						number = 16,
						type = "属性",
						name = "精力"
					}
				},
				[3] = {
					{
						itemId = "money",
						number = 5000,
						type = "属性",
						name = "碎银"
					}
				},
				[4] = {
					{
						itemId = "yitannverhong",
						number = 1,
						type = "物品"
					}
				},
			}
			return reward[flyType]
		elseif score >= 10 and score < 30 then
			local reward = {
				[1] = {
					{
						itemId = "breathVal",
						number = 1500,
						type = "属性",
						name = "真气"
					}
				},
				[2] = {
					{
						itemId = "jing",
						number = 24,
						type = "属性",
						name = "精力"
					}
				},
				[3] = {
					{
						itemId = "money",
						number = 8000,
						type = "属性",
						name = "碎银"
					}
				},
				[4] = {
					{
						itemId = "yitannverhong",
						number = 1,
						type = "物品"
					}
				},
			}
			return reward[flyType]
		elseif score >= 30 and score < 60 then
			local reward = {
				[1] = {
					{
						itemId = "breathVal",
						number = 2000,
						type = "属性",
						name = "真气"
					}
				},
				[2] = {
					{
						itemId = "jing",
						number = 32,
						type = "属性",
						name = "精力"
					}
				},
				[3] = {
					{
						itemId = "money",
						number = 10000,
						type = "属性",
						name = "碎银"
					}
				},
				[4] = {
					{
						itemId = "yitannverhong",
						number = 1,
						type = "物品"
					}
				},
			}
			return reward[flyType]
		elseif score >= 60 and score < 100 then
			local reward = {
				[1] = {
					{
						itemId = "breathVal",
						number = 4000,
						type = "属性",
						name = "真气"
					}
				},
				[2] = {
					{
						itemId = "jing",
						number = 48,
						type = "属性",
						name = "精力"
					}
				},
				[3] = {
					{
						itemId = "money",
						number = 15000,
						type = "属性",
						name = "碎银"
					}
				},
				[4] = {
					{
						itemId = "yitannverhong",
						number = 1,
						type = "物品"
					}
				},
			}
			return reward[flyType]
		elseif score >= 100 and score < 190 then
			local reward = {
				[1] = {
					{
						itemId = "breathVal",
						number = 6000,
						type = "属性",
						name = "真气"
					}
				},
				[2] = {
					{
						itemId = "jing",
						number = 64,
						type = "属性",
						name = "精力"
					}
				},
				[3] = {
					{
						itemId = "money",
						number = 20000,
						type = "属性",
						name = "碎银"
					}
				},
				[4] = {
					{
						itemId = "yitannverhong",
						number = 2,
						type = "物品"
					}
				},
			}
			return reward[flyType]
		else
			local reward = {
				[1] = {
					{
						itemId = "breathVal",
						number = 10000,
						type = "属性",
						name = "真气"
					}
				},
				[2] = {
					{
						itemId = "jing",
						number = 100,
						type = "属性",
						name = "精力"
					}
				},
				[3] = {
					{
						itemId = "money",
						number = 30000,
						type = "属性",
						name = "碎银"
					}
				},
				[4] = {
					{
						itemId = "yitannverhong",
						number = 2,
						type = "物品"
					},--chunguijiu1
					{
						itemId = "chunguijiu1",
						number = 1,
						type = "物品"
					}
				},
			}
			return reward[flyType]
		end
	end
	local theFlyType=User:getRole():getDayFlag("风筝类型")
	local reward = getRewardList(score,theFlyType)
	if DEBUG_MODE == 1 then
		if score >100 and score <= 110 then
			local rewards = {
				[1] = {
					{
						itemId = "breathVal",
						number = 4000,
						type = "属性",
						name = "真气"
					}
				},
				[2] = {
					{
						itemId = "jing",
						number = 48,
						type = "属性",
						name = "精力"
					}
				},
				[3] = {
					{
						itemId = "money",
						number = 15000,
						type = "属性",
						name = "碎银"
					}
				},
				[4] = {
					{
						itemId = "yitannverhong",
						number = 1,
						type = "物品"
					}
				},
			}
			reward = rewards[theFlyType]
		elseif score > 110 then
			local rewards = {
				[1] = {
					{
						itemId = "breathVal",
						number = 10000,
						type = "属性",
						name = "真气"
					}
				},
				[2] = {
					{
						itemId = "jing",
						number = 100,
						type = "属性",
						name = "精力"
					}
				},
				[3] = {
					{
						itemId = "money",
						number = 30000,
						type = "属性",
						name = "碎银"
					}
				},
				[4] = {
					{
						itemId = "yitannverhong",
						number = 2,
						type = "物品"
					},--chunguijiu1
					{
						itemId = "chunguijiu1",
						number = 1,
						type = "物品"
					}
				},
			}
			reward = rewards[theFlyType]
		end
	end
	if MapIsEmpty(reward) == true then
		if DEBUG_MODE == 1 then
			print("function KiteLayer:getDayReward(score),",score,theFlyType)
		end
	else
		local role = User:getRole()
		for k,v in pairs(reward) do 
			if v.type == "物品" then
				local itemAttr = role:getOneItemByKey(v.itemId)
				if itemAttr then
					if role:checkCanBuyThings(v.itemId,v.number) == true then
						role:addItemCount(v.itemId,v.number)
						PopText("获得物品"..itemAttr.name.."X"..tostring(v.number))
					else
						local map = role:getCurrMap()
						map:dropItem(map:getCurrRoomId(),v.itemId,v.number)
						MainControllLayer:getLayer("MapLayer"):setNeedRefreshMap()
					end
				end
			else
				role:addAttr(v.itemId,v.number)
				PopText(v.name.."+"..tostring(v.number))
			end
		end
	end 
end

function KiteLayer:setButtons()
	local buttonName = {"经脉有成","神兵材料","财源广进","美酒佳肴"}
	local desc = "小伙子，放风筝的感觉如何，还想不想再试试？老夫这还有风筝，你要愿意，便拿去玩玩吧。"
	for i=1,3 do 
		self.Panel_start["Button_start_"..tostring(i)]:setVisible(true)
		self.Panel_start["Button_start_"..tostring(i)].Text_startButtonName:setString(buttonName[i])
		self.Panel_start["Button_start_"..tostring(i)]:releaseFunc(function()
			Audio:playEffect("xiaoAnNiu")
			self:startGame(i)
		end)
		if self.flyKiteType =="shiwan" then
			self.Panel_start["Button_start_"..tostring(i)]:setVisible(false)
		end
	end
	self.Panel_start.Button_start.Text_startButtonName:setString("美酒佳肴")
	if self.flyKiteType =="shiwan" then
		self.Panel_start.Button_start.Text_startButtonName:setString("试玩")
	end
	desc = "本次风筝大赛各大门派均有弟子参加，奖励丰厚，少侠参与比赛前若看上了什么心仪的奖品只需告知在下即可。且每日只可参与三次，第一次免费，之后嘛就需要少侠付些费用了。"

	self.Panel_start.Text_desc_0:setString(desc)
	self.Panel_start.Button_start:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
			self:startGame(4)
	end)

	self.Panel_start.Button_cancel:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		PopupLayerController:hideLayer("KiteLayer", function(layer)
    		self:hide()
    	end)
	end)

	self.Panel_play.Button_up:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver then
			return
		end

		self.UpDownState = 1
		self.moveTime = GetTime()
	end)

	self.Panel_play.Button_down:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver then
			return
		end

		-- 如果已到达1丈，再往下结束游戏
		if self.kiteHeight == 1 then
			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			local dialog = DialogALayer:getInstance()
			dialog:hide()
			local showStr=self.flyKiteType=="shiwan" and "收线将退出风筝练习，是否确定收线？" or "收线将退出风筝大赛，并扣除今日的一次参与机会，是否确定收线？"
			dialog:show(showStr)
			dialog:setRichText(showStr)
			dialog:setButton1("确定", function()
				self:gameOver("你慢慢收线，风筝缓缓降落在地上。")
			end)

			dialog:setButton2("取消", function()
			end)
			return
		end
		self.UpDownState = -1
		self.moveTime = GetTime()
	end)

	self.Panel_play.Button_left:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver then
			return
		end

		local tar = "风筝"
		if self.kiteHeight >= 45 then
			tar = "黑点"
		end

		-- 字体颜色
		local color = "HIC"
		if self.kiteDirection ~= 1 then
			color = "RED"
		end
		local str = string.gsub(color .. "你向左拉扯风筝线,在你的控制下，$x向左偏了偏。", "$x", tar)
		self:print(str)
		self:pullKite(2)
	end)

	self.Panel_play.Button_right:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver then
			return
		end

		local tar = "风筝"
		if self.kiteHeight >= 45 then
			tar = "黑点"
		end
		-- 字体颜色
		local color = "HIC"
		if self.kiteDirection ~= 2 then
			color = "RED"
		end
		local str = string.gsub(color .. "你向右拉扯风筝线,在你的控制下，$x向右偏了偏。", "$x", tar)
		self:print(str)
		self:pullKite(1)
	end)

	self.Panel_over.Button_return:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.flyKiteType ~="shiwan" and overDesc ~= nil then
			RichPrint("main",overDesc)
		end
		PopupLayerController:hideLayer("KiteLayer", function(layer)
    		self:hide()
    	end)
	end)
end

-- 左右拉线
function KiteLayer:pullKite(direction)
	if direction == self.kiteDirection then
		self.kiteState = self.kiteState + 1
	elseif self.kiteDirection == 0 then
		self.kiteState = self.kiteState + 1
		self.kiteDirection = direction
	else
		self.kiteState = self.kiteState - 1
	end

	-- 状态变为0
	if self.kiteState == 0 then
		self.kiteDirection = 0
	end

	-- 大于等于6 游戏结束
	if self.kiteState >= 6 then
		self.kiteState = 6
		self:gameOver("HIW风筝摇摆不定，终是控制不住，从空中坠落！")
		self:updateText()
	end
end

-- 设置耐力条
function KiteLayer:setEnduranceBar()
	self.Panel_play.LoadingBar:setPercent(self.endurance)
end

function KiteLayer:setBack()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("KiteLayer", function(layer)
    		self:hide()
    	end)
	end)
end

-- 出现动画
function KiteLayer:showButtonAnimation(btnList, isInOut)
	if MapIsEmpty(btnList) == true then
		return
	end

	local animDuration = 0.25
	local function buttonAnim(button, dir, isInOut)
		local offsetsXY = {{0, 150}, {0, -150}, {-300, 0}, {300, 0}}
		button:setOpacity(isInOut * 255)

		if isInOut == 0 then
			button:setPosition(cc.p(540, 400))
			button:runAction(YXEaseAction:create( cc.Spawn:create(
				cc.MoveTo:create(animDuration, cc.p( button:getPositionX() + offsetsXY[dir][1], button:getPositionY() + offsetsXY[dir][2]) ) ,
				cc.FadeIn:create(animDuration)
			),  Sine_EaseOut ))
		else
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

--获得游字令
function KiteLayer:PopYouZiLingText(str1,str2)
	if str1 and str1~="" then 
		PopText(str1)
	end
	if str2 and str2~="" then 
		PopText(str2)
	end
end

function KiteLayer:__getQiXiLiQuan()
	if  GetTime() < Helper:getTimeStampWithStringDate("20210809", 0)  or GetTime() > Helper:getTimeStampWithStringDate("20210816", 0) then
		return
	end 

	HttpManagerEx:addZhounianJifen("qixiliquan3",20,function(status, errcode, errmsg, data)
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
end

function KiteLayer:__getHeightLiquanRewardNum()
	local rate = {
		["35"] = 12,
		["45"] = 17,
		["55"] = 22,
		["60"] = 28,
	}

	if rate[tostring(self.kiteBestHeight)] then
		local random = math.random(1,100)

		return random < rate[tostring(self.kiteBestHeight)] and 1 or 0
	else
		return 0
	end
end

function KiteLayer:setTestWindyOpen()
	self._testWindyClose = false
end

function KiteLayer:setTestWindyClose()
	self._testWindyClose = false
end

function KiteLayer:setTestWindyLevel(data)
	if MapIsEmpty(data) == false then
		windLevel = data
	end
end

function KiteLayer:setRandomHeight(height)
	self._testRandomHeight = height
end

Helper:classDefNodeGetInstance(KiteLayer)

return KiteLayer00000000000
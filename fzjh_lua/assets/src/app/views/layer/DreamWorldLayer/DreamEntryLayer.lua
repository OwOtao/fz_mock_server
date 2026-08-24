local DreamEntryLayer = class("DreamEntryLayer", LayerEx)

local showDreamText = {
	{
		["1"] = {
			"RAN又一个宁静的清晨，",
			"RAN阳光和煦，微风拂面。"
		},
		["2"] = {
			"RAN你再背起了行囊，",
			"RAN踏上了江湖之旅。"
		}
	},
	{
		["1"] = {
			"RAN听着知了的鸣叫，",
			"RAN你掸了掸身上的尘土。"
		},
		["2"] = {
			"RAN感受着一路上的清风，",
			"RAN开始了新一天的行程。"
		}
	},
	{
		["1"] = {
			"RAN在温暖火光的照耀下，",
			"RAN你从营火旁缓缓起身。"
		},
		["2"] = {
			"RAN舒展了一下四肢，",
			"RAN你大踏步走向前方。"
		}
	},
	{
		["1"] = {
			"RAN耳边回响着马蹄声，",
			"RAN马车依旧颠簸无比。"
		},
		["2"] = {
			"RAN你摇了摇昏沉的脑袋，",
			"RAN下车开始了新的旅途。"
		}
	},
}

local showFondDreamText = {
    {
        ["1"] = {
            "RAN你出现在一片迷雾中，",
            "RAN隐隐能听到清脆的落子音。"
        },
        ["2"] = {
            "RAN环顾了一下四周，",
            "RAN只有前方能看见模糊的轮廓，",
            "RAN你大步向前方走去。"
        }
    },
}

local showChallengeText = {
    {
        ["1"] = {
            "RAN此次行事紧急，",
            "RAN你匆忙启程来到此处。"
        },
        ["2"] = {
            "",
            "RAN到达后方才发现因大意忘记携带",
            "RAN平日存放物品的行囊。"
        }
    },
}

local showTextType = {
	DREAM_TEXT = 5,
	FONDDREAM_TEXT = 6,
	CHALLENGE_TEXT = 7,  
}

function DreamEntryLayer:getText(showType)
	if showType == showTextType.DREAM_TEXT then
		return showDreamText
	elseif showType == showTextType.FONDDREAM_TEXT then
		return showFondDreamText
	elseif showType == showTextType.CHALLENGE_TEXT then
		return showChallengeText
	end

	return showDreamText
end

function DreamEntryLayer:create()
	local p = DreamEntryLayer:new()
	p:init()
	return p
end

function DreamEntryLayer:init()
	local UI = require("Layer/DreamWorldUI/DreamEntryUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUI(self) -- 获得所有子节点
end

function DreamEntryLayer:showLayer(mapType,func)
	self._showText = self:getText(mapType)
	self:show()
	self:initText()
	self:initUI()
	self:delayFunc(0.1,function()
		self:FirstTextAction()
	end)
	if func then
		func()
	end
end

function DreamEntryLayer:hideLayer()
	PopupLayerController:hideLayer("DreamEntryLayer",function()
		if self.afterFunc then
			self.afterFunc()
			self.afterFunc = nil
		end
		self.status = nil
		self:hide()
	end)
end

function DreamEntryLayer:setAfterFunc(func)
	if type(func) == "function" then
		self.afterFunc = func
	end
end

function DreamEntryLayer:FirstTextAction()
	self.Node_1:setVisible(true)
    local fisrtMoveTime = 1.5
    local fadeInAndMoveTo = cc.Spawn:create(
		cc.FadeIn:create(fisrtMoveTime),
		cc.MoveBy:create(fisrtMoveTime, cc.p(0, 100))
	)
	local sequenceAct = cc.Sequence:create(
		cc.CallFunc:create(function()
			self:showTouchSwallowLayer()
		end),
		fadeInAndMoveTo,
		cc.CallFunc:create(function()
			self:continueTextAction()
		end),
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			self.status = 1
			self:hideTouchSwallowLayer()
			self.Panel_BG:setTouchEnabled(true)
		end)
	)
	self.Node_1:runAction(sequenceAct)
end

function DreamEntryLayer:SecondTextAction()
	self.Node_2:setVisible(true)
    local secondMoveTime = 1.5
    local fadeInAndMoveTo = cc.Spawn:create(
		cc.FadeIn:create(secondMoveTime),
		cc.MoveBy:create(secondMoveTime, cc.p(0, 200))
	)
	local sequenceAct = cc.Sequence:create(fadeInAndMoveTo,
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			self.Text_7:setVisible(true)
		end),
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			self.status = 2
		end)
	)
	self.Node_2:runAction(sequenceAct)
end

function  DreamEntryLayer:continueTextAction()
	self.Text_7:setVisible(true)
    local animOffset = 5
	local interval = 0.3

	local action = cc.RepeatForever:create(
	cc.Sequence:create(
		cc.MoveBy:create(interval, cc.p(0, animOffset + 3)),
		cc.MoveBy:create(interval, cc.p(0, -(animOffset + 3)))
		)
	)
	self.Text_7:runAction(action)
end

function DreamEntryLayer:initUI()
	self.Node_1:setVisible(false)
	self.Node_2:setVisible(false)
	self.Text_7:setVisible(false)
	self.Node_1:setPositionY(-200)
	self.Node_2:setPositionY(-200)
	self.Node_1:setOpacity(0)
	self.Node_2:setOpacity(0)
	self.Panel_BG:releaseFunc(function()
		if self.status == 1 then
			self:SecondTextAction()
			self.Text_7:setVisible(false)
			self.status = 0
		elseif self.status == 2 then
			self.status = 0
			self:hideLayer()
		end
	end)
end

function DreamEntryLayer:initText()
	self.Text_1:setString("")
	self.Text_2:setString("")
	self.Text_3:setString("")
	self.Text_4:setString("")
	self.Text_5:setString("")
	self.Text_6:setString("")
	local texts = self._showText[math.random(1, #self._showText)]
	local firstText = texts["1"]
	local secondText = texts["2"]
	for i=1,#firstText do
		self["Text_"..i]:setString(firstText[i])
	end

	for i=1,#secondText do
		self["Text_"..i+3]:setString(secondText[i])
	end
end


Helper:classDefNodeGetInstance(DreamEntryLayer)
return DreamEntryLayer
000
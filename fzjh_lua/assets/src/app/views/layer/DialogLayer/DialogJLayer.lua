local DialogJLayer = class("DialogJLayer", cc.Layer)

function DialogJLayer:create()
	local p = DialogJLayer:new()
	p:init()
	return p
end

function DialogJLayer:init()
	self._round = require("Layer/Dialog/Dialog14UI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) 
	self:setVisible(false)

end

local test = {
	[1] = {
		text = "RAN莲花落",
		posY = 1700,
		posX = 200,
		time = 2,
	},
	[2] = {
		text = "莲花落",
		posY = 1600,
		posX = 300,
		time = 1.5,
	},
	[3] = {
		text = "RAN莲花落",
		posY = 1500,
		posX = 400,
		time = 2,
	},
	[4] = {
		text = "莲花落",
		posY = 1400,
		posX = 500,
		time = 1.5,
	},
	[5] = {
		text = "RAN莲花落",
		posY = 1300,
		posX = 550,
		time = 3,
	},
	[6] = {
		text = "HIY莲花落",
		posY = 1200,
		posX = 600,
		time = 2,
	},
	[7] = {
		text = "RAN莲花落",
		posY = 1100,
		posX = 700,
		time = 1.5,
	},
	[8] = {
		text = "BLU莲花落",
		posY = 1000,
		posX = 800,
		time = 1.5,
	},
}
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/19 11:19:26
-- @desc rukou
function DialogJLayer:showLayer(textList,hideFunc)
	-- textList = test
	self:show()
	self.Panel_back:setOpacity(0)
	local action = cc.Sequence:create(
		cc.FadeIn:create(2),
		cc.CallFunc:create(function()
			self:setTextWithAnimation(textList,hideFunc)
		end)
	)
	self.Panel_back:runActionWithName("Panel_back",action)
end

--设置背景音乐
function DialogJLayer:setMusic(name,delayTime)
	if type(name) ~= "string" then
		if DEBUG_MODE == 1 then
			print("-------------------------------------------------------",name)
		end
		return 
	end
	self:delayFunc(Helper:getDef(delayTime,0),function()
		self.musicName = name
		Audio:playMusic(name)
	end)

end 

--
function DialogJLayer:setEffect(name,delayTime)
	if type(name) ~= "string" then
		if DEBUG_MODE == 1 then
			print("-------------------------------------------------------",name)
		end
		return 
	end
	self:delayFunc(Helper:getDef(delayTime,0),function()
		self.effectName = Audio:playEffect(name,true)
	end)
end
function DialogJLayer:setTextWithAnimation(textList,hideFunc)
	local time = 0
	for k,text in ipairs(textList) do 
		time = time + text.time
		self:delayFunc(time,function()
			local Text_Node = self:createTextNode()
			Text_Node:setString(text.text)
			Text_Node:setPosition(Helper:getDef(text.posX,540),text.posY -30)
			Text_Node:setOpacity(0)
			Text_Node:runActionWithName("showAndHide",cc.Spawn:create(
				cc.MoveTo:create(1.5, cc.p(Helper:getDef(text.posX,540), text.posY)),
				cc.FadeIn:create(1.5)
			))

		end)
	end
	self:delayFunc(time + 2,function()
		print("---------------------",self.musicName,self.effectName)
		-- self.Panel_back:releaseFunc(function()
		if self.musicName ~= nil then
			Audio:stopMusic(self.musicName)
		end
		if self.effectName ~= nil then
			Audio:stopEffect(self.effectName)
		end
		if self.musicName ~= nil then
			print("---------------------------------------",self.musicName)
		end
		if type(hideFunc) == "function" then
			hideFunc()
		end
		self:destroyInstance()
		-- end)
	end)
end

function DialogJLayer:createTextNode()
	local Text_Node = self.Text_1:clone()
	Text_Node:addTo(self)
	return Text_Node
end

Helper:classDefNodeGetInstance(DialogJLayer)
return DialogJLayer0000000000
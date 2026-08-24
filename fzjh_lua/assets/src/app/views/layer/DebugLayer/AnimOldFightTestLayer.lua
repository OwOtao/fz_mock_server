local AnimOldFightTestLayer = class("AnimOldFightTestLayer", cc.Layer)

local FondDrSkillAnimUI = require("app.views.layer.FondDrLayer.FondDrSkillAnimUI")

function AnimOldFightTestLayer:create()
	local p = AnimOldFightTestLayer:new()
	p:init()
	return p
end

function AnimOldFightTestLayer:init()
	self._round = require("Layer/DebugUI/AnimTestUI.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点
	
	self:setPanelBack()
end

function AnimOldFightTestLayer:showLayer()
    self:setButton1()
    self:setButton2()
    self:setButton3()
    self:playAnim()
    self:show()
end

function AnimOldFightTestLayer:setIndex(index)
	self.__index = index
end

function AnimOldFightTestLayer:setAnimList(animList)
    self.__animList = animList
end

function AnimOldFightTestLayer:setTital(text)
	self.Text_title:setString(text)
end

function AnimOldFightTestLayer:setTital2(text)
	self.Text_title2:setString(text)
end

function AnimOldFightTestLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)

	self.Image_infoArea:releaseFunc(function()
		self:hideLayer()
	end)
end

function AnimOldFightTestLayer:hideLayer()
	self.__stop = nil

	if self.__anim then
		self.AnimNode_left:removeChild(self.__anim)
		self.__anim = nil
    end
    
	PopupLayerController:hideLayer("AnimOldFightTestLayer",function(layer)
		layer:hide()
	end)
end

function AnimOldFightTestLayer:playAnim()
	self.__anim = Resource:getSkAnim("gongfu")
	self.__anim:setSlotColor("body", cc.c4f(1, 1, 0, 1))
	self.__anim:setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
	self.AnimNode_left:addChild(self.__anim)
    self.__anim:setPosition(0,0)
	self.Shadow:setVisible(false)
	self.__anim:setVisible(true)

	self.__anim:playAnim(self.__animList[self.__index])

	self.__anim:registerSpineEventHandler(function(event)
		if self.__stop == true then
			return
		end

		self.__anim:setToSetupPose()
        self.__anim:setSlotColor("body", cc.c4f(1, 1, 0, 1))
		self.__anim:setSlotColor("body_back", cc.c4f(1, 1, 0, 1))

		self.__index = self.__index + 1

		if self.__index > #self.__animList then
			self.__index = 1 
		end

		local animName = self.__animList[self.__index]

		if animName == nil then
			return
		end

		self:setTital("动画序号 = "..self.__index)

		self:setTital2("动画名 = "..animName)

		self.__anim:playAnim(animName)

	end, sp.EventType.ANIMATION_COMPLETE)
end

function AnimOldFightTestLayer:setButton1()
	self.Button_1:releaseFunc(function()
		self.__stop = true
	end)
end

function AnimOldFightTestLayer:setButton2()
	self.Button_2:releaseFunc(function()
		if self.__stop == true and self.__animList[self.__index] then
			self.__stop = false
			self.__anim:playAnim(self.__animList[self.__index])
		end
	end)
end

function AnimOldFightTestLayer:setButton3()
	self.Button_3:releaseFunc(function()
		self.__index = math.max(self.__index - 2,1)
	end)
end

Helper:classDefNodeGetInstance(AnimOldFightTestLayer)
return AnimOldFightTestLayer000000000000
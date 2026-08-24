local AnimTestLayer = class("AnimTestLayer", cc.Layer)

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FondDrSkillAnimUI = require("app.views.layer.FondDrLayer.FondDrSkillAnimUI")

function AnimTestLayer:create()
	local p = AnimTestLayer:new()
	p:init()
	return p
end

function AnimTestLayer:init()
	self._round = require("Layer/DebugUI/AnimTestUI.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点
	

	self:setPanelBack()
end

function AnimTestLayer:showLayer()
    self._stop = false
    self:setButton1()
    self:setButton2()
    self:setButton3()
    self:playAnim()
    self:show()
end

function AnimTestLayer:setAnimList(animList)
    self._animList = animList
end

function AnimTestLayer:setIndex(index)
	self._index = index
end

function AnimTestLayer:setTital(text)
	self.Text_title:setString(text)
end

function AnimTestLayer:setTital2(text)
	self.Text_title2:setString(text)
end

function AnimTestLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)

	self.Image_infoArea:releaseFunc(function()
		self:hideLayer()
	end)
end

function AnimTestLayer:hideLayer()
	if self._handel then
		self:unschedule(self._handel)
	end
	if self._animLeftUI then
		self._animLeftUI:onDestroy()
		self._animLeftUI = nil
    end
    
	PopupLayerController:hideLayer("AnimTestLayer",function(layer)
		layer:hide()
	end)
end

function AnimTestLayer:playAnim()
	self._animLeftUI = FondDrSkillAnimUI:create(self.AnimNode_left)
	self._animLeftUI:setVisible(true)

	self._time = 0
	self._duration = 0
   
    local anims = self._animList

	self._handel = self:schedule(
        function(ft)
            if self._stop == true then
                return
            end

			self._animLeftUI:onUpdate(ft)
			
			self._time = self._time + ft
			if self._time > self._duration then
				if self._index > #anims then
					self._index = 1
				end
				
                local animName = anims[self._index].anim
                local animResId = anims[self._index].animResId
				local animType = anims[self._index].type
                local duration = AnimResManager:getAnimTime(animName)

				self._duration = duration
				self._animLeftUI:playAnim(animName)
				self:setTital("序号:"..self._index.."     动画资源ID = "..animResId)
				self:setTital2("动画资源名 = "..animName)
				self._index = self._index + 1
				self._time = 0
			end
		end, 0
	)
end

function AnimTestLayer:setButton1()
	self.Button_1:releaseFunc(function()
		self._stop = true
	end)
end

function AnimTestLayer:setButton2()
	self.Button_2:releaseFunc(function()
		self._stop = false
	end)
end

function AnimTestLayer:setButton3()
	self.Button_3:releaseFunc(function()
		self._index = math.max(self._index - 2,1)
	end)
end

Helper:classDefNodeGetInstance(AnimTestLayer)
return AnimTestLayer0000000
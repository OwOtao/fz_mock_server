--
-- Author: Your Name
-- Date: 2018-12-18 11:44:07
--
local ShenZhaoChuanGongLayer=class("ShenZhaoChuanGongLayer", cc.Layer)
function ShenZhaoChuanGongLayer:create()
	local layer=ShenZhaoChuanGongLayer:new()
	layer:init()
	return layer
end
function ShenZhaoChuanGongLayer:init(type)
	self._UI = require("Layer/SkillUI/ShenZhaoChuanGongUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUI(self) -- 获得所有子节点
	self.Panel:releaseFunc(function ()
		if self._isFinish==true then
			if  self._MusicId then 
				Audio:stopEffect(self._MusicId)
				self._MusicId=nil
			end
			PopupLayerController:removeLayer("ShenZhaoChuanGongLayer")
		end
	end)
	if type == 1 then 
		self:showType1()
	elseif type == 2 then 
		self:showType2()
	end
end
function ShenZhaoChuanGongLayer:showType1()
	self._MusicId=Audio:playEffect("shenzhaocg",true)
	self.Image_1:setVisible(true)
	self.Image_1:setScale(0)
	local fadeInAction=cc.FadeIn:create(2)
	local ScaleMax=cc.ScaleTo:create(2, 1, 1)
	local SpawnAciton=cc.Spawn:create(fadeInAction,ScaleMax)
	local delayTime=cc.DelayTime:create(1)
	local delayTime1=cc.DelayTime:create(9)
	self.Image_1:runAction(cc.Sequence:create(SpawnAciton,delayTime,cc.CallFunc:create(function ()
		self:showWord1()
	end),delayTime1,cc.CallFunc:create(function()
		self:showText(self._TextShow)
	end)))
	self.Image_2:setVisible(false)

end

function ShenZhaoChuanGongLayer:showType2()
	self._MusicId=Audio:playEffect("shenzhaocgjs")
	self.Image_1:setVisible(false)
	self.Image_2:setVisible(true)
	self.Image_2:setScale(0)
	local fadeInAction=cc.FadeIn:create(2)
	local ScaleMax=cc.ScaleTo:create(2, 1, 1)
	local SpawnAciton=cc.Spawn:create(fadeInAction,ScaleMax)
	local delayTime=cc.DelayTime:create(1.5)
	local delayTime1=cc.DelayTime:create(4)
	self.Image_2:runAction(cc.Sequence:create(SpawnAciton,delayTime,cc.CallFunc:create(function ()
		self:showWord2()
	end),delayTime1,cc.CallFunc:create(function()
		self:showText(self._TextShow)
	end)))
	
end

function ShenZhaoChuanGongLayer:showText(text)
	if not text then 
	else
		PopText(text)
	end
end

function ShenZhaoChuanGongLayer:showWord1()
	for i=1,10,1 do
		self:delayFunc(1*i,function()
			local wordIndex ="zi_"..tostring(i)
			local word=self[wordIndex]
			word:setVisible(true)
			word:setScale(0)
			word:runAction(cc.ScaleTo:create(1, 1, 1))
			if i==10 then 
				self._isFinish=true
			end
		end) 
	end
end

function ShenZhaoChuanGongLayer:showWord2()
	for i=1,4,1 do
		self:delayFunc(i*1,function()
			local wordIndex ="zi_1"..tostring(i)
			local word=self[wordIndex]
			word:setVisible(true)
			word:setScale(0)
			word:runAction(cc.ScaleTo:create(1, 1, 1))
			if i==4 then 
				self._isFinish=true
			end
		end) 
	end
end

function ShenZhaoChuanGongLayer:showLayer(type,text)
	self._isFinish=false
	self:init(type)
	if not text then 
		text =""
	end
	self._TextShow=text
end
Helper:classDefNodeGetInstance(ShenZhaoChuanGongLayer)
return ShenZhaoChuanGongLayer00
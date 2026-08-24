local ShowActionLayer = class("ShowActionLayer", LayerEx)

local imagePath="Image/UI/StoryImage/"   
local musicPath="Music/"

function ShowActionLayer:create()
	local p = ShowActionLayer:new()
	p:init()
	return p
end

function ShowActionLayer:init()
	self.UI = require("Layer/ShowActionUI.lua").create()['root']
	self.UI:addTo(self)
	Helper:convertUI(self) -- 获得所有子节点
end

function ShowActionLayer:initImage(imageStr,position,size)
	local image=ccui.ImageView:create()
	image:loadTexture(imagePath..imageStr..".png",0)
	image:setPosition(position)
	if size ~= nil then
		image:setContentSize(size)
	end
	image:setVisible(false)
	image:addTo(self)
	image:setName(imageStr)
	self[imageStr]=image
end

function ShowActionLayer:initUI(duration1,duration2,imageStr1,imageStr2)
	self:initImage(imageStr1,cc.p(540,1470),{width = 1080.00, height = 897.00})
	self:initImage(imageStr2,cc.p(540,500))
	self[imageStr1]:setScale(0)
	self[imageStr2]:setScale(0)
	local fadeInAction=cc.FadeIn:create(duration1)
	local ScaleMax=cc.ScaleTo:create(duration1, 1, 1)
	local SpawnAciton=cc.Spawn:create(fadeInAction,ScaleMax)
	local delayTime=cc.DelayTime:create(duration2)
	self[imageStr1]:setVisible(true)
	self[imageStr1]:runAction(
		cc.Sequence:create(SpawnAciton,cc.CallFunc:create(function ()
			self[imageStr2]:setVisible(true)
			self[imageStr2]:runAction(SpawnAciton)
		end),delayTime,
		cc.CallFunc:create(function ()
			self.isPlaying=true
		end)
		)
	)
	self.Panel_back:releaseFunc(function ()
		if self.isPlaying==true then 
			self:removeImage(imageStr1)
			self:removeImage(imageStr2)
			self:hideLayer()
		end
	end)
end

function ShowActionLayer:removeImage(imageStr)
	self[imageStr]=nil
	self:removeChildByName(imageStr)
end

function ShowActionLayer:fadeIn(duration, func)
    
    self:setVisible(true)
    self:resumeSelfAndChildren()
    
    self:setCascadeOpacityEnabled(true)
    self:callAllChild(
        function(child)
            child:setCascadeOpacityEnabled(true)
        end)
    
    self:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(duration)
            , cc.CallFunc:create(function()
                    if type(func) == "function" then
                        func(self)
                    end
            end)))
end

function ShowActionLayer:fadeOut(duration, func)
    self:setVisible(true)
    self:resumeSelfAndChildren()
    
    self:setCascadeOpacityEnabled(true)
    self:callAllChild(
        function(child)
            child:setCascadeOpacityEnabled(true)
        end)
    
    self:runAction(
        cc.Sequence:create(
            cc.FadeOut:create(duration)
            , cc.CallFunc:create(function()
                if func then
                    -- self:pauseSelfAndChildren()
                    -- self:setVisible(false)
                    if type(func) == "function" then
                        func(self)
                    end
                end
            end)))
end

--@desc 界面隐藏后执行
function ShowActionLayer:setEndFunc(func)
	if type(func) ~= "function" then
		return
	end
	self._endFunc = func
end

function ShowActionLayer:showLayer(duration1,duration2,imageStr1,imageStr2,musicName,func)
	if musicName=="plmusic213" or musicName=="plmusic214" then
		self.isPlayer=true 
		Audio:playMusic("plmusic",true)
	elseif musicName then 
		self.isPlayer=true 
		Audio:playMusic(musicName,true)
	end
	self:setShowAndHideAnimType(duration1)
	self:show(function ()
		self:initUI(duration1,duration2,imageStr1,imageStr2)
		if func then
			func()
		end
	end)
	self.isPlaying=false
	
end

function ShowActionLayer:hideLayer()
	if self.isPlayer==true then
		Audio:stopMusic()
	end
	PopupLayerController:hideLayer("ShowActionLayer", function(layer)
		layer:hide(function ()
			if self._endFunc then
				self._endFunc()
				self._endFunc = nil
			end
		end)
	end)
end

Helper:classDefNodeGetInstance(ShowActionLayer)
return ShowActionLayer00
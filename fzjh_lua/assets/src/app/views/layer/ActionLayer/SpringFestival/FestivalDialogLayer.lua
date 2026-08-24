local FestivalDialogLayer = class("FestivalDialogLayer", LayerEx)
function FestivalDialogLayer:create()
	local p = FestivalDialogLayer:new()
	p:init()
	return p
end
function FestivalDialogLayer:init()
	local UI = require("Layer/ActionUI/FestivalDialogUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:createSnow()
end

function FestivalDialogLayer:showLayer(buttonFunc)
	self:show(true)
	self:setEntryButton(buttonFunc)
	self:setBack()
	self:playLayerMusic()
end

--创建雪花
function FestivalDialogLayer:createSnow()
    if self._animView == nil then
        self._animView = Resource:getSkAnim("newyear", 1)
        self:addChild(self._animView)
    end

    -- 显示动画
    self._animView:playAnim("animation", true)

    -- 设置渲染节点的坐标
    do
        self._animView:setPosition(cc.p(540,1258))
        self._animView:setLocalZOrder(-1)
        self._animView:setSpeedScale(0.6)
    end

	local particle = cc.ParticleSystemQuad:create("Image/UI/Plist/snow.plist")
	particle:addTo(self)
	particle:setPosition(540,1464)
	self.Image_back:setVisible(false)
end

function FestivalDialogLayer:setEntryButton(func)
	self.Image_button:maxZ()
	self.Image_button:releaseFunc(function()
		if func then
			func()
		end
		PopupLayerController:hideLayer("FestivalDialogLayer",function(layer)
			layer:stopLayerMusic()
			layer:hide()
		end)
	end)
end

function FestivalDialogLayer:setBack()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("FestivalDialogLayer",function(layer)
			layer:stopLayerMusic()
			layer:hide()
		end)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/02/10 16:58:20
-- @desc 音乐播放
function FestivalDialogLayer:playLayerMusic()
	-- if self._musicHandel == nil then
		self._musicHandel = Audio:playMusic("xinchunbianpao")
	-- else
		-- Audio:resumeMusic()
	-- end
	self.__lastPlayTime = GetTime()
	
	self:schedule(function()
		if GetTime() - self.__lastPlayTime > 17 + 15 then
			self._musicHandel = Audio:playMusic("xinchunbianpao")
			self.__lastPlayTime = GetTime()
		end
	end, 1)
	
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/02/10 17:03:49
-- @desc 停止音乐
function FestivalDialogLayer:stopLayerMusic()
	-- Audio:pauseMusic()
	Audio:stopMusic()
	self:unscheduleAll()
end

Helper:classDefNodeGetInstance(FestivalDialogLayer)
return FestivalDialogLayer00000000
local ActiveZhaoGuaJiUI = class("ActiveZhaoGuaJiUI", LayerEx)

function ActiveZhaoGuaJiUI:create()
	local p = ActiveZhaoGuaJiUI:new()
	p:init()
	return p
end

function ActiveZhaoGuaJiUI:init()
    self._round = require("Layer/SkillUI/ActiveZhaoMeditate/ActiveZhaoGuaJiUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ActiveZhaoGuaJiUI:showUI()
    self:setVisible(true)
end

function ActiveZhaoGuaJiUI:hideUI()
    self:setVisible(false)
end

function ActiveZhaoGuaJiUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ActiveZhaoGuaJiUI:initAnimator()
    local SpineAnimator = require("third.animator.SpineAnimator.SpineAnimator")
    if self.__animator == nil then
        self.__animator = SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/UIAnim/hiddenMeridian/jingmai/jingmai.skel", "Anim/UIAnim/hiddenMeridian/jingmai/jingmai.atlas", 1), "动画初始化出错"))
        self.Panel_anim:addChild(self.__animator:getSkeletonAnimation())
        self.__animator:getSkeletonAnimation():setPosition(self.Panel_anim:getSizeWidth()/2, self.Panel_anim:getSizeHeight()/2)
		self.__animator:getSkeletonAnimation():setScale(0.6,0.6)
    end

    return self.__animator
end

function ActiveZhaoGuaJiUI:playAnim(animName)
    self.__animator:play(animName, true)
end

function ActiveZhaoGuaJiUI:setTextTitle(text)
	self.Text_title:setString(text)
end

function ActiveZhaoGuaJiUI:setText1(text)
	self.Text_1:setString(text)
end

function ActiveZhaoGuaJiUI:setText2(text)
	self.Text_2:setString(text)
end

function ActiveZhaoGuaJiUI:setText3(text)
	self.Text_3:setString(text)
end

function ActiveZhaoGuaJiUI:setText4(text)
	self.Text_4:setString(text)
end

function ActiveZhaoGuaJiUI:setButtonConfirm(name,func)
	self.Button_confirm.Text_ButtonName:setString(name)

	self.Button_confirm:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ActiveZhaoGuaJiUI000000000000000
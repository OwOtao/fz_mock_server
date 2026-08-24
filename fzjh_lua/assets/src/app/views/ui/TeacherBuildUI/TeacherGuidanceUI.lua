local TeacherGuidanceUI = class("TeacherGuidanceUI", LayerEx)

function TeacherGuidanceUI:create()
	local p = TeacherGuidanceUI:new()
	p:init()
	return p
end

function TeacherGuidanceUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherGuidanceUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherGuidanceUI:setDscText(text)
	self.Text_dsc:setString(text)
end

function TeacherGuidanceUI:setTouXianText(text)
	self.Text_touxian:setString(text)
end

function TeacherGuidanceUI:setGuidanceCountText(text)
	self.Text_guidanceCount:setString(text)
end 

function TeacherGuidanceUI:setReduceTimeText(text)
    self.Text_reduceTime:setString(text)
end

function TeacherGuidanceUI:setNoStateTextVisible(visible)
    self.Text_noState:setVisible(visible)
end

function TeacherGuidanceUI:setStateVisible(visible)
    self.Panel_state:setVisible(visible)
end

function TeacherGuidanceUI:setStateText(text)
    self.Panel_state.Text_state:setString(text)
end

function TeacherGuidanceUI:setStateTimeText(text)
    self.Panel_state.Text_time:setString(text)
end

function TeacherGuidanceUI:setButtonFunc(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function TeacherGuidanceUI:initAnimator()
    local SpineAnimator = require("third.animator.SpineAnimator.SpineAnimator")
    if self.__animator == nil then
        self.__animator = SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/UIAnim/hiddenMeridian/jingmai/jingmai.skel", "Anim/UIAnim/hiddenMeridian/jingmai/jingmai.atlas", 1), "动画初始化出错"))
        self.Panel_state.Panel_anim:addChild(self.__animator:getSkeletonAnimation())
        self.__animator:getSkeletonAnimation():setPosition(self.Panel_state.Panel_anim:getSizeWidth()/2, self.Panel_state.Panel_anim:getSizeHeight()/2)
    end
    return self.__animator
end

function TeacherGuidanceUI:playAnim(animName)
    self.__animator:play(animName, true)
end

return TeacherGuidanceUI0000000000000000
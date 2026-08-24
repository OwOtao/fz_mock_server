local TaskButtonUI = class("TaskButtonUI", ccui.Layout)

function TaskButtonUI:create(uiNode)
    local p = TaskButtonUI:new()
    p:init(uiNode)
    return p
end

function TaskButtonUI:init(uiNode)
    self._UI = uiNode:clone()
    self._UI:setAnchorPoint(0.5, 0.5)
    self:setSize({width = 1080.0000, height = 217.00})
    self._UI:setPosition(1080.0000 / 2, 217.00 / 2)
    self:setVisible(true)
    self:setAnchorPoint(0, 0)
    self._UI:addTo(self)
    Helper:convertUIByParent(self._UI)

    self.__textActionName = nil
end

function TaskButtonUI:setTaskNameImage(imgPath)
    self._UI.Image_TaskName:loadTexture(imgPath, 0)
end

function TaskButtonUI:setLoadingBarProgressImg(imgPath)
    self._UI.LoadingBar_Progress:loadTexture(imgPath, 0)
end

function TaskButtonUI:setLoadingBarVisible(bool)
    self._UI.LoadingBar_Progress:setVisible(bool)
end

function TaskButtonUI:setTaskProgress(progress)
    self._UI.LoadingBar_Progress:setPercent(progress)
end

function TaskButtonUI:setAcceptButtonVisible(bool)
    if bool ~= true and bool ~= false then
        assert(false, "TaskButtonUI:setAcceptButtonVisible args is wrong")
    end
    self._UI.Button_Accept:setVisible(bool)
end

function TaskButtonUI:setAcceptButtonName(btnName)
    self._UI.Button_Accept.Text_buttonName:setString(btnName)
end

function TaskButtonUI:setAcceptButtonClickFunc(func)
    func = Helper:getDef(func, EMPTY_FUNC)
    self._UI.Button_Accept:releaseFunc(
        function()
            Audio:playEffect("daAnNiu")
            func()
        end
    )
end

function TaskButtonUI:setTextVisible(bool)
    if bool ~= true and bool ~= false then
        assert(false, "TaskButtonUI:setTextVisible args is wrong")
    end

    self._UI.Text_dsc:setVisible(bool)
end

function TaskButtonUI:setTextFontSize(fontSize)
    self._UI.Text_dsc:setFontSize(fontSize)
end

function TaskButtonUI:setTextColor(color)
    self._UI.Text_dsc:setTextColor(color)
end

function TaskButtonUI:setEnableOutline(outlineColor, outlineWidth)
    self._UI.Text_dsc:enableOutline(outlineColor, outlineWidth)
end

function TaskButtonUI:setButtonText(str)
    self._UI.Text_dsc:setString(str)
end

function TaskButtonUI:setButtonClickFunc(func)
    func = Helper:getDef(func, EMPTY_FUNC)
    self._UI:releaseFunc(
        function()
            Audio:playEffect("daAnNiu")
            func()
        end
    )
end

function TaskButtonUI:runTextAnimAction(action_type)
    if self.__textActionName ~= nil then
        self._UI.Text_dsc:stopActionByName(self.__textActionName)
    end
    if action_type == "fade" then
        self:setTextVisible(true)
        
        self._UI.Text_dsc:setOpacity(0)
        
        local action = cc.FadeIn:create(0.5)
        
        self._UI.Text_dsc:runActionWithName(action_type, action)
        
        self.__textActionName = action_type
    elseif action_type == "fade-in-out" then
        self:setTextVisible(true)
        self._UI.Text_dsc:setOpacity(0)
        local action = cc.Sequence:create(cc.FadeIn:create(0.5), cc.DelayTime:create(1), cc.FadeOut:create(0.5))
        self._UI.Text_dsc:runActionWithName(action_type, action)
        self.__textActionName = action_type
    else
        assert(false, "TaskButtonUI:runTextAnimAction has not this action type :" .. action_type)
    end
end

return TaskButtonUI
0000000000000000
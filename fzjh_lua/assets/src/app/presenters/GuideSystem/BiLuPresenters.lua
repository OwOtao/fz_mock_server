local BiLuPresenters = class("BiLuPresenters", cc.Layer)

function BiLuPresenters:create()
    local p = BiLuPresenters:new()
    p:init()
    return p
end

function BiLuPresenters:init()
    self._actionUI = require("app.views.ui.GuideSystemUI.BiLuUI"):create()

    self._actionUI:addTo(self)

    self._actionUI:setButtonBackFunc(function()
        self:hideLayer()
    end)

    local BiLu = require("app.models.GuideSystem.BiLu")

    self._interactor = BiLu:create()
end

function BiLuPresenters:showLayer()
    self._role = User:getRole()
    
    self._interactor:setRole(self._role)
    
    self:__initData(function()
        self:__initUI()
        self._actionUI:showUI()
    end)
end

function BiLuPresenters:setTaskId(taskId)
    self._interactor:setTaskId(taskId)
end


function BiLuPresenters:setTitleName(name)
    self._actionUI:setTitleName(name)
end

function BiLuPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "BiLuPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function BiLuPresenters:__initUI()
    self._actionUI:setTitle_1Text(self._interactor:getStoryText())

    self._actionUI:setTitle_2Text(self._interactor:getTargetText())

    self._actionUI:setTitle_4Text(self._interactor:getDescText())

    self._actionUI:setTitle_5Text()

    local taskId_1 =  self._interactor:getSelect1TaskId()

    if taskId_1 then
        self._actionUI:setButton_1Name(self._interactor:getSelect1Text())
        self._actionUI:setButton_1Visible(true)
    else
        self._actionUI:setButton_1Visible(false)
    end

    self._actionUI:setButton_1Func(function()
        if taskId_1 and taskId_1 ~= 0 then
            if self._interactor:checkIsFinish() then
                self._interactor:setTaskId(taskId_1)
                self:__initData(function()
                    self:__initUI()
                end)
            else
                PopText("你还没有完成当前笔录")
            end
        else
            self:hideLayer()    
        end
    end)

    local taskId_2 =  self._interactor:getSelect2TaskId()

    if taskId_2 then
        self._actionUI:setButton_2Name(self._interactor:getSelect2Text())
        self._actionUI:setButton_2Visible(true)
    else
        self._actionUI:setButton_2Visible(false)
    end
    
    self._actionUI:setButton_2Func(function()
        if taskId_2 and taskId_2 ~= 0 then
            if self._interactor:checkIsFinish() then
                self._interactor:setTaskId(taskId_2)
                self:__initData(function()
                    self:__initUI()
                end)
            else
                PopText("你还没有完成当前笔录")
            end
        else
            self:hideLayer()    
        end
    end)
end

function BiLuPresenters:__initData(func)
    self._interactor:init(
        function()
            if func then
                func()
            end
        end
    )
end

Helper:classDefNodeGetInstance(BiLuPresenters)

return BiLuPresenters
0000
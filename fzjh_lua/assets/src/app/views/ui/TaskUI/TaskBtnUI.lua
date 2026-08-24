local TaskBtnUI = class("TaskBtnUI", ccui.Widget)

function TaskBtnUI:create(resPath)
    local p = TaskBtnUI:new()
    p:init(resPath)
    return p
end

function TaskBtnUI:init(resPath)
    assert(resPath, "TaskBtnUI:init resPath is null")

    local resPath = resPath
    self._UI = require(resPath).create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self._UI)

    self:setIgnoreAnchorPointForPosition(true)

    self:setAnchorPoint(0.5000, 0.5000)

    local size = self._UI.Btn_Task_Item:getSize()

    self:setContentSize({width = size.width, height = size.height})

    self._UI:setPosition(cc.p(0, 0))

    self.__innerBtnClickMusic = nil
end

function TaskBtnUI:setNameImg(url)
    self._UI.Btn_Task_Item.Img_TaskName:loadTexture(url, 0)
end

function TaskBtnUI:setProgressImg(url)
    self._UI.Btn_Task_Item.LoadingBar_Progress:loadTexture(url, 0)
end

function TaskBtnUI:setInnerBtnClickFunc(func)
    self._UI.Btn_Task_Item.Button_Accept:releaseFunc(
        function()
            if self.__innerBtnClickMusic ~= nil then
                Audio:playEffect(self.__innerBtnClickMusic)
            end
            func()
        end
    )
end

function TaskBtnUI:setInnerBtnName(name)
    self._UI.Btn_Task_Item.Button_Accept.Text_buttonName:setString(name)
end

function TaskBtnUI:setProgressPercent(value)
    self._UI.Btn_Task_Item.LoadingBar_Progress:setPercent(value)
end

function TaskBtnUI:setInnerBtnClickMusic(name)
    self.__innerBtnClickMusic = name
end

return TaskBtnUI
000000
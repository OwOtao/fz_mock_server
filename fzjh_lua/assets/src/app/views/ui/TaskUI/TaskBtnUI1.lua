local TaskBtnUI1 = class("TaskBtnUI1", ccui.Widget)

function TaskBtnUI1:create(resPath)
    local p = TaskBtnUI1:new()
    p:init(resPath)
    return p
end

function TaskBtnUI1:init(resPath)
    assert(resPath, "TaskBtnUI1:init resPath is null")
    local resPath = resPath
    local UI = require(resPath).create()["root"]

    self._UI = UI:getChildByName("Btn_Task_Item")

    self._UI:retain()

    self._UI:removeFromParent()

    self._UI:addTo(self)

    self._UI:release()

    Helper:convertUIByParent(self._UI)

    self:setIgnoreAnchorPointForPosition(true)

    self:setAnchorPoint(0.5000, 0.5000)

    local size = self._UI:getSize()

    self:setContentSize({width = size.width, height = size.height})

    self._UI:setPosition(cc.p(0, 0))

    self._UI.Pnl_Disable:setVisible(false)
end

function TaskBtnUI1:setButtonDisable()
    self._UI.Pnl_Enable:setVisible(false)
    self._UI.Pnl_Disable:setVisible(true)
end

function TaskBtnUI1:setDisableText1(str)
    self._UI.Pnl_Disable.Txt_Disable1:setString(str)
end

function TaskBtnUI1:setDisableTextVisible1(bool)
    self._UI.Pnl_Disable.Txt_Disable1:setVisible(bool)
end

function TaskBtnUI1:setDisableText2(str)
    self._UI.Pnl_Disable.Txt_Disable2:setString(str)
end

function TaskBtnUI1:setDisableTextVisible2(bool)
    self._UI.Pnl_Disable.Txt_Disable2:setVisible(bool)
end

function TaskBtnUI1:setButtonEnable()
    self._UI.Pnl_Enable:setVisible(true)
    self._UI.Pnl_Disable:setVisible(false)
end

function TaskBtnUI1:setBtnName(name)
    self._UI.Pnl_Enable.Txt_TaskName:setString(name)
end

function TaskBtnUI1:setBtnNameColor(color3B)
    self._UI.Pnl_Enable.Txt_TaskName:setTextColor(color3B)
end

function TaskBtnUI1:setBtnClickFunc(clickFunc)
    self._UI:releaseFunc(
        function()
            if self.__btnClickMusic ~= nil then
                Audio:playEffect(self.__btnClickMusic)
            end
            clickFunc()
        end
    )
end

function TaskBtnUI1:setBtnClickMusic(name)
    self.__btnClickMusic = name
end

function TaskBtnUI1:setInnerBtnClickFunc(clickFunc)
    self._UI.Pnl_Enable.Btn_Start:releaseFunc(
        function()
            if self.__innerBtnClickMusic ~= nil then
                Audio:playEffect(self.__innerBtnClickMusic)
            end
            clickFunc()
        end
    )
end

function TaskBtnUI1:setInnerBtnName(name)
    self._UI.Pnl_Enable.Btn_Start.Text_buttonName:setString(name)
end

function TaskBtnUI1:setInnerBtnVisible(bool)
    self._UI.Pnl_Enable.Btn_Start:setVisible(bool)
end

function TaskBtnUI1:setInnerText(str)
    self._UI.Pnl_Enable.Txt_Status:setString(str)
end

function TaskBtnUI1:setInnerTextVisible(bool)
    self._UI.Pnl_Enable.Txt_Status:setVisible(bool)
end

function TaskBtnUI1:setInnerBtnClickMusic(name)
    self.__innerBtnClickMusic = name
end

function TaskBtnUI1:setProgressVisible(bool)
    self._UI.Prg_CD:setVisible(bool)
end

function TaskBtnUI1:setProgressPercent(value)
    self._UI.Prg_CD:setPercent(value)
end

return TaskBtnUI1
00000
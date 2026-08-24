local NewClass = require("third.class.NewClass")

local DoTween = require("third.dotween.DoTween")

local CharacterControllerBtnUI = require("app.FightSystem.UICtrl.UI.CharacterControllerBtnUI")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARATER_CMD_TYPE = FightCommons.CHARATER_CMD_TYPE

local BTN_MAX_COUNT = 9

local placeholder = -1

local ButtonsAreaCtrl = {
    --@desc
    __node = nil,
    __btnNode = nil,
    __playerId = nil,
    --@desc type:{} element: id = {id = xx, name = "", percent = 100}
    __btn_info_dict = {},
    --@desc type:{} element: id = CharacterControllerBtnUI
    __btnUI_dict = {},
    __btnCtrls = {}
}

--@desc:
--@author:Seven
--@time:2021-05-21 14:38:01
--@return [src.app.FightSystem.UICtrl.ButtonsAreaCtrl#ButtonsAreaCtrl]
function ButtonsAreaCtrl:create()
    local p = ButtonsAreaCtrl.new()
    return p
end

function ButtonsAreaCtrl:ctor()
    for i = 1, BTN_MAX_COUNT do
        self.__btnCtrls[i] = placeholder
    end
end

function ButtonsAreaCtrl:init()
end

function ButtonsAreaCtrl:setVisible(bool)
    self.__node:setVisible(bool)
end

function ButtonsAreaCtrl:setBtnAreaParent(node)
    self.__node = node
end

function ButtonsAreaCtrl:setBtnNode(btnNode)
    self.__btnNode = btnNode
end

function ButtonsAreaCtrl:setFightUICtrl(ctrl)
    --@RefType [Fight2Layer]
    self.__fightUICtrl = ctrl
end

function ButtonsAreaCtrl:setPlayerId(c_id)
    self.__playerId = c_id
end

function ButtonsAreaCtrl:__initStartFight()
    self.__node:removeAllChildren()

    if self.__playerId == nil then
        self.__node:setVisible(false)
        return
    end

    self.__node:setVisible(true)

    self.__playerCtrl = self.__fightUICtrl:getCharacterUICtrl(self.__playerId)
end

function ButtonsAreaCtrl:addActiveSkills(skillInfos)
    if not MapIsEmpty(skillInfos) then
        for i = 1, FightCommons.ACTIVE_UI_BTN_COUNT do
            --@RefType [src.app.FightSystem.UICtrl.UIModel.ActiveSkillInfoVm#ActiveSkillInfoVm]
            local actSkillInfo = skillInfos[tostring(i)]

            if actSkillInfo then
                self:addBtn(actSkillInfo, i)
            else
                self:__addPlaceholderBtn(i)
            end
        end
    end
end

function ButtonsAreaCtrl:updateBtnPos()
    self:__moveBtnPosition()
end

function ButtonsAreaCtrl:__initActiveSkillBtns()
    local activeSkillInfos = self.__playerCtrl:getVMActiveSkills()

    self:addActiveSkills(activeSkillInfos)
end

function ButtonsAreaCtrl:startFight()
    self:__initStartFight()

    self:__initActiveSkillBtns()

    self:__addRunawayBtnCtrl()

    self:__addChangeWeaponBtn()

    self:__moveBtnPosition()
end

function ButtonsAreaCtrl:__addChangeWeaponBtn()
    local changeWeaponVm = self.__playerCtrl:getChangeWeaponVmInfo()

    self:addBtn(changeWeaponVm, 8)
end

function ButtonsAreaCtrl:__addRunawayBtnCtrl()
    local runawayVmInfo = self.__playerCtrl:getRunawayVmInfo()
    self:addBtn(runawayVmInfo, 9)
end

function ButtonsAreaCtrl:__moveBtnPosition()
    local area_size = self.__node:getContentSize()
    local btn_size = self.__btnNode:getContentSize()

    Helper:foreachItemInMatrixArea(
        self.__node:getContentSize(),
        self.__btnNode:getContentSize(),
        3,
        3,
        80,
        60,
        function(index, ix, iy, x, y)
            local btnCtrl = self.__btnCtrls[index]
            if btnCtrl ~= placeholder then
                btnCtrl:setPosition(x, y)
            end
        end
    )
end

function ButtonsAreaCtrl:onUpdate(ft)
    for i = 1, table.getn(self.__btnCtrls) do
        local ctrl = self.__btnCtrls[i]
        if ctrl ~= placeholder then
            ctrl:update(ft)
        end
    end
end

function ButtonsAreaCtrl:onDestroy()
    self.__node:removeAllChildren()
end

--@author:Seven
--@time:2022-01-15 16:10:07
--@btnId: 按钮id
--@return [src.app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl#ABtnCtrl]
function ButtonsAreaCtrl:__getBtnCtrl(btnId)
    for i = 1, table.getn(self.__btnCtrls) do
        local btnCtrl = self.__btnCtrls[i]
        if btnCtrl ~= placeholder then
            if btnCtrl:getId() == btnId then
                return btnCtrl, i
            end
        end
    end

    return nil
end

function ButtonsAreaCtrl:setBtnEnable(btnId, bool)
    local ctrl = self:__getBtnCtrl(btnId)

    if ctrl then
        ctrl:setEnable(bool)
    end
end

function ButtonsAreaCtrl:setBtnVisible(btnId, bool)
    local ctrl = self:__getBtnCtrl(btnId)

    if ctrl then
        ctrl:setVisible(bool)
    end
end

function ButtonsAreaCtrl:setBtnProgress(btnId, value, maxValue)
    local ctrl = self:__getBtnCtrl(btnId)

    if ctrl then
        ctrl:setProgress(value, maxValue)
    end
end

function ButtonsAreaCtrl:removeBtn(btnId)
    local ctrl, index = self:__getBtnCtrl(btnId)

    if ctrl == nil then
        return
    end

    local ui = ctrl:getUI()

    ui:getNode():removeFromParent()

    self.__btnCtrls[index] = placeholder
end

--@btnInfo: [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
--@index: 插入位置
function ButtonsAreaCtrl:addBtn(btnInfo, index)
    if index <= 0 or index > BTN_MAX_COUNT then
        error("ButtonsAreaCtrl:addBtn 不可小于等于0或大于" .. BTN_MAX_COUNT .. "，检查代码 ，index：" .. index)
    end

    local currCtrl = self.__btnCtrls[index]

    if currCtrl ~= placeholder and currCtrl:getType() ~= CHARATER_CMD_TYPE.PLACEHOLDER then
        error("ButtonsAreaCtrl:addBtn 当前位置已有按钮存在，不可插入，检查代码逻辑 ，index ：" .. tostring(index))
    end

    local btnUI = self.__fightUICtrl:createPlayerCtlBtnUI()

    local classPath
    if btnInfo:getType() == CHARATER_CMD_TYPE.RELEASE_ACTIVE then
        classPath = "app.FightSystem.UICtrl.PlayerBtnCtrl.ActiveSkillBtnCtrl"
    elseif btnInfo:getType() == CHARATER_CMD_TYPE.RUNAWAY then
        classPath = "app.FightSystem.UICtrl.PlayerBtnCtrl.RunawayBtnCtrl"
    elseif btnInfo:getType() == CHARATER_CMD_TYPE.CHANGE_WEAPON then
        classPath = "app.FightSystem.UICtrl.PlayerBtnCtrl.ChangeWeaponBtnCtrl"
    elseif btnInfo:getType() == CHARATER_CMD_TYPE.QI_RECOEVE then
        classPath = "app.FightSystem.UICtrl.PlayerBtnCtrl.HpHealBtnCtrl"
    end

    --@RefType [src.app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl#ABtnCtrl]
    local ctrl = require(classPath):create(btnInfo:getId())

    ctrl:setBtnUI(btnUI)

    ctrl:setFightUICtrl(self.__fightUICtrl)

    ctrl:setBtnName(btnInfo:getName())

    ctrl:setEnable(btnInfo:getEnable())

    ctrl:setVisible(btnInfo:getVisible())

    self.__btnCtrls[index] = ctrl

    self.__node:addChild(btnUI:getNode())
end

function ButtonsAreaCtrl:__addPlaceholderBtn(index)
    local btnUI = self.__fightUICtrl:createPlayerCtlBtnUI()

    --@RefType [src.app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl#ABtnCtrl]
    local ctrl = require("app.FightSystem.UICtrl.PlayerBtnCtrl.PlaceholderBtnCtrl"):create()

    ctrl:setBtnUI(btnUI)

    ctrl:setFightUICtrl(self.__fightUICtrl)

    ctrl:setBtnName("")

    ctrl:setEnable(false)

    ctrl:setVisible(true)

    ctrl:setProgress(0, 100)

    ctrl:btnLoadTextureNormal("Image/BaseUI/btn-fight-notPrepare.png")

    self.__btnCtrls[index] = ctrl

    self.__node:addChild(btnUI:getNode())
end

return NewClass("ButtonsAreaCtrl", {}, ButtonsAreaCtrl)
00000
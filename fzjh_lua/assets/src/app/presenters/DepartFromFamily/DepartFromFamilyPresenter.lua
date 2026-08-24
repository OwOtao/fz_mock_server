local newClass = require("third.class.NewClass")

local DepartFromFamily = require("app.models.departFromFamily.DepartFromFamily")

local DepartFromFamilyPresenter = {}

function DepartFromFamilyPresenter:create()
    return DepartFromFamilyPresenter.new()
end

function DepartFromFamilyPresenter:init()
    self:setInput()
end

function DepartFromFamilyPresenter:setRole(role)
    self._role = role
end

function DepartFromFamilyPresenter:setInput()
    self._input = DepartFromFamily:create()
    self._input:setRole(self._role)
end

function DepartFromFamilyPresenter:showLeaveUI()
    local isCanLeave, msg = self._input:checkRoleCanLeave()
    local isStartTask = self._input:checkRoleStartLeaveTask()
    if isStartTask == false and isCanLeave == false then
        local isCanStartTask, conditionText, msg = self._input:checkRoleCanStartLeaveTask()

        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:show(GameConst:getDefaultValue("departFromFamilyTask_start_text"),conditionText)
        dialog:setButton1("确定", function()
            if isCanStartTask == false then
                PopText(msg)
            else
                self._input:startLeaveTask()
            end
        end)
        dialog:setButton2("取消", function()
            dialog:hide()
        end)
        dialog:setWeChatVisible(false)
    else
        if isCanLeave == true then
            self:__showConfirmUI()
        else
            PopText(msg)
        end
    end
end

function DepartFromFamilyPresenter:__showConfirmUI()
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:show(GameConst:getDefaultValue("departFromFamily_confirm_text"),GameConst:getDefaultValue("departFromFamily_confirm_tips"))
    dialog:setButton1("确定", function()
        self:__departFromFamily()
    end)
    dialog:setButton2("取消", function()
        dialog:hide()
    end)
    dialog:setWeChatVisible(false)
end

function DepartFromFamilyPresenter:__departFromFamily()
    if self._role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
        PopText("正在练功中，请终止后再次尝试")
        return
    end

    if self._role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
        PopText("正在修炼中，请终止后再次尝试")
        return
    end

    if self._role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
        PopText("正在打坐中，请终止后再次尝试")
        return
    end

    if self._role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
        PopText("正在闭关中，请终止后再次尝试")
        return
    end

    if self._role:isInCurrState(ROLE_CURR_STATE_TEACHERGUAJI) then
        PopText("当前师门日常进行中，请终止后再次尝试")
        return
    end

    local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")
    if TeacherGuaJiTaskUtil:cheakTaskStateIsSubmit() == true then
		PopText("有师门任务奖励未领取！")
        return
    end

    local anims = self._input:getLeaveAnim()

    self._input:departFromFamily(function()
        if MapIsEmpty(anims) == false then
            PopupLayerController:showLayer("DepartFromFamilyTextAnimLayer",function(layer)
                layer:setAnimInfo(anims)
                layer:showLayer(function()
                    MainControllLayer:pushLayer("MainLayer")
                end)
            end)
        end
    end)
end


return newClass("DepartFromFamilyPresenter", {}, DepartFromFamilyPresenter)
00
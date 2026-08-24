local SelfCreatedTaskActionLayer = class("SelfCreatedTaskActionLayer", LayerEx)

local QiXiActionUI = require("app.views.layer.ActionLayer.QiXiFestival_2019.QiXiActionUI")

local SelfCreatedSkillTaskModel = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillTask.SelfCreatedSkillTaskModel")

function SelfCreatedTaskActionLayer:create()
    local p = SelfCreatedTaskActionLayer:new()
    p:init()
    return p
end

function SelfCreatedTaskActionLayer:init()
    --@RefType[QiXiActionUI]
    self._UI = QiXiActionUI:create()
    self._UI:addTo(self)

    self._UI:setButton1(
        "关闭",
        function()
            self:hideLayer()
        end
    )

    self:setVisible(false)
end

function SelfCreatedTaskActionLayer:setDesc(desc)
    self._UI:setRichText(desc)
end

function SelfCreatedTaskActionLayer:setTitleName(name)
    self._UI:setTitleName(name)
end

function SelfCreatedTaskActionLayer:showLayer()
    PopupLayerController:showLayer(
        "GlobalShadeLayer",
        function(layer)
            layer:showLayer()
            layer:setPopText("请稍等")
        end
    )
    SelfCreatedSkillTaskModel:getTaskInfo(
        function(taskInfo)
            local state = taskInfo.state

            self:refreshLayer(state)
            self:show(
                function()
                    PopupLayerController:hideLayer(
                        "GlobalShadeLayer",
                        function(layer)
                            layer:hideLayer()
                        end
                    )
                end
            )
        end
    )
end

function SelfCreatedTaskActionLayer:refreshLayer(state)
    if state == TASK_STATE_IDLE then
        self._UI:setButton3(
            "接取任务",
            function()
                SelfCreatedSkillTaskModel:acceptTask(
                    function(result, taskInfo)
                        if result == 0 then
                            PopText("接取成功")
                        elseif result == 1 then
                            PopText("任务已完成，无法接取。")
                        elseif result == 2 then
                            PopText("已经接取过该任务，无需重复接取。")
                        elseif result == 3 then
                            PopText("当天已达到完成次数上限，无法再次接取该任务。")
                        end
                        self:refreshLayer(taskInfo.state)
                    end
                )
            end
        )
    elseif state == TASK_STATE_ACCEPT then
        self._UI:setButton3(
            "开始任务",
            function()
                local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

                local enterSelectMapLayer = function()
                    self:hideLayer()
                    MainControllLayer:pushLayer("SelectMapLayer")
                    local selectMapLayer = MainControllLayer:getLayer("SelectMapLayer")
                    selectMapLayer:setMap("fb02")
                end

                if RoleTaskControllor:clickMapLayer(User:getRole()) == false then
                    return
                else
                    enterSelectMapLayer()
                end
            end
        )


    elseif state == TASK_STATE_TO_SUBMIT then
        self._UI:setButton3(
            "提交任务",
            function()
                SelfCreatedSkillTaskModel:submitTask(
                    function(result, taskInfo, rewards)
                        if result == 0 then
                            local clientReward = rewards.client
                            local role = User:getRole()
                            if MapIsEmpty(clientReward.attrs) == false then
                                for attrName, value in pairs(clientReward.attrs) do
                                    if value > 0 then
                                        PopText(role:getCHAttrName(attrName) .. " +" .. value)
                                    end
                                end
                            end

                            local serverReward = rewards.server

                            if MapIsEmpty(serverReward.currency) == false then
                                for currencyName, value in pairs(serverReward.currency) do
                                    if value > 0 then
                                        PopText(role:getCHAttrName(currencyName) .. " +" .. value)
                                    end
                                end
                            end

                            local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
                            if MapIsEmpty(serverReward.selfCreatedItems) == false then
                                for itemId, count in pairs(serverReward.selfCreatedItems) do
                                    if tonumber(count) > 0 then
                                        PopText(SelfCreatedSkillManager:getPropMap(itemId).name .. " +" .. tostring(count))
                                    end
                                end
                            end
                        elseif result == 1 then
                            PopText("任务已提交，无需重复提交。")
                        elseif result == 2 then
                            PopText("提交失败，任务未接取。")
                        elseif result == 3 then
                            PopText("提交失败，任务尚未完成。")
                        elseif result == 5 then
                            PopText("提交失败，该任务已超过提交时间。")
                        end
                        self:refreshLayer(taskInfo.state)
                    end
                )
            end
        )
    elseif state == TASK_STATE_COMPLETE then
        self._UI:setButton3(
            "已完成",
            function()
                PopText("本周任务已完成。")
            end
        )
    else
        assert(false, "传入状态无效，请检查： " .. state)
    end
end

function SelfCreatedTaskActionLayer:hideLayer()
    PopupLayerController:hideLayer(
        "SelfCreatedTaskActionLayer",
        function(layer)
            self:hide()
        end
    )
end

Helper:classDefNodeGetInstance(SelfCreatedTaskActionLayer)
return SelfCreatedTaskActionLayer
000000000
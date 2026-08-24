local TeacherBuildPromotePresenter = class("TeacherBuildPromotePresenter", cc.Layer)

function TeacherBuildPromotePresenter:create()
    local p = TeacherBuildPromotePresenter:new()
    p:init()
    return p
end

function TeacherBuildPromotePresenter:init()
    self._ui = require("app.views.ui.TeacherBuildUI.TeacherBuildPromoteUI"):create()

    self._ui:addTo(self)

    local TeacherBuildPromote = require("app.models.TeacherBuildSystem.TeacherBuildPromote.TeacherBuildPromote")

    self._ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._interactor = TeacherBuildPromote:create()

    self:setVisible(false)
end

function TeacherBuildPromotePresenter:showLayer()
    self._lastSelectIndex = nil

    self._selectBuildName = ""
    
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()

    self:setVisible(true)
end

function TeacherBuildPromotePresenter:setTitleName(name)
    self._ui:setText1(name)
end

function TeacherBuildPromotePresenter:__initData()
    self._interactor:init(
        function()
            self._ui:setText2(self._interactor:getActionDesc())

            self:refreshUI()

            self._ui:setButton1Func(function()
                if not self._lastSelectIndex then
                    PopText("请选择兴建建筑")
                    return
                end

                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:show()

                local buildText = self._interactor:getBuildText()
                local rewards = self._interactor:getRewardInfo()

                buildText = string.gsub(buildText, "num1", rewards[1].number)
                buildText = string.gsub(buildText, "num2", rewards[2].number)
                buildText = string.gsub(buildText, "res1", self._interactor:getAttrName(rewards[1].id))
                buildText = string.gsub(buildText, "res2", self._interactor:getAttrName(rewards[2].id))
                buildText = string.gsub(buildText, "buildName", self._selectBuildName)

                dialog:setRichText(buildText)
                dialog:setBack(false)
                dialog:setWeChatVisible(false)
                dialog:setButton3("取消", EMPTY_FUNC)
                dialog:setButton2(
                    "确定",
                    function()
                        self._interactor:doReward(function(errcode, errmsg)
                            if errcode ~= 0 then
                                if errmsg then
                                    PopText(errmsg)
                                end
                            else
                                PopText("兴建成功")
                                self._interactor:init(function()
                                    self:refreshUI()
                                end)
                            end
                        end)
                    end
                )
            end)

            self._ui:show()
        end,
        function()
            self:hideLayer()
        end
    )
end

function TeacherBuildPromotePresenter:refreshUI()
    local rewards = self._interactor:getRewardInfo()

    local text = "今日可分配："

    for i = 1, #rewards, 1 do
        text = text.. rewards[i].number.. self._interactor:getAttrName(rewards[i].id).."、"
    end

    text = string.sub(text, 1, -4)

    self._ui:setText3(text)

    self:__showListView()
end

function TeacherBuildPromotePresenter:__showListView()
    self._ui:clearListView()

    local list = self._interactor:getList()
    if MapIsEmpty(list) == false then

        for i, v in ipairs(list) do
            local panel = self._ui:getPanel()
            local panelInfo = {
                text1 = v.name,
                text2 = "建筑等级："..v.lv,
                text3 = v.state == 0 and "修筑度："..v.exp.."/"..v.maxExp or "",
                textVisible = v.state == 1,
                panelVisible = v.state == 1,
                lightVisible = false,
                func = function()
                    if v.state == 1 then
                        PopText("该建筑已达到满级，无法兴建，请重新选择")
                        return
                    end

                    if self._lastSelectIndex == i - 1 then
                        return
                    end
                    
                    self._selectBuildName = v.name
                    
                    self._interactor:setBuildTypeId(v.id)
                    
                    self._ui:showPanelLightBg(self._ui:getListItemByIndex(i - 1))

                    if self._lastSelectIndex then
                        self._ui:hidePanelLightBg(self._ui:getListItemByIndex(self._lastSelectIndex))
                    end

                    self._lastSelectIndex = i - 1
                end
            }

            self._ui:initPanel(panel, panelInfo)
            self._ui:addItemToList(panel)
        end
    end

    self._ui:listViewJumpToTop()
end

function TeacherBuildPromotePresenter:hideLayer()
    self._role:getTeacherBuildSystem():getTeacherBuildData(function()
        PopupLayerController:hideLayer(
            "TeacherBuildPromotePresenter",
            function(layer)
                self._ui:hide()
            end
        )
    end)
end

Helper:classDefNodeGetInstance(TeacherBuildPromotePresenter)

return TeacherBuildPromotePresenter
000
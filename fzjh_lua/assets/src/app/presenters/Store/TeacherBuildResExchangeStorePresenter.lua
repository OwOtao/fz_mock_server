local TeacherBuildResExchangeStorePresenter = class("TeacherBuildResExchangeStorePresenter", cc.Layer)

function TeacherBuildResExchangeStorePresenter:create()
    local p = TeacherBuildResExchangeStorePresenter:new()
    p:init()
    return p
end

function TeacherBuildResExchangeStorePresenter:init()
    self._ui = require("app.views.ui.TeacherBuildUI.TeacherBuildResExchangeStoreUI"):create()

    self._ui:addTo(self)

    local TeacherBuildResExchangeStore = require("app.models.Store.TeacherBuildResExchangeStore")

    self._ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._interactor = TeacherBuildResExchangeStore:create()

    self:setVisible(false)
end

function TeacherBuildResExchangeStorePresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()

    self._ui:setButton1Func(
        function()
            self._role:getTeacherBuildSystem():getTeacherBuildItems(
                function(isOk,msg,data)
                    if isOk then
                        PopupLayerController:showLayer(
                            "TeacherBuildItemPresenter",
                            function(layer)
                                layer:setRole(self._role)
                                layer:setItemData(data)
                                layer:showLayer()
                            end
                        )
                    else
                        PopText(msg)
                    end
                end
            )
        end
    )
end

function TeacherBuildResExchangeStorePresenter:setTitleName(name)
    self._ui:setText1(name)
end

function TeacherBuildResExchangeStorePresenter:__initData()
    self._interactor:init(
        function()
            self._ui:setText2(self._interactor:getActionDesc())

            self:initUI()

            self:setVisible(true)
        end, function()
            self:hideLayer()
        end
    )
end

function TeacherBuildResExchangeStorePresenter:initUI()
    self._ui:setText3("本日剩余交易次数："..self._interactor:getExchangeTimes())
    self:__showListView()
end

function TeacherBuildResExchangeStorePresenter:__showListView()
    self._ui:clearListView()

    local list = self._interactor:getList()
    if MapIsEmpty(list) == false then
        for i, v in ipairs(list) do
            local panel = self._ui:getPanel()
            local panelInfo = {
                text1 = v.text1,
                text2 = v.text2,
                text3 =  v.state == 0 and v.text3 or "",
                btnVisible = v.state == 1,
                bgVisible = v.state == 0,
                btnName = "缴纳",
                func = function()
                    self._interactor:buyGoods(v.id, function()
                        self:__initData()
                    end)
                end
            }

            self._ui:initPanel(panel, panelInfo)
            self._ui:addItemToList(panel)
        end
    end
end

function TeacherBuildResExchangeStorePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "TeacherBuildResExchangeStorePresenter",
        function(layer)
            self:setVisible(false)
        end
    )
end

Helper:classDefNodeGetInstance(TeacherBuildResExchangeStorePresenter)

return TeacherBuildResExchangeStorePresenter
00000000000
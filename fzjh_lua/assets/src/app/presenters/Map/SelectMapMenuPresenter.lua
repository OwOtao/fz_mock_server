local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
local SelectMapMenuPresenter = class("SelectMapMenuPresenter", cc.Layer)

function SelectMapMenuPresenter:create()
    local p = SelectMapMenuPresenter:new()
    p:init()
    return p
end

function SelectMapMenuPresenter:init()
    self._UI = require("app.views.ui.MapUI.SelectMapMenuUI"):create()
    self._UI:addTo(self)
end

function SelectMapMenuPresenter:onResume()
    self:showLayer()
end

function SelectMapMenuPresenter:showLayer()
    self:setButtonOldMap()
    self:setButtonNewMap()
end

function SelectMapMenuPresenter:setButtonOldMap()
    self._UI:setButtonOldMap(
        "江湖往事",
        function()
            Audio:playEffect("daAnNiu")
            MainControllLayer:pushLayer("SelectMapLayer")
            RichPrint("main", "HIR江湖险恶，人心叵测。", 30)
            RichPrint("main", "HIR你背上行囊，决定出门闯荡一番。")
        end
    )
end

function SelectMapMenuPresenter:setButtonNewMap()
    self._UI:setButtonNewMap(
        "江湖轶闻",
        function()
            Audio:playEffect("daAnNiu")

            ChallengeMapSystem:getInstance():isChallengeMapReconnection(
                function(isOk, arg)
                    if isOk then
                        local status = arg.status
                        if status == 0 then
                            MainControllLayer:pushLayer("JiangHuAnecdotePresenter")
                        elseif status == 1 then
                            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                            local dialog = DialogALayer:getInstance()
                            dialog:hide()
                            local text = "由于少侠你上次的江湖轶闻冒险还在继续，是否再次进行冒险？"
                            dialog:setBack(false)
                            dialog:show(text)
                            dialog:setButton1(
                                "确定",
                                function()
                                    self:_enterMap()
                                end
                            )
                            dialog:setButton2(
                                "离开",
                                function()
                                    ChallengeMapSystem:getInstance():challengeMapLeave(
                                        3,
                                        function(result, msg)
                                            if result then
                                                MainControllLayer:pushLayer("JiangHuAnecdotePresenter")
                                            else
                                                PopText(msg)
                                            end
                                        end
                                    )
                                end
                            )
                            dialog:setWeChatVisible(false)
                        elseif status == 2 then
                            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                            local dialog = DialogALayer:getInstance()
                            dialog:hide()
                            local text = "由于少侠你上次的江湖轶闻冒险已经超出调查时间，将无法继续进行调查？"
                            dialog:setBack(false)
                            dialog:show(text)
                            dialog:setButton1()
                            dialog:setButton2(
                                "离开",
                                function()
                                    ChallengeMapSystem:getInstance():challengeMapLeave(
                                        3,
                                        function(result, msg)
                                            if result then
                                                MainControllLayer:pushLayer("JiangHuAnecdotePresenter")
                                            else
                                                PopText(msg)
                                            end
                                        end
                                    )
                                end
                            )
                            dialog:setWeChatVisible(false)
                        else
                            error("非法状态" .. status)
                        end
                    else
                        local errmsg = arg
                        PopText(errmsg)
                    end
                end
            )
        end
    )
end

function SelectMapMenuPresenter:_enterMap()
    ChallengeMapSystem:getInstance():reEnterChallengemap(
        function(isOk, arg)
            if isOk then
                Audio:stopMusic()

                local map = arg

                local challengeMapPresenter = require("app.presenters.ChallengeMap.ChallengeMapPresenter"):create()
                local mapLayer = MainControllLayer:getLayer("NewMapLayer")

                mapLayer:setInput(challengeMapPresenter)
                challengeMapPresenter:setOutput(mapLayer)

                challengeMapPresenter:setInput(map)
                map:setOutput(challengeMapPresenter)

                local BuffSystemPresenter = require("app.presenters.ChallengeMap.BuffSystemPresenter"):create()
                BuffSystemPresenter:setOutput(MainControllLayer:getLayer("PrintLayer"))
                ChallengeMapSystem:getInstance():getBuffSystem():setOutput(BuffSystemPresenter)

                mapLayer:setMap(map)

                local titleLayer = MainControllLayer:getLayer("TitleLayer")
                titleLayer:hide(true)

                MainControllLayer:pushLayer("NewMapLayer")

                MainControllLayer:getLayer("PrintLayer"):initRichText()
                local layer = MainControllLayer:getLayer("PrintLayer")
                layer:setLocalZOrder(10)
                layer:show()
            else
                local errmsg = arg
                PopText(errmsg)
            end
        end
    )
end

function SelectMapMenuPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "SelectMapMenuPresenter",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(SelectMapMenuPresenter)
return SelectMapMenuPresenter
0000000
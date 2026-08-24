local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
local ChallengeMapCustomsPresenter = class("ChallengeMapCustomsPresenter", cc.Layer)
local ChallengeMapConstant = require("app.models.ChallengeMap.ChallengeMapConstant")

function ChallengeMapCustomsPresenter:create()
    local p = ChallengeMapCustomsPresenter:new()
    p:init()
    return p
end

function ChallengeMapCustomsPresenter:init()
    self.__ui = require("app.views.ui.ChallengeMapUI.ChallengeMapCustomsUI"):create()
    self.__ui:addTo(self)

    self.__ui:hideUI()
end

function ChallengeMapCustomsPresenter:showLayer()
    self:setDesc()
    self:setButton1()
    self:setButton2()
    self:setListViewCondition()
    self.__ui:showUI()
end

function ChallengeMapCustomsPresenter:setCallback(func)
    self.__callBack = func
end

function ChallengeMapCustomsPresenter:setConditons(conditions)
    self.__conditions = conditions
end

function ChallengeMapCustomsPresenter:setMapData(mapData)
    self.__mapData = mapData
end

function ChallengeMapCustomsPresenter:setRole(role)
    self.__role= role
end

function ChallengeMapCustomsPresenter:setDesc()
    self.__ui:setDesc("若选择匆匆了事探索本次事件，只能获得最基本的报酬，无法获取下一次探索的线索，是否确认以此方式进行探索？")
end

function ChallengeMapCustomsPresenter:setListViewCondition()
    self.__ui:setListView(self.__conditions)
end

function ChallengeMapCustomsPresenter:setButton1()
    self.__ui:setButton1(
        "确定",
        function()
            local itemEnough,consume_map,itemCheckMsg = ChallengeMapSystem:getInstance():checkExpendItem(self.__mapData.ExpendItem)

            if not itemEnough then
                PopText(itemCheckMsg)
                return
            end

            local level = self.__mapData.level
            if self.__role:getLv() < level then
                PopText("进入该副本需的等级不足" .. level .. "，无法开始")
                return
            end

            ChallengeMapSystem:getInstance():challengeMapFinish(
                self.__mapData.id,
                ChallengeMapConstant.FinishType.Faster,
                function(ok, arg1, arg2)
                    if ok then
                        for i, v in ipairs(consume_map) do
                            self.__role:addItemCount(v.id, -v.num)
                            PopText("已使用" .. Item:getOneItemByKey(v.id).name .. "X".. v.num)
                        end

                        local itemList = arg1
                        local tips = arg2 or "若背包已满，则可通过江湖邮驿获取此次奖励。"
                        PopupLayerController:showLayer(
                            "ChallengeMapFinishPresenter",
                            function(layer)
                                layer:setRole(self.__role)
                                layer:setButtonLeave(
                                    "离开",
                                    function()
                                        layer:hideLayer()
                                        if self.__callBack then
                                            self.__callBack()
                                        end
                                    end
                                )
                                layer:showLayer(itemList)
                                layer:setTextTips(tips)
                            end
                        )

                        self:hideLayer()
                    else
                        local errmsg = arg1
                        PopText(errmsg)
                    end
                end
            )
        end
    )
end

function ChallengeMapCustomsPresenter:setButton2()
    self.__ui:setButton2(
        "取消",
        function()
            self:hideLayer()
        end
    )
end

function ChallengeMapCustomsPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ChallengeMapCustomsPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ChallengeMapCustomsPresenter)
return ChallengeMapCustomsPresenter
000
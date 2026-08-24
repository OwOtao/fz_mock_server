local class = require("third.class.NewClass")
local IMapPresenter = require("app.presenters.Map.IMapPresenter")
local LogSystem = require("app.models.LogSystem.LogSystem")
local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
local ChallengeMapConstant = require("app.models.ChallengeMap.ChallengeMapConstant")

local function print(...)
    LogSystem:log("挑战副本", ...)
end

local ChallengeMapPresenter = {}

function ChallengeMapPresenter:create()
    local p = ChallengeMapPresenter.new()
    return p
end

function ChallengeMapPresenter:setInput(iMapModel)
    --@RefType [src.app.models.ChallengeMap.ChallengeMap#ChallengeMap]
    self.__input = iMapModel
end

function ChallengeMapPresenter:setOutput(iMapView)
    --@RefType [NewMapLayer]
    self.__output = iMapView
end

-- 点击房间单位按钮
function ChallengeMapPresenter:clickRoomObjectButton(objectId)
    local role = self.__input:getObject(objectId)

    local functionList = {}

    for i, operation in ipairs(role.operationList) do
        if operation.buttonShow == 1 then
            table.insert(
                functionList,
                {
                    btnName = operation.caozuoName,
                    btnFunc = function()
                        self.__input:executeObjectEventConditionAndResultGroup(
                            role:getId(),
                            i,
                            function()
                                -- LogSystem:log("挑战副本, 结果执行完毕:", {operationName = operation.caozuoName, roleId = role:getId()})
                            end
                        )
                    end
                }
            )
        end
    end

    self.__output:showRoleObserverLayer(role, functionList)
end

-- 进入房间
function ChallengeMapPresenter:entryRoom(fromRoomId, roomId, direction)
    self.__output:hideRoleObserverLayer()
    self.__input:enterRoom(
        fromRoomId,
        roomId,
        function(result)
            self.__output:hideRoleObserverLayer()
            if result then
                self.__output:replaceRoom(roomId, direction)
            end
        end
    )
end

-- 离开副本
function ChallengeMapPresenter:leaveMap()
    self.__input:canLeaveMap(
        function(result)
            if result then
                self:popMapFinishChoiceLayer()
            else
                self:popConfirmLeaveMapLayer()
            end
        end
    )
end

function ChallengeMapPresenter:popMapFinishChoiceLayer()
    PopupLayerController:showLayer(
        "ChallengeMapSucChoicePresenter",
        function(layer)
            layer:setCallback(function()
                self:popMapFinishLayer()
            end)
            layer:showLayer()
        end
    )
end

function ChallengeMapPresenter:popMapFinishLayer()
    --@RefType [src.app.models.ChallengeMap.ChallengeMapSystem#ChallengeMapSystem]
    local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
    ChallengeMapSystem:getInstance():clearTheMap(
        self.__input,
        function(ok, arg1, arg2)
            if ok then
                local itemList = arg1
                local tips = arg2 or "若背包已满，则可通过江湖邮驿获取此次奖励。"
                PopupLayerController:showLayer(
                    "ChallengeMapFinishPresenter",
                    function(layer)
                        layer:setRole(self.__input:getPlayer())
                        layer:setButtonLeave(
                            "离开",
                            function()
                                self.__input:quit()
                                layer:hideLayer()
                            end
                        )
                        layer:showLayer(itemList)
                        layer:setTextTips(tips)
                    end
                )
            else
                local errmsg = arg1
                PopText(errmsg)
            end
        end
    )
end

function ChallengeMapPresenter:popConfirmLeaveMapLayer()
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    local text = "目前副本未完成，离开此副本后背包内物品无法携带出副本，并且无法获取通过奖励，是否确认离开？"
    dialog:show(text)
    dialog:setButton1(
        "离开",
        function()
            local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
            ChallengeMapSystem:getInstance():leaveTheMap(
                self.__input,
                1,
                function(result, msg)
                    if result then
                        self.__input:quit()
                    else
                        PopText(msg)
                    end
                end
            )
        end
    )
    dialog:setButton2("取消")
    dialog:setWeChatVisible(false)
end

-- 刷新副本
function ChallengeMapPresenter:refreshMap()
    print("ChallengeMapPresenter:refreshMap()")

    -- 刷新房间
    self.__output:refreshRoom()

    -- 刷新人物
    self:showCurrRoomObjectList()

    -- 刷新UI
    self.__output:refreshUI()
end

-- 显示当前房间单位列表
function ChallengeMapPresenter:showCurrRoomObjectList()
    local objectList = self.__input:getCurrRoomObjectList()

    local buttonList = {}

    for i, object in ipairs(objectList) do
        if object.isForbidden == true then
            -- 禁止 则不显示
        else
            table.insert(
                buttonList,
                {
                    id = object:getId(),
                    buttonText = object.name,
                    buttonImageIndex = object.btnImg
                }
            )
        end
    end

    self.__output:showObjectButtonList(buttonList)
end

function ChallengeMapPresenter:update(ft)
    self.__input:update(ft)
end

function ChallengeMapPresenter:quit()
    self.__output:quit()
end

function ChallengeMapPresenter:interactDisable()
    if self.__waitingLayer == nil then
        self.__waitingLayer = WaitingLayer:createInRunningScene()
    end
    self.__waitingLayer:show()
    print("禁止交互")
end

function ChallengeMapPresenter:interactEnable()
    if self.__waitingLayer then
        self.__waitingLayer:hideAndRemoveSelf()
        self.__waitingLayer = nil
        print("允许交互\n")
    end
end

function ChallengeMapPresenter:hidePanelWait()
    if self.__waitingLayer then
        self.__waitingLayer:hidePanelWait()
    end
end

return class("ChallengeMapPresenter", {IMapPresenter}, ChallengeMapPresenter)
0000000000000
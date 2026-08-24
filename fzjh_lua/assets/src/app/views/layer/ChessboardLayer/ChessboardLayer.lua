local ChessboardLayer = class("ChessboardLayer", cc.Layer)
local FondDreamResManager = require("app.models.FondDream.FondDreamResManager")

function ChessboardLayer:create()
    local p = ChessboardLayer:new()
    p:init()
    return p
end

function ChessboardLayer:init()
    self._UI = require("app.views.ui.Chessboard.ChessboardUI"):create()
    self._UI:addTo(self)

    self._UI:setButtonBack(
        function()
            self:hideLayer()
        end
    )
end

function ChessboardLayer:showLayer()
    self._list = FondDreamResManager:getChessList()
    self:setTital()
    self:setChessListView()
    self._UI:showUI()
end

function ChessboardLayer:setTital()
    self._UI:setTital("棋局观摩")
end

function ChessboardLayer:setChessListView()
    if MapIsEmpty(self._list) then
        return
    end
    table.sort(self._list,function(a,b)
        if a and b then
            return a.id < b.id
        end
    end)
    
    local retArray = {}
    for i,v in ipairs(self._list) do
        local tab = {
            name = "",
            func = EMPTY_FUNC
        }
        tab["name"] = v.name
        tab["func"] = function()
            self:confirmLayer(v.dsc,function()
                MainControllLayer:getLayer("PrintLayer"):initRichText()

                local drSystem = require("app.models.FondDream.FondDreamSystem"):create(User:getRole())
                local events = string.split(v.event,";")
                local eventId = events[math.random(1,#events)]
                local chessEventInfo = FondDreamResManager:getChessEventInfo(eventId)
                local familyMobanId = chessEventInfo.familyMobanId
                local attrMobanId = chessEventInfo.attrMobanId
                local chessType = chessEventInfo.type
                local role = drSystem:createNewDreamRole(attrMobanId,familyMobanId)
                role.chessType = chessType
                role.chessEventId = eventId
                HttpManagerEx:uploadFondDreamRoleData(role:getTrimData(),function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            PopupLayerController:showLayer("DreamEntryLayer",
                                function(layer)
                                    layer:showLayer(MAP_TYPE.FONDDREAMMAP,
                                        function()
                                            drSystem:enterNewMap(role)
                                        end
                                    )
                                end
                            )
                            self:hideLayer()
                            return true
                        elseif errcode == 2 then
                            role:destory()
                            local player = drSystem:createDreamRoleWithData(data)
                            player.chessType = chessType
                            player.chessEventId = eventId
                            PopupLayerController:showLayer(
                                "DreamEntryLayer",
                                function(layer)
                                    layer:showLayer(MAP_TYPE.FONDDREAMMAP,
                                        function()
                                            drSystem:enterNewMap(player)
                                        end
                                    )
                                end
                            )
                            self:hideLayer()
                            return true
                        elseif errcode == 3 then
                            PopText(errmsg)
                            return true
                        end
                    else
                        PopText(errmsg)
                        return false
                    end
                end,IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
            end)
        end
        table.insert(retArray, tab)
    end

    self._UI:setListView(retArray)
end

function ChessboardLayer:confirmLayer(text,callback)
    local data = {
        desc = text,
        button1Name = "观摩",
        button1Func = callback,
        button2Name = "离开",
    }
    
    self._UI:initPanelTip(data)
end

function ChessboardLayer:hideLayer()
    PopupLayerController:hideLayer(
        "ChessboardLayer",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ChessboardLayer)
return ChessboardLayer
000000
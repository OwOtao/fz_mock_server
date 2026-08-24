local JiangHuAnecdotePresenter = class("JiangHuAnecdotePresenter", cc.Layer)

local ChallengeMapConstant = require("app.models.ChallengeMap.ChallengeMapConstant")

function JiangHuAnecdotePresenter:create()
    local p = JiangHuAnecdotePresenter:new()
    p:init()
    return p
end

function JiangHuAnecdotePresenter:init()
    self._UI = require("app.views.ui.ChallengeMapUI.JiangHuAnecdoteUI"):create()
    self._UI:addTo(self)
    self:hide()
end

function JiangHuAnecdotePresenter:onResume()
	self:showLayer()
end

function JiangHuAnecdotePresenter:showLayer()
    self._list = self:getMapInfoMap()
    self:setMapListView()

    HttpManagerEx:getAnecdote(
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self:show()
                local titleLayer = MainControllLayer:getLayer("TitleLayer")
                titleLayer:setAnecdoteText("『轶闻』"..tostring(data.number).."/"..tostring(data.max_number))
            else
                PopText(errmsg)
            end
        end,
    IS_SHOW_WAITING)
end

function JiangHuAnecdotePresenter:getMapInfoMap()
    local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
    local mapInfo = ChallengeMapSystem:getInstance():getMapInfoMap()
    local retList = {}
    local currTime = GetTime()

    for grade,group in pairs(mapInfo) do
        local isOpen = false
        for level,mapData in ipairs(group) do
            local stratTime = mapData.startTime
            local endTime = mapData.endTime
            if stratTime then
                stratTime = Helper:getTimeStampWithStringDate(string.sub(stratTime, 1, 8), tonumber(string.sub(stratTime, 9, 10)))
            else
                isOpen = true
                break
            end

            if endTime then
                endTime = Helper:getTimeStampWithStringDate(string.sub(endTime, 1, 8), tonumber(string.sub(endTime, 9, 10)))
            else
                isOpen = true
                break
            end

            if currTime >= stratTime and currTime < endTime then
                isOpen = true
            end
        end
        if isOpen == true then
            table.insert(retList, group)
        end
    end

    table.sort(retList, function(a, b)
        return a[1].section[1] < b[1].section[1]
    end)

    return retList
end

function JiangHuAnecdotePresenter:setMapListView()
    if MapIsEmpty(self._list) then
        return
    end
    
    local retArray = {}
    for i,v in ipairs(self._list) do
        local tab = {
            name = "",
            func = EMPTY_FUNC
        }
        tab["name"] = v[1].name
        tab["func"] = function()
            if v[1].type == ChallengeMapConstant.MapType.Normal then
                self:showMapDetailPresenter(v)
            elseif v[1].type == ChallengeMapConstant.MapType.Festival then
                self:showFestivalMapDetailPresenter(v[1].section[1],v)
            elseif v[1].type == ChallengeMapConstant.MapType.Conceal then
                self:showConcealMapDetailPresenter(v)
            else
                error("挑战副本类型异常"..v[1].type)
            end
        end
        table.insert(retArray, tab)
    end

    self._UI:setListView(retArray)
end

function JiangHuAnecdotePresenter:showConcealMapDetailPresenter(mapGroup)
    HttpManagerEx:getAnecdote(
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                PopupLayerController:showLayer(
                    "ConcealMapDetailPresenter",
                    function(layer)
                        layer:setMapGroup(mapGroup)
                        layer:setCurrStrain(data.number)
                        layer:setMaxStrain(data.max_number)
                        layer:showLayer()
                    end
                )
            else
                PopText(errmsg)
            end
        end,
    IS_SHOW_WAITING)
end

function JiangHuAnecdotePresenter:showMapDetailPresenter(mapGroup)
    HttpManagerEx:getAnecdote(
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                PopupLayerController:showLayer(
                    "ChallengeMapDetailPresenter",
                    function(layer)
                        layer:setMapGroup(mapGroup)
                        layer:setCurrStrain(data.number)
                        layer:setMaxStrain(data.max_number)
                        layer:showLayer()
                    end
                )
            else
                PopText(errmsg)
            end
        end,
    IS_SHOW_WAITING)
end

function JiangHuAnecdotePresenter:showFestivalMapDetailPresenter(groupId,mapGroup)
    HttpManagerEx:getAnecdote(
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                HttpManagerEx:getFestivalMapInfo(
                    groupId,
                    function(status, errcode, errmsg, festivalGroupData)
                        if status == 200 and errcode == 0 then
                            PopupLayerController:showLayer(
                                "FestivalMapDetailPresenter",
                                function(layer)
                                    layer:setMapGroup(mapGroup)
                                    layer:setCurrStrain(data.number)
                                    layer:setMaxStrain(data.max_number)
                                    layer:setFestivalGroupData(festivalGroupData)
                                    layer:showLayer()
                                end
                            )
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            else
                PopText(errmsg)
            end
        end,
    IS_SHOW_WAITING)
end

Helper:classDefNodeGetInstance(JiangHuAnecdotePresenter)
return JiangHuAnecdotePresenter
0000
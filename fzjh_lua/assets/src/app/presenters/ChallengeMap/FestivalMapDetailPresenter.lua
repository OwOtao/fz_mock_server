local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

local AbsMapDetailPresenter = require("app.presenters.ChallengeMap.AbsMapDetailPresenter")

local FestivalMapDetailPresenter = class("FestivalMapDetailPresenter", AbsMapDetailPresenter)

function FestivalMapDetailPresenter:create()
    local p = FestivalMapDetailPresenter:new()
    p:init()
    return p
end

function FestivalMapDetailPresenter:init()
    self._UI = require("app.views.ui.ChallengeMapUI.ChallengeMapDetailUI"):create()
    self._UI:addTo(self)

    self._UI:hideUI()
    self._UI:setButtonBack(
        function()
            self:hideLayer()
        end
    )
end

function FestivalMapDetailPresenter:showLayer()
    self:initIndex()
    self:setButtonLeft()
    self:setButtonRight()
    self:setButtonEnter()
    self:setButtonCustoms()
    self:setCurrMapUI()
    self._UI:showUI()
end

function FestivalMapDetailPresenter:initIndex()
    local index = #self._mapGroup
    for i = #self._mapGroup,1,-1 do
        local mapData = self._mapGroup[i]
        local festivalData = self._festivalGroupData[i]
        if festivalData.dayTime < mapData.daily and festivalData.finalTime < mapData.activity then
            index = i
        end
    end
    self:setIndex(index)
end

function FestivalMapDetailPresenter:setIndex(index)
    self._index = index
end

function FestivalMapDetailPresenter:setMapGroup(mapGroup)
    self._mapGroup = mapGroup
end

function FestivalMapDetailPresenter:setCurrStrain(strain)
    self._strain = strain
end

function FestivalMapDetailPresenter:setMaxStrain(strain)
    self._maxStrain = strain
end

function FestivalMapDetailPresenter:setFestivalGroupData(festivalGroupData)
    self._festivalGroupData = festivalGroupData
end

function FestivalMapDetailPresenter:getCurrFestivalData()
    return self._festivalGroupData[self._index]
end

function FestivalMapDetailPresenter:getCurrMapData()
    return self._mapGroup[self._index]
end

function FestivalMapDetailPresenter:setCurrMapUI()
    self._mapData = self._mapGroup[self._index]
    self:_setMapName()
    self:_setMapGradeSelectText()
    self:_setMapDesc()
    self:_setGradeName()
    self:_setTextFinishCon()
    self:_setTextAward()
    self:_setTextEndTime()
    self:_setTextStartTime()
    self:_setTextDailyTime()
    self:_setTextActivityTime()
end

function FestivalMapDetailPresenter:setButtonLeft()
    self._UI:setButtonLeft(
        function()
            if self._index > 1 then
                self._index = self._index - 1
                self:setCurrMapUI()
            end
        end
    )
end

function FestivalMapDetailPresenter:setButtonRight()
    self._UI:setButtonRight(
        function()
            local nextIndex = self._index + 1
            if self._mapGroup[nextIndex] then
                self._index = self._index + 1
                self:setCurrMapUI()
            end
        end
    )
end

function FestivalMapDetailPresenter:setButtonEnter()
    local args = {
        positionX = 540,
        positionY = 239.5,
        isVisible = true,
        text = "开始调查",
        func = function()
            local mapId = self._mapData.id
            self:enterMap(mapId)
        end
    }

    self._UI:setButtonEnter(args)
end

function FestivalMapDetailPresenter:setButtonCustoms()
    local args = {
        positionX = 0,
        positionY = 0,
        isVisible = false,
        text = "",
        func = EMPTY_FUNC
    }

    self._UI:setButtonCustoms(args)
end

function FestivalMapDetailPresenter:_setMapName()
    local name = self._mapData.name
    self._UI:setMapName(name)
end

function FestivalMapDetailPresenter:_setMapGradeSelectText()
    self._UI:setGradeSelectText("剧情选择")
end

function FestivalMapDetailPresenter:_setMapDesc()
    local desc = self._mapData.summary
    self._UI:setMapDesc(desc)
end

function FestivalMapDetailPresenter:_setGradeName()
    local gradeName = self._mapData.gradeName
    self._UI:setGradeName(gradeName)
end

function FestivalMapDetailPresenter:_setTextFinishCon()
    local finishTexts = self._mapData.finishText
    local texts = ""
    for i, text in ipairs(finishTexts) do
        texts = texts .. text .. "\n"
    end

    self._UI:setTextFinishCon(texts)
end

function FestivalMapDetailPresenter:_setTextAward()
    local finishAwardTxts = self._mapData.finishAwardTxt
    local retList = {}
    for i, text in ipairs(finishAwardTxts) do
        local oneTexts = {reward1 = "", reward2 = ""}
        if i % 2 == 0 then
            local index = math.ceil(i / 2)
            retList[index]["reward2"] = text
        else
            oneTexts["reward1"] = text
            table.insert(retList, oneTexts)
        end
    end

    self._UI:setListViewReward(retList)
end

function FestivalMapDetailPresenter:_setTextEndTime()
    local endTime = self._mapData.endTime
    local year = tonumber(string.sub(endTime, 1, 4))
    local month = tonumber(string.sub(endTime, 5, 6))
    local day = tonumber(string.sub(endTime, 7, 8))
    local hour = tonumber(string.sub(endTime, 9, 10))

    self._UI:setTextEnterConItem("结束时间:" .. month.."月"..day.."日"..hour.."点")
end


function FestivalMapDetailPresenter:_setTextStartTime()
    local startTime = self._mapData.startTime
    local year = tonumber(string.sub(startTime, 1, 4))
    local month = tonumber(string.sub(startTime, 5, 6))
    local day = tonumber(string.sub(startTime, 7, 8))
    local hour = tonumber(string.sub(startTime, 9, 10))

    self._UI:setTextEnterConLv("开始时间:" .. month.."月"..day.."日"..hour.."点")
end

function FestivalMapDetailPresenter:_setTextDailyTime()
    local daily = self._mapData.daily
    self._UI:setTextEnterConsume("本日次数:" ..self:getCurrFestivalData().dayTime.."/"..daily)
end

function FestivalMapDetailPresenter:_setTextActivityTime()
    local activity = self._mapData.activity
    self._UI:setTextCurrConsume("活动次数:" ..self:getCurrFestivalData().finalTime.."/"..activity)
end

function FestivalMapDetailPresenter:_enterMap(map)
    Audio:stopMusic()
    PopupLayerController:showLayer(
        "DreamEntryLayer",
        function(layer)
            layer:showLayer(
                7,
                function()
                    local challengeMapPresenter = require("app.presenters.ChallengeMap.ChallengeMapPresenter"):create()
                    local mapLayer = MainControllLayer:getLayer("NewMapLayer")

                    mapLayer:setInput(challengeMapPresenter)
                    challengeMapPresenter:setOutput(mapLayer)

                    challengeMapPresenter:setInput(map)
                    map:setOutput(challengeMapPresenter)

                    local BuffSystemPresenter = require("app.presenters.ChallengeMap.BuffSystemPresenter"):create()
                    BuffSystemPresenter:setOutput(MainControllLayer:getLayer("PrintLayer"))
                    ChallengeMapSystem:getInstance():getBuffSystem():setOutput(BuffSystemPresenter)

                    local titleLayer = MainControllLayer:getLayer("TitleLayer")
                    titleLayer:hide(true)

                    MainControllLayer:pushLayer("NewMapLayer")

                    MainControllLayer:getLayer("PrintLayer"):initRichText()
                    local layer = MainControllLayer:getLayer("PrintLayer")
                    layer:setLocalZOrder(10)
                    layer:show()

                    mapLayer:setMap(map)
                end
            )

            layer:setAfterFunc(
                function()
                    self:hideLayer()
                end
            )
        end
    )
end

function FestivalMapDetailPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "FestivalMapDetailPresenter",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(FestivalMapDetailPresenter)
return FestivalMapDetailPresenter
000
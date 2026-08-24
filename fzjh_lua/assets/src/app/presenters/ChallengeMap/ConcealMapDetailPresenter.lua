local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

local AbsMapDetailPresenter = require("app.presenters.ChallengeMap.AbsMapDetailPresenter")

local ConcealMapDetailPresenter = class("ConcealMapDetailPresenter", AbsMapDetailPresenter)

function ConcealMapDetailPresenter:create()
    local p = ConcealMapDetailPresenter:new()
    p:init()
    return p
end

function ConcealMapDetailPresenter:init()
    self._UI = require("app.views.ui.ChallengeMapUI.ChallengeMapDetailUI"):create()
    self._UI:addTo(self)

    self._UI:hideUI()
    self._UI:setButtonBack(
        function()
            self:hideLayer()
        end
    )
end

function ConcealMapDetailPresenter:showLayer()
    self:setIndex(1)
    self:setButtonLeft()
    self:setButtonRight()
    self:setButtonEnter()
    self:setButtonCustoms()
    self:setCurrMapUI()
    self._UI:showUI()
end

function ConcealMapDetailPresenter:setIndex(index)
    self._index = index
end

function ConcealMapDetailPresenter:setMapGroup(mapGroup)
    self._mapGroup = mapGroup
end

function ConcealMapDetailPresenter:setCurrStrain(strain)
    self._strain = strain
end

function ConcealMapDetailPresenter:setMaxStrain(strain)
    self._maxStrain = strain
end

function ConcealMapDetailPresenter:getCurrMapData()
    return self._mapGroup[self._index]
end

function ConcealMapDetailPresenter:setCurrMapUI()
    self._mapData = self._mapGroup[self._index]
    self:_setMapName()
    self:_setMapGradeSelectText()
    self:_setMapDesc()
    self:_setGradeName()
    self:_setTextFinishCon()
    self:_setTextAward()
    self:_setTextEnterConItem()
    self:_setTextEnterConLv()
    self:_setTextEnterConsume()
    self:_setTextCurrConsume()
    self:_setTextEnterCondotion()
end

function ConcealMapDetailPresenter:setButtonLeft()
    self._UI:setButtonLeft(
        function()
            if self._index > 1 then
                self._index = self._index - 1
                self:setCurrMapUI()
            end
        end
    )
end

function ConcealMapDetailPresenter:setButtonRight()
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

function ConcealMapDetailPresenter:setButtonEnter()
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

function ConcealMapDetailPresenter:setButtonCustoms()
    local args = {
        positionX = 0,
        positionY = 0,
        isVisible = false,
        text = "",
        func = EMPTY_FUNC
    }

    self._UI:setButtonCustoms(args)
end

function ConcealMapDetailPresenter:_setMapName()
    local name = self._mapData.name
    self._UI:setMapName(name)
end

function ConcealMapDetailPresenter:_setMapGradeSelectText()
    self._UI:setGradeSelectText("剧情选择")
end

function ConcealMapDetailPresenter:_setMapDesc()
    local desc = self._mapData.summary
    self._UI:setMapDesc(desc)
end

function ConcealMapDetailPresenter:_setGradeName()
    local gradeName = self._mapData.gradeName
    self._UI:setGradeName(gradeName)
end

function ConcealMapDetailPresenter:_setTextFinishCon()
    local finishTexts = self._mapData.finishText
    local texts = ""
    for i, text in ipairs(finishTexts) do
        texts = texts .. text .. "\n"
    end

    self._UI:setTextFinishCon(texts)
end

function ConcealMapDetailPresenter:_setTextAward()
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

function ConcealMapDetailPresenter:_setTextEnterConItem()
    self._UI:setTextEnterConItem("")
end

function ConcealMapDetailPresenter:_setTextEnterConLv()
    self._UI:setTextEnterConLv("")
end

function ConcealMapDetailPresenter:_setTextEnterConsume()
    self._UI:setTextEnterConsume("")
end

function ConcealMapDetailPresenter:_setTextCurrConsume()
    self._UI:setTextCurrConsume("")
end

function ConcealMapDetailPresenter:_setTextEnterCondotion()
    self._UI:setTextEnterCondotion("进入条件:"..self._mapData.econdition)
end

function ConcealMapDetailPresenter:_enterMap(map)
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

function ConcealMapDetailPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ConcealMapDetailPresenter",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ConcealMapDetailPresenter)
return ConcealMapDetailPresenter
00000000000000
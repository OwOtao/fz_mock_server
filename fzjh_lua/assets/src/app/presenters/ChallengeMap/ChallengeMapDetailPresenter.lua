local AbsMapDetailPresenter = require("app.presenters.ChallengeMap.AbsMapDetailPresenter")

local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

local ChallengMapExpendItem = require("app.models.ChallengeMap.ChallengeMapExpendItem")

local ChallengeMapDetailPresenter = class("ChallengeMapDetailPresenter", AbsMapDetailPresenter)

function ChallengeMapDetailPresenter:create()
    local p = ChallengeMapDetailPresenter:new()
    p:init()
    return p
end

function ChallengeMapDetailPresenter:init()
    self._UI = require("app.views.ui.ChallengeMapUI.ChallengeMapDetailUI"):create()
    self._UI:addTo(self)

    self._UI:hideUI()
    self._UI:setButtonBack(
        function()
            self:hideLayer()
        end
    )
end

function ChallengeMapDetailPresenter:showLayer()
    self:setIndex(1)
    self:setCurrMapUI()
    self:setButtonLeft()
    self:setButtonRight()
    self:setButtonEnter()
    self._UI:showUI()
end

function ChallengeMapDetailPresenter:setIndex(index)
    self._index = index
end

function ChallengeMapDetailPresenter:setMapGroup(mapGroup)
    self._mapGroup = mapGroup
end

function ChallengeMapDetailPresenter:setCurrStrain(strain)
    self._strain = strain
end

function ChallengeMapDetailPresenter:setMaxStrain(strain)
    self._maxStrain = strain
end

function ChallengeMapDetailPresenter:getCurrMapData()
    return self._mapGroup[self._index]
end

function ChallengeMapDetailPresenter:setCurrMapUI()
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
	self:setButtonCustoms()
end

function ChallengeMapDetailPresenter:setButtonLeft()
    self._UI:setButtonLeft(
        function()
            if self._index > 1 then
                self._index = self._index - 1
                self:setCurrMapUI()
            end
        end
    )
end

function ChallengeMapDetailPresenter:setButtonRight()
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

function ChallengeMapDetailPresenter:setButtonEnter()
    local args = {
        positionX = 278.5,
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

function ChallengeMapDetailPresenter:setButtonCustoms()
	local isVisible = true

	if not MapIsEmpty(self._mapData.notcleaningtime) then
		local startTime = self._mapData.notcleaningtime[1]

		local endTime = self._mapData.notcleaningtime[2]
		
		if startTime and endTime then
			startTime = Helper:getTimeStampWithFullStringDate(startTime)
			
			endTime = Helper:getTimeStampWithFullStringDate(endTime)

			local currTime = GetTime()

			if currTime >= startTime and currTime <= endTime then
				isVisible = false
			end
		end
	end

    local args = {
        positionX = 801.5,
        positionY = 239.5,
        isVisible = isVisible,
        text = "匆匆了事",
        func = function()
            ChallengeMapSystem:getInstance():challengeMapIsCustoms(
                self._mapData.id,
                function(isOk, arg1)
                    if isOk then
                        PopupLayerController:showLayer(
                            "ChallengeMapCustomsPresenter",
                            function(layer)
                                local conditonTexts = ChallengMapExpendItem:create(ChallengeMapSystem:getInstance():getRole(),self._mapData.ExpendItem):getTexts()
                                table.insert(conditonTexts, "轶闻值" .. self._mapData.strain)
                                layer:setConditons(conditonTexts)
                                layer:setMapData(self._mapData)
                                layer:setRole(ChallengeMapSystem:getInstance():getRole())
                                layer:setCallback(
                                    function()
                                        self._strain = self._strain - self._mapData.strain
                                        self:_setTextCurrConsume()
                                        local titleLayer = MainControllLayer:getLayer("TitleLayer")
                                        titleLayer:setAnecdoteText("『轶闻』" .. tostring(self._strain) .. "/" .. tostring(self._maxStrain))
                                    end
                                )
                                layer:showLayer()
                            end
                        )
                    else
                        local errmsg = arg1
                        PopText(errmsg)
                    end
                end
            )
        end
    }

    self._UI:setButtonCustoms(args)
end

function ChallengeMapDetailPresenter:_setMapName()
    local name = self._mapData.name
    self._UI:setMapName(name)
end

function ChallengeMapDetailPresenter:_setMapGradeSelectText()
    self._UI:setGradeSelectText("难度选择")
end

function ChallengeMapDetailPresenter:_setMapDesc()
    local desc = self._mapData.summary
    self._UI:setMapDesc(desc)
end

function ChallengeMapDetailPresenter:_setGradeName()
    local gradeName = self._mapData.gradeName
    self._UI:setGradeName(gradeName)
end

function ChallengeMapDetailPresenter:_setTextFinishCon()
    local finishTexts = self._mapData.finishText
    local texts = ""
    for i, text in ipairs(finishTexts) do
        texts = texts .. text .. "\n"
    end

    self._UI:setTextFinishCon(texts)
end

function ChallengeMapDetailPresenter:_setTextAward()
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

function ChallengeMapDetailPresenter:_setTextEnterConItem()
    local conditonTexts = ChallengMapExpendItem:create(ChallengeMapSystem:getInstance():getRole(),self._mapData.ExpendItem):getTexts()
    local conText = ""
    for i, text in ipairs(conditonTexts) do
        conText = conText..text.."\n"
    end
    self._UI:setTextEnterConItem("入场所需:")
    self._UI:setTextEnterConItems(conText)
end

function ChallengeMapDetailPresenter:_setTextEnterConLv()
    local level = self._mapData.level

    self._UI:setTextEnterConLv("入场所需等级:" .. level)
end

function ChallengeMapDetailPresenter:_setTextEnterConsume()
    local strain = self._mapData.strain
    self._UI:setTextEnterConsume("消耗轶闻:" .. strain)
end

function ChallengeMapDetailPresenter:_setTextCurrConsume()
    self._UI:setTextCurrConsume("我的轶闻:" .. self._strain)
end

function ChallengeMapDetailPresenter:_enterMap(map)
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
                    -- 进入副本
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

function ChallengeMapDetailPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ChallengeMapDetailPresenter",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ChallengeMapDetailPresenter)
return ChallengeMapDetailPresenter
0000000000000
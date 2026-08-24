local FishingPresenter = class("FishingPresenter", cc.Layer)

function FishingPresenter:create()
    local p = FishingPresenter:new()
    p:init()
    return p
end

function FishingPresenter:init()
    self.__ui = require("app.views.ui.ChallengeMapUI.MiniGame.FishingUI"):create()
    self.__ui:addTo(self)

    self.__ui:hideUI()
end

function FishingPresenter:showLayer()
    self.__fishResult = nil -- 钓鱼结果 1成功 ，2失败

    self.__fishRound = 0 --当前回合数

    self.__sucfulPosX = nil --成功区域的横坐标

    self.__sucfulAreaSize = tonumber(self.__fishingData.area)

    self:setButton1()

    self:setTitle()

    self:setDesc()

    self:setDistraction()

    self:setFocus()

    self:setCountText()

    self:setSucSize()

    self:refreshUI()

    self.__ui:showUI()

    MainControllLayer:pauseUpdate()
end

--@desc: 游戏完成后回调
--@author:Seven
--@time:2024-01-28 17:24:24
function FishingPresenter:setFinishCallbackFunc(fishFinishCallback)
    self.__fishFinishCallback = fishFinishCallback
end

function FishingPresenter:refreshUI()
    self.__ui:setButton1Enabled(true)

    -- 开始时间
    self.__startTime = GetTime()

    -- 更新剩余时间
    if self._handle ~= nil then
        self:unschedule(self._handle)
        self._handle = nil
    end

    self._handle =
        self:schedule(
        function(ft)
            self:updateTime()
        end,
        0.1
    )

    self:randomSuccessfulRegional()

    self:moveBlock()
end

function FishingPresenter:updateTime()
    local currTime = GetTime()
    local num = 0

    num = math.floor(self.__fishingData.endtime - (currTime - self.__startTime))

    if num <= 0 then
        num = 0
        self:__finishGame()
        return
    end

    self.__ui:setTime("剩余时间：" .. num .. "秒")
end

function FishingPresenter:setFishingData(fishingData)
    self.__fishingData = fishingData
end

function FishingPresenter:setRole(role)
    self.__role = role
end

function FishingPresenter:setTitle()
    self.__ui:setTitle(self.__fishingData.title)
end

function FishingPresenter:setDesc()
    self.__ui:setDesc(self.__fishingData.text)
end

function FishingPresenter:setSucSize()
    self.__ui:setSucSize(self.__sucfulAreaSize)
end

function FishingPresenter:setDistraction()
    self.__ui:setDistraction("")
end

function FishingPresenter:setFocus()
    self.__ui:setFocus("")
end

function FishingPresenter:setCountText()
    local text = self.__fishingData.attemptstext

    text = string.gsub(text, "#s", self.__fishingData.attempts)

    self.__ui:setCountText(text)
end

function FishingPresenter:setButton1()
    self.__ui:setButton1(
        self.__fishingData.buttonname,
        function()
            --提交钓鱼结果
            self:stopMoveBlock()

            self:submitResults()
        end
    )
end

function FishingPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "FishingPresenter",
        function(layer)
            self.__ui:hideUI()
            MainControllLayer:resumeUpdate()
        end
    )
end

--随机成功区域
function FishingPresenter:randomSuccessfulRegional()
    local minPosX = math.ceil(self.__sucfulAreaSize / 2)

    local maxPosX = self.__ui:getFanilWidth() - math.ceil(self.__sucfulAreaSize / 2)

    local randomPosX = math.random(minPosX, maxPosX)

    self.__sucfulPosX = randomPosX

    self.__ui:setSucPosX(randomPosX)
end

-- 移动方块
function FishingPresenter:moveBlock()
    local track = self.__ui:getTrack()

    local trackWidth = track:getSizeWidth()

    self.__ui:setTrackPosX(trackWidth / 2)

    local x1 = self.__ui:getFanilWidth() - (trackWidth / 2)

    local x2 = trackWidth / 2

    local time = Helper:getDef(self.__fishingData.movementspeed, 3)

    track:stopAllActions()

    local action =
        cc.Sequence:create(cc.MoveTo:create(0, cc.p(x2, track:getPositionY())), cc.MoveTo:create(time, cc.p(x1, track:getPositionY())), cc.MoveTo:create(time, cc.p(x2, track:getPositionY())))

    track:runAction(cc.RepeatForever:create(action))
end

-- 停止移动方块
function FishingPresenter:stopMoveBlock()
    local track = self.__ui:getTrack()

    track:stopAllActions()

    --判断是否在成功区域
    local minSucfulPosX = self.__sucfulPosX - (self.__sucfulAreaSize / 2)

    local maxSucfulPosX = self.__sucfulPosX + (self.__sucfulAreaSize / 2)

    if track:getPositionX() >= minSucfulPosX and track:getPositionX() <= maxSucfulPosX then
        --停在成功区域
        self.__fishResult = 1 --成功
    else
        self.__fishResult = 2 --失败
    end
end

function FishingPresenter:submitResults()
    self.__ui:setButton1Enabled(false)

    self.__fishRound = self.__fishRound + 1

    if self.__fishResult == 1 then
        local itemId = Helper:RandomByWeight(self.__fishingData.award, 2, 1)

        self.__role:addItemCount(itemId, 1)

        PopText("成功获得" .. Item:getOneItemByKey(itemId).name)
    else
        PopText("失败了，请再次尝试")
    end

    self:delayFunc(
        0.5,
        function()
            if self.__fishRound >= self.__fishingData.attempts then
                self:__finishGame()
            else
                self.__ui:setButton1Enabled(true)

                self:randomSuccessfulRegional()

                self:moveBlock()
            end
        end
    )
end

function FishingPresenter:__finishGame()
    if self.__fishFinishCallback then
        self.__fishFinishCallback()
    end

    if self._handle ~= nil then
        self:unschedule(self._handle)
        self._handle = nil
    end

    self:hideLayer()

    PopText("本次小挑战结束")
end

Helper:classDefNodeGetInstance(FishingPresenter)
return FishingPresenter
00
--[[
    author:Seven
    time:2023-04-17 14:54:30
    desc:
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local NetUpdater = {}

function NetUpdater:create(client)
    return NetUpdater.new():__init(client)
end

function NetUpdater:ctor()
    self.__view_frame_index = 0

    self.__logic_frame_index = 0

    self.__multiple = math.ceil(FightCommons.VIWE_FPS / FightCommons.LOGIC_FPS)

    -- --@desc 逻辑帧间隔，固定时间
    self.__LOGIC_UPDATE_DURATION = 1 / FightCommons.LOGIC_FPS

    self.__logic_frames = {}

    self.__isFinish = false

    --@desc 缓存帧数最大值
    self.__netFrameIndex = -1
end

function NetUpdater:__init(netNode)
    --@RefType [src.app.models.net.NetNode#NetNode]
    self.__netClient = netNode

    local testNumber = 0

    self.__netClient:registerMessageDispatch(
        "fight_room_frame",
        function(data)
            self:__putFrameData(data.frame, data.inputs or {}, data.seed)
        end
    )

    self.__netClient:registerMessageDispatch(
        "fight_start_fail",
        function(data)
            if self.__fight then
                self.__fight:destory()
            end

            if self.__view then
                self.__view:destory()
            end

            PopText(string.format("战斗开始失败，房间已解散(%s)", tostring(data.reason)))
        end
    )

    self.__netClient:registerNetDisconnectCallback(
        function(code)
            if not self.__isFinish then
                PopupLayerController:showLayer(
                    "TipsPopFullScreenLayer",
                    function(layer)
                        layer:showLayer("网络发生异常（" .. tostring(code) .. "）")
                        layer:setButton1(
                            "退出",
                            function()
                                if self.__fight then
                                    self.__fight:destory()
                                end

                                if self.__view then
                                    self.__view:destory()
                                end
                            end
                        )
                        layer:setButton2(nil, nil)
                    end
                )
            end
        end
    )

    return self
end

function NetUpdater:isOnline()
    return true
end

function NetUpdater:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
end

function NetUpdater:setView(fightView)
    --@RefType [FightMainView]
    self.__view = fightView
end

function NetUpdater:startFight()
    self.__netClient:send("player_fight_ready", {})

    scheduler.performWithDelayGlobal(
        function()
            self:__startUpdate()
        end,
        0.001
    )
end

function NetUpdater:__startUpdate()
    if self.__view then
        self.__view:showReadyPanel()
        self.__handle =
            self.__view:schedule(
            function(ft)
                self:update(ft)
            end,
            1 / FightCommons.VIWE_FPS
        )
    else
        self.__handle =
            Game:schedule(
            function(ft)
                self:update(ft)
            end,
            1 / FightCommons.VIWE_FPS
        )
    end
end

function NetUpdater:__destoryUpdate()
    if self.__view then
        if self.__handle then
            self.__view:unschedule(self.__handle)
        end
    else
        if self.__handle then
            Game:unschedule(self.__handle)
        end
    end
end

function NetUpdater:finish()
    self.__isFinish = true
end

function NetUpdater:fightEnd()
    self.__netClient:disconnect()
end

function NetUpdater:destory()
    self:__destoryUpdate()
end

function NetUpdater:sendData(proto, data)
    self.__netClient:send(proto, data)
end

function NetUpdater:sendPlayerPrepOperation(data)
    self:sendData("player_fight_input", data)
end

function NetUpdater:__putFrameData(frameIndex, input, seed)
    if self.__logic_frames[tostring(frameIndex)] ~= nil then
        error("检查流程，已经存在帧数据 ， frameIndex : " .. tostring(frameIndex))
    end

    if tonumber(frameIndex) ~= self.__netFrameIndex + 1 then
        error("检查流程，帧数据不连续， frameIndex : " .. tostring(frameIndex) .. " , self.__netFrameIndex : " .. tostring(self.__netFrameIndex))
    end

    self.__netFrameIndex = tonumber(frameIndex)

    if self.__netFrameIndex == 1 and self.__view and self.__view:readyPanelIsShow() == true then
        self.__view:hideReadyPanel()
        self.__netClient:unregisterMessageDispatch("fight_start_fail")
    end

    self.__logic_frames[tostring(frameIndex)] = {
        frameIndex = frameIndex,
        data = input,
        seed = seed
    }
end

function NetUpdater:getLogicIndex()
    return self.__logic_frame_index
end

function NetUpdater:__getFrameData(index)
    return self.__logic_frames[tostring(index)]
end

function NetUpdater:__updateDelay(ft)
    self.__lastDelayUpdateTime = self.__lastDelayUpdateTime or 0

    if self.__lastDelayUpdateTime >= 2 or self.__lastDelayUpdateTime == 0 then
        self.__view:updateMs(self.__netClient:getDelay())
        self.__lastDelayUpdateTime = 0.0001
    end

    self.__lastDelayUpdateTime = self.__lastDelayUpdateTime + ft
end

function NetUpdater:__updateView(ft)
    FightUtil:printTemplateLog("VIEW_FRAME_START", self.__view_frame_index)
    if self.__view then
        self.__view:updateView(ft)
    end
    FightUtil:printTemplateLog("VIEW_FRAME_END", self.__view_frame_index)

    self.__view_frame_index = self.__view_frame_index + 1
end

function NetUpdater:__logicUpdate(ft, framedata, seed)
    if seed then
        FightUtil:setRandomSeed(seed)
    end

    self.__fight:putCurrentFrameData(framedata)

    FightUtil:printTemplateLog("LOGIC_FRAME_START", self.__logic_frame_index)

    self.__fight:update(self.__LOGIC_UPDATE_DURATION)

    FightUtil:printTemplateLog("LOGIC_FRAME_END", self.__logic_frame_index)

    self:__updateView(ft)

    self.__logic_frames[tostring(self.__logic_frame_index)] = nil

    self.__logic_frame_index = self.__logic_frame_index + 1

    self.__fight:setLogicIndex(self.__logic_frame_index)
end

function NetUpdater:update(ft)
    self:__updateDelay(ft)
    if self.__netFrameIndex - self.__logic_frame_index >= 10 then
        self.__speedUpdating = true
    end

    if self.__speedUpdating == true then
        for i = 1, 3 do
            self:__updateFight(ft)
        end

        if self.__netFrameIndex - self.__logic_frame_index <= 3 then
            self.__speedUpdating = false
        end

        return
    else
        self:__updateFight(ft)
    end
end

function NetUpdater:__updateFight(ft)
    if (self.__view_frame_index % self.__multiple) == 0 then
        if self.__isFinish then
            self:__logicUpdate(ft, {}, nil)
            return
        end

        if self.__waitCache ~= true and self:__getFrameData(self.__logic_frame_index + 2) ~= nil then
            local currLogicFrame = self:__getFrameData(self.__logic_frame_index)
            self:__logicUpdate(ft, currLogicFrame.data, currLogicFrame.seed)
        else
            if not self.__waitCache then
                -- self.__waitCache = true
                -- local af = self.__pingService:getAF()
                -- -- 波动值小，代表网络相对稳定
                -- if af < 40 then
                --     self.__waitCacheCount = 2
                -- elseif af < 80 then
                --     -- 波动值中，代表网络不稳定
                --     self.__waitCacheCount = 10
                -- else
                --     -- 波动值大，代表网络延迟高且不稳定
                --     self.__waitCacheCount = 15
                -- end
            else
                if self:__getFrameData(self.__logic_frame_index + self.__waitCacheCount) then
                    self.__waitCache = false
                end
            end
        end
    else
        self:__updateView(ft)
    end
end

return newClass("NetUpdater", {}, NetUpdater)
0000000000000000
--[[
    author:Seven
    time:2024-04-19 14:17:44
    desc:
]]
local newClass = require("third.class.NewClass")

local LocalUpdater = require("app.FightSystem.Updater.LocalUpdater")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ReplayUpdater = {}

function ReplayUpdater:create(...)
    return ReplayUpdater.new():__init(...)
end

function ReplayUpdater:ctor()
    self.__view_frame_index = 0

    self.__logic_frame_index = 0

    self.__multiple = math.ceil(FightCommons.VIWE_FPS / FightCommons.LOGIC_FPS)

    --@desc 逻辑帧间隔，固定时间
    self.__LOGIC_UPDATE_DURATION = 1 / FightCommons.LOGIC_FPS

    self.__current_time = 0

    self.__logic_frames = {}

    self.__is_start = false

    self.__is_finish = false
end

function ReplayUpdater:__init(frames)
    self.__reply_frames = frames
    return self
end

function ReplayUpdater:sendPlayerPrepOperation(data)
end

function ReplayUpdater:__pushReplayData()
    if self.__isFinish then
        self.__fight:putCurrentFrameData({})
        return
    end

    local frame = self.__reply_frames[tostring(self.__logic_frame_index)]

    local data = frame.inputs

    local seed = frame.seed

    if seed then
        FightUtil:setRandomSeed(seed)
    end

    self.__fight:putCurrentFrameData(data)
end

function ReplayUpdater:update(ft)
    if self.__logic_frame_index == 0 then
        if self.__view then
            self.__view:hideReadyPanel()
        end
    end

    if (self.__view_frame_index % self.__multiple) == 0 then
        self:__pushReplayData()
        self:__updateLocal(ft)
    else
        self:__updateView(ft)
    end
end

return newClass("ReplayUpdater", {LocalUpdater}, ReplayUpdater)
000000
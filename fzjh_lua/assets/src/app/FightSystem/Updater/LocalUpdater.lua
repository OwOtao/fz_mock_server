--[[
    author:Seven
    time:2022-08-09 14:42:53
    desc: 本地战斗更新
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local LocalUpdater = {}

function LocalUpdater:create()
    return LocalUpdater.new()
end

function LocalUpdater:ctor()
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

function LocalUpdater:isOnline()
    return false
end

function LocalUpdater:finish()
    self.__isFinish = true
end

function LocalUpdater:fightEnd()
end

function LocalUpdater:sendPlayerPrepOperation(data)
    table.insert(self.__logic_frames[tostring(self.__logic_frame_index)].data, data)
end

--@desc: 提取当前帧数据
--@author:Seven
--@time:2023-02-14 21:08:04
function LocalUpdater:__pushPrevFrameData()
    local frameData = self.__logic_frames[tostring(self.__logic_frame_index - 1)]
    if self.__logic_frame_index == 0 then
        frameData = {}
    end

    if frameData == nil then
        assert(false, "LocalUpdater:__pushPrevFrameData 没有帧数据信息，请查看代码 : " .. tostring(self.__logic_frame_index))
    end

    self.__fight:putCurrentFrameData(frameData.data)
end

function LocalUpdater:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
end

function LocalUpdater:setView(fightView)
    --@RefType [FightMainView]
    self.__view = fightView
end

function LocalUpdater:startFight()
    if self.__view then
        self.__view:showReadyPanel()
    end
    scheduler.performWithDelayGlobal(
        function()
            self.__handle =
                Game:schedule(
                function(ft)
                    self:update(ft)
                end,
                1 / FightCommons.VIWE_FPS
            )
        end,
        0.001
    )
end

function LocalUpdater:destory()
    if self.__handle then
        Game:unschedule(self.__handle)
    end
end

function LocalUpdater:getLogicIndex()
    return self.__logic_frame_index
end

function LocalUpdater:__updateLocal(ft)
    FightUtil:printTemplateLog("LOGIC_FRAME_START", self.__logic_frame_index)
    self.__fight:update(self.__LOGIC_UPDATE_DURATION)
    FightUtil:printTemplateLog("LOGIC_FRAME_END", self.__logic_frame_index)
    self:__updateView(ft)
    self.__logic_frame_index = self.__logic_frame_index + 1
    self.__fight:setLogicIndex(self.__logic_frame_index)
end

function LocalUpdater:update(ft)
    if self.__view_frame_index == 0 then
        --@desc 第0帧 都不做事情
        self.__logic_frames[tostring(self.__logic_frame_index)] = {
            frameIndex = self.__logic_frame_index,
            data = {}
        }

        self.__view_frame_index = self.__view_frame_index + 1

        self.__logic_frame_index = self.__logic_frame_index + 1

        self.__logic_frames[tostring(self.__logic_frame_index)] = {
            frameIndex = self.__logic_frame_index,
            data = {}
        }

        self.__fight:setLogicIndex(self.__logic_frame_index)

        if self.__view then
            self.__view:hideReadyPanel()
        end

        return
    end

    if (self.__view_frame_index % self.__multiple) == 0 then
        self:__pushPrevFrameData()
        self:__updateLocal(ft)

        self.__logic_frames[tostring(self.__logic_frame_index)] = {
            frameIndex = self.__logic_frame_index,
            data = {}
        }
    else
        self:__updateView(ft)
    end
end

function LocalUpdater:__updateView(ft)
    local viewIndex = self.__view_frame_index
    FightUtil:printTemplateLog("VIEW_FRAME_START", viewIndex)
    if self.__view then
        self.__view:updateView(ft)
    end
    self.__view_frame_index = self.__view_frame_index + 1
    FightUtil:printTemplateLog("VIEW_FRAME_END", viewIndex)
end

return newClass("LocalUpdater", {}, LocalUpdater)
000
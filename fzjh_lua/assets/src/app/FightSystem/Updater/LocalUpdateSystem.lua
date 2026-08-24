local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType[src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

--@SuperType [src.app.FightSystem.AFightSystem#AFightSystem]
local LocalUpdateSystem = {}

function LocalUpdateSystem:init()
    self.__view_frame_index = 0

    self.__logic_frame_index = 0

    self.__multiple = math.ceil(FightCommons.VIWE_FPS / FightCommons.LOGIC_FPS)

    --@desc 逻辑帧间隔，固定时间
    self.__LOGIC_UPDATE_DURATION = 1 / FightCommons.LOGIC_FPS

    self.__current_time = 0

    self.__next_logic_runtime = 0

    self.__logic_frames = {}

    self.__is_start = false

    self.__is_finish = false
end

function LocalUpdateSystem:connect(callback)
    return callback(true)
end

function LocalUpdateSystem:reconnent(callback)
    return callback(true)
end

function LocalUpdateSystem:getLogicFrameIndex()
    return self.__logic_frame_index
end

function LocalUpdateSystem:start()

    MainControllLayer:pauseUpdate()


    self.__is_start = true
end

function LocalUpdateSystem:sendCmds(cmds)
    self:putFrameCmd(
        {
            frameIndex = self.__logic_frame_index,
            cmds = Helper:getDef(cmds, {})
        }
    )

    FightUtil:printLog("LocalUpdateSystem:sendCmds 发送数据：")
    FightUtil:printLog(cmds)
end

--@desc:
--@author:Seven
--@time:2021-06-18 18:04:31
--@frame_cmd: 帧数据
--@return
function LocalUpdateSystem:putFrameCmd(frame_cmd)
    local logic_index = frame_cmd.frameIndex
    if self.__logic_frame_index < logic_index then
        assert(false, "收到命令帧的帧数大于当前帧数，请检查代码！")
    end

    local cmds = frame_cmd.cmds

    self.__fight:addCommand(logic_index, cmds)
end

function LocalUpdateSystem:finish()
    self.__is_finish = true
    -- self.__node:unschedule(self.__updateTag)
    -- MainControllLayer:delayFunc(
    --     0.1,
    --     function()
    --         self.__node:removeFromParent()
    --     end
    -- )
end

function LocalUpdateSystem:__isKeyFrame()
    return (self.__view_frame_index % self.__multiple) == 0
end

function LocalUpdateSystem:__update(ft)
    if self.__view_frame_index == 0 then
        self.__fight:updateView(ft)
        self.__view_frame_index = self.__view_frame_index + 1
        self.__next_logic_runtime = self.__next_logic_runtime + self.__LOGIC_UPDATE_DURATION
        return
    end
    FightUtil:printLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 渲染帧【", self.__view_frame_index , "】开始 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    if self:__isKeyFrame() then
        FightUtil:printLog("┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅ 逻辑帧【", self.__logic_frame_index , "】开始 ┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅")
        if self.__fight:isFinish() == false then
            self.__fight:update(self.__LOGIC_UPDATE_DURATION)
        elseif self.__is_finish == false then
            FightUtil:printLog("战斗结束，战斗结果：" , tostring(self.__fight:isWin()))
            self:finish()
        end
        FightUtil:printLog("┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅ 逻辑帧【", self.__logic_frame_index , "】结束 ┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅")

        self.__logic_frame_index = self.__logic_frame_index + 1

        BattleGlobalData:getInstance():put("m_logic_index", self.__logic_frame_index)
    end

    self.__fight:updateView(ft)

    FightUtil:printLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 渲染帧【", self.__view_frame_index , "】结束 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    self.__view_frame_index = self.__view_frame_index + 1
end

function LocalUpdateSystem:release()
    BattleGlobalData:destoryInstance()
end

function LocalUpdateSystem:update(ft)
    if self.__is_start then
        self:__update(ft)
    end
end

return class("LocalUpdateSystem", {require("app.FightSystem.AFightSystem")}, LocalUpdateSystem)
00000000000
--[[
    author:Seven
    time:2023-02-14 16:55:57
    desc: 战斗帧消息管理系统
]]
local newClass = require("third.class.NewClass")

local AFightSystem = require("app.FightSystem.Fight.BasicBattleSystem.AFightSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.Fight.BasicBattleSystem.AFightSystem#AFightSystem]
local FightFrameMessageSystem = {}

FightFrameMessageSystem.SYSTEM_NAME = "FightFrameMessageSystem"

function FightFrameMessageSystem:create(fight)
    return FightFrameMessageSystem.new():__init(fight)
end

function FightFrameMessageSystem:ctor()
    --@desc 当前帧需要处理的帧数据
    self.__frameData = {}
end

function FightFrameMessageSystem:__init(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight

    return self
end

--@desc: 放入当前帧要处理的数据
--@author:Seven
--@time:2023-02-14 20:16:21
--@data: 帧数据
function FightFrameMessageSystem:putCurrentFrameData(data)
    self.__frameData = data
end

--@desc: 处理当前帧数据
--@author:Seven
--@time:2023-02-14 18:13:08
function FightFrameMessageSystem:handleCurrFrameData()
    if self.__frameData == nil then
        error("FightFrameMessageSystem:getAndClearCurrentFrameData 当前帧还未收到数据，不应该执行")
    end

    local data = self.__frameData

    self.__frameData = nil

    if MapIsEmpty(data) == true then
        return
    end

    for i, v in ipairs(data) do
        self.__fight:pushCharacterOperationAction(v.o_type, v.c_id, v.args)
    end
end

return newClass("FightFrameMessageSystem", {}, FightFrameMessageSystem)
0
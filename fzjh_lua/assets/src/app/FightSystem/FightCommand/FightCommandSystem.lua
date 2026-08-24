--[[
    --@desc 参战系统
]]
local class = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local CommandFactory = require("app.FightSystem.Factory.FightCommandFactory.CommandFactory")

--@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

--@SuperType [src.app.FightSystem.AFightSystem#AFightSystem]
local FightCommandSystem = {}

function FightCommandSystem:init()
    self.__send_cmds = {}
    --@desc 等处理的命令
    self.__cmd_list = {
        ["0"] = {}
    }
end

function FightCommandSystem:release()
    self.__cmd_list = {["0"] = {}}
end

function FightCommandSystem:addCommands(frame_index, cmds)
    if self.__cmd_list[tostring(frame_index)] == nil then
        self.__cmd_list[tostring(frame_index)] = {}
    end

    self.__cmd_list[tostring(frame_index)] = cmds
end

function FightCommandSystem:runCmd()
end

--@desc: 添加需要发送的数据
--@author:Seven
--@time:2021-06-18 15:14:35
--@cmd_data: 自定义数据
function FightCommandSystem:putSendCmd(cmd_data)
    table.insert(self.__send_cmds, cmd_data)
end

function FightCommandSystem:getSendCmds()
    return self.__send_cmds
end

--@desc: 清理待发送数据。
--@author:Seven
--@time:2021-06-18 15:18:40
function FightCommandSystem:clearSendCmds()
    self.__send_cmds = {}
end

function FightCommandSystem:__runCmds()
    local curr_frame_index = BattleGlobalData:getInstance():get("m_logic_index")

    --@desc 第0帧没数据不处理
    if curr_frame_index == 0 then
        return
    end

    local pre_frame_index = curr_frame_index - 1

    local cmds = self.__cmd_list[tostring(pre_frame_index)]

    if cmds == nil then
        error("cmds 是空值，pre_frame_index : " .. pre_frame_index)
    end

    if #cmds == 0 then
        FightUtil:printLog("FightCommandSystem runCmd : 当前帧【", curr_frame_index , "】没有要执行的命令")
        return
    end

    for i = 1, #cmds do
        local cmd_data = cmds[i]

        local cmd = CommandFactory:createFightCommand(cmd_data.type, cmd_data.c_id, cmd_data.data, self.__fight)

        cmd:runCommand()
    end

    self.__cmd_list[tostring(pre_frame_index)] = nil
end

function FightCommandSystem:update(ft)
    self:__runCmds()
end

return class("FightCommandSystem", {require("app.FightSystem.AFightSystem")}, FightCommandSystem)
0000
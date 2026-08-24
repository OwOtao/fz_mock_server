local newClass = require("third.class.NewClass")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local ICharacterCommand = require("app.FightSystem.FightRole.CharacterCommands.ICharacterCommand")

local CharacterCmdSystem = {
    __cmds = {}
}

function CharacterCmdSystem:create()
    return CharacterCmdSystem.new()
end

function CharacterCmdSystem:canAddCmd()
    local listCount = table.getn(self.__cmds)

    if listCount >= BattleConstConf:get("zhaoQueueLimit") then
        FightUtil:printLog(" CharacterCmdSystem:canAddCmd 战场行动已满，无法添加新的操作。")
        return false, TextResManager:getText("1011")
    end

    return true
end

function CharacterCmdSystem:getCharacterCmdCount(c_id)
    local count = 0
    for i = table.getn(self.__cmds), 1, -1 do
        --@RefType [src.app.FightSystem.FightRole.CharacterCommands.ICharacterCommand#ICharacterCommand]
        local cmd = self.__cmds[i]

        if cmd:getOwnerId() == c_id then
            count = count + 1
        end
    end

    return count
end

function CharacterCmdSystem:getCharacterCmdCountByCmdType(c_id, cmd_type)
    local count = 0
    for i = table.getn(self.__cmds), 1, -1 do
        --@RefType [src.app.FightSystem.FightRole.CharacterCommands.ICharacterCommand#ICharacterCommand]
        local cmd = self.__cmds[i]

        if cmd:getOwnerId() == c_id and cmd:getCmdType() == cmd_type then
            count = count + 1
        end
    end

    return count
end

function CharacterCmdSystem:getCharacterCmdsByType(c_id, cmd_type)
    local list = {}
    for i = table.getn(self.__cmds), 1, -1 do
        --@RefType [src.app.FightSystem.FightRole.CharacterCommands.ICharacterCommand#ICharacterCommand]
        local cmd = self.__cmds[i]

        if cmd:getOwnerId() == c_id and cmd:getCmdType() == cmd_type then
            table.insert(list, cmd)
        end
    end

    return list
end

function CharacterCmdSystem:addCharacterCommand(cmd)
    FightUtil:printLog("CharacterCmdSystem:addCharacterCommand 添加命令：")
    table.insert(self.__cmds, isImplement(cmd, ICharacterCommand))
    self:__sortCommands()
end

function CharacterCmdSystem:removeCharacterAllCommand(c_id)
    for i = table.getn(self.__cmds), 1, -1 do
        --@RefType [src.app.FightSystem.FightRole.CharacterCommands.ICharacterCommand#ICharacterCommand]
        local cmd = self.__cmds[i]

        if cmd:getOwnerId() == c_id then
            table.remove(self.__cmds, i)
        end
    end

    self:__sortCommands()
end

--@author:Seven
--@time:2022-01-13 16:02:23
--@return [src.app.FightSystem.FightRole.CharacterCommands.ACharacterCommand#ACharacterCommand]
function CharacterCmdSystem:getFirstCommand()
    return self.__cmds[1]
end

function CharacterCmdSystem:removeCharacterCommand(cmd)
    for i = 1, table.getn(self.__cmds) do
        local currCmd = self.__cmds[i]
        if currCmd == cmd then
            table.remove(self.__cmds, i)
            return
        end
    end

    error("CharacterCmdSystem:removeCommand 移除的命令并没在队列中，请检查代码")
end

function CharacterCmdSystem:__sortCommands()
    FightUtil:printLog("~~~~~~~~~~~~~~~~~~ 命令排序开始 ~~~~~~~~~~~~~~~~~~~~~")
    FightUtil:printLog("CharacterCmdSystem:__sortCommands : 排序前")
    for i = 1, table.getn(self.__cmds) do
        local cmd = self.__cmds[i]
        FightUtil:printLog("index：", i, ", type:", cmd:getCmdType(), " ,frameIndex :", cmd:getFrameIndex(), ", Priority", cmd:getPriority())
    end

    table.heapSort(
        self.__cmds,
        function(a, b)
            --@RefType [src.app.FightSystem.FightRole.CharacterCommands.ACharacterCommand#ACharacterCommand]
            a = a
            --@RefType [src.app.FightSystem.FightRole.CharacterCommands.ACharacterCommand#ACharacterCommand]
            b = b

            if a:getPriority() > b:getPriority() then
                return true
            end

            if a:getPriority() == b:getPriority() then
                return a:getFrameIndex() >= b:getFrameIndex()
            end

            return false
        end
    )
    FightUtil:printLog("CharacterCmdSystem:__sortCommands : 排序后")
    for i = 1, table.getn(self.__cmds) do
        local cmd = self.__cmds[i]
        FightUtil:printLog("index：", i, ", type:", cmd:getCmdType(), " ,frameIndex :", cmd:getFrameIndex(), ", Priority", cmd:getPriority())
    end
    FightUtil:printLog("~~~~~~~~~~~~~~~~~~ 命令排序结束 ~~~~~~~~~~~~~~~~~~~~~")
end

function CharacterCmdSystem:checkCanAddList(c_id)
    local tips
    local characterPrepCount = self:getCharacterCmdCount(c_id)

    if characterPrepCount >= BattleConstConf:get("oneRoleZhaoQueueLimit") then
        FightUtil:printLog(string.format("CharacterCmdSystem:checkCanAddList %s 队列中已申请 %d 个操作 , 无法加入队列", tostring(c_id), characterPrepCount))
        return false
    end

    local isCanAdd, tips = self:canAddCmd()

    if not isCanAdd then
        return false, tips
    end

    return true
end

return newClass("CharacterCmdSystem", {}, CharacterCmdSystem)
000000
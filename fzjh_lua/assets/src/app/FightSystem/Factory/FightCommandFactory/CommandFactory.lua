local CommandFactory = {}

local FightCommons = require("app.FightSystem.FightCommons")

local CMD_TYPE = FightCommons.FIGHT_CMD_TYPE

--@desc: 创建命令
--@author:Seven
--@time:2021-06-18 15:35:03
--@return [src.app.FightSystem.FightCommand.ACommand#ACommand]
function CommandFactory:createFightCommand(c_type, c_id, data, fight)
    local cmdClass

    if c_type == CMD_TYPE.TEST then
        cmdClass = require("app.FightSystem.FightCommand.Command.TestCommand")
    elseif c_type == CMD_TYPE.CHARACTER_ACTIVE then
        cmdClass = require("app.FightSystem.FightCommand.Command.CharacterActiveCmd")
    elseif c_type == CMD_TYPE.CHARACTER_RUNAWAY then
        cmdClass = require("app.FightSystem.FightCommand.Command.CharacterRunawayCmd")
    elseif c_type == CMD_TYPE.CHANGE_WEAPON then
        cmdClass = require("app.FightSystem.FightCommand.Command.FChangeWeaponCmd")
    elseif c_type == CMD_TYPE.RECOVER_QI then
        cmdClass = require("app.FightSystem.FightCommand.Command.FRecoverQiCmd")
    end

    --@RefType[src.app.FightSystem.FightCommand.ACommand#ACommand]
    local cmd = cmdClass:create()

    cmd:setFight(fight)

    cmd:setCharacterId(c_id)

    if MapIsEmpty(data) == false then
        for k, v in pairs(data) do
            cmd:putData(k, v)
        end
    end

    return cmd
end

return CommandFactory
00000000000
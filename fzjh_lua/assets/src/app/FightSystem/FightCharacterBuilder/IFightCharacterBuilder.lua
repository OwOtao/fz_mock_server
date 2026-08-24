--[[
    author:Seven
    time:2024-01-19 16:49:46
    desc:
]]
local interface = require("third.class.interface")

local IFightCharacterBuilder = {}

--@desc: 创建战斗角色
--@author:Seven
--@time:2024-01-22 16:45:37
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function IFightCharacterBuilder:buildCharacter()
end

return interface("IFightCharacterBuilder", IFightCharacterBuilder)
000000000000
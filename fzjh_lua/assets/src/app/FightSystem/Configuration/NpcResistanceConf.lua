--[[
    author:Seven
    time:2025-05-14 14:54:45
    desc: NPC抗性配置
]]
local npcResistanceConf = require("script.newbattle.demo.npcResistanceConf")["data"]

local NpcResistanceConf = {}

function NpcResistanceConf:getNpcResistanceWithClassType(classTypeId)
    local list = {}

    for k, v in pairs(npcResistanceConf) do
        if tostring(v.class) == tostring(classTypeId) then
            table.insert(list, v)
        end
    end

    return list
end

return NpcResistanceConf
000000000000000
--[[
    NPC属性模板
]]
local npcAttrConfRes = require("script.newbattle.demo.npcAttrConf")["战斗属性"]

local NpcAttrConf = {}

function NpcAttrConf:getConf(id)
    local conf = npcAttrConfRes[tostring(id)]

    if conf == nil then
        assert(false, "找不到NPC 战斗属性 id ：" .. id)
    end

    return conf
end

return NpcAttrConf
000000000000
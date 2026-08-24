local Npc = require("app.models.npc.Npc")
local Role = require("app.models.role.Role")

local DreamNpc = {}

function DreamNpc:create(npc_info)
    --#TODO npc初始属性baseId被Npc:initNpc覆盖，后续需检查改动会否影响之前的功能
    local baseId = npc_info.baseId
    local npc = Npc:initNpc(npc_info)
    npc.baseId = baseId
    npc = Helper:tableCover(Role:create(), npc)
    npc:addSubModuleTo("RoleModule", "app.models.role.module.dream.RoleDreamNpcModule")
    return npc
end

return DreamNpc
0000000000
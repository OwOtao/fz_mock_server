-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 17:40:45
-- @desc 战斗中效果管理器
local FightEffectManager = {}

defVars(FightEffectManager,
    {
            
    })

function FightEffectManager:create()
    local p = clone(FightEffectManager)
    p:init()
    return p
end

function FightEffectManager:init()
end

return FightEffectManager
00000000
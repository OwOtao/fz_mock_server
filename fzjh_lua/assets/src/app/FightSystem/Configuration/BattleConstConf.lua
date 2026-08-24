local battleConfRes = require("script.newbattle.demo.battleConst")["战斗通用参数"]
local BattleConstConf = {}

function BattleConstConf:get(key)
    local info = battleConfRes[key]

    if info == nil then
        assert(false, "没有 id 为 ：" .. key .. " 的战斗配置参数！")
    end

    return info.content
end

return BattleConstConf
0000000000000000
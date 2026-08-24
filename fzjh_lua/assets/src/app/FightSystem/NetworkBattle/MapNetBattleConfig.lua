--[[
    author:Seven
    time:2024-02-27 17:23:48
    desc:网络战斗配置文件
]]
return inherit(
    {
        systemMap = {
            finishStrategy = "app.FightSystem.NetworkBattle.MapNetBattleFinishStrategy"
        }
    },
    require("app.FightSystem.Fight.SystemConfig.BasicBattleSystemConfig")
)
0000000000
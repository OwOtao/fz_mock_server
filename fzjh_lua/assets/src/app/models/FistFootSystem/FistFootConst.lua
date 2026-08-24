local FistFootConst = {
    --任务类型
    TaskType = {
        Quan = 1,
        Zhang = 2,
        Zhua = 3,
        Zhi = 4,
        Tui = 5,
        Character = 6,
        Plot = 7,
        Loop = 8,
    },

    --任务状态类型
    TaskStateType = {
        Lock = 0, --未解锁
        Unlock = 1, --解锁(不在冷却中）
        Cd = 2 --解锁（冷却中）
    },

    --任务冷却类型
    TaskCdType = {
        None = 1, --无需冷却，做完立即刷新
        Interval = 2, --间隔时间刷新，任务完成后间隔多久刷新
        Fixed = 3 --固定时间点刷新
    },


    AwardType = {
        Exp = 1, --阅历经验
        RefExp = 2,--特性经验
        Item = 3,--剧情道具
        Net = 4,--服务器资源
    },

    TechniqueType = {
        Normal = 0, --普通技巧，不可领悟特性
        Special = 1  --特殊技巧，可领悟特性
    },

    --重置天赋页货币类型
    ResetTalentCurrType = {
        YuanBao = 1
    }
}

function FistFootConst:getConf(id)
    local paramConf = require("script.fistFoot.fistFootConst")["data"]

    if paramConf[tostring(id)] == nil then
        error("  FistFootConst:getConf  参数找不到 id = "..id)
    end
    
    return paramConf[tostring(id)].content
end

return FistFootConst
00000000000000
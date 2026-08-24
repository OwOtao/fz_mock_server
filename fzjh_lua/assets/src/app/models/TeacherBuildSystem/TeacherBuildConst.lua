local TeacherBuildConst = {
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

    --师门建筑状态
    BuildStateType = {
        None = 0,--未开始
        BuildIng = 1,--建造中
    },

    --建筑功能按钮状态
    BuildEffectButtonType = {
        None = 0, --无
        Have = 1, --有
    },

    --建筑功能效果类型
    BuildEffectType = {
        Transfer = "transfer", --判师
        Extra = "extra",  --增加可以装备的门外武学数量
        ReputationStore = "shop", --功绩商店
        DonateShop = "donateshop", --兑换商店
        Promote = "pursue",         --振兴门派
        SupportShop = "supportshop", --易物堂
    },

    TaskType = {
        Reputation = 1, --功绩任务
        Gbpoint = 2, --门派建设值任务
        Bmaterials = 3, --建筑
        Renown = 4 --资历
    },

    TaskTypeName = {
        Reputation = "功绩",
        Gbpoint = "昌盛度", 
        Bmaterials = "建筑",
        Renown = "资历"
    },

    --师门状态标识UI个数
    FamilyStateUICount = 8
    
}

return TeacherBuildConst
000
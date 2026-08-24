local IntelligenceConstants = {}

--@desc 技巧类情报生成数量
IntelligenceConstants.Technique_num = 1

--@desc 情报是否阅读
IntelligenceConstants.UnRead = 0 
IntelligenceConstants.IsRead = 1

--@desc 模板能否生成技巧类情报
IntelligenceConstants.TechniqueOpen = {
    UnOpen = 0,--不生成技巧类情报
    Open = 1,--生成技巧类情报
}

--@desc 购买情报模板所需货币类型
IntelligenceConstants.CurrencyType = {
    Suiyin = 1,--碎银
    Yinpiao = 2,--银票
    Yuanbao = 3,--元宝
}

--@desc 购买情报模板所需货币类型
IntelligenceConstants.CurrencyName = {
    [1] = "碎银",
    [2] = "银票",
    [3] = "元宝"
}

--@desc 情报解锁条件类型
IntelligenceConstants.UnLockConType = {
    UnCondition = 0,--无条件
    CompleteMap = 1,--通关副本
    RoleLv = 2,--人物等级区间
    InheritCount = 3,--传承次数
    Intelligence = 4,--已抽到过指定情报
    Family = 5,--门派
}

--@desc 情报类型
IntelligenceConstants.IntelligenceType = {
    Activity = 1,--活动类
    Plot = 2,--剧情类
    Technique = 3,--技巧类
}

--@desc 情报是否开放
IntelligenceConstants.OpenType = {
    UnOpen = 0,--未开放
    Open = 1,--开放
}

return IntelligenceConstants000
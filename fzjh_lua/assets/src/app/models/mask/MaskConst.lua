local MaskConst = {}

-- 1=消耗道具
-- 2=角色等级
-- 3=传承次数
-- 4=声望
-- 5=碎银
-- 6=银票
-- 7=饰品材料
-- 8=纵横令
-- 9=性别
-- 10=称号
MaskConst.Condition = {
    Item = 1,
    Lv = 2,
    InheritCount = 3,
    Prestige = 4,
    Money = 5,
    Yinpiao = 6,
    Spcl = 7,
    Zongheng = 8,
    Sex = 9,
    Title = 10,
    PayMaskMake = 11,
}

MaskConst.ConditionAttr = {
    [4] = "prestige",
    [5] = "money",
    [6] = "yinpiao",
    [7] = "spcl",
    [8] = "zongheng",
    [11] = "paymaskmake"
}

MaskConst.MakeMaskGiftState = {
    UnOpenTime = 0, --未到开放时间
    UnMake = 1, --未制作
    Received = 2, --已领取未领取完
    CanReceive = 3, --可领取
    AllReceive = 4, --全部领取
}

return MaskConst
000000
local HiddenMeridianConstants = {}

HiddenMeridianConstants.ResItemId = "ygpill"

--一个加速资源可加速时间(秒s)
HiddenMeridianConstants.SpeedUpTime = 300

--经脉buff属性显示时的倍率
HiddenMeridianConstants.BuffAttrMult = 10000

HiddenMeridianConstants.ConditionType = {
    DirectPass = 0, -- 直接判断通过
    RoleAttr = 100, -- 角色属性
    RoleAttrCalculated = 101, -- 角色属性计算值
    RoleAttrFight = 102, -- 角色战斗属性
    RoleAttrFamily = 103, -- 角色门派属性
    SkillLv = 200, -- 武学等级
    CanPrepareTypeSkillLvNum = 201, -- 可准备指定类型同时满足武学等级的武学数量
    CanPrepareTypeSkillLvLimitNum = 202, -- 可准备指定类型同时满足武学等级上限的武学数量
    ActiveZhaoExp = 300, -- 主动招式熟练度
    SelfCreatedSkillNum = 400, -- 自创招式数量
    SelfCreatedSkillAffixCount = 401, -- 自创招式词缀数量
    MapCompleted = 500, -- 副本通关情况
    ChallengeMapCompleted = 600, -- 挑战副本通关情况
    TeacherBuildAttr = 700, -- 师门建筑属性
    ShenBingSubTypeCount = 800, -- 神兵子类型数量
    ShenBingAttrCount = 801, -- 神兵符合属性条件数量
    ShenBingFirstTypeCount = 802, -- 神兵类型数量
    FistFootAttr = 900, -- 拳脚系统属性
    FistFootBranchLv = 901, -- 拳脚分支锻境等级
    MeridianAttr = 1000, -- 经脉系统相关属性
    HiddenMeridianAttr = 1100, -- 隐藏经脉系统相关属性
    HiddenMeridianAttachBuff = 1101, -- 窍关装备的指定玄络类型数量
    RoleTitle = 1200, -- 角色称号
}

--经脉buff删除节点
HiddenMeridianConstants.DeleteBuffNodal = {
    DEPARTFROMFAMILY = 1, -- 叛师
    ROLEINHERIT = 2, -- 传承
    LOGIN = 3, -- 登录
}

return HiddenMeridianConstants0000000000
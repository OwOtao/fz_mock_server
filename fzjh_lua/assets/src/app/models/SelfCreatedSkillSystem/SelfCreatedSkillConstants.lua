local SkillConst = require("app.models.skill.SkillConst")

local SelfCreatedSkillConstants = {}

SelfCreatedSkillConstants.SkillCreateState = {
    None = 0,
    Creating = 1,
    Completed = 2
}

SelfCreatedSkillConstants.ZhaoQuality = {
    Normal = 1, -- 普通
    Delicate = 2, -- 精妙
    Extraordinary = 3, -- 超凡
    Supernatural = 4 -- 神通
}

--@desc 武学第一类型
SelfCreatedSkillConstants.SkillFirstType = SkillConst.SkillFirstType

--@desc 武学第二类型
SelfCreatedSkillConstants.SkillSecondType = SkillConst.SkillSecondType

--@desc 武学第三类型
SelfCreatedSkillConstants.SkillThirdType = SkillConst.SkillThirdType

--@desc 武学类型中文名称
SelfCreatedSkillConstants.SkillThirdName = {
    [SkillConst.SkillThirdType.QUAN_FA] = "拳法",
    [SkillConst.SkillThirdType.ZHANG_FA] = "掌法",
    [SkillConst.SkillThirdType.ZHUA_FA] = "爪法",
    [SkillConst.SkillThirdType.ZHI_FA] = "指法",
    [SkillConst.SkillThirdType.TUI_FA] = "腿法",
    [SkillConst.SkillThirdType.JIAN_FA] = "剑法",
    [SkillConst.SkillThirdType.DAO_FA] = "刀法",
    [SkillConst.SkillThirdType.GUN_FA] = "棍法",
    [SkillConst.SkillThirdType.BIAN_FA] = "鞭法",
    [SkillConst.SkillThirdType.AN_QI] = "暗器",
    [SkillConst.SkillThirdType.SHUANG_CHI] = "双持",
    [SkillConst.SkillThirdType.QIN_FA] = "乐器",
    [SkillConst.SkillThirdType.QING_GONG] = "轻功",
    [SkillConst.SkillThirdType.NEI_GONG] = "内功",
    [SkillConst.SkillThirdType.ZHAO_JIA] = "招架",
}

--@desc 武学第三类型图鉴索引
SelfCreatedSkillConstants.SkillThirdTuJianIndex = {
    [SkillConst.SkillThirdType.QUAN_FA] = "quan",
    [SkillConst.SkillThirdType.ZHANG_FA] = "zhang",
    [SkillConst.SkillThirdType.ZHUA_FA] = "zhua",
    [SkillConst.SkillThirdType.ZHI_FA] = "zhi",
    [SkillConst.SkillThirdType.TUI_FA] = "tui",
    [SkillConst.SkillThirdType.JIAN_FA] = "jian",
    [SkillConst.SkillThirdType.DAO_FA] = "dao",
    [SkillConst.SkillThirdType.GUN_FA] = "gun",
    [SkillConst.SkillThirdType.BIAN_FA] = "bian",
    [SkillConst.SkillThirdType.AN_QI] = "anqi",
    [SkillConst.SkillThirdType.SHUANG_CHI] = "shuangchi",
    [SkillConst.SkillThirdType.QIN_FA] = "qin",
    [SkillConst.SkillThirdType.QING_GONG] = "qinggong",
    [SkillConst.SkillThirdType.NEI_GONG] = "neigong",
    [SkillConst.SkillThirdType.ZHAO_JIA] = "zhaojia",
}

--@desc 武学第二类型准备类型索引
SelfCreatedSkillConstants.SkillSecondPrepareIndex = {
    [SkillConst.SkillSecondType.QUAN_JIAO] = "quanjiao1",
    [SkillConst.SkillSecondType.DAO_FA] = "daofa",
    [SkillConst.SkillSecondType.JIAN_FA] = "jianfa",
    [SkillConst.SkillSecondType.GUN_FA] = "gunfa",
    [SkillConst.SkillSecondType.BIAN_FA] = "bianfa",
    [SkillConst.SkillSecondType.SHUANG_CHI] = "shuangchi",
    [SkillConst.SkillSecondType.AN_QI] = "anqi",
    [SkillConst.SkillSecondType.QIN_FA] = "qinfa",
    [SkillConst.SkillSecondType.NEI_GONG] = "neigong",
    [SkillConst.SkillSecondType.QING_GONG] = "qinggong",
    [SkillConst.SkillSecondType.ZHAO_JIA] = "zhaojia",
}

--通用参数id
SelfCreatedSkillConstants.Params = {
    -- complete_all_num	 6	完成自创武学_需求总招式数
    -- complete_general_num	3	完成自创武学_需求总被动招式数
    -- transform_nAtk	0.01	门派武学转换_攻击性能转换系数
    -- transform_hit	0.01	门派武学转换_命中性能转换系数
    -- transform_dam	1	门派武学转换_伤害性能转换系数
    -- transform_preDuration	0.01	门派武学转换_招式攻击前摇转换系数
    -- transform_aftDuration	0.01	门派武学转换_体力消耗转换系数
    -- transform_zhaoparry	0	门派武学转换_招式招架加成转换系数
    -- transform_zhaododge	0	门派武学转换_招式闪避加成转换系数
    -- transform_atk	10	门派武学转换_武学攻击力系数转换系数
    -- transform_hitRate	10	门派武学转换_武学命中率系数转换系数
    -- transform_damRate	10	门派武学转换_武学招式伤害系数转换系数
    -- transform_powerDamRate	10	门派武学转换_武学加力伤害系数转换系数
    -- transform_powerAtkRate	10	门派武学转换_武学加力攻击力系数转换系数
    -- transform_HpRate	0.1	门派武学转换_内功气血性能转换系数
    -- transform_neili	0.13	门派武学转换_内功治疗性能转换系数
    -- transform_Addneili	0.09	门派武学转换_内功回内性能转换系数
    -- transform_nDef	0.09	门派武学转换_招架防御性能转换系数
    -- transform_parry	0.09	门派武学转换_招架性能转换系数
    -- transform_dodge	0.1	门派武学转换_轻功闪避性能转换系数
    -- transform_atkSpd	0.1	门派武学转换_轻功攻速性能转换系数
    -- template_addOrder	1#1#1|2#2#0.6|3#3#0.36|4#4#0.22|5#5#0.13|6#6#0.08|7#7#0.05|8#8#0.03|9#9#0.02|10#999#0.01	招式模板_武学全域性能加成顺序系数，配置格式：顺序范围下限#顺序范围上限#参数值|顺序范围下限#顺序范围上限#参数值
    -- affix_sAtk	2	招式特性_属性内功攻击系数
    -- affix_sDef	0.5	招式特性_属性内功抵御系数
}

--自创武学道具功能类型
SelfCreatedSkillConstants.PropType = {
    ADD_CREATEZHAO_SUCCESSRATE = 1,
    ZHAO_ALL_RESET = 3,
}

--武学产出类型
SelfCreatedSkillConstants.SkillOutputType = {
    SERVER_CREATE = 1, --服务器产出
    LILIANMAP_CREATE = 2, --历练副本产出
}

--招式产出类型
SelfCreatedSkillConstants.ZhaoOutputType = {
    SERVER_CREATE = 1, --服务器产出
    LILIANMAP_CREATE = 2, --历练副本产出
}

--招式特性攻击加成伤害类型
SelfCreatedSkillConstants.ZhaoTraitAtkType = {
    "positive", --阳性
    "negative", --阴性
    "mixed",    --混元
    "poisonous" --毒性
}

--@desc自创武学数量上限
SelfCreatedSkillConstants.SelfCreatedSkillCountMax = 10

return SelfCreatedSkillConstants
00
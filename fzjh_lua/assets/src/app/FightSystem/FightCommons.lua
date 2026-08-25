local FightCommons = {}

--@desc 队伍成员最大数
FightCommons.TEAMMATE_COUNT = 3

--@desc 属性区域显示buff最大数量
FightCommons.BUFFICON_MAXCOUNT = 8

--@desc 所有buff图标显示最大数量
FightCommons.ALL_BUFFICON_MAXCOUNT = 30

--@desc 逻辑帧数
FightCommons.LOGIC_FPS = 10

--@desc 渲染帧数
FightCommons.VIWE_FPS = 30

function FightCommons:setViewFPS(fps)
    FightCommons.VIWE_FPS = fps
end

-- FightCommons.CHANGE_WEAPON_NAME = "易武"

-- FightCommons.RCOVER_QI_NAME = "恢复"

-- FightCommons.RUNAWAY_NAME = "逃跑"

--@desc UI 操作按钮数量
FightCommons.MAX_BTN_COUNT = 9

--@desc 角色物种
FightCommons.CHARACTER_SPECIES = {
    MALE = "male",
    FEMALE = "female",
    BIRD = "bird",
    CENTIPEDE = "centipede",
    SCORPION = "scorpion",
    SNAKE = "snake",
    SPIDER = "spider",
    WOLF = "wolf"
}

FightCommons.PREP_ACT_MAX_COUNT = 6

--@desc 主动技能按钮最大数量
FightCommons.ACTIVE_UI_BTN_COUNT = 6

--@desc 主动技能释放类型（1、攻击类型，2、释放辅助类型）,无逻辑流程区分处理，主要用于buff判断使用。
FightCommons.ACTIVE_TYPE = {
    ATTACK = 1,
    RELEASE = 2
}

FightCommons.CHARACTER_POSITION = {
    [1] = cc.p(373, 181),
    [2] = cc.p(173, 246),
    [3] = cc.p(272, 60),
    [4] = cc.p(703, 181),
    [5] = cc.p(907, 246),
    [6] = cc.p(833, 60)
}

local FightRoleAnimFaceDirection = {
    RIGHT = 1,
    LEFT = -1
}

--@desc: 动画面对的方向
--@author:Seven
--@time:2020-09-19 15:45:41
--@return [src.app.FightSystem.FightCommons#FightRoleAnimDirection]
function FightCommons:getAnimFaceDirection()
    return FightRoleAnimFaceDirection
end

--@desc 战斗状态
FightCommons.FIGHT_STATE = {
    IDLE = 0,
    PAUSE = 1,
    JOINING = 2,
    BATTLE = 3,
    FINISH = 4
}

FightCommons.FINISH_STATE = {
    --@desc 胜利
    WIN = 1,
    --@desc 失败
    LOSE = 2,
    --@desc 平局
    NO_WINNER = 3,
    --@desc 逃跑
    RUNAWAY = 4
}

FightCommons.CHARACTER_UI_STATE = {
    NONE = 0,
    --@desc 静止状态
    IDLE = 1,
    --@desc 死亡
    ATTACK = 2,
    --@desc 受击
    UNDERATTACK = 3,
    --@desc 跳跃状态
    JUMPING = 4,
    --@desc 准备状态
    JOINING = 5,
    --@desc 主动技能释放前置
    ACTIVEREADY = 6,
    --@desc 气血恢复
    RECOVERQI = 7,
    --@desc 易武
    CHANGEWEAPON = 8
}

FightCommons.CHARACTER_CONTROLLED_STATE = {
    --@desc 站立
    STAND = 0,
    --@desc 晕眩
    STUN = 1,
    --@desc 混乱
    CONFUSE = 2
}

FightCommons.ATTACK_HIT_TYPE = {
    NONE = 0, -- 空类型（用于播放动画，无任何逻辑实现）
    HIT = 1, --击中
    PARRY = 2, --普通招架
    DODGE = 3, --闪避
    PARRY_SPEC = 4, -- 招架格挡
    DODGE_SPC = 5, -- 轻功跳离,
    ACTIVE_RELEASE = 6 -- 主动技能释放类型用
}

FightCommons.HIT_POS = {
    HEAD = "head",
    CHEST = "chest",
    FOOT = "foot"
}

FightCommons.EQUIP_PART = {
    WEAPON = "weapon",
    HEAD = "head",
    CLOTH = "cloth",
    BELT = "belt",
    HAND = "hand",
    PANTS = "pants",
    SHOES = "shoes",
    RING = "ring",
    YAOZHUI = "yaozhui",
    NECKLACE = "necklace"
}

FightCommons.FIGHT_CMD_TYPE = {
    TEST = 0,
    CHARACTER_ACTIVE = 1,
    CHARACTER_RUNAWAY = 2,
    CHANGE_WEAPON = 3,
    RECOVER_QI = 4
}

--@desc 武器的战斗状态
FightCommons.FIGHT_WEAPON_STATE = {
    NORMAL = "normal",
    FLY = "fly",
    DESTROY = "destroy",
    GIVEUP = "giveUp"
}

FightCommons.CHARATER_CMD_TYPE = {
    PLACEHOLDER = 0,
    RELEASE_ACTIVE = 1,
    CHANGE_WEAPON = 2,
    QI_RECOEVE = 3,
    RUNAWAY = 4
}

FightCommons.NPC_BUILD_WEAPON_TYPE = {
    GOD = "godweapon",
    NORMAL = "equipment"
}

local NETWORK_INFO = {
    IP = "127.0.0.1",
    PORT = 5454
}
function FightCommons:getNetworkInfo()
    return NETWORK_INFO
end

-- 角色自身影响攻击结果相关类型
FightCommons.INFLUENCE_ATTACK_HIT_TYPE = {
    --@desc 攻击者攻击必定被格挡类型
    ATTACKER_BE_PARRY = 102,
    --@desc 攻击者攻击必定被躲闪类型
    ATTACKER_BE_DODGE = 103,
    --@desc 目标无法格挡类型
    TARGET_BAN_PARRY = 302,
    --@desc 目标无法闪躲类型
    TARGET_BAN_DODGE = 303
}

--@desc 减免特效属性名前缀
FightCommons.HURT_REDUCE_ATTR_PREFIX = "HRAP|"

--@desc 战斗事件
FightCommons.FIGHT_EVENT_NAME = {
    --@desc 战斗初始化
    FIGHT_INIT = 100,
    --@desc 进入战斗开始
    ENTER_FIGHT_START = 101,
    --@desc 进入战斗结束
    ENTER_FIGHT_FINISH = 102,
    --@desc 战斗开始
    START_FIGHT = 103,
    --@desc 战斗结束
    FINISH_FIGHT = 104
}

--@desc 角色内部事件事件
FightCommons.CHARACTER_EVENT_NAME = {
    --@desc 角色进入战斗可初始化
    FIGHT_INIT = 1000,
    --@desc 通知角色系统，战斗进入入场阶段开始
    ENTER_FIGHT_START = 1001,
    --@desc 通知角色系统，战斗进入入场阶段结束
    ENTER_FIGHT_FINISH = 1002,
    ANY_ATK_COMB_START = 1100,
    ANY_ATK_COMB_FINISH = 1101,
    --@region 被动技能攻击流程事件
    AUTO_ATK_COMB_START = 1200,
    AUTO_ATK_ZHAO_START = 1201,
    AUTO_ATK_ZHAO_HIT = 1202,
    AUTO_ATK_ZHAO_FINISH = 1203,
    AUTO_ATK_COMB_FINISH = 1204,
    --@endregion
    --@region 主动技能攻击流程事件
    ACTIVE_ATK_COMB_START = 1300,
    ACTIVE_ATK_ZHAO_START = 1301,
    ACTIVE_ATK_ZHAO_HIT = 1302,
    ACTIVE_ATK_ZHAO_FINISH = 1303,
    ACTIVE_ATK_COMB_FINISH = 1304,
    --@endregion
    --@region 玩家特殊操作流程相关
    --@desc 易武
    USE_CHANGE_WEAPON = 1500,
    --@desc 气血恢复
    USE_RECOVER_QI = 1501,
    --@desc 逃跑
    USE_RUNAWAY = 1502
    --@endregion
}

-- 玩家操作插槽最大数量
FightCommons.CHARACTER_OPERATION_MAX_INDEX = 9

FightCommons.CHARACTER_OPERATION_TYPE = {
    --@desc 未定义
    OPEARTION_NONE = 0,
    --@desc 主动技能操作
    OPERATION_ACTIVE_SKILL = 1,
    --@desc 气血恢复操作
    OPERATION_QI_RECOVER = 2,
    --@desc 角色易武操作
    OPERATION_CHANGE_WEAPON = 3,
    --@desc 角色逃跑
    OPERATION_RUNAWAY = 4
}

FightCommons.BAN_OPERATION_TYPE = {
    --@desc 禁用易武
    BAN_CHANGE_WEAPON = "changeWeapon",
    --@desc 禁用气血恢复
    BAN_RECOVER_QI = "healthy",
    --@desc 禁用逃跑
    BAN_RUNAWAY = "runAway"
}

--@desc 招式攻击时音效
FightCommons.ZHAOINFO_SOUND_TYPE = {
    --@desc 招式本身音效
    ZHAO_ORIGIN = 0,
    --@desc 攻击者武器音效
    ATTACKER_WEAPON = 1
}

--@desc 角色主动技能名称释放时的动画样式
FightCommons.HIDE_ACTIVE_SKILL_NAME_ANIM_STYLE = {
    FONT_GREEN = 1,
    FONT_YELLOW = 2
}

FightCommons.ACCEPT_KONWLEDGE_SKILL = {
    "changshengjueyin",
    "changshengjueyang"
}

return FightCommons
00000000000000
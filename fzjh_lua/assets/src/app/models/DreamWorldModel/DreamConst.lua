local DreamConst = {
    EmotionType = {
        None = 1, -- 毫无波澜
        Impressed = 2, -- 心动
        Ecstasy = 3, -- 狂喜
        Calmdown = 4, -- 冷静
        Fear = 5, -- 恐惧
        Agitated = 6, -- 烦躁
        Sad = 7 --悲伤
    },
    EmotionAttr = {
        talkWeight1 = "talkWeight1",
        talkWeightPercent1 = "talkWeightPercent1",
        talkWeight2 = "talkWeight2",
        talkWeightPercent2 = "talkWeightPercent2",
        talkWeight3 = "talkWeight3",
        talkWeightPercent3 = "talkWeightPercent3",
        talkWeight4 = "talkWeight4",
        talkWeightPercent4 = "talkWeightPercent4",
        talkWeight5 = "talkWeight5",
        talkWeightPercent5 = "talkWeightPercent5",
        talkWeight6 = "talkWeight6",
        talkWeightPercent6 = "talkWeightPercent6",
        talkWeight7 = "talkWeight7",
        talkWeightPercent7 = "talkWeightPercent7",
        randomEventWeight1 = "randomEventWeight1",
        randomEventWeightPercent1 = "randomEventWeightPercent1",
        randomEventWeight2 = "randomEventWeight2",
        randomEventWeightPercent2 = "randomEventWeightPercent2",
        randomEventWeight3 = "randomEventWeight3",
        randomEventWeightPercent3 = "randomEventWeightPercent3",
        randomEventWeight4 = "randomEventWeight4",
        randomEventWeightPercent4 = "randomEventWeightPercent4",
        randomEventWeight5 = "randomEventWeight5",
        randomEventWeightPercent5 = "randomEventWeightPercent5",
        randomEventWeight6 = "randomEventWeight6",
        randomEventWeightPercent6 = "randomEventWeightPercent6",
        randomEventWeight7 = "randomEventWeight7",
        randomEventWeightPercent7 = "randomEventWeightPercent7",
        boxEventWeight1 = "boxEventWeight1",
        boxEventWeightPercent1 = "boxEventWeightPercent1",
        boxEventWeight2 = "boxEventWeight2",
        boxEventWeightPercent2 = "boxEventWeightPercent2",
        boxEventWeight3 = "boxEventWeight3",
        boxEventWeightPercent3 = "boxEventWeightPercent3",
        boxEventWeight4 = "boxEventWeight4",
        boxEventWeightPercent4 = "boxEventWeightPercent4",
        boxEventWeight5 = "boxEventWeight5",
        boxEventWeightPercent5 = "boxEventWeightPercent5",
        boxEventWeight6 = "boxEventWeight6",
        boxEventWeightPercent6 = "boxEventWeightPercent6",
        boxEventWeight7 = "boxEventWeight7",
        boxEventWeightPercent7 = "boxEventWeightPercent7",
        newFloorRate = "newFloorRate",
        newFloorRatePercent = "newFloorRatePercent",
        battleWinRate = "battleWinRate",
        battleWinRatePercent = "battleWinRatePercent",
        battleLoseRate = "battleLoseRate",
        battleLoseRatePercent = "battleLoseRatePercent",
        fightWinRate = "fightWinRate",
        fightWinRatePercent = "fightWinRatePercent",
        fightLoseRate = "fightLoseRate",
        fightLoseRatePercent = "fightLoseRatePercent",
        talkRate = "talkRate",
        talkRatePercent = "talkRatePercent",
        randEventRate = "randEventRate",
        randEventRatePercent = "randEventRatePercent"
    },
    RoomEventType = {
        BOSS = 1,
        SHOP = 2,
        DEFAULT = 3,
        HIDE = 4,
        TREASURE = 5,
        TASKS = 6,
        FIGHT = 7,
        EMPTY = 8,
        BOSSPRE = 10,
        EXIT = 11
    },
    RoomTypeName = {
        [1] = "bossRoom",
        [2] = "shopRoom",
        [3] = "defaultRoom",
        [4] = "hideRoom",
        [5] = "treasureRoom",
        [6] = "taskRoom",
        [7] = "fightRoom",
        [8] = "emptyRoom",
        [10] = "bossPreRoom",
        [11] = "exitRoom"
    },
    OpertionEventName = {
        Unlock_Talent = "unlockTalent",
        Upgrade_Talent = "upgradeTalent"
    },
    SOBER_LIMIT = 100,

    --@desc 最大楼层
    MAX_FLOOR = 40,
}

return DreamConst
000000000000
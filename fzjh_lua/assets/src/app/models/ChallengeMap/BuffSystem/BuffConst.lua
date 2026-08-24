local BuffConst = {
   BuffEffectType = {
        NONE_VALUE = 0, -- 没有效果，纯粹的加一个buff作为标识
        ROLE_FIGHT_ATTR_VALUE = 1,
        ROLE_FIGHT_ATTR_PERCENT_VALUE = 2,
        ROLE_ATTR_VALUE = 3,
        ROLE_ATTR_PERCENT_VALUE = 4,
   },

   NormalBuffRemoveType = {
       SYSTEM = 0,
       FIGHT_TIMES = 1,
       DURATION = 2,
   }
}


return BuffConst
0000000000
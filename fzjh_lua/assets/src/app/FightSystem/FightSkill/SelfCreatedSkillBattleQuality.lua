-- local class = require("third.class.NewClass")

-- local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")

-- local ISkillBattleQuality = require("app.FightSystem.FightSkill.ISkillBattleQuality")

-- local SelfCreatedSkillBattleQuality = {
--     --@desc 攻击武学品质攻击力
--     __atk = 0,
--     --@desc 攻击武学品质伤害力
--     __damage = 0,
--     --@desc 攻击武学品质命中力
--     __hit = 0,
--     --@desc 轻功武学品质闪躲力
--     __dodge = 0,
--     --@desc 轻功武学品质体复力
--     __tiliRegain = 0,
--     --@desc 招架武学品质防御力
--     __def = 0,
--     --@desc 招架武学品质招架力
--     __parry = 0,
--     --@desc 内功武学品质气血上限
--     __blood = 0,
--     --@desc 内功武学品质治疗
--     __recoveryQixue = 0,
--     --@desc 内功武学品质回内
--     __recoveryNeili = 0
-- }

-- --@desc:
-- --@author:LvBin
-- --@time:2022-01-18 11:00:59
-- function SelfCreatedSkillBattleQuality:create()
--     local p = SelfCreatedSkillBattleQuality.new()
--     p:init()
--     return p
-- end

-- function SelfCreatedSkillBattleQuality:init()
--     self.__atk = SelfCreatedSkillManager:getParamsById("transform_atk")

--     self.__damage = SelfCreatedSkillManager:getParamsById("transform_powerDamRate")

--     self.__hit = SelfCreatedSkillManager:getParamsById("transform_hitRate")
-- end

-- function SelfCreatedSkillBattleQuality:getAttr(attr)
--     return assert(self["__" .. attr], "品质属性不存在 : " .. attr)
-- end

-- return class("SelfCreatedSkillBattleQuality", {ISkillBattleQuality}, SelfCreatedSkillBattleQuality)
000000000000000
-- --[[
--     新版战斗用自创武学
-- ]]

-- local NormalFightSkill = require("app.FightSystem.FightSkill.NormalFightSkill")

-- local SelfCreatedSkillBattleQuality = require("app.FightSystem.FightSkill.SelfCreatedSkillBattleQuality")

-- local SelfCreatedAutoZhaoCombination = require("app.FightSystem.FightRole.AttackSystem.AutoSkill.SelfCreatedAutoZhaoCombination")

-- local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

-- local class = require("third.class.NewClass")

-- local SelfCreatedFightSkill = {
--     __id = 0,
--     __type = 2,
--     --@desc 武学描述
--     __dsc = "",
--     --@desc 武学名颜色
--     __nameColor = "",
--     __name = "拳",
--     --@desc 入场动画，0 表示没有
--     __battleJoinAnim = 0,
--     --@desc 站立动画（待机动画，非攻击动画为0）
--     __battleIdleAnim = 0,
--     --@desc 跳跃动画（攻击准备动画。非攻击动画为0）
--     __battleRunAnim = 0,
--     --@desc 跳回动画（返回动画，非攻击动画为0）
--     __battleBackAnim = 0,
--     --@desc 该武学在招架时对应的class，根据攻击部位获取
--     __parryClass = {},
--     --@desc 该武学在闪避时对应的class，根据攻击部位获取
--     __dodgeClass = {},
--     --@desc 武学类型（对应 SkillClassifyManager 的武学分类）
--     __skillType = {},
--     __weaponTypes = {},
--     --@desc 主动技能id列表：[]
--     __activeZhaos = {},
--     __level = 0
-- }

-- function SelfCreatedFightSkill:create()
--     local p = SelfCreatedFightSkill.new()
--     return p
-- end

-- --@desc: 
-- --@author:LvBin
-- --@time:2022-01-17 18:21:16
-- --@skill: [src.app.models.SelfCreatedSkillSystem.SelfCreatedSkill.SelfCreatedSkill#SelfCreatedSkill]
-- --@return
-- function SelfCreatedFightSkill:initData(skill)
--     self.__skill = skill

--     self.__id = skill:getId()

--     self.__type = skill:getType()
    
--     local dsc = "HIW"..skill:getDsc().."NOR"
--     local skillTypeName = skill:getSkillTypeName()
--     local weaponTypeText = skill:getWeapontypeText()

--     dsc = dsc.."\n \n可准备为:"..skillTypeName
--     if type(weaponTypeText) == "string" then
--         dsc = dsc.."\n需要装备:"..weaponTypeText
--     end

--     self.__dsc = dsc
    
--     self.__nameColor = "OLIVE"
    
--     self.__name = skill:getName()
    
--     self.__battleJoinAnim = skill:getBattleJoinAnim()

--     self.__battleIdleAnim = skill:getBattleIdleAnim()

--     self.__battleRunAnim = skill:getBattleRunAnim()

--     self.__battleBackAnim = skill:getBattleBackAnim()

--     self.__skillType = skill:getSkillType()

--     self.__weaponTypes = skill:getWeaponTypes()

--     self.__activeZhaos = {}

--     self.__battleQualityClass = SelfCreatedSkillBattleQuality:create()
-- end

-- function SelfCreatedFightSkill:getBattleQualityClass()
--     return self.__battleQualityClass
-- end

-- --@desc: 获取随机武功被动招式组合对象
-- --@author:LvBin
-- --@time:2022-01-18 14:44:47
-- --@return [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.SelfCreatedAutoZhaoCombination#SelfCreatedAutoZhaoCombination]
-- function SelfCreatedFightSkill:getAttackAutoZhaoComb()
--     local random_list = self:__getMatchCombResList()

--     local index = FightUtil:random(1, #random_list)

--     local autoZhao = random_list[index]

--     local zhao_comb = SelfCreatedAutoZhaoCombination:create(autoZhao,self.__skill)

--     return zhao_comb
-- end

-- --@desc: 获得满足出招条件的被动招式列表
-- --@author:LvBin
-- --@time:2022-01-18 14:47:45
-- --@return
-- function SelfCreatedFightSkill:__getMatchCombResList()
--     local autoZhaos = self.__skill:getAttackZhaos()

--     local skill_lv = self:getLevel()

--     local list = {}

--     for _, autoZhao in ipairs(autoZhaos) do
--         if autoZhao:getGrade() <= skill_lv then
--             table.insert(list, autoZhao)
--         end
--     end

--     if MapIsEmpty(list) then
--         assert(false, "自创武学 技能id:" .. self:getId() .. "，等级lv:" .. self:getLevel() .. " 满足出招条件的被动招式列表为空 ")
--     end

--     table.sort(
--         list,
--         function(a, b)
--             if a:getGrade() == b:getGrade() then
--                 return a:getId() < b:getId()
--             else
--                 return a:getGrade() < b:getGrade()
--             end
--         end
--     )

--     return list
-- end

-- --@desc: 获取武功被动招式组合对象列表
-- --@author:LvBin
-- --@time:2022-01-11 17:32:21
-- --@return [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.SelfCreatedAutoZhaoCombination#SelfCreatedAutoZhaoCombination]
-- function SelfCreatedFightSkill:getAutoZhaoCombs()
--     local autoZhaos = self.__skill:getZhaos()

--     local zhao_combs = {}

--     for _, autoZhao in ipairs(autoZhaos) do
--         local zhao_comb = SelfCreatedAutoZhaoCombination:create(autoZhao,self.__skill)
--         table.insert(zhao_combs, zhao_comb)
--     end

--     return zhao_combs
-- end

-- --@desc: 获取符合最高等级的招式comb
-- --@author:LvBin
-- --@time:2022-01-11 17:44:19
-- --@return [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.SelfCreatedAutoZhaoCombination#SelfCreatedAutoZhaoCombination]
-- function SelfCreatedFightSkill:getAutoZhaoCombByLvMax()
--     local list = self:__getMatchCombResList()

--     local zhao_comb = SelfCreatedAutoZhaoCombination:create(list[#list],self.__skill)

--     return zhao_comb
-- end


-- return class("SelfCreatedFightSkill", {NormalFightSkill}, SelfCreatedFightSkill)00000000000000
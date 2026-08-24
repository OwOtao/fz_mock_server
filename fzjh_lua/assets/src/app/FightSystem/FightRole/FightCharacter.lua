-- local class = require("third.class.NewClass")

-- local isImplement = require("third.assertIsInstance.assertIsInstance")

-- local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

-- local SkillConst = require("app.models.skill.SkillConst")

-- --@RefType src.app.models.skill.SkillConst#SkillConst.SkillSecondType
-- local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

-- local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

-- --@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
-- local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

-- local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

-- local FightCommons = require("app.FightSystem.FightCommons")

-- local CustomBuffNeeded = require("app.FightSystem.FightBuff.CustomBuffNeeded")

-- local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

-- local Desc = require("app.FightSystem.FightBuff.Desc")

-- local BasicSkill = require("app.models.skill.BasicSkill.BasicSkill")

-- local CHARACTER_STATE = FightCommons.CHARACTER_STATE

-- local FightCharacter = {
--     __teamId = nil,
--     --@desc 角色物种
--     __species = FightCommons.CHARACTER_SPECIES.MALE,
--     --@desc 是否玩家所操控的人物
--     __isPlayer = false,
--     __target = nil,
--     __posIndex = 1,
--     __pos = {
--         x = 0,
--         y = 0,
--         h = 0
--     },
--     --@desc 一段攻击中
--     __attackingAnim = false,
--     --@desc 角色属性对象
--     __characterAttr = nil,
--     --@desc 人物状态
--     __stateMachine = nil,
--     --@desc 是否能恢复体力
--     __can_recover = true,
--     --@region 武学、主动技能相关
--     __skills = {},
--     --@desc 当前使用的攻击技能类型索引
--     __attackSkillType = tostring(SKILL_SECOND_TYPE.QUAN_JIAO),
--     --@desc 基本武学
--     __base_skill = {
--         [tostring(SKILL_SECOND_TYPE.QUAN_JIAO)] = nil,
--         [tostring(SKILL_SECOND_TYPE.JIAN_FA)] = nil,
--         [tostring(SKILL_SECOND_TYPE.DAO_FA)] = nil,
--         [tostring(SKILL_SECOND_TYPE.GUN_FA)] = nil,
--         [tostring(SKILL_SECOND_TYPE.BIAN_FA)] = nil,
--         [tostring(SKILL_SECOND_TYPE.SHUANG_CHI)] = nil,
--         [tostring(SKILL_SECOND_TYPE.AN_QI)] = nil,
--         [tostring(SKILL_SECOND_TYPE.QIN_FA)] = nil,
--         [tostring(SKILL_SECOND_TYPE.QING_GONG)] = nil,
--         [tostring(SKILL_SECOND_TYPE.NEI_GONG)] = nil
--     },
--     --@desc 准备武学
--     __prep_skill = {
--         [tostring(SKILL_SECOND_TYPE.QUAN_JIAO)] = nil,
--         [tostring(SKILL_SECOND_TYPE.JIAN_FA)] = nil,
--         [tostring(SKILL_SECOND_TYPE.DAO_FA)] = nil,
--         [tostring(SKILL_SECOND_TYPE.GUN_FA)] = nil,
--         [tostring(SKILL_SECOND_TYPE.BIAN_FA)] = nil,
--         [tostring(SKILL_SECOND_TYPE.SHUANG_CHI)] = nil,
--         [tostring(SKILL_SECOND_TYPE.AN_QI)] = nil,
--         [tostring(SKILL_SECOND_TYPE.QIN_FA)] = nil,
--         [tostring(SKILL_SECOND_TYPE.QING_GONG)] = nil,
--         [tostring(SKILL_SECOND_TYPE.NEI_GONG)] = nil
--     },
--     --@desc 互备武学(暂时只限攻击类武学) type:{}
--     __standby_atk_skill = {
--         [tostring(SKILL_SECOND_TYPE.QUAN_JIAO)] = nil
--         --@region 未开放
--         -- [tostring(SKILL_SECOND_TYPE.JIAN_FA)] = nil,
--         -- [tostring(SKILL_SECOND_TYPE.DAO_FA)] = nil,
--         -- [tostring(SKILL_SECOND_TYPE.GUN_FA)] = nil,
--         -- [tostring(SKILL_SECOND_TYPE.BIAN_FA)] = nil,
--         -- [tostring(SKILL_SECOND_TYPE.SHUANG_CHI)] = nil,
--         -- [tostring(SKILL_SECOND_TYPE.AN_QI)] = nil,
--         -- [tostring(SKILL_SECOND_TYPE.QIN_FA)] = nil
--         --@endregion
--     },
--     --@desc 玩家配置的主动技能列表
--     --@desc 格式： [武学二类型] = {["1"]=主动技能id,["4"]=主动技能id,["5"]=主动技能id}
--     __active_skill_config = {},
--     --@desc 可用主动技能 type:{}
--     __active_skill = {},
--     --@desc 当前装备的主动技能列表(只存id)
--     __prep_act = {},
--     --@endregion

--     --@region 攻击相关
--     --@desc 被动攻击
--     __autoSkillAttack = nil,
--     --@desc 主动攻击相关
--     __activeSkillAttack = nil,
--     __attackSys = {},
--     --@endregion

--     --@region 人物当前受控状态值（只影响人物ui显示）
--     __controlledUIState = FightCommons.CHARACTER_CONTROLLED_STATE.STAND,
--     --@endregion

--     --@desc 主动技能自动释放
--     __activeReleaseAI = nil,
--     __runawayCd = 0,
--     __qiRecoverCd = 0,
--     __recordClass = nil,
--     __funcSystems = {}
-- }

-- function FightCharacter:create()
--     return FightCharacter.new()
-- end

-- function FightCharacter:init()
--     self:setAttackSkillType(self:getEquipSys():getWeapon():getAutoChooseSkill())
--     self:initActivePrepActiveSkill()

--     --@RefType [src.app.FightSystem.FightRole.CharacterState.CharacterStateMachine#CharacterStateMachine]
--     self.__stateMachine = require("app.FightSystem.FightRole.CharacterState.CharacterStateMachine"):create(self)
--     self.__stateMachine:changeState(CHARACTER_STATE.READY, nil)
--     self.__battleData = BattleGlobalData:getInstance()
--     self.__autoSkillAttack = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.NewAutoSkillAttack"):create(self)
--     self.__activeSkillAttack = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.NewActiveSkillAttack"):create(self)
--     self.__activeReleaseAI:init(self)
--     self.__recordClass = require("app.FightSystem.FightRole.CharacterFightRecord.CharacterRecord"):create(self)

--     self.__switchWeaponFunc = require("app.FightSystem.FightRole.CharacterEquipment.SwitchWeaponFunc"):create(self)
-- end

-- function FightCharacter:getFight()
--     return self.__character_sys:getFight()
-- end

-- function FightCharacter:setFight(fight)
--     self.__fight = fight
-- end

-- --@desc: 添加角色功能系统
-- --@author:Seven
-- --@time:2022-07-05 16:04:07
-- --@funcClass: [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
-- function FightCharacter:addFuncSystem(funcClass)
--     table.insert(self.__funcSystems, isImplement(funcClass, require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")))
--     funcClass:setCharacter(self)
-- end

-- --@desc: 遍历角色功能
-- --@author:Seven
-- --@time:2022-07-05 16:12:25
-- --@func: 回调函数
-- function FightCharacter:__walkFuncSystem(func)
--     for i, v in ipairs(self.__funcSystems) do
--         func(v)
--     end
-- end

-- function FightCharacter:getFuncSystem(name)
--     for i, v in ipairs(self.__funcSystems) do
--         if v:getName() == name then
--             return v
--         end
--     end
-- end

-- function FightCharacter:setCharacterSystem(sys)
--     --@RefType[src.app.FightSystem.FightRole.CharacterSystem#CharacterSystem]
--     self.__character_sys = sys
-- end

-- function FightCharacter:getCharacterSystem()
--     return self.__character_sys
-- end

-- function FightCharacter:setEquipSys(sys)
--     --@RefType[src.app.FightSystem.FightRole.CharacterEquipment.CharacterEquipmentSystem#CharacterEquipmentSystem]
--     self.__equipsSys = sys
-- end

-- --@return [src.app.FightSystem.FightRole.CharacterEquipment.CharacterEquipmentSystem#CharacterEquipmentSystem]
-- function FightCharacter:getEquipSys()
--     return self.__equipsSys
-- end

-- function FightCharacter:setFistFootSystem(sys)
--     --@RefType [src.app.FightSystem.FightRole.FistFoot.CharacterFistFootSystem#CharacterFistFootSystem]
--     self.__fistFootSystem = sys
-- end

-- function FightCharacter:setCharacterOutput(output)
--     --@RefType [src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
--     self.__output = output
-- end

-- --@desc:
-- --@author:Seven
-- --@time:2022-01-23 22:09:54
-- --@return [src.app.FightSystem.FightRole.CharacterFightRecord.CharacterRecord#CharacterRecord]
-- function FightCharacter:getRecordClass()
--     return self.__recordClass
-- end

-- function FightCharacter:setActiveSkillReleaseAI(releaseAI)
--     --@RefType[src.app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI#ActiveSkillReleaseAI]
--     self.__activeReleaseAI = releaseAI
-- end

-- function FightCharacter:setCharacterAttr(iCharacterAttr)
--     --@RefType[src.app.FightSystem.FightRole.CharacterAttr.ICharacterAttr#ICharacterAttr]
--     self.__characterAttr = isImplement(iCharacterAttr, require("app.FightSystem.FightRole.CharacterAttr.ICharacterAttr"))
-- end

-- function FightCharacter:getId()
--     return tostring(self:getAttr("id"))
-- end

-- function FightCharacter:setTeamId(team_id)
--     self.__teamId = team_id
-- end

-- function FightCharacter:getTeamId()
--     return self.__teamId
-- end

-- function FightCharacter:setSpecies(species)
--     self.__species = species
-- end

-- --@desc: 获取物种
-- --@author:Seven
-- --@time:2021-07-08 17:13:04
-- function FightCharacter:getSpecies()
--     return self.__species
-- end

-- function FightCharacter:setPosIndex(index)
--     self.__posIndex = index
-- end

-- function FightCharacter:getPosIndex()
--     return self.__posIndex
-- end

-- function FightCharacter:getOriginPos()
--     local pos = FightCommons.CHARACTER_POSITION[self.__posIndex]
--     return {
--         x = pos.x,
--         y = pos.y,
--         h = 0
--     }
-- end

-- function FightCharacter:setPlayer(bool)
--     self.__isPlayer = bool
-- end

-- function FightCharacter:isPlayer()
--     return self.__isPlayer
-- end

-- function FightCharacter:getControlledUIState()
--     return self.__controlledUIState
-- end

-- function FightCharacter:setControlledUIState(state)
--     self.__controlledUIState = state
-- end

-- function FightCharacter:updateControlledUIState(state)
--     if self:getControlledUIState() == state then
--         return
--     end

--     if self:isDead() then
--         return
--     end

--     FightUtil:printLog(self:getAttr("name"), "角色受控状态改变 ：", state)

--     self:setControlledUIState(state)

--     if self.__output then
--         self.__output:updateControlledState(state)
--     end
-- end

-- --@return [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
-- function FightCharacter:getTarget()
--     return self.__target
-- end

-- function FightCharacter:setTarget(target)
--     --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--     self.__target = target

--     if self.__output then
--         self.__output:changeTarget(self.__target:getId())
--     end
-- end

-- function FightCharacter:removeTarget()
--     self.__target = nil
-- end

-- function FightCharacter:selectTarget()
--     --@RefType[src.app.FightSystem.FightDataModel.FightTeam#FightTeam]
--     local target_team = self.__character_sys:getTargetTeam(self:getTeamId())

--     local targets = target_team:getCharacters()
--     local can_select_list = {}
--     for _, target in ipairs(targets) do
--         if target:isStop() == false then
--             table.insert(can_select_list, target)
--         end
--     end

--     if MapIsEmpty(can_select_list) then
--         assert(false, "可选攻击目标列表为空，请检查")
--     end

--     local random_index = FightUtil:random(1, #can_select_list)

--     local target = can_select_list[random_index]

--     FightUtil:printLog(self:getAttr("name"), " 选择了攻击目标 : ", target:getId())

--     return target
-- end

-- function FightCharacter:canDead()
--     if self:getAttr("qi") <= 0 and not self:isDead() then
--         return true
--     end

--     return false
-- end

-- function FightCharacter:addAttr(name, value)
--     return self.__characterAttr:addAttr(name, value)
-- end

-- function FightCharacter:setAttr(name, value)
--     self.__characterAttr:setAttr(name, value)
-- end

-- function FightCharacter:getAttr(name)
--     return self.__characterAttr:getAttr(name)
-- end

-- function FightCharacter:getQiStage()
--     local CharacterQiStageConf = require("app.FightSystem.ResourceManager.CharacterQiStageConf")
--     return CharacterQiStageConf:getStage(self:getAttr("qi") / self:getAttr("qiLimit") * 100)
-- end

-- function FightCharacter:setPosition(x, y, h)
--     if type(x) ~= "number" or type(y) ~= "number" or type(h) ~= "number" then
--         assert(false, "FightCharacter 位置设置，参数值有非数字：x - " .. type(x) .. " y - " .. type(y) .. " h - " .. type(h))
--     end

--     self.__pos.x = x
--     self.__pos.y = y
--     self.__pos.h = h
-- end

-- function FightCharacter:getPosition()
--     return self.__pos
-- end

-- function FightCharacter:getStandAnimName()
--     return AnimResManager:getOtherAnimName(self:getAttackSkill():getBattleIdleAnim())
-- end

-- function FightCharacter:getJumpForwardAnimName()
--     return AnimResManager:getOtherAnimName(self:getAttackSkill():getBattleRunAnim())
-- end

-- function FightCharacter:getJumpBackAnimName()
--     return AnimResManager:getOtherAnimName(self:getAttackSkill():getBattleBackAnim())
-- end

-- function FightCharacter:getJoinAnimName()
--     local animResId = self:getAttackSkill():getBattleJoinAnim()
--     if animResId ~= 0 then
--         return AnimResManager:getOtherAnimName(animResId)
--     end
--     return nil
-- end

-- --@desc: 获取受击动画组
-- --@author:Seven
-- --@time:2021-07-17 10:31:58
-- function FightCharacter:getHurtAnims()
--     local CharacterDefaultConf = require("app.FightSystem.Configuration.CharacterDefaultConf")

--     --@desc 设置受击动画组
--     local HIT_POS = FightCommons.HIT_POS

--     local anims = {
--         [HIT_POS.CHEST] = {CharacterDefaultConf:getHurtChestAnim(self.__species)},
--         [HIT_POS.FOOT] = {CharacterDefaultConf:getHurtFootAnim(self.__species)},
--         [HIT_POS.HEAD] = {CharacterDefaultConf:getHurtHeadAnim(self.__species)}
--     }

--     return anims
-- end

-- --@desc: 获取普通招架动画组
-- --@author:Seven
-- --@time:2021-07-17 10:38:24
-- function FightCharacter:getNormalParryAnims()
--     local parryClasses = self:getParrySkill():getParryClasses()

--     local anims = {}
--     for hitPos, parryClassHitPos in pairs(parryClasses) do
--         if #parryClassHitPos > 0 then
--             for _, parryClass in ipairs(parryClassHitPos) do
--                 if anims[hitPos] == nil then
--                     anims[hitPos] = {}
--                 end

--                 table.insert(anims[hitPos], AnimResManager:getOtherAnimName(parryClass:getActionNormal()))
--             end
--         end
--     end

--     return anims
-- end

-- function FightCharacter:getNormalDodgeAnims()
--     local dodgeClasses = self:getDodgeSkill():getDodgeClasses()

--     local anims = {}
--     for hitPos, dodgeClassHitPos in pairs(dodgeClasses) do
--         if #dodgeClassHitPos > 0 then
--             for _, dodgeClass in ipairs(dodgeClassHitPos) do
--                 if anims[hitPos] == nil then
--                     anims[hitPos] = {}
--                 end

--                 table.insert(anims[hitPos], AnimResManager:getOtherAnimName(dodgeClass:getActionNormal()))
--             end
--         end
--     end

--     return anims
-- end

-- function FightCharacter:setCanRecover(bool)
--     self.__can_recover = bool
-- end

-- function FightCharacter:canRecover()
--     return self.__battleData:get("m_battle_recover") and self.__can_recover
-- end

-- function FightCharacter:getAtk()
--     return self.__characterAttr:getAttr("atkBattle")
-- end

-- function FightCharacter:getDef()
--     return self.__characterAttr:getAttr("defBattle")
-- end

-- function FightCharacter:getHitForce()
--     return self.__characterAttr:getAttr("hitForceBattle")
-- end

-- function FightCharacter:getDodgeForce()
--     return self.__characterAttr:getAttr("dodgeForceBattle")
-- end

-- function FightCharacter:getParryForce()
--     return self.__characterAttr:getAttr("parryForceBattle")
-- end

-- function FightCharacter:getDamage()
--     return self.__characterAttr:getAttr("damageBattle")
-- end

-- function FightCharacter:getPlusPointBattle()
--     return self.__characterAttr:getAttr("plusPointBattle")
-- end

-- function FightCharacter:getProtect()
--     return self.__characterAttr:getAttr("protectBattle")
-- end

-- --@desc: 卸载武器
-- --@author:Seven
-- --@time:2022-04-09 16:46:53
-- --@weapon: [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
-- function FightCharacter:__unmountWeapon(weapon)
--     local list

--     if weapon:getFirstType() == "空手" then
--         list = table.mergeArray(weapon:getBuffArray(), self:getFistFootPermanentBuffs())
--     else
--         list = weapon:getBuffArray()
--     end

--     -- 换武器需要移除换下的武器的相关buff, 并且添加上新武器的相关buff
--     for i, buff in ipairs(list) do
--         local removeBuffArray = self.__buffSystem:roleRemoveBuff(self:getId(), buff.addBuffID)
--         for _, buff in ipairs(removeBuffArray) do
--             local removeText = buff:getRemoveText()
--             if type(removeText) == "string" and removeText ~= "" then
--                 self:printDesces({Desc:create(removeText, {{"$BsN", self:getAttr("name")}})})
--             end
--         end
--     end
-- end

-- function FightCharacter:__useWeapon(weapon)
--     local attack_type = weapon:getAutoChooseSkill()

--     --@desc 切换攻击类型
--     if self:getAttackSkillType() ~= tostring(attack_type) then
--         self:setAttackSkillType(attack_type)
--     end

--     self:__resetPrepActiveSkill()

--     local list
--     if weapon:getFirstType() == "空手" then
--         list = table.mergeArray(weapon:getBuffArray(), self:getFistFootPermanentBuffs())
--     else
--         list = weapon:getBuffArray()
--     end

--     -- 添加上新的武器的buff
--     local buffExecutors = {}
--     for i, buff in ipairs(list) do
--         table.insert(buffExecutors, self:addBuff(self, buff.addBuffID, 1, buff.addBuffdynamicArg1, buff.addBuffdynamicArg2, buff.addBuffdynamicArg3, 100))
--     end

--     local AttackBuffExecutors = require("app.FightSystem.FightBuff.BuffExecutor.AttackBuffExecutors")
--     local a_executors = AttackBuffExecutors:create()
--     a_executors:setSkillAttack(self)
--     for i, buffExecutor in ipairs(buffExecutors) do
--         a_executors:addExecutor(buffExecutor)
--     end

--     a_executors:execute()

--     -- self:updateBuffInfos()

--     self.__character_sys:removeCharacterAllCommand(self:getId())
-- end

-- function FightCharacter:__resetPrepActiveSkill()
--     -- 移除之前添加的主动技能携带buff
--     for i, buff in ipairs(self:getCarryBuffArray()) do
--         FightUtil:printLog("添加携带buff:", buff)
--         self:getBuffSystem():roleRemoveAllBuffByBuffId(self:getId(), buff[1])
--     end

--     --@desc 重新生成准备主动技能列表
--     self:initActivePrepActiveSkill()

--     -- 添加主动技能携带buff
--     for i, buff in ipairs(self:getCarryBuffArray()) do
--         FightUtil:printLog("添加携带buff:", buff)
--         self:getBuffSystem():addBuff(self, self, buff[1], 1, buff[2], buff[3], buff[4], 100)
--     end
-- end

-- function FightCharacter:setEquipWeapon(weapon)
--     self:setEquipment(FightCommons.EQUIP_PART.WEAPON, isImplement(weapon, require("app.FightSystem.FightRole.CharacterEquipment.IWeapon")))
-- end

-- function FightCharacter:setStandbyWeapon(weapon)
--     self:setStandbyEquipment(FightCommons.EQUIP_PART.WEAPON, weapon)
-- end

-- function FightCharacter:removeStandbyWeapon()
--     self:getEquipSys():unmountStandbyWeapon()
-- end

-- --@desc: 获取备用武器
-- --@author:Seven
-- --@time:2022-01-19 21:23:03
-- --@return [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
-- function FightCharacter:getStandbyWeapon()
--     return self:getStandbyEquipment(FightCommons.EQUIP_PART.WEAPON)
-- end

-- --@desc: 获取攻击武器
-- --@author:Seven
-- --@time:2021-05-29 18:09:25
-- --@return [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
-- function FightCharacter:getWeapon()
--     return self:getEquipSys():getWeapon()
-- end

-- --[[
--     @desc:判断是否为空手
--     author:tangjian
--     time:2021-07-30 14:37:48
--     @return: boolean
-- ]]
-- function FightCharacter:weaponIsEmptyHand()
--     return self:getEquipSys():weaponIsEmptyHand()
-- end

-- function FightCharacter:standbyWeaponIsEmptyHand()
--     return self:getEquipSys():standbyWeaponIsEmptyHand()
-- end

-- function FightCharacter:setEquipment(equipPart, equipment)
--     return self:getEquipSys():setEquipment(equipPart, equipment)
-- end

-- function FightCharacter:getEquipment(equipPart)
--     return self:getEquipSys():getEquipment(equipPart)
-- end

-- function FightCharacter:setStandbyEquipment(equipPart, equipment)
--     return self:getEquipSys():setStandbyEquipment(equipPart, equipment)
-- end

-- function FightCharacter:getStandbyEquipment(equipPart)
--     return self:getEquipSys():getStandbyEquipment(equipPart)
-- end
 
-- --@desc: 角色装备防护力
-- --@author:Seven
-- --@time:2021-06-29 21:32:17
-- function FightCharacter:getEquipTotalProtect()
--     return self:getEquipSys():getEquipTotalProtect()
-- end

-- --@desc: 外部角色武学相关信息(该字段只用于初始化阶段，进入战斗后不再使用)
-- --@author:Seven
-- --@time:2021-07-16 11:53:26
-- --@skills: 外部角色技能信息
-- function FightCharacter:setSkills(skills)
--     self.__skills = skills
-- end

-- --@desc: 获取已学技能的技能对象（根据）
-- --@author:Seven
-- --@time:2021-07-16 11:41:33
-- --@skill_id: 技能id
-- --@return [src.app.FightSystem.FightSkill.NormalFightSkill#NormalFightSkill]
-- function FightCharacter:getSkill(skill_id)
--     if MapIsEmpty(self.__skills) then
--         return nil
--     end

--     for id, skill_info in pairs(self.__skills) do
--         if skill_id == id then
--             local Skill = require("app.models.skill.Skill")
--             local SkillFactory = require("app.FightSystem.Factory.FightSkillFactory.SkillFactory")
--             local lv = Skill:getLv(skill_info.exp)
--             local f_skill = SkillFactory:createSkill(skill_id, lv)
--             return f_skill
--         end
--     end

--     return nil
-- end

-- --@desc: 攻击类型
-- --@author:Seven
-- --@time:2021-05-29 18:16:29
-- --@attack_skill_type: 攻击类型（即技能二级类型）
-- function FightCharacter:setAttackSkillType(attack_skill_type)
--     self.__attackSkillType = tostring(attack_skill_type)
-- end

-- --@desc: 当前使用的攻击武学类型
-- --@author:Seven
-- --@time:2021-05-28 11:20:49
-- function FightCharacter:getAttackSkillType()
--     return self.__attackSkillType
-- end

-- --@desc: 当前攻击基本武学
-- --@author:Seven
-- --@time:2021-06-29 17:38:07
-- function FightCharacter:getBaseAttackSkill()
--     local attackSkillType = tostring(self:getAttackSkillType())

--     local baseSkill = self:getBaseSkill(attackSkillType)

--     return baseSkill
-- end

-- --@desc: 获取当前准备武学（需武器配套）
-- --@author:Seven
-- --@time:2021-07-08 22:14:59
-- function FightCharacter:getPrepAttackSkill()
--     local prepAttackSkill = self:getPrepSkill(self:getAttackSkillType())

--     if prepAttackSkill == nil then
--         return nil
--     end

--     local weapon = self:getWeapon()

--     if prepAttackSkill:isUseWeaponType(weapon:getWeaponResId()) then
--         return prepAttackSkill
--     end

--     return nil
-- end

-- --@desc: 获取当前攻击使用的武学
-- --@author:Seven
-- --@time:2021-05-31 10:35:48
-- --@return [src.app.FightSystem.FightSkill.NormalFightSkill#NormalFightSkill]
-- function FightCharacter:getAttackSkill()
--     local attackSkill

--     local prepSkill = self:getPrepAttackSkill()

--     if prepSkill == nil then
--         local attackSkillType = tostring(self:getAttackSkillType())
--         attackSkill = self:getBaseSkill(attackSkillType)
--     else
--         attackSkill = prepSkill
--     end

--     return attackSkill
-- end

-- --@return [src.app.FightSystem.FightSkill.NormalFightSkill#NormalFightSkill]
-- function FightCharacter:getDodgeSkill()
--     local dodgeSkill

--     local prepDodgeSkill = self:getPrepSkill(tostring(SKILL_SECOND_TYPE.QING_GONG))

--     if prepDodgeSkill == nil then
--         dodgeSkill = self:getBaseSkill(tostring(SKILL_SECOND_TYPE.QING_GONG))
--     else
--         dodgeSkill = prepDodgeSkill
--     end

--     return dodgeSkill
-- end

-- --@return [src.app.FightSystem.FightSkill.NormalFightSkill#NormalFightSkill]
-- function FightCharacter:getParrySkill()
--     local parrySkill

--     local prepParrySkill = self:getPrepSkill(tostring(SKILL_SECOND_TYPE.ZHAO_JIA))

--     if prepParrySkill == nil then
--         parrySkill = self:getBaseSkill(tostring(SKILL_SECOND_TYPE.ZHAO_JIA))
--     else
--         parrySkill = prepParrySkill
--     end

--     return parrySkill
-- end

-- function FightCharacter:getNeiGongSkill()
--     local neiGongSkill
--     local prepNeiGongSkill = self:getPrepSkill(tostring(SKILL_SECOND_TYPE.NEI_GONG))

--     if prepNeiGongSkill == nil then
--         neiGongSkill = self:getBaseSkill(tostring(SKILL_SECOND_TYPE.NEI_GONG))
--     else
--         neiGongSkill = prepNeiGongSkill
--     end

--     return neiGongSkill
-- end

-- function FightCharacter:addPrepSkill(skillSecType, skill)
--     self.__prep_skill[tostring(skillSecType)] = skill
-- end

-- function FightCharacter:getPrepSkills()
--     return self.__prep_skill
-- end

-- --@desc: 获取准备技能
-- --@author:Seven
-- --@time:2021-06-29 19:01:12
-- --@skillSecType: 技能二类型
-- --@return [src.app.FightSystem.FightSkill.NormalFightSkill#NormalFightSkill]
-- function FightCharacter:getPrepSkill(skillSecType)
--     return self.__prep_skill[tostring(skillSecType)]
-- end

-- --@desc: 添加基本武学
-- --@author:Seven
-- --@time:2021-06-28 15:06:18
-- function FightCharacter:addBaseSkill(skillSecType, baseSkill)
--     self.__base_skill[tostring(skillSecType)] = baseSkill
-- end

-- --@desc: 获取基本武学类型
-- --@author:Seven
-- --@time:2021-06-28 15:02:11
-- --@skillSecType: 武学第二类型
-- --@return [src.app.FightSystem.FightSkill.NormalFightSkill#NormalFightSkill]
-- function FightCharacter:getBaseSkill(skillSecType)
--     return self.__base_skill[tostring(skillSecType)]
-- end

-- --@desc: 添加主动招式
-- --@author:Seven
-- --@time:2021-06-18 11:53:55
-- --@activeSkill: [src.app.FightSystem.FightSkill.NormalFightActiveSkill#NormalFightActiveSkill]
-- function FightCharacter:addActiveSkill(activeSkill)
--     self.__active_skill[activeSkill:getId()] = activeSkill
-- end

-- function FightCharacter:removePrepActiveSkill(act_id)
--     local isRemoveSuccess = false

--     self:__walkPrepActiveSkill(
--         function(pos, id)
--             if id == act_id then
--                 self.__prep_act[tostring(pos)] = nil
--                 isRemoveSuccess = true
--                 return true
--             end
--             return false
--         end
--     )

--     if not isRemoveSuccess then
--         assert(false, "FightCharacter:removePrepActiveSkill 没有准备 id :" .. act_id .. "的主动技能，无法移除")
--     end
-- end

-- function FightCharacter:__walkPrepActiveSkill(func)
--     if not MapIsEmpty(self.__prep_act) then
--         for pos, id in pairs(self.__prep_act) do
--             if func(pos, id) then
--                 break
--             end
--         end
--     end
-- end

-- --@desc: 添加可使用的主动招式
-- --@author:Seven
-- --@time:2021-06-18 11:58:09
-- --@skillId: 主动技能ID
-- function FightCharacter:addPrepActiveSkill(act_id, pos_index)
--     if type(act_id) ~= "string" then
--         assert(false, "FightCharacter:addPrepActiveSkill 添加准备主动技能参数错误")
--     end

--     local need_add = true
--     --@desc 去重
--     if not MapIsEmpty(self.__prep_act) then
--         for pos, id in pairs(self.__prep_act) do
--             if id == act_id then
--                 need_add = false
--             end
--         end
--     end

--     if need_add then
--         self.__prep_act[tostring(pos_index)] = act_id
--     end
-- end

-- function FightCharacter:__isPrepActiveSkill(act_id)
--     local isPrep = false

--     if not MapIsEmpty(self.__prep_act) then
--         for k, v in pairs(self.__prep_act) do
--             if v == act_id then
--                 isPrep = true
--                 break
--             end
--         end
--     end

--     return isPrep
-- end

-- --@desc: 已准备的主动技能
-- --@author:Seven
-- --@time:2022-10-09 14:10:02
-- function FightCharacter:getPrepAcitveSkills()
--     local prepActSkills = {}
--     if MapIsEmpty(self.__prep_act) then
--         return prepActSkills
--     end

--     local actIds = {}
--     for index, act_id in pairs(self.__prep_act) do
--         table.insert(actIds, act_id)
--     end

--     table.sort(actIds)

--     for _, act_id in ipairs(actIds) do
--         local actSkill = self:getActiveSkill(act_id)
--         table.insert(prepActSkills, actSkill)
--     end

--     return prepActSkills
-- end

-- function FightCharacter:getPrepActiveSkillAtOrder()
--     return self.__prep_act
-- end

-- function FightCharacter:setPrepActiveSkillConfig(skillSecType, config)
--     if skillSecType == nil or config then
--         assert(false, "FightCharacter:setPrepSkillConfig ：传参错误，请检查代码")
--     end
--     self.__active_skill_config[tostring(skillSecType)] = config
-- end

-- function FightCharacter:getPrepActiveSkillConfig(skillSecType)
--     return Helper:getDef(self.__active_skill_config[tostring(skillSecType)], {})
-- end

-- function FightCharacter:initActivePrepActiveSkill()
--     -- local config = {
--     --     ["101"] = {
--     --         ["1"] = {activeSkillId = "qiankungunding", level = 10},
--     --         -- ["2"] = {activeSkillId = "wuhenzhifeng", level = 10},
--     --         -- ["3"] = {activeSkillId = "fusuzhifeng", level = 10},
--     --         ["4"] = {activeSkillId = "tianhuojianglin", level = 10},
--     --         ["5"] = {activeSkillId = "yurenwushuang", level = 10},
--     --         -- ["6"] = {activeSkillId = "bingjiyugu", level = 10}
--     --     }
--     -- }

--     -- self.__active_skill_config = config

--     local currWeapon = self:getWeapon()

--     --@RefType [src.app.models.ActiveSkillPrepare.ActiveSkillPrepareV2#ActiveSkillPrepareV2]
--     local activeSkillPrepareV2 = require("app.models.ActiveSkillPrepare.ActiveSkillPrepareV2"):create()

--     activeSkillPrepareV2:setCharacter(self)

--     activeSkillPrepareV2:setWeaponType(currWeapon:getFirstType())

--     activeSkillPrepareV2:setWeaponSecType(currWeapon:getSecondType())

--     activeSkillPrepareV2:initialize()

--     print(table.tostring(activeSkillPrepareV2:getPreparedActiveSkillList()))

--     local prep_map = activeSkillPrepareV2:getPreparedActiveSkillList()

--     if not MapIsEmpty(self.__prep_act) then
--         self:__walkPrepActiveSkill(
--             function(pos, act_id)
--                 self:removePrepActiveSkill(act_id)
--             end
--         )
--     end

--     for pos_index, actSkill_info in pairs(prep_map) do
--         self:addPrepActiveSkill(actSkill_info.activeSkillId, tonumber(pos_index))
--     end
-- end

-- function FightCharacter:getActiveSkills()
--     return self.__active_skill
-- end

-- --@desc: 获取主动招式
-- --@author:Seven
-- --@time:2021-06-18 12:08:07
-- --@act_id: 主动招式ID
-- --@return [src.app.FightSystem.FightSkill.NormalFightActiveSkill#NormalFightActiveSkill]
-- function FightCharacter:getActiveSkill(act_id)
--     local act = self.__active_skill[act_id]
--     if act == nil then
--         assert(false, "角色 ： " .. self:getAttr("name") .. "没有该可用主动技能 ：" .. act_id)
--     end

--     return act
-- end

-- --@desc: 由于旧版战斗相关系统并未完全接入，有时需要判断当前是否存在该主动技能
-- --@author:Seven
-- --@time:2022-09-26 16:10:39
-- --@act_id: 主动技能id
-- --@return: true|false
-- function FightCharacter:findActiveSkill(act_id)
--     return self.__active_skill[act_id] ~= nil
-- end

-- function FightCharacter:setActiveSkillCd(act_id, cd)
--     local activeSkill = self:getActiveSkill(act_id)

--     activeSkill:setCD(cd)

--     if self.__output then
--         self.__output:setActiveSkillCD(act_id, cd)
--     end
-- end

-- function FightCharacter:__updateActSkillsCD(ft)
--     local act_skills = self:getActiveSkills()

--     for _, actSkill in pairs(act_skills) do
--         local cd = actSkill:getCD()
--         if cd > 0 then
--             local cdTime = math.max(cd - ft, 0)

--             actSkill:setCD(cdTime)

--             FightUtil:printLog(string.format("【%s】 主动技能CD更新【%s】 CD剩余: %f", self:getAttr("name"), actSkill:getName(), cdTime))

--             self:__updateActiveSkillCDView(actSkill:getId(), cd, cdTime, ft)
--         end
--     end
-- end

-- function FightCharacter:__updatePrepActiveSkillsEnable()
--     local prepActSkills = self:getPrepAcitveSkills()

--     if #prepActSkills < 0 then
--         return
--     end

--     for i = 1, #prepActSkills do
--         --@RefType [src.app.FightSystem.FightSkill.NormalFightActiveSkill#NormalFightActiveSkill]
--         local actSkill = prepActSkills[i]

--         local isMeetCost = actSkill:releaseAreMet()
--         if isMeetCost then
--             self:__updateActiveSkillIsEnable(actSkill:getId(), true)
--         else
--             self:__updateActiveSkillIsEnable(actSkill:getId(), false)
--         end
--     end
-- end

-- --@desc: 判断是否可以出手
-- --@author:Seven
-- --@time:2021-05-11 15:55:24
-- function FightCharacter:canAutoAttack()
--     local isIdleState = self.__stateMachine:getCurrStateType() == CHARACTER_STATE.IDLE

--     local isTiliMeet = self:getAttr("tili") >= BattleConstConf:get("autoUseSkillTili")

--     local isBuffBanAuto = self:getBuffSystem():roleIsBanAutoZhao(self:getId())

--     return isIdleState and not isBuffBanAuto and isTiliMeet
-- end

-- --@desc: 攻击
-- --@author:Seven
-- --@time:2021-05-27 11:40:57
-- --@zhaoAtk: [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
-- function FightCharacter:attack(zhaoAtk)
--     local target = self:getTarget()
--     zhaoAtk:doAttack(self, target)

--     if self.__output then
--         self.__output:attack(target:getId(), zhaoAtk)
--     end
-- end

-- function FightCharacter:recoverTili(ft)
--     local value = self:getAttr("tiliSpeedBattle") * ft

--     local addValue = self:addAttr("tili", value)

--     FightUtil:printLog(" 【", self:getAttr("name"), "】体力恢复 : ", addValue, "，当前体力：", self:getAttr("tili"))

--     if self.__output then
--         self.__output:recoverTili(value, ft)
--     end
-- end

-- --@desc: 消耗体力
-- --@author:Seven
-- --@time:2021-05-26 15:29:02
-- --@value: 消耗的值
-- function FightCharacter:consumeTili(value)
--     if value < 0 then
--         assert(false, "消耗体力值不可为负数")
--     end

--     local n_tili = self:getAttr("tili")

--     local consume_value = value
--     if n_tili < value then
--         consume_value = n_tili
--     end

--     self:setAttr("tili", n_tili - consume_value)

--     if self.__output then
--         self.__output:costTili(self:getAttr("tili"))
--     end

--     FightUtil:printLog(" 【", self:getAttr("name"), "】 计算消耗体力 - ", value, "，实际消耗体力 - ", consume_value, ", 剩余体力 - ", self:getAttr("tili"))
-- end

-- function FightCharacter:consumeNeili(value)
--     if value < 0 then
--         assert(false, "消耗内力值不可为负数")
--     end

--     local addValue = self:addAttr("neili", -value)

--     if self.__output then
--         self.__output:costNeili(addValue)
--     end
-- end

-- function FightCharacter:triggerEvent(event)
--     return self.__stateMachine:trigger(event)
-- end

-- function FightCharacter:changeState(state, params)
--     return self.__stateMachine:changeState(state, params)
-- end

-- --@desc: 获取当前角色状态
-- --@author:Seven
-- --@time:2021-05-19 16:24:21
-- function FightCharacter:getCharacterState()
--     return self.__stateMachine:getCurrentState()
-- end

-- function FightCharacter:getCurrentStateType()
--     return self.__stateMachine:getCurrStateType()
-- end

-- function FightCharacter:isDead()
--     return self.__stateMachine:getCurrStateType() == CHARACTER_STATE.DEAD
-- end

-- function FightCharacter:isRunaway()
--     return self.__stateMachine:getCurrStateType() == CHARACTER_STATE.RUNAWAY
-- end

-- function FightCharacter:isStop()
--     return self:isDead() or self.__stateMachine:getCurrStateType() == CHARACTER_STATE.RUNAWAY
-- end

-- --@desc: 获取角色被动招式管理系统
-- --@author:Seven
-- --@time:2021-06-23 10:51:45
-- --@return [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.NewAutoSkillAttack#NewAutoSkillAttack]
-- function FightCharacter:getAutoSkillAttack()
--     return self.__autoSkillAttack
-- end

-- --@desc: 获取角色主动招式管理系统
-- --@author:Seven
-- --@time:2021-06-23 10:52:08
-- --@return [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.ActiveSkillAttack#ActiveSkillAttack]
-- function FightCharacter:getActiveSkillAttack()
--     return self.__activeSkillAttack
-- end

-- function FightCharacter:checkActiveReleaseAI()
--     self.__activeReleaseAI:checkReleaseRules()
-- end

-- --@desc: 自动申请释放主动技能
-- --@author:Seven
-- --@time:2021-07-20 14:53:38
-- --@act_id: 主动技能id
-- function FightCharacter:applyPrepReleaseActiveSkill(act_id)
--     if not self:__isPrepActiveSkill(act_id) then
--         return
--     end

--     local activeSkill = self:getActiveSkill(act_id)
--     FightUtil:printLog(string.format("【%s】 自动申请释放主动技能：%s(id：%s)", self:getAttr("name"), activeSkill:getName(), activeSkill:getId()))
--     self.__character_sys:characterPrepReleaseActiveSkill(self:getId(), act_id)
-- end

-- --@desc: 准备释放主动技能
-- --@author:Seven
-- --@time:2021-06-28 20:20:23
-- function FightCharacter:prepReleaseActiveSkill(act_id)
--     if not self:__isPrepActiveSkill(act_id) then
--         FightUtil:printLog(string.format("【%s】 申请准备释放主动技能失败，并非准备的主动技能 ：(id：%s)", self:getAttr("name"), tostring(act_id)))
--         return
--     end
--     self.__character_sys:applyReleaseActiveSkill(self:getId(), act_id)
--     if self.__output then
--         local activeSkill = self:getActiveSkill(act_id)
--         self.__output:showOpertionName(activeSkill:getName())
--     end
-- end

-- --@desc: 释放主动技能
-- --@author:Seven
-- --@time:2021-06-28 20:21:00
-- function FightCharacter:releaseActiveSkill(act_id)
--     self.__activeReleaseAI:releaseActiveZhao(act_id)

--     self:getRecordClass():addActiveReleaseTime(act_id)

--     if self.__output then
--         self.__output:removeOperationName()
--     end
-- end

-- function FightCharacter:cancelReleaseActiveSkill(act_id)
--     if self.__output then
--         self.__output:removeOperationName()
--     end
-- end

-- --@desc: 开始行动
-- --@author:Seven
-- --@time:2021-06-28 17:05:03
-- function FightCharacter:startAction()
--     local target = self:getTarget()
--     if target == nil then
--         target = self:selectTarget()
--         self:setTarget(target)
--     end
--     self.__character_sys:startAction(self:getId())
-- end

-- --@desc: 结束行动
-- --@author:Seven
-- --@time:2021-06-28 17:05:12
-- function FightCharacter:finishAction()
--     local target = self:getTarget()
--     --@desc 敌人已死亡，移除目标
--     if target:isDead() then
--         self:removeTarget()
--     end
--     self.__character_sys:finishAction(self:getId())
-- end

-- function FightCharacter:startCombAttack()
-- end

-- --@desc: 招式组合结束前的执行调用
-- --@author:Seven
-- --@time:2021-12-21 14:49:55
-- function FightCharacter:doWhenFinishCombAttack(skillAttack)
--     self.__character_sys:doWhenZhaoCombFinish(self:getId(), skillAttack)
-- end

-- function FightCharacter:finishCombAttack(skillAttack)
--     self.__character_sys:characterZhaoCombFinish(self:getId(), skillAttack)
-- end

-- function FightCharacter:runAway()
--     self:setRunawayCd(BattleConstConf:get("battleAction_runAway_cd"))
--     if self.__output then
--         self.__output:removeOperationName()
--         self.__output:runAway()
--     end
-- end

-- function FightCharacter:cancelRunAway()
--     if self.__output then
--         self.__output:removeOperationName()
--     end
-- end

-- function FightCharacter:update(ft)
--     if self:canRecover() and self:getAttr("tili") <= tonumber(BattleConstConf:get("tiliMax")) then
--         self:recoverTili(ft)
--     end

--     self.__activeReleaseAI:update(ft)

--     self:__updateActSkillsCD(ft)

--     self:__updatePrepActiveSkillsEnable(ft)

--     self:__updateQiRecover(ft)

--     self:__updateRunawayCd(ft)

--     self.__stateMachine:update(ft)
-- end

-- --@region output
-- --@desc:更新主动技能CD
-- --@author:Seven
-- --@time:2021-07-09 15:40:23
-- --@act_id: 技能id
-- --@preCD : cd恢复前的值
-- --@cdTime: 恢复的时间
-- function FightCharacter:__updateActiveSkillCDView(act_id, preCD, cdTime, ft)
--     if self.__output then
--         self.__output:updateActiveSkillCD(act_id, preCD, cdTime, ft)
--     end
-- end

-- function FightCharacter:__updateActiveSkillIsEnable(act_id, bool)
--     if self.__output then
--         self.__output:updateActiveSkillEnable(act_id, bool)
--     end
-- end

-- function FightCharacter:stand()
--     if self.__output then
--         self.__output:enterIdleState()
--     end
-- end

-- function FightCharacter:jump(animName, jump_info)
--     if self.__output then
--         self.__output:jump(animName, jump_info)
--     end
-- end

-- function FightCharacter:enterFight()
--     if self.__output then
--         self.__output:enterFight()
--     end
-- end

-- function FightCharacter:activeReady(animName, soundId, soundStart)
--     if self.__output then
--         self.__output:activeReady(animName, {soundId = soundId, soundStart = soundStart})
--     end
-- end

-- function FightCharacter:outputDesces(desces)
--     self.__output:printDesces(
--         table.map(
--             desces,
--             function(desc)
--                 -- desc:setReplace("$N", self:getAttr("name"))
--                 return desc
--             end
--         )
--     )
-- end

-- function FightCharacter:updateBuffInfos()
--     local buffSystem = self.__character_sys:getFight():getBuffSystem()
--     self.__output:updateBuffInfos(buffSystem:getRoleBuffIconAndLevelArray(self:getId()))
-- end

-- function FightCharacter:__updateRecoverQiCDView(preCD, cdTime, ft)
--     if self.__output then
--         self.__output:updateRecoverQiCD(preCD, cdTime, ft)
--     end
-- end

-- --@endregion

-- --@region BuffSystem

-- --[[
--     @desc: 获得buff执行器
--     author:TangJian
--     time:2022-01-12 17:56:30
--     --@eventType: buff事件类型
-- 	--@eventParam: buff事件参数
--     @return: buff执行器
-- ]]
-- function FightCharacter:getBuffExecutor(eventType, eventParam)
--     return self:getBuffSystem():getBuffExecutor(self, eventType, eventParam)
-- end

-- function FightCharacter:__updateAnimUIView()
--     local text = self:getBuffSystem():getRoleHeadText(self:getId())
--     if text and text ~= 0 then
--         self.__output:showStatusTips(text)
--     else
--         self.__output:hideStatusTips()
--     end

--     self:updateControlledUIState(self:getBuffSystem():getRoleIdleExpression(self:getId()))
-- end

-- function FightCharacter:addBuff(attacker, buffId, autoAvgAtk, dynamicArg1, dynamicArg2, dynamicArg3, addProbability)
--     if self:isDead() then
--         return
--     end
--     return self:getBuffSystem():addBuff(attacker, self, buffId, autoAvgAtk, dynamicArg1, dynamicArg2, dynamicArg3, addProbability)
-- end

-- function FightCharacter:tryRemoveBuff(eventName, eventParam)
--     local hasRemove = false
--     local removeBuffArray = self:getBuffSystem():roleTryRemoveBuff(self:getId(), eventName, eventParam)
--     for _, buff in ipairs(removeBuffArray) do
--         hasRemove = true
--         local removeText = buff:getRemoveText()
--         if type(removeText) == "string" and removeText ~= "" then
--             self:printDesces({Desc:create(removeText, {{"$BsN", self:getAttr("name")}})})
--         end
--     end

--     if hasRemove then
--         self:updateBuffInfos()
--         self:__updateAnimUIView()
--         self:updateAnimQiShield()
--         self:updateShadowEffect()
--     end
-- end

-- function FightCharacter:updateAnimQiShield()
--     if self.__output == nil then
--         return
--     end
--     local shieldValue = self:getBuffSystem():getShieldValue(self:getId())

--     self.__output:setQiShieldValue(shieldValue)
--     if shieldValue > 0 then
--         local shieldAnimResId = self:getBuffSystem():getRoleShieldAnimId(self:getId())
--         self.__output:showQiShieldAnim(shieldAnimResId)
--     else
--         self.__output:hideQiShieldAnim()
--     end
-- end

-- function FightCharacter:updateShadowEffect()
--     if self.__output == nil then
--         return
--     end
--     local animId = self:getBuffSystem():getRoleFeetHaloAnimId(self:getId())
--     if animId then
--         self.__output:showShadowEffect(animId)
--     else
--         self.__output:hideShadowEffect()
--     end
-- end

-- function FightCharacter:getBuffAddAttr(attrName)
--     if self.__character_sys then
--         return self:getBuffSystem():getAddAttr(self:getId(), attrName)
--     end
--     return 0
-- end

-- function FightCharacter:getBuffMulAttr(attrName)
--     if self.__character_sys then
--         return self:getBuffSystem():getMulAttr(self:getId(), attrName)
--     end
--     return 0
-- end

-- function FightCharacter:setBuffSystem(buffSystem)
--     self.__buffSystem = buffSystem
-- end

-- --@return [src.app.FightSystem.FightBuff.BuffSystem#BuffSystem]
-- function FightCharacter:getBuffSystem()
--     return self.__buffSystem
-- end

-- function FightCharacter:getMulAutoZhaoTiliCost()
--     local buffSys = self:getBuffSystem()

--     if buffSys then
--         return buffSys:roleGetMulAutoZhaoTiliCost(self:getId())
--     end

--     return 0
-- end

-- function FightCharacter:getAddAutoZhaoTiliCost()
--     local buffSys = self:getBuffSystem()

--     if buffSys then
--         return buffSys:roleGetAddAutoZhaoTiliCost(self:getId())
--     end

--     return 0
-- end

-- function FightCharacter:getAddAutoZhaoNeiliCost()
--     local buffSys = self:getBuffSystem()

--     if buffSys then
--         return buffSys:roleGetAddAutoZhaoNeiliCost(self:getId())
--     end

--     return 0
-- end

-- function FightCharacter:getMulAutoZhaoNeiliCost()
--     local buffSys = self:getBuffSystem()

--     if buffSys then
--         return buffSys:roleGetMulAutoZhaoNeiliCost(self:getId())
--     end

--     return 0
-- end

-- function FightCharacter:getMulActiveZhaoNeiliCost()
--     local buffSys = self:getBuffSystem()

--     if buffSys then
--         return buffSys:roleGetMulActiveZhaoNeiliCost(self:getId())
--     end

--     return 0
-- end

-- function FightCharacter:getAddActiveZhaoNeiliCost()
--     local buffSys = self:getBuffSystem()

--     if buffSys then
--         return buffSys:roleGetAddActiveZhaoNeiliCost(self:getId())
--     end

--     return 0
-- end

-- function FightCharacter:getMulActiveZhaoTiliCost()
--     local buffSys = self:getBuffSystem()

--     if buffSys then
--         return buffSys:roleGetMulActiveZhaoTiliCost(self:getId())
--     end

--     return 0
-- end

-- function FightCharacter:getAddActiveZhaoTiliCost()
--     local buffSys = self:getBuffSystem()

--     if buffSys then
--         return buffSys:roleGetAddActiveZhaoTiliCost(self:getId())
--     end

--     return 0
-- end

-- function FightCharacter:isRandomBaseAutoZhao()
--     local buffSys = self:getBuffSystem()

--     if buffSys then
--         return buffSys:roleIsRandomBaseAutoZhao(self:getId())
--     end

--     return false
-- end

-- --@endregion

-- --@region 门派相关
-- function FightCharacter:setFamilyID(familyId)
--     self.__familyId = familyId
-- end

-- function FightCharacter:getFamilyId()
--     return self.__familyId
-- end
-- --@endregion

-- function FightCharacter:printDesces(desces)
--     if self.__output then
--         self.__output:printDesces(desces)
--     end
-- end

-- function FightCharacter:PopText(text)
--     if self.__output then
--         self.__output:popOverHeadText(text)
--     end
-- end

-- function FightCharacter:doChangeAttrMap(attrChangeMap)
--     if MapIsEmpty(attrChangeMap) then
--         return
--     end

--     local result = {}

--     local addToResult = function(attrName, value)
--         if result[attrName] == nil then
--             result[attrName] = 0
--         end

--         result[attrName] = result[attrName] + value
--     end

--     for attrName, value in pairs(attrChangeMap) do
--         if attrName ~= "qi" and attrName ~= "qiMax" then
--             local realValue = self:addAttr(attrName, value)
--             addToResult(attrName, value)
--         end
--     end

--     local qiMaxValue = attrChangeMap["qiMax"]
--     local qiValue = attrChangeMap["qi"]

--     if qiMaxValue == nil then
--         qiMaxValue = 0
--     end

--     if qiValue == nil then
--         qiValue = 0
--     end

--     if qiMaxValue > 0 then
--         addToResult("qiMax", self:addAttr("qiMax", qiMaxValue))
--     end

--     if qiValue > 0 then
--         addToResult("qi", self:addAttr("qi", qiValue))
--     end

--     if qiValue < 0 then
--         addToResult("qi", self:addAttr("qi", qiValue))
--     end

--     if qiMaxValue < 0 then
--         addToResult("qiMax", self:addAttr("qiMax", qiMaxValue))
--     end

--     return result
-- end

-- --@region 角色逃跑功能相关
-- function FightCharacter:setRunawayCd(value)
--     if value < 0 then
--         error("设置逃跑CD不可小于0")
--     end

--     self.__runawayCd = value
-- end

-- function FightCharacter:getRunawayCd()
--     return self.__runawayCd
-- end

-- function FightCharacter:__updateRunawayCd(ft)
--     if self.__runawayCd <= 0 then
--         return
--     end
--     local value = self.__runawayCd - ft

--     if value < 0 then
--         value = 0
--     end

--     if self.__output then
--         self.__output:updateRecoverQiCD(self.__runawayCd, value, ft)
--     end

--     self:setRunawayCd(value)
-- end

-- function FightCharacter:canRunAway()
--     local banInfo = self:__getDisableOperationInfo("runAway")

--     if banInfo ~= nil then
--         local BuffConf = require("app.FightSystem.Configuration.BuffConf")
--         local effect = BuffConf:getEffect(banInfo.effectId)

--         local tip = effect:getActiveEffectUseZhaoTips()

--         return false, tip
--     end

--     if self:getRunawayCd() > 0 then
--         return false, "逃跑CD中，无法逃跑"
--     end

--     return true
-- end

-- function FightCharacter:applyRunaway()
--     local can, tip = self:canRunAway()

--     if not can then
--         if self:isPlayer() and tip ~= nil then
--             self.__character_sys:getFight():popMessage(tip)
--         end
--         return
--     end

--     self.__character_sys:removeCharacterAllCommand(self:getId())
--     self.__character_sys:applyRunaway(self:getId())

--     if self.__output then
--         self.__output:showOpertionName(BattleConstConf:get("battleAction_runAway_name"))
--     end
-- end
-- --@endregion

-- --@region 易武相关
-- function FightCharacter:canDoChangeWeapon()
--     if self:getEquipSys():standbyWeaponIsEmptyHand() then
--         return false
--     end

--     local standby_weapon = self:getEquipSys():getStandbyWeapon()

--     if standby_weapon:getFightState() == FightCommons.FIGHT_WEAPON_STATE.DESTROY then
--         return false, TextResManager:getText("1081")
--     end

--     if standby_weapon:getFightState() == FightCommons.FIGHT_WEAPON_STATE.FLY then
--         return false, TextResManager:getText("1082")
--     end

--     if standby_weapon:getFightState() == FightCommons.FIGHT_WEAPON_STATE.GIVEUP then
--         return false, TextResManager:getText("1083")
--     end

--     local banInfo = self:__getDisableOperationInfo("changeWeapon")

--     if banInfo ~= nil then
--         local BuffConf = require("app.FightSystem.Configuration.BuffConf")
--         local effect = BuffConf:getEffect(banInfo.effectId)

--         local tip = effect:getActiveEffectUseZhaoTips()

--         return false, tip
--     end

--     return true
-- end

-- --@desc: 申请易武
-- --@author:Seven
-- --@time:2022-01-14 14:16:41
-- function FightCharacter:applyChangeWeapon()
--     local canDo, tip = self:canDoChangeWeapon()

--     if not canDo then
--         if self:isPlayer() and tip ~= nil then
--             self.__character_sys:getFight():popMessage(tip)
--         end
--         return
--     end

--     self.__character_sys:applyChangeWeapon(self:getId())

--     if self.__output then
--         self.__output:showOpertionName(BattleConstConf:get("battleAction_changeWeapon_name"))
--     end
-- end

-- function FightCharacter:getCharacterViewInfo()
--     return {
--         stand_anim = self:getStandAnimName(),
--         join_anim = self:getJoinAnimName(),
--         jumpForwardAnim = self:getJumpForwardAnimName(),
--         jumpbackAnim = self:getJumpBackAnimName()
--     }
-- end

-- function FightCharacter:getChararcterActiveSkillVm()
--     local activeSkillInfo = {}

--     local actSkillMap = self:getPrepActiveSkillAtOrder()

--     if MapIsEmpty(actSkillMap) == false then
--         local ActiveSkillInfoVm = require("app.FightSystem.UICtrl.UIModel.ActiveSkillInfoVm")
--         for prep_pos, act_id in pairs(actSkillMap) do
--             --@RefType [src.app.FightSystem.FightSkill.NormalFightActiveSkill#NormalFightActiveSkill]
--             local act_skill = self:getActiveSkill(act_id)

--             --@RefType [src.app.FightSystem.UICtrl.UIModel.ActiveSkillInfoVm#ActiveSkillInfoVm]
--             local act_vm = ActiveSkillInfoVm:create()

--             act_vm:setType(FightCommons.CHARATER_CMD_TYPE.RELEASE_ACTIVE)

--             act_vm:setId(act_skill:getId())

--             act_vm:setName(act_skill:getName())

--             act_vm:setDesc(act_skill:getDesc())

--             act_vm:setLevel(act_skill:getLevel())

--             act_vm:setConditionTexts(act_skill:getUseConditionTexts())

--             act_vm:setCD(act_skill:getCD())

--             act_vm:setCoolTime(act_skill:getCoolDownTime())

--             act_vm:setEnable(false)

--             act_vm:setCostNeili(act_skill:getNeiliCost())

--             activeSkillInfo[prep_pos] = act_vm
--         end
--     end

--     return activeSkillInfo
-- end

-- --@desc 切换为备用武器
-- function FightCharacter:changeStandbyWeapon()
--     if self:getEquipSys():standbyWeaponIsEmptyHand() then
--         assert(false, "备用武器栏为空，不可易武，检查代码")
--     end

--     self:__unmountWeapon(self:getWeapon())

--     local standByWeapon = self:getEquipSys():getStandbyWeapon()

--     self:getEquipSys():setWeapon(standByWeapon)

--     self:__useWeapon(standByWeapon)
-- end

-- --@desc: 角色执行了易武操作
-- --@author:Seven
-- --@time:2022-01-14 14:44:50
-- function FightCharacter:aftChangeStandbyWeapon(animName, weapon)
--     --@region 功能先实现，后续需跟characterCtrlFactory 创建主动技能的部分整合。

--     --@endregion

--     if self.__output then
--         local act_vm_info = self:getChararcterActiveSkillVm()
--         local viewInfo = self:getCharacterViewInfo()
--         self.__output:removeOperationName()
--         self.__output:removeAllOperationName()
--         self.__output:characterChangedStandByWeapon(animName, weapon, act_vm_info, viewInfo)
--         self:updateBuffInfos()
--     end
-- end

-- function FightCharacter:cancelChangeStandbyWeapon()
--     if self.__output then
--         self.__output:removeOperationName()
--     end
-- end
-- --@endregion

-- function FightCharacter:__getDisableOperationInfo(functionName)
--     local list = self:getBuffSystem():getDisableFunctionArray(self:getId())
--     for i = 1, table.getn(list) do
--         local info = list[i]
--         if info.disableFunctionName == functionName then
--             return info
--         end
--     end

--     return nil
-- end

-- --@region 气血恢复
-- function FightCharacter:setQiRecoverCd(cd)
--     self.__qiRecoverCd = cd
-- end

-- function FightCharacter:getQiRecoverCd()
--     return self.__qiRecoverCd
-- end

-- function FightCharacter:canDoQiRecover()
--     local isBanInfo = self:__getDisableOperationInfo("healthy")
--     if isBanInfo ~= nil then
--         local BuffConf = require("app.FightSystem.Configuration.BuffConf")
--         local effect = BuffConf:getEffect(isBanInfo.effectId)

--         local tip = effect:getActiveEffectUseZhaoTips()

--         return false, tip
--     end

--     if self:getQiRecoverCd() > 0 then
--         return false
--     end

--     local isMeetCondition, tip = self:__rcoverQiAreMet()

--     if isMeetCondition then
--         return false, tip
--     end

--     if self:getAttr("qi") == self:getAttr("qiMax") then
--         return false, TextResManager:getText("1014")
--     end

--     return true
-- end

-- function FightCharacter:__rcoverQiAreMet()
--     local costList = self:__getRecoverCostList()

--     for i, v in ipairs(costList) do
--         local attrName = v.attrName
--         local value = v.value

--         local currValue = self:getAttr(attrName)
--         if currValue < value then
--             return true
--         end
--     end

--     return false
-- end

-- function FightCharacter:__getRecoverCostList()
--     return {
--         {
--             attrName = "neili",
--             value = math.ceil(20 + self:getAttr("neiliMax") / 50)
--         }
--     }
-- end

-- function FightCharacter:__updateQiRecover(ft)
--     self:__updateQiRecoverCd(ft)

--     if self.__output then
--         if self.__qiRecoverCd > 0 then
--             self.__output:updateQiRecoverEnable(false)
--             return
--         end

--         if self:__rcoverQiAreMet() then
--             self.__output:updateQiRecoverEnable(false)
--         else
--             self.__output:updateQiRecoverEnable(true)
--         end
--     end
-- end

-- function FightCharacter:__updateQiRecoverCd(ft)
--     if self.__qiRecoverCd <= 0 then
--         return
--     end
--     local value = self.__qiRecoverCd - ft

--     if value < 0 then
--         value = 0
--     end

--     self:__updateRecoverQiCDView(self.__qiRecoverCd, value, ft)

--     self:setQiRecoverCd(value)
-- end

-- function FightCharacter:applyQiRecover()
--     local canDo, tip = self:canDoQiRecover()

--     if not canDo then
--         if self:isPlayer() and tip ~= nil then
--             self.__character_sys:getFight():popMessage(tip)
--         end
--         return
--     end

--     self.__character_sys:applyRecoverQi(self:getId())

--     if self.__output then
--         self.__output:showOpertionName(BattleConstConf:get("battleAction_healthy_name"))
--     end
-- end

-- function FightCharacter:recoverQi(animName, value)
--     self:setQiRecoverCd(BattleConstConf:get("battleAction_healthy_cd"))

--     local costList = self:__getRecoverCostList()

--     FightUtil:printLog(string.format("角色(%s)释放【恢复】：%s", self:getAttr("name"), value))

--     for i = 1, table.getn(costList) do
--         local info = costList[i]
--         local attrName = info.attrName
--         if attrName == "neili" then
--             self:consumeNeili(info.value)
--         else
--             self:addAttr(attrName, -value)
--         end
--         FightUtil:printLog(string.format(" - 消耗：%s - %s", FightUtil:getCharacterAttrCHName(attrName), info.value))
--     end

--     self:addAttr("qi", value)

--     if self.__output then
--         self.__output:recoverQi(animName, value)
--     end
-- end

-- function FightCharacter:cancelRecoverQi()
--     if self.__output then
--         self.__output:removeOperationName()
--     end
-- end

-- --@endregion

-- function FightCharacter:removeAllPrepOpertion()
--     FightUtil:printLog(self:getAttr("name"), "所有操作被移除")
--     if self.__output then
--         --@desc 界面显示被刷新
--         self.__output:removeAllOperationName()
--     end
-- end

-- --@desc: 手中武器被卸载
-- --@author:Seven
-- --@time:2022-01-17 21:48:57
-- function FightCharacter:beUnmountWeapon(weaponState)
--     local prevWeapon = self:getEquipSys():unmountWeapon()

--     self:__unmountWeapon(prevWeapon)

--     prevWeapon:updateFightState(weaponState)

--     self:__useWeapon(self:getWeapon())

--     self:removeAllPrepOpertion()

--     if self.__output then
--         local actVmInfos = self:getChararcterActiveSkillVm()
--         local viewInfos = self:getCharacterViewInfo()
--         self.__output:changeWeapon(self:getEquipSys():getWeapon())
--         self.__output:setStandAnim(viewInfos.stand_anim)
--         self.__output:setJoinAnim(viewInfos.join_anim)
--         self.__output:setJumpForwardAnim(viewInfos.jumpForwardAnim)
--         self.__output:setJumpBackAnim(viewInfos.jumpbackAnim)
--         self.__output:changeAllActiveSkills(actVmInfos)
--     end
-- end

-- function FightCharacter:addUpSufferDamge(value)
--     if value < 0 then
--         error("FightCharacter:addUpSufferDamge value不可小于0，检查代码")
--     end

--     self:getBuffSystem():comsumeSufferDamge(self:getId(), value)
-- end

-- function FightCharacter:doEffectChangeAttrUpdateInfo(attrName, value)
--     if self.__output then
--         if attrName == "tili" then
--             self.__output:buffUpdateTili(self:getAttr("tili"))
--         else
--             self.__output:buffSetAttr(attrName, value)
--         end
--     end
-- end

-- --@desc 击飞武器
-- function FightCharacter:flyWeapon()
--     if self:getEquipSys():weaponIsEmptyHand() then
--         assert(false, "空手无法打飞、检查代码")
--     end

--     local prevWeapon = self:getEquipSys():unmountWeapon()

--     self:__unmountWeapon(prevWeapon)

--     self:__useWeapon(self:getWeapon())

--     self:removeAllPrepOpertion()
-- end

-- --@desc 打断武器
-- function FightCharacter:blockWeapon()
--     if self:getEquipSys():weaponIsEmptyHand() then
--         assert(false, "空手无法打断、检查代码")
--     end

--     local prevWeapon = self:getEquipSys():unmountWeapon()

--     prevWeapon:setCommence(0)

--     self:__unmountWeapon(prevWeapon)

--     self:__useWeapon(self:getWeapon())

--     self:removeAllPrepOpertion()
-- end

-- function FightCharacter:switchWeapon(switchType, switchConditionLogicalSymbol, switchConditionValue, switchFailTextId)
--     local prevWeapon = self.__equipsSys:getWeapon()

--     local isSuccess, msg = self.__switchWeaponFunc:switchWeapon(switchType, switchConditionLogicalSymbol, switchConditionValue, switchFailTextId)

--     if isSuccess then
--         -- 换武器需要移除换下的武器的相关buff, 并且添加上新武器的相关buff
--         for i, buff in ipairs(prevWeapon:getBuffArray()) do
--             local removeBuffArray = self.__buffSystem:roleRemoveBuff(self:getId(), buff.addBuffID)
--             for _, buff in ipairs(removeBuffArray) do
--                 local removeText = buff:getRemoveText()
--                 if type(removeText) == "string" and removeText ~= "" then
--                     self:printDesces({Desc:create(removeText, {{"$BsN", self:getAttr("name")}})})
--                 end
--             end
--         end

--         self:__useWeapon(self.__equipsSys:getWeapon())

--         self:removeAllPrepOpertion()

--         if self.__output then
--             if self:isPlayer() then
--                 self:PopText(TextResManager:getText("1070"))
--             end
--             local actVmInfos = self:getChararcterActiveSkillVm()
--             local viewInfos = self:getCharacterViewInfo()
--             self.__output:changeWeapon(self:getEquipSys():getWeapon())
--             self.__output:setStandAnim(viewInfos.stand_anim)
--             self.__output:setJoinAnim(viewInfos.join_anim)
--             self.__output:setJumpForwardAnim(viewInfos.jumpForwardAnim)
--             self.__output:setJumpBackAnim(viewInfos.jumpbackAnim)
--             self.__output:changeAllActiveSkills(actVmInfos)
--         end
--     else
--         if self.__output then
--             if self:isPlayer() and msg ~= "" and msg ~= nil then
--                 self:PopText(msg)
--             end
--         end
--     end
-- end

-- --@desc:
-- --@author:Seven
-- --@time:2022-05-11 15:36:32
-- --@return [src.app.FightSystem.FightRole.CharacterEquipment.SwitchWeaponFunc#SwitchWeaponFunc]
-- function FightCharacter:getSwitchWeaponFunc()
--     return self.__switchWeaponFunc
-- end

-- -- 获得携带buff数组
-- function FightCharacter:getCarryBuffArray()
--     local buffs = {}
--     local activeSkills = self:getPrepAcitveSkills()
--     for i, activeSkill in ipairs(activeSkills) do
--         for i, buff in ipairs(activeSkill:getCarryBuffs()) do
--             table.insert(buffs, buff)
--         end
--     end
--     return buffs
-- end

-- local INFLUENCE_ATTACK_HIT_TYPE = FightCommons.INFLUENCE_ATTACK_HIT_TYPE

-- --@desc: 角色攻击影响命中结果
-- --@author:Seven
-- --@time:2022-11-16 14:54:52
-- --@attack_type:
-- --@return: true || false
-- function FightCharacter:beInluenceByAttack(influenceType)
--     if influenceType == INFLUENCE_ATTACK_HIT_TYPE.ATTACKER_BE_DODGE then
--         if self.__buffSystem:dodgeAutoSkillNecessarily(self:getId()) then
--             FightUtil:printLog("角色：", self:getAttr("name"), "攻击必定被闪躲")
--             return true
--         end
--     elseif influenceType == INFLUENCE_ATTACK_HIT_TYPE.ATTACKER_BE_PARRY then
--         if self.__buffSystem:parrayAutoSkillNecessarily(self:getId()) then
--             FightUtil:printLog("角色：", self:getAttr("name"), "攻击必定被格挡")
--             return true
--         end
--     end

--     return false
-- end

-- --@desc: 角色受击影响命中结果
-- --@author:Seven
-- --@time:2022-11-16 14:59:46
-- --@return:
-- function FightCharacter:beInluenceByHit(influenceType)
--     if influenceType == INFLUENCE_ATTACK_HIT_TYPE.TARGET_BAN_DODGE then
--         if self:getBuffSystem():roleIsBanQingGongDodge(self:getId()) then
--             FightUtil:printLog("角色：", self:getAttr("name"), "受击无法闪躲")
--             return true
--         end
--     elseif influenceType == INFLUENCE_ATTACK_HIT_TYPE.TARGET_BAN_PARRY then
--         if self:getBuffSystem():roleIsBanNormalParry(self:getId()) then
--             FightUtil:printLog("角色：", self:getAttr("name"), "受击无法格挡")
--             return true
--         end
--     end
--     return false
-- end

-- function FightCharacter:getFistFootFdamage()
--     local value = 0

--     if not self:weaponIsEmptyHand() then
--         return value
--     end

--     local prep_skill = self:getPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO)
--     if prep_skill then
--         local skillTypes = prep_skill:getSkillTypes()

--         for _, skill_type_id in ipairs(skillTypes) do
--             if BasicSkill.IsAttackType(skill_type_id) then
--                 value = self.__fistFootSystem:getFdamage(skill_type_id)
--                 break
--             end
--         end
--     end

--     return value
-- end

-- function FightCharacter:getFistFootJqdamage()
--     local value = 0

--     if not self:weaponIsEmptyHand() then
--         return value
--     end

--     local prep_skill = self:getPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO)
--     if prep_skill then
--         local skillTypes = prep_skill:getSkillTypes()

--         for _, skill_type_id in ipairs(skillTypes) do
--             if BasicSkill.IsAttackType(skill_type_id) then
--                 value = self.__fistFootSystem:getJqdamage(skill_type_id)
--                 break
--             end
--         end
--     end

--     return value
-- end

-- function FightCharacter:getFistFootJqdamageByType(skillTypeId)
--     return self.__fistFootSystem:getJqdamage(skillTypeId)
-- end

-- function FightCharacter:getFistFootPermanentBuffs()
--     if not self:weaponIsEmptyHand() then
--         return {}
--     end

--     local prep_skill = self:getPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO)
--     if prep_skill then
--         local skillTypes = prep_skill:getSkillTypes()

--         for _, skill_type_id in ipairs(skillTypes) do
--             if BasicSkill.IsAttackType(skill_type_id) then
--                 return self.__fistFootSystem:getPermanentBuffs(skill_type_id)
--             end
--         end
--     end

--     return {}
-- end

-- function FightCharacter:getFistFootBuffLauncherAdder()
--     if not self:weaponIsEmptyHand() then
--         return nil
--     end

--     local prep_skill = self:getPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO)
--     if prep_skill then
--         local skillTypes = prep_skill:getSkillTypes()

--         for _, skill_type_id in ipairs(skillTypes) do
--             if BasicSkill.IsAttackType(skill_type_id) then
--                 return self.__fistFootSystem:getBuffLauncherAdd(skill_type_id)
--             end
--         end
--     end

--     return nil
-- end

-- --@desc: 拳脚分支属性值获取
-- --@author:Seven
-- --@time:2022-12-17 14:40:04
-- --@name: 拳脚分支属性名
-- function FightCharacter:getFistFootAttr(name)
--     return self.__fistFootSystem:getFistFootAttr(name)
-- end

-- return class("FightCharacter", {}, FightCharacter)
0000000000000000
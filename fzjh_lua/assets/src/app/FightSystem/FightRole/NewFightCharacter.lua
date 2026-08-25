--[[
    author:Seven
    time:2022-07-14 11:10:18
    desc: 新的战斗角色类，用于开发替换，替换完代码可删除
]]
local class = require("third.class.NewClass")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local SkillConst = require("app.models.skill.SkillConst")

--@RefType src.app.models.skill.SkillConst#SkillConst.SkillSecondType
local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightCommons = require("app.FightSystem.FightCommons")

local CustomBuffNeeded = require("app.FightSystem.FightBuff.CustomBuffNeeded")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local BasicSkill = require("app.models.skill.BasicSkill.BasicSkill")

--@RefType [src.app.FightSystem.FightRole.CharacterConfigs.CharacterConfig#CharacterConfig]
local CharacterConfig = require("app.FightSystem.FightRole.CharacterConfigs.CharacterConfig")
local SYSTEM_NAME = CharacterConfig.SYSTEM_NAME

--@RefType [src.app.FightSystem.FightRole.CharacterBattleState.CharacterBattleStateSystem#CharacterBattleStateSystem]
local CharacterBattleStateSystem = require("app.FightSystem.FightRole.CharacterBattleState.CharacterBattleStateSystem")
local CHARACTER_BATTLE_STATE = CharacterBattleStateSystem.STATE

local Desc = require("app.FightSystem.FightBuff.Desc")

local FightCharacter = {
    __teamId = nil,
    --@desc 角色物种
    __species = FightCommons.CHARACTER_SPECIES.MALE,
    --@desc 是否玩家所操控的人物
    __isPlayer = false,
    __target = nil,
    __posIndex = 1,
    __pos = {
        x = 0,
        y = 0,
        h = 0
    },
    __isInOriginPos = true,
    --@desc 是否能恢复体力
    __can_recover = true,
    --@desc 主动技能自动释放
    __activeReleaseAI = nil,
    __recordClass = nil,
    __funcSystems = {},
    __funcSystemMap = {}
}

function FightCharacter:create(config)
    local p = FightCharacter.new()
    p:__init(config)
    return p
end

--@desc:
--@author:Seven
--@time:2022-09-14 16:43:00
function FightCharacter:__init(config)
    isImplement(config, require("app.FightSystem.FightRole.CharacterConfigs.DefaultCharacterConfig"))
    --@RefType [src.app.FightSystem.FightRole.CharacterConfigs.CharacterConfig#CharacterConfig]
    local configClass = require("app.FightSystem.FightRole.CharacterConfigs.CharacterConfig"):create(config)

    local systemInfos = configClass:getSystemInfos()

    FightUtil:printLog("角色系统创建：")
    for i = 1, #systemInfos do
        local info = systemInfos[i]
        FightUtil:printLog(" -- ", info.path)

        local systemClass = require(info.path):create(table.unpack(info.args))
        systemClass:setName(info.name)

        self:addFuncSystem(systemClass)
    end

    self.__recordClass = require("app.FightSystem.FightRole.CharacterFightRecord.CharacterRecord"):create(self)
end

function FightCharacter:init()
    FightUtil:printLog("角色系统初始化 ： ")
    self:__walkFuncSystem(
        function(v)
            v:init()
        end
    )
end

function FightCharacter:startFight()
    FightUtil:printLog(self:getAttr("name") .. "开始战斗 ： ")
    self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):updatePrepActiveSkill()
end

function FightCharacter:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
end

function FightCharacter:getFight()
    return self.__fight
end

--@desc: 添加角色功能系统
--@author:Seven
--@time:2022-07-05 16:04:07
--@funcClass: [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
function FightCharacter:addFuncSystem(funcClass)
    table.insert(self.__funcSystems, isImplement(funcClass, require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")))
    funcClass:setCharacter(self)
    if self.__funcSystemMap[funcClass:getName()] ~= nil then
        assert(false, "FightCharacter:addFuncSystem 已存在，请勿重复添加相同系统")
    end

    self.__funcSystemMap[funcClass:getName()] = funcClass
end

--@desc: 遍历角色功能
--@author:Seven
--@time:2022-07-05 16:12:25
--@func: 回调函数
function FightCharacter:__walkFuncSystem(func)
    for i = 1, #self.__funcSystems do
        local v = self.__funcSystems[i]
        func(v)
    end
end

function FightCharacter:getFuncSystem(name)
    local funcClass = self.__funcSystemMap[name]
    if funcClass == nil then
        assert(false, "无法找到该系统 -- " .. tostring(name))
    end

    return funcClass
end

--@desc: 是否存在该系统
--@author:Seven
--@time:2023-03-28 11:05:55
--@name: 系统名称
--@return true:存在 false:不存在
function FightCharacter:hasFuncSystem(name)
    return self.__funcSystemMap[name] ~= nil
end

--@desc:
--@author:Seven
--@time:2022-01-23 22:09:54
--@return [src.app.FightSystem.FightRole.CharacterFightRecord.CharacterRecord#CharacterRecord]
function FightCharacter:getRecordClass()
    return self.__recordClass
end

function FightCharacter:getId()
    return tostring(self:getAttr("id"))
end

function FightCharacter:setTeamId(team_id)
    self.__teamId = team_id
end

function FightCharacter:getTeamId()
    return self.__teamId
end

function FightCharacter:setSpecies(species)
    self.__species = species
end

--@desc: 获取物种
--@author:Seven
--@time:2021-07-08 17:13:04
function FightCharacter:getSpecies()
    return self.__species
end

function FightCharacter:setPosIndex(index)
    self.__posIndex = index
end

function FightCharacter:getPosIndex()
    return self.__posIndex
end

function FightCharacter:getOriginPos()
    local pos = FightCommons.CHARACTER_POSITION[self.__posIndex]
    return {
        x = pos.x,
        y = pos.y,
        h = 0
    }
end

--@desc: 设置角色是否在原位（该属性一般用于判断攻击是否需要跳跃使用）
--@author:Seven
--@time:2023-02-24 11:40:26
--@bool: true|false
--@return: void
function FightCharacter:setIsInOriginPos(bool)
    if type(bool) ~= "boolean" then
        error("FightCharacter:setIsInOriginPos 参数类型错误，必须是boolean类型：" .. tostring(bool))
    end

    self.__isInOriginPos = bool
end

--@desc: 获取角色是否在原位
--@author:Seven
--@time:2023-02-24 11:40:04
--@return: true | false
function FightCharacter:isInOrignPos()
    return self.__isInOriginPos
end

--@desc: 后续可能删除，逻辑层去除具体位置定义
--@author:Seven
--@time:2023-02-24 11:37:13
function FightCharacter:setPosition(x, y, h)
    if type(x) ~= "number" or type(y) ~= "number" or type(h) ~= "number" then
        assert(false, "FightCharacter 位置设置，参数值有非数字：x - " .. type(x) .. " y - " .. type(y) .. " h - " .. type(h))
    end

    self.__pos.x = x
    self.__pos.y = y
    self.__pos.h = h
end

function FightCharacter:getPosition()
    return self.__pos
end

function FightCharacter:setPlayer(bool)
    self.__isPlayer = bool
end

function FightCharacter:isPlayer()
    return self.__isPlayer
end

--@desc: 获取攻击目标
--@author:Seven
--@time:2023-03-16 17:07:38
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function FightCharacter:getTarget()
    return self.__fight:getAttackTarget(self:getId())
end

function FightCharacter:hasTarget()
    -- 只需要判断是否存在战场对象，如果战场对象已获取，则说明目标是存在的。
    if self.__fight == nil then
        return false
    end

    return true
end

--@region 角色战场状态系统
function FightCharacter:canDead()
    if self:getAttr("qi") <= 0 and not self:isDead() then
        return true
    end

    return false
end

--@desc: 杀死角色
--@author:Seven
--@time:2023-03-02 15:28:44
function FightCharacter:killCharacter()
    self:changeCharacterBattleState(CHARACTER_BATTLE_STATE.DEAD)

    self.__fight:charaterDead(self:getId())
end

--@desc: 角色是否死亡
--@author:Seven
--@time:2023-03-02 15:13:52
--@return: true | false
function FightCharacter:isDead()
    if self:getCharacterBattleState() == CHARACTER_BATTLE_STATE.DEAD then
        return true
    end

    return false
end
--@desc: 角色是否逃跑
--@author:Seven
--@time:2023-03-02 19:55:27
--@return:true | false
function FightCharacter:isRunaway()
    if self:getCharacterBattleState() == CHARACTER_BATTLE_STATE.RUNAWAY then
        return true
    end

    return false
end

--@desc: 改变角色战斗状态
--@author:Seven
--@time:2023-03-02 15:15:38
--@state: 战斗状态
function FightCharacter:changeCharacterBattleState(state)
    return self:getFuncSystem(SYSTEM_NAME.CHARACTER_BATTLE_STATE_SYSTEM):changeBattleState(state)
end

--@desc: 获取当前角色战斗状态
--@author:Seven
--@time:2023-03-02 15:17:36
function FightCharacter:getCharacterBattleState()
    return self:getFuncSystem(SYSTEM_NAME.CHARACTER_BATTLE_STATE_SYSTEM):getBattleState()
end

--@desc: 角色是否处于脱离战斗状态
--@author:Seven
--@time:2023-03-02 15:21:42
--@return true | false
function FightCharacter:isOutOfBattleState()
    return self:getFuncSystem(SYSTEM_NAME.CHARACTER_BATTLE_STATE_SYSTEM):isOutOfBattleState()
end
--@endregion

--@region 属性系统
function FightCharacter:addAttr(name, value)
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):addAttr(name, value)
end

function FightCharacter:setAttr(name, value)
    self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):setAttr(name, value)
end

function FightCharacter:getAttr(name)
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):getAttr(name)
end

function FightCharacter:getQiStage()
    local CharacterQiStageConf = require("app.FightSystem.ResourceManager.CharacterQiStageConf")
    return CharacterQiStageConf:getStage(self:getAttr("qi") / self:getAttr("qiLimit") * 100)
end

--@desc: 修正角色属性值上下限
--@author:Seven
--@time:2023-03-03 14:34:56
function FightCharacter:correctAttrLimit()
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):correctAttrLimit()
end
--@endregion

function FightCharacter:getJumpForwardAnimId()
    return self:getAttackSkill():getBattleRunAnim()
end

function FightCharacter:getJumpBackAnimId()
    return self:getAttackSkill():getBattleBackAnim()
end

function FightCharacter:getJoinAnimId()
    local animResId = self:getAttackSkill():getBattleJoinAnim()
    if animResId ~= 0 then
        return animResId
    end
    return nil
end

--@region 受击动画系统

--@desc: 获取受击动画组
--@author:Seven
--@time:2021-07-17 10:31:58
function FightCharacter:getHurtAnimAndSoundMap()
    return self:getFuncSystem(SYSTEM_NAME.HURT_STATE_ANIM_SYSTEM):getHurtAnimAndSoundMap()
end

--@desc: 添加影响角色被击中时相关的受击类型
--@author:Seven
--@time:2023-02-10 15:20:30
--@hurtExpression: 受击类型
--@sortPriority: 优先级
--@return: 受击对象id
function FightCharacter:addHurtExpression(hurtExpression, sortPriority)
    return self:getFuncSystem(SYSTEM_NAME.HURT_STATE_ANIM_SYSTEM):addHurtExpression(hurtExpression, sortPriority)
end

--@desc: 移除受击类型
--@author:Seven
--@time:2023-02-10 15:21:48
--@exprId: 受击类型对象id
function FightCharacter:removeHurtExpression(exprId)
    return self:getFuncSystem(SYSTEM_NAME.HURT_STATE_ANIM_SYSTEM):removeHurtExpression(exprId)
end

--@desc: 获取普通招架动画组
--@author:Seven
--@time:2021-07-17 10:38:24
function FightCharacter:getParryAnimAndSoundMap()
    return self:getFuncSystem(SYSTEM_NAME.HURT_STATE_ANIM_SYSTEM):getParryAnimAndSoundMap()
end

--@desc: 获取闪避动画
--@author:Seven
--@time:2023-02-07 15:20:13
function FightCharacter:getDodgeAnimAndSoundMap()
    return self:getFuncSystem(SYSTEM_NAME.HURT_STATE_ANIM_SYSTEM):getDodgeAnimAndSoundMap()
end
--@endregion

--@region 待机动画系统
--@desc: 获取角色待机动画id
--@author:Seven
--@time:2023-02-10 11:58:15
function FightCharacter:getIdleAnimId()
    return self:getFuncSystem(SYSTEM_NAME.IDLE_STATE_ANIM_SYSTEM):getIdleAnimId()
end

--@desc: 添加待机动画
--@author:Seven
--@time:2023-02-10 12:01:29
--@animStateInfo: [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
--@return: animInfo id
function FightCharacter:addIdleAnimStateInfo(animStateInfo)
    return self:getFuncSystem(SYSTEM_NAME.IDLE_STATE_ANIM_SYSTEM):addIdleAnim(animStateInfo)
end

--@desc: 移除待机动画信息
--@author:Seven
--@time:2023-02-10 12:04:32
--@animInfoId: id 索引
--@return [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
function FightCharacter:removeIdleAnimState(animInfoId)
    return self:getFuncSystem(SYSTEM_NAME.IDLE_STATE_ANIM_SYSTEM):removeIdleAnim(animInfoId)
end
--@endregion

--@region 死亡动画
function FightCharacter:getDeadAnimAndSoundMap()
    local map = {}

    local CharacterDefaultConf = require("app.FightSystem.Configuration.CharacterDefaultConf")

    local HIT_POS = FightCommons.HIT_POS

    for _, hitPos in pairs(HIT_POS) do
        map[hitPos] = {
            {
                hurtAnimName = CharacterDefaultConf:getDeadAnim(self.__species, hitPos),
                hurtSoundId = CharacterDefaultConf:getDieSoundId(self.__species)
            }
        }
    end

    return map
end
--@endregion

--@region 角色脚部动画系统
--@desc: 添加脚部动画
--@author:Seven
--@time:2023-02-10 21:03:46
--@animStateInfo: [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
--@return: 脚部光环对象id
function FightCharacter:addHaloOfFootAnim(animStateInfo)
    return self:getFuncSystem(SYSTEM_NAME.BOTTOM_OF_FOOT_ANIM_SYSTEM):addHaloAnim(animStateInfo)
end

--@desc: 移除脚部光环动画
--@author:Seven
--@time:2023-02-10 21:04:55
--@animStateId: 光环动画对象id
--@return [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
function FightCharacter:removeHaloOfFootAnim(animStateId)
    return self:getFuncSystem(SYSTEM_NAME.BOTTOM_OF_FOOT_ANIM_SYSTEM):removeHaloAnim(animStateId)
end

--@desc: 获取脚部光环动画
--@author:Seven
--@time:2023-02-10 21:06:54
--@return: 动画id，可为空
function FightCharacter:getHaloOfFootAnimId()
    return self:getFuncSystem(SYSTEM_NAME.BOTTOM_OF_FOOT_ANIM_SYSTEM):getHaloAnimId()
end
--@endregion

--@region 头顶文本系统

--@desc: 添加头部文本
--@author:Seven
--@time:2023-02-10 21:30:08
--@textInfo: [src.app.FightSystem.FightRole.AnimSystem.TextStateInfo#TextStateInfo]
--@return: 文本对象id
function FightCharacter:addTopTextInfo(textInfo)
    return self:getFuncSystem(SYSTEM_NAME.TOP_OF_HEAD_TEXT_SYSTEM):addText(textInfo)
end

--@desc: 移除文本
--@author:Seven
--@time:2023-02-10 21:31:14
--@textId: 文本对象id
--@return [src.app.FightSystem.FightRole.AnimSystem.TextStateInfo#TextStateInfo]
function FightCharacter:removeTopTextInfo(textId)
    return self:getFuncSystem(SYSTEM_NAME.TOP_OF_HEAD_TEXT_SYSTEM):removeText(textId)
end

--@desc: 获取当前头部文本
--@author:Seven
--@time:2023-02-10 21:32:05
--@return 头部挂载文本
function FightCharacter:getTextOfTop()
    return self:getFuncSystem(SYSTEM_NAME.TOP_OF_HEAD_TEXT_SYSTEM):getTopText()
end
--@endregion

function FightCharacter:setCanRecover(bool)
    self.__can_recover = bool
end

function FightCharacter:canRecover()
    return self.__can_recover
end

function FightCharacter:getAtk()
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):getAttr("atkBattle")
end

function FightCharacter:getDef()
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):getAttr("defBattle")
end

function FightCharacter:getHitForce()
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):getAttr("hitForceBattle")
end

function FightCharacter:getDodgeForce()
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):getAttr("dodgeForceBattle")
end

function FightCharacter:getParryForce()
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):getAttr("parryForceBattle")
end

function FightCharacter:getDamage()
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):getAttr("damageBattle")
end

function FightCharacter:getPlusPointBattle()
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):getAttr("plusPointBattle")
end

function FightCharacter:getProtect()
    return self:getFuncSystem(SYSTEM_NAME.ATTR_SYSTEM):getAttr("protectBattle")
end

--@region 装备系统
function FightCharacter:useWeapon(weapon)
    self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):useWeapon(weapon)
end

--@desc: 卸载武器
--@author:Seven
--@time:2023-12-01 20:21:39
--@return [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function FightCharacter:unmountCharacterWeapon()
    self:useWeapon(self:getEmptyHandWeapon())
end

--@desc: 获取空手武器
--@author:Seven
--@time:2023-12-01 20:50:40
--@return:
function FightCharacter:getEmptyHandWeapon()
    return self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):getEmptyHandWeapon()
end

--@desc: 通知角色武器已改变
--@author:Seven
--@time:2023-11-15 14:45:11
--@weapon: [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function FightCharacter:weaponChanged(weapon, prevWeapon)
    --@desc 刷新主动技能列表
    self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):refreshActiveSkillPrepList()

    self.__fight:removeCharacterAllOperation(self:getId())

    local prevIsEmptyHand = prevWeapon:getFirstType() == "空手"

    local isEmptyHand = weapon:getFirstType() == "空手"

    if prevIsEmptyHand == isEmptyHand then
        return
    end

    if prevIsEmptyHand then
        self:disableFistFootCarryBuff()
        self:disableFistFootCarryBuffAdder()
    elseif isEmptyHand then
        self:enableFistFootCarryBuff()
        self:enableFistFootCarryBuffAdder()
    end
end

--@desc: 设置当前使用的武器
--@author:Seven
--@time:2023-04-03 14:55:22
--@weapon: [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
--@return: nil
function FightCharacter:setWeapon(weapon)
    return self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):setWeapon(weapon)
end

--@desc: 获取当前使用的武器
--@author:Seven
--@time:2021-05-29 18:09:25
--@return [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function FightCharacter:getWeapon()
    return self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):getWeapon()
end

--@desc: 把当前角色使用武器携带buff添加至角色
--@author:Seven
--@time:2023-10-17 21:25:07
function FightCharacter:addCurrentWeaponCarryBuff()
    local wepaon = self:getWeapon()
    self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):addWeaponCarryBuff(wepaon)
end

--@desc: 删除当前角色使用武器携带的buff
--@author:Seven
--@time:2023-10-17 21:25:30
function FightCharacter:removeCurrentWeaponCarryBuff()
    local wepaon = self:getWeapon()
    self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):removeWeaponCarryBuff(wepaon)
end

--@desc: 把当前角色使用武器携带buff添加器添加至角色
--@author:Seven
--@time:2023-10-17 21:26:07
function FightCharacter:addCurrentWeaponCarryBuffAdder()
    local weapon = self:getWeapon()

    self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):addWeaponCarryBuffAdderGroup(weapon)
end

--@desc: 删除当前角色使用武器携带的buff添加器
--@author:Seven
--@time:2023-10-17 21:28:35
function FightCharacter:removeCurrentWeaponCarryBuffAdder()
    local weapon = self:getWeapon()

    self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):removeWeaponCarryBuffAdderGroup(weapon)
end

--@desc: 设置空手武器
--@author:Seven
--@time:2023-02-21 10:47:35
--@weapon: [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function FightCharacter:setEmptyHandWeapon(weapon)
    if weapon ~= nil then
        weapon:setCharacter(self)
    end
    self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):setEmptyHandWeapon(weapon)
end

--@desc: 设置准备的武器
--@author:Seven
--@time:2023-03-01 15:43:14
--@weapon:[src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function FightCharacter:setEquipWeapon(weapon)
    if weapon ~= nil then
        weapon:setCharacter(self)
    end
    self:setEquipment(FightCommons.EQUIP_PART.WEAPON, weapon)
end

--@desc: 设置备用武器
--@author:Seven
--@time:2023-03-01 15:43:44
--@weapon:[src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function FightCharacter:setStandbyWeapon(weapon)
    if weapon ~= nil then
        weapon:setCharacter(self)
    end
    self:setStandbyEquipment(FightCommons.EQUIP_PART.WEAPON, weapon)
end

--@desc: 获取备用武器
--@author:Seven
--@time:2022-01-19 21:23:03
--@return [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function FightCharacter:getStandbyWeapon()
    return self:getStandbyEquipment(FightCommons.EQUIP_PART.WEAPON)
end

--[[
    @desc:判断是否为空手
    author:tangjian
    time:2021-07-30 14:37:48
    @return: boolean
]]
function FightCharacter:weaponIsEmptyHand()
    return self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):weaponIsEmptyHand()
end

--@desc: 备用武器是否为空手
--@author:Seven
--@time:2023-03-01 15:45:06
--@return: true|false
function FightCharacter:standbyWeaponIsEmptyHand()
    return self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):standbyWeaponIsEmptyHand()
end

--@desc: 设置装备
--@author:Seven
--@time:2023-03-01 15:45:24
--@equipPart:装备位置
function FightCharacter:setEquipment(equipPart, equipment)
    return self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):setEquipment(equipPart, equipment)
end

--@desc: 获取装备
--@author:Seven
--@time:2023-03-01 15:46:27
function FightCharacter:getEquipment(equipPart)
    return self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):getEquipment(equipPart)
end

--@desc: 设置备用装备
--@author:Seven
--@time:2023-03-01 15:46:39
function FightCharacter:setStandbyEquipment(equipPart, equipment)
    return self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):setStandbyEquipment(equipPart, equipment)
end

--@desc: 获取装备
--@author:Seven
--@time:2023-03-01 15:48:27
function FightCharacter:getStandbyEquipment(equipPart)
    return self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):getStandbyEquipment(equipPart)
end

--@desc: 角色装备防护力
--@author:Seven
--@time:2021-06-29 21:32:17
function FightCharacter:getEquipTotalProtect()
    return self:getFuncSystem(SYSTEM_NAME.EQUIP_SYSTEM):getEquipTotalProtect()
end

--@desc: 打断武器
--@author:Seven
--@time:2023-02-17 16:08:33
function FightCharacter:blockWeapon()
    FightUtil:printLog(self:getAttr("name") .. "武器被打断")
    local currentWeapon = self:getWeapon()
    if currentWeapon:getFirstType() == "空手" then
        return
    end

    currentWeapon:setCommence(0)

    self:unmountCharacterWeapon()
end

--@desc: 打飞武器
--@author:Seven
--@time:2023-02-17 16:09:02
function FightCharacter:flyWeapon()
    FightUtil:printLog(self:getAttr("name") .. "武器被打飞")
    self:unmountCharacterWeapon()
end

--@endregion

--@region 易武功能
--@desc: 设置易武功能开关
--@author:Seven
--@time:2023-03-01 16:18:49
--@bool: true | false
function FightCharacter:setChangeWeaponFuncIsOpen(bool)
    return self:getFuncSystem(SYSTEM_NAME.CHANGE_WEAPON_FUNC):setChangeStandByWeaponOpen(bool)
end

--@desc: 检查是否可以执行易武操作
--@author:Seven
--@time:2023-03-01 16:27:41
--@return: true | false , failMsg
function FightCharacter:checkCanDoChangeWeaponFunc()
    return self:getFuncSystem(SYSTEM_NAME.CHANGE_WEAPON_FUNC):checkCanDoChangeWeapon()
end

--@desc: 获取易武功能是否开启
--@author:Seven
--@time:2023-03-01 16:18:22
--@return: true  | false
function FightCharacter:isChangeWeaponFuncOpen()
    return self:getFuncSystem(SYSTEM_NAME.CHANGE_WEAPON_FUNC):getChangeWeaponIsOpen()
end

--@desc: 执行易武
--@author:Seven
--@time:2023-03-01 16:16:09
function FightCharacter:doChangeWeaponFunc()
    return self:getFuncSystem(SYSTEM_NAME.CHANGE_WEAPON_FUNC):doChangeWeaponFunc()
end
--@endregion

--@region 逃跑功能
--@desc: 检查是否可执行逃跑操作
--@author:Seven
--@time:2023-03-02 15:57:12
function FightCharacter:checkCanDoRunawayFunc()
    return self:getFuncSystem(SYSTEM_NAME.RUNAWAY_FUNC):checkCanDoRunawayFunc()
end

--@desc: 执行逃跑
--@author:Seven
--@time:2023-03-02 15:57:02
function FightCharacter:doRunawayFunc()
    return self:getFuncSystem(SYSTEM_NAME.RUNAWAY_FUNC):doRunaway()
end

--@author:Seven
--@time:2023-11-06 20:15:39
--@return [src.app.FightSystem.FightRole.CharacterRunaway.Runaway#Runaway]
function FightCharacter:getRunaway()
    return self:getFuncSystem(SYSTEM_NAME.RUNAWAY_FUNC):getRunaway()
end

function FightCharacter:isRunawayOpen()
    return self:getFuncSystem(SYSTEM_NAME.RUNAWAY_FUNC):isOpen()
end

function FightCharacter:setRunawayOpen(bool)
    return self:getFuncSystem(SYSTEM_NAME.RUNAWAY_FUNC):setIsOpen(bool)
end
--@endregion

--@desc: 外部角色武学原始数据(个别系统需要获取角色未在战斗中使用的技能数据，因此此处会储存角色原始存档中的所有技能数据)
--@author:Seven
--@time:2021-07-16 11:53:26
--@skills: 外部角色技能信息
function FightCharacter:setRawSkillMap(skillMap)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):setRawSkillMap(skillMap)
end

--@desc: 获取已学技能的原始数据
--@author:Seven
--@time:2021-07-16 11:41:33
--@skill_id: 技能id
function FightCharacter:getSkillRawData(skill_id)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getSkillFormRawData(skill_id)
end

function FightCharacter:getSkillLevel(skillId)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getSkillLevel(skillId)
end

--@desc: 当前使用的攻击武学类型
--@author:Seven
--@time:2021-05-28 11:20:49
function FightCharacter:getAttackSkillType()
    return tostring(self:getWeapon():getAutoChooseSkill())
end

--@desc: 当前攻击基本武学
--@author:Seven
--@time:2021-06-29 17:38:07
function FightCharacter:getBaseAttackSkill()
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getBaseAttackSkill()
end

--@desc: 获取当前准备武学（需武器配套）
--@author:Seven
--@time:2021-07-08 22:14:59
function FightCharacter:getPrepAttackSkill()
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getPrepAttackSkill()
end

--@desc: 获取当前攻击使用的武学
--@author:Seven
--@time:2021-05-31 10:35:48
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function FightCharacter:getAttackSkill()
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getAttackSkill()
end

--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function FightCharacter:getDodgeSkill()
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getDodgeSkill()
end

--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function FightCharacter:getParrySkill()
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getParrySkill()
end

function FightCharacter:getNeiGongSkill()
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getNeiGongSkill()
end

function FightCharacter:addPrepSkill(skillSecType, skill)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):prepSkill(skillSecType, skill)
end

function FightCharacter:getPrepSkills()
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getPrepSkillMap()
end

--@desc: 添加知识类武学
--@author:Seven
--@time:2026-05-19 20:16:19
--@skillId: 技能id
--@knowledgeSkill:[src.app.FightSystem.FightSkill.BasicFightKnowledgeSkill#BasicFightKnowledgeSkill]
function FightCharacter:addKnowledgeSkill(skillId, knowledgeSkill)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):addKnowledgeSkill(skillId, knowledgeSkill)
end

--@desc: 获取知识武学 , 可为空
--@author:Seven
--@time:2026-05-19 00:00:00
--@skillId: 武学ID
--@return [src.app.FightSystem.FightSkill.BasicFightKnowledgeSkill#BasicFightKnowledgeSkill]
function FightCharacter:getKnowledgeSkill(skillId)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getKnowledgeSkill(skillId)
end

--@desc: 获取准备技能
--@author:Seven
--@time:2021-06-29 19:01:12
--@skillSecType: 技能二类型
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function FightCharacter:getPrepSkill(skillSecType)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getPrepSkill(skillSecType)
end

--@desc: 添加基本武学
--@author:Seven
--@time:2021-06-28 15:06:18
function FightCharacter:addBaseSkill(skillSecType, baseSkill)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):addBaseSkill(skillSecType, baseSkill)
end

--@desc: 获取基本武学类型
--@author:Seven
--@time:2021-06-28 15:02:11
--@skillSecType: 武学第二类型
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function FightCharacter:getBaseSkill(skillSecType)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getBaseSkill(skillSecType)
end

--@desc: 添加主动招式
--@author:Seven
--@time:2021-06-18 11:53:55
--@activeSkill: [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function FightCharacter:addActiveSkill(activeSkill)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):addActiveSkill(activeSkill)
end

--@desc: 设置准备主动技能配置
--@author:Seven
--@time:2023-02-13 18:18:37
--@skillSecType: 武学准备类型（武学二类型）
--@configTable: 配置信息
function FightCharacter:setPrepActiveSkillConfig(skillSecType, configTable)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):setPrepActiveSkillConfig(skillSecType, configTable)
end

--@desc: 获取准备技能配置
--@author:Seven
--@time:2023-02-13 18:18:53
--@skillSecType: 武学准备类型（武学二类型）
function FightCharacter:getPrepActiveSkillConfig(skillSecType)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getPrepActiveSkillConfig(skillSecType)
end

--@desc: 添加可使用的主动招式
--@author:Seven
--@time:2021-06-18 11:58:09
--@skillId: 主动技能ID
function FightCharacter:addPrepActiveSkill(act_id)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):addPrepActiveSkill(act_id)
end

--@desc: 获取已准备的主动技能列表
--@author:Seven
--@time:2023-03-16 16:42:36
--@return: []
function FightCharacter:getPrepAcitveSkills()
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getPrepAcitveSkills()
end

--@desc: 遍历准备技能id
--@author:Seven
--@time:2023-04-03 19:41:09
--@func: 回调方法
function FightCharacter:walkPrepActiveSkillIdList(func)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):walkPrepActiveSkillIds(func)
end

--@desc: 获取主动技能列表
--@author:Seven
--@time:2023-03-16 16:44:00
--@return:[]
function FightCharacter:getActiveSkills()
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getActiveSkills()
end

--@desc: 获取主动招式
--@author:Seven
--@time:2021-06-18 12:08:07
--@act_id: 主动招式ID
--@return [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function FightCharacter:getActiveSkill(act_id)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getActiveSkill(act_id)
end

--@desc: 查看是否拥有主动技能id
--@author:Seven
--@time:2023-02-21 15:29:49
--@act_id: 主动技能id
function FightCharacter:hasActiveSkill(act_id)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):hasActiveSkill(act_id)
end

--@desc: 是否准备的主动技能
--@author:Seven
--@time:2023-02-23 16:02:26
--@act_id: 主动技能 id
function FightCharacter:isPrepActiveSkill(act_id)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):isPrepActiveSkill(act_id)
end

--@desc: 卸载准备的主动技能
--@author:Seven
--@time:2023-04-03 18:15:04
--@index: 准备的位置
--@return activeSkillId
function FightCharacter:unmountPrepActiveSkill(index)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):unmountPrepActiveSkill(index)
end

--@desc: 准备主动技能
--@author:Seven
--@time:2023-04-03 15:32:45
--@posIndex: 准备位置
--@act_id: 主动技能id
function FightCharacter:prepActiveSkill(posIndex, act_id)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):prepActiveSkill(posIndex, act_id)
end

--@desc: 给角色添加主动技能携带buff
--@author:Seven
--@time:2023-10-17 19:59:38
function FightCharacter:addActiveSkillCarryBuff(activeSkill)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):addActiveCarryBuff(activeSkill)
end

--@desc: 移除主动技能携带buff
--@author:Seven
--@time:2023-10-17 20:02:50
--@activeSkill: [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function FightCharacter:removeActiveSkillCarryBuff(activeSkill)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):removeActiveCarryBuff(activeSkill)
end

--@desc: 添加主动技能携带进场添加器
--@author:Seven
--@time:2023-10-17 20:30:19
--@activeSkill: [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function FightCharacter:addActiveSkillCarryEnterBuffAdder(activeSkill)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):addEnterBuffAdderGroup(activeSkill)
end

--@desc: 移除主动技能携带进场添加器
--@author:Seven
--@time:2023-10-17 20:31:09
--@activeSkill: [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function FightCharacter:removeActiveSkillCarryEnterBuffAdder(activeSkill)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):removeEnterBuffAdderGroup(activeSkill)
end

--@desc: 根据位置索引获取准备的主动技能(可为空)
--@author:Seven
--@time:2023-04-03 15:40:40
--@posIndex: 位置索引
--@return [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function FightCharacter:getPrepActiveSkillByPosIndex(posIndex)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):getPrepActiveSkillByPosIndex(posIndex)
end

--@desc: 填加禁止被动技能使用的值
--@author:Seven
--@time:2023-03-16 16:26:42
--@tip: 提示
--@return: 索引id
function FightCharacter:addBanAutoAttack(tips)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):addBanAutoAttack(tips)
end

--@desc: 移除禁止被动技能功能
--@author:Seven
--@time:2023-03-16 18:30:15
--@index: 索引
function FightCharacter:removeBanAutoAttack(index)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):removeBanAutoAttack(index)
end

--@desc: 角色是否被禁止使用被动技能
--@author:Seven
--@time:2023-03-16 16:28:55
--@return true | false
function FightCharacter:autoAttackIsBan()
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):isBanAttackByType("auto")
end

--@desc: 添加禁止主动技能使用的值
--@author:Seven
--@time:2023-03-16 16:26:42
--@tips: 提示
--@return: 索引id
function FightCharacter:addBanActiveAttack(banType, tips)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):addBanActiveAttack(banType, tips)
end

--@desc: 删除禁止主动技能信息
--@author:Seven
--@time:2023-03-16 18:30:45
--@activeType: 主动技能类型
--@index: 索引
function FightCharacter:removeBanActiveAttack(activeType, index)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):removeBanActiveAttack(activeType, index)
end

--@desc: 主动技能是否禁止释放
--@author:Seven
--@time:2023-03-16 16:41:43
--@activeType: 主动技能类型
function FightCharacter:activeSkillIsBan(activeType)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_SYSTEM):isBanAttackByType("active", activeType)
end

--@region 拳脚系统
--@desc: 添加拳脚分支
--@author:Seven
--@time:2023-02-07 14:12:15
--@branch: [src.app.FightSystem.FightRole.FistFoot.FightFistFootBranch#FightFistFootBranch]
function FightCharacter:addFistFootBranch(branch)
    return self:getFuncSystem(SYSTEM_NAME.FISTFOOT_SYSTEM):addBranch(branch)
end

--@desc: 获取拳脚系统相关属性
--@author:Seven
--@time:2023-02-07 14:13:48
--@name: 拳脚系统属性名
function FightCharacter:getFistFootAttr(name)
    return self:getFuncSystem(SYSTEM_NAME.FISTFOOT_SYSTEM):getFistFootAttr(name)
end

--@desc: 获取相关分支的fdamage
--@author:Seven
--@time:2023-02-07 14:14:50
--@b_type: 分支类型
function FightCharacter:getFdamage(b_type)
    return self:getFuncSystem(SYSTEM_NAME.FISTFOOT_SYSTEM):getFdamage(b_type)
end

--@desc: 获取相关分支的Jqdamage
--@author:Seven
--@time:2023-02-07 14:14:50
--@b_type: 分支类型
function FightCharacter:getJqdamage(b_type)
    return self:getFuncSystem(SYSTEM_NAME.FISTFOOT_SYSTEM):getJqdamage(b_type)
end

--@desc: 拳脚武炼值
--@author:Seven
--@time:2023-02-09 16:47:00
function FightCharacter:getFistFootFdamage()
    local value = 0

    if not self:weaponIsEmptyHand() then
        return value
    end

    local prep_skill = self:getPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO)
    if prep_skill then
        local skillTypes = prep_skill:getSkillTypes()

        for _, skill_type_id in ipairs(skillTypes) do
            if BasicSkill.IsAttackType(skill_type_id) then
                value = self:getFuncSystem(SYSTEM_NAME.FISTFOOT_SYSTEM):getFdamage(skill_type_id)
                break
            end
        end
    end

    return value
end

--@desc: 拳脚系统谙技值
--@author:Seven
--@time:2023-02-09 16:49:12
function FightCharacter:getFistFootJqdamage()
    local value = 0

    if not self:weaponIsEmptyHand() then
        return value
    end

    local prep_skill = self:getPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO)
    if prep_skill then
        local skillTypes = prep_skill:getSkillTypes()

        for _, skill_type_id in ipairs(skillTypes) do
            if BasicSkill.IsAttackType(skill_type_id) then
                value = self:getFuncSystem(SYSTEM_NAME.FISTFOOT_SYSTEM):getJqdamage(skill_type_id)
                break
            end
        end
    end

    return value
end

function FightCharacter:enableFistFootCarryBuff()
    return self:getFuncSystem(SYSTEM_NAME.FISTFOOT_SYSTEM):enableCarryBuff()
end

function FightCharacter:disableFistFootCarryBuff()
    return self:getFuncSystem(SYSTEM_NAME.FISTFOOT_SYSTEM):disableCarryBuff()
end

function FightCharacter:enableFistFootCarryBuffAdder()
    return self:getFuncSystem(SYSTEM_NAME.FISTFOOT_SYSTEM):enableCarryBuffAdder()
end

function FightCharacter:disableFistFootCarryBuffAdder()
    return self:getFuncSystem(SYSTEM_NAME.FISTFOOT_SYSTEM):disableCarryBuffAdder()
end

--@endregion

--@desc: 消耗体力
--@author:Seven
--@time:2021-05-26 15:29:02
--@value: 消耗的值
function FightCharacter:consumeTili(value)
    if value < 0 then
        assert(false, "消耗体力值不可为负数")
    end

    local n_tili = self:getAttr("tili")

    local consume_tili = value
    if n_tili < value then
        consume_tili = n_tili
    end

    self:setAttr("tili", n_tili - consume_tili)

    local CharacterCostTiliViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.CharacterCostTiliViewEvent")

    local event = CharacterCostTiliViewEvent:create(self:getId(), self:getAttr("tili"), self:getAttr("tiliMax"), value)

    self.__fight:notifyVeiwEvent(event)

    FightUtil:printLog(" 【", self:getAttr("name"), "】 计算消耗体力 - ", value, "，实际消耗体力 - ", consume_tili, ", 剩余体力 - ", self:getAttr("tili"))

    return consume_tili
end

function FightCharacter:consumeNeili(value)
    if value < 0 then
        assert(false, "FightCharacter:consumeNeili 消耗内力值不可为负数")
    end

    local n_neili = self:getAttr("neili")

    local consume_neili = value

    if n_neili < value then
        consume_neili = n_neili
    end

    self:setAttr("neili", n_neili - consume_neili)

    local CharacterCostNeiliViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.CharacterCostNeiliViewEvent")

    local event = CharacterCostNeiliViewEvent:create(self:getId(), self:getAttr("neili"), self:getAttr("neiliMax"), value)

    self.__fight:notifyVeiwEvent(event)

    return consume_neili
end

function FightCharacter:update(ft)
    self:__walkFuncSystem(
        function(system)
            system:update(ft)
        end
    )
end

--@endregion

--@region 门派相关
function FightCharacter:setFamilyID(familyId)
    self.__familyId = familyId
end

function FightCharacter:getFamilyId()
    return self.__familyId
end
--@endregion

--@region 护盾系统

--@desc:消耗护盾值，逐个护盾消耗，直到消耗完毕，返回被消耗的护盾数组
--@author:Seven
--@time:2023-02-08 14:30:01
--@value: 消耗的护盾值
--@return: 返回被完全消耗的护盾数组
function FightCharacter:costQiShieldValue(value)
    if value < 0 then
        error("FightCharacter:costShieldValue 参数不可小0 ： " .. tostring(value))
    end
    FightUtil:printLog(self:getAttr("name"), "消耗护盾值:" .. value)
    return self:getFuncSystem(SYSTEM_NAME.SHIELD_SYSTEM):costQiShieldValue(value)
end

--@desc: 获取当前气血护盾值
--@author:Seven
--@time:2023-02-08 14:32:07
--@return 气血护盾总值
function FightCharacter:getQiShieldValue()
    return self:getFuncSystem(SYSTEM_NAME.SHIELD_SYSTEM):getTotalQiShieldValue()
end

--@desc: 获取当前气血护盾动画id
--@author:Seven
--@time:2023-02-10 20:32:50
--@return: 护盾动画id
function FightCharacter:getQiShieldAnimId()
    return self:getFuncSystem(SYSTEM_NAME.SHIELD_SYSTEM):getCurrQiShieldAnimId()
end

--@desc: 添加护盾
--@author:Seven
--@time:2023-02-08 14:33:15
--@shield: [src.app.FightSystem.FightRole.CharacterShield.BasicShield#BasicShield]
--@return 护盾id
function FightCharacter:addQiShield(shield)
    return self:getFuncSystem(SYSTEM_NAME.SHIELD_SYSTEM):addQiShield(shield)
end

function FightCharacter:removeQiShield(shieldId)
    return self:getFuncSystem(SYSTEM_NAME.SHIELD_SYSTEM):removeQiShield(shieldId)
end

function FightCharacter:getQiShield(shieldId)
    return self:getFuncSystem(SYSTEM_NAME.SHIELD_SYSTEM):getQiShield(shieldId)
end
--@endregion

--@region 图标系统

--@desc: 添加图标
--@author:Seven
--@time:2023-02-11 16:08:32
--@icon: [src.app.FightSystem.FightRole.IconSystem.BasicIcon#BasicIcon]
--@return: 图标id
function FightCharacter:addIcon(icon)
    return self:getFuncSystem(SYSTEM_NAME.ICON_SYSTEM):addIcon(icon)
end

--@desc: 删除图标
--@author:Seven
--@time:2023-02-11 16:08:54
--@id: 图标id
--@return [src.app.FightSystem.FightRole.IconSystem.BasicIcon#BasicIcon]
function FightCharacter:removeIcon(id)
    return self:getFuncSystem(SYSTEM_NAME.ICON_SYSTEM):removeIcon(id)
end

--@desc: 获取图标对象
--@author:Seven
--@time:2023-02-11 16:09:26
--@id: 图标id
--@return [src.app.FightSystem.FightRole.IconSystem.BasicIcon#BasicIcon]
function FightCharacter:getIcon(id)
    return self:getFuncSystem(SYSTEM_NAME.ICON_SYSTEM):getIcon(id)
end

--@desc: 获取全部图标
--@author:Seven
--@time:2023-02-11 16:10:10
--@return: 图标数组
function FightCharacter:getIcons()
    return self:getFuncSystem(SYSTEM_NAME.ICON_SYSTEM):getIcons()
end
--@endregion

--@region buff系统

--@desc: 遍历当前角色所有buff
--@author:Seven
--@time:2023-03-20 21:02:49
--@func: 回调函数
function FightCharacter:walkAllBuff(func)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):walkAllBuff(func)
end

--@desc: 删除移除buff
--@author:Seven
--@time:2023-12-05 10:36:48
function FightCharacter:tryRemoveBuffs()
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):tryRemoveBuffs()
end

--@desc: 获取buff系统属性
--@author:Seven
--@time:2023-03-15 20:54:27
--@name: buff系统属性名
--@return: value
function FightCharacter:getBuffSystemAttr(name)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getBuffSystemAttr(name)
end

--@desc: 加入添加器
--@author:Seven
--@time:2023-03-10 18:35:10
--@return 添加后buff添加器组在角色身上的唯一标识
function FightCharacter:addBuffAdderGroup(buffAdderGroup)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):addBuffAdderGroup(buffAdderGroup)
end

--@desc: 移除添加器组
--@author:Seven
--@time:2023-03-11 14:35:56
--@indexId: 添加器组唯一索引id
--@return [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup#AFightCharacterBuffAdderGroup]
function FightCharacter:removeBuffAdderGroup(index)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):removeBuffAdderGroup(index)
end

--@desc: 根据触发时机获取添加器组列表
--@author:Seven
--@time:2023-10-08 14:34:17
--@addTriggerType:
--@return: array [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup#AFightCharacterBuffAdderGroup]
function FightCharacter:getAdderGroupByAdderTriggerType(addTriggerType)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getAdderGroupByAdderTriggerType(addTriggerType)
end

--@desc: 根据添加节点生成待添加的buff列表
--@author:Seven
--@time:2023-10-08 12:04:37
--@return: array {buff = [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicCharacterBuff#BasicCharacterBuff], cid = number}
function FightCharacter:popPrepAddBuffArrayByAddNode(addNode)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):popPrepAddBuffArrayByAddNode(addNode)
end

--@desc: 添加buff
--@author:Seven
--@time:2023-03-10 18:37:36
--@buff: 添加buff
--@return: buff index id
function FightCharacter:addCharacterBuff(buff)
    local index = self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):addBuff(buff)

    local addDesc = buff:getAddBuffDesc()

    if addDesc ~= nil then
        self.__fight:recordAddBuffDesc(addDesc)
    end

    return index
end

--@desc: 通过buff id 获取buff列表
--@author:Seven
--@time:2023-10-09 21:04:05
--@buffid: buff id
--@return: array
function FightCharacter:getBuffByBuffId(buffid)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getBuffByBuffId(buffid)
end

--@desc: 获取BuffGroup对象，可能为空
--@author:Seven
--@time:2023-12-03 16:26:10
--@buffId: buffId
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuffGroup#IFightCharacterBuffGroup]
function FightCharacter:getBuffGroupByBuffId(buffId)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getBuffGroup(buffId)
end

--@desc: 获取buff迭代器
--@author:Seven
--@time:2023-12-03 16:28:36
function FightCharacter:getBuffGroupIterator()
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getBuffGroupIterator()
end

--@desc: 根据buff id 获取buff当前最大层数
--@author:Seven
--@time:2023-10-08 20:18:52
--@return buff层数上限，如果当前没有buff，返回0
function FightCharacter:getBuffMaxLayerCount(buffid)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getBuffMaxLayerCount(buffid)
end

--@desc: 设置buff层数的最大上限
--@author:Seven
--@time:2023-10-08 20:21:30
--@buffid: buff id
function FightCharacter:setBuffMaxLayerCount(buffid, maxLayerCount)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):setBuffMaxLayerCount(buffid, maxLayerCount)
end

--@desc: 获取角色buffid层数
--@author:Seven
--@time:2023-03-09 14:27:39
--@buffId: buff id
--@return: buff 层数 ，没有就是0
function FightCharacter:getBuffLayerCountByBuffId(buffId)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getBuffLayerCountByBuffId(buffId)
end

--@desc: 生效buff效果
--@author:Seven
--@time:2023-10-17 16:13:20
--@effectNode: [src.app.FightSystem.FightBuff.Constants#Constants.BUFF_MAKE_EFFECT_ON_NODE_TYPE]
--@args: 生效相关参数
function FightCharacter:makeBuffEffectOn(effectNode, ...)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):makeEffectOn(effectNode, ...)
end

--@desc: 触发现有角色buff存活次数减少节点
--@author:Seven
--@time:2023-03-15 18:12:36
--@triggerNodeType: 触发节点
--@args: 根据类型传参
function FightCharacter:triggerReduceBuffLives(triggerNodeType, ...)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):triggerReduceBuffLives(triggerNodeType, ...)
end

--@desc:
--@author:Seven
--@time:2023-03-21 12:05:57
--@buffIndexid:
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function FightCharacter:removeCharacterBuff(buffIndexid)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
    local buff = self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):removeBuffByIndex(buffIndexid)

    if buff then
        local removeDesc = buff:getDeleteBuffDesc()

        if removeDesc ~= nil then
            self.__fight:recordDeleteDesc(removeDesc)
        end
    end

    return buff
end

--@desc: 角色是否拥有buff
--@author:Seven
--@time:2023-03-08 16:20:38
--@buffid: buff id
function FightCharacter:hasCharacterBuffbyId(buffid)
    return self:getBuffLayerCountByBuffId(buffid) > 0
end

--@desc: 角色是否拥有buff
--@author:Seven
--@time:2023-03-08 16:23:13
--@buffClass: buff class
function FightCharacter:hasCharacterBuffByClass(buffClass)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):hasCharacterBuffByClass(buffClass)
end

--@desc:获得角色属性加法加成
--@author:Seven
--@time:2023-03-15 16:51:44
--@attrName: 属性名
function FightCharacter:getBuffAddAttr(attrName)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getAddAttr(attrName)
end

--@desc: 加减角色属性加法加成
--@author:Seven
--@time:2023-03-16 12:12:22
--@attrName: 属性名
--@name: 加减值
function FightCharacter:addBuffAddAttr(attrName, value)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):addBuffAddAttr(attrName, value)
end

--@desc: 获得属性乘法加成
--@author:Seven
--@time:2023-03-15 16:51:52
--@attrName: 属性名
function FightCharacter:getBuffMulAttr(attrName)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getMulAttr(attrName)
end

--@desc: 加减角色属性乘法法加成
--@author:Seven
--@time:2023-03-16 12:12:22
--@attrName: 属性名
--@name: 加减值
function FightCharacter:addBuffMulAttr(attrName, value)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):addBuffMulAttr(attrName, value)
end

--@desc:获得武器属性加法加成
--@author:Seven
--@time:2025-09-06
--@attrName: 属性名
function FightCharacter:getBuffWeaponAddAttr(attrName)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getWeaponAddAttr(attrName)
end

--@desc: 加减武器属性加法加成
--@author:Seven
--@time:2025-09-06
--@attrName: 属性名
--@name: 加减值
function FightCharacter:addBuffWeaponAddAttr(attrName, value)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):addBuffWeaponAddAttr(attrName, value)
end

--@desc: 获得武器属性乘法加成
--@author:Seven
--@time:2025-09-06
--@attrName: 属性名
function FightCharacter:getBuffWeaponMulAttr(attrName)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getWeaponMulAttr(attrName)
end

--@desc: 加减武器属性乘法加成
--@author:Seven
--@time:2025-09-06
--@attrName: 属性名
--@name: 加减值
function FightCharacter:addBuffWeaponMulAttr(attrName, value)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):addBuffWeaponMulAttr(attrName, value)
end

--@desc: 添加buff带来的某属性值，该类值获取时会取最大值
--@author:Seven
--@time:2023-03-23 14:11:42
--@attrName: 属性名
--@value: 值
--@effectId: 效果id
--@return: only id
function FightCharacter:addBuffMaxValue(attrName, value, effectId)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):addMaxValue(attrName, value, effectId)
end

--@desc: 获取该类值中的最大值
--@author:Seven
--@time:2023-03-23 14:25:44
--@attrName: 属性名
--@return: 该类属性值得最大值
function FightCharacter:getBuffMaxValue(attrName)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getMaxValue(attrName)
end

--@desc: 删除buff添加的最大值
--@author:Seven
--@time:2023-03-23 14:27:11
--@attrName: 属性名
--@id: 该值在添加时返回的id
function FightCharacter:removeBuffMaxValue(attrName, id)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):removeMaxAttr(attrName, id)
end

--@desc: 添加buff带来的某属性值，该类值获取时会取最小值
--@author:Seven
--@time:2025-11-12
--@attrName: 属性名
--@value: 值
--@effectId: 效果id
--@return: only id
function FightCharacter:addBuffMinValue(attrName, value, effectId)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):addMinValue(attrName, value, effectId)
end

--@desc: 获取该类值中的最小值
--@author:Seven
--@time:2025-11-12
--@attrName: 属性名
--@defaultValue: 默认值
--@return: 该类属性值的最小值
function FightCharacter:getBuffMinValue(attrName, defaultValue)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):getMinValue(attrName, defaultValue)
end

--@desc: 删除buff添加的最小值
--@author:Seven
--@time:2025-11-12
--@attrName: 属性名
--@id: 该值在添加时返回的id
function FightCharacter:removeBuffMinValue(attrName, id)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):removeMinAttr(attrName, id)
end

--@desc: 添加buff免疫功能
--@author:Seven
--@time:2023-03-17 14:07:45
--@immuneType: 免疫类型
--@args: 相关参数
--@return: id
function FightCharacter:addImmuneBuff(immuneType, ...)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):addImmuneBuff(immuneType, ...)
end

--@desc: 删除免疫对象
--@author:Seven
--@time:2023-03-17 14:08:51
--@immuneType: 免疫类型
--@id: 免疫对象id
--@return: 被删除的免疫对象
function FightCharacter:removeImmuneBuff(immuneType, id)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):removeImmuneBuff(immuneType, id)
end

--@desc: 获取是否免疫
--@author:Seven
--@time:2023-03-17 14:09:57
--@immuneType: 免疫类型
--@args: 免疫相关参数
--@return: true,popText,printText | false
function FightCharacter:isImmuneBuff(immuneType, ...)
    return self:getFuncSystem(SYSTEM_NAME.BUFF_SYSTEM):isImmuneBuff(immuneType, ...)
end

--@endregion

--@region 武器切换功能

--@desc: 直接切换武器
--@author:Seven
--@time:2024-05-13 16:27:25
function FightCharacter:switchWeapon()
    return self:getFuncSystem(SYSTEM_NAME.SWITCH_WEAPON_FUNC):switchWeapon()
end

--@desc: 判断是否可切换武器
--@author:Seven
--@time:2023-02-15 17:12:53
--@switchType: 切换类型
--@switchConditionLogicalSymbol: 切换条件（大于、小于）
--@switchConditionValue: 切换的条件值
--@switchFailTextId: 如果不可切换，输出文本的id
--@return: 是否成功，失败的文本
function FightCharacter:judgeSwitchWeapon(switchType, switchConditionLogicalSymbol, switchConditionValue, switchFailTextId)
    local isSuccess, msg = self:getFuncSystem(SYSTEM_NAME.SWITCH_WEAPON_FUNC):judgeSwitchWeapon(switchType, switchConditionLogicalSymbol, switchConditionValue, switchFailTextId)

    return isSuccess, msg
end

--@desc: 获取当前切换功能中切换的目标武器
--@author:Seven
--@time:2023-02-15 17:17:53
--@return [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function FightCharacter:getSwitchTargetWeapon()
    return self:getFuncSystem(SYSTEM_NAME.SWITCH_WEAPON_FUNC):getSwitchTargetWeapon()
end
--@endregion

--@region 气血恢复系统
--@desc: 设置气血恢复是否开启
--@author:Seven
--@time:2023-02-16 17:22:46
--@bool: true | false
function FightCharacter:setQiRecoverFuncOpen(bool)
    return self:getFuncSystem(SYSTEM_NAME.RECOVER_QI_FUNC):setRcoverQiOpen(bool)
end

--@desc: 气血恢复是否开启
--@author:Seven
--@time:2023-11-06 15:45:27
--@return true | false
function FightCharacter:isQiRecoverOpen()
    return self:getFuncSystem(SYSTEM_NAME.RECOVER_QI_FUNC):getRecoverIsOpen()
end

--@desc: 气血恢复对象
--@author:Seven
--@time:2023-02-28 20:51:19
--@return [src.app.FightSystem.FightRole.CharacterRecovery.RecoverQi#RecoverQi]
function FightCharacter:getRecoverQi()
    return self:getFuncSystem(SYSTEM_NAME.RECOVER_QI_FUNC):getRecoverQi()
end
--@endregion

--@region 主动技能ai系统
function FightCharacter:addActiveReleaseAIRule(rule)
    return self:getFuncSystem(SYSTEM_NAME.ACTIVE_AUTO_RELEASE_AI_SYSTEM):addRule(rule)
end

--@desc: 获取AI释放主动技能规则
--@author:Seven
--@time:2024-03-19 11:02:08
--@actId: 主动技能ID
--@return [src.app.FightSystem.FightRole.CharacterAI.IReleaseActiveAIRule#IReleaseActiveAIRule]
function FightCharacter:getActiveReleaseAIRule(actId)
    if self:hasFuncSystem(SYSTEM_NAME.ACTIVE_AUTO_RELEASE_AI_SYSTEM) then
        return self:getFuncSystem(SYSTEM_NAME.ACTIVE_AUTO_RELEASE_AI_SYSTEM):getRule(actId)
    end

    return nil
end

function FightCharacter:aiCheckAndRelease(hasSomeAction)
    if self:hasFuncSystem(SYSTEM_NAME.ACTIVE_AUTO_RELEASE_AI_SYSTEM) then
        self:getFuncSystem(SYSTEM_NAME.ACTIVE_AUTO_RELEASE_AI_SYSTEM):checkReleaseRules(hasSomeAction)
    end
end

function FightCharacter:applyReleaseOperation(o_type, args)
    self.__fight:sendOperationMesaage(self:getId(), o_type, args)
end
--@endregion

--@region 禁用操作
--@desc: 添加禁止操作功能类型的值
--@author:Seven
--@time:2024-03-01 16:04:41
--@banType: [src.app.FightSystem.FightCommons#FightCommons.BAN_OPERATION_TYPE]
--@tips: string
--@return: id index number
function FightCharacter:addBanOperation(banType, tips)
    return self:getFuncSystem(SYSTEM_NAME.BAN_OPERATION_SYSTEM):addBanOperation(banType, tips)
end

--@desc: 移除禁止操作功能类型的值
function FightCharacter:removeBanOperation(index)
    return self:getFuncSystem(SYSTEM_NAME.BAN_OPERATION_SYSTEM):removeBanOperation(index)
end

--@desc: 是否禁止操作功能类型的值
--@return: true | false , failMsg or nil
function FightCharacter:isBanOperation(banType)
    return self:getFuncSystem(SYSTEM_NAME.BAN_OPERATION_SYSTEM):isBanOperation(banType)
end
--@endregion

--@region 武学抗性系统
function FightCharacter:addSkillAtkResistance(id, value)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_RESISTANCE_SYSTEM):addSkillAtkResistance(id, value)
end

function FightCharacter:getSkillAtkResistance(id)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_RESISTANCE_SYSTEM):getSkillAtkResistance(id)
end

function FightCharacter:addSkillDefResistance(id, value)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_RESISTANCE_SYSTEM):addSkillDefResistance(id, value)
end

function FightCharacter:getSkillDefResistance(id)
    return self:getFuncSystem(SYSTEM_NAME.SKILL_RESISTANCE_SYSTEM):getSkillDefResistance(id)
end
--@endregion

--@desc: 刷新角色属性限制并判断是否进入死亡状态
--@author:Seven
--@time:2023-11-24 17:14:52
function FightCharacter:updateSelfAlive()
    self:correctAttrLimit()
    if self:canDead() then
        self:killCharacter()
    end
end

function FightCharacter:updateViews()
    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterAttrInfoSyncUIViewEvent":create(self))
    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterUpdateShieldViewEvent":create(self:getId(), self:getQiShieldAnimId()))
    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterUpdateShadowViewEvent":create(self:getId(), self:getHaloOfFootAnimId()))
    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterUpdateHeadStatusTextViewEvent":create(self:getId(), self:getTextOfTop()))
    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterWeaponSkinUpdateViewEvent":create(self:getId(), self:getWeapon():getWeaponSkin()))
    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterUpdateIconsViewEvent":create(self:getId(), self:getIcons()))
    if not self:isDead() then
        self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterUpdateAndPlayIdleAnimNameViewEvent":create(self:getId(), self:getIdleAnimId()))
    else
        self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterUpdateAndPlayDeadAnimViewEvent":create(self:getId(), FightCommons.HIT_POS.CHEST))
    end
end

--@region 自身携带buff

--@desc:
--@author:Seven
--@time:2026-01-07 17:49:11
--@initCarryBuffClass: [src.app.FightSystem.FightRole.CharacterBuff.CharacterCarryBuffWhenInit#CharacterCarryBuffWhenInit]
function FightCharacter:setCarryBuffHandler(initCarryBuffClass)
    self.__carryBuffHandler = initCarryBuffClass
end

--@desc: 获取角色初始化时携带的buff类
--@return [src.app.FightSystem.FightRole.CharacterBuff.CharacterCarryBuffWhenInit#CharacterCarryBuffWhenInit]
function FightCharacter:getCarryBuffHandler()
    return self.__carryBuffHandler
end

--@endregion

return class("FightCharacter", {}, FightCharacter)
00000000
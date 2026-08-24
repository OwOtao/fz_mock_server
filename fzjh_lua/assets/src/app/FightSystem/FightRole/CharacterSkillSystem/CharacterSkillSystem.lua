--[[
    author:Seven
    time:2022-07-06 15:07:58
    desc:
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local BasicFightActiveSkill = require("app.FightSystem.FightSkill.BasicFightActiveSkill")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local SkillConst = require("app.models.skill.SkillConst")

local ActiveSkillCdUpdateViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.ActiveSkillCdUpdateViewEvent")

--@RefType src.app.models.skill.SkillConst#SkillConst.SkillSecondType
local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local CharacterSkillSystem = {
    __attackSkillType = SKILL_SECOND_TYPE.QUAN_JIAO,
    --@desc 存放角色所会的武学数据
    __skillMap = {},
    -- 基本武学
    __base_skill = {
        [tostring(SKILL_SECOND_TYPE.QUAN_JIAO)] = nil,
        [tostring(SKILL_SECOND_TYPE.JIAN_FA)] = nil,
        [tostring(SKILL_SECOND_TYPE.DAO_FA)] = nil,
        [tostring(SKILL_SECOND_TYPE.GUN_FA)] = nil,
        [tostring(SKILL_SECOND_TYPE.BIAN_FA)] = nil,
        [tostring(SKILL_SECOND_TYPE.SHUANG_CHI)] = nil,
        [tostring(SKILL_SECOND_TYPE.AN_QI)] = nil,
        [tostring(SKILL_SECOND_TYPE.QIN_FA)] = nil,
        [tostring(SKILL_SECOND_TYPE.QING_GONG)] = nil,
        [tostring(SKILL_SECOND_TYPE.NEI_GONG)] = nil
    },
    -- 准备的武学（可为空）
    __prep_skill = {
        [tostring(SKILL_SECOND_TYPE.QUAN_JIAO)] = nil,
        [tostring(SKILL_SECOND_TYPE.JIAN_FA)] = nil,
        [tostring(SKILL_SECOND_TYPE.DAO_FA)] = nil,
        [tostring(SKILL_SECOND_TYPE.GUN_FA)] = nil,
        [tostring(SKILL_SECOND_TYPE.BIAN_FA)] = nil,
        [tostring(SKILL_SECOND_TYPE.SHUANG_CHI)] = nil,
        [tostring(SKILL_SECOND_TYPE.AN_QI)] = nil,
        [tostring(SKILL_SECOND_TYPE.QIN_FA)] = nil,
        [tostring(SKILL_SECOND_TYPE.QING_GONG)] = nil,
        [tostring(SKILL_SECOND_TYPE.NEI_GONG)] = nil
    },
    __standby_skill = {
        [tostring(SKILL_SECOND_TYPE.QUAN_JIAO)] = nil
        --@region 未开放
        -- [tostring(SKILL_SECOND_TYPE.JIAN_FA)] = nil,
        -- [tostring(SKILL_SECOND_TYPE.DAO_FA)] = nil,
        -- [tostring(SKILL_SECOND_TYPE.GUN_FA)] = nil,
        -- [tostring(SKILL_SECOND_TYPE.BIAN_FA)] = nil,
        -- [tostring(SKILL_SECOND_TYPE.SHUANG_CHI)] = nil,
        -- [tostring(SKILL_SECOND_TYPE.AN_QI)] = nil,
        -- [tostring(SKILL_SECOND_TYPE.QIN_FA)] = nil
        --@endregion
    },
    --@desc 存放主动技能准备配置
    __prep_act_config = {},
    __active_skill_map = {},
    __prep_act = {},
    --@desc 存放buff添加器索引
    __buffAdderGroupMap = {},
    __buffIndexs = {}
}

function CharacterSkillSystem:getCurrActivePrepActiveSkillIdMap()
    error(" CharacterSkillSystem:getCurrActivePrepActiveSkillIdMap 需重写该方法")
end

function CharacterSkillSystem:onInit()
    --@RefType [src.app.FightSystem.FightRole.CharacterSkillSystem.BanSkillAttackFuncMap#BanSkillAttackFuncMap]
    self.__banSkillAttackFunc = require("src.app.FightSystem.FightRole.CharacterSkillSystem.BanSkillAttackFuncMap"):create()
end

function CharacterSkillSystem:updatePrepActiveSkill()
    self.__prep_act = {}
    local prep_active_map = self:getCurrActivePrepActiveSkillIdMap()

    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local actSkill_info = prep_active_map[tostring(i)]
        if actSkill_info ~= nil then
            self:prepActiveSkill(actSkill_info.activeSkillId, tonumber(i))
        end
    end
end

--@desc: 刷新主动技能准备列表
--@author:Seven
--@time:2023-11-15 15:23:32
function CharacterSkillSystem:refreshActiveSkillPrepList()
    local old_prep_map = self.__prep_act

    self:updatePrepActiveSkill()

    local new_prep_map = self.__prep_act

    --@desc 去除旧配置中已被卸载的主动技能
    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local act_id = old_prep_map[tostring(i)]
        if act_id then
            if not table.keyof(new_prep_map, act_id) then
                local removedActiveSkill = self:getActiveSkill(act_id)
                self:removeActiveCarryBuff(removedActiveSkill)
                self:removeEnterBuffAdderGroup(removedActiveSkill)
            end
        end
    end

    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local new_act_id = new_prep_map[tostring(i)]
        if new_act_id then
            if not table.keyof(old_prep_map, new_act_id) then
                local addedActiveSkill = self:getActiveSkill(new_act_id)
                self:addActiveCarryBuff(addedActiveSkill)
                self:addEnterBuffAdderGroup(addedActiveSkill)
            end
        end
    end

    self.__prevActiveSkillUpdateEnableResult = nil
end

function CharacterSkillSystem:onDestory()
end

function CharacterSkillSystem:onUpdate(ft)
    self:__updateActSkillsCD(ft)
    self:__updatePrepActiveSkillsEnable()
end

--@desc: 存放角色已学会的所有武学数据
--@author:Seven
--@time:2022-07-12 14:30:02
--@skillMap: 角色所学的武学数据
function CharacterSkillSystem:setRawSkillMap(skillMap)
    self.__rawSkillMap = skillMap
end

function CharacterSkillSystem:getSkillFormRawData(skillId)
    if MapIsEmpty(self.__rawSkillMap) then
        return nil
    end
    local skill_info = self.__rawSkillMap[skillId]

    if skill_info ~= nil then
        return skill_info
    end

    return nil
end

--@desc: 添加基本武学
--@author:Seven
--@time:2021-06-28 15:06:18
--@skillSecType: 准备位置
--@baseSkill: [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function CharacterSkillSystem:addBaseSkill(skillSecType, baseSkill)
    self.__base_skill[tostring(skillSecType)] = isImplement(baseSkill, require("app.FightSystem.FightSkill.BasicFightSkill"))
    baseSkill:setCharacter(self.__character)
end

--@desc: 获取基本武学类型信息
--@author:Seven
--@time:2021-06-28 15:02:11
--@skillSecType: 武学第二类型
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function CharacterSkillSystem:getBaseSkill(skillSecType)
    return self.__base_skill[tostring(skillSecType)]
end

--@desc: 准备武学
--@author:Seven
--@time:2022-07-06 16:11:06
--@skillSecType: 武学第二类型
--@f_skill: [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function CharacterSkillSystem:prepSkill(skillSecType, f_skill)
    f_skill:setCharacter(self.__character)
    self.__prep_skill[tostring(skillSecType)] = isImplement(f_skill, require("app.FightSystem.FightSkill.BasicFightSkill"))
end

function CharacterSkillSystem:getPrepSkillMap()
    return self.__prep_skill
end

--@desc: 获取准备技能
--@author:Seven
--@time:2021-06-29 19:01:12
--@skillSecType: 技能二类型
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function CharacterSkillSystem:getPrepSkill(skillSecType)
    return self.__prep_skill[tostring(skillSecType)]
end

--@desc: 设置准备技能配置
--@author:Seven
--@time:2023-02-13 18:17:03
--@skillSecType: 武学准备类型（武学二类型）
--@configTable: 配置信息
function CharacterSkillSystem:setPrepActiveSkillConfig(skillSecType, configTable)
    self.__prep_act_config[tostring(skillSecType)] = configTable
end

--@desc: 获取准备技能配置
--@author:Seven
--@time:2023-02-13 18:14:54
--@skillSecType: 武学准备类型（武学二类型）
function CharacterSkillSystem:getPrepActiveSkillConfig(skillSecType)
    return Helper:getDef(self.__prep_act_config[tostring(skillSecType)], {})
end

--@desc: 添加主动招式
--@author:Seven
--@time:2021-06-18 11:53:55
--@activeSkill: [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function CharacterSkillSystem:addActiveSkill(activeSkill)
    self.__active_skill_map[activeSkill:getId()] = isImplement(activeSkill, BasicFightActiveSkill)
end

function CharacterSkillSystem:getActiveSkills()
    return table.mapToArray(self.__active_skill_map)
end

--@desc: 是否拥有主动技能
--@author:Seven
--@time:2023-02-13 15:43:19
--@actId: 主动技能id
--@return true | false
function CharacterSkillSystem:hasActiveSkill(actId)
    return self.__active_skill_map[tostring(actId)] ~= nil
end

--@desc: 获取主动招式
--@author:Seven
--@time:2021-06-18 12:08:07
--@act_id: 主动招式ID
--@return [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function CharacterSkillSystem:getActiveSkill(act_id)
    local act = self.__active_skill_map[tostring(act_id)]

    if act == nil then
        assert(false, "角色 ： " .. self.__character:getAttr("name") .. "没有该可用主动技能 ：" .. act_id)
    end

    return act
end

function CharacterSkillSystem:unmountPrepActiveSkill(index)
    local id = self.__prep_act[tostring(index)]

    self.__prep_act[tostring(index)] = nil

    return id
end

--@desc: 准备主动技能
--@author:Seven
--@time:2021-06-18 11:58:09
--@skillId: 主动技能ID
function CharacterSkillSystem:prepActiveSkill(act_id, pos_index)
    if pos_index == nil then
        assert(false, "CharacterSkillSystem:prepActiveSkill 准备主动技能，请指定位置，位置不可为空。")
    end

    if type(act_id) ~= "string" then
        assert(false, "CharacterSkillSystem:prepActiveSkill 添加准备主动技能参数错误")
    end

    self.__prep_act[tostring(pos_index)] = act_id
end

--@desc: 判断是否已准备的主动技能id
--@author:Seven
--@time:2023-02-23 16:31:35
--@act_id: 主动技能
function CharacterSkillSystem:isPrepActiveSkill(act_id)
    for pos, preActId in pairs(self:getPrepActiveSkillMap()) do
        if preActId == act_id then
            return true, pos
        end
    end

    return false
end

function CharacterSkillSystem:getPrepActiveSkillMap()
    return self.__prep_act
end

--@desc: 获取某个位置上的主动技能
--@author:Seven
--@time:2023-04-03 15:45:09
--@pos_index: 位置索引
--@return [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function CharacterSkillSystem:getPrepActiveSkillByPosIndex(pos_index)
    local actId = self.__prep_act[tostring(pos_index)]

    if actId == nil then
        return nil
    end

    return self:getActiveSkill(actId)
end

--@desc: 获取已准备的主动技能
--@author:Seven
--@time:2023-02-13 16:26:13
--@return: 已准备的主动技能数组
function CharacterSkillSystem:getPrepAcitveSkills()
    local prepActSkills = {}

    if MapIsEmpty(self.__prep_act) == true then
        return prepActSkills
    end

    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local activeSkillId = self.__prep_act[tostring(i)]
        if activeSkillId ~= nil then
            local activeSkill = self:getActiveSkill(activeSkillId)
            table.insert(prepActSkills, activeSkill)
        end
    end

    return prepActSkills
end

--@desc: 刷新主动技能是否满足使用条件
--@author:Seven
--@time:2022-07-08 14:36:34
function CharacterSkillSystem:__updatePrepActiveSkillsEnable()
    local prepActSkills = self:getPrepAcitveSkills()
    if #prepActSkills <= 0 then
        return
    end

    if self.__prevActiveSkillUpdateEnableResult == nil then
        self.__prevActiveSkillUpdateEnableResult = {}
    end

    for i = 1, #prepActSkills do
        --@RefType [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
        local actSkill = prepActSkills[i]
        local isMeetCost = actSkill:releaseAreMet()

        local prevResult = self.__prevActiveSkillUpdateEnableResult[tostring(actSkill:getId())]

        if prevResult ~= isMeetCost then
            self.__prevActiveSkillUpdateEnableResult[tostring(actSkill:getId())] = isMeetCost
            self.__character:getFight():notifyVeiwEvent(require("app.FightSystem.Veiws.ViewEvents.Events.ActiveSkillEnableViewEvent"):create(self.__character:getId(), actSkill:getId(), isMeetCost))
        end
    end
end

--@desc: 刷新主动技能CD
--@author:Seven
--@time:2022-07-08 14:36:11
--@ft: 时间间隔
function CharacterSkillSystem:__updateActSkillsCD(ft)
    local act_skills = self:getActiveSkills()

    for _, actSkill in pairs(act_skills) do
        local oldCd = actSkill:getCD()
        if oldCd > 0 then
            local newCd = math.max(oldCd - ft, 0)

            actSkill:setCD(newCd)

            FightUtil:printLog(string.format(" CharacterSkillSystem:__updateActSkillsCD【%s】 主动技能【%s】CD更新,剩余: %f", self.__character:getAttr("name"), actSkill:getName(), newCd))

            local updateViewEvent = ActiveSkillCdUpdateViewEvent:create(self.__character:getId(), actSkill:getId(), oldCd, newCd, ft)

            self.__character:getFight():notifyVeiwEvent(updateViewEvent)
        end
    end
end

--@desc: 获取当前准备武学（需武器配套）
--@author:Seven
--@time:2021-07-08 22:14:59
function CharacterSkillSystem:getPrepAttackSkill()
    local prepAttackSkill = self:getPrepSkill(self.__character:getAttackSkillType())

    if prepAttackSkill == nil then
        return nil
    end

    local weapon = self.__character:getWeapon()

    if prepAttackSkill:isUseWeaponType(weapon:getWeaponResId()) then
        return prepAttackSkill
    end

    return nil
end

--@desc: 获取当前攻击使用的武学
--@author:Seven
--@time:2021-05-31 10:35:48
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function CharacterSkillSystem:getAttackSkill()
    local attackSkill

    local prepSkill = self:getPrepAttackSkill()

    if self.__character:getBuffAddAttr("useBaseAttackSkill") > 0 or prepSkill == nil then
        attackSkill = self:getBaseSkill(self.__character:getAttackSkillType())
    else
        attackSkill = prepSkill
    end

    return attackSkill
end

--@desc: 获取当前使用的闪避武学
--@author:Seven
--@time:2023-10-14 11:09:24
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function CharacterSkillSystem:getDodgeSkill()
    local dodgeSkill

    local prepDodgeSkill = self:getPrepSkill(tostring(SKILL_SECOND_TYPE.QING_GONG))

    if prepDodgeSkill == nil then
        dodgeSkill = self:getBaseSkill(tostring(SKILL_SECOND_TYPE.QING_GONG))
    else
        dodgeSkill = prepDodgeSkill
    end

    return dodgeSkill
end

--@desc: 获取当前使用的招架武学
--@author:Seven
--@time:2023-10-14 11:09:42
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function CharacterSkillSystem:getParrySkill()
    local parrySkill

    local prepParrySkill = self:getPrepSkill(tostring(SKILL_SECOND_TYPE.ZHAO_JIA))

    if prepParrySkill == nil then
        parrySkill = self:getBaseSkill(tostring(SKILL_SECOND_TYPE.ZHAO_JIA))
    else
        parrySkill = prepParrySkill
    end

    return parrySkill
end

--@desc: 获取当前使用的内功武学
--@author:Seven
--@time:2023-10-14 11:09:57
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function CharacterSkillSystem:getNeiGongSkill()
    local neiGongSkill
    local prepNeiGongSkill = self:getPrepSkill(tostring(SKILL_SECOND_TYPE.NEI_GONG))

    if prepNeiGongSkill == nil then
        neiGongSkill = self:getBaseSkill(tostring(SKILL_SECOND_TYPE.NEI_GONG))
    else
        neiGongSkill = prepNeiGongSkill
    end

    return neiGongSkill
end

--@desc: 当前攻击基本武学
--@author:Seven
--@time:2021-06-29 17:38:07
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function CharacterSkillSystem:getBaseAttackSkill()
    local baseSkill = self:getBaseSkill(self.__character:getAttackSkillType())

    return baseSkill
end

function CharacterSkillSystem:__walkPrepActiveSkill(func)
    if MapIsEmpty(self.__prep_act) then
        return
    end

    for pos, act_id in pairs(self.__prep_act) do
        if func(pos, act_id) then
            break
        end
    end
end

function CharacterSkillSystem:walkPrepActiveSkillIds(func)
    if MapIsEmpty(self.__prep_act) then
        return
    end

    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local activeSkillId = self.__prep_act[tostring(i)]
        if activeSkillId ~= nil then
            if func(i, activeSkillId) then
                break
            end
        end
    end
end

function CharacterSkillSystem:removePrepActiveSkill(act_id)
    self:__walkPrepActiveSkill(
        function(pos, prepId)
            if act_id == prepId then
                self.__prep_act[pos] = nil
                return true
            end
        end
    )
end

--@region 主动技能使用静止相关
--@desc: 指定禁止使用被动技能
--@author:Seven
--@time:2023-03-16 16:40:07
--@tips: 提示
function CharacterSkillSystem:addBanAutoAttack(tips)
    return self.__banSkillAttackFunc:addBanAutoSkill(tips)
end

function CharacterSkillSystem:removeBanAutoAttack(index)
    return self.__banSkillAttackFunc:removeBanAutoAttack(index)
end

--@desc: 指定禁止主动类型
--@author:Seven
--@time:2023-03-16 16:32:07
--@activeType: 指定禁止的主动类型
--@tips: 提示
function CharacterSkillSystem:addBanActiveAttack(activeType, tips)
    return self.__banSkillAttackFunc:addBanActiveSkill(activeType, tips)
end

function CharacterSkillSystem:removeBanActiveAttack(activeType, index)
    return self.__banSkillAttackFunc:removeBanActiveSkill(activeType, index)
end
--@endregion

function CharacterSkillSystem:isBanAttackByType(attackType, ...)
    if attackType == "auto" then
        return self.__banSkillAttackFunc:isBanAutoSkill()
    elseif attackType == "active" then
        local activeType = unpack({...})

        if activeType == nil then
            error("CharacterSkillSystem:isBanAttackByType active , 主动技能，指定获取的禁止类型，检查代码")
        end

        return self.__banSkillAttackFunc:isBanActiveSkill(activeType)
    else
        error("CharacterSkillSystem:isBanAttackByType 禁止攻击类型未知：" .. tostring(attackType))
    end
end

--@desc: 添加入场buff添加器
--@author:Seven
--@time:2023-10-14 16:06:12
--@activeSkill: [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function CharacterSkillSystem:addEnterBuffAdderGroup(activeSkill)
    local adderGroupList = activeSkill:getCarryBuffAdderGroupArray()

    if MapIsEmpty(adderGroupList) then
        return
    end

    for _, adderGroup in ipairs(adderGroupList) do
        if self.__buffAdderGroupMap[activeSkill:getId()] == nil then
            self.__buffAdderGroupMap[activeSkill:getId()] = {}
        end

        table.insert(self.__buffAdderGroupMap[activeSkill:getId()], self.__character:addBuffAdderGroup(adderGroup))
    end
end

--@desc: 删除角色身上入场buff添加器
--@author:Seven
--@time:2023-10-14 17:03:41
--@active_skill: [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
--@return:
function CharacterSkillSystem:removeEnterBuffAdderGroup(active_skill)
    local list = self.__buffAdderGroupMap[active_skill:getId()]
    if list ~= nil then
        for _, v in ipairs(list) do
            self.__character:removeBuffAdderGroup(v)
        end

        self.__buffAdderGroupMap[active_skill:getId()] = nil
    end
end

--@desc: 添加装备主动技能携带的buff
--@author:Seven
--@time:2023-10-14 17:12:39
--@active_skill: [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function CharacterSkillSystem:addActiveCarryBuff(active_skill)
    local buffArray = active_skill:getCarryBuffArray()
    if MapIsEmpty(buffArray) then
        return
    end
    for _, buff in ipairs(buffArray) do
        local AddBuffUtil = require("app.FightSystem.FightRole.CharacterBuff.Utils.AddBuffUtil")

        local result = AddBuffUtil:addBuff(self.__character, buff)

        if result.needAdd == true then
            if self.__buffIndexs[active_skill:getId()] == nil then
                self.__buffIndexs[active_skill:getId()] = {}
            end
            table.insert(self.__buffIndexs[active_skill:getId()], result.index)
        end
    end
end

--@desc: 移除主动技能携带buff
--@author:Seven
--@time:2023-10-17 20:02:18
--@activeSkill: [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function CharacterSkillSystem:removeActiveCarryBuff(activeSkill)
    local list = self.__buffIndexs[activeSkill:getId()]

    if MapIsEmpty(list) then
        return
    end

    for _, index in ipairs(list) do
        self.__character:removeCharacterBuff(index)
    end
end

return newClass("CharacterSkillSystem", {ABasicCharacterFuncSystem}, CharacterSkillSystem)
000000000
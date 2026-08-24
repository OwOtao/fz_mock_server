--[[
    author:Seven
    time:2022-09-22 15:47:15
    desc: 使用新版武学数据，进行主动技能准备相关
    暂时只用于新版战斗中的角色使用（可能包含棋局、梦境、挑战副本）
]]
local newClass = require("third.class.NewClass")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")

local ActiveSkillConf = require("app.FightSystem.Configuration.ActiveSkillConf")

local FightCommons = require("app.FightSystem.FightCommons")

local IActiveSkillPrepareInput = require("app.models.ActiveSkillPrepare.IActiveSkillPrepareInput")

local ActiveSkillPrepareV2 = {}

function ActiveSkillPrepareV2:create()
    return ActiveSkillPrepareV2.new()
end

function ActiveSkillPrepareV2:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

function ActiveSkillPrepareV2:initialize()
    self.__canPrepList = {}

    self.__currAttackSecSkillType = WeaponTypesResManager:getWeaponInfoByTypeAndType2(self.__firstWeaponType, self.__secondWeaponType).autoChooseSkill

    local currCanPrepSkillSecTypeList = {}

    local firstSkillList = SkillClassifyManager:getFirstTypes()

    for _, firstType in ipairs(firstSkillList) do
        local secTypeList = SkillClassifyManager:getAllSecondTypesByFirstType(firstType)
        if SkillClassifyManager:isAttackSkllTypeByFirstType(firstType) then
            for __, secType in ipairs(secTypeList) do
                if tostring(secType) == tostring(self.__currAttackSecSkillType) then
                    table.insert(currCanPrepSkillSecTypeList, tostring(secType))
                end
            end
        else
            for __, secType in ipairs(secTypeList) do
                table.insert(currCanPrepSkillSecTypeList, tostring(secType))
            end
        end
    end

    self:__filterRemoveNotMatchActiveSkillId()

    self:__initCanPrepActiveSkillList(currCanPrepSkillSecTypeList)

    self:__initPrepSkillList()
end

function ActiveSkillPrepareV2:__initCanPrepActiveSkillList(currCanPrepSkillSecTypeList)
    --@desc 去重使用
    local act_map = {}

    for _, secSkillType in ipairs(currCanPrepSkillSecTypeList) do
        local prepSkill = self.__character:getPrepSkill(secSkillType)

        if prepSkill ~= nil then
            local activeSkillList = prepSkill:getActiveZhaos()
            if MapIsEmpty(activeSkillList) == false then
                local skill_contains_active_list = {}
                for _, act_id in ipairs(activeSkillList) do
                    if act_map[act_id] == nil and self.__character:hasActiveSkill(act_id) then
                        local activeSkill = self.__character:getActiveSkill(act_id)

                        if activeSkill:isMeetUseCondition() == true then
                            table.insert(skill_contains_active_list, {activeSkillId = activeSkill:getId(), level = activeSkill:getLevel()})
                            act_map[act_id] = true
                        end
                    end
                end

                if not MapIsEmpty(skill_contains_active_list) then
                    table.sort(
                        skill_contains_active_list,
                        function(a, b)
                            return a.level > b.level
                        end
                    )

                    for _, v in ipairs(skill_contains_active_list) do
                        table.insert(self.__canPrepList, v)
                    end
                end
            end
        end
    end
end

function ActiveSkillPrepareV2:__initPrepSkillList()
    local currConfig = clone(self.__character:getPrepActiveSkillConfig(self.__currAttackSecSkillType))

    local currPrepMap = {}
    if MapIsEmpty(currConfig) ~= nil then
        currPrepMap =
            table.getMap(
            currConfig,
            function(k, v)
                return v.activeSkillId, true
            end
        )
    end

    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local config_active = currConfig[tostring(i)]

        if config_active == nil then
            while true do
                if table.getn(self.__canPrepList) > 0 then
                    local can_prep_act = table.remove(self.__canPrepList, 1)

                    if currPrepMap[can_prep_act.activeSkillId] ~= true then
                        currConfig[tostring(i)] = can_prep_act

                        break
                    end
                else
                    break
                end
            end
        end
    end

    self.__prepList = currConfig
end

--@desc: 删除配置中无法使用的主动技能id
--@author:Seven
--@time:2022-09-23 16:07:40
function ActiveSkillPrepareV2:__filterRemoveNotMatchActiveSkillId()
    local currConfig = self.__character:getPrepActiveSkillConfig(self.__currAttackSecSkillType)
    for i = FightCommons.PREP_ACT_MAX_COUNT, 1, -1 do
        if currConfig[tostring(i)] ~= nil then
            local act_id = currConfig[tostring(i)].activeSkillId

            if self.__character:hasActiveSkill(act_id) then
                local activeSkill = self.__character:getActiveSkill(act_id)

                if not activeSkill:isMeetUseCondition() then
                    currConfig[tostring(i)] = nil
                end
            else
                currConfig[tostring(i)] = nil
            end
        end
    end
end

function ActiveSkillPrepareV2:setWeaponType(weaponType)
    self.__firstWeaponType = weaponType
end

function ActiveSkillPrepareV2:setWeaponSecType(weaponSecType)
    self.__secondWeaponType = weaponSecType
end

function ActiveSkillPrepareV2:getWeaponType()
    return self.__firstWeaponType
end

function ActiveSkillPrepareV2:getPreparedActiveSkillList()
    return self.__prepList
end

function ActiveSkillPrepareV2:prepareActiveSkill(currIndex, toIndex)
end

function ActiveSkillPrepareV2:getCanPrepareActiveSkillList()
    return self.__canPrepList
end

return newClass("ActiveSkillPrepareV2", {IActiveSkillPrepareInput}, ActiveSkillPrepareV2)
00000
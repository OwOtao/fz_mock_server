--[[
    author:Seven
    time:2022-07-26 10:04:37
    desc: 挑战副本角色数据与玩家数据同步系统
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")

local statustagsyncmgr = require("script.challengeMap.statustagsyncmgr")["Sheet1"]

local StatusTagsResourceHelper = require("app.models.RoleStatusTags.StatusTagsResourceHelper")

local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")

local EQUIP_PART = FightCommons.EQUIP_PART

local ChallengeMapSyncSystem = {
    __data = {},
    __mapId = nil
}

function ChallengeMapSyncSystem:create(...)
    return ChallengeMapSyncSystem.new():__init(...)
end

function ChallengeMapSyncSystem:__init(mapId)
    self.__data = {}

    self.__mapId = mapId

    return self
end

function ChallengeMapSyncSystem:recordOriBags(bags)
    self.__data.bagItems = {}

    for i, v in ipairs(bags) do
        table.insert(self.__data.bagItems, clone(v))
    end
end

--@mapPlayer: 挑战副本角色
--@player: 玩家存档角色
function ChallengeMapSyncSystem:syncPlayerData(mapPlayer, player, isCompleted)
    self:__syncActiveReleaseTimes(mapPlayer, player, isCompleted)
    self:__syncBagsData(mapPlayer, player, isCompleted)
    self:__syncEquip(mapPlayer, player, isCompleted)
    self:__syncFlag(mapPlayer, player, isCompleted)
    self:__syncStatusTags(mapPlayer, player, isCompleted)
end

--@desc:计算角色主动招式释放次数，添加熟练度
--@author:Seven
--@time:2025-05-10 15:21:10
function ChallengeMapSyncSystem:__syncActiveReleaseTimes(mapPlayer, player)
    local activeReleaseTimesMap = mapPlayer:getAttr("activeReleaseTimesMap")

    --@desc 每日上限是40
    local dayMaxExp = 40

    if MapIsEmpty(activeReleaseTimesMap) == false then
        for zhaoId, time in pairs(activeReleaseTimesMap) do
            local zhao = player:getSkillZhao(zhaoId)

            if zhao then
                local currLv = player:getSkillZhaoLv(zhaoId) -- 增加前的招式等级
                local dayExp = player:getDayFlag(zhaoId) -- 记录每天记录的增加量

                if time > 0 and dayExp < 40 then
                    local addExp = Helper:getRange(math.min(time * 2, dayMaxExp - dayExp), 0)
                    player:addSkillZhaoExp(zhaoId, addExp)
                    player:setDayFlag(zhaoId, dayExp + addExp) -- 更新每天记录的增加量

                    player:checkZhaoIsLevelUp(zhaoId, currLv)
                end
            end
        end
    end
end

function ChallengeMapSyncSystem:__syncBagsData(mapPlayer, player)
    if MapIsEmpty(self.__data.bagItems) then
        return
    end

    local removeItems = {}
    for i = #self.__data.bagItems, 1, -1 do
        local itemInfo = self.__data.bagItems[i]
        local mapPlayerItemInfo = mapPlayer:getItemWithOnlyId(itemInfo.id)

        if mapPlayerItemInfo then
            if mapPlayerItemInfo.itemId == itemInfo.itemId then
                for k, v in pairs(mapPlayerItemInfo) do
                    if type(v) ~= "table" then
                        if itemInfo[k] ~= v then
                            itemInfo[k] = v
                        end
                    else
                        error("物品信息结构内不应该有table：" .. table.tostring(v))
                    end
                end
            else
                error("挑战副本角色物品onlyid与初始物品onlyid一致但物品信息不一致，检查代码！！" .. table.tostring(mapPlayerItemInfo) .. " vs " .. table.tostring(itemInfo))
            end
        else
            --@desc 删除已不在背包的道具
            table.remove(self.__data.bagItems, i)
            table.insert(removeItems, itemInfo)
        end
    end

    for i, itemInfo in ipairs(self.__data.bagItems) do
        local playerItemInfo = player:getItemWithOnlyId(itemInfo.id)

        if playerItemInfo.itemId == itemInfo.itemId then
            if Item:itemIsWeapon(player:getOneItemByKey(playerItemInfo.itemId)) then
                if playerItemInfo.type == "神兵" then
                    ShenBingDuanZao:updateShenBingInfo(mapPlayer:getOneItemByKey(playerItemInfo.itemId), player)
                end
                for k, v in pairs(itemInfo) do
                    if type(v) ~= "table" then
                        if playerItemInfo[k] ~= v then
                            playerItemInfo[k] = v
                        end
                    else
                        error("物品信息结构内不应该有table：" .. table.tostring(v))
                    end
                end
            end
        else
            error("玩家角色物品onlyid与初始物品onlyid一致但物品信息不一致，检查代码！！" .. table.tostring(playerItemInfo) .. " vs " .. table.tostring(itemInfo))
        end
    end

    if not MapIsEmpty(removeItems) then
        for i, v in ipairs(removeItems) do
            player:addItemCount(v.itemId, v.count, nil, v.id)
        end
    end
end

function ChallengeMapSyncSystem:__syncEquip(mapPlayer, player)
    local equipMap = {}

    local mapPlayerEquipMap = mapPlayer:getEquipMap()

    if not MapIsEmpty(mapPlayerEquipMap) then
        for part, equipInfo in pairs(mapPlayerEquipMap) do
            local onlyid = equipInfo.id
            if self:__isOriBagsItem(onlyid) then
                equipMap[part] = equipInfo
            end
        end
    end

    for part, partName in pairs(EQUIP_PART) do
        local equipInfo = equipMap[partName]

        if equipInfo ~= nil then
            player:equipItem(partName, equipInfo)
        elseif player:getEquipByName(partName) ~= nil then
            player:removeEquipItem(partName)
        end
    end

    local mapPlayerPrepWeapon = mapPlayer:getPrepareWeapon()
    if mapPlayerPrepWeapon then
        if self:__isOriBagsItem(mapPlayerPrepWeapon.id) then
            player:setPrepareWeapon(mapPlayerPrepWeapon)
        else
            player:setPrepareWeapon(nil)
        end
    else
        player:setPrepareWeapon(nil)
    end
end

function ChallengeMapSyncSystem:__isOriBagsItem(onlyid)
    if MapIsEmpty(self.__data.bagItems) then
        return false
    end

    for i, v in ipairs(self.__data.bagItems) do
        if v.id == onlyid then
            return true
        end
    end

    return false
end

function ChallengeMapSyncSystem:__syncFlag(mapPlayer, player)
    local GameConst = require("app.models.game.GameConst")
    local flag = GameConst:getConfigValue("departFromFamilyTask_startFlag")
	local roleCompletedMapFlags = GameConst:getConfigValue("challengeMapTower_climbingHidden")
    if player:getFlag(flag) == 1 then
        local value = mapPlayer:getFlag(flag)
        player:setFlag(flag, value)
    end

	local completedMapFlagList = string.split(roleCompletedMapFlags,";")

	for i,flagId in ipairs(completedMapFlagList) do
		if ChallengeMapResource:getInstance():getFlagDataById(flagId) then
			local flagValue = tonumber(mapPlayer:getFlag(flagId))
			if flagValue and flagValue > 0 then
				player:setFlag(flagId, flagValue)
			end
		end
	end
end

local _status_tag_need_sync_in_map = function(statustags_sync_info, mapid)
end

function ChallengeMapSyncSystem:__syncStatusTags(mapPlayer, player, isCompleted)
    if isCompleted ~= true then
        -- 非通关副本不同步
        return
    end

    for statustagsId, info in pairs(statustagsyncmgr) do
        if not StatusTagsResourceHelper:isRoleStatusTagsType(statustagsId) then
            assert(false, "挑战副本同步状态标识id资源配置错误，非角色状态标识id：" .. tostring(statustagsId))
        end

        if StatusTagsResourceHelper:isNormalStatusTag(statustagsId) then
            local value = mapPlayer:getRoleStatusTags(statustagsId)
            if value >= 0 then
                player:setRoleStatusTags(statustagsId, value)
            end
        elseif StatusTagsResourceHelper:isInheritStatusTag(statustagsId) then
            local value = mapPlayer:getInheritRoleStatusTags(statustagsId)
            if value >= 0 then
                player:setInheritRoleStatusTags(statustagsId, value)
            end
        elseif StatusTagsResourceHelper:isTimeLimitStatusTag(statustagsId) then
            local value = mapPlayer:getTimeStatusTags(statustagsId)
            if value >= 0 then
                player:setTimeStatusTags(statustagsId, value)
            end
        elseif StatusTagsResourceHelper:isInheritTimeLimitStatusTag(statustagsId) then
            local value = mapPlayer:getInheritTimeStatusTags(statustagsId)
            if value >= 0 then
                player:setInheritTimeStatusTags(statustagsId, value)
            end
        else
            assert(false, "挑战副本同步状态标识id类型不支持，通知程序检查代码，同步状态标识id：" .. tostring(statustagsId))
        end
    end
end

return newClass("ChallengeMapSyncSystem", {}, ChallengeMapSyncSystem, false)
00
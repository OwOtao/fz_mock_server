local class = require("third.class.NewClass")
local ChallengeMapResource = {}

local __instance = nil

function ChallengeMapResource:getInstance()
    if __instance == nil then
        __instance = ChallengeMapResource.new()
        __instance:init()
    end
    return __instance
end

function ChallengeMapResource:init()
    self.__mapInfoMap = assert(requireWithEncrypt("script.challengeMap.mapInfo")["map"])
    -- self.__roomMapMap = assert(requireWithEncrypt("script.challengeMap.rooms"))
    -- self.__roleMapMap = assert(requireWithEncrypt("script.challengeMap.roles"))
    -- self.__itemMapMap = assert(requireWithEncrypt("script.challengeMap.items"))
    self.__flagsMap = assert(requireWithEncrypt("script.challengeMap.flags")["flag"])
    self.__npcTeamMap = assert(requireWithEncrypt("script.challengeMap.fightNpcTeam")["战队组"])
    self.__npcBaseAttrMap = assert(requireWithEncrypt("script.challengeMap.fightNpcBaseInfo")["战队组"])
    self.__resultAnim = assert(requireWithEncrypt("script.challengeMap.resultAnim")["Sheet1"])
    self.__fishingData = assert(requireWithEncrypt("script.miniGame.fishingInfo")["Sheet1"])

    self.__answerData = assert(requireWithEncrypt("script.miniGame.questionInfo")["Sheet1"])
    self.__questionMap = assert(requireWithEncrypt("script.miniGame.questionBankInfo")["questionListA"])

    self.__npcTeamMapGroup = {}
    for k, v in pairs(self.__npcTeamMap) do
        if v.battlegroup then
            if self.__npcTeamMapGroup[tostring(v.battlegroup)] == nil then
                self.__npcTeamMapGroup[tostring(v.battlegroup)] = {}
            end

            table.insert(self.__npcTeamMapGroup[tostring(v.battlegroup)], v)
        end
    end
end

function ChallengeMapResource:getMapRolesById(roleGridId)
    return assert(requireWithEncrypt("script.challengeMap.roles." .. roleGridId), "roleGridId: " .. tostring(roleGridId) .. " not found")
end

function ChallengeMapResource:getMapItemsById(itemGridId)
    return assert(requireWithEncrypt("script.challengeMap.items." .. itemGridId), "itemGridId: " .. tostring(itemGridId) .. " not found")
end

function ChallengeMapResource:getMapRoomsById(roomGridId)
    return assert(requireWithEncrypt("script.challengeMap.rooms." .. roomGridId), "roomGridId: " .. tostring(roomGridId) .. " not found")
end

function ChallengeMapResource:getMapNpcsById(npcGridId)
    return assert(requireWithEncrypt("script.challengeMap.roleBaseData." .. npcGridId), "npcGridId: " .. tostring(npcGridId) .. " not found")
end

--[[
    @desc: 获取挑战副本信息
    author:TangJian
    time:2021-12-15 12:00:26
    --@mapId: 
    @return:
]]
function ChallengeMapResource:getMapInfoById(mapId)
    return assert(self.__mapInfoMap[mapId], "mapId: " .. tostring(mapId) .. " not found")
end

function ChallengeMapResource:getMapInfoMap()
    return self.__mapInfoMap
end

function ChallengeMapResource:getMapInfosByType(mapType)
    local retMap = {}
    for mapId, mapinfo in pairs(self.__mapInfoMap) do
        if mapinfo.type == mapType then
            retMap[mapId] = mapinfo
        end
    end
    return retMap
end

--获取标记数据
function ChallengeMapResource:getFlagDataById(flagId)
    return assert(self.__flagsMap[flagId], "flagId: " .. tostring(flagId) .. " not found")
end

--@desc 获取战队组数据
function ChallengeMapResource:getNpcTeamMapById(teamId)
    return assert(self.__npcTeamMap[tonumber(teamId)], "teamId: " .. tostring(teamId) .. " not found")
end

--@desc 获取战队组数据
function ChallengeMapResource:getNpcTeamMapByGroupId(groupId,roleLv)
    local npcTeamGroup = assert(self.__npcTeamMapGroup[tostring(groupId)], "groupId: " .. tostring(groupId) .. " not found")

    for i, v in ipairs(npcTeamGroup) do
        local minLv = v.Gradesegment[1]

        local maxLv = v.Gradesegment[2]
        
        if roleLv >= minLv and roleLv <= maxLv then
            return v
        end
    end

    assert(nil, "groupId: " .. tostring(groupId) .. " roleLv: " .. tostring(roleLv) .. " not found")
end

--@desc 获取战斗npc基本属性数据
function ChallengeMapResource:getNpcBaseAttrMapById(baseAttrId)
    return assert(self.__npcBaseAttrMap[tonumber(baseAttrId)], "baseAttrId: " .. tostring(baseAttrId) .. " not found")
end

function ChallengeMapResource:getResultAnimById(animId)
    local animMap = {}

    for k, v in pairs(self.__resultAnim) do
        if tostring(v.flagid) == tostring(animId) then
            local info = {}
            info.text = v.text
            info.index = v.index
            info.duration = v.time
            table.insert(animMap, info)
        end
    end

    if MapIsEmpty(animMap) then
        assert(nil, "挑战副本结局动画配置异常  animId: " .. tostring(animId) .. " not found")
        return
    end

    table.sort(
        animMap,
        function(a, b)
            return a.index < b.index
        end
    )

    return animMap
end

function ChallengeMapResource:getFishingDataById(fishingId)
    return assert(self.__fishingData[tostring(fishingId)], "fishingId: " .. tostring(fishingId) .. " not found")
end

function ChallengeMapResource:getAnswerDataById(answerId)
    return assert(self.__answerData[tostring(answerId)], "answerId: " .. tostring(answerId) .. " not found")
end

function ChallengeMapResource:getQuestionMapByBankId(bankId)
    local retMap = {}

    for k, v in pairs(self.__questionMap) do
        if tostring(v.questionbankid) == tostring(bankId) then
            table.insert(retMap, v)
        end
    end

    if MapIsEmpty(retMap) then
        return assert(nil, "答题库 bankId: " .. tostring(bankId) .. " not found")
    end

    return retMap
end

function ChallengeMapResource:getNpcOldFightData(battleGroupId,levelId,roleLv)
	assert(battleGroupId, "battleGroupId =  nil")

	assert(levelId, "levelId =  nil")

    local npcDataRes = assert(requireWithEncrypt("script.challengeMap.oldFightNpcAttr." .. levelId), "levelId: " .. tostring(levelId) .. " not found")

	for k, v in pairs(npcDataRes) do
		if tonumber(v.battlegroup) == tonumber(battleGroupId) then
			local gradesegment = string.split(v.gradesegment,"#")
			
			local minLv = tonumber(gradesegment[1])
	
			local maxLv = tonumber(gradesegment[2])
			
			if roleLv >= minLv and roleLv <= maxLv then
				return v
			end
		end
    end

    assert(nil, "levelId: " .. tostring(levelId) .. "battleGroupId: " .. tostring(battleGroupId) .. " roleLv: " .. tostring(roleLv) .. " not found")
end

return class("ChallengeMapResource", {}, ChallengeMapResource)
00000
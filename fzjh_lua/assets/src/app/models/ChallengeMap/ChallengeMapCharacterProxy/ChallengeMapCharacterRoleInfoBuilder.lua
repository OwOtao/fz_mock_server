--[[
    author:Seven
    time:2024-01-18 20:39:59
    desc: 挑战副本角色信息展示代理类建造者
]]
local LocalPlayerFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.LocalPlayerFightCharacterBuilder")

--@RefType [src.app.models.ChallengeMap.ChallengeMapSystem#ChallengeMapSystem]
local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

local newClass = require("third.class.NewClass")

local ChallengeMapCharacterRoleInfoBuilder = {}

function ChallengeMapCharacterRoleInfoBuilder:create(...)
    return ChallengeMapCharacterRoleInfoBuilder.new():__init(...)
end

function ChallengeMapCharacterRoleInfoBuilder:__init(role)
    self.__role = role

    self.__mapBuffSystem = ChallengeMapSystem:getInstance():getBuffSystem()

    return self
end

function ChallengeMapCharacterRoleInfoBuilder:__getConfigClass()
    return require("app.models.ChallengeMap.ChallengeMapCharacterProxy.ChallengeMapCharacterConfig"):create(self.__mapBuffSystem):getConfigClass()
end

return newClass("ChallengeMapCharacterRoleInfoBuilder", {LocalPlayerFightCharacterBuilder}, ChallengeMapCharacterRoleInfoBuilder)
000000000000000
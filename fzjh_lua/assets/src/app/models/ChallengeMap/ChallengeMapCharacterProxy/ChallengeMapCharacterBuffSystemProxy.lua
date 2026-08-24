--[[
    author:Seven
    time:2024-01-18 20:58:14
    desc:
]]
local newClass = require("third.class.NewClass")
local ChallengeMapCharacterBuffSystemProxy = {}

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

function ChallengeMapCharacterBuffSystemProxy:create(buffSystem)
    return ChallengeMapCharacterBuffSystemProxy.new():__init(buffSystem)
end

function ChallengeMapCharacterBuffSystemProxy:__init(buffSystem)
    --@RefType [src.app.models.ChallengeMap.BuffSystem.BuffSystem#BuffSystem]
    self.__mapBuffSystem = buffSystem

    return self
end

function ChallengeMapCharacterBuffSystemProxy:onInit()
end

function ChallengeMapCharacterBuffSystemProxy:onDestory()
end

function ChallengeMapCharacterBuffSystemProxy:onUpdate(ft)
end

--@desc: 获取buff系统属性
--@author:Seven
--@time:2023-03-15 20:52:13
--@name: 属性名
function ChallengeMapCharacterBuffSystemProxy:getBuffSystemAttr(name)
    return self.__mapBuffSystem:getAttr(name)
end

function ChallengeMapCharacterBuffSystemProxy:getAddAttr(name)
    return self.__mapBuffSystem:getConstAttr(name)
end

function ChallengeMapCharacterBuffSystemProxy:getMulAttr(name)
    return self.__mapBuffSystem:getPercentAttr(name)
end

return newClass("ChallengeMapCharacterBuffSystemProxy", {ABasicCharacterFuncSystem}, ChallengeMapCharacterBuffSystemProxy)
00000
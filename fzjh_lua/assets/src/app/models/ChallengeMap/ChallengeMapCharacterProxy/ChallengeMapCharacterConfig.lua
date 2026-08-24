--[[
    author:Seven
    time:2024-01-18 21:10:27
    desc: 挑战副本属性展示角色相关配置
]]
local newClass = require("third.class.NewClass")

local ChallengeMapCharacterConfig = {}

function ChallengeMapCharacterConfig:create(mapBuffSystem)
    return ChallengeMapCharacterConfig.new():__init(mapBuffSystem)
end

function ChallengeMapCharacterConfig:__init(mapBuffSystem)
    self.__mapBuffSystem = mapBuffSystem

    return self
end

function ChallengeMapCharacterConfig:getConfigClass()
    return inherit(
        {
            systemMap = {
                attrSystem = "app.models.ChallengeMap.ChallengeMapCharacterProxy.ChallengeMapCharacterAttr",
                characterBuffSystem = {
                    path = "app.models.ChallengeMap.ChallengeMapCharacterProxy.ChallengeMapCharacterBuffSystemProxy",
                    args = {self.__mapBuffSystem}
                }
            }
        },
        require("app.FightSystem.FightRole.CharacterConfigs.DefaultCharacterConfig")
    )
end

return newClass("ChallengeMapCharacterConfig", {}, ChallengeMapCharacterConfig)
00000
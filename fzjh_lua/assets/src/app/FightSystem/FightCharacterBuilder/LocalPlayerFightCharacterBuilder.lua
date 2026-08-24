--[[
    author:Seven
    time:2023-02-20 21:30:37
    desc: 本地玩家战斗角色建造器
]]
local newClass = require("third.class.NewClass")

local APlayerFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.PlayerBuilder.APlayerFightCharacterBuilder")

--@SuperType [src.app.FightSystem.FightCharacterBuilder.PlayerBuilder.APlayerFightCharacterBuilder#APlayerFightCharacterBuilder]
local LocalPlayerFightCharacterBuilder = {}

function LocalPlayerFightCharacterBuilder:create(...)
    return LocalPlayerFightCharacterBuilder.new():__init(...)
end

function LocalPlayerFightCharacterBuilder:__init(role, carrybuffs)
    self:setRole(role)

    self.__carrybuffs = carrybuffs or {}

    return self
end

--@desc: 战斗角色系统配置类
--@author:Seven
--@time:2024-01-24 10:56:32
function LocalPlayerFightCharacterBuilder:__getCharacterConfigClass()
    return require("app.FightSystem.FightRole.CharacterConfigs.DefaultCharacterConfig")
end

function LocalPlayerFightCharacterBuilder:__getAttrGetterConfig()
    return require("app.FightSystem.FightCharacterBuilder.PlayerBuilder.PlayerFightCharacterAttrGetterStrategyConfig"):create(self.__role)
end

return newClass("LocalPlayerFightCharacterBuilder", {APlayerFightCharacterBuilder}, LocalPlayerFightCharacterBuilder)
000000000
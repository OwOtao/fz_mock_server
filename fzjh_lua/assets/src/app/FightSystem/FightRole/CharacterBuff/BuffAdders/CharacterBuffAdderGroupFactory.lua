--[[
    author:Seven
    time:2023-03-09 21:24:57
    desc:
]]
local CharacterBuffAdderGroupFactory = {}

--@desc: 获取主动添加器
--@author:Seven
--@time:2023-03-09 21:34:30
--@buffLauncherId:buff 添加器id
--@character:[src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@return [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderGroups.ActiveBuffAdderGroup#ActiveBuffAdderGroup]
function CharacterBuffAdderGroupFactory:getActiveBuffAdderGroup(buffLauncherId, character, fight)
    local ActiveBuffAdderGroup = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderGroups.ActiveBuffAdderGroup")

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderGroups.ActiveBuffAdderGroup#ActiveBuffAdderGroup]
    local adderGroup = ActiveBuffAdderGroup:create()

    adderGroup:setCharacter(character)

    adderGroup:setFight(fight)

    adderGroup:initAdderGroup(buffLauncherId)

    return adderGroup
end

--@desc:获取被动buff添加器
--@author:Seven
--@time:2023-03-09 21:33:16
--@buffLauncherId:buff 添加器id
--@character:[src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@dynamicArgMap: 动态参数
--@return [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderGroups.AutoBuffAdderGroup#AutoBuffAdderGroup]
function CharacterBuffAdderGroupFactory:getAutoBuffAdderGroup(buffLauncherId, character, fight, customDynamicArgMap)
    local AutoBuffAdderGroup = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderGroups.AutoBuffAdderGroup")

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderGroups.AutoBuffAdderGroup#AutoBuffAdderGroup]
    local adderGroup = AutoBuffAdderGroup:create()

    adderGroup:setCharacter(character)

    adderGroup:setFight(fight)

    adderGroup:initAdderGroup(buffLauncherId, Helper:getDef(customDynamicArgMap, {}))

    return adderGroup
end

--@desc:
--@author:Seven
--@time:2023-03-09 21:35:40
--@buffLauncherId:buff 添加器id
--@character:[src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@return [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderGroups.EnterFightBuffAdderGroup#EnterFightBuffAdderGroup]
function CharacterBuffAdderGroupFactory:getEnterFightBuffAdderGroup(buffLauncherId, character, fight)
    local EnterFightBuffAdderGroup = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderGroups.EnterFightBuffAdderGroup")

    --@RefType[src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderGroups.EnterFightBuffAdderGroup#EnterFightBuffAdderGroup]
    local adderGroup = EnterFightBuffAdderGroup:create()

    adderGroup:setCharacter(character)

    adderGroup:setFight(fight)

    adderGroup:initAdderGroup(buffLauncherId)

    return adderGroup
end

return CharacterBuffAdderGroupFactory
0000000
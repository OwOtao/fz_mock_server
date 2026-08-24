--[[
    author:Seven
    time:2026-01-12
    desc: 战斗buff添加器抽象基类
]]
local newClass = require("third.class.NewClass")

local AFightCharacterBuffAdder = {}

--@desc: 设置该添加器拥有者
--@author:Seven
--@time:2026-01-12
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AFightCharacterBuffAdder:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

--@desc: 获得当前拥有者
--@author:Seven
--@time:2026-01-12
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AFightCharacterBuffAdder:getCharacter()
    return self.__character
end

--@desc: 设置战场
--@author:Seven
--@time:2026-01-12
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
function AFightCharacterBuffAdder:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
end

--@desc: 获得当前战场
--@author:Seven
--@time:2026-01-12
--@return [src.app.FightSystem.Fight.BattleSystem#Fight]
function AFightCharacterBuffAdder:getFight()
    return self.__fight
end

--@desc: 获取添加Buff节点
--@author:Seven
--@time:2026-01-12
function AFightCharacterBuffAdder:getAddBuffNodes()
    error("AFightCharacterBuffAdder:getAddBuffNodes() 请在子类中实现")
end

--@desc: 获取要添加的BuffID
--@author:Seven
--@time:2026-01-12
function AFightCharacterBuffAdder:getAddBuffId()
    error("AFightCharacterBuffAdder:getAddBuffId() 请在子类中实现")
end

--@desc: 获取buff添加目标列表
--@author:Seven
--@time:2026-01-12
--@return: array
function AFightCharacterBuffAdder:getAddBuffTargets()
    error("AFightCharacterBuffAdder:getAddBuffTargets() 请在子类中实现")
end

--@desc: 获取Buff效果参数1
--@author:Seven
--@time:2026-01-12
function AFightCharacterBuffAdder:getAddBuffdynamicArg1()
    error("AFightCharacterBuffAdder:getAddBuffdynamicArg1() 请在子类中实现")
end

--@desc: 获取Buff效果参数2
--@author:Seven
--@time:2026-01-12
function AFightCharacterBuffAdder:getAddBuffdynamicArg2()
    error("AFightCharacterBuffAdder:getAddBuffdynamicArg2() 请在子类中实现")
end

--@desc: 获取Buff效果参数3
--@author:Seven
--@time:2026-01-12
function AFightCharacterBuffAdder:getAddBuffdynamicArg3()
    error("AFightCharacterBuffAdder:getAddBuffdynamicArg3() 请在子类中实现")
end

--@desc: 获取Buff效果参数4
--@author:Seven
--@time:2026-01-12
function AFightCharacterBuffAdder:getAddBuffdynamicArg4()
    error("AFightCharacterBuffAdder:getAddBuffdynamicArg4() 请在子类中实现")
end

--@desc: 获取Buff添加目标类型(由子类实现)
--@author:Seven
--@time:2026-01-12
--@return: 目标类型编号
function AFightCharacterBuffAdder:getAddBuffTargetType()
    error("AFightCharacterBuffAdder:getAddBuffTargetType() 请在子类中实现")
end

--@desc: 获取buff添加目标列表
--@author:Seven
--@time:2026-01-12
--@return: array
function AFightCharacterBuffAdder:getAddBuffTargets()
    local list = {}
    local targetTypes = self:getAddBuffTargetType()

    if targetTypes == 0 then
        table.insert(list, self.__character)
    elseif targetTypes == 1 then
        local teammates = self.__fight:getTeammates(self.__character:getId())
        if not MapIsEmpty(teammates) then
            for i, v in ipairs(teammates) do
                table.insert(list, v)
            end
        end
    elseif targetTypes == 2 then
        local characters = self.__fight:getTeamCharacters(self.__character:getTeamId())
        for i, v in ipairs(characters) do
            table.insert(list, v)
        end
    elseif targetTypes == 10 then
        table.insert(list, self.__character:getTarget())
    elseif targetTypes == 11 then
        local attackTarget = self.__character:getTarget()
        local teammates = self.__fight:getTeammates(attackTarget:getId())
        if not MapIsEmpty(teammates) then
            for i, v in ipairs(teammates) do
                table.insert(list, v)
            end
        end
    elseif targetTypes == 12 then
        local attackTarget = self.__character:getTarget()
        local characters = self.__fight:getTeamCharacters(attackTarget:getTeamId())
        for i, v in ipairs(characters) do
            table.insert(list, v)
        end
    else
        error("AFightCharacterBuffAdder:getAddBuffTargets() 获取buff添加器添加目标类型错误：" .. tostring(targetTypes))
    end

    return list
end

return newClass("AFightCharacterBuffAdder", {}, AFightCharacterBuffAdder)
00000000
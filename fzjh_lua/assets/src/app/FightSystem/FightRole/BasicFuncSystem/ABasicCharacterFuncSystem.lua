local interface = require("third.class.interface")

local ICharacterFuncSystem = {}

function ICharacterFuncSystem:onInit()
end

function ICharacterFuncSystem:onDestory()
end

function ICharacterFuncSystem:onUpdate(ft)
end

ICharacterFuncSystem = interface("ICharacterFuncSystem", ICharacterFuncSystem)

local abstract = require("third.class.abstract")

--[[
    author:Seven
    time:2022-07-05 10:07:55
    desc: 角色相关系统基础类
]]
--@SuperType [src.app.FightSystem.CharacterSystem.ABasicCharacterFuncSystem#ICharacterFuncSystem]
local ABasicCharacterFuncSystem = {}

--@desc: 设置角色
--@author:Seven
--@time:2022-07-05 10:28:47
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ABasicCharacterFuncSystem:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

function ABasicCharacterFuncSystem:setName(name)
    self.__name = name
end

function ABasicCharacterFuncSystem:getName()
    if self.__name == nil then
        assert(false, "角色系统未命名！！")
    end
    return self.__name
end

function ABasicCharacterFuncSystem:init()
    self:onInit()
end

function ABasicCharacterFuncSystem:destory()
    self:onDestory()
end

function ABasicCharacterFuncSystem:onUpdate(ft)
end

function ABasicCharacterFuncSystem:update(ft)
    self:onUpdate(ft)
end

return abstract("ABasicCharacterFuncSystem", {ICharacterFuncSystem}, ABasicCharacterFuncSystem)
000
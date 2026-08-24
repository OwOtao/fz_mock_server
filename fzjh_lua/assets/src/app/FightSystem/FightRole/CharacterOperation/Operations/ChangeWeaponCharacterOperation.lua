--[[
    author:Seven
    time:2023-12-20 10:57:50
    desc: 武器切换操作
]]
local newClass = require("third.class.NewClass")

local ACharacterOperation = require("app.FightSystem.FightRole.CharacterOperation.ACharacterOperation")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.FightRole.CharacterOperation.ACharacterOperation#ACharacterOperation]
local ChangeWeaponCharacterOperation = {}

function ChangeWeaponCharacterOperation:create(...)
    return ChangeWeaponCharacterOperation.new():__init(...)
end

function ChangeWeaponCharacterOperation:ctor()
    self:setCharacterOperationType(FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_CHANGE_WEAPON)
end

function ChangeWeaponCharacterOperation:canDoOperation()
    return
end

function ChangeWeaponCharacterOperation:doOperation()
end

return newClass("ChangeWeaponCharacterOperation", {ACharacterOperation}, ChangeWeaponCharacterOperation)
00000000000
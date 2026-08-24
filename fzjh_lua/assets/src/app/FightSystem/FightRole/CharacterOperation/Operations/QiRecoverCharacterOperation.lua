--[[
    author:Seven
    time:2023-12-20 10:57:50
    desc: 武器切换操作
]]
local newClass = require("third.class.NewClass")

local ACharacterOperation = require("app.FightSystem.FightRole.CharacterOperation.ACharacterOperation")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.FightRole.CharacterOperation.ACharacterOperation#ACharacterOperation]
local QiRecoverCharacterOperation = {}

function QiRecoverCharacterOperation:create()
    return QiRecoverCharacterOperation.new()
end

function QiRecoverCharacterOperation:ctor()
    self:setCharacterOperationType(FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_QI_RECOVER)
end

function QiRecoverCharacterOperation:canDoOperation()
    return
end

function QiRecoverCharacterOperation:doOperation()
end

return newClass("QiRecoverCharacterOperation", {ACharacterOperation}, QiRecoverCharacterOperation)
00000
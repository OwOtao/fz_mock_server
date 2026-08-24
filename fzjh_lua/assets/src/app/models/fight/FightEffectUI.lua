local newClass = require("third.class.NewClass")
local isImpl = require("third.assertIsInstance.assertIsInstance")

local FightEffectUI = {
    --效果id
    __effectId = nil,
    --效果释放者效果ui信息
    __effectOwnerUIInfo = {},
    --效果生效者效果ui信息
    __effectObjectUIInfo = {}
}

function FightEffectUI:create(effectId)
    local p = FightEffectUI.new()
    p:init(effectId)
    return p
end

function FightEffectUI:init(effectId)
    self.__effectId = effectId
end

--info "app.models.fight.EffectUIInfo"类对象
function FightEffectUI:addEffectObjectUIInfo(info)
    table.insert(self.__effectObjectUIInfo, isImpl(info, require("app.models.fight.EffectUIInfo")))
end

--info "app.models.fight.EffectUIInfo"类对象
function FightEffectUI:addEffectOwnerUIInfo(info)
    table.insert(self.__effectOwnerUIInfo, isImpl(info, require("app.models.fight.EffectUIInfo")))
end

function FightEffectUI:getEffectId()
    return self.__effectId
end

function FightEffectUI:getEffectObjectUIInfo()
    return self.__effectObjectUIInfo
end

function FightEffectUI:getEffectOwnerUIInfo()
    return self.__effectOwnerUIInfo
end

return newClass("FightEffectUI", {}, FightEffectUI)
0
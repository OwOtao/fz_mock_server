--

local newClass = require("third.class.NewClass")

local Hurt = require("app.FightSystem.AttackModel.Hurt")

local AllocHurt = {}

function AllocHurt:create(hurts, totalWeight, allocWeights)
    local p = self:new()
    p:init(hurts, totalWeight, allocWeights)
    return p
end

function AllocHurt:init(hurts, totalWeight, allocWeight)
    self.__hurts = hurts
    self.__totalWeight = totalWeight
    self.__allocWeight = allocWeight
end

function AllocHurt:alloc()
    local count = #self.__hurts

    local newHurts = {}
    for i = 1, count do
        --@RefType [src.app.FightSystem.AttackModel.Hurt#Hurt]
        local hurtRes = self.__hurts[i]

        --@RefType [src.app.FightSystem.AttackModel.Hurt#Hurt]
        local newHurt = hurtRes:allocByWeight(self.__totalWeight, self.__allocWeight)

        table.insert(newHurts, newHurt)
    end

    return newHurts
end

return newClass("AllocHurt", {}, AllocHurt)
000000000000000
local NewClass = require("third.class.NewClass")
local assertIsInstance = require("third.assertIsInstance.assertIsInstance")
local ISkillUniverse = require("app.models.SelfCreatedSkillSystem.ISkillUniverse")
local SelfCreatedZhao = require("app.models.SelfCreatedSkillSystem.SelfCreatedZhao.SelfCreatedZhao")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")

local SkillUniverse = {
    __universeValues = nil
}

function SkillUniverse:create(zhaos)
    local p = SkillUniverse.new()
    p:setZhaos(zhaos)

    return p
end

function SkillUniverse:setZhaos(zhaos)
    self.zhaos = zhaos
end

function SkillUniverse:getUniverseValue(attrIndex)
    local value = 0
    if self.__universeValues == nil then
        self.__universeValues = {}
        if not MapIsEmpty(self.zhaos) then
            for i, zhaoData in ipairs(self.zhaos) do
                local zhao = SelfCreatedZhao:create(zhaoData)
                table.insert(self.__universeValues,zhao:getUniverseValue(attrIndex))
            end
        end
        table.sort(self.__universeValues,function (a,b)
            return tonumber(a) > tonumber(b)
        end)    
    end

    local zhaoAddOrders = SelfCreatedSkillManager:getZhaoAddOrders()

    for i,v in ipairs(self.__universeValues) do
        local addOrder = Helper:getDef(zhaoAddOrders[i],zhaoAddOrders[#zhaoAddOrders])
        value = value + addOrder*v
    end

    return value/100
end

return NewClass("SkillUniverse", { ISkillUniverse }, SkillUniverse)000000000000000
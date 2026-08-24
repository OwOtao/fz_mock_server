local class = require("third.class.NewClass")

local DreamMapRoleAttr = require("app.models.MapRole.DreamMapRoleAttr")

local FondFightPlayerBuilder = require("app.models.FondDream.MapBattle.FondFightPlayerBuilder")

local FoodDreamMapRoleAttr = {}

function FoodDreamMapRoleAttr:create()
    return FoodDreamMapRoleAttr:new()
end

function FoodDreamMapRoleAttr:ctor()
end

function FoodDreamMapRoleAttr:setRole(role)
    self.__role = role

    self.__character = FondFightPlayerBuilder:create(self.__role):buildCharacter()
end

function FoodDreamMapRoleAttr:getAtk()
    return "【攻击力】 "..tostring(Helper:mathFloor(self.__character:getAtk()))
end

function FoodDreamMapRoleAttr:getDodge()
    return "【躲闪力】 "..tostring(Helper:mathFloor(self.__character:getDodgeForce()))
end

function FoodDreamMapRoleAttr:getFangYu()
    return "【防御力】 "..tostring(Helper:mathFloor(self.__character:getDef()))
end

function FoodDreamMapRoleAttr:getDamage()
    return "【伤害力】 "..tostring(Helper:mathFloor(self.__character:getAttr("damage")))
end

function FoodDreamMapRoleAttr:getFangHu()
    return "【防护力】 "..tostring(Helper:mathFloor(self.__character:getProtect()))
end

return class("FoodDreamMapRoleAttr", {DreamMapRoleAttr}, FoodDreamMapRoleAttr)
0
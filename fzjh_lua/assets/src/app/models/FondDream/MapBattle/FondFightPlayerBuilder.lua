--[[
    author:Seven
    time:2024-01-24 14:15:17
    desc:
]]
local LocalPlayerFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.LocalPlayerFightCharacterBuilder")

local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.FightCharacterBuilder.PlayerBuilder.IFightCharacterAttrStrategyConfig#IFightCharacterAttrStrategyConfig]
local FondFightCharacterAttrGetterStrategyConfig = {}

function FondFightCharacterAttrGetterStrategyConfig:create(...)
    return FondFightCharacterAttrGetterStrategyConfig.new():__init(...)
end

function FondFightCharacterAttrGetterStrategyConfig:__init(role)
    self.__role = role

    self.__dict = {
        id = self.__role:getAttr("id"),
        name = self.__role:getAttr("name"),
        lv = self.__role:getAttr("lv"),
        jingMax = self.__role:getJingMax(),
        looks = self.__role:getFinalAttr("looks"),
        age = self.__role:getAge(),
        qi = Helper:mathFloor(self.__role:getAttr("qi")),
        qiMax = Helper:mathFloor(self.__role:getFinalAttr("qiMax") * self.__role:getAttr("qiPercent")),
        qiLimit = Helper:mathFloor(self.__role:getFinalAttr("qiMax")),
        neili = Helper:mathFloor(self.__role:getAttr("neili")),
        neiliMax = Helper:mathFloor(self.__role:getFinalAttr("neiliMax")),
        neiliLimit = Helper:mathFloor(self.__role:getFinalAttr("neiliMax")),
        str = self.__role:getAttr("str"),
        dex = self.__role:getAttr("dex"),
        con = self.__role:getAttr("con"),
        int = self.__role:getAttr("int"),
        strCondSkill = self.__role:getFinalAttr("currStr"),
        dexCondSkill = self.__role:getFinalAttr("currDex"),
        conCondSkill = self.__role:getFinalAttr("currCon"),
        intCondSkill = self.__role:getFinalAttr("currInt"),
        zhengqi = self.__role:getFinalAttr("zhengqi"),
        plusPoint = self.__role:getAttr("jiaLi")
    }

    local species

    if self.__role:getAttr("sex") == "男" then
        species = FightCommons.CHARACTER_SPECIES.MALE
    else
        species = FightCommons.CHARACTER_SPECIES.FEMALE
    end

    self.__dict.species = species

    self.__dict.familyID = self.__role:getFamilyId()

    return self
end

function FondFightCharacterAttrGetterStrategyConfig:getRoleAttr(name)
    if self.__dict[name] == nil then
        assert(false, "FondFightCharacterAttrGetterStrategyConfig 找不到 属性 name ：" .. name)
    end

    return self.__dict[name]
end

FondFightCharacterAttrGetterStrategyConfig = newClass("FondFightCharacterAttrGetterStrategyConfig", {LocalPlayerFightCharacterBuilder}, FondFightCharacterAttrGetterStrategyConfig)

--@SuperType [src.app.FightSystem.FightCharacterBuilder.LocalPlayerFightCharacterBuilder#LocalPlayerFightCharacterBuilder]
local FondFightPlayerBuilder = {}

function FondFightPlayerBuilder:create(...)
    return FondFightPlayerBuilder.new():__init(...)
end

function FondFightPlayerBuilder:__init(role)
    self:setRole(role)

    return self
end

function FondFightPlayerBuilder:__getAttrGetterConfig()
    return FondFightCharacterAttrGetterStrategyConfig:create(self.__role)
end

return newClass("FondFightPlayerBuilder", {LocalPlayerFightCharacterBuilder}, FondFightPlayerBuilder)
000000000000
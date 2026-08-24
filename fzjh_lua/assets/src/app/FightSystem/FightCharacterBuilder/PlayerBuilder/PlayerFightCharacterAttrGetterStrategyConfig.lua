--[[
    author:Seven
    time:2024-01-23 21:20:50
    desc: 玩家属性获取策略配置
]]
local newClass = require("third.class.NewClass")
local IFightCharacterAttrStrategyConfig = require("app.FightSystem.FightCharacterBuilder.PlayerBuilder.IFightCharacterAttrStrategyConfig")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.FightCharacterBuilder.PlayerBuilder.IFightCharacterAttrStrategyConfig#IFightCharacterAttrStrategyConfig]
local PlayerFightCharacterAttrGetterStrategyConfig = {}

function PlayerFightCharacterAttrGetterStrategyConfig:create(...)
    return PlayerFightCharacterAttrGetterStrategyConfig.new():__init(...)
end

function PlayerFightCharacterAttrGetterStrategyConfig:__init(role)
    self.__role = role

    self.__dict = {
        id = self.__role:getAttr("userid"),
        name = self.__role:getAttr("name"),
        lv = self.__role:getAttr("lv"),
        jingMax = self.__role:getJingMax(),
        looks = self.__role:getFinalAttr("looks"),
        age = self.__role:getAge(),
        qi = Helper:mathFloor(self.__role:getAttr("qi")),
        qiMax = Helper:mathFloor(self.__role:getFinalAttr("qiMax") * self.__role:getAttr("qiPercent")),
        qiLimit = Helper:mathFloor(self.__role:getFinalAttr("qiMax")),
        neili = Helper:mathFloor(self.__role:getAttr("neili")),
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

    local neiliMax = Helper:mathFloor(self.__role:getFinalAttr("neiliMax"))
    local neiliLimit = neiliMax * 2

    self.__dict.neiliMax = neiliMax
    self.__dict.neiliLimit = neiliLimit

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

function PlayerFightCharacterAttrGetterStrategyConfig:getRoleAttr(name)
    if self.__dict[name] == nil then
        assert(false, "PlayerFightCharacterAttrGetterStrategyConfig 找不到 属性 name ：" .. name)
    end

    return self.__dict[name]
end

return newClass("PlayerFightCharacterAttrGetterStrategyConfig", {IFightCharacterAttrStrategyConfig}, PlayerFightCharacterAttrGetterStrategyConfig)
00000000
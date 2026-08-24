local newClass = require("third.class.NewClass")

local CharacterByRoleFactory = require("app.FightSystem.Factory.CharacterFactory.CharacterByRoleFactory")

--@SuperType [src.app.FightSystem.Factory.CharacterFactory.ICharacterFcatory#ICharacterFcatory]
local ChallengeCharacterByRoleFactory = {}

function ChallengeCharacterByRoleFactory:create(role)
    local p = ChallengeCharacterByRoleFactory.new()
    p:init(role)
    return p
end

function ChallengeCharacterByRoleFactory:init(role)
    self.__role = role
end

function ChallengeCharacterByRoleFactory:__initAttr(character)
    --@RefType [src.app.FightSystem.FightRole.CharacterAttr.ChallengeMapPlayerAttr#ChallengeMapPlayerAttr]
    local playerAttr = require("app.FightSystem.FightRole.CharacterAttr.ChallengeMapPlayerAttr"):create(character)

    playerAttr:setNormalBuffSystem(self.__normalBuffSystem)

    playerAttr:setAttr("id", self.__role:getAttr("id"))

    playerAttr:setAttr("name", self.__role:getAttr("name"))

    playerAttr:setAttr("lv", self.__role:getAttr("lv"))

    playerAttr:setAttr("jingMax", self.__role:getJingMax())

    playerAttr:setAttr("looks", self.__role:getFinalAttr("looks"))

    playerAttr:setAttr("age", self.__role:getAge())

    playerAttr:setAttr("qi", Helper:mathFloor(self.__role:getAttr("qi")))
    playerAttr:setAttr("qiMax", Helper:mathFloor(self.__role:getFinalAttr("qiMax") * self.__role:getAttr("qiPercent")))
    playerAttr:setAttr("qiLimit", Helper:mathFloor(self.__role:getFinalAttr("qiMax")))

    playerAttr:setAttr("neili", Helper:mathFloor(self.__role:getAttr("neili")))
    playerAttr:setAttr("neiliMax", Helper:mathFloor(self.__role:getFinalAttr("neiliMax")))
    playerAttr:setAttr("neiliLimit", Helper:mathFloor(self.__role:getFinalAttr("neiliMax")))

    playerAttr:setAttr("str", self.__role:getAttr("str"))
    playerAttr:setAttr("dex", self.__role:getAttr("dex"))
    playerAttr:setAttr("con", self.__role:getAttr("con"))
    playerAttr:setAttr("int", self.__role:getAttr("int"))

    playerAttr:setAttr("strCondSkill", self.__role:getFinalAttr("currStr"))
    playerAttr:setAttr("dexCondSkill", self.__role:getFinalAttr("currDex"))
    playerAttr:setAttr("conCondSkill", self.__role:getFinalAttr("currCon"))
    playerAttr:setAttr("intCondSkill", self.__role:getFinalAttr("currInt"))

    playerAttr:setAttr("zhengqi", self.__role:getFinalAttr("zhengqi"))

    playerAttr:setAttr("plusPoint", self.__role:getAttr("jiaLi"))

    return playerAttr
end

return newClass("ChallengeCharacterByRoleFactory", {CharacterByRoleFactory}, ChallengeCharacterByRoleFactory)
000000000000
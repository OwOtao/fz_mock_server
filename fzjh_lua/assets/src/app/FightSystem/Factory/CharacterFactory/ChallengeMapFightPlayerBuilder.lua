local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local EquipmentFactory = require("app.FightSystem.Factory.EquipmentFactory.EquipmentFactory")

local SkillFactory = require("app.FightSystem.Factory.FightSkillFactory.SkillFactory")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local ActiveFactory = require("app.FightSystem.Factory.FightSkillFactory.ActiveFactory")

local CharacterByRoleFactory = require("app.FightSystem.Factory.CharacterFactory.CharacterByRoleFactory")

--@SuperType [src.app.FightSystem.Factory.CharacterFactory.CharacterByRoleFactory#CharacterByRoleFactory]
local ChallengeMapFightPlayerBuilder = {}

function ChallengeMapFightPlayerBuilder:create(role)
    local p = ChallengeMapFightPlayerBuilder.new()
    p:init(role)
    return p
end

function ChallengeMapFightPlayerBuilder:init(role)
    self.__role = role
end

function ChallengeMapFightPlayerBuilder:setShenBingBuffArray(buffArray)
    self.__buffArray = buffArray
end

function ChallengeMapFightPlayerBuilder:setNormalBuffSystem(system)
    self.__normalBuffSystem = system
end

function ChallengeMapFightPlayerBuilder:__initAttr(character)
    --@RefType [src.app.FightSystem.FightRole.CharacterAttr.PlayerAttr#PlayerAttr]
    local playerAttr = require("app.FightSystem.FightRole.CharacterAttr.PlayerAttr"):create(character)

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

    local neiliMax = Helper:mathFloor(self.__role:getFinalAttr("neiliMax"))
    
    playerAttr:setAttr("neiliMax", neiliMax)

    playerAttr:setAttr("neiliLimit", neiliMax * 2)

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

return newClass("ChallengeMapFightPlayerBuilder", {CharacterByRoleFactory}, ChallengeMapFightPlayerBuilder)
000000000000
local class = require("third.class.NewClass")

local ChallengeMapRoleAttr = {}

function ChallengeMapRoleAttr:create()
    return ChallengeMapRoleAttr:new()
end

function ChallengeMapRoleAttr:ctor()
end

function ChallengeMapRoleAttr:setRole(role)
    self._role = role
    self:__initChallengeRole()
end

function ChallengeMapRoleAttr:__initChallengeRole()
    -- local ChallengeCharacterByRoleFactory = require("app.FightSystem.Factory.CharacterFactory.ChallengeCharacterByRoleFactory")
    -- local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
    -- local builder = ChallengeCharacterByRoleFactory:create(self._role)

    -- ChallengeMapSystem:getInstance():removeFistFootBuffs(self._role)

    -- local equipWeapon = self._role:getEquipByName("weapon")
	-- if equipWeapon == nil or equipWeapon == "拳脚" then
    --     local fistFootEffects = self._role:getPrepFistFootEffects()
    --     local buffArray = {}
    --     for i, v in ipairs(fistFootEffects) do
    --         local buffId = v:getPermanentBuffId()
    --         if buffId ~= 0 then
    --             ChallengeMapSystem:getInstance():addBuff(buffId,self._role)
    --             ChallengeMapSystem:getInstance():recordFistFootBuff(buffId)
    --         end
    --     end
    -- end

    -- builder:setNormalBuffSystem(ChallengeMapSystem:getInstance():getBuffSystem())

    local ChallengeMapCharacterRoleInfoBuilder = require("app.models.ChallengeMap.ChallengeMapCharacterProxy.ChallengeMapCharacterRoleInfoBuilder")
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local character = ChallengeMapCharacterRoleInfoBuilder:create(self._role):buildCharacter()

    self.__challengeRole =character
end

function ChallengeMapRoleAttr:getRole()
    return self._role
end

function ChallengeMapRoleAttr:getRoleAttr(attr)
    return self.__challengeRole:getAttr(attr)
end

function ChallengeMapRoleAttr:getRoleAtk()
    return self.__challengeRole:getAttr("atk")
end

function ChallengeMapRoleAttr:getRoleDodge()
    return self.__challengeRole:getAttr("dodgeForce")
end

function ChallengeMapRoleAttr:getRoleDef()
    return self.__challengeRole:getAttr("def")
end

function ChallengeMapRoleAttr:getRolePowerDamage()
    return self.__challengeRole:getAttr("damage")
end

function ChallengeMapRoleAttr:getRoleFangHu()
    return self.__challengeRole:getAttr("protect")
end


return class("ChallengeMapRoleAttr", {}, ChallengeMapRoleAttr)
00000000000
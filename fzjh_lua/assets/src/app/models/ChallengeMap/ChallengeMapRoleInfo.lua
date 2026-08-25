local class = require("third.class.NewClass")
local SkillConst = require("app.models.skill.SkillConst")
local SKILL_SECOND_TYPE = SkillConst.SkillSecondType
local ChallengeMapRoleInfo = {}

local CanNotDaZuo = {
    NEIGONG = "需要学习基本内功才能打坐回复",
    XINGZHEN = "受行针走穴影响，暂时无法运功打坐。"
}

local CanNotHuiFu = {
    NEILI = "内力不足，不能回血",
    QIMAX = "你现在气血充沛。",
    INJURED = "你受伤了，无法继续回复。"
}

local CanNotLiaoShang = {
    NOTINJURED = "你没有受伤。",
    NEILI = "内力不足，不能疗伤"
}

local CanNotUseCsj = {
    QIMAX = "你现在气血充沛。"
}

function ChallengeMapRoleInfo:create()
    return ChallengeMapRoleInfo:new()
end

function ChallengeMapRoleInfo:ctor()
end

function ChallengeMapRoleInfo:setRole(role)
    self._role = role
    self:__initChallengeRole()
end

function ChallengeMapRoleInfo:getRole()
    return self._role
end

function ChallengeMapRoleInfo:getRoleName()
    return self._role:getAttr("name")
end

function ChallengeMapRoleInfo:getRoleChengHao()
    return self._role:getChengHaoColorName()
end

function ChallengeMapRoleInfo:getRoleLv()
    return self._role:getLv()
end

function ChallengeMapRoleInfo:getRoleExp()
    return self._role:getExp()
end

function ChallengeMapRoleInfo:getRoleFamilyName()
    return self._role:getFamilyName()
end

function ChallengeMapRoleInfo:getRoleAgeDesc()
    return self._role:getAgeWithChinese()
end

function ChallengeMapRoleInfo:getRoleIsDaZuo()
    return self._role:isInCurrState(ROLE_CURR_STATE_DAZUO)
end

function ChallengeMapRoleInfo:__initChallengeRole()
    local ChallengeMapCharacterRoleInfoBuilder = require("app.models.ChallengeMap.ChallengeMapCharacterProxy.ChallengeMapCharacterRoleInfoBuilder")
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local character = ChallengeMapCharacterRoleInfoBuilder:create(self._role):buildCharacter()

    self.__challengeRole = character

    return self.__challengeRole
end

function ChallengeMapRoleInfo:liaoShang()
    local qiMax = self._role:getFinalAttr("qiMax")
    local currQiMax = self._role:getCurrQiMax()
    -- 内力消耗
    local needNeiLi = 40 + tonumber(Helper:mathFloor(self._role:getFinalAttr("neiliMax") / 5))
    local addQiMax = needNeiLi * 1.5 * self.__challengeRole:getAttr("healthyQiMax") + 5

    self._role:setAttr("qiPercent", (addQiMax + currQiMax) / qiMax)
    self._role:addAttr("neili", -needNeiLi)
end

function ChallengeMapRoleInfo:startDaZuo()
    self.__daZuoStarTime = GetTime()
    self._role:setRoleCurrState(ROLE_CURR_STATE_DAZUO)
    self._role:setFlag("地图打坐", true)
end

function ChallengeMapRoleInfo:daZuo()
    if not self.__daZuoStarTime then
        self.__daZuoStarTime = 0
    end

    if self._role:isInCurrState(ROLE_CURR_STATE_DAZUO) and GetTime() - self.__daZuoStarTime >= 1 then
        --副本打坐每秒增加内力 = 基础打坐恢复内力 * 副本打坐恢复内力修正系数 * 特殊治疗类武学恢复内力修正系数 * 长生诀阳恢复内力修正系数 * 行针Buff恢复内力修正系数
        --基础打坐恢复内力 = ((基本内功等级/2+准备内功武学等级) * 角色打坐恢复力 + 5) * (1 + 0.005 * (先天根骨 + INT(基本内功等级/10)/2) )
        local duration = GetTime() - self.__daZuoStarTime
        local baseLv, prepLv = 0, 0
        local baseNeiGongSkill = self.__challengeRole:getBaseSkill(SKILL_SECOND_TYPE.NEI_GONG)
        local prepNeiGongSkill = self.__challengeRole:getPrepSkill(SKILL_SECOND_TYPE.NEI_GONG)
        if baseNeiGongSkill then
            baseLv = baseNeiGongSkill:getLevel()
        end
        if prepNeiGongSkill then
            prepLv = prepNeiGongSkill:getLevel()
        end

        local baseSpeed = ((baseLv / 2 + prepLv) * self.__challengeRole:getAttr("healthyNeili") + 5) * (1 + 0.005 * (self._role:getAttr("con") + Helper:mathFloor(baseLv / 10) / 2))
        local fubenFactor = 1.5
        local specialHuiFuFactor = self._role:getHuiFuSpeedRate()
        local changshengjueyang = self._role:getSkillLv("changshengjueyang")
        local changshengjueyangFactor = changshengjueyang / 5000 + 1
        local xingzhenFactor = 1 + self._role:getBuffAttr("xingzhenNeiLi")
        local pointSwitchSkillFactor = 1 + self._role:getDazuoAddition() / 100

        local finalSpeed = baseSpeed * fubenFactor * specialHuiFuFactor * changshengjueyangFactor * xingzhenFactor * pointSwitchSkillFactor

        print(
            "副本打坐每秒增加内力:",
            finalSpeed,
            "基础打坐恢复内力:",
            baseSpeed,
            "副本打坐恢复内力修正系数:",
            fubenFactor,
            "特殊治疗类武学恢复内力修正系数:",
            specialHuiFuFactor,
            "长生诀阳恢复内力修正系数:",
            changshengjueyangFactor,
            "行针Buff恢复内力修正系数",
            xingzhenFactor,
            "先天切换武学打坐恢复内力修正系数",
            pointSwitchSkillFactor
        )

        local neili = self._role:getAttr("neili")
        local neiliMax = math.floor(self._role:getFinalAttr("neiliMax"))
        neili = neili + finalSpeed * duration

        neili = math.min(neili, neiliMax * 2)

        if neili < neiliMax * 2 then
            self._role:setAttr("neili", neili)
            self.__daZuoStarTime = GetTime()
        else
            self._role:setAttr("neili", neiliMax * 2)
            self._role:removeRoleCurrState(ROLE_CURR_STATE_DAZUO)
        end
    end
end

function ChallengeMapRoleInfo:huiFu()
    local needNeiLi = 20 + tonumber(Helper:mathFloor(self._role:getFinalAttr("neiliMax") / 50))
    local addQi = needNeiLi * 1.5 * self.__challengeRole:getAttr("healthyQi") + 50
    self._role:addAttr("qi", addQi)
    self._role:addAttr("neili", -needNeiLi)
end

function ChallengeMapRoleInfo:checkCanLiaoShang()
    if self._role:getAttr("qiPercent") == 1 then
        return false, CanNotLiaoShang.NOTINJURED
    end

    local needNeiLi = 40 + tonumber(Helper:mathFloor(self._role:getFinalAttr("neiliMax") / 5))
    if self._role:getNumAttr("neili") < needNeiLi then
        return false, CanNotLiaoShang.NEILI
    end

    return true
end

function ChallengeMapRoleInfo:checkCanDaZuo()
    local baseNeiGongSkill = self.__challengeRole:getBaseSkill(SKILL_SECOND_TYPE.NEI_GONG)

    if not baseNeiGongSkill then
        return false, CanNotDaZuo.NEIGONG
    end

    local baseLv = baseNeiGongSkill:getLevel()

    if baseLv < 1 then
        return false, CanNotDaZuo.NEIGONG
    end

    if self._role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
        self._role:setFlag("地图打坐", nil)
        self._role:stopDaZuo()
        return false
    elseif self._role:getBuffAttr("xingzhenDaZuo") >= 1 then
        self._role:stopDaZuo()
        return false, CanNotDaZuo.XINGZHEN
    end

    return true
end

function ChallengeMapRoleInfo:checkCanHuiFu()
    local needNeiLi = 20 + tonumber(Helper:mathFloor(self._role:getFinalAttr("neiliMax") / 50))

    if self._role:getNumAttr("neili") < needNeiLi then
        return false, CanNotHuiFu.NEILI
    end

    if Helper:mathFloor(self._role:getNumAttr("qi")) == Helper:mathFloor(self._role:getFinalAttr("qiMax")) then
        return false, CanNotHuiFu.QIMAX
    elseif
        Helper:mathFloor(self._role:getNumAttr("qi")) == Helper:mathFloor(self._role:getCurrQiMax()) and
            Helper:mathFloor(self._role:getNumAttr("qi")) < Helper:mathFloor(self._role:getFinalAttr("qiMax"))
     then
        return false, CanNotHuiFu.INJURED
    end

    return true
end

function ChallengeMapRoleInfo:checkCanUseCsj()
    if Helper:mathFloor(self._role:getNumAttr("qi")) == Helper:mathFloor(self._role:getFinalAttr("qiMax")) and 
        self._role:getAttr("qiPercent") == 1 and
        Helper:mathFloor(self._role:getNumAttr("neili")) >= Helper:mathFloor(self._role:getFinalAttr("neiliMax")) * 2 then
    
        return false, CanNotUseCsj.QIMAX
    end

    return true
end

function ChallengeMapRoleInfo:useCsj()
    if self._role:getFlag("地图打坐") == true then
        self._role:setFlag("地图打坐", nil)
        self._role:stopDaZuo()
    end
end

return class("ChallengeMapRoleInfo", {}, ChallengeMapRoleInfo)
000000000000000
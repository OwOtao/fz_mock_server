local class = require("third.class.NewClass")
local SkillConst = require("app.models.skill.SkillConst")
local SKILL_SECOND_TYPE = SkillConst.SkillSecondType
local MapRoleAttr = {}

local CanNotDaZuo = {
    MAPID = "你当前无法打坐",
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

function MapRoleAttr:create()
    return MapRoleAttr:new()
end

function MapRoleAttr:ctor()
end

function MapRoleAttr:setRole(role)
    self.__role = role
end

function MapRoleAttr:getRole()
    return self.__role
end

function MapRoleAttr:getRoleName()
    return self.__role:getAttr("name")
end

function MapRoleAttr:getRoleChengHao()
    return self.__role:getChengHaoColorName()
end

function MapRoleAttr:getRoleLv()
    return self.__role:getLv()
end

function MapRoleAttr:getRoleExp()
    return self.__role:getExp()
end

function MapRoleAttr:getRoleFamilyName()
    return self.__role:getFamilyName()
end

function MapRoleAttr:getRoleAgeDesc()
    return self.__role:getAgeWithChinese()
end

function MapRoleAttr:getRoleIsDaZuo()
    return self.__role:isInCurrState(ROLE_CURR_STATE_DAZUO)
end

function MapRoleAttr:huiFu()
    local needNeiLi = 20 + tonumber(Helper:mathFloor(self.__role:getFinalAttr("neiliMax") / 50))
    local addQi = tonumber(needNeiLi * self.__role:getSkillFactor("neigong", "neili") / 60 + 5)
    self.__role:addAttr("qi", addQi)
    self.__role:addAttr("neili", -needNeiLi)
end

function MapRoleAttr:checkCanHuiFu()
    local needNeiLi = 20 + tonumber(Helper:mathFloor(self.__role:getFinalAttr("neiliMax") / 50))

    if self.__role:getNumAttr("neili") < needNeiLi then
        return false, CanNotHuiFu.NEILI
    end

    if Helper:mathFloor(self.__role:getNumAttr("qi")) == Helper:mathFloor(self.__role:getFinalAttr("qiMax")) then
        return false, CanNotHuiFu.QIMAX
    elseif
        Helper:mathFloor(self.__role:getNumAttr("qi")) == Helper:mathFloor(self.__role:getCurrQiMax()) and
            Helper:mathFloor(self.__role:getNumAttr("qi")) < Helper:mathFloor(self.__role:getFinalAttr("qiMax"))
     then
        return false, CanNotHuiFu.INJURED
    end

    return true
end

function MapRoleAttr:checkCanUseCsj()
    if Helper:mathFloor(self.__role:getNumAttr("qi")) == Helper:mathFloor(self.__role:getFinalAttr("qiMax")) and 
        self.__role:getAttr("qiPercent") == 1 and
        Helper:mathFloor(self.__role:getNumAttr("neili")) >= Helper:mathFloor(self.__role:getFinalAttr("neiliMax")) * 2 then
    
        return false, CanNotUseCsj.QIMAX
    end

    return true
end

function MapRoleAttr:useCsj()
    if self.__role:getFlag("地图打坐") == true then
        self.__role:setFlag("地图打坐", nil)
        self.__role:stopDaZuo()
    end
end

function MapRoleAttr:checkCanLiaoShang()
    if self.__role:getAttr("qiPercent") == 1 then
        return false, CanNotLiaoShang.NOTINJURED
    end

    local needNeiLi = 40 + tonumber(Helper:mathFloor(self.__role:getFinalAttr("neiliMax") / 5))
    if self.__role:getNumAttr("neili") < needNeiLi then
        return false, CanNotLiaoShang.NEILI
    end

    return true
end

function MapRoleAttr:liaoShang()
    local qiMax = self.__role:getFinalAttr("qiMax")
    
    local currQiMax = self.__role:getCurrQiMax()

    local needNeiLi = 40 + tonumber(Helper:mathFloor(self.__role:getFinalAttr("neiliMax") / 5))

    local addQiMax = tonumber(needNeiLi * self.__role:getSkillFactor("neigong", "neili") / 500 + 5)

    self.__role:setAttr("qiPercent", (addQiMax + currQiMax) / qiMax)
    
    self.__role:addAttr("neili", -needNeiLi)
end

function MapRoleAttr:checkCanDaZuo()
    local mapLayer = MainControllLayer:getLayer("MapLayer")

    if mapLayer._currMap and mapLayer._currMap.id == "fb220" then 
        return false, CanNotDaZuo.MAPID
    end

    if self.__role:getSkillExp("jibenneigong") < 1 then
        return false, CanNotDaZuo.NEIGONG
    end

    if self.__role:getBuffAttr("xingzhenDaZuo") >= 1 then
        self.__role:stopDaZuo()
        return false, CanNotDaZuo.XINGZHEN
    end

    return true
end

function MapRoleAttr:daZuo()
    self.__role:setFlag("地图打坐", true)
    self.__role:daZuo()
end

return class("MapRoleAttr", {}, MapRoleAttr)
00000000
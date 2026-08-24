local class = require("third.class.NewClass")
local SkillConst = require("app.models.skill.SkillConst")

local XiSuiJingUtil = {}

function XiSuiJingUtil:create()
    return XiSuiJingUtil:new()
end

function XiSuiJingUtil:ctor()
    self:__initSkill()
end

function XiSuiJingUtil:setRole(role)
    self.__role = role
end

function XiSuiJingUtil:getSkillName()
    return self.__skill:getName()
end

function XiSuiJingUtil:getSkillStageDsc()
    return self.__skill:getStageDsc(self.__role)
end

function XiSuiJingUtil:getSkillDsc()
    return self.__skill:getDsc()
end

function XiSuiJingUtil:getSkillId()
    return self.__skill.id
end

function XiSuiJingUtil:getLv(exp)
    if not exp then
        exp = self.__role:getSkillExp(self:getSkillId())
    end

    return self.__skill:getLv(exp)
end

function XiSuiJingUtil:getExp(lv)
    return self.__skill:getExp(lv)
end

function XiSuiJingUtil:getSkillExp()
    return self.__role:getSkillExp(self:getSkillId())
end

function XiSuiJingUtil:xiSui(times)
    local needJing = self:__getXiSuiNeedJing() * times
    local needPot = self:__getXiSuiNeedPot() * times
    local addExp = self:__getOnceXiSuiAddExp() * times
    local currExp = self:getSkillExp()
    local skillId = self:getSkillId()

    if addExp + currExp > self:getMaxExp() then
        addExp = self:getMaxExp() - currExp
    end

    local skill = self.__role:getSkill(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM))
    skill.exp = skill.exp + addExp
    
    self.__role:addAttr("jing",-needJing)
    self.__role:addAttr("pot",-needPot)

    return addExp,needJing,needPot
end

function XiSuiJingUtil:checkCanXiSui()
    local needJing = self:__getXiSuiNeedJing()
    local needPot = self:__getXiSuiNeedPot()
    local roleJing = self.__role:getAttr("jing")
    local rolePot = self.__role:getAttr("pot")

    if roleJing < needJing then
        return false,SkillConst.ZhiShiSkillParams.TIPS_UPGRADE_JINGLACK
    end

    if rolePot < needPot then
        return false,SkillConst.ZhiShiSkillParams.TIPS_UPGRADE_POTLACK
    end

    return true
end

function XiSuiJingUtil:getCanXiSuiTimes()
    local needJing = self:__getXiSuiNeedJing()
    local needPot = self:__getXiSuiNeedPot()
    local roleJing = self.__role:getAttr("jing")
    local rolePot = self.__role:getAttr("pot")

    local times = Helper:mathFloor(roleJing/needJing)

    if times < 1 then
        return 0
    end

    if times > rolePot/needPot then
        times = Helper:mathFloor(rolePot/needPot)
    end

    local onceExp = self:__getOnceXiSuiAddExp()
    local currExp = self:getSkillExp()
    local maxExp = self:getMaxExp()
    local addExp = onceExp * times

    if maxExp <  currExp + addExp then
        times = math.ceil((maxExp - currExp) / onceExp)
    end

    return times
end

function XiSuiJingUtil:getSkillStageInfo()
    return self.__skill:getSkillStageInfoByExp(self:getSkillExp())
end

function XiSuiJingUtil:getSkillStageInfoById(id)
    return self.__skill:getSkillStageInfoById(id)
end

function XiSuiJingUtil:checkIsMaxSkillStage()
    local maxStage = self.__skill:getSkillStageMax()
    local stageInfo = self:getSkillStageInfo()
    return maxStage == stageInfo.id
end


function XiSuiJingUtil:__initSkill()
    local xisuijing = Skill:getSkill(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM))
    self.__skill = xisuijing
end

function XiSuiJingUtil:__getOnceXiSuiAddExp()
    return self.__skill:xiSui(self.__role:getAttr("currInt"))
end

function XiSuiJingUtil:__getXiSuiNeedJing()
    return self.__skill:getXiSuiNeedJing()
end

function XiSuiJingUtil:__getXiSuiNeedPot()
    return self.__skill:getXiSuiNeedPot(self.__role:getAttr("currInt"))
end

function XiSuiJingUtil:getMaxExp()
    return self.__skill:getMaxExp()
end

function XiSuiJingUtil:getMaxLv()
    return self.__skill:getMaxLv()
end

return class("XiSuiJingUtil", {}, XiSuiJingUtil)
0000000000
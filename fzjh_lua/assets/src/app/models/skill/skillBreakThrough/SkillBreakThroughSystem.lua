local newClass = require("third.class.NewClass")

local SkillConst = require("app.models.skill.SkillConst")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillBreakThroughResManager = require("app.models.skill.skillBreakThrough.SkillBreakThroughResManager")

local SkillBreakThroughSystem = {}

function SkillBreakThroughSystem:create(role)
    local p = SkillBreakThroughSystem.new()
    p:__init(role)
    return p
end

function SkillBreakThroughSystem:__init(role)
    self.__isNotSerializable = true
    self.__role = role
end

--@desc: 能否进行武学突破
--@author:LvBin
--@time:2022-01-12 14:54:21
--@return
function SkillBreakThroughSystem:isBreakThrough()
    local skillSecondTypeMap = SkillConst.SkillSecondType

    for k,secType in pairs(skillSecondTypeMap) do
        local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(secType)
        if self.__role:getSkillLv(baseSkillId) >= 1000 then
            return true
        end
    end

    return false
end

--@desc: 获取能进行武学突破的列表
--@author:LvBin
--@time:2022-01-12 15:22:33
--@return
function SkillBreakThroughSystem:getSkillBreakThroughList()
    local retSkills = {}
    local skillList = self.__role:getSkills()
    for skillId,v in pairs(skillList) do
        local skill = Skill:getSkill(skillId)
        local skillType = skill.type
        local skillLv = self.__role:getSkillLv(skillId)
        if self:__isSkillBreakThroughType(skillType) and skillLv >= 1000 then
            table.insert(retSkills,skill)
        end
    end
    return retSkills
end

--@desc: 获取能进行招式突破的武学列表
--@author:LvBin
--@time:2022-01-20 17:34:01
--@return
function SkillBreakThroughSystem:getZhaoBreakThroughList()
    local retSkills = {}
    local skillList = self.__role:getSkills()
    for skillId,v in pairs(skillList) do
        local skill = Skill:getSkill(skillId)
        local skillType = skill.type
        local skillLv = self.__role:getSkillLv(skillId)
        local zhaoList = self.__role:getSkillZhaoList(skillId)
        local isLearn = false
        if not MapIsEmpty(zhaoList) then
            for i,zhao in ipairs(zhaoList) do
                if self.__role:getSkillZhaoExp(zhao.id) > 0 then
                    isLearn = true
                    break
                end
            end
        end
        if self:__isSkillBreakThroughType(skillType) and skillLv >= 1000 and isLearn == true then
            table.insert(retSkills,skill)
        end
    end
    return retSkills
end

--@desc: 判断武学类型能否进行武学突破
--@author:LvBin
--@time:2022-01-12 15:52:23
--@type: 
--@return
function SkillBreakThroughSystem:__isSkillBreakThroughType(type)
    type = tonumber(type)
    return type == SKILL_TYPE_BASE or type == SKILL_TYPE_NORMAL or type == SKILL_TYPE_SELFCREATE
end

--@desc: 判断武学是否到突破最高阶段
--@author:LvBin
--@time:2022-01-13 16:04:11
--@return
function SkillBreakThroughSystem:isSkillBreakThroughMaxLevel(skillId)
    local breId = self.__role:getSkillBreId(skillId)

    local level = SkillBreakThroughResManager:getSkillBreakThroughMapById(breId).class
    
    if level >= SkillBreakThroughResManager:getSkillBreakThroughMaxLevel() then
        return true
    end

    return false
end

--@desc: 获取武学默认突破id
--@author:LvBin
--@time:2022-01-24 18:41:46
--@return
function SkillBreakThroughSystem:getSkillDefaultBreId()
    return "100001"
end

--@desc: 获取武学当前阶段突破数据
--@author:LvBin
--@time:2022-01-13 15:07:05
--@skillId: 
--@return
function SkillBreakThroughSystem:getSkillBreakThroughMap(skillId)
    local breId = self.__role:getSkillBreId(skillId)

    local level = SkillBreakThroughResManager:getSkillBreakThroughMapById(breId).class
    
    return SkillBreakThroughResManager:getSkillBreakThroughMapById(breId)
end

--@desc: 根据武学突破阶段获取突破数据
--@author:LvBin
--@time:2022-01-13 17:25:43
--@level: 
--@return
function SkillBreakThroughSystem:getSkillBreakThroughMapByLevel(level)
    return SkillBreakThroughResManager:getSkillBreakThroughMapByLevel(level)
end

--@desc: 武学突破
--@author:LvBin
--@time:2022-01-13 15:09:26
--@return
function SkillBreakThroughSystem:skillBreakThrough(skillId,callback)
    local breId = self.__role:getSkillBreId(skillId)

    local level = SkillBreakThroughResManager:getSkillBreakThroughMapById(breId).class

    level = level + 1

    local breMap = self:getSkillBreakThroughMapByLevel(level)

    local nextBreId = breMap.id

    HttpManagerEx:skillBreakThrough(nextBreId,skillId,self.__role:getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                
                local reitem_list = data.reitem_list

                for i, v in ipairs(reitem_list) do
                    self.__role:addItemCount(v.id,-v.num)
                end

                if data.currencyVersion then
                    self.__role:setCurrencyVersion(data.currencyVersion)
                end
                
                self.__role:setSkillBreId(skillId, nextBreId)

                callback(true,data)
            else
                callback(false,errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 判断招式是否突破到最高阶段
--@author:LvBin
--@time:2022-01-23 12:17:14
--@skillId: 
--@return
function SkillBreakThroughSystem:isZhaoBreakThroughMaxLevel(zhaoId)
    local maxLevel = self:getZhaoMaxLevel(zhaoId)
    local currLvLimit = self:getZhaoLvLimit(zhaoId)
    
    if currLvLimit >= maxLevel then
        return true
    end

    return false
end

--@desc: 获取招式最高重数
--@author:LvBin
--@time:2022-01-25 15:17:19
--@return
function SkillBreakThroughSystem:getZhaoMaxLevel(zhaoId)
    local zhao = Skill:getActiveZhao(zhaoId)
    local activeSkillType = zhao.activeSkillType

    return SkillBreakThroughResManager:getZhaoBreakThroughMaxLevelByActiveSkillType(activeSkillType)
end

--@desc: 招式突破
--@author:LvBin
--@time:2022-01-23 13:10:19
--@skillId:
	--@callback: 
--@return
function SkillBreakThroughSystem:zhaoBreakThrough(zhaoId,callback)
    local currZhaoLvLimit = self:getZhaoLvLimit(zhaoId)

    local nextZhaoLvLimit = currZhaoLvLimit + 1

    local nextBreData = self:getZhaoBreDataByZhaoIdAndZhaoLv(zhaoId,nextZhaoLvLimit)

    local nextBreId = nextBreData.id

    HttpManagerEx:zhaoBreakThrough(nextBreId,zhaoId,self.__role:getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then

                self.__role:setZhaoBreId(zhaoId, nextBreId)

                if data.currencyVersion then
                    self.__role:setCurrencyVersion(data.currencyVersion)
                end

                callback(true,data)
            else
                callback(false,errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 根据招式id和招式重数获取招式突破数据
--@author:LvBin
--@time:2022-01-21 19:29:38
--@return
function SkillBreakThroughSystem:getZhaoBreDataByZhaoIdAndZhaoLv(zhaoId,zhaoLv)
    local zhao = Skill:getActiveZhao(zhaoId)
    local activeSkillType = zhao.activeSkillType
    return SkillBreakThroughResManager:getZhaoBreDataByZhaoLvAndActiveSkillType(activeSkillType,zhaoLv)
end

function SkillBreakThroughSystem:getZhaoDefaultBreId(zhaoId)
    --@TODO 2022-01-22 16:07:28 暂时用默认9，之后把武学等级解锁招式填到表里
    local defaultLv = 9
    local zhaoBreData = self:getZhaoBreDataByZhaoIdAndZhaoLv(zhaoId,defaultLv)
    local breId = zhaoBreData.id
    return breId
end

function SkillBreakThroughSystem:getZhaoLvLimit(zhaoId)
    local zhaoBreId = self.__role:getZhaoBreId(zhaoId)
    
    return SkillBreakThroughResManager:getZhaoBreakThroughMapById(zhaoBreId).Blevel
end

return newClass("SkillBreakThroughSystem", {}, SkillBreakThroughSystem)
0
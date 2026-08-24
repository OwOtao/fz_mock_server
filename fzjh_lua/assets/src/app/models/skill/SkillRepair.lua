local newClass = require("third.class.NewClass")

local SkillRepair = {}

local RepairType = {
    YanJiu = 1, --武学研究引发的问题，基本武学等级超过准备武学等级+1
}

function SkillRepair:create(role)
    local p = SkillRepair.new()

    p:__init(role)

    return p
end

function SkillRepair:__init(role)
    self.__role = role
end

function SkillRepair:repair()
    self:__clearCacheMsg()

    if self.__role:getInheritFlag("__repairRoleSkillData") == 0 or self.__role:getInheritFlag("__repairRoleSkillData") == 1 then
        self:__baseSkillLvRepair()
    end

    if self.__role:getInheritFlag("__repairRoleSkillData") == 2 then
        self:__deleteSelfCreatedSkillInSeeSkills()
    end
end

function SkillRepair:__baseSkillLvRepair()
    local baseSkillIdList = {
        "jibenquanjiao",
        "jibenqinggong",
        "jibenzhaojia",
        "jibenjianfa",
        "jibendaofa",
        "jibengunfa",
        "jibenanqi",
        "jibenbianfa",
        "jibenshuangchi",
        "jibenqinfa",
    }

    local skills = self.__role:getSkills()

    local recordRepairMsg = {}

    for i = 1, #baseSkillIdList, 1 do
        local skillId = baseSkillIdList[i]

        local roleSkillData = skills[skillId]

        if roleSkillData then
            local yanJiuSkillLvLimit = self:__getJiBenSkillYanJiuSkillLvLimit(skillId)
            
            if yanJiuSkillLvLimit then
                local skillExp = self.__role:getSkillExp(skillId)

                local skillLv = self.__role:getSkillLv(skillId)
                
                if skillLv > 500 and skillLv > yanJiuSkillLvLimit + 1 then
                    local exp = Skill:getExp(yanJiuSkillLvLimit + 1)
        
                    roleSkillData.exp = exp

                    table.insert(recordRepairMsg,{
                        skillId = skillId, --技能id
                        startExp = skillExp,--修复前经验
                        endExp = exp, --修复后经验
                        repairTime = math.floor(GetTime()),--修复时间
                    })
                end
            end 
        end
    end

    self:__recordRepairSkillYanJiuMsg(recordRepairMsg)

	self.__role:setInheritFlag("__repairRoleSkillData", 2)
end

function SkillRepair:__getJiBenSkillYanJiuSkillLvLimit(baseSkillId)
    local yanJiuSkillLvLimit = nil

    local baseSkill = Skill:getSkill(baseSkillId)

    local method = nil

    if baseSkill and baseSkill.methods and baseSkill.methods[1] then
        method = baseSkill.methods[1]
    else
        return nil
    end
    
    local function isMethods(skillId)
        local skill = Skill:getSkill(skillId)
        if skill and skill.methods then
            for i,vtype in ipairs(skill.methods) do
                if vtype == method then
                    return true
                end
            end
        end

        return false
    end 

    for k,v in pairs(self.__role:getSkills()) do
        local skill = Skill:getSkill(k)
        if k ~= baseSkillId and isMethods(k) then
            if yanJiuSkillLvLimit == nil then
                yanJiuSkillLvLimit = self.__role:getSkillLv(k)
            else
                yanJiuSkillLvLimit = math.max(yanJiuSkillLvLimit,self.__role:getSkillLv(k))
            end
        end
    end

    return yanJiuSkillLvLimit
end

--@desc: 记录修复武学研究日志信息
--@author:LvBin
--@time:2024-12-12 17:16:21
--@repairMsg: 修复日志信息
--@return
function SkillRepair:__recordRepairSkillYanJiuMsg(repairMsg)
    if MapIsEmpty(repairMsg) then
       return 
    end

    local recordMsg = {
        repairType = RepairType.YanJiu,
        repairMsg = repairMsg,
    }

    self.__role:setAttr("repairSkillYanJiuMsg",recordMsg)

    local Record = require("app.models.Record.Record")
    
    Record:addLogData(Record.RECORD_TYPE.SKILL_YANJIU_LIMITLV, recordMsg)
end

--@desc: 清除客户端临时记录的修复武学研究日志信息
--@author:LvBin
--@time:2024-12-12 17:27:47
--@return
function SkillRepair:__clearCacheMsg()
    local clearMsgTime = 60 * 60 * 24 * 14 -- 14天清理一次缓存

    local repairSkillYanJiuMsg = self.__role:getAttr("repairSkillYanJiuMsg")

    if repairSkillYanJiuMsg and repairSkillYanJiuMsg.repairTime then
        if GetTime() - repairSkillYanJiuMsg.repairTime > clearMsgTime then
            self.__role:setAttr("repairSkillYanJiuMsg",nil)
        end
    end
end

--删除见闻武学中的自创武学
function SkillRepair:__deleteSelfCreatedSkillInSeeSkills()
    local seeSkills = self.__role:getAttr("seeSkills")
    local needDeleteSkills = {}

    for i = #seeSkills, 1, -1 do
        --见闻武学当前存的是自创武学数据id
        if tonumber(seeSkills[i]) then
            table.insert(needDeleteSkills, seeSkills[i])
        end
    end

    for i = 1, #needDeleteSkills, 1 do
        self.__role:deleteSeeSkill(needDeleteSkills[i])
    end

    self.__role:setInheritFlag("__repairRoleSkillData", 3)
end

return newClass("SkillRepair", {}, SkillRepair)
0000000000000
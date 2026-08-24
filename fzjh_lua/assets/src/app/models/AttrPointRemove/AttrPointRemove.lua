local class = require("third.class.NewClass")
local SkillConst = require("app.models.skill.SkillConst")
local NaturalAttrAdjustmentConst = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst")
local NaturalAttrUtil = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrUtil")
local attrPointRemoveNum = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TRANSFORM_MONEY)    --洗点数
local str_need = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TRANSFORM_STR_NEED)
local con_need = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TRANSFORM_CON_NEED)
local dex_need = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TRANSFORM_DEX_NEED)
local int_need = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TRANSFORM_INT_NEED)

local attrConditions = {
    [NaturalAttrAdjustmentConst.ATTR_TYPE.INT] = int_need,
    [NaturalAttrAdjustmentConst.ATTR_TYPE.STR] = str_need,
    [NaturalAttrAdjustmentConst.ATTR_TYPE.DEX] = dex_need,
    [NaturalAttrAdjustmentConst.ATTR_TYPE.CON] = con_need,
}

local AttrPointRemove = {}

function AttrPointRemove:create()
    return AttrPointRemove:new()
end

function AttrPointRemove:ctor()
    self.__surplusTimes = 3  --剩余次数
	self.__defaultLimitTimes = 3	 --最大上限
	self.__removeCoolTime= 3600*12	--单次冷却时间
	self.__unitPrice = 300		--单次洗点元宝价格
	self.__endTime = 0
	self.__npcName = "刘寻山"
end

function AttrPointRemove:setRole(role)
    self.__role = role
end

function AttrPointRemove:setAttrType(attr)
    self.__attrType = attr
end

function AttrPointRemove:getAttrName(attr)
    return self.__role:getCHAttrName(attr)
end

function AttrPointRemove:getAttrList()
    return NaturalAttrAdjustmentConst.ATTR_TYPE
end

function AttrPointRemove:getBaseRemovePoint()
    return attrPointRemoveNum
end

function AttrPointRemove:getNpcName()
    return self.__npcName
end

function AttrPointRemove:getSkillRemovePoint()
    local skillId = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)
	local xisuijingExp = self.__role:getSkillExp(skillId)
    local skill = Skill:getSkill(skillId)
    local skillAdd = skill:getAttrPointValue(self.__attrType,xisuijingExp)

    return skillAdd
end

function AttrPointRemove:getSkillName()
    local skillId = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)
    local skill = Skill:getSkill(skillId)
    return skill:getName()
end

function AttrPointRemove:getUnitPrice()
    return self.__unitPrice
end

function AttrPointRemove:getInfo(func)
    HttpManagerEx:getAttributeTimes(function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__defaultLimitTimes= tonumber(data.count)
                self.__removeCoolTime = tonumber(data.cooltime)
                self.__surplusTimes = tonumber(data.num)
                self.__unitPrice = tonumber(data.remove)
                self.__endTime = GetTime() + self.__removeCoolTime
                self.__npcName = "刘寻山"

                if func then
                    func()
                end
            else
                PopText(errmsg)
            end
    end, IS_SHOW_WAITING)
end

function AttrPointRemove:getTimes()
    return self.__surplusTimes
end

function AttrPointRemove:getTotalPoint()
    local inheritCount = self.__role:getAttr("inheritCount")
    local naturalAttrAdjustmentPlan = NaturalAttrUtil:getPlayerCurrentNaturalAdjustmentPlan()
    local plan = naturalAttrAdjustmentPlan:getUsagePlan()
    local totalPoint = plan:getAssignablePoints()

    return totalPoint
end

function AttrPointRemove:getRoleAttr(attr)
    return self.__role:getAttr(attr)
end

function AttrPointRemove:getEndTime()
    return self.__endTime
end

function AttrPointRemove:checkAttrIsMeetTheConditions(attr)
    if attrConditions[attr] then
        return self.__role:getAttr(attr) >= attrConditions[attr]
    end
    return false
end

function AttrPointRemove:checkTimesIsEnough()
    return self.__surplusTimes > 0
end

function AttrPointRemove:checkIsCoolState()
    return self.__endTime - GetTime() > 0
end

function AttrPointRemove:doRemoveFunc(successFunc,failFunc)
    self:__initBefRecords()
    HttpManagerEx:removeAttributePoint(function(status, errcode, errmsg, data)
        if status == 200 then 
            if errcode == 0 then
                self.__removeCoolTime = tonumber(data.cooltime)
                self.__surplusTimes = tonumber(data.num)
                self.__unitPrice = tonumber(data.remove)
                self.__endTime = GetTime() + self.__removeCoolTime

                local attrPoint = attrPointRemoveNum + self:getSkillRemovePoint()
                local naturalAttrAdjustmentPlan = NaturalAttrUtil:getPlayerCurrentNaturalAdjustmentPlan()
                local plan = naturalAttrAdjustmentPlan:getUsagePlan()
                
                plan:setNaturalPlanAttr(self.__attrType, plan:getNaturalPlanAttr(self.__attrType) - attrPoint)
                naturalAttrAdjustmentPlan:useAttrAdjustmentPlanType(plan:getNaturalPlanType())

                self:__initAftRecords()

                self:__record()
                
                if successFunc then
                    successFunc()
                end
            else
                PopText(errmsg)
                if failFunc then
                    failFunc()
                end
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

function AttrPointRemove:__initBefRecords()
    local records = {}
    local naturalAttrAdjustmentPlan = NaturalAttrUtil:getPlayerCurrentNaturalAdjustmentPlan()
    local plan = naturalAttrAdjustmentPlan:getUsagePlan()
    local attrDict = plan:getNaturalPlanAttrDict()
	local totalPoint = self:getTotalPoint()

    self.__befRecord = {
        str = attrDict.str,
        int = attrDict.int,
        dex = attrDict.dex,
        con = attrDict.con,
        totalPoint = totalPoint,
    }
end

function AttrPointRemove:__initAftRecords()
    local records = {}
    local naturalAttrAdjustmentPlan = NaturalAttrUtil:getPlayerCurrentNaturalAdjustmentPlan()
    local plan = naturalAttrAdjustmentPlan:getUsagePlan()
    local attrDict = plan:getNaturalPlanAttrDict()
	local totalPoint = self:getTotalPoint()

    self.__aftRecord = {
        str = attrDict.str,
        int = attrDict.int,
        dex = attrDict.dex,
        con = attrDict.con,
        totalPoint = totalPoint,
    }
end

function AttrPointRemove:__record()
	local role = self.__role

    local records = {}
    records.method = {
		yuanbao = self.__unitPrice
    }
    records.beforeAttr = {
        str = self.__befRecord.str,
        int = self.__befRecord.int,
        con = self.__befRecord.con,
        dex = self.__befRecord.dex,
        free = self.__befRecord.totalPoint
    }

    records.afterAttr = {
        str = self.__aftRecord.str,
        int = self.__aftRecord.int,
        con = self.__aftRecord.con,
        dex = self.__aftRecord.dex,
        free = self.__aftRecord.totalPoint
    }

    local skillId = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)
    local skillExp = role:getSkillExp(skillId)
    local skill = Skill:getSkill(skillId)
    local skillAdd = skill:getAttrPointValue(self.__attrType,skillExp)
    records.skillExp = skillExp
    records.skillLv = role:getSpecialZhiShiSkillLv(skillId)
    records.basePoint = attrPointRemoveNum
    records.skillAddPoint = skillAdd
    records.finalPoint = attrPointRemoveNum + skillAdd

    HttpManagerEx:uploadWashAttributeRecord(records,
        function(status, errcode, errmsg, data)
        end,
        IS_SHOW_WAITING
    )
end

return class("AttrPointRemove", {}, AttrPointRemove)
000000000000000
local NewClass = require("third.class.NewClass")

local SkillConst = require("app.models.skill.SkillConst")

--@RefType [src.app.models.Record.HuaYuanRecord.HuaYuanRecord#HuaYuanRecord]
local HuaYuanRecord = require("app.models.Record.HuaYuanRecord.HuaYuanRecord")

local MeridianResources = require("app.models.Meridian.MeridianResources")

local MeridianSkillUtil = {}

local RESETSEC = tonumber(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.MERIDIANCONVERT_USERESET)) * 24 * 3600

function MeridianSkillUtil:create(role)
    return MeridianSkillUtil.new():__init(role)
end

function MeridianSkillUtil:__init(role)
    self.__role = role

    --@RefType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
    self.__meridianSys = role:getMeridianSystem()

    self:__initSkill()
    return self
end

function MeridianSkillUtil:__initSkill()
    self.__skill = Skill:getSkill(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_MERIDIAN))
end

function MeridianSkillUtil:getSkillName()
    return self.__skill:getName()
end

function MeridianSkillUtil:getSkillStageDsc()
    return self.__skill:getStageDsc(self.__role)
end

function MeridianSkillUtil:getSkillDsc()
    return self.__skill:getDsc()
end

function MeridianSkillUtil:getSkillId()
    return self.__skill.id
end

function MeridianSkillUtil:getLv(exp)
    if not exp then
        exp = self:getSkillExp()
    end

    return self.__skill:getLv(exp)
end

function MeridianSkillUtil:getExp(lv)
    return self.__skill:getExp(lv)
end

function MeridianSkillUtil:getSkillExp()
    return self.__role:getSkillExp(self:getSkillId())
end

function MeridianSkillUtil:getMaxExp()
    return self.__skill:getMaxExp()
end

function MeridianSkillUtil:getMaxLv()
    return self.__skill:getMaxLv()
end

function MeridianSkillUtil:lianGong()
    local currInt = self.__role:getAttr("currInt")
    local needJing = self.__skill:getLianGongNeedJing()
    local needPot = self.__skill:getLianGongNeedPot(currInt)
    local addExp = self.__skill:getLianGongAddExp(currInt)
    local currExp = self:getSkillExp()
    local skillId = self:getSkillId()

    if addExp + currExp > self:getMaxExp() then
        addExp = self:getMaxExp() - currExp
    end

    local skill = self.__role:getSkill(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_MERIDIAN))
    skill.exp = skill.exp + addExp

    self.__role:addAttr("jing", -needJing)
    self.__role:addAttr("pot", -needPot)

    return addExp, needJing, needPot
end

function MeridianSkillUtil:checkCanLianGong()
    local needJing = self.__skill:getLianGongNeedJing()
    local needPot = self.__skill:getLianGongNeedPot(self.__role:getAttr("currInt"))
    local roleJing = self.__role:getAttr("jing")
    local rolePot = self.__role:getAttr("pot")

    if roleJing < needJing then
        return false, SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TIPS_UPGRADE_JINGLACK)
    end

    if rolePot < needPot then
        return false, SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TIPS_UPGRADE_POTLACK)
    end

    local lv = self:getLv(self:getSkillExp())

    if lv >= self:getMaxLv() then
        return false, self:getSkillName() .. "等级已达上限。"
    end

    return true
end

function MeridianSkillUtil:getSkillStageInfo()
    return self.__skill:getSkillStageInfoByExp(self:getSkillExp())
end

function MeridianSkillUtil:getSkillStageInfoById(id)
    return self.__skill:getSkillStageInfoById(id)
end

function MeridianSkillUtil:checkIsMaxSkillStage()
    local maxStage = self.__skill:getSkillStageMax()
    local stageInfo = self:getSkillStageInfo()
    return maxStage == stageInfo.id
end

--@desc: 获取经脉印记对象
--@author:Seven
--@time:2025-01-18 15:07:38
--@imprintingId: 经脉印记ID
--@return [src.app.models.Meridian.MeridianImprintingRes#MeridianImprintingRes]
function MeridianSkillUtil:getImprintingById(imprintingId)
    return MeridianResources:getMeridianImprintingRes(imprintingId)
end

function MeridianSkillUtil:getLeftMeridianList()
    local leftMeridianList = {}

    local list = self.__meridianSys:getCurrentPageMeridianImprintings()
    for i, v in ipairs(list) do
        if v:getPeiyuan() == 1 then
            table.insert(leftMeridianList, MeridianResources:getMeridianImprintingRes(v:getImprintingId()))
        end
    end

    return leftMeridianList
end

function MeridianSkillUtil:getRightMeridianList()
    local rightMeridianList = {}

    local allImprResList = MeridianResources:getAllMeridianImprintingRes()
    for i, v in ipairs(allImprResList) do
        if v:getPeiyuan() == 1 and not self.__meridianSys:currPageHasMeridianImprinting(v:getImprintingId()) then
            table.insert(rightMeridianList, v)
        end
    end

    return rightMeridianList
end

--@desc: 真气培元
--@author:LvBin
--@time:2023-07-03 17:27:04
--@leftId: 培元删除的经脉id
--@rightId: 培元后新增的经脉id
--@return nil
function MeridianSkillUtil:breathValPeiYuan(originid, replaceid)
    local speed = self:getPeiYuanBreathVal(replaceid)

    local befValue = self.__role:getAttr("breathVal")

    if speed > befValue then
        return false, "真气数量不足"
    end

    self.__role:addAttr("breathVal", -speed)

    local aftValue = self.__role:getAttr("breathVal")

    self:__peiYuan(originid, replaceid)

    self:__getLogRecord(
        HuaYuanRecord.R_TYPE.BREATHVAL_USE,
        originid,
        replaceid,
        {
            cost = speed,
            costbef = befValue,
            costaft = aftValue
        }
    ):submitRecord()

    return true
end

--@desc: 真气丹培元
--@author:LvBin
--@time:2023-07-03 17:31:52
--@originid: 培元删除的经脉id
--@replaceid: 培元后新增的经脉id
--@return nil
function MeridianSkillUtil:zhenQiDanPeiYuan(originid, replaceid)
    local speed = self:getPeiYuanZhenQiDanNum(replaceid)

    local ITEMID = "jingmai101"

    local befValue = self.__role:getItemCount(ITEMID)

    if speed > befValue then
        return false, "真气丹数量不足"
    end

    self.__role:addItemCount(ITEMID, -speed)

    local aftValue = self.__role:getItemCount(ITEMID)

    self:__peiYuan(originid, replaceid)

    local logRecord =
        self:__getLogRecord(
        HuaYuanRecord.R_TYPE.ITEM_USE,
        originid,
        replaceid,
        {
            itemid = ITEMID,
            cost = speed,
            costbef = befValue,
            costaft = aftValue
        }
    ):submitRecord()

    return true
end

function MeridianSkillUtil:__peiYuan(originid, replaceid)
    self.__meridianSys:replaceMeridianImprinting(self.__meridianSys:getCurrUsingMeridianImprintingPageNumber(), originid, replaceid)

    self.__role:updateRoleBuff()

    self:addUseMeridianSkillPeiYuanRecord()
end

--@desc: 获取培元日志记录对象
--@author:Seven
--@time:2023-07-05 14:49:43
--@stype: 培元类型
--@originid: 原始经脉id
--@replaceid: 新的经脉id
--@env: 自定义环境变量
--@return [src.app.models.Record.HuaYuanRecord.HuaYuanRecord#HuaYuanRecord]
function MeridianSkillUtil:__getLogRecord(stype, originid, replaceid, env)
    local roleUseRecord = self.__role:getMSkillUseRecord()

    local resettm = roleUseRecord.firstUseTime + RESETSEC

    local usetimes = roleUseRecord.time - 1

    local record = HuaYuanRecord:create(stype, originid, replaceid, usetimes, resettm, env)

    return record
end

function MeridianSkillUtil:getPeiYuanBreathVal(imprintingId)
    local imprinting = self:getImprintingById(imprintingId)

    local baseCost = tonumber(imprinting:getHycost())

    local stage = json.decode(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.MERIDIANCONVERT_STAGE))

    local time = self:getUseMeridianSkillTime()

    local currTime = time + 1

    local index = ""

    for _index, v in pairs(stage) do
        if currTime >= v.min and currTime <= v.max then
            index = _index
        end
    end

    local exp = self:getSkillExp()

    local stageParam = self.__skill:getStageParam(exp, index)

    local costBreathVal = math.ceil((baseCost - (baseCost * stageParam)) / 100) * 100

    return costBreathVal
end

function MeridianSkillUtil:getPeiYuanZhenQiDanNum(imprintingId)
    local costBreathVal = self:getPeiYuanBreathVal(imprintingId)

    local itemCost = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.MERIDIANCONVERT_ITEMCOST)

    local costZhenQiDanNum = math.ceil(costBreathVal / itemCost)

    return costZhenQiDanNum
end

function MeridianSkillUtil:getBreathVal()
    return self.__role:getAttr("breathVal")
end

function MeridianSkillUtil:getZhenQiDanNum()
    return self.__role:getItemCount("jingmai101")
end

--@desc: 获取经脉武学使用次数
--@author:LvBin
--@time:2023-07-04 14:48:08
--@return
function MeridianSkillUtil:getUseMeridianSkillTime()
    self:__refreshUseMeridianSkillTime()

    local mSkillUseRecord = self.__role:getMSkillUseRecord()

    return mSkillUseRecord.time
end

--@desc: 获取剩余重置刷新时间
--@author:LvBin
--@time:2023-07-05 20:17:36
--@return
function MeridianSkillUtil:getMeridianSkillResetTime()
    local mSkillUseRecord = self.__role:getMSkillUseRecord()

    local currTime = Helper:mathFloor(GetTime())

    local resetTime = math.max(RESETSEC - (currTime - mSkillUseRecord.firstUseTime), 0)

    return resetTime
end

--@desc: 是否第一次使用洞元录化元
--@author:LvBin
--@time:2023-07-06 17:07:44
--@return
function MeridianSkillUtil:isFirstUse()
    local mSkillUseRecord = self.__role:getMSkillUseRecord()
    if mSkillUseRecord.firstUseTime == 0 and mSkillUseRecord.time == 0 then
        return true
    end

    return false
end

--@desc: 刷新经脉武学使用次数
--@author:LvBin
--@time:2023-07-05 15:14:53
--@return
function MeridianSkillUtil:__refreshUseMeridianSkillTime()
    if self:isFirstUse() then
        return
    end

    local mSkillUseRecord = self.__role:getMSkillUseRecord()

    if GetTime() - mSkillUseRecord.firstUseTime >= RESETSEC then
        mSkillUseRecord.firstUseTime = mSkillUseRecord.firstUseTime + RESETSEC

        mSkillUseRecord.time = 0
    end
end

--@desc: 记录使用经脉武学培元次数
--@author:LvBin
--@time:2023-07-04 14:45:27
--@return
function MeridianSkillUtil:addUseMeridianSkillPeiYuanRecord()
    local mSkillUseRecord = self.__role:getMSkillUseRecord()

    if self:isFirstUse() then
        mSkillUseRecord.firstUseTime = Helper:mathFloor(GetTime())
    end

    mSkillUseRecord.time = self:getUseMeridianSkillTime() + 1
end

return NewClass("MeridianSkillUtil", {}, MeridianSkillUtil)
000000000000
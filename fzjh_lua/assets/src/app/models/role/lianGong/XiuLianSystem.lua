local newClass = require("third.class.NewClass")

local LianGongParamsManager = require("app.models.role.lianGong.LianGongParamsManager")

local SkillConst = require("app.models.skill.SkillConst")

local AsyncFunction = require("third.async.AsyncFunction")

local LogSystem = require("app.models.LogSystem.LogSystem")

local ErrmsgRecord = require("app.models.Record.ErrmsgRecord.ErrmsgRecord")

local SkillHelper = require("app.models.skill.SkillHelper")

local function print(...)
    return LogSystem:log("新版练功", ...)
end

local XiuLianSystem = {
    __codeVersion = 1,
    __ver = 0,
    __skillId = nil,
    __skillPrepareType = nil,
    __xinshen = 0,
    __startTime = nil,
    __duration = nil,
    __selectJing = nil,
    __selectLv = nil,
    __useXgsCount = 0,
    __variates = {},
    __dummy = {},
    __startExp = nil,
    __startLvLimit = nil,
    __playerLv = nil
}

function XiuLianSystem:create(player)
    local p = XiuLianSystem.new(TableProxy:createEncryptedTable({}))
    p:__init(player)
    return p
end

function XiuLianSystem:ctor()
    self.__isNotSerializable = true

    self.__isXiuLianing = false

    self.__player = nil
end

function XiuLianSystem:__init(player)
    self.__player = player
end

--@desc: 结束旧版修炼
--@author:LvBin
--@time:2022-04-13 09:55:49
--@return
function XiuLianSystem:stopOldXiuLian()
    if self.__player:getInheritFlag("stopOldXiuLian") == 0 then
        local roleCurrState = self.__player:getAttr("roleCurrState")
        local isOldXiuLian = false

        if MapIsEmpty(roleCurrState) == false then
            for state, bool in pairs(roleCurrState) do
                if tostring(state) == tostring(ROLE_CURR_STATE_XIULIAN) then
                    isOldXiuLian = true
                    break
                end
            end
        end

        if isOldXiuLian then
            self.__player:xiuLian()
            self.__player:stopXiuLian()
        end

        self.__player:setInheritFlag("stopOldXiuLian", 1)
    end
end

function XiuLianSystem:initData(data)
    self:setVer(data.ver)

    self:setXinShen(data.xinshen)

    --自创武学id重新定义后，需要处理正在练功的自创武学id
    local skillId = data.skillId

    if Game:isTesting() then
        --由于自创武学id：userid__selfCreatedSkill__自创数据id，盖档需要调整成正确的userid
        if SkillHelper:checkIsSelfCreatedSkillId(skillId) then
            local skillDataId = SkillHelper:skillIdToSelfCreatedSkillDataId(skillId)
            skillId = SkillHelper:selfCreatedSkillDataIdToSkillId(self.__player:getAttr("userid"), skillDataId)
        end
    end

    if SkillHelper:checkSkillIdIsSelfCreatedSkillDataId(self.__player, skillId) then
        --自创武学数据id
        self.__selfCreatedSkillDataId = skillId
        self:setSkillId(SkillHelper:selfCreatedSkillDataIdToSkillId(self.__player:getAttr("userid"), skillId))
    else
        self:setSkillId(skillId) 
    end

    self:setSkillPrepareType(data.skillPrepareType)

    self:setStartTime(data.startTime)

    self:setDuration(data.duration)

    self:setSelectJing(data.selectJing)

    --因为版本更新，这里设置体力值需要设置默认值0
    self:setSelectTiLi(Helper:getDef(data.selectTiLi,0))

    self:setSelectLv(data.selectLv)

    self:setUseXgsCount(data.useXgsCount)

    self:setVariates(data.variates)

    self:setDummy(data.dummy)

    self:setStartExp(data.startExp)

    self:setStartLvLimit(data.startLvLimit)

    self:setPlayerLv(data.playerLv)
end

function XiuLianSystem:getXiuLianState(callback)
    self.__player:getServerActionSystem():getXiuLianState(
        self.__codeVersion,
        function(ok, isXiuLian)
            callback(ok, isXiuLian == 1)
        end
    )
end

function XiuLianSystem:pullXiuLianData(callback)
    self.__player:getServerActionSystem():getXiuLianData(
        self.__codeVersion,
        function(ok, errmsg, startAction, useXgsCount)
            if ok then
                if startAction ~= "" and startAction.data ~= "" then
                    self:initData(startAction.data)
                end
                if type(useXgsCount) == "number" then
                    self:setUseXgsCount(useXgsCount)
                end
                callback(true)
            else
                callback(false, errmsg)
            end
        end
    )
end

function XiuLianSystem:getPlayer()
    return self.__player
end

function XiuLianSystem:setIsXiuLianing(b)
    self.__isXiuLianing = b
end

function XiuLianSystem:isXiuLianing()
    return self.__isXiuLianing
end

--@desc: 设置版本号
--@author:LvBin
--@time:2022-03-21 12:07:07
--@ver:
--@return
function XiuLianSystem:setVer(ver)
    self.__ver = ver
end

function XiuLianSystem:getVer()
    return self.__ver
end

--@desc: 设置修炼所需时长
--@author:LvBin
--@time:2022-03-21 12:07:36
--@return
function XiuLianSystem:setDuration(duration)
    self.__duration = duration
end

function XiuLianSystem:getDuration()
    return self.__duration
end

function XiuLianSystem:getEndTime()
    return self:getStartTime() + self:getDuration()
end

function XiuLianSystem:setXinShen(num)
    self.__xinshen = num
end

function XiuLianSystem:setSkillId(skillId)
    self.__skillId = skillId
end

function XiuLianSystem:getSkillId()
    return self.__skillId
end

function XiuLianSystem:setSkillPrepareType(skillPrepareType)
    self.__skillPrepareType = skillPrepareType
end

function XiuLianSystem:getSkillPrepareType()
    return self.__skillPrepareType
end

function XiuLianSystem:getXinShen()
    return self.__xinshen
end

function XiuLianSystem:setSelectJing(jingNum)
    self.__selectJing = jingNum
end

function XiuLianSystem:getSelectJing()
    return self.__selectJing
end

function XiuLianSystem:setSelectLv(skillLv)
    self.__selectLv = skillLv
end

function XiuLianSystem:getSelectLv()
    return self.__selectLv
end

function XiuLianSystem:setSelectTiLi(tiliNum)
    self.__selectTiLi = tiliNum
end

function XiuLianSystem:getSelectTiLi()
    return self.__selectTiLi
end

function XiuLianSystem:setStartTime(time)
    self.__startTime = time
end

function XiuLianSystem:getStartTime()
    return self.__startTime
end

function XiuLianSystem:setUseXgsCount(count)
    self.__useXgsCount = count
end

function XiuLianSystem:setDummy(dummy)
    self.__dummy = dummy
end

function XiuLianSystem:getDummy()
    return self.__dummy
end

function XiuLianSystem:getDummyJingBuff()
    local jjId = self.__dummy.jjId

    local itemAttr = Item:getOneItemByKey(jjId)

    local buffTab = string.split(itemAttr.value, ";")

    local jingBuff = buffTab[1] or 0

    return tonumber(jingBuff)
end

function XiuLianSystem:getDummyExpBuff()
    local jjId = self.__dummy.jjId

    local itemAttr = Item:getOneItemByKey(jjId)

    local buffTab = string.split(itemAttr.value, ";")

    local expBuff = buffTab[2] or 0

    return tonumber(expBuff)
end

function XiuLianSystem:getDummyBreakLvBuff()
    local jjId = self.__dummy.jjId

    local itemAttr = Item:getOneItemByKey(jjId)

    local buffTab = string.split(itemAttr.value, ";")

    local breakLv = buffTab[3] or 0

    return tonumber(breakLv)
end

function XiuLianSystem:setVariates(variates)
    self.__variates = variates
end

function XiuLianSystem:getVariates()
    return self.__variates
end

function XiuLianSystem:getCsjLv()
    return self.__variates.csjLv
end

function XiuLianSystem:getInheritCount()
    return self.__variates.inheritCount
end

function XiuLianSystem:getDsszLv()
    return self.__variates.dsszLv
end

function XiuLianSystem:getInt()
    return self.__variates.int
end

function XiuLianSystem:setStartExp(exp)
    self.__startExp = exp
end

function XiuLianSystem:getStartExp()
    return self.__startExp
end

function XiuLianSystem:setStartLvLimit(lvLimit)
    self.__startLvLimit = lvLimit
end

function XiuLianSystem:getStartLvLimit()
    return self.__startLvLimit
end

function XiuLianSystem:setPlayerLv(playerLv)
    self.__playerLv = playerLv
end

function XiuLianSystem:getPlayerLv()
    return self.__playerLv
end

--@desc: 开始修炼
--@author:LvBin
--@time:2022-04-22 19:47:53
--@skillPrepareType: 修炼武功所属准备类型
--@callback:
--@return
function XiuLianSystem:startXiuLianOnline(skillPrepareType, callback)
    local xiuLianData = {
        ver = 0,
        skillId = self.__skillId,
        skillPrepareType = skillPrepareType,
        xinshen = self:getXinShen(),
        startTime = GetTime(),
        duration = self:calXiuLianTime(),
        selectJing = self:getSelectJing(),
        selectLv = self:getSelectLv(),
        selectTiLi = self:getSelectTiLi(),
        xinShenCost = self:getCostXinShen(),
        useXgsCount = 0,
        dummy = self:getDummy(),
        variates = self:getVariates(),
        startExp = self:getStartExp(),
        startLvLimit = self:getStartLvLimit(),
        playerLv = self:getPlayerLv()
    }

    self.__player:getServerActionSystem():xiuLianStart(
        xiuLianData,
        self.__codeVersion,
        GetTime(),
        function(ok, errmsg)
            if ok then
                self.__player:addAttr("jing", -self:getSelectJing())

                self.__player:setFlag("精力回复时间", GetTime())

                self:setSkillPrepareType(skillPrepareType)

                self:setIsXiuLianing(true)

                self:setVer(0)

                self:setStartTime(GetTime())

                self:setDuration(self:calXiuLianTime())

                self:setUseXgsCount(0)

                callback(ok, errmsg)
            else
                callback(ok, errmsg)
            end
        end
    )
end

--@desc: 结束修炼
--@author:LvBin
--@time:2022-04-29 19:47:38
--@callback:回调函数
--@return
function XiuLianSystem:stopXiuLianOnline(callback)
    local addExp = 0
    local spillExp = 0
    local csjAddExp = 0
    local xinShenReturn = self:getCostXinShen()
    local tiLiReture = self:getSelectTiLi()

    if self:checkXiuLianCanProfit() then
        addExp, spillExp = self:calXiuLianExpAndSpillExp()
        csjAddExp = self:calCsjAddExp()
        xinShenReturn = self:getBackXinShen()
        tiLiReture = self:getBackTiLi()
    end

    local actionData = {
        skillId = self.__selfCreatedSkillDataId and self.__selfCreatedSkillDataId or self.__skillId,
        addExp = addExp,
        csjAddExp = csjAddExp,
        xinShenReturn = xinShenReturn,
        tiLiReture = tiLiReture
    }

    self.__player:getServerActionSystem():xiuLianFinish(
        actionData,
        self.__codeVersion,
        GetTime(),
        function(ok, errmsg)
            if ok then
                xpcall(function()
                    if self.__selfCreatedSkillDataId then
                        self.__selfCreatedSkillDataId = nil
                    end
                    
                    self.__player:addSkillExp(self.__skillId, addExp)

                    local csjSkillInfo = self.__player:getSkill("changshengjueyang") or self.__player:getSkill("changshengjueyin")
                    if csjSkillInfo then
                        local csjSkill = Skill:getSkill(csjSkillInfo.id)
                        self.__player:addSkillExp(csjSkillInfo.id, csjAddExp)
                    end

                    self:setIsXiuLianing(false)

                    self:costDurable()

					local duration = self:getDuration() - self.__useXgsCount * 3600
	
					duration = math.max(duration,0)
	
					local jingTime = math.min(self:getStartTime() + duration,GetTime())


                    self.__player:setFlag("精力回复时间", jingTime)

                    self.__player:addJing()

                    self.__useXgsCount = 0

                    if spillExp > 0 then
                        RichPrint("main", "因武学等级达到上限或基本功火候未到，本次修炼溢出" .. spillExp .. "经验")
                    end

                    do --每日任务
                        if addExp > 0 then
                            local DailyTasksActivity = require("app.models.Action.DailyTasksActivity")
                            DailyTasksActivity:addDailyTaskPoint("liangong")
                        end
                    end

                    callback(ok, errmsg)
                end,
                function(msg) 
                    local traceback_msg = debug.traceback()
                    print(msg)
                    print(traceback_msg)

                    ErrmsgRecord:addErrmsg(msg .. " ; " ..traceback_msg)
                end)
            else
                callback(ok, errmsg)
            end
        end
    )
end

function XiuLianSystem:getXiuLianTiLi(callback)
    self.__player:getServerActionSystem():getLianGongTiLi(
        self.__codeVersion,
        function(ok, errmsg, data)
            if ok then
                callback(ok, errmsg, data)
            else
                callback(ok, errmsg)
            end
        end
    )
end

--@desc: 检查修炼是否完成
--@author:LvBin
--@time:2022-03-09 17:30:11
--@return
function XiuLianSystem:checkXiuLianIsFinish()
    if GetTime() + self.__useXgsCount * 3600 >= self:getEndTime() then
        return true
    end

    return false
end

--@desc: 检查修炼能否获得收益，修炼不足一分钟且修炼未完成，取消修炼无收益
--@author:LvBin
--@time:2022-04-12 19:17:28
--@return
function XiuLianSystem:checkXiuLianCanProfit()
    if GetTime() - self:getStartTime() + self.__useXgsCount * 3600 < 60 and self:checkXiuLianIsFinish() == false then
        return false
    end

    return true
end

--@desc: 修炼剩余时间
--@author:LvBin
--@time:2022-03-21 12:23:42
--@return
function XiuLianSystem:getResidueTime()
    return math.max(math.ceil(self:getEndTime() - self.__useXgsCount * 3600 - GetTime()), 0)
end

--@desc: 刷新修炼
--@author:LvBin
--@time:2022-03-09 15:34:26
--@return
function XiuLianSystem:updata()
    -- if self:checkXiuLianIsFinish() == true then
    --     self:stopXiuLian()
    --     return
    -- end
end

--@desc: 使用行功散
--@author:LvBin
--@time:2022-03-10 11:05:39
--@count: 数量
--@return
function XiuLianSystem:useXingGongSan(count, callback)
    self.__player:getServerActionSystem():xiuLianUseXingGongSan(
        self.__codeVersion,
        GetTime(),
        function(ok, errmsg)
            if ok then
                self.__useXgsCount = self.__useXgsCount + count
                callback(ok, errmsg)
            else
                callback(ok, errmsg)
            end
        end
    )
end

--@desc: 心神能够修炼时长
--@author:LvBin
--@time:2022-04-20 15:12:16
--@return
function XiuLianSystem:getXinShenTime()
    local currXinShen = self:getXinShen()

    local unitCostXinshen = self:getUnitCostXinShen()

    local xinshenTime = Helper:preciseDecimal(currXinShen / unitCostXinshen, 10)

    return xinshenTime
end

--@desc: 获取修炼时间上限
--@author:LvBin
--@time:2022-04-20 15:12:37
--@return
function XiuLianSystem:getXiuLianTimeLimit()
    return LianGongParamsManager:getConfContent("4")
end

--[[
    @desc: 无任何加速情况下,正常需要的修炼时长
    author:{author}
    time:2022-03-20 19:19:31
    @return:
]]
function XiuLianSystem:getXiuLianNormalTime()
    local timeLimit = self:getXiuLianTimeLimit()

    local baseTime = self:getBaseXiuLianTime()

    local xinshenTime = self:getXinShenTime()

    local time = math.min(math.min(math.min(xinshenTime, baseTime), timeLimit), self:getDummyCanXiuLianTime())

    local minTime = 1/self:getUnitCostXinShen()

    local currXinShen = self:getXinShen()
    
    if currXinShen <= 0 then
        minTime = 0
    end

    time = math.max(time,minTime)

    return math.ceil(time)
end

function XiuLianSystem:getDummyCanXiuLianTime()
    local durable = self.__dummy.durable

    local time = durable * LianGongParamsManager:getConfContent("7")

    return time
end

function XiuLianSystem:getUnitCostXinShen()
    local baseXinShen = LianGongParamsManager:getConfContent("12")

    local jingBuff = self:getDummyJingBuff()

    local unitCostXinshen = baseXinShen * (1 - jingBuff * LianGongParamsManager:getConfContent("13"))

    return unitCostXinshen
end

--@desc: 计算修炼等级上限
--@author:LvBin
--@time:2022-04-22 16:20:17
--@jibenSkillLv: 对应基本功等级
--@return
function XiuLianSystem:calXiuLianLvLimit(jibenSkillLv)
    local dummyCanXiuLianTime = self:getDummyCanXiuLianTime()

    local unitAddExp = self:getUnitAddExp()

    local timeLimit = self:getXiuLianTimeLimit()

    local xinshenTime = self:getXinShenTime()

    local time = math.min(xinshenTime, timeLimit)

    local actualTime = 0

    if dummyCanXiuLianTime >= time then
        actualTime = time
    else
        actualTime = dummyCanXiuLianTime
    end

    local addExp = actualTime * unitAddExp

    local startExp = self:getStartExp()

    local startLv = self.__player:conversionSkillExpAndLv("lv",startExp)

    local predictLv = self.__player:conversionSkillExpAndLv("lv",startExp + addExp)

    local predictLvMax = math.max(predictLv,startLv + 1)

    local lvMax = math.min(math.min(self:getPlayerLv(),self:getStartLvLimit()),Helper:mathFloor(jibenSkillLv) + 1 + self:getDummyBreakLvBuff())

    local lvLimit = math.min(predictLvMax,lvMax)

    return lvLimit
end

--@desc: 修炼预计获得武学经验
--@author:LvBin
--@time:2022-03-21 10:16:17
--@return
function XiuLianSystem:getPredictExp()
    local predictExp = self:getCostXinShen() * self:getUnitXinShenAddExp()

    return math.ceil(predictExp)
end

--[[
    @desc: 一次修炼需要时长
    author:{author}
    time:2022-03-17 18:07:50
    @return:
]]
function XiuLianSystem:calXiuLianTime()
    local normalTime = self:getXiuLianNormalTime()

    local time = normalTime - self:getXiuLianSpeedUpTime()

    return math.ceil(time)
end

--@desc: 计算武学修炼实际获得的武学经验和溢出经验
--@author:LvBin
--@time:2022-04-22 21:27:31
--@return
function XiuLianSystem:calXiuLianExpAndSpillExp()
    local exp = (self:getCostXinShen() - self:getBackXinShen()) * self:getUnitXinShenAddExp()

    exp = math.ceil(exp)

    local currExp = self.__player:getSkillExp(self.__skillId)
    
    local jibenSkillLv = self.__player:getSkillLv(self:getJiBenSkillId())

    local lvMax = math.min(self.__player:getLv(),Helper:mathFloor(jibenSkillLv) + 1 + self:getDummyBreakLvBuff())

    local limitLvMinExp = self.__player:conversionSkillExpAndLv("exp",self.__player:getSkillLvLimit(self.__skillId))

    local spillExp = 0

    local expMax = math.min(self.__player:conversionSkillExpAndLv("exp", lvMax + 1) - 1,limitLvMinExp)
    
	local canAddExp = math.max(expMax - currExp,0)

    if exp > canAddExp then
        spillExp = math.floor(exp - (canAddExp))

        exp = math.ceil(canAddExp)
    end

    return exp, spillExp
end

--[[
    @desc: 修炼实际收益时长
    author:{author}
    time:2022-03-20 20:01:54
    @return:
]]
function XiuLianSystem:getXiuLianActualTime()
    local currTime = GetTime()

    local duration = currTime - self:getStartTime()

    local actualTime = math.min(duration + self.__useXgsCount * 3600, self:getDuration()) * 1 / (1 - self:getXiuLianSpeedUpRatio())

    actualTime = math.min(actualTime,self:getXiuLianNormalTime())

    return math.ceil(actualTime)
end

--[[
    @desc: 武学升级挂机时长比例加速:指不同养成系统，按比例缩短武学升级挂机时长的比例总和。
    author:{author}
    time:2022-03-19 18:22:23
    @return:
]]
function XiuLianSystem:getXiuLianSpeedUpRatio()
    local costXinShen = self:getCostXinShen()

    local jingUpRatio = LianGongParamsManager:getConfContent("11") * (self:getSelectJing() / (costXinShen * LianGongParamsManager:getConfContent("10")))

    local dummyUpRatio = self:getDummyJingBuff() * LianGongParamsManager:getConfContent("6")

    local csjUpRatio = 0

    local csjLv = self:getCsjLv()
    if csjLv >= 600 then
        csjUpRatio = math.pow(csjLv, 2) / LianGongParamsManager:getConfContent("5")
    end

    local inheritUpRatio = self:getInheritCount() * LianGongParamsManager:getConfContent("8")

    local tiliUpRatio = LianGongParamsManager:getConfContent("28") * (self:getSelectTiLi() / (costXinShen * LianGongParamsManager:getConfContent("29")))

    local ratio = jingUpRatio + dummyUpRatio + csjUpRatio + inheritUpRatio + tiliUpRatio

    local ratioLimit = LianGongParamsManager:getConfContent("27")

    ratio = Helper:preciseDecimal(math.min(ratio, ratioLimit),10)

    print("精力加速：",jingUpRatio)
    print("假人加速：",dummyUpRatio)
    print("长生诀加速：",csjUpRatio)
    print("传承加速：",inheritUpRatio)
    print("笃志加速：",tiliUpRatio)
    print("武学升级挂机时长比例加速：",ratio)

    return ratio
end

--@desc: 需要消耗的心神数值
--@author:LvBin
--@time:2022-03-21 15:01:07
--@return
function XiuLianSystem:getCostXinShen()
    local normalTime = self:getXiuLianNormalTime()

    local costXinShen = math.min(normalTime * self:getUnitCostXinShen(),self:getPredictCostXinShen())

    -- costXinShen = math.max(math.floor(costXinShen),1)

    costXinShen = math.ceil(costXinShen)

    local currXinShen = self:getXinShen()
    
    if currXinShen <= 0 then
        costXinShen = 0
    end

    return costXinShen
end

--@desc: 中途停止修炼返还心神值
--@author:LvBin
--@time:2022-03-21 15:01:29
--@return
function XiuLianSystem:getBackXinShen()
    local costXinShen = self:getCostXinShen()

    local duration = GetTime() - self:getStartTime()

    duration = math.min(duration + self.__useXgsCount * 3600, self:getDuration())

   local backXinShen = costXinShen *(1 - duration / self:calXiuLianTime())

    return math.max(math.floor(backXinShen), 0)
end

--@desc: 根据选择修炼等级获取基础修炼时长
--@author:LvBin
--@time:2022-04-20 15:14:49
--@return
function XiuLianSystem:getBaseXiuLianTime()
    local startExp = self:getStartExp()

    local finalExp = self:getSelectLvConversionExp()

    local addExp = finalExp - startExp

    local unitAddExp = self:getUnitAddExp()

    local baseTime = addExp / unitAddExp

    return Helper:preciseDecimal(baseTime, 6)
end

--@desc: 获取修炼至指定等级所需最小时间
--@author:LvBin
--@time:2022-04-20 18:53:35
--@lv: 修炼至的等级
--@return
function XiuLianSystem:getXiuLianMinTimeByLv(lv)
    local startExp = self:getStartExp()

    local finalExp = self.__player:conversionSkillExpAndLv("exp", lv)

    local addExp = finalExp - startExp

    local unitAddExp = self:getUnitAddExp()

    local minTime = addExp / unitAddExp

    return minTime
end

--[[
    @desc: 每秒获得武学经验
    author:{author}
    time:2022-03-18 18:21:25
    @return:
]]
function XiuLianSystem:getUnitAddExp()
    local skill = Skill:getSkill(self.__skillId)

    local baseUnitExp = LianGongParamsManager:getConfContent("14")

    local baseIntCorrection = LianGongParamsManager:getConfContent("15")

    local dushuCorrection = math.floor(self:getDsszLv() / 10)

    local unitAddExp = baseUnitExp * skill:getLearnPotEfficiency() * (baseIntCorrection + self:getInt() + dushuCorrection)

    local expBuff = self:getDummyExpBuff()

    unitAddExp = unitAddExp * (1 + LianGongParamsManager:getConfContent("16") * expBuff)

    return unitAddExp
end

--[[
    @desc: 武学修炼加速时长
    author:{author}
    time:2022-03-20 19:32:28
    @return:
]]
function XiuLianSystem:getXiuLianSpeedUpTime()
    local normalTime = self:getXiuLianNormalTime()

    local speedUpRatio = self:getXiuLianSpeedUpRatio()

    local speedTime = normalTime * speedUpRatio

    return math.ceil(speedTime)
end

--@desc: 可选精力最大值
--@author:LvBin
--@time:2022-03-24 10:49:52
--@return
function XiuLianSystem:getCanSelectJingMax()
    local costXinShen = self:getCostXinShen()

    local canSelectJingMax = costXinShen * LianGongParamsManager:getConfContent("10")

    return math.floor(canSelectJingMax)
end

--@desc: 可选笃志最大值
--@author:LvBin
--@time:2022-10-27 16:55:24
--@return
function XiuLianSystem:getCanSelectTiLiMax()
    local costXinShen = self:getCostXinShen()

    local canSelectTiLiMax = costXinShen * LianGongParamsManager:getConfContent("29")

    return math.ceil(canSelectTiLiMax)
end

--@desc: 中途停止练功返还体力值
--@author:LvBin
--@time:2022-10-27 17:55:24
--@return
function XiuLianSystem:getBackTiLi()
    local duration = GetTime() - self:getStartTime()

    duration = math.min(duration + self.__useXgsCount * 3600, self:getDuration())

    local backTiLi = self:getSelectTiLi() *(1 - duration / self:calXiuLianTime())

    return math.max(math.floor(backTiLi), 0)
end

function XiuLianSystem:calCsjAddExp()
    local retExp = 0

    local csjSkillInfo = self.__player:getSkill("changshengjueyang") or self.__player:getSkill("changshengjueyin")

    if csjSkillInfo then
        local csjLv = self.__player:getSkillLv(csjSkillInfo.id)
        if csjLv >= 600 then
            local csjSkill = Skill:getSkill(csjSkillInfo.id)

            local baseUnitExp = LianGongParamsManager:getConfContent("14")

            local baseIntCorrection = LianGongParamsManager:getConfContent("15")

            local dushuCorrection = math.floor(self:getDsszLv() / 10)

            local csjUnitAddExp = baseUnitExp * csjSkill:getLearnPotEfficiency() * (baseIntCorrection + self:getInt() + dushuCorrection) * (csjLv / 2000)

            local duration = GetTime() - self:getStartTime()

            duration = math.min(duration + self.__useXgsCount * 3600, self:getDuration())

            local addCsjExp = csjUnitAddExp * duration

            retExp = addCsjExp
        end
    end

    return retExp
end

--@desc: 修炼结束时扣除耐久
--@author:LvBin
--@time:2022-03-25 14:53:39
function XiuLianSystem:costDurable()
    if self:checkDummyDurableIsUnlimit() then
        self.__dummy.durable = 9999
    else
        local costDurable = self:getCurrPredictCostDurable()
    
        self.__dummy.durable = self.__dummy.durable - costDurable

        if self.__dummy.durable < 1 then
            self.__dummy.durable = 0
        end
    end

    local extraAttr = {{fid = self.__dummy.fid, attr = {durable = self.__dummy.durable}}}

    HttpManagerEx:uploadFurnitureExtra(
        self.__player:getHouseId(),
        extraAttr,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if self.__player:getCurrMap() and self.__player:getCurrMap():getRoleIsInMap() == true then
                        local curMap = self.__player:getCurrMap()
                        local currRole = curMap:getRole("f_" .. self.__dummy.fid)
                        if currRole then
                            currRole.durable = self.__dummy.durable
                        end
                    end
                    RichPrint("main", "HIC你调整呼吸，收起架势，停止了修炼。")
                    return true
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

--@desc: 获取修炼结束预计扣除耐久值
--@author:LvBin
--@time:2022-03-25 14:54:44
--@return
function XiuLianSystem:getPredictCostDurable()
    local duration = self:calXiuLianTime()

    local predictCostDurable = math.ceil(duration / LianGongParamsManager:getConfContent("7"))

    return predictCostDurable
end

--@desc: 获取当前预计扣除耐久值
--@author:LvBin
--@time:2022-03-25 15:28:25
--@return
function XiuLianSystem:getCurrPredictCostDurable()
    local duration = GetTime() - self:getStartTime()

    duration = math.min(duration + self.__useXgsCount * 3600, self:getDuration())

    local predictCostDurable = math.ceil(duration / LianGongParamsManager:getConfContent("7"))

    return predictCostDurable
end

--@desc: 检查假人耐久是否无限制
--@author:LvBin
--@time:2022-04-18 15:00:15
--@return
function XiuLianSystem:checkDummyDurableIsUnlimit()
    local itemAttr = Item:getOneItemByKey(self.__dummy.jjId)
    if itemAttr.att >= 9999 then
        return true
    end
    return false
end

function XiuLianSystem:getJiBenSkillId()
    local prepareType = self:getSkillPrepareType()

    local prepareList = SkillConst.PrepareList

    local jibenSkillId = prepareList[prepareType]

    return jibenSkillId
end

--@desc: 获取修炼选择等级下限
--@author:LvBin
--@time:2022-04-26 18:03:46
--@jibenSkillLv: 
--@return
function XiuLianSystem:getXiuLianSelectMinLv(jibenSkillLv)
    -- local minExp = self:getStartExp() + self:getUnitXinShenAddExp()

    -- local minLv = self.__player:conversionSkillExpAndLv("lv",minExp)

    local minLv = self.__player:conversionSkillExpAndLv("lv",self:getStartExp()) + 1

    local selectMinLv = math.min(math.min(math.min(self:getStartLvLimit(),Helper:mathFloor(jibenSkillLv) + 1 + self:getDummyBreakLvBuff()),self:getPlayerLv()),minLv)

    return selectMinLv
end

function XiuLianSystem:getSelectLvConversionExp()
    local exp = self.__player:conversionSkillExpAndLv("exp", self:getSelectLv())
    -- if self:getSelectLv() < self:getStartLvLimit() then
    --     exp = self.__player:conversionSkillExpAndLv("exp", self:getSelectLv() + 1) - 1
    -- else
    --     exp = self.__player:conversionSkillExpAndLv("exp", self:getSelectLv())
    -- end

    return math.ceil(exp)
end

--@desc: 每心神增加武学经验
--@author:LvBin
--@time:2022-04-26 19:13:20
--@return
function XiuLianSystem:getUnitXinShenAddExp()
    local exp = self:getUnitAddExp() * 1/self:getUnitCostXinShen()

    return Helper:preciseDecimal(exp, 6) 
end

--@desc: 预计需要消耗心神
--@author:LvBin
--@time:2022-04-26 18:28:56
--@return
function XiuLianSystem:getPredictCostXinShen()
    local predictCostXinShen = (self:getSelectLvConversionExp() - self:getStartExp()) / self:getUnitXinShenAddExp()

    return math.ceil(predictCostXinShen)
end

return newClass("XiuLianSystem", {}, XiuLianSystem)
000000000
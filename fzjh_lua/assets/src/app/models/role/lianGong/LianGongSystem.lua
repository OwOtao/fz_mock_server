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

local LianGongSystem = {
    __codeVersion = 1,
    __ver = 0,
    __skillId = nil,
    __skillPrepareType = nil,
    __xinshen = 0,
    __startTime = nil,
    __duration = nil,
    __selectJing = nil,
    __selectLv = nil,
    __selectTiLi = nil,
    __useXgsCount = 0,
    __variates = {},
    __startExp = nil,
    __startLvLimit = nil,
    __playerLv = nil
}

function LianGongSystem:create(player)
    local p = LianGongSystem.new(TableProxy:createEncryptedTable({}))
    p:__init(player)
    return p
end

function LianGongSystem:ctor()
    self.__isNotSerializable = true

    self.__hasPulledData = false

    self.__isLianGonging = false

    self.__player = nil
end

function LianGongSystem:__init(player)
    self.__player = player
end

--@desc: 结束旧版练功
--@author:LvBin
--@time:2022-04-13 09:50:42
--@return
function LianGongSystem:stopOldLianGong()
    if self.__player:getInheritFlag("stopOldLianGong") == 0 then
        local roleCurrState = self.__player:getAttr("roleCurrState")
        local isOldLianGong = false

        if MapIsEmpty(roleCurrState) == false then
            for state, bool in pairs(roleCurrState) do
                if tostring(state) == tostring(ROLE_CURR_STATE_LIANGONG) then
                    isOldLianGong = true
                    break
                end
            end
        end

        if isOldLianGong then
            self.__player:lianGong()
            self.__player:stopLianGong()
        end

        self.__player:setInheritFlag("stopOldLianGong", 1)
    end
end

function LianGongSystem:initData(data)
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

    self:setStartExp(data.startExp)

    self:setStartLvLimit(data.startLvLimit)
    
    self:setPlayerLv(data.playerLv)
end

function LianGongSystem:getLianGongState()
    local ok, isLianGong = AsyncFunction:asyncAwaitWithCallback(self.__player:getServerActionSystem().getLianGongState, self.__player:getServerActionSystem(), self.__codeVersion, "callback")
    return ok, isLianGong == 1
end

function LianGongSystem:pullLianGongData(callback)
    self.__player:getServerActionSystem():getLianGongData(
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

function LianGongSystem:getPlayer()
    return self.__player
end

function LianGongSystem:setIsLianGonging(b)
    self.__isLianGonging = b
end

function LianGongSystem:isLianGonging()
    return self.__isLianGonging
end

--@desc: 设置版本号
--@author:LvBin
--@time:2022-03-21 12:07:07
--@ver:
--@return
function LianGongSystem:setVer(ver)
    self.__ver = ver
end

function LianGongSystem:getVer()
    return self.__ver
end

--@desc: 设置练功所需时长
--@author:LvBin
--@time:2022-03-21 12:07:36
--@return
function LianGongSystem:setDuration(duration)
    self.__duration = duration
end

function LianGongSystem:getDuration()
    return self.__duration
end

function LianGongSystem:getEndTime()
    return self:getStartTime() + self:getDuration()
end

function LianGongSystem:setXinShen(num)
    self.__xinshen = num
end

function LianGongSystem:setSkillId(skillId)
    self.__skillId = skillId
end

function LianGongSystem:getSkillId()
    return self.__skillId
end

function LianGongSystem:setSkillPrepareType(skillPrepareType)
    self.__skillPrepareType = skillPrepareType
end

function LianGongSystem:getSkillPrepareType()
    return self.__skillPrepareType
end

function LianGongSystem:getXinShen()
    return self.__xinshen
end

function LianGongSystem:setSelectJing(jingNum)
    self.__selectJing = jingNum
end

function LianGongSystem:getSelectJing()
    return self.__selectJing
end

function LianGongSystem:setSelectLv(skillLv)
    self.__selectLv = skillLv
end

function LianGongSystem:getSelectLv()
    return self.__selectLv
end

function LianGongSystem:setSelectTiLi(tiliNum)
    self.__selectTiLi = tiliNum
end

function LianGongSystem:getSelectTiLi()
    return self.__selectTiLi
end

function LianGongSystem:setStartTime(time)
    self.__startTime = time
end

function LianGongSystem:getStartTime()
    return self.__startTime
end

function LianGongSystem:setUseXgsCount(count)
    self.__useXgsCount = count
end

function LianGongSystem:setVariates(variates)
    self.__variates = variates
end

function LianGongSystem:getVariates()
    return self.__variates
end

function LianGongSystem:getCsjLv()
    return self.__variates.csjLv
end

function LianGongSystem:getInheritCount()
    return self.__variates.inheritCount
end

function LianGongSystem:getDsszLv()
    return self.__variates.dsszLv
end

function LianGongSystem:getInt()
    return self.__variates.int
end

function LianGongSystem:setStartExp(exp)
    self.__startExp = exp
end

function LianGongSystem:getStartExp()
    return self.__startExp
end

function LianGongSystem:setStartLvLimit(lvLimit)
    self.__startLvLimit = lvLimit
end

function LianGongSystem:getStartLvLimit()
    return self.__startLvLimit
end

function LianGongSystem:setPlayerLv(playerLv)
    self.__playerLv = playerLv
end

function LianGongSystem:getPlayerLv()
    return self.__playerLv
end

--@desc: 开始练功
--@author:LvBin
--@time:2022-03-21 11:35:37
--@skillPrepareType: 武功技能栏所准备的类型
--@return
function LianGongSystem:startLianGongOnline(skillPrepareType, callback)
    self.__lianGongData = {
        ver = 0,
        skillId = self.__skillId,
        skillPrepareType = skillPrepareType,
        xinshen = self:getXinShen(),
        startTime = GetTime(),
        duration = self:calLianGongTime(),
        selectJing = self:getSelectJing(),
        selectLv = self:getSelectLv(),
        selectTiLi = self:getSelectTiLi(),
        xinShenCost = self:getCostXinShen(),
        useXgsCount = 0,
        variates = self:getVariates(),
        startExp = self:getStartExp(),
        startLvLimit = self:getStartLvLimit(),
        playerLv = self:getPlayerLv()
    }

    self.__player:getServerActionSystem():lianGongStart(
        self.__lianGongData,
        self.__codeVersion,
        GetTime(),
        function(ok, errmsg)
            if ok then
                self.__player:addAttr("jing", -self:getSelectJing())

                -- self.__player:setFlag("当前武功", self.__skillId)

                self.__player:setFlag("武功准备类型", skillPrepareType)

                self.__player:setFlag("精力回复时间", GetTime())

                self:setSkillPrepareType(skillPrepareType)

                self:setIsLianGonging(true)

                self:setVer(0)

                self:setStartTime(GetTime())

                self:setDuration(self:calLianGongTime())

                self:setUseXgsCount(0)
                callback(ok, errmsg)
            else
                callback(ok, errmsg)
            end
        end
    )
end

--@desc: 结束练功
--@author:LvBin
--@time:2022-04-29 19:35:25
--@callback: 回调函数
--@return
function LianGongSystem:stopLianGongOnline(callback)
    local addExp = 0
    local spillExp = 0
    local csjAddExp = 0
    local xinShenReturn = self:getCostXinShen()
    local tiLiReture = self:getSelectTiLi()

    if self:checkLianGongCanProfit() then
        addExp,spillExp = self:calLianGongExpAndSpillExp()
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

    self.__player:getServerActionSystem():lianGongFinish(
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

                    self.__player:setFlag("当前武功", nil)

                    self.__player:setFlag("武功准备类型", nil)
                    
                    self:setIsLianGonging(false)

					local duration = self:getDuration() - self.__useXgsCount * 3600
	
					duration = math.max(duration,0)
	
					local jingTime = math.min(self:getStartTime() + duration,GetTime())

                    self.__player:setFlag("精力回复时间", jingTime)

                    self.__player:addJing()

                    self.__useXgsCount = 0

                    if spillExp > 0 then
                        RichPrint("main","因武学等级达到上限或基本功火候未到，本次练功溢出"..spillExp.."经验")
                    end

                    do  --每日任务
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

function LianGongSystem:getLianGongTiLi(callback)
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

--@desc: 检查练功是否完成
--@author:LvBin
--@time:2022-03-09 17:30:11
--@return
function LianGongSystem:checkLianGongIsFinish()
    if GetTime() + self.__useXgsCount * 3600 >= self:getEndTime() then
        return true
    end

    return false
end

--@desc: 检查练功能否获得收益，练功不足一分钟且练功未完成，取消练功无收益
--@author:LvBin
--@time:2022-04-12 18:57:49
--@return
function LianGongSystem:checkLianGongCanProfit()
    if GetTime() - self:getStartTime() + self.__useXgsCount * 3600 < 60 and self:checkLianGongIsFinish() == false then
        return false
    end

    return true
end

--@desc: 练功剩余时间
--@author:LvBin
--@time:2022-03-21 12:23:42
--@return
function LianGongSystem:getResidueTime()
    return math.max(math.ceil(self:getEndTime() - self.__useXgsCount * 3600 - GetTime()), 0)
end

--@desc: 刷新练功
--@author:LvBin
--@time:2022-03-09 15:34:26
--@return
function LianGongSystem:updata()
end

--@desc: 使用行功散
--@author:LvBin
--@time:2022-03-10 11:05:39
--@count: 数量
--@return
function LianGongSystem:useXingGongSan(count, callback)
    self.__player:getServerActionSystem():lianGongUseXingGongSan(
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

--@desc: 心神能够练功时长
--@author:LvBin
--@time:2022-04-20 14:31:35
--@return
function LianGongSystem:getXinShenTime()
    local currXinShen = self:getXinShen()

    local baseXinShen = self:getUnitCostXinShen()

    local xinshenTime = Helper:preciseDecimal(currXinShen / baseXinShen, 10)

    return xinshenTime
end

--@desc: 获取练功时间上限
--@author:LvBin
--@time:2022-04-20 15:07:48
--@return
function LianGongSystem:getLianGongTimeLimit()
    return LianGongParamsManager:getConfContent("3")
end

--[[
    @desc: 无任何加速情况下,正常需要的练功时长
    author:{author}
    time:2022-03-20 19:19:31
    @return:
]]
function LianGongSystem:getLianGongNormalTime()
    local timeLimit = self:getLianGongTimeLimit()

    local baseTime = self:getBaseLianGongTime()

    local xinshenTime = self:getXinShenTime()

    local time = math.min(math.min(xinshenTime, baseTime), timeLimit)

    local minTime = 1/self:getUnitCostXinShen()

    local currXinShen = self:getXinShen()
    
    if currXinShen <= 0 then
        minTime = 0
    end

    time = math.max(time,minTime)

    return math.ceil(time)
end

--@desc: 计算练功等级上限
--@author:LvBin
--@time:2022-04-22 15:19:38
--@jibenSkillLv: 对应基本功等级
--@return
function LianGongSystem:calLianGongLvLimit(jibenSkillLv)
    local unitAddExp = self:getUnitAddExp()

    local timeLimit = self:getLianGongTimeLimit()

    local xinshenTime = self:getXinShenTime()
    
    local time = math.min(xinshenTime, timeLimit)
    
    local addExp = time * unitAddExp
    
    local startExp = self:getStartExp()
    
    local startLv = self.__player:conversionSkillExpAndLv("lv",startExp)

    local predictLv = self.__player:conversionSkillExpAndLv("lv",startExp + addExp)

    local predictLvMax = math.max(predictLv,startLv + 1)

    local lvMax = math.min(math.min(self:getPlayerLv(),self:getStartLvLimit()),Helper:mathFloor(jibenSkillLv) + 1)

    local lvLimit = math.min(predictLvMax,lvMax)

    return lvLimit
end

--@desc: 练功预计获得武学经验
--@author:LvBin
--@time:2022-03-21 10:16:17
--@return
function LianGongSystem:getPredictExp()
    local predictExp = self:getCostXinShen() * self:getUnitXinShenAddExp()

    return math.ceil(predictExp)
end

--[[
    @desc: 一次练功需要时长
    author:{author}
    time:2022-03-17 18:07:50
    @return:
]]
function LianGongSystem:calLianGongTime()
    local normalTime = self:getLianGongNormalTime()

    local time = normalTime - self:getLianGongSpeedUpTime()

    return math.ceil(time)
end

--[[
    @desc: 计算武学升级实际获得的武学经验和溢出经验
    author:{author}
    time:2022-03-20 19:54:59
    @return:
]]
function LianGongSystem:calLianGongExpAndSpillExp()
    local exp = (self:getCostXinShen() - self:getBackXinShen()) * self:getUnitXinShenAddExp()

    exp = math.ceil(exp)

    local currExp = self.__player:getSkillExp(self.__skillId)

    local jibenSkillLv = self.__player:getSkillLv(self:getJiBenSkillId())

    local lvMax = math.min(self.__player:getLv(),Helper:mathFloor(jibenSkillLv) + 1)
    
    local limitLvMinExp = self.__player:conversionSkillExpAndLv("exp",self.__player:getSkillLvLimit(self.__skillId))

    local spillExp = 0

    local expMax = math.min(self.__player:conversionSkillExpAndLv("exp", lvMax + 1) - 1,limitLvMinExp)
    
	local canAddExp = math.max(expMax - currExp,0)

    if exp > canAddExp then
        spillExp = math.floor(exp - canAddExp)

        exp = math.ceil(canAddExp)
    end

    return exp,spillExp
end

--[[
    @desc: 练功实际收益时长
    author:{author}
    time:2022-03-20 20:01:54
    @return:
]]
function LianGongSystem:getLianGongActualTime()
    local currTime = GetTime()

    local duration = currTime - self:getStartTime()

    local actualTime = math.min(duration + self.__useXgsCount * 3600, self:getDuration()) * 1 / (1 - self:getLianGongSpeedUpRatio())

    actualTime = math.min(actualTime,self:getLianGongNormalTime())

    return math.ceil(actualTime)
end

--[[
    @desc: 武学升级挂机时长比例加速:指不同养成系统，按比例缩短武学升级挂机时长的比例总和。
    author:{author}
    time:2022-03-19 18:22:23
    @return:
]]
function LianGongSystem:getLianGongSpeedUpRatio()
    local costXinShen = self:getCostXinShen()

    local jingUpRatio = LianGongParamsManager:getConfContent("11") * (self:getSelectJing() / (costXinShen * LianGongParamsManager:getConfContent("10")))

    local csjUpRatio = 0

    local csjLv = self:getCsjLv()
    if csjLv >= 600 then
        csjUpRatio = math.pow(csjLv, 2) / LianGongParamsManager:getConfContent("5")
    end

    local inheritUpRatio = self:getInheritCount() * LianGongParamsManager:getConfContent("8")

    local tiliUpRatio = LianGongParamsManager:getConfContent("28") * (self:getSelectTiLi() / (costXinShen * LianGongParamsManager:getConfContent("29")))

    local ratio = jingUpRatio + csjUpRatio + inheritUpRatio + tiliUpRatio

    local ratioLimit = LianGongParamsManager:getConfContent("26")

    ratio = Helper:preciseDecimal(math.min(ratio, ratioLimit),10)

    print("精力加速：",jingUpRatio)
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
function LianGongSystem:getCostXinShen()
    local normalTime = self:getLianGongNormalTime()

    local costXinShen = math.min(normalTime * self:getUnitCostXinShen(),self:getPredictCostXinShen())
    
    -- costXinShen = math.max(math.floor(costXinShen),1)
    costXinShen = math.ceil(costXinShen)

    local currXinShen = self:getXinShen()
    
    if currXinShen <= 0 then
        costXinShen = 0
    end

    return costXinShen
end

--@desc: 中途停止练功返还心神值
--@author:LvBin
--@time:2022-03-21 15:01:29
--@return
function LianGongSystem:getBackXinShen()
    local costXinShen = self:getCostXinShen()

    local duration = GetTime() - self:getStartTime()

    duration = math.min(duration + self.__useXgsCount * 3600, self:getDuration())

    local backXinShen = costXinShen *(1 - duration / self:calLianGongTime())

    return math.max(math.floor(backXinShen), 0)
end

--@desc: 根据选择练功等级获取基础练功时长
--@author:LvBin
--@time:2022-04-20 14:35:51
--@return
function LianGongSystem:getBaseLianGongTime()
    local startExp = self:getStartExp()

    local finalExp = self:getSelectLvConversionExp()

    local addExp = finalExp - startExp

    local unitAddExp = self:getUnitAddExp()

    local baseTime = addExp / unitAddExp

    return Helper:preciseDecimal(baseTime, 6)
end

--@desc: 获取升级至指定等级所需最小时间
--@author:LvBin
--@time:2022-04-20 18:26:39
--@addLv: 指定等级
--@return
function LianGongSystem:getLianGongMinTimeByLv(lv)
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
function LianGongSystem:getUnitAddExp()
    local skill = Skill:getSkill(self.__skillId)

    local baseUnitExp = LianGongParamsManager:getConfContent("14")

    local baseIntCorrection = LianGongParamsManager:getConfContent("15")

    local dushuCorrection = math.floor(self:getDsszLv() / 10)

    local unitAddExp = baseUnitExp * skill:getLearnPotEfficiency() * (baseIntCorrection + self:getInt() + dushuCorrection)

    return unitAddExp
end

--[[
    @desc: 武学练功加速时长
    author:{author}
    time:2022-03-20 19:32:28
    @return:
]]
function LianGongSystem:getLianGongSpeedUpTime()
    local normalTime = self:getLianGongNormalTime()

    local speedUpRatio = self:getLianGongSpeedUpRatio()

    local speedTime = normalTime * speedUpRatio

    return math.ceil(speedTime)
end

--@desc: 可选精力最大值
--@author:LvBin
--@time:2022-03-24 10:49:52
--@return
function LianGongSystem:getCanSelectJingMax()
    local costXinShen = self:getCostXinShen()

    local canSelectJingMax = costXinShen * LianGongParamsManager:getConfContent("10")

    return math.ceil(canSelectJingMax)
end

--@desc: 可选笃志最大值
--@author:LvBin
--@time:2022-10-27 16:55:24
--@return
function LianGongSystem:getCanSelectTiLiMax()
    local costXinShen = self:getCostXinShen()

    local canSelectTiLiMax = costXinShen * LianGongParamsManager:getConfContent("29")

    return math.ceil(canSelectTiLiMax)
end

--@desc: 中途停止练功返还笃志值
--@author:LvBin
--@time:2022-10-27 17:55:24
--@return
function LianGongSystem:getBackTiLi()
    local duration = GetTime() - self:getStartTime()

    duration = math.min(duration + self.__useXgsCount * 3600, self:getDuration())

    local backTiLi = self:getSelectTiLi() *(1 - duration / self:calLianGongTime())

    return math.max(math.floor(backTiLi), 0)
end

function LianGongSystem:calCsjAddExp()
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

function LianGongSystem:getJiBenSkillId()
    local prepareType = self:getSkillPrepareType()

    local prepareList = SkillConst.PrepareList

    local jibenSkillId = prepareList[prepareType]

    return jibenSkillId
end

function LianGongSystem:getUnitCostXinShen()
    return LianGongParamsManager:getConfContent("12")
end

--@desc: 获取练功选择等级下限
--@author:LvBin
--@time:2022-04-26 18:03:46
--@jibenSkillLv: 
--@return
function LianGongSystem:getLianGongSelectMinLv(jibenSkillLv)
    -- local minExp = self:getStartExp() + self:getUnitXinShenAddExp()

    -- local minLv = self.__player:conversionSkillExpAndLv("lv",minExp)

    local minLv = self.__player:conversionSkillExpAndLv("lv",self:getStartExp()) + 1

    local selectMinLv = math.min(math.min(math.min(self:getStartLvLimit(),Helper:mathFloor(jibenSkillLv) + 1),self:getPlayerLv()),minLv)

    return minLv
end

function LianGongSystem:getSelectLvConversionExp()
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
function LianGongSystem:getUnitXinShenAddExp()
    local exp = self:getUnitAddExp() * 1/self:getUnitCostXinShen()

    return Helper:preciseDecimal(exp, 6)
end

--@desc: 预计需要消耗心神
--@author:LvBin
--@time:2022-04-26 18:28:56
--@return
function LianGongSystem:getPredictCostXinShen()
    local predictCostXinShen = (self:getSelectLvConversionExp() - self:getStartExp()) / self:getUnitXinShenAddExp()

    return math.ceil(predictCostXinShen)
end

return newClass("LianGongSystem", {}, LianGongSystem)
00000000000000
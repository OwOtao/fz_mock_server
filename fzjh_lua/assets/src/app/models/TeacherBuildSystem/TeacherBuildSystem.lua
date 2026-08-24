local newClass = require("third.class.NewClass")

local TeacherBuildResManager = require("app.models.TeacherBuildSystem.TeacherBuildResManager")

local TeacherBuildConst = require("app.models.TeacherBuildSystem.TeacherBuildConst")

local TeacherBuildSystem = {
    __guajiInfo = {
        -- taskId = nil
        -- startTime = 0
        -- speedUpTime = 0
    },
    __taskNumDay = 0, --本日已完成日常任务
    __taskNumLimit = 0,--本日可完成上限
    __reputation = 0,--个人威望值
    __sgbpoint = 0,--个人师门建设值
    __gbpoint = 0,--门派师门建设值
    __diligent = 0,--加速资源
    __diligentLimit = 0, --加速资源上限

    __renown = 0,--资历
    __renownLimit = 0, --资历上限
    __donate = 0, --佳绩

    __buildList = {
        -- {
        --     buildTypeId = "建筑类型id" ,
        --     buildTeacherExp = 100 ,--师门建筑累计建设值
        --     buildLv = 1, --师门建筑个人开放等级
        --     state = 0, --建筑状态 初始状态为0,兴建中为1
        -- },
    },
    __familyStates = {}, --师门状态标识

    __featList = {}, --名绩列表

    __featscount = 0 --师门名绩点数
}

function TeacherBuildSystem:create(player)
    local p = TeacherBuildSystem.new(TableProxy:createEncryptedTable({}))
    p:__initPlayer(player)
    return p
end

function TeacherBuildSystem:ctor()
    self.__isNotSerializable = true

    self.__player = nil
end

function TeacherBuildSystem:resetData()
    self:setGuaJiInfo({})

    self:setTaskNumDay(0)

    self:setTaskNumLimit(0)

    self:setReputation(0)

    self:setSgbpoint(0)

    self:setGbpoint(0)

    self:setSpeedUp(0)

    self:setSpeedUpLimit(0)

    self:setRenown(0)

    self:setRenownLimit(0)

    self:setDonate(0)

    self:setBuildList({})

    self:setFamilyStates({})

    self:setFeatList({})

    self:setFeatScount(0)
end

function TeacherBuildSystem:__initPlayer(player)
    self.__player = player
end

function TeacherBuildSystem:getPlayer()
    return self.__player
end

function TeacherBuildSystem:getFamilyId()
    return self.__player:getFamilyId()
end

function TeacherBuildSystem:__initData(data)
    self:setGuaJiInfo(data.guajiInfo)

    self:setTaskNumDay(data.taskNumDay)

    self:setTaskNumLimit(data.taskNumLimit)

    self:setReputation(data.reputation)

    self:setSgbpoint(data.sgbpoint)

    self:setGbpoint(data.gbpoint)

    self:setSpeedUp(data.diligent)

    self:setSpeedUpLimit(data.diligentLimit)

    self:setRenown(data.renown)

    self:setRenownLimit(data.renownLimit)

    self:setDonate(data.donate)
    
    self:setFamilyStates(data.familyStates)

    self:setFeatScount(data.featscount)
end

function TeacherBuildSystem:setGuaJiInfo(guajiInfo)
    self.__guajiInfo = guajiInfo
end

function TeacherBuildSystem:getGuaJiInfo()
    return self.__guajiInfo
end

function TeacherBuildSystem:setTaskNumDay(taskNumDay)
    self.__taskNumDay = taskNumDay
end

function TeacherBuildSystem:getTaskNumDay()
    return self.__taskNumDay
end

function TeacherBuildSystem:setTaskNumLimit(taskNumLimit)
    self.__taskNumLimit = taskNumLimit
end

function TeacherBuildSystem:getTaskNumLimit()
    return self.__taskNumLimit
end

function TeacherBuildSystem:setReputation(reputation)
    self.__reputation = reputation
end

function TeacherBuildSystem:getReputation()
    return self.__reputation
end

function TeacherBuildSystem:getReputationName()
    return User:getRole():getCHAttrName("reputation")
end

function TeacherBuildSystem:setSgbpoint(sgbpoint)
    self.__sgbpoint = sgbpoint
end

function TeacherBuildSystem:getSgbpoint()
    return self.__sgbpoint
end

function TeacherBuildSystem:getSgbpointName()
    return User:getRole():getCHAttrName("sgbpoint")
end

--@desc: 获取师门等级
--@author:LvBin
--@time:2023-09-14 18:18:55
--@return
function TeacherBuildSystem:getSectLv()
    return self:getSectLevelData().sectlevel
end

function TeacherBuildSystem:setGbpoint(gbpoint)
    self.__gbpoint = gbpoint
end

function TeacherBuildSystem:getGbpoint()
    return self.__gbpoint
end

function TeacherBuildSystem:getGbpointName()
    return  User:getRole():getCHAttrName("gbpoint")
end

function TeacherBuildSystem:setSpeedUp(diligent)
    self.__diligent = diligent
end

function TeacherBuildSystem:getSpeedUp()
    return self.__diligent
end

function TeacherBuildSystem:setSpeedUpLimit(diligentLimit)
    self.__diligentLimit = diligentLimit
end

function TeacherBuildSystem:getSpeedUpLimit()
    return self.__diligentLimit
end

function TeacherBuildSystem:getSpeedUpName()
    return User:getRole():getCHAttrName("diligent")
end

function TeacherBuildSystem:setRenown(renown)
    self.__renown = renown
end

function TeacherBuildSystem:getRenown()
    return self.__renown
end

function TeacherBuildSystem:setRenownLimit(renownLimit)
    self.__renownLimit = renownLimit
end

function TeacherBuildSystem:getRenownLimit()
    return self.__renownLimit
end

function TeacherBuildSystem:getRenownName()
    return User:getRole():getCHAttrName("renown")
end

function TeacherBuildSystem:setDonate(donate)
    self.__donate = donate
end

function TeacherBuildSystem:getDonate()
    return self.__donate
end

function TeacherBuildSystem:getDonateName()
    return User:getRole():getCHAttrName("donate")
end

function TeacherBuildSystem:setFamilyStates(states)
    self.__familyStates = states
end

function TeacherBuildSystem:getFamilyStates()
    local states = {}
    local FamilyState = require("app.models.TeacherBuildSystem.FamilyState.FamilyState")
    for i, _state in pairs(self.__familyStates) do
        local state = FamilyState:create(_state.id)
        table.insert(states, state)
    end

    return states
end 

function TeacherBuildSystem:getTask(taskId)
    return assert(TeacherBuildResManager:getTaskMap()[tostring(taskId)],"任务不存在 taskId = "..taskId)
end

function TeacherBuildSystem:isGuaJi()
    return not MapIsEmpty(self.__guajiInfo)
end

function TeacherBuildSystem:isCompleteGuaJi()
    local endTime = self.__guajiInfo.startTime + self:getTask(self.__guajiInfo.taskId).time * 3600 - self.__guajiInfo.speedUpTime
    if GetTime() > endTime then
        return true
    end
    return false
end

function TeacherBuildSystem:refreshGamingTime()
	if not self:isGuaJi() then
		return
	end
	
	if self:isCompleteGuaJi() then
		local endTime = self.__guajiInfo.startTime + self:getTask(self.__guajiInfo.taskId).time * 3600 - self.__guajiInfo.speedUpTime
		if endTime > self.__player:getFlag("游戏时间") then
			self.__player:setGamingTime(endTime)
		end
	else
		self.__player:setGamingTime()
	end
end

function TeacherBuildSystem:getCHAttrName(attr)
    local name = User:getRole():getCHAttrName(attr)
    
    if name == "" then
        return nil
    end

    return name
end

--@desc: 获取师门建设数据详情
--@author:LvBin
--@time:2023-08-21 11:08:28
--@callback: 
--@return
function TeacherBuildSystem:getTeacherBuildInFo(callback)
    HttpManagerEx:getTeacherBuildInFo(
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__initData(data)
                    
                    callback(true)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 开始师门建设日常任务
--@author:LvBin
--@time:2023-08-18 14:59:42
--@taskId:
	--@callback: 
--@return
function TeacherBuildSystem:startTeacherBuildTask(taskId, callback)
    HttpManagerEx:startTeacherBuildTask(
        taskId,
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__guajiInfo = {}
                    self.__guajiInfo.taskId = taskId
                    self.__guajiInfo.startTime = data.startTime
                    self.__guajiInfo.speedUpTime = 0
                    
                    callback(true)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 停止师门建设日常任务
--@author:LvBin
--@time:2023-08-18 15:51:35
--@callback: 
--@return
function TeacherBuildSystem:stopTeacherBuildTask(callback)
    HttpManagerEx:stopTeacherBuildTask(
        self.__guajiInfo.taskId,
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__guajiInfo = {}

                    callback(true)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 完成师门建设任务
--@author:LvBin
--@time:2023-08-18 15:51:58
--@bagEnough:
	--@callback: 
--@return
function TeacherBuildSystem:finishTeacherBuildTask(callback)
    HttpManagerEx:finishTeacherBuildTask(
        self.__guajiInfo.taskId,
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    -- self:getTeacherBuildTaskReward(data.reward)

                    self.__guajiInfo = {}

                    self.__taskNumDay = data.taskNumDay

                    self.__reputation = data.reputation

                    self.__sgbpoint = data.sgbpoint

                    self.__renown = data.renown

                    callback(true,"",data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 加速师门建设任务
--@author:LvBin
--@time:2023-08-18 15:53:12
--@cost:
	--@callback: 
--@return
function TeacherBuildSystem:speedUpTeacherBuildTask(cost, callback)
    HttpManagerEx:speedUpTeacherBuildTask(
        self.__guajiInfo.taskId,
        cost,
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__diligent = self.__diligent - data.cost

                    self.__guajiInfo.speedUpTime = self.__guajiInfo.speedUpTime + data.speedUpTime

                    callback(true)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 获取师门建设挂机任务列表
--@author:LvBin
--@time:2023-08-19 11:33:06
--@callback: 
--@return
function TeacherBuildSystem:getTeacherBuildTasks(callback)
    HttpManagerEx:getTeacherBuildTasks(
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:setTaskNumDay(data.taskNumDay)

                    self:setTaskNumLimit(data.taskNumLimit)
                    
                    callback(true,"", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 更新拳脚系统标记
--@author:LvBin
--@time:2023-08-21 14:20:48
--@addFlags: 添加的标记数组
--@deleteFlags: 删除的标记数组

--@callback:
--@return
function TeacherBuildSystem:updataTeacherBuildFlag(addFlags, deleteFlags,callback)
    HttpManagerEx:updataTeacherBuildFlag(
        addFlags,
        deleteFlags,
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 获取师门建设挂机任务奖励
--@author:LvBin
--@time:2023-08-24 11:17:59
--@rewardList: 
--@return
-- function TeacherBuildSystem:getTeacherBuildTaskReward(rewardList)
--     local canRewardIdList = {
--         reputation = true,
--         sgbpoint = true,
--     }

--     for i,v in ipairs(rewardList) do
--         local id = v[1]
--         local num = tonumber(v[2])

--         if canRewardIdList[id] == true and type(self["__"..id]) == "number" then
--             self["__"..id] = self["__"..id] + num
--         else
--             error("未定义的奖励id = ",id)
--         end
--     end
-- end

function TeacherBuildSystem:getSectLevelData()
    local level = 0
    local retData = {}
    local sectLevelMap = TeacherBuildResManager:getSectLevelMap()

    for k,v in pairs(sectLevelMap) do
        if self.__gbpoint >= v.prosperity and v.sectlevel > level then
            level = v.sectlevel
            retData = v
        end
    end

    return retData
end

function TeacherBuildSystem:isMaxSectLevel()
    local currLv = self:getSectLv()

    local sectLevelMap = TeacherBuildResManager:getSectLevelMap()

    for k,v in pairs(sectLevelMap) do
        if v.sectlevel > currLv then
            return false
        end
    end

    return true
end

--@desc: 获取升级所需门派昌盛度
--@author:LvBin
--@time:2023-09-14 18:23:13
--@return
function TeacherBuildSystem:getNextLevelNeedGbpoint()
    local currLv = self:getSectLv()
    
    local needSgbpoint = 0

    if self:isMaxSectLevel() then
        needSgbpoint = self:getSectLevelData().prosperity
    else
        local nextLv = currLv + 1

        local sectLevelMap = TeacherBuildResManager:getSectLevelMap()

        for k,v in pairs(sectLevelMap) do
            if v.sectlevel == nextLv then
                needSgbpoint = v.prosperity
                break
            end
        end
    end

    return needSgbpoint
end

--@desc: 获取师门建筑能装备非本门武学限制
--@author:LvBin
--@time:2023-09-26 16:31:18
--@return
function TeacherBuildSystem:getTeacherBuildCanPrepareSkillLimit()
    local buildList = self:getBuildList()

    for i,buildData in ipairs(buildList) do
        local build = self:getBuildByLv(buildData.buildTypeId,buildData.buildLv)

        local effectList = build:getEffectList()
                
        for i,effect in ipairs(effectList) do
            if effect:getEffectType() == TeacherBuildConst.BuildEffectType.Extra then
                return tonumber(effect:getEffect()[2]),tonumber(effect:getEffect()[3])
            end
        end
    end

    return 0
end

function TeacherBuildSystem:setBuildList(buildList)
    self.__buildList = buildList
end

function TeacherBuildSystem:getBuildList()
   return self.__buildList 
end

function TeacherBuildSystem:setSelectIndex(selectIndex)
    self.__selectIndex = selectIndex
end

function TeacherBuildSystem:getSelectIndex()
    return self.__selectIndex
end

function TeacherBuildSystem:setFeatList(featList)
    self.__featList = featList
end

function TeacherBuildSystem:getFeatList()
   return self.__featList 
end

function TeacherBuildSystem:setFeatScount(featscount)
    self.__featscount = featscount
end

function TeacherBuildSystem:getFeatScount()
    return self.__featscount
end

function TeacherBuildSystem:getCurrBuildName()
    local buildList = self:getBuildList()

    for i,buildData in ipairs(buildList) do
        if i == self.__selectIndex then
            local build = self:getBuildByLv(buildData.buildTypeId,buildData.buildLv)
            
            return build:getName()
        end
    end
end

--@desc: 设置建筑兴建状态
--@author:LvBin
--@time:2023-10-16 14:55:11
--@buildTypeId:
--@return
function TeacherBuildSystem:setBuildIngState(buildTypeId)
    for i,v in ipairs(self:getBuildList()) do
        if buildTypeId == v.buildTypeId then
            v.state = TeacherBuildConst.BuildStateType.BuildIng
        else
            v.state = TeacherBuildConst.BuildStateType.None
        end
    end
end

--@desc: 设置建筑师门累计经验
--@author:LvBin
--@time:2023-10-16 14:58:24
--@buildTypeId:
	--@buildTeacherExp: 
--@return
function TeacherBuildSystem:setBuildTeacherExp(buildTypeId,buildTeacherExp)
    for i,v in ipairs(self:getBuildList()) do
        if buildTypeId == v.buildTypeId then
            v.buildTeacherExp = buildTeacherExp
            break
        end
    end
end

--@desc: 设置建筑个人开放等级
--@author:LvBin
--@time:2023-10-16 14:55:51
--@buildTypeId:
	--@lv: 
--@return
function TeacherBuildSystem:setBuildOpenLv(buildTypeId,lv)
    for i,v in ipairs(self:getBuildList()) do
        if buildTypeId == v.buildTypeId then
            v.buildLv = lv
            break
        end
    end
end

--@desc: 获取师门建筑列表
--@author:LvBin
--@time:2023-08-19 11:33:06
--@callback: 
--@return
function TeacherBuildSystem:getTeacherBuildData(callback)
    HttpManagerEx:getTeacherBuildData(
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:setBuildList(data)

                    callback(true,"")
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 获取师门建筑材料信息
--@author:LvBin
--@time:2023-10-11 11:52:44
--@callback: 
--@return
function TeacherBuildSystem:getTeacherBuildItems(callback)
    HttpManagerEx:getTeacherBuildItems(
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then

                    callback(true,"", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 兴建师门建筑
--@author:LvBin
--@time:2023-10-13 11:06:22
--@buildTypeId: 建筑类型id
	--@callback: 
--@return
function TeacherBuildSystem:buildTeacherBuild(buildTypeId,callback)
    HttpManagerEx:buildTeacherBuild(
        buildTypeId,
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:setBuildIngState(buildTypeId)

                    callback(true,"")
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 获取师门建筑捐献信息
--@author:LvBin
--@time:2023-10-14 17:46:55
--@buildTypeId:
	--@callback: 
--@return
function TeacherBuildSystem:getTeacherBuildDonateInfo(buildTypeId,callback)
    HttpManagerEx:getTeacherBuildDonateInfo(
        buildTypeId,
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:setBuildTeacherExp(buildTypeId,data.buildTeacherExp)
                    
                    callback(true,"",data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 捐献建筑材料
--@author:LvBin
--@time:2023-10-14 17:46:55
--@buildTypeId: 捐献id
--@donateState: 捐献状态
	--@callback: 
--@return
function TeacherBuildSystem:donateTeacherBuild(buildTypeId,donateId,donateState,callback)
    HttpManagerEx:donateTeacherBuild(
        buildTypeId,
        donateId,
        donateState,
        self:getFamilyId(),
        self.__player:getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:setRenown(data.renown)
                    self:setDonate(data.donate)
                    self:setBuildTeacherExp(buildTypeId,data.buildTeacherExp)

                    if data.currencyVersion then
                        self.__player:setCurrencyVersion(data.currencyVersion)
                    end

                    callback(errcode,"",data)
                elseif errcode == 4 then
                    --捐献的时候已经满级了
                    self:setBuildTeacherExp(buildTypeId,data.buildTeacherExp)

                    callback(errcode,errmsg,data)
                else
                    callback(errcode, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 师门建筑开放等级升级
--@author:LvBin
--@time:2023-10-16 12:27:26
--@buildTypeId:
	--@callback: 
--@return
function TeacherBuildSystem:upgradeTeacherBuild(buildTypeId,callback)
    HttpManagerEx:upgradeTeacherBuild(
        buildTypeId,
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:setBuildOpenLv(buildTypeId,data.buildLv)

                    self:setRenown(data.renown)
                    callback(true,"",data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function TeacherBuildSystem:getBuildById(buildId)
    local TeacherBuild = require("app.models.TeacherBuildSystem.Build.TeacherBuild")
    return TeacherBuild:create(buildId)
end

function TeacherBuildSystem:getBuildByExp(buildTypeId,buildTeacherExp)
    local TeacherBuild = require("app.models.TeacherBuildSystem.Build.TeacherBuild")

    local buildMap = TeacherBuildResManager:getBuildMap()

    local buildId = nil

    local buildLv = 0

    for k,v in pairs(buildMap) do
        if v.buildingid == buildTypeId and buildTeacherExp >= v.maxupresources and v.buildlv >= buildLv then
            buildId = v.buildid

            buildLv = v.buildlv
        end
    end

    assert(buildId,"建筑经验对应等级不存在 buildTypeId :"..buildTypeId.." exp :"..buildTeacherExp)
    
    return TeacherBuild:create(buildId)
end

function TeacherBuildSystem:getBuildByLv(buildTypeId,lv)
    local TeacherBuild = require("app.models.TeacherBuildSystem.Build.TeacherBuild")

    local buildMap = TeacherBuildResManager:getBuildMap()

    for k,v in pairs(buildMap) do
        if v.buildingid == buildTypeId and v.buildlv == lv then
            return TeacherBuild:create(v.buildid)
        end
    end
end

function TeacherBuildSystem:getBuildItemName(id)
    return User:getRole():getCHAttrName(id)
end

--@desc: 指定建筑是否达到最高级
--@author:LvBin
--@time:2023-10-12 16:54:15
--@buildTypeId: 建筑类型id
	--@buildTeacherExp: 建筑经验
--@return
function TeacherBuildSystem:isMaxBuildLevel(buildTypeId,buildTeacherExp)
    local buildMap = TeacherBuildResManager:getBuildMap()

    local build = self:getBuildByExp(buildTypeId,buildTeacherExp)
    
    local buildLv = build:getLv()

    for k,v in pairs(buildMap) do
        if v.buildingid == buildTypeId and v.buildlv > buildLv then
            return false
        end
    end

    return true
end

--@desc: 获取建筑升级所需门槛经验
--@author:LvBin
--@time:2023-10-12 17:29:08
--@buildTypeId: 建筑类型id
	--@buildTeacherExp: 建筑经验
--@return
function TeacherBuildSystem:getBuildUpgradeNeedExp(buildTypeId,buildTeacherExp)
    local needExp = 0

    if self:isMaxBuildLevel(buildTypeId,buildTeacherExp) then
        needExp = buildTeacherExp
    else
        local build = self:getBuildByExp(buildTypeId,buildTeacherExp)

        local nextLv = build:getLv() + 1

        local nextBuild = self:getBuildByLv(buildTypeId,nextLv)

        needExp = nextBuild:getMaxExp()
    end

    return needExp
end

--@desc: 获取师门建筑效果列表
--@author:LvBin
--@time:2023-10-16 15:17:39
--@return [src.app.models.TeacherBuildSystem.BuildEffect.TeacherBuildEffect#TeacherBuildEffect]
function TeacherBuildSystem:getTeacherBuildEffects()
    local buildEffects = {}

    local buildList = self:getBuildList()

    for i,buildData in ipairs(buildList) do
        local build = self:getBuildByLv(buildData.buildTypeId,buildData.buildLv)

        table.appendArray(buildEffects, build:getEffectList())
    end

    return buildEffects
end

--@desc: 是否有判师建筑效果
--@author:LvBin
--@time:2023-10-16 16:19:33
--@return
-- function TeacherBuildSystem:isTransfer()
--     local effects = self:getTeacherBuildEffects()
    
--     for i,effect in ipairs(effects) do
--         if effect:getEffectType() == TeacherBuildConst.BuildEffectType.Transfer then
--             return true
--         end
--     end

--     return false    
-- end

--@desc: 获取判师建筑师门解锁功能效果id
--@author:LvBin
--@time:2023-10-16 16:19:33
--@return
function TeacherBuildSystem:getTransferFamilyEffectId()
    local buildList = self:getBuildList()

    for i,buildData in ipairs(buildList) do
        local build = self:getBuildByExp(buildData.buildTypeId,buildData.buildTeacherExp)

        local effectList = build:getEffectList()
                
        for i,effect in ipairs(effectList) do
            if effect:getEffectType() == TeacherBuildConst.BuildEffectType.Transfer then
                return effect:getEffect()[2]
            end
        end
    end
end

--@desc: 获取判师建筑个人解锁功能效果id
--@author:LvBin
--@time:2023-10-16 16:20:33
--@return
function TeacherBuildSystem:getTransferSelfEffectId()
    local buildList = self:getBuildList()

    for i,buildData in ipairs(buildList) do
        local openBuild = self:getBuildByLv(buildData.buildTypeId,buildData.buildLv)

        local effectList = openBuild:getEffectList()
                
        for i,effect in ipairs(effectList) do
            if effect:getEffectType() == TeacherBuildConst.BuildEffectType.Transfer then
                return effect:getEffect()[2]
            end
        end
    end
end

--@desc: 获取师门名绩类
--@author:LvBin
--@time:2024-03-11 15:41:21
--@featId: 
--@return [src.app.models.TeacherBuildSystem.Feat.TeacherFeat#TeacherFeat]
function TeacherBuildSystem:getFeat(featId)
    local TeacherFeat = require("app.models.TeacherBuildSystem.Feat.TeacherFeat")

    return TeacherFeat:create(featId)
end

--@desc: 获取师门名绩数据
--@author:LvBin
--@time:2024-03-11 16:29:08
--@callback: 
--@return
function TeacherBuildSystem:getTeacherFeatData(callback)
    HttpManagerEx:getTeacherFeatData(
        self:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:setFeatList(data.list)

                    self:setFeatScount(data.featscount)

                    callback(true,"")
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 领取师门名绩奖励
--@author:LvBin
--@time:2024-03-12 16:10:11
--@featId:
	--@callback: 
--@return
function TeacherBuildSystem:getTeacherFeatReward(featId,callback)
    HttpManagerEx:getTeacherFeatReward(
        self:getFamilyId(),
        featId,
        self:getPlayer():getServerActionSystem():getDataVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:setFeatScount(data.featscount)

                    local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

                    local GoodsHelper = require("app.models.Store.GoodsHelper")
                    
                    GoodsHelper:fromNetworkGrantGoods(self:getPlayer(),GrantGoodRequest:create({goodsList = data.reward,dataVersion = data.dataVer}))
                    
                    callback(true,data.msg)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 获取职阶列表
--@author:LvBin
--@time:2024-03-12 15:44:34
--@return
function TeacherBuildSystem:getFeatClassList()
    local featClassLevelList = assert(TeacherBuildResManager:getFeatClassLevelMap()[tostring(self:getFamilyId())],"师门职阶不存在 师门id = "..self:getFamilyId())

    table.sort(featClassLevelList, function(a,b)
        return tonumber(a.classlevel) < tonumber(b.classlevel)
    end)

    return featClassLevelList
end

--@desc: 获取职阶名字
--@author:LvBin
--@time:2024-03-12 15:44:52
--@return
function TeacherBuildSystem:getFeatClassName()
    local featClassLevelList = self:getFeatClassList()

    local featClassName = ""

    for i,v in ipairs(featClassLevelList) do
        if self:getFeatScount() >= v.featscount then
            featClassName = v.text
        end
    end
    
    return featClassName
end

--@desc: 获取师门职阶等级
--@author:LvBin
--@time:2025-02-25 10:53:28
--@return
function TeacherBuildSystem:getFeatClassLevel()
    local featClassLevelList = self:getFeatClassList()

    local classlevel = 0

    for i,v in ipairs(featClassLevelList) do
        if self:getFeatScount() >= v.featscount then
            classlevel = v.classlevel
        end
    end
    
    return classlevel
end

function TeacherBuildSystem:serializationForPVP()
    return {
        featscount = self:getFeatScount()
    }
end

function TeacherBuildSystem:initFromPVPData(data)
    self:setFeatScount(data.featscount)
end

return newClass("TeacherBuildSystem", {}, TeacherBuildSystem)
000000
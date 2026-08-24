local LogSystem = require("app.models.LogSystem.LogSystem")
local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")
local ChallengeMapConstant = require("app.models.ChallengeMap.ChallengeMapConstant")
local ChallengeMapExpendItem = require("app.models.ChallengeMap.ChallengeMapExpendItem")
local class = require("third.class.NewClass")
local ChallengeMapSystem = {
    __completedMapIds = {}
}

local __instance = nil


--@desc: 获取挑战副本系统实例
--author:TangJian
--time:2021-12-13 18:16:12
--@return src.app.models.ChallengeMap.ChallengeMapSystem#ChallengeMapSystem
function ChallengeMapSystem:getInstance()
    if __instance == nil then
        __instance = ChallengeMapSystem.new()
        __instance:init()
    end
    return __instance
end

function ChallengeMapSystem:ctor()
    self.__conditionMap = nil
    self.__resultMap = nil
    self.__role = nil
    self.__buffSystem = nil
end

function ChallengeMapSystem:init()
    self:__initConditionMap()
    self:__initResultMap()
end

--@desc: 初始化挑战副本通关id数据
--@author:LvBin
--@time:2025-03-12 17:36:54
--@mapIdArray: 通关id数据
--@return
function ChallengeMapSystem:initCompletedMapIds(mapIdArray)
    self.__completedMapIds = table.arrayToMap(mapIdArray)
end

function ChallengeMapSystem:setCompletedMapId(mapId)
    local isOk, err =
        pcall(
        function()
            ChallengeMapResource:getInstance():getMapInfoById(mapId)
        end
    )

    if isOk == false then
        print("ChallengeMapSystem:setCompletedMapId err : ", err)
        print(debug.traceback())
        return
    end

    self.__completedMapIds[mapId] = true
end

--@desc: 挑战副本是否通关
--@author:LvBin
--@time:2025-03-12 17:36:45
--@mapId: 副本id
--@return true or false
function ChallengeMapSystem:isCompleted(mapId)
    return self.__completedMapIds[mapId] == true
end

function ChallengeMapSystem:setRole(role)
    self.__role = role
end

function ChallengeMapSystem:getRole()
    return self.__role
end

function ChallengeMapSystem:setBuffSystem(sys)
    self.__buffSystem = sys
end

function ChallengeMapSystem:getBuffSystem()
    return self.__buffSystem
end

--[[
    @desc: 创建挑战副本
    author:TangJian
    time:2021-12-13 17:34:38
    --@mapId: 挑战副本Id
    @return: src.app.models.ChallengeMap.ChallengeMap#ChallengeMap#ChallengeMap
]]
function ChallengeMapSystem:createMap(mapId)
    local ChallengeMapBuilder = require("app.models.ChallengeMap.ChallengeMapBuilder")

    local builder = ChallengeMapBuilder:create(mapId)
    builder:buildMap()
    return builder:getMap()
end

function ChallengeMapSystem:createPlayer()
    local role = Role:create(self.__role)

    --背包初始化容量100
    role:setAttr("weight", 100)

    --@desc 初始化主动技能释放次数
    role:setAttr("activeReleaseTimesMap", {})

    role.isChallengeRole = true

    local skillPrepare = role:getSkillPrepare()

    --取消互备拳脚
    if skillPrepare and skillPrepare["quanjiao2"] then
        skillPrepare["quanjiao2"] = nil
    end

    -- 挑战副本角色暂时去除准备的自创武学
    if MapIsEmpty(skillPrepare) == false then
        for k, skillId in pairs(skillPrepare) do
            local skill = Skill:getSkill(skillId)
            if skill.type == SKILL_TYPE_SELFCREATE then
                skillPrepare[k] = nil
            end
        end
    end

    --背包保留装备
    local newBagItems = {}
    local items = role:getItems()
    for i, v in ipairs(items) do
        local itemAttr = role:getOneItemByKey(v.itemId)
        if itemAttr.canEquip == ITEM_STATE_TRUE then
            table.insert(newBagItems, v)

            if role:checkItemIsEquip(v.id) and itemAttr.wpType == "神兵" then
                --刷新神兵buff
                local buffs = ShenBingEffct:getShenBingNormalBuff(itemAttr)

                if MapIsEmpty(buffs) == false then
                    for __, buffId in ipairs(buffs) do
                        self.__buffSystem:addBuff(buffId, role)
                    end
                end
            end
        end
    end

    self.__sysncSystem:recordOriBags(newBagItems)

    role:setAttr("items", newBagItems)

    return role
end

--[[
    @desc: 获取副本异步条件
    author:TangJian
    time:2021-12-15 15:46:07
    --@conditionId: 
    @return:
]]
function ChallengeMapSystem:getConditionById(conditionId)
    local conditionFunc = self.__conditionMap[string.lower(conditionId)]
    assert(type(conditionFunc) == "function", "conditionId: " .. tostring(conditionId) .. " not found")
    return conditionFunc
end

--[[
    @desc: 获取副本异步结果
    author:TangJian
    time:2021-12-15 15:45:58
    --@resultId: 
    @return:
]]
function ChallengeMapSystem:getResultById(resultId)
    local resultFunc = self.__resultMap[string.lower(resultId)]
    assert(type(resultFunc) == "function", "resultId: " .. tostring(resultId) .. " not found")
    return resultFunc
end

function ChallengeMapSystem:getMapInfoMap()
    local mapInfo = ChallengeMapResource:getInstance():getMapInfoMap()
    local retMaps = {}
    for mapId, mapData in pairs(mapInfo) do
        local grade = tostring(mapData.section[1])
        local level = mapData.section[2]
        if retMaps[grade] == nil then
            retMaps[grade] = {}
        end
        retMaps[grade][level] = mapData
    end

    return retMaps
end

function ChallengeMapSystem:__initConditionMap()
    self.__conditionMap = {}

    -- 合并条件
    for k, v in pairs(require("app.models.ChallengeMap.condition.ChallengeMapConditions")) do
        self.__conditionMap[string.lower(k)] = v
    end
end

function ChallengeMapSystem:__initResultMap()
    self.__resultMap = {}

    -- 合并结果
    for k, v in pairs(require("app.models.ChallengeMap.result.ChallengeMapResults")) do
        self.__resultMap[string.lower(k)] = v
    end
end

--@desc: 判断挑战副本是否重连
--@author:LvBin
--@time:2022-02-15 16:17:46
--@mapId:
--@callback:
--@return
function ChallengeMapSystem:isChallengeMapReconnection(callback)
    HttpManagerEx:isChallengeMapReconnection(
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                callback(true, data)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 挑战副本能否进行快速通关
--@author:LvBin
--@time:2022-06-16 10:13:13
--@mapId:
--@callback:
--@return
function ChallengeMapSystem:challengeMapIsCustoms(mapId, callback)
    HttpManagerEx:challengeMapIsCustoms(
        mapId,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                callback(true, data)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc:
--@author:Seven
--@time:2022-07-26 16:32:47
function ChallengeMapSystem:__enterMap(mapId)
    --@RefType [src.app.models.ChallengeMap.SyncDataSystem.ChallengeMapSyncSystem#ChallengeMapSyncSystem]
    self.__sysncSystem = require("app.models.ChallengeMap.SyncDataSystem.ChallengeMapSyncSystem"):create(mapId)

    local buffSys = require("app.models.ChallengeMap.BuffSystem.BuffSystem"):create()

    ChallengeMapSystem:getInstance():setBuffSystem(buffSys)

    local map = self:createMap(mapId)

    local player = self:createPlayer()

    map:setPlayer(player)

    self:__doEnterExtraActionFunc()

    return map
end

--@desc: 进入未完成的挑战副本
--@author:LvBin
--@time:2022-02-15 20:03:43
--@callback:
--@return
function ChallengeMapSystem:reEnterChallengemap(callback)
    HttpManagerEx:reEnterChallengemap(
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local map = self:__enterMap(data.challengemap.map_id)
                callback(true, map)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function ChallengeMapSystem:checkExpendItem(expendItem)
    return ChallengeMapExpendItem:create(self.__role, expendItem):check()
end

function ChallengeMapSystem:enterChallengeMap(mapId, callback)
    HttpManagerEx:enterChallengeMap(
        mapId,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local mapInfo = ChallengeMapResource:getInstance():getMapInfoById(mapId)

                local itemEnough, consume_map, itemCheckMsg = self:checkExpendItem(mapInfo.ExpendItem)

                if not itemEnough then
                    callback(false, itemCheckMsg)
                    return
                end

                local level = data.level
                if self.__role:getLv() < level then
                    callback(false, "进入该副本需的等级不足" .. level .. "，无法开始")
                    return
                end

                local sign = data.sign
                if sign and sign[1] then
                    if self.__role:getFlag(sign[1]) ~= sign[2] then
                        callback(false, "当前进入条件不符合，请准备充足后再次进行调查")
                        return
                    end
                end

                HttpManagerEx:challengeMapConfirmConsume(
                    mapId,
                    consume_map,
                    function(status, errcode, errmsg, data)
                        if status == 200 and errcode == 0 then
                            --@desc 扣除进入副本所需物品
                            for i, v in ipairs(consume_map) do
                                self.__role:addItemCount(v.id, -v.num)
                            end
                            callback(true, self:__enterMap(mapId), consume_map)
                        else
                            callback(false, errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 副本完成
--@time:2022-07-26 14:20:46
--@mapId: 副本ID
--@finishType: 完成类型 1 正常副本通关完成 2、快速通关（匆匆了事）
function ChallengeMapSystem:challengeMapFinish(mapId, finishType, callback)
    HttpManagerEx:challengeMapFinish(
        mapId,
        finishType,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__completedMapIds[mapId] = true

                local grantAwardType, uploadList = self:analysisReward(data.award_id)

                HttpManagerEx:challengeMapGetAward(
                    mapId,
                    grantAwardType,
                    uploadList,
                    finishType,
                    self.__role:getCurrencyVersion(),
                    function(status, errcode, errmsg, data)
                        if status == 200 and errcode == 0 then
                            --data.msg 货币达到上限提示
                            self:getAward(grantAwardType, data.award_list)

                            if data.currencyVersion then
                                self.__role:setCurrencyVersion(data.currencyVersion)
                            end

                            callback(true, data.award_list, data.msg)

                            self:__doFinishExtraActionFunc(mapId)
                        else
                            callback(false, errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 通关挑战副本
--@author:Seven
--@time:2022-07-28 15:44:54
function ChallengeMapSystem:clearTheMap(map, callback)
    self:challengeMapFinish(
        map.id,
        ChallengeMapConstant.FinishType.Normal,
        function(ok, arg1, arg2)
            if ok then
                self:roleDataSynchronism(map, true)
            end
            callback(ok, arg1, arg2)
        end
    )
end

--@desc 非通关离开副本（点击离开按钮或者决斗失败导致强制退出）
function ChallengeMapSystem:leaveTheMap(map, type, callback)
    self:challengeMapLeave(
        type,
        function(result, msg)
            if result then
                self:roleDataSynchronism(map, false)
            end
            callback(result, msg)
        end
    )
end

--@desc: 挑战副本离开(用于未通关退出挑战副本，通知服务器结束这次挑战副本记录)
--@author:LvBin
--@time:2022-02-15 16:36:55
--@type: 1主动退出/2失败退出/3重连退出
--@callback:
function ChallengeMapSystem:challengeMapLeave(type, callback)
    HttpManagerEx:challengeMapLeave(
        type,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                callback(true)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function ChallengeMapSystem:analysisReward(rewardId)
    local grantAwardType = 1 --1.直接发放；2.背包不足邮件发放

    --@desc 奖励物品，用于检测背包容量
    local itemTab = {}

    --@desc 上传服务器记录
    local uploadList = {}

    if rewardId and rewardId ~= "" then
        local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(rewardId, self.__role:getAttr("exp"), self.__role:getFinalAttr("luck"), self.__role:getKongfu())

        if not MapIsEmpty(rewardArray) then
            for i, reward in ipairs(rewardArray) do
                local id = reward.id
                local value = tonumber(reward.value)
                if reward.type == "物品" then
                    itemTab[id] = value
                    table.insert(uploadList, {type = ChallengeMapConstant.RewardType.Loc_Item, id = id, num = value})
                elseif reward.type == "属性" then
                    table.insert(uploadList, {type = ChallengeMapConstant.RewardType.Loc_Attr, id = id, num = value})
                elseif reward.type == "称号" then
                    table.insert(uploadList, {type = ChallengeMapConstant.RewardType.BasicTitle, id = id, num = value})
                else
                    if DEBUG_MODE == 1 then
                        assert(false, "奖励策略奖励类型填写错误")
                    end
                end
            end
        end

        if self.__role:checkCanBuyTwoOrMoreThings(itemTab) == false then
            grantAwardType = 2
        end
    end

    return grantAwardType, uploadList
end

function ChallengeMapSystem:getAward(grantAwardType, rewardArray)
    for i, reward in ipairs(rewardArray) do
        local id = reward.id
        local num = reward.num
        local rewardType = reward.type

        if rewardType == ChallengeMapConstant.RewardType.Loc_Item then
            if grantAwardType == 1 then
                self.__role:addItemCount(id, num)
            end
        elseif rewardType == ChallengeMapConstant.RewardType.Loc_Attr then
            self.__role:addAttr(id, num)
        elseif rewardType == ChallengeMapConstant.RewardType.net_Res then
            print("服务器资源奖励 id = ", id)
        elseif rewardType == ChallengeMapConstant.RewardType.BasicTitle then
            self.__role:addBasicTitle(tostring(id))
        else
            assert(false, "未知奖励类型" .. rewardType)
        end
    end
end

function ChallengeMapSystem:addBuff(buffId, role)
    self.__buffSystem:addBuff(buffId, role)
    self.__buffSystem:updateRoleBuffValue(role)
end

function ChallengeMapSystem:removeBuff(buffId, role)
    self.__buffSystem:removeBuff(buffId)
    self.__buffSystem:updateRoleBuffValue(role)
end

function ChallengeMapSystem:updateBuffs(role)
    self.__buffSystem:update()
    self.__buffSystem:updateRoleBuffValue(role)
end

function ChallengeMapSystem:updateFightBuffs(role)
    self.__buffSystem:updateFightDeleteBuffs()
    self.__buffSystem:updateRoleBuffValue(role)
end

function ChallengeMapSystem:recordFistFootBuff(buffId)
    self.__buffSystem:recordFistFootBuff(buffId)
end

function ChallengeMapSystem:removeFistFootBuffs(role)
    self.__buffSystem:removeFistFootBuffs()
    self.__buffSystem:updateRoleBuffValue(role)
end

--@desc: 角色数据同步
--@author:LvBin
--@time:2022-02-11 17:50:46
--@map: src.app.models.ChallengeMap.ChallengeMap#ChallengeMap
--@return
function ChallengeMapSystem:roleDataSynchronism(map, isCompleted)
    self.__sysncSystem:syncPlayerData(map:getPlayer(), self.__role, isCompleted)
    --@desc 同步完删除
    self.__sysncSystem = nil
end

--成功进入挑战副本需要进行的额外活动处理
function ChallengeMapSystem:__doEnterExtraActionFunc()
    local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")

    if LimitedTimeExperience:checkTaskIsOpen("yiwen") then
        LimitedTimeExperience:setRole(self.__role)
        LimitedTimeExperience:finishTaskByTaskType("yiwen")
    end
end

--@desc: 挑战副本结算需要进行的额外活动处理
--@author:LvBin
--@time:2023-02-09 18:00:55
--@mapId: 副本id
--@return
function ChallengeMapSystem:__doFinishExtraActionFunc(mapId)
    local mapInfo = ChallengeMapResource:getInstance():getMapInfoById(mapId)
    if mapInfo.type == ChallengeMapConstant.MapType.Normal then
        local DailyTasksActivity = require("app.models.Action.DailyTasksActivity")
        DailyTasksActivity:addDailyTaskPoint("yiwen")
    elseif mapInfo.type == ChallengeMapConstant.MapType.Festival then
    elseif mapInfo.type == ChallengeMapConstant.MapType.Conceal then
    else
        error("挑战副本类型异常" .. mapInfo.type)
    end
end

return class("ChallengeMapSystem", {}, ChallengeMapSystem)
0
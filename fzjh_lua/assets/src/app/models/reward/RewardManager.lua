-- local function GetTime()
--     return os.time()
-- end
local md5 = require("app.extends.md5")

local SchemeStateMapKey = "SchemeStateMapKey"
local MapSchemeStateMapKey = "MapSchemeStateMapKey"
SchemeStateMapKey = md5:getMd5("SchemeStateMapKey")
MapSchemeStateMapKey = md5:getMd5("MapSchemeStateMapKey")

local VERSION = 1.0

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 16:54:38
-- @desc 奖励管理类, 提供通过简历策略获得奖励id等方法.
local RewardManager = {
    role = nil,
    -- 记录获得奖励状态的map
    schemeStateMap = {
        version = VERSION
        -- schemeId =
        -- {
        --     totalTimes = 0,
        --     dayTimes = 0
        -- }
    },
    -- 记录每个副本奖励状态的map
    mapSchemeStateMap = {
        version = VERSION
        -- fb01 =
        -- {
        --     schemeId =
        -- {
        --     totalTimes = 0,
        --     dayTimes = 0
        -- }
        -- }
    },
    rewardSchemeRestrictions = nil, -- 限制
    rewardScheme = nil, -- 奖励规则|方案
    rewardMap = nil -- 奖励地图
}

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 11:45:31
-- @desc 测试接口
function RewardManager.test()
    Helper = require("app.Helper")
    Formula = require("app.models.formula.Formula")
    JMForLua = require("app.extends.JMForLua")

    luaTableEncode, luaTableDecode = require("app.extends.tableToString")()
    DataBase = require("app.DataBase")

    require("app.Definition")

    local reward = RewardManager:create()

    for i = 1, 10 do
        reward:_getMapRewardArrayWithRewardScheme("fb01", "fubenxiangzi", 1, 1, 1)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 11:43:40
-- @desc 创建奖励对象
function RewardManager:create()
    local p = clone(RewardManager)
    p:init()
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 11:43:31
-- @desc 初始化奖励策略
function RewardManager:init()
    -- 奖励地图初始化
    self.rewardMap = clone(requireWithEncrypt("script.map.mapItemAttr")["Rewards"])
    -- print(json.encode(self.rewardMap))
    -- 奖励规则初始化
    self.rewardSchemes = {}

    -- 奖励规则限制初始化
    self.rewardSchemeRestrictions = {}

    local rewardSchemes = clone(require("script.rewardScheme")["rewardScheme"])
    for k, rewardScheme in pairs(rewardSchemes) do
        do
            -- 补全格式
            rewardScheme.rule = string.gsub(rewardScheme.rule, " ", "")
            rewardScheme.rule = string.gsub(rewardScheme.rule, "{", [[{"]])
            rewardScheme.rule = string.gsub(rewardScheme.rule, "}", [["}]])
            rewardScheme.rule = string.gsub(rewardScheme.rule, ",", [[","]])
            rewardScheme.rule = string.gsub(rewardScheme.rule, [["{]], [[{]])
            rewardScheme.rule = string.gsub(rewardScheme.rule, [[}"]], [[}]])
        end

        if rewardScheme.type == "限制" then
            rewardScheme.rule = loadstring("return " .. rewardScheme.rule)()
            if type(rewardScheme.rule) ~= "table" then
                rewardScheme.rule = {rewardScheme.rule}
            end
            self.rewardSchemeRestrictions[k] = rewardScheme
        elseif rewardScheme.type == "奖励" then
            self.rewardSchemes[k] = rewardScheme
        elseif rewardScheme.type == "策略" then
            self.rewardSchemes[k] = rewardScheme
        else
            if PRINT_MODE == 1 then
                print("rewardScheme.type = ", rewardScheme.type)
            end
        end
    end

    -- 错误检测
    self:_errorDetect()

    self:setRole({})

    -- print("初始化结束 add by TangJian 2016/11/29 19:47:07")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/20 14:53:14
-- @desc 设置角色
function RewardManager:setRole(role)
    self.role = role

    -- 载入本地策略状态
    self.schemeStateMap = Helper:getDef(self:_getLocalRewardSchemeStateMap(), {})
    self.mapSchemeStateMap = Helper:getDef(self:_getLocalMapRewardSchemeStateMap(), {})
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/20 15:04:57
-- @desc 得到角色
function RewardManager:getRole()
    if type(self.role) == "table" then
        return self.role
    end
    -- print("没有设置角色!!!!")
    return {}
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/20 14:58:04
-- @desc 得到存储table
function RewardManager:_getStorage()
    if type(self:getRole().storage) ~= "table" then
        self:getRole().storage = {}
    end
    if type(self:getRole().storage.RewardManager) ~= "table" then
        self:getRole().storage.RewardManager = {}
    end
    return self:getRole().storage.RewardManager
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/10 15:48:23
-- @desc 得到本地策略
function RewardManager:_getLocalRewardSchemeStateMap()
    local data = self:_getStorage().schemeStateMap
    return Helper:tableCover(clone(self.schemeStateMap), data)
    -- 通过存档覆盖当前结构
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/10 15:48:33
-- @desc 设置本地策略
function RewardManager:_setLocalRewardSchemeStateMap(schemeStateMap)
    self:_getStorage().schemeStateMap = schemeStateMap
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/15 16:39:55
-- @desc得到副本策略状态map
function RewardManager:_getLocalMapRewardSchemeStateMap()
    local data = self:_getStorage().mapSchemeStateMap
    return Helper:tableCover(clone(self.mapSchemeStateMap), data)
    -- 通过存档覆盖当前结构
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/15 16:40:38
-- @desc 设置副本策略状态map
function RewardManager:_setLocalMapRewardSchemeStateMap(mapSchemeStateMap)
    self:_getStorage().mapSchemeStateMap = mapSchemeStateMap
end

local cacheMap = {}

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 15:57:38
-- @desc 错误检测
function RewardManager:_errorDetect()
    -- for k, v in pairs(self.rewardSchemeRestrictions) do
    --     if string.find(v.rule, "{") and string.find(v.rule, "}") then -- 必须要有括号, 不然结构不完整...
    --         else
    --         error("v.rule 结构不完整", "v.rule = ", v.rule)
    --     end
    -- end

    for k, v in pairs(self.rewardSchemes) do
        if PRINT_MODE == 1 then
            print("开始测试奖励策略", k)
        end

        if string.find(v.rule, "{") and string.find(v.rule, "}") then -- 必须要有括号, 不然结构不完整...
        else
            error("v.rule 结构不完整", "v.rule = ", v.rule)
        end

        cacheMap = {}
        cacheMap[k] = {}

        local rewardIdArray = self:_getRewardIdArrayWithRewardScheme(k)
        if self:_getRewardIdArrayWithRewardScheme(k) then
            if PRINT_MODE == 1 then
                print("策略", k, "获取奖励正常:")
                for k, v in pairs(rewardIdArray) do
                    print(k, v)
                end
            end
        end

        if PRINT_MODE == 1 then
            print("结束测试奖励策略", k)
        end
    end

    cacheMap = nil
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/10 16:06:20
-- @desc 得到策略状态
function RewardManager:_getSchemeState(schemeId)
    local retState = self.schemeStateMap[schemeId]
    if type(retState) == "table" then
    else
        retState = {
            updateTime = GetTime(),
            times = 0,
            dayTimes = 0
        }
        self:_setSchemeState(schemeId, retState)
    end

    -- add by XiaoZhiWei 2018/05/02 18:56:14 限制次数重新计算规则扩展
    --[[
        原始限制为记录每天次数
        扩展情况:
            兼容 每天     次数记录
            兼容 每周     次数记录
            兼容 每月     次数记录
            兼容 指定天数 次数记录
    ]]
    do
        local reward = self.rewardSchemeRestrictions[schemeId]
        if reward == nil then
            reward = self.rewardSchemes[schemeId]
        end

        if reward == nil then
            if PRINT_MODE == 1 then
                error("奖励策略错误, 找不到对应的ID:" .. tostring(schemeId))
            end
            reward = {}
        end

        local ret =
            switch(
            reward.limitDays,
            {
                ["一周"] = function()
                    return Helper:isThisWeek(GetTime(), retState.updateTime) == false
                end,
                ["一个月"] = function()
                    return Helper:isThisMonth(GetTime(), retState.updateTime) == false
                end,
                ["default"] = function()
                    return Helper:diffWithDate(GetTime(), retState.updateTime) >= Helper:getDef(reward.limitDays, 1)
                end
            }
        )
        if ret == true then
            retState.dayTimes = 0
            self:_setSchemeState(schemeId, retState)
        end
    end

    return retState
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/10 16:15:55
-- @desc 设置策略状态
function RewardManager:_setSchemeState(schemeId, schemeState)
    self.schemeStateMap[schemeId] = schemeState
    -- 刷新更新时间
    self.schemeStateMap[schemeId].updateTime = GetTime()

    -- 保存状态到本地
    self:_setLocalRewardSchemeStateMap(self.schemeStateMap)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/15 16:44:04
-- @desc 得到副本策略状态
function RewardManager:_getMapSchemeState(mapId, schemeId)
    if self.mapSchemeStateMap[mapId] == nil then
        self.mapSchemeStateMap[mapId] = {}
    end
    local retState = self.mapSchemeStateMap[mapId][schemeId]
    if type(retState) == "table" then
    else
        retState = {
            updateTime = GetTime(),
            times = 0,
            dayTimes = 0
        }
        self:_setMapSchemeState(mapId, schemeId, retState)
    end

    if Helper:diffWithDate(GetTime(), retState.updateTime) ~= 0 then
        retState.dayTimes = 0
        self:_setMapSchemeState(mapId, schemeId, retState)
    end

    return retState
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/15 16:48:53
-- @desc 设置副本策略状态map
function RewardManager:_setMapSchemeState(mapId, schemeId, schemeState)
    if self.mapSchemeStateMap[mapId] == nil then
        self.mapSchemeStateMap[mapId] = {}
    end

    self.mapSchemeStateMap[mapId][schemeId] = schemeState

    -- 刷新更新时间
    self.mapSchemeStateMap[mapId][schemeId].updateTime = GetTime()

    -- 保存状态到本地
    self:_setLocalMapRewardSchemeStateMap(self.mapSchemeStateMap)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/10 16:50:43
-- @desc 判断限制是否有效
function RewardManager:_rewardSchemeRestrictionIsValid(mapId, rsrId)
    local rewardSchemeRestriction = self.rewardSchemeRestrictions[rsrId]
    if rewardSchemeRestriction then
        -- 针对副本限制
        if type(rewardSchemeRestriction.mapLimit) == "number" then
            -- 每天次数限制
            if type(rewardSchemeRestriction.timesLimit) == "number" then
                local dayTimes = 0

                for i, schemeId_ in ipairs(rewardSchemeRestriction.rule) do
                    local state
                    if type(mapId) == "string" then
                        state = self:_getMapSchemeState(mapId, schemeId_)
                    else
                        state = self:_getSchemeState(schemeId_)
                    end
                    dayTimes = dayTimes + state.dayTimes
                end

                if dayTimes >= rewardSchemeRestriction.timesLimit then
                    return true
                end
            else
                if PRINT_MODE == 1 then
                    print("rewardSchemeRestriction.timesLimit = ", rewardSchemeRestriction.timesLimit)
                end
            end
        else
            -- 每天次数限制
            if type(rewardSchemeRestriction.timesLimit) == "number" then
                local dayTimes = 0

                for i, schemeId_ in ipairs(rewardSchemeRestriction.rule) do
                    local state = self:_getSchemeState(schemeId_)
                    dayTimes = dayTimes + state.dayTimes
                end

                if dayTimes >= rewardSchemeRestriction.timesLimit then
                    return true
                end
            else
                if PRINT_MODE == 1 then
                    print("rewardSchemeRestriction.timesLimit = ", rewardSchemeRestriction.timesLimit)
                end
            end
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/10 15:53:26
-- @desc 判断策略是否能够执行
function RewardManager:_rewardSchemeCanDo(mapId, schemeId)
    local success, ret =
        xpcall(
        function()
            for rewardSchemeRestrictionId, rewardSchemeRestriction in pairs(self.rewardSchemeRestrictions) do
                for i, schemeId_ in ipairs(rewardSchemeRestriction.rule) do
                    if schemeId_ == schemeId then
                        if self:_rewardSchemeRestrictionIsValid(mapId, rewardSchemeRestrictionId) then
                            return false
                        end
                        break
                    end
                end
            end
            return true
        end,
        function(errmsg)
            print("errmsg = ", errmsg)
            print(debug.traceback())
        end
    )
    if success == true then
        return ret
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 11:53:26
-- @desc 分析奖励策略规则
function RewardManager:_getRewardIdArrayAndWeightArrayWithRewardSchemeRlue(rewardSchemeRlue)
    -- 分隔奖励和权重
    local array = string.split(rewardSchemeRlue, ";")
    local arraySize = #array

    local rewardArray = nil -- 奖励数组
    local weightArray = nil -- 奖励权重数组

    -- 规则数组长度
    if arraySize == 1 then -- 长度为1, 则认为没有权重信息
        rewardArray = loadstring("return " .. array[1])()
    elseif arraySize == 2 then -- 长度为2, 则认为有权重信息
        rewardArray = loadstring("return " .. array[1])()
        weightArray = loadstring("return " .. array[2])()
    else -- 其他情况均为错误
        error()
    end

    -- 奖励数组不能为空
    assert(rewardArray ~= nil, "奖励数组不能为空")

    -- 奖励数组如果不是
    if type(rewardArray) ~= "table" then
        local value = rewardArray
        rewardArray = {}
        table.insert(rewardArray, value)
    end

    -- 如果权重信息不为table, 则自动生成权重信息
    if type(weightArray) ~= "table" then
        weightArray = {}
        for i, v in ipairs(rewardArray) do
            table.insert(weightArray, 1)
        end
    end

    return rewardArray, weightArray
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 12:45:12
-- @desc 通过奖励和权重, 得到随机奖励
function RewardManager:_getRandomRewardWithRewardIdArrayAndWeightArray(rewardArray, weightArray, rsid)
    -- print("weightArray:")
    -- for k,v in pairs(weightArray) do
    --     print(k,v)
    -- end
    rsid = rsid or ""

    if MapIsEmpty(rewardArray) or MapIsEmpty(weightArray) then
        print("该策略权重或者奖励有问题，策略id:", rsid)
    end
    local rewardArray_length = #rewardArray
    local weightArray_length = #weightArray

    if weightArray_length > rewardArray_length then
        print("有问题 rewardArray_length:", rewardArray_length, "weightArray_length:", weightArray_length, "rsid:", rsid)
    end

    local index = Helper:RandomIndexByPercent(unpack(weightArray))
    -- 通过权重获得奖励

    if PRINT_MODE == 1 then
        print("index = ", index)
    end

    if not rewardArray[index] then
        print("权重奖励下标：", index, "策略id:", rsid)
    end
    return assert(rewardArray[index])
end

local RewardRecordItem = require("app.models.Record.Reward.RewardRecordItem")
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 11:43:55
-- @desc 通过奖励规则获得奖励
function RewardManager:_getRewardIdArrayWithRewardScheme(rsid, rrecord)
    rsid = tostring(rsid)

    local needRecord = false
    if not rrecord then
        rrecord = RewardRecordItem:create(rsid)
        needRecord = true
    else
        rrecord:chainAppend(rsid)
    end

    local rewards = {}
    -- 奖励列表
    local rewardScheme = self.rewardSchemes[rsid]

    if rewardScheme then
        local rewardIdArray, weightArray = self:_getRewardIdArrayAndWeightArrayWithRewardSchemeRlue(rewardScheme.rule)
        local reward = self:_getRandomRewardWithRewardIdArrayAndWeightArray(rewardIdArray, weightArray, rsid)

        if rewardScheme.type == "策略" then
            -- print("策略 reward = ", reward)
            if type(reward) == "table" then
                for i, v in ipairs(reward) do
                    local rewards_ = self:_getRewardIdArrayWithRewardScheme(v, rrecord)
                    for i_, v_ in ipairs(rewards_) do
                        table.insert(rewards, v_)
                    end
                end
            elseif type(reward) == "string" then
                if reward ~= "-1" then
                    local rewards_ = self:_getRewardIdArrayWithRewardScheme(reward, rrecord)
                    for i_, v_ in ipairs(rewards_) do
                        table.insert(rewards, v_)
                    end
                end
            else
                error()
            end
        elseif rewardScheme.type == "奖励" then
            if type(reward) == "table" then
                for i_, v_ in ipairs(reward) do
                    table.insert(rewards, v_)
                end
            elseif type(reward) == "string" then
                if reward ~= "-1" then
                    table.insert(rewards, reward)
                end
            else
                error()
            end
        else
            error()
        end
    else
        if PRINT_MODE == 1 then
            print("id = ", rsid)
        end
        Helper:print_lua_table(cacheMap)
        error("限制不能作为策略执行!!! : " .. tostring(rsid))
    end

    if needRecord then
        rrecord:setRewardsRecord(rewards)
    end

    return rewards, rrecord
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/15 18:00:45
-- @desc 获得副本奖励列表, 通过奖励策略组
function RewardManager:getMapRewardArrayWithRewardSchemeArray(mapId, rewardSchemeIdArray, exp, luck, kongfu)
    local retRewardArray = {}
    local rewardRecordItems = {}
    if type(rewardSchemeIdArray) == "table" and #rewardSchemeIdArray > 0 then
        for i, rewardSchemeId in ipairs(rewardSchemeIdArray) do
            local rewardArray, rrecordItem = self:_getMapRewardArrayWithRewardScheme(mapId, rewardSchemeId, exp, luck, kongfu)
            table.insert(rewardRecordItems, rrecordItem)
            for i, reward in ipairs(rewardArray) do
                table.insert(retRewardArray, reward)
            end
        end
    end
    return retRewardArray, rewardRecordItems
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/15 17:00:17
-- @desc 在副本中使用奖励策略
function RewardManager:_getMapRewardArrayWithRewardScheme(mapId, rsid, exp, luck, kongfu)
    -- 限制奖励获取
    if self:_rewardSchemeCanDo(mapId, rsid) then
        -- print("可以获得奖励")
        local rewardIdArray, record = self:_getRewardIdArrayWithRewardScheme(rsid)
        local rewardArray = {}
        if rewardIdArray then
            for i, v in ipairs(rewardIdArray) do
                local reward = self:_getRewardWithRewardId(v, exp, luck, kongfu)
                table.insert(rewardArray, reward)
            end
        end

        -- 获得奖励成功, 需要记录
        if #rewardArray > 0 then
            -- print("获取到奖励")
            -- 副本奖励策略状态
            local state = self:_getMapSchemeState(mapId, rsid)
            state.times = state.times + 1
            state.dayTimes = state.dayTimes + 1
            self:_setMapSchemeState(mapId, rsid, state)

            -- 整体奖励策略状态
            local state = self:_getSchemeState(rsid)
            state.times = state.times + 1
            state.dayTimes = state.dayTimes + 1
            self:_setSchemeState(rsid, state)
        else
            if PRINT_MODE == 1 then
                print("没有获取到奖励")
            end
        end

        return rewardArray, record
    else
        if PRINT_MODE == 1 then
            print("不能获得奖励")
        end
        return {}
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 17:50:50
-- @desc 获得奖励列表
function RewardManager:getRewardArrayWithRewardScheme(rsid, exp, luck, kongfu)
    -- 限制奖励获取
    if self:_rewardSchemeCanDo(nil, rsid) then
        -- print("可以获得奖励")
        local rewardIdArray, record = self:_getRewardIdArrayWithRewardScheme(rsid)
        local rewardArray = {}
        if rewardIdArray then
            for i, v in ipairs(rewardIdArray) do
                local reward = self:_getRewardWithRewardId(v, exp, luck, kongfu)
                table.insert(rewardArray, reward)
            end
        end

        -- 获得奖励成功, 需要记录
        if #rewardArray > 0 then
            -- print("获取到奖励")
            local state = self:_getSchemeState(rsid)
            state.times = state.times + 1
            state.dayTimes = state.dayTimes + 1
            self:_setSchemeState(rsid, state)
        else
            if PRINT_MODE == 1 then
                print("没有获取到奖励")
            end
        end

        return rewardArray, record
    else
        if PRINT_MODE == 1 then
            print("不能获得奖励")
        end
        return {} ,{}
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/20 19:52:31
-- @desc 获得奖励列表, 通过奖励策略id, 无限制
function RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(rsid, exp, luck, kongfu)
    local rewardIdArray = self:_getRewardIdArrayWithRewardScheme(rsid)
    local rewardArray = {}
    if rewardIdArray then
        for i, v in ipairs(rewardIdArray) do
            local reward = self:_getRewardWithRewardId(v, exp, luck, kongfu)
            table.insert(rewardArray, reward)
        end
    end
    return rewardArray
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 17:29:33
-- @desc 获得奖励
function RewardManager:_getRewardWithRewardId(rid, exp, luck, kongfu ,lv)
    -- print("RewardManager:_getRewardWithRewardId(rid)")
    rid = tostring(rid)

    local lv = lv or User:getRoleAttr("lv")

    if rid == nil or exp == nil or luck == nil then
        if PRINT_MODE == 1 then
            print("warning rid == nil or exp == nil or luck == nil")
        end
    end

    local reward = self.rewardMap[rid]
    if reward then
        if reward.rwType == "物品" then
            return {type = "物品", id = reward.rwName, value = reward.rwNumber, rid = rid}
        elseif reward.rwType == "称号" then
                return {type = "称号", id = reward.rwName, value = reward.rwNumber, rid = rid}
        elseif reward.rwType == "属性" then
            if reward.calcType == "固定类" then
                -----------------------------------------------------------------------------------------------------------
                -- @author GaoHanZheng
                -- @time 2017/06/21 16:30:14
                -- @desc 将固定类改为可支持公式
                local value_rwNumber = 0
                if type(reward.rwNumber) == "string" then
                    -- print("固定类公式1:",reward.rwNumber)
                    value_rwNumber = Helper:GetValueFromScript(reward.rwNumber, {lv = lv})
                elseif type(reward.rwNumber) == "number" then
                    value_rwNumber = reward.rwNumber
                end
                return {type = "属性", id = reward.rwName, value = value_rwNumber, rid = rid}
            elseif reward.calcType == "公式类" then
                -- 根据公式计算奖励
                local value = math.floor(Formula:getFormula(reward.rwFormula)(exp, luck, kongfu, reward.rwNumber, lv))
                return {type = "属性", id = reward.rwName, value = value, rid = rid}
            elseif reward.calcType == "随机类" then
                local num = string.split(reward.rwNumber, ";")
                local value = math.random(tonumber(num[1]), tonumber(num[2]))
                return {type = "属性", id = reward.rwName, value = value, rid = rid}
            else
                error()
            end
            return {type = "物品", id = reward.rwName, value = reward.rwNumber, rid = rid}
        end
    else
        if PRINT_MODE == 1 then
            print("找不到奖励: ", rid)
        end
    end

end

function RewardManager:getFinalRewardWithRewarId(id, exp, luck, kongfu, lv)
    return self:_getRewardWithRewardId(id, exp, luck, kongfu, lv)
end

return RewardManager
000000
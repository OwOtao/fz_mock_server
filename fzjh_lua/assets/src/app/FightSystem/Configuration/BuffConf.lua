--@RefType [Constants]
local Constants = require("app.FightSystem.FightBuff.Constants")

local buffResMap = require("script.newbattle.demo.buff")["总Buff"]
local buffResClassMap = {}

local buffEffectAppearenceMap = require("script.newbattle.demo.buffEffectAppearance")["Buff效果表现"]

-- 加载effect数据
local buffEffectDataMap = require("script.newbattle.demo.buffEffect")["Buff效果"]
local buffEffectMap = {}
--@desc effect分组索引表
local buffEffectIdGroupMap = {}
--@desc 存放效果基础类
local basicEffectClassMap = {}

local BasicEffect = require("app.FightSystem.FightBuff.BasicEffects.BasicEffect")

local function effectGrouping()
    for id, effectRawData in pairs(buffEffectDataMap) do
        local groupId = tostring(effectRawData.effectID)
        if buffEffectIdGroupMap[groupId] == nil then
            buffEffectIdGroupMap[groupId] = {}
        end

        table.insert(buffEffectIdGroupMap[groupId], id)
    end
end
effectGrouping()

local BuffConf = {}

function BuffConf:getEffectData(id)
    return buffEffectDataMap[id]
end

--@return [src.app.FightSystem.FightBuff.Effect#Effect]
function BuffConf:getEffect(id)
    local Effect = require("app.FightSystem.FightBuff.Effect")

    if buffEffectMap[id] == nil then
        buffEffectMap[id] = Effect:create(self:getEffectData(id))
    end
    return buffEffectMap[id]
end

local basicAppearenceMap = {}
--@desc: buff影响的外观属性
--@author:Seven
--@time:2023-03-25 10:52:45
--@buffEffectAppearenceId:
--@return [src.app.FightSystem.FightBuff.BasicBuff.BasicBuffEffectAppearence#BasicBuffEffectAppearence]
function BuffConf:getBuffEffectAppearence(buffEffectAppearenceId)
    if buffEffectAppearenceMap[buffEffectAppearenceId] == nil then
        buffEffectAppearenceId = "noExpression"
    end

    if basicAppearenceMap[buffEffectAppearenceId] ~= nil then
        return basicAppearenceMap[buffEffectAppearenceId]
    end

    local res = buffEffectAppearenceMap[buffEffectAppearenceId]

    local BasicBuffEffectAppearence = require("app.FightSystem.FightBuff.BasicBuff.BasicBuffEffectAppearence")

    local appearenceClass = BasicBuffEffectAppearence:create(res)

    basicAppearenceMap[appearenceClass:getId()] = appearenceClass

    return appearenceClass
end

--@desc: 获取buff基础资源类
--@author:Seven
--@time:2023-03-06 11:16:25
--@buffId: buff id
--@return [src.app.FightSystem.FightBuff.BasicBuff.BasicBuff#BasicBuff]
function BuffConf:getBasicBuffClass(buffId)
    if buffResClassMap[tostring(buffId)] ~= nil then
        return buffResClassMap[tostring(buffId)]
    end

    local resData = buffResMap[tostring(buffId)]

    if resData == nil then
        error("BuffConf:getBasicBuffClass buff不存在，id：" .. tostring(buffId))
    end

    local BasicBuff = require("app.FightSystem.FightBuff.BasicBuff.BasicBuff")

    local buffClass = BasicBuff:create(resData)

    buffResClassMap[tostring(buffClass:getId())] = buffClass
    return buffClass
end

--@desc: 根据效果组id获取效果基础类
--@author:Seven
--@time:2023-03-06 15:08:27
--@effectGroupId: 效果组id
function BuffConf:getBasicEffectsByEffectGroupId(effectGroupId)
    local idList = buffEffectIdGroupMap[tostring(effectGroupId)]
    if idList == nil then
        error("没有找到该效果ID effectId ：" .. tostring(effectGroupId))
    end

    table.sort(
        idList,
        function(a, b)
            return tonumber(a) < tonumber(b)
        end
    )

    local list = {}

    for _, id in ipairs(idList) do
        table.insert(list, self:getBasicEffect(id))
    end

    return list
end

--@desc: 获取效果基础类
--@author:Seven
--@time:2023-03-06 15:34:38
--@id: 效果的编号;id
--@return [src.app.FightSystem.FightBuff.BasicEffects.BasicEffect#BasicEffect]
function BuffConf:getBasicEffect(id)
    if basicEffectClassMap[tostring(id)] == nil then
        local rawData = buffEffectDataMap[tostring(id)]
        if rawData == nil then
            error("BuffConf:getBasicEffect 没有找到效果资源，id：" .. tostring(id))
        end
        basicEffectClassMap[tostring(id)] = BasicEffect:create(rawData)
    end

    return basicEffectClassMap[tostring(id)]
end

--@desc: 获取buff添加器的默认值
--@author:Seven
--@time:2023-03-07 15:50:20
--@adderType: buff添加器类型
function BuffConf:getBuffAdderDefault(adderType)
    local buffAdderDefaultDatas = require("script.newbattle.demo.buffAdderDefault")["添加器类型默认值"]
    return buffAdderDefaultDatas[tostring(adderType)]
end

local buffAdderDatas = require("script.newbattle.demo.buffAdder")["Buff添加器"]
local activeAdderGroupRes
local function __initActiveBuffAdders()
    activeAdderGroupRes = {}
    for k, v in pairs(buffAdderDatas) do
        if activeAdderGroupRes[v.buffLauncher] == nil then
            activeAdderGroupRes[v.buffLauncher] = {}
        end
        table.insert(activeAdderGroupRes[v.buffLauncher], v)
    end
end
__initActiveBuffAdders()
--@desc: 获取主动buff添加器组
--@author:Seven
--@time:2023-03-07 17:19:03
--@buffLauncherId: 主动技能添加器组id
function BuffConf:getActiveBuffAdderGroupResClass(buffLauncherId)
    local list = {}

    local groupRes = activeAdderGroupRes[buffLauncherId]
    if groupRes == nil then
        error("BuffConf:getActiveBuffAdderGroupResClass buffLauncher 为 " .. tostring(buffLauncherId) .. " 的相关资源")
    end

    for i, v in ipairs(groupRes) do
        table.insert(list, require("app.FightSystem.FightBuff.BasicBuffAdder.BasicBuffAdderRes"):create(Constants.ADDER_TYPE.ACTIVE, v))
    end

    table.sort(
        list,
        function(a, b)
            if a:getOrder() == b:getOrder() then
                return tonumber(a:getId()) < tonumber(b:getId())
            end
            return a:getOrder() < b:getOrder()
        end
    )

    return list
end

local autoBuffAdderDatas = require("script.newbattle.demo.shenBingBuffAdder")["新版战斗特性调用表id"]
local autoAdderGroupRes
local function __initAutoBuffAdders()
    autoAdderGroupRes = {}
    for k, v in pairs(autoBuffAdderDatas) do
        if autoAdderGroupRes[v.buffLauncher] == nil then
            autoAdderGroupRes[v.buffLauncher] = {}
        end
        table.insert(autoAdderGroupRes[v.buffLauncher], v)
    end
end
__initAutoBuffAdders()
function BuffConf:getAutoBuffAdderGroupResClass(buffLauncherId)
    local list = {}

    local groupRes = autoAdderGroupRes[buffLauncherId]
    if groupRes == nil then
        error("BuffConf:getAutoBuffAdderGroupResClass buffLauncher 为 " .. tostring(buffLauncherId) .. " 的相关资源")
    end

    for i, v in ipairs(groupRes) do
        table.insert(list, require("app.FightSystem.FightBuff.BasicBuffAdder.BasicBuffAdderRes"):create(Constants.ADDER_TYPE.AUTO, v))
    end

    table.sort(
        list,
        function(a, b)
            if a:getOrder() == b:getOrder() then
                return tonumber(a:getId()) < tonumber(b:getId())
            end
            return a:getOrder() < b:getOrder()
        end
    )

    return list
end

local enterFightBuffAdderDatas = require("script.newbattle.demo.enterFightBuffAdder")["入场Buff添加器"]
local enterBuffAdders
local function __initEnterFightBuffAdder()
    enterBuffAdders = {}
    for k, v in pairs(enterFightBuffAdderDatas) do
        if enterBuffAdders[v.buffLauncher] == nil then
            enterBuffAdders[v.buffLauncher] = {}
        end
        table.insert(enterBuffAdders[v.buffLauncher], v)
    end
end
__initEnterFightBuffAdder()
function BuffConf:getEnterBuffAdderGroupResClass(buffLauncherId)
    local list = {}

    local groupRes = enterBuffAdders[buffLauncherId]
    if groupRes == nil then
        error("BuffConf:getEnterBuffAdderGroupResClass buffLauncher 为 " .. tostring(buffLauncherId) .. " 的相关资源")
    end

    for i, v in ipairs(groupRes) do
        table.insert(list, require("app.FightSystem.FightBuff.BasicBuffAdder.BasicBuffAdderRes"):create(Constants.ADDER_TYPE.ENTER_FIGHT, v))
    end

    table.sort(
        list,
        function(a, b)
            if a:getOrder() == b:getOrder() then
                return tonumber(a:getId()) < tonumber(b:getId())
            end
            return a:getOrder() < b:getOrder()
        end
    )

    return list
end

local NormalBuffRes = require("script.newbattle.demo.normalBuff")["总Buff表常态类"]
function BuffConf:getNormalBuffRes(id)
    local res = NormalBuffRes[tostring(id)]
    if res == nil then
        assert(false, "BuffConf:getNormalBuffRes 没有找到常态buff资源，id：" .. tostring(id))
    end

    return res
end

return BuffConf
000000000000
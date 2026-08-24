--[[
    author:Seven
    time:2023-03-07 19:53:44
    desc: 战斗buff添加器抽象类
]]
local newClass = require("third.class.NewClass")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local AFightCharacterBuffAdderGroup = {}

--@desc: 初始化添加器组(该方法只会在添加器组被添加到角色身上时调用一次，不会重复调用)
--@author:Seven
--@time:2023-10-12 16:29:57
--@buffLauncherId: 添加器id
--@customDynamicArgMap: 自定义动态参数
function AFightCharacterBuffAdderGroup:initAdderGroup(buffLauncherId, customDynamicArgMap)
    self.__adders = {}

    self.__buffLaunchId = buffLauncherId

    --@desc 存放准备加入的buff添加器(根据添加节点分类)
    self.__prepAdderMapByAddNodes = {}

    self:__initBuffAdder(buffLauncherId)

    self:__initBuffAdderDynamicArgMap(customDynamicArgMap)

    --@desc 检查配置
    self:__checkAdderDataRuleHasError()
end

function AFightCharacterBuffAdderGroup:__initBuffAdderDynamicArgMap(customDynamicArgMap)
    if MapIsEmpty(customDynamicArgMap) then
        return
    end
    self:__walkAllAdders(
        function(index, adder)
            for k, v in pairs(customDynamicArgMap) do
                adder:putAdderDynamicArg(k, v)
            end
        end
    )
end

--@desc: 添加器id
--@author:Seven
--@time:2023-03-07 21:11:09
function AFightCharacterBuffAdderGroup:getBuffLauncherId()
    return self.__buffLaunchId
end

--@desc: 设置索引用id
--@author:Seven
--@time:2023-03-11 14:39:25
--@id: 设置索引id
function AFightCharacterBuffAdderGroup:setId(id)
    self.__id = id
end

--@desc: 获取索引id(该id只有直接添加到角色身上时才会存在)
--@author:Seven
--@time:2023-03-11 14:41:03
function AFightCharacterBuffAdderGroup:getId()
    if self.__id == nil then
        error("AFightCharacterBuffAdderGroup:getId 当前buff添加器并未初始化id，检查代码！")
    end

    return self.__id
end

--@desc:获得该添加器组的触发类型
--@author:Seven
--@time:2023-03-07 21:13:48
--@return true|false
function AFightCharacterBuffAdderGroup:isHasTriggerType(triggerType)
    local bool = false
    self:__walkAllAdders(
        function(index, adder)
            if adder:getTriggerType() == triggerType then
                bool = true
                return true
            end

            return false
        end
    )

    return bool
end

--@desc: 设置该添加器拥有者
--@author:Seven
--@time:2023-03-07 20:04:55
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AFightCharacterBuffAdderGroup:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AFightCharacterBuffAdderGroup:getCharacter()
    return self.__character
end

--@desc: 检查该添加器组的触发类型是否一致
--@author:Seven
--@time:2023-03-09 20:06:13
function AFightCharacterBuffAdderGroup:__checkAdderIsSameTriggerType()
    local isSame = true

    local prevValue

    self:__walkAllAdders(
        function(i, adder)
            if prevValue == nil then
                prevValue = adder:getTriggerType()
            else
                if adder:getTriggerType() == prevValue then
                    prevValue = adder:getTriggerType()
                else
                    isSame = false
                    return true
                end
            end

            return false
        end
    )

    return isSame
end

--@desc: 添加器组中的添加器是否有前后顺序关系
--@author:Seven
--@time:2023-03-09 20:16:58
function AFightCharacterBuffAdderGroup:__checkAdderHasOrder()
    local hasOrder = false

    self:__walkAllAdders(
        function(i, adder)
            --@desc 只要有一个添加器的order不为0，则代表该添加器组有顺序关系
            if adder:getOrder() > 0 then
                hasOrder = true
                return true
            end
        end
    )

    return hasOrder
end

--@desc: 检查该添加器组的数据是否正确
--@author:Seven
--@time:2023-03-09 20:21:24
function AFightCharacterBuffAdderGroup:__checkAdderDataRuleHasError()
    local isSameTriggerType = self:__checkAdderIsSameTriggerType()

    local hasOrder = self:__checkAdderHasOrder()

    if isSameTriggerType == false and hasOrder == true then
        error("添加器组：" .. tostring(self.__buffLaunchId) .. " 不支持存在多种triggerType的情况下，有order不为0的情况")
    end
end

--@desc: 设置战场
--@author:Seven
--@time:2023-03-07 20:05:34
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
function AFightCharacterBuffAdderGroup:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
end

function AFightCharacterBuffAdderGroup:__walkAllAdders(func)
    if table.getn(self.__adders) <= 0 then
        return
    end

    for i, v in ipairs(self.__adders) do
        if func(i, v) == true then
            break
        end
    end
end

--@desc: 根据触发节点判断是否应该执行触发
--@author:Seven
--@time:2023-10-07 15:34:20
--@triggerType: 触发类型
--@return: true | false
function AFightCharacterBuffAdderGroup:needTriggerByType(triggerType)
    local bool = false

    self:__walkAllAdders(
        function(index, adder)
            if adder:getTriggerType() == triggerType then
                bool = true
                return true
            end
        end
    )

    return bool
end

--@desc: 根据添加器触发类型过滤添加器组中的添加器列表
--@author:Seven
--@time:2023-10-07 10:53:12
--@triggerType:
--@return: list
function AFightCharacterBuffAdderGroup:__filterAddersByTriggerType(triggerType)
    local list = {}

    self:__walkAllAdders(
        function(index, adder)
            if adder:getTriggerType() == triggerType then
                table.insert(list, adder)
            end
        end
    )

    return list
end

--@desc: 判断添加器是否满足条件
--@author:Seven
--@time:2023-03-10 10:49:44
--@adders: 添加器组
function AFightCharacterBuffAdderGroup:__trigerCheckConditions(adders)
    if MapIsEmpty(adders) then
        return
    end

    local __prepAdders = {}

    local results = {}

    for i, adder in ipairs(adders) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.BasicFightCharacterBuffAdder#BasicFightCharacterBuffAdder]
        adder = adder

        local prevIndex = adder:getIdPrerequisites()

        local prevCondition = true
        if prevIndex > 0 then
            prevCondition = results[prevIndex]

            if prevCondition == nil then
                error("添加器前置判断" .. tostring(adder:getIdPrerequisites()) .. "未找到内容，可能前置添加器触发器类型不一致")
            end
        end

        if prevCondition == true and adder:triggerCheck() then
            results[adder:getOrder()] = true

            table.insert(__prepAdders, adder)
        else
            results[adder:getOrder()] = false
        end
    end
    if MapIsEmpty(__prepAdders) then
        return
    end
    self:__classifyAdder(__prepAdders)
end

--@desc: 根据添加节点分类
--@author:Seven
--@time:2023-03-09 17:49:41
--@prepAdders: 准备好添加的添加器
function AFightCharacterBuffAdderGroup:__classifyAdder(prepAdders)
    for i, adder in ipairs(prepAdders) do
        self:__addToPrepAdderMap(adder)
        self:__processWeightedRandomAdder(adder)
    end
end

--@desc: 根据节点弹出已通过条件判断并准备添加的添加器
--@author:Seven
--@time:2023-03-09 16:57:53
--@addNode: 添加节点
function AFightCharacterBuffAdderGroup:__popPrepAdderByAddNode(addNode)
    local list = Helper:getDef(self.__prepAdderMapByAddNodes[tostring(addNode)], {})

    self.__prepAdderMapByAddNodes[tostring(addNode)] = nil

    return list
end

--@desc: 生成待添加buff数组
--@author:Seven
--@time:2023-10-07 15:07:03
--@addNode: 添加节点类型
--@return: array {buff = [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicCharacterBuff#BasicCharacterBuff], cid = number}
function AFightCharacterBuffAdderGroup:buildAddBuffArrayByAddNode(addNode)
    local prepAdderList = self:__popPrepAdderByAddNode(addNode)

    if table.getn(prepAdderList) == 0 then
        return {}
    end

    local list = {}

    for _, adder in ipairs(prepAdderList) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdder#AFightCharacterBuffAdder]
        adder = adder
        local buffId = adder:getAddBuffId()
        local arg1 = adder:getAddBuffdynamicArg1()
        local arg2 = adder:getAddBuffdynamicArg2()
        local arg3 = adder:getAddBuffdynamicArg3()
        local arg4 = adder:getAddBuffdynamicArg4()

        local targetArray = adder:getAddBuffTargets()
        if table.getn(targetArray) > 0 then
            for _, character in ipairs(targetArray) do
                if not character:isDead() then
                    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
                    local buffBuilder = require("app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder"):create()

                    table.insert(
                        list,
                        {
                            buff = buffBuilder:setBuffId(buffId):setCharacter(character):setBuffCreator(self.__character):setFight(self.__fight):setBuffDynamicArgValue("dynamicArg1", arg1):setBuffDynamicArgValue(
                                "dynamicArg2",
                                arg2
                            ):setBuffDynamicArgValue("dynamicArg3", arg3):setBuffDynamicArgValue("dynamicArg4", arg4):build()
                        }
                    )
                end
            end
        end
    end

    return list
end

function AFightCharacterBuffAdderGroup:triggerBuffAdder(triggerType)
    --@RefType [Constants]
    local BUFF_CONSTANS = require("app.FightSystem.FightBuff.Constants")

    if table.keyof(BUFF_CONSTANS.ADDER_TRIGGER_TYPE, triggerType) == nil then
        assert(false, "AFightCharacterBuffAdderGroup:triggerBuffAdder 未知的触发类型" .. tostring(triggerType) .. "，请检查代码")
    end
    self:__trigerCheckConditions(self:__filterAddersByTriggerType(triggerType))
end

--@desc: 初始化添加器组
--@author:Seven
--@time:2023-03-10 11:18:35
--@buffLauncherId: 添加器组id
function AFightCharacterBuffAdderGroup:__initBuffAdder(buffLauncherId)
    error("AFightCharacterBuffAdderGroup:__initBuffAdder请重写该方法")
end

--@desc: 处理单个添加器的加权随机逻辑
--@author:Seven
--@time:2026-01-12
--@adder: [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.BasicFightCharacterBuffAdder#BasicFightCharacterBuffAdder]
function AFightCharacterBuffAdderGroup:__processWeightedRandomAdder(adder)
    local weightedLauncherConfig = adder:getWeightedLauncher()

    if weightedLauncherConfig == nil or weightedLauncherConfig == "" then
        return
    end

    local launcherId, randomCount = self:__parseWeightedConfig(weightedLauncherConfig)
    local weightedAdders = self:__loadWeightedAdders(launcherId)

    if MapIsEmpty(weightedAdders) then
        return
    end

    local FightUtil = require("app.FightSystem.FightUtil.FightUtil")
    local actualCount = math.min(randomCount, table.getn(weightedAdders))
    FightUtil:printFormatLog("加权随机Buff添加器 - 加载了%s个候选项，将随机选择%s次", table.getn(weightedAdders), actualCount)

    for i = 1, actualCount do
        local selectedAdder, selectedIndex = self:__weightedRandomSelect(weightedAdders, FightUtil)
        if selectedAdder then
            FightUtil:printFormatLog("加权随机Buff添加器 - 第%s次选中: BuffID=%s, 权重=%s", i, selectedAdder:getAddBuffId(), selectedAdder:getWeight())
            self:__addToPrepAdderMap(selectedAdder)
            table.remove(weightedAdders, selectedIndex)
        end
    end
end

--@desc: 解析加权随机配置
--@author:Seven
--@time:2026-01-12
--@config: 配置字符串 格式: launcherId#randomCount
--@return: launcherId, randomCount
function AFightCharacterBuffAdderGroup:__parseWeightedConfig(config)
    local parts = string.split(config, "#")
    local launcherId = parts[1]
    local randomCount = tonumber(parts[2])

    if not launcherId or not randomCount or randomCount <= 0 then
        error("加权随机添加器配置错误: " .. config)
    end

    return launcherId, randomCount
end

--@desc: 添加到准备添加器映射表
--@author:Seven
--@time:2026-01-12
--@adder: 添加器
function AFightCharacterBuffAdderGroup:__addToPrepAdderMap(adder)
    local addNode = tostring(adder:getAddBuffNodes())

    if not self.__prepAdderMapByAddNodes[addNode] then
        self.__prepAdderMapByAddNodes[addNode] = {}
    end

    table.insert(self.__prepAdderMapByAddNodes[addNode], adder)
end

--@desc: 加载加权随机添加器列表
--@author:Seven
--@time:2026-01-12
--@launcherId: 添加器系列ID
--@return: 加权随机添加器列表
function AFightCharacterBuffAdderGroup:__loadWeightedAdders(launcherId)
    local BuffSystemResource = require("app.FightSystem.FightBuff.BuffSystemResource")
    local weightedAdderResList = BuffSystemResource:getWeightedBuffAddersByLauncher(launcherId)

    if MapIsEmpty(weightedAdderResList) then
        return {}
    end

    local adders = {}
    for _, res in ipairs(weightedAdderResList) do
        local adder = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.WeightedFightCharacterBuffAdder"):create(res)
        adder:setCharacter(self.__character)
        adder:setFight(self.__fight)
        table.insert(adders, adder)
    end

    return adders
end

--@desc: 加权随机选择
--@author:Seven
--@time:2026-01-12
--@weightedAdders: 加权随机添加器列表
--@FightUtil: FightUtil实例(避免重复require)
--@return: 选中的添加器, 选中的索引
function AFightCharacterBuffAdderGroup:__weightedRandomSelect(weightedAdders, FightUtil)
    if MapIsEmpty(weightedAdders) then
        return nil, nil
    end

    local totalWeight = 0
    for _, adder in ipairs(weightedAdders) do
        totalWeight = totalWeight + adder:getWeight()
    end

    if totalWeight <= 0 then
        return nil, nil
    end

    local randomValue = FightUtil:random(1, totalWeight)
    local currentWeight = 0

    for index, adder in ipairs(weightedAdders) do
        currentWeight = currentWeight + adder:getWeight()
        if randomValue <= currentWeight then
            return adder, index
        end
    end

    return weightedAdders[1], 1
end

return newClass("AFightCharacterBuffAdderGroup", {}, AFightCharacterBuffAdderGroup)
00000000000000
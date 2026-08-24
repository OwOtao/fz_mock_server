local LogSystem = require("app.models.LogSystem.LogSystem")
local oldPrint = print
local function print(...)
    LogSystem:logWithTab("增益日志.BuffSystem:", ...)
end

local Buff = require("app.FightSystem.FightBuff.Buff")

--@RefType[src.app.FightSystem.FightBuff.Constants#Constants]
local FightBuffConstants = require("app.FightSystem.FightBuff.Constants")

local AFightSystem = require("app.FightSystem.AFightSystem")

local inherit = require("third.inherit.inherit")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local assertIsInstance = require("third.assertIsInstance.assertIsInstance")

local IBuffNeeded = require("app.FightSystem.FightBuff.IBuffNeeded")

local LazyUpdateMap = require("third.collections.map.LazyUpdateMap")

local CustomBuffNeeded = require("app.FightSystem.FightBuff.CustomBuffNeeded")

local FightFormula = require("app.FightSystem.FightFormula")

local AttrsEffect = require("app.FightSystem.FightBuff.AttrsEffect")

local Desc = require("app.FightSystem.FightBuff.Desc")

local ZhaoAttackAttrsEffectArray = require("app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray")

local ZhaoAttackAttrsEffect = require("app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect")

local BuffEmptyExecutor = require("app.FightSystem.FightBuff.BuffEmptyExecutor")

--@class[src.app.FightSystem.FightBuff.BuffExecutor#BuffExecutor]
local BuffExecutor = require("app.FightSystem.FightBuff.BuffExecutor")

local class = require("third.class.NewClass")

local BuffSystem = {
    Constants = FightBuffConstants
}

-- 加载buff数据
local buffDataMap = require("script.newbattle.demo.buff")["总Buff"]
local buffMap = {}
for k, buffData in pairs(buffDataMap) do
    buffData.id = tostring(buffData.id)
    buffMap[k] = Buff:create(buffData)
end

function BuffSystem:init()
    -- 需要移除的buff
    self.__needRemoveBuffArray = {}

    -- 角色buff数组的映射
    self.__roleBuffArrayMap = {}

    -- 角色属性增益
    self.__lazyUpdateRoleAddAttrsMap =
        LazyUpdateMap:create(
        function(map, roleId)
            local addAttrs = {}

            self:__walkActiveBuff(
                function(activeBuff)
                    for attrName, addValue in pairs(activeBuff:getExtraAddAttrs()) do
                        if addAttrs[attrName] == nil then
                            addAttrs[attrName] = 0
                        end
                        addAttrs[attrName] = addAttrs[attrName] + addValue
                    end
                end,
                roleId
            )
            map:set(roleId, addAttrs)
        end
    )

    self.__lazyUpdateRoleMulAttrsMap =
        LazyUpdateMap:create(
        function(map, roleId)
            local mulAttrs = {}
            self:__walkActiveBuff(
                function(activeBuff)
                    for attrName, addValue in pairs(activeBuff:getExtraMulAttrs()) do
                        if mulAttrs[attrName] == nil then
                            mulAttrs[attrName] = 0
                        end
                        mulAttrs[attrName] = mulAttrs[attrName] + addValue
                    end
                end,
                roleId
            )
            map:set(roleId, mulAttrs)
        end
    )

    -- 角色状态映射
    self.__lazyUpdateRoleIdleExpressionMap =
        LazyUpdateMap:create(
        function(map, roleId)
            local state = 0
            local currPriority = 0
            self:__walkActiveEffect(
                function(activeEffect)
                    local newState, priority = activeEffect:getRoleState()
                    if priority > currPriority then
                        currPriority = priority
                        state = newState
                    end
                end,
                roleId
            )

            if map:get(roleId) ~= state then
                map:set(roleId, state)
                self:emitEvent(FightBuffConstants.BuffSystemEventType.__UpdateRoleState, {roleId, state})
            end
        end
    )

    -- buff系统属性
    self.__lazyUpdateRoleBuffSystemAttrMap =
        LazyUpdateMap:create(
        function(map, roleId)
            local buffNum = 0
            local deBuffNum = 0

            self:__walkActiveBuff(
                function(activeBuff)
                    local buffClass = activeBuff:getClass()
                    if buffClass == 0 then
                        buffNum = buffNum + 1
                    elseif buffClass == 1 or buffClass == 4 then
                        deBuffNum = deBuffNum + 1
                    end
                end,
                roleId
            )

            map:set(roleId, {buffNum = buffNum, deBuffNum = deBuffNum})
        end
    )

    --
    self.__lazyUpdateRoleShieldAnimIdMap =
        LazyUpdateMap:create(
        function(map, roleId)
            local currValue = nil
            local currPriority = 0
            self:__walkActiveBuff(
                function(activeBuff)
                    local value, priority = activeBuff:getShieldAnimIdAndPriority()
                    if priority > currPriority then
                        currPriority = priority
                        currValue = value
                    end
                end,
                roleId
            )

            if map:get(roleId) ~= currValue then
                map:set(roleId, currValue)
            end
        end
    )

    -- 脚底光环动画id
    self.__lazyUpdateFeetHaloAnimIdMap =
        LazyUpdateMap:create(
        function(map, roleId)
            local currValue = nil
            local currPriority = 0
            self:__walkActiveBuff(
                function(activeBuff)
                    local value, priority = activeBuff:getFeetHaloAnimIdAndPriority()
                    if priority > currPriority then
                        currPriority = priority
                        currValue = value
                    end
                end,
                roleId
            )

            if map:get(roleId) ~= currValue then
                map:set(roleId, currValue)
            end
        end
    )

    -- 角色buff图标和层数缓存
    self.__lazyUpdateRoleBuffIconAndLevelArrayMap =
        LazyUpdateMap:create(
        function(map, roleId)
            local buffIconAndLevelMap = {}
            local buffIconAndLevelArray = {}
            self:__walkActiveBuff(
                function(activeBuff)
                    if activeBuff:getIcon() then
                        local buffId = activeBuff:getId()
                        if buffIconAndLevelMap[buffId] == nil then
                            table.insert(buffIconAndLevelArray, {buffId = buffId, icon = activeBuff:getIcon(), level = 1})
                            buffIconAndLevelMap[buffId] = #buffIconAndLevelArray
                        else
                            local buffTypeAndLevel = buffIconAndLevelArray[buffIconAndLevelMap[buffId]]
                            buffTypeAndLevel.level = buffTypeAndLevel.level + 1
                        end
                    end
                end,
                roleId
            )
            map:set(roleId, buffIconAndLevelArray)
        end
    )

    self.__lazyUpdateRolePoptextMap =
        LazyUpdateMap:create(
        function(map, roleId)
            local headText = nil
            local currPriority = 0
            self:__walkActiveEffect(
                function(activeEffect)
                    local newHeadText, priority = activeEffect:getRoleHeadText()
                    if priority > currPriority then
                        currPriority = priority
                        headText = newHeadText
                    end
                end,
                roleId
            )

            map:set(roleId, headText)
        end
    )

    self.__lazyUpdateRoleHurtExpressionMap =
        LazyUpdateMap:create(
        function(map, roleId)
            local state = 0
            local currPriority = 0
            self:__walkActiveEffect(
                function(activeEffect)
                    local newState, priority = activeEffect:getRoleHurtState()
                    if priority > currPriority then
                        currPriority = priority
                        state = newState
                    end
                end,
                roleId
            )

            map:set(roleId, state)
        end
    )

    self.__lazyUpdateRoleTiliAndNeiliCostMap =
        LazyUpdateMap:create(
        function(map, roleId)
            local addActiveZhaoTiliCost = 0
            local mulActiveZhaoTiliCost = 0

            local addAutoZhaoTiliCost = 0
            local mulAutoZhaoTiliCost = 0

            local addActiveZhaoNeiliCost = 0
            local mulActiveZhaoNeiliCost = 0

            local addAutoZhaoNeiliCost = 0
            local mulAutoZhaoNeiliCost = 0

            self:__walkActiveEffect(
                function(activeEffect)
                    addActiveZhaoTiliCost = addActiveZhaoTiliCost + activeEffect:getAddActiveZhaoTiliCost()
                    mulActiveZhaoTiliCost = mulActiveZhaoTiliCost + activeEffect:getMulActiveZhaoTiliCost()

                    addAutoZhaoTiliCost = addAutoZhaoTiliCost + activeEffect:getAddAutoZhaoTiliCost()
                    mulAutoZhaoTiliCost = mulAutoZhaoTiliCost + activeEffect:getMulAutoZhaoTiliCost()

                    addActiveZhaoNeiliCost = addActiveZhaoNeiliCost + activeEffect:getAddActiveZhaoNeiliCost()
                    mulActiveZhaoNeiliCost = mulActiveZhaoNeiliCost + activeEffect:getMulActiveZhaoNeiliCost()

                    addAutoZhaoNeiliCost = addAutoZhaoNeiliCost + activeEffect:getAddAutoZhaoNeiliCost()
                    mulAutoZhaoNeiliCost = mulAutoZhaoNeiliCost + activeEffect:getMulAutoZhaoNeiliCost()
                end,
                roleId
            )

            map:set(
                roleId,
                {
                    addActiveZhaoTiliCost = addActiveZhaoTiliCost,
                    mulActiveZhaoTiliCost = mulActiveZhaoTiliCost,
                    addAutoZhaoTiliCost = addAutoZhaoTiliCost,
                    mulAutoZhaoTiliCost = mulAutoZhaoTiliCost,
                    addActiveZhaoNeiliCost = addActiveZhaoNeiliCost,
                    mulActiveZhaoNeiliCost = mulActiveZhaoNeiliCost,
                    addAutoZhaoNeiliCost = addAutoZhaoNeiliCost,
                    mulAutoZhaoNeiliCost = mulAutoZhaoNeiliCost
                }
            )
        end
    )

    -- 事件监听
    self.__eventListener = function()
    end
end

function BuffSystem:startFight()
    local charaters = self.__fight:getFightCharacters()

    local buffExecutors = {}
    for i = 1, table.getn(charaters) do
        local f_character = charaters[i]

        --@region 武器相关buff添加
        local weapon = f_character:getWeapon()

        local list = table.mergeArray(weapon:getBuffArray(), f_character:getFistFootPermanentBuffs())

        for i, buff in ipairs(list) do
            table.insert(
                buffExecutors,
                f_character:getBuffSystem():addBuff(f_character, f_character, buff.addBuffID, 1, buff.addBuffdynamicArg1, buff.addBuffdynamicArg2, buff.addBuffdynamicArg3, 100)
            )
        end
    end
    --#TODO 这个位置不能支持buffExecutor
    -- for i, buffExecutor in ipairs(buffExecutors) do
    --     buffExecutor:execute()
    -- end
end

function BuffSystem:getBuff(buffId)
    return assert(buffMap[buffId], "找不到buffId：" .. tostring(buffId))
end

function BuffSystem:__updateRoleState(roleId)
    self.__lazyUpdateRoleAddAttrsMap:update(roleId)
    self.__lazyUpdateRoleMulAttrsMap:update(roleId)
    self.__lazyUpdateRoleBuffSystemAttrMap:update(roleId)
    self.__lazyUpdateRoleTiliAndNeiliCostMap:update(roleId)
    self.__lazyUpdateRoleIdleExpressionMap:update(roleId)
    self.__lazyUpdateRoleHurtExpressionMap:update(roleId)
    self.__lazyUpdateRolePoptextMap:update(roleId)
    self.__lazyUpdateRoleShieldAnimIdMap:update(roleId)
    self.__lazyUpdateFeetHaloAnimIdMap:update(roleId)
    self.__lazyUpdateRoleBuffIconAndLevelArrayMap:update(roleId)
end

function BuffSystem:addEventListener(listener)
    self.__eventListener = listener
end

function BuffSystem:emitEvent(eventType, params)
    print("emitEvent", eventType, unpack(params))
    return self.__eventListener(eventType, params)
end

--[[
    @desc: 判断角色是否拥有某个buff
    author:TangJian
    time:2021-06-25 17:43:41
    --@roleId: 角色ID
	--@buffId: 增益ID
    @return: boolean
]]
function BuffSystem:roleHasBuff(roleId, buffId)
    assert(roleId)
    assert(buffId)

    local roleBuffArray = self:__getRoleBuffArray(roleId, buffId)
    return #roleBuffArray > 0
end

function BuffSystem:roleHasBuffClass(roleId, buffClass)
    assert(roleId)
    assert(buffClass)

    local ok = false
    buffClass = tonumber(buffClass)

    self:__walkActiveBuff(
        function(activeBuff)
            if activeBuff:getClass() == buffClass then
                ok = true
                return true
            end
        end,
        roleId
    )

    return ok
end

-- 获得buff层数
function BuffSystem:getBuffCount(roleId, buffId)
    buffId = tostring(buffId)
    local roleBuffArray = self:__getRoleBuffArray(roleId, buffId)
    return #roleBuffArray
end

--[[
    @desc: 获取当前buffIcon和层数的数组
    author: 唐健
    time:2021-07-02 17:48:37
    --@roleId: 角色Id
    @return: {{buffId = buffId, icon = activeBuff:getIcon(), level = 1}}
]]
function BuffSystem:getRoleBuffIconAndLevelArray(roleId)
    local rets = self.__lazyUpdateRoleBuffIconAndLevelArrayMap:get(roleId)
    print("getRoleBuffIconAndLevelArray", rets)
    return rets
end

--@region BuffSystem
-- 条件ID：1=自身持有特定BuffID；参数：BuffID
-- 条件ID：2=目标持有特定BuffID；参数：BuffID
-- 条件ID：3=自身持有特定BuffClass；参数：BuffClass
-- 条件ID：4=目标持有特定BuffClass；参数：BuffClass
-- 条件ID：40=自身持有指定武器类型；参数：武器第三类型
-- 条件ID：41=目标持有指定武器类型；参数：武器第三类型
function BuffSystem:addBuff(attacker, target, buffId, autoAvgAtk, dynamicArg1, dynamicArg2, dynamicArg3, addProbability)
    assert(attacker, "添加buff失败，攻击者不存在")
    assert(target, "添加buff失败，目标不存在")
    assert(autoAvgAtk, "添加buff失败，攻击力不存在")
    assert(dynamicArg1, "添加buff失败，动态参数1不存在")
    assert(dynamicArg2, "添加buff失败，动态参数2不存在")
    assert(dynamicArg3, "添加buff失败，动态参数3不存在")
    assert(type(addProbability) == "number")
    assert(buffId ~= nil, "buffId is nil")
    -- buffId必须为字符串
    buffId = tostring(buffId)

    if target:isDead() then
        return BuffEmptyExecutor:create()
    end

    -- if self:roleIsImmuneBuff(target:getId(), buffId) then
    --     print(target:getId(), "免疫buff", buffId)
    --     return BuffEmptyExecutor:create()
    -- end

    --@RefType[src.app.FightSystem.FightBuff.CustomBuffNeeded#CustomBuffNeeded]
    local buffNeeded = CustomBuffNeeded:create()
    buffNeeded:setAttacker(attacker)

    buffNeeded:setGetAttrFunc(
        function(attrName)
            return attacker:getAttr(attrName)
        end
    )

    buffNeeded:setSelfWeaponAttrGetter(
        function(attrName)
            return attacker:getWeapon():getWeaponAttr(attrName)
        end
    )

    buffNeeded:setGetTargetAttrFunc(
        function(attrName)
            return target:getAttr(attrName)
        end
    )

    buffNeeded:setTargetWeaponAttrGetter(
        function(attrName)
            return target:getWeapon():getWeaponAttr(attrName)
        end
    )

    buffNeeded:setAutoAvgAtk(autoAvgAtk)
    buffNeeded:setDynamicArg1(dynamicArg1)
    buffNeeded:setDynamicArg2(dynamicArg2)
    buffNeeded:setDynamicArg3(dynamicArg3)

    buffNeeded:setSelfWeaponType(attacker:getWeapon():getFirstType())
    buffNeeded:setTargetWeaponType(target:getWeapon():getFirstType())

    local addSuccess, effectArray = self:__addBuff(target:getId(), buffId, buffNeeded)

    if addSuccess then
        self:__updateRoleState(attacker:getId())
        self:__updateRoleState(target:getId())
    end

    local buffExecutor = BuffExecutor:create()
    buffExecutor:setBuffSystem(self)
    buffExecutor:setAttacker(attacker)
    buffExecutor:setTarget(target)
    buffExecutor:setEffectArray(effectArray)
    buffExecutor:appendBuffAnimEffect(buffMap[buffId]:getAddBuffEffect())

    if addSuccess then
        buffExecutor:setAddBuffPrintText(buffMap[buffId]:getAddText())
        return buffExecutor
    else
        return buffExecutor
    end
end

--[[
    @desc:给角色加buff
    author:唐健
    time:2021-06-30 15:47:39
    --@roleId: 角色Id
	--@buffId: buffId
    @return: {src.app.FightSystem.FightBuff.Desc#Desc}
]]
function BuffSystem:__addBuff(roleId, buffId, buffNeeded)
    assert(roleId)
    assert(buffId)
    assert(buffNeeded)

    if type(buffId) == "number" then
        buffId = tostring(buffId)
    end

    assertIsInstance(buffNeeded, IBuffNeeded)

    local addBuffSuccess = false

    local retEffectArray = {}

    local buff = buffMap[buffId]
    assert(buff ~= nil, "找不到buffId:" .. tostring(buffId))

    local activeBuff = buff:createActiveBuff(buffNeeded)

    local isImmuneBuff = self:roleIsImmuneBuff(roleId, activeBuff:getId())

    print("BuffTriggerAddBuff:trigger:isImmuneBuff:", isImmuneBuff)

    if isImmuneBuff then
        return false, {}
    end

    local roleBuffArray = self:__getRoleBuffArray(roleId, buff:getId())

    if buff:getStackType() == 0 then
        -- 添加buff
        local triggerSuccess, effectArray = self:roleTriggerBuff(roleId, FightBuffConstants.BuffTriggerType.Add, activeBuff)
        print("添加buff结果：", triggerSuccess)

        table.appendArray(retEffectArray, effectArray)

        if triggerSuccess then
            addBuffSuccess = true

            for i = #roleBuffArray, 1, -1 do
                local activeBuff = roleBuffArray[i]
                table.remove(roleBuffArray, i)
            end

            table.insert(roleBuffArray, activeBuff)

            print(roleId, "添加buff", activeBuff:getName(), "成功, 当前层数", #roleBuffArray)
        end
    elseif buff:getStackType() == 1 then
        if #roleBuffArray < activeBuff:getStackTimes() then
            -- addBuff触发
            local triggerSuccess, effectArray = self:roleTriggerBuff(roleId, FightBuffConstants.BuffTriggerType.Add, activeBuff)
            print("添加buff结果：", triggerSuccess)

            table.appendArray(retEffectArray, effectArray)

            if triggerSuccess then
                addBuffSuccess = true
                table.insert(roleBuffArray, activeBuff)
                print(roleId, "添加buff", activeBuff:getName(), "成功, 当前层数", #roleBuffArray)
            end
        end
    elseif buff:getStackType() == 2 then
        if #roleBuffArray < activeBuff:getStackTimes() then
            -- addBuff触发
            local triggerSuccess, effectArray = self:roleTriggerBuff(roleId, FightBuffConstants.BuffTriggerType.Add, activeBuff)
            print("添加buff结果：", triggerSuccess)

            table.appendArray(retEffectArray, effectArray)

            if triggerSuccess then
                addBuffSuccess = true
                table.insert(roleBuffArray, activeBuff)
                print(roleId, "添加buff", activeBuff:getName(), "成功, 当前层数", #roleBuffArray)
            end
        end

        -- 重置触发次数
        for i = #roleBuffArray, 1, -1 do
            local activeBuff = roleBuffArray[i]
            activeBuff:initTriggerTimes()
        end
    elseif buff:getStackType() == 3 then
        -- addBuff触发
        local triggerSuccess, effectArray = self:roleTriggerBuff(roleId, FightBuffConstants.BuffTriggerType.Add, activeBuff)
        print("添加buff结果：", triggerSuccess)

        table.appendArray(retEffectArray, effectArray)

        if triggerSuccess then
            addBuffSuccess = true

            self:roleRemoveBuffByBuffEffectClass(roleId, activeBuff:getEffectClass())

            table.insert(roleBuffArray, activeBuff)

            print(roleId, "添加buff", activeBuff:getName(), "成功, 当前层数", #roleBuffArray)
        end
    else
        error("找不到buff堆叠类型:" .. tostring(buff:getStackType()))
    end

    if addBuffSuccess then
        -- buffclass触发
        local triggerSuccess, effectArray = self:roleTriggerBuff(roleId, FightBuffConstants.BuffTriggerType.GetBuffClass, buff:getClass())
        table.appendArray(retEffectArray, effectArray)

        print("添加buff成功:", buffId)
    else
        print("添加buff失败:", buffId)
    end

    return addBuffSuccess, retEffectArray
end

--[[
    @desc: 获取效果执行器
    author:TangJian
    time:2022-01-12 17:46:15
    --@roleId: 角色Id
	--@eventType: 事件类型
	--@eventParam: 事件参数
    @return: 效果执行器
]]
function BuffSystem:getBuffExecutor(character, eventType, eventParam)
    local ok, effectArray = self:roleTriggerBuff(character:getId(), eventType, eventParam)
    local buffExecutor = BuffExecutor:create()
    buffExecutor:setBuffSystem(self)
    buffExecutor:setTarget(character)
    buffExecutor:setEffectArray(effectArray)
    return buffExecutor
end

--[[
    @desc:通过事件触发buff
    author:唐健
    time:2021-06-30 15:43:37
    --@roleId: 角色Id
	--@eventName: 事件名
	--@eventParam: 事件参数
    @return: 属性效果, 描述
]]
function BuffSystem:roleTriggerBuff(roleId, eventName, eventParam)
    assert(roleId)
    assert(eventName)

    local trigger = require("app.FightSystem.FightBuff.BuffTrigger.BuffTriggerFactory"):create(self, roleId, eventName, eventParam)
    return trigger:trigger()
end

function BuffSystem:addNeedRemoveBuffByLevelCount(roleId, buffId, levelCount)
    if levelCount == nil then
        levelCount = -1
    end
    if levelCount == 0 then
        return
    end

    local buffArray = self:__getRoleBuffArray(roleId, buffId)
    for i = 1, #buffArray do
        if levelCount >= i or levelCount < 0 then
            self:addNeedRemoveBuff(roleId, buffId, i)
        end
    end
end

function BuffSystem:addNeedRemoveBuff(roleId, buffId, buffIndex)
    print("BuffSystem:addNeedRemoveBuff:", roleId, buffId, buffIndex)
    table.insert(self.__needRemoveBuffArray, {roleId = roleId, buffId = buffId, buffIndex = buffIndex})
end

function BuffSystem:roleRemoveBuffByBuffClass(roleId, buffClass)
    self:__walkActiveBuff(
        function(activeBuff, roleId, buffId, buffIndex)
            buffClass = tonumber(buffClass)
            if buffClass == 0 or activeBuff:getClass() == buffClass then
                table.insert(self.__needRemoveBuffArray, {roleId = roleId, buffId = buffId, buffIndex = buffIndex})
            end
        end,
        roleId
    )

    return self:__removeBuff(roleId)
end

function BuffSystem:roleRemoveBuffByBuffEffectClass(roleId, effectClass)
    self:__walkActiveBuff(
        function(activeBuff, roleId, buffId, buffIndex)
            if activeBuff:getEffectClass() == effectClass then
                table.insert(self.__needRemoveBuffArray, {roleId = roleId, buffId = buffId, buffIndex = buffIndex})
            end
        end,
        roleId
    )

    return self:__removeBuff(roleId)
end

--[[
    @desc: 尝试移除buff
    author:tangjian
    time:2021-06-30 15:44:24
    --@eventName: 事件名
    @return: 移除的buff列表
]]
function BuffSystem:roleTryRemoveBuff(roleId, eventType, eventParam)
    assert(roleId)
    assert(eventType)

    self:__walkActiveBuff(
        function(activeBuff, roleId, buffId, buffIndex)
            -- 尝试删除条件
            activeBuff:tryDeleteCon(eventType, eventParam)

            if activeBuff:tryRemove(eventType, eventParam) then
                table.insert(self.__needRemoveBuffArray, {roleId = roleId, buffId = buffId, buffIndex = buffIndex})
            end
        end,
        roleId
    )

    return self:__removeBuff(roleId)
end

function BuffSystem:__removeBuff(roleId)
    local removeBuffArray = self.__needRemoveBuffArray
    self.__needRemoveBuffArray = {}
    local hasRemoveBuff = false
    -- 移除这些buff, 先按照buffIndex降序排列, 然后挨个移除
    table.sort(
        removeBuffArray,
        function(a, b)
            return a.buffIndex > b.buffIndex
        end
    )

    local retRemoveBuffArray = {}

    for _, removeBuff in ipairs(removeBuffArray) do
        hasRemoveBuff = true
        local buff = self:__removeActiveBuff(removeBuff.roleId, removeBuff.buffId, removeBuff.buffIndex)
        table.insert(retRemoveBuffArray, buff)
        print(roleId, "移除buff", removeBuff.roleId, removeBuff.buffId, removeBuff.buffIndex)
    end

    if hasRemoveBuff then
        self:__updateRoleState(roleId)
    end

    return retRemoveBuffArray
end

function BuffSystem:getRoleIdleExpression(roleId)
    assert(roleId)
    return self.__lazyUpdateRoleIdleExpressionMap:get(roleId) or 0
end

function BuffSystem:getRoleHurtExpression(roleId)
    assert(roleId)
    return self.__lazyUpdateRoleHurtExpressionMap:get(roleId) or 0
end

function BuffSystem:getRoleHeadText(roleId)
    assert(roleId)
    return self.__lazyUpdateRolePoptextMap:get(roleId)
end

function BuffSystem:getRoleShieldAnimId(roleId)
    assert(roleId)
    return self.__lazyUpdateRoleShieldAnimIdMap:get(roleId)
end

function BuffSystem:getRoleFeetHaloAnimId(roleId)
    assert(roleId)
    return self.__lazyUpdateFeetHaloAnimIdMap:get(roleId)
end

--[[
    @desc: 获取buff系统中的属性
    author:TangJian
    time:2022-05-17 17:32:19
    --@attrName: 
    @return:
]]
function BuffSystem:getBuffSystemAttr(roleId, attrName)
    local attrValue = self.__lazyUpdateRoleBuffSystemAttrMap:get(roleId)[attrName]
    assert(attrValue ~= nil, "BuffSystem:getBuffSystemAttr:", roleId, attrName)
    return attrValue
end

--[[
    @desc: 获得角色属性加法加成
    author: 唐健
    time:2021-07-01 10:10:34
    --@roleId: 角色ID
	--@attrName: 属性名
    @return: number
]]
function BuffSystem:getAddAttr(roleId, attrName)
    assert(roleId)
    assert(attrName)

    local addAttrs = self.__lazyUpdateRoleAddAttrsMap:get(roleId)
    if addAttrs == nil or addAttrs[attrName] == nil then
        print(roleId, "获取角色属性加法加成", attrName, 0)
        return 0
    end
    print(roleId, "获取角色属性加法加成", attrName, addAttrs[attrName])
    return addAttrs[attrName]
end

--[[
    @desc: 获得属性乘法加成
    author: 唐健
    time:2021-07-01 10:39:46
    --@roleId: 属性Id
	--@attrName: 属性名
    @return: number
]]
function BuffSystem:getMulAttr(roleId, attrName)
    assert(roleId)
    assert(attrName)

    local mulAttrs = self.__lazyUpdateRoleMulAttrsMap:get(roleId)
    if mulAttrs == nil or mulAttrs[attrName] == nil then
        print(roleId, "获取角色属性乘法加成", attrName, 0)
        return 0
    end
    print(roleId, "获取角色属性乘法加成", attrName, mulAttrs[attrName])
    return mulAttrs[attrName]
end

--[[
    @desc:获取被动招式伤害减免率数组
    author:tang
    time:2021-07-15 15:02:25
    --@roleId: 
    @return:{{effectFuncId = activeEffect:getId(), value = value}}
]]
function BuffSystem:roleGetAutoZhaoReductionOfInjuryRateArray(roleId)
    assert(roleId)

    local autoZhaoReductionOfInjuryArray = {}
    self:__walkActiveEffect(
        function(activeEffect)
            local ok, value = activeEffect:tryGetAutoZhaoReductionOfInjury()
            if ok then
                table.insert(autoZhaoReductionOfInjuryArray, {effectFuncId = activeEffect:getId(), value = value})
            end
        end,
        roleId
    )
    return autoZhaoReductionOfInjuryArray
end

--[[
    @desc:获取主动招式伤害减免率数组
    author:tang
    time:2021-07-15 15:02:25
    --@roleId: 
    @return:{{effectFuncId = activeEffect:getId(), value = value}}
]]
function BuffSystem:roleGetActiveZhaoReductionOfInjuryRateArray(roleId)
    assert(roleId)

    local activeZhaoReductionOfInjuryArray = {}
    self:__walkActiveEffect(
        function(activeEffect)
            local ok, value = activeEffect:tryGetActiveZhaoReductionOfInjury()
            if ok then
                table.insert(activeZhaoReductionOfInjuryArray, {effectFuncId = activeEffect:getId(), value = value})
            end
        end,
        roleId
    )
    return activeZhaoReductionOfInjuryArray
end

--[[
    @desc: 获取被动招式伤害减免值数组
    author:TangJian
    time:2021-12-02 20:22:08
    --@roleId: 
    @return:{{effectFuncId = activeEffect:getId(), value = value}}
]]
function BuffSystem:roleGetAutoZhaoReductionOfInjuryValueArray(roleId)
    assert(roleId)

    local autoZhaoReductionOfInjurySubArray = {}
    self:__walkActiveEffect(
        function(activeEffect)
            local ok, value = activeEffect:tryGetAutoZhaoReductionOfInjurySub()
            if ok then
                table.insert(autoZhaoReductionOfInjurySubArray, {effectFuncId = activeEffect:getId(), value = value})
            end
        end,
        roleId
    )
    return autoZhaoReductionOfInjurySubArray
end

--[[
    @desc: 获取主动招式伤害减免值数组
    author:TangJian
    time:2021-12-02 20:22:08
    --@roleId: 
    @return:{{effectFuncId = activeEffect:getId(), value = value}}
]]
function BuffSystem:roleGetActiveZhaoReductionOfInjuryValueArray(roleId)
    assert(roleId)

    local activeZhaoReductionOfInjurySubArray = {}
    self:__walkActiveEffect(
        function(activeEffect)
            local ok, value = activeEffect:tryGetActiveZhaoReductionOfInjurySub()
            if ok then
                table.insert(activeZhaoReductionOfInjurySubArray, {effectFuncId = activeEffect:getId(), value = value})
            end
        end,
        roleId
    )
    return activeZhaoReductionOfInjurySubArray
end

--[[
    @desc: 角色是否随机使用基本被动招式
    author:tangjian
    time:2021-07-29 16:53:09
    --@roleId: 
    @return:
]]
function BuffSystem:roleIsRandomBaseAutoZhao(roleId)
    assert(roleId)

    local success = false
    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:isRandomBaseAutoZhao() then
                success = true
                return true
            end
        end,
        roleId
    )

    return success
end

function BuffSystem:roleIsBanAutoZhao(roleId)
    assert(roleId)

    local success = false
    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:isBanAutoZhao() then
                success = true
                return true
            end
        end,
        roleId
    )

    return success
end

function BuffSystem:roleIsBanActiveZhao(roleId, activeZhaoType)
    assert(roleId)
    assert(activeZhaoType)

    local success = false
    local tip = ""

    self:__walkActiveEffect(
        function(activeEffect)
            success, tip = activeEffect:isBanActiveZhao(activeZhaoType)
            return success
        end,
        roleId
    )
    return success, tip
end

function BuffSystem:roleIsBanQingGongDodge(roleId)
    assert(roleId)

    local success = false
    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:isBanQingGongDodge() then
                success = true
                return true
            end
        end,
        roleId
    )

    return success
end

function BuffSystem:roleIsBanNormalParry(roleId)
    assert(roleId)

    local success = false
    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:isBanNormalParry() then
                success = true
                return true
            end
        end,
        roleId
    )

    return success
end

function BuffSystem:roleIsImmuneBuff(roleId, buffId)
    assert(roleId)
    assert(buffId)

    if type(buffId) == "number" then
        buffId = tostring(buffId)
    end

    local immune = false
    self:__walkActiveEffect(
        function(activeEffect)
            local buff = buffMap[buffId]

            immune = activeEffect:isImmuneBuff(buff)

            if immune then
                return true
            end

            return false
        end,
        roleId
    )

    print("BuffSystem:roleIsImmuneBuff:return:", immune)
    return immune
end

--[[
    @desc: 获取主动技能体力消耗加法加成
    author:tangjian
    time:2021-07-29 16:04:52
    --@roleId: 
    @return:
]]
function BuffSystem:roleGetAddActiveZhaoTiliCost(roleId)
    assert(roleId)

    local costMap = self.__lazyUpdateRoleTiliAndNeiliCostMap:get(roleId)
    if costMap then
        return costMap.addActiveZhaoTiliCost or 0
    end
    return 0
end

--[[
    @desc: 获取主动技能体力消耗乘法加成
    author:tangjian
    time:2021-07-29 16:05:23
    --@roleId: 
    @return:
]]
function BuffSystem:roleGetMulActiveZhaoTiliCost(roleId)
    assert(roleId)

    local costMap = self.__lazyUpdateRoleTiliAndNeiliCostMap:get(roleId)
    if costMap then
        return costMap.mulActiveZhaoTiliCost or 0
    end
    return 0
end

--[[
    @desc: 获取被动技能体力消耗加法加成
    author:tangjian
    time:2021-07-29 16:05:51
    --@roleId: 
    @return:
]]
function BuffSystem:roleGetAddAutoZhaoTiliCost(roleId)
    assert(roleId)

    local costMap = self.__lazyUpdateRoleTiliAndNeiliCostMap:get(roleId)
    if costMap then
        return costMap.addAutoZhaoTiliCost or 0
    end
    return 0
end

--[[
    @desc: 获取被动技能体力消耗乘法加成
    author:tangjian
    time:2021-07-29 16:06:12
    --@roleId: 
    @return:
]]
function BuffSystem:roleGetMulAutoZhaoTiliCost(roleId)
    assert(roleId)

    local costMap = self.__lazyUpdateRoleTiliAndNeiliCostMap:get(roleId)
    if costMap then
        return costMap.mulAutoZhaoTiliCost or 0
    end
    return 0
end

--[[
    @desc: 获取主动技能内力消耗加法加成
    author:tangjian
    time:2021-07-29 16:06:30
    --@roleId: 
    @return:
]]
function BuffSystem:roleGetAddActiveZhaoNeiliCost(roleId)
    assert(roleId)

    local costMap = self.__lazyUpdateRoleTiliAndNeiliCostMap:get(roleId)
    if costMap then
        return costMap.addActiveZhaoNeiliCost or 0
    end
    return 0
end

--[[
    @desc: 获取主动技能内力消耗加法加成
    author:{author}
    time:2021-07-29 16:06:54
    --@roleId: 
    @return:
]]
function BuffSystem:roleGetMulActiveZhaoNeiliCost(roleId)
    assert(roleId)

    local costMap = self.__lazyUpdateRoleTiliAndNeiliCostMap:get(roleId)
    if costMap then
        return costMap.mulActiveZhaoNeiliCost or 0
    end
    return 0
end

--[[
    @desc: 获取被动技能内力消耗加法加成
    author:tangjian
    time:2021-07-29 16:07:14
    --@roleId: 
    @return:
]]
function BuffSystem:roleGetAddAutoZhaoNeiliCost(roleId)
    assert(roleId)

    local costMap = self.__lazyUpdateRoleTiliAndNeiliCostMap:get(roleId)
    if costMap then
        return costMap.addAutoZhaoNeiliCost or 0
    end
    return 0
end

--[[
    @desc: 获取被动技能内力消耗加乘加成
    author:tangjain
    time:2021-07-29 16:07:26
    --@roleId: 
    @return:
]]
function BuffSystem:roleGetMulAutoZhaoNeiliCost(roleId)
    assert(roleId)

    local costMap = self.__lazyUpdateRoleTiliAndNeiliCostMap:get(roleId)
    if costMap then
        return costMap.mulAutoZhaoNeiliCost or 0
    end
    return 0
end

--[[
    @desc: 合并激活的效果数组
    author:TangJian
    time:2021-12-02 21:06:08
    --@activeEffects: 
    @return:
]]
function BuffSystem:combineActiveEffect(activeEffects)
    local activeEffectIndexMap = {}
    local combinedActiveEffectArray = {}
    for i, activeEffect in ipairs(activeEffects) do
        if activeEffect:getStackType() == FightBuffConstants.EffectStackType.Max then
            if activeEffectIndexMap[activeEffect:getId()] == nil then
                local combinedActiveEffect = inherit({}, activeEffect)
                table.insert(combinedActiveEffectArray, combinedActiveEffect)
                activeEffectIndexMap[activeEffect:getId()] = combinedActiveEffect
            else
                local combinedActiveEffect = activeEffectIndexMap[activeEffect:getId()]
                combinedActiveEffect:combine(activeEffect)
            end
        else
            table.insert(combinedActiveEffectArray, activeEffect)
        end
    end

    return combinedActiveEffectArray
end

-- 被动招式攻击伤害比例影响属性
--@desc: 获取被动攻击中攻击者身上影响双方属性的buff效果
--@author:Seven
--@time:2021-12-02 18:55:36
--@roleId: 攻击中攻击者的id(即buff拥有者)
--@return [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
function BuffSystem:roleGetUseAutoZhaoAttrsEffectMap(roleId)
    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
    local roleAttrsEffectArray = ZhaoAttackAttrsEffectArray:create()

    self:__walkActiveEffect(
        function(activeEffect)
            local ok, target, attrName, value = activeEffect:getUseAutoZhaoAttrEffect()
            if ok then
                --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
                local v = ZhaoAttackAttrsEffect:create()
                v:setOwnerId(roleId)
                v:setEffectFuncId(activeEffect:getId())
                v:setTargetType(target)
                v:setAttrName(attrName)
                v:setValue(value)
                roleAttrsEffectArray:add(v)
            end
        end,
        roleId
    )

    print("roleGetUseAutoZhaoAttrsEffectMap:", roleAttrsEffectArray:getZhaoAttackAttrs())
    return roleAttrsEffectArray
end

--@desc:获取被动攻击中受击者身上影响双方属性的buff效果
--@author:Seven
--@time:2021-12-02 18:53:52
--@roleId: 攻击中受击方的id(即buff拥有者)
--@return [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
function BuffSystem:roleGetUnderAutoZhaoAttrsEffectMap(roleId)
    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
    local roleAttrsEffectArray = ZhaoAttackAttrsEffectArray:create()

    self:__walkActiveEffect(
        function(activeEffect)
            local ok, target, attrName, value = activeEffect:getUnderAutoZhaoAttrEffect()
            if ok then
                --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
                local v = ZhaoAttackAttrsEffect:create()
                v:setOwnerId(roleId)
                v:setEffectFuncId(activeEffect:getId())
                v:setTargetType(target)
                v:setAttrName(attrName)
                v:setValue(value)
                roleAttrsEffectArray:add(v)
            end
        end,
        roleId
    )

    print("roleGetUnderAutoZhaoAttrsEffectMap:", roleAttrsEffectArray:getZhaoAttackAttrs())
    return roleAttrsEffectArray
end

-- 主动招式攻击伤害比例影响属性
--@desc: 获取主动攻击中攻击者身上影响双方属性的buff效果
--@author:Seven
--@time:2021-12-02 18:55:36
--@roleId: 攻击中攻击者的id(即buff拥有者)
--@return [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
function BuffSystem:roleGetUseActiveZhaoAttrsEffectMap(roleId)
    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
    local roleAttrsEffectArray = ZhaoAttackAttrsEffectArray:create()

    self:__walkActiveEffect(
        function(activeEffect)
            local ok, target, attrName, value = activeEffect:getUseActiveZhaoAttrEffect()
            if ok then
                --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
                local v = ZhaoAttackAttrsEffect:create()
                v:setOwnerId(roleId)
                v:setEffectFuncId(activeEffect:getId())
                v:setTargetType(target)
                v:setAttrName(attrName)
                v:setValue(value)
                roleAttrsEffectArray:add(v)
            end
        end,
        roleId
    )

    print("roleGetUseActiveZhaoAttrsEffectMap:", roleAttrsEffectArray:getZhaoAttackAttrs())
    return roleAttrsEffectArray
end

--@desc:获取主动攻击中受击者身上影响双方属性的buff效果
--@author:Seven
--@time:2021-12-02 18:53:52
--@roleId: 攻击中受击方的id(即buff拥有者)
--@return [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
function BuffSystem:roleGetUnderActiveZhaoAttrsEffectMap(roleId)
    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
    local roleAttrsEffectArray = ZhaoAttackAttrsEffectArray:create()

    self:__walkActiveEffect(
        function(activeEffect)
            local ok, target, attrName, value = activeEffect:getUnderActiveZhaoAttrEffect()
            if ok then
                --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
                local v = ZhaoAttackAttrsEffect:create()
                v:setOwnerId(roleId)
                v:setEffectFuncId(activeEffect:getId())
                v:setTargetType(target)
                v:setAttrName(attrName)
                v:setValue(value)
                roleAttrsEffectArray:add(v)
            end
        end,
        roleId
    )

    print("roleGetUnderActiveZhaoAttrsEffectMap:", roleAttrsEffectArray:getZhaoAttackAttrs())
    return roleAttrsEffectArray
end

--[[
    @desc: 受击方闪避属性影响
    author:TangJian
    time:2021-12-20 19:27:52
    --@roleId: 
    @return:
]]
function BuffSystem:roleGetAutoDodgeAttrsEffectMap(roleId)
    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
    local roleAttrsEffectArray = ZhaoAttackAttrsEffectArray:create()

    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:getType() == FightBuffConstants.EffectType.TargetAutoDodgeEffectCurrAttr then
                local ok, target, attrName, value = activeEffect:getAutoDodgeAttrEffect()
                if ok then
                    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
                    local v = ZhaoAttackAttrsEffect:create()
                    v:setOwnerId(roleId)
                    v:setEffectFuncId(activeEffect:getId())
                    v:setTargetType(target)
                    v:setAttrName(attrName)
                    v:setValue(value)
                    roleAttrsEffectArray:add(v)
                end
            end
        end,
        roleId
    )

    print("roleGetAutoDodgeAttrsEffectMap:", roleAttrsEffectArray:getZhaoAttackAttrs())
    return roleAttrsEffectArray
end

--[[
    @desc: 受击方招架属性影响
    author:TangJian
    time:2021-12-20 19:28:08
    --@roleId: 
    @return: 
]]
function BuffSystem:roleGetAutoParryAttrsEffectMap(roleId)
    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
    local roleAttrsEffectArray = ZhaoAttackAttrsEffectArray:create()

    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:getType() == FightBuffConstants.EffectType.TargetAutoParryEffectCurrAttr then
                local ok, target, attrName, value = activeEffect:getAutoParryAttrEffect()
                if ok then
                    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
                    local v = ZhaoAttackAttrsEffect:create()
                    v:setOwnerId(roleId)
                    v:setEffectFuncId(activeEffect:getId())
                    v:setTargetType(target)
                    v:setAttrName(attrName)
                    v:setValue(value)
                    roleAttrsEffectArray:add(v)
                end
            end
        end,
        roleId
    )

    -- --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
    -- local v1 = ZhaoAttackAttrsEffect:create()
    -- v1:setOwnerId(roleId)
    -- v1:setEffectFuncId(52000)
    -- v1:setTargetType("atk")
    -- v1:setAttrName("neili")
    -- v1:setValue(100)
    -- roleAttrsEffectArray:add(v1)

    print("roleGetAutoParryAttrsEffectMap:", roleAttrsEffectArray:getZhaoAttackAttrs())
    return roleAttrsEffectArray
end

--@desc: 受击方招架属性影响，根据单次命中结果伤害值计算
--@author:Seven
--@time:2023-09-27 14:26:27
--@roleId: buff持有者
--@zhaoAttacks: 存放招式组合攻击相关的类
--@return:
function BuffSystem:roleGetAutoParryOnHitDamageAttrsEffectMap(roleId, zhaoAttacks)
    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
    local roleAttrsEffectArray = ZhaoAttackAttrsEffectArray:create()

    if MapIsEmpty(zhaoAttacks) then
        print("roleGetAutoParryOnHitDamageAttrsEffectMap:", roleAttrsEffectArray:getZhaoAttackAttrs())
        return roleAttrsEffectArray
    end

    local activeEffects = {}

    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:getType() == FightBuffConstants.EffectType.TargetAutoParryOnHitDamageEffectCurrAttr then
                table.insert(activeEffects, activeEffect)
            end
        end,
        roleId
    )

    if table.getn(activeEffects) > 0 then
        local totalQiDamage = 0

        for _, zhaoAttack in ipairs(zhaoAttacks) do
            local allDamagesByHit = zhaoAttack:getZhaoHitDamages()
            if table.getn(allDamagesByHit) > 0 then
                for _, damage in ipairs(allDamagesByHit) do
                    for _, attrDamage in ipairs(damage) do
                        if attrDamage:getAttrName() == "qi" then
                            local value = attrDamage:getHitNormalDamageValue()
                            totalQiDamage = totalQiDamage + value
                        end
                    end
                end
            end
        end
        for i, activeEffect in ipairs(activeEffects) do
            local ok, target, attrName, value = activeEffect:getAutoParryAttrEffect()
            if ok then
                --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
                local v = ZhaoAttackAttrsEffect:create()
                v:setOwnerId(roleId)
                v:setEffectFuncId(activeEffect:getId())
                v:setTargetType(target)
                v:setAttrName(attrName)

                local result = tonumber(string.format("%." .. tostring(0) .. "f", totalQiDamage * value))
                FightUtil:printLog("rAutoParryOnHitDamageAttrsEffect 效果id: ", activeEffect:getId(), " 当前被格挡的被动招式命中气血伤害总值 :", totalQiDamage, "效果系数：", value, "最终伤害值：", result)
                v:setValue(result)
                roleAttrsEffectArray:add(v)
            end
        end
    end

    print("roleGetAutoParryOnHitDamageAttrsEffectMap:", roleAttrsEffectArray:getZhaoAttackAttrs())
    return roleAttrsEffectArray
end

function BuffSystem:printInfo()
    local depth = -1
    for roleId, roleBuffArrayMap in pairs(self.__roleBuffArrayMap) do
        depth = depth + 1
        print(string.rep("  ", depth) .. roleId .. ":")
        for buffId, roleBuffArray in pairs(roleBuffArrayMap) do
            depth = depth + 1
            print(string.rep("  ", depth) .. buffId .. ":")
            for i, roleBuff in ipairs(roleBuffArray) do
                depth = depth + 1
                print(string.rep("  ", depth) .. tostring(i) .. ":" .. roleBuff:getName())
                depth = depth - 1
            end
            depth = depth - 1
        end
        depth = depth - 1
    end
end

function BuffSystem:release()
end

function BuffSystem:update(dt)
end

--[[
    @desc: 通过buffId移除所有满足要求的buff
    author:TangJian
    time:2022-12-02 16:27:08
    --@roleId:
	--@buffId: 
    @return:
]]
function BuffSystem:roleRemoveAllBuffByBuffId(roleId, buffId)
    -- 先移除需要移除的buff
    self:__walkActiveBuff(
        function(activeBuff, roleId, buffId, buffIndex)
            self:addNeedRemoveBuff(roleId, buffId, buffIndex)
        end,
        roleId
    )

    -- 尝试移除buff
    self:__removeBuff(roleId)
end

function BuffSystem:roleRemoveBuff(roleId, buffId, levelCount)
    self:addNeedRemoveBuffByLevelCount(roleId, buffId, levelCount)
    return self:__removeBuff(roleId)
end

function BuffSystem:__getRoleBuffArray(roleId, buffId)
    assert(roleId)
    assert(buffId)

    if type(buffId) == "number" then
        buffId = tostring(buffId)
    end

    local buffArrayMap = self:__getRoleBuffArrayMap(roleId)
    if buffArrayMap[buffId] == nil then
        buffArrayMap[buffId] = {}
    end
    return buffArrayMap[buffId]
end

function BuffSystem:__getRoleBuffArrayMap(roleId)
    if self.__roleBuffArrayMap[roleId] == nil then
        self.__roleBuffArrayMap[roleId] = {}
    end

    return self.__roleBuffArrayMap[roleId]
end

function BuffSystem:getRoleBuffIdArray(roleId)
    local buffArrayMap = self:__getRoleBuffArrayMap(roleId)
    local buffIdArray = {}

    for buffId, buffArray in pairs(buffArrayMap) do
        if table.getn(buffArray) > 0 then
            table.insert(buffIdArray, buffId)
        end
    end

    return buffIdArray
end

function BuffSystem:transferBuff(fromRoleId, toRoleId, buffId)
    local fromBuffArray = self:__getRoleBuffArray(fromRoleId, buffId)
    local toBuffArray = self:__getRoleBuffArray(toRoleId, buffId)

    LogSystem:logWithTab("增益日志：", "BuffSystem:transferBuff:", fromRoleId, toRoleId, buffId, fromBuffArray, toBuffArray, self:getBuff(buffId):getStackType())
    LogSystem:logWithTab(
        "增益日志：",
        "BuffSystem:transferBuff,数目，添加前:",
        #fromBuffArray,
        #toBuffArray,
        fromRoleId,
        toRoleId,
        self:getRoleBuffIconAndLevelArray(fromRoleId),
        self:getRoleBuffIconAndLevelArray(toRoleId)
    )

    if self:getBuff(buffId):getStackType() == 0 then
        for i = #toBuffArray, 1, -1 do
            local activeBuff = toBuffArray[i]
            table.remove(toBuffArray, i)
        end

        for i = table.getn(fromBuffArray), 1, -1 do
            local buff = fromBuffArray[i]
            table.insert(toBuffArray, buff)
            table.remove(fromBuffArray, i)
        end
    else
        for i = table.getn(fromBuffArray), 1, -1 do
            local buff = fromBuffArray[i]
            table.insert(toBuffArray, buff)
            table.remove(fromBuffArray, i)
        end
    end

    self:__updateRoleState(fromRoleId)
    self:__updateRoleState(toRoleId)

    LogSystem:logWithTab("增益日志：", "BuffSystem:transferBuff,添加完成:", fromBuffArray, toBuffArray)
    LogSystem:logWithTab(
        "增益日志：",
        "BuffSystem:transferBuff,数目:",
        #fromBuffArray,
        #toBuffArray,
        fromRoleId,
        toRoleId,
        self:getRoleBuffIconAndLevelArray(fromRoleId),
        self:getRoleBuffIconAndLevelArray(toRoleId)
    )
end

function BuffSystem:__walkActiveBuff(callback, roleId, buffId)
    assert(roleId)

    if type(buffId) == "number" then
        buffId = tostring(buffId)
    end

    if roleId then
        local roleBuffArrayMap = self.__roleBuffArrayMap[roleId]
        if roleBuffArrayMap then
            if buffId then
                local buffArray = roleBuffArrayMap[buffId]
                local willBreak = false
                for buffIndex, buff in ipairs(buffArray) do
                    willBreak = callback(buff, roleId, buffId, buffIndex)
                    if willBreak then
                        break
                    end
                end
            else
                local willBreak = false
                for buffId, buffArray in pairs(roleBuffArrayMap) do
                    for buffIndex, buff in ipairs(buffArray) do
                        willBreak = callback(buff, roleId, buffId, buffIndex)
                        if willBreak then
                            break
                        end
                    end
                    if willBreak then
                        break
                    end
                end
            end
        end
    else
        local willBreak = false
        for roleId, roleBuffArrayMap in pairs(self.__roleBuffArrayMap) do
            if buffId then
                local buffArray = roleBuffArrayMap[buffId]
                for buffIndex, buff in ipairs(buffArray) do
                    willBreak = callback(buff, roleId, buffId, buffIndex)
                    if willBreak then
                        break
                    end
                end
                if willBreak then
                    break
                end
            else
                local willBreak = false
                for buffId, buffArray in pairs(roleBuffArrayMap) do
                    for buffIndex, buff in ipairs(buffArray) do
                        willBreak = callback(buff, roleId, buffId, buffIndex)
                        if willBreak then
                            break
                        end
                    end
                    if willBreak then
                        break
                    end
                end
            end
        end
    end
end

function BuffSystem:__walkActiveEffect(callback, roleId, buffId)
    if type(buffId) == "number" then
        buffId = tostring(buffId)
    end

    self:__walkActiveBuff(
        function(roleBuff)
            for _, activeEffect in ipairs(roleBuff:getActiveEffects()) do
                local ret = callback(activeEffect)
                if ret then
                    return true
                end
            end
        end,
        roleId,
        buffId
    )
end

function BuffSystem:__removeActiveBuff(roleId, buffId, buffIndex)
    if type(buffId) == "number" then
        buffId = tostring(buffId)
    end

    print("移除buff", roleId, buffId, buffIndex)
    local roleActiveBuffArray = self:__getRoleBuffArray(roleId, buffId)
    local buff = roleActiveBuffArray[buffIndex]
    table.remove(roleActiveBuffArray, buffIndex)
    return buff
end

function BuffSystem:setTestBuffParamsArray(buffParamsArrayString)
    buffParamsArrayString = string.trim(buffParamsArrayString)
    if buffParamsArrayString == "" then
        self.__buffParamsArray = nil
        return
    end

    self.__buffParamsArray =
        table.map(
        string.split(buffParamsArrayString, "|"),
        function(str)
            return string.split(str, "#")
        end
    )
end

--[[
    @desc: 判断角色是否有护盾效果
    author:TangJian
    time:2021-12-18 16:29:38
    --@roleId: 
    @return:
]]
function BuffSystem:hasShield(roleId)
    local hasShield = false

    self:__walkActiveBuff(
        function(roleBuff)
            if roleBuff:hasShield() then
                hasShield = true
                return true
            end
        end,
        roleId
    )

    return hasShield
end

--[[
    @desc: 获取护盾值
    author:TangJian
    time:2021-12-18 16:27:14
    --@roleId: 
    @return:
]]
function BuffSystem:getShieldValue(roleId)
    local shieldValue = 0

    self:__walkActiveBuff(
        function(roleBuff)
            shieldValue = shieldValue + roleBuff:getShieldValue()
        end,
        roleId
    )

    return shieldValue
end

--[[
    @desc: 消耗护盾
    author:TangJian
    time:2021-12-18 16:27:09
    --@roleId:
	--@value: 
    @return:
]]
function BuffSystem:comsumeShieldValue(roleId, value)
    local remainValue = value

    self:__walkActiveBuff(
        function(roleBuff)
            if roleBuff:getShieldValue() >= remainValue then
                remainValue = remainValue - roleBuff:comsumeShieldValue(remainValue)
                assert(remainValue == 0, "护盾值异常" .. tostring(remainValue))
                return true
            else
                remainValue = remainValue - roleBuff:comsumeShieldValue(roleBuff:getShieldValue())
            end
        end,
        roleId
    )

    print(roleId, " 消耗护盾值:", value - remainValue)

    return value - remainValue
end

--[[
    @desc: 获得当前总承伤量
    author:TangJian
    time:2022-01-06 21:00:12
    --@roleId: 
    @return:
]]
function BuffSystem:getSufferDamge(roleId)
    local sufferDamage = 0

    self:__walkActiveBuff(
        function(roleBuff)
            sufferDamage = sufferDamage + roleBuff:getSufferDamage()
        end,
        roleId
    )

    return sufferDamage
end

--[[
    @desc: 消耗承伤量
    author:TangJian
    time:2022-01-05 18:20:40
    --@roleId:
	--@value: 
    @return:
]]
function BuffSystem:comsumeSufferDamge(roleId, value)
    local remainValue = value

    self:__walkActiveBuff(
        function(roleBuff)
            if remainValue > 0 then
                remainValue = remainValue - roleBuff:comsumeSufferDamge(value)
            end
        end,
        roleId
    )

    print("消耗承伤量:", value - remainValue)

    return value - remainValue
end

--[[
    @desc: 获取伤害减免值表
    author:TangJian
    time:2022-01-07 21:37:02
    --@roleId: 
    @return:{id=value}
]]
function BuffSystem:getDamageReductionValueMap(roleId)
    local retMap = {}

    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:getType() == FightBuffConstants.EffectType.SpecialAttrValueFix then
                local specialId, value = activeEffect:getFixValue()
                if retMap[specialId] == nil then
                    retMap[specialId] = value
                else
                    retMap[specialId] = retMap[specialId] + value
                end
            end
        end,
        roleId
    )

    return retMap
end

-- 判断是否有真伤效果
function BuffSystem:hasRealDamage(roleId)
    local hasRealDamage = false

    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:getType() == FightBuffConstants.EffectType.RealDamage then
                hasRealDamage = true
                return true
            end
        end,
        roleId
    )

    return hasRealDamage
end

--[[
    @desc: 获得禁用功能数组
    author:TangJian
    time:2022-01-13 15:06:04
    --@roleId: 角色ID
    @return: {{disableFunctionName = disableFunctionName, effectId = effectId}}
]]
function BuffSystem:getDisableFunctionArray(roleId)
    local disableFunctionArray = {}
    local lookupMap = {}

    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:getType() == FightBuffConstants.EffectType.DisableFunction then
                local disableFunctionArray_ = activeEffect:getDisableFunctionArray()
                for _, disableFunction in ipairs(disableFunctionArray_) do
                    if lookupMap[disableFunction] == nil then
                        lookupMap[disableFunction] = true
                        table.insert(disableFunctionArray, {disableFunctionName = disableFunction, effectId = activeEffect:getId()})
                    end
                end
            end
        end,
        roleId
    )

    return disableFunctionArray
end

function BuffSystem:getExtraAutoSkillBuffAdderParamsArray(roleId)
    local extraAutoSkillBuffAdderIdArray = {}
    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:getType() == FightBuffConstants.EffectType.ExtraAutoSkillBuffAdder then
                local buffAdderId = activeEffect:getBuffAdderId()
                local buffAdderParams = activeEffect:getBuffAddParams()
                table.insert(extraAutoSkillBuffAdderIdArray, {buffAdderId = buffAdderId, buffAdderParams = buffAdderParams})
            end
        end,
        roleId
    )
    return extraAutoSkillBuffAdderIdArray
end

--[[
    @desc: 必然闪躲被动攻击
    author:TangJian
    time:2022-11-16 15:05:41
    --@roleId: 
    @return: 
]]
function BuffSystem:dodgeAutoSkillNecessarily(roleId)
    local isAvailable = false
    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:getType() == FightBuffConstants.EffectType.AutoSkillDodge then
                isAvailable = true
                return true
            end
        end,
        roleId
    )
    print("dodgeAutoSkillNecessarily:", isAvailable)
    return isAvailable
end

--[[
    @desc: 必然招架被动攻击
    author:TangJian
    time:2022-11-16 15:05:44
    --@roleId: 
    @return: 
]]
function BuffSystem:parrayAutoSkillNecessarily(roleId)
    local isAvailable = false
    self:__walkActiveEffect(
        function(activeEffect)
            if activeEffect:getType() == FightBuffConstants.EffectType.AutoSkillParry then
                isAvailable = true
                return true
            end
        end,
        roleId
    )
    print("parrayAutoSkillNecessarily:", isAvailable)
    return isAvailable
end

-- 更新增益效果
function BuffSystem:updateBuffEffect(roleId, effectUpdateNodeType)
    self:__walkActiveBuff(
        function(roleBuff)
            if table.contains(roleBuff:getEffectUpdataNode(), effectUpdateNodeType) then
                roleBuff:refreshAllEffect()
            end
        end,
        roleId
    )
    -- 再刷新一下角色状态
    self:__updateRoleState(roleId)
end

return class("BuffSystem", {AFightSystem}, BuffSystem)
000
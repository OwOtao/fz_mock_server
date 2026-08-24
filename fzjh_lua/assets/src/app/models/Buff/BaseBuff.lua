local BaseBuff = class("BaseBuff")

function BaseBuff:create(luaData, manager)
    local p = BaseBuff:new()
    p:init(luaData, manager)
    return p
end

function BaseBuff:ctor()
    -- self.layers = 0
    -- self.name = "BaseBuff"
    -- self.role = nil
    -- --@RefType[BuffManager]
    -- self.buffManager = nil
    -- self.count = 0
    -- self.eventFunc = {}
    -- self.conditions = {}
    -- self.effects = {}
    -- --@desc 触发后是否失效
    -- self.unActiveAfterTrigger = false
    -- --@desc buff添加后是否需要立刻判断能否触发一次
    -- self.onAddTrigger = false
end

function BaseBuff:init(luaData, manager)
    self.luaData = luaData

    --@RefType[BuffManager]
    self.buffManager = manager

    self.id = self.luaData.id

    self.state = false

    --@desc 当前生效层数
    self.layers = 0

    --@desc 已经添加层数
    self.addLayers = 0

    self.name = "BaseBuff"

    self.role = nil

    self.count = 0

    self.eventFunc = {}

    self.conditions = {}

    self.effects = {}

    --@desc 是否限计时buff
    self.timed = false

    self.addTime = 0

    --@desc 触发后是否失效
    self.unActiveAfterTrigger = false

    --@desc buff添加后是否需要立刻判断能否触发一次
    self.onAddTrigger = false

    self:initActiveTime()
    self:initActiveType()
    self:initUnActiveTime()
    self:initConditions()
    self:initEffects()

    self:onInit()
end

function BaseBuff:onInit()
end

function BaseBuff:initActiveTime()
    local activeTimesList = string.split(self.luaData.activeTime, ";")
    for i = 1, #activeTimesList do
        local activeTime = tonumber(activeTimesList[i])
        if activeTime ~= nil and activeTime > 0 then
            local eventName

            local triggerFunc = function(context)
                --@desc 已处于生效状态，无需重复触发
                if self:getState() == true then
                    print("buff : " .. self:getId() .. " 已处于生效状态，无法再次触发。")
                    return false
                end

                if self.luaData.probability ~= nil and self.luaData.probability > 0 then
                    local rate = math.random(1, 100)

                    if self.luaData.probability < rate then
                        return false
                    end
                end

                if self:checkCondition(context) == false then
                    return false
                end

                self:trigger(context)
            end

            if activeTime == 1 then
                self.onAddTrigger = true
            elseif activeTime == 2 then
                eventName = "FightStartEvent"
                self:addListener(
                    eventName,
                    function(event)
                        local context = {
                            role = event.player,
                            target = event.target,
                            fightType = event.fightType,
                            map = event.map,
                            layers = self.layers
                        }

                        triggerFunc(context)
                    end
                )
            elseif activeTime == 3 then
                eventName = "FightEndEvent"
                self:addListener(
                    eventName,
                    function(event)
                        local context = {
                            role = event.player,
                            target = event.target,
                            fightType = event.fightType,
                            fightResult = event.fightResult,
                            map = event.map,
                            layers = self.layers
                        }

                        triggerFunc(context)
                    end
                )
            elseif activeTime == 4 then
                eventName = "FinishDrBossTaskEvent"
                self:addListener(
                    eventName,
                    function(event)
                        local context = {
                            role = self.role,
                            layers = self.layers
                        }
                        triggerFunc(context)
                    end
                )
            elseif activeTime == 5 then
                eventName = "FloorCompleteEvent"
                self:addListener(
                    eventName,
                    function(event)
                        local context = {
                            role = self.role,
                            layers = self.layers
                        }
                        triggerFunc(context)
                    end
                )
            elseif activeTime == 6 then
                eventName = "AttrChangeAfterEvent"
                self:addListener(
                    eventName,
                    function(event)
                        local context = {
                            role = self.role,
                            attrName = event.attrName,
                            layers = self.layers
                        }
                        triggerFunc(context)
                    end
                )
            elseif activeTime == 7 then
                eventName = "FightAttrChangeAfterEvent"
                self:addListener(
                    eventName,
                    function(event)
                        local context = {
                            role = self.role,
                            attrName = event.attrName,
                            layers = self.layers
                        }
                        triggerFunc(context)
                    end
                )
            elseif activeTime == 8 then
                eventName = "PlayActiveZhaoEvent"
                self:addListener(
                    eventName,
                    function(event)
                        local context = {
                            role = event.role,
                            target = event.target,
                            activeZhao = event.activeZhao,
                            layers = self.layers
                        }
                        triggerFunc(context)
                    end
                )
            elseif activeTime == 9 then
                eventName = "EmotionChangeEvent"
                self:addListener(
                    eventName,
                    function(event)
                        local context = {
                            role = self.role,
                            currEmotionType = event.newEmotionType,
                            newEmotionType = event.newEmotionType,
                            oldEmotionType = event.oldEmotionType,
                            layers = self.layers
                        }
                        triggerFunc(context)
                    end
                )
            end
        end
    end
end

function BaseBuff:initUnActiveTime()
    local unActiveTimes = string.split(self.luaData.unActiveTime, ";")

    for i = 1, #unActiveTimes do
        local unActiveTime = tonumber(unActiveTimes[i])
        if unActiveTime ~= nil and unActiveTime > 0 then
            local eventName
            if unActiveTime == 1 then
                self.unActiveAfterTrigger = true
            elseif unActiveTime == 2 then
                eventName = "AttrChangeAfterEvent"
                self:addListener(
                    eventName,
                    function(event)
                        --@desc
                        if self:getState() == false then
                            return
                        end
                        local context = {
                            role = self.role,
                            attrName = event.attrName
                        }

                        --@desc 直接改变状态为失效
                        if self:checkCondition(context) == false then
                            print("Because AttrChangeAfterEvent , buff unActivate : ", self:getId())
                            self.state = false
                        end
                    end
                )
            elseif unActiveTime == 3 then
                eventName = "FightEndEvent"
                self:addListener(
                    eventName,
                    function(event)
                        print("Because fight end, buff unActivate : ", self:getId())
                        self.state = false
                    end
                )
            elseif unActiveTime == 4 then
                eventName = "FightAttrChangeAfterEvent"
                self:addListener(
                    eventName,
                    function(event)
                        --@desc
                        if self:getState() == false then
                            return
                        end
                        local context = {
                            role = self.role,
                            attrName = event.attrName,
                            layers = self.layers
                        }
                        --@desc 直接改变状态为失效
                        if self:checkCondition(context) == false then
                            print("Because FightAttrChangeAfterEvent , buff unActivate : ", self:getId())
                            self.state = false
                        end
                    end
                )
            elseif unActiveTime == 5 then
                eventName = "EmotionChangeEvent"
                self:addListener(
                    eventName,
                    function(event)
                        --@desc
                        if self:getState() == false then
                            return
                        end

                        local context = {
                            role = self.role,
                            currEmotionType = event.newEmotionType,
                            newEmotionType = event.newEmotionType,
                            oldEmotionType = event.oldEmotionType,
                            layers = self.layers
                        }

                        --@desc 直接改变状态为失效
                        if self:checkCondition(context) == false then
                            print("Because EmotionChangeEvent , buff unActivate : ", self:getId())
                            self.state = false
                        end
                    end
                )
            end
        end
    end
end

function BaseBuff:initActiveType()
    if self.luaData.activeType == 1 then
        self:addListener(
            "FightEndEvent",
            function(event)
                if self.count >= self.luaData.duration then
                    self.buffManager:removeBuff(self:getId())
                end
            end
        )
    elseif self.luaData.activeType == 2 then
        self.timed = true
    end
end

function BaseBuff:initConditions()
    for i = 1, 3 do
        local cType = self.luaData["cType" .. i]

        if cType ~= 0 then
            local args = {
                arg1 = self.luaData["cArg1_" .. i],
                arg2 = self.luaData["cArg2_" .. i],
                arg3 = self.luaData["cArg3_" .. i]
            }

            local condition
            local path = "app.models.Buff.Conditions."
            if cType == 1 then
                path = path .. "FightFinishCondition"
            elseif cType == 2 then
                path = path .. "RoleAttrCondition"
            elseif cType == 3 then
                path = path .. "PrepareWeaponCondition"
            elseif cType == 4 then
                path = path .. "TargetPrepareWeaponCondition"
            elseif cType == 5 then
                path = path .. "MapAttrConditon"
            elseif cType == 6 then
                path = path .. "RoleEmotionCondition"
            end

            condition = require(path):create()

            condition:setBuff(self)

            for j = 1, 3 do
                condition:setArgs("arg" .. j, args["arg" .. j])
            end

            table.insert(self.conditions, condition)
        end
    end
end

function BaseBuff:initEffects()
    local i = 1
    while true do
        local effectType = self.luaData["effectType" .. i]

        if effectType == nil or effectType == 0 then
            break
        end

        local effect
        --@RefType[BaseBuffEffect]
        effect =
            switch(
            effectType,
            {
                [1] = function()
                    return require("app.models.Buff.Effects.AttrBuffEffect"):create()
                end,
                [2] = function()
                    return require("app.models.Buff.Effects.AttrValueBuffEffect"):create()
                end,
                [3] = function()
                    return require("app.models.Buff.Effects.AddItemEffect"):create()
                end,
                [4] = function()
                    return require("app.models.Buff.Effects.ItemRandomEffect"):create()
                end,
                default = function()
                    error("buff 效果类型未定义 " .. effectType .. "  buff id : " .. self.id)
                end
            }
        )

        effect:setId(tostring(self.id) .. "_" .. tostring(i))
        effect:setBuff(self)
        effect:setValueType(self.luaData["valueType" .. i])
        effect:setValue(self.luaData["value" .. i])
        effect:setisMutiply(self.luaData["isMutiply" .. i])
        effect:setAttrType(self.luaData["attrType" .. i])

        table.insert(self.effects, effect)

        i = i + 1
    end
end

function BaseBuff:setRole(role)
    self.role = role
end

function BaseBuff:getRole()
    return self.role
end

function BaseBuff:getId()
    return self.id
end

function BaseBuff:addListener(eventName, listener)
    if self.eventFunc[eventName] == nil then
        self.eventFunc[eventName] = {}
    end

    table.insert(self.eventFunc[eventName], listener)

    self.buffManager:subscribe(eventName, self)
end

function BaseBuff:setManager(manager)
    self.buffManager = manager
end

function BaseBuff:getLayers()
    return self.layers
end

function BaseBuff:getTriggerCount()
    return self.count
end

--@desc: 运行状态
--@author:Seven_L
--@time:2020-07-30 14:10:52
--@return true|false
function BaseBuff:getState()
    return self.state
end

function BaseBuff:add()
    --@desc 已添加层数每次都要加1
    self.addLayers = self.addLayers + 1

    if self.luaData.layers > 0 then
        if self.layers < self.luaData.layers then
            self.layers = self.layers + 1
            if self:isTimed() then
                self.addTime = GetTime()
            end
            self:onAdd()
        else
            print("该buff" .. self:getId() .. "已叠加至最高层数，无法叠加")
            return
        end
    else
        self.layers = self.layers + 1
        if self:isTimed() then
            self.addTime = GetTime()
        end
        self:onAdd()
    end

    if self.onAddTrigger then
        --@desc 直接触发
        if self.luaData.probability ~= nil and self.luaData.probability > 0 then
            local rate = math.random(1, 100)

            if self.luaData.probability < rate then
                return false
            end
        end

        local context = {
            event = nil,
            role = self.role,
            layers = self.layers
        }

        if self:checkCondition(context) == false then
            return false
        end

        self:trigger(context)
    end
end

function BaseBuff:onAdd()
end

local EventName = {}

function BaseBuff:receive(eventName, event)
    if self.eventFunc[eventName] ~= nil and #self.eventFunc[eventName] > 0 then
        for i = 1, #self.eventFunc[eventName] do
            local eventFunc = self.eventFunc[eventName][i]
            eventFunc(event)
        end
    end
end

function BaseBuff:checkCondition(context)
    for i = 1, #self.conditions do
        local condition = self.conditions[i]
        if condition:check(context) == false then
            return false
        end
    end

    if self:onCheck(context) then
        return true
    else
        return false
    end

    return true
end

function BaseBuff:onCheck(context)
    return true
end

function BaseBuff:trigger(context)
    if MapIsEmpty(self.effects) == false then
        for i, effect in ipairs(self.effects) do
            effect:trigger(context)
        end
    end
    self:onTrigger()

    self:showBuffTips()

    --@desc 触发
    self.state = true
    self.count = self.count + 1

    if self.unActiveAfterTrigger == true then
        self.state = false
    end
end

function BaseBuff:onTrigger()
end

function BaseBuff:getEffectValue(attrName)
    local value = 0
    if self.state ~= true then
        return value
    end

    if self.effects ~= nil and #self.effects > 0 then
        for i = 1, #self.effects do
            local effect = self.effects[i]

            local effectValue = effect:getEffectValue()

            if effectValue[attrName] ~= nil then
                value = value + effectValue[attrName] * self.layers
            end
        end
    end

    return value
end

function BaseBuff:isTimed()
    return self.timed
end

function BaseBuff:update()
    local nowTime = GetTime()

    if self.addTime <= 0 then
        return
    end

    -- print("buff " .. self:getId() .. " intervalTime : " .. nowTime - self.addTime, self.luaData.duration)

    --@desc 该时效性buff时间到时直接销毁，不管拥有几层。
    if nowTime - self.addTime >= self.luaData.duration then
        -- print("buff " .. self:getId() .. " is time end : " .. nowTime - self.addTime, self.luaData.duration)
        self.buffManager:destoryBuff(self)
    end
end

function BaseBuff:getBuffEndTime()
    if self.addTime <= 0 then
        return 0
    end

    return math.max(self.luaData.duration - (GetTime() - self.addTime),0)
end

--@desc: 移除
--@author:Seven_L
--@time:2020-07-30 14:12:55
function BaseBuff:remove()
    self.addLayers = math.max(self.addLayers - 1, 0)

    if self.layers > self.addLayers then
        self.layers = math.max(self.layers - 1, 0)
    end

    self:onRemove()
end

function BaseBuff:onRemove()
end

--@desc: 销毁
--@author:Seven_L
--@time:2020-07-30 14:12:47
function BaseBuff:destory()
    self:onDestory()
end

function BaseBuff:onDestory()
end

--@desc: 序列化
--@author:Seven_L
--@time:2020-07-30 10:42:02
function BaseBuff:serialization()
    local serialzationAttr = {
        "id",
        "layers",
        "count",
        "state",
        "addLayers"
    }

    local serialObject = {}
    for i, v in ipairs(serialzationAttr) do
        serialObject[v] = self[v]
    end

    if self:isTimed() then
        serialObject.timed = self.timed
        serialObject.addTime = self.addTime
    end

    self:onSerialization(serialObject)

    return serialObject
end

function BaseBuff:onSerialization(serialObject)
end

--@desc: 反序列化
--@author:Seven_L
--@time:2020-07-30 10:42:13
function BaseBuff:deserialization(data)
    for k, v in pairs(data) do
        if k ~= "id" then
            self[k] = v
        end
    end

    if self.state ~= true then
        return
    end

    --@desc 如果处于运行状态，需生成增益效果
    if self.effects ~= nil and #self.effects > 0 then
        for i = 1, #self.effects do
            --@RefType[BaseBuffEffect]
            local effect = self.effects[i]
            if effect.effectType == 1 then
                effect:trigger({role = self.role})
            end
        end
    end
end

function BaseBuff:getStatusInfo()
    return tostring(self.layers) .. "|" .. tostring(self.count) .. "|" .. tostring(self.state)
end

function BaseBuff:showBuffTips()
    if self.luaData.effecttext1 ~= 0 and self.luaData.effecttext1 ~= nil then
        PopText(self.luaData.effecttext1)
    end

    if self.luaData.effecttext2 ~= 0 and self.luaData.effecttext2 ~= nil then
        RichPrint("main", self.luaData.effecttext2)
    end
end

function BaseBuff:printInfo()
    print("------------------------------buff-------------------------------")
    print("【id】 : " .. self.id)
    print("【状态】 : " .. tostring(self.state))
    print("【buff时效类型】 : " .. self.luaData.activeType)
    print("【buff持续时间】 : " .. self.luaData.duration)
    print("【效果生效时机】 : " .. self.luaData.activeTime)
    print("【效果失效效时机】 : " .. self.luaData.unActiveTime)
    print("【layers】 : " .. self.layers)
    print("【add layers】 : " .. self.addLayers)

    if self:isTimed() then
        print("【buff 添加时间】:" .. self.addTime)
        print("【buff 已持续时间（秒）】:" .. GetTime() - self.addTime)
    end

    if self.effects ~= nil and #self.effects > 0 then
        for i = 1, #self.effects do
            local effect = self.effects[i]

            local effectValue = effect:getEffectValue()

            for attrName, v in pairs(effectValue) do
                local value = v * self.layers
                print("【属性名" .. i .. " attrName】 : " .. attrName)
                print("【加成值" .. i .. " value 】 : " .. value)
            end
        end
    end

    print("【额外信息】 : " )
    self:onPrintInfo()
    print("-----------------------------------------------------------------\n")
end

function BaseBuff:onPrintInfo()
    print("     【无】")
end

return BaseBuff
00000000
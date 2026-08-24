
local BaseBuff = require("app.models.Buff.BaseBuff")
--@SuperType [BaseBuff]
local DrFloorTriggerBuff = class("DrFloorTriggerBuff", BaseBuff)

function DrFloorTriggerBuff:create(luaData, manager)
    local p = DrFloorTriggerBuff:new()
    p:init(luaData, manager)
    return p
end

function DrFloorTriggerBuff:onInit()
    self.name = "DrFloorTriggerBuff"

    self.effectValue = {}

    self.conditions = {}

    self:addListener(
        "FloorCompleteEvent",
        function(event)
            if self.luaData.probability ~= nil and self.luaData.probability > 0 then
                local rate = math.random(1, 100)

                if self.luaData.probability < rate then
                    return false
                end
            end

            local context = {
                role = self.role,
                layers = self.layers
            }

            self:trigger(context)
        end,
        self
    )
end

--@desc buff添加时
function DrFloorTriggerBuff:onAdd()
    self.state = true
end

function DrFloorTriggerBuff:trigger(context)
    self.count = self.count + 1
    if MapIsEmpty(self.effects) == false then
        for i = 1, #self.effects do
            local effect = self.effects[i]
            effect:trigger(context)
            local effectValues = effect:getEffectValue()

            for attrName, attrValue in pairs(effectValues) do
                if self.effectValue[attrName] == nil then
                    self.effectValue[attrName] = 0
                end

                print("DrFloorTriggerBuff 增加属性：", User:getRole():getCHAttrName(attrName), "值：" .. attrValue * self.layers)

                self.effectValue[attrName] = self.effectValue[attrName] + attrValue * self.layers
            end
        end

        self:showBuffTips()
    end
end

--@desc buff移除时
function DrFloorTriggerBuff:onRemove()
    if MapIsEmpty(self.effects) == false then
        for i = 1, #self.effects do
            local effect = self.effects[i]
            local effectValues = effect:getEffectValue()
            for attrName, attrValue in pairs(effectValues) do
                if self.effectValue[attrName] ~= nil then
                    self.effectValue[attrName] = self.effectValue[attrName] - attrValue
                end
                print("DrFloorTriggerBuff 移除buff：", User:getRole():getCHAttrName(attrName), "值：-" .. attrValue)
            end
        end
    end
end

function DrFloorTriggerBuff:getEffectValue(attrName)
    local value = 0
    if self.state == false then
        return value
    else
        value = Helper:getDef(self.effectValue[attrName], 0)
        return value
    end
end

function DrFloorTriggerBuff:onSerialization(serialObject)
    serialObject.effectValue = self.effectValue
end

function DrFloorTriggerBuff:printInfo()
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

    if MapIsEmpty(self.effectValue) == false then
        local i = 1
        for attrName, attrValue in pairs(self.effectValue) do
            print("【属性名" .. i .. " attrName】 : " .. attrName)
            print("【加成值" .. i .. " value 】 : " .. attrValue)
            i = i + 1
        end
    end
    print("-----------------------------------------------------------------\n")
end

return DrFloorTriggerBuff
0
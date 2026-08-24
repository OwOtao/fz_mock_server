
local BaseBuff = require("app.models.Buff.BaseBuff")
--@SuperType [BaseBuff]
local DrFloorBuff = class("DrFloorBuff", BaseBuff)

function DrFloorBuff:create(luaData,manager)
    local p = DrFloorBuff:new()
    p:init(luaData,manager)
    return p
end


function DrFloorBuff:onInit()
    self.name = "DrFloorBuff"

    self.effectValue = {}

    self.conditions = {}

    if self.luaData.scriptArgs == nil or self.luaData.scriptArgs == "" then
        assert(false, "buff id : " .. self:getId() .. "的脚本参数填写错误！！！")
    end

    local args = string.split(self.luaData.scriptArgs, ";")

    self.floorNum = tonumber(args[1])

    local i = 2
    while true do
        if args[i] == nil or args[i] == "" then
            break
        end

        if tonumber(args[i]) == nil then
            error(false, "buff id : " .. self:getId() .. "脚本参数填写错误")
        end

        self["effectValueMax" .. i] = tonumber(args[i])
        i  = i + 1
    end

    self:addListener(
        "FloorCompleteEvent",
        function(event)
            local role = event.map:getPlayer()

            local currFloor = role.dreamWorld.cFloor

            if currFloor % self.floorNum == 0 then
                self:trigger({role = role})
                self.state = true
            end
        end,
        self
    )
end

--@desc buff添加时
function DrFloorBuff:onAdd()
    local role = self:getRole()

    local currfloor = role.dreamWorld.cFloor

    local loopCount = select(1, math.modf((currfloor-1) / self.floorNum))

    if loopCount > 0 then
        for i = 1, loopCount do
            self:trigger({role = role})
        end
        self.state = true
    end
end

function DrFloorBuff:trigger(context)
    local role = context.role
    for i = 1, #self.effects do
        local index = i + 1
        local effect = self.effects[i]
        effect:trigger({role = role})

        local effectValue = effect:getEffectValue()

        if MapIsEmpty(effectValue) == false then
            local maxValue = self["effectValueMax" .. index]
            for k, v in pairs(effectValue) do
                if self.effectValue[k] == nil then
                    self.effectValue[k] = 0
                end

                if self.effectValue[k] ~= maxValue then
                    self.effectValue[k] = self.effectValue[k] + v
                    if maxValue ~= nil and maxValue > 0 and self.effectValue[k] > maxValue then
                        self.effectValue[k] = maxValue
                    end
                end
            end

            self:showBuffTips()
        end
    end

    self.count = self.count + 1
end

--@desc buff移除时
function DrFloorBuff:onRemove()
end

function DrFloorBuff:getEffectValue(attrName)
    local value = 0
    if self.state == false then
        return value
    else
        local value = Helper:getDef(self.effectValue[attrName], 0) * self.layers
        return value
    end
end

function DrFloorBuff:onSerialization(serialObject)
    serialObject.effectValue = self.effectValue
end

function DrFloorBuff:onPrintInfo()
    print("【楼层buff 触发次数】 : " .. self.count)
end

return DrFloorBuff
00000000
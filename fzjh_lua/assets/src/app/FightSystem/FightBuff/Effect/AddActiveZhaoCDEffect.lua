-- 效果类型=12 影响当前主动招式剩余CD，修改后：
-- 效果功能：被添加Buff的角色，所有使用中主动招式符合指定条件主动招式，当前剩余CD时间同时增加或者减少N秒。
-- effectTypeParam配置指定的主动招式类型，配置格式：影响主动类型#参数@参数#主动冷却上限类型#上限类型参数。影响主动类型与对应参数有：
-- all = 影响任意主动，参数固定填0
-- class = 按类型影响，参数填1(攻击)或者2(释放)，对应主动的招式类型（表[武功主动招式组合].activeType），参数可填多个用@间隔，符合参数配置都受影响。
-- skill = 按指定主动ID影响，参数填主动招式ID（表[武功主动招式组合].activeId），可填多个用@间隔，符合参数配置都受影响。
-- used = 影响任意主动招式剩余冷却CD>0的主动，参数固定填0
-- 主动冷却上限类型与上限类型参数：
-- cd = 以主动招式自身的默认冷却时间作为主动冷却上限， 参数固定填0
-- num = 配置具体值作为主动冷却上限， 参数配置数值
-- fm = 配置总Buff表效果伤害ID，伤害ID公式返回值为主动冷却上限
local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local FightCommons = require("app.FightSystem.FightCommons")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")
local Constants = require("app.FightSystem.FightBuff.Constants")

local AddActiveZhaoCDEffect = {}

function AddActiveZhaoCDEffect:create(effect, buffNeeded)
    local p = AddActiveZhaoCDEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function AddActiveZhaoCDEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function AddActiveZhaoCDEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    local effectTypeParams = self.__effect:getEffectTypeParam()

    self.__addActiveZhaoCDType = effectTypeParams[1]

    self.__addActiveZhaoCDIds = string.split(effectTypeParams[2], "@")

    self.__coolTimeLimitType = effectTypeParams[3]

    self.__coolTimeLimitValue = effectTypeParams[4]

    local damageId = self.__effect:getArgsParam()[1]
    self.__value = self.__effect:getDamage(damageId, self.__buffNeeded)

    assert(type(self.__value) == "number", "AddActiveZhaoCDEffect:__init() error, value is invalid" .. tostring(self.__value))
    assert(table.contains({"all", "class", "skill", "used"}, self.__addActiveZhaoCDType), "AddActiveZhaoCDEffect:__init() error, addActiveZhaoCDType is invalid" .. tostring(self.__addActiveZhaoCDType))

    BuffSystemUtil:log("招式CD影响：", self.__addActiveZhaoCDType, self.__value)
end

function AddActiveZhaoCDEffect:getAddActiveZhaoCDType()
    return self.__addActiveZhaoCDType
end

function AddActiveZhaoCDEffect:getAddActiveZhaoValue()
    return self.__value
end

function AddActiveZhaoCDEffect:getAddActiveZhaoCDIds()
    return self.__addActiveZhaoCDIds
end

function AddActiveZhaoCDEffect:getAddActiveZhaoCDLimit(defaultCD)
    local limitValue = defaultCD

    if self.__coolTimeLimitType == "num" then
        limitValue = tonumber(self.__coolTimeLimitValue)
    elseif self.__coolTimeLimitType == "fm" then
        limitValue = self.__effect:getDamage(self.__coolTimeLimitValue, self.__buffNeeded)
    end

    return limitValue
end

function AddActiveZhaoCDEffect:tryTrigger(eventType, eventParams)
    if eventType == Constants.BuffTriggerType.Add then
        return true
    end
    return false
end

return class("AddActiveZhaoCDEffect", {ActiveEffect}, AddActiveZhaoCDEffect)
000000000
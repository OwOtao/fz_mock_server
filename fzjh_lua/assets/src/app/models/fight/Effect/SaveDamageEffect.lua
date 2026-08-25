local newClass = require("third.class.NewClass")

local BaseEffect = require("app.models.fight.Effect.BaseEffect")

local SaveDamageEffect = {
    __basePercent = 0,

    __isActiveHurt = false,
    
    __activePercent = 0,

    __isAutoHurt= false,

    __autoPercent = 0,
}

function SaveDamageEffect:create(effect)
    local p = SaveDamageEffect.new()
    p:init(effect)
    return p
end

function SaveDamageEffect:ctor()
end

function SaveDamageEffect:init(effect)    
    self:setId(effect:getId())

    self:__initEffect(effect)
end

--@desc: 初始化储伤效果
--@author:LvBin
--@time:2023-03-09 15:45:18
--@return
function SaveDamageEffect:__initEffect(effect)
    local arg1 = effect:getFinalArg1()
    
    local arg2 = effect:getArg2()

    local isActive,activePercent

    local isAuto,autoPercent

    local strList = string.split(arg2, "|")

    for i,v in ipairs(strList) do

        local saveList = string.split(v, "#")

        if saveList[1] == "activeHurt" then
            isActive = true

            activePercent = tonumber(saveList[2])
        elseif saveList[1] == "autoHurt" then
            isAuto = true

            autoPercent = tonumber(saveList[2])
        end
    end

    self.__basePercent = arg1

    self.__isActiveHurt = isActive

    self.__activePercent = activePercent

    self.__isAutoHurt = isAuto

    self.__autoPercent = autoPercent
end

--@desc: 添加主动伤害类型储伤值
--@author:LvBin
--@time:2023-03-09 16:41:33
--@value: 伤害值
--@return
function SaveDamageEffect:__addActiveHurtSaveDamageValue(value)
    value = value * self.__activePercent * self.__basePercent

    value = math.abs(value)

    self:getPlayer():addAttr("saveDamage", value, 0, self:getPlayer():getSaveDamageMax())
end

--@desc: 添加被动伤害类型储伤值
--@author:LvBin
--@time:2023-03-09 16:41:33
--@value: 伤害值
--@return
function SaveDamageEffect:__addAutoHurtSaveDamageValue(value)
    value = value * self.__autoPercent * self.__basePercent

    value = math.abs(value)

    self:getPlayer():addAttr("saveDamage", value, 0, self:getPlayer():getSaveDamageMax())
end

--@desc: 是否有主动伤害类型储伤
--@author:LvBin
--@time:2023-03-09 16:45:58
--@return
function SaveDamageEffect:isActiveHurtSaveDamage()
    return self.__isActiveHurt
end

--@desc: 是否有被动伤害类型储伤
--@author:LvBin
--@time:2023-03-09 16:45:58
--@return
function SaveDamageEffect:isAutoHurtSaveDamage()
    return self.__isAutoHurt
end

--@desc: 是否触发
--@author:LvBin
--@time:2026-07-14 16:44:36
--@hurt: [src.app.models.fight.Hurt.BaseHurt#BaseHurt]
--@return
function SaveDamageEffect:isTrigger(hurt)
	if hurt:isAutoHurt() and self:isAutoHurtSaveDamage() then
		return true
    elseif hurt:isActiveHurt() and self:isActiveHurtSaveDamage() then
		return true
	end
	return false
end  

--@desc: 触发
--@author:LvBin
--@time:2026-07-14 17:02:14
--@hurt: [src.app.models.fight.Hurt.BaseHurt#BaseHurt]
--@return
function SaveDamageEffect:trigger(hurt)
	if hurt:isAutoHurt() then
		self:__addAutoHurtSaveDamageValue(hurt:getValue())
    elseif hurt:isActiveHurt() then
		self:__addActiveHurtSaveDamageValue(hurt:getValue())
	end
end

--@desc: 是否生效
--@author:LvBin
--@time:2023-03-10 16:31:32
--@return
function SaveDamageEffect:isTakeEffect()
    for k, effect in pairs(self:getPlayer():getEffectMap()) do
        if effect:getType() == "储伤失效" then
            return false
        end
    end

    return true
end

return newClass("SaveDamageEffect", {BaseEffect}, SaveDamageEffect)
0
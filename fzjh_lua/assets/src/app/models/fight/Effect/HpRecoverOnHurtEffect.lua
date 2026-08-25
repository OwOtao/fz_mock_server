local newClass = require("third.class.NewClass")

local BaseEffect = require("app.models.fight.Effect.BaseEffect")

local FightEffectUI = require("app.models.fight.FightEffectUI")

local EffectUIInfo = require("src.app.models.fight.EffectUIInfo")

local LogSystem = require("app.models.LogSystem.LogSystem")

local HpRecoverOnHurtEffect = {
    __isActiveHurt = false,

    __isAutoHurt= false,

	__recoverPercent = 0
}

function HpRecoverOnHurtEffect:create(effect)
    local p = HpRecoverOnHurtEffect.new()
    p:init(effect)
    return p
end

function HpRecoverOnHurtEffect:ctor()
end

function HpRecoverOnHurtEffect:init(effect)    
    self:setId(effect:getId())

    self:__initEffect(effect)
end

--@desc: 初始化受伤回血效果
--@author:LvBin
--@time:2026-07-14 16:30:34
--@effect: 
--@return
function HpRecoverOnHurtEffect:__initEffect(effect)
    local arg1 = effect:getFinalArg1()
    
    local arg2 = effect:getArg2()

	self.__recoverPercent = arg1

	if string.find(arg2,"activeHurt") then
		self.__isActiveHurt = true
	end

	if string.find(arg2,"autoHurt") then
		self.__isAutoHurt = true
	end

	self.__effect = effect
end

--@desc: 是否触发
--@author:LvBin
--@time:2026-07-14 16:44:36
--@hurt: [src.app.models.fight.Hurt.BaseHurt#BaseHurt]
--@return
function HpRecoverOnHurtEffect:isTrigger(hurt)
	if hurt:isAutoHurt() and self.__isAutoHurt then
		return true
    elseif hurt:isActiveHurt() and self.__isActiveHurt then
		return true
	end
	return false
end  

--@desc: 触发
--@author:LvBin
--@time:2026-07-14 17:02:14
--@hurt: [src.app.models.fight.Hurt.BaseHurt#BaseHurt]
--@return
function HpRecoverOnHurtEffect:trigger(hurt)
	local hurtValue = math.abs(hurt:getValue())

	local recoverValue = math.floor(hurtValue * self.__recoverPercent)

	self:getPlayer():addAttr("qi", recoverValue)

	local immediateEffectUIInfo = FightEffectUI:create(self.__effect:getId())

	local objectUIInfo = 
		{
			attr = self.__effect:getArg1(),
			value = recoverValue,
			popValue = recoverValue,
			popTextColor = cc.c4b(51, 153, 51, 255),
			popText = nil
		}

	immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))
	self:getPlayer()._fight:callEventListener("addRolesEffectChangeFunction", function()
		self:getPlayer()._fight:callEventListener("doEffect", self:getPlayer(), self.__effect ,immediateEffectUIInfo)
		return true
	end)

	LogSystem:log("旧版战斗："," |受伤回血 效果  回血 = ",recoverValue," |回血系数 = ",self.__recoverPercent)
end

return newClass("HpRecoverOnHurtEffect", {BaseEffect}, HpRecoverOnHurtEffect)
00000
local newClass = require("third.class.NewClass")

local BaseEffect = require("app.models.fight.Effect.BaseEffect")

local SelfKillEffect = {
    __sound = nil,

    __animName = nil,

    __animFrame = 0
}

function SelfKillEffect:create(effect)
    local p = SelfKillEffect.new()
    p:init(effect)
    return p
end

function SelfKillEffect:ctor()
end

function SelfKillEffect:init(effect)
    self:setId(effect:getId())

    self:__initEffect(effect)
end

function SelfKillEffect:__initEffect(effect)
    local arg1 = effect:getArg1()
    
    local arg2 = effect:getArg2()

    self.__animName = arg1

    self.__animFrame = tonumber(arg2)
end

--@desc: 触发立即死亡
--@author:LvBin
--@time:2023-03-09 18:13:01
--@hitPos: 击中部位
--@return
function SelfKillEffect:trigger(hitPos)
    self:getPlayer()._fight:callEventListener("playSelfKill",self:getPlayer(),hitPos,self.__sound,self.__animName,self.__animFrame)
end 

return newClass("SelfKillEffect", {BaseEffect}, SelfKillEffect)
0000000000000
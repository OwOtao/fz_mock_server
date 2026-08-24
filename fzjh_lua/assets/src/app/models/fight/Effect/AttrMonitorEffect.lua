local newClass = require("third.class.NewClass")

local BaseEffect = require("app.models.fight.Effect.BaseEffect")

local AttrMonitorEffect = {
    __condition = false,

    __effectIds = {}
}

function AttrMonitorEffect:create(effect)
    local p = AttrMonitorEffect.new()
    p:init(effect)
    return p
end

function AttrMonitorEffect:ctor()
end

function AttrMonitorEffect:init(effect)
    self:setId(effect:getId())

    self:__initEffect(effect)
end

function AttrMonitorEffect:__initEffect(effect)
    local arg1 = effect:getFinalArg1()
    
    local arg2 = effect:getArg2()

    local effectIds = string.split(arg2, "#")

    self.__condition = arg1 == 1 and true or false

    self.__effectIds = effectIds
end

--@desc: 监控是否触发
--@author:LvBin
--@time:2023-03-09 17:51:51
--@return
function AttrMonitorEffect:isTrigger()
    return self.__condition
end  

--@desc: 触发
--@author:LvBin
--@time:2023-03-09 18:13:01
--@return
function AttrMonitorEffect:trigger()
    if MapIsEmpty(self.__effectIds) then
        return
    end

    for i,effectId in ipairs(self.__effectIds) do
        local effect = Skill:getSkillEffect(effectId):clone()
        effect:setOwner(self:getPlayer())
        effect:setObject(self:getPlayer())
        self:getPlayer()._fight:roleAddEffect(self:getPlayer(),self:getPlayer(), effect)
    end
end 

return newClass("AttrMonitorEffect", {BaseEffect}, AttrMonitorEffect)
000000
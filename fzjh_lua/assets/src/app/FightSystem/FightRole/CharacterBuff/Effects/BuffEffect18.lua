--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
    * **效果类型ID=18，携带被动招式Buff添加器**
        * 效果触发节点：3=被添加Buff
        * 效果功能执行：当角色持有Buff时，角色会同时加载对应的**被动招式Buff添加器**，此时角色进行被动招式攻击时，会根据添加器执行条件给指定目标添加Buff。
        > 被动招式Buff添加器，即[总Buff表被动Buff添加器]。
        * `effectTypeParam`配置：填写携带的被动招式Buff添加器ID，添加器ID对应 `表[总Buff表被动Buff添加器].buff添加器;buffLauncher` 
        * `argsParam`配置：添加器条件参数
              * 添加器条件参数用来为`表[总Buff表被动Buff添加器]`传递动态参数用。
              * 可以配置**具体数值**或者动态参数`dynamicArg1、dynamicArg2、dynamicArg3`，动态参数来源自添加Buff获得的 Buff效果参数1~3 。
        * 效果生效表现：无特殊需求（用Buff本身表现效果和添加器本身表现效果即可）
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect18 = {}

function BuffEffect18:create()
    return BuffEffect18.new():__init()
end

function BuffEffect18:__init()
    self.__isInit = false
    return self
end

function BuffEffect18:updateEffectValue()
    self.__buffLaunchId = self.__basicEffect:getEffectTypeParam()

    local argValue = tonumber(self.__basicEffect:getArgsParam())

    if argValue == nil then
        argValue = self.__buff:getBuffDynamicArg(self.__basicEffect:getArgsParam())
    end

    self.__argValue = argValue
end

function BuffEffect18:makeEffectOnAdd()
    if self.__isInit == false then
        self:updateEffectValue()
        self.__isInit = true
    end

    local CharacterBuffAdderGroupFactory = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.CharacterBuffAdderGroupFactory")

    self.__indexId =
        self.__buff:getBuffOwner():addBuffAdderGroup(
        CharacterBuffAdderGroupFactory:getAutoBuffAdderGroup(
            self.__buffLaunchId,
            self.__buff:getBuffOwner(),
            self.__buff:getBuffOwner():getFight(),
            {
                ["dynamicLaun"] = self.__argValue
            }
        )
    )
end

function BuffEffect18:makeEffectOnRemove()
    self.__buff:getBuffOwner():removeBuffAdderGroup(self.__indexId)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect18:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect18", {ABuffEffect}, BuffEffect18)
000000000
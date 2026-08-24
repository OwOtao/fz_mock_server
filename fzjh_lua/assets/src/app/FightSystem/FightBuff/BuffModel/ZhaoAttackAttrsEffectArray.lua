--[[
    临时对象

    该对象存放影响攻击结果相关的buff效果
]]
local newClass = require("third.class.NewClass")

local LogSystem = require("app.models.LogSystem.LogSystem")

local ZhaoAttackAttrsEffectArray = {
    __list = {}
}

function ZhaoAttackAttrsEffectArray:create()
    return ZhaoAttackAttrsEffectArray.new()
end

function ZhaoAttackAttrsEffectArray:getCount()
    return #self.__list
end

function ZhaoAttackAttrsEffectArray:getZhaoAttackAttrs()
    return self.__list
end

function ZhaoAttackAttrsEffectArray:add(zhaoAttackAttrsEffect)
    table.insert(self.__list, zhaoAttackAttrsEffect)
end

--@desc:
--@author:Seven
--@time:2021-12-02 21:09:18
--@index: 索引
--@return [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
function ZhaoAttackAttrsEffectArray:get(index)
    if index > self:getCount() or index < 1 then
        error("ZhaoAttackAttrsEffectArray:get 索引越界 :" .. index .. " 最大值：" .. self:getCount())
    end

    return self.__list[index]
end

return newClass("ZhaoAttackAttrsEffectArray", {}, ZhaoAttackAttrsEffectArray)
00000
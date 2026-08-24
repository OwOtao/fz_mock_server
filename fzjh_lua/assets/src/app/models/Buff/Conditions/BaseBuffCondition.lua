local BaseBuffCondition = class("BaseBuffCondition")

function BaseBuffCondition:create()
    local p = BaseBuffCondition:new()
    p:init()
    return p
end

function BaseBuffCondition:ctor()
    self.type = 0
    self.arg1 = 0
    self.arg2 = 0
    self.arg3 = 0
end

function BaseBuffCondition:init()
end

function BaseBuffCondition:check(context)
    self.context = context
    return self:onCheck()
end

function BaseBuffCondition:onCheck()
    return true
end

function BaseBuffCondition:setArgs(name, value)
    if self[name] == nil then
        error("buff 条件无该属性：" .. name)
    end

    self[name] = value
end

--@desc:
--@author:Seven_L
--@time:2020-06-04 22:37:37
--@buff: [BaseBuff]
function BaseBuffCondition:setBuff(buff)
    --@RefType[BaseBuff]
    self.buff = buff
end

return BaseBuffCondition
000000000
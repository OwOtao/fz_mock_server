--[[
    author:Seven
    time:2023-02-10 10:56:47
    desc: 记录动画相关信息model
]]
local newClass = require("third.class.NewClass")

local AnimStateInfo = {}

--@desc: 动画信息创建
--@author:Seven
--@time:2023-02-10 11:06:05
--@source: 来源
--@animId: 动画id
--@priority: 优先级
--@return [src.app.FightSystem.FightRole.AnimSystem.AnimStateInfo#AnimStateInfo]
function AnimStateInfo:create(source, animId, priority)
    return AnimStateInfo.new():__init(source, animId, priority)
end

function AnimStateInfo:__init(source, animId, priority)
    if animId == nil then
        error("AnimStateInfo 创建失败，animId 参数不可为空")
    end
    self.__animId = animId

    if source == nil then
        error("AnimStateInfo 创建失败，source 参数不可为空")
    end
    self.__source = source

    if priority == nil then
        priority = 0
    end

    if type(priority) ~= "number" then
        error("AnimStateInfo 创建失败， priority 类型必须为数字")
    end
    self.__priority = priority

    return self
end

function AnimStateInfo:setId(id)
    self.__id = id
end

function AnimStateInfo:getId()
    if self.__id == nil then
        error("AnimStateInfo:getId 对象id为空，检查代码")
    end
    return self.__id
end

function AnimStateInfo:getAnimId()
    return self.__animId
end

function AnimStateInfo:getSource()
    return self.__source
end

function AnimStateInfo:getPriority()
    return self.__priority
end

return newClass("AnimStateInfo", {}, AnimStateInfo)
00000000000
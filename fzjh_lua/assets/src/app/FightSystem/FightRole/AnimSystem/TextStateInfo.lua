--[[
    author:Seven
    time:2023-02-10 21:16:03
    desc: 角色头顶文字信息类
]]
local newClass = require("third.class.NewClass")

local TextStateInfo = {}

--@desc: 文本信息创建
--@author:Seven
--@time:2023-02-10 21:17:05
--@source: 来源
--@text: 文本
--@priority: 优先级
--@return [src.app.FightSystem.FightRole.AnimSystem.TextStateInfo#TextStateInfo]
function TextStateInfo:create(source, text, priority)
    return TextStateInfo.new():__init(source, text, priority)
end

function TextStateInfo:__init(source, text, priority)
    if text == nil then
        error("TextStateInfo 创建失败，text 参数不可为空")
    end
    self.__text = text

    if source == nil then
        error("TextStateInfo 创建失败，source 参数不可为空")
    end
    self.__source = source

    if priority == nil then
        priority = 0
    end

    if type(priority) ~= "number" then
        error("TextStateInfo 创建失败， priority 类型必须为数字")
    end
    self.__priority = priority

    return self
end

function TextStateInfo:setId(id)
    self.__id = id
end

function TextStateInfo:getId()
    if self.__id == nil then
        error("TextStateInfo:getId 对象id为空，检查代码")
    end
    return self.__id
end

function TextStateInfo:getText()
    return self.__text
end

function TextStateInfo:getSource()
    return self.__source
end

function TextStateInfo:getPriority()
    return self.__priority
end

return newClass("TextStateInfo", {}, TextStateInfo)
000
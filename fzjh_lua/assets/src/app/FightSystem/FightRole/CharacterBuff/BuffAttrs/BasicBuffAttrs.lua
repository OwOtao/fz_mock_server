--[[
    author:Seven
    time:2022-12-17 11:35:03
    desc: buff系统属性子系统
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BasicBuffAttrs = {}

local getFuncNameCache = {}

function BasicBuffAttrs:create(sys)
    return BasicBuffAttrs.new():__init(sys)
end

function BasicBuffAttrs:__init(sys)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BasicBuffSystem#BasicBuffSystem]
    self.__sys = sys

    return self
end

function BasicBuffAttrs:getAttr(name)
    local getFuncName = getFuncNameCache[name]
    if getFuncName == nil then
        getFuncName = string.format("__get%s", string.gsub(name, "^%l", string.upper))
        getFuncNameCache[name] = getFuncName
    end

    if self[getFuncName] ~= nil then
        return self[getFuncName](self)
    end

    error(string.format("Buff系统属性：%s 不支持读取或未定义", name))
end

function BasicBuffAttrs:__getBuffNum()
    local value = 0

    self.__sys:walkAllBuff(
        function(buff)
            local buffClass = buff:getBuffClass()
            if buffClass == 0 then
                value = value + 1
            end
        end
    )

    return value
end

function BasicBuffAttrs:__getDeBuffNum()
    local value = 0

    self.__sys:walkAllBuff(
        function(buff)
            local buffClass = buff:getBuffClass()
            if buffClass == 1 or buffClass == 4 then
                value = value + 1
            end
        end
    )

    return value
end

return newClass("BasicBuffAttrs", {}, BasicBuffAttrs)
0000000000000
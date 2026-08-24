--[[
    author:Seven
    time:2022-12-17 11:35:03
    desc: 拳脚系统属性子系统
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightFistFootAttr = {}

local getFuncNameCache = {}

function FightFistFootAttr:create(sys)
    return FightFistFootAttr.new():__init(sys)
end

function FightFistFootAttr:__init(sys)
    --@RefType [src.app.FightSystem.FightRole.FistFoot.CharacterFistFootSystem#CharacterFistFootSystem]
    self.__sys = sys

    return self
end

function FightFistFootAttr:getAttr(name)
    local getFuncName = getFuncNameCache[name]
    if getFuncName == nil then
        getFuncName = string.format("__get%s", string.gsub(name, "^%l", string.upper))
        getFuncNameCache[name] = getFuncName
    end

    if self[getFuncName] ~= nil then
        return self[getFuncName](self)
    end

    error(string.format("拳脚系统属性：%s 不支持读取或未定义", name))
end

--@desc: 拳分支谙技值
--@author:Seven
--@time:2022-12-17 14:36:53
function FightFistFootAttr:__getJqdamagequan()
    local value = self.__sys:getJqdamage("10010")
    FightUtil:printLog("getJqdamagequan 拳分支谙技值：",value)
    return value
end

--@desc: 掌分支谙技值
--@author:Seven
--@time:2022-12-17 14:36:53
function FightFistFootAttr:__getJqdamagezhang()
    local value = self.__sys:getJqdamage("10020")
    FightUtil:printLog("getJqdamagezhang 掌分支谙技值：",value)
    return value
end

--@desc: 爪分支谙技值
--@author:Seven
--@time:2022-12-17 14:37:45
function FightFistFootAttr:__getJqdamagezhua()
    local value = self.__sys:getJqdamage("10030")
    FightUtil:printLog("getJqdamagezhua 爪分支谙技值：",value)
    return value
end

--@desc: 指分支谙技值
--@author:Seven
--@time:2022-12-17 14:37:54
function FightFistFootAttr:__getJqdamagezhi()
    local value = self.__sys:getJqdamage("10040")
    FightUtil:printLog("getJqdamagezhi 指分支谙技值：",value)
    return value
end

--@desc: 腿分支谙技值
--@author:Seven
--@time:2022-12-17 14:38:05
function FightFistFootAttr:__getJqdamagetui()
    local value = self.__sys:getJqdamage("10050")
    FightUtil:printLog("getJqdamagetui 腿分支谙技值：",value)
    return value
end

return newClass("FightFistFootAttr", {}, FightFistFootAttr)
00000
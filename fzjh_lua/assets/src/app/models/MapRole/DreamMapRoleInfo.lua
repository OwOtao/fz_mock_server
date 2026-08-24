local class = require("third.class.NewClass")

local DreamMapRoleInfo = {}

function DreamMapRoleInfo:create()
    return DreamMapRoleInfo:new()
end

function DreamMapRoleInfo:ctor()
end

function DreamMapRoleInfo:setRole(role)
    self.__role = role
end

function DreamMapRoleInfo:getRole()
    return self.__role
end

function DreamMapRoleInfo:getName()
    return Helper:getDef(self.__role.title,"WHT【普通百姓】")  .. " " .. self.__role:getName()
end

function DreamMapRoleInfo:getBirth()
    return Helper:getDef(User:getRole():getDreamSystem():getResManager():getRoleAttrTab()[tostring(self.__role.drzjid)].drtext,"")
end

function DreamMapRoleInfo:getSex()
    return "【"..self.__role:getCHAttrName("sex").."】"..tostring(self.__role:getAttr("sex"))
end

function DreamMapRoleInfo:getAge()
    return "【"..self.__role:getCHAttrName("age").."】"..tostring(self.__role:getAttr("age"))
end

function DreamMapRoleInfo:getLv()
    return "【"..self.__role:getCHAttrName("lv").."】"..tostring(self.__role:getLv())
end

function DreamMapRoleInfo:getEmotion()
    return "【"..self.__role:getCHAttrName("emotion").."】".. self.__role.emotionMgr:getCurrEmotion():getName()
end

function DreamMapRoleInfo:getCurrency()
    return "【"..self.__role:getCHAttrName("dreamPoints").."】"..tostring(Helper:getDef(self.__role:getAttr("dreamPoints"),0))
end


return class("DreamMapRoleInfo", {}, DreamMapRoleInfo)
0
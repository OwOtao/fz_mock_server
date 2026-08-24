--[[
    角色头像边框系统
    记录角色头像边框来源及顺序
]]
local newClass = require("third.class.NewClass")

local BorderConfigManager = require("app.models.HeadViewSystem.BorderConfigManager")

local IGetRoleViewBorder = require("app.models.HeadViewSystem.IGetRoleViewBorder")

local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

local MaskResManager = require("app.models.mask.MaskResManager")

local LogSystem = require("app.models.LogSystem.LogSystem")

--@SuperType [src.app.models.HeadViewSystem.IGetRoleViewBorder#IGetRoleViewBorder]
local RoleViewBorderSys = {
    __borderVer = 0,
    __sysClasses = {},
    __showList = {}
}

function RoleViewBorderSys:create(role)
    local p = RoleViewBorderSys.new()
    p.__isNotSerializable = true
    p:__init(role)
    return p
end

function RoleViewBorderSys:__init(role)
    self.__role = role
    self:load()
    self:registerClass("mask", self.__role:getMaskSystem())
    self:registerClass("title", self.__role:getTitleSystem())

    self:__changeData()
end

function RoleViewBorderSys:registerClass(name, sysClass)
    if self.__sysClasses[name] ~= nil then
        error("RoleViewBorderSys:registerClass - name : " .. name .. " 已注册过，检查代码。")
    end

    self.__sysClasses[name] = sysClass
end

--@return [src.app.models.HeadViewSystem.IGetRoleViewBorder#IGetRoleViewBorder]
function RoleViewBorderSys:__getSysClass(name)
    return self.__sysClasses[name]
end

function RoleViewBorderSys:addShowClass(name)
    if self.__sysClasses[name] == nil then
        error("RoleViewBorderSys:addShowClass 添加显示来源错误：" .. name .. "，未注册该来源类")
    end

    --@desc 去重
    if #self.__showList > 0 then
        for i = #self.__showList, 1, -1 do
            local className = self.__showList[i]

            if className == name then
                table.remove(self.__showList, i)
                break
            end
        end
    end

    table.insert(self.__showList, 1, name)
end

function RoleViewBorderSys:removeShowClass(name)
    if #self.__showList <= 0 then
        return
    end

    for i = #self.__showList, 1, -1 do
        local className = self.__showList[i]

        if className == name then
            table.remove(self.__showList, i)
            break
        end
    end
end

function RoleViewBorderSys:getBorder()
    local className = self.__showList[1]

    LogSystem:log("RoleViewBorderSys:getBorder ", self.__showList)

    if className == nil then
        return BorderConfigManager:getBorderConf(self:getDefaultBorderId()):getFramePath()
    end

    local class = self:__getSysClass(className)

    return class:getBorder()
end

function RoleViewBorderSys:getBorderId()
    local className = self.__showList[1]

    LogSystem:log("RoleViewBorderSys:getBorderId ", self.__showList)

    if className == nil then
        return self:getDefaultBorderId()
    end

    local class = self:__getSysClass(className)

    return class:getBorderId()
end

function RoleViewBorderSys:getDefaultBorderId()
    return 10000
end

function RoleViewBorderSys:getInfoViewBorder()
    local className = self.__showList[1]

    LogSystem:log("RoleViewBorderSys:getInfoViewBorder ", self.__showList)

    if className == nil then
        return BorderConfigManager:getBorderConf(self:getDefaultBorderId()):getInfoFramePath()
    end

    local class = self:__getSysClass(className)

    return class:getInfoViewBorder()
end

function RoleViewBorderSys:serialization()  
    self.__role:setAttr("borderVer",self.__borderVer)
    self.__role:setBorderShowList(self.__showList)
end

function RoleViewBorderSys:load()
    self.__borderVer = self.__role:getAttr("borderVer")

    self.__showList = self.__role:getBorderShowList()
end

--@desc: 数据转换
--@author:Seven
--@time:2021-12-01 11:52:48
function RoleViewBorderSys:__changeData()
    if self.__borderVer == 0 then
        local titleBorderId = self.__role:getTitleSystem():getBorderId() 
        if titleBorderId ~= self:getDefaultBorderId() then
            self:addShowClass("title")
        end

        --@RefType [src.app.models.mask.MaskAttr#MaskAttr]
        local wearMask = self.__role:getMaskSystem():getWearMask()
        if wearMask ~= nil and wearMask:getFramePath() ~= nil then
            self:addShowClass("mask")
        end

        self.__borderVer = 1

        self:serialization()
    end
end

return newClass("RoleViewBorderSys", {IGetRoleViewBorder}, RoleViewBorderSys)
000000000000
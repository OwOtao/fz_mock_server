--[[
    author:Seven
    time:2023-02-11 15:34:21
    desc: 角色图标系统
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local isImplements = require("third.assertIsInstance.assertIsInstance")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local IconSystem = {}

function IconSystem:create()
    return IconSystem.new()
end

function IconSystem:onInit()
    self.__iconList = {}
    --@desc 保证角色中图标id唯一
    self.__idIndex = 9000
end

--@desc: 添加图标对象
--@author:Seven
--@time:2023-02-11 16:03:29
--@icon: [src.app.FightSystem.FightRole.IconSystem.BasicIcon#BasicIcon]
--@return: 图标对象id
function IconSystem:addIcon(icon)
    local newId = self:__getNewId()
    table.insert(self.__iconList, isImplements(icon, require("app.FightSystem.FightRole.IconSystem.BasicIcon")))
    icon:setId(newId)
    return icon:getId()
end

function IconSystem:__walkIconList(func)
    if table.getn(self.__iconList) <= 0 then
        return
    end

    for i, v in ipairs(self.__iconList) do
        if func(i, v) == true then
            break
        end
    end
end

function IconSystem:__getNewId()
    self.__idIndex = self.__idIndex + 1

    return self.__idIndex
end

--@desc: 获取图标对象
--@author:Seven
--@time:2023-02-11 16:19:46
--@id: 图标id
--@return [src.app.FightSystem.FightRole.IconSystem.BasicIcon#BasicIcon]
function IconSystem:getIcon(id)
    local icon

    self:__walkIconList(
        function(index, iconObject)
            if id == iconObject:getId() then
                icon = iconObject
                return true
            end

            return false
        end
    )

    if icon == nil then
        error("IconSystem:getIcon 图标对象未找到，id：" .. tostring(id))
    end

    return icon
end

--@desc: 移除图标
--@author:Seven
--@time:2023-02-11 16:20:35
--@id: 图标对象id
--@return [src.app.FightSystem.FightRole.IconSystem.BasicIcon#BasicIcon]
function IconSystem:removeIcon(id)
    local removeIcon
    local removeIndex

    self:__walkIconList(
        function(index, iconObject)
            if id == iconObject:getId() then
                removeIndex = index
                removeIcon = iconObject
                return true
            end

            return false
        end
    )

    if removeIcon == nil then
        error("IconSystem:removeIcon 图标对象未找到，id：" .. tostring(id))
    end

    table.remove(self.__iconList, removeIndex)

    return removeIcon
end

--@desc: 获取所有图标
--@author:Seven
--@time:2023-02-11 16:20:21
--@return: 图标数组
function IconSystem:getIcons()
    return self.__iconList
end

function IconSystem:onDestory()
end

function IconSystem:onUpdate(ft)
end

return newClass("IconSystem", {ABasicCharacterFuncSystem}, IconSystem)
0
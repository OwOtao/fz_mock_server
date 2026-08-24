--[[
    author:Seven
    time:2023-03-03 20:08:57
    desc: 角色buff组，用于管理记录相同buffid的公用属性
]]
local newClass = require("third.class.NewClass")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local Constants = require("app.FightSystem.FightBuff.Constants")

local BasicFightCharacterBuffGroup = {}

function BasicFightCharacterBuffGroup:create(buffId)
    return BasicFightCharacterBuffGroup.new():__init(buffId)
end

function BasicFightCharacterBuffGroup:__init(buffId)
    self.__buffId = buffId

    --@RefType [src.app.FightSystem.FightBuff.BasicBuff.BasicBuff#BasicBuff]
    self.__basicBuff = BuffConf:getBasicBuffClass(self.__buffId)

    --@desc 该组的最大上限
    self.__stackMax = 0

    --@desc 存放角色的buff索引
    self.__list = {}

    self.__iconOnlyId = nil

    return self
end

function BasicFightCharacterBuffGroup:setOwner(owner)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__owner = owner
end

function BasicFightCharacterBuffGroup:getOwner()
    return self.__owner
end

function BasicFightCharacterBuffGroup:getBuffId()
    return self.__buffId
end

function BasicFightCharacterBuffGroup:getBuffClass()
    return tonumber(self.__basicBuff:getClass())
end

--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function BasicFightCharacterBuffGroup:addBuffToGroup(buff)
    table.insert(self.__list, buff:getId())

    self:__addIcon()
end

--@desc: 从列表中删除buff的index
--@author:Seven
--@time:2023-10-10 14:24:52
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function BasicFightCharacterBuffGroup:removeBuffFromGroup(buff)
    local buffindex = buff:getId()
    for i = 1, table.getn(self.__list) do
        if self.__list[i] == buffindex then
            self:__reduceIconCount()
            table.remove(self.__list, i)
        end
    end
end

function BasicFightCharacterBuffGroup:getBuffIndexs()
    return self.__list
end

--@desc: 添加图标
--@author:Seven
--@time:2023-03-15 15:19:51
function BasicFightCharacterBuffGroup:__addIcon()
    local iconId = self.__basicBuff:getIcon()
    if iconId == nil then
        return
    end
    if self.__iconOnlyId == nil then
        local BasicIcon = require("app.FightSystem.FightRole.IconSystem.BasicIcon")
        local icon = BasicIcon.createIcon(iconId)
        self.__iconOnlyId = self.__owner:addIcon(icon)
    else
        local characterIcon = self.__owner:getIcon(self.__iconOnlyId)
        if characterIcon == nil then
            error("BasicFightCharacterBuffGroup:__addIcon 无法获取图标对象，检查代码 onlyId:" .. tostring(self.__iconOnlyId) .. " iconId:" .. tostring(iconId) .. "")
        end
        characterIcon:setCount(characterIcon:getCount() + 1)
    end
end

--@desc: 减少图标层数
--@author:Seven
--@time:2023-03-15 15:54:08
function BasicFightCharacterBuffGroup:__reduceIconCount()
    if self.__iconOnlyId == nil then
        return
    end
    local characterIcon = self.__owner:getIcon(self.__iconOnlyId)
    local newCount = characterIcon:getCount() - 1
    if newCount == 0 then
        self.__owner:removeIcon(self.__iconOnlyId)
        self.__iconOnlyId = nil
    elseif newCount > 0 then
        characterIcon:setCount(newCount)
    else
        error("BasicFightCharacterBuffGroup:__reduceIconCount 代码逻辑错误，检查代码")
    end
end

function BasicFightCharacterBuffGroup:getBuffCount()
    return table.getn(self.__list)
end

--@desc: 设置buff叠加层数
--@author:Seven
--@time:2023-03-13 17:16:52
function BasicFightCharacterBuffGroup:setBuffStackMax(value)
    if self.__stackMax ~= value then
        self.__stackMax = value
    end
end

--@desc: 获取buff叠加上限最大值
--@author:Seven
--@time:2023-03-13 17:17:26
function BasicFightCharacterBuffGroup:getBuffStackMax()
    return self.__stackMax
end

return newClass("BasicFightCharacterBuffGroup", {}, BasicFightCharacterBuffGroup)
000
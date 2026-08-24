--[[
    author:Seven
    time:2023-03-16 21:14:40
    desc: buff 免疫功能
]]
local newClass = require("third.class.NewClass")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local BuffImmuneFunc = {}

function BuffImmuneFunc:create(sys)
    return BuffImmuneFunc.new():__init(sys)
end

function BuffImmuneFunc:__init(sys)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BasicBuffSystem#BasicBuffSystem]
    self.__sys = isImpl(sys, require("app.FightSystem.FightRole.CharacterBuff.BasicBuffSystem"))

    return self
end

function BuffImmuneFunc:ctor()
    self.__indexId = 3000

    self.__immuneBuffAll = {}

    self.__buffClassArray = {}

    self.__buffIdArray = {}
end

function BuffImmuneFunc:__getNewIndexId()
    self.__indexId = self.__indexId + 1
    return self.__indexId
end

function BuffImmuneFunc:addImmuneBuff(immuneType, ...)
    local args = {...}

    if immuneType == "BuffAll" then
        return self:__addAll(args[1], args[2])
    elseif immuneType == "BuffClass" then
        return self:__addBuffClass(args[1], args[2], args[3])
    elseif immuneType == "BuffID" then
        return self:__addBuffId(args[1], args[2], args[3])
    else
        error("BuffImmuneFunc:addImmuneBuff 免疫类型未知：" .. tostring(immuneType))
    end
end

function BuffImmuneFunc:__addAll(popText, printText)
    local id = self:__getNewIndexId()

    table.insert(
        self.__immuneBuffAll,
        {
            id = id,
            popText = popText,
            printText = printText
        }
    )

    return id
end

function BuffImmuneFunc:__addBuffClass(buffClass, popText, printText)
    local id = self:__getNewIndexId()

    table.insert(
        self.__buffClassArray,
        {
            id = id,
            buffClass = buffClass,
            popText = popText,
            printText = printText
        }
    )

    return id
end

function BuffImmuneFunc:__addBuffId(buffId, popText, printText)
    local id = self:__getNewIndexId()

    table.insert(
        self.__buffIdArray,
        {
            id = id,
            buffId = buffId,
            popText = popText,
            printText = printText
        }
    )

    return id
end

function BuffImmuneFunc:isImmuneBuff(immuneType, ...)
    local args = {...}
    if immuneType == "BuffAll" then
        return self:__isAll()
    elseif immuneType == "BuffClass" then
        return self:__isBuffClass(args[1])
    elseif immuneType == "BuffID" then
        return self:__isBuffId(args[1])
    else
        error("BuffImmuneFunc:isImmuneBuff 免疫类型未知：" .. tostring(immuneType))
    end
end

function BuffImmuneFunc:__isAll()
    local info = self.__immuneBuffAll[1]

    if info ~= nil then
        return true, Helper:getDef(info.popText, ""), Helper:getDef(info.printText, "")
    end

    return false
end

function BuffImmuneFunc:__isBuffClass(buffClass)
    if MapIsEmpty(self.__buffClassArray) then
        return false
    end

    local info
    buffClass = tonumber(buffClass)
    
    for _, v in ipairs(self.__buffClassArray) do
        if v.buffClass == buffClass then
            info = v
            break
        end
    end

    if info ~= nil then
        return true, Helper:getDef(info.popText, ""), Helper:getDef(info.printText, "")
    end

    return false
end

function BuffImmuneFunc:__isBuffId(buffId)
    if MapIsEmpty(self.__buffIdArray) then
        return false
    end

    local info
    for _, v in ipairs(self.__buffIdArray) do
        if v.buffId == buffId then
            info = v
            break
        end
    end

    if info ~= nil then
        return true, Helper:getDef(info.popText, ""), Helper:getDef(info.printText, "")
    end

    return false
end

function BuffImmuneFunc:removeImmune(immuneType, id)
    local list

    if immuneType == "BuffAll" then
        list = self.__immuneBuffAll
    elseif immuneType == "BuffClass" then
        list = self.__buffClassArray
    elseif immuneType == "BuffID" then
        list = self.__buffIdArray
    else
        error("BuffImmuneFunc:removeImmune 免疫类型未知：" .. tostring(immuneType))
    end

    local removeObject = self:__removeList(list, id)

    if removeObject == nil then
        error("BuffImmuneFunc:removeImmune , 移除时未找到免疫类型：" .. tostring(immuneType) .. "中的对象 id：" .. tostring(id) .. "检查代码")
    end
end

function BuffImmuneFunc:__removeList(list, id)
    for index, v in ipairs(list) do
        if v.id == id then
            return table.remove(list, index)
        end
    end

    return nil
end

return newClass("BuffImmuneFunc", {}, BuffImmuneFunc)
0
local newClass = require("third.class.NewClass")

local BtnInfoVm = {
    __id = "test",
    __type = 0,
    __name = "",
    __cd = 0,
    __coolTime = 0,
    __isEnable = true,
    __visible = true
}

function BtnInfoVm:create(id)
    local p = BtnInfoVm.new()
    p:__init(id)
    return p
end

function BtnInfoVm:__init(id)
    self.__id = id
end

function BtnInfoVm:getId()
    return self.__id
end

function BtnInfoVm:setType(type)
    self.__type = type
end

function BtnInfoVm:getType()
    return self.__type
end

function BtnInfoVm:setName(name)
    self.__name = name
end

function BtnInfoVm:getName()
    return self.__name
end

function BtnInfoVm:setCD(cd)
    self.__cd = cd
end

function BtnInfoVm:getCD()
    return self.__cd
end

function BtnInfoVm:setCoolTime(time)
    self.__coolTime = time
end

function BtnInfoVm:getCoolTime()
    return self.__coolTime
end

function BtnInfoVm:setEnable(enable)
    self.__isEnable = enable
end

function BtnInfoVm:getEnable()
    return self.__isEnable
end

function BtnInfoVm:setVisible(bool)
    self.__visible = bool
end

function BtnInfoVm:getVisible()
    return self.__visible
end

return newClass("BtnInfoVm", {}, BtnInfoVm)
0000000000000000
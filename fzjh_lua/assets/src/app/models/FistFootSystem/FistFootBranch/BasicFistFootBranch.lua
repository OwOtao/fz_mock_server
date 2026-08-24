--[[
    author:Seven
    time:2022-11-25 15:15:08
    desc: 基础拳脚分支类
]]
local newClass = require("third.class.NewClass")

local BasicFistFootBranch = {}

function BasicFistFootBranch:create(res)
    return BasicFistFootBranch.new():__init(res)
end

function BasicFistFootBranch:__init(res)
    self.__res = res

    return self
end

function BasicFistFootBranch:getId()
    return self.__res.id
end

function BasicFistFootBranch:getType()
    return self.__res.type
end

--@desc: 等级
--@author:Seven
--@time:2022-11-25 15:47:57
function BasicFistFootBranch:getLevel()
    return self.__res.level
end

--@desc: 对应等级的最小经验
--@author:Seven
--@time:2022-11-25 15:47:39
function BasicFistFootBranch:getExp()
    return self.__res.exp
end

--@desc: 分支武炼值
--@author:Seven
--@time:2022-11-25 16:03:35
function BasicFistFootBranch:getDamage()
    return self.__res.damage
end

return newClass("BasicFistFootBranch", {}, BasicFistFootBranch)
000000000000000
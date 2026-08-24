--[[
    author:Seven
    time:2024-01-11 11:57:22
    desc: 基础武学重数资源类
]]
local newClass = require("third.class.NewClass")

local BasicSkillStage = {}

function BasicSkillStage:create(res)
    return BasicSkillStage.new():__init(res)
end

function BasicSkillStage:__init(res)
    self.__res = res
    return self
end

--@desc: 获取当前重数id
--@author:Seven
--@time:2024-01-11 12:06:37
--@return: number(int)
function BasicSkillStage:getStageId()
    return self.__res.id
end

--@desc: 当前重数
--@author:Seven
--@time:2024-01-11 18:27:19
function BasicSkillStage:getStageLevel()
    return self:getStageId()
end

--@desc: 解锁当前重数的武学等级，如果武学等级处于[当前重数解锁等级，下一级重数解锁等级]之间，则当前重数为该武学的重数
--@author:Seven
--@time:2024-01-11 12:08:39
--@return:
function BasicSkillStage:getLevel()
    return self.__res.level
end

function BasicSkillStage:getStageText()
    return self.__res.text
end

function BasicSkillStage:getStageParam(param)
    return self.__res[param]
end

return newClass("BasicSkillStage", {}, BasicSkillStage)
00000
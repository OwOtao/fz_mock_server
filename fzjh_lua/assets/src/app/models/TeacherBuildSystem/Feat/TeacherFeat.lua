--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-04-12 12:04:45
--]]
local NewClass = require("third.class.NewClass")

local TeacherBuildResManager = require("app.models.TeacherBuildSystem.TeacherBuildResManager")

local TeacherFeat = {}

function TeacherFeat:create(featId)
    local p = TeacherFeat.new()
    p:init(featId)
    return p
end

function TeacherFeat:init(featId)
    self.__data = assert(TeacherBuildResManager:getFeatInfoMap()[tostring(featId)],"师门建树不存在 featId = "..featId)
end

function TeacherFeat:getId()
    return self.__data.featsid
end

function TeacherFeat:getLabel()
    return self.__data.label
end

--阵营
function TeacherFeat:getCamp()
    return self.__data.camp
end

--功绩名称
function TeacherFeat:getTitle()
    return self.__data.title
end

--功绩达成条件描述文本
function TeacherFeat:getText()
    return self.__data.text
end

--奖励文本
function TeacherFeat:getAwardTexts()
    return self.__data.awardtext
end

function TeacherFeat:getAwardText()
    local awardtext = ""

    for i,text in ipairs(self:getAwardTexts()) do
        if i == 1 then
            awardtext = text
        else
            awardtext = awardtext.."、"..text
        end
    end

    return awardtext
end

--奖励配置
function TeacherFeat:getAwards()
    return self.__data.awards
end

--完成条件
function TeacherFeat:getCompletion()
    return self.__data.Completion
end

return NewClass("TeacherFeat", {}, TeacherFeat)000000000000000
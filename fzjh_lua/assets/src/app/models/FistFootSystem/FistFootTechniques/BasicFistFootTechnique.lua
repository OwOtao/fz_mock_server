--[[
    author:Seven
    time:2022-10-18 16:47:29
    desc: 拳脚技巧
]]
local newClass = require("third.class.NewClass")
local BasicFistFootTechnique = {}

function BasicFistFootTechnique:create(res)
    local p = BasicFistFootTechnique.new()
    p:__init(res)
    return p
end

function BasicFistFootTechnique:__init(res)
    if res == nil then
        assert(false, "技巧资源对象创建失败")
    end
    self.__res = res
end

-- 流水id
function BasicFistFootTechnique:getId()
    return self.__res.id
end

-- 技巧id
function BasicFistFootTechnique:getSkillid()
    return self.__res.skillid
end

-- 技巧位置id
function BasicFistFootTechnique:getSplace()
    return self.__res.splace
end

-- 类型
function BasicFistFootTechnique:getType()
    return self.__res.type
end

-- 技巧名称
function BasicFistFootTechnique:getName()
    return self.__res.name
end

-- 可否领悟特性
function BasicFistFootTechnique:isEffect()
    return self.__res.character
end

-- 技巧境界等级
function BasicFistFootTechnique:getSkilllv()
    return self.__res.skilllv
end

-- 升级所需技巧感悟点数
function BasicFistFootTechnique:getSkillcon()
    return self.__res.skillcon
end

-- 谙技
function BasicFistFootTechnique:getJqdamage()
    return self.__res.jqdamage
end

-- 升级条件（拳脚等级）
function BasicFistFootTechnique:getCondition()
    return self.__res.condition
end

-- 升级条件（技巧等级）
function BasicFistFootTechnique:getScondition()
    return self.__res.Scondition
end

-- 所需标记
function BasicFistFootTechnique:getSign()
    return self.__res.sign
end

-- 技巧升级文本
function BasicFistFootTechnique:getOpentext()
    return Helper:getDef(self.__res.opentext,"")
end

-- 特性池id
function BasicFistFootTechnique:getPapool()
    return self.__res.papool
end

-- 抽取所需见解
function BasicFistFootTechnique:getResource()
    return self.__res.resource
end

return newClass("BasicFistFootTechnique", {}, BasicFistFootTechnique)
0
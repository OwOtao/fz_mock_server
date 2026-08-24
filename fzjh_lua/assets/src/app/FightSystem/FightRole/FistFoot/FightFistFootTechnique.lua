--[[
    author:Seven
    time:2022-11-24 15:58:12
    desc: 战斗用技巧类
]]
local newClass = require("third.class.NewClass")

local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")

local FightFistFootTechnique = {}

function FightFistFootTechnique:create(t_id, t_lv)
    return FightFistFootTechnique.new():__init(t_id, t_lv)
end

--@desc: 创建战斗技巧
--@author:Seven
--@time:2022-11-24 16:02:43
--@t_id: 技巧id
--@t_lv: 技巧等级
--@return:
function FightFistFootTechnique:__init(t_id, t_lv)
    --@RefType [src.app.models.FistFootSystem.FistFootTechniques.BasicFistFootTechnique#BasicFistFootTechnique]
    self.__basicFistFootTechnique = FistFootResManager:getBasicFistFootTechnique(t_id, t_lv)

    self.__effects = {}

    return self
end

function FightFistFootTechnique:getName()
    return self.__basicFistFootTechnique:getName()
end

function FightFistFootTechnique:getLv()
    return self.__basicFistFootTechnique:getSkilllv()
end

--@desc: 技巧谙技值
--@author:Seven
--@time:2022-11-24 16:10:24
function FightFistFootTechnique:getJqdamage()
    return self.__basicFistFootTechnique:getJqdamage()
end

--@desc: 添加拳脚特性
--@author:Seven
--@time:2022-11-28 15:37:45
--@effect: [src.app.FightSystem.FightRole.FistFoot.FightFistFootEffect#FightFistFootEffect]
function FightFistFootTechnique:addFistFootEffect(effect)
    table.insert(self.__effects, effect)
end

function FightFistFootTechnique:getEffects()
    return self.__effects
end

return newClass("FightFistFootTechnique", {}, FightFistFootTechnique)
00000000000
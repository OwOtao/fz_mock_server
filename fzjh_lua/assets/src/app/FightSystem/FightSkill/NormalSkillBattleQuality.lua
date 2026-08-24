local class = require("third.class.NewClass")

local ISkillBattleQuality = require("app.FightSystem.FightSkill.ISkillBattleQuality")

local NormalSkillBattleQuality = {}

--@desc: 创建方法
function NormalSkillBattleQuality:create(id)
    local p = self.new()
    p:init(id)
    return p
end

function NormalSkillBattleQuality:init(id)
    self.__id = id
    --@RefType [PrepSkillQualityConf]
    self.__conf = require("app.FightSystem.Configuration.PrepSkillQualityConf")
end

function NormalSkillBattleQuality:getAttr(attr)
    local value = self.__conf:get(self.__id)[attr]
    if value == nil then
        error(tostring(self.__id) .. " 的武学品质属性" .. attr .. "不存在")
    end
    return value
end

return class("NormalSkillBattleQuality", {ISkillBattleQuality}, NormalSkillBattleQuality)
000000000
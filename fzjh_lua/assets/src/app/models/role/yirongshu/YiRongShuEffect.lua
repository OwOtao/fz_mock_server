local NewClass = require("third.class.NewClass")

local YiRongShuEffect = {}

function YiRongShuEffect:create(id)
    local p = YiRongShuEffect.new()
    p:__init(id)
    return p
end

function YiRongShuEffect:__init(id)
    self.__data = require("app.models.role.yirongshu.YiRongShuResManager"):getEffectAttrById(id)
end

function YiRongShuEffect:getId()
    return self.__data.id
end

function YiRongShuEffect:getLevelMin()
    return self.__data.levelMin
end

function YiRongShuEffect:getLevelMax()
    return self.__data.levelMax
end

function YiRongShuEffect:getYouth()
    return self.__data.youth
end

function YiRongShuEffect:getOlder()
    return self.__data.older
end

function YiRongShuEffect:getBeautify()
    return self.__data.beautify
end

function YiRongShuEffect:getUgly()
    return self.__data.ugly
end

function YiRongShuEffect:getLooksCd(skillLv)
    return Helper:GetValueFromScript(self.__data.lookscd, {skillLv = skillLv})
end

function YiRongShuEffect:getLooksDuration(skillLv)
    return Helper:GetValueFromScript(self.__data.looksduration, {skillLv = skillLv})
end

function YiRongShuEffect:getGenderDuration(skillLv)
    return Helper:GetValueFromScript(self.__data.genderduration, {skillLv = skillLv})
end

function YiRongShuEffect:getAddExp(skillLv)
    return Helper:GetValueFromScript(self.__data.expAdd, {skillLv = skillLv})
end

return NewClass("YiRongShuEffect", {}, YiRongShuEffect)
0000000000
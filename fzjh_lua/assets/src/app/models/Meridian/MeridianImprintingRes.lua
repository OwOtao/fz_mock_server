local newClass = require("third.class.NewClass")

local MeridianImprintingRes = {}

function MeridianImprintingRes:create(...)
    local p = MeridianImprintingRes.new()
    p:__init(...)
    return p
end

function MeridianImprintingRes:__init(res)
    self.__res = assert(res, "MeridianImprintingRes:__init res is nil")
end

-- 编号;id(只是编号，可用于排序)
function MeridianImprintingRes:getIndexId()
    return self.__res.id
end

-- 随机权重;probability
function MeridianImprintingRes:getProbability()
    return self.__res.probability
end

-- 印记ID;imprintingId
function MeridianImprintingRes:getImprintingId()
    return self.__res.imprintingId
end

-- 印记名;name
function MeridianImprintingRes:getName()
    return self.__res.name
end

-- 显示效果描述;text
function MeridianImprintingRes:getText()
    return self.__res.text
end

-- N次传承后可获得;inherit
function MeridianImprintingRes:getInherit()
    return self.__res.inherit
end

-- 可否培元;peiyuan
function MeridianImprintingRes:getPeiyuan()
    return self.__res.peiyuan
end

-- 类型;type
function MeridianImprintingRes:getType()
    return self.__res.type
end

-- 化元消耗真气;hycost
function MeridianImprintingRes:getHycost()
    return self.__res.hycost
end

-- 效果值;value
function MeridianImprintingRes:getValue()
    return self.__res.value
end

return newClass("MeridianImprintingRes", {}, MeridianImprintingRes)
000
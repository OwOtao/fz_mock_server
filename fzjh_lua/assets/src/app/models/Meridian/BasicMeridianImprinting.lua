local newClass = require("third.class.NewClass")

local MeridianResources = require("app.models.Meridian.MeridianResources")

local BasicMeridianImprinting = {}

--@desc: 构造函数，创建一个新的实例BasicMeridianImprinting
--@author:Seven
--@time:2025-01-22 16:52:27
--@args: 构造参数
--@return [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
function BasicMeridianImprinting:create(...)
    local p = BasicMeridianImprinting.new()
    return p:__init(...)
end

function BasicMeridianImprinting:__init(id, custiomData)
    self.__res = MeridianResources:getMeridianImprintingRes(id)

    return self
end

-- 编号;id(只是编号，可用于排序)
function BasicMeridianImprinting:getIndexId()
    return self.__res:getIndexId()
end

-- 随机权重;probability
function BasicMeridianImprinting:getProbability()
    return self.__res:getProbability()
end

-- 印记ID;imprintingId
function BasicMeridianImprinting:getImprintingId()
    return self.__res:getImprintingId()
end

-- 印记名;name
function BasicMeridianImprinting:getName()
    return self.__res:getName()
end

-- 显示效果描述;text
function BasicMeridianImprinting:getText()
    return self.__res:getText()
end

-- N次传承后可获得;inherit
function BasicMeridianImprinting:getInherit()
    return self.__res:getInherit()
end

-- 可否培元;peiyuan
function BasicMeridianImprinting:getPeiyuan()
    return self.__res:getPeiyuan()
end

-- 类型;type
function BasicMeridianImprinting:getType()
    return self.__res:getType()
end

-- 化元消耗真气;hycost
function BasicMeridianImprinting:getHycost()
    return self.__res:getHycost()
end

-- 效果值;value
function BasicMeridianImprinting:getValue()
    return self.__res:getValue()
end

--@desc: 用户需要序列化的数据
--@author:Seven
--@time:2025-01-16 21:20:22
--@return: table
function BasicMeridianImprinting:getImprintingData()
    return {}
end

return newClass("BasicMeridianImprinting", {}, BasicMeridianImprinting)
000000
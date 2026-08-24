local newClass = require("third.class.NewClass")

local SpecialTitle = {}

function SpecialTitle:create(data)
    return SpecialTitle.new(data)
end

-- 称号id;
function SpecialTitle:getId()
    return self.id
end
-- 已有id;
function SpecialTitle:getOid()
    return self.oid
end
-- 统一称号类型;
function SpecialTitle:getType()
    return self.type
end
-- 类型名称;
function SpecialTitle:getTypename()
    return self.typename
end
-- 文本颜色;
function SpecialTitle:getColor()
    return self.color
end
-- 称号级别;
function SpecialTitle:getNumber()
    return self.number
end
-- 边框id;
function SpecialTitle:getBorderId()
    return self.borderId
end
-- 称号文本;
function SpecialTitle:getText()
    return self.text
end

return newClass("SpecialTitle", {}, SpecialTitle)
0000
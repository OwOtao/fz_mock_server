local newClass = require("third.class.NewClass")

local BasicTitle = {}

function BasicTitle:create(data)
    return BasicTitle.new(data)
end

-- 称号id;
function BasicTitle:getId()
    return self.id
end

-- 类型;
function BasicTitle:getType()
    return self.type
end
-- 类型名称;
function BasicTitle:getTypename()
    return self.typeName
end
-- 文本颜色;
function BasicTitle:getColor()
    return self.color
end
-- 称号级别;
function BasicTitle:getNumber()
    return self.number
end
-- 边框id;
function BasicTitle:getBorderId()
    return self.borderId
end
-- 称号文本;
function BasicTitle:getText()
    return self.text
end
-- 称号带名颜色文本
function BasicTitle:getColorName()
    return self:getColor().."【"..self:getText().."】"
end

return newClass("BasicTitle", {}, BasicTitle)
00000000000000
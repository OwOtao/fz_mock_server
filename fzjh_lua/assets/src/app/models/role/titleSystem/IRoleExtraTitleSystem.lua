local interface = require("third.class.interface")

local IRoleExtraTitleSystem = {}

-- @desc 是否存在某个称号
function IRoleExtraTitleSystem:containsTitle(titleType, titleId)
end

-- @desc 添加称号
function IRoleExtraTitleSystem:addTitle(titleType,titleId)
end

-- @desc 删除称号
function IRoleExtraTitleSystem:deletaTitle(titleType, titleId)
end

-- @desc 删除指定类型称号
function IRoleExtraTitleSystem:deletaTitleByType(titleType)
end

--@desc 获取称号资源数据
function IRoleExtraTitleSystem:getSpecialTitle(titleType, titleId)
end

--@desc 获取称号类型名称
function IRoleExtraTitleSystem:getSpTitleTypeName(titleType)
end

function IRoleExtraTitleSystem:transitionExtraTitle()
end

return interface("IRoleExtraTitleSystem", IRoleExtraTitleSystem)
0000000
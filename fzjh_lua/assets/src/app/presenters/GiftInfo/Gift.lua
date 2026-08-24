local newClass = require("third.class.NewClass")

local Gift = {}

function Gift:create(data)
    return Gift.new(data)
end

-- 礼包id
function Gift:getId()
    return self.id
end

-- 礼包名称
function Gift:getName()
    return self.name
end

-- 礼包描述
function Gift:getDsc()
    return self.dsc
end

-- 图片地址
function Gift:getIcon()
    return self.icon
end

--礼包商品
function Gift:getGoodsIdList()
    return self.goodsIdList
end

return newClass("Gift", {}, Gift)
00
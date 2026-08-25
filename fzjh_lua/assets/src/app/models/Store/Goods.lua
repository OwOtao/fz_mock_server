--[[
    author:Seven
    time:2024-04-12 15:43:27
    desc: 商品类
]]
local newClass = require("third.class.NewClass")

local Goods = {}

Goods.Const = {
    TYPE = {
        -- 道具
        CLIENT_ITEM = 1,
        -- 客户端特殊道具
        CLIENT_SPECIAL_ITEM = 2,
        -- 客户端属性
        CLIENT_ATTR = 3,
        --服务器物品
        SERVER_ITEM = 4,
        --服务器缓存资源
        SERVER_RES = 5,
        --服务器可回溯资源
        SERVER_RESTORE_RES = 6,
        --解锁功能道具
        SERVER_UNLOCK_RES = 7,
        --江湖雅士
        SERVER_JIANG_HU_YA_SHI = 8,
        --称号
        CLIENT_ROLE_TITLE = 9,
        --货币管理控制货币
        VERSION_CURRENCY = 10
    },
    VIEWTYPE = {
        --普通道具
        NORMAL = 0,
        --面具
        MASK = 1,
        --挂饰
        APPEARANCE = 2,
        --武学
        SKILL = 3,
        --宝箱
        BOX = 4,
		-- 装备
		EQUIP = 5
    }
}

function Goods:create(data)
    return Goods.new(data)
end

-- 商品id
function Goods:getId()
    return self.id
end

-- 道具/资源id
function Goods:getItemId()
    return self.itemId
end

-- 类型
function Goods:getItype()
    return self.itype
end

-- 商品名称
function Goods:getName()
    return self.name
end

-- 商品描述
function Goods:getDsc()
    return self.dsc
end

-- 图片地址
function Goods:getIcon()
    return self.icon
end

--预览类型
function Goods:getViewType()
    return self.viewtype
end

--预览信息
function Goods:getViewInfo()
    return self.extra
end

function Goods:getSearchcondition()
    -- local t = {"and", {100001, {"or", {200130, 200131, 200132, 200133, 200134}}}}

    return self.searchcondition
end

return newClass("Goods", {}, Goods)
0000000000
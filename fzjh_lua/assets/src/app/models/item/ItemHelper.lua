--[[
    author:Seven
    time:2025-09-19 15:03:17
    desc:
]]
local XuanBingDongModel = require("app.models.ShenBing.XuanBingDongModel")

local CangYiGeModel = require("app.models.ShenBing.CangYiGeModel")

local ItemHelper = {}

--@role: [src.app.models.role.Role#Role]
--@itemId: int 物品id
function ItemHelper.getRoleOwnedTotalCountWithItemId(role, itemId)
    assert(role ~= nil, "ItemHelper.getRoleOwnedTotalCountWithItemId role 不能为空")
    assert(itemId ~= nil, "ItemHelper.getRoleOwnedTotalCountWithItemId itemId 不能为空")

    local count = 0

    count = count + role:getItemTotalCount(itemId)

    -- 使用阻塞调用获取异步结果
    count = count + XuanBingDongModel.getItemCountById(role, itemId)

    count = count + CangYiGeModel.getItemCountById(role, itemId)

    return count
end

return ItemHelper
00000000000
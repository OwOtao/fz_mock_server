local CkChapman = {
    needRefesh = false
}

--@RefType [src.app.models.HomelandModel.FurnitureModel.StorageBox#StorageBox]
local StorageBox = require("app.models.HomelandModel.FurnitureModel.StorageBox")

local PRICE_UINIT_NAME = {
    money = "碎银",
    yinpiao = "银票"
}

function CkChapman:getNeedRefresh()
    return self.needRefesh
end

function CkChapman:setNeedRefresh(needRefresh)
    self.needRefesh = needRefresh
end

--@desc: 设置现有箱子的列表
--@author:Liang SongQiang
--@time:2018-10-10 17:06:27
--@box_list: 现有箱子的列表（服务器返回）
function CkChapman:setNowBoxList(box_list)
    self.box_list = {}
    if MapIsEmpty(box_list) then
        return
    end

    self.box_list = {}
    for index, box in ipairs(box_list) do
        if type(box.extra) == "table" then
            local temp = {
                itemId = box.extra.itemId,
                name = StorageBox:getBoxName(box.extra.itemId),
                addCount = StorageBox:getAddCapacity(box.extra.itemId),
                id = box.id
            }

            table.insert(self.box_list, temp)
        end
    end
end

function CkChapman:updateBox(index, updateData)
    local box = self.box_list[index]

    if box == nil then
        return
    end

    Helper:tableCover(box, updateData)

    self.box_list[index] = box
end

function CkChapman:addBox(box)
    table.insert(self.box_list, box)
end

--@desc: 获取现有的箱子列表
--@author:Liang SongQiang
--@time:2018-10-10 17:10:44
function CkChapman:getNowBoxList()
    return self.box_list or {}
end

--@desc: 获取现有箱子的数量
--@author:Liang SongQiang
--@time:2018-10-10 17:06:13
function CkChapman:getNowBoxNum()
    return #self.box_list or 0
end

--@desc: 设置商人售卖的储物箱
--@author:Liang SongQiang
--@time:2018-10-10 17:07:34
--@sellerItems: 设置售卖列表
function CkChapman:setSellerItems(sellerItems)
    self.sellerItems = {}

    if MapIsEmpty(sellerItems) then
        return
    end

    for index, box in ipairs(sellerItems) do
        local temp = {
            unit = box.unit,
            price = box.price,
            itemId = box.itemId,
            name = StorageBox:getBoxName(box.itemId),
            number = box.countNum,
            desc = StorageBox:getBoxDesc(box.itemId),
            addCount = StorageBox:getAddCapacity(box.itemId)
        }

        table.insert(self.sellerItems, temp)
    end
end

--@desc: 获取售卖列表
--@author:Liang SongQiang
--@time:2018-10-10 17:09:04
function CkChapman:getSellerItems()
    return self.sellerItems or {}
end

function CkChapman:getSellerItemByIndex(index)
    local item = self.sellerItems[index]

    return item
end

function CkChapman:setNowPoint(num)
    self.point = num or 0
end

function CkChapman:getNowPoint()
    return self.point or 0
end

function CkChapman:setSellerUnit(unit)
    self.unit = unit or "yinpiao"
end

function CkChapman:getSellerUnit()
    return self.unit
end

function CkChapman:setNpcId(npcId)
    self.npcId = npcId
end

--@desc: 购买并替换
--@author:Liang SongQiang
--@time:2018-10-10 17:09:41
function CkChapman:buyAndRelace(sell_index, replaceIndex, callback)
    if sell_index == nil then
        return
    end

    local sellItem = self.sellerItems[sell_index]

    local itemId
    if sellItem then
        itemId = sellItem.itemId
    end

    if itemId == nil then
        return
    end

    local addCount = 0

    local replaceItemId
    if replaceIndex and self.box_list[replaceIndex] then
        replaceItemId = self.box_list[replaceIndex].id

        local nowCount = self.box_list[replaceIndex].addCount

        local sellItemCount = sellItem.addCount

        if sellItemCount >= nowCount then
            addCount = sellItemCount - nowCount
        else
            PopText("只能替换容量小的储物箱。")
            return
        end
    else
        addCount = sellItem.addCount
    end

    TransCheck:setTransWithWebOrderId(
        function(transId)
            HttpManagerEx:buyStorageBox(
                self.npcId,
                itemId,
                transId,
                replaceItemId,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            Helper:print_lua_table(data)
                            TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)

                            PopText("你花费了" .. data.remove_point .. PRICE_UINIT_NAME[sellItem.unit])

                            self:setNowPoint(data.total_point)

                            if callback then
                                callback()
                            end

                            --@RefType [src.app.models.role.Role#Role]
                            local role = User:getRole()

                            local ckLimit = role:getAttr("ckLimit")

                            ckLimit = ckLimit + addCount

                            PopText("你的仓库上限 +"..addCount)

                            role:setAttr("ckLimit", ckLimit)

                            local temp = {
                                itemId = data.storage_box.extra.itemId,
                                name = StorageBox:getBoxName(data.storage_box.extra.itemId),
                                addCount = StorageBox:getAddCapacity(data.storage_box.extra.itemId),
                                id = data.storage_box.id
                            }


                            if replaceIndex then
                                self:updateBox(replaceIndex,temp)
                            else
                                self:addBox(temp)
                            end

                            self:setNeedRefresh(true)
                        else
                            PopText(errmsg)
                        end
                        return true
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING,
                HTTP_MANAGER_RETRY_TYPE_RETRY
            )
        end,
        itemId,
        1,
        -1
    )
end

function CkChapman:checkIsReplaceSameItem(sellIndex, replaceIndex)
    if not sellIndex or not replaceIndex then
        return false
    end

    if self.sellerItems[sellIndex] and self.box_list[replaceIndex] then
        if self.sellerItems[sellIndex].itemId == self.box_list[replaceIndex].itemId then
            return true
        end
    end

    return false
end

return CkChapman
000000000000000
local MedicinalBoxModel = {}

local poisonList = {}
local stuffList = {}
local formulaList = {}


function MedicinalBoxModel:addItemToMedicinalBox(itemId, count,role)
    print("add ItemToMedicinalBox success")
    local result,itemInfo = role:addNoLimitItem(role.medicinalBox,itemId,count)
    if role.userid == User:getUserId() then
        self:classifyBox()
    end
    return result,itemInfo
end



--@desc: 把药囊分类
--@author:Liang SongQiang
--@time:2018-01-12 12:04:21
function MedicinalBoxModel:classifyBox()
    --@RefType [app.models.role.Role#Role]
    local player = User:getRole()

    local mList = player:getAttr("medicinalBox")

    if not MapIsEmpty(poisonList) then
        poisonList = {}
    end

    if not MapIsEmpty(stuffList) then
        stuffList = {}
    end

    if not MapIsEmpty(mList) then
        for i, v in ipairs(mList) do
            local item = Item:getOneItemByKey(v.itemId)
            if item.type == "制药材料" then
                table.insert(stuffList, v)
            elseif item.type == "毒药" then
                table.insert(poisonList, v)
            end
        end
    end

    print("=========================")
    Helper:print_lua_table(poisonList)
    print("=========================\n")
end

--@desc: 获取毒药列表
--@author:Liang SongQiang
--@time:2018-01-12 12:23:23
function MedicinalBoxModel:getPoisonList()
    return poisonList
end

--@desc: 获取材料列表
--@author:Liang SongQiang
--@time:2018-01-12 12:23:33
function MedicinalBoxModel:getStuffList()
    return stuffList
end

--@desc: 获取配方列表
--@author:Liang SongQiang
--@time:2018-01-12 12:24:37
function MedicinalBoxModel:getFormulaList()

    local rolePoisonFormula  = PoisonFormula:getUserPoisonFormula()

    local sortList = {}

    for k, v in pairs(rolePoisonFormula) do
        table.insert(sortList, k)
    end

    table.sort(
        sortList,
        function(a, b)
            local num_a = string.sub(a, 3, string.len(a))
            local num_b = string.sub(b, 3, string.len(b))

            return tonumber(num_a) < tonumber(num_b)
        end
    )

    if not MapIsEmpty(formulaList) then
        formulaList = {}
    end

    for _, v in ipairs(sortList) do
        table.insert(formulaList, v)
    end
    return formulaList
end

--@desc: 获取材料数量
--@author:Liang SongQiang
--@time:2018-01-12 17:41:03
--@stuffId: 材料ID
function MedicinalBoxModel:getHasStuffCount( stuffId )
    if MapIsEmpty(stuffList) then
        self:classifyBox()
    end
    if MapIsEmpty(stuffList) then
        return 0
    end
    for i,v in ipairs(stuffList) do
        if v.itemId == stuffId then
            return v.count
        end
    end

    return 0
end

-- --@desc: 添加item到药囊
-- --@author:Liang SongQiang
-- --@time:2018-01-05 14:03:32
-- --@role: [app.models.role.Role#Role]
-- function MedicinalBoxModel:addItemToMedicinalBox_old(itemId, count,role)
--     if not itemId then
--         assert(nil, "PoisonUtil:addItemToMedicinalBox(itemId, count) -> can not use nil itemId")
--     end

--     assert(type(count) == "number")

--     local itemAttr = Item:getOneItemByKey(itemId)
--     if not itemAttr then
--         if PRINT_MODE == 1 then
--             print("物品不存在")
--         end
--         return nil
--     end

--     local items = role:getItemsWithItemId(itemId, "medicinalBox")
--     if not MapIsEmpty(items) then
--         for i,v in ipairs(items) do
--             if math.floor(count) > 0 then
--                 v.count = v.count + count
--             elseif math.floor(count) < 0 then
--                 v.count = v.count + count
--                 if v.count <= 0 then
--                     table.remove(role.medicinalBox, v.index)
--                 else
--                     count = 0
--                 end
--             else
--                 break
--             end
--         end
--     else
--         if count > 0 then
--             local itemData = {id = role:getItemOnlyId(), count = count, itemId = itemId}
--             table.insert(role.medicinalBox, role:createSafeItem(itemData))
--         end
--     end

--     if role.userid == User:getUserId() then
--         self:classifyBox()
--     end
--     return true
-- end

return MedicinalBoxModel
0000000000
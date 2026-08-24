--@SuperType [src.app.models.map.BaseMap#BaseMap]
local EMap = class("EMap", require("app.models.map.BaseMap"))

--@desc: 执行房间操作
--@author:Liang SongQiang
--@time:2018-12-03 15:58:44
--@currRoomId: 当前所在房间
--@roomId: 下一个要进入的房间
function EMap:doRoomOperation(operationName, currRoomId, roomId)
    local currRoom = self:getRoomAttr(self.__currRoomId)
    if currRoom and MapIsEmpty(currRoom.operations) == false then
        for i, operation in ipairs(currRoom.operations) do
            self:doOperationByName(
                operationName,
                currRoom.operations,
                {
                    operation = operationName,
                    currRoomId = currRoomId,
                    roomId = roomId
                }
            )
        end
    end

    --在执行房间单位的条件结果
    for i, roleId in ipairs(currRoom.roleList) do
        local unit = self:getRole(roleId)
        if MapIsEmpty(unit.operations) ~= true and unit.isForbidden ~= true and unit.isFromWeb ~= true then
            self:doOperationByName(
                operationName,
                unit.operations,
                {
                    operation = operationName,
                    currRoomId = currRoomId,
                    currRole = unit,
                    roomId = roomId
                }
            )
        end
    end
end

--@desc: 根据人物ID和操作名字执行指定人物操作
--@author:Liang SongQiang
--@time:2019-03-28 11:18:42
--@operationName: 操作名字
--@roleId:人物ID
--@currRoomId:当前房间ID
--@roomId:离开房间时，下一个要进入的房间
function EMap:__doRoleOperationInCurrRoomByName(operationName, roleId, currRoomId, roomId)
    local currRoom = self:getRoomAttr(currRoomId)
    --在执行房间单位的条件结果
    for i, roomRoleId in ipairs(currRoom.roleList) do
        if roleId == roomRoleId then
            local unit = self:getRole(roleId)
            if MapIsEmpty(unit.operations) ~= true and unit.isForbidden ~= true and unit.isFromWeb ~= true then
                self:doOperationByName(
                    operationName,
                    unit.operations,
                    {
                        operation = operationName,
                        currRoomId = currRoomId,
                        currRole = unit,
                        roomId = roomId
                    }
                )
            end
            break
        end
    end
end

function EMap:doOperation(operation, environment)
    if operation.isEnable and operation.isEnable == 0 then
        print(operation.id .. " 操作不可用 跳过")
        return
    end

    local doFunc = function()
        -- 条件成立 执行结果
        if self:__conditionsIsTrue(operation.conditions, operation.condOperator, environment) then
            print("执行成功结果")
            self:doResults(operation.results, environment)
        else
            print("执行失败结果")
            self:doResults(operation.faildResults, environment)
        end
    end

    local printFunc = function()
        local name = ""
        local id = ""

        if environment.currRole ~= nil then
            id = environment.currRole.id
            name = environment.currRole.name
        elseif environment.currRoomId ~= nil then
            id = environment.currRoomId
        end

        print("------- 开始执行 " .. id .. "  ： 【 " .. operation.id .. "】 -------")

        doFunc()

        print("------------ 执行结束 ：【" .. operation.id .. "】 -------------\n")
    end

    printFunc()

    --@desc 检查任务分支
    self:checkMapBranch(operation, environment)
end

--@desc 任务分支触发检查
function EMap:checkMapBranch(operation, environment)

    if MapIsEmpty(self.branchMap) == true then
       return 
    end

    -- 检测是否触发副本分支跳转
    for k, branch in pairs(self.branchMap) do
        -- print("===== " .. "分支" .. k .. " =====")
        -- print("当前节点 = " .. branch.currNodeId)
        for k, triggerNode in pairs(branch.nodeMap[branch.currNodeId].triggerMap) do
            -- print("当前可触发的分支点")
            -- Helper:print_lua_table_ChunWai(triggerNode)
            for i, trigger in ipairs(triggerNode.triggerList) do
                if
                    trigger.objType == "room" and environment.currRoomId == trigger.objId and
                        trigger.objOperationId == operation.id
                 then
                    branch.currNodeId = trigger.id
                    print("===== 执行分支 " .. branch.currNodeId .. " 操作 =====")
                    -- PopText("跳转分支" .. branch.currNodeId)
                    for i, operation in ipairs(branch.nodeMap[branch.currNodeId].operations) do
                        self:doOperation(
                            operation,
                            {
                                mapLayer = environment.mapLayer,
                                currRoomId = environment.currRoomId,
                                branchId = branch.id,
                                nodeId = trigger.id,
                                operationId = operation.id
                            }
                        )
                    end
                elseif
                    trigger.objType == "unit" and environment.currRole and environment.currRole.id == trigger.objId and
                        trigger.objOperationId == operation.id
                 then
                    branch.currNodeId = trigger.id
                    print("===== 执行分支 " .. branch.currNodeId .. " 操作 =====")
                    -- PopText("跳转分支" .. branch.currNodeId)
                    for i, operation in ipairs(branch.nodeMap[branch.currNodeId].operations) do
                        self:doOperation(
                            operation,
                            {
                                mapLayer = environment.mapLayer,
                                currRoomId = environment.currRoomId,
                                branchId = branch.id,
                                nodeId = trigger.id,
                                operationId = operation.id
                            }
                        )
                    end
                end
                self:getPlayer():saveMapNode(self.id, branch.id, branch.currNodeId)
            end
        end
    end
end

--@desc 刷新节点事件
function EMap:refreshBranchEvent()
    local mapStore = self:getPlayer():getAttr("mapStore")

    if MapIsEmpty(mapStore[self.id]) then
        return
    end

    local getParentId = function(nodeMap, nodeId)
        local node = nodeMap[nodeId]

        local parentId = node.parentId

        return parentId
    end

    --@desc 储存要要执行的任务节点。
    local eventList = {}
    for branchId, currNodeId in pairs(mapStore[self.id]) do
        eventList[branchId] = {}
        local nodeMap = self.branchMap[branchId].nodeMap

        self.branchMap[branchId].currNodeId = currNodeId

        local node = nodeMap[currNodeId]

        local nodeId = node.id
        table.insert(eventList[branchId], nodeId)
        while true do
            local parentId = getParentId(nodeMap, nodeId)
            if parentId == nil then
                break
            else
                table.insert(eventList[branchId], 1, parentId)
                nodeId = parentId
            end
        end
    end

    -- Helper:print_lua_table(self.branchMap)
    for branchId, node_id_list in pairs(eventList) do
        local branch = self.branchMap[branchId]
        for index, nodeId in ipairs(node_id_list) do
            local node = branch.nodeMap[nodeId]

            if MapIsEmpty(node.operations) == false then
                for _, operation in ipairs(node.operations) do
                    if operation.operationName ~= "节点奖励" then
                        self:doOperation(
                            operation,
                            {
                                mapLayer = self.__MapLayer
                            }
                        )
                    end
                end
            end
        end
    end
end

--@desc: 创建environment对象
--@author:Liang SongQiang
--@time:2018-12-10 20:49:56
function EMap:createEnvironment(roleId, operationName, callback)
    local environment = {
        map = self,
        mapLayer = self.__MapLayer,
        currRoomId = self:getCurrRoomId(),
        operationName = operationName,
        callback = Helper:getDef(callback, EMPTY_FUNC)
    }

    if roleId ~= nil then
        environment.currRole = self:getRole(roleId)
    end

    return environment
end

--@desc: 根据名字执行操作
--@author:Liang SongQiang
--@time:2018-12-10 20:50:23
function EMap:doOperationByName(name, operations, environment)
    if MapIsEmpty(operations) == false then
        for i, v in ipairs(operations) do
            if v.operationName and v.operationName == name then
                self:doOperation(v, environment)
            end
        end
    end
end

--@desc: 根据操作ID执行操作
--@author:Liang SongQiang
--@time:2018-12-10 20:50:59
function EMap:doOperationById(id, operations, environment)
    if MapIsEmpty(operations) == false then
        for i, v in ipairs(operations) do
            if v.id == id then
                self:doOperation(v, environment)
            end
        end
    end
end

--@desc override
function EMap:dropItem(roomId, itemId, count)
    if not roomId or not itemId then
        return
    end
    local item = Item:getOneItemByKey(itemId)
    if item == nil then
        if PRINT_MODE == 1 then
            assert(nil, "这个物品的资源不存在, 物品ID = " .. tostring(itemId))
        end
    end

    count = Helper:getDef(count, 1)
    local desc = "这是".. Helper:numberCast(count) .. tostring(item.unit) .. tostring(item.name).."。"
    local itemBox = {
        type = "item",
        subType = "item",
        id = tostring(item.name) .. tostring(Helper:getOnlyId()),
        baseId = itemId,
        name = tostring(item.name),
        dsc = desc,
        canSee = true, -- 可见
        operations = {}
    }

    local result = OperationFactory:createResult("拾取物品",count)
    local operation = OperationFactory:createNoConditionBtnOperation("拾取", {result})
    table.insert(itemBox.operations, operation)
    self:createRole(itemBox) -- 创建打开的箱子
    self:addRoomRole(roomId, itemBox.id)
end

Decorator:after(
    EMap,
    "addRoomRole",
    function(funcName, self, roomId, roleId)
        self:__doRoleOperationInCurrRoomByName("NPC进入房间", roleId, roomId)
    end
)

return EMap
00000000000000
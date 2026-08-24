local OperationFactory = {}

local operation_template = {
    id = "", -- 此ID用于分支触发判断用
    isEnable = 1, -- 此操作是否可用
    isVisible = 1, -- 控制按钮显示
    operationButton = "", -- 匹配按钮触发的操作用
    operationName = "", --匹配不是按钮触发的操作用
    condOperator = [[and]], -- 条件判断逻辑
    conditions = {}, -- 条件
    results = {}, -- 条件成功执行的结果
    faildResults = {} -- 条件失败执行的结果
}

--@desc: 创建无条件按钮
--@author:Liang SongQiang
--@time:2019-01-03 10:19:42
--@btnName:按钮名字
--@successResultList: 成功结果list
function OperationFactory:createNoConditionBtnOperation(btnName, successResultList)
    local operation = self:getOpertionTemplate()

    successResultList = Helper:getDef(successResultList, {})

    operation.operationButton = btnName

    for i, result in ipairs(successResultList) do
        if type(result) == "table" then
            table.insert(operation.results, result)
        end
    end

    return operation
end

--@desc: 创建无条件事件触发结果操作
--@author:Liang SongQiang
--@time:2019-06-11 15:40:21
--@eventNama: 触发事件的索引
--@successResultList: 成功结果list
function OperationFactory:createNoConditionEventOperation(eventName,successResultList)
    local operation = self:getOpertionTemplate()

    successResultList = Helper:getDef(successResultList, {})

    operation.operationName = eventName

    for i, result in ipairs(successResultList) do
        if type(result) == "table" then
            table.insert(operation.results, result)
        end
    end

    return operation
end

--@desc: 获取一个默认操作
--@author:Liang SongQiang
--@time:2019-01-02 17:55:48
function OperationFactory:getOpertionTemplate()
    local operation = clone(operation_template)
    operation.id = self:createOpertionId()
    return operation
end

--@desc 获取一个随机操作的Id
function OperationFactory:createOpertionId()
    --@desc opp：operation program 程序生成
    local id = "opp" .. Helper:getOnlyId()

    return id
end

--@desc: 创建一个结果
--@author:Liang SongQiang
--@time:2019-01-02 17:47:29
--@resultName:
--@args: 参数列表
function OperationFactory:createResult(resultName, ...)
    local result = {
        arg1 = resultName
    }

    for i, value in ipairs({...}) do
        result["arg" .. tostring(i + 1)] = value
    end

    return result
end

--@desc: 创建一个条件对象
--@author:Liang SongQiang
--@time:2018-12-11 17:36:19
function OperationFactory:createCondition(conditionName, ...)
    local condition = {
        arg1 = conditionName
    }
    for i, v in ipairs({...}) do
        condition["arg" .. tostring(i + 1)] = v
    end

    return condition
end

return OperationFactory
00000000000000
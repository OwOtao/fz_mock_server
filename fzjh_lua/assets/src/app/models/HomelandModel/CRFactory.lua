local CRFactory = {}

--@desc: 创建一个条件对象
--@author:Liang SongQiang
--@time:2018-08-06 12:16:24
--@index: 按钮触发的索引
local function btnCondition(index)
    local condition = {}

    condition.arg1 = "玩家操作"

    condition.arg2 = "操作" .. index

    return condition
end

--@desc: 创建一个结果对象
--@author:Liang SongQiang
--@time:2018-08-06 12:15:56
--@resultName:调用的条件结果名字
--@args: 调用条件结果需要用到的参数
local function btnResult(resultName, ...)
    local result = {}

    result.arg1 = resultName

    for i, v in ipairs({...}) do
        result["arg" .. tostring(i + 1)] = v
    end

    return result
end

--@desc: 创建按钮相关的条件结果
--@author:Liang SongQiang
--@time:2018-08-06 12:07:59
--@role:需要创建的人物
--@btnName:按钮名字
--@resultName:调用的条件结果名字
--@args: 调用条件结果要用的参数
function CRFactory:createBtnCR(role, btnName, resultName, ...)
    local btnIndex = self:initFuncBtnIndex(role)

    local condition = btnCondition(btnIndex)

    local result = btnResult(resultName, ...)

    role["caozuoName" .. btnIndex] = btnName
    role["caozuo" .. btnIndex] = false

    local conAndResult = {
        conditionRelation = "and",
        conditions = {},
        results = {}
    }

    if role.btnFuncIndex == nil then
        role.btnFuncIndex = {}
    end

    role.btnFuncIndex[resultName] = btnIndex

    table.insert(conAndResult.conditions, condition)
    table.insert(conAndResult.results, result)

    if PRINT_MODE == 1 then
        print("---------------- create btn cr start ----------------")
        Helper:print_lua_table(role.btnFuncIndex)
        print("--------------- con result ---------------")
        Helper:print_lua_table(conAndResult)
        print("---------------- create btn cr end ----------------\n")
    end

    table.insert(role.conditionAndResults, conAndResult)
end

--@desc: 创建按钮索引
--@author:Liang SongQiang
--@time:2018-08-06 12:09:40
--@role: 对应的role
--@return 按钮索引值
function CRFactory:initFuncBtnIndex(role)
    local index = 0

    for i, v in ipairs(role.conditionAndResults) do
        if v.conditions then
            --@desc 查找按钮索引
            for _, condition in ipairs(v.conditions) do
                if condition.arg1 == "玩家操作" then
                    local caozuo_index = string.split(condition.arg2, "操作")[2]
                    if tonumber(caozuo_index) > index then
                        index = tonumber(caozuo_index)
                    end
                end
            end
        end
    end

    return index + 1
end

--@desc: 开启或关闭人物某个按钮功能
--@author:Liang SongQiang
--@time:2018-08-06 14:20:12
--@role:操作的人物
--@funcName:调用的结果名
--@funcType: open 、 close
function CRFactory:openOrCloseBtnFunc(role, funcName, funcType)
    if role.btnFuncIndex == nil then
        return
    end

    if role.btnFuncIndex[tostring(funcName)] == nil then
        return
    end

    local index = role.btnFuncIndex[tostring(funcName)]

    switch(
        funcType,
        {
            ["open"] = function(index)
                role["caozuo" .. index] = true
            end,
            ["close"] = function(index)
                role["caozuo" .. index] = false
            end,
            ["default"] = function(index)
                role["caozuo" .. index] = false
            end
        },
        index
    )
end


return CRFactory
000
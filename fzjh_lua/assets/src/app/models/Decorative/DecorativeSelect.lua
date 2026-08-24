local DecorativeSelect = {}
--@RefType [src.app.views.layer.ShenBingLayer.CommonLayer.binding#binding]
local binding = require("app.views.layer.ShenBingLayer.CommonLayer.binding")

local _list = {
    "mianju1000",
    "mianju1001",
    "mianju1002",
    "mianju1003",
    "mianju1004",
    "mianju1005",
    "mianju1006",
    "mianju1007",
    "mianju1008",

}

local ROW_COUNT = 4

function DecorativeSelect:setSelectList(selectList)
    -- selectList = _list

    local resultList = {}
    local count = 1
    local data = {}
    for i = 1, #selectList do
        data = {}
        local maskId = selectList[i]

        if not resultList[count] then
            resultList[count] = {}
        end

        data = binding.bindable({
            maskId = maskId,
            state = 0
        })

        table.insert(resultList[count], data)

        if i % ROW_COUNT == 0 then
            count = count + 1
        end
    end

    return resultList
end

return DecorativeSelect
000000000
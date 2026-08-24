local SeedLayer = {}

local _land = {}
local _map = {}

function SeedLayer:showLayer(land,map)
    _land = land
    _map = map
    PopupLayerController:showLayer(
        "ShenBingBagLayer",
        function(layer)
            --@RefType [app.views.layer.ShenBingLayer.CommonLayer.ShenBingBagLayer#ShenBingBagLayer]
            local layer = layer

            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local bagItems = role:getItems()

            layer:setLeftName("背包")
            layer:setRightName("土地")

            for i, item in ipairs(bagItems) do
                local itemAttr = Item:getOneItemByKey(item.itemId)
                if itemAttr.type == "种子" then
                    local temp = {
                        itemId = itemAttr.id,
                        type = itemAttr.type,
                        count = item.count
                    }
                    layer:pushItemToLeftList(temp)
                end
            end

            layer:setCondiPushRightList(
                function(leftList, rightList, item)
                    if #rightList >= 1 then
                        PopText("只能放一颗种子。")
                        return false
                    end

                    -- local itemAttr = Item:getOneItemByKey(item.itemId)

                    if item.type ~= "种子" then
                        PopText("土地只能放入种子。")
                        return false
                    end

                    return true
                end
            )

            layer:btnRightClickFunc(
                function(leftList, rightList)
                    local result = self:seed(leftList, rightList)

                    if not result then
                        return
                    end

                    layer:destory()
                end,
                "播种"
            )
            layer:btnLeftClickFunc(
                function()
                    layer:destory()
                end
            ,"取消"
            )

            layer:showLayer()
        end
    )
end

function SeedLayer:seed(leftList, rightList)
    if #rightList == 0 then
        PopText("请放入种子。")
        return
    end

    local item = rightList[1]

    --@RefType [app.models.HomelandModel.SeedModel#SeedModel]
    local SeedModel = require("app.models.HomelandModel.SeedModel")

    local result, msg = SeedModel:seed(item, _land,_map)

    if not result then
        PopText(msg)
    end

    return result
end

return SeedLayer
0000
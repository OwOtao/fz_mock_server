local ItemShowPanelConf = {}

local listById = {}

local listByType = {
    ["家具"] = "FurnitureBackLayer"
}


function ItemShowPanelConf:getById( id )
    return listById[id]
end

function ItemShowPanelConf:getByType( item_type )
    return listByType[item_type]
end

function ItemShowPanelConf:getLayerName(itemAttr)
    local layerName 

    layerName = self:getById(itemAttr.id)

    if layerName == nil then
        layerName = self:getByType(itemAttr.type)
    end

    return layerName
end

return  ItemShowPanelConf00000
local ColorManager = {
    _colors = {}
}

local function loadColorRes()
    local colorRes = require("script.others.colors")["ColorCode"]
    for k,v in pairs(colorRes) do
        if v.type == "颜色" then
            ColorManager._colors[k] = {
                id = v.id,
                index = v.index,
                type = v.type,
                color = loadstring("return "..v.color)()
            }
        else
            ColorManager._colors[k] = {
                id = v.id,
                index = v.index,
                type = v.type,
            }
        end
    end
end

loadColorRes()

function ColorManager:getColors()
    return self._colors
end



return ColorManager00000000000
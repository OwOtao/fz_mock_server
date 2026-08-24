local IconResManager = {
    __iconRes = {}
}

local function loadRes()
    local iconRes = require("script.common.commonIconConfig")["图标"]

    local __iconRes = {}
    for k, v in pairs(iconRes) do
        if not __iconRes[v.id] then
            __iconRes[v.id] = v.iconRes
        end
    end

    IconResManager.__iconRes = __iconRes
end

loadRes()

function IconResManager:getIconById(id)
    if self.__iconRes[id] then
        return self.__iconRes[id]
    end

    assert(false, "公用图标表找不到对应id,"..id.."不存在")
end

return IconResManager
000000000
local NewClass = require("third.class.NewClass")

local BorderConfigManager = require("app.models.HeadViewSystem.BorderConfigManager")

local MaskRes = require("script.others.maskRes")["Sheet1"]

local MaskAttr = {}

function MaskAttr:create(id)
    local p = MaskAttr.new()
    p._data = assert(MaskRes[tostring(id)], "没有这个面具资源 id = " .. id)
    return p
end

function MaskAttr:getId()
    return self._data.id
end

function MaskAttr:getResPath()
    return self._data.resPath
end

function MaskAttr:getAnimPath()
    return self._data.animPath
end

function MaskAttr:getAnimFolderPath()
    return self._data.animFolderPath
end

function MaskAttr:getEffectPath()
    return self._data.effectPath
end

function MaskAttr:getBgPath()
    return self._data.bgPath
end

function MaskAttr:getFramePath()
    local borderId = self:getBorderId()

    if borderId == nil then
        return
    end

    local roleBorderConfig = BorderConfigManager:getBorderConf(borderId)

    return roleBorderConfig:getFramePath()
end

function MaskAttr:getInfoFramePath()
    local borderId = self:getBorderId()

    if borderId == nil then
        return
    end

    local roleBorderConfig = BorderConfigManager:getBorderConf(borderId)

    return roleBorderConfig:getInfoFramePath()
end

function MaskAttr:isShowInfoFramePath()
    local borderId = self:getBorderId()

    if borderId == nil then
        return false
    end

    local roleBorderConfig = BorderConfigManager:getBorderConf(borderId)

    return not roleBorderConfig:isDefaultFrame()
end

function MaskAttr:getBackgroundPath()
    return self._data.backgroundPath
end

function MaskAttr:getBorderId()
    return self._data.borderId
end

function MaskAttr:getMaskDesc()
    return self._data.maskDesc or ""
end

return NewClass("MaskAttr", {}, MaskAttr)
000000000000000
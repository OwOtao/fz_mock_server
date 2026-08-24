local SpringFestivalUIContr = {}
  
local PrintLayerUI = {
    PrintLayerUI_1 = "Image/UI/SpringUI/printKuang.png",
}

local MainLayerBtnUI = {
    Button_task = "Image/UI/SpringUI/btn1.png",
    Button_jianghu = "Image/UI/SpringUI/btn2.png",
    Button_shimen = "Image/UI/SpringUI/btn2.png",
}

local MainLayerBtnUI9Scale = {
    Button_task = {x = 253, y = 11, width = 22, height = 195},
    Button_jianghu = {x = 33, y = 11, width = 22, height = 140},
    Button_shimen = {x = 33, y = 11, width = 22, height = 140},
}

local MainLayerBtnRecoverUI = {
    Button_task = "Image/UI/MainUI/anniu01.png",
    Button_jianghu = "Image/UI/MainUI/anniu02.png",
    Button_shimen = "Image/UI/MainUI/anniu02.png",
}

local MainLayerBtnUIRecover9Scale = {
    Button_task = {x = 15, y = 11, width = 938, height = 195},
    Button_jianghu = {x = 15, y = 11, width = 420, height = 140},
    Button_shimen ={x = 15, y = 11, width = 420, height = 140},
}

local AttrLayerBtnUI = {
    Button_dazuo = "Image/UI/SpringUI/btn3.png",
    Button_jiali = "Image/UI/SpringUI/btn3.png",
    Button_neidan = "Image/UI/SpringUI/btn3.png",
    Button_inherit = "Image/UI/SpringUI/btn3.png",
    Button_attrPoint = "Image/UI/SpringUI/btn3.png",
}

local AttrLayerBtnRecoverUI = {
    Button_dazuo = "Image/UI/AttrUI/xiaoanniu.png",
    Button_jiali = "Image/UI/AttrUI/xiaoanniu.png",
    Button_neidan = "Image/UI/AttrUI/xiaoanniu.png",
    Button_inherit = "Image/UI/AttrUI/xiaoanniu.png",
    Button_attrPoint = "Image/UI/AttrUI/xiaoanniu.png",
}

local JiangHuAttrLayerBtnUI = {
    Button_skills = "Image/UI/SpringUI/btn3.png",
    Button_tujian = "Image/UI/SpringUI/btn3.png",
    Button_guide = "Image/UI/SpringUI/btn3.png",
}

local JiangHuAttrLayerBtnRecoverUI = {
    Button_skills = "Image/UI/AttrUI/xiaoanniu.png",
    Button_tujian = "Image/UI/AttrUI/xiaoanniu.png",
    Button_guide = "Image/UI/AttrUI/xiaoanniu.png",
} 

local TableLayerSpriteUI = {
    Sprite_table = "Image/UI/SpringUI/dikuang.png",
}

local TableLayerSpriteRecoverUI = {
    Sprite_table = "Image/UI/AttrUI/tab.png",
}

local BackLayerUI = {
    Sprite_bottom = "SpringUI/xinnian.png",
    Sprite_background = "Image/UI/SpringUI/yearbackgurand.jpg",
}

local BackLayerOpenChangeLayer = {
    ["MainLayer"] = true,
    ["AttrLayer"] = true,
    ["JiangHuLayer"] = true
}

local SpringNodeUI = {
    PrintLayer = "Image_printKuangBg",
    MainLayer = "Panel_main",
    TitleLayer = "Panel_doorPlate",
    AttrLayer = "Panel_attr",
    JiangHuLayer = "Panel_attr",
}

function SpringFestivalUIContr:initMainLayerUI(layerUI)
    for btnName,texture in pairs(MainLayerBtnUI) do
        if layerUI[btnName] then
            layerUI[btnName]:loadTextureNormal(texture)
            layerUI[btnName]:setCapInsets(MainLayerBtnUI9Scale[btnName])
        end
    end
end

function SpringFestivalUIContr:initAttrLayerUI(layerUI)
    for btnName,texture in pairs(AttrLayerBtnUI) do
        if layerUI[btnName] then
            layerUI[btnName]:loadTextureNormal(texture)
        end
    end
end

function SpringFestivalUIContr:initJiangHuAttrLayerUI(layerUI)
    for btnName,texture in pairs(JiangHuAttrLayerBtnUI) do
        if layerUI[btnName] then
            layerUI[btnName]:loadTextureNormal(texture)
        end
    end
end

function SpringFestivalUIContr:initTableLayerUI(layerUI)
    for spriteName,texture in pairs(TableLayerSpriteUI) do
        if layerUI[spriteName] then
            layerUI[spriteName]:setTexture(texture)
        end
    end
end

function SpringFestivalUIContr:getBackLayerUITexture(UI)
    return BackLayerUI[UI]
end

function SpringFestivalUIContr:checkBackLayerUIIsOpen(layerName)
    return BackLayerOpenChangeLayer[layerName]
end

function SpringFestivalUIContr:getLayerAddNodeUI(layerName)
    local nodeName = SpringNodeUI[layerName]

    if nodeName then
        return self:__getUIByName(nodeName)
    end
end

function SpringFestivalUIContr:mainUIRecover(layerUI)
    for btnName,texture in pairs(MainLayerBtnRecoverUI) do
        if layerUI[btnName] then
            layerUI[btnName]:loadTextureNormal(texture)
            layerUI[btnName]:setCapInsets(MainLayerBtnUIRecover9Scale[btnName])
        end
    end
end

function SpringFestivalUIContr:attrUIRecover(layerUI)
    for btnName,texture in pairs(AttrLayerBtnRecoverUI) do
        if layerUI[btnName] then
            layerUI[btnName]:loadTextureNormal(texture)
        end
    end
end

function SpringFestivalUIContr:jiangHuAttrUIRecover(layerUI)
    for btnName,texture in pairs(JiangHuAttrLayerBtnRecoverUI) do
        if layerUI[btnName] then
            layerUI[btnName]:loadTextureNormal(texture)
        end
    end
end

function SpringFestivalUIContr:tableUIRecover(layerUI)
    for spriteName,texture in pairs(TableLayerSpriteRecoverUI) do
        if layerUI[spriteName] then
            layerUI[spriteName]:setTexture(texture)
        end
    end
end

function SpringFestivalUIContr:isOpen()
    if GetTime() > Helper:getTimeStampWithStringDate("20220115", 0) and GetTime() < Helper:getTimeStampWithStringDate("20220226", 0) then
        self:initUI()
        return true
    end

    return false
end

function SpringFestivalUIContr:initUI()
    if self._initUI ~= true then
        self._initUI = true
        self:__loadUI()
    end
end

function SpringFestivalUIContr:__loadUI()
    self:__releaseUI()

    self._UI = require("Layer/PartUI/SpringUI.lua").create()['root']
    Helper:convertUI(self._UI)

    self._UI:retain()
end

function SpringFestivalUIContr:__releaseUI()
    if self._UI then
        self._UI:release()
        self._UI = nil
    end
end

function SpringFestivalUIContr:__getUIByName(name)
    local ui = assert(self._UI[name], "没有找到这个UI")
    return ui:clone()
end

return SpringFestivalUIContr00000000000
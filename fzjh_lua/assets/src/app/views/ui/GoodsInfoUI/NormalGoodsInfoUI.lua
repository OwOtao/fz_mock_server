local NormalGoodsInfoUI = class("NormalGoodsInfoUI", LayerEx)

function NormalGoodsInfoUI:create()
    local p = NormalGoodsInfoUI:new()
    p:init()
    return p
end

function NormalGoodsInfoUI:init()
    self._UI = require("Layer/GoodsInfo/NormalGoodsInfoUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function NormalGoodsInfoUI:showUI()
    self:show()
end

function NormalGoodsInfoUI:hideUI()
    self:hide()
end

function NormalGoodsInfoUI:setTitle(text)
    self.Text_Tital:setString(text)
end

function NormalGoodsInfoUI:setGoodsName(text)
    self.Text_name:setString(text)
end

function NormalGoodsInfoUI:setGoodsDesc(text)
    self.Text_desc:setString(text)
end

function NormalGoodsInfoUI:setGoodsImageIcon(image)
    self.Image_icon:loadTexture(image,0)
end

function NormalGoodsInfoUI:setButtonBackVisible(bool)
    self.Button_back:setVisible(bool)
end

function NormalGoodsInfoUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

Helper:classDefNodeGetInstance(NormalGoodsInfoUI)

return NormalGoodsInfoUI
0000000000000000
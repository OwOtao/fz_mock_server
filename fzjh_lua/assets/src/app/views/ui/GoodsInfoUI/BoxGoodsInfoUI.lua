local BoxGoodsInfoUI = class("BoxGoodsInfoUI", LayerEx)

function BoxGoodsInfoUI:create()
    local p = BoxGoodsInfoUI:new()
    p:init()
    return p
end

function BoxGoodsInfoUI:init()
    self._UI = require("Layer/GoodsInfo/BoxGoodsInfoUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function BoxGoodsInfoUI:showUI()
    self:show()
end

function BoxGoodsInfoUI:hideUI()
    self:hide()
end

function BoxGoodsInfoUI:setTitle(text)
    self.Text_title:setString(text)
end

function BoxGoodsInfoUI:setTextName(name)
    self.Text_name:setString(name)
end

function BoxGoodsInfoUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function BoxGoodsInfoUI:setButtonBackVisible(bool)
    self.Button_back:setVisible(bool)
end

function BoxGoodsInfoUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function BoxGoodsInfoUI:setGoodsUIVisible(visible)
    self.Panel_addNode:setVisible(visible)
end

function BoxGoodsInfoUI:addGoodsUI(ui)
    self.Panel_addNode:addChild(ui)
end

function BoxGoodsInfoUI:removeGoodsUI()
    self.Panel_addNode:removeAllChildren()
end

function BoxGoodsInfoUI:setGoodsList(goodsList)
    self.ListView_1:removeAllItems()

    for i = 1, #goodsList, 1 do
        local itemPanel = self:__getItemPanel()
        self:__initItemPanel(itemPanel, goodsList[i])
        if i % 2 == 0 then
            local panel = self.ListView_1:getItem(math.floor(i/2) - 1)
            panel:addChild(itemPanel)	
            itemPanel:setPosition(cc.p(500, 0))
        else
            local panel = self.Panel_1:clone()
            panel:addChild(itemPanel)	
            itemPanel:setPosition(cc.p(10, 0))
            self.ListView_1:pushBackCustomItem(panel)
        end
    end
end

function BoxGoodsInfoUI:__getItemPanel()
    local panel = self.Panel_item:clone()
    Helper:convertUIByParent(panel)
    return panel
end

function BoxGoodsInfoUI:__initItemPanel(panel, panelInfo)
    panel.Text_1:setString(panelInfo.name)
    panel:releaseFunc(function()
        if panelInfo.func then
            panelInfo.func()
        end
    end)
end

return BoxGoodsInfoUI
000000000000000
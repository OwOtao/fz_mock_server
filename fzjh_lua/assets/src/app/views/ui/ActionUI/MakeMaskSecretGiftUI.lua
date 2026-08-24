local MakeMaskSecretGiftUI = class("MakeMaskSecretGiftUI", LayerEx)

function MakeMaskSecretGiftUI:create()
    local p = MakeMaskSecretGiftUI:new()
    p:init()
    return p
end

function MakeMaskSecretGiftUI:init()
    self._UI = require("Layer/ActionUI/MakeMaskSecretGiftUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function MakeMaskSecretGiftUI:showUI()
    self:show()
end

function MakeMaskSecretGiftUI:hideUI()
    self:hide()
end

function MakeMaskSecretGiftUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function MakeMaskSecretGiftUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function MakeMaskSecretGiftUI:setTextDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function MakeMaskSecretGiftUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MakeMaskSecretGiftUI:createListViewItem()
    local itemUI = self.Panel_mask:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function MakeMaskSecretGiftUI:addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

function MakeMaskSecretGiftUI:removeListViewAllItems()
    self.ListView_item:removeAllItems()
end

return MakeMaskSecretGiftUI
00000
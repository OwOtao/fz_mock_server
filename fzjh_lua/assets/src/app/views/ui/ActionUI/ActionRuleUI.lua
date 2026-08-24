local ActionRuleUI = class("ActionRuleUI", LayerEx)

function ActionRuleUI:create()
    local p = ActionRuleUI:new()
    p:init()
    return p
end

function ActionRuleUI:init()
    self._UI = require("Layer/ActionUI/ActionRuleUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_info:setScrollBarEnabled(false)

    self:setVisible(false)
end

function ActionRuleUI:showUI()
    self:show()
    self:setVisible(true)
end

function ActionRuleUI:hideUI()
    self:hide()
    self:setVisible(false)
end

function ActionRuleUI:setButtonBack(func)
    self.Panel_bg:releaseFunc(
        function()
            func()
        end
    )
end

function ActionRuleUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function ActionRuleUI:showPanel_1(str)
    self.ListView_info:removeAllItems()

    local panel = self:__clonePanel_1()
    local text = self:__cloneText_1()
    text:setTextAreaSize({width = 980, height = 0})
    text:ignoreContentAdaptWithSize(true)
    text:setString(str)

    local contentSize = text:getAutoRenderSize()
    panel:setSize({width = 1050, height = contentSize.height + 10})
    panel:addChild(text)
    text:setPosition(cc.p(36,0))

    self.ListView_info:pushBackCustomItem(panel)
end

function ActionRuleUI:__clonePanel_1()
    local itemUI = self.Panel_1:clone()
    return itemUI
end

function ActionRuleUI:__cloneText_1()
    local text = self.Text_1:clone()
    return text
end

Helper:classDefNodeGetInstance(ActionRuleUI)
return ActionRuleUI
000000000000000
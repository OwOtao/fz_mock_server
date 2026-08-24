local JiangHuYiRenLuAction2UI = class("JiangHuYiRenLuAction2UI", LayerEx)

function JiangHuYiRenLuAction2UI:create()
    local p = JiangHuYiRenLuAction2UI:new()
    p:init()
    return p
end

function JiangHuYiRenLuAction2UI:init()
    self._UI = require("Layer/ActionUI/JiangHuYiRenLuAction2UI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function JiangHuYiRenLuAction2UI:showUI()
    self:show()
end

function JiangHuYiRenLuAction2UI:hideUI()
    self:hide()
end

function JiangHuYiRenLuAction2UI:setPanelBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function JiangHuYiRenLuAction2UI:setTextCurrency(desc)
    self.Text_currency:setString(Helper:getDef(desc, ""))
end

function JiangHuYiRenLuAction2UI:setTextExchangeCurrency(desc)
    self.Text_exchangeCurrency:setString(Helper:getDef(desc, ""))
end

function JiangHuYiRenLuAction2UI:setTextTitle(name)
    self.Text_title:setString(Helper:getDef(name, ""))
end

function JiangHuYiRenLuAction2UI:setDesc(name)
    self.Text_5:setString(Helper:getDef(name, ""))
end

function JiangHuYiRenLuAction2UI:initPanel1(itemInfo)
    self:__updatePanelInfo("Panel_item_1", itemInfo.name, itemInfo.icon, itemInfo.number)
end

function JiangHuYiRenLuAction2UI:initPanel2(itemInfo)
    self:__updatePanelInfo("Panel_item_2", itemInfo.name, itemInfo.icon, itemInfo.number)
end

function JiangHuYiRenLuAction2UI:initPanel3(itemInfo)
    self:__updatePanelInfo("Panel_item_3", itemInfo.name, itemInfo.icon, itemInfo.number)
end

function JiangHuYiRenLuAction2UI:initPanel4(itemInfo)
    self:__updatePanelInfo("Panel_item_4", itemInfo.name, itemInfo.icon, itemInfo.number)
end

function JiangHuYiRenLuAction2UI:__updatePanelInfo(panelName, textName, icon, number)
    if self[panelName] == nil then
        assert(false, "JiangHuYiRenLuAction2UI:__updatePanelInfo UI不存在" .. panelName)
    end

    self[panelName].Text_name:setTextColor({r = 255, g = 255, b = 255})

    self[panelName].Text_name:setString(textName)

    if icon ~= nil and icon ~= "" then
        self[panelName].Image_zhuzi:loadTexture(icon)
    end

    self[panelName].Text_num:setString(number)
end

function JiangHuYiRenLuAction2UI:setButtonClickFunc1(name, clickFunc)
    clickFunc = Helper:getDef(clickFunc, EMPTY_FUNC)
    self.Button_1.Text_buttonName:setString(name)
    self.Button_1:releaseFunc(
        function()
            clickFunc()
        end
    )
end

function JiangHuYiRenLuAction2UI:setButtonClickFunc2(name, clickFunc)
    clickFunc = Helper:getDef(clickFunc, EMPTY_FUNC)
    self.Button_2.Text_buttonName:setString(name)
    self.Button_2:releaseFunc(
        function()
            clickFunc()
        end
    )
end

function JiangHuYiRenLuAction2UI:setButtonClickFunc3(name, clickFunc)
    clickFunc = Helper:getDef(clickFunc, EMPTY_FUNC)
    self.Button_3.Text_buttonName:setString(name)
    self.Button_3:releaseFunc(
        function()
            clickFunc()
        end
    )
end

function JiangHuYiRenLuAction2UI:setPanelCostText1(desc)
    self.Panel_Info1.Text_Cost1:setString(desc)
end


function JiangHuYiRenLuAction2UI:setPanelCostText2(desc)
    self.Panel_Info2.Text_Cost1:setString(desc)
end

function JiangHuYiRenLuAction2UI:setPanelCostImage1(imageUrl)
    if imageUrl == nil then
        imageUrl = "Image/UI/StoreUI/sc04.png"
    end
    self.Panel_Info1.Image_29:loadTexture(imageUrl)
end

function JiangHuYiRenLuAction2UI:setPanelCostImage2(imageUrl)
    if imageUrl == nil then
        imageUrl = "Image/UI/StoreUI/sc04.png"
    end
    self.Panel_Info2.Image_29:loadTexture(imageUrl)
end

function JiangHuYiRenLuAction2UI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return JiangHuYiRenLuAction2UI
0000000
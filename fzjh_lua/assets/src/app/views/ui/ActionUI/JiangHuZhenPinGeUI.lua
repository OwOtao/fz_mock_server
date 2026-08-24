local JiangHuZhenPinGeUI = class("JiangHuZhenPinGeUI", LayerEx)

function JiangHuZhenPinGeUI:create()
    local p = JiangHuZhenPinGeUI:new()
    p:init()
    return p
end

function JiangHuZhenPinGeUI:init()
    self._UI = require("Layer/ActionUI/JiangHuZhenPinGeUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function JiangHuZhenPinGeUI:showUI()
    self:show()
end

function JiangHuZhenPinGeUI:hideUI()
    self:hide()
end

function JiangHuZhenPinGeUI:setPanelBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function JiangHuZhenPinGeUI:setTextCurrency(desc)
    self.Text_currency:setString(Helper:getDef(desc, ""))
end

function JiangHuZhenPinGeUI:setTextExchangeCurrency(desc)
    self.Text_exchangeCurrency:setString(Helper:getDef(desc, ""))
end

function JiangHuZhenPinGeUI:setTextTitle(name)
    self.Text_title:setString(Helper:getDef(name, ""))
end

function JiangHuZhenPinGeUI:setDesc(name)
    self.Text_5:setString(Helper:getDef(name, ""))
end

function JiangHuZhenPinGeUI:initPanel(index, info)
    if self["Panel_item_"..tostring(index)] then
        self["Panel_item_"..tostring(index)].Text_name:setTextColor({r = 255, g = 255, b = 255})

        self["Panel_item_"..tostring(index)].Text_name:setString(info.name)

        self["Panel_item_"..tostring(index)].Image_zhuzi:loadTexture(info.icon)

        self["Panel_item_"..tostring(index)].Text_num:setString(info.number)

        self["Panel_item_"..tostring(index)]:releaseFunc(
            function()
                if info.func then
                    info.func()
                end
            end
        )
    end
end

function JiangHuZhenPinGeUI:setButtonClickFunc1(name, clickFunc)
    clickFunc = Helper:getDef(clickFunc, EMPTY_FUNC)
    self.Button_1.Text_buttonName:setString(name)
    self.Button_1:releaseFunc(
        function()
            clickFunc()
        end
    )
end

function JiangHuZhenPinGeUI:setButtonClickFunc2(name, clickFunc)
    clickFunc = Helper:getDef(clickFunc, EMPTY_FUNC)
    self.Button_2.Text_buttonName:setString(name)
    self.Button_2:releaseFunc(
        function()
            clickFunc()
        end
    )
end

function JiangHuZhenPinGeUI:setButtonClickFunc3(name, clickFunc)
    clickFunc = Helper:getDef(clickFunc, EMPTY_FUNC)
    self.Button_3.Text_buttonName:setString(name)
    self.Button_3:releaseFunc(
        function()
            clickFunc()
        end
    )
end

function JiangHuZhenPinGeUI:setPanelCostText1(desc)
    self.Panel_Info1.Text_Cost1:setString(desc)
end


function JiangHuZhenPinGeUI:setPanelCostText2(desc)
    self.Panel_Info2.Text_Cost1:setString(desc)
end

function JiangHuZhenPinGeUI:setPanelCostImage1(imageUrl)
    if imageUrl == nil then
        imageUrl = "Image/UI/StoreUI/sc04.png"
    end
    self.Panel_Info1.Image_29:loadTexture(imageUrl)
end

function JiangHuZhenPinGeUI:setPanelCostImage2(imageUrl)
    if imageUrl == nil then
        imageUrl = "Image/UI/StoreUI/sc04.png"
    end
    self.Panel_Info2.Image_29:loadTexture(imageUrl)
end

function JiangHuZhenPinGeUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function JiangHuZhenPinGeUI:setLoadingBarPercent(percent)
    percent = Helper:getDef(percent, 0)
    self.LoadingBar_1:setPercent(percent)
end

function JiangHuZhenPinGeUI:setTextCountStr(str)
    str = Helper:getDef(str, "0/15")
    self.Text_count:setString(str)
end

return JiangHuZhenPinGeUI
0000000000000000
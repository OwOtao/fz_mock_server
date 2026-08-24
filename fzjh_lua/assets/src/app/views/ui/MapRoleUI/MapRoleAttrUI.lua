local MapRoleAttrUI = class("MapRoleAttrUI", LayerEx)

function MapRoleAttrUI:create()
    local p = MapRoleAttrUI:new()
    p:init()
    return p
end

function MapRoleAttrUI:init()
    self.__ui = require("Layer/MapRoleUI/MapRoleAttrUI.lua").create()['root']

    self.__ui:addTo(self)
    
    Helper:convertUIByParent(self)
    
    self:setVisible(false)
end

function MapRoleAttrUI:showUI()
    self:setVisible(true)
end

function MapRoleAttrUI:hideUI()
    self:setVisible(false)
end

function MapRoleAttrUI:setTextDesc(text)
    self.Panel_attr.Text_desc:setString(text)
end

function MapRoleAttrUI:setTextQi(text)
    self.Panel_attr.Text_qi:setString(text)
end

function MapRoleAttrUI:setTextNeiLi(text)
    self.Panel_attr.Text_neili:setString(text)
end

function MapRoleAttrUI:setTextExp(text)
    self.Panel_attr.Text_jingyan:setString(text)
end

function MapRoleAttrUI:setTextWeiWang(text)
    self.Panel_attr.Text_weiwang:setString(text)
end

function MapRoleAttrUI:setTextMoney(text)
    self.Panel_attr.Text_money:setString(text)
end

function MapRoleAttrUI:setTextPot(text)
    self.Panel_attr.Text_pot:setString(text)
end

function MapRoleAttrUI:setQimaxPercent(percent)
    self.Panel_attr.Panel_qi.LoadingBar_qi_max:setPercent(percent)
end

function MapRoleAttrUI:setQiPercent(percent)
    self.Panel_attr.Panel_qi.LoadingBar_qi:setPercent(percent)
end

function MapRoleAttrUI:setNeiLiPercent(percent)
    self.Panel_attr.Panel_neili.LoadingBar_neili:setPercent(percent)
end

function MapRoleAttrUI:setButtonName(index, name)
    local panelButton = self.Panel_attr["Panel_"..index]
    if panelButton then
        panelButton.Text_name:setString(name)
    end
end

function MapRoleAttrUI:setButtonVisible(index, bool)
    local panelButton = self.Panel_attr["Panel_"..index]
    if panelButton then
        panelButton:setVisible(bool)
    end
end

function MapRoleAttrUI:setButtonFunc(index, func)
    local panelButton = self.Panel_attr["Panel_"..index]
    if panelButton then
        panelButton:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function MapRoleAttrUI:setButtonPercent(index, percent)
    local panelButton = self.Panel_attr["Panel_"..index]
    if panelButton then
        panelButton.LoadingBar_button:setPercent(percent)
    end
end

Helper:classDefNodeGetInstance(MapRoleAttrUI)
return MapRoleAttrUI
000
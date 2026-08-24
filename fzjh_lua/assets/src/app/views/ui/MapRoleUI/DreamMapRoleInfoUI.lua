local DreamMapRoleInfoUI = class("DreamMapRoleInfoUI", LayerEx)

function DreamMapRoleInfoUI:create()
    local p = DreamMapRoleInfoUI:new()
    p:init()
    return p
end

function DreamMapRoleInfoUI:init()
    self.__ui = require("Layer/MapRoleUI/DreamMapRoleInfoUI.lua").create()['root']

    self.__ui:addTo(self)
    
    Helper:convertUIByParent(self)
    
    self:setVisible(false)
end

function DreamMapRoleInfoUI:showUI()
    self:setVisible(true)
end

function DreamMapRoleInfoUI:hideUI()
    self:setVisible(false)
end

function DreamMapRoleInfoUI:getImageHead()
    return self.Panel_info.Image_head
end

function DreamMapRoleInfoUI:setTextName(text)
    self.Panel_info.Text_name:setString(text)
end

function DreamMapRoleInfoUI:setTextBirth(text)
    self.Panel_info.Text_chushen:setString(text)
end

function DreamMapRoleInfoUI:setTextSex(text)
    self.Panel_info.Text_sex:setString(text)
end

function DreamMapRoleInfoUI:setTextAge(text)
    self.Panel_info.Text_age:setString(text)
end

function DreamMapRoleInfoUI:setTextLv(text)
    self.Panel_info.Text_lv:setString(text)
end

function DreamMapRoleInfoUI:setTextEmotion(text)
    self.Panel_info.Text_emotion:setString(text)
end

function DreamMapRoleInfoUI:setTextCurrency(text)
    self.Panel_info.Text_huobi:setString(text)
end

function DreamMapRoleInfoUI:setTextQi(text)
    self.Panel_info.Text_qi:setString(text)
end

function DreamMapRoleInfoUI:setTextNeiLi(text)
    self.Panel_info.Text_neili:setString(text)
end

function DreamMapRoleInfoUI:setQimaxPercent(percent)
    self.Panel_info.Panel_qi.LoadingBar_qi_max:setPercent(percent)
end

function DreamMapRoleInfoUI:setQiPercent(percent)
    self.Panel_info.Panel_qi.LoadingBar_qi:setPercent(percent)
end

function DreamMapRoleInfoUI:setNeiLiPercent(percent)
    self.Panel_info.Panel_neili.LoadingBar_neili:setPercent(percent)
end

Helper:classDefNodeGetInstance(DreamMapRoleInfoUI)
return DreamMapRoleInfoUI
0000000000
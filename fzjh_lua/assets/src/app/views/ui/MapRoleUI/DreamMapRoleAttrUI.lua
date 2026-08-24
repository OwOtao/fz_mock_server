local DreamMapRoleAttrUI = class("DreamMapRoleAttrUI", LayerEx)

function DreamMapRoleAttrUI:create()
    local p = DreamMapRoleAttrUI:new()
    p:init()
    return p
end

function DreamMapRoleAttrUI:init()
    self.__ui = require("Layer/MapRoleUI/DreamMapRoleAttrUI.lua").create()['root']

    self.__ui:addTo(self)
    
    Helper:convertUIByParent(self)
    
    self:setVisible(false)
end

function DreamMapRoleAttrUI:showUI()
    self:setVisible(true)
end

function DreamMapRoleAttrUI:hideUI()
    self:setVisible(false)
end

function DreamMapRoleAttrUI:setTextMenPaiName(text)
    self.Panel_attr.Text_menpai:setString(text)
end

function DreamMapRoleAttrUI:setTextMenPaiDesc(text)
    self.Panel_attr.Text_menpaiinfo:setString(text)
end

function DreamMapRoleAttrUI:setTextCon(text)
    self.Panel_attr.Text_con:setString(text)
end

function DreamMapRoleAttrUI:setTextAtk(text)
    self.Panel_attr.Text_atk:setString(text)
end

function DreamMapRoleAttrUI:setTextStr(text)
    self.Panel_attr.Text_str:setString(text)
end

function DreamMapRoleAttrUI:setTextDodge(text)
    self.Panel_attr.Text_dodge:setString(text)
end

function DreamMapRoleAttrUI:setTextDex(text)
    self.Panel_attr.Text_dex:setString(text)
end

function DreamMapRoleAttrUI:setTextFangYu(text)
    self.Panel_attr.Text_fangyu:setString(text)
end

function DreamMapRoleAttrUI:setTextDamage(text)
    self.Panel_attr.Text_shanghai:setString(text)
end

function DreamMapRoleAttrUI:setTextZhengQi(text)
    self.Panel_attr.Text_zhengqi:setString(text)
end

function DreamMapRoleAttrUI:setTextFangHu(text)
    self.Panel_attr.Text_fanghu:setString(text)
end

Helper:classDefNodeGetInstance(DreamMapRoleAttrUI)
return DreamMapRoleAttrUI
00000000000
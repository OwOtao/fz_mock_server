local ChallengeMapRoleAttrUI = class("ChallengeMapRoleAttrUI", LayerEx)

function ChallengeMapRoleAttrUI:create()
    local p = ChallengeMapRoleAttrUI:new()
    p:init()
    return p
end

function ChallengeMapRoleAttrUI:init()
    self.__ui = require("Layer/MapRoleUI/ChallengeMapRoleAttrUI.lua").create()['root']

    self.__ui:addTo(self)
    
    Helper:convertUIByParent(self)
    
    self:setVisible(false)
end

function ChallengeMapRoleAttrUI:showUI()
    self:setVisible(true)
end

function ChallengeMapRoleAttrUI:hideUI()
    self:setVisible(false)
end

function ChallengeMapRoleAttrUI:setRoleAttrTextStr(index,attrText)
    if self.Panel_challengeRoleAttr["Text_crAttr_"..tostring(index)] then
        self.Panel_challengeRoleAttr["Text_crAttr_"..tostring(index)]:setString(attrText)
    end
end

function ChallengeMapRoleAttrUI:setRoleAttrTextVisible(index,visible)
    visible = Helper:getDef(visible,false)
    if self.Panel_challengeRoleAttr["Text_crAttr_"..tostring(index)] then
        self.Panel_challengeRoleAttr["Text_crAttr_"..tostring(index)]:setVisible(visible)
    end
end

Helper:classDefNodeGetInstance(ChallengeMapRoleAttrUI)
return ChallengeMapRoleAttrUI
000000000
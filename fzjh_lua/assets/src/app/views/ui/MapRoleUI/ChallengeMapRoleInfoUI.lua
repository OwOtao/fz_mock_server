local ChallengeMapRoleInfoUI = class("ChallengeMapRoleInfoUI", LayerEx)

function ChallengeMapRoleInfoUI:create()
    local p = ChallengeMapRoleInfoUI:new()
    p:init()
    return p
end

function ChallengeMapRoleInfoUI:init()
    self.__ui = require("Layer/MapRoleUI/ChallengeMapRoleInfoUI.lua").create()['root']

    self.__ui:addTo(self)
    
    Helper:convertUI(self)
    
    self:setVisible(false)
end

function ChallengeMapRoleInfoUI:showUI()
    self:setVisible(true)
end

function ChallengeMapRoleInfoUI:hideUI()
    self:setVisible(false)
end

function ChallengeMapRoleInfoUI:setRoleName(str)
    self.Text_crName:setString(str)
end

function ChallengeMapRoleInfoUI:setRoleFamily(str)
    self.Text_crFamily:setString(str)
end

function ChallengeMapRoleInfoUI:setRoleExp(str)
    self.Text_crExp:setString(str)
end

function ChallengeMapRoleInfoUI:setRoleLv(str)
    self.Text_crLv:setString(str)
end

function ChallengeMapRoleInfoUI:setRoleAge(str)
    self.Text_crAge:setString(str)
end

function ChallengeMapRoleInfoUI:setRoleNeiLiValue(value)
    self.Text_crNeili_value:setString(value)
end

function ChallengeMapRoleInfoUI:setRoleQiValue(value)
    self.Text_crQi_value:setString(value)
end

function ChallengeMapRoleInfoUI:setRoleNeiLiPercent(percent)
    self.LoadingBar_cr_neili:setPercent(percent)
end

function ChallengeMapRoleInfoUI:setRoleQiPercent(percent)
    self.LoadingBar_cr_qi:setPercent(percent)
end

function ChallengeMapRoleInfoUI:setRoleQiMaxPercent(percent)
    self.LoadingBar_cr_qi_max:setPercent(percent)
end

function ChallengeMapRoleInfoUI:createButton(index,posX,posY)
    if not self["Panel_button"..tostring(index)] then
		local panel = Resource:getUIByName("Panel_cd_button")
		Helper:convertUI(panel)
		self.Panel_challengeRoleInfo:addChild(panel)
		panel.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
		panel:move(cc.p(posX, posY))
		self["Panel_button"..tostring(index)] = panel
		self["LoadingBar_"..tostring(index)] = panel.LoadingBar_button
		self["Panel_button"..tostring(index)]:setVisible(false)
	end
end

function ChallengeMapRoleInfoUI:setButtonName(index,name)
    self["Panel_button"..tostring(index)].Text_name:setString(name)
end

function ChallengeMapRoleInfoUI:setButtonFunc(index,func)
    self["Panel_button"..tostring(index)]:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ChallengeMapRoleInfoUI:setButtonTouchEnable(index,enable)
    enable = Helper:getDef(enable,false)
    self["Panel_button"..tostring(index)]:setTouchEnabled(enable)
end

function ChallengeMapRoleInfoUI:setButtonVisible(index,visible)
    visible = Helper:getDef(visible,false)
    self["Panel_button"..tostring(index)]:setVisible(visible)
end

function ChallengeMapRoleInfoUI:setButtonPercent(index,percent)
    self["LoadingBar_"..tostring(index)]:setPercent(percent)
end

Helper:classDefNodeGetInstance(ChallengeMapRoleInfoUI)
return ChallengeMapRoleInfoUI
0000
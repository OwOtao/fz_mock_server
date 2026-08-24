local CommercialTimePrivilegeUI = class("CommercialTimePrivilegeUI", LayerEx)

function CommercialTimePrivilegeUI:create()
	local p = CommercialTimePrivilegeUI:new()
	p:init()
	return p
end

function CommercialTimePrivilegeUI:init()
    self._round = require("Layer/CommercialTimeUI/CommercialTimePrivilegeUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function CommercialTimePrivilegeUI:showUI()
    self:show()
end

function CommercialTimePrivilegeUI:hideUI()
    self:hide()
end

function CommercialTimePrivilegeUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function CommercialTimePrivilegeUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function CommercialTimePrivilegeUI:setTextDsc(text)
    self.Text_dsc:setString(text)
end

function CommercialTimePrivilegeUI:setTextPrivilege(text)
    self.Text_privilege:setString(text)
end

function CommercialTimePrivilegeUI:setTextExtra(text)
    self.Text_extra:setString(text)
end

function CommercialTimePrivilegeUI:setTextRuler(text)
    self.Text_ruler:setString(text)
end

function CommercialTimePrivilegeUI:setTextPrivilegeTimes(text)
    self.Text_privilege_times:setString(text)
end

function CommercialTimePrivilegeUI:setTextExpiredTime(text)
    self.Text_expired_time:setString(text)
end

function CommercialTimePrivilegeUI:setPrivilegeDescVisible(bool)
    self.Text_privilegeDesc:setVisible(bool)
end

function CommercialTimePrivilegeUI:setButtonExtraName(text)
	self.Button_1.Text_buttonName:setString(text)
end

function CommercialTimePrivilegeUI:setButtonExtraPosX(posX)
	self.Button_1:setPositionX(posX)
end

function CommercialTimePrivilegeUI:setButtonExtraEnable(isEnable)
	self.Button_1:setEnabled(isEnable)
end

function CommercialTimePrivilegeUI:setButtonExtraFunc(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CommercialTimePrivilegeUI:setButtonPrivilegeVisible(bool)
    self.Button_2:setVisible(bool)
end

function CommercialTimePrivilegeUI:setButtonPrivilegeFunc(func)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CommercialTimePrivilegeUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return CommercialTimePrivilegeUI00000000000
--
-- Author: TanQinJian
-- Date: 2020-04-15 14:27:27
--
local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
local PuRenManagementLayer = class("PuRenManagementLayer", LayerEx)

function PuRenManagementLayer:create()
	local p = PuRenManagementLayer:new()
	p:init()
	return p
end

function PuRenManagementLayer:init()
	local UI = require("Layer/HomelandUI/PuRenManagementUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self.Panel_bg:releaseFunc(function()
        PopupLayerController:hideLayer("PuRenManagementLayer", function(layer)
        	self:hide()
		end)
    end)
end

function PuRenManagementLayer:showLayer(map)
	self:initUI(map)
    self:show()
end

function PuRenManagementLayer:initUI(map)
	local desc = "#ch#，这是府上的仆人名单，不知有何吩咐？"
	desc = HomelandDesc:subChengHuText(desc)
	self.Text_desc:setString(desc)

	local PuRenModel = require("app.models.HomelandModel.HomelandRoleModel.PuRenModel")
	local puRenInfo = map.puRenInfo
	self.ListView_role:removeAllItems()
	
	Helper:print_lua_table(puRenInfo)
	local role_index = 1
	for k,v in pairs(puRenInfo) do 
		local panelIndex = Helper:mathFloor((role_index - 1) / 2)

        local panel = self.ListView_role:getItem(panelIndex)

        if panel == nil then
            panel = self.Panel_role:clone()
            local button_role = self.Button_role:clone()
            Helper:convertUIByParent(button_role)
            button_role.Text_buttonName:setString(v.name)
            button_role.Text_buttonName:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
            panel:addChild(button_role)
            button_role:setPosition(200, 60)
            button_role:releaseFunc(function()
				PopupLayerController:showLayer("HomelandRoleInfoLayer", function(layer)
					local puRen = map:getRole(v.rwId)
					layer:showLayer(puRen,map,true)
				end)
			end)
            self.ListView_role:pushBackCustomItem(panel)
        else
            local button_role = self.Button_role:clone()
            Helper:convertUIByParent(button_role)
            button_role.Text_buttonName:setString(v.name)
            button_role.Text_buttonName:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
            panel:addChild(button_role)
            button_role:setPosition(600, 60)
            button_role:releaseFunc(function()
				PopupLayerController:showLayer("HomelandRoleInfoLayer", function(layer)
					local puRen = map:getRole(v.rwId)
					layer:showLayer(puRen,map,true)
				end)
			end)
        end
        role_index = role_index + 1 
	end

end

Helper:classDefNodeGetInstance(PuRenManagementLayer)

return PuRenManagementLayer000000000000000
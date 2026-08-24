local AcupointActivateUI = class("AcupointActivateUI", LayerEx)

function AcupointActivateUI:create()
    local p = AcupointActivateUI:new()
    p:init()
    return p
end

function AcupointActivateUI:init()
    self.__ui = require("Layer/MeridianUI/HiddenMeridian/AcupointActivateUI.lua").create()["root"]

    self.__ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function AcupointActivateUI:showUI()
    self:show()
end

function AcupointActivateUI:hideUI()
    self:hide()
end

function AcupointActivateUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function AcupointActivateUI:setTextResouce(text)
    self.Text_resouce:setString(text)
end

function AcupointActivateUI:setTextTime(text)
    self.Text_time:setString(text)
end

function AcupointActivateUI:setButton1(name,func)
    self.Button_1.Text_ButtonName:setString(name)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function AcupointActivateUI:setButton2(name,func)
    self.Button_2.Text_ButtonName:setString(name)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return AcupointActivateUI
0
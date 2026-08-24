local HiddenMeridianUnlockBuffUI = class("HiddenMeridianUnlockBuffUI", LayerEx)

function HiddenMeridianUnlockBuffUI:create()
    local p = HiddenMeridianUnlockBuffUI:new()
    p:init()
    return p
end

function HiddenMeridianUnlockBuffUI:init()
    self.__ui = require("Layer/MeridianUI/HiddenMeridian/HiddenMeridianUnlockBuffUI.lua").create()["root"]

    self.__ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function HiddenMeridianUnlockBuffUI:showUI()
    self:show()
end

function HiddenMeridianUnlockBuffUI:hideUI()
    self:hide()
end

function HiddenMeridianUnlockBuffUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function HiddenMeridianUnlockBuffUI:setTextResouce(text)
    self.Text_resouce:setString(text)
end

function HiddenMeridianUnlockBuffUI:setTextUnlock(text)
    self.Text_unlock:setString(text)
end

function HiddenMeridianUnlockBuffUI:setButton1(name,func)
    self.Button_1.Text_ButtonName:setString(name)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function HiddenMeridianUnlockBuffUI:setButton2(name,func)
    self.Button_2.Text_ButtonName:setString(name)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return HiddenMeridianUnlockBuffUI
0000000000000
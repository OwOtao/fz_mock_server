local HiddenMeridianBreakthroughUI = class("HiddenMeridianBreakthroughUI", LayerEx)

function HiddenMeridianBreakthroughUI:create()
    local p = HiddenMeridianBreakthroughUI:new()
    p:init()
    return p
end

function HiddenMeridianBreakthroughUI:init()
    self.__ui = require("Layer/MeridianUI/HiddenMeridian/HiddenMeridianBreakthroughUI.lua").create()["root"]

    self.__ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function HiddenMeridianBreakthroughUI:showUI()
    self:show()
end

function HiddenMeridianBreakthroughUI:hideUI()
    self:hide()
end

function HiddenMeridianBreakthroughUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function HiddenMeridianBreakthroughUI:setTextType1(text)
    self.Text_type1:setString(text)
end

function HiddenMeridianBreakthroughUI:setTextType2(text)
    self.Text_type2:setString(text)
end

function HiddenMeridianBreakthroughUI:setTextType3(text)
    self.Text_type3:setString(text)
end

function HiddenMeridianBreakthroughUI:setTextResouce(text)
    self.Text_resouce:setString(text)
end

function HiddenMeridianBreakthroughUI:setTextTime(text)
    self.Text_time:setString(text)
end

function HiddenMeridianBreakthroughUI:setButton1(name,func)
    self.Button_1.Text_ButtonName:setString(name)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function HiddenMeridianBreakthroughUI:setButton2(name,func)
    self.Button_2.Text_ButtonName:setString(name)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return HiddenMeridianBreakthroughUI
000
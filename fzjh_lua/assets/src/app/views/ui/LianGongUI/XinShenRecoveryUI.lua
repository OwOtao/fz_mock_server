local XinShenRecoveryUI = class("XinShenRecoveryUI", LayerEx)

function XinShenRecoveryUI:create()
	local p = XinShenRecoveryUI:new()
	p:init()
	return p
end

function XinShenRecoveryUI:init()
    self._UI = require("Layer/LianGongUI/XinShenRecoveryUI.lua").create()['root']

    self._UI:addTo(self)

    Helper:convertUIByParent(self)
end

function XinShenRecoveryUI:showUI()
    self:setVisible(true)
end

function XinShenRecoveryUI:hideUI()
    self:setVisible(false)
end

function XinShenRecoveryUI:setCurrXinShenText(text)
    self.Text_content1:setString(text)
end

function XinShenRecoveryUI:setCurrXinShenMaxText(text)
    self.Text_content2:setString(text)
end

function XinShenRecoveryUI:setXinShenRecover(text)
    self.Text_content3:setString(text)
end

function XinShenRecoveryUI:setPanelBack(func)
    self.Panel_back:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function XinShenRecoveryUI:setPanel(index,data)
    local panel = self["Panel_"..index] 
    panel.Image_2:loadTexture(data.image,0)
    panel.Text_name:setString(data.name)
    panel.Text_recovery:setString(data.recovery)
    panel:releaseFunc(function()
        if data.func then
            data.func()
        end
    end)
end

function XinShenRecoveryUI:setPanelItemConut(index,text)
    local panel = self["Panel_"..index] 
    panel.Text_name:setString(text)
end

return XinShenRecoveryUI0000000000
local XinShenUI = class("XinShenUI", LayerEx)

function XinShenUI:create()
	local p = XinShenUI:new()
	p:init()
	return p
end

function XinShenUI:init()
    self._UI = require("Layer/LianGongUI/XinShenUI.lua").create()['root']

    self._UI:addTo(self)

    Helper:convertUIByParent(self)
end

function XinShenUI:showUI()
    self:setVisible(true)
end

function XinShenUI:hideUI()
    self:setVisible(false)
end

function XinShenUI:setTitle(text)
    self.Text_title:setString(text)
end

function XinShenUI:setCurrXinShenText(text)
    self.Image_kuang.Text_content1:setString(text)
end

function XinShenUI:setCurrXinShenMaxText(text)
    self.Image_kuang.Text_content2:setString(text)
end

function XinShenUI:setXinShenRecover(text)
    self.Image_kuang.Text_content3:setString(text)
end

function XinShenUI:setXinShenUpgrade(text)
    self.Image_kuang.Text_content4:setString(text)
end

function XinShenUI:setXinShenCondition(text)
    self.Image_kuang.Text_condition:setString(text)
end

function XinShenUI:setXinFaText(text)
    self.Image_kuang.Text_content6:setString(text)
end

function XinShenUI:setXinShenCost(text)
    self.Image_kuang.Text_content7:setString(text)
end

function XinShenUI:setXinShenIsMaxVisible(bool)
    self.Image_kuang.Text_xinshenMax:setVisible(bool)
end

function XinShenUI:setSubTitle5Visible(bool)
    self.Image_kuang.Text_subTitle5:setVisible(bool)
end

function XinShenUI:setSubTitle6Visible(bool)
    self.Image_kuang.Text_subTitle6:setVisible(bool)
end

function XinShenUI:setSubTitle7Visible(bool)
    self.Image_kuang.Text_subTitle7:setVisible(bool)
end

function XinShenUI:setButton1(name,func,enabled)
    self.Button_1:setEnabled(enabled) 
    self.Button_1.Text_ButtonName:setString(name)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function XinShenUI:setButton2(name,func)
    self.Button_2.Text_ButtonName:setString(name)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function XinShenUI:setButton3(name,func)
    self.Button_3.Text_ButtonName:setString(name)
    self.Button_3:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return XinShenUI00000000000000
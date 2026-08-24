local TechniqueUI = class("TechniqueUI", LayerEx)

function TechniqueUI:create()
	local p = TechniqueUI:new()
	p:init()
	return p
end

function TechniqueUI:init()
    self._round = require("Layer/FistFootUI/TechniqueUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TechniqueUI:setPanelButton(index,data)
    if self["Panel_technique"..index] == nil then
        return
    end

    self["Panel_technique"..index].Image_1:loadTexture(data.image1,0)
    self["Panel_technique"..index].Image_2:loadTexture(data.image2,0)
    
	self["Panel_technique"..index]:releaseFunc(function()
		if data.callback then
			data.callback()
		end
	end)
end

function TechniqueUI:setLightButton(index)
    for i = 1,10 do
        self["Panel_technique"..i].Image_1:setVisible(false)
    end

    self["Panel_technique"..index].Image_1:setVisible(true)
end

function TechniqueUI:setPanelText(textMap)
    self.Panel_di.Text_1:setString(textMap[1])
    self.Panel_di.Text_2:setString(textMap[2])
    self.Panel_di.Text_3:setString(textMap[3])
    self.Panel_di.Text_4:setString(textMap[4])
    self.Panel_di.Text_5:setString(textMap[5])
    self.Panel_di.Text_6:setString(textMap[6])
end

function TechniqueUI:setButton1(buttonName,func)
    self.Panel_di.Button_1.Text_buttonName:setString(buttonName)
	self.Panel_di.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function TechniqueUI:setButton2(isGray,buttonName,func)
    if isGray then
        self.Panel_di.Button_2:getVirtualRenderer():getSprite():setGLProgram(Resource:getSpriteGrayShder())
    else
        self.Panel_di.Button_2:getVirtualRenderer():getSprite():setGLProgram(Resource:getSpriteNormalShder())
    end
    self.Panel_di.Button_2.Text_buttonName:setString(buttonName)
	self.Panel_di.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end


return TechniqueUI000000000
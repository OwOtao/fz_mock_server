local TeacherBuildGuaJiUI = class("TeacherBuildGuaJiUI", LayerEx)

function TeacherBuildGuaJiUI:create()
	local p = TeacherBuildGuaJiUI:new()
	p:init()
	return p
end

function TeacherBuildGuaJiUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherBuildGuaJiUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)

    self:initRichText()
end

function TeacherBuildGuaJiUI:updateSkin(skin_config)
    if skin_config == nil then
        self.Button_1:loadTextureNormal("Image/UI/MapUI/anniu05.png", 0)
        self.Button_2:loadTextureNormal("Image/UI/MapUI/anniu05.png", 0)
        self.Button_3:loadTextureNormal("Image/UI/MapUI/anniu05.png", 0)
    end


    local btnImage = skin_config.Clickbtn or "Image/UI/MapUI/anniu05.png"
    self.Button_1:loadTextureNormal(btnImage, 0)
    self.Button_2:loadTextureNormal(btnImage, 0)
    self.Button_3:loadTextureNormal(btnImage, 0)
end

function TeacherBuildGuaJiUI:initRichText()
    if self.__richPrint then
        self.__richPrint:removeFromParent()
        self.__richPrint = nil
    end
    self.__richPrint = ExtRichTextScroll:create()
    self.Panel_1:addChild(self.__richPrint)
    local size = self.Panel_1.Panel_textArea:getContentSize()
    local x, y = self.Panel_1.Panel_textArea:getPosition()
    self.__richPrint:setAnchorPoint(0.5000, 0.5000)
    self.__richPrint:setPosition(cc.p(x, y))
    self.__richPrint:setSize(size)
    self.__richPrint:setScrollBarEnabled(false)
    self.__richPrint:getRichText():setVerticalSpace(20)

    -- 设置最大显示高度
    self.__richPrint:setTextMaxHeight(2000)
    self.__richPrint:setTouchEnabled(false)
end

function TeacherBuildGuaJiUI:addText(str)
    str = tostring(str)
    self.__richPrint:pushBackText(str, cc.c3b(255, 255, 255), 255, Resource:getFontPath("default"), 38)
    self.__richPrint:pushBackNewLine(0)
end

function TeacherBuildGuaJiUI:setButton1(buttonName,isViseble,func)
    self.Button_1.Text_buttonName:setString(buttonName)
    self.Button_1:setVisible(isViseble)
	self.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function TeacherBuildGuaJiUI:setButton2(buttonName,isViseble,func)
    self.Button_2.Text_buttonName:setString(buttonName)
    self.Button_2:setVisible(isViseble)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function TeacherBuildGuaJiUI:setButton3(buttonName,isViseble,func)
    self.Button_3.Text_buttonName:setString(buttonName)
    self.Button_3:setVisible(isViseble)
	self.Button_3:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function TeacherBuildGuaJiUI:setTimeText(text)
    self.Panel_2.Text_value1:setString(text)
end

function TeacherBuildGuaJiUI:setSpeedName(text)
    self.Panel_2.Text_title2:setString(text)
end

function TeacherBuildGuaJiUI:setSpeedText(text)
    self.Panel_2.Text_value2:setString(text)
end

function TeacherBuildGuaJiUI:setRewardTexts(texts)
    for i = 1,4 do
        local text = texts[i] or ""
        self.Panel_2["Text_reward"..i]:setString(text)
    end
end


return TeacherBuildGuaJiUI00000000000000
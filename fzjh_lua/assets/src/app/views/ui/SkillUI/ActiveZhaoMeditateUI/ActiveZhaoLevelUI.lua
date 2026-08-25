local ActiveZhaoLevelUI = class("ActiveZhaoLevelUI", LayerEx)

function ActiveZhaoLevelUI:create()
	local p = ActiveZhaoLevelUI:new()
	p:init()
	return p
end

function ActiveZhaoLevelUI:init()
    self._round = require("Layer/SkillUI/ActiveZhaoMeditate/ActiveZhaoLevelUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ActiveZhaoLevelUI:showUI()
    self:setVisible(true)
end

function ActiveZhaoLevelUI:hideUI()
    self:setVisible(false)
end

function ActiveZhaoLevelUI:setTextTitle(text)
	self.Text_title:setString(text)
end

function ActiveZhaoLevelUI:setText(index,text)
	self["Text_"..index]:setString(text)
end

function ActiveZhaoLevelUI:setItemText(textArray)
	for i= 1, 4 do
		if textArray[i] then
			self["Text_item"..tostring(i)]:setVisible(true)
			self["Text_item"..tostring(i)]:setString(Helper:getDef(textArray[i], ""))
		else
			self["Text_item"..tostring(i)]:setVisible(false)
		end
    end
end

function ActiveZhaoLevelUI:setButtonConfirm(isVisible,func)
	self.Button_confirm:setVisible(isVisible)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoLevelUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ActiveZhaoLevelUI00000000000000
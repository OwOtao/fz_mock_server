local LetterFormatLayer = class("LetterFormatLayer", cc.Layer)

function LetterFormatLayer:create()
	local p = LetterFormatLayer:new()
	p:init()
	return p
end

function LetterFormatLayer:init()
	self._UI = require("Layer/HomelandUI/EmployDscUI.lua").create()['root']
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self.Text_name:setVisible(false)
    self.Text_desc:setVisible(false)
    self.Button_DecorativeBox:setVisible(false)
    self.Button_Employ:setVisible(false)

    self.Panel_Letter:setVisible(true)

    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end


function LetterFormatLayer:showLayer()
    self:show()
end

function LetterFormatLayer:setText1( str )
    str = str or ""
    self.Panel_Letter.Text_name:setString(str)
end

function LetterFormatLayer:setText2( str )
    str = str or ""
    self.Panel_Letter.Text_name2:setString(str)
end

function LetterFormatLayer:setDesc( desc )
    desc = desc or ""
    self.Panel_Letter.Text_desc:setString(desc)
end

function LetterFormatLayer:setTimeDesc( desc )
    desc = desc or ""
    self.Panel_Letter.Text_timeDesc:setString(desc)
end

function LetterFormatLayer:hideLayer( )
    PopupLayerController:hideLayer("LetterFormatLayer",function ( layer )
        layer:hide()
    end)
end

Helper:classDefNodeGetInstance(LetterFormatLayer)
return LetterFormatLayer00
local DialogFLayer = class("DialogFLayer", cc.Layer)

function DialogFLayer:create()
	local p = DialogFLayer:new()
	p:init()
	return p
end

function DialogFLayer:init()
	self._round = require("Layer/Dialog/Dialog6UI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) 
	self:setVisible(false)
	self:setButtonRandom()
	self:setPanelBack()
end

function DialogFLayer:show()
	self:setVisible(true)
	-- self:setText_desc(text)
end

function DialogFLayer:hide()
	self:setVisible(false)
end

function DialogFLayer:setButton1()
	self.Button_1:releaseFunc(function()
		
	end)
end

function DialogFLayer:setButton2()
end

function DialogFLayer:setButtonRandom()
	self.Button_random:releaseFunc(function()
		local str = self.TextField_name:getString()
		if PRINT_MODE == 1 then
			print("str = "..tostring(str))
			print("length = "..string.len(str))
		end
	end)
end

function DialogFLayer:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		self:hide()
		if func then
			func()
		end
	end)
end

Helper:classDefNodeGetInstance(DialogFLayer)
return DialogFLayer0000000000000000
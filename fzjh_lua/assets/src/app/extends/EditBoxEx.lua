Decorator:replace(ccui.EditBox, "create",
	function(funcName, func, self, size, placeholder)
		if placeholder == "" then
			placeholder = " "
		end

    	if Game:isNewPackage() == true then
	        local editBox = func(self, size, "point.png")
	        editBox:setPlaceHolder(placeholder)
	        return editBox
       else
	        local editBox = func(self, size, placeholder)
	        return editBox
       end
    end)
00000000
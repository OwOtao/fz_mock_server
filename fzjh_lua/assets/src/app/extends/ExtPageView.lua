ccui.PageViewOld = ccui.PageView

ccui.PageView = ExtPageView

-- local getPageOld = ccui.PageView.getPage

-- function ccui.PageView:getPage(index)
-- 	if Game:isNewPackage() == true then
-- 		return self:getItem(index)
-- 	else
-- 		return getPageOld(self, index)
-- 	end
-- end

function ccui.PageView:getPageByIndex(index)
	if Game:isNewPackage() == true and Game:getVersion() ~= "1.5.10" then
		return self:getItem(index)
	else
		return self:getPage(index)
	end
end

function ccui.PageView:getInnerContainerPosX()
	local innerContainer = nil
	if Game:isNewPackage() == true and Game:getVersion() ~= "1.5.10"  then
		innerContainer = self:getInnerContainer()
	else
		innerContainer = self:getPageByIndex(0)
	end
	if innerContainer then
		return innerContainer:getPositionX()
	else
		return 0
	end
end

function ccui.PageView:setScrollDurationWithNumber(num)
	if Game:isNewPackage() == true and Game:getVersion() ~= "1.5.10"  then
		self:setScrollDuration(num)
	else
	end
end
000
local TableView = cc.TableView

-----------------------------------------------------------------------------------------------------------
-- @desc 替换create
if TableView.create_old == nil then
	TableView.create_old = TableView.create

	TableView.create = function(self, ...)
		local tableView = TableView.create_old(self, ...)

		local pause = tableView.pause
		local resume = tableView.resume

		tableView.pause = function(self)
			pause(self, self)
		end

		tableView.resume = function(self)
			resume(self, self)
		end

		return tableView
	end
end

-- width -- getDirection 0w, 1h
TableView.scrollToIndex = function(self, index, animated)
	if self._maxCount and self._cellWidth and self._cellHeight then
		local size = self:getViewSize()
		local dir = self:getDirection()
		if dir == 0 then
			-- 水平
			local width = self:getContentSize().width

			if width > size.width then
				index = math.max(math.min(index, self._maxCount), 1)
				local cellX = (index-1) * self._cellWidth
				cellX = math.max(cellX - size.width/2 + self._cellWidth/2, 0)
				cellX = math.min(cellX, width - size.width)
				self:setContentOffset(cc.p(-cellX, 0), true)
			end
		else
			-- 垂直
			local height = self:getContentSize().height

			if height > size.height then
				index = math.max(math.min(index, self._maxCount), 1)
			end
		end
	end
end000
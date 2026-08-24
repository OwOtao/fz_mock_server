-- add by XiaoZhiWei 2017/11/15 17:59:07 镜像
--[[
	该类用以实现属性监控,当监控属性发生变化时,及时更新实例本身记录的属性
]]

local Monitor = {
	value = nil,  -- add by XiaoZhiWei 2017/11/15 18:00:43 记录镜像实例的值
	upFunc = nil, -- add by XiaoZhiWei 2017/11/15 18:02:01 实例的实际值获取途径
	tab = nil,
	valueName = nil,
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/16 11:35:11
-- @desc 创建并初始化
function Monitor:create(tab, valueName, upFunc)
	local monitor = clone(Monitor)	
	monitor.upFunc = upFunc
	monitor.tab = tab
	monitor.valueName = valueName

	monitor.value = monitor.tab[monitor.valueName]
	return monitor
end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/11/15 18:03:18
-- -- @desc 检查更新方法
function Monitor:check()
	if self.value ~= self.tab[self.valueName] then
		self.value = self.tab[self.valueName]
		return true 
	else
		return false
	end
end

return Monitor0000000000000
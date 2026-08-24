-- add by XiaoZhiWei 2017/11/15 17:39:52 
--[[
	该模块用于管理联动更新属性变化的过程
]]
local Monitor = require("app.models.MonitorPool.Monitor")

local MonitorPool = 
{
	list = {},		-- add by XiaoZhiWei 2017/11/15 17:41:58 实例对象存储列表,用于存储各种情况的实例对象,方便遍历
	needRefreshMap = {}
}

local MonitorPoolMap = {}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/15 17:43:44
-- @desc 创建实例方法
function MonitorPool:create(name)
	assert(name ~= nil)
	local ret = clone(self)
	MonitorPoolMap[name] = ret 	
	return ret
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/28 17:46:52
-- @desc 添加实例列表  valueList 只能传递一个数组 优势,添加数组后,只会调用一次更新方法
function MonitorPool:addList(tab, valueList, target, upFunc)
	if type(tab) ~= "table" or type(valueList) ~= "table" or upFunc == nil then
		if DEBUG_MODE == 1 then
			-- assert(nil, "添加错误,实例对象必须存在update方法"..tab..valueName..target, upFunc)
		end
		print(tab, valueList, target, upFunc)
		error()
	end

	for i,valueName in ipairs(valueList) do
		table.insert(self.list ,Monitor:create(tab, valueName, upFunc))

		self.needRefreshMap[upFunc] = 
		{
			needRefresh = false,
			target = target,
			func = upFunc
		}
	end

	upFunc(target)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/15 17:51:43
-- @desc 从列表中添加实例
function MonitorPool:add(tab, valueName, target, upFunc)
	if type(tab) ~= "table" or valueName == nil or upFunc == nil then
		if DEBUG_MODE == 1 then
			-- assert(nil, "添加错误,实例对象必须存在update方法"..tab..valueName..target, upFunc)
		end
		print(tab, valueName, target, upFunc)
		error()
	end

	table.insert(self.list ,Monitor:create(tab, valueName, upFunc))

	self.needRefreshMap[upFunc] = 
	{
		needRefresh = false,
		target = target,
		func = upFunc
	}

	upFunc(target)
	-- table.insert(self.list, obj)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/15 17:38:10
-- @desc 更新方法
function MonitorPool:update()
	-- add by XiaoZhiWei 2017/11/15 17:49:05 遍历各个实例,并且调用实例自身的更新方法
	for i = 1, #self.list do
		local v = self.list[i]
		if v:check() then
			self.needRefreshMap[v.upFunc].needRefresh = true			
		end
	end

	for k,v in pairs(self.needRefreshMap) do
		if v.needRefresh then
			v.needRefresh = false
			v.func(v.target)
		end
	end
end

return MonitorPool0000000000000
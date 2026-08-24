--[[

	大纲 :
		用来测试每一个类的内存占用情况,检查是否存在内存溢出的情况
		


]]

local defaultSortName = "sub"

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/07 15:51:43
-- @desc 
local MemoryDetection = {
	_statics = {} -- add by XiaoZhiWei 2017/09/08 15:38:53 记录各个类的信息
}


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/08 15:58:04
-- @desc 打印一个类
function MemoryDetection:printStaticsInfo(className, sortName)
	if className == nil or self._statics[className] == nil then
		return
	end
	sortName = Helper:getDef(sortName, defaultSortName)
	local classMap = self._statics[className]
	local list = {}
	for k,v in pairs(classMap) do
		table.insert(list, {className = className, funcName = k, pre = v.pre, after = v.after, sub = v.sub, times = v.times})
	end

	table.sort(list, function(a, b)
		if type(a[sortName]) ~= "number" or type(b[sortName]) ~= "number" then
			return false
		end
		return a[sortName] < b[sortName]
	end)

	for i,v in ipairs(list) do
		print(i, v.className, "pre = "..v.pre.."	", "after = "..v.after.."	", "sub = "..math.floor(v.sub).."	", v.funcName.."		", "times = "..v.times.."	")
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/08 16:11:20
-- @desc 打印所有记录
function MemoryDetection:printAllStaticsInfo(sortName)
	if MapIsEmpty(self._statics) == true then
		return
	end
	sortName = Helper:getDef(sortName, defaultSortName)
	for k,v in pairs(self._statics) do
		self:printStaticsInfo(k, sortName)
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/08 15:37:15
-- @desc 设置记录的类
function MemoryDetection:setCalcClass(className, class)
	if className == nil or class == nil then
		return
	end

	Decorator:replaceAll(class, function(funcName, func, ...)
		return self:calc(className, funcName, func, ...)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/08 15:45:55
-- @desc 更新内存信息
function MemoryDetection:updateStatics(className, funcName, pre, after, sub)
	if className == nil or funcName == nil or pre == nil or after == nil or sub == nil then
		return
	end
	self._statics[className] = Helper:getDef(self._statics[className], {})
	self._statics[className][funcName] = Helper:getDef(self._statics[className][funcName], {})
	self._statics[className][funcName].pre = pre
	self._statics[className][funcName].after = after
	self._statics[className][funcName].sub = Helper:getDef(self._statics[className][funcName].sub, 0) + sub
	self._statics[className][funcName].times = Helper:getDef(self._statics[className][funcName].times, 0) + 1
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/07 15:53:27
-- @desc 计算前后内存差
local pre, after , sub
function MemoryDetection:calc(className, funcName, func, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10  
	pre = collectgarbage("count")
	arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 = func(...)
	after = collectgarbage("count")
	sub = after - pre
	self:updateStatics(className, funcName, pre, after, sub)
	return arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10
end

return MemoryDetection000000000
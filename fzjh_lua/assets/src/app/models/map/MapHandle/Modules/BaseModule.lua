local BaseModule = {
	--@desc 涉及的地图ID
	mapId = {
	},
	
	--@desc 模块涉及的房间ID
	roomId = {["fb01_03"] = true, ["fb02_18"] = true},
	
	--@desc 开启状态
	status = 1,
	
	--@desc 模块开启时间
	activityTime = 0,
	
	--@desc 子模块
	childModule = {
		
	},
	
	--[[		
		@desc : 模块涉及的条件结果
	]]
	doResult = {
		
		-- ["测试"] = function(map, result, environment)
		-- 	print("测试测试测试测试")
		-- 	print("arg1", result.arg1)
		-- end
	},
}

-- --@desc [src.app.models.map.BaseMap#BaseMap]
-- BaseModule._currMap = {}
--@desc: 判断是否在开启时间内
--@author:Liang SongQiang
--@time:2017-12-04 10:26:19
--@timeStr: 时间字符串 格式：["20171010,20180101"]
local function isInTime(timeStr)
	local timeArr = string.split(timestr, ",")
	local startTime = timeArr[1]
	local endTime = timeArr[2]
	local nowTime = GetTime()
	
	startTime = Helper:getTimeStampWithStringDate(startTime)
	
	if endTime == nil then
		return nowTime >= startTime
	end
	
	
	if startTime > endTime then
		assert(false, "日期顺序填写错误")
	end
	
	if nowTime >= startTime and nowTime <= endTime then
		return true
	end
	
	return false
end



--@desc: 初始化，并绑定当前进入的副本
--@author:Liang SongQiang
--@time:2017-11-13 15:17:06
function BaseModule:init(map)
	if MapIsEmpty(map) then
		assert(false, "map 是空值，请检查代码。")
		return false
	end

	if type(self.status) ~= "number" then
		assert(false,"模块状态码填写有误，请检查。")
	end
	
	if not MapIsEmpty(self.mapId) and not self.mapId[map.id] then
		print("当前副本不涉及该模块")
		return false
	end
	
	if self.activityTime ~= 0 and isInTime(self.activityTime) then
		print("此模块还未到开启时间")
		return false
	end
	
	self:loadCR(map)
	
	return true
end

-- --@desc: 根据当前进入的副本创建初始化子模块
-- --@author:Liang SongQiang
-- --@time:2017-12-02 15:20:20
-- --@map: [src.app.models.map.BaseMap#BaseMap]
-- function BaseModule:initChildModule(map)
-- 	if not MapIsEmpty(self.childModule) then
-- 		for k, m in pairs(self.childModule) do
-- 			if m.status == 0 then
-- 				print(k .. "子模块还未开启")
-- 			elseif m:init(map) then
-- 				m:entryMap(map)
-- 			end
-- 		end
-- 	end
-- 	return self
-- end

--@desc: 初始化当前模块的条件结果
--@author:Liang SongQiang
--@time:2017-12-02 15:22:32
--@return [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
function BaseModule:loadCR(map)
	if not MapIsEmpty(self.doResult) then
		for k, v in pairs(self.doResult) do
			map.doResultFun[k] = v
		end
	end

	--@desc 子模块涉及的条件结果
	if not MapIsEmpty(self.childModule) then
		for k,m_name in pairs(self.childModule) do
			print(m_name)
			local m = require(m_name)
			if m.status == 0 then
				print(k .. "子模块还未开启")
			else
				m:loadCR(map)
			end
		end
	end

	return self
end

--@desc: 进入副本时需执行的条件结果（此方法运行必须在所有模块的条件结果加载完成后）
--@author:Liang SongQiang
--@time:2018-04-21 16:20:55
--@map:[src.app.models.map.BaseMap#BaseMap]
--@currTime: 当前时间
function BaseModule:loadMap( map ,currTime)
	if MapIsEmpty(map) then
		assert(false, "map 是空值，请检查代码。")
		return false
	end

	if not MapIsEmpty(self.mapId) and not self.mapId[map.id] then
		print("当前副本不涉及该模块")
		return false
	end
	
	if self.activityTime ~= 0 and isInTime(self.activityTime) then
		print("此模块还未到开启时间")
		return false
	end

	self:entryMap(map,currTime)
	if not MapIsEmpty(self.childModule) then
		for k,m_name in pairs(self.childModule) do
			local m = require(m_name)
			if m.status == 0 then
			else
				m:entryMap(map,currTime)
			end
		end
	end
end


--@desc: 操作当前map，所有逻辑实现入口
--@author:Liang SongQiang
--@time:2017-11-14 11:31:50
function BaseModule:entryMap(map,currTime)
	if PRINT_MODE == 1 then
		print("EntryMap(): id: " .. map.id, "name: " .. map.name)
	end
	
	return true
end


--@desc 离开当前副本时的逻辑
function BaseModule:leaveMap(map)
	-- if not self.mapId[self._currMap.id] then
	-- 	return self._currMap
	-- end
	print("leave map : " .. map.name)
end

return BaseModule00000000000000
local MapPVP = {}
local WAITING_TIME = 10 -- add by XiaoZhiWei 2017/06/15 15:05:17 等待时间10秒

--[[
	tiemDesc = "刚刚",
	targetName = "一剑万年",
	result = 0,
	fightType = "切磋",
	startRole = "HE",
	userid = 123,
	time = 123
	key = 1
]]
local MAXCACHECOUNT = 100
local cacheTab = {}
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 16:46:24
-- @desc 战斗数据更新
function MapPVP:updateFightMsg(key, params)
	if key == nil or MapIsEmpty(params) == true then
		return
	end
	params.key = key 

	cacheTab = self:getData()
	local isUpdate = false
	for i,v in ipairs(cacheTab) do
		if v.key == key then
			v = Helper:tableCover(v, params)
			isUpdate = true
		end
	end

	if isUpdate == false then
		table.insert(cacheTab, params)
	end

	-- add by XiaoZhiWei 2017/06/14 17:12:04 暂时只缓存10条数据
	while #cacheTab > MAXCACHECOUNT do
		table.remove(cacheTab, 1)
	end

	if #cacheTab > 1 then
		table.sort(cacheTab, function(a, b)
			if a == b then
				return false
			end

			if a.time == nil and b.time == nil then 
			 	return false
			elseif a.time == nil and b.time ~= nil then
				return false
			elseif a.time ~= nil and b.time == nil then
				return true
			else
				return a.time > b.time
			end
		end)
	end

	self:saveData(cacheTab)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 17:41:12
-- @desc 移除无效数据
function MapPVP:removeFightMsg(key)
	if key == nil then
		return
	end
	cacheTab = self:getData()
	for i,v in ipairs(cacheTab) do
		if v.key == key then
			table.remove(cacheTab, i)
			break
		end
	end
end 

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 18:32:56
-- @desc 根据状态获取缓存战斗信息数据
function MapPVP:getDataWithStatus(status)
	local retList = {}
	if status == nil then
		return retList
	end
	cacheTab = self:getData()
	for i,v in ipairs(cacheTab) do
		if v.status == status then
			table.insert(retList, v)
		end
	end
	return retList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 19:59:36
-- @desc 根据战斗结果获取缓存战斗信息数据
function MapPVP:getDataWithResult(result)
	local retList = {}
	if result == nil then
		return retList
	end
	cacheTab = self:getData()
	for i,v in ipairs(cacheTab) do
		if v.result == result then
			table.insert(retList, v)
		end
	end
	return retList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/03 15:10:48
-- @desc 获取未查阅的邀请记录
function MapPVP:getUnReadInvitation()
	local retList = {}
	cacheTab = self:getData()
	for i,v in ipairs(cacheTab) do
		if v.status == "被邀请切磋等待中" and v.isRead ~= true then
			table.insert(retList, v)
		end
	end
	return retList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/03 15:33:36
-- @desc 更新记录的查看状态
function MapPVP:updateDataReadStatus(keys)
	if MapIsEmpty(keys) then
		return false
	end
	for k,key in pairs(keys) do
		self:updateFightMsg(key, {isRead = true})
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/03 15:41:03
-- @desc 更新所有记录的查看状态
function MapPVP:updateAllReadStatus()
	cacheTab = self:getData()
	for k,v in pairs(cacheTab) do
		if v.isRead ~= true then
			v = Helper:tableCover(v, {isRead = true})
		end
	end
	self:saveData(cacheTab)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/19 16:35:46
-- @desc 获取指定的战斗记录
function MapPVP:getOneDataWithKey(key)
	local result = {}
	if key == nil then
		return result
	end
	cacheTab = self:getData()
	for i,v in ipairs(cacheTab) do
		if v.key == key then
			result = v
			break
		end
	end
	return result
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 17:05:21
-- @desc 获取战斗数据
function MapPVP:getCacheList()
	return Helper:getDef(cacheTab, {})
end

-- 加载数据
function MapPVP:loadData()
	cacheTab = Helper:getDef(DataBase:getLuaTable("fightHistoryMsg_"..tostring(User:getUserId())), {})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 16:24:01
-- @desc 缓存战斗信息数据
function MapPVP:saveData(data)
	DataBase:setLuaTable("fightHistoryMsg_"..tostring(User:getUserId()), Helper:getDef(data, {}))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 17:06:57
-- @desc 读取缓存战斗信息数据
function MapPVP:getData()
	cacheTab = Helper:getDef(cacheTab, {})
	return cacheTab
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/19 17:30:06
-- @desc 更新状态 (将 被邀请战斗,但是超时的数据更新为拒绝状态,并且拒绝对方)
function MapPVP:update()
	cacheTab = self:getData()
	local changeList = {}
	local isNeedChangeStatus = true
	for i,v in ipairs(cacheTab) do
		if v.time ~= nil then
			if GetTime() - v.time > WAITING_TIME and status == "被邀请切磋等待中" then
				table.insert(changeList, v)
			elseif GetTime() - v.time < WAITING_TIME then
				-- add by XiaoZhiWei 2017/06/20 18:34:06 还有正在等待中的 记录
				isNeedChangeStatus = false
			end
		end
	end

	if MapIsEmpty(changeList) == false then
		for i,v in ipairs(changeList) do
			if v.time ~= nil then
				self:updateFightMsg(v.key, {status = "拒绝战斗"})
				FubenClient:reject(v.userid, v.actionCode, v.time * 1000, v.key, User:getRoleAttr("name").."拒绝了你的切磋请求", v.id)
			end
		end
	else
	end

	if isNeedChangeStatus == true then
		User:getRole():updateFightStatus("战斗结束")
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/21 12:16:13
-- @desc 测试使用,清空历史数据
function MapPVP:clearHistoryData()
	cacheTab = {}
	self:saveData(cacheTab)
end

return MapPVP0000000000000000
local DataBase = {}
local roleKey = "RoleData"
-- 保存luaTable的目录
local LUATABLE_PATH = cc.FileUtils:getInstance():getWritablePath().."luaTablePath/"

function DataBase:getData(key)
	local str = cc.UserDefault:getInstance():getStringForKey(key)

	-- 解密读取
	str = JMForLua:decrypt(str)

	local tb = luaTableDecode(str)
	if tb == nil then
		if type(str) == "string" and string.len(str) > 0 and tostring(str) ~= "nil" then
			return json.decode(str)
		end
	else
	end
	return tb
end

function DataBase:setData(key, data, needEncrypt)
	if needEncrypt == nil then
		needEncrypt = true
	end

	local saveStr = ""
	if type(data) == "table" then
		saveStr = luaTableEncode(data)
	else
		saveStr = tostring(data)
	end
	if needEncrypt then
		if DEBUG_MODE == 1 then
		else
			saveStr = JMForLua:encrypt(saveStr)
		end
	end
	cc.UserDefault:getInstance():setStringForKey(key, saveStr)
end

local UPLOAD_INTERVAL_SEC = 0

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/29 00:45:54
-- @desc 协程方式保存存档
function DataBase:createSetDataCoroutine()
	return coroutine.create(
	function(key, data, needEncrypt)
		if needEncrypt == nil then
			needEncrypt = true
		end

		local saveStr = ""

		if type(data) == "table" then
			local tableToStringCoroutine = createTableToStringCoroutine()
			while true do
				local a1, finished
				a1, finished, saveStr = coroutine.resume(tableToStringCoroutine, data)
				if finished == true then
					break
				else
					coroutine.yield()
				end
			end
		else
			saveStr = tostring(data)
		end
		coroutine.yield()

		if needEncrypt then
			if DEBUG_MODE == 1 then
			else
				saveStr = JMForLua:encrypt(saveStr)
			end
		end
		coroutine.yield()

		do
			if DEBUG_MODE == 1 then
				key = md5:getMd5(key) -- 使用key的md5
			else
				key = md5:getMd5(key) -- 使用key的md5
			end
    
            coroutine.yield()

			cc.FileUtils:getInstance():createDirectory(LUATABLE_PATH)

			key = tostring(key)

    		coroutine.yield()

			if IS_ABLE_TO_SAVE_DATA == true then
				cc.FileUtils:getInstance():writeStringToFile(saveStr, LUATABLE_PATH..key)
				if cc.UserDefault:getInstance():getStringForKey("RoleData") ~= nil then
					cc.UserDefault:getInstance():deleteValueForKey("RoleData")
					cc.UserDefault:getInstance():deleteValueForKey(key)
				end

        		coroutine.yield()

				local nTime = GetTime()
				if UPLOAD_INTERVAL_SEC <= 0 then
					local minute = math.random( 20,40 )
					UPLOAD_INTERVAL_SEC = minute * 60
					print("存档上传间隔时间为："..minute.."分钟")
				end

		        coroutine.yield()

				if nTime - Account:getUploadTime() >= UPLOAD_INTERVAL_SEC then
					Account:uploadUserData(EMPTY_FUNC,false,false)
				end
        		coroutine.yield()
			end
		end

		-- cc.UserDefault:getInstance():setStringForKey(key, saveStr)
		coroutine.yield(true)
	end)
end


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得字符串
function DataBase:getString(key)
	Helper:getDef(key, "")
	return cc.UserDefault:getInstance():getStringForKey(key)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置字符串
function DataBase:setString(key, str)
	Helper:getDef(key, "")
	Helper:getDef(str, "")
	cc.UserDefault:getInstance():setStringForKey(key, str)
end

function DataBase:getDataWithString(key)
	local str = cc.UserDefault:getInstance():getStringForKey(key)
	if type(str) == "string" and str ~= "" and str ~= "nil" then
		return str
	end
	return nil
end

function DataBase:setDataByString(key, str)
	cc.UserDefault:getInstance():setStringForKey(key, str)
end

function DataBase:getRoleData()
	local roleData = self:getLuaTable(roleKey)
	if roleData == nil then
		roleData = self:getData(roleKey)
	elseif type(roleData) ~= "table" then
		roleData = JMForLua:decrypt(roleData)
	else
	end
	if type(roleData) == "table" and type(roleData.userid) == "number" and roleData.userid > 0 then
		return roleData
	end
	return nil, roleData
end

function DataBase:setRoleData(data)
	self:setLuaTable(roleKey, data)
	-- self:setData(roleKey, data)
end

-- 重置玩家数据
function DataBase:resetRoleData()
	self:setLuaTable(roleKey, {})
	-- self:setData(roleKey, nil)
end

-- 写文件保存数据, key为文件名, 请使用英文
function DataBase:getLuaTable(key)
	local rawKey = key
	if DEBUG_MODE == 1 and key ~= roleKey then
	else
		key = md5:getMd5(key) -- 使用key的md5
	end

	-- 创建目录
	cc.FileUtils:getInstance():createDirectory(LUATABLE_PATH)

	key = tostring(key)
	-- 判断文件是否存在
	local isFileExist = cc.FileUtils:getInstance():isFileExist(LUATABLE_PATH..key)
	if isFileExist ~= true then
		return nil
	end

	local str = cc.FileUtils:getInstance():getStringFromFile(LUATABLE_PATH..key)
	if str == nil or str == "" then
		return nil
	end
	str = JMForLua:decrypt(str) -- 解密
	local isOk, luaTable =  pcall(luaTableDecode, str)
	if isOk ~= true then
		local str = rawKey .. " file luaTable decode error: " .. tostring(luaTable)
		print( "DataBase:getLuaTable error "..str)
		print(debug.traceback())

		Collection:recordLoadErrmsg(str)
		
		return nil
	end
	return luaTable
end

-- 读文件数据, key为文件名, 请使用英文
function DataBase:setLuaTable(key, tb, ver)
	if DEBUG_MODE == 1 and key ~= roleKey then
	else
		key = md5:getMd5(key) -- 使用key的md5
	end

	if PRINT_MODE == 1 then
		-- print("function DataBase:setLuaTable(key, tb)")
	end
	-- 创建目录
	cc.FileUtils:getInstance():createDirectory(LUATABLE_PATH)

	key = tostring(key)
	if type(tb) ~= "table" then
		return false
	end
	local luaTableStr = luaTableEncode(tb)
	if PRINT_MODE == 1 then
		print("luaTablePath..key = "..LUATABLE_PATH..key)
	end
	if DEBUG_MODE == 1 then
	else
		luaTableStr = JMForLua:encrypt(luaTableStr, ver) -- 加密
	end
	return cc.FileUtils:getInstance():writeStringToFile(luaTableStr, LUATABLE_PATH..key)
end

return DataBase
000000000
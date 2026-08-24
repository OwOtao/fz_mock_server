local Encryptor = require("third.encryptor.Encryptor")
local Comparer = require("third.comparer.Comparer")
local PairsCoroutine = require("third.coroutine.PairsCoroutine")

local DataValidationTable = {}

local encryptTableMetatable = {
	-- 新增值的时候调用(这里是修改值的时候调用)
	__newindex = function(t, k, v)
		local values = rawget(t, "__EncryptedTable").values
		local encryptedTable = rawget(t, "__EncryptedTable").encryptedTable

		if (values[k] == nil and encryptedTable[k] == nil) or Encryptor:encrypt(values[k], k) == encryptedTable[k] then
			values[k] = v
			encryptedTable[k] = Encryptor:encrypt(v, k)
        else
            error("作弊")
		end
	end,
	-- 获得值的时候调用
	__index = function(t, k)
		local values = rawget(t, "__EncryptedTable").values
		local encryptedTable = rawget(t, "__EncryptedTable").encryptedTable
		
		if Encryptor:encrypt(values[k], k) == encryptedTable[k] then
			return values[k]	
		end

		error("作弊")
	end
}

local function isArray(tb)
	local hasOne = false
	for k, v in pairs(tb) do
		if type(k) == "number" then
			if k == 1 then
				hasOne = true
			end
		else
			return false
		end
	end
	return hasOne
end

local function isEncryptedTable(tb)
	return rawget(tb, "__EncryptedTable")
end

local function createEncryptedTable(values)
	if isEncryptedTable(values) == false then
		return values
	end

	if isArray(values) then
		return values
	end

	local proxy = {
		__EncryptedTable = {
			-- 忽略tablecover
			__ignore_table_cover = true,
			encryptedTable = {},
			values = {}
		}
	}
	setmetatable(proxy, encryptTableMetatable)

	-- 对初始值防修改
	for k, v in pairs(values) do
		proxy[k] = v
	end

	-- assert(Comparer:equals(values, proxy), "加密后导致table不相等!!")
	return proxy
end

local function createEncryptedTableRecursive(values)
	local lookup_table = {}
	local function innerCreateEncryptedTableRecursive(values)
		if lookup_table[values] then
			return lookup_table[values]
		elseif isEncryptedTable(values) then
			return values
		end
		local new_values = createEncryptedTable(values)
		lookup_table[values] = new_values
		for k, v in pairs(values) do
			if type(v) == "table" then
				new_values[k] = innerCreateEncryptedTableRecursive(v)
			end
		end
		return new_values
	end
	return innerCreateEncryptedTableRecursive(values)
end

function DataValidationTable:create(values)
	if self:isEncryptedTable(values) then
		return values
	end
	return createEncryptedTable(values)
end

function DataValidationTable:createRecursive(values)
	return createEncryptedTableRecursive(values)
end

function DataValidationTable:isEncryptedTable(tb)
	return isEncryptedTable(tb)
end

-- 遍历属性的协程
local function __pairs(self, filter)
	for k, v in pairs(rawget(self, "__EncryptedTable").values) do
		k, v = k, self[k]
		if filter then
			k, v = filter(k, v)
		end
		coroutine.yield(k, v)
	end
end

function DataValidationTable.__pairs(self)
	return PairsCoroutine(__pairs, self)
end

-- 遍历属性的协程
local function __ipairs(self)
	for k, v in ipairs(rawget(self, "__EncryptedTable").values) do
		coroutine.yield(k, self[k])
	end
end

function DataValidationTable.__ipairs(self)
	return PairsCoroutine(__ipairs, self)
end

function DataValidationTable.__clone(self, lookup_table)
	local newObject = {}
	lookup_table[self] = newObject
	rawset(newObject, "__EncryptedTable", clone(rawget(self, "__EncryptedTable"), lookup_table))
	return setmetatable(newObject, getmetatable(self))
end

function DataValidationTable.__getn(self)
	return table.getn(rawget(self, "__EncryptedTable").values)
end

return DataValidationTable
00000
local OfflineProfit =
{
	showFlag = true,
	profitMap = {},
	profitSort =
	{
		"exp",
		"pot",
		"money",
		"neiliMax",
		"skillLv"
	},
	exchangeMap = {},
	beforeMap = {}
}

-- 初始化基本数据
function OfflineProfit:init()
	self.showFlag = true
	self.profitMap = {}
	self.profitSort =
	{
		"exp",
		"pot",
		"money",
		"neiliMax",
		"skillLv"
	}
	self.exchangeMap = {}
	self.beforeMap = {}
end

function OfflineProfit:getOfflineProfit( key )
	if self.profitMap[ key ] == nil then
		return 0
	end
	return math.floor( self.profitMap[ key ] )
end

function OfflineProfit:setBeforeStatus(key, value, name)
	if key == nil or value == nil then
		return
	end
	if name ~= nil then
		self.exchangeMap[key.."Name"] = name
	end
	self.beforeMap[key] = tonumber(value)
end

-- 设置变化后的状态 并 计算记录增量值
function OfflineProfit:setAfterStatus(key, value, name)
	if key == nil or value == nil then
		return
	end
	if name ~= nil then
		self.exchangeMap[key.."Name"] = name
	end

	local beforeValue = self.beforeMap[key]
	local afterValue = tonumber(value)
	
	if self.profitMap[key] == nil then
		self.profitMap[key] = 0
	end
	if beforeValue == nil or type(beforeValue) ~= type(afterValue) then
		return
	end
	self.profitMap[key] = self.profitMap[key] + (afterValue - beforeValue)
end

-- 设置变化前的值 带来源(sType)
function OfflineProfit:setBeforeStatusWithType(sType, key, value, name)
	if sType == nil or key == nil or value == nil then
		return
	end
	-- 名字不是必须的,存在则做记录
	if name ~= nil then
		-- key = skill  sType = GZ  --->>> skill_GZ_Name
		self.exchangeMap[tostring(key).."_"..tostring(sType).."_Name"] = tostring(name)
	end
	-- 第一份用于文本输出 第二份用于记录
	self.beforeMap[tostring(key)] = value

	-- 这一份用于记录,区分来源
	if self.beforeMap["_"..tostring(sType)] == nil then
		self.beforeMap["_"..tostring(sType)] = {}
	end
	self.beforeMap["_"..tostring(sType)]["Before_"..tostring(key)] = value
end

-- 设置变化后的值 带来源(sType)
function OfflineProfit:setAfterStatusWithType(sType, key, value, name)
	if sType == nil or key == nil or value == nil then
		return
	end
	-- 名字不是必须的,存在则做记录
	if name ~= nil then
		-- key = skill  sType = GZ  --->>> skill_GZ_Name
		self.exchangeMap[tostring(key).."Name"] = tostring(name)
		self.exchangeMap[tostring(key).."_"..tostring(sType).."_Name"] = tostring(name)
	end

	local beforeValue = self.beforeMap[tostring(key)]
	local afterValue = tonumber(value)
	if self.profitMap[key] == nil then
		self.profitMap[key] = 0
	end
	-- 变化前的记录没有或者前后的变化值类型不一致(其实还只能是数字类型,不然后面的加减运算会报错)
	if beforeValue == nil or type(beforeValue) ~= type(afterValue) then
		return
	end
	self.profitMap[key] = self.profitMap[key] + (afterValue - beforeValue)

	-- 用于记录
	if self.beforeMap["_"..tostring(sType)] ~= nil then
		self.beforeMap["_"..tostring(sType)]["After_"..tostring(key)] = value
		if MapIsEmpty(self.profitMap["_"..tostring(sType)]) == true then
			self.profitMap["_"..tostring(sType)] = {}
		end

		if self.profitMap["_"..tostring(sType)][tostring(key)] == nil then
			self.profitMap["_"..tostring(sType)][tostring(key)] = 0
		end
		self.profitMap["_"..tostring(sType)][tostring(key)] = self.profitMap["_"..tostring(sType)][tostring(key)] + (value - self.beforeMap["_"..tostring(sType)]["Before_"..tostring(key)])
	end
end

-- function OfflineProfit:setOfflineProfit( duration, key, value, name )
-- 	if self.showFlag == false then
-- 		return
-- 	end
-- 	if duration == nil or key == nil or value == 0 or value == nil or type( duration ) ~= "number" then
-- 		return
-- 	end
-- 	-- print( "duration: " .. tostring( duration ) )
-- 	-- print( "key: " .. key )
-- 	-- print( "value: " .. tostring( value ) )
-- 	-- print( "name: " .. ( name or "nil" ) )
-- 	if self.profitMap[ key ] == nil then
-- 		self.profitMap[ key ] = 0
-- 	end
-- 	if key == "skillLv" and name ~= nil then
-- 		self.exchangeMap[ key ] = string.format( self.exchangeMap[ "skillName" ], name )
-- 	end
-- 	self.profitMap[ key ] = self.profitMap[ key ] + value
-- end

function OfflineProfit:getProfitMap()
	return self.profitMap
end

function OfflineProfit:show( nodeUi )
	-- if self.showFlag == false then
	-- 	return
	-- end

	-- Helper:print_lua_table(self.profitMap)
	local popStrList = {}
	local richStr = "你一共获得离线收益"

	local flag = false
	for i, v in ipairs( self.profitSort ) do
		local key = v
		local value = self.profitMap[key]
		if value ~= nil and value ~= 0 and type(value) == "number" and key ~= nil then
			flag = true
			local str = self.exchangeMap[ key.."Name" ] .. Helper:numberToStringWithPlus(math.floor(value))
			richStr = richStr ..  " " .. str
			table.insert( popStrList, str)
		end
	end

	if MapIsEmpty(self.profitMap["_GZ"]) == false then
		local gzStr = "其中离线观战收益为："
		local gzFlag = false
		for i, v in ipairs( self.profitSort ) do
			local key = v
			local value = self.profitMap["_GZ"][key]
			if value ~= nil and value ~= 0 and type(value) == "number" and key ~= nil then
				gzFlag = true
				local str = self.exchangeMap[ key.."Name" ] .. Helper:numberToStringWithPlus(math.floor(value))
				gzStr = gzStr ..  " " .. str
			end
		end
		if gzFlag == true then
			richStr = richStr .."。".. gzStr
		end
	end

	if flag == true then
		self:richPrint( richStr )
		self:popText( popStrList, nodeUi )
	end
	-- self.showFlag = false

	return richStr
end

function OfflineProfit:popText( strList, nodeUi )
	local delay = 0
	for key, str in pairs( strList ) do
		-- 如果类型是table string.len 会报错
		if str ~= nil and type(str) == "string" and string.len( str ) >= 0 then
			nodeUi:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(
				function()
					PopText( str )
        				end)))
			delay = delay + 0.5
		end
	end
end

function OfflineProfit:richPrint( str )
	-- 如果类型是table string.len 会报错
	if str == nil or type(str) ~= "string" or string.len( str ) <= 0 then
		return
	end
	RichPrint( "main", str )
end

return OfflineProfit00000000000000
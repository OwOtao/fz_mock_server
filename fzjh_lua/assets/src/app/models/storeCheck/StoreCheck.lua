-- 物品交易及校验模块
local StoreCheck = {}

function StoreCheck:init()
	self.transList = DataBase:getLuaTable("storeTrans")
end

StoreCheck:init()
---------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------              物品交易部分               ------------------------------------------------------
local transIndex = 0
local function getTransId()
	local role = User:getRole()
	local userid = role:getAttr("userid")
	if userid == nil or string.len(userid) <= 0 then
		return -1
	end
	local time = GetTime()
	transIndex = transIndex + 1
	return "trans"..tostring(math.floor(time))..tostring(userid)..tostring(transIndex)
end

-- 记录（设置）交易凭证
function StoreCheck:setTrans(item, count)
	if item == nil or count == nil or type(count) ~= "number" then
		return -1
	end
	local transId = getTransId()
	if transId == -1 then
		return nil
	end

	-- 为nil时是用户ID不存在的时候直接返回
	local transList = self:getTransList()
	if transList == nil then
		return
	end

	local trans = 
	{
		transId = transId,
		time = GetTime(),
		item = item,
		count = count,
		status = RESPONSE_STATUS_UNKNOW
	}
	table.insert(transList, trans)
	self.transList["totalCount"] = #transList
	DataBase:setLuaTable("storeTrans", self.transList)
	return transId
end

-- 更新交易凭证
function StoreCheck:updateTrans(transId, status)
	-- 状态未未知时不做处理
	if transId == nil or status == nil or status == RESPONSE_STATUS_UNKNOW then
		return
	end
	local transList = self:getTransList()
	if MapIsEmpty(transList) == true then
		return
	end
	-- 遍历
	for i,trans in pairs(transList) do
		-- ID相等
		if trans.transId == transId then
			if RESPONSE_STATUS_SUCCESS then
				transList["result"] = "success"
				self.transList["successCount"] = self.transList["successCount"] == nil and 1 or self.transList["successCount"] + 1
			else
				transList["result"] = "failed"
				self.transList["failedCount"] = self.transList["failedCount"] == nil and 1 or self.transList["failedCount"] + 1
			end
			table.remove(transList, i)
			break
		end
	end
	self.transList["totalCount"] = #transList
	DataBase:setLuaTable("storeTrans", self.transList)
end

-- 校验所有凭证（进入商城时调用）
function StoreCheck:checkAllTrans(func)
	local role = User:getRole()
	local transList = self:getTransList()
	if MapIsEmpty(transList) == false then
		local count = 0
		for i,trans in pairs(transList) do
			if count >= 100 then
				break
			end
			self.transList["unknowCount"] = self.transList["unknowCount"] == nil and 1 or self.transList["unknowCount"] + 1
			self:httpForCheckTrans(trans.transId)
			count = count + 1
		end
	end

	-- local index = #transList
	-- local trans = transList[index]
	-- local transId = trans.transId
	-- if transId == nil then
	-- 	return
	-- end

	-- local response = function(str, status, transId)
	-- 	if PRINT_MODE == 1 then
	-- 		print("response:"..tostring(str))
	-- 		print("status:"..tostring(status))
	-- 	end
	-- 	if status == 200 then
	-- 		local list = json.decode(str)
	-- 		if list.errcode == 0 then
	-- 			self:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
	-- 		elseif list.errcode == 1 then
	-- 			self:updateTrans(transId, RESPONSE_STATUS_UNKNOW)
	-- 		else
	-- 			self:updateTrans(transId, RESPONSE_STATUS_FAILED)
	-- 		end
	-- 	end

	-- 	index = index - 1
	-- 	trans = transList[index]
	-- 	transId = trans.transId
	-- 	if transId == nil then
	-- 		return
	-- 	end
	-- 	HttpManagerEx:checkTrans(transId, function(str, status)
	-- 		response(str, status, transId)
	-- 	end)
	-- end

	-- HttpManagerEx:checkTrans(transId, function(str, status)
	-- 	response(str, status, transId)
	-- end)

	-- if PRINT_MODE == 1 then
	-- 	print("222222222222222222222222222222222222222222")
	-- end

	if func then
		func()
	end
end

-- 商品校验Http请求方法体
function StoreCheck:httpForCheckTrans(transId)
	if transId == nil then
		return
	end
	HttpManagerEx:checkTrans(transId, function(status, errcode, errmsg, data)
		if PRINT_MODE == 1 then
			print("status:"..tostring(status))
			print("errcode:"..tostring(errcode))
		end
		if status == 200 then
			if errcode == 0 then
				self:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
			elseif errcode == 1 then
				self.transList["unknowCount2"] = self.transList["unknowCount2"] == nil and 1 or self.transList["unknowCount2"] + 1
				self:updateTrans(transId, RESPONSE_STATUS_UNKNOW)
			else
				self:updateTrans(transId, RESPONSE_STATUS_FAILED)
			end
		else
			self.transList["unknowCount3"] = self.transList["unknowCount3"] == nil and 1 or self.transList["unknowCount3"] + 1
		end
	end)
end

-- 获取所有交易凭证
function StoreCheck:getTransList()
	if self.transList == nil or type(self.transList) ~= "table" then
		self.transList = {}
	end

	local userid = User:getRoleAttr("userid")
	if userid == nil or string.len(userid) <= 0 then
		return nil
	end
	if self.transList["trans_"..tostring(userid)] == nil then
		self.transList["trans_"..tostring(userid)] = {}
	end
	return self.transList["trans_"..tostring(userid)]
end

return StoreCheck000000000000
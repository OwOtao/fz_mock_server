--[[
	从服务器获取orderId
	保存orderId 和 order信息到本地
	和服务器沟通完成order
	成功完成的order 删除本地的order信息
	失败的 有重试机制 没重试一次 次数加1
	次数如果到达10次的order信息,标记为异常订单,不再重复校验,并发送给服务器.
]]

local Order = {}
	
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/13 17:47:01
-- @desc 从服务器获取订单信息 orderType 订单类型 orderInfo 订单业务信息 [不同的订单有不同的业务信息,所以统一传一个Map]
function Order:getOrderIdFromWeb(orderType, orderInfo, callBack)
	if orderType == nil or MapIsEmpty(orderInfo) == true then
		return nil
	end
	-- 从服务器获取orderId
	HttpManagerEx:getFestivalOrderId(orderType, orderInfo, function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 and errcode == 0 and data.order_id ~= nil then
			self:addOneOrderInfo(data.order_id, orderType, orderInfo)
			if callBack then
				callBack(data.order_id)
			end
		else
			PopText(errmsg)
		end
	end, true)	
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/17 15:57:57
-- @desc 获取订单ID前, 先检查本地是否有当前类型的订单信息未处理


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 09:32:47
-- @desc 校验成功的订单数据,在删除前可以添加一定的处理流程
function Order:checkOrderSuccessBeforeDelete(orderInfo)
	-- 拓展处理 
	return true -- 返回处理结果,如果处理流程出现问题,状态更改为 无需校验 ,下次无需请求,直接处理结果
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/16 12:24:47
-- @desc 校验当前账户的所有订单信息
function Order:checkOrderInfoWithAccountId()
	self:checkOrderInfoList(self:getOrderInfoWithAccountId())
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 10:06:59
-- @desc 校验当前角色的所有订单信息
function Order:checkOrderInfoWithUserid()
	self:checkOrderInfoList(self:getOrderInfoWithUserid())
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 10:03:18
-- @desc 校验某一个类型的订单数据  在当前角色下
function Order:checkOrderInfoByOrderTypeUnderUser(orderType)
	self:checkOrderInfoList(self:getOrderInfoWithOrderTypeUnderUser(orderType))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/17 16:05:19
-- @desc 检查某一个类型的订单数据 在当前账户下
function Order:checkOrderInfoByTypeUnderAccount(orderType)
	self:checkOrderInfoList(self:getOrderInfoWithOrderTypeUnderAccount(orderType))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 10:04:45
-- @desc 校验指定订单号的订单数据
function Order:checkOrderInfoByOrderId(orderId)
	self:checkOneOrderInfo(self:getOneOrderInfoByOrderId(orderId))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 09:51:22
-- @desc 校验多张订单的数据
function Order:checkOrderInfoList(orderInfoList)
	if MapIsEmpty(orderInfoList) == true then
		return
	end
	for k,orderInfo in pairs(orderInfoList) do
		self:checkOneOrderInfo(orderInfo)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/17 17:17:35
-- @desc 校验特殊条件下的订单数据  参数可自定义, 带回调
function Order:checkOrderInfoWithParams(params, func)
	func = Helper:getDef(func, EMPTY_FUNC)
	if MapIsEmpty(params) == true then
		func()
		return
	end

	local checkTab = {}
	local orderData = self:getOrderData()
	local index = 0
	for orderId,orderInfo in pairs(orderData) do
		for key,value in pairs(params) do
			if orderInfo[key] ~= nil and value == orderInfo[key] then
				index = index + 1
				checkTab[tostring(orderId)] = orderInfo
			end
		end
	end

	if index >= 1 then
		for orderId,orderInfo in pairs(checkTab) do
			index = index - 1
			if index == 0 then
				self:checkOneOrderInfo(orderInfo, func)
			else
				self:checkOneOrderInfo(orderInfo)
			end
		end
	else
		func()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/13 19:38:16
-- @desc 重新校验一张订单数据
function Order:checkOneOrderInfo(orderInfo, func)
	if MapIsEmpty(orderInfo) == true or orderInfo.orderStatus == ORDER_STATUS_NOT_NEED_CHECK then
		return
	end

	-- 数据发生异常的,直接丢入异常列表
	if orderInfo.userid == nil or orderInfo.userid <= 0 or orderInfo.accountid == nil or orderInfo.accountid <= 0 then
		self:moveOneOrderToErrorList(orderInfo.order_id)
		return
	end

	HttpManagerEx:rollBackOrderStatus(orderInfo.orderType, orderInfo.order_id, orderInfo, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				-- 删除之前 可以根据业务需求, 做一定的处理,处理成功删除记录,处理失败更新订单信息的状态为无需校验
				if self:checkOrderSuccessBeforeDelete(orderInfo) == true then
					self:deleteOneOrderInfo(orderInfo.order_id)
					if func then
						func()
					end
				else
					self:updateOneOrderToNotNeedCheck()
				end
			else
				self:deleteOneOrderInfo(orderInfo.order_id)
			end
		else
			self:updateOneOrderCheckTimes(orderInfo.order_id)
		end
	end, true)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/13 17:54:47
-- @desc 本地保存一份订单信息 [需区分角色]
--[[
	本地订单保存结构
	{
		orderid1 = {
			order_id = orderid1,
			orderType = orderType,
			chechTimes = 0,
			userid = userid,
			accountid = accountid,
			orderStatus = orderStatus
		},
		orderid2 = {
			order_id = orderid2,
			orderType = orderType,
			chechTimes = 0,
			userid = userid,
			accountid = accountid,
			orderStatus = orderStatus
		}
		...
		errOrder =  -- 存储异常订单信息
		{}
	}
]]
function Order:addOneOrderInfo(orderId, orderType, orderInfo)
	if orderId == nil or orderType == nil or MapIsEmpty(orderInfo) == true then
		return 
	end
	local data = Helper:getDef(self:getOrderData(), {})
	data[tostring(orderId)] = orderInfo 				-- 订单详细的业务信息
	data[tostring(orderId)].order_id = orderId 				-- 订单Id,从服务器获取
	data[tostring(orderId)].orderType = orderType 	-- 订单类型,和服务器确定的一个值
	data[tostring(orderId)].checkTimes = 0			-- 校验次数
	data[tostring(orderId)].userid = User:getUserId() -- 记录当前角色的Id
	data[tostring(orderId)].accountid = User:getAccountId() -- 记录当前账户的ID
	data[tostring(orderId)].orderStatus = ORDER_STATUS_NORMAL -- 订单状态 ORDER_STATUS_NORMAL = 1 普通的 ORDER_STATUS_NOT_NEED_CHECK = 2 订单信息无误,无需校验 [和服务器校验成功,但本地处理出现异常的情况]
	self:saveOrderdata(data)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 09:47:22
-- @desc 更新一条订单信息的状态为 无需校验
function Order:updateOneOrderToNotNeedCheck(orderId)
	if orderId == nil then
		return
	end
	local orderInfo = self:getOneOrderInfoByOrderId(orderId)
	if MapIsEmpty(orderInfo) == true then
		return
	end
	orderInfo.orderStatus = ORDER_STATUS_NOT_NEED_CHECK
	self:saveOneOrderInfoWithOrderId(orderId, orderInfo)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 08:52:36
-- @desc 更新一条订单信息的校验次数 [次数到达一定次数,则标记为异常,不再校验,并发给服务器]
function Order:updateOneOrderCheckTimes(orderId)
	local orderInfo = self:getOneOrderInfoByOrderId(orderId)
	if MapIsEmpty(orderInfo) == true then
		return
	end	
	orderInfo.checkTimes = orderInfo.checkTimes + 1
	-- 订单请求次数超过10次,则 移动到异常列表
	if orderInfo.checkTimes >= 10 then
		self:moveOneOrderToErrorList(orderId)
	else
		self:saveOneOrderInfoWithOrderId(orderId, orderInfo)	
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/13 19:09:36
-- @desc 删除一条订单信息,只能通过orderId删除
function Order:deleteOneOrderInfo(orderId)
	if orderId == nil then
		return
	end
	local data = self:getOrderData()
	data[tostring(orderId)] = nil
	self:saveOrderdata(data)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 09:09:56
-- @desc 将一条异常订单移至 异常列表
function Order:moveOneOrderToErrorList(orderId)
	if orderId == nil then
		return
	end
	local orderInfo = self:getOneOrderInfoByOrderId(orderId)
	if MapIsEmpty(orderInfo) == true then
		return
	end
	local orderData = self:getOrderData()
	orderData.errOrder = Helper:getDef(orderData.errOrder, {}) 	-- 异常订单列表 
	orderData.errOrder[tostring(orderId)] = orderInfo 					-- 将订单信息保存至异常列表
	self:saveOrderdata(orderData) 								-- 保存所有的订单信息
	self:deleteOneOrderInfo(orderId)  							-- 删除当前的订单信息
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 09:16:56
-- @desc 获取异常订单信息列表
function Order:getErrOrderMap()
	local orderData = self:getOrderData()
	return Helper:getDef(orderData.errOrder, {})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/13 18:54:59
-- @desc 获取所有的订单信息
function Order:getOrderData()
	return Helper:getDef(DataBase:getLuaTable("OrderInfo"), {})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/13 18:55:34
-- @desc 保存所有的订单信息
function Order:saveOrderdata(orderData)
	DataBase:setLuaTable("OrderInfo", Helper:getDef(orderData, {}))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 19:49:57
-- @desc 保存一个订单数据信息
function Order:saveOneOrderInfoWithOrderId(orderId, orderInfo)
	if orderId == nil then
		return
	end
	local data = self:getOrderData()
	data[tostring(orderId)] = orderInfo
	self:saveOrderdata(data)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/13 17:58:18
-- @desc 获取当前角色在本地的订单信息
function Order:getOrderInfoWithUserid(userid)
	local userid = Helper:getDef(userid, User:getUserId()) 
	local data = self:getOrderData()
	local retTab = {}
	for orderId,orderInfo in pairs(data) do
		if orderInfo.userid == userid then
			retTab[tostring(orderId)] = orderInfo
		end
	end
	return retTab
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/16 12:22:35
-- @desc 获取当前账户在本地的订单信息
function Order:getOrderInfoWithAccountId()
	local accountid = User:getAccountId()
	local data = self:getOrderData()
	local retTab = {}
	for orderId,orderInfo in pairs(data) do
		if orderInfo.accountid == accountid then
			retTab[tostring(orderId)] = orderInfo
		end
	end
	return retTab
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/13 18:03:43
-- @desc 获取当前角色指定类型的订单信息列表
function Order:getOrderInfoWithOrderTypeUnderUser(orderType)
	local retTab = {}
	if orderType == nil then
		return retTab
	end
	local userOrderInfo = self:getOrderInfoWithUserid()
	if MapIsEmpty(userOrderInfo) == true then
		return retTab
	end
	for orderId, orderInfo in pairs(userOrderInfo) do
		if orderInfo.orderType == orderType then
			table.insert(retTab, orderInfo)
		end
	end
	return retTab
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/17 16:56:46
-- @desc 获取当前账户 下指定类型的订单信息列表
function Order:getOrderInfoWithOrderTypeUnderAccount(orderType)
	local retTab = {}
	if orderType == nil then
		return retTab
	end
	local accountOrderInfo = self:getOrderInfoWithAccountId()
	if MapIsEmpty(accountOrderInfo) == true then
		return retTab
	end
	for orderId, orderInfo in pairs(accountOrderInfo) do
		if orderInfo.orderType == orderType then
			table.insert(retTab, orderInfo)
		end
	end
	return retTab
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 08:54:47
-- @desc 根据orderId获取指定订单信息 [只会在当前角色的订单信息内查找]
function Order:getOneOrderInfoByOrderId(orderId)
	if orderId == nil then
		return {}
	end
	local data = self:getOrderData()
	return Helper:getDef(data[tostring(orderId)], {})
end

return Order0
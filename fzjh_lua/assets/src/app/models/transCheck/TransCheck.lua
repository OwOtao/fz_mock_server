-- 物品交易及校验模块
local TransCheck = {}

function TransCheck:init()
	self.transList = DataBase:getLuaTable("historyTransList")
end

TransCheck:init()
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

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/08 18:05:05
-- @desc 获取orderId
function TransCheck:getTransIdFromWeb(func)
	HttpManagerEx:getBuyOrderId(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			func(data.order_id)
		end
	end, IS_SHOW_WAITING)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/09 11:37:52
-- @desc 记录（设置）交易凭证 transType 1 元宝类 2 月卡类 3 福缘丹 4 论剑奖励 5 江湖美誉 8 冥币 12 积分 (从服务器获取订单ID)
function TransCheck:setTransWithWebOrderId(callBack, item, count, transType)
	if item == nil or count == nil or type(count) ~= "number" or transType == nil then
		return -1
	end
	self:getTransIdFromWeb(function(transId)
		if transId == nil then
			return
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
			transType = transType,
			status = RESPONSE_STATUS_UNKNOW
		}
		table.insert(transList, trans)
		self.transList["totalCount"] = #transList
		DataBase:setLuaTable("historyTransList", self.transList)

		callBack(transId)
	end)
end

-- 记录（设置）交易凭证 transType 1 元宝类 2 月卡类 3 福缘丹 4 论剑奖励
function TransCheck:setTrans(item, count, transType)
	if item == nil or count == nil or type(count) ~= "number" or transType == nil then
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
		transType = transType,
		status = RESPONSE_STATUS_UNKNOW
	}
	table.insert(transList, trans)
	self.transList["totalCount"] = #transList
	DataBase:setLuaTable("historyTransList", self.transList)
	return transId
end

-- 获取月卡奖励
local function getYueKaReward(num, params)
	if num == nil or MapIsEmpty(params) == true then
		return
	end
	local role = User:getRole()
	for name,val in pairs(params) do
		-----------------------------------------------------------------------------------------------------------
		-- @author XiaoZhiWei
		-- @time 2016/12/20 15:06:44
		-- @desc 原来只会增加经验,潜能,金钱3个属性.第一个判断兼容老版本,下面两个为结构改变后的处理流程
		if name == "exp" or name == "pot" or name == "money" then
			role:addAttr(name, val * num)
		elseif name == "attr" then
			for attrName, addNum in pairs(val) do
				role:addAttr(attrName, addNum * num)
			end
		elseif name == "items" then
			for itemId,addNum in pairs(val) do
				role:addItemCount(itemId, addNum * num)
			end
		end
	end
end

-- 更新交易凭证
function TransCheck:updateTrans(transId, status)
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
			if status == RESPONSE_STATUS_SUCCESS then
				if trans.transType == 2 then
					--月卡奖励返回至YueKaLayer中的getReward2请求回调中
					getYueKaReward(trans.count, trans.item)
					-- Helper:print_lua_table(trans.item)
				end
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
	DataBase:setLuaTable("historyTransList", self.transList)
end

-- 校验所有凭证（进入商城时调用）
function TransCheck:checkTransWithType(transType, func)
	self:checkAllTrans(func, transType)
end

-- 校验所有凭证（进入商城时调用）
function TransCheck:checkAllTrans(func, transType)
	local role = User:getRole()
	local transList = self:getTransList()
	if MapIsEmpty(transList) == false then
		local count = 0
		for i,trans in pairs(transList) do
			if count >= 100 then
				break
			end
			if transType == nil or (transType ~= nil and transType == trans.transType) then
				self.transList["unknowCount"] = self.transList["unknowCount"] == nil and 1 or self.transList["unknowCount"] + 1
				if trans.transType == 2 then
					self:httpForYueKaCheckTrans(trans)
				else
					self:httpForCheckTrans(trans.transId, trans.transType)
				end
				count = count + 1
			end
		end
	end

	if func then
		func()
	end
end

--检验月卡当日福利领取订单
function  TransCheck:httpForYueKaCheckTrans(trans)
	-- local transDate = tonumber(Helper:date("%Y%m%d",Helper:getDef(trans.time,GetTime()))) + 1
	-- local transTime = Helper:getTimeStampWithStringDate(tostring(transDate),0)
	local transTime = tonumber(Helper:diffWithDate(trans.time,GetTime()))
	if transTime ~= 0 then
		--过期订单 删除订单
		self:updateTrans(trans.transId, RESPONSE_STATUS_FAILED)
	else
		local role = User:getRole()
		local homeland_open = 0

		local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen(false) == true then
			homeland_open = 1
		end
		
		HttpManagerEx:getReward2(1, trans.transId,homeland_open, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if PRINT_MODE_GHZ == true then
						PopText("有订单，但是元宝道具都没有领取，现在补发全部")
					end
					self:updateTrans(trans.transId, RESPONSE_STATUS_SUCCESS)
				elseif errcode == 7 then
					if PRINT_MODE_GHZ == true then
						PopText("元宝已经领取，现在补发道具")
					end
					self:updateTrans(trans.transId, RESPONSE_STATUS_SUCCESS)
				else
					self:updateTrans(trans.transId, RESPONSE_STATUS_FAILED)
				end
			else

			end

		end)
	end

end

-- 商品校验Http请求方法体
function TransCheck:httpForCheckTrans(transId, transType)
	if transId == nil or transType == nil then
		return
	end
	HttpManagerEx:checkTrans(transType, transId, function(status, errcode, errmsg, data)
		if PRINT_MODE == 1 then
			print("errcode:"..tostring(errcode))
			print("status:"..tostring(status))
		end
		if status == 200 then
			-- add by XiaoZhiWei 2016/12/27 09:51:20 bug修复:由于数据加密,errcode有可能获取不到,所以没有errcode的情况不能判断为失败
			-- -1 参数错误
			-- 0 无异常
			-- 1 不存在trans_id
			-- 2 购买商品失败补偿元宝 - SQL执行错误（可以重试）
			-- 3 不存在福利trans_id
			-- 4 更新trans_id转太失败 - 可重试
			-- 5 不存在比武奖励
			-- 6 比武trans_id更新失败 - 重试
			-- 8 不存在福缘丹领取记录
			-- 7 非法的event_id
			-- 9 福缘丹trans_id更新失败 重试。
			-- 1,3,5,7,8 都可以删除这个trans_id。 2,4,6,9重试。 0 OK。 -1 参数错误 删除transId
			if errcode == 0 then
				self:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
			elseif errcode == -1 or errcode == 1 or errcode == 3 or errcode == 5 or errcode == 7 or errcode == 8 then
				self:updateTrans(transId, RESPONSE_STATUS_FAILED)
			elseif errcode == 2 or errcode == 4 or errcode == 6 or errcode == 9 then
				-- self:updateTrans(transId, RESPONSE_STATUS_UNKNOW)
			else
				-- 其他情况 不做处理
				-- self:updateTrans(transId, RESPONSE_STATUS_FAILED)
			end
		else
		end
	end)
end

-- 获取所有交易凭证
function TransCheck:getTransList()
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


local conf_cn = {
	["ssyjf"] = "新春礼券",  --双十一,
	["znqjf"] = "小年礼券",
	["luckpoint"] = "好运通宝",
	["daily_point"] = "积分"
}

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 元宝商品购买
-- @desc discount 是否打折 0 不折 , 1打折
function TransCheck:buyItem(item,func, others, num,discount)
	if type(func) ~= "function" then
		func = nil
	end
	num = Helper:getDef(num,1)
	discount = Helper:getDef(discount,0)
	-- 额外传给服务器的数据 经脉印记 折扣免单
    others = Helper:getDef(others, {})

	local role = User:getRole()
	local transType = 1
	-- add by XiaoZhiWei 2016/12/27 10:16:40 福缘丹 的类型要设置为3
	if item.itemId == "fuyuandan" then
		transType = 3
	end
	local transId = TransCheck:setTrans(clone(item), num, transType)
	if transId == nil or (type(transId) == "number" and transId <= 0) then
		return
	end

	HttpManagerEx:buyGoods(item.id, item.itemId, num, transId, others,discount,function(status,errcode,errmsg,data)
		print("  status,errcode,errmsg,data ="..status.."   "..tostring(errcode).."  "..tostring(data))
		if status == 200 then
			if errcode == 0 then
				TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
				if func then
					func("success",data.special_reward)
				end

				Mob.buy(item.name, num, item.price*num)
				role:setAttr("yuanbao", data.total_yuanbao)


	            if MapIsEmpty(data.activity) == false then
	            	for k,v in pairs(data.activity) do
	            		if v > 0 then
	            			PopText(conf_cn[k].." +"..v)
	            		end
	            	end
	            end

				if MapIsEmpty(others) ~= true and MapIsEmpty(others.mark) ~= true then
					if others.mark.isFreeSingle == true and data.remove_yuanbao == 0 then
						PopText("购买免单")
					end
				end
			else
				PopText("购买失败，"..tostring(errmsg))
				TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
				if func then
					func("failed",data.special_reward)
				end
			end
		else
	    	PopText("网络请求出错,请换个网络环境再试!")
			if func then
				func("failed",data.special_reward)
			end
		end
	end, IS_SHOW_WAITING)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--[[
	以下的trans校验是在做签到时新增的,只记录了校验trans的接口以及记录时间
	并且 拥有trans记录的时候会去服务器请求,不管服务器返回成功或者失败,本地记录都删除
	之前的trans在校验成功后会有一些数据操作,但是下面新增的不会有任何数据操作,仅仅是一个凭证的校验
	服务器在收到改校验请求时,将改记录标记为删除或直接删除,相当于本次交易无效,请重新操作
]]

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/15 11:48:23
-- @desc 获取所有的tuans 列表
function TransCheck:getTransInfo()
	return Helper:getDef(DataBase:getLuaTable("transInfo"), {})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/15 11:17:26
-- @desc 获取 相关 url 的trans 列表
function TransCheck:getTransListWithUrl(url)
	local transInfo = self:getTransInfo()
	return Helper:getDef(transInfo[url], {})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/15 11:49:54
-- @desc 设置相关 url 的truans 记录
function TransCheck:setTransListWithUrl(url, transList)
	if url == nil then
		return
	end
	local transInfo = self:getTransInfo()
	transInfo[url] = transList
	DataBase:setLuaTable("transInfo", transInfo)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/13 14:29:15
-- @desc 生成TransId 并记录下来 url 检查trans的接口
function TransCheck:setTransIdWithUrl(url)
	if url == nil then
		return -1
	end
	local transId = getTransId()
	if transId == -1 then
		return nil
	end

	local transList = self:getTransListWithUrl(url)
	local trans =
	{
		transId = transId,
		time = GetTime(),
	}

	table.insert(transList, trans)
	self:setTransListWithUrl(url, transList)
	return transId
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/15 12:03:17
-- @desc 检查所有接口的trans记录
function TransCheck:checkAllUrlTrans()
	local transInfo = self:getTransInfo()
	if MapIsEmpty(transInfo) == false then
		for url,transList in pairs(transInfo) do
			self:checkTransWithUrl(url, transList)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/15 11:16:26
-- @desc 检查指定接口的trans记录
function TransCheck:checkTransWithUrl(url, transList)
	local transList = Helper:getDef(transList, self:getTransListWithUrl(url))
	-- 校验记录不为空的时候
	if MapIsEmpty(transList) == false then
		for i,trans in ipairs(transList) do
			self:checkOneTransWithUrl(url, trans)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/15 11:34:29
-- @desc 检查一条指定接口的trans记录
--[[
	同一个接口考虑做一个队列
]]
function TransCheck:checkOneTransWithUrl(url, trans)
	if url == nil or MapIsEmpty(trans) == true then
		return
	end
	HttpManagerEx:retryPostWithHeader(url, {trans_id = trans.transId}, nil,
    function(response, status)
    	local responseData = nil
        if status == 200 then
			self:deleteOneTransWithUrl(url, trans.transId)
        else
            PopText("网络连接失败, 请检查网络是否正常")
        end
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/15 11:43:31
-- @desc 删除一条trans记录
function TransCheck:deleteOneTransWithUrl(url, transId)
	local transList = self:getTransListWithUrl(url)
	if MapIsEmpty(transList) == false then
		for i,trans in ipairs(transList) do
			if transId == trans.transId then
				table.remove(transList, i)
				break
			end
		end
	end
	self:setTransListWithUrl(url, transList)
end


return TransCheck
000000
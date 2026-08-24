local ShenBingRongLian = {}
local godweapon = require("script.others.godweapon")
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 14:59:35
-- @desc 熔炼结果
function ShenBingRongLian:getResult(temperature,rlList)
	assert(temperature and type(rlList) == "table")
	local result = {}
	local rlMap = self:createMapByTable(rlList)
	result,rlList = self:getSpecialResult(temperature,rlMap)
	result = self:getCommonResult(temperature,rlMap,result)
	-- return result
	return self:helpChange(result)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 16:26:08
-- @desc  转换一下数据格式
function ShenBingRongLian:helpChange(result)
	local list = {}
	for itemId,count in pairs(result) do 
		table.insert(list,{itemId = itemId,count = count})
	end
	return list
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 15:00:11
-- @desc 判断特殊熔炼
function ShenBingRongLian:getSpecialResult(temperature,rlMap)
	assert(temperature and type(rlMap) == "table")
	local result = {}
	-- Helper:print_lua_table(rlMap)
	-- print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
	local configuration = self:getSpecilaConfiguration()

	for k , config in pairs(configuration) do 
		print("=========================kkkkk======================",k)
		local needMap = {}
		local count = 20
		for i = 1,20 do 
			-- print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^",config["Materia"..tostring(i)])
			if config["Materia"..tostring(i)] == nil then
				-- print("--------------------------temperature:",temperature,",config.needtemperature:",config.needtemperature,i)
				if temperature >= config.needtemperature then
					--特殊熔炼成功
					-- table.insert(result,assert(config.successMaterial))
					print("特殊熔炼成功")
					result = self:addItem(result,assert(config.successMaterial),count)
				else
					--特殊熔炼成功
					print("特殊熔炼失败")
					-- table.insert(result,assert(config.failMaterial))
					result = self:addItem(result,assert(config.failMaterial),count)
				end
				--rlMap扣掉特殊熔炼所需物品
				for itemId,num in pairs(needMap) do 
					if rlMap[itemId] == nil or rlMap[itemId].count < count then
						assert("逻辑有问题")
					else
						rlMap[itemId].count = rlMap[itemId].count - count
						if rlMap[itemId].count == 0 then
							rlMap[itemId] = nil
						end
					end
				end
				break
			end
			if rlMap[config["Materia"..tostring(i)]] == nil then
				break
			end
			if rlMap[config["Materia"..tostring(i)]].count < count then
				count = rlMap[config["Materia"..tostring(i)]].count
			end
			needMap[config["Materia"..tostring(i)]] = 1
		end
	end
	-- print("----------------------------------------判断特殊熔炼之后---------------------------------------------")
	-- Helper:print_lua_table(rlMap)
	return result ,rlMap
end


--获取熔炼的最高温度
function ShenBingRongLian:getMaxTemperature(temperature,rlList)
	assert(temperature and type(rlList) == "table")
	local result = {}
	local rlMap = self:createMapByTable(rlList)
	assert(temperature and type(rlMap) == "table")
	local result = {}
	-- Helper:print_lua_table(rlMap)
	-- print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
	local configuration = self:getSpecilaConfiguration()

	for k , config in pairs(configuration) do 
		print("=========================kkkkk======================",k)
		local needMap = {}
		local count = 20
		for i = 1,20 do 
			-- print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^",config["Materia"..tostring(i)])
			if config["Materia"..tostring(i)] == nil then
				-- print("--------------------------temperature:",temperature,",config.needtemperature:",config.needtemperature,i)
				if temperature < config.needtemperature then
					temperature = config.needtemperature
				end

			end
			if rlMap[config["Materia"..tostring(i)]] == nil then
				break
			end
			if rlMap[config["Materia"..tostring(i)]].count < count then
				count = rlMap[config["Materia"..tostring(i)]].count
			end
			needMap[config["Materia"..tostring(i)]] = 1
		end
	end
	return temperature

end
function ShenBingRongLian:addItem(result,itemId,count)
	if result[itemId] == nil then	
		result[itemId] = count
	else
		result[itemId] = result[itemId] + count
	end
	return result
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 15:25:20
-- @desc 普通熔炼
function ShenBingRongLian:getCommonResult(temperature,rlMap,result)
	assert(temperature and type(rlMap) == "table" and type(result) == "table")
	local configuration = self:getCommonConfiguration()
	for k , itemdata in pairs(rlMap) do 
		-- assert(configuration[k],"配置有问题，可以熔炼，但是没有配置熔炼结果")
		if configuration[k] == nil then
			configuration[k] = {
				meltingsuccess = "rongliianshibai2",
				meltingfail = "rongliianshibai2"
			}
		end
		local itemAttr = Item:getOneItemByKey(k)
		if temperature >= assert(tonumber(itemAttr.melting),"该物品没有熔点，应该不可以熔炼，选择熔炼材料逻辑错误") then
			-- table.insert(result,assert(configuration[k].meltingsuccess))
			result = self:addItem(result,assert(configuration[k].meltingsuccess),itemdata.count)
		else
			-- table.insert(result,assert(configuration[k].meltingfail))
			result = self:addItem(result,assert(configuration[k].meltingfail),itemdata.count)
		end
	end
	return result
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 15:06:58
-- @desc 将熔炼材料表转成map
function ShenBingRongLian:createMapByTable(rlList)
	assert(type(rlList) == "table")
	local rlMap = {}
	for k, itemData in pairs(rlList) do 
		if rlMap[itemData.itemId] ~= nil then
			rlMap[itemData.itemId].count = rlMap[itemData.itemId].count + itemData.count
		else
			rlMap[itemData.itemId] = itemData
		end
	end
	return rlMap
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 15:12:39
-- @desc 获取特殊熔炼配置表
function ShenBingRongLian:getSpecilaConfiguration()
	local configuration = assert(godweapon["specialRongLianConfig"])
	local temp = {}
	for k,config in pairs(configuration) do 
		table.insert(temp,config)
	end
	table.sort(temp,function(a,b)
		return tonumber(a.priority1) < tonumber(b.priority1)
	end)
	-- print("----------------------------获取特殊熔炼配置表-----------------------------------")
	-- Helper:print_lua_table(temp)
	return temp
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 15:33:33
-- @desc 获取普通熔炼配置表
function ShenBingRongLian:getCommonConfiguration()
	if self.configuration == nil then
		self.configuration = {}
		local configuration = assert(godweapon["rongLianItems"])
		for k,conf in pairs(configuration) do 
			self.configuration[conf.itemid] = conf
		end
	end
	return self.configuration
end
return ShenBingRongLian0000000000000000
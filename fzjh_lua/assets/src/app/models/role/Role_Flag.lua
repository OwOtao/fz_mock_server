local Role_Flag = {}

-- 人物标记
function Role_Flag:getFlag(name, def)
	-- print("def1 = ", def)
	if def == nil then -- 兼容之前的默认值 add by TangJian 2016/11/05 18:17:01
		def = 0
	end
	-- print("def2 = ", def)

	if self._flags == nil then
		self._flags = {}
	end

	if self._flags[name] == nil then
		-- print("def3 = ", def)
		return def -- 修复得到一次之后, 就会被设置为默认值的bug add by TangJian 2016/11/05 18:28:57
	end

	if self._flags[name] == 0 then
		return 0
	end

	return self._flags[name]
end

function Role_Flag:setFlag(name, value)
	if self._flags == nil then
		self._flags = {}
	end

	if self._flags[name] == nil then
		self._flags[name] = 0
	end

	self._flags[name] = value

	self._flags = TableProxy:createEncryptedTableRecursive(self._flags)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/29 18:31:44
-- @desc 获取按日计算的标记,按日计算的标记会在新的一天清除 如果为空 返回 0
function Role_Flag:getDayFlag(name)
	if self._dayFlags == nil then
		self._dayFlags =
		{
			time = GetTime(),
			flags = {}
		}
	else
		if Helper:diffWithDate(GetTime(), self._dayFlags.time) >= 1 then
			self._dayFlags.flags = {}
		end
		self._dayFlags.time = GetTime()
	end

	if self._dayFlags.flags[name] == nil then
		self._dayFlags.flags[name] = 0
	end

	if self._dayFlags.flags[name] == 0 then
		return 0
	end

	return self._dayFlags.flags[name]
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/29 18:32:06
-- @desc 设置按日计算的标记,按日计算的标记会在新的一天清除
function Role_Flag:setDayFlag(name, value)
	if self._dayFlags == nil then
		self._dayFlags =
		{
			time = GetTime(),
			flags = {}
		}
	else
		if Helper:diffWithDate(GetTime(), self._dayFlags.time) >= 1 then
			self._dayFlags.flags = {}
		end
		self._dayFlags.time = GetTime()
	end

	if self._dayFlags.flags[name] == nil then
		self._dayFlags.flags[name] = 0
	end

	self._dayFlags.flags[name] = value

	self._dayFlags = TableProxy:createEncryptedTableRecursive(self._dayFlags)
end

-- 设置人物限时标记
function Role_Flag:setTimeLimitFlag(name, value, timeLimit)
	if self._timeLimitFlags == nil then
		self._timeLimitFlags = {}
	end

	-- 限时没有则为0
	if timeLimit == nil then
		timeLimit = 0
	end
	--print("设置人物限时标记 " .. name .. " value = " .. value .. " timeLimit = " .. timeLimit)
	-- 检测标记是否全部超时 超时则清除所有标记
	local flag = false
	for k,v in pairs(self._timeLimitFlags) do
		if self:getTimeLimitFlag(k) ~= 0 then
			flag = true
		end
	end
	if flag == false then
		self._timeLimitFlags = {}
	end

	if self._timeLimitFlags[name] == nil then
		self._timeLimitFlags[name] =
		{
			value = 0,
			timeLimit = 0,
			startTime = 0,
		}
	end

	self._timeLimitFlags[name].value = value
	self._timeLimitFlags[name].timeLimit = timeLimit
	self._timeLimitFlags[name].startTime = GetTime()
	
	self._timeLimitFlags = TableProxy:createEncryptedTableRecursive(self._timeLimitFlags)
end

-- 获取人物限时标记
function Role_Flag:getTimeLimitFlag(name)
	if self._timeLimitFlags == nil then
		self._timeLimitFlags = {}
	end

	if self._timeLimitFlags[name] == nil then
		self._timeLimitFlags[name] =
		{
			value = 0,
			timeLimit = 0,
			startTime = 0,
		}
	end

	if GetTime() - self._timeLimitFlags[name].startTime >= self._timeLimitFlags[name].timeLimit then
		self._timeLimitFlags[name] =
		{
			value = 0,
			timeLimit = 0,
			startTime = 0,
		}
	end
	--print("value = " .. self._timeLimitFlags[name].value .. " 时间  = " .. GetTime() - self._timeLimitFlags[name].startTime)
	if self._timeLimitFlags[name].value == 0 then
		return 0
	end

	return self._timeLimitFlags[name].value
end
function Role_Flag:getTimeLimitFlagTime(name)
	if self._timeLimitFlags == nil then
		self._timeLimitFlags = {}
	end
	if self._timeLimitFlags[name] == nil then
		--print("人物限时标记为空 " .. name)
		self._timeLimitFlags[name] =
		{
			value = 0,
			timeLimit = 0,
			startTime = 0,
		}
	end
	if GetTime() - self._timeLimitFlags[name].startTime >= self._timeLimitFlags[name].timeLimit then
		self._timeLimitFlags[name] =
		{
			value = 0,
			timeLimit = 0,
			startTime = 0,
		}
		return self._timeLimitFlags[name].startTime
	end

	if self._timeLimitFlags[name].timeLimit- GetTime() + self._timeLimitFlags[name].startTime == 0 then
		return 0
	end

	return self._timeLimitFlags[name].timeLimit- GetTime()+self._timeLimitFlags[name].startTime
end
function Role_Flag:updateTimeLimitFlag(name,value)
	if self._timeLimitFlags == nil then
		self._timeLimitFlags = {}
	end
	if self._timeLimitFlags[name] == nil and value == nil then
		return
	end
	if GetTime() - self._timeLimitFlags[name].startTime >= self._timeLimitFlags[name].timeLimit then
		self._timeLimitFlags[name] =
		{
			value = 0,
			timeLimit = 0,
			startTime = 0,
		}
		return
	end
	local newTImeLimit = self._timeLimitFlags[name].timeLimit - (GetTime()-self._timeLimitFlags[name].startTime)

	self._timeLimitFlags[name].value = value
	self._timeLimitFlags[name].timeLimit = newTImeLimit
	self._timeLimitFlags[name].startTime = GetTime()

	self._timeLimitFlags = TableProxy:createEncryptedTableRecursive(self._timeLimitFlags)
end

-- 获取可传承角色标记（不随人物重置而重置）
function Role_Flag:getInheritFlag(name)
	if self._inherit_flags == nil then
		self._inherit_flags = {}
	end
	if self._inherit_flags[name] == nil then
		self._inherit_flags[name] = 0
	end

	if self._inherit_flags[name] == 0 then
		return 0
	end

	return self._inherit_flags[name]
end

--设置可传承角色标记
function Role_Flag:setInheritFlag(name, value)
	if self._inherit_flags == nil then
		self._inherit_flags = {}
	end

	if self._inherit_flags[name] == nil then
		self._inherit_flags[name] = 0
	end

	self._inherit_flags[name] = value

	self._inherit_flags = TableProxy:createEncryptedTableRecursive(self._inherit_flags)
end

--角色标记加密
function Role_Flag:encryptedRoleFlag()
	if self._flags then
		self._flags = TableProxy:createEncryptedTableRecursive(self._flags)
	end

	if self._inherit_flags then
		self._inherit_flags = TableProxy:createEncryptedTableRecursive(self._inherit_flags)
	end

	if self._dayFlags then
		self._dayFlags = TableProxy:createEncryptedTableRecursive(self._dayFlags)
	end

	if self._timeLimitFlags then
		self._timeLimitFlags = TableProxy:createEncryptedTableRecursive(self._timeLimitFlags)
	end
end

return Role_Flag00000000000
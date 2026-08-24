--@RefType [MeridianHelper]
local MeridianHelper = require("app.models.Meridian.MeridianHelper")
--@RefType [MeridianResources]
local MeridianResources = require("app.models.Meridian.MeridianResources")

local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Role = require("app.models.role.Role")
local HuaZhi = require("script.meridian.huazhi").Text

-- 经脉系统
local Meridian = {}

local MeridianAcupoint = requireWithEncrypt("script.meridian.meridian")["acupoint"]
local MeridianExp = requireWithEncrypt("script.meridian.meridian")["exp"]
local MeridianImprinting = requireWithEncrypt("script.meridian.meridianImprinting")["Sheet1"]

-- 阳维→阴维→阳跷→阴跷→冲脉→带脉→任脉→督脉
local meridianNameList =
{
	[1] = "阳维",
	[2] = "阴维",
	[3] = "阳跷",
	[4] = "阴跷",
	[5] = "冲脉",
	[6] = "带脉",
	[7] = "任脉",
	[8] = "督脉",
}

function Meridian:init()
	-- 穴道表
	if self.MeridianAcupoint == nil then
		self.MeridianAcupoint = {}
		for i = 1,8 do
			local acupointList = {}
			for k,v in pairs(MeridianAcupoint) do
				if v.meridian == meridianNameList[i] then
					table.insert(acupointList, v)
				end
			end

			table.sort(acupointList, function(a, b)
				return a.id < b.id
			end)

			table.insert(self.MeridianAcupoint, {id = i, name = meridianNameList[i], acupointList = acupointList})
		end
	end

	self.MeridianAcupoint = TableProxy:createEncryptedTableRecursive(self.MeridianAcupoint)

	-- 经脉等级表
	if self.MeridianExp == nil then
		self.MeridianExp = {}
		for i,v in pairs(MeridianExp) do
			table.insert(self.MeridianExp, v)
		end

		table.sort( self.MeridianExp,function(a, b)
			return a.lv < b.lv
		end )
	end

	self.MeridianExp = TableProxy:createEncryptedTableRecursive(self.MeridianExp)
end

-- 初始化经脉属性
function Meridian:initMerdian()
	local role = User:getRole()

	local meridian = role:getAttr("meridian")

	if MapIsEmpty(meridian) == true then
		meridian = {}
		-- meridianCount 已经激活的经脉数量
		-- acupointCount 当前经脉已经激活的穴道数量
		-- alreadyDisease 当前穴道是否已经暗疾
		-- alreadyDisorder 当前穴道是否已经絮乱
		-- acupointState 0 未开启 1 待冲穴 2 待固本 3 完成 4 发现暗疾 5 真气紊乱 6 激活属性 7 培元
		meridian.meridianCount = 0
		meridian.acupointCount = 0
		meridian.acupointState = 1
		meridian.alreadyDisease = 0
		meridian.alreadyDisorder = 0

		-- 经脉属性加成的选择记录 1 经脉索引meridianIndex 2 穴道索引acupointIndex 3 选择项selectNum
		meridian.attrList = {}

		-- 经脉固本增加的属性总和
		meridian.attrTotal =
		{
			["qiMax"] = 0, 			-- 气血上限
			["neiLiLimit"] = 0,		-- 内力上限
			["atk"] = 0,			-- 攻击力
			["dodge"] = 0,			-- 闪躲力
			["def"] = 0,			-- 防御力
			["damage"] = 0,			-- 伤害力
			["protect"] = 0,		-- 防护力
		}
		role:setAttr("meridian", meridian)
		role:setAttr("meridianExp", 0)
		role:setAttr("breathVal", 0)
		role:setAttr("leftRightFightExp", 0)
	end
	-- 重新计算经脉增加的属性总和
	-- self:countGuBenAttrTotal(role)

end

-- 获得经脉名字
function Meridian:getMeridianName(num)
	return meridianNameList[num]
end

-- 获得穴道颜色
function Meridian:getAcupointColor(meridianIndex, acupointIndex)
	return self.MeridianAcupoint[meridianIndex].acupointList[acupointIndex].color
end

-- 获得穴道名字
function Meridian:getAcupointName(meridianIndex, acupointIndex)
	return self.MeridianAcupoint[meridianIndex].acupointList[acupointIndex].name
end


-- 获得经脉穴道列表
function Meridian:getAcupointList(num)
	return self.MeridianAcupoint[num].acupointList
end

-- 根据经验获得经脉等级
function Meridian:getMeridianLv(exp)
	if exp == nil then
		return 1
	end

	local lv = 1

	for i,v in ipairs(self.MeridianExp) do
		if exp > v.exp and lv < v.lv then
			lv = v.lv
		end
	end

	return lv
end

-- 获取经脉印记属性 byId
function Meridian:getImprintingId(imprintingId)
	for k,v in pairs(MeridianImprinting) do
		if imprintingId == v.imprintingId then
			return v
		end
	end
	return nil
end

-- 获得经脉印记数据
function Meridian:getImprinting()
	return MeridianImprinting
end

-- 获得经脉穴位数据
function Meridian:getMeridianAcupoint()
	return MeridianAcupoint
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/10/19 20:05:21
-- @desc 获得当前冲穴失败次数
function Meridian:getFailCount()
	local role = User:getRole()
	local meridian = role:getAttr("meridian")

	if meridian.failCount == nil then
		meridian.failCount = 0
	end

	return meridian.failCount
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/10/19 20:05:45
-- @desc 增加冲穴失败次数
function Meridian:addFailCount()
	local role = User:getRole()
	local meridian = role:getAttr("meridian")

	if meridian.failCount == nil then
		meridian.failCount = 0
	end

	meridian.failCount = meridian.failCount + 1

	role:setAttr("meridian", meridian)
end

-- 获取当前调息所需要的时间
function Meridian:getPranayamaTime(exp)
	if exp == nil then
		return 0
	end

	local role = User:getRole()
	local lv = self:getMeridianLv(exp)
	local time = 0

	for i,v in ipairs(self.MeridianExp) do
		if lv == v.lv then
			time = v.time

			-- 经脉印记效果 降低调息所需要的时间
			if role:isHaveImprintingId("taixiyin") then
				local meridianBuffValue = self:getMeridianBuffValue("taixiyin")
				time = math.ceil(time * meridianBuffValue)
			end

			break
		end
	end

	return time
end

-- 获得调息奖励
function Meridian:getPranayamaReward(exp)
	if exp == nil then
		return
	end

	local role = User:getRole()
	local lv = self:getMeridianLv(exp)

	--@desc 家园系统加成
	local k1 = role:getFlag("经脉加成",1)
	local k2 = role:getFlag("真气加成",1) 

	local meridianExp = 100
	local breathVal = 100

	for i,v in ipairs(self.MeridianExp) do
		if lv == v.lv then
			
			meridianExp = v.pranayamaExp * k1
			breathVal = v.pranayamaZhenQi * k2
			if k1 > 1 then
				print("调息经验，家园加成后",meridianExp)
			end
			if k2 > 1 then
				print("调息真气，家园加成后",breathVal)
			end
			
			-- 经脉印记加成
			if role:isHaveImprintingId("wuzhenyin") then
				local meridianBuffValue = self:getMeridianBuffValue("wuzhenyin")
				breathVal = breathVal + breathVal * meridianBuffValue
			end

			-- 道具加成
			local limitFlag = role._timeLimitFlags["真气加成"]
			if limitFlag and limitFlag.value == 1 and limitFlag.startTime + limitFlag.timeLimit >= role:getFlag("调息完成时间") then
				breathVal = breathVal + breathVal * 1
			end
			break
		end
	end

	return meridianExp, breathVal
end

-- 获得经脉穴道
function Meridian:getAcupoint(meridianIndex, acupointIndex)
	local acupointList = self.MeridianAcupoint[meridianIndex].acupointList
	if acupointList then
		local acupoint = acupointList[acupointIndex]
		if acupoint then
			return acupoint
		else
			print("acupoint is nil")
			print(acupointIndex)
		end
	else
		print("acupointList is nil")
		print(meridianIndex)
	end
	print("找不到该穴道 ")
	return nil
end

-- 获得当前经脉固本属性描述
function Meridian:getAcupointAttr(meridianIndex, acupointIndex)
	local attr1, attr2, attr3

	local attrDesc =
	{
		["qiMax"] = "气血上限", 		-- 气血上限
		["neiLiLimit"] = "内力上限",	-- 内力上限
		["atk"] = "攻击力",			-- 攻击力
		["dodge"] = "闪躲力",			-- 闪躲力
		["def"] = "防御力",			-- 防御力
		["damage"] = "伤害力",		-- 伤害力
		["protect"] = "防护力",		-- 防护力
	}

	local acupoint = self:getAcupoint(meridianIndex, acupointIndex)
	if acupoint then
		attr1 = attrDesc[string.split(acupoint.attr1,";")[1]] .. "+" .. string.split(acupoint.attr1,";")[2]
		attr2 = attrDesc[string.split(acupoint.attr2,";")[1]] .. "+" .. string.split(acupoint.attr2,";")[2]
		attr3 = attrDesc[string.split(acupoint.attr3,";")[1]] .. "+" .. string.split(acupoint.attr3,";")[2]
	end
	return attr1, attr2, attr3
end

-- 选择固本属性
function Meridian:selectGuBenSelectAttr(meridianIndex, acupointIndex, selectNum)
	local role = User:getRole()
	local meridian = role:getAttr("meridian")

	-- 经脉属性加成的选择记录 1 经脉索引meridianIndex 2 穴道索引acupointIndex 3 选择项selectNum
	for i,v in ipairs(meridian.attrList) do
		if meridianIndex == v.meridianIndex and acupointIndex == v.acupointIndex then
			v.selectNum = selectNum
			return
		end
	end

	table.insert(meridian.attrList, {meridianIndex = meridianIndex, acupointIndex = acupointIndex, selectNum = selectNum})

	-- 返回选择的属性
	local acupoint = self:getAcupoint(meridianIndex, acupointIndex)
	local attrName
	local attrNum
	if selectNum == 1 then
		attrName, attrNum = string.splitUnpack(acupoint.attr1,";")
	elseif selectNum == 2 then
		attrName, attrNum = string.splitUnpack(acupoint.attr2,";")
	elseif selectNum == 3 then
		attrName, attrNum = string.splitUnpack(acupoint.attr3,";")
	end
	return attrName, attrNum
end

-- 计算固本属性总和
function Meridian:countGuBenAttrTotal(role)
	local meridian = role:getAttr("meridian")

	for k,v in pairs(meridian.attrTotal) do
		meridian.attrTotal[k] = 0
	end

	for i,v in ipairs(meridian.attrList) do
		local acupoint = self:getAcupoint(v.meridianIndex, v.acupointIndex)
		if acupoint then
			local attrName
			local attrNum
			if v.selectNum == 1 then
				attrName, attrNum = string.splitUnpack(acupoint.attr1,";")
			elseif v.selectNum == 2 then
				attrName, attrNum = string.splitUnpack(acupoint.attr2,";")
			elseif v.selectNum == 3 then
				attrName, attrNum = string.splitUnpack(acupoint.attr3,";")
			end
			meridian.attrTotal[attrName] = meridian.attrTotal[attrName] + attrNum
		end
	end
end

-- 计算总经脉增益
function Meridian:countImprintingAttrTotal(role)
	local meridianBuff = {}

	-- 攻击力加成
	meridianBuff["atk"] = self:getMeridianBuffAtk(role ,role:getAtk(true))

	-- 躲闪力加成
	meridianBuff["dodge"] = self:getMeridianBuffDodge(role, role:getDodge(true))

	-- 防御力加成
	meridianBuff["def"] = self:getMeridianBuffDef(role, role:getDef(true))

	-- 伤害力加成
	meridianBuff["damage"] = self:getMeridianBuffPowerDamage(role, role:getPowerDamage(true))

	-- 防护力加成
	meridianBuff["protect"] = self:getMeridianBuffFangHu(role, role:getFangHu(true))

	-- 内力上限
	meridianBuff["neiLiLimit"] = self:getMeridianBuffNeiLiLimit(role, role:calcNeiLiLimit(true))

	-- 气血最大值
	meridianBuff["qiMax"] = self:getMeridianBuffQiMax(role)

	-- 根骨
	meridianBuff["secCon"] = self:getMeridianBuffCon(role)

	-- 悟性
	meridianBuff["secInt"] = self:getMeridianBuffInt(role)

	-- 身法
	meridianBuff["secDex"] = self:getMeridianBuffDex(role)

	-- 福缘
	meridianBuff["luck"] = self:getMeridianBuffLuck(role)

	-- 招架力加成
	meridianBuff["parry"] = self:getMeridianBuffParry(role, role:getParry(true))

	return meridianBuff
end

-- 冲穴 固本
function Meridian:acupointBreak(meridianIndex, acupointIndex, callBackFunc)
	local role = User:getRole()
	local meridian = role:getAttr("meridian")

	if callBackFunc == nil then
		callBackFunc = function()
		end
	end

	if ( meridianIndex ~= meridian.meridianCount + 1 or acupointIndex ~= meridian.acupointCount + 1 ) and meridian.acupointState ~= 7 then
		print("meridianIndex ~= meridian.meridianCount + 1 or acupointIndex ~= meridian.acupointCount + 1")
		return false
	end

	if meridian.acupointState == 1 then
		-- 冲穴
		local str
		meridian.acupointState, str = self:getRandomEventState(meridianIndex, acupointIndex)
		callBackFunc(str)

		local Record = require("app.models.Record.Record")
		local breathVal = role:getAttr("breathVal")
		Record:addRecordCount("jingmai", "chongxue", meridianIndex .. ";" ..acupointIndex .. ";" .. breathVal)
		return true
	elseif meridian.acupointState == 2 then
		-- 固本 需要潜能
		if role:getAttr("pot") >= self:getAcupointBreakPot(meridianIndex, acupointIndex) then
			PopupLayerController:showLayer("MeridianGuBenLayer", function(layer)
				layer:showLayer(function(attrName)
					role:addAttr("pot", - self:getAcupointBreakPot(meridianIndex, acupointIndex))
					meridian.alreadyDisease = 0
					meridian.alreadyDisorder = 0
					meridian.failCount = 0
					role:updateRoleBuff()
					self:openNextAcupoint(meridianIndex, acupointIndex)
					local name = self:getAcupointName(meridianIndex, acupointIndex)
					local str = "\n"
					local color = self:getAcupointColor(meridianIndex, acupointIndex)

					if attrName == "atk" then
						str = str .. "YEL随着一阵真气翻涌，你感到自己的力气变大了一些。"
					elseif attrName == "dodge" then
						str = str .. "YEL随着一阵真气翻涌，你感到自己的身手变得更轻盈了一些。"
					elseif attrName == "qiMax" then
						str = str .. "YEL随着一阵真气翻涌，你感到自己体内气血更丰盈了。"
					elseif attrName == "neiLiLimit" then
						str = str .. "YEL随着一阵真气翻涌，你感到自己的内力增加了一些。"
					elseif attrName == "def" then
						str = str .. "YEL随着一阵真气翻涌，你感到自己的筋骨更加坚韧了一些。"
					elseif attrName == "damage" then
						str = str .. "YEL随着一阵真气翻涌，你感到自己的劲道更加强横了一些。"
					elseif attrName == "protect" then
						str = str .. "YEL随着一阵真气翻涌，你感到自己的六识更加敏锐了一些。"
					end

					callBackFunc("HIC你凝神静气，将真气冲入" .. color .. name .. "HIC中，随着一阵愉悦从身体的深处传来，" .. color .. name .. "HIC已经修练成型了。" .. str)
				end)
			end)
		else
			PopText("潜能不足，无法进行本次固本")
		end
		return false
	elseif meridian.acupointState == 4 then
		-- 治疗暗疾
		local name = self:getAcupointName(meridianIndex, acupointIndex)
		PopupLayerController:showLayer("MeridianDiseaseLayer", function(layer)
			layer:show()
			layer.isMap = false
			layer:initUI(role:getMeridianLevel(), name,
				function()
				end,
				function(zhenqi)
					if zhenqi > 0 then
						User:addRoleAttr("breathVal", zhenqi)
						PopText("真气 + " .. zhenqi)
					end
					meridian.acupointState = 1
					callBackFunc("GRN随着一股真气激荡，累计在RED" .. name .. "GRN的暗疾，像一阵轻烟消失无踪。你长吁一口气，感到有些疲惫，但心中无比欢喜。")
				end,
				function()
					callBackFunc("HIC看来累积在这个RED" .. name .. "HIC的暗疾已经有些时日了，一时间你竟然没法将其消除！你寻思着，要不要再试试……")
				end,
				function()
					PopText("服用春元丹")
					meridian.acupointState = 1
					callBackFunc("GRN服下春元丹，药力很快生效，真气运转变得十分平滑，在RED" .. name .. "GRN的暗疾也消失无踪了。")
				end
			)
		end)
		return false
	elseif meridian.acupointState == 5 then
		-- 絮乱
		PopupLayerController:showLayer("MeridianCalmDownLayer", function(layer)
			layer:showLayer(1, function()
				local role = User:getRole()
				role:setFlag("坐等平复", 0)
				role:setTimeLimitFlag("坐等平复", 0, 0)
				role:setFlag("平复真气", 0)
				meridian.acupointState = 1
				callBackFunc("GRN随着丹药入腹，体内紊乱的真气渐渐平复下来，其中之艰险，真是让人心有余悸啊。")
			end,
			function()
				local role = User:getRole()
				role:setFlag("坐等平复", 0)
				role:setTimeLimitFlag("坐等平复", 0, 0)
				role:setFlag("平复真气", 0)
				meridian.acupointState = 1
				callBackFunc("YEL体内的真气终于平复下来了，也算是好事多磨吧。")
			end)
		end)
		return false
	elseif meridian.acupointState == 7 then
		-- 培元
		local flag, str = self:openNextMeridian(meridianIndex, acupointIndex)
		if flag == true then
			callBackFunc(str)
		end
		return false
	end
	return false
end

-- 开启下一穴道
function Meridian:openNextAcupoint(meridianIndex, acupointIndex)
	local role = User:getRole()
	local meridian = role:getAttr("meridian")

	if meridianIndex ~= meridian.meridianCount + 1 or acupointIndex ~= meridian.acupointCount + 1 then
		print("meridianIndex ~= meridian.meridianCount + 1 or acupointIndex ~= meridian.acupointCount + 1")
		return false
	end

	meridian.acupointCount = meridian.acupointCount + 1
	if meridian.acupointCount == #self.MeridianAcupoint[meridianIndex].acupointList then
		print("当前经脉全部激活 培元")
		meridian.acupointState = 7
	else
		meridian.acupointState = 1
	end
	return true
end

-- 开启下一条经脉
function Meridian:openNextMeridian(meridianIndex, acupointIndex)
	local role = User:getRole()
	local meridian = role:getAttr("meridian")


	local str = "YEL一股浩大的真气突然激荡开来，你感到精神一振，随即被一种巨大的喜悦击中："
	if meridian.acupointCount == #self.MeridianAcupoint[meridianIndex].acupointList then
		meridian.acupointState = 1
		meridian.acupointCount = 0
		meridian.meridianCount = meridian.meridianCount + 1

		local inheritCount = role:getAttr("inheritCount")
		local num = 1
		if role:isHaveImprintingId("zuoyouhuboyin") then
			num = 0
		end

		-- 设置标记
		if meridian.meridianCount >= 8 and inheritCount >= 1 then
			role:setFlag("左右互搏可开启", 1)
		end

		local currUseCount = #role:getMeridianSystem():getCurrentPageMeridianImprintings()

		for i = currUseCount + num, inheritCount + meridianIndex do
			local imprintingId = self:addMeridianImprinting()
			if imprintingId ~= nil then
				local impri = MeridianResources:getMeridianImprintingRes(imprintingId)
				str = str .. "\nYEL获得经脉天赋WHT" .. impri:getName()
			end
		end
	else
		print("meridian.acupointCount ~= #self.MeridianAcupoint[meridianIndex].acupointList")
		return false
	end

	return true, str
end

-- 增加一条经脉印记
function Meridian:addMeridianImprinting()
	local role = User:getRole()

	local sys = role:getMeridianSystem()


	local imprId = MeridianHelper:getAllRandomNewImprintId(sys)

	if imprId then
		sys:addMeridianImprinting(imprId)
	end

	return imprId
end

-- 检测能否开启左右互搏
function Meridian:checkCanOpenLeftRightFight(role)
	if role == nil then
		role = User:getRole()
	end

	local meridian = role:getAttr("meridian")
	local inheritCount = role:getAttr("inheritCount")

	if MapIsEmpty(meridian) == true then
		return false
	end

	if meridian.meridianCount >= 8 and inheritCount >= 1 then
		return true
	end

	if role:getFlag("左右互搏可开启") ~= 0 then
		return true
	end

	return false
end

--开启左右互搏
function Meridian:openZuoYouHuBoYin()
    local role = User:getRole()

    local inheritCount = role:getAttr("inheritCount")

    if role:getFlag("左右互搏入门贴获取") == 0 and inheritCount < 3 then
        -- 获取左右互搏入门贴
        local count = 0
        if inheritCount == 1 then
            count = 3
        elseif inheritCount == 2 then
            count = 5
        end
        if role:getAttr("weight") - #role:getItems() < count then
            return false,"背包空间不足"
        end
        role:addItemCount("zuoyouhubo1", count)

        role:setFlag("左右互搏入门贴获取", 1)

        return true,"获得福禄寿酒 X " .. count
    end

    return true
end

-- 获取冲穴随机事件
function Meridian:getRandomEventState(meridianIndex, acupointIndex)
	local role = User:getRole()
	local meridian = role:getAttr("meridian")
	local acupoint = self:getAcupoint(meridianIndex, acupointIndex)
	local event1 = acupoint.event1
	local event2 = acupoint.event2
	local event3 = acupoint.event3

	-- 已经发现过暗疾，无法再次出现
	local event4 = acupoint.event4
	if meridian.alreadyDisease == 1 then
		event4 = 0
	end

	-- 已经出现过一次真气絮乱 无法再次出现
	local event5 = acupoint.event5
	if meridian.alreadyDisorder == 1 then
		event5 = 0
	end

	if role:getTimeLimitFlag("冲穴加成") == 1 then
		event1 = event1 + 100
		event2 = event2 - 100
		if event2 < 0 then
			event2 = 0
		end
	end
	local str = event1 .. ";" .. event2 .. ";" .. event3 .. ";" .. event4 .. ";" .. event5
	local event = Helper:RandomIndexByPercentWithString(str)
	local state = 2
	local str

	-- 道具加成，必定成功
	if role:getTimeLimitFlag("冲穴成功") == 1 then
		role:setTimeLimitFlag("冲穴成功", 2, role:getTimeLimitFlagTime("冲穴成功"))
		event = 1
	end

	--走穴十四经，修改冲穴加成的概率
	if math.random() < User:getRole():getBuffAttr("xingzhenChong") then 
		local XingZhen = require("app.models.XingZhenEffects.XingZhenEffects")
		XingZhen:removeZouxueEffectByKey("xingzhenChong")
		event = 1 
	end
	-- 随机事件 1 冲穴成功 2 冲穴失败 3 冲穴成功并返还部分真气 4 发现暗疾 5 真气紊乱
	if event == 1 then
		print("冲穴成功")
		local color = self:getAcupointColor(meridianIndex, acupointIndex)
		state = 2
		str = "GRN随着一股真气激荡，" .. color .. self:getAcupointName(meridianIndex, acupointIndex) .. "GRN被冲开了。"
		PopText("穴位冲开，可以固本了")
		Audio:stopAllEffects()
		Audio:playEffect("meridianBreakSucc", false)
	elseif event == 2 then
		print("冲穴失败")
		state = 1
		str = "RED尝试着注入真气，但觉得艰涩无比，始终无法冲开……"
		PopText("真气遇到了阻塞")
		Audio:stopAllEffects()
		Audio:playEffect("meridianBreakFaild", false)
		self:addFailCount()
	elseif event == 3 then
		print("冲穴成功并返还部分真气")
		local color = self:getAcupointColor(meridianIndex, acupointIndex)
		local val = math.floor(self:getAcupointBreakBreathVal(meridianIndex, acupointIndex) / 2)
		role:addAttr("breathVal", val)
		state = 2
		str = "GRN随着一股真气激荡，" .. color .. self:getAcupointName(meridianIndex, acupointIndex) .. "GRN被冲开了。你突然心有所感，运气收功，一股真气流回丹田。\n" .. "HIW获得真气 " .. val .. "!"
		PopText("冲穴成功，并返还部分真气！")
		Audio:stopAllEffects()
		Audio:playEffect("meridianBreakSucc", false)
	elseif event == 4 then
		print("发现暗疾")
		meridian.alreadyDisease = 1
		state = 4
		str = "RED真气快速在穴位内游走，滋润着穴位，突然感到一阵刺痛，真气的游走也随之停了下来。你心里一个咯噔，隐约记得这里受过伤……"
		PopText("发现暗疾！")
		Audio:stopAllEffects()
		Audio:playEffect("meridianBreakEvent", false)
		self:addFailCount()
	elseif event == 5 then
		print("真气紊乱")
		meridian.alreadyDisorder = 1
		state = 5
		PopText("真气紊乱！")
		str = "RED真气像脱缰的野马，在体内乱窜，你有点力不能支，需要将真气平复下来，才能重新冲穴……"
		Audio:stopAllEffects()
		Audio:playEffect("meridianBreakEvent", false)
		self:addFailCount()
	end
	return state, str
end

-- 获取冲穴所需真气值
function Meridian:getAcupointBreakBreathVal(meridianIndex, acupointIndex)
	local role = User:getRole()

	local acupointList = self.MeridianAcupoint[meridianIndex].acupointList
	if acupointList then
		local acupoint = acupointList[acupointIndex]
		if acupoint then
			local zhenqi = acupoint.zhenqi

			-- 失败一次减少10%真气 大于15级开启
			if role:getMeridianLevel() >= 15 then
				local count = self:getFailCount()
				if count > 7 then
					count = 7
				end
				zhenqi = zhenqi * (1 - (count / 10))
			end

			-- 经脉印记效果 减少所需真气值
			if role:isHaveImprintingId("ganzhenyin") then
				local meridianBuffValue = self:getMeridianBuffValue("ganzhenyin")
				zhenqi = math.ceil(zhenqi * meridianBuffValue)
			end

			return zhenqi
		else
			print("acupoint is nil")
			print(acupointIndex)
		end
	else
		print("acupointList is nil")
		print(meridianIndex)
	end
	print("找不到该穴道 ")
	return nil
end

-- 获取固本所需潜能值
function Meridian:getAcupointBreakPot(meridianIndex, acupointIndex)
	local acupointList = self.MeridianAcupoint[meridianIndex].acupointList
	if acupointList then
		local acupoint = acupointList[acupointIndex]
		if acupoint then
			return acupoint.pot
		else
			print("acupoint is nil")
			print(acupointIndex)
		end
	else
		print("acupointList is nil")
		print(meridianIndex)
	end
	print("找不到该穴道 ")
	return nil
end

-- 测试 获取所有经脉印记
function Meridian:getAllMeridianImprinting()
	local list = {}
	for k,v in pairs(MeridianImprinting) do
		table.insert(list, {imprintingId = v.imprintingId})
	end
	return list
end

------------------------- 属性加成 印记 等 -------------------------

-- 攻击力加成
function Meridian:getMeridianBuffAtk(role, baseValue)
	-- 经脉加成
	local meridianBuff = role:getMeridianAttrValue("atk")

	-- 经脉印记加成 装备武器时，提升一定攻击力
	if role:getCurrWeaponType() == "剑" and role:isHaveImprintingId("baoyuanyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("baoyuanyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	elseif role:getCurrWeaponType() == "刀" and role:isHaveImprintingId("baozhenyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("baozhenyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	elseif role:getCurrWeaponType() == "棍" and role:isHaveImprintingId("baokongyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("baokongyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	elseif role:getCurrWeaponType() == "鞭" and role:isHaveImprintingId("baomingyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("baomingyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	elseif role:getCurrWeaponType() == "暗器" and role:isHaveImprintingId("baoxuanyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("baoxuanyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	elseif role:getCurrWeaponType() == "双持" and role:isHaveImprintingId("shuangrenyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("shuangrenyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	elseif role:getCurrWeaponType() == "乐器" and role:isHaveImprintingId("qinrenyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("qinrenyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	elseif role:getCurrWeaponType() == "拳脚" and role:isHaveImprintingId("kongleiyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("kongleiyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	end

	-- 经脉印记效果 提升1%，散人提升3%
	if role:isHaveImprintingId("zhenwuyin") then
		local meridianBuffValue = self:getMeridianBuffValue("zhenwuyin")
		meridianBuffValue = string.split(meridianBuffValue,";")
		local familyValue = tonumber(meridianBuffValue[1])
		local sanRenValue = tonumber(meridianBuffValue[2])
		if role:isYouXia() then
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.ceil( baseValue * 3 )
			else
				meridianBuff = meridianBuff + math.ceil( baseValue * sanRenValue )
			end
		else
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.ceil( baseValue * 1 )
			else
				meridianBuff = meridianBuff + math.ceil( baseValue * familyValue )
			end
		end
	end

	-- 经脉印记效果 佩戴面具时，攻击力有微量提升
	if (role:checkHeadIsMask() or role:getPortraitId() ~= "") and role:isHaveImprintingId("jinmianyin") then
		local meridianBuffValue = self:getMeridianBuffValue("jinmianyin")
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + 10000
		else
			meridianBuff = meridianBuff + meridianBuffValue
		end
	end

	-- 经脉印记效果 容貌越高，攻击力越高
	if role:isHaveImprintingId("huarongyin") then
		local looks = role:getAttr("looks")
		-- 容貌小于200，每点加2点，
		-- 容貌大于等于200、小于500，每多1点加1点
		-- 容貌大于等于500，每多3点加2点
		local addVal = 0
		if DEBUG_MODE == 1 then
			if looks > 200 then
				addVal = addVal + 400 * 50
				if looks > 500 then
					addVal = addVal + 300 * 50
					addVal = addVal + math.floor((looks - 500) * 2/ 3) * 50
				else
					addVal = addVal + math.floor((looks - 200)) * 50
				end
			else
				addVal = addVal + looks * 100
			end

			-- 最多210000
			if addVal >= 210000 then
				addVal = 210000
			end
		else
			if looks > 200 then
				addVal = addVal + 400
				if looks > 500 then
					addVal = addVal + 300
					addVal = addVal + math.floor((looks - 500) * 2/ 3)
				else
					addVal = addVal + math.floor(looks - 200)
				end
			else
				addVal = addVal + looks * 2
			end

			-- 最多4200
			if addVal >= 4200 then
				addVal = 4200
			end
		end
		meridianBuff = meridianBuff + addVal
	end

	-- 经脉印记效果 攻击力提升
	-- if role:getTimeLimitFlag("经脉印记攻击力提升") == 1 then
	-- 	meridianBuff = meridianBuff + math.ceil(baseValue * 0.05)
	-- end

	return meridianBuff
end

-- 躲闪力加成
function Meridian:getMeridianBuffDodge(role, baseValue)
	-- 经脉加成
	local meridianBuff =  role:getMeridianAttrValue("dodge")

	-- 经脉印记加成 空手时，提升一定闪躲力
	if role:getCurrWeaponType() == "拳脚" and role:isHaveImprintingId("kongqiyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("kongqiyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	end

	-- 经脉印记效果 提升1%，散人提升3%
	if role:isHaveImprintingId("zhenxiyin") then
		local meridianBuffValue = self:getMeridianBuffValue("zhenxiyin")
		meridianBuffValue = string.split(meridianBuffValue,";")
		local familyValue = tonumber(meridianBuffValue[1])
		local sanRenValue = tonumber(meridianBuffValue[2])
		if role:isYouXia() then
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.ceil( baseValue * 3)
			else
				meridianBuff = meridianBuff + math.ceil( baseValue * sanRenValue )
			end
		else
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.ceil( baseValue * 1)
			else
				meridianBuff = meridianBuff + math.ceil( baseValue * familyValue )
			end
		end
	end

	-- 经脉印记效果 佩戴面具时，闪躲力有微量提升
	if (role:checkHeadIsMask() or role:getPortraitId() ~= "") and role:isHaveImprintingId("yinmianyin") then
		local meridianBuffValue = self:getMeridianBuffValue("yinmianyin")
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + 10000
		else
			meridianBuff = meridianBuff + meridianBuffValue
		end
	end

	-- 经脉印记效果 容貌越高，闪躲力越高
	if role:isHaveImprintingId("yunrongyin") then
		local looks = role:getAttr("looks")
		-- 容貌小于1000，每点加4点，
		-- 容貌大于等于1000、小于2000，每多1点加3点
		-- 容貌大于等于2000，每多1点加2点
		local addVal = 0
		if DEBUG_MODE == 1 then
			if looks > 1000 then
				addVal = addVal + 4000 * 50
				if looks > 2000 then
					addVal = addVal + 3000 * 50
					addVal = addVal + math.floor(looks - 2000) * 100
				else
					addVal = addVal + math.floor(looks - 1000) * 150
				end
			else
				addVal = addVal + looks * 200
			end

			-- 最多600000
			if addVal >= 600000 then
				addVal = 600000
			end
		else
			if looks > 1000 then
				addVal = addVal + 4000
				if looks > 2000 then
					addVal = addVal + 3000
					addVal = addVal + math.floor((looks - 2000) * 2)
				else
					addVal = addVal + math.floor((looks - 1000) * 3)
				end
			else
				addVal = addVal + looks * 4
			end

			-- 最多12000
			if addVal >= 12000 then
				addVal = 12000
			end
		end	
		meridianBuff = meridianBuff + addVal
	end


	return meridianBuff
end

-- 防御力加成
function Meridian:getMeridianBuffDef(role, baseValue)
	-- 经脉加成
	local meridianBuff = role:getMeridianAttrValue("def")

	-- 经脉印记加成 空手时，提升一定防御力
	if role:getCurrWeaponType() == "拳脚" and role:isHaveImprintingId("kongxuanyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("kongxuanyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	end

	-- 经脉印记效果 提升1%，散人提升3%
	if role:isHaveImprintingId("zhenxuanyin") then
		local meridianBuffValue = self:getMeridianBuffValue("zhenxuanyin")
		meridianBuffValue = string.split(meridianBuffValue,";")
		local familyValue = tonumber(meridianBuffValue[1])
		local sanRenValue = tonumber(meridianBuffValue[2])
		if role:isYouXia() then
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.ceil( baseValue * 3)
			else
				meridianBuff = meridianBuff + math.ceil( baseValue * sanRenValue )
			end
		else
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.ceil( baseValue * 1)
			else
				meridianBuff = meridianBuff + math.ceil( baseValue * familyValue )
			end
		end
	end

	-- 经脉印记效果 佩戴面具时，防御力有微量提升
	if (role:checkHeadIsMask() or role:getPortraitId() ~= "") and role:isHaveImprintingId("tongmianyin") then
		local meridianBuffValue = self:getMeridianBuffValue("tongmianyin")
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + 10000
		else
			meridianBuff = meridianBuff + meridianBuffValue
		end
	end

	-- 经脉印记效果 容貌越高，防御力越高
	if role:isHaveImprintingId("fengrongyin") then
		local looks = role:getAttr("looks")
		-- 容貌小于200，每点加1点，
		-- 容貌大于等于200、小于500，每多2点加1点
		-- 容貌大于等于500，每多3点加1点
		local addVal = 0
		if DEBUG_MODE == 1 then
			if looks > 200 then
				addVal = addVal + 200 * 50
				if looks > 500 then
					addVal = addVal + 150 *50
					addVal = addVal + math.floor((looks - 500) / 3) * 50
				else
					addVal = addVal + math.floor((looks - 200) / 2) * 50
				end
			else
				addVal = addVal + looks * 50
			end

			-- 最多70000
			if addVal >= 70000 then
				addVal = 70000
			end
		else
			if looks > 200 then
				addVal = addVal + 200
				if looks > 500 then
					addVal = addVal + 150
					addVal = addVal + math.floor((looks - 500) / 3)
				else
					addVal = addVal + math.floor((looks - 200) / 2)
				end
			else
				addVal = addVal + looks
			end

			-- 最多1400
			if addVal >= 1400 then
				addVal = 1400
			end
		end
		meridianBuff = meridianBuff + addVal
	end


	-- 经脉印记效果 攻击力提升
	-- if role:getTimeLimitFlag("经脉印记防御力提升") == 1 then
	-- 	meridianBuff = meridianBuff + math.ceil(baseValue * 0.02)
	-- end

	return meridianBuff
end

-- 伤害力加成
function Meridian:getMeridianBuffPowerDamage(role, baseValue)
	-- 经脉加成
	local meridianBuff = role:getMeridianAttrValue("damage")

	-- 经脉印记加成 空手时，提升一定伤害力
	if role:getCurrWeaponType() == "拳脚" and role:isHaveImprintingId("kongmieyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("kongmieyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	end

	-- 经脉印记效果 佩戴面具时，伤害力有微量提升
	if (role:checkHeadIsMask() or role:getPortraitId() ~= "") and role:isHaveImprintingId("huomianyin") then
		local meridianBuffValue = self:getMeridianBuffValue("huomianyin")
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + 10000
		else
			meridianBuff = meridianBuff + meridianBuffValue
		end
	end

	-- 经脉印记效果 容貌越高，伤害力越高
	if role:isHaveImprintingId("huorongyin") then
		local looks = role:getAttr("looks")
		-- 容貌小于900，每3点加一点伤害力
		-- 容貌大于等于900，每4点加1点伤害力
		-- 最多450
		local addVal = 0
		if DEBUG_MODE == 1 then
			if looks > 900 then
				addVal = 300 * 50 + math.floor((looks-900) / 4) * 50
			else
				addVal = math.floor(looks / 3) * 50
			end

			-- 最多22500
			if addVal >= 22500 then
				addVal = 22500
			end
		else
			if looks > 900 then
				addVal = 300 + math.floor((looks-900) / 4)
			else
				addVal = math.floor(looks / 3)
			end

			-- 最多450
			if addVal >= 450 then
				addVal = 450
			end
		end
		meridianBuff = meridianBuff + addVal
	end


	return meridianBuff
end

-- 防护力加成
function Meridian:getMeridianBuffFangHu(role, baseValue)
	--经脉加成
	local meridianBuff = role:getMeridianAttrValue("protect")

	-- 经脉印记加成 空手时，提升一定防护力
	if role:getCurrWeaponType() == "拳脚" and role:isHaveImprintingId("kongyangyin") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("kongyangyin")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	end

	-- 经脉印记效果 提升1%，散人提升3%
	if role:isHaveImprintingId("zhenanyin") then
		local meridianBuffValue = self:getMeridianBuffValue("zhenanyin")
		local familyValue, sanRenValue = string.splitUnpack(meridianBuffValue,";")
		familyValue, sanRenValue = tonumber(familyValue), tonumber(sanRenValue)
		if role:isYouXia() then
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.ceil( baseValue * 3)
			else
				meridianBuff = meridianBuff + math.ceil( baseValue * sanRenValue )
			end
		else
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.ceil( baseValue * 1)
			else
				meridianBuff = meridianBuff + math.ceil( baseValue * familyValue )
			end
		end
	end

	-- 经脉印记效果 佩戴面具时，防护力有微量提升
	if (role:checkHeadIsMask() or role:getPortraitId() ~= "") and role:isHaveImprintingId("shuimianyin") then
		local meridianBuffValue = self:getMeridianBuffValue("shuimianyin")
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + 10000
		else
			meridianBuff = meridianBuff + meridianBuffValue
		end
	end

	-- 经脉印记效果 容貌越高，防护力越高
	if role:isHaveImprintingId("shuirongyin") then
		local looks = role:getFinalAttr("looks")
		-- 容貌每3点加一点防护力 最多300
		local addVal = 0
		if DEBUG_MODE == 1 then
			addVal = math.floor(looks / 3) * 50

			-- 最多20000
			if addVal >= 20000 then
				addVal = 20000
			end
		else
			addVal = math.floor(looks / 3)

			-- 最多300
			if addVal >= 300 then
				addVal = 300
			end
		end
		meridianBuff = meridianBuff + addVal
	end

	return meridianBuff
end

-- 招架力加成
function Meridian:getMeridianBuffParry(role, baseValue)
	local meridianBuff = 0

	-- 经脉印记加成 空手时，提升一定招架力
	if role:getCurrWeaponType() == "拳脚" and role:isHaveImprintingId("kongjia") then
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + math.ceil(baseValue * 1)
		else
			local meridianBuffValue = self:getMeridianBuffValue("kongjia")
			meridianBuff = meridianBuff + math.ceil(baseValue * meridianBuffValue)
		end
	end


	if role:isHaveImprintingId("zhenjia") then
		local meridianBuffValue = self:getMeridianBuffValue("zhenjia")
		local familyValue, sanRenValue = string.splitUnpack(meridianBuffValue,";")
		familyValue, sanRenValue = tonumber(familyValue), tonumber(sanRenValue)
		if role:isYouXia() then
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.ceil( baseValue * 3)
			else
				meridianBuff = meridianBuff + math.ceil( baseValue * sanRenValue )
			end
		else
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.ceil( baseValue * 1)
			else
				meridianBuff = meridianBuff + math.ceil( baseValue * familyValue )
			end
		end
	end

	-- 经脉印记效果 佩戴面具时，招架力有微量提升
	if (role:checkHeadIsMask() or role:getPortraitId() ~= "") and role:isHaveImprintingId("jiamianyin") then
		local meridianBuffValue = self:getMeridianBuffValue("jiamianyin")
		if DEBUG_MODE == 1 then
			meridianBuff = meridianBuff + 10000
		else
			meridianBuff = meridianBuff + meridianBuffValue
		end
	end

	-- 经脉印记效果 容貌越高，招架力越高
	if role:isHaveImprintingId("jiarongyin") then
		local looks = role:getFinalAttr("looks")
		local meridianBuffValue = self:getMeridianBuffValue("jiarongyin")
		local formulaParams = string.split(meridianBuffValue,"|")
		local maxAddValue = tonumber(formulaParams[1])
		local levelParams = string.split(formulaParams[2],"#")

		local addVal = 0
		for k, params in ipairs(levelParams) do
			local values = string.split(params, "@")
			local _leftValue = tonumber(values[1])
			local _rightValue = tonumber(values[2])
			local _value = tonumber(values[3])
			if looks >= _rightValue then
				addVal = _value * (_rightValue - _leftValue + 1) + addVal
			elseif looks >= _leftValue then
				addVal = _value * (looks - _leftValue + 1) + addVal
			end
		end

		if addVal > maxAddValue then
			addVal = maxAddValue
		end

		meridianBuff = meridianBuff + addVal
	end

	return meridianBuff
end

-- 内力上限加成
function Meridian:getMeridianBuffNeiLiLimit(role, baseValue)
	-- 经脉加成
	local meridianBuff = role:getMeridianAttrValue("neiLiLimit")

	-- 经脉印记效果 提升1%，散人提升3%
	if role:isHaveImprintingId("zhenyuanyin") then
		local meridianBuffValue = self:getMeridianBuffValue("zhenyuanyin")
		meridianBuffValue = string.split(meridianBuffValue,";")
		local familyValue = tonumber(meridianBuffValue[1])
		local sanRenValue = tonumber(meridianBuffValue[2])
		if role:isYouXia() then
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.floor( baseValue * 3 )
			else	
				meridianBuff = meridianBuff + math.floor( baseValue * sanRenValue )
			end
		else
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.floor( baseValue * 1 )
			else	
				meridianBuff = meridianBuff + math.floor( baseValue * familyValue )
			end
		end
	end

	return meridianBuff
end

-- 气血最大值加成
function Meridian:getMeridianBuffQiMax(role, baseValue)
	-- 经脉加成
	local meridianBuff = role:getMeridianAttrValue("qiMax")

	-- 经脉印记效果 提升1%，散人提升3%
	if role:isHaveImprintingId("zhengangyin") then
		local meridianBuffValue = self:getMeridianBuffValue("zhengangyin")
		meridianBuffValue = string.split(meridianBuffValue,";")
		local familyValue = tonumber(meridianBuffValue[1])
		local sanRenValue = tonumber(meridianBuffValue[2])
		if role:isYouXia() then
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.floor( role:getAttr("qiMax") * 3 )
			else	
				meridianBuff = meridianBuff + math.floor( role:getAttr("qiMax") * sanRenValue )
			end
		else
			if DEBUG_MODE == 1 then
				meridianBuff = meridianBuff + math.floor( role:getAttr("qiMax") * 1 )
			else	
				meridianBuff = meridianBuff + math.floor( role:getAttr("qiMax") * familyValue )
			end
		end
	end
	return meridianBuff
end

-- 获得根骨加成
function Meridian:getMeridianBuffCon(role, baseValue)
	local meridianBuff = 0

	-- 增加5点根骨
	if role:isHaveImprintingId("genguyin") then	
		local meridianBuffValue = self:getMeridianBuffValue("genguyin")
		meridianBuff = meridianBuff + meridianBuffValue
	end

	return meridianBuff
end

-- 获得悟性加成
function Meridian:getMeridianBuffInt(role, baseValue)
	local meridianBuff = 0

	-- 增加5点悟性
	if role:isHaveImprintingId("wuxingyin") then
		local meridianBuffValue = self:getMeridianBuffValue("wuxingyin")
		meridianBuff = meridianBuff + meridianBuffValue
	end

	return meridianBuff
end

-- 获得身法加成
function Meridian:getMeridianBuffDex(role, baseValue)
	local meridianBuff = 0

	-- 增加5点身法
	if role:isHaveImprintingId("shenfayin") then
		local meridianBuffValue = self:getMeridianBuffValue("shenfayin")
		meridianBuff = meridianBuff + meridianBuffValue
	end

	return meridianBuff
end

-- 获得臂力加成
function Meridian:getMeridianBuffStr(role, baseValue)
	local meridianBuff = 0

	return meridianBuff
end

-- 获得福缘加成
function Meridian:getMeridianBuffLuck(role, baseValue)
	local meridianBuff = 0

	-- 增加5点福缘
	if role:isHaveImprintingId("fuyuanyin") then
		local meridianBuffValue = self:getMeridianBuffValue("fuyuanyin")
		meridianBuff = meridianBuff + meridianBuffValue
	end

	return meridianBuff
end

-- 使用食品
function Meridian:useFoodItem(role)
	-- 拥有经脉印记 使用食物的特殊效果
	-- 食用各种食品时，有几率提升一定防御力，持续10分钟
	if role:isHaveImprintingId("taotieyin") then
		if DEBUG_MODE == 1 then
			print("食用食物提升一定防御力，持续10分钟")
			role:setTimeLimitFlag("经脉印记防御力提升", 1, 600)
			RichPrint("main", "真气在你的体内快速运转，随着一阵灼热传来，激活了HIC以食为天NOR！防御提升！")
			return
		end
		if math.random(1, 100) <= 30 then
			print("食用食物提升一定防御力，持续10分钟")
			role:setTimeLimitFlag("经脉印记防御力提升", 1, 600)
			RichPrint("main", "真气在你的体内快速运转，随着一阵灼热传来，激活了HIC以食为天NOR！防御提升！")
		end
	end
end

-- 使用酒
function Meridian:useWineItem(role)
	-- 拥有经脉印记 使用酒的特殊效果
	-- 喝酒时，有几率提升一定攻击力，持续10分钟
	if role:isHaveImprintingId("dukangyin") then
		if DEBUG_MODE == 1 then
			print("喝酒提升一定攻击力，持续10分钟")
			role:setTimeLimitFlag("经脉印记攻击力提升", 1, 600)
			RichPrint("main", "真气在你的体内快速运转，随着一阵灼热传来，激活了HIC酒国中人NOR！攻击提升！")
			return
		end
		if math.random(1, 10) == 1 then
			print("喝酒提升一定攻击力，持续10分钟")
			role:setTimeLimitFlag("经脉印记攻击力提升", 1, 600)
			RichPrint("main", "真气在你的体内快速运转，随着一阵灼热传来，激活了HIC酒国中人NOR！攻击提升！")
		end
	end
end

-- 使用真气丹效果加成
function Meridian:useZhenQiDan(role, baseValue, attr)
	local meridianBuff = 0

	-- 经脉印记效果 提升服用真气丹的效果
	if role:isHaveImprintingId("danyangyin") and attr == "breathVal" then
		local meridianBuffValue = self:getMeridianBuffValue("danyangyin")
		meridianBuff = math.ceil(baseValue * meridianBuffValue)
		print("经脉印记效果 真气额外增加" .. meridianBuff)
	end

	return meridianBuff
end

-- 使用经脉丹效果
function Meridian:useJingMaiDan(role, baseValue, attr)
	local meridianBuff = 0

	-- 经脉印记效果 提升服用经脉丹的效果
	if role:isHaveImprintingId("danyinyin") and attr == "meridianExp" then
		local meridianBuffValue = self:getMeridianBuffValue("danyinyin")
		meridianBuff = math.ceil(baseValue * meridianBuffValue)
		print("经脉印记效果 经脉经验额外增加" .. meridianBuff)
	end

	return meridianBuff
end

-- 获取经脉效果加成的数值
function Meridian:getMeridianBuffValue(imprintingId)
	local meridian = self:getImprintingId(imprintingId)
	if meridian == nil then
		-- assert(false,"检查经脉资源 经脉"..imprintingId.."不存在")
		return 0
	end

	local addValue = meridian.value

	return addValue
end

-- 创建化指为剑招式的动画
function Meridian:createZhaoIsAnimAndText(fightRole,cType)
	local role = fightRole:getRole()
	local atkSkillId = role:getPrepareSkill(cType)
    if not atkSkillId then
        if cType == "quanjiao1" or cType == "quanjiao2" then
			cType = "quanjiao"
		end
		atkSkillId = "jiben"..cType 
    end
	local atkSkill = Skill:getSkill(atkSkillId)
	local atkSkName = atkSkill.name

	local meridianZhaoList = {}

	for k,v in pairs(HuaZhi) do
		if v.type == cType then
			table.insert( meridianZhaoList, v)
		end
	end
	local fight = fightRole._fight

	local animAndTextArray = meridianZhaoList[fight:random(1,#meridianZhaoList)]

	if DEBUG_MODE == 1 then
		Helper:print_lua_table(animAndTextArray)
	end

	local anims = {
		{
			anim = animAndTextArray.anim,
			offset = animAndTextArray.offset,
			hitPos = animAndTextArray.hitPos,
			speed = animAndTextArray.speed
		}
	}

	local texts = animAndTextArray.text
	local textArray = string.split(texts,";")
	local text = textArray[math.random(1,#textArray)]
	text = string.gsub( text,"AAAA",atkSkName)
	return anims,text
end

--获得特殊经脉效果表
function Meridian:getSpecialMeridianList()
	--经脉特殊效果表
	local SpecialMeridianList = {
		{
			id = "huajianyin",
			value = self:getMeridianBuffValue("huajianyin")*100,
			effect = "jianfa", --追加一次准备的剑法招式
			name = "RAN化\n指\n为\n剑NOR"
		},
		{
			id = "huadaoyin",
			value = self:getMeridianBuffValue("huadaoyin")*100,
			effect = "daofa", --追加一次准备的刀法招式
			name = "RAN化\n掌\n为\n刀NOR"
		},
		{
			id = "huabianyin",
			value = self:getMeridianBuffValue("huabianyin")*100,
			effect = "bianfa", --追加一次准备的鞭法招式
			name = "RAN化\n腿\n为\n鞭NOR"
		},
		{
			id = "huaqiangyin",
			value = self:getMeridianBuffValue("huaqiangyin")*100,
			effect = "gunfa", --追加一次准备的棍法招式
			name = "RAN化\n拳\n为\n枪NOR"
		},
		{
			id = "huaanqiyin",
			value = self:getMeridianBuffValue("huaanqiyin")*100,
			effect = "anqi", --追加一次准备的暗器招式
			name = "RAN化\n爪\n为\n镖NOR"
		},
		{
			id = "huashuangchiyin",
			value = self:getMeridianBuffValue("huashuangchiyin")*100,
			effect = "shuangchi", --追加一次准备的双持招式
			name = "RAN化\n腿\n为\n刃NOR"
		},
		{
			id = "huayueqiyin",
			value = self:getMeridianBuffValue("huayueqiyin")*100,
			effect = "qinfa", --追加一次准备的乐器招式
			name = "RAN化\n拳\n为\n音NOR"
		},
	}

	return SpecialMeridianList
end
------------------------- 属性加成 印记 等 -------------------------

Meridian:init()

return Meridian00
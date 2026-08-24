local LaBaShiZhou = {}
local MapInfo = require("app.models.map.MapInfo")
local taskNpc = require("script.npc.taskNpc")
function LaBaShiZhou:start(log,maxCount)
	-- print("---------------------------------------",log,maxCount)
	self.maplayer = MainControllLayer:getLayer("MapLayer")
	self.mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
	self.maxCountList = string.split(maxCount,";")
	if #self.maxCountList < 3 then
		-- print("-----------策划填写的配置有问题------------------:",maxCount)
		return
	else
		self:setMapLayerExitButton(log)
	end
	local text = {
		"YEL施粥长老：少侠，这做粥的食材都在此了，这些香客少侠千万不可怠慢了他们，但其中有一些心生贪念者，会多次领粥，少侠你亦需留意一二，莫要发给他们。",
		"CYN你架起大铁锅，将一旁的大米，胡桃，松子等物，混入清水倒入锅中。",
		"CYN你取来干柴，放在锅底，点燃开始熬制腊八粥。",
		"CYN过了好一会，锅中清香扑鼻，腊八粥已经是熬制完毕，可以开始布释腊八粥了。",
		"CYN如今天色尚早，寺门外香客陆续走来，你的施粥工作就此开始了。",
	}
	self:initVariable()
	self.maxCount = Helper:getDef(tonumber(self.maxCountList[self.stage]),6)
	for i = 1,#text + 1 do
		if i ~= #text + 1 then
			self.maplayer:delayFunc(2 * i - 1,function()
				if not self.exit then
					RichPrint("main",text[i])
				end
			end)
		else
			self.maplayer:delayFunc(2 * i - 2,function()
				if not self.exit then
					self:setSchedule()
				end
			end)	
		end
	end
	-- self:setSchedule()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 10:47:10
-- @desc 设置初始变量
function LaBaShiZhou:initVariable()
	self.time = 120 --总时间
	self.timeCount = 120
	self.stageTime = 0
	-- self.textTimeCount = 0--文本计时 每到达一定时间输出一次文本一
	self.textTime = 24--当文本计时等于此数值时输出文本
	self.attitudeCount = 5--僧人态度，，为0时立即结束游戏
	self.successCount = 0--成功施粥人数
	self.stage = 1--阶段
	self.common = {
		"身穿RED红色WHT衣服的",
		"身穿HIR亮红色WHT衣服的",
		"身穿BLU蓝色WHT衣服的",
		"身穿HIB亮蓝色WHT衣服的",
		"身穿GRN绿色WHT衣服的",
		"身穿HIG亮绿色WHT衣服的",
		"身穿YEL黄色WHT衣服的",
		"身穿HIY亮黄色WHT衣服的",
		"身穿MAG暗紫色WHT衣服的",
		"身穿HIC亮青色WHT衣服的",
		"身穿CYN暗青色WHT衣服的",
		"身穿HIM亮紫色WHT衣服的",
		"身穿HIW白色WHT衣服的",
	}
	self.special = {}
	self.descList = {}
	self.specialProb = 40
	self.naoshiProb = 20
	self.npcList = {}--创建并存在的NPC列表
	self.currCount = 0 -- 当前普通香客+特殊香客数量
	self.score = 0--积分用于计算奖励
	self.operation = true
	self.exit = false
	-- if DEBUG_MODE == 1 then
	-- 	self.stage = 2
	-- 	self:createCommonDescList(self.stage)
	-- end
end



function LaBaShiZhou:setMapLayerExitButton(log)
	self.mapRoleLayer:exitButtonFunc(false,function()
		if self.handle ~= nil then
			self.maplayer._currMap:pauseSchedule(self.handle)
		end
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show("你正在进行腊八施粥，确定要离开副本么？（离开副本会导致任务失败）")
		dialog:setBack(false)
		dialog:setButton1("离开" , function()
				self.mapRoleLayer:exitButtonFunc(true)
				self.maplayer:setUnmoveRoom(false)
				self.maplayer._currMap:setCanLeave(true)
				self:deleteAllNpc()
				if self.handle ~= nil then
					self.maplayer._currMap:unSchedule(self.handle)
					self.handle = nil
				end
				self.exit = true
				self.maplayer:quit()
		end)
		dialog:setButton2("取消",function()
			if self.handle ~= nil then
				self.maplayer._currMap:resumeSchedule(self.handle)
			end
		end)
	end)
	self.maplayer:setUnmoveRoom(true,function()
		RichPrint("main",log)
	end)
	self.maplayer._currMap:setCanLeave(false)
	User:getRole():setFlag("副本状态","忙碌")
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 11:08:02
-- @desc 计时器时间处理包含输出文本
function LaBaShiZhou:dealScheduleTime()
	local timeText = {
		"HIG时间一分一秒过去，你已工作了数个时辰。",
		"HIG现正是晌午，你吃过午饭，又开始了施粥。",
		"HIG天色不早了，来往香客仍是络绎不绝，你不禁感觉有点劳累。",
		"HIG太阳快落山了，香客越来越少，看来施粥快结束了。",
		"HIG天色已晚，一旁的僧人向你作了一礼，这一天的施粥已经结束了。",
	}
	self.timeCount = self.timeCount - 1
	-- self.textTimeCount = self.textTimeCount + 1
	-- print((self.time - self.timeCount) / self.textTime)
	if (self.time - self.timeCount)% self.textTime == 0 then
		RichPrint("main",timeText[(self.time - self.timeCount) / self.textTime])
	end
	if self.timeCount == 0 then
		self:finish()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 11:20:20
-- @desc 结束游戏
function LaBaShiZhou:finish()
	if self.handle ~= nil then
		self.maplayer._currMap:unSchedule(self.handle)
		self.handle = nil
	end
	self.mapRoleLayer:exitButtonFunc(true)
	self.maplayer:setUnmoveRoom(false)
	self.maplayer._currMap:setCanLeave(true)
	User:getRole():setFlag("副本状态","空闲中")
	self:deleteAllNpc()
	if self.successFunc then
		self.successFunc()
	end
	--计算积分
	if User:getRole():getDayFlag("腊八施粥奖励") == 1 then
		RichPrint("main","YEL施粥长老：少侠，今日你已经帮过我寺施粥，老衲在此谢过了。")
	else
		self:getReward()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 16:51:53
-- @desc 获取奖励
function LaBaShiZhou:getReward()
	local reward = {}
	local str = ""
	if self.score < 0 then
		str = "着实有些不尽人意"
		reward = {
			money = 5000
		}
	elseif self.score >= 0 and self.score <= 50 then
		str = "着实有些不尽人意"
		reward = {
			money = 10000,
			exp = 5000,
			pot = 5000
		}
	elseif self.score >= 51 and self.score <= 70 then
		str = "做得还行"
		reward = {
			money = 15000,
			exp = 15000,
			pot = 15000
		}
	elseif self.score >= 71 and self.score <= 90 then
		str = "做得还行"
		reward = {
			money = 20000,
			exp = 25000,
			pot = 25000
		}
	elseif self.score >= 91 and self.score <= 100 then
		str = "干的不错"
		reward = {
			money = 25000,
			exp = 30000,
			pot = 30000
		}
	elseif self.score >= 101 and self.score <= 120 then
		str = "干的不错"
		reward = {
			money = 30000,
			exp = 35000,
			pot = 35000
		}

	elseif self.score >= 121 and self.score < 145 then
		str = "做得实在是太好了，我真不知说什么好"
		reward = {
			money = 40000,
			exp = 40000,
			pot = 40000
		}
	elseif self.score >= 145 then
		str = "做得实在是太好了，我真不知说什么好"
		reward = {
			money = 50000,
			exp = 50000,
			pot = 50000
		}
	end
	local list = {
		pot = "潜能",
		exp = "经验",
		money = "碎银"
	}
	local text = "施粥长老：少侠，你本次施粥$C人，施错$c人，$D，这是老衲的一点心意，少侠走好。"
	text = string.gsub(text,"$C",tostring(self.successCount))
	text = string.gsub(text,"$c",tostring(5 - self.attitudeCount))
	text = string.gsub(text,"$D",str)
	RichPrint("main",text)
	for id ,var in pairs(reward) do 
		User:getRole():addAttr(id,var)
		PopText(list[id].."+"..tostring(var))
	end
	if DEBUG_MODE == 1 then

	else
		User:getRole():setDayFlag("腊八施粥奖励",1)
	end
end

function LaBaShiZhou:setSchedule()
	-- self.count = 0 --计时
	-- self.extraCount = 0 --计时闹事香客出现间隔
	-- self.currCount = 0--当前普通香客和特殊香客总数
	-- self.operation = true
	-- self.complete = 0
	-- self.npcList = {}
	self.handle = self.maplayer._currMap:setSchedule(function()
		self:dealScheduleTime()
		-- print("--------------setSchedule-----------------",self.time - self.timeCount,"---------完成数量-----------",self.successCount)
		if self.timeCount ~= 0 then
			if self.currCount < self.maxCount  then
				self.stageTime = self.stageTime + 1
				if self.stageTime <= 6 and self.stageTime%2 == 0 then
					self:createCommonNPC("普通香客")
				elseif self.stageTime > 6 and self.stageTime%2 == 0 then
					local random = math.random(1,100)
					if random <= self.specialProb then
						if MapIsEmpty(self.special) == false then
							self:createCommonNPC("特殊香客")
						else
							self:createCommonNPC("普通香客")
						end 
					else
						self:createCommonNPC("普通香客")
					end
				end
			else
				if DEBUG_MODE == 1 then
					print("--------------------------普通香客+特殊香客的数量已经达到最大值---------------------------------")
				end
			end
		end
	end,1.0,1.0)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/03 17:56:34
-- @desc 创建npc
function LaBaShiZhou:createNPC(role)
	assert(type(role) == "table")
	if self.time - self.timeCount >= 120 or self.timeCount == 0 then
		return
	end
	role.needState = 1
	MapInfo:addRoleToRoomByRoomId(self.maplayer._currMap,self.maplayer._currRoom.id,role)
	self.npcList[role.id] = true
	local role = self.maplayer._currMap:getRole(role.id)
	self.maplayer:setNeedRefreshMap()
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 12:31:10
-- @desc 随机香客容貌
function LaBaShiZhou:getRandomNPCDsc(doFlag,roleId)
	local str = "这是一名$DWHT香客，来领取腊八粥。"

	local desc = ""
	local random
	self.descList[self.stage] = Helper:getDef(self.descList[self.stage],{})
	if doFlag == "普通香客" then
		random = math.random(1,#self.common)
		-- self.special = {}
		-- table.insert(self.special,self.common[random])
		desc =  self.common[random]
		self.descList[self.stage][roleId] = desc
		table.remove(self.common,random)
	else
		random = math.random(1,#self.special)
		desc =  self.special[random]
		self.descList[self.stage][roleId] = desc
		table.remove(self.special,random)
	end
	-- print(str,"-------------------------------------",desc)
	return string.gsub(str,"$D",desc)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/03 18:02:05
-- @desc 普通香客,特殊香客
function LaBaShiZhou:createCommonNPC(doFlag)
	-- print("创建npc",name)
	local baseId = self:getRandomRoleBaseId(doFlag)
	local baseInfo = self:getNPCBaseInfo(baseId)
	if baseInfo == nil then
		return 
	end
	self.currCount = self.currCount + 1
	local roleId = baseId..tostring(Helper:getOnlyId())
	
	local role = {
		id= roleId,
		baseId = baseId,
		sex = Helper:getDef(sex,self:getRandomRoleSex()),
		type = "role",
		name = Helper:getDef(name,"普通香客"),
		canSee = true,
		caozuo = true,
		canTalk = false,
		caozuoName = "施粥",
		caozuo1 = true,
		caozuoName1 = "赶走",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						arg1 = "腊八施粥操作",
						arg2 = doFlag,
						arg3 = "施粥",
					},
				},
			},
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作1",
					}
				},
				results =
				{
					{
						arg1 = "腊八施粥操作",
						arg2 = doFlag,
						arg3 = "拒绝",
					},
				},
			}
		}
	}
	role = table.mergeMap(role,baseInfo)--Helper:tableCover(npc,role)
	role.id= roleId
	if self.stage == 1 then
		local desc = self:getRandomNPCDsc(doFlag,roleId)
		role.dsc = desc
	else
		role = self:getSpecialRandomNPCDsc(role,doFlag)
	end
	if DEBUG_MODE == 1 then
		if doFlag == "特殊香客" then
			role.dsc = role.dsc .. "ZZZZZZ"
		end
	end
	-- role.name = name
	self:createNPC(role)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 16:10:44
-- @desc 
function LaBaShiZhou:getSpecialRandomNPCDsc(role,doFlag)
	local random
	local descList = {}
	self.descList[self.stage] = Helper:getDef(self.descList[self.stage],{})
	if doFlag == "普通香客" then
		random = math.random(1,#self.common)
		-- self.special = {}
		-- table.insert(self.special,self.common[random])
		descList =  self.common[random]
		self.descList[self.stage][role.id] = descList
		table.remove(self.common,random)
	else
		random = math.random(1,#self.special)
		descList =  self.special[random]
		self.descList[self.stage][role.id] = desc
		table.remove(self.special,random)
	end
	Helper:tableCover(role,descList) 
	return role
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/03 18:15:50
-- @desc 闹事香客
function LaBaShiZhou:createSpecialNPC(roleData)
	local doFlag = "闹事香客"
	local baseId = self:getRandomRoleBaseId(doFlag)
	local roleId = baseId..tostring(Helper:getOnlyId())
	local baseInfo = self:getNPCBaseInfo(baseId)
	if baseInfo == nil then
		return 
	end
	self.operation = false
	local role = {
		id= roleId,
		baseId = baseId,
		sex = Helper:getDef(sex,self:getRandomRoleSex()),
		type = "role",
		name = Helper:getDef(name,"闹事香客"),
		canSee = true,
		caozuo = true,
		canTalk = false,
		caozuoName = "赶走",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						arg1 = "执行函数",
						arg2 = function()
							if self.time - self.timeCount >= 120 or self.timeCount == 0 then
								return
							end
							if self.handle ~= nil  then
								self.maplayer._currMap:pauseSchedule(self.handle)
							end
						end
					},	
					{
						arg1 = "主动切磋玩家",

					},
				},
			},
			{
				conditionRelation = "and",
				conditions =
				{
					{
						-- type = "玩家操作",
						arg1 = "特殊条件",
						arg2 = "切磋",
						arg3 = "成功"
					}
				},
				results =
				{
					{
						arg1 = "删除自身",

					},
					{
						arg1 = "执行函数",
						arg2 = function()
							if self.time - self.timeCount >= 120 or self.timeCount == 0 then
								return
							end
							RichPrint("main","HIC你将闹事香客狠狠教训了一顿，平息了事端。")
							self.maplayer._currMap:resumeSchedule(self.handle)
							self.operation = true
							self.npcList[roleId] = nil
							self:addRewardScore(1)
						end
					},
				},
			}
		}
	}
	-- role = table.mergeMap(role,roleData)
	role = table.mergeMap(role,baseInfo)--Helper:tableCover(npc,role)
	-- role = table.mergeMap(role,roleData)
	for key,value in pairs(role) do
		if roleData[key] ~= nil and key ~= "conditionAndResults" and key ~= "caozuoName" then
			role[key] = roleData[key]
		end
	end
	role.id= roleId
	role.sex = roleData.sex
	local sex = ""
	if roleData.sex == "男" then
		sex = "他"
	else
		sex = "她"
	end
	role.dsc = string.split(roleData.dsc,"，")[1].."，此时"..sex.."正在闹事。"
	role.name = doFlag
	self:createNPC(role)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/03 18:05:22
-- @desc 随机性别
function LaBaShiZhou:getRandomRoleSex()
	local sexList = {"男","女"}
	local random = math.random(1,#sexList)
	return sexList[random]
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/04 17:45:47
-- @desc 随机npc的baseId
function LaBaShiZhou:getRandomRoleBaseId(npcType)
	local baseIdList = {
		"labashizhou1",
		"labashizhou2",
		"labashizhou3",
		"labashizhou4",
		"labashizhou5",
		"labashizhou6",
		"labashizhou7",
		"labashizhou8",
		"labashizhou9"
	}
	local random
	if npcType == "普通香客" then
		random = math.random(1,4)
	elseif npcType == "特殊香客" then
		random = math.random(5,8)
	else
		random = 9
	end
	-- print("---------------------------------------",baseIdList[random])
	return baseIdList[random]
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/04 17:45:57
-- @desc 根据NPC的baseId读取配置属性
function LaBaShiZhou:getNPCBaseInfo(baseId)
	local npcBaseInfoList = assert(taskNpc["npc"])
	return npcBaseInfoList[baseId]
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/03 18:36:29
-- @desc 普通香客,特殊香客操作处理
function LaBaShiZhou:dealOperation(npcType,operateName,roleId)
	assert(npcType and operateName)
	if self.time - self.timeCount >= 120 or self.timeCount == 0 then
		self.maplayer._currMap:removeRoomRole(self.maplayer._currRoom.id,roleId) 
		self.maplayer:setNeedRefreshMap()
		return
	end
	if self.operation == false then
		RichPrint("main","有闹事香客正在闹事，还是先处理了再做别的事吧。")
		return
	end
	if self:logText(npcType,operateName) == false then
		return
	end
	local random = math.random(1,100)
	if npcType == "特殊香客" then
		if operateName == "施粥" then
			self:addRewardScore(-2)
		else
			if random <= self.naoshiProb then
				local role = self.maplayer._currMap:getRole(roleId)
				RichPrint("main","HIR却没想到这人竟十分无耻，在原地大闹了起来，一时间场面十分混乱。")
				self:createSpecialNPC(role)
			else
			end
		end
		if self.descList[self.stage][roleId] ~= nil then
			table.insert(self.special,self.descList[self.stage][roleId])
		end
	else
		if operateName == "施粥" then
			self:addSuccessCount(1)
			self.descList[self.stage] = Helper:getDef(self.descList[self.stage],{})
			if self.descList[self.stage][roleId] ~= nil then
				table.insert(self.special,self.descList[self.stage][roleId])
			end
			self:addRewardScore(5)
		else
			if random <= self.naoshiProb then
				local role = self.maplayer._currMap:getRole(roleId)
				RichPrint("main","HIR却没想到这名香客却大闹了起来，一时间场面十分混乱。")
				self:createSpecialNPC(role)
			else
			end
			table.insert(self.common,self.descList[self.stage][roleId])
			self:addRewardScore(-2)
		end
	end
	self.descList[self.stage][roleId] = nil
	self.currCount = self.currCount -1
	self.npcList[roleId] = nil
	self.maplayer._currMap:removeRoomRole(self.maplayer._currRoom.id,roleId) 
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 17:13:46
-- @desc 增加积分
function LaBaShiZhou:addRewardScore(var)
	assert(type(var) == "number")
	self.score = self.score + var
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 12:24:44
-- @desc 成功施粥计数已经阶段计数
function LaBaShiZhou:addSuccessCount(var)
	assert(type(var) == "number")
	self.successCount = self.successCount + 1
	if self.successCount / 10 == 1 then
		self.stage = 2
		self.specialProb = 45
		self.naoshiProb = 40
		self.special = {}
		self:createCommonDescList(self.stage)
		RichPrint("main","HIY你布施得人数颇多，一旁的僧人微微点头，招呼得更起劲了，更多的香客朝着你这走来。")
	elseif self.successCount / 10 == 2 then
		self.stage = 3
		self.specialProb = 50
		self.naoshiProb = 50
		self.special = {}
		self:createCommonDescList(self.stage)
		RichPrint("main","HIY你布施工作完成的很好，一旁的僧人十分高兴，招呼得更起劲了，更多的香客朝着你这走来。")
	end
	self.maxCount = tonumber(self.maxCountList[self.stage])
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 15:31:23
-- @desc 生成第二,三阶段的容貌列表
function LaBaShiZhou:createCommonDescList(stage)
	local afList = {
		{
			dsc = "HIC青年WHT",
			age = 18,
			looks = 21,
			sex = "男"
		},
		{ 
			dsc = "HIC文士WHT",	
			age = 20,	
			looks = 20, 
			sex = "男"
		},
		{ 
			dsc = "HIC书生WHT",	
			age = 25,	
			looks = 21, 
			sex = "男"
		},
		{ 
			dsc = "HIC大汉WHT",	
			age = 32,	
			looks = 19, 
			sex = "男"
		},
		{ 
			dsc = "HIC壮汉WHT",	
			age = 32,	
			looks = 18, 
			sex = "男"
		},
		{ 
			dsc = "HIC老头WHT",	
			age = 60,	
			looks = 17, 
			sex = "男"
		},
		{ 
			dsc = "HIC老妪WHT",	
			age = 60,	
			looks = 17, 
			sex = "女"
		},
		{ 
			dsc = "HIC姑娘WHT",	
			age = 16,	
			looks = 20, 
			sex = "女"
		},
		{ 
			dsc = "HIC小姐WHT",	
			age = 20,	
			looks = 21, 
			sex = "女"
		},
		{ 
			dsc = "HIC妇人WHT",	
			age = 42,	
			looks = 20, 
			sex = "女"
		},
		{ 
			dsc = "HIC少女WHT",	
			age = 18,	
			looks = 20, 
			sex = "女"
		},
		{ 
			dsc = "HIC少妇WHT",	
			age = 32,	
			looks = 23, 
			sex = "女"
		}
	}
	self.common = {}
	if stage == 2 then
		local descList = {
			"身穿RED红色WHT衣服的",
			"身穿HIR亮红色WHT衣服的",
			"身穿BLU蓝色WHT衣服的",
			"身穿HIB亮蓝色WHT衣服的",
			"身穿GRN绿色WHT衣服的",
			"身穿HIG深绿色WHT衣服的",
			"身穿YEL黄色WHT衣服的",
			"身穿HIY亮黄色WHT衣服的",
			"身穿MAG暗紫色WHT衣服的",
			"身穿HIC亮青色WHT衣服的",
			"身穿CYN暗青色WHT衣服的",
			"身穿HIM亮紫色WHT衣服的",
			"身穿HIW白色WHT衣服的",
		}
		for k,desc in pairs(descList) do 
			for i,af in pairs(afList) do 
				local tab = clone(af)
				local str = "这是一名$DWHT香客，来领取腊八粥。"
				tab.dsc = string.gsub(str,"$D",desc..tab.dsc)
				table.insert(self.common,tab)
			end
		end
	elseif stage == 3 then
		local descList = {
			"身穿RED红色WHT衣服的",
			"身穿HIR亮红色WHT衣服的",
			"身穿BLU蓝色WHT衣服的",
			"身穿HIB亮蓝色WHT衣服的",
			"身穿GRN绿色WHT衣服的",
			"身穿HIG深绿色WHT衣服的",
			"身穿YEL黄色WHT衣服的",
			"身穿HIY亮黄色WHT衣服的",
			"身穿MAG暗紫色WHT衣服的",
			"身穿HIC亮青色WHT衣服的",
			"身穿CYN暗青色WHT衣服的",
			"身穿HIM亮紫色WHT衣服的",
			"身穿HIW白色WHT衣服的",
		}
		local zsList = {
			"手中拿着一把HIC折扇WHT",
			"手中拿着一把HIC宝剑WHT",
			"手中提着一个HIC箱子WHT",
			"手中拿着一串HIC佛珠WHT",
			"手中拿着一个HIC礼盒WHT",
			"手中捏着一张HIC符咒WHT"
		}
		for k,desc in pairs(descList) do 
			for i,af in pairs(afList) do 
				for j ,zs in pairs(zsList) do 
					local tab = clone(af)
					local str = "这是一名$DWHT，来领取腊八粥。"
					tab.dsc = string.gsub(str,"$D",desc..tab.dsc..","..zs)
					table.insert(self.common,tab)
				end
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 12:05:43
-- @desc 僧人态度计数
function LaBaShiZhou:addNPCAttitudeCount(var)
	assert(type(var) == "number")
	local text = {
		"HIR一旁的僧人看着你的举动，皱了皱眉头，并没有说什么。",
		"HIR一旁的僧人看着你的举动，脸上露出丝丝不满，似乎是在抱怨你一般。",
		"HIR一旁的僧人看着你的举动，小声地在你耳边说起刚刚的事情，并提醒你细心一些。",
		"HIR一旁的僧人看着你的举动，气愤地跟你说你刚刚犯的错误，并告诉你不可再犯。",
		"HIR一旁的僧人看着你的举动，怒不可遏，将你赶离施粥场，你的施粥就此结束。",
	}	
	self.attitudeCount = self.attitudeCount + var
	if self.attitudeCount == 0 then
		return text[#text - self.attitudeCount]
	end
	return text[#text - self.attitudeCount]
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/04 17:30:11
-- @desc 完成回调
function LaBaShiZhou:setSuccessFunc(func)
	func = Helper:getDef(func,function()

	end)
	self.successFunc = func
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/04 15:28:23
-- @desc 操作对应的文本
function LaBaShiZhou:logText(npcType,operateName)
	local str = ""
	local text = ""
	if npcType == "特殊香客" then
		if operateName == "施粥" then
			text = "HIR你小心翼翼地盛了一碗腊八粥给这名香客，香客居然露出了一丝狡黠的笑容，随后便扬长而去，"
			str = self:addNPCAttitudeCount(-1)
		else
			text = "HIC你隐约记得这名香客之前已经来过，便婉言将其劝退了。"
		end
	elseif npcType == "普通香客" then
		if operateName == "施粥" then
			text = "HIC你小心翼翼地盛了一碗腊八粥给这名香客，香客笑着对你点了点头，满意而去。"
		else
			text = "HIR你三言两语便将这名香客赶走了，"
			str = self:addNPCAttitudeCount(-1)
		end
	else

	end
	RichPrint("main",text..str)
	if self.attitudeCount == 0 then
		self:finish()
		return false
	end
	return true
end

function LaBaShiZhou:deleteAllNpc()
	if MapIsEmpty(self.npcList) == true then
		return
	end
	for roleId,v in pairs(self.npcList) do 
		self.maplayer._currMap:removeRoomRole(self.maplayer._currRoom.id,roleId) 
	end
	self.maplayer:setNeedRefreshMap()
	self.npcList = {}
end



return LaBaShiZhou00000000
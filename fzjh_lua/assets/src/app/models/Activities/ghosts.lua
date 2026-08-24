local  TreasureList = require("script.others.Treasure")
local GhostsList = require("script.others.ghost") 
local ghosts = {}

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/08/24 10:11:21
-- @desc 检测是否可以生成玩法信息
function ghosts:checkCanCreateInformation()
	if Map:getMapState("fb01") ~= MAP_STATE.COMPLETE then
		PopText("请先通关“鹊起无名卷”第一章")
		return false
	end
	local _ghosts = self:getGhosts()
	if _ghosts == 0 then
		local date = tonumber(Helper:date("%Y%m%d",GetTime()))
		local time = tonumber(Helper:date("%Y%m%d%H",GetTime()))
		print(time,tonumber(tostring(date).."19"),tonumber(tostring(date + 1).."05"))
		if time >= tonumber(tostring(date).."19") and time <= tonumber(tostring(date + 1).."05") then
			return true
		else
			return false
		end
	else
		return false
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/08/24 10:55:09
-- @desc 获取信息
function ghosts:getGhosts()
	-- return User:getRole():getTimeLimitFlag("ghosts")
	-- DataBase:setLuaTable("ghosts", self.transList)
	if User:getRole():getTimeLimitFlag("ghosts") == true then
		local userid = User:getUserId()
		if userid == -1 or userid == 0 then
			return 0
		else
			local list = DataBase:getLuaTable("ghosts")
			if type(list) ~= "table" then
				return 0
			end
			return list[tostring(userid)]
		end
	else
		return 0
	end
end

function ghosts:setGhosts(tab)
	if type(tab) ~= "table" then
		return
	end
	if User:getRole():getTimeLimitFlag("ghosts") == true then
		local userid = User:getUserId()
		if userid == -1 or userid == 0 then
			return 
		else
			-- return DataBase:getLuaTable("ghosts")[tostring(userid)]
			local list = Helper:getDef(DataBase:getLuaTable("ghosts"),{})
			list[tostring(userid)] = tab
			DataBase:setLuaTable("ghosts", list)
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/08/24 11:01:49
-- @desc 生成信息
function ghosts:createGhosts()
	local _ghosts = {}
	-- if self:checkCanCreateInformation() then
	-- 	_ghosts = self:createMapList()
	-- 	User:getRole():setTimeLimitFlag("ghosts",_ghosts,self:getInformationSdEndTime()-GetTime())
	-- end	
	_ghosts = self:createMapList()
	return _ghosts
end

function ghosts:testFun()
	if DEBUG_MODE ~= 1  then
		local currDate = Helper:date("%Y%m%d",GetTime())
		if tonumber(currDate) < 20170904 or tonumber(currDate) > 20170920 then
			if PRINT_MODE == 1 then
				PopText("不在活动日期内")
			end
			return
		end
		if Helper:getTimeStampWithStringDate(tostring(currDate),5) < GetTime() and Helper:getTimeStampWithStringDate(tostring(currDate),19) > GetTime() then
			if PRINT_MODE == 1 then
				PopText("不在当天活动时间内")
			end
			return
		end
	end
	local _ghosts = self:getGhosts()

	-- self:print_ghz(_ghosts)
	if _ghosts == 0 then
		_ghosts = self:createGhosts()
		if _ghosts == nil then
			return nil 
		end
		self:setGhosts(_ghosts)
		User:getRole():setTimeLimitFlag("ghosts",true,math.min(self:getInformationSdEndTime(),3600))--最长有效期为2小时
	end
	return _ghosts
end
function ghosts:setRoomWithComeInMap(mapId,_ghosts)
	local list = _ghosts[mapId]
	if type(list) ~= "table" then
		return
	end
	local possibleRoomList = Helper:getDef(TreasureList["神书送礼"],{})
	for mid,v in pairs(possibleRoomList) do
		if mid == mapId then
			local roomList = self:splitString(v.possibleRoom,",")
			for i,j in pairs(list) do 
				local random = math.random(1,#roomList)
				list[i].roomId = roomList[random]
				table.remove(roomList,random)
			end
			_ghosts[mapId] = list
			self:setGhosts(_ghosts)
			-- User:getRole():updateTimeLimitFlag("ghosts",_ghosts)
		end
	end
	return _ghosts
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/08/24 11:07:25
-- @desc 生成信息副本列表
function ghosts:createMapList()

	local jindu = tonumber(User:getRole():getAttr("jindu"))
	if jindu < 2 then
		return {}
	end
	if type(TreasureList["江湖进度"]) ~= "table" or type(TreasureList["江湖进度"][tostring(math.max(jindu-1,1))]) ~= "table" or type(TreasureList["江湖进度"][tostring(math.max(jindu-1,1))].list) ~= "table" then
		if DEBUG_MODE == 1 then
			print("江湖进度:",jindu,"TreasureList.江湖进度中没有关于"..tostring(jindu).."信息")
		end
		return {}
	end
	local mapList = self:splitString(TreasureList["江湖进度"][tostring(math.max(jindu-1,1))].list,",")
	local _ghosts = {}
	for k,v in ipairs(mapList) do 
		_ghosts[v] = self:createRoomList(v)
	end
	return _ghosts
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/08/24 11:36:55
-- @desc 生成副本房间内的信息
function ghosts:createRoomList(mapId)
	if type(mapId) ~= "string" then
		-- assert(nil)
		return {}
	end
	local random = math.random(3,5)
	local rTab = {}
	local possibleRoomList = Helper:getDef(TreasureList["神书送礼"],{})
	for mid,v in pairs(possibleRoomList) do
		if mid == mapId then
			local roomList = self:splitString(v.possibleRoom,",")
			random = math.min(random,#roomList) --确保每个房间只有一个npc
			local hasPlayer = false
			for i = 1, random do 
				local randomId = math.random(1,#roomList)
				local tab,hasPlayer = self:createNPCList(1,hasPlayer)
				table.insert(rTab,tab)
			end
		end
	end
	return rTab
end
function ghosts:dealNPCDscByNameAndSex(dsc,name,sex)
	if sex == 0 then
		return dsc
	end
	if type(dsc) ~= "string" or type(name) ~= "string" or type(sex) ~= "string"  then
		-- print(dsc,name,sex)
		-- assert(nil)
		return dsc
	end
	local cl = "他"
	if sex == "女" then
		cl = "她"
	end
	dsc = cl.."就是"..name.."。"..dsc
	return dsc
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/08/24 12:15:12
-- @desc 生成NPC
function ghosts:createNPCList(type,hasPlayer)
	hasPlayer = Helper:getDef(hasPlayer,false)
	local itemList = {
		[1] = "zhongyuanrernwu16",	--镜子
		[2] = "zhongyuanrernwu17",	--棺材
		[3] = "zhongyuanrernwu18",	--破旧蒲团
		[4] = "zhongyuanrernwu19"	--石像
	}
	local demon_nan = {
		[1] = "zhongyuanrernwu2",--血衣男子
		[2] = "zhongyuanrernwu5",--漂浮男子
		[3] = "zhongyuanrernwu6",--笑脸老人
		[4] = "zhongyuanrernwu8",--独脚男子
		[5] = "zhongyuanrernwu10",--拐杖老人
		[6] = "zhongyuanrernwu13", --布衣男子	
	}
	local demon_nv = {

		[1] = "zhongyuanrernwu3",--披发女子
		[2] = "zhongyuanrernwu4",--流泪女子
		[3] = "zhongyuanrernwu7",--阴沉老妇
		[4] = "zhongyuanrernwu9",--独眼女子
		[5] = "zhongyuanrernwu11",--老妇
		[6] = "zhongyuanrernwu12",--青衣女子
	}
	local demon_wanjia = {

	}
	local demon_king = "zhongyuanrernwu1"
	local other = {
		[1] = "zhongyuanrernwu20",
		[2] = "zhongyuanrernwu21"
	}
	local function getOtherNPC(count)
		local rTab = {}
		count = Helper:getDef(count,1)
		for i=1,count do 
			local random = math.random(1,#other)
			local name,sex
			if random == 1 then
				name = Helper:getRandomName("男")
				sex = "男"
			else
				name = Helper:getRandomName("女")
				sex = "女"
			end
			local tab = {
				npcName = name,
				npcBaseId = other[random],
				npcId = other[random]..tostring(Helper:getOnlyId()),
			}
			tab.npcDsc,tab.dscA = self:getRoleBaseDsc(other[random],sex)
			local name = self:getRolenameByDscA(tab.dscA,sex)
			if name ~= nil then
				tab.npcName = name
			end
			tab.npcDsc = self:dealNPCDscByNameAndSex(tab.npcDsc,tab.npcName,sex)
			table.insert(rTab,tab)
		end
		return rTab
	end
	local weight = {}
	if type == 1 then
		if hasPlayer == false then
			weight = {[1] = 30,[2] = 25, [3] = 25 , [4] = 10 , [5] = 10}
		else
			weight = {[1] = 30,[2] = 30, [3] = 30 , [4] = 10 , [5] = 0}
		end
	elseif  type == 2 then
		weight = {[1] = 0,[2] = 50, [3] = 50 , [4] = 0 , [5] = 0}
	elseif type == 3 then
		weight = {[1] = 30,[2] = 34, [3] = 34 , [4] = 2 , [5] = 0}
	end
	-- if DEBUG_MODE == 1 and type == 1 then
	-- 	weight = {[1] = 20,[2] = 10, [3] = 20 , [4] = 30 , [5] = 5000}
	-- end
	local random = Helper:RandomByWeight(weight)
	if type == 1 then
		if DEBUG_MODE ~= 1 then
			local random2 = math.random(1,2)
			if random2 == 1 then
				random = 6
			end
		end
	end
	if random == 1 then
		local randomId = math.random(1,#itemList)
		local tab = {
			npcBaseId = itemList[randomId],
			npcId = itemList[randomId]..tostring(Helper:getOnlyId()),
			type = "item",
		}
		return tab,hasPlayer
	elseif random == 2 then
		local randomId = math.random(1,#demon_nan)
		local tab = {
			npcBaseId = demon_nan[randomId],
			npcId = demon_nan[randomId]..tostring(Helper:getOnlyId()),
			sex = "男",
			npcName = Helper:getRandomName("男"),
			type = "role",
		}
		tab.npcDsc,tab.dscA = self:getRoleBaseDsc(other[random],"男")
		local name = self:getRolenameByDscA(tab.dscA,"男")
		if name ~= nil then
			tab.npcName = name
		end
		tab.npcDsc = self:dealNPCDscByNameAndSex(tab.npcDsc,tab.npcName,tab.sex)
		if type == 1 or type ==3 then
			print("生成other",type,"男")
			tab.other = getOtherNPC(2)
		end
		return tab,hasPlayer
	elseif random == 3 then
		local randomId = math.random(1,#demon_nv)
		local tab = {
			npcBaseId = demon_nv[randomId],
			npcId = demon_nv[randomId]..tostring(Helper:getOnlyId()),
			sex = "女",
			npcName = Helper:getRandomName("女"),
			type = "role",
		}
		tab.npcDsc,tab.dscA = self:getRoleBaseDsc(other[random],"女")
		local name = self:getRolenameByDscA(tab.dscA,"女")
		if name ~= nil then
			tab.npcName = name
		end
		tab.npcDsc = self:dealNPCDscByNameAndSex(tab.npcDsc,tab.npcName,tab.sex)
		if type == 1 or type ==3  then
			print("生成other",type,"女")
			tab.other = getOtherNPC(2)
		end
		return tab,hasPlayer
	elseif random ==4 then
		local tab = {
			npcBaseId = demon_king,
			npcId = demon_king..tostring(Helper:getOnlyId()),
			sex = "男",
			npcName = Helper:getRandomName("男"),
			type = "role",
		}
		tab.npcDsc,tab.dscA = self:getRoleBaseDsc(other[random],"男")
		local name = self:getRolenameByDscA(tab.dscA,"女")
		if name ~= nil then
			tab.npcName = name
		end
		tab.npcDsc = self:dealNPCDscByNameAndSex(tab.npcDsc,tab.npcName,tab.sex)
		return tab,hasPlayer
	elseif random == 5 then
		local tab = {
			npcBaseId = "zhongyuanrernwu14",
			npcId = "zhongyuanrernwu14"..tostring(Helper:getOnlyId()),
			type = "role",

		}
		return tab,hasPlayer
	elseif random == 6 then
		local tab = {
			npcBaseId = demon_king,
			npcId = demon_king..tostring(Helper:getOnlyId()),
			sex = "男",
			npcName = Helper:getRandomName("男"),
			type = "role",
			canSee = false
		}
		tab.other = getOtherNPC(3)
		return tab,hasPlayer
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/08/24 15:37:12
-- @desc 获取基本描述ABC 
function ghosts:getRoleBaseDsc(baseId,sex)
	local str = ""
	local tab = {"dscA","dscB","dscC"}
	local strA = ""
	for k,v in pairs(tab) do
		local dsc = self:getRoleDsc(baseId,sex,v)
		if v == "dscA" then
			strA = dsc
		end
		str = str .. dsc
	end
	return str ,strA
end
--玩家数据描述
function ghosts:getPlayerGhostsDsc(role)
	local dsc = ""
	if type(role) ~= "table" then
		return dsc
	end
	if role.sex == "男" then
		dsc = "他就是"..role.name.."。\n他生得"
	elseif role.sex == "女" then
		dsc = "她就是"..role.name.."。\n她生得"
	else
		dsc = ""
	end
	-- role.baseId = "zhongyuanrernwu14"
	dsc = dsc..self:getRoleDsc("zhongyuanrernwu14")
	return dsc
end

function ghosts:checkTypeIsSpecialType(type)
	local tab = {"dscF","dscG","dscH","dscJ"}
	for k,v in pairs(tab) do 
		if v == type then
			return true
		end
	end
	return false
end
function ghosts:checkRoleIsSpecial(baseId)
	local tab = {"zhongyuanrernwu2","zhongyuanrernwu3","zhongyuanrernwu4","zhongyuanrernwu5","zhongyuanrernwu6","zhongyuanrernwu7","zhongyuanrernwu8","zhongyuanrernwu9","zhongyuanrernwu10","zhongyuanrernwu11","zhongyuanrernwu12","zhongyuanrernwu13"}
	print("获取特殊描述",baseId)
	for k,v in pairs(tab) do 
		if v == baseId then
			return true
		end
	end
	return false
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/08/24 15:02:52
-- @desc 获取人物的描述 type为描述的类型 
function ghosts:getRoleDsc(baseId,sex,type)
	baseId = Helper:getDef(baseId,"zhongyuanrernwu2")
	sex = Helper:getDef(sex,"男")
	type = Helper:getDef(type,"dscA")

	local function getAllDscWithType(type,list,baseId)--从Ghosts表中获取所有type类型的描述
		list = Helper:getDef(list,{})
		local rTab = {}
		if type ~= "dscJ" then
			for k,v in pairs(list) do 
				if v[type] ~= nil then
					table.insert(rTab,v[type])
				end
			end
		else
			for k,v in pairs(list) do 
				if v.id == baseId then
					table.insert(rTab,v[type])
				end
			end
		end
		return rTab
	end
	local list = {}
	if baseId == "zhongyuanrernwu14" then
		local wanjia_list = {
			[1] = "BLU面色铁青，目无神采，浑身湿漉漉的，似乎刚从水中捞出来一样。",
			[2] = "HIW无面无相，手拿蒲扇，十分吓人。",
			[3] = "HIM长发飘然，面无血色，阴森恐怖。",
			[4] = "HIY头生三眼，脑大少发，畸形渗人。",
			[5] = "HIM黑青面庞，白眼无瞳，脸上异纹横生，眉间还有一抹殷红，浑身煞气，令人生惧。",
		}
		local random = math.random(1,#wanjia_list)
		return wanjia_list[random]
	end
	if not self:checkTypeIsSpecialType(type) then--不是"dscF","dscG","dscH","dscJ"
		if sex == "男" then
			list = getAllDscWithType(type,GhostsList["男容貌"])--Ghosts["男容貌"]
			return list[math.random(1,#list)]
		else
			list = getAllDscWithType(type,GhostsList["女容貌"])--["女容貌"]
			return list[math.random(1,#list)]
		end
	else
		if self:checkRoleIsSpecial(baseId) == true then
			list = getAllDscWithType(type,GhostsList["特殊鬼"],baseId)--["女容貌"]
			return list[math.random(1,#list)]
		else
		end
	end
	return ""
end
function ghosts:getRolenameByDscA(dscA,sex)
	local list = {}
	if sex == "男" then
		list = GhostsList["男容貌"]
	elseif sex == "女" then
		list = GhostsList["女容貌"]
	end
	for k,v in pairs(list) do 
		if v.dscA == dscA and v.peoplename ~= nil then
			local nameList = string.split(v.peoplename,";")
			return nameList[math.random(1,#nameList)]
		end
	end
	return nil
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/08/24 11:16:51
-- @desc 获取信息结束时间
function ghosts:getInformationSdEndTime()
	local currTime = GetTime()
	local today_date = tonumber(Helper:date("%Y%m%d",currTime))
	local hour = tonumber(Helper:date("%H",currTime))
	if hour >= 19 and hour < 24 then--判断创建时间是不是在当日的19点--24点之间
		return 7200
	elseif hour >= 0 and hour < 5 then
		--在当日的0点-5点之间开启
		return Helper:getTimeStampWithStringDate(tostring(today_date),5) - currTime
	end
	return currTime
end
function ghosts:splitString(str,separator)
	if type(str) ~= "string" then
		self:print_ghz(str)
		-- assert(nil)
		return 
	end
	if type(separator) ~= "string" then
		return str
	end
	return string.split(str,separator)
end
function ghosts:getDemonlevel(baseId)
		local level = string.split(baseId,"zhongyuanrernwu")[2]
		Helper:print_lua_table(string.split(baseId,"zhongyuanrernwu"))
		level = Helper:getDef(tonumber(level),0)
		local lv = 0
		if level == 1 then
			lv = 1
		elseif level >=2 and level <= 3 then
			lv = 2
		elseif level >=4 and level <= 7 then
			lv = 3
		elseif level >=8 and level <= 11 then
			lv = 4
		elseif level >=12 and level <= 13 then
			lv = 5
		elseif level == 14 then
			lv = 7
		elseif level >=16 and level <= 19 then
			lv = 6
		end
		return lv
	end
function ghosts:useCandle(mapId,roomId,role,func)--zhongyuanlazhu1
	local _ghosts = self:getGhosts()
	if type(role) ~= "table" or role.name == nil or _ghosts == 0 or type(_ghosts[mapId]) ~= "table" then
		self:candleLog(0,role)
		User:getRole():addItemCount("zhongyuanlazhu1",-1)
		if func then
			func(level,dsc)
		end
		return
	end
	local dscList = {
		[1] = {"dscD","dscE"},
		[2] = {"dscF","dscG"},
		[3] = {"dscG","dscH"},
		[4] = {"dscF","dscH"},
		[5] = {"dscF","dscG","dscH"},
		[6] = {"dscD","dscG"},
		[7] = {"dscF","dscE"},
		[8] = {"dscD","dscH"},
		[9] = {"dscJ"},
	}
	local function getNewDsc(role)
		local canRefresh = Helper:getDef(role.canRefresh,true)
		if role.baseId == "zhongyuanrernwu1" then
			return role.npcDsc,role.words,canRefresh
		elseif role.baseId == "zhongyuanrernwu14" then
			return role.npcDsc,role.words,canRefresh
		else
			if canRefresh == false then
				-- print("(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((")
				return role.npcDsc,role.words,canRefresh
			else
				local str = Helper:getDef(role.dscA,"")
				local words = self:getRoleWordByDscType(role,"dscA")
				local random = math.random(1,#dscList)
				-- random = #dscList
				if random == #dscList then
					str = ""
					words = self:getRoleWordByDscType(role,dscList[random][1])
					canRefresh = false
				end
				for k ,v in pairs(dscList[random]) do 
					local text = self:getRoleDsc(role.baseId,role.sex,v)
					print(v,text)
				str = str .. text
				end
				str = self:dealNPCDscByNameAndSex(str,role.name,role.sex)
				return str,words,canRefresh
			end
		end
		-- assert(nil)
	end
	if role ~= nil then
		local level = self:getDemonlevel(role.baseId)
		level = Helper:getDef(level,0)
		self:candleLog(level,role)
		if func then
			local newDsc,words,canRefresh = getNewDsc(role)
			func(level,newDsc,words,canRefresh)
		end
		User:getRole():addItemCount("zhongyuanlazhu1",-1)
	end
end
function ghosts:candleLog(level,role)
	-- print("role.baseId",role.baseId,level)
	local level_6 = {
		["zhongyuanrernwu16"] = "你点燃白蜡烛，地上那块小镜子中，竟然冒出一道人影！",
		["zhongyuanrernwu17"] = "你将白蜡烛点燃，棺材盖竟然“嗡嗡”作响，只听”哐”地一声，棺盖被掀飞，从里面爬出来一人。",
		["zhongyuanrernwu18"] = "你将白蜡烛点燃，地上的破旧蒲团中突然冒出一股黑烟，缓缓地凝成了一个人形。",
		["zhongyuanrernwu19"] = "你点燃一根白蜡烛，观察着周围，怪异的石像居然动了起来，缓缓变成一个人形。",
	}
	local level_5 = {
		fireText = {
			[1] = "CYN你将白蜡烛点上，火光照亮了这里，",
			[2] = "CYN你将白蜡烛点上，烛光微动，",
			[3] = "CYN你刚将白蜡烛点上，",
			[4] = "CYN你将白蜡烛点燃，在幽光的照耀下，",
		},
		roomText = {
			[1] = "CYN丝丝阴气显现，应是有阴物作祟。",
			[2] = "CYN周遭阴气大盛，应是有鬼物存在。",
			[3] = "CYN旁边的$N浑身抽搐，像是变了个人一样。",
			[4] = "CYN$N宛若疯了一样，冲向别处。",
		},
		text = {
			[1] = "CYN你将白蜡烛点上，烛火微微颤动着。",
			[2] = "CYN你将白蜡烛点燃，白蜡烛发出幽幽青光。",
		}
	}
	local level_4 = {
		fireText = {
			[1] = "CYN你点燃了一根白蜡烛，观察着四周，",
			[2] = "CYN你点燃了白蜡烛，",
			[3] = "CYN你将白蜡烛点上，火光通明，",
			[4] = "CYN你点燃一根白蜡烛，烛光摇曳，",
			[5] = "CYN你将蜡烛点燃，烛光微亮，",
		},
		roomText = {
			[1] = "CYN$N突然害怕了起来，躲在角落瑟瑟发抖。",
			[2] = "CYN$N浑身发抖，像是见到鬼一样，跑向了角落。",
			[3] = "CYN一股股黑气充斥着周遭，此地应是有鬼物存在。",
			[4] = "CYN照亮了周边，满是阴气，令人生惧。",
			[5] = "CYN你耳旁传来阵阵鬼哭之声，凄惨悲凉，令人毛乎悚然。",
		},
		text = {
			[1] = "CYN你点燃一根白蜡烛，烛火摇曳不已。",
			[2] = "CYN你将蜡烛点燃，幽黄色的烛光微微摇曳。",
		}
	}
	local level_3 = {
		fireText = {
			[1] = "CYN你点燃白蜡烛，火光摇摆不定，",
			[2] = "CYN你点上白蜡烛，烛光摇曳不定，",
			[3] = "CYN你刚将蜡烛点燃，只见一阵阴风袭来，几乎要将烛火吹灭，",
			[4] = "CYN你将白蜡烛点燃，火光暗淡，",
		},
		roomText = {
			[1] = "CYN耳边传来嘤嘤之声，似哭似笑，让你不寒而栗。",
			[2] = "CYN你突然闻到一股尸臭，你眼前一黑，一个踉跄，差点摔倒。",
			[3] = "CYN你看着周遭散发出的阵阵阴气，看来此地应有鬼魂作乱。",
			[4] = "CYN旁边的$N悄然发生了一些变化。",
		},
		text = {
			[1] = "CYN你点燃白蜡烛，烛火呈阴蓝之色。",
			[2] = "CYN你将白蜡烛点燃，火光十分暗淡。",
		}
	}
	local level_2 = {
		fireText = {
			[1] = "CYN你将白蜡烛点燃，烛光摇摆不定，几要熄灭，",
			[2] = "CYN你将白蜡烛点燃，",
			[3] = "CYN你点燃一根白蜡烛，顿时阴风大作，在蜡烛被吹灭前，",
			[4] = "CYN你将白蜡烛点燃，烛光忽明忽暗，",
		},
		roomText = {
			[1] = "CYN只听嘤呜之声不绝于耳，凄戚悲恸，你感觉呼吸都十分困难。",
			[2] = "CYN你看到了一大片血色和黑色，不知那是什么。",
			[3] = "CYN你隐隐看见一张恐怖的面孔。",
			[4] = "CYN$N盯了你一眼，你心中顿觉失落无比，过了许久方才反应过来。",
		},
		text = {
			[1] = "CYN你将白蜡烛点燃，烛火竟变成了黑色！",
			[2] = "CYN你将白蜡烛点燃，烛火忽明忽暗。",
		}
	}
	local level_1 = {
		fireText = {
			[1] = "CYN你将白蜡烛点燃，烛火刚被点上就被一阵阴风吹灭了，你观察着周围，但似乎什么都没有发现。",
			[2] = "CYN你将蜡烛点燃，烛火忽的一下就熄灭了，你观察着周遭，并没有什么异样发生。",
			[3] = "CYN你尝试点燃白蜡烛，但似乎怎么都点不上，十分奇怪。",
			[4] = "CYN你将白蜡烛点上，旁边的$N朝着你这边看了一眼，蜡烛便熄灭了！",
		},
		text = {
			[1] = "CYN你将蜡烛点燃，烛火忽的一下就熄灭了。",
			[2] = "CYN你尝试点燃白蜡烛，但似乎怎么都点不上，十分奇怪。",			
		}
	}
	local level_0 = {
		[1] = "CYN你点燃了一根白蜡烛，蜡烛散发出幽幽的光，但什么事情都没有发生。",
		[2] = "CYN你将白蜡烛点燃，你观察着周围，但似乎什么都没有发现。",
		[3] = "CYN你将蜡烛点燃，烛光明亮，周遭并没有什么异样发生。",
	}
	local function stringGsub(str,char1,char2)
		return string.gsub(str,char1,char2)
	end
	if level >=1 and level <= 5 then
		level = self:checkCanLogUsualText(level) --是否会输出普通文本
	end
	local random = Helper:RandomByWeight({[1] = 8,[2] = 2})
	if level == 7 then
		role.baseId = "zhongyuanrernwu14"
		self:candleLog(math.random(2,5),role)
	elseif level == 6 then
		RichPrint("main",level_6[role.baseId])
	elseif level == 5 then
		if random == 1 then
			RichPrint("main",level_5.text[math.random(1,#level_5.text)])
		else
			local str1 = stringGsub(level_5.fireText[math.random(1,#level_5.fireText)],"$N",role.name)
			local str2 = stringGsub(level_5.roomText[math.random(1,#level_5.roomText)],"$N",role.name)
			RichPrint("main",str1..str2)
		end
	elseif level == 4 then
		if random == 1 then
			RichPrint("main",level_4.text[math.random(1,#level_4.text)])
		else
			RichPrint("main",stringGsub(level_4.fireText[math.random(1,#level_4.fireText)],"$N",role.name)..stringGsub(level_4.roomText[math.random(1,#level_4.roomText)],"$N",role.name))
		end
	elseif level == 3 then
		if random == 1 then
			RichPrint("main",level_3.text[math.random(1,#level_3.text)])
		else
			RichPrint("main",stringGsub(level_3.fireText[math.random(1,#level_3.fireText)],"$N",role.name)..stringGsub(level_3.roomText[math.random(1,#level_3.roomText)],"$N",role.name))
		end
	elseif level == 2 then
		if random == 1 then
			RichPrint("main",level_2.text[math.random(1,#level_2.text)])
		else
			RichPrint("main",stringGsub(level_2.fireText[math.random(1,#level_2.fireText)],"$N",role.name)..stringGsub(level_2.roomText[math.random(1,#level_2.roomText)],"$N",role.name))
		end
	elseif level == 1 then
		if random == 1 then
			RichPrint("main",level_1.text[math.random(1,#level_1.text)])
		else
			RichPrint("main",stringGsub(level_1.fireText[math.random(1,#level_1.fireText)],"$N",role.name))
		end
	elseif level == 0 then
		RichPrint("main",level_0[math.random(1,#level_0)])
	end
end
function ghosts:checkCanLogUsualText(level)
	local list = {
		[1] = 5,
		[2] = 5,
		[3] = 10,
		[4] = 20,
		[5] = 30,
	}
	local count = Helper:getDef(list[tonumber(level)],0)
	local random = Helper:RandomByWeight({[1] = count ,[2] = 100- count})
	print("count",count,"random:",random)
	if random == 1 then
		level = 0
	else
	end
	print("使用白蜡烛随机本本",level)
	return level
end

--创建NPC
function ghosts:createGhostsNPC(list)
	list = Helper:getDef(list,{})
	local npc = Helper:getDef(self:getNPCBaseList(list.npcBaseId),{})
	local role = {}
	role = Helper:tableCover(role,npc)
	role = self:replaceRoleAttr(role)
	role.id = list.npcId
	if list.corpseReward then
		role.corpseReward = list.corpseReward
	end
	role.baseId = list.npcBaseId
	role.type = Helper:getDef(list.type,"role")
	role.npcDsc = list.npcDsc
	if list.npcName then
		role.name = list.npcName
	end
	if list.dscA then
		role.dscA = list.dscA
	end
	if self:getDemonlevel(list.npcBaseId) ~= 0 then
		role.specialType = "中元节"
	else
		role.specialType = "中元节伴生"
	end
	if list.npcBaseId == "zhongyuanrernwu14" then
		role.canKill = false
		role.words = self:getPlayerSpeckWord()
		role.npcDsc = self:getPlayerGhostsDsc(list)
		role.name = list.name
	else
		role.canKill = true
	end
	role.canTalk = true
	role.canPresent = true
	return role
end
function ghosts:getPlayerSpeckWord()
	local list = {
		[1] = "嘶..哈..",
		[2] = "呜..哈..",
		[3] = "呜呜呜..",
		[4] = "好..惨..",
		[5] = "嘿..嘿嘿..",
		[6] = "死..啊..",
		[7] = "惨..啊..",
		[8] = "眼..睛..",
		[9] = "饿..了..",
		[10] = "嘿..嘿..",
		[11] = "啊..好..痛..",
		[12] = "可..恶..",
	}
	return list[math.random(1,#list)]
end
function ghosts:print_ghz(str)
	if type(str) == "table" then
		Helper:print_lua_table(str)
	else
		print(str)
		
	end
end
local taskNpc = require("script.npc.taskNpc")
function ghosts:getNPCBaseList(baseId)
	local list = taskNpc.npc
	for k,v in pairs(list) do 
		if k == baseId then
			return v
		end
	end
end
--替换公式
function ghosts:replaceRoleAttr(role)
	local tab = {"int","jiaLi","skillLv7","lv","skillLv6","skillLv5","skillLv4","skillLv3","skillLv2","skillLv1","str","dex","neili","qi","con"}
	if role ~= nil and type(role) == "table" then
		for k,v in pairs(role) do 
			for i,value in pairs(tab) do 
				if k == value then
					local tmp = v
					tmp = Helper:GetValueFromScript(v, {lv = User:getRoleAttr("lv")})
					role[k] = tmp 
				end
			end
		end	
	end
	role.qiMax = role.qi
	role.neiliMax = role.neili
	return role
end
function ghosts:updateGhosts(mapId,roomId,role)
	if type(mapId) ~= "string" or type(roomId) ~= "string" or type(role) ~= "table" then
		return
	end
	local _ghosts = Helper:getDef(self:getGhosts(),{})
	local function _updateGhosts(list,roomId,role)
		if list == nil or type(list) ~= "table" then
			return 
		end
		for k,v in pairs(list) do 
			if v.roomId == roomId then
				list[k] = nil
			end
		end
		if #list == 0 then
			list = nil
		end
		return list
	end
	for k,v in pairs(_ghosts) do 
		if k == mapId then
			_ghosts[k] = _updateGhosts(v,roomId,role)
		end
	end
	self:setGhosts(_ghosts)
	-- User:getRole():updateTimeLimitFlag("ghosts",_ghosts)
end

function ghosts:setItenGhostOther(mapId,roomId,role)
	if type(mapId) ~= "string" or type(roomId) ~= "string" or type(role) ~= "table" then
		-- assert(nil)
		return
	end
	local _ghosts = self:getGhosts()
	if type(_ghosts) ~= "table" then
		return
	end
	if type(_ghosts[mapId]) ~= "table" then
		return
	end
	for k,v in pairs(_ghosts[mapId]) do 
		if v.roomId == roomId then
			_ghosts[mapId][k].other = role
		end
	end
	self:setGhosts(_ghosts)
	-- User:getRole():updateTimeLimitFlag("ghosts",_ghosts)
end

function ghosts:killGhost(mapId,roomId,role)
	local baseId,roleId = role.baseId,role.id
	self:killGhostRole(mapId,roomId,role)
	if type(mapId) ~= "string" or type(roomId) ~= "string" or type(baseId) ~= "string" then
		-- assert(nil)
		return
	end
	local _ghosts = self:getGhosts()
	if type(_ghosts) ~= "table" then
		return
	end
	if type(_ghosts[mapId]) ~= "table" then
		return
	end
	for k,v in pairs(_ghosts[mapId]) do 
		if v.roomId == roomId then
			if v.type == "item" then
				if type(v.other) == "table" then
					if v.other.npcBaseId == baseId then
						_ghosts[mapId][k] = nil
					end
				end
			else
				if v.npcBaseId == baseId then
					_ghosts[mapId][k] = nil
				end
			end
			if #_ghosts[mapId] == nil then
				_ghosts[mapId] = nil
			end
		end
	end
	self:setGhosts(_ghosts)
	-- User:getRole():updateTimeLimitFlag("ghosts",_ghosts)
end
function ghosts:killGhostRole(mapId,roomId,role)
	if type(mapId) ~= "string" or type(role) ~= "table" then
		-- assert(nil)
		return
	end
	if role.baseId == "zhongyuanrernwu20" or role.baseId == "zhongyuanrernwu21" then
		User:getRole():setAttr("qi",1)
		local str = "YEL"..role.name.."大吼一声：我跟你拼了！\n却见"..role.name.."耗尽全身气力，一拳打在你胸口上，你被这拼死一击击中，口吐鲜血，险些丧命！"
		RichPrint("main",str)
	end
end
function ghosts:getRoleWordByDscType(role,type)
	local function getAllDTypeDsc(type,list)
		list = Helper:getDef(list,{})
		local rTab = {}
		for k,v in pairs(list) do 
			if v[type] ~= nil then
				local tab = {
					dsc = v[type],
					words = v.talk
				}
				table.insert(rTab,tab)
			end
		end
		return rTab
	end
	if type == "dscA" then
		local dscList = nil
		if role.sex == "男" then
			dscList = getAllDTypeDsc(type,GhostsList["男容貌"])
		elseif role.sex == "女" then
			dscList = getAllDTypeDsc(type,GhostsList["女容貌"])
		end
		if dscList == nil then
			return ""
		end
		for k,v in pairs(dscList) do 
			if v.dsc == role.dscA then
				return string.split(v.words,";")
			end
		end
	else
		local dscList = {
			[1] = "嘶..哈..;呜..哈..;呜呜呜..;嘿..嘿嘿..;死..啊..;惨..啊..;眼..睛..;饿..了..;啊..好..痛.."
		}
		return string.split(dscList[math.random(1,#dscList)],";")
	end
end

--获取玩家信息失败，随机生成鬼兵并保存
function ghosts:replacePlayerWithGhost(role,roomId,mapId)
	if type(role) ~= "table" or type(roomId) ~= "string" or type(mapId) ~= "string" then
		return
	end
	local _ghosts = Helper:getDef(self:getGhosts(),{})
	local mapList = Helper:getDef(_ghosts[mapId],{})
	for k,v in pairs(mapList) do 
		if v.roomId == roomId then
			Helper:print_lua_table(v)
			local tab = Helper:tableCover({},role)
			tab.roomId = roomId
			_ghosts[mapId][k] = tab
		end
	end
	self:setGhosts(_ghosts)
	-- User:getRole():updateTimeLimitFlag("ghosts",_ghosts)
	-- assert(nil)
end
function ghosts:getInheritHistoryDsc(list)
	list = Helper:getDef(list,{})
	local dsc = ""
	local cl = "WHT"
	local role = User:getRole()
	for k,v in pairs(list) do 
		local map = role:getMapById("fb"..tostring(v.retireMap))
		dsc = dsc .. cl .. "公元" .. Helper:numberCast(Helper:date("%y", v.inheritTime)) .. "年" .. Helper:numberCast(Helper:date("%m", v.inheritTime)).. "月" .. Helper:numberCast(Helper:date("%d", v.inheritTime)).. "日" .. " " .. v.parentName .. "将衣钵传与" .. v.inheritName .. "，遂隐退于" .. map.name .."。\n"

	end
end
function ghosts:checkGhostDsc(role)
	if type(role) ~= "table" then
		return ""
	end
	if role.baseId == "zhongyuanrernwu14" then
		return self:getPlayerGhostsDsc(role)
	else
		local dsc = Helper:getDef(role.dscA,"")
		dsc = dsc..self:getRoleDsc(role.baseId,role.sex,"dscB")--{"dscA","dscB","dscC"}
		dsc = dsc..self:getRoleDsc(role.baseId,role.sex,"dscC")--baseId,sex,type
		return dsc
	end
end
return ghosts0000000
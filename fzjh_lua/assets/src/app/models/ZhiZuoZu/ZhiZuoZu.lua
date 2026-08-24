local User = require("app.models.user.User")

local Role = require("app.models.role.Role")

local DataBase = require("app.DataBase")

local ZhiZuoZu = {}

local NpcList = {}

local NpcTotalCountList = {}

local ZhiZuoZuRoleList =
	{
		-- fb200r02_1	npc200_16	fb200r11_1	谭欣
		["npc200_16"] =
		{
			npcId = "npc200_16",
			fbId = "fb200r02_1",
			maofangId = "fb200r11_1",
			roomId = "fb200_02",
		},
		--fb200r02_2	npc200_17	fb200r11_2	张伟
		["npc200_17"] =
		{
			npcId = "npc200_17",
			fbId = "fb200r02_2",
			maofangId = "fb200r11_2",
			roomId = "fb200_02",
		},
		--fb200r03_1	npc200_13	fb200r11_3	永福
		["npc200_13"] =
		{
			npcId = "npc200_13",
			fbId = "fb200r03_1",
			maofangId = "fb200r11_3",
			roomId = "fb200_03",
		},
		--fb200r03_2	npc200_14	fb200r11_4	文龙
		["npc200_14"] =
		{
			npcId = "npc200_14",
			fbId = "fb200r03_2",
			maofangId = "fb200r11_4",
			roomId = "fb200_03",
		},
		--fb200r03_3	npc200_22	fb200r11_5	睿智
		["npc200_22"] =
		{
			npcId = "npc200_22",
			fbId = "fb200r03_3",
			maofangId = "fb200r11_5",
			roomId = "fb200_03",
		},
		--fb200r04_1	npc200_06	fb200r11_6	柳如烟
		["npc200_06"] =
		{
			npcId = "npc200_06",
			fbId = "fb200r04_1",
			maofangId = "fb200r11_6",
			roomId = "fb200_04",
		},
		--fb200r06_1	npc200_10	fb200r11_7	雨珊
		["npc200_10"] =
		{
			npcId = "npc200_10",
			fbId = "fb200r06_1",
			maofangId = "fb200r11_7",
			roomId = "fb200_06",
		},
		--fb200r06_2	npc200_15	fb200r11_8	志杰
		["npc200_15"] =
		{
			npcId = "npc200_15",
			fbId = "fb200r06_2",
			maofangId = "fb200r11_8",
			roomId = "fb200_06",
		},
		--fb200r07_1	npc200_12	fb200r11_9	秋珊灵
		["npc200_12"] =
		{
			npcId = "npc200_12",
			fbId = "fb200r07_1",
			maofangId = "fb200r11_9",
			roomId = "fb200_07",
		},
		--fb200r08_1	npc200_25	fb200r11_10	香志达
		["npc200_25"] =
		{
			npcId = "npc200_25",
			fbId = "fb200r08_1",
			maofangId = "fb200r11_10",
			roomId = "fb200_08",
		},
		--fb200r09_1	npc200_21	fb200r11_11	曾忪
		["npc200_21"] =
		{
			npcId = "npc200_21",
			fbId = "fb200r09_1",
			maofangId = "fb200r11_11",
			roomId = "fb200_09",
		},
		--fb200r12_1	npc200_03	fb200r11_12	何虚名
		["npc200_03"] =
		{
			npcId = "npc200_03",
			fbId = "fb200r12_1",
			maofangId = "fb200r11_12",
			roomId = "fb200_12",
		},
		--fb200r12_2	npc200_04	fb200r11_13	王真一
		["npc200_04"] =
		{
			npcId = "npc200_04",
			fbId = "fb200r12_2",
			maofangId = "fb200r11_13",
			roomId = "fb200_12",
		},
		--fb200r13_1	npc200_05	fb200r11_14	天蚕
		["npc200_05"] =
		{
			npcId = "npc200_05",
			fbId = "fb200r13_1",
			maofangId = "fb200r11_14",
			roomId = "fb200_13",
		},
		--fb200r13_2	npc200_26	fb200r11_15	婵娟
		["npc200_26"] =
		{
			npcId = "npc200_26",
			fbId = "fb200r13_2",
			maofangId = "fb200r11_15",
			roomId = "fb200_13",
		},
		--fb200r14_1	npc200_18	fb200r11_16	神僧
		["npc200_18"] =
		{
			npcId = "npc200_18",
			fbId = "fb200r14_1",
			maofangId = "fb200r11_16",
			roomId = "fb200_14",
		},
		--fb200r16_1	npc200_20	fb200r11_17	高汉正
		["npc200_20"] =
		{
			npcId = "npc200_20",
			fbId = "fb200r16_1",
			maofangId = "fb200r11_17",
			roomId = "fb200_16",
		},
		--fb200r16_2	npc200_23	fb200r11_18	张钦雄
		["npc200_23"] =
		{
			npcId = "npc200_23",
			fbId = "fb200r16_2",
			maofangId = "fb200r11_18",
			roomId = "fb200_16",
		},
		--fb200r17_1	npc200_19	fb200r11_19	燕返
		["npc200_19"] =
		{
			npcId = "npc200_19",
			fbId = "fb200r17_1",
			maofangId = "fb200r11_19",
			roomId = "fb200_17",
		},
		--fb200r18_1	npc200_24	fb200r11_20	思敏
		["npc200_24"] =
		{
			npcId = "npc200_24",
			fbId = "fb200r18_1",
			maofangId = "fb200r11_20",
			roomId = "fb200_18",
		}
	}

local cailiao =
{
	[1] = "cailiao200_01",
	[2] = "cailiao200_02",
	[3] = "cailiao200_03",
	[4] = "cailiao200_04",
	[5] = "cailiao200_05",
	[6] = "cailiao200_06",
	[7] = "cailiao200_07",
	[8] = "cailiao200_08",
	[9] = "cailiao200_09",
	[10] = "cailiao200_10",
	[11] = "cailiao200_11",
	[12] = "cailiao200_12",
	[13] = "cailiao200_13",
	[14] = "cailiao200_14",
	[15] = "cailiao200_15",
	[16] = "cailiao200_16",
	[17] = "cailiao200_17",
	[18] = "cailiao200_18",
	[19] = "cailiao200_19",
	[20] = "cailiao200_20",
	[21] = "cailiao200_21",
	[22] = "cailiao200_22",
	[23] = "cailiao200_23",
	[24] = "cailiao200_24",
	[25] = "cailiao200_25",
	[26] = "cailiao200_26",
	[27] = "cailiao200_27",
	[28] = "cailiao200_28"
}

-- 获得制作组副本
function ZhiZuoZu:getZhiZhuZuMap()
	local role = User:getRole()
	local map = nil

	if MapIsEmpty(NpcList) == true then
		return nil
	end

	map = role:getMapById("fb200")
	User:setRoleAttr("currMapId", map.id)
	if map._isComingIn ~= true then
		print("初始化制作组副本信息")

		map = role:initMapById(map.id)
		map:enterMap()
		map:setMapInfo()
		map._isComingIn = true

		self:addTaskTotalCount(map)
		self:addRoleToMap(map)
	else
		map:enterMap()

		self:addTaskTotalCount(map)
	end

	return map
end

-- 获取今日制作组列表
function ZhiZuoZu:getZhiZuoZuList(func)
	HttpManagerEx:getZhiZuoZuRoleList(function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
            	NpcList = data["data1"]
            	NpcTotalCountList = data["data2"]
            	func()
            else
                --PopText(errmsg)
            end
    	end
	end, IS_SHOW_WAITING)
end

-- 添加制作组角色任务完成总次数
function ZhiZuoZu:addTaskTotalCount(map)
	local mapRolelist = map:getRoles()
	for npcId,npc in pairs(mapRolelist) do
		if ZhiZuoZuRoleList[npc.baseId] ~= nil then
			npc.ZhiZuoZuTotalCount = 0
		end
		if NpcTotalCountList then
			for k,v in pairs(NpcTotalCountList) do
				if npc.baseId == k then
					npc.ZhiZuoZuTotalCount = tonumber(v)
					--print(npc.id .. " 制作组任务总次数 " .. v)
				end
			end
		end
	end
end

-- 添加角色到制作组副本
function ZhiZuoZu:addRoleToMap(map)
	if map.id == "fb200" then
		-- fb200_11 茅房ID
		local role = User:getRole()

		if NpcList.maofang ~= "npc_nil" then
			print("添加角色 " .. ZhiZuoZuRoleList[NpcList.maofang].maofangId .. "至茅房")
			map:addRoomRole("fb200_11", ZhiZuoZuRoleList[NpcList.maofang].maofangId)
		end

		for k,v in pairs(NpcList.npc_id_user) do
			print(" 添加角色ID " .. ZhiZuoZuRoleList[k].fbId)
			map:addRoomRole(ZhiZuoZuRoleList[k].roomId, ZhiZuoZuRoleList[k].fbId)
		end
	end
end

function ZhiZuoZu:testGetReward(npcId)
	HttpManagerEx:addZhiZuoZuNpcRecord(npcId, function(status, errcode, errmsg, data)
	        if status == 200 then
	            if errcode == 0 then
	            else
	                --PopText(errmsg)
	            end
	    	end
		end, IS_SHOW_WAITING)
end

-- 保存副本人物位置信息
function ZhiZuoZu:savaMapRole(map)
	local role = User:getRole()
	DataBase:setLuaTable("ZhiZuoZuMap", map)
end

-- 检测是否拥有面具或材料
function ZhiZuoZu:checkIsHaveMask(itemId)
	local role = User:getRole()
	-- 装饰箱物品ID
	local Masks =
	{
		xinwu200_01 = {"cailiao200_01", "cailiao200_02"},
		xinwu200_02 = {"cailiao200_03", "cailiao200_04"},
		xinwu200_03 = {"cailiao200_05", "cailiao200_06", "cailiao200_07"},
		xinwu200_04 = {"cailiao200_08", "cailiao200_09", "cailiao200_10", "cailiao200_11"},
		xinwu200_05 = {"cailiao200_12", "cailiao200_13"},
		xinwu200_06 = {"cailiao200_14", "cailiao200_15"},
		xinwu200_07 = {"cailiao200_16", "cailiao200_17", "cailiao200_18"},
		xinwu200_08 = {"cailiao200_19", "cailiao200_20"},
		xinwu200_09 = {"cailiao200_21", "cailiao200_22"},
		xinwu200_10 = {"cailiao200_23", "cailiao200_24"},
		xinwu200_11 = {"cailiao200_25", "cailiao200_26"},
		xinwu200_12 = {"cailiao200_27", "cailiao200_28"},
	}
	local decorativeId = nil
	for k,v in pairs(Masks) do
		for kk,cailiaoId in pairs(v) do
			if itemId == cailiaoId then
				decorativeId = role:getItem(cailiaoId)
				if decorativeId == nil then
					decorativeId = role:getckItem(cailiaoId)
				end
				if decorativeId == nil then
					decorativeId = role:getDecorative(k)
				end
				if decorativeId == nil then
					decorativeId = role:getItem(k)
				end
				if decorativeId == nil then
					decorativeId = role:getckItem(k)
				end
			end
		end
	end

	if decorativeId == nil then
		return false
	else
		return true
	end
end

-- 打开制作组商人交易界面
function ZhiZuoZu:openZhiZuoZuChapman(role)
	TransCheck:checkAllUrlTrans()
    role.blackMarket = {}

    HttpManagerEx:getMaskList(function(status, errcode, errmsg, data, isEncrypted)
	    if isEncrypted == false then
	        Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
	        return
	    end
	    if status == 200 then
	        if errcode ~= 0 then
	        else
	            if data.status == "OPEN" then
	            	role.blackMarket = self:getMaskList()

	            	local MapBagLayer = require("app.views.layer.MapLayer.MapBagLayer")
				    local layer = MapBagLayer:getInstance()
				    layer:show()
				    layer:setRoles(User:getRole(), role, function()
				    	local currMap = User:getRole():getCurrMap()
				        -- 刷新房间条件结果
				        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
				    end)
				    User:getRole():setAttr("meiyu",data.points)
				    layer:setTextMeiYu(data.points)
				    layer.Text_desc:setVisible(true)
				    layer.Text_desc:setString("花费" .. data.yuanbao .. "元宝立即刷新")
				    layer:setNpcCanSale(false)
				    -- observerLayer:hide(true)
				    -- if callBackFunc then
				    --     callBackFunc()
				    -- end

				    layer:setButton1("立即刷新", function()
				    	-- 没有可买的，不让刷新
				    	local canBuyItemList = {}
						for i,v in ipairs(cailiao) do
							if self:checkIsHaveMask(v) ~= true then
								table.insert(canBuyItemList, i)
							end
						end
						if #canBuyItemList >  #self:getMaskList() then
						else
							PopText("无法刷新出更多道具了")
				    		return
						end
				    	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
						local dialog = DialogALayer:getInstance()
						dialog:show("花费" .. data.yuanbao .. "元宝立即刷新杂货商道具列表。")
						dialog:setRichText("花费" .. data.yuanbao .. "元宝立即刷新杂货商道具列表。")
						dialog:setButton1("确定", function()
							TransCheck:setTransWithWebOrderId(function(transId)
								HttpManagerEx:refreshMaskList(transId, function(status, errcode, errmsg, data)
									if status == 200 then
								        if errcode == 0 then
								        	TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
								        	self:refreshMaskList()
				    						self:openZhiZuoZuChapman(role)
								        else
								        	PopText(errmsg)
								        end
								    else
								    	PopText(errmsg)
									end
								end, IS_SHOW_WAITING)
							end, "zhizuozushuaxin", 1, 9)
						end)

						dialog:setButton2("取消", function()
						end)
				    end, false)
				end
            end
        end
	end, IS_SHOW_WAITING)


end

-- 获取制作组商人道具列表
function ZhiZuoZu:getMaskList()
	local role = User:getRole()
	local list = {}

	if role:getDayFlag("制作组商人道具列表") == 0 then
		-- 每天0点刷新列表
		self:refreshMaskList()
    end

    local str = role:getDayFlag("制作组商人道具列表")

    local cailiaoList = string.split(str, ";")

    if MapIsEmpty(cailiaoList) ~= true then
    	for i,v in ipairs(cailiaoList) do
			local cailiaoId = cailiao[tonumber(v)]
			if cailiaoId and self:checkIsHaveMask(cailiaoId) ~= true then
				table.insert(list, { id = User:getRole():getItemOnlyId() , count = 1 , itemId = cailiaoId ,priceUnit = "meiyu"})
			end
		end
    end
    return list
end

-- 刷新制作组商人道具列表
function ZhiZuoZu:refreshMaskList()
	local role = User:getRole()
	local str = ""

	-- 能够购买的道具 已拥有的不显示
	local canBuyItemList = {}
	for i,v in ipairs(cailiao) do
		if self:checkIsHaveMask(v) ~= true then
			table.insert(canBuyItemList, i)
		end
	end

	-- 设置每日标记 制作组道具列表索引
	if MapIsEmpty(canBuyItemList) ~= true then
		local indexList = self:getRandNumArray(1, #canBuyItemList, 7)
		for i,v in ipairs(indexList) do
			str = str .. tostring(canBuyItemList[v]) --.. ";"
			if i ~= #indexList then
				str = str .. ";"
			end
		end
	end

	role:setDayFlag("制作组商人道具列表", str)

	return str
end

-- 随机数 例如 1~100间取不重复10个数字 1, 100, 10
function ZhiZuoZu:getRandNumArray(startNum, endNum, count)
	local numMap = {}
	local numList = {}

	if endNum - startNum + 1 < count then
		count = endNum - startNum + 1
	end

	while true do
		if count == 0 then
			break
		end
		local randNum = math.random(startNum, endNum)
		if numMap[tostring(randNum)] ~= 1 then
			numMap[tostring(randNum)] = 1
			count = count - 1
		end
	end

	for k,v in pairs(numMap) do
		table.insert(numList, tonumber(k))
	end

	return numList
end

return ZhiZuoZu000
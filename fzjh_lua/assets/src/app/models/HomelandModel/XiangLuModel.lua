--
-- Author: TanQinJian
-- Date: 2020-03-23 10:32:31
--
local dreamcenser = require("script.dreamworld.dreamcenser")
local xiangLuTable = dreamcenser["炉"] or {}
local xiangTable = dreamcenser["香"] or {}
local buffTable = dreamcenser["buff"]
local XiangLuModel = {}

local FireXIANG_TYPE = {
	NORMAL = 1,	--正常带有buff的香
	DEFAULT = 2	--默认香 无buff
}

local defaultXiang = "drxiang01"

--床 休息功能
function XiangLuModel:bedRestFun(bedValue,xiangLuId,xiangId)
	local role = User:getRole()
	local drSystem = require("app.models.DreamWorldModel.DreamSystem"):create(role)
    local pijuan = role:getAttr("pijuan")
    local dreamPreFlag = role:getFlag("drqianzhi")
    if DEBUG_MODE == 1 then
    	dreamPreFlag = 1
    	pijuan =500
	end

	if not xiangId then
		xiangId = defaultXiang
	end

    local DREAM_CASE = {
        PIJUAN_NOT_ENOUGH = 1,   --疲劳值不足
		PRE_TASK_IS_NOT_COMPLETE = 2,   --未完成前置任务
		NO_CENSER = 3,			--没香炉
        INDREAM_SUCCESS = 4,   --成功
        INDREAM_FAILURE = 5,   --失败
	}

    --床恢复精力
    local function addJingFun()
        local addJing = (bedValue * bedValue  + role:getJingMax() / 100) * 80 / 200

        local jingMax = role:getJingMax()
        local currJing = role:getAttr("jing")

        if addJing < jingMax - currJing  then
        	role:addAttr("jing", addJing)
        	RichPrint("main", "精力 + "..math.floor(addJing))
        elseif currJing < jingMax then
        	role:addAttr("jing", jingMax - currJing)
        	RichPrint("main", "精力 + "..math.floor(jingMax - currJing))
		end
	end

	local function consumePiJuan(value)
		value = Helper:getDef(value,-80)
		role:addAttr("pijuan",value)
	end

    local function afterText()
    	local text = ""
    	if pijuan < 80 then
    		text = "你毫无倦意，在床上折腾了几番，只得起身离去。"
		elseif pijuan < 160 then
			text = "你舒展四肢，安稳地躺在床上。"
		else
			text = "你拖着疲惫的身躯躺在了床上。"
		end
		RichPrint("main", text)
    end

    local function preConditionCaseType()
        if pijuan < 80 then
            return DREAM_CASE.PIJUAN_NOT_ENOUGH
        end
        if dreamPreFlag~=1 then
            return DREAM_CASE.PRE_TASK_IS_NOT_COMPLETE
		end
		if not xiangLuId then
			return DREAM_CASE.NO_CENSER
		end

		local xiangLuAddRate = self:getSpecialValue(xiangLuId, xiangId)

		local yuekaAddRate = 0

		if role:yueKaIsValid() then
			yuekaAddRate = 10
		end

		local dreamRate = self:getDreamRate(xiangId,xiangLuAddRate,yuekaAddRate)

      	if self:isCanDream(dreamRate) then
            return DREAM_CASE.INDREAM_SUCCESS
        else
            return DREAM_CASE.INDREAM_FAILURE
        end
	end

	local addPijuanFunc = function(addValue)
		if addValue == 0 or type(addValue) ~= "number" then
			return
		end
		local role = User:getRole()
		role:addAttr("pijuan",addValue)
		local text 
		if addValue > 0 then
			text = "随着梦境的深入，疲倦值增加"..tostring(addValue).."点"
		else
			text = "随着梦境的深入，疲倦值扣除"..tostring(math.abs(addValue)).."点"
		end
		PopText(text)
	end

	local function bedRestResultSuccess()
		MainControllLayer:getLayer("PrintLayer"):initRichText()
		local DreamRoleModel = require("app.models.DreamWorldModel.DreamRoleModel")
		local role = drSystem:createNewDreamRole()
		role.dreamPoints  = role.dreamPoints + User:getRole():getFinalAttr("drRoleMoneyAdd")
		role.weight  = role.weight + User:getRole():getFinalAttr("drRoleWeightAdd")
		User:getRole():dispatchEvent("CreateNewDrPlayerEvent", {role = role})
		--上传服务器
		DreamRoleModel:uploadDreamRole(
			role:getTrimData(),
			function(errcode, errmsg, data)
				if errcode == 0 then
					PopupLayerController:showLayer(
						"DreamEntryLayer",
						function(layer)
							layer:showLayer(MAP_TYPE.DREAMMAP,
								function()
									drSystem:enterNewMap(role)
								end
							)
							layer:setAfterFunc(
								function()
									addPijuanFunc(data.addPijuan)
									local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")
									DreamTalentModel:unlockActiveTalent(User:getRole())

									self:__doExtraActionFunc()
								end
							)
						end
					)
					return true
				elseif errcode == 2 then
					--@desc 数据有变动，需重新创建
					role:destory()
					local player = drSystem:createDreamRoleWithData(data)
					PopupLayerController:showLayer(
						"DreamEntryLayer",
						function(layer)
							layer:showLayer(MAP_TYPE.DREAMMAP,
								function()
									drSystem:enterNewMap(role)
								end
							)
							layer:setAfterFunc(
								function()
									addPijuanFunc(data.addPijuan)
									local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")
									DreamTalentModel:unlockActiveTalent(User:getRole())

									self:__doExtraActionFunc()
								end
							)
						end
					)
					return true
				else
					PopText(errmsg)
					return false
				end
			end
		)
	end

	local function getDreamFailBuff(xiangLuId, xiangId)
		local buffAddRate = self:getSpecialValue(xiangLuId, xiangId)
		local buffId = self:getFailBuff(xiangId,buffAddRate)
		--没有buff情况 什么都不发生
		if not buffId then
			return
		end

		local buffAttr = self:getAsleepBuffAttr(buffId)
		if MapIsEmpty(buffAttr) then
			print("没有buff资源 buffId = ",buffId)
			return
		end

		print("入梦失败，获得入梦buff ",buffId)
		local printText = buffAttr.text
		RichPrint("main", printText)

		local role = User:getRole()
		local asleepBuff = role:getAttr("AsleepBuff")
		if MapIsEmpty(asleepBuff) == false then
			RichPrint("main", "体内的临时能力似乎产生了变化")
		end
		--暂时需求是直接覆盖之前buff
		role:setAttr("AsleepBuff",{{id = buffId,startTime = GetTime()}})
		role:updateRoleBuff()
	end

	local function bedRestResultFail()
		if self:checkIsDefaultXiang(xiangId) == false and xiangLuId then
			getDreamFailBuff(xiangLuId,xiangId)
		end
		RichPrint("main", "HIY踏实酣眠，一觉无梦，疲劳之感已去大半")
	end

	--@desc 进入梦境需要记录的数据
	local function recordEnterDreamParams()
		local role = User:getRole()
		local dr_params = {
			enterDreamPijuan = role:getAttr("pijuan"),
			enterDreamBedValue = bedValue,
		}
		role:setAttr("dr_params",dr_params)
	end

	local function DreamCase()
		local dreamCase = preConditionCaseType()
		if  DEBUG_MODE == 1 then
			dreamCase = DREAM_CASE.INDREAM_SUCCESS
		end
		switch(dreamCase,{
			[DREAM_CASE.PIJUAN_NOT_ENOUGH] = function ()
				afterText()
			end,
			[DREAM_CASE.PRE_TASK_IS_NOT_COMPLETE] = function ()
				afterText()
				addJingFun()
				consumePiJuan(-80)
			end,
			[DREAM_CASE.NO_CENSER] = function ()
				afterText()
				addJingFun()
				consumePiJuan(-80)
			end,
			[DREAM_CASE.INDREAM_SUCCESS] = function ()
				afterText()
				recordEnterDreamParams()
				bedRestResultSuccess()
				consumePiJuan(-80)
			end,
			[DREAM_CASE.INDREAM_FAILURE] = function ()
				afterText()
				addJingFun()
				bedRestResultFail()
				consumePiJuan(-80)
			end,
			default = function ()
			end,
		})
	end

	local function getDreamRoleData()
		local DreamRoleModel = require("app.models.DreamWorldModel.DreamRoleModel")
		DreamRoleModel:getDreamRoleFromWeb(
			function(roleData)
				local role
				local floorNum = 1
				if roleData == nil then
					DreamCase()
				else
					MainControllLayer:getLayer("PrintLayer"):initRichText()
					
					--@desc 有数据，接上次数据继续未完梦境
					role = drSystem:createDreamRoleWithData(roleData)
					floorNum = Helper:getDef(role.dreamWorld.cFloor, 1)
					PopupLayerController:showLayer(
						"DreamEntryLayer",
						function(layer)
							layer:showLayer(MAP_TYPE.DREAMMAP,
								function()
									drSystem:enterMap(floorNum, role)
								end
							)

							layer:setAfterFunc(
								function()
									drSystem:showFloorSettleLayer(floorNum,User:getRole():getCurrMap())
								end
							)
						end
					)
				end
			end
		)
	end

	HttpManagerEx:checkDreamRoleDataIsOverdue(User:getRole():getTrimData(),function(status, errcode, errmsg, data)
		--@desc errcode = 0 结算上次梦境 errcode = 2没有需要结算的过期梦境  errcode = -2上次梦境作弊
		print("checkDreamRoleDataIsOverdue          errcode = ",errcode)
		if status == 200 then
			if errcode == 0 then
				if MapIsEmpty(data.eventsInfo) == false then
					drSystem:handlDreamOperationEvent(data.eventsInfo)
				end

				RichPrint("main","大于72小时没继续梦境闯荡，现对上次梦境玩法进行奖励结算：")
				RewardManager2:receiveRewardIsOverdue(data.reward,User:getRole(),User:getRole():getCurrMap())

				--@desc 完成梦境时，给玩家回复精力值
				drSystem:addJingDreamComplete()
			elseif errcode == 2 then
				getDreamRoleData()
			elseif errcode == -2 then
				getDreamRoleData()
			else
				PopText(errmsg)
			end
		end
    end, IS_SHOW_WAITING)
end

--获取香炉相关信息
function XiangLuModel:getXiangLuInfo(xiangLuId)
	if not xiangLuId then
		assert(false,"XiangLuModel:getXiangLuInfo 缺少参数")
	end
	local xiangLuInfo
	for k,v in pairs(xiangLuTable) do
		if xiangLuId == v.xlid then
			xiangLuInfo = v
			break
		end
	end
	if MapIsEmpty(xiangLuInfo) ==false then
		return xiangLuInfo
	end
	assert(false,"找不到该香炉 xiangluid:"..xiangLuId)
end

--获取香相关信息
function XiangLuModel:getXiangInfo(xiangId)
	if not xiangId then
		assert(false,"XiangLuModel:getXiangInfo 缺少参数")
	end
	local xiangInfo
	for k,v in pairs(xiangTable) do
		if xiangId == v.drxiangid then
			xiangInfo = v
			break
		end
	end
	if MapIsEmpty(xiangInfo) ==false then
		return xiangInfo
	end
	assert(false,"找不到该香 xiangid:"..xiangId)
end

function XiangLuModel:getAllXiang()
	return xiangTable or {}
end

function XiangLuModel:getXiangInfoInXiangLu(xiangLu)
	local xiangInfo={}
	if MapIsEmpty(xiangLu) then
		return xiangInfo
	end
	if self:getFireXiangType(xiangLu) == FireXIANG_TYPE.NORMAL then
		local xiangAttr = self:getXiangInfo(xiangLu.extra.xiangId)
		local xiangItem = Item:getOneItemByKey(xiangAttr.drxiangid)
		xiangAttr.startTime = xiangLu.extra.fireTime
		xiangAttr.name = xiangItem.name
		xiangInfo = xiangAttr
	else
		local xiangAttr = self:getXiangInfo(defaultXiang)
		local xiangItem = Item:getOneItemByKey(xiangAttr.drxiangid)
		xiangAttr.startTime = 0
		xiangAttr.name = xiangItem.name
		xiangInfo = xiangAttr
	end
	return xiangInfo
end

--获取香炉的特性
function XiangLuModel:getSpecialValue(xiangLuId,xiangId)
	if xiangLuId == nil or xiangId == nil then
		return 0
	end
	local currXiangluInfo = self:getXiangLuInfo(xiangLuId)
	if MapIsEmpty(currXiangluInfo) then
		assert(false,"香炉资源有问题 xiangLuId:"..xiangLuId)
	end
	local specialTab = string.split(currXiangluInfo.rxtx,";")

	for k,v in pairs(specialTab) do
		if string.find(v,xiangId) then
			local fireXiangTab = string.split(v,",")
			return fireXiangTab[2]
		end
	end
end

--获取失败buff specialValue 由香炉附带的特性值
function XiangLuModel:getFailBuff(xiangId,specialValue)
	local currXiang = self:getXiangInfo(xiangId)
	if MapIsEmpty(currXiang) then
		assert(false,"香资源有问题 xiangid:"..xiangId)
	end
	--不产生buff的香
	if not currXiang.lsbuffid or currXiang.lsbuffid == "" then
		return 
	end
	local randomList = {}
	local buffs = string.split(currXiang.lsbuffid,",")
	local weightValue = string.split(currXiang.buffqz,",")
	for i=1,#buffs do
		randomList[buffs[i]] = weightValue[i] or 0
	end
	if specialValue and currXiang.txsz then
		if randomList[currXiang.txsz] then
			randomList[currXiang.txsz] = randomList[currXiang.txsz] + specialValue
		else
			randomList[currXiang.txsz] = specialValue
		end
	end

	local buffId = Helper:RandomByWeight(randomList)
	return buffId
end

--判断点燃香的情况下是否可以入梦 specialValue 由香炉附带的特性值
function XiangLuModel:isCanDream(dreamRate)
	if type(dreamRate) ~= "number" then
		assert(false,"XiangLuModel:isCanDream 参数dreamRate 类型不对")
	end

	local randRate = math.random(1,100)
	dreamRate = dreamRate * 100

	print("当前入梦概率：",dreamRate," 随机概率：",randRate)
    if dreamRate >= randRate then
    	return true
    end
	return false
end

--入梦概率百分比 
--extraAddRate 江湖名士额外增加的概率 
--specialValue 香炉与香的特性增加概率
function XiangLuModel:getDreamRate(xiangId,specialValue,extraAddRate)
	local currXiang = self:getXiangInfo(xiangId)
	if MapIsEmpty(currXiang) then
		assert(false,"香资源有问题 xiangid:"..xiangId)
	end
	local successRate = currXiang.drgl or 0
    if currXiang.txlx == 1 and specialValue then
        successRate = successRate + specialValue + User:getRole():getFinalAttr("enterDreamRate")
	end
	successRate = successRate + extraAddRate
	return successRate/100
end

--判断当前香炉是否可以点燃当前香
function XiangLuModel:isCanFire(xiangLuId,xiangId)
	if xiangLuId == nil or xiangId == nil then
		return false
	end

	local currXiangluInfo = self:getXiangLuInfo(xiangLuId)
	if MapIsEmpty(currXiangluInfo) then
		return false
	end

	if string.find(currXiangluInfo.rxtx,xiangId) then
		return true
	end

	return false
end

--获取当前香炉点燃香的类型
function XiangLuModel:getFireXiangType(xiangLu)
	if MapIsEmpty(xiangLu) then
		assert(false,"XiangLuModel:getFireXiangType xiangLu参数有误")
	end

	if MapIsEmpty(xiangLu.extra) then
		return FireXIANG_TYPE.DEFAULT
	end

	local startTime = xiangLu.extra.fireTime
	local xiangId = xiangLu.extra.xiangId

	local xiangInfo = self:getXiangInfo(xiangId)
	if GetTime() - startTime >= xiangInfo.rxtime then
		return FireXIANG_TYPE.DEFAULT
	end

	return FireXIANG_TYPE.NORMAL
end

function XiangLuModel:checkFireXiangIsNormal(_type)
	return  _type == FireXIANG_TYPE.NORMAL
end

--燃buff香 实质数据保存在香炉身上
function XiangLuModel:fireXiang(furnitureId,xiangId,func)
    local itemInfo = {}
    itemInfo.fid = furnitureId
    local attr = {}
    attr.fireTime = GetTime() --只需记录香的点燃时间
    attr.xiangId = xiangId
    itemInfo.attr = attr

    local extraAttr = {}
    table.insert(extraAttr,itemInfo)
    local mid = User:getRole():getHouseId()

    HttpManagerEx:uploadFurnitureExtra(mid,extraAttr,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local curMap = User:getRole():getCurrMap()
            local currRole = curMap:getRole("f_"..furnitureId) --刷新香炉相关属性
            if currRole then
                currRole.extra = attr
            end
            if func then
            	func(currRole)
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

--刷新香炉状态 --燃香熄灭的处理（梦境结算时需熄灭）
function XiangLuModel:updateXiangLuState(xiangLu,func)
	if MapIsEmpty(xiangLu) then
		return
	end
	local fireXiangType = self:getFireXiangType(xiangLu)

	if fireXiangType == FireXIANG_TYPE.NORMAL then
		local xiangId = xiangLu.extra.xiangId
		local extraAttr = {}
		local itemInfo = {}
		itemInfo.fid = xiangLu.fid
		itemInfo.attr = {}
		table.insert(extraAttr,itemInfo)
	    local mid = User:getRole():getHouseId()

	    HttpManagerEx:uploadFurnitureExtra(mid,extraAttr,function(status, errcode, errmsg, data)
	        if status == 200 and errcode == 0 then
	            local curMap = User:getRole():getCurrMap()
	            local currRole = curMap:getRole("f_"..xiangLu.fid) --刷新香炉相关属性
	            if currRole then
	                currRole.extra = {}
	            end
	            if func then
	            	func(currRole)
	            end
	        else
	            PopText(errmsg)
	        end
	    end, IS_SHOW_WAITING)
	end
end

function XiangLuModel:getAsleepBuffAttr(buffId)
    local attr = {}
    if buffId == nil then
        return attr
    end

    return buffTable[tostring(buffId)]
end

function XiangLuModel:checkIsDefaultXiang(xiangId)
	if not xiangId then
		return true
	end
	if defaultXiang == xiangId then
		return true
	end
	return false
end

--获取玩家背包香
function XiangLuModel:getRoleBagXiang(role)
	if not role then
		role = User:getRole()
	end
	local xiangTab = {}
	local xiangInfoTab = self:getAllXiang()
	if MapIsEmpty(xiangInfoTab) == false then
		for k,v in pairs(xiangInfoTab) do
			local currNum = role:getItemCount(v.drxiangid)
			if currNum > 0 then
				xiangTab[v.drxiangid] = currNum
			end
		end
	end
	return xiangTab
end

--成功进入梦境需要进行的额外活动处理
function XiangLuModel:__doExtraActionFunc()
    local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")

	if LimitedTimeExperience:checkTaskIsOpen("dream") then
		LimitedTimeExperience:setRole(User:getRole())
		LimitedTimeExperience:finishTaskByTaskType("dream")
	end
end

return XiangLuModel000000000
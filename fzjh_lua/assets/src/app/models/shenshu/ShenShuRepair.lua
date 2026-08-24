local newClass = require("third.class.NewClass")
local ShenShuHelper = require("app.models.shenshu.shenshu")
local ShenShuRepair = {}

function ShenShuRepair:create(role)
    local p = ShenShuRepair.new()

    p:__init(role)

    return p
end

function ShenShuRepair:__init(role)
    self.__role = role
end

function ShenShuRepair:repair()
    if self.__role.repairShenShu == nil then
        self:__ShenShuListRepair()
    end

	if self.__role.repairShenShu == 1 then
        self:__changeToNewShenShu()
    end

	if self.__role.repairShenShu == 2 then
        self:__repairShenShuInherit()
    end

	if self.__role.repairShenShu == 3 then
        self:__repairShenShuItemDelete()
    end
end

function ShenShuRepair:__ShenShuListRepair()
    --神书线上存储结构优化
	local shenShuInfo = self.__role:getTimeLimitFlag("ShenShuList")
	if MapIsEmpty(shenShuInfo) == false then
		local newShenShuInfo = {}

		for __, v in pairs(shenShuInfo) do
			for k, info in pairs(v) do
				local _info = {}
				Helper:tableCover(_info, info)
				_info.id = ShenShuHelper:getShenShuIdByItemId(info.itemId)

				table.insert(newShenShuInfo, _info)
			end
		end

		self.__role:updateTimeLimitFlag("ShenShuList", newShenShuInfo)
	end
	
	self.__role.repairShenShu = 1
end

function ShenShuRepair:__changeToNewShenShu()
	local currtime = Helper:date("%y%m%d", GetTime())
    local time = self.__role:getInheritFlag("ShenShu")
	local shenShuTime = self.__role:getTimeLimitFlagTime("ShenShuList")
	local shenShuList = self.__role:getTimeLimitFlag("ShenShuList")
	local songLiNPCList = self.__role:getTimeLimitFlag("SongLiNPCList")

	--当天有做神书，且还在继续
	if currtime == time and shenShuTime ~= 0 then
		local shenShuTask = self.__role:getAttr("shenShuTask")
		shenShuTask.count = 1
		shenShuTask.allCount = 1
		shenShuTask.startTime = GetTime() - shenShuTime
		shenShuTask.task = {
			startTime = GetTime() - shenShuTime,
			bookDropInfoList = shenShuList
		}

		ShenShuHelper:setTaskSongLiInfo(self.__role, {
			startTime = GetTime() - shenShuTime,
			npcList = songLiNPCList
		})
	end

	--没有开启过神书，用以修复传承神书未消失切没有开启神书任务，原在Role:repairUserData()中修复，现调整到此
	if time == 0 then
		local items = self.__role:getItems()

		if items then
			for i = #items,1,-1 do 
				local itemAttr = self.__role:getOneItemByKey(items[i].itemId)
				if itemAttr and itemAttr.type == "神书" then
					table.remove(items, i)
				end
			end
		end

		local ckItems = self.__role:getckItems()
		if ckItems then
			for i = #ckItems,1,-1 do 
				local itemAttr = self.__role:getOneItemByKey(ckItems[i].itemId)
				if itemAttr and itemAttr.type == "神书" then
					table.remove(ckItems, i)
				end
			end
		end
	end

	self.__role:setTimeLimitFlag("ShenShuList", nil)
	self.__role:setTimeLimitFlag("SongLiNPCList", nil)
	self.__role:setInheritFlag("ShenShu", nil)
	self.__role:setFlag("ShenShuOpen", nil)

	self.__role.repairShenShu = 2
end

--[[
    @desc: 神书改版上线第一周传承导致刷新异常问题修复，1751212800上线时间
    author:tanqinjian
    time:2025-07-01 15:00:31
    @return:
]]
function ShenShuRepair:__repairShenShuInherit()
	local shenShuTask = self.__role:getAttr("shenShuTask")
	--没有使用灵石开启，却有收集神书次数，当前只有传承异常导致
	if shenShuTask.count > 0 and shenShuTask.startTime == -1 then
		shenShuTask.startTime = 1751212800
	end

	self.__role.repairShenShu = 3
end

--[[
    @desc: 修复新版神书更新后一直没有开启神书任务的玩家身上神书道具
    author:tanqinjian
    time:2025-07-01 15:10:52
    @return:
]]
function ShenShuRepair:__repairShenShuItemDelete()
	local shenShuSongLiInfo = self.__role:getAttr("shenShuSongLiInfo")
	--未开启神书送礼时，背包神书需要删除
	if shenShuSongLiInfo.startTime == -1 then
		local items = self.__role:getItems()
		local list = {}

		if items then
			for i = #items,1,-1 do 
				local itemAttr = self.__role:getOneItemByKey(items[i].itemId)
				if itemAttr and itemAttr.type == "神书" then
					list[items[i].itemId] = items[i].count
				end
			end

			for itemId, count in pairs(list) do
				self.__role:addItemCount(itemId, -count, nil, nil, "神书过期")
			end
		end
	end

	self.__role.repairShenShu = 4
end

return newClass("ShenShuRepair", {}, ShenShuRepair)
000
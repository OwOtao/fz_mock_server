
--
-- Author: TanQinJian
-- Date: 2019-04-24 16:39:14
--师门声望
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local chengHaoListData = assert(clone(RoleTitleResManager:getPrestigeTitle()))
local FamilyPrestige = {}

--@desc: 获取当前声望
--@author:Liang SongQiang
--@time:2019-04-24 17:25:27
function FamilyPrestige:getUserPrestige(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:getUserPrestige(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                	--判断是否解锁新称号
                	self:__updateFamilyPrestigeTitle(data)
                    callback(data)
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 增加玩家师门声望
--@author:Liang SongQiang
--@time:2019-04-24 17:11:25
--@addPrestige:增加的值
--@event: 事件信息
function FamilyPrestige:addUserPrestige(addPrestige,event,callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:addUserPrestige(
        addPrestige,
        event,
        function(status, errcode, errmsg, data)
            if status == 200 then  
                if errcode == 0 then
                	--判断是否解锁新称号
                	self:__updateFamilyPrestigeTitle(data)
                    callback(data)
					if data.upper == true then
						PopText("今日可获得声望已经达到上限！")
					end
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function FamilyPrestige:__updateFamilyPrestigeTitle(prestigeData)
	if MapIsEmpty(prestigeData) then 
		return 
	end

	self:__updateOnlyTitle(prestigeData.title)
	self:__updateNoramlTitle(prestigeData.total)
end

function FamilyPrestige:__updateOnlyTitle(titleList)
	if self._isUpdateOnlyTitle then 
		return 
	end

	self._isUpdateOnlyTitle = true

	local role = User:getRole()
	local roleTitleList = role:getRoleBasicTitleList()
	local roleFamilyPrestigeOnlyTitleList = {}

	for i, title in ipairs(roleTitleList) do
		if title:getType() == RoleTitleConst.BasicTitleType.Prestige then
			local basicTitleId = title:getId()
			for k, v in pairs(chengHaoListData) do
				if tostring(v.basicTitleId) == basicTitleId and v.rank ~= 0 then
					table.insert(roleFamilyPrestigeOnlyTitleList, basicTitleId)
				end
			end
		end
	end

	if MapIsEmpty(titleList) == false then
		local webTitleList = {}

		for __, title in ipairs(titleList) do
			for k, v in pairs(chengHaoListData) do
				if v.title == title and v.rank ~= 0 then
					table.insert(webTitleList, tostring(v.basicTitleId))
				end
			end
		end

		for i, roleTitleId in ipairs(roleFamilyPrestigeOnlyTitleList) do
			local isNeedRemove = true

			for __, titleId in ipairs(webTitleList) do
				if roleTitleId == titleId then
					isNeedRemove = false
				end
			end

			if isNeedRemove then
				self:__deleteBasicTitle(roleTitleId)
			end
		end

		for __, titleId in ipairs(webTitleList) do
			if role:hasBasicTitle(titleId) == false then
				self:__addBasicTitle(titleId)
			end
		end
	else
		for i, roleTitleId in ipairs(roleFamilyPrestigeOnlyTitleList) do
			self:__deleteBasicTitle(roleTitleId)
		end
	end
end

function FamilyPrestige:__updateNoramlTitle(prestigeValue)
	prestigeValue = tonumber(prestigeValue)

	local role = User:getRole() 
	local roleTitleList = role:getRoleBasicTitleList()
	local roleFamily = role:getFamilyId()
	local weiwang = role:getAttr("weiwang")
	local sexType = role:getAttr("sex") == "男" and 1 or 2

	local function familyConditon(needFamily)
		if roleFamily ~= needFamily then
			return false
		end

		return true
	end
	
	local function rankCondition(needRank)
		needRank = tonumber(needRank)
		--排行不等0，服务器解锁
		if needRank ~= 0 then
			return false
		end 

		return true
	end
	
	local function prestigeCondition(needPrestige)
		needPrestige = tonumber(needPrestige)

		if prestigeValue < needPrestige then
			return false
		end

		return true
	end
	
	local function weiWangCondition(needWeiWang)
		needWeiWang = tonumber(needWeiWang)

		if needWeiWang == 0 then
			return true
		end

		if weiwang < needWeiWang then
			return false
		end

		return true
	end
	
	local function sexTypeCondition(needSexType)
		needSexType = tonumber(needSexType)

		if needSexType == 0 then
			return true
		end
		
		if needSexType ~= sexType then
			return false
		end

		return true
	end
	
	local function skillCondition(needSkill)
		if needSkill == 0 then
			return true
		end

		local skillInfo = string.split(needSkill, ",")

		if MapIsEmpty(skillInfo) == false then 
			for i, v in pairs(skillInfo) do 
				local skillTab = string.split(v,":")
				local skillId = skillTab[1]
				local needExp = tonumber(skillTab[2])
				local currSkill = role:getSkill(skillId)

				if MapIsEmpty(currSkill) == false then
					if currSkill.exp < needExp then
						return false
					end
				else
					return false
				end
			end
		end

		return true
	end 

	--先判断已获得称号是否不满足条件，不满足则删除
	for i, title in ipairs(roleTitleList) do
		if title:getType() == RoleTitleConst.BasicTitleType.Prestige then
			local basicTitleId = title:getId()

			for k, v in pairs(chengHaoListData) do
				local isNormal = rankCondition(v.rank)
				if isNormal and tostring(v.basicTitleId) == basicTitleId then
					local isTrue = familyConditon(v.family)

					if isTrue then
						isTrue = prestigeCondition(v.shengwang)
					end

					if isTrue then
						isTrue = weiWangCondition(v.weiwang)
					end

					if isTrue then
						isTrue = sexTypeCondition(v.sex)
					end

					if isTrue then
						isTrue = skillCondition(v.skill)
					end

					if isTrue == false then
						self:__deleteBasicTitle(basicTitleId)
					end
				end
			end
		end
	end

	--判断是否有新的解锁称号
	for k, v in pairs(chengHaoListData) do
		local isTrue = familyConditon(v.family)

		if isTrue then
			isTrue = rankCondition(v.rank)
		end

		if isTrue then
			isTrue = prestigeCondition(v.shengwang)
		end

		if isTrue then
			isTrue = weiWangCondition(v.weiwang)
		end

		if isTrue then
			isTrue = sexTypeCondition(v.sex)
		end

		if isTrue then
			isTrue = skillCondition(v.skill)
		end

		if isTrue and role:hasBasicTitle(v.basicTitleId) == false then
			self:__addBasicTitle(v.basicTitleId)
		end
	end
end

function FamilyPrestige:__addBasicTitle(basicTitleId)
	local title = RoleTitleResManager:getBasicTitleClassById(basicTitleId)
	if title then
		local name = title:getColorName()
		local role = User:getRole()
		role:addBasicTitle(basicTitleId)
		RichPrint("main", "随着你的武功不断精进以及在门派中的地位提升，获得了门派声望头衔："..name)
	end
end

function FamilyPrestige:__deleteBasicTitle(basicTitleId)
	local title = RoleTitleResManager:getBasicTitleClassById(basicTitleId)
	if title then
		local role = User:getRole()
		role:deleteBasicTitle(basicTitleId)
		local name = title:getColorName()
		RichPrint("main", "RED师门声望排名争夺激烈，你之前的头衔NOR"..name.."RED已经不属于你了。NOR")
	end
end
	

return FamilyPrestige
00
local Role_Title = {}
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local GameConst = require("app.models.game.GameConst")

-- 玩家称号
function Role_Title:getChengHaoColorName()
	local currBasicTitle = self:getTitleSystem():getCurrBasicTitle()
	local titleType = currBasicTitle:getType()

	if titleType == RoleTitleConst.BasicTitleType.Family or titleType == RoleTitleConst.BasicTitleType.JiangHu or titleType == RoleTitleConst.BasicTitleType.YouXia then
		self:updateNormalChengHao()
	end

	return currBasicTitle:getColorName()
end

function Role_Title:initChengHao()
	local listData = assert(clone(RoleTitleResManager:getNormalTitle()))
	if not listData then
		return
	end

	local function initchengHaoDesc(tab)
		local list =
		{
			sex = "男",
			title = "普通百姓",
			lv = 0,
			id = 0
		}
		if MapIsEmpty(tab) then
			return list
		end
		tab.lv = tab.number
		tab.zhengqi = tab.shen
		-- NEEDTODO 后面加一个颜色DWT
		tab.title = tostring(tab.color).."【"..tostring(tab.title).."】"
		tab.id = tab.id
		return Helper:tableCover(list, tab)
	end

	if not self.chengHaoDesc then
		self.chengHaoDesc = {}
	end
	for k,v in pairs(listData) do
		table.insert(self.chengHaoDesc, initchengHaoDesc(v))
	end
end

function Role_Title:getTouXian()
	if self:getFamilyId() == "youxia" then
		return "江湖浪人    "
	elseif self:getFamilyId() == "seclusion" then
		return GameConst:getDefaultValue("seclusion_family_touxian")
	elseif self:getFamilyId() == "guanfu" then
		local lv = self:getFamilyLevel()
		if lv == 2 then
			return " 崇武卫副统领 "
		elseif lv == 3 then
			return " 捕风密探 "
		elseif lv == 4 then
			return " 京兆捕快 "
		else
			return tostring(self:getFamilyName()).."第"..Helper:numberCast(lv).."代弟子 "
		end
	else
		local lv = self:getFamilyLevel()
		return tostring(self:getFamilyName()).."第"..Helper:numberCast(lv).."代弟子 "
	end
end

function Role_Title:getExtraTitle()
	return self:getAttr("titles").extraTitle
end

function Role_Title:setExtraTitle(extraTitle)
	self:getAttr("titles").extraTitle = extraTitle
end

function Role_Title:getTitleSystem()
	return self._titleSystem
end

function Role_Title:getBasicTitleData()
	return self.basicTitleData
end

--是否拥有新称号
function Role_Title:hasBasicTitle(titleId)
	return self:getTitleSystem():hasBasicTitle(titleId)
end

--获取角色所有新称号
function Role_Title:getRoleBasicTitleList()
	return self:getTitleSystem():getRoleBasicTitleList()
end

--获取角色身上某个称号
function Role_Title:getBasicTitle(titleId)
    return self:getTitleSystem():getBasicTitle(titleId)
end

--使用新称号
function Role_Title:useBasicTitle(titleId)
	self:getTitleSystem():useBasicTitle(titleId)
end

--添加新称号
function Role_Title:addBasicTitle(titleId)
    self:getTitleSystem():addBasicTitle(titleId)
end

--删除新称号
function Role_Title:deleteBasicTitle(titleId)
    self:getTitleSystem():deleteBasicTitle(titleId)
end

--获取当前称号
function Role_Title:getCurrBasicTitle()
	return self:getTitleSystem():getCurrBasicTitle()
end

function Role_Title:updateRoleTitle()
	self:updateNormalChengHao()
	self:updateYueKaChengHao()
	self:updateOfficialChengHao()
end

function Role_Title:getConditionMatchNormalChengHaoList()
	local list = {}

	if not self.chengHaoDesc then
		self:initChengHao()
	end

	if not self.chengHaoDesc then
		return list
	end

	local zhengQi = self.zhengqi
	local flag = true
	--判断正气值正负
	if zhengQi < 0 then
		flag = false
	end

	local family = self:getFamily()
	local roleFamilySkillId = family:getFamilySkill()
	local roleFamilySkill = self:getSkill(roleFamilySkillId)
	local roleFamilySkillLv = self:getSkillLv(roleFamilySkillId)
	local isFamily = self:hasFamily()
	local familyId = self:getFamilyId()

	for k,v in pairs(self.chengHaoDesc) do
		local isTrue = false
		
		if v.sex == self.sex then 
			if isFamily == true then
				if v.family and string.find(v.family, familyId) ~= nil then
					if roleFamilySkill then
						if v.skilllv and roleFamilySkillLv and roleFamilySkillLv >= v.skilllv then
							isTrue = true
						end
					elseif v.skilllv == 1 then
						isTrue = true
					end
				end
			end
			
			if isFamily == false then
				if v.family == familyId then
					if type(v.exp) == "number" and self.exp >= v.exp then
						isTrue = true
					end
				end
			end

			if v.family == nil then
				if v.zhengqi == nil then
					isTrue = true
				else
					if flag then
						if tonumber(zhengQi) >= tonumber(v.zhengqi) and tonumber(v.zhengqi) > 0 then
							isTrue = true
						end
					else
						if tonumber(zhengQi) <= tonumber(v.zhengqi) and tonumber(v.zhengqi) < 0 then
							isTrue = true
						end
					end
				end
			end
		end

		if isTrue then
			table.insert(list, v)
		end
	end

	--根据称号等级排序
	table.sort(list, function(a, b)
		return a.lv < b.lv
	end)

	return list
end

function Role_Title:getConditionMatchOfficialChengHaoList(officialType, officialAchievement)
    local officialChengHao = assert(clone(RoleTitleResManager:getOfficialTitle()))
	local list = {}

	for type, titles in pairs(officialChengHao) do
		if type == officialType then
			for __, title in ipairs(titles) do
				local isTrue = false
	
				if officialAchievement >= title.value and officialAchievement >= 0 and title.value >= 0 then
					isTrue = true
				elseif officialAchievement <= title.value and officialAchievement < 0 and title.value < 0 then
					isTrue = true
				end
	
				if isTrue then
					table.insert(list, title)
				end
			end
		end
	end

	table.sort(list, function(a, b)
		return a.lv < b.lv 
	end)

	return list
end

function Role_Title:updateNormalChengHao()
	if not self.chengHaoDesc then
		self:initChengHao()
	end

	if not self.chengHaoDesc then
		return
	end

	local zhengQi = self.zhengqi
	local flag = true
	--判断正气值正负
	if zhengQi < 0 then
		flag = false
	end

	local family = self:getFamily()
	local roleFamilySkillId = family:getFamilySkill()
	local roleFamilySkill = self:getSkill(roleFamilySkillId)
	local roleFamilySkillLv = self:getSkillLv(roleFamilySkillId)
	local isFamily = self:hasFamily()
	local familyId = self:getFamilyId()

	for k,v in pairs(self.chengHaoDesc) do
		local isTrue = false
		
		if v.sex == self.sex then 
			if isFamily == true then
				if v.family and string.find(v.family, familyId) ~= nil then
					if roleFamilySkill then
						if v.skilllv and roleFamilySkillLv and roleFamilySkillLv >= v.skilllv then
							isTrue = true
						end
					elseif v.skilllv == 1 then
						isTrue = true
					end
				end
			end
			
			if isFamily == false then
				if v.family == familyId then
					if type(v.exp) == "number" and self.exp >= v.exp then
						isTrue = true
					end
				end
			end

			if v.family == nil then
				if v.zhengqi == nil then
					isTrue = true
				else
					if flag then
						if tonumber(zhengQi) >= tonumber(v.zhengqi) and tonumber(v.zhengqi) > 0 then
							isTrue = true
						end
					else
						if tonumber(zhengQi) <= tonumber(v.zhengqi) and tonumber(v.zhengqi) < 0 then
							isTrue = true
						end
					end
				end
			end
		end

		if isTrue == true and self:hasBasicTitle(v.basicTitleId) == false then
			self:addBasicTitle(v.basicTitleId)
		elseif isTrue == false and self:hasBasicTitle(v.basicTitleId) == true then
			self:deleteBasicTitle(v.basicTitleId)
		end
	end
end

function Role_Title:updateYueKaChengHao()
	local yueKaBasicId = RoleTitleConst.SpecialBasicTitleId.YueKa
	local isTrue = self:hasBasicTitle(yueKaBasicId)

	if isTrue == false and self:yueKaIsValid() == true then
		self:addBasicTitle(yueKaBasicId)
	elseif isTrue == true and self:yueKaIsValid() == false then
		self:deleteBasicTitle(yueKaBasicId)
	end
end

function Role_Title:updateOfficialChengHao()
	local officialType = self:getAttr("officialType")
	local value = self:getAttr("officialAchievement")

    local officialChengHao = assert(clone(RoleTitleResManager:getOfficialTitle()))

	for type, titles in pairs(officialChengHao) do
		if type == officialType then
			for __, title in ipairs(titles) do
				local isTrue = false
	
				if value >= title.value and value >= 0 and title.value >= 0 then
					isTrue = true
				elseif value <= title.value and value < 0 and title.value < 0 then
					isTrue = true
				end
	
				if isTrue == true and self:hasBasicTitle(title.basicTitleId) == false then
					self:addBasicTitle(title.basicTitleId)
				elseif isTrue == false and self:hasBasicTitle(title.basicTitleId) == true then
					self:deleteBasicTitle(title.basicTitleId)
				end
			end
		else
			for __, title in ipairs(titles) do
				if self:hasBasicTitle(title.basicTitleId) then
					self:deleteBasicTitle(title.basicTitleId)
				end
			end
		end 
	end
end

return Role_Title00000000000000
local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_ActiveZhaoBook = {}

--固定一本添加500熟练度
local One_Book_Exp = 500

function RoleUseItem_ActiveZhaoBook:__doUseItem()
    local item = self._item
	local role = self._role
	local itemCount = self._useNum

	if item.zhaoId ~= nil then
		local zhao = Skill:getActiveZhao(item.zhaoId)
		-- 是否已经学会技能
		if role:getSkillZhao(item.zhaoId) ~= nil then
			local currInt = role:getFinalAttr("currInt")

			local exp = 0

			-- 悟性加成额外经验值
			local extraExp = 0
			
			for i = 1,itemCount do
				exp = exp + One_Book_Exp
				extraExp = extraExp + self:__zhaoAddExp(currInt)
			end

			local ret, addExp = role:checkSkillZhaoCanUp(item.zhaoId, exp + extraExp)
			if addExp < 500 then -- add by XiaoZhiWei 2017/04/11 11:55:05 修改为不能获得满额500经验则不能吃
				self:__popText("研习后超出最大熟练度，无法研习")
				return
			end

			local zhaoLv = role:getSkillZhaoLv(zhao:getId()) -- 增加经验之前的招式等级
			role:addSkillZhaoExp(item.zhaoId, addExp)
			role:addItemCount(item.id, - itemCount)
			
			local richText = "你通过研习秘籍残本将『" .. tostring(zhao:getName()) .. "』熟练度提升了" .. tostring(exp) .. "！"
			if extraExp > 0 then
				richText = richText .. "你在研习时突然顿悟，额外再获得" .. extraExp .. "点熟练度！"
			end
			self:__richPrint(richText)

			role:checkZhaoIsLevelUp(zhao:getId(), zhaoLv)
		else
			local ret, addExp = role:checkSkillZhaoCanUp(item.zhaoId, role:conversionZhaoExpAndLv("exp", 1, role:getSkillZhaoPotEfficiency(item.zhaoId)))
			if addExp <= 0 then
				local skillName = Skill:getSkill(item.skillid).name
				self:__popText("需要先习得"..skillName)
				return
			end

			-- 只有招式的学习类型是书页习得类型,才可以使用书页学习,否则只能使用
			if zhao.learnMethod == 0 then
				local text = zhao:getLearnZhaoConditionText(role)
				if text ~= nil and text ~= "" then
					self:__popText(text.."方能研习此招式")
				else
					print("检查主动技能资源配表格式")
				end
				return
			end

			local page = self:__getSkillPage()
			-- 检测是否集齐所有书页
			if page ~= nil then
				local flag, useCount = false, 1
				for k, v in pairs(page) do
					if v.name == item.id then
						if role:getZhaoShuXiang(v.name) ~= nil and role:getZhaoShuXiang(v.name).count >= v.needCount then
							flag = true
							useCount = v.needCount
						else
							self:__popText("秘籍残页不足！")
						end
						break
					end
				end

				--集齐书页学习该技能
				if flag then
					-- 学习技能经验 按照自定义经验增加，没有默认1
					role:addSkillZhaoLv(item.zhaoId, 1)
					role:addItemCount(item.id, - useCount)
					self:__richPrint( "你通过研习秘籍残本悟得特殊招式『" .. tostring(zhao:getName()) .. "』！")
					role:updateActiveZhaoStatus() -- add by XiaoZhiWei 2017/04/02 00:24:13 及时更新招式准备状态
				end
			end
		end
		self:__onUseAft()
	else
		if DEBUG_MODE == 1 then
			assert(nil, "改书页的招式ID未填写,请补充完善")
		end
	end
    return true
end

function RoleUseItem_ActiveZhaoBook:__getSkillPage()
	local item = self._item
	local page

	if item.zhaoId then
		local bookSkills = require("app.models.book.BookSkills")
		local activeZhao = clone(bookSkills:getBookActiveZhao())
		if item.skillid == nil then
			item.skillid = Skill:getSkillIdByZhaoId(item.zhaoId)
		end
		-- 寻找对应技能
		for id, skill in pairs(activeZhao) do
			if skill.skillId == item.skillid then
				page = skill.page
				break
			end
		end
		if page == nil then
			print("没有该招式 " .. item.zhaoId)
		end
	end
	return page
end

function RoleUseItem_ActiveZhaoBook:__zhaoAddExp(currInt)
	local percent = math.random(1, 100)
	local extraExp = 0
	if percent <= (math.max(currInt/500,0.05) * 100) then
		extraExp = math.floor((currInt/5)+0.5 * math.random(1,currInt/2))
	end
	return extraExp
end

return NewClass("RoleUseItem_ActiveZhaoBook", {AbstractUseItem}, RoleUseItem_ActiveZhaoBook)
000
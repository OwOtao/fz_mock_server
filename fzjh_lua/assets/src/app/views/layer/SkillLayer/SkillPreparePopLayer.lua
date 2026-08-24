local Resource = require("app.Resource")
local Skill = require("app.models.skill.Skill")
local SkillPreparePopLayer = class("SkillPreparePopLayer", require("app.views.base.BaseLayer"))


local prepareTypes = 
{
	"基本拳脚",	-- 拳脚
	"基本内功", 	-- 内功
	"基本轻功",	-- 轻功
	"基本招架",	-- 招架
	"基本剑法",    	-- 剑法
	"基本刀法",    	-- 刀法
	"基本棍法",   	-- 棍法
	"基本暗器",    	-- 暗器	
	"基本鞭法",    	-- 鞭法
	"基本双持",	-- 双持	
	"基本乐器",  --乐器
}

function SkillPreparePopLayer:create()
	local p = SkillPreparePopLayer:new()
	p:init()
	return p
end

function SkillPreparePopLayer:init()
	self._UI = require("Layer/SkillUI/SkillPreparePopUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点

	self.Panel_back:releaseFunc(
		function()
			self:hideLayer()
		end
		)

	self:hide() -- 隐藏自身	
end

-- 获取角色技能准备列表
function SkillPreparePopLayer:getRoleSkills(role, skillType, skillPrepareid)
	local prepare = role:getPrepareSkill(skillPrepareid)
	local list = {}
	local zuoYouHB = role:isHaveImprintingId("zuoyouhuboyin")

	if skillPrepareid == "quanjiao2" and zuoYouHB == false then
		prepare = role:getPrepareSkill("quanjiao1")
		if not prepare then
			return
		end
		local skill = Skill:getSkill(prepare)
		if skill.combob and string.len(skill.combob) >= 1 then
			local cbRoleSkill = role:getSkill(skill.combob)
			if not cbRoleSkill then
				return
			end
			local cbSkill = Skill:getSkill(skill.combob)
			table.insert(
				list,
				{
					id = cbSkill.id,
					name = cbSkill.name,
					stageDsc = cbSkill:getStageDsc(role),
					expDsc = role:getSkillLvWithRoleLvLimit(cbRoleSkill.id) .. "级"
				}
			)
		end
	else
		local skills = role:getSkills()
		for k, roleSkill in pairs(skills) do
			local skill = Skill:getSkill(roleSkill.id)
			if skill.type ~= SKILL_TYPE_BASE and skill:canPrepareType(skillType) and skill.id ~= prepare then
				-- add by XiaoZhiWei 2017/07/06 11:13:42 如果是拳脚2类型,并且当前武功已经准备到拳脚1 则不需要当前技能在列表中显示
				if skillPrepareid == "quanjiao2" and skill.id == role:getPrepareSkillIdByType("quanjiao1") then
				else
					table.insert(
						list,
						{
							id = skill.id,
							name = skill.name,
							stageDsc = skill:getStageDsc(role),
							expDsc = role:getSkillLvWithRoleLvLimit(roleSkill.id).."级"
						}
					)
				end
			end
		end
	end
	return list
end

function SkillPreparePopLayer:setSkillType(role, skillType, skillPrepareid)
	self.ListView_area:removeAllItems()

	local canPrepareList = Helper:getDef(self:getRoleSkills(role, skillType, skillPrepareid),{})

	--@desc 取消装备按钮
	table.insert(canPrepareList, {
		id = "cancelPrepare",
		name = "取消装备",
	})

	self.ListView_area:setSwallowTouches(false)

	local roleItemNum = #canPrepareList
    local listSize = self.ListView_area:getContentSize()
    local itemSize = Resource:getUIByName("Panel_skillPreparePopItemUI"):getContentSize()
    local itemsMargin = self.ListView_area:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height/(itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

    self.ListView_area:setItemHeight(itemSize.height)

    self.ListView_area:setItemInitFunc(function(item,prepareInfo)
        self:__initSkillPreparePanelInfo(item,prepareInfo,role,skillType, skillPrepareid)
    end)

    self.ListView_area:setItemCreateFunc(function()
        return self:__createItem()
    end)

    self.ListView_area:showListView(canPrepareList,itemMaxCount)

	if isSchedule then
        self.ListView_area:jumpToTop()

        local isTrue = self.ListView_area:refreshReuseItems()
		while isTrue do
			isTrue = self.ListView_area:refreshReuseItems()
		end

        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end

        self.listViewSchedule = self:schedule(function()
            self.ListView_area:refreshReuseItems()
        end)
    end
end

function SkillPreparePopLayer:__initSkillPreparePanelInfo(item,prepareInfo,role, skillType, skillPrepareid)
	if prepareInfo.id == "cancelPrepare" then
		item.Text_name:setTextColor({r = 255, g = 255, b = 255})
		item.Text_name:setString(prepareInfo.name)
		item.Text_name:move(415, 30)
		item.Text_dsc:setString("")
		item.Text_expDsc:setString("")
		
		item:releaseFunc(
			function()
				local prepare = role:getPrepareSkill(skillPrepareid)
				if not prepare then
					self:hideLayer()
					return
				end
				local skill = Skill:getSkill(prepare)
				if not skill then
					return
				end

				if role:prepareSkill(skillPrepareid, nil) then
					RichPrint("main", "你取消了["..tostring(skill.name).."]的准备。")
				end

				self.skillPrepareLayer:refreshPrepareSkills()
				self:hideLayer()
			end
		)
	else
		item.Text_name:setTextColor({r = 255, g = 255, b = 255})
		item.Text_name:setString(prepareInfo.name)
		item.Text_name:move(5.5, 17)
		item.Text_dsc:setString(prepareInfo.stageDsc)
		item.Text_expDsc:setString(prepareInfo.expDsc)
		
		item:releaseFunc(
			function()
				if skillPrepareid ~= "quanjiao2" and role:prepareSkill(skillPrepareid, prepareInfo.id) then
					RichPrint("main", "你决定使用["..tostring(prepareInfo.name).."]做为你的[HIW"..tostring(prepareTypes[skillType]).."NOR]")
				elseif skillPrepareid == "quanjiao2" then
					role:prepareSkill(skillPrepareid, prepareInfo.id)
				end
	
				self.skillPrepareLayer:refreshPrepareSkills()
				self:hideLayer()
			end
		)
	end

end

function SkillPreparePopLayer:__createItem()
	local item = Resource:getUIByName("Panel_skillPreparePopItemUI")
	Helper:convertUI(item)

	return item
end

function SkillPreparePopLayer:hideLayer()
	PopupLayerController:hideLayer("SkillPreparePopLayer")
	self:hideWithFade(true, 100)
end

Helper:classDefNodeGetInstance(SkillPreparePopLayer)

return SkillPreparePopLayer00000000000
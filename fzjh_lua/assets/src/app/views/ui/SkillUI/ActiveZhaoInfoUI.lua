local Resource = require("app.Resource")

local ActiveZhaoInfoUI = class("ActiveZhaoInfoUI", LayerEx)

function ActiveZhaoInfoUI:create()
	local p = ActiveZhaoInfoUI:new()
	p:init()
	return p
end

function ActiveZhaoInfoUI:init()
	self._round = require("Layer/SkillUI/ActiveZhaoInfoUI.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点
	self:setPanelBack()

	self.Text_learnCondition_use:setString("使用条件")

	-- self.Text_buttonName:setString("学\n习")
	-- self.Button_learn:setVisible(false)
	self.Text_up_condition_use:setTextColor(cc.c4b(208, 208, 208, 255))

	self.ListView_condition_use:setScrollBarEnabled(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 18:23:12
-- @desc 设置所有的招式信息
function ActiveZhaoInfoUI:showAllInfo(name, exp, needExp, level, desc, conditionList,role,zhaoId)
	self:show()

	if name == "恢复" then
		self:showHuiFuPanel(name, desc, conditionList)
		return
	end

	exp = Helper:getDef(exp, 0)
	if exp <= 0 then
		self:showLearnPanel(name, exp, level, desc, conditionList)
	else
		self:showUsePanel(name, exp, needExp, level, desc, conditionList,role,zhaoId)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/14 17:59:12
-- @desc 回复武功的面板
function ActiveZhaoInfoUI:showHuiFuPanel(name, desc, conditionList)
	self.Panel_learn:setVisible(true)
	self.Panel_use:setVisible(false)
	self.Text_learnCondition_learn:setString("使用条件")
	self:setTextZhaoName(self.Text_zhaoName_learn, name)
	-- self:setTextZhaoDesc(self.Text_zhaoDesc_learn, desc)
	self:setTextUse(self.Text_zhaoDesc_learn,desc)
	self.Text_zhaoLevel_learn:setString("已习得")
	self:setConditonDescList(self.ListView_condition_learn, conditionList)
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/02 15:28:47
-- @desc 学习条件面板
function ActiveZhaoInfoUI:showLearnPanel(name, exp, level, desc, conditionList)
	self.Panel_learn:setVisible(true)
	self.Panel_use:setVisible(false)
	self.Text_learnCondition_learn:setString("学习条件")
	self:setTextZhaoName(self.Text_zhaoName_learn, name)
	-- self:setTextZhaoDesc(self.Text_zhaoDesc_learn, desc)
	self:setTextUse(self.Text_zhaoDesc_learn,desc)
	self:setTextZhaoLevel(self.Text_zhaoLevel_learn, exp, level)
	self:setConditonDescList(self.ListView_condition_learn, conditionList)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/02 17:39:43
-- @desc 使用条件面板
function ActiveZhaoInfoUI:showUsePanel(name, exp, needExp, level, desc, conditionList,role,zhaoId)
	self.Panel_learn:setVisible(false)
	self.Panel_use:setVisible(true)
	self:setTextZhaoName(self.Text_zhaoName_use, name)
	-- self:setTextZhaoDesc(self.Text_zhaoDesc_use, desc)
	self:setTextUse(self.Text_zhaoDesc_use,desc)
	self:setTextZhaoLevel(self.Text_zhaoLevel_use, exp, level)
	self:setConditonDescList(self.ListView_condition_use, conditionList)

	--@desc 梦境与非梦境角色展示文本规则不一样
	if role.isDreamRole == true then
		self:setDreamRoleSkillLevelText(self.Text_up_condition_use, level,role)
	else
		self:setTextNeedExp(self.Text_up_condition_use, needExp, level,role,zhaoId)
	end
end

function ActiveZhaoInfoUI:setTextUse(ui,desc)
	self:initRichText(ui)

	if not desc then
		desc = "这是一个特殊招式的描述"
	end

    local textColor = cc.c3b(123, 123, 123)
    self.RichText_print:pushBackText(desc, textColor, 255, Resource:getFontPath("default"),38)
    self:delayFunc(0.1,function ()
		self.RichText_print:jumpToTop()
	end)
end

function ActiveZhaoInfoUI:initRichText(ui)
	if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

    local x, y = ui:getPosition()
    local size = ui:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    ui:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
    self.RichText_print:setBounceEnabled(false)
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 18:02:22
-- @desc 设置招式名称
function ActiveZhaoInfoUI:setTextZhaoName(ui, name)
	ui:setString(Helper:getDef(name, "特殊招式"))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 18:03:22
-- @desc 设置招式等级
function ActiveZhaoInfoUI:setTextZhaoLevel(ui, exp, level)
	local text = ""
	exp = Helper:getDef(exp, 0)
	level = Helper:getDef(level, 0)
	if exp <= 0 or level <= 0 then
		if self.Text_zhaoName_learn:getString() == "回复" then
			text = "已习得"
		else
			text = "未习得"	
		end
	else
		-- text = tostring(Helper:mathFloor(exp)).."/"..tostring(Helper:getRange(Helper:mathFloor(level), 1)).."重"
		text = tostring(level).."重"
	end
	ui:setString(text)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 18:05:11
-- @desc 设置招式描述
-- function ActiveZhaoInfoUI:setTextZhaoDesc(ui, desc)
-- 	ui:setString(Helper:getDef(desc, "这是一个特殊招式的描述"))
-- end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/02 18:23:26
-- @desc 设置升级所需经验值
function ActiveZhaoInfoUI:setTextNeedExp(ui, needExp, level,role,zhaoId)
	local expText = "当前熟练度为："..Helper:mathFloor(role:getSkillZhaoExp(zhaoId)).."/"..role:getZhaoExpLimit(zhaoId,role:getZhaoLvLimit(zhaoId))
	local maxLevel = role:getSkillBreakThroughSystem():getZhaoMaxLevel(zhaoId)

	-- add by XiaoZhiWei 2017/04/14 10:08:02 武功招式重数受等级影响调整
	local skillLv = Helper:mathFloor(level+ 1) * 100
	if level < 5 then
		skillLv = Helper:mathFloor(level+ 1) * 100
	elseif level < 6 then
		skillLv = 540
	elseif level < 7 then
		skillLv = 560
	elseif level < 8 then
		skillLv = 580
	elseif level < 9 then
		skillLv = 600
	elseif level < maxLevel then
		skillLv = role:getSkillBreakThroughSystem():getZhaoBreDataByZhaoIdAndZhaoLv(zhaoId,Helper:mathFloor(math.min(level+1,maxLevel))).skill
	end

	local text = ""
	if level >= maxLevel then
		text = expText.."\n您的招式已达最高重数\n\n每天使用此招式最多可获得40熟练度"
	elseif level >= role:getZhaoLvLimit(zhaoId) and level >= 9 then
		text = expText.."\n目前已达最高重数，可尝试进行技能突破。\n\n每天使用此招式最多可获得40熟练度"
	else
		if needExp > 0 then
			text = expText.."\n提升至下一重还需要"..tostring(math.ceil(needExp)).."熟练度\n所属武功达到"..tostring(skillLv).."级\n\n每天使用此招式最多可获得40熟练度"
		else
			text = expText.."\n所需熟练度已达成\n所属武功达到"..tostring(skillLv).."级\n\n每天使用此招式最多可获得40熟练度"
		end
	end

	ui:setString(text)
end

-----------------------------------------------------------------------------------------------------------
-- @desc 设置梦境人物武功重数展示文本
function ActiveZhaoInfoUI:setDreamRoleSkillLevelText(ui,level,role)
	local text = ""
	local maxLv = role:getZhaoLvLimit()
	if level < maxLv then
		if not role._isFondDrRole then
			text = "\n决斗胜利有概率提升准备武学的主动技能重数。"
		end
	else
		text = "\n技能已达最高重数。"
	end

	ui:setString(text)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 18:36:38
-- @desc 设置背景点击
function ActiveZhaoInfoUI:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/24 10:51:52
-- @desc 生成文本列表
function ActiveZhaoInfoUI:setConditonDescList(ui, list)
	ui:removeAllItems()
	if MapIsEmpty(list) == true then
		return
	else
		local tab = {}
		for i,condition in ipairs(list) do
			table.insert(tab, condition)
			local panel = self:createTwoRow(tab)
			-- if i == #list then
			-- 	for i=1,3 do
			-- 		panel = self:createTwoRow(tab)
			-- 		self.ListView_condition:pushBackCustomItem(panel)
			-- 	end
			-- 	return
			-- end
			tab = {}
			if panel ~= nil then
				ui:pushBackCustomItem(panel)
			end
		end		
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/24 11:11:06
-- @desc 创建双列栏目
function ActiveZhaoInfoUI:createTwoRow(tabs)
	if MapIsEmpty(tabs) == true then
		return
	end
	local panel = self.Panel_row:clone()
	Helper:convertUI(panel)

	local color = {"HIW","HIY","HIG","HIC","NOR"}
	for j,v in pairs(color) do
	    tabs[1] = string.gsub(tabs[1], color[j], "")
	end

	panel.Text_cond_desc:setString(Helper:getDef(tabs[1], ""))
	panel.Text_cond_desc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	panel:setVisible(true)
	panel.Text_cond_desc:setVisible(true)
	return panel
end

Helper:classDefNodeGetInstance(ActiveZhaoInfoUI)
return ActiveZhaoInfoUI00000000000000
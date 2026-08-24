local KnowledgeSelectLayer = class("KnowledgeSelectLayer", cc.Layer)
local SelectButtonModel = require("app.models.task.teacherGuaJiTask.SelectButtonModel")
local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")

function KnowledgeSelectLayer:create()
	local p = KnowledgeSelectLayer:new()
	p:init()
	return p
end

function KnowledgeSelectLayer:init()
	self._round = require("Layer/TeacherTask/TeacherGuaJiTask/KnowledgeSelectUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)

	self:setButtonBack()
	self:setTitle()

    self.Panel_bg:releaseFunc(function()
		if self.Is_show == false then
			self:itemDescHide()
		end
	end)

    self.task = nil
end

local ButtonPos = {
    [1] = {
        x = 162,
        y = 221
    },
    [2] = {
        x = 500,
        y = 221
    },
    [3] = {
        x = 838,
        y = 221
    },
    [4] = {
        x = 162,
        y = 91
    },
    [5] = {
        x = 500,
        y = 91
    },
    [6] = {
        x = 838,
        y = 91
    }
}
function KnowledgeSelectLayer:showLayer(task)
    self.task = task
	self:initTaskList()
	self:show()
end

function KnowledgeSelectLayer:setButtonBack(func)
	self.Button_back:releaseFunc(function()
		PopupLayerController:hideLayer("KnowledgeSelectLayer", function(layer)
            if func then
                func()
            end
			self:hide()
		end)
	end)
end

function KnowledgeSelectLayer:setTitle()
	self.Text_title:setString("知识选择")
end

function KnowledgeSelectLayer:initTaskList()
    local role = User:getRole()
    local skillList = role:getSkills()
    local zsList = {}
    local dowmList = {}
    for k,v in pairs(skillList) do
        local skill = Skill:getSkill(k)
        --符合规则的技能加入列表
        if skill.type == SKILL_TYPE_DUSHU or skill.type == SKILL_TYPE_SPECIAL or skill.type == SKILL_TYPE_HUIFU or skill.type == SKILL_TYPE_DUNDI or skill.type == SKILL_TYPE_ZHISHI then
            -- 待规则全部给出 todo:选择的知识保存在task里面，如果已经保存的，需要把select状态设置为1
            local knowlegeList = TeacherGuaJiTaskUtil:getTaskKnowlege(self.task)
            
            if knowlegeList[skill.id] == true then
                table.insert(zsList,{skillId = skill.id,select = 1})
                table.insert(dowmList,{id = skill.id,skillId = skill.id})
            else
                table.insert(zsList,{skillId = skill.id,select = 0})
            end 
        end
    end

    SelectButtonModel:initUpList(zsList)
    SelectButtonModel:initDownList(dowmList)

    self:refreshUpList()
    self:refreshDownList()
end

function KnowledgeSelectLayer:createUpPanel(data)
	local panel = self.Panel_item:clone()
    Helper:convertUIByParent(panel)
    panel.Panel_ButtonDsc.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    panel.Button_1.Text_buttonName:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
    
    local role = User:getRole()
    local skillId = data.skillId
    local skill = Skill:getSkill(skillId)
    local isSelect = data.select
    local skillStageDsc = skill:getStageDsc(role)

	panel.Panel_ButtonDsc.Text_name:setString(skill.name)
    panel.Panel_ButtonDsc:releaseFunc(function()
        self:setPanelItemDesc(skill,skillStageDsc)
        self:itemDescShow()
    end)
	panel.Text_stateDsc:setString(skillStageDsc)

    if isSelect == 0 then
        panel.Button_1:setVisible(true)
        panel.Text_select:setVisible(false)
    else
        panel.Button_1:setVisible(false)
        panel.Text_select:setVisible(true)
    end

	panel.Button_1:releaseFunc(function()
        local downList = SelectButtonModel:getDownList()
        local dowmButtonNum = #downList
        if dowmButtonNum >= 3 then
            PopText("可选择的知识已达上限")
            return
        end

        local list = SelectButtonModel:getUpList()
        for i,v in ipairs(list) do
            if v.skillId == skillId then
                v.select = 1
            end
        end
        --保存选择的知识
        local knowlegeList = TeacherGuaJiTaskUtil:getTaskKnowlege(self.task)
        knowlegeList[skillId] = true
        TeacherGuaJiTaskUtil:setTaskKnowlege(self.task,knowlegeList)

        SelectButtonModel:addButtonToDownList({id = skillId,skillId = skillId})
        self:refreshUpList()
        self:refreshDownList()
    end)
	return panel
end

function KnowledgeSelectLayer:createDowmButton(data)
    local button = self.Panel_item.Button_1:clone()
    Helper:convertUIByParent(button)
    button.Text_buttonName:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
    
    local skillId = data.skillId
    local skill = Skill:getSkill(skillId)
    button.Text_buttonName:setString(skill.name)
    button:releaseFunc(function()
        local list = SelectButtonModel:getUpList()
        for i,v in ipairs(list) do
            if v.skillId == skillId then
                v.select = 0
            end
        end

        --删除选择的知识
        local knowlegeList = TeacherGuaJiTaskUtil:getTaskKnowlege(self.task)
        knowlegeList[skillId] = nil

        SelectButtonModel:removeButtonFromDownList(data)
        self:refreshUpList()
        self:refreshDownList()
    end)

    return button
end

--刷新上方列表
function KnowledgeSelectLayer:refreshUpList()
    self.ListView_TaskList:removeAllItems()
    local list = SelectButtonModel:getUpList()
    if MapIsEmpty(list) then
        self.Text_none:setVisible(true)
        self.Text_none:setString("你没有可供选择的知识类技能")
        return
    else
        self.Text_none:setVisible(false)
    end
    
    for i,v in ipairs(list) do
        
        local panel = self:createUpPanel(v)
        
        self.ListView_TaskList:pushBackCustomItem(panel)
    end

end

--刷新下方列表
function KnowledgeSelectLayer:refreshDownList()
    self.Panel_ButtonList:removeAllChildren()
    local list = SelectButtonModel:getDownList()
    if MapIsEmpty(list) then
        return
    end
    
    for i, v in ipairs(list) do
        local button = self:createDowmButton(v)
        button:addTo(self.Panel_ButtonList)
        button:setPosition(ButtonPos[i].x,ButtonPos[i].y)
    end
end

---点击知识
function KnowledgeSelectLayer:setPanelItemDesc(skill,skillStageDsc)
    local role = User:getRole()
	-- 书籍名字
	self.Panel_itemDesc.Image_back.Panel_title.Text_name:setString(skill.name)
	-- 等级描述
	self.Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(skillStageDsc)
	-- 书籍描述
    local skillDsc = skill.dsc
    --去除技能描述里面的颜色字符
    for _, v in pairs(GetColorList()) do
		local s, e = string.find(skillDsc, v.id)
		if s ~= nil and e ~= nil then
		    skillDsc = string.gsub(skillDsc,v.id,"")
		end
	end
	self.Panel_itemDesc.Image_back.TextField_desc:setString(skillDsc)
	-- 技能等级
    local skillLv = role:getSkillLv(skill.id)
    if skill:checkIsSpecialZhiShiSkill() then
		skillLv = role:getSpecialZhiShiSkillLv(skill.id)
    end
	self.Panel_itemDesc.Image_back.Text_level:setString(math.floor(role:getSkillExp(skill.id)) .. "/" .. skillLv .. "级")

end

-- 物品描述显示
function KnowledgeSelectLayer:itemDescShow()
	self.Panel_itemDesc:setTouchEnabled(true)
	self.Panel_bg:setVisible(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	self.Panel_bg:setVisible(true)
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(300, 1420))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(300.00, 1220.00)),
			cc.FadeIn:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
				self.Is_show = false
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
end

-- 物品描述隐藏
function KnowledgeSelectLayer:itemDescHide()
	self.Panel_itemDesc:setTouchEnabled(false)
	self.Panel_bg:setVisible(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	self.Panel_bg:setVisible(true)
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(300, 1220))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(300.00, 1420.00)),
			cc.FadeOut:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
				self.Panel_itemDesc:setVisible(false)
				self.Panel_bg:setVisible(false)
				self.Is_show = false
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
end

Helper:classDefNodeGetInstance(KnowledgeSelectLayer)
return KnowledgeSelectLayer0000000000000
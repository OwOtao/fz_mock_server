local GuaJiTaskPrepareLayer = class("GuaJiTaskPrepareLayer", cc.Layer)
local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")

function GuaJiTaskPrepareLayer:create()
	local p = GuaJiTaskPrepareLayer:new()
	p:init()
	return p
end

function GuaJiTaskPrepareLayer:init()
	self._round = require("Layer/TeacherTask/TeacherGuaJiTask/GuaJiTaskPrepareUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)

	self:setButtonBack()

end

function GuaJiTaskPrepareLayer:showLayer(task)
	self:show()
	self:setRewardText(task)
	self:setTitle(task)
	self:setTaskDsc(task)
	self:setChangeKnowledgeButton(task)
	self:setKnowledgeText(task)
	self:setKaiShiButton(task)
end

function GuaJiTaskPrepareLayer:setButtonBack()
	self.Button_back:releaseFunc(function()
		PopupLayerController:hideLayer("GuaJiTaskPrepareLayer", function(layer)
			self:hide()
		end)
	end)
end

function GuaJiTaskPrepareLayer:setTitle(task)
	local taskName = task.taskName
	self.Text_title:setString("任务:"..task.taskName)
end

--任务描述
function GuaJiTaskPrepareLayer:setTaskDsc(task)
	local textId = task.taskText1

	local taskText = TeacherGuaJiTaskUtil:getTextByTextId(textId)
	self.Text_dsc:setString(taskText)
end

--奖励描述文本
function GuaJiTaskPrepareLayer:setRewardText(task)
	local rewardText = task.showAward
	self.Text_2:setString(rewardText)
end

--准备的知识
function GuaJiTaskPrepareLayer:setKnowledgeText(task)
	local text = ""
	local knowlegeList = TeacherGuaJiTaskUtil:getTaskKnowlege(task)
    if not MapIsEmpty(knowlegeList) then
		for skillId,v in pairs(knowlegeList) do
			local skill = Skill:getSkill(skillId)
			if skill then
				if text ~= "" then
					text = text.."、".. skill.name
				else
					text = skill.name
				end
			end
		end
    end
	self.Text_4:setString(text)
	self.Text_4:setColor(cc.c3b(233,231,77))
end

--更改知识按钮
function GuaJiTaskPrepareLayer:setChangeKnowledgeButton(task)
    self.Button_Change:releaseFunc(function()
        PopupLayerController:showLayer("KnowledgeSelectLayer", function(layer)
            layer:showLayer(task)
			layer:setButtonBack(function()
				self:setKnowledgeText(task)
			end)
        end)
    end)
end

--开始任务按钮
function GuaJiTaskPrepareLayer:setKaiShiButton(task)
    self.Button_KaiShi:releaseFunc(function()
		--跳到呼朋引伴界面
		PopupLayerController:showLayer("HuPengYinBanLayer", function(layer)
            layer:showLayer(task)
        end)
		
    end)
end

Helper:classDefNodeGetInstance(GuaJiTaskPrepareLayer)
return GuaJiTaskPrepareLayer00000
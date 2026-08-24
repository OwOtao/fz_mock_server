local GuajiTaskDetailLayer = class("GuajiTaskDetailLayer", cc.Layer)
local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")

function GuajiTaskDetailLayer:create()
	local p = GuajiTaskDetailLayer:new()
	p:init()
	return p
end

function GuajiTaskDetailLayer:init()
	self._round = require("Layer/TeacherTask/TeacherGuaJiTask/GuaJiTaskDetailUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)

	self:setButtonBack()
    self:initRichText()
end

function GuajiTaskDetailLayer:initRichText()
	if self.rich_text ~= nil then
        self.rich_text:removeFromParent()
	end

	local x, y = self.Panel_print:getPosition()
    local size = self.Panel_print:getContentSize()

    self.rich_text = ExtRichTextScroll:create()

    self.Panel_print:getParent():addChild(self.rich_text)
    self.rich_text:move(cc.p(x, y))
    self.rich_text:setSize(size)
    self.rich_text:setAnchorPoint(cc.p(0.5, 0.5))
    self.rich_text:setDirection(kCCScrollViewDirectionVertical)
    self.rich_text:getRichText():setVerticalSpace(20)
end

function GuajiTaskDetailLayer:showLayer(task)
    self:setTitle(task)
    self:setTaskDsc(task)

	self:show()
end

function GuajiTaskDetailLayer:setTitle(task)
    local taskName = task.taskName
	self.Text_title:setString(taskName)
end

--任务描述
function GuajiTaskDetailLayer:setTaskDsc(task)
    self:initRichText()
    local taskTextId = task.taskText
    local taskText = TeacherGuaJiTaskUtil:getTextByTextId(taskTextId)
    
	local textColor = cc.c3b(208, 208, 208)

    self.rich_text:pushBackText(taskText, textColor, 255, Resource:getFontPath("default"), 48)
    self:delayFunc(0.2,function ()
		self.rich_text:jumpToTop()
	end)
end

function GuajiTaskDetailLayer:hideLayer()
    PopupLayerController:hideLayer("GuajiTaskDetailLayer", function(layer)
        self:hide()
    end)
end

--离开按钮
function GuajiTaskDetailLayer:setButtonBack()
	self.Button_cancel:releaseFunc(function()
		self:hideLayer()
	end)
end

--接受任务按钮
function GuajiTaskDetailLayer:setAcceptButton(func)
    self.Button_Accept:releaseFunc(function()
        --接受任务 检查是否 满足任务接取条件 改变任务状态，关闭界面
        if func then
            func()
        end
    end)
end

Helper:classDefNodeGetInstance(GuajiTaskDetailLayer)
return GuajiTaskDetailLayer0000
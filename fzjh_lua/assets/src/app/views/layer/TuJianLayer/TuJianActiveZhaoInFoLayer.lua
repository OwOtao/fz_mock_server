local Resource = require("app.Resource")

local TuJianActiveZhaoInFoLayer = class("TuJianActiveZhaoInFoLayer", LayerEx)

function TuJianActiveZhaoInFoLayer:create()
	local p = TuJianActiveZhaoInFoLayer:new()
	p:init()
	return p
end

function TuJianActiveZhaoInFoLayer:init()
	self._round = require("Layer/TuJianUI/tujianActiveZhaoInfoUI.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点
	self:setPanelBack()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 18:23:12
-- @desc 设置所有的招式信息
function TuJianActiveZhaoInFoLayer:showAllInfo(name, desc, LearnconditionList,UseConditonList)
	self:show()

    self:showLearnPanel(name, desc, LearnconditionList,UseConditonList)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/02 15:28:47
-- @desc 学习条件面板
function TuJianActiveZhaoInFoLayer:showLearnPanel(name, desc, LearnconditionList,UseConditonList)
	self:setTextZhaoName(self.Text_zhaoName_learn, name)
	self:setTextUse(self.Text_zhaoDesc_learn,desc)
	self:setConditonDescList(self.ListView_condition_learn, LearnconditionList)
    self:setConditonDescList(self.ListView_condition_use, UseConditonList)
end

function TuJianActiveZhaoInFoLayer:setTextUse(ui,desc)
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

function TuJianActiveZhaoInFoLayer:initRichText(ui)
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
function TuJianActiveZhaoInFoLayer:setTextZhaoName(ui, name)
	ui:setString(Helper:getDef(name, "特殊招式"))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 18:36:38
-- @desc 设置背景点击
function TuJianActiveZhaoInFoLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/24 10:51:52
-- @desc 生成文本列表
function TuJianActiveZhaoInFoLayer:setConditonDescList(ui, list)
	ui:removeAllItems()
	if MapIsEmpty(list) == true then
		return
	else
		local str = ""

		for i,condition in ipairs(list) do
			str = str..condition
			if i ~= #list then
				str = str.."\n"
			end
		end	
		
		local panel = self:createTextPanel(str)

		if panel ~= nil then
			ui:pushBackCustomItem(panel)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/24 11:11:06
-- @desc 创建双列栏目
function TuJianActiveZhaoInFoLayer:createTextPanel(str)
	local panel = self.Panel_row:clone()
	Helper:convertUI(panel)

	local color = {"HIW","HIY","HIG","HIC","NOR"}
	for j,v in pairs(color) do
	    str = string.gsub(str, color[j], "")
	end

	local width = panel:getSizeWidth()

    panel.Text_cond_desc:setTextAreaSize({width = width, height = 0})
    panel.Text_cond_desc:ignoreContentAdaptWithSize(true)
	panel.Text_cond_desc:setString(Helper:getDef(str, ""))
	panel.Text_cond_desc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	
	local contentSize = panel.Text_cond_desc:getAutoRenderSize()
	panel.Text_cond_desc:setVisible(true)
	panel:setVisible(true)
	panel:setContentSize({width = width, height = contentSize.height})
	panel.Text_cond_desc:setPosition(cc.p(0,contentSize.height))

	return panel
end

Helper:classDefNodeGetInstance(TuJianActiveZhaoInFoLayer)
return TuJianActiveZhaoInFoLayer0000000
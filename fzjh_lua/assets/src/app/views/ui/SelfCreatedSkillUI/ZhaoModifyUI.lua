local ZhaoModifyUI = class("ZhaoModifyUI", LayerEx)
local ZhaoModifyPresenter = require("app.presenters.selfCreatedSkill.zhaoModify.ZhaoModifyPresenter")
local IZhaoModifyPresenterOutput = require("app.presenters.selfCreatedSkill.zhaoModify.IZhaoModifyPresenterOutput")
local IZhaoModifyPresenterInput = require("app.presenters.selfCreatedSkill.zhaoModify.IZhaoModifyPresenterInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function ZhaoModifyUI:create()
	local p = ZhaoModifyUI:new()
	p:init()
	return p
end

function ZhaoModifyUI:init()
    self._round = require("Layer/SelfCreatedSkillUI/zhaoModifyUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ZhaoModifyUI:showLayer(selfCreatedSkillSystem,zhaoIndex,callback)
	self._IZhaoModifyPresenterInput = isImplement(ZhaoModifyPresenter:create(self,selfCreatedSkillSystem,zhaoIndex), IZhaoModifyPresenterInput)
    self._IZhaoModifyPresenterInput:showLayer(callback)
end

function ZhaoModifyUI:setShowLayer()
    self:show()
end

function ZhaoModifyUI:setTextRandomDsc(text)
    self.Panel_1.Panel_3.Text_3:setString(text)
end

-- @desc 创建输入框
function ZhaoModifyUI:createEditBox()
	-- self.EditBoxArea:setTouchEnabled(true)
	local editBox
	local size = self.Panel_1.Panel_2.EditBoxArea:getContentSize()
	if self.editBox == nil then
		editBox = ccui.EditBox:create(size,"")
		self.editBox = editBox
		editBox:setFontName("Font/default.ttf")
		editBox:setFontSize(54)
		editBox:setPlaceholderFontSize(54)
		editBox:setPlaceholderFontName("Font/default.ttf")
		editBox:setVisible(true)
		-- 设置输入类型
		editBox:setInputMode(6)
		editBox:setReturnType(1)

		editBox:onEditHandler(
			function(event)
				local eventName = event.name
				local eventTarget = event.target

				if PRINT_MODE == 1 then
					print("eventName = " .. tostring(eventName))
					print("eventTarget = " .. tostring(eventTarget))
				end

				if eventName == "began" then
					self._isEditing = true
				elseif eventName == "changed" then
					self._editBoxString = editBox:getText()
					if PRINT_MODE == 1 then
						print("self._editBoxString = " .. tostring(self._editBoxString))
					end
				elseif eventName == "end" then
				elseif eventName == "return" then
					self._isEditing = false
				end
			end
		)

		self.Panel_1.Panel_2.EditBoxArea:getParent():addChild(editBox)
		editBox:setPosition(self.Panel_1.Panel_2.EditBoxArea:getPositionX(), self.Panel_1.Panel_2.EditBoxArea:getPositionY())
	end
end

-- @desc 设置输入框文本颜色
function ZhaoModifyUI:setEditBoxFontColor(color)
	if self.editBox then
		self.editBox:setFontColor(color)
	end
end

-- @desc 设置输入框文本
function ZhaoModifyUI:setEditBoxText(text)
	if self.editBox ~= nil and self._isEditing ~= true then
		self.editBox:setText(text)
	end
end

function ZhaoModifyUI:setPanelHideIsVisible(isVisible)
	self.Panel_1.Panel_hide:setVisible(isVisible)
end

function ZhaoModifyUI:setPanel4IsVisible(isVisible)
	self.Panel_1.Panel_4:setVisible(isVisible)
end

function ZhaoModifyUI:setColorListView(colorArray)
	self.Panel_1.Panel_4.ListView_1:removeAllItems()
	local mod, remainder = math.modf(#colorArray/5)
    if math.ceil(remainder) == 1 then
        mod = mod + 1
    end
	for i = 1,mod do
		local panel = self.Panel_color:clone()
		self.Panel_1.Panel_4.ListView_1:pushBackCustomItem(panel)
		Helper:convertUIByParent(panel)

		self:__setPanelZhao(panel,colorArray,i)
	end
end

function ZhaoModifyUI:__setPanelZhao(panel,colorArray,index)
	for i = 1, 5 do
		local colorData = colorArray[5*(index-1)+i]
		if colorData then
			panel["Panel_one_color"..i].Image_1:setVisible(colorData["Image_1IsVisible"])
			panel["Panel_one_color"..i].Image_1:loadTexture(colorData["Image_1Image"],0)
			panel["Panel_one_color"..i].Image_2:setVisible(colorData["Image_2IsVisible"])
			panel["Panel_one_color"..i]:releaseFunc(function()
				if type(colorData["func"]) == "function" then
					colorData["func"]()
				end
			end)
		else
			panel["Panel_one_color"..i]:setVisible(false)
		end
	end
end

function ZhaoModifyUI:setImageDownIsVisible(isVisible)
	self.Panel_1.Panel_2.Panel_selectColor.Image_down:setVisible(isVisible)
end

function ZhaoModifyUI:setImageUpIsVisible(isVisible)
	self.Panel_1.Panel_2.Panel_selectColor.Image_up:setVisible(isVisible)
end

function ZhaoModifyUI:setButtonSelectColor(callback)
    self.Panel_1.Panel_2.Panel_selectColor:releaseFunc(function()
        if callback then
            callback()
        end
    end)
end

function ZhaoModifyUI:setButtonOk(func)
	self.Panel_1.Button_ok:releaseFunc(function()
		if self.editBox ~= nil then
            self._editBoxString = self.editBox:getText()
            if func then
				func(self._editBoxString)
			end
		else
		end
	end)
end

function ZhaoModifyUI:setButtonCancel(func)
	self.Panel_1.Button_cancel:releaseFunc(function()
		if func then
            func()
        end
	end)
end

-- @desc 随机名称按钮
function ZhaoModifyUI:setRandomNameButton(func)
	self.Panel_1.Panel_2.Button_randomName:releaseFunc(function()
		if self.editBox ~= nil and self._isEditing ~= true then
	    	self.editBox:setText(func())
	    end
	end)
end

-- @desc 随机描述按钮
function ZhaoModifyUI:setRandomDscButton(func)
	self.Panel_1.Panel_3.Button_randomName:releaseFunc(function()
		if func then
            func()
        end
	end)
end

function ZhaoModifyUI:hideLayer()
    PopupLayerController:hideLayer("ZhaoModifyUI",function(layer)
        layer:hide()
    end)
end

function ZhaoModifyUI:popText(text)
	PopText(text)
end

isImplement(ZhaoModifyUI,IZhaoModifyPresenterOutput)
Helper:classDefNodeGetInstance(ZhaoModifyUI)
return ZhaoModifyUI0000000000000
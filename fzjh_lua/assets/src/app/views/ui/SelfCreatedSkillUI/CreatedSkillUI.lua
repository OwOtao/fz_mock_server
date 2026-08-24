local CreatedSkillUI = class("CreatedSkillUI", LayerEx)
local CreatedSkillPresenter = require("app.presenters.selfCreatedSkill.createdSkill.CreatedSkillPresenter")
local ICreatedSkillPresenterOutput = require("app.presenters.selfCreatedSkill.createdSkill.ICreatedSkillPresenterOutput")
local ICreatedSkillPresenterInput = require("app.presenters.selfCreatedSkill.createdSkill.ICreatedSkillPresenterInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function CreatedSkillUI:create()
	local p = CreatedSkillUI:new()
	p:init()
	return p
end

function CreatedSkillUI:init()
    self._round = require("Layer/SelfCreatedSkillUI/createdSkillUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function CreatedSkillUI:showLayer(selfCreatedSkillSystem,callback)
	self._ICreatedSkillPresenterInput = isImplement(CreatedSkillPresenter:create(self,selfCreatedSkillSystem,callback), ICreatedSkillPresenterInput)
    self._ICreatedSkillPresenterInput:showLayer()
end

function CreatedSkillUI:setShowLayer()
    self:show()
end

-- @desc 创建输入框
function CreatedSkillUI:createEditBox()
	-- self.EditBoxArea:setTouchEnabled(true)
	local editBox
	local size = self.Panel_1.Panel_2.EditBoxArea:getContentSize()
	if self.editBox == nil then
		editBox = ccui.EditBox:create(size, "请输入")
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
		editBox:setTouchEnabled(true)
		self.Panel_1.Panel_2.EditBoxArea:getParent():addChild(editBox)
		editBox:setPosition(self.Panel_1.Panel_2.EditBoxArea:getPositionX(), self.Panel_1.Panel_2.EditBoxArea:getPositionY())
	end
end

function CreatedSkillUI:setPanelHideIsVisible(isVisible)
	self.Panel_1.Panel_hide:setVisible(isVisible)
end

function CreatedSkillUI:setPanel4IsVisible(isVisible)
	self.Panel_1.Panel_4:setVisible(isVisible)
end

function CreatedSkillUI:setImageDownIsVisible(isVisible)
	self.Panel_1.Panel_2.Panel_select.Image_down:setVisible(isVisible)
end

function CreatedSkillUI:setImageUpIsVisible(isVisible)
	self.Panel_1.Panel_2.Panel_select.Image_up:setVisible(isVisible)
end

function CreatedSkillUI:setNameAffix(text)
	self.Panel_1.Panel_2.Panel_select.Text_nameAffix:setString(text)
end

function CreatedSkillUI:setDscListView(dscArray)
	self.Panel_1.Panel_4.ListView_1:removeAllItems()
	local mod, remainder = math.modf(#dscArray/3)
    if math.ceil(remainder) == 1 then
        mod = mod + 1
    end
	for i = 1,mod do
		local panel = self.Panel_dsc:clone()
		self.Panel_1.Panel_4.ListView_1:pushBackCustomItem(panel)
		Helper:convertUIByParent(panel)

		self:__setPanelZhao(panel,dscArray,i)
	end
end

function CreatedSkillUI:__setPanelZhao(panel,dscArray,index)
	for i = 1, 3 do
		local dscData = dscArray[3*(index-1)+i]
		if dscData then
			panel["Panel_one_dsc"..i].Text_affix:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
			panel["Panel_one_dsc"..i].Text_affix:setString(dscData["nameAffix"])
			panel["Panel_one_dsc"..i].Image_suo:setVisible(dscData["ImageSuoIsVisible"])
			panel["Panel_one_dsc"..i]:releaseFunc(function()
				if type(dscData["func"]) == "function" then
					dscData["func"]()
				end
			end)
		else
			panel["Panel_one_dsc"..i]:setVisible(false)
		end
	end
end

function CreatedSkillUI:setButtonOk(func)
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

-- @desc 随机名称按钮
function CreatedSkillUI:setRandomNameButton(func)
	self.Panel_1.Panel_2.Button_randomName:releaseFunc(function()
		if self.editBox ~= nil and self._isEditing ~= true then
			local randomName = func()
	    	self:setEditBoxText(randomName)
	    end
	end)
end

-- @desc 随机名称按钮
function CreatedSkillUI:setEditBoxText(text)
	self.editBox:setText(text)
end

-- @desc 设置输入框文本颜色
function CreatedSkillUI:setEditBoxFontColor(color)
	if self.editBox then
		self.editBox:setFontColor(color)
	end
end

function CreatedSkillUI:setButtonSelectNameAfterAffix(callback)
    self.Panel_1.Panel_2.Panel_select:releaseFunc(function()
        if callback then
            callback()
        end
    end)
end

function CreatedSkillUI:setTextSkillDsc(text)
	self.Panel_1.Panel_3.Text_dsc:setString(text)
end

function CreatedSkillUI:setTextPreSkillType(text)
    self.Panel_1.Text_1:setString(text)
end

function CreatedSkillUI:setTextEquipType(text)
    self.Panel_1.Text_3:setString(text)
end

function CreatedSkillUI:setTextActiveZhaoNum(text)
    self.Panel_1.Text_6:setString(text)
end

function CreatedSkillUI:setTextAutoZhaoNum(text)
    self.Panel_1.Text_9:setString(text)
end

function CreatedSkillUI:setTextStr1(text)
    self.Panel_1.Text_str1:setString(text)
end

function CreatedSkillUI:setTextStr2(text)
    self.Panel_1.Text_str2:setString(text)
end

function CreatedSkillUI:setTextStr3(text)
    self.Panel_1.Text_str3:setString(text)
end

function CreatedSkillUI:setTextStr4(text)
    self.Panel_1.Text_str4:setString(text)
end

function CreatedSkillUI:setTextStr5(text)
    self.Panel_1.Text_str5:setString(text)
end

function CreatedSkillUI:setTextStr6(text)
    self.Panel_1.Text_str6:setString(text)
end

function CreatedSkillUI:setTextStr7(text)
    self.Panel_1.Text_str7:setString(text)
end

function CreatedSkillUI:setTextStr8(text)
    self.Panel_1.Text_str8:setString(text)
end

function CreatedSkillUI:setTextLevel1(text)
    self.Panel_1.Text_level1:setString(text)
end

function CreatedSkillUI:setTextLevel2(text)
    self.Panel_1.Text_level2:setString(text)
end

function CreatedSkillUI:setTextLevel3(text)
    self.Panel_1.Text_level3:setString(text)
end

function CreatedSkillUI:setTextLevel4(text)
    self.Panel_1.Text_level4:setString(text)
end

function CreatedSkillUI:setTextLevel5(text)
    self.Panel_1.Text_level5:setString(text)
end

function CreatedSkillUI:setTextLevel6(text)
    self.Panel_1.Text_level6:setString(text)
end

function CreatedSkillUI:setTextLevel7(text)
    self.Panel_1.Text_level7:setString(text)
end

function CreatedSkillUI:setTextLevel8(text)
    self.Panel_1.Text_level8:setString(text)
end

-- @desc 设置输入框文本颜色
function CreatedSkillUI:__setEditBoxFontColor(color)
	if self.editBox then
		self.editBox:setFontColor(color)
	end
end

function CreatedSkillUI:hideLayer()
	PopupLayerController:hideLayer("CreatedSkillUI",function(layer)
        layer:hide()
    end)
end

function CreatedSkillUI:popText(text)
    PopText(text)
end


isImplement(CreatedSkillUI,ICreatedSkillPresenterOutput)
Helper:classDefNodeGetInstance(CreatedSkillUI)
return CreatedSkillUI00
local EditRoleAttrLayer3 = class("EditRoleAttrLayer3", cc.LayerColor)
local DebugLayer = require("app.views.layer.DebugLayer.DebugLayer")
local Skill = require("app.models.skill.Skill")
local Item = require("app.models.item.Item")
local Ranking = require("app.views.ui.RankingUI.RankingUI")

function EditRoleAttrLayer3:create()
	local p = EditRoleAttrLayer3:new()
	p:init()
	
	return p
end


local Table = {
}

function EditRoleAttrLayer3:init()
	self._round = require("Layer/DebugUI/EditRoleAttrLayer2.lua").create() ['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)
	
	-- User:getRole():setAttr("breathVal", 2000000)
	local role = User:getRole()
	local inherit = User:getRole():getHeOrHer(User:getRoleAttr("inherit").endurance)
	print("................................................:" .. inherit)
end


function EditRoleAttrLayer3:show(tab)
	local items = User:getRole():getItems()
	local itemTab = clone(items)
	for i = 1, table.getn(itemTab) do
		for j = i + 1, table.getn(itemTab) do
			if itemTab[i].itemId == itemTab[i].itemId then
				-- print(itemTab[i].itemId .. "的数量加1")
				itemTab[i].count = itemTab[j].count + 1
			end
		end
		for j = i + 1, table.getn(itemTab) do
			if itemTab[i].itemId == itemTab[i].itemId then
				table.remove(itemTab, j)
			end
		end
	end
	
	self.Text_title:setString(tab.name)
	tab = Table[tab.name]

	local filterTab = {}
	local index = 0
	for k, v in pairs(tab) do
		if v.name and GameChannelContext:checkGMIsOpen(v.name) then
			index = index + 1
			filterTab[index] = v
		end
	end
	
	self:setButtonBack(filterTab)

	if index <= 0 then
		return
	end

	for i = 1, index, 1 do
		if filterTab[i].panelName == "Panel_1" then
			self:dealTypePanel1(filterTab[i])
		elseif filterTab[i].panelName == "Panel_2" then
			self:dealTypePanel2(filterTab[i])
		elseif filterTab[i].panelName == "Panel_3" then
			self:dealTypePanel3(filterTab[i])
		elseif filterTab[i].panelName == "Panel_time" then
			self:dealTypePanelTime(filterTab[i])
		elseif filterTab[i].panelName == "Panel_time_curr" then
			self:dealTypePanelCurrTime(filterTab[i])
		end
	end
end



function EditRoleAttrLayer3:dealTypePanel1(tab)
	local row = self:clonePanle(self.Panel_1)
	row.Text_desc:setString(tab.name)
	local tditBox = self:createEditBox(row)
	tditBox:setTag(999)
	tab.editValueFunc = Helper:getDef(tab.editValueFunc, EMPTY_FUNC)
	self:initEditBox(tab.editValueFunc(), nil, tditBox)
	self.ListView:pushBackCustomItem(row)
end


function EditRoleAttrLayer3:dealTypePanel2(tab)
	local row = self:clonePanle(self.Panel_2)
	row.Text_desc:setString(tab.name)
	row:releaseFunc(function()
		if tab.panelFunc then
			tab.panelFunc()
		end
	end)
	self.ListView:pushBackCustomItem(row)
end


function EditRoleAttrLayer3:dealTypePanel3(tab)
	local row = self:clonePanle(self.Panel_3)
	local editName = self:createEditBox(row)
	editName:setTag(666)
	editName:setPosition(row.Image_name:getPositionX(), row.Image_name:getPositionY())
	self:initEditBox(tab.name, nil, editName)
	local editNum = self:createEditBox(row)
	editNum:setTag(999)
	tab.editValueFunc = Helper:getDef(tab.editValueFunc, EMPTY_FUNC)
	self:initEditBox(tab.editValueFunc(), nil, editNum)
	self.ListView:pushBackCustomItem(row)
	--插入队头
	-- self.ListView:insertCustomItem(row, 0)
end


function EditRoleAttrLayer3:dealTypePanelTime(tab)
	local row = self:clonePanle(self.Panel_time)
	row.Text_desc:setString(tab.name)
	self:createTimeEditBox(row)
	
	self.ListView:pushBackCustomItem(row)
end


function EditRoleAttrLayer3:dealTypePanelCurrTime(tab)
	local row = self:clonePanle(self.Panel_time_curr)
	row.Text_desc:setString(tab.name)
	self.ListView:pushBackCustomItem(row)
	
	Game:getWebTime(function(time)
		row.Text_time:setString(os.date("%x %X", time))
	end)
end


function EditRoleAttrLayer3:createTimeEditBox(row)
	
	local size = row.Image_year:getContentSize()
	local year = ccui.EditBox:create(size, os.date("%Y", os.date(WEB_TIME)))
	year:setInputMode(1)
	year:setInputFlag(3)
	year:setReturnType(1)
	year:setFontSize(48)
	year:setTag(770)
	year:addTo(row)
	year:setPosition(row.Image_year:getPositionX(), row.Image_year:getPositionY())
	
	local size = row.Image_mon:getContentSize()
	local month = ccui.EditBox:create(size, os.date("%m", os.date(WEB_TIME)))
	month:setInputMode(1)
	month:setInputFlag(3)
	month:setReturnType(1)
	month:setFontSize(48)
	month:setTag(771)
	month:addTo(row)
	month:setPosition(row.Image_mon:getPositionX(), row.Image_mon:getPositionY())
	
	local size = row.Image_date:getContentSize()
	local day = ccui.EditBox:create(size, os.date("%d", os.date(WEB_TIME)))
	day:setInputMode(1)
	day:setInputFlag(3)
	day:setReturnType(1)
	day:setFontSize(48)
	day:setTag(772)
	day:addTo(row)
	day:setPosition(row.Image_date:getPositionX(), row.Image_date:getPositionY())
	
	local size = row.Image_hour:getContentSize()
	local hour = ccui.EditBox:create(size, os.date("%H", os.date(WEB_TIME)))
	hour:setInputMode(1)
	hour:setInputFlag(3)
	hour:setReturnType(1)
	hour:setFontSize(48)
	hour:setTag(773)
	hour:addTo(row)
	hour:setPosition(row.Image_hour:getPositionX(), row.Image_hour:getPositionY())
	
	local size = row.Image_min:getContentSize()
	local minute = ccui.EditBox:create(size, os.date("%M", os.date(WEB_TIME)))
	minute:setInputMode(1)
	minute:setInputFlag(3)
	minute:setReturnType(1)
	minute:setFontSize(48)
	minute:setTag(774)
	minute:addTo(row)
	minute:setPosition(row.Image_min:getPositionX(), row.Image_min:getPositionY())
end

function EditRoleAttrLayer3:createEditBox(row)
	local size = row.Image_num:getContentSize()
	local name_EditBox = ccui.EditBox:create(size, "self.exp")
	name_EditBox:setInputMode(1)
	name_EditBox:setInputFlag(3)
	name_EditBox:setReturnType(1)
	name_EditBox:setFontSize(48)
	name_EditBox:addTo(row)
	name_EditBox:setPosition(row.Image_num:getPositionX(), row.Image_num:getPositionY())
	return name_EditBox
end



function EditRoleAttrLayer3:initEditBox(text, func, editBox)
	editBox:setText(text)
	if func ~= nil then
		editBox:onEditHandler(func)
	else
		editBox:onEditHandler(function(event)
			if event.name == "return" then
			end
		end)
	end
end



function EditRoleAttrLayer3:clonePanle(panel)
	if panel == nil then
		return
	end
	local row = panel:clone()
	Helper:convertUI(row)
	return row
end


function EditRoleAttrLayer3:setButtonBack(tab)
	self.Button_back_0:releaseFunc(function()
		self:removeFromParent()
	end)
	self.Button_back:releaseFunc(function()
		local items = self.ListView:getItems()
		for i = 1, table.getn(items) do
			if tab[i].panelName == "Panel_1" then
				local editNum = items[i]:getChildByTag(999)
				if tab[i].buttonFunc then
					tab[i].buttonFunc(editNum)
				end
			elseif tab[i].panelName == "Panel_3" then
				local editName = items[i]:getChildByTag(666)
				print(editName:getText())
				local editNum = items[i]:getChildByTag(999)
				print(editName:getText())
				if tab[i].buttonFunc then
					tab[i].buttonFunc(editName, editNum)
				end
			elseif tab[i].panelName == "Panel_2" then
				if tab[i].buttonFunc then
					tab[i].buttonFunc()
				end
			elseif tab[i].panelName == "Panel_time" then
				local editYear = items[i]:getChildByTag(770)
				local editMon = items[i]:getChildByTag(771)				
				local editDay = items[i]:getChildByTag(772)
				local editHour = items[i]:getChildByTag(773)
				local editMin = items[i]:getChildByTag(774)
				
				local year = Helper:getDef(tonumber(editYear:getText()), tonumber(editYear:getPlaceHolder()))
				local month = Helper:getDef(tonumber(editMon:getText()), tonumber(editMon:getPlaceHolder()))
				local day = Helper:getDef(tonumber(editDay:getText()), tonumber(editDay:getPlaceHolder()))
				local hour = Helper:getDef(tonumber(editHour:getText()), tonumber(editHour:getPlaceHolder()))
				local minute = Helper:getDef(tonumber(editMin:getText()), tonumber(editMin:getPlaceHolder()))
				
				local time = {
					year = year,
					month = month,
					day = day,
					hour = hour,
					min = minute
				}
				if tab[i].buttonFunc then
					tab[i].buttonFunc(time)
				end
			end
		end
	end)
end

function EditRoleAttrLayer3:dealItemTable(tab)
	for i = 1, table.getn(tab) do
		print(i)
		if tab[i] ~= nil then
			local itemAttr = Item:getOneItemByKey(tab[i].itemId)
			if itemAttr ~= nil and(itemAttr.canFold == 0 or tab[i].count == 99) then
				table.remove(tab, i)
			end
		end
	end
end

function EditRoleAttrLayer3:dealAddToTable(tab, i, name, num, panelName, func, editfunc, nameEditFunc)
	tab[i] = {
		name = name,
		panelName = panelName,
		isEdit = false,
		buttonFunc = func,
		editFunc = editfunc,
		nameEdit = nameEditFunc,
		editValueFunc = function()
			return num
		end,
		panelFunc = function()
		end,
	}
end
Helper:classDefNodeGetInstance(EditRoleAttrLayer3)
return EditRoleAttrLayer3 000000
--[[
Descripttion: 
version: 
Author: LvBin
Date: 2026-07-20 19:59:34
--]]
local ActiveZhaoMergePresenter = class("ActiveZhaoMergePresenter", cc.Layer)

function ActiveZhaoMergePresenter:create()
    local p = ActiveZhaoMergePresenter:new()
    p:init()
    return p
end

function ActiveZhaoMergePresenter:init()
    self.__ui = require("app.views.ui.SkillUI.ActiveZhaoMeditateUI.ActiveZhaoMergeUI"):create()

    self.__ui:addTo(self)
end

function ActiveZhaoMergePresenter:setRole(role)
	self.__role = role

	self.__sys = self.__role:getActiveZhaoMeditateSystem()
end

function ActiveZhaoMergePresenter:showLayer(zhao)
	self.__index = 1

	self.__touchTime = 0

	self.__itemId = nil

	self.__itemTable = {}

	self.__ui:setTextTitle("融汇")

	self.__ui:setPanelBack(function()
		self:hideLayer()
	end)

	self:__clearHandle()
	
	self:__refreshButton()

	self:__refreshCanYePanel()
	
	self:__setTextNum()

	self:__initTitleList()

	self:__setTitleListView()

	self:__refreshListView()

	self:__setCanyeTextNum()

	self:setButtonConfirm()

	self:setButtonMin()

	self:setButtonMax()

	self.__ui:showUI()
end

function ActiveZhaoMergePresenter:__setTextNum()
	self.__ui:setText1("尘世感悟："..self.__sys:getCsgwNum())
end

function ActiveZhaoMergePresenter:setCallback(func)
	self.__callback = func
end

function ActiveZhaoMergePresenter:__initTitleList()
    local canYeList = self.__sys:getActiveZhaoCanYeList()
    self.__titleList = {
        {name = "拳脚", list = {}},
        {name = "兵器", list = {}},
        {name = "轻功", list = {}},
        {name = "内功", list = {}},
        {name = "招架", list = {}}
    }

    for i,v in ipairs(canYeList) do
		local itemAttr = Item:getOneItemByKey(v.itemId)

		local zhaoId = itemAttr.zhaoId

		local itemName = itemAttr.name

		local zhaoType = Skill:getActiveZhao(zhaoId):getZhaoMethod()

		local retData = {
			name = itemName,
			count = v.count,
			itemId = v.itemId
		}

		if zhaoType == SKILL_METHOD_TYPE_QUANJIAO then
			table.insert(self.__titleList[1].list,retData)
		elseif zhaoType == SKILL_METHOD_TYPE_NEIGONG then
			table.insert(self.__titleList[4].list,retData)
		elseif zhaoType == SKILL_METHOD_TYPE_QINGGONG then
			table.insert(self.__titleList[3].list,retData)
		elseif zhaoType == SKILL_METHOD_TYPE_ZHAOJIA then
			table.insert(self.__titleList[5].list,retData)
		else
			table.insert(self.__titleList[2].list,retData)
		end
	end
end

function ActiveZhaoMergePresenter:__setTitleListView()
    local retArray = {}
    for i,v in ipairs(self.__titleList) do
        local tab = {
            name = "",
            func = EMPTY_FUNC
        }
        tab["title"] = v.name
        tab["func"] = function()
            self.__index = i

			self.__itemId = nil
            
			self:__refreshListView()
			
			self:__refreshCanYePanel()

			self:__setCanyeTextNum()

			self:__refreshButton()
			
			self.__ui:skillListViewJumpToTop()
        end
        table.insert(retArray, tab)
    end
    
    self.__ui:setTitleListView(retArray)
end

function ActiveZhaoMergePresenter:__refreshListView()
    self.__ui:lightTab(self.__titleList[self.__index].name)

	self:__setCanyeListView()
end

function ActiveZhaoMergePresenter:__setCanyeListView()
    local retArray = {}
    local list = self.__titleList[self.__index].list

    if MapIsEmpty(list) == false then
        for index,v in ipairs(list) do
			local itemId = v.itemId

			local nameText = v.name
			
			local lvText = self:__getItemNum(itemId).."/"..v.count

			local textColor = {r = 255, g = 255, b = 255}

			local func = function()
				if self.__itemId == itemId then
					self.__itemId = nil
				else					
					self.__itemId = itemId
				end

				self:__refreshCanYePanel()

				self:__setCanyeTextNum()

				self:__refreshButton()

				self.__ui:lightCanyeItem(self.__itemId)
			end

			local retTab = {
				itemId = itemId,
				nameText = nameText,
				lvText = lvText,
				textColor = textColor,
				func = func
			}

            table.insert(retArray, retTab)
        end
    end

    self.__ui:setSkillListView(retArray)
end

function ActiveZhaoMergePresenter:__refreshCanYePanel()
	local mergeCsgwNum = self.__sys:getMergeCsgwNum(self.__itemTable)

	local weekCsgwNum = self.__sys:getWeekCsgwNum() + mergeCsgwNum

	local weekCsgwNumLimit = self.__sys:getWeekCsgwNumLimit()

	local panelInfo = {
		text1 = "",
		text2 = "融汇残页数量："..self:__getCanYeFinalNum(),
		text3 = "获得尘世感悟："..mergeCsgwNum,
		text4 = "本周已融汇尘世感悟："..weekCsgwNum.."/"..weekCsgwNumLimit,
		visible = false,
		func = EMPTY_FUNC
	}
	if self.__itemId then
		panelInfo.visible = true

		local itemName = Item:getOneItemByKey(self.__itemId).name

		panelInfo.text1 = itemName
	end

	self.__ui:setCanYePanel(panelInfo)
end

function ActiveZhaoMergePresenter:__refreshButton()
	self:__setButtonSub()

	self:__setButtonAdd()
end

function ActiveZhaoMergePresenter:__setButtonSub()
	local retData = {
		beganFunc = EMPTY_FUNC,
        endedFunc = EMPTY_FUNC,
        canceledFunc = EMPTY_FUNC
    }

	if self.__itemId then
		local currNum = self:__getItemNum(self.__itemId)
	
		if currNum - 1 >= 0 then
			retData.beganFunc = self:createBeganFunc(
				function()
					if currNum - 1 < 0 then
						self:__clearHandle()
						return
					end
	
					currNum = currNum - 1
	
					self:__setCurrItemNum(currNum)
	
					self:__setCanyeTextNum()

					self:__refreshPanelItemCanyeTextNum()
	
					self:__refreshButton()

					self:__refreshCanYePanel()
				end
			)
			retData.endedFunc = function()
				currNum = currNum - 1
	
				self:__setCurrItemNum(currNum)
	
				self:__setCanyeTextNum()

				self:__refreshPanelItemCanyeTextNum()
	
				self:__refreshButton()

				self:__refreshCanYePanel()
	
				self:__clearHandle()
			end
	
			retData.canceledFunc = function()
				self:__clearHandle()
			end
		end
	else
		self:__clearHandle()
	end

	
	self.__ui:setButtonChange("Button_2",retData)
end

function ActiveZhaoMergePresenter:__setButtonAdd()
	local retData = {
		beganFunc = EMPTY_FUNC,
        endedFunc = EMPTY_FUNC,
        canceledFunc = EMPTY_FUNC
    }

	if self.__itemId then
		local currNum = self:__getItemNum(self.__itemId)
	
		local currNumLimit = self:__getCurrItemNumLimit()
	
		if currNum + 1 <= currNumLimit then
			retData.beganFunc = self:createBeganFunc(
				function()
					if currNum + 1 > currNumLimit then
						self:__clearHandle()
						return
					end
	
					currNum = currNum + 1
	
					self:__setCurrItemNum(currNum)
	
					self:__setCanyeTextNum()

					self:__refreshPanelItemCanyeTextNum()
	
					self:__refreshButton()

					self:__refreshCanYePanel()
				end
			)
			retData.endedFunc = function()
				currNum = currNum + 1
	
				self:__setCurrItemNum(currNum)
	
				self:__setCanyeTextNum()

				self:__refreshPanelItemCanyeTextNum()
	
				self:__refreshButton()

				self:__refreshCanYePanel()
	
				self:__clearHandle()
			end
	
			retData.canceledFunc = function()
				self:__clearHandle()
			end
		end
	else
		self:__clearHandle()
	end
	
	self.__ui:setButtonChange("Button_3",retData)
end

function ActiveZhaoMergePresenter:__getItemNum(itemId)
	return Helper:getDef(self.__itemTable[itemId],0)
end

function ActiveZhaoMergePresenter:__getCurrItemNumLimit()
	return self.__sys:getCanYeNum(self.__itemId)
end

function ActiveZhaoMergePresenter:__setCurrItemNum(num)
	if num <= 0 then
		self.__itemTable[self.__itemId] = nil
	else
		self.__itemTable[self.__itemId] = num
	end
end

function ActiveZhaoMergePresenter:__setCanyeTextNum()
	self.__ui:setSelectText(self:__getItemNum(self.__itemId))
end

function ActiveZhaoMergePresenter:__refreshPanelItemCanyeTextNum()
	local num = self:__getItemNum(self.__itemId)

	local numMax = self:__getCurrItemNumLimit()

	self.__ui:setTextPanelItemNum(self.__itemId,num.."/"..numMax)
end

function ActiveZhaoMergePresenter:createBeganFunc(callback)
    local function retFunc()
        local currTime = GetTime()

        if currTime - self.__touchTime < 0.3 then
            return
        end

        self.__touchTime = currTime

        self:__clearHandle()

        local total_time = 0

        self.__handle =
            self:schedule(
            function(ft)
                total_time = total_time + ft
                if total_time > 1.25 then
                    callback()
                end
            end
        )
    end
    return retFunc
end

function ActiveZhaoMergePresenter:__clearHandle()
    if self.__handle ~= nil then
        self:unschedule(self.__handle)
        self.__handle = nil
    end
end

function ActiveZhaoMergePresenter:__getCanYeFinalNum()
	local finalNum = 0
	if not MapIsEmpty(self.__itemTable) then
		for itemId,num in pairs(self.__itemTable) do
			finalNum = finalNum + num
		end
	end
	return finalNum
end

function ActiveZhaoMergePresenter:setButtonMin()
	self.__ui:setButtonMin(
		function()
			self:__setCurrItemNum(0)
	
			self:__setCanyeTextNum()

			self:__refreshPanelItemCanyeTextNum()

			self:__refreshButton()

			self:__refreshCanYePanel()
		end
	)
end

function ActiveZhaoMergePresenter:setButtonMax()
	self.__ui:setButtonMax(
		function()
			self:__setCurrItemNum(self:__getCurrItemNumLimit())
	
			self:__setCanyeTextNum()

			self:__refreshPanelItemCanyeTextNum()

			self:__refreshButton()

			self:__refreshCanYePanel()
		end
	)
end

function ActiveZhaoMergePresenter:__checkCanMerge()
	if self:__getCanYeFinalNum() < 1 then
		PopText("请放置残页后再进行融汇")
		return false
	end

	local weekCsgwNum = self.__sys:getWeekCsgwNum()
	
	local weekCsgwNumLimit = self.__sys:getWeekCsgwNumLimit()
	
	if weekCsgwNum >= weekCsgwNumLimit then
		PopText("本周尘世感悟已达到最大值")
		return false
	end

	local mergeCsgwNum = self.__sys:getMergeCsgwNum(self.__itemTable)

	if weekCsgwNum + mergeCsgwNum > weekCsgwNumLimit then
		PopText("已超过本周可获得尘世感悟数量，请减少残页")
		return false
	end

	return true
end

function ActiveZhaoMergePresenter:setButtonConfirm()
    self.__ui:setButtonConfirm(function()
		if self:__checkCanMerge() then
			self:__showConfirmUI()
		end
    end)
end

function ActiveZhaoMergePresenter:__showConfirmUI()
	PopupLayerController:showLayer("ActiveZhaoMergeConfirmPresenter",function(layer)
		local uiList = {}

		for itemId,num in pairs(self.__itemTable) do
			table.insert(uiList, {num = num, name = Item:getOneItemByKey(itemId).name})
		end

		layer:setTextDsc("是否确认融汇以下残页?融汇后可获得"..tostring(self.__sys:getMergeCsgwNum(self.__itemTable)).."点尘世感悟，融汇后资源不可恢复，请谨慎确认。")

		layer:setListView(uiList)

		layer:setButtonConfirm(function()
			self.__sys:mergeActiveZhaoCanYe(self.__itemTable,function(isOk,msg)
				if isOk then
					if self.__callback then
						self.__callback()
					end
					self:hideLayer()
					PopText(msg)
				else
					PopText(msg)
				end
			end)
		end)

		layer:showLayer()
	end) 
end

function ActiveZhaoMergePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ActiveZhaoMergePresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ActiveZhaoMergePresenter)
return ActiveZhaoMergePresenter
0000000
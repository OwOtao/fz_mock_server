--[[
Descripttion: 
version: 
Author: LvBin
Date: 2026-07-20 18:46:04
--]]
local ActiveZhaoLevelPresenter = class("ActiveZhaoLevelPresenter", cc.Layer)

local CurrencyUtil = require("app.models.Currency.CurrencyUtil")

function ActiveZhaoLevelPresenter:create()
    local p = ActiveZhaoLevelPresenter:new()
    p:init()
    return p
end

function ActiveZhaoLevelPresenter:init()
    self.__ui = require("app.views.ui.SkillUI.ActiveZhaoMeditateUI.ActiveZhaoLevelUI"):create()

    self.__ui:addTo(self)
end

function ActiveZhaoLevelPresenter:setRole(role)
	self.__role = role

	self.__sys = self.__role:getActiveZhaoMeditateSystem()
end

function ActiveZhaoLevelPresenter:showLayer()
	self.__levelClass = self.__sys:getCurrActiveZhaoLevelClass()

	self.__ui:setTextTitle("领悟境界")
	
	self.__ui:setPanelBack(function()
		self:hideLayer()
	end)

	self:__initUI()

	self.__ui:showUI()
end

function ActiveZhaoLevelPresenter:setCallback(func)
	self.__callback = func
end

function ActiveZhaoLevelPresenter:__initUI()
	self.__ui:setText(1,"当前境界等级："..self.__levelClass:getId())

	self.__ui:setText(2,"残页领悟熟练度：+"..self.__levelClass:getCanyeToProficiencyAdd())

	self.__ui:setText(3,"尘世领悟熟练度：+"..self.__levelClass:getPowerToProficiencyAdd())

	self.__ui:setText(4,"融汇额外尘世感悟：+"..self.__levelClass:getCanyeToPowerAdd())

	self.__ui:setText(5,"周融汇最大值：+"..self.__levelClass:getWeeklyEnergyLimit())

	if self.__levelClass:getId() == self.__sys:getActiveZhaoMaxLevel() then
		self.__ui:setText(6,"")

		self.__ui:setText(7,"")

		self.__ui:setText(8,"")

		self.__ui:setText(9,"")

		self.__ui:setText(10,"")

		self.__ui:setText(11,"")

		self.__ui:setText(12,"当前已达到最大等级")

		self.__ui:setItemText({})

		self.__ui:setButtonConfirm(false,EMPTY_FUNC)
	else
		self.__ui:setText(6,"境界等级："..self.__levelClass:getId() + 1)

		self.__ui:setText(7,"升级效果：")

		self.__ui:setText(8,self.__levelClass:getUpgradeEffectDesc())

		self.__ui:setText(9,"升级所需：")

		self.__ui:setText(10,self.__levelClass:getUpgradeNeedDesc())

		self.__ui:setText(11,"升级消耗：")

		self.__ui:setText(12,"")

		local itemTextArray = {}

		local costList = self.__levelClass:getUpgradeCost()

		for i = 1,#costList do
			local costData = costList[i]

			local currencyId = costData[1]

			local currencyNum = costData[2]

			local currencyResClass = CurrencyUtil:getCurrencyResClass(currencyId)
			
			local name = currencyResClass:getName()

			table.insert(itemTextArray, name.."："..tostring(currencyNum))
		end

		self.__ui:setItemText(itemTextArray)

		self.__ui:setButtonConfirm(true,function()
			PopupLayerController:showLayer("ActiveZhaoInsightConfirmPresenter",function(layer)
				layer:setLevelText("提升后境界等级："..tostring(self.__levelClass:getId() + 1))

				layer:setEffectDscText(self.__levelClass:getUpgradeEffectDesc())

				layer:setConditionDscText(self.__levelClass:getUpgradeNeedDesc())

				layer:setResText(itemTextArray)
				
				layer:setButtonConfirm(function()
					local conditionResult,conditionMsg = self.__sys:checkAdvanceCondition()

					if conditionResult then
						self.__sys:advanceActiveZhaoMeditateLevel(function(isOk,msg)
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
					else
						PopText(conditionMsg)
					end
				end)

				layer:showLayer()
			end) 
		end)
	end
end

function ActiveZhaoLevelPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ActiveZhaoLevelPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ActiveZhaoLevelPresenter)
return ActiveZhaoLevelPresenter
00000000000
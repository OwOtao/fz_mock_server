local ActiveZhaoGuaJiPresenter = class("ActiveZhaoGuaJiPresenter", cc.Layer)

function ActiveZhaoGuaJiPresenter:create()
    local p = ActiveZhaoGuaJiPresenter:new()
    p:init()
    return p
end

function ActiveZhaoGuaJiPresenter:init()
    self.__ui = require("app.views.ui.SkillUI.ActiveZhaoMeditateUI.ActiveZhaoGuaJiUI"):create()

    self.__ui:addTo(self)
end

function ActiveZhaoGuaJiPresenter:setRole(role)
	self.__role = role

	self.__sys = self.__role:getActiveZhaoMeditateSystem()
end

function ActiveZhaoGuaJiPresenter:setCallback(func)
	self.__callback = func
end

function ActiveZhaoGuaJiPresenter:showLayer()
	local meditatingInfo = self.__sys:getMeditatingInfo()

	local zhaoId = meditatingInfo.zhaoId

	local addZhaoExp = meditatingInfo.addZhaoExp

	local zhaoName = Skill:getActiveZhao(zhaoId):getName()

	local zhaoExp = self.__role:getSkillZhaoExp(zhaoId)

	local maxExp = self.__role:getZhaoExpLimit(zhaoId,self.__role:getZhaoLvLimit(zhaoId))

	self.__ui:setText1(zhaoName)

	self.__ui:setText2("当前熟练度："..Helper:mathFloor(zhaoExp).."/"..Helper:mathFloor(maxExp))

	self.__ui:setText3("可获得熟练度："..addZhaoExp)

	self.__ui:setPanelBack(function()
		self:hideLayer()
	end)

	self.__animator = self.__ui:initAnimator()

    self.__animator:play("jingmai", true)
    
    self:scheduleUnique(
        function(ft)
            self:__updataUI(ft)
        end,
        0,
        "updataGJSchedule"
    )

	self.__ui:showUI()
end


function ActiveZhaoGuaJiPresenter:__updataUI(ft)
    local isFinish = self.__sys:isCompleteMeditate()
    
    if isFinish then
        self.__ui:setTextTitle("领悟完成")

        self.__ui:setText4("")

        self.__ui:setButtonConfirm(
            "领取",
            function()
				self.__sys:completeMeditate(
					function(isOk,msg)
						if isOk then
							if self.__callback then
								self.__callback()
							end
							self:hideLayer()

							PopText(msg)
						else
							PopText(msg)
						end
					end
				)
            end
        )

        self:unscheduleWithTag("updataGJSchedule")
    else
        self.__animator:update(ft)

        self.__ui:setTextTitle("领悟中")

		local hour, min, sec = Helper:sec2timeDsc(self.__sys:getResidueTime())

        self.__ui:setText4("所需时间："..hour .. "小时" .. min .. "分钟" .. sec .. "秒")

		self.__ui:setButtonConfirm(
            "终止领悟",
            function()
				PopupLayerController:showLayer("ActiveZhaoStopInsightPresenter",function(layer)
					layer:setRole(self.__role)

					layer:setButtonConfirm(function()
						self.__sys:cancelMeditate(
							function(isOk,msg)
								if isOk then
									self:hideLayer()

									PopText("终止领悟")
								else
									PopText(msg)
								end
							end
						)
					end)

					layer:showLayer()
				end)
            end
        )
    end
end

function ActiveZhaoGuaJiPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ActiveZhaoGuaJiPresenter",
        function(layer)
			self:unscheduleWithTag("updataGJSchedule")

            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ActiveZhaoGuaJiPresenter)
return ActiveZhaoGuaJiPresenter
0
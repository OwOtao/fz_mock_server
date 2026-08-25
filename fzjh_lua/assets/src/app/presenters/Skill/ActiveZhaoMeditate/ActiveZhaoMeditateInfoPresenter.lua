local ActiveZhaoMeditateInfoPresenter = class("ActiveZhaoMeditateInfoPresenter", cc.Layer)

function ActiveZhaoMeditateInfoPresenter:create()
    local p = ActiveZhaoMeditateInfoPresenter:new()
    p:init()
    return p
end

function ActiveZhaoMeditateInfoPresenter:init()
    self.__ui = require("app.views.ui.SkillUI.ActiveZhaoMeditateUI.ActiveZhaoMeditateInfoUI"):create()

    self.__ui:addTo(self)
end

function ActiveZhaoMeditateInfoPresenter:setRole(role)
	self.__role = role

	self.__sys = self.__role:getActiveZhaoMeditateSystem()
end

function ActiveZhaoMeditateInfoPresenter:showLayer(zhao)
	self.__touchTime = 0

	self.__zhao = zhao
	
	self.__canyeId = zhao.id.."canye"
	
	self.__canyeNum = 0

	self.__canyeNumLimit = self.__sys:getCanYeNum(self.__canyeId)
	
	self.__csgwNum = 0

	self.__csgwNumLimit = self.__sys:getCsgwNum()

	local zhaoName = zhao.name

	local zhaoExp = Helper:mathFloor(self.__role:getSkillZhaoExp(zhao.id))

	local maxExp = Helper:mathFloor(self.__role:getZhaoExpLimit(zhao.id,self.__role:getZhaoLvLimit(zhao.id)))

	self.__zhaoExp = zhaoExp

	self.__zhaoMaxExp = maxExp

	self.__canyeName = Item:getOneItemByKey(self.__canyeId).name

	self.__ui:setText(1,zhaoName)

	self.__ui:setText(2,"当前熟练度："..zhaoExp.."/"..maxExp)

	self.__ui:setText(4,self.__canyeName)

	self.__ui:setText(5,"尘世感悟")

	self.__ui:setPanelBack(function()
		self:hideLayer()
	end)

	self:clearHandle()

	self:setCanyeTextNum()

	self:setCsgwTextNum()

	self:refreshButton()

	self:setTextAddExpNum()

	self:setTextNeedTime()

	self:setButtonConfirm()

	self:setButtonCanyeMin()

	self:setButtonCanyeMax()
	
	self:setButtonCsgwMin()
	
	self:setButtonCsgwMax()

	self.__ui:showUI()
end

function ActiveZhaoMeditateInfoPresenter:setCallback(func)
	self.__callback = func
end

function ActiveZhaoMeditateInfoPresenter:refreshButton()
    self:setButton1()

    self:setButton2()

	self:setButton3()

    self:setButton4()
end

function ActiveZhaoMeditateInfoPresenter:checkCsgwAdd(canyeNum,csgwNum,isPopText)
	if csgwNum > self.__csgwNumLimit then
        if isPopText then
            PopText("尘世感悟数量不足")
        end
        return false
    end

	local csgwMaxNum = self.__sys:calCsgwMaxNum(self.__canyeId,canyeNum)

	if csgwNum > csgwMaxNum then
		if isPopText then
            PopText("已超出最大熟练度，无法增加")
        end
		return false
	end

	return true
end

function ActiveZhaoMeditateInfoPresenter:checkCanyeAdd(canyeNum,csgwNum,isPopText)
	if canyeNum  > self.__canyeNumLimit then
        if isPopText then
            PopText(self.__canyeName.."数量不足")
        end
        return false
    end

	local canyeMaxNum = self.__sys:calCanYeMaxNum(self.__canyeId,csgwNum)

	if canyeNum > canyeMaxNum then
		if isPopText then
            PopText("已超出最大熟练度，无法增加")
        end
		return false
	end

	return true
end

function ActiveZhaoMeditateInfoPresenter:changeRefresh()
	self:setCanyeTextNum()

	self:setCsgwTextNum()

	self:refreshButton()

	self:setTextAddExpNum()

	self:setTextNeedTime()
end

function ActiveZhaoMeditateInfoPresenter:setButton1()
	local retData = {
        beganFunc = EMPTY_FUNC,
        endedFunc = EMPTY_FUNC,
        canceledFunc = EMPTY_FUNC
    }

	if self.__canyeNum - 1 >= 0 then
		retData.beganFunc = self:createBeganFunc(
            function()
                if self.__canyeNum - 1 < 0 then
                    self:clearHandle()
                    return
                end

                self.__canyeNum = self.__canyeNum - 1

				self:changeRefresh()
            end
        )
		retData.endedFunc = function()
			self.__canyeNum = self.__canyeNum - 1

			self:changeRefresh()

			self:clearHandle()
		end

		retData.canceledFunc = function()
			self:clearHandle()
		end
	end
	
	self.__ui:setButtonCanyeDec(retData)
end

function ActiveZhaoMeditateInfoPresenter:setButton2()
	local retData = {
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
            self:checkCanyeAdd(self.__canyeNum + 1,self.__csgwNum,true)
        end,
        canceledFunc = EMPTY_FUNC
    }

	if self:checkCanyeAdd(self.__canyeNum + 1,self.__csgwNum,false) then
		retData.beganFunc = self:createBeganFunc(
            function()
                if self:checkCanyeAdd(self.__canyeNum + 1,self.__csgwNum,true) == false then
                    self:clearHandle()
                    return
                end

                self.__canyeNum = self.__canyeNum + 1

                self:changeRefresh()
            end
        )
		retData.endedFunc = function()
			self.__canyeNum = self.__canyeNum + 1

			self:changeRefresh()

			self:clearHandle()
		end

		retData.canceledFunc = function()
			self:clearHandle()
		end
	end
	
	self.__ui:setButtonCanyeAdd(retData)
end

function ActiveZhaoMeditateInfoPresenter:setButton3()
	local retData = {
        beganFunc = EMPTY_FUNC,
        endedFunc = EMPTY_FUNC,
        canceledFunc = EMPTY_FUNC
    }

	if self.__csgwNum - 1 >= 0 then
		retData.beganFunc = self:createBeganFunc(
            function()
                if self.__csgwNum - 1 < 0 then
                    self:clearHandle()
                    return
                end

                self.__csgwNum = self.__csgwNum - 1

                self:changeRefresh()
            end
        )
		retData.endedFunc = function()
			self.__csgwNum = self.__csgwNum - 1

			self:changeRefresh()

			self:clearHandle()
		end

		retData.canceledFunc = function()
			self:clearHandle()
		end
	end
	
	self.__ui:setButtonCsgwDec(retData)
end

function ActiveZhaoMeditateInfoPresenter:setButton4()
	local retData = {
        beganFunc = EMPTY_FUNC,
        endedFunc = function()
            self:checkCsgwAdd(self.__canyeNum,self.__csgwNum + 1,true)
        end,
        canceledFunc = EMPTY_FUNC
    }

	if self:checkCsgwAdd(self.__canyeNum,self.__csgwNum + 1,false) then
		retData.beganFunc = self:createBeganFunc(
            function()
                if self:checkCsgwAdd(self.__canyeNum,self.__csgwNum + 1,true) == false then
                    self:clearHandle()
                    return
                end

                self.__csgwNum = self.__csgwNum + 1

                self:changeRefresh()
            end
        )
		retData.endedFunc = function()
			self.__csgwNum = self.__csgwNum + 1

			self:changeRefresh()

			self:clearHandle()
		end

		retData.canceledFunc = function()
			self:clearHandle()
		end
	end
	
	self.__ui:setButtonCsgwAdd(retData)
end

function ActiveZhaoMeditateInfoPresenter:setButtonCanyeMin()
	self.__ui:setButtonCanyeMin(
		function()
			self.__canyeNum = 0
	
			self:changeRefresh()
		end
	)
end

function ActiveZhaoMeditateInfoPresenter:setButtonCanyeMax()
	self.__ui:setButtonCanyeMax(
		function()
			local canyeMaxNum = self.__sys:calCanYeMaxNum(self.__canyeId,self.__csgwNum)

			local finalMaxNum = math.min(canyeMaxNum,self.__canyeNumLimit)

			self.__canyeNum = finalMaxNum
	
			self:changeRefresh()
		end
	)
end

function ActiveZhaoMeditateInfoPresenter:setButtonCsgwMin()
	self.__ui:setButtonCsgwMin(
		function()
			self.__csgwNum = 0
	
			self:changeRefresh()
		end
	)
end

function ActiveZhaoMeditateInfoPresenter:setButtonCsgwMax()
	self.__ui:setButtonCsgwMax(
		function()
			local csgwMaxNum = self.__sys:calCsgwMaxNum(self.__canyeId,self.__canyeNum)

			local finalMaxNum = math.min(csgwMaxNum,self.__csgwNumLimit)

			self.__csgwNum = finalMaxNum
	
			self:changeRefresh()
		end
	)
end

function ActiveZhaoMeditateInfoPresenter:createBeganFunc(callback)
    local function retFunc()
        local currTime = GetTime()

        if currTime - self.__touchTime < 0.3 then
            return
        end

        self.__touchTime = currTime

        self:clearHandle()

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

function ActiveZhaoMeditateInfoPresenter:clearHandle()
    if self.__handle ~= nil then
        self:unschedule(self.__handle)
        self.__handle = nil
    end
end

function ActiveZhaoMeditateInfoPresenter:setCanyeTextNum()
	self.__ui:setSelectText1(tostring(self.__canyeNum))
end

function ActiveZhaoMeditateInfoPresenter:setCsgwTextNum()
	self.__ui:setSelectText2(tostring(self.__csgwNum))
end

function ActiveZhaoMeditateInfoPresenter:setTextAddExpNum()
	local addExp = self.__sys:calAddZhaoExp(self.__canyeId,self.__canyeNum,self.__csgwNum)

	self.__ui:setText(6,"可获得熟练度："..addExp)
end

function ActiveZhaoMeditateInfoPresenter:setTextNeedTime()
	local needTime = self.__sys:calNeedTime(self.__canyeId,self.__canyeNum,self.__csgwNum)

	local hour, min, sec = Helper:sec2timeDsc(needTime)

	self.__ui:setText(7,"所需时间："..hour .. "小时" .. min .. "分钟" .. sec .. "秒")
end	

function ActiveZhaoMeditateInfoPresenter:setButtonConfirm()
    self.__ui:setButtonConfirm(function()
		if self.__canyeNum == 0 and self.__csgwNum == 0 then
			PopText("资源不足，请先获取残页或融汇")
			return
		end
		
		local addExp,spillExp = self.__sys:calAddZhaoExp(self.__canyeId,self.__canyeNum,self.__csgwNum)

		if spillExp > 0 then
			self:showConfirmUI(addExp)
		else
			self:startMeditate()
		end
    end)
end

function ActiveZhaoMeditateInfoPresenter:startMeditate()
	self.__sys:startMeditate(
		self.__zhao.id,
		self.__canyeNum,
		self.__csgwNum,
		function()
			if self.__callback then
				self.__callback()
			end

			self:hideLayer()

			PopText("开始领悟")
		end
	)
end

function ActiveZhaoMeditateInfoPresenter:showConfirmUI(addExp)
	PopupLayerController:showLayer("ActiveZhaoMeditateConfirmPresenter",function(layer)
		layer:setDscText("本次领悟后，获取的熟练度会超出最大熟练度，超出部分会消失不会累计，是否确认要进行领悟?")

		layer:setText1("领悟后获得熟练度："..addExp)

		layer:setText2("当前熟练度："..tostring(self.__zhaoExp).."/"..tostring(self.__zhaoMaxExp))

		local textArray = {}

		if self.__canyeNum > 0 then
			table.insert(textArray,self.__canyeName.."*"..tostring(self.__canyeNum))
		end

		if self.__csgwNum > 0 then
			table.insert(textArray,"尘世感悟*"..tostring(self.__csgwNum))
		end

		layer:setResText(textArray)
		
		layer:setButtonConfirm(function()
			self:startMeditate()
		end)

		layer:showLayer()
	end) 
end

function ActiveZhaoMeditateInfoPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ActiveZhaoMeditateInfoPresenter",
        function(layer)
			self:clearHandle()

            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ActiveZhaoMeditateInfoPresenter)
return ActiveZhaoMeditateInfoPresenter
00000
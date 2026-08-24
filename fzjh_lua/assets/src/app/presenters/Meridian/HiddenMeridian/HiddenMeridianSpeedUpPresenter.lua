local HiddenMeridianSpeedUpPresenter = class("HiddenMeridianSpeedUpPresenter", cc.Layer)

local HiddenMeridianConstants = require("app.models.Meridian.HiddenMeridianConstants")

function HiddenMeridianSpeedUpPresenter:create()
    local p = HiddenMeridianSpeedUpPresenter:new()
    p:init()
    return p
end

function HiddenMeridianSpeedUpPresenter:init()
    self.__ui = require("app.views.ui.FistFootUI.SpeedUpGuaJiUI"):create()

    self.__ui:addTo(self)
end

function HiddenMeridianSpeedUpPresenter:showLayer()
    self.__touchTime = 0

    self.__cost = 1

    self.__role = self.__input:getRole()

    self.__sys = self.__role:getHiddenMeridianSystem()

    self.__material = self.__sys:getYgpillCount()

    self:__initResidueTime()

    self:__showTextTime()

    self:__refreshCost()
    
    self:__setButtonConfirm()
    
    self:__setButtonCancel()

    self.__ui:show()
end

--@desc: 
--@author:LvBin
--@time:2025-01-21 11:16:11
--@Iinput: [src.app.models.Meridian.HiddenMeridianInteractor#HiddenMeridianInteractor]
--@return
function HiddenMeridianSpeedUpPresenter:setInput(Iinput)
    self.__input = Iinput
end

function HiddenMeridianSpeedUpPresenter:setConfirmFunc(func)
    self.__confirmFunc = func
end

function HiddenMeridianSpeedUpPresenter:setTime(time)
    self.__endTime = time
end

function HiddenMeridianSpeedUpPresenter:__refreshCost()
    self:__setTextDesc()

    self:__setTextNum()
    
    self:__setTextSpeedTime()
    
    self:__setPanelMin()
    
    self:__setButtonDec()
    
    self:__setButtonAdd()
    
    self:__setPanelMax()
end

function HiddenMeridianSpeedUpPresenter:__showTextTime()
    self.__ui:setTextTime("预估剩余时间："..self.__residueMinTime .. "分钟")
end

function HiddenMeridianSpeedUpPresenter:__initResidueTime()
    local time = math.max(self.__endTime - GetTime(), 0)

    local hour, min, sec = Helper:sec2timeDsc(time)

    min = hour * 60 + min + math.min(sec,1) 

    self.__residueMinTime = min

    local mod, remainder = math.modf(self.__residueMinTime / 5)

    if math.ceil(remainder) == 1 then
        mod = mod + 1
    end

    self.__maxCost = mod
end

function HiddenMeridianSpeedUpPresenter:__getMaxCost()
    return math.min(self.__material,self.__maxCost)
end

function HiddenMeridianSpeedUpPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "HiddenMeridianSpeedUpPresenter",
        function(layer)
            self.__ui:hide()
        end
    )
end

function HiddenMeridianSpeedUpPresenter:__setTextDesc()
    local resName = Role:getCHAttrName(HiddenMeridianConstants.ResItemId)
    local text = "当前拥有"..self.__material.."点"..resName.."，是否消耗"..self.__cost.."点加速资源加快完成？"
    self.__ui:setTextDesc(text)
end

function HiddenMeridianSpeedUpPresenter:__setTextNum()
    self.__ui:setTextNum(self.__cost)
end

function HiddenMeridianSpeedUpPresenter:__setTextSpeedTime()
    local time = self.__cost * (HiddenMeridianConstants.SpeedUpTime/60)
    self.__ui:setTextSpeedTime("可加速时间："..time.."分钟")
end

function HiddenMeridianSpeedUpPresenter:__setPanelMin()
    local retData = {}

    if self.__cost <= 1 then
        retData.image = "Image/UI/AttrUI/jiali02b.png"
        retData.color = {r = 255, g = 255, b = 255}
		retData.func = EMPTY_FUNC
    else
        retData.image = "Image/UI/AttrUI/jiali02.png"
        retData.color = {r = 0, g = 204, b = 0}
        retData.func = function()
            self.__cost = 1
            self:__refreshCost()
        end
    end
    
    self.__ui:setPanelMin(retData)
end

function HiddenMeridianSpeedUpPresenter:__createBeganFunc(callback)
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

function HiddenMeridianSpeedUpPresenter:__clearHandle()
    if self.__handle ~= nil then
        self:unschedule(self.__handle)
        self.__handle = nil
    end
end

function HiddenMeridianSpeedUpPresenter:__setButtonDec()
    local retData = {
        bright = false,
        beganFunc = EMPTY_FUNC,
        endedFunc = EMPTY_FUNC,
        canceledFunc = EMPTY_FUNC
    }
    if self.__cost > 1 then
        retData["bright"] = true
        retData["beganFunc"] =
            self:__createBeganFunc(
            function()
                if self.__cost <= 1 then
                    self:__clearHandle()
                    return
                end

                self.__cost = self.__cost - 1

                self:__refreshCost()
            end
        )

        retData["endedFunc"] = function()
            self.__cost = self.__cost - 1

            self:__refreshCost()

            self:__clearHandle()
        end
        retData["canceledFunc"] = function()
            self:__clearHandle()
        end
    end

    self.__ui:setButtonDec(retData)
end

function HiddenMeridianSpeedUpPresenter:__setButtonAdd()
    local retData = {
        bright = false,
        beganFunc = EMPTY_FUNC,
        endedFunc = EMPTY_FUNC,
        canceledFunc = EMPTY_FUNC
    }
    if self.__material > 0 and self.__cost < self:__getMaxCost() then
        retData["bright"] = true
        retData["beganFunc"] =
            self:__createBeganFunc(
            function()
                if self.__cost >= self:__getMaxCost() then
                    self:__clearHandle()
                    return
                end

                self.__cost = self.__cost + 1

                self:__refreshCost()
            end
        )

        retData["endedFunc"] = function()
            self.__cost = self.__cost + 1

            self:__refreshCost()

            self:__clearHandle()
        end
        retData["canceledFunc"] = function()
            self:__clearHandle()
        end
    end

    self.__ui:setButtonAdd(retData)
end

function HiddenMeridianSpeedUpPresenter:__setPanelMax()
    local retData = {}

    if self.__cost >= self:__getMaxCost() then
        retData.image = "Image/UI/AttrUI/jiali02b.png"
        retData.color = {r = 255, g = 255, b = 255}
		retData.func = EMPTY_FUNC
    else
        retData.image = "Image/UI/AttrUI/jiali02.png"
        retData.color = {r = 0, g = 204, b = 0}
        retData.func = function()
            self.__cost = self:__getMaxCost()
            self:__refreshCost()
        end
    end
    
    self.__ui:setPanelMax(retData)
end

function HiddenMeridianSpeedUpPresenter:__setButtonConfirm(func)
    self.__ui:setButtonConfirm(function()
        if self.__confirmFunc then
            self.__confirmFunc(self.__cost)
        end
    end)
end

function HiddenMeridianSpeedUpPresenter:__setButtonCancel(func)
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end


Helper:classDefNodeGetInstance(HiddenMeridianSpeedUpPresenter)
return HiddenMeridianSpeedUpPresenter
0000000000000
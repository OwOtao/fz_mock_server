local SpeedUpGuaJiPresenter = class("SpeedUpGuaJiPresenter", cc.Layer)

function SpeedUpGuaJiPresenter:create()
    local p = SpeedUpGuaJiPresenter:new()
    p:init()
    return p
end

function SpeedUpGuaJiPresenter:init()
    self.__ui = require("app.views.ui.FistFootUI.SpeedUpGuaJiUI"):create()

    self.__ui:addTo(self)
end

function SpeedUpGuaJiPresenter:showLayer()
    self.__touchTime = 0

    self.__cost = 1

    self:setMaterialNum()
    self:setTextTime()
    self:refreshCost()
    self:setButtonConfirm()
    self:setButtonCancel()

    self.__ui:show()
end

function SpeedUpGuaJiPresenter:setRole(role)
    self.__role = role
end

function SpeedUpGuaJiPresenter:setMaterialNum()
    self.__material = self.__role:getFistFootSystem():getAccpoint()
end

function SpeedUpGuaJiPresenter:setResidueTime(time)
    local hour, min, sec = Helper:sec2timeDsc(time)

    min = hour * 60 + min + math.min(sec,1) 

    self.__residueMinTime = min

    local mod, remainder = math.modf(self.__residueMinTime / 5)

    if math.ceil(remainder) == 1 then
        mod = mod + 1
    end

    self.__maxCost = mod
end

function SpeedUpGuaJiPresenter:getMaxCost()
    return math.min(self.__material,self.__maxCost)
end

function SpeedUpGuaJiPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "SpeedUpGuaJiPresenter",
        function(layer)
            self.__ui:hide()
        end
    )
end

function SpeedUpGuaJiPresenter:setTextDesc()
    local resName = User:getRole():getCHAttrName("accpoint")
    local text = "当前拥有"..self.__material.."点"..resName.."，是否消耗"..self.__cost.."点加速资源加快完成此任务？"
    self.__ui:setTextDesc(text)
end

function SpeedUpGuaJiPresenter:setTextTime()
    self.__ui:setTextTime("预估剩余时间："..self.__residueMinTime .. "分钟")
end

function SpeedUpGuaJiPresenter:setTextNum()
    self.__ui:setTextNum(self.__cost)
end

function SpeedUpGuaJiPresenter:setSpeedTime()
    self.__speedTime = self.__cost * 3600
end

function SpeedUpGuaJiPresenter:setTextSpeedTime()
    local time = self.__cost * 5
    self.__ui:setTextSpeedTime("可加速时间："..time.."分钟")
end

function SpeedUpGuaJiPresenter:refreshCost()
    self:setTextDesc()
    self:setTextNum()
    self:setSpeedTime()
    self:setTextSpeedTime()
    self:setPanelMin()
    self:setButtonDec()
    self:setButtonAdd()
    self:setPanelMax()
end

function SpeedUpGuaJiPresenter:setPanelMin()
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
            self:refreshCost()
        end
    end
    
    self.__ui:setPanelMin(retData)
end

function SpeedUpGuaJiPresenter:createBeganFunc(callback)
    local function retFunc()
        local currTime = GetTime()

        if currTime - self.__touchTime < 0.3 then
            return
        end

        self.__touchTime = currTime

        self:clearHandle()

        local total_time = 0

        self._handle =
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

function SpeedUpGuaJiPresenter:clearHandle()
    if self._handle ~= nil then
        self:unschedule(self._handle)
        self._handle = nil
    end
end


function SpeedUpGuaJiPresenter:setButtonDec()
    local retData = {
        bright = false,
        beganFunc = EMPTY_FUNC,
        endedFunc = EMPTY_FUNC,
        canceledFunc = EMPTY_FUNC
    }
    if self.__cost > 1 then
        retData["bright"] = true
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self.__cost <= 1 then
                    self:clearHandle()
                    return
                end

                self.__cost = self.__cost - 1

                self:refreshCost()
            end
        )

        retData["endedFunc"] = function()
            self.__cost = self.__cost - 1

            self:refreshCost()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonDec(retData)
end

function SpeedUpGuaJiPresenter:setButtonAdd()
    local retData = {
        bright = false,
        beganFunc = EMPTY_FUNC,
        endedFunc = EMPTY_FUNC,
        canceledFunc = EMPTY_FUNC
    }
    if self.__material > 0 and self.__cost < self:getMaxCost() then
        retData["bright"] = true
        retData["beganFunc"] =
            self:createBeganFunc(
            function()
                if self.__cost >= self:getMaxCost() then
                    self:clearHandle()
                    return
                end

                self.__cost = self.__cost + 1

                self:refreshCost()
            end
        )

        retData["endedFunc"] = function()
            self.__cost = self.__cost + 1

            self:refreshCost()

            self:clearHandle()
        end
        retData["canceledFunc"] = function()
            self:clearHandle()
        end
    end

    self.__ui:setButtonAdd(retData)
end

function SpeedUpGuaJiPresenter:setPanelMax()
    local retData = {}

    if self.__cost >= self:getMaxCost() then
        retData.image = "Image/UI/AttrUI/jiali02b.png"
        retData.color = {r = 255, g = 255, b = 255}
		retData.func = EMPTY_FUNC
    else
        retData.image = "Image/UI/AttrUI/jiali02.png"
        retData.color = {r = 0, g = 204, b = 0}
        retData.func = function()
            self.__cost = self:getMaxCost()
            self:refreshCost()
        end
    end
    
    self.__ui:setPanelMax(retData)
end

function SpeedUpGuaJiPresenter:setButtonConfirm(func)
    self.__ui:setButtonConfirm(function()
        self.__role:getFistFootSystem():speedUpFistTask(self.__cost,function(isOk,msg)
            if isOk then
                self:hideLayer()
            else
                PopText(msg)
            end
        end)
    end)
end

function SpeedUpGuaJiPresenter:setButtonCancel(func)
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end


Helper:classDefNodeGetInstance(SpeedUpGuaJiPresenter)
return SpeedUpGuaJiPresenter
0000
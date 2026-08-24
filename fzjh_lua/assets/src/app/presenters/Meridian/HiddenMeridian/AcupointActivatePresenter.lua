local AcupointActivatePresenter = class("AcupointActivatePresenter", LayerEx)

function AcupointActivatePresenter:create()
    return AcupointActivatePresenter:new()
end

--@desc: 
--@author:LvBin
--@time:2025-01-21 11:16:11
--@Iinput: [src.app.models.Meridian.HiddenMeridianInteractor#HiddenMeridianInteractor]
--@return
function AcupointActivatePresenter:setInput(Iinput)
    self.__input = Iinput
end

function AcupointActivatePresenter:setUI(ui)
    self.__ui = ui

    self.__ui:addTo(self)
end

function AcupointActivatePresenter:setCallFunc(func)
    self.__callFunc = func
end

function AcupointActivatePresenter:showPresenter(acupointId)
    self.__acupointId = acupointId

    self.__role = self.__input:getRole()

    self.__sys = self.__role:getHiddenMeridianSystem()

    self.__ui:setTextDesc("是否确认消耗以下资源进行冲脉？")

    self:__showTextResources()

    self:__showTextTime()

    self.__ui:setButton1(
        "取消",
        function()
            Audio:playEffect("xiaoAnNiu")
            self:hidePresenter()
        end
    )

    self.__ui:setButton2(
        "冲脉",
        function()
            Audio:playEffect("xiaoAnNiu")
            self.__sys:acupointActivate(
            self.__acupointId,
            function(isOk,msg)
                if isOk then
                    if self.__callFunc then
                        self.__callFunc()
                    end

                    self:hidePresenter()
                else
                    PopText(msg)
                end
            end)
        end
    )

    self.__ui:showUI()
end

function AcupointActivatePresenter:__showTextResources()
    local text = ""

    local resources = self.__sys:getAcupoint(self.__acupointId):getResource()

    if MapIsEmpty(resources) then
        text = "无"
    else     
        for i,v in ipairs(resources) do
            local name = Role:getCHAttrName(v[1])
    
            local num = v[2]
            
            text = text..name..":"..num.."\n"
        end
    end

    self.__ui:setTextResouce(text)
end

function AcupointActivatePresenter:__showTextTime()
    local time = self.__sys:getAcupoint(self.__acupointId):getTime()

    local hour, min, sec = Helper:sec2timeDsc(time)
    
    self.__ui:setTextTime(hour .. "小时" .. min .. "分钟" .. sec .. "秒")
end

function AcupointActivatePresenter:hidePresenter()
    PopupLayerController:hideLayer("AcupointActivatePresenter", function(layer)
        self.__ui:hideUI()
    end, 0)
end

Helper:classDefNodeGetInstance(AcupointActivatePresenter)
return AcupointActivatePresenter00
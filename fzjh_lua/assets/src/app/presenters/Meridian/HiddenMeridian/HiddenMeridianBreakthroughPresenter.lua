local HiddenMeridianBreakthroughPresenter = class("HiddenMeridianBreakthroughPresenter", LayerEx)

function HiddenMeridianBreakthroughPresenter:create()
    return HiddenMeridianBreakthroughPresenter:new()
end

--@desc: 
--@author:LvBin
--@time:2025-01-21 11:16:11
--@Iinput: [src.app.models.Meridian.HiddenMeridianInteractor#HiddenMeridianInteractor]
--@return
function HiddenMeridianBreakthroughPresenter:setInput(Iinput)
    self.__input = Iinput
end

function HiddenMeridianBreakthroughPresenter:setUI(ui)
    self.__ui = ui

    self.__ui:addTo(self)
end

function HiddenMeridianBreakthroughPresenter:setCallFunc(func)
    self.__callFunc = func
end

function HiddenMeridianBreakthroughPresenter:showPresenter()
    self.__role = self.__input:getRole()

    self.__sys = self.__role:getHiddenMeridianSystem()

    self.__ui:setTextDesc("是否进行破境，进行破境时进入引气通络状态，保留当前境界属性到下一阶中，每次对下一阶隐脉图进行冲脉时，都会降低一部分引气通络属性，直至下一阶全部冲脉完成后解除引气通络状态，也可以随时进行手动解除。")

    local nextLv = self.__sys:getHiddenMeridianChartLv() + 1

    self.__ui:setTextType1(self.__input:getAcupointLvName(1)..":"..self.__input:getHiddenMeridianChartAcupointNum(nextLv,1))

    self.__ui:setTextType2(self.__input:getAcupointLvName(2)..":"..self.__input:getHiddenMeridianChartAcupointNum(nextLv,2))

    self.__ui:setTextType3(self.__input:getAcupointLvName(3)..":"..self.__input:getHiddenMeridianChartAcupointNum(nextLv,3))

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
        "破境",    
        function()
            Audio:playEffect("xiaoAnNiu")
            self.__sys:breakThrough(function(isOk,msg)
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

function HiddenMeridianBreakthroughPresenter:__showTextResources()
    local text = ""

    local resources = self.__sys:getHiddenMeridianChart():getResource()

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

function HiddenMeridianBreakthroughPresenter:__showTextTime()
    local time = self.__sys:getHiddenMeridianChart():getTime()

    local hour, min, sec = Helper:sec2timeDsc(time)
    
    self.__ui:setTextTime(hour .. "小时" .. min .. "分钟" .. sec .. "秒")
end

function HiddenMeridianBreakthroughPresenter:hidePresenter()
    PopupLayerController:hideLayer("HiddenMeridianBreakthroughPresenter", function(layer)
        self.__ui:hideUI()
    end, 0)
end

Helper:classDefNodeGetInstance(HiddenMeridianBreakthroughPresenter)
return HiddenMeridianBreakthroughPresenter000000
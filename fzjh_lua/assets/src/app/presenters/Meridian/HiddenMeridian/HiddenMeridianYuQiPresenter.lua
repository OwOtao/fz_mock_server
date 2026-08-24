local HiddenMeridianConstants = require("app.models.Meridian.HiddenMeridianConstants")

local HiddenMeridianYuQiPresenter = class("HiddenMeridianYuQiPresenter", LayerEx)

function HiddenMeridianYuQiPresenter:create()
    return HiddenMeridianYuQiPresenter:new()
end

--@desc: 
--@author:LvBin
--@time:2025-01-21 11:16:11
--@Iinput: [src.app.models.Meridian.HiddenMeridianInteractor#HiddenMeridianInteractor]
--@return
function HiddenMeridianYuQiPresenter:setInput(Iinput)
    self.__input = Iinput
end

function HiddenMeridianYuQiPresenter:setUI(ui)
    self.__ui = ui

    self.__ui:addTo(self)
end

function HiddenMeridianYuQiPresenter:setCallFunc(func)
    self.__callFunc = func
end

function HiddenMeridianYuQiPresenter:showPresenter()
    self.__role = self.__input:getRole()

    self.__sys = self.__role:getHiddenMeridianSystem()

    self.__ui:setTextDesc("这是当前获得的余炁状态，余炁是上一个玄络图成功破境后尚未散尽的经脉加成，若不满意当前余炁带来的加成，可进行主动解除余炁状态。")

    self.__ui:setTextYuQi("当前余炁效果:" .. tostring(self.__sys:getYuQiRatio() * 100).."%")

    self:__showYuQiBuffAttr()

    self.__ui:setButton1(
        "返回",    
        function()
            Audio:playEffect("xiaoAnNiu")
            self:hidePresenter()
        end
    )

    self.__ui:setButton2(
        "解除余炁",      
        function()
            Audio:playEffect("xiaoAnNiu")

            self.__ui:setTextDesc("是否确认解除余炁状态，余炁状态一旦解除后，在下次破境完成前将无法重新获取，请慎重考虑。")
            
            self.__ui:setButton2(
                "确认解除", 
                function()
                    Audio:playEffect("xiaoAnNiu")
                    
                    self.__sys:removeYuQi(
                        function(isOk,msg)
                            if isOk then
                                if self.__callFunc then
                                    self.__callFunc()
                                end

                                self:hidePresenter()
                            else
                                PopText(msg)
                            end
                        end
                    )
                end
            )
        end
    )

    self.__ui:showUI()
end

function HiddenMeridianYuQiPresenter:__showYuQiBuffAttr()
    self.__ui:removeListViewAllItems()

    local buffAttrList = self.__input:getYuQiBuffAttrList()

    if #buffAttrList == 0 then
        return
    end

    local maxPanelCount, isRemain = math.modf(#buffAttrList / 2)

    if isRemain > 0 then
        maxPanelCount = maxPanelCount + 1
    end

    for i = 1, maxPanelCount do
        local panel = self.__ui:createPanelAttr()

        self.__ui:insertPanelToListView(panel)

        for _i = 1, 2 do
            local index = (i-1) * 2 + _i

            if buffAttrList[index] then
                local attrName = buffAttrList[index].name

                local value = Helper:mathFloor(buffAttrList[index].value * HiddenMeridianConstants.BuffAttrMult)
                
                panel["Text_attr".._i]:setVisible(true)

                panel["Text_attr".._i]:setString(attrName.." "..value)
            else
                panel["Text_attr".._i]:setVisible(false)
            end 
        end
    end

    local effectTextList = self.__sys:getYuQiBuffEffectText()

    if MapIsEmpty(effectTextList) == false then
        self.__ui:removeEffectListViewAllItems()

        local panel = self.__ui:createPanelEffectText()

        self.__ui:insertPanelToEffectListView(panel) 

        local text = ""

        for i, v in ipairs(effectTextList) do
            text = text..v
            if i < #effectTextList then
                text = text.. "\n"
            end
        end

        panel.Text_effect:setString(text)
    end
    
end

function HiddenMeridianYuQiPresenter:hidePresenter()
    PopupLayerController:hideLayer("HiddenMeridianYuQiPresenter", function(layer)
        self.__ui:hideUI()
    end, 0)
end

Helper:classDefNodeGetInstance(HiddenMeridianYuQiPresenter)
return HiddenMeridianYuQiPresenter000000000000
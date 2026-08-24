local HiddenMeridianUnlockBuffPresenter = class("HiddenMeridianUnlockBuffPresenter", LayerEx)

function HiddenMeridianUnlockBuffPresenter:create()
    return HiddenMeridianUnlockBuffPresenter:new()
end

--@desc: 
--@author:LvBin
--@time:2025-01-21 11:16:11
--@Iinput: [src.app.models.Meridian.HiddenMeridianInteractor#HiddenMeridianInteractor]
--@return
function HiddenMeridianUnlockBuffPresenter:setInput(Iinput)
    self.__input = Iinput
end

function HiddenMeridianUnlockBuffPresenter:setUI(ui)
    self.__ui = ui

    self.__ui:addTo(self)
end

function HiddenMeridianUnlockBuffPresenter:setCallFunc(func)
    self.__callFunc = func
end

function HiddenMeridianUnlockBuffPresenter:showPresenter(meridianBuffId)
    self.__meridianBuffId = meridianBuffId

    self.__role = self.__input:getRole()

    self.__sys = self.__role:getHiddenMeridianSystem()

    self.__ui:setTextDesc("是否确认消耗以下资源解锁对应玄络？")

    self:__showTextResources()

    self.__ui:setTextUnlock(self.__sys:getHiddenMeridianBuff(self.__meridianBuffId):getUnlockText())

    self.__ui:setButton1(
        "取消",    
        function()
            Audio:playEffect("xiaoAnNiu")
            self:hidePresenter()
        end
    )

    self.__ui:setButton2(
        "解锁",    
        function()
            Audio:playEffect("xiaoAnNiu")
            if self.__sys:canUnlockBuff(self.__meridianBuffId) then
                self.__sys:unlockBuff(self.__meridianBuffId,
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
            else
                PopText("当前未达成玄络所需解锁条件，解锁失败")
            end
        end
    )

    self.__ui:showUI()
end

function HiddenMeridianUnlockBuffPresenter:__showTextResources()
    local text = ""

    local resources = self.__sys:getHiddenMeridianBuff(self.__meridianBuffId):getResource()

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

function HiddenMeridianUnlockBuffPresenter:hidePresenter()
    PopupLayerController:hideLayer("HiddenMeridianUnlockBuffPresenter", function(layer)
        self.__ui:hideUI()
    end, 0)
end

Helper:classDefNodeGetInstance(HiddenMeridianUnlockBuffPresenter)
return HiddenMeridianUnlockBuffPresenter0000000
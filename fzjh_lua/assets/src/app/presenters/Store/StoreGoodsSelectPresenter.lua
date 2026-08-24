local StoreGoodsSelectPresenter = class("StoreGoodsSelectPresenter", cc.Layer)

function StoreGoodsSelectPresenter:create()
    local p = StoreGoodsSelectPresenter:new()
    p:init()
    return p
end

function StoreGoodsSelectPresenter:init()
    self._ui = require("app.views.ui.Dialog.SelectNumberItemUI"):create()

    self._ui:addTo(self)

    self._ui:setImageGoodsVisible(false)

    self._ui:setTextHorizontalAlignmentWithType("Text_desc_3",1)

    self._ui:setTextHorizontalAlignmentWithType("Text_desc_1",0)

    self._ui:setTextDescPositionX("Text_desc_3", 540)

    self._ui:setTextVisible("Text_3", false)

    self._ui:setTextVisible("Text_4", false)

    self._ui:setTextVisible("Text_5", true)

    self._ui:setTextVisible("Text_6", true)

    self._ui:setTextVisible("Text_7", true)

    self.__buyNumber = 0

    self.__maxBuyNumber = 0
end

function StoreGoodsSelectPresenter:showLayer()
    self._ui:showUI()
    self:__initSelectButton()
end

function StoreGoodsSelectPresenter:hideLayer()
    PopupLayerController:hideLayer("StoreGoodsSelectPresenter",function()
        self._ui:hideUI()
    end)
end

function StoreGoodsSelectPresenter:setBuyNumber(num)
    self.__buyNumber = num
end

function StoreGoodsSelectPresenter:setMaxBuyNumber(num)
    self.__maxBuyNumber = num
end

function StoreGoodsSelectPresenter:setLimitBuyNumber(num)
    self.__limitBuyNumber = num
end

function StoreGoodsSelectPresenter:setUnitPrice(price)
    self.__unitPrice = price
end

function StoreGoodsSelectPresenter:setPriceName(name)
    self.__priceName = name
end

function StoreGoodsSelectPresenter:setGoodsUnitCount(count)
    self.__goodsUnitCount = count
end

function StoreGoodsSelectPresenter:setItemName(name)
    self.__itemName = name
end

function StoreGoodsSelectPresenter:setTitle(title)
    self._ui:setTitleText(title)
end

function StoreGoodsSelectPresenter:setTextDesc_1(str)
    self._ui:setTextDescStr("Text_desc_1", str)
end

function StoreGoodsSelectPresenter:setTextDesc_2(str)
    self._ui:setTextDescStr("Text_desc_2", str)
end

function StoreGoodsSelectPresenter:setTextDesc_3(str1, str2)
    local str = self:__getReturnString(str1, str2)
    self._ui:setTextDescStr("Text_desc_3", str)
end


function StoreGoodsSelectPresenter:setText_1Str(str)
    self._ui:setTextStr("Text_1", str)
end

function StoreGoodsSelectPresenter:setText_2Str(str)
    self._ui:setTextStr("Text_2", str)
end

function StoreGoodsSelectPresenter:setText_3Str(str)
    self._ui:setTextStr("Text_5", str)
end

function StoreGoodsSelectPresenter:setText_4Str(str)
    self._ui:setTextStr("Text_6", str)
end

function StoreGoodsSelectPresenter:setText_5Str(str)
    self._ui:setTextStr("Text_7", str)
end

function StoreGoodsSelectPresenter:setSelectText(str)
    self._ui:setSelectTextStr(str)
end

function StoreGoodsSelectPresenter:setButton_1Func(func)
    local func = function()
        func(self.__buyNumber)
        self:hideLayer()
    end
    self._ui:setButton_1Func(func)
end

function StoreGoodsSelectPresenter:setButton_2Func(func)
    self._ui:setButton_2Func(func)
end

function StoreGoodsSelectPresenter:__initSelectButton()
    self.__touchTime = 0
    self:__updateSelectBtnUI()
    self:__setSelectLeft_1Func()
    self:__setSelectLeft_2Func()
    self:__setSelectRight_1Func()
    self:__setSelectRight_2Func()
end

function StoreGoodsSelectPresenter:__updateSelectBtnUI()
    local maxBuyNumber = self.__maxBuyNumber
    if self.__limitBuyNumber and self.__limitBuyNumber < maxBuyNumber then
        maxBuyNumber = self.__limitBuyNumber
    end
    
    if maxBuyNumber - self.__buyNumber >= 1 then
        self:__setSelectRight_1Texture("Image/UI/AttrUI/jiali02.png")
        self:__setSelectRight_1Enable(true)
    else
        self:__setSelectRight_1Texture("Image/UI/AttrUI/jiali02b.png")
        self:__setSelectRight_1Enable(false)
    end

    if maxBuyNumber - self.__buyNumber >= 10 then
        self:__setSelectRight_2Texture("Image/UI/AttrUI/jiali02.png")
        self:__setSelectRight_2Enable(true)
    else
        self:__setSelectRight_2Texture("Image/UI/AttrUI/jiali02b.png")
        self:__setSelectRight_2Enable(false)
    end

    if self.__buyNumber > 1 then
        self:__setSelectLeft_2Texture("Image/UI/AttrUI/leftbright.png")
        self:__setSelectLeft_2Enable(true)
    else
        self:__setSelectLeft_2Texture("Image/UI/AttrUI/leftgrey.png")
        self:__setSelectLeft_2Enable(false)
    end

    if self.__buyNumber > 10 then
        self:__setSelectLeft_1Texture("Image/UI/AttrUI/leftbright.png")
        self:__setSelectLeft_1Enable(true)
    else
        self:__setSelectLeft_1Texture("Image/UI/AttrUI/leftgrey.png")
        self:__setSelectLeft_1Enable(false)
    end
end

function StoreGoodsSelectPresenter:__refreshUI()
    self:__updateSelectBtnUI()
    self:setSelectText(tostring(self.__buyNumber).."/"..tostring(self.__maxBuyNumber))
    
    self:setTextDesc_3(self.__itemName, self.__buyNumber * self.__goodsUnitCount)

    self:setText_2Str(tostring(self.__unitPrice * self.__buyNumber)..self.__priceName)
end

function StoreGoodsSelectPresenter:__getReturnString(desc1, desc2)
	local str = ""
	if not desc1 and not desc2 then
	elseif not desc1 then
		str = desc2
	elseif not desc2 then
		str = desc1
	else
		if type(desc2) == "number" then
			str = tostring(desc1).."x"..tostring(desc2)	
		else
			str = tostring(desc1).."\n"..tostring(desc2)	
		end
	end
	return str
end

function StoreGoodsSelectPresenter:__setSelectLeft_1Func()
    local func1 = self:__update(function()
        if self.__buyNumber - 10 > 0 then
            self.__buyNumber = self.__buyNumber - 10
            self:__refreshUI()
        else
            self:__stopSchedule()
        end
    end)

    local func2 = function()
        if self.__buyNumber - 10 > 0 then
            self.__buyNumber = self.__buyNumber - 10
            self:__refreshUI()
        end
        
        self:__stopSchedule()
    end

    local func3 = function()
        self:__stopSchedule()
    end

    self._ui:setSelectButtonFunc("Button_left_1", func1, func2, func3)
end

function StoreGoodsSelectPresenter:__setSelectLeft_2Func()
    local func1 = self:__update(function()
        if self.__buyNumber - 1 >= 1 then
            self.__buyNumber = self.__buyNumber - 1
            self:__refreshUI()
        else
            self:__stopSchedule()
        end
    end)

    local func2 = function()
        if self.__buyNumber - 1 >= 1 then
            self.__buyNumber = self.__buyNumber - 1
            self:__refreshUI()
        end
        
        self:__stopSchedule()
    end

    local func3 = function()
        self:__stopSchedule()
    end

    self._ui:setSelectButtonFunc("Button_left_2", func1, func2, func3)
end

function StoreGoodsSelectPresenter:__setSelectRight_1Func()
    local func1 = self:__update(function()
        if self.__maxBuyNumber - self.__buyNumber >= 1 then
            self.__buyNumber = self.__buyNumber + 1
            self:__refreshUI()
        else
            self:__stopSchedule()
        end
    end)

    local func2 = function()
        if self.__maxBuyNumber - self.__buyNumber >= 1 then
            self.__buyNumber = self.__buyNumber + 1
            self:__refreshUI()
        end
        
        self:__stopSchedule()
    end

    local func3 = function()
        self:__stopSchedule()
    end

    self._ui:setSelectButtonFunc("Button_right_1", func1, func2, func3)
end

function StoreGoodsSelectPresenter:__setSelectRight_2Func()
    local func1 = self:__update(function()
        if self.__maxBuyNumber - self.__buyNumber >= 10 then
            self.__buyNumber = self.__buyNumber + 10
            self:__refreshUI()
        else
            self:__stopSchedule()
        end
    end)

    local func2 = function()
        if self.__maxBuyNumber - self.__buyNumber >= 10 then
            self.__buyNumber = self.__buyNumber + 10
            self:__refreshUI()
        end

        self:__stopSchedule()
    end

    local func3 = function()
        self:__stopSchedule()
    end

    self._ui:setSelectButtonFunc("Button_right_2", func1, func2, func3)
end

function StoreGoodsSelectPresenter:__update(callback)
    local function retFunc()
        local currTime = GetTime()

        if currTime - self.__touchTime < 0.3 then
            return
        end

        self.__touchTime = currTime

        self:__stopSchedule()

        local total_time = 0

        self.__handle =
            self:schedule(
            function(ft)
                total_time = total_time + ft
                if total_time > 1.25 then
                    if callback then
                        callback()
                    end
                end
            end
        )
    end
    return retFunc
end

function StoreGoodsSelectPresenter:__stopSchedule()
    if self.__handle then
        self:unschedule(self.__handle)
        self.__handle = nil
    end
end

function StoreGoodsSelectPresenter:__setSelectLeft_1Enable(enable)
    self._ui:setSelectButtonEnable("Button_left_1", enable)
end

function StoreGoodsSelectPresenter:__setSelectLeft_2Enable(enable)
    self._ui:setSelectButtonEnable("Button_left_2", enable)
end

function StoreGoodsSelectPresenter:__setSelectRight_1Enable(enable)
    self._ui:setSelectButtonEnable("Button_right_1", enable)
end

function StoreGoodsSelectPresenter:__setSelectRight_2Enable(enable)
    self._ui:setSelectButtonEnable("Button_right_2", enable)
end

function StoreGoodsSelectPresenter:__setSelectLeft_1Texture(texture)
    self._ui:setSelectButtonTexture("Button_left_1", texture)
end

function StoreGoodsSelectPresenter:__setSelectLeft_2Texture(texture)
    self._ui:setSelectButtonTexture("Button_left_2", texture)
end

function StoreGoodsSelectPresenter:__setSelectRight_1Texture(texture)
    self._ui:setSelectButtonTexture("Button_right_1", texture)
end

function StoreGoodsSelectPresenter:__setSelectRight_2Texture(texture)
    self._ui:setSelectButtonTexture("Button_right_2", texture)
end

Helper:classDefNodeGetInstance(StoreGoodsSelectPresenter)

return StoreGoodsSelectPresenter
00
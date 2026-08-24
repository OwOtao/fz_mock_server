local SelectNumberItemUI = class("SelectNumberItemUI", cc.Layer)

function SelectNumberItemUI:create()
	local p = SelectNumberItemUI:new()
	p:init()
	return p
end

function SelectNumberItemUI:init()
	self._round = require("Layer/Dialog/SelectNumberItemUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点
end

function SelectNumberItemUI:showUI()
    self:show()
end

function SelectNumberItemUI:hideUI()
    self:hide()
end

function SelectNumberItemUI:setTitleText(str)
    self.Text_title:setString(str)
end

function SelectNumberItemUI:setTextDescStr(text, str)
    self[text]:setString(str)
end

function SelectNumberItemUI:setTextHorizontalAlignmentWithType(text, type)
    self[text]:setTextHorizontalAlignment(type)
end

function SelectNumberItemUI:setTextDescPositionX(text, x)
    self[text]:setPositionX(x)
end

function SelectNumberItemUI:setImageGoodsVisible(visible)
    visible = Helper:getDef(visible, false)
    self.Image_Goods:setVisible(visible)
end

function SelectNumberItemUI:setImageGoodsTexture(texture)
    if not texture then
        self.Image_Goods:setVisible(false)
    end

    self.Image_Goods:loadTexture(texture)
end

function SelectNumberItemUI:setButton_1Func(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function SelectNumberItemUI:setButton_2Func(func)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function SelectNumberItemUI:setTextStr(text, str)
    if self[text] then
        self[text]:setString(str)
    end
end

function SelectNumberItemUI:setTextVisible(text, visible)
    if self[text] then
        self[text]:setVisible(visible)
    end
end

function SelectNumberItemUI:setTextFunc(text, func)
    if self[text] then
        self[text]:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function SelectNumberItemUI:setSelectButtonFunc(btn, beganFunc, endedFunc, canceledFunc)
    if self.Panel_select[btn] then
        self.Panel_select[btn]:releaseFuncTotally(function()
            if beganFunc then
                beganFunc()
            end
        end,function()
            if endedFunc then
                endedFunc()
            end
        end,function()
            if canceledFunc then
                canceledFunc()
            end
        end)
    end
end

function SelectNumberItemUI:setSelectButtonEnable(btn, enable)
    if self.Panel_select[btn] then
        self.Panel_select[btn]:setTouchEnabled(enable)
    end
end

function SelectNumberItemUI:setSelectButtonTexture(btn, texture)
    if self.Panel_select[btn] then
        self.Panel_select[btn]:loadTextureNormal(texture)
    end
end

function SelectNumberItemUI:setSelectTextStr(str)
    self.Panel_select.Text_num:setString(str)
end

return SelectNumberItemUI00
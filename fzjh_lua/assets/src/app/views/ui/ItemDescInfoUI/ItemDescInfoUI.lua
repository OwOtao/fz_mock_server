local ItemDescInfoUI = class("ItemDescInfoUI", cc.Layer)

function ItemDescInfoUI:create()
	local p = ItemDescInfoUI:new()
	p:init()
	return p
end

function ItemDescInfoUI:init()
	self._UI = require("Layer/ShenBing/ShenBingInfo.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUI(self)

	self.Text_desc:setVisible(false)
	self:show()
end

function ItemDescInfoUI:setHideButtonFunc(func)
	self.Button_YiShi:releaseFunc(function()
        if func then
            func()
        end
	end)

    self.Panel_back:releaseFunc(function()
        if func then
            func()
        end
	end)
end

function ItemDescInfoUI:setScoreText(score)
	self.Text_title:setString(score)
end

function ItemDescInfoUI:setScoreVisible(visible)
	self.Text_OuYeZi_title:setVisible(visible)
	self.Text_title:setVisible(visible)
end

function ItemDescInfoUI:setNameText(name)
    self.Text_Equip_Name:setColor(cc.c3b(208, 208, 208))
    self.Text_Equip_Name:setString(Helper:getDef(name,""))
end

function ItemDescInfoUI:setDamageText(damage)
    self.Text_Equip_Atk:setString(damage)
end

function ItemDescInfoUI:setProtectText(protect)
    self.Text_Equip_Atk:setString(protect)
end

function ItemDescInfoUI:setDescText(desc)
    self:__initRichText()
    self.RichText_print:pushBackText(desc, cc.c3b(127, 127, 127), 255, Resource:getFontPath("default"),48)
    self:delayFunc(0.1,function ()
		self.RichText_print:jumpToTop()
	end)
end

function ItemDescInfoUI:setAttributeText(index, attrName, attrDesc)
    if index == 1 then
        self:__setAttribute_1Text(attrName, attrDesc)
    elseif index == 2 then
        self:__setAttribute_2Text(attrName, attrDesc)
    elseif index == 3 then
        self:__setAttribute_3Text(attrName, attrDesc)
    elseif index == 4 then
        self:__setAttribute_4Text(attrName, attrDesc)
    elseif index == 5 then
        self:__setAttribute_5Text(attrName, attrDesc)
    elseif index == 6 then
        self:__setAttribute_6Text(attrName, attrDesc)
    end
end

function ItemDescInfoUI:setAttributePanelFunc(index, func)
    local panel = self["Panel_"..tostring(index)]
    if panel then
        Helper:convertUIByParent(panel)
        panel:releaseFunc(function()
            panel.Image_8:setVisible(false)
            self.Panel_desc:setVisible(true)

            self:setTipsPanelBackFunc(function()
                panel.Image_8:setVisible(true)
                self.Panel_desc:setVisible(false)
            end)

            if func then
                func()
            end
        end)
    end
end

function ItemDescInfoUI:setTipsPanelBackFunc(func)
    self.Panel_desc:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ItemDescInfoUI:setTipsDesc_1Text(text)
    self.Text_desc1:setString(Helper:getDef(text,""))
end

function ItemDescInfoUI:setTipsDesc_2Text(text)
    self.Text_desc2:setString(Helper:getDef(text,""))
end

function ItemDescInfoUI:setTipsDesc_3Text(text)
    self.Text_Val:setString(Helper:getDef(text,""))
end

function ItemDescInfoUI:setAttributeTextMaskVisible(visible)
    self.Panel_8:setVisible(visible)
end

function ItemDescInfoUI:__initRichText()
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

    local x, y = self.Text_desc:getPosition()
    local size = self.Text_desc:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    self.Text_desc:getParent():addChild(self.RichText_print)
    self.RichText_print:setAnchorPoint(cc.p(0, 1))
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
    self.RichText_print:setBounceEnabled(false)
end

function ItemDescInfoUI:__setAttribute_1Text(attrName, attrDesc)
    self.Text_YingDu:setString(Helper:getDef(attrName,""))
    self.Text_Info1:setString(Helper:getDef(attrDesc,""))
end

function ItemDescInfoUI:__setAttribute_2Text(attrName, attrDesc)
    self.Text_JianRen:setString(Helper:getDef(attrName,""))
    self.Text_Info2:setString(Helper:getDef(attrDesc,""))
end

function ItemDescInfoUI:__setAttribute_3Text(attrName, attrDesc)
    self.Text_ZhuangTai:setString(Helper:getDef(attrName,""))
    self.Text_Info3:setString(Helper:getDef(attrDesc,""))
end

function ItemDescInfoUI:__setAttribute_4Text(attrName, attrDesc)
    self.Text_ZhongLiang:setString(Helper:getDef(attrName,""))
    self.Text_Info4:setString(Helper:getDef(attrDesc,""))
end

function ItemDescInfoUI:__setAttribute_5Text(attrName, attrDesc)
    self.Text_TeXin:setString(Helper:getDef(attrName,""))
    self.Text_Info5:setString(Helper:getDef(attrDesc,""))
end

function ItemDescInfoUI:__setAttribute_6Text(attrName, attrDesc)
    self.Text_TeXin_other:setString(Helper:getDef(attrName,""))
    self.Text_Info6:setString(Helper:getDef(attrDesc,""))
end

Helper:classDefNodeGetInstance(ItemDescInfoUI)
return ItemDescInfoUI
000
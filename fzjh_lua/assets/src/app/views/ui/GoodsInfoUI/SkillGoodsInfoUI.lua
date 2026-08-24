local SkillGoodsInfoUI = class("SkillGoodsInfoUI", LayerEx)

function SkillGoodsInfoUI:create()
    local p = SkillGoodsInfoUI:new()
    p:init()
    return p
end

function SkillGoodsInfoUI:init()
    self._UI = require("Layer/GoodsInfo/SkillGoodsInfoUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function SkillGoodsInfoUI:showUI()
    self:show()
end

function SkillGoodsInfoUI:hideUI()
    self:hide()
end

function SkillGoodsInfoUI:setTitle(text)
    self.Text_title:setString(text)
end

function SkillGoodsInfoUI:setTextName(name)
    self.Text_name:setString(name)
end

function SkillGoodsInfoUI:setTextDesc(text)
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

    local x, y = self.Text_detailDsc:getPosition()
    local size = self.Text_detailDsc:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    self.Text_detailDsc:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
    self.RichText_print:setBounceEnabled(false)

    self.RichText_print:pushBackText(Helper:getDef(text,""), cc.c3b(167, 167, 167), 255, Resource:getFontPath("HYCFS"),42)
    self:delayFunc(0.1,function ()
		self.RichText_print:jumpToTop()
	end)
end

function SkillGoodsInfoUI:setButtonBackVisible(bool)
    self.Button_back:setVisible(bool)
end

function SkillGoodsInfoUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function SkillGoodsInfoUI:setActiveZhaoVisible(visible)
    self.Text_1:setVisible(visible)
    self.ListView_1:setVisible(visible)
end

function SkillGoodsInfoUI:setActiveZhao(activeZhaoList)
    self.ListView_1:removeAllItems()

    for i = 1, #activeZhaoList, 1 do
        local activeZhaoPanel = self:__getActiveZhaoPanel()
        self:__initActiveZhaoPanel(activeZhaoPanel, activeZhaoList[i])
        if i % 2 == 0 then
            local panel = self.ListView_1:getItem(math.floor(i/2) - 1)
            panel:addChild(activeZhaoPanel)	
            activeZhaoPanel:setPosition(cc.p(350, 0))
        else
            local panel = self.Panel_1:clone()
            panel:addChild(activeZhaoPanel)	
            activeZhaoPanel:setPosition(cc.p(0, 0))
            self.ListView_1:pushBackCustomItem(panel)
        end
    end
end

function SkillGoodsInfoUI:getAnimFightAreaPanel()
    return self.Panel_animFightArea
end

function SkillGoodsInfoUI:getLeftFightPos1()
    return self.Panel_animFightArea.Panel_leftFightPos1:getPosition()
end

function SkillGoodsInfoUI:getRightFightPos1()
    return self.Panel_animFightArea.Panel_rightFightPos1:getPosition()
end

function SkillGoodsInfoUI:setAutoZhaoVisible(visible)
    self.Text_2:setVisible(visible)
    self.Panel_autoZhaoInfo:setVisible(visible)
end

function SkillGoodsInfoUI:initAutoZhaoPanel(panelInfo)
    self.Panel_autoZhaoInfo:releaseFunc(function()
        if panelInfo.func then
            panelInfo.func()
        end
    end)

    self.Panel_autoZhaoInfo.Text_1:setString(panelInfo.text)
end

function SkillGoodsInfoUI:__getActiveZhaoPanel()
    local panel = self.Panel_activeZhaoInfo:clone()
    Helper:convertUIByParent(panel)
    return panel
end

function SkillGoodsInfoUI:__initActiveZhaoPanel(panel, panelInfo)
    panel.Text_1:setString(panelInfo.name)
    panel:releaseFunc(function()
        if panelInfo.func then
            panelInfo.func()
        end
    end)
end


return SkillGoodsInfoUI
0000000000
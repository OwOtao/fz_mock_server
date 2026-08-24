local HiddenMeridianMenuUI = class("HiddenMeridianMenuUI", LayerEx)

function HiddenMeridianMenuUI:create()
    local p = HiddenMeridianMenuUI:new()
    p:init()
    return p
end

function HiddenMeridianMenuUI:init()
    self.__ui = require("Layer/MeridianUI/HiddenMeridian/HiddenMeridianMenuUI.lua").create()["root"]

    self.__ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function HiddenMeridianMenuUI:showUI()
    self:show()
end

function HiddenMeridianMenuUI:hideUI()
    self:hide()
end

function HiddenMeridianMenuUI:setTextLevel(text)
    self.Text_level:setString(text)
end

function HiddenMeridianMenuUI:setTextResouce(text)
    self.Text_resouce:setString(text)
end

function HiddenMeridianMenuUI:setButtonName(index,name)
    if self["Button_"..index] == nil then
        return
    end

    self["Button_"..index].Text_buttonName:setString(name)
end

function HiddenMeridianMenuUI:setButtonVisible(index,bool)
    if self["Button_"..index] == nil then
        return
    end

    self["Button_"..index]:setVisible(bool)
end

function HiddenMeridianMenuUI:setButtonFunc(index,func)
    if self["Button_"..index] == nil then
        return
    end
    self["Button_"..index]:releaseFunc(function()
        func()
    end)
end

function HiddenMeridianMenuUI:setPanelAttrInfoVisible(bool)
    self.Panel_attrInfo:setVisible(bool)
end

function HiddenMeridianMenuUI:setPanelAttrChartName(text)
    self.Panel_attrInfo.Text_name:setString(text)
end

function HiddenMeridianMenuUI:setPanelAcupointInfoVisible(bool)
    self.Panel_acupointInfo:setVisible(bool)
end

function HiddenMeridianMenuUI:setPanelBuffInfoVisible(bool)
    self.Panel_buffInfo:setVisible(bool)
end

function HiddenMeridianMenuUI:removeListViewAllItems()
    self.Panel_attrInfo.ListView_attr:removeAllItems()
end

function HiddenMeridianMenuUI:insertPanelToListView(panel)
    self.Panel_attrInfo.ListView_attr:pushBackCustomItem(panel)
end

function HiddenMeridianMenuUI:removeBuffListViewAllItems()
    self.Panel_buffInfo.ListView_buff:removeAllItems()
end

function HiddenMeridianMenuUI:insertBuffPanelToBuffListView(panel)
    self.Panel_buffInfo.ListView_buff:pushBackCustomItem(panel)
end

function HiddenMeridianMenuUI:getBuffTitlePanel()
    local panel = self.Panel_buffTitle:clone()
    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianMenuUI:getBuffAttrPanel()
    local panel = self.Panel_buffAttr:clone()
    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianMenuUI:getBuffDescPanel()
    local panel = self.Panel_buffDesc:clone()
    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianMenuUI:setPanelAcupointInfoTexts(texts)
    for i = 1, 4 do
        self.Panel_acupointInfo["Text_"..i]:setString(texts[i])
    end
end

function HiddenMeridianMenuUI:createPanelAttr()
    local panel = self.Panel_attr:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianMenuUI:getPanelChart(imageIndex)
    if self["Panel_map"..imageIndex] then
        return self["Panel_map"..imageIndex]
    end

    return nil
end

function HiddenMeridianMenuUI:hideNodeAndAllChildren(node)
    if node then
        node:setVisible(false)
        local children = node:getChildren()
        for i, child in ipairs(children) do
            child:setVisible(false)
        end
    end
end

function HiddenMeridianMenuUI:initAnimator()
    local SpineAnimator = require("third.animator.SpineAnimator.SpineAnimator")
    if self.__animator == nil then
        self.__animator = SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/UIAnim/hiddenMeridian/jingmai/jingmai.skel", "Anim/UIAnim/hiddenMeridian/jingmai/jingmai.atlas", 1), "动画初始化出错"))
        self.Panel_breakthrough.Panel_anim:addChild(self.__animator:getSkeletonAnimation())
        self.__animator:getSkeletonAnimation():setPosition(self.Panel_breakthrough.Panel_anim:getSizeWidth()/2, self.Panel_breakthrough.Panel_anim:getSizeHeight()/2)
    end
    return self.__animator
end

function HiddenMeridianMenuUI:playAnim(animName)
    self.__animator:play(animName, true)
end

function HiddenMeridianMenuUI:setPanelBreakthroughVisible(bool)
    self.Panel_breakthrough:setVisible(bool)
end

function HiddenMeridianMenuUI:setTextBreakthroughTitle(text)
    self.Panel_breakthrough.Text_title:setString(text)
end

function HiddenMeridianMenuUI:setTextBreakthroughTitle1(text)
    self.Panel_breakthrough.Text_title1:setString(text)
end

function HiddenMeridianMenuUI:setTextAcupointCount1(text)
    self.Panel_breakthrough.Text_type1:setString(text)
end

function HiddenMeridianMenuUI:setTextAcupointCount2(text)
    self.Panel_breakthrough.Text_type2:setString(text)
end

function HiddenMeridianMenuUI:setTextAcupointCount3(text)
    self.Panel_breakthrough.Text_type3:setString(text)
end

function HiddenMeridianMenuUI:setTextAcupointDesc(text)
    self.Panel_breakthrough.Text_desc:setString(text)
end

function HiddenMeridianMenuUI:setTextBreakthroughTime(text)
    self.Panel_breakthrough.Text_time:setString(text)
end

function HiddenMeridianMenuUI:setBreakthroughButton1(visible,name,func)
    self.Panel_breakthrough.Button_1:setVisible(visible)

    self.Panel_breakthrough.Button_1.Text_ButtonName:setString(name)

    self.Panel_breakthrough.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function HiddenMeridianMenuUI:setBreakthroughButton2(visible,name,func)
    self.Panel_breakthrough.Button_2:setVisible(visible)

    self.Panel_breakthrough.Button_2.Text_ButtonName:setString(name)

    self.Panel_breakthrough.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function HiddenMeridianMenuUI:setBreakthroughButton1PosY(posY)
    self.Panel_breakthrough.Button_1:setPositionY(posY)
end

function HiddenMeridianMenuUI:setBreakthroughButton2PosY(posY)
    self.Panel_breakthrough.Button_2:setPositionY(posY)
end

return HiddenMeridianMenuUI
0000000000000000
local Resource = require("app.Resource")

--@SuperType [LayerEx]
local ActiveSkillInfoForBattleUI = class("ActiveSkillInfoForBattleUI", LayerEx)

function ActiveSkillInfoForBattleUI:create()
    local p = ActiveSkillInfoForBattleUI:new()
    p:init()
    return p
end

function ActiveSkillInfoForBattleUI:init()
    self.__ui = require("Layer/SkillUI/ActiveSkillInfoForBattleUI.lua").create()["root"]
    self.__ui:addTo(self)

    Helper:convertUIByParent(self) -- 获得所有子节点

    self:setVisible(false)
end

function ActiveSkillInfoForBattleUI:setPanelBackFunc(func)
    self.Panel_back:releaseFunc(
        function()
            func()
        end
    )
end

function ActiveSkillInfoForBattleUI:setTextName(str)
    self.InfoContainerPanel.Text_Name:setString(str)
end

function ActiveSkillInfoForBattleUI:setTextTitle1(str)
    self.InfoContainerPanel.Text_Title1:setString(str)
end

function ActiveSkillInfoForBattleUI:setTextTitle2(str)
    self.InfoContainerPanel.Text_Title2:setString(str)
end

function ActiveSkillInfoForBattleUI:setTextLevel(str)
    self.InfoContainerPanel.Text_Level:setString(str)
end

function ActiveSkillInfoForBattleUI:removeAllConditionsList()
    self.InfoContainerPanel.ListView_Conditions:removeAllItems()
end

function ActiveSkillInfoForBattleUI:addStringToListView(str)
    local strItem = self:__cloneListViewItem()

    strItem:ignoreContentAdaptWithSize(true)

    strItem:setTextAreaSize({width = 800, height = 0})
    
    strItem:setString(str)

    self.InfoContainerPanel.ListView_Conditions:pushBackCustomItem(strItem)
end

function ActiveSkillInfoForBattleUI:__cloneListViewItem()
    return self.Text_Cond_Desc:clone()
end

local textColor = cc.c3b(123, 123, 123)
-- 战斗输出默认文字颜色
local textFont = Resource:getFontPath("default")
function ActiveSkillInfoForBattleUI:setTextDesc(str)
    self:__initRichText()

    self.__richPrint:pushBackText(str, textColor, 255, textFont, 38)
    self.__richPrint:pushBackNewLine(0)
end

function ActiveSkillInfoForBattleUI:__initRichText()
    if self.__richPrint then
        self.__richPrint:removeFromParent()
        self.__richPrint = nil
    end
    self.__richPrint = ExtRichTextScroll:create()
    self.InfoContainerPanel:addChild(self.__richPrint)
    local size = self.InfoContainerPanel.Text_Dsc:getContentSize()
    local x, y = self.InfoContainerPanel.Text_Dsc:getPosition()
    self.__richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
    self.__richPrint:setSize(size)
    self.__richPrint:getRichText():setVerticalSpace(5)
    self.__richPrint.fightStatusStringArray = {}
    -- 设置最大显示高度
    self.__richPrint:setTextMaxHeight(size.height)
end

Helper:classDefNodeGetInstance(ActiveSkillInfoForBattleUI)
return ActiveSkillInfoForBattleUI
000000000000000
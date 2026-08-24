--@SuperType [src.app.views.base.LayerEx#LayerEx]
local FamilyGroupRankLayer = class("FamilyGroupRankLayer", cc.Layer)

function FamilyGroupRankLayer:create()
    local p = FamilyGroupRankLayer:new()
    p:init()
    return p
end

function FamilyGroupRankLayer:init()
    self._UI = require("Layer/TeacherUI/FamilyGroupRankUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self) -- 获得所有子节点

    self.Panel_Title.Text_desc2:setString(User:getRole():getCHAttrName("prestige"))

    self:setVisible(false)
end

function FamilyGroupRankLayer:hideLayer()
    self:hide()
end

function FamilyGroupRankLayer:showLayer(rankData)
    -- Helper:print_lua_table(rankData)
    -- self:show()

    for index, rank in ipairs(rankData) do
        local listItem = self.ListView_Rank:getItem(index - 1)

        if listItem == nil then
            listItem = self:createRankItem()
            self.ListView_Rank:pushBackCustomItem(listItem)
        end

        listItem.Text_mingci:setString(Helper:changeNumZeroToTenForCN(index))

        listItem.Text_name:setString(rank.name)

        listItem.Text_Level:setString(self:getLevelText(rank.kongfu))

        listItem.Text_Value:setString(rank.prestige)
    end

    local listItemCount = #self.ListView_Rank:getItems()
    local rankCount = #rankData
    if rankCount < listItemCount then
        for i = listItemCount - 1, rankCount, -1 do
            self.ListView_Rank:removeItem(i)
        end
    end

    self:setVisible(true)
end

function FamilyGroupRankLayer:createRankItem()
    local rankPanel = self.Panel_item:clone()
    Helper:convertUIByParent(rankPanel)
    rankPanel.Text_mingci:enableOutline({r = 221, g = 215, b = 151, a = 255}, 5)
    rankPanel.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    rankPanel.Text_Level:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    rankPanel.Text_Value:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)

    return rankPanel
end

function FamilyGroupRankLayer:getLevelText(levelValue)
    local text = "停滞不前"
    if levelValue > 10 and levelValue <= 20 then
        text = "犹如龟速"
    elseif levelValue > 20 and levelValue <= 30 then
        text = "进展缓慢"
    elseif levelValue > 30 and levelValue <= 50 then
        text = "进步神速"
    elseif levelValue > 50 then
        text = "一日千里"
    end

    return text
end

Helper:classDefNodeGetInstance(FamilyGroupRankLayer)
return FamilyGroupRankLayer
0000000
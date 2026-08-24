--[[
    author:Seven
    time:2022-07-16 15:20:34
    desc: 角色信息区域UI类
]]
local newClass = require("third.class.NewClass")

local BaseViewUI = require("app.FightSystem.Veiws.ViewCommon.BaseViewUI")

--@SuperType [src.app.FightSystem.Veiws.ViewCommon.BaseViewUI#BaseViewUI]
local CharacterInfoAreaViewUI = {}

function CharacterInfoAreaViewUI:onInit()
    self.ListView_L:setVisible(false)
    self.ListView_R:setVisible(false)
end

--@desc: 设置左边列表是否可见
--@author:Seven
--@time:2023-10-19 16:13:06
--@bool: 是否可见 true | false
function CharacterInfoAreaViewUI:setLeftListVisible(bool)
    self.ListView_L:setVisible(bool)
end

function CharacterInfoAreaViewUI:getLeftListViewNode()
    return self.ListView_L
end

--@desc: 设置右边列表是否可见
--@author:Seven
--@time:2023-10-19 16:13:06
--@bool: 是否可见 true | false
function CharacterInfoAreaViewUI:setRightListVisible(bool)
    self.ListView_R:setVisible(bool)
end

function CharacterInfoAreaViewUI:getRightListViewNode()
    return self.ListView_R
end

--@desc: 插入左边列表指定位置
--@author:Seven
--@time:2023-10-19 17:32:22
--@index: 索引
function CharacterInfoAreaViewUI:insertCustomItemToLeft(index, uinode)
    self.ListView_L:insertCustomItem(uinode, index - 1)
end

function CharacterInfoAreaViewUI:pushBackCustomItemToLeft(uinode)
    self.ListView_L:pushBackCustomItem(uinode)
end

function CharacterInfoAreaViewUI:removeLeftItem(index)
    self.ListView_L:removeItem(index - 1)
end

function CharacterInfoAreaViewUI:getLeftItem(index)
    self.ListView_L:getItem(index - 1)
end

function CharacterInfoAreaViewUI:insertCustomItemToRight(index, uinode)
    self.ListView_R:insertCustomItem(uinode, index - 1)
end

function CharacterInfoAreaViewUI:pushBackCustomItemToRight(uinode)
    self.ListView_R:pushBackCustomItem(uinode)
end

function CharacterInfoAreaViewUI:removeRightItem(index)
    self.ListView_R:removeItem(index - 1)
end

function CharacterInfoAreaViewUI:getRightItem(index)
    self.ListView_R:getItem(index - 1)
end

function CharacterInfoAreaViewUI:onDestroy()
    self.ListView_L:removeAllItems()
    self.ListView_R:removeAllItems()
end

return newClass("CharacterInfoAreaViewUI", {BaseViewUI}, CharacterInfoAreaViewUI)
00
local BaseUI = require("app.FightSystem.UICtrl.UI.BaseUI")
local NewClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
local CharacterInfoAreaUI = {}
local Actions = require("app.extends.NodeAction.Actions")

function CharacterInfoAreaUI:onInit()
    self.__leftUIList = {}

    self.__rightUIList = {}

    local NodeActionManager = require("app.extends.NodeAction.NodeActionManager")
    self.__actionManager = NodeActionManager:create()
end

function CharacterInfoAreaUI:onDestroy()
    self.ListView_L:removeAllItems()
    self.ListView_R:removeAllItems()
end

function CharacterInfoAreaUI:onUpdate(ft)
    self.__actionManager:update(ft)
end

--@desc: 左列表指定索引添加ui
--@author:Seven
--@time:2021-07-01 14:59:45
--@index: 索引
--@infoUI: [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
function CharacterInfoAreaUI:insertCustomInfoUIToLeft(index, infoUI)
    table.insert(self.__leftUIList, index, infoUI)
    self.ListView_L:insertCustomItem(infoUI:getNode(), index - 1)
end

--@desc: 左列表插入ui到
--@author:Seven
--@time:2021-07-01 15:14:49
--@infoUI: [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
function CharacterInfoAreaUI:pushBackCustomItemToLeft(infoUI)
    table.insert(self.__leftUIList, infoUI)
    self.ListView_L:pushBackCustomItem(infoUI:getNode())
end

--@desc: 左列表移除ui
--@author:Seven
--@time:2021-07-01 15:15:36
--@index: [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
function CharacterInfoAreaUI:removeLeftItem(index)
    table.remove(self.__leftUIList, index)
    self.ListView_L:removeItem(index - 1)
end

--@desc: 右列表指定索引添加ui
--@author:Seven
--@time:2021-07-01 14:59:45
--@index: 索引
--@infoUI: [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
function CharacterInfoAreaUI:insertCustomItemToRight(index, infoUI)
    table.insert(self.__rightUIList, index, infoUI)
    self.ListView_R:insertCustomItem(infoUI:getNode(), index - 1)
end

--@infoUI: [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
function CharacterInfoAreaUI:pushBackCustomItemToRight(infoUI)
    table.insert(self.__rightUIList, infoUI)
    self.ListView_R:pushBackCustomItem(infoUI:getNode())
end

function CharacterInfoAreaUI:removeRightItem(index)
    table.remove(self.__rightUIList, index)
    self.ListView_R:removeItem(index - 1)
end

function CharacterInfoAreaUI:startFight()
    local l_position = cc.p(self.ListView_L:getPosition())
    local l_size = self.ListView_L:getSize()
    self.ListView_L:setPositionX(l_position.x - l_size.width)
    self.__actionManager:runAction(self.ListView_L, Actions.MoveTo:create(0.5, l_position))
    
    local r_position = cc.p(self.ListView_R:getPosition())
    local r_size = self.ListView_R:getSize()
    self.ListView_R:setPositionX(r_position.x + r_size.width)
    self.__actionManager:runAction(self.ListView_R, Actions.MoveTo:create(0.5, r_position))
end

return NewClass("CharacterInfoAreaUI", {BaseUI}, CharacterInfoAreaUI)
0
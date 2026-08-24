local TreasureList = require("script.others.Treasure")
local ShenShuLayer = class("ShenShuLayer", LayerEx)
local DialogCLayer = require("app.views.layer.DialogLayer.DialogCLayer")
local ShenShuHelper = require("app.models.shenshu.shenshu")

function ShenShuLayer:create()
    local p = ShenShuLayer:new()
    p:init()
    return p
end

function ShenShuLayer:shouLayer(tag, currlayer, func)
    local layer = self:getInstance()
    layer:show()
    if tag == 1 then
        layer:initUseLayer(currlayer, func)
    else
        layer:initLayer(func, currlayer)
    end
end

function ShenShuLayer:init()
    local UI = require("Layer/ShenShu/ShenShuUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)
end

function ShenShuLayer:initLayer(func, currlayer)
    self:initPanelTypeOne(func, currlayer)
end

function ShenShuLayer:initPanelTypeOne(func, currlayer)
    self.Panel_1:setVisible(true)
    self.Panel_2:setVisible(false)
    self.Panel_3:setVisible(false)
    self.Panel_1.Button_back:releaseFunc(function()
        self:hide()
    end)

    local list = ShenShuHelper:getShenShuAuthor()
    self.Panel_1.ListView_1:removeAllItems()

    for k, v in pairs(list) do
        local row = self:copyPanelYype()
        row.Text_35:setString(v)
        self.Panel_1.ListView_1:pushBackCustomItem(row)
        row.Button_10:releaseFunc(function()
            self:initPanelType(v, func, currlayer)
        end)
    end
end

function ShenShuLayer:initPanelType(auther, func, currlayer)
    local list = ShenShuHelper:getAutherWorks(auther)

    self.Panel_2:setVisible(true)
    self.Panel_1:setVisible(false)
    self.Panel_3:setVisible(false)
    self.Panel_2.Button_back:releaseFunc(function()
        self.Panel_2:setVisible(false)
        self.Panel_1:setVisible(true)
        self.Panel_3:setVisible(false)
    end)

    self.Panel_2.ListView_1:removeAllItems()

    local row, button

    for k, v in ipairs(list) do
        button = self.Panel_2.Button_10:clone()
        Helper:convertUI(button)
        button.Text_35:setFontName("Font/default.ttf")
        button.Text_35:setFontSize(48)
        button.Text_35:enableOutline({
            r = 17,
            g = 18,
            b = 18,
            a = 255
        }, 5)

        if math.mod(k, 2) == 1 then
            row = self:copyPanelYype(2)
            button:addTo(row)
            button:setPosition(304, 65)
            button.Text_35:setString(v.name)
            self.Panel_2.ListView_1:pushBackCustomItem(row)
        else
            button:addTo(row)
            button:setPosition(736, 65)
            button.Text_35:setString(v.name)
        end

        button:releaseFunc(function()
            self:askLingShi(auther, v.id, func, currlayer)
        end)
    end
end

function ShenShuLayer:askLingShi(auther, bookId, func, currlayer)
    if currlayer then
        if currlayer._currMap:canLeaveRoom() == false then
            PopText("请专注眼前事，莫要分心！")
            return
        end
    end

    local role = User:getRole()

    if ShenShuHelper:checkIsInFindBook(role) == false then
        RichPrint("main", "神书尚未现世，无法获知其下落。")
        self:hide()
        return
    end

    local isFound, book = ShenShuHelper:checkBookIsFound(role, bookId)

    if isFound then
        local bookName = ShenShuHelper:getShenShuName(bookId)
        RichPrint("main", "你向灵石询问" .. bookName ..
            "的下落，只听一声轻响，灵石化作一道金光，光中显示出你自己的模样。")
        
        self:hide()
        return
    end

    if not book.pointMsg then
        book = ShenShuHelper:askLingShiToFindBook(role, bookId)
    end

    RichPrint("main", book.pointMsg)
    PopupLayerController:showLayer("DunDiFuLayer", function(layer)
        layer:show()
        layer:showlayer(book)
    end)
    func()
    self:hide()
end

function ShenShuLayer:initUseLayer(currLayer, func)
    self.Panel_1:setVisible(false)
    self.Panel_2:setVisible(false)
    self.Panel_3:setVisible(true)
    self.Panel_3.Button_1:releaseFunc(function()
        self:openShenShuTask(currLayer, func)
    end)
    self.Panel_3.Button_2:releaseFunc(function()
        self:hide()
    end)
end

function ShenShuLayer:openShenShuTask(currLayer, func)
    local role = User:getRole()

    local isTrue, msg = ShenShuHelper:checkCanOpenTask(role)

    if isTrue == false then
        RichPrint("main", msg)
        self:hide()
        return false
    end
    
    ShenShuHelper:startTask(role)

    self:dealUseLingShiInMap(currLayer)
    self:hide()
    func()

    return true
end

function ShenShuLayer:copyPanelYype(tYpe)
    local row
    if tYpe == nil or tYpe == 1 then
        row = self.Panel_1.Panel_12:clone()
        Helper:convertUI(row)
        row.Text_35:setFontName("Font/default.ttf")
        row.Text_35:setFontSize(48)
        row.Text_35:enableOutline({
            r = 17,
            g = 18,
            b = 18,
            a = 255
        }, 5)
    else
        row = self.Panel_2.Panel_12:clone()
        Helper:convertUI(row)
    end
    return row
end

-- 处理在副本中使用灵石
function ShenShuLayer:dealUseLingShiInMap(currLayer)
    if currLayer == nil then
        return
    end

    local role = User:getRole()
    
    if ShenShuHelper:checkIsInFindBook(role) == false then
        return
    end

    -- @desc 副本调整，入口更改
    local currMap = role:getCurrMap()
    local ShenShuTask = require("app.models.map.MapHandle.Modules.TaskModule.ShenShuTask")
    ShenShuTask:initTreasure(currMap)
    currMap.__MapLayer:setNeedRefreshMap()
end

Helper:classDefNodeGetInstance(ShenShuLayer)

return ShenShuLayer
000000
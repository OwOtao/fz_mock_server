local PracticeOfSkillUI = class("PracticeOfSkillUI", LayerEx)

function PracticeOfSkillUI:create()
    local p = PracticeOfSkillUI:new()
    p:init()
    return p
end

function PracticeOfSkillUI:init()
    self._UI = require("Layer/ActionUI/PracticeOfSkillUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function PracticeOfSkillUI:showUI()
    self:setVisible(true)
    self:show()
end

function PracticeOfSkillUI:showLayer(func)
    PopupLayerController:showLayer("PracticeOfSkillUI",function()
        if func then
            func()
        end
    end)
end

function PracticeOfSkillUI:hideUI()
    self:setVisible(false)
    self:hide()
end

function PracticeOfSkillUI:hideLayer(func)
    PopupLayerController:hideLayer("PracticeOfSkillUI",function()
        if func then
            func()
        end
    end)
end

function PracticeOfSkillUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function PracticeOfSkillUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function PracticeOfSkillUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function PracticeOfSkillUI:setTextDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function PracticeOfSkillUI:setText_3Str(str)
    self.Text_3:setString(Helper:getDef(str,""))
end

function PracticeOfSkillUI:setText_3StrColor(color)
    self.Text_3:setColor(Helper:getDef(color, cc.c3b(255,255,255)))
end

function PracticeOfSkillUI:showListView(listData)
    if MapIsEmpty(listData) == true then
        return
    end

    for i =1,#listData do
        local panel = self.ListView_item:getItem(i - 1)
        if panel == nil then
            local panel = self:__createItem()
            self:__initItem(panel,listData[i])
            self.ListView_item:pushBackCustomItem(panel)
        else
            self:__initItem(panel,listData[i])
        end
    end

    if #listData < #self.ListView_item:getItems() then
        for i = #listData + 1, #self.ListView_item:getItems() do
            self.ListView_item:removeLastItem()
        end
    end

    -- self.ListView_item:jumpToTop()
end

function PracticeOfSkillUI:__createItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function PracticeOfSkillUI:__initItem(item,itemInfo)
    item.Text_1:setString(itemInfo.text1)
    item.Text_1:setColor(cc.c3b(255,255,255))
    item.Text_2:setString(itemInfo.text2)
    item.Button_1.Text_buttonName:setString(itemInfo.btnName)
    item.Button_1:setTouchEnabled(itemInfo.enable)
    item.Button_1:loadTextureNormal(itemInfo.loadTexture)
    item.Button_1:releaseFunc(function()
        if itemInfo.func then
            itemInfo.func()
        end
    end)
end

Helper:classDefNodeGetInstance(PracticeOfSkillUI)
return PracticeOfSkillUI
0000
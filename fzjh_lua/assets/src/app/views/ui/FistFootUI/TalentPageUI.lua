local TalentPageUI = class("TalentPageUI", LayerEx)

function TalentPageUI:create()
    local p = TalentPageUI:new()
    p:init()
    return p
end

function TalentPageUI:init()
    self._round = require("Layer/FistFootUI/TalentPageUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TalentPageUI:setTitleText(text)
    self.Text_title1:setString(text)
end

--@desc: 获取ListView1 的子元素
--@author:Seven
--@time:2023-01-09 17:12:24
function TalentPageUI:getNewListView1PanelItem()
    local panel = self.Panel_item:clone()
    Helper:convertUIByParent(panel)
    for i = 1, 4 do
        panel["Panel_page" .. i]:setVisible(false)
    end
    return panel
end

function TalentPageUI:getPanelItemFromListView1(index)
    return self.ListView_1:getItem(index)
end

--@desc: 移除listView1所有item
--@author:Seven
--@time:2023-01-09 14:16:55
function TalentPageUI:removeListView1AllItems()
    return self.ListView_1:removeAllItems()
end

function TalentPageUI:pushItemToListView1(item)
    self.ListView_1:pushBackCustomItem(item)
end

function TalentPageUI:listView1JumpToTop()
    self.ListView_1:jumpToTop()
end

function TalentPageUI:setText1(str)
    if str == nil then
        str = ""
    end
    self.Panel_di.Text_1:setString(str)
end

function TalentPageUI:setText2(str)
    if str == nil then
        str = ""
    end
    self.Panel_di.Text_2:setString(str)
end

function TalentPageUI:setText3(str)
    if str == nil then
        str = ""
    end
    self.Panel_di.Text_3:setString(str)
end

function TalentPageUI:setText4(str)
    if str == nil then
        str = ""
    end
    self.Panel_di.Text_4:setString(str)
end

function TalentPageUI:setText5(str)
    if str == nil then
        str = ""
    end
    self.Panel_di.Text_5:setString(str)
end

function TalentPageUI:setText6(str)
    if str == nil then
        str = ""
    end
    self.Panel_di.Text_6:setString(str)
end

function TalentPageUI:setText7(str)
    if str == nil then
        str = ""
    end
    self.Panel_di.Text_7:setString(str)
end

--@desc:获取一个全新的 ListView2 的列表元素
--@author:Seven
--@time:2023-01-09 14:17:55
function TalentPageUI:getNewListView2TextPanelItem()
    local panel = self.Panel_text:clone()
    Helper:convertUIByParent(panel)
    for i = 1, 3 do
        panel["Text_char" .. i]:setVisible(false)
    end
    return panel
end

function TalentPageUI:getPanelItemFromListView2(index)
    return self.Panel_di.ListView_2:getItem(index)
end

--@desc: 移除listView2所有item
--@author:Seven
--@time:2023-01-09 14:16:55
function TalentPageUI:removeListView2AllItems()
    return self.Panel_di.ListView_2:removeAllItems()
end

function TalentPageUI:pushItemToListView2(item)
    self.Panel_di.ListView_2:pushBackCustomItem(item)
end

function TalentPageUI:listView2JumpToTop()
    self.Panel_di.ListView_2:jumpToTop()
end

function TalentPageUI:setButton1(buttonName, func)
    self.Panel_di.Button_1.Text_buttonName:setString(buttonName)
    self.Panel_di.Button_1:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function TalentPageUI:setButton2(buttonName, func)
    self.Panel_di.Button_2.Text_buttonName:setString(buttonName)
    self.Panel_di.Button_2:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

return TalentPageUI
00
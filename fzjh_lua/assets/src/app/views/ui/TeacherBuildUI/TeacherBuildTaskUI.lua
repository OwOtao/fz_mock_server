local TeacherBuildTaskUI = class("TeacherBuildTaskUI", LayerEx)

function TeacherBuildTaskUI:create()
    local p = TeacherBuildTaskUI:new()
    p:init()
    return p
end

function TeacherBuildTaskUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherBuildTaskUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self)

    self.Image_1.ListView_taskType:setScrollBarEnabled(false)
end

function TeacherBuildTaskUI:updateSkin(skin_config)
    if skin_config == nil then
        self.Button_start:loadTextureNormal("Image/UI/MapUI/anniu05.png", 0)
    end


    local btnImage = skin_config.Clickbtn or "Image/UI/MapUI/anniu05.png"
    self.Button_start:loadTextureNormal(btnImage, 0)
end

function TeacherBuildTaskUI:setLightTask(index)
    for i, item in ipairs(self.ListView_task:getItems()) do
        item.Image_light:setVisible(false)
    end

    self.ListView_task:getItem(index - 1).Image_light:setVisible(true)
end

function TeacherBuildTaskUI:clearListViewTask()
    self.ListView_task:removeAllItems()
end

function TeacherBuildTaskUI:setListViewTask(array)
    for i, v in ipairs(array) do
        local button = self.Button_task:clone()
        Helper:convertUIByParent(button)

        if v.isState == 1 then
            button.Pnl_cd:setVisible(false)
            button.Pnl_able:setVisible(false)
            button.Pnl_Disable:setVisible(true)
            button.Image_di:loadTexture(v.diImage, 0)
            button.Pnl_Disable.Text_condition:setString(v.condition)
        elseif v.isState == 2 then
            button.Pnl_cd:setVisible(false)
            button.Pnl_able:setVisible(true)
            button.Pnl_Disable:setVisible(false)
            button.Image_di:loadTexture(v.diImage, 0)
            button.Pnl_able.Text_name:setString(v.name)
            button.Pnl_able.Text_reward1:setString(v.reward1)
            button.Pnl_able.Text_reward2:setString(v.reward2)
            button.Pnl_able.Text_time:setString(v.time)
        elseif v.isState == 3 then
            button.Pnl_cd:setVisible(true)
            button.Pnl_able:setVisible(false)
            button.Pnl_Disable:setVisible(false)
            button.Image_di:loadTexture(v.diImage, 0)
            button.Pnl_cd.Text_name:setString(v.name)
            button.Pnl_cd.Text_reward1:setString(v.reward1)
            button.Pnl_cd.Text_reward2:setString(v.reward2)
            button.Pnl_cd.Text_time:setString(v.time)
        end

        button:releaseFunc(
            function()
                if v.func then
                    v.func()
                end
            end
        )

        self.ListView_task:pushBackCustomItem(button)
    end

    self.ListView_task:jumpToTop()
end

function TeacherBuildTaskUI:setTypeSelectList(list)
    self.Image_1.ListView_taskType:removeAllItems()
    if MapIsEmpty(list) == false then
        local count = #list
        local itemMergin = {
            ["3"] = 80,
            ["4"] = 20
        }
        self.Image_1.ListView_taskType:setItemsMargin(itemMergin[tostring(count)])
        for k, v in ipairs(list) do
            local panel = self:__cloneTaskTypePanel()
            panel.Text_task:setString(v.text)
            panel:releaseFunc(
                function()
                    if v.func then
                        v.func()
                    end
                end
            )
            self.Image_1.ListView_taskType:pushBackCustomItem(panel)

            if k < #list then
                local line = self.Panel_taskSplit:clone()
                self.Image_1.ListView_taskType:pushBackCustomItem(line)
            end
        end
    end
end

function TeacherBuildTaskUI:setTypeSelectTextColor(index, color)
    local item = self.Image_1.ListView_taskType:getItem(index)
    if item then
        item.Text_task:setTextColor(color)
    end
end

function TeacherBuildTaskUI:setButtonStart(func)
    self.Button_start:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function TeacherBuildTaskUI:setText1(text)
    self.Text_1:setString(text)
end

function TeacherBuildTaskUI:setText2(text)
    self.Text_2:setString(text)
end

function TeacherBuildTaskUI:setText3(text)
    self.Text_3:setString(text)
end

function TeacherBuildTaskUI:setNotTaskVisible(bool)
    self.Text_notTask:setVisible(bool)
end

function TeacherBuildTaskUI:__cloneTaskTypePanel()
    local panel = self.Panel_taskType:clone()
    Helper:convertUIByParent(panel)
    return panel
end

return TeacherBuildTaskUI
00000000000
local TeacherBuildListUI = class("TeacherBuildListUI", LayerEx)

function TeacherBuildListUI:create()
    local p = TeacherBuildListUI:new()
    p:init()
    return p
end

function TeacherBuildListUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherBuildListUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherBuildListUI:updateSkin(skin_config)
    self.__skinConfig = skin_config

    if self.__skinConfig and self.__skinConfig.Clickbtn then
        local btn_texture = self.__skinConfig.Clickbtn or "Image/UI/PopUI/anniu.png"
        self.Button_items:loadTextureNormal(btn_texture, 0)
        self.Button_info:loadTextureNormal(btn_texture, 0)
    end

    -- local listAllItems = self.ListView_task:getItems()
    -- if #listAllItems > 0 then
    --     for i, item in ipairs(listAllItems) do
    --         self:__updateListItemTexture(item)
    --     end
    -- end
end

function TeacherBuildListUI:setLightBuild(index)
    for i, item in ipairs(self.ListView_task:getItems()) do
        item.Image_light:setVisible(false)
    end

    self.ListView_task:getItem(index - 1).Image_light:setVisible(true)
end

function TeacherBuildListUI:__updateListItemTexture(item)
    if self.__skinConfig and self.__skinConfig.FamilyBuildList then
        local texture_list = string.split(self.__skinConfig.FamilyBuildList, ";")
        local texture_border = texture_list[1] or "Image/BaseUI/bt-yellow-select.png"
        local texture_button = texture_list[2] or "Image/UI/ActionUI/panelBg.png"

        if item.Image_kuang then
            item.Image_kuang:loadTexture(texture_button, 0)
        end

        if item.Image_light then
            item.Image_light:loadTexture(texture_border, 0)
        end
    else
        if item.Image_kuang then
            item.Image_kuang:loadTexture("Image/UI/ActionUI/panelBg.png", 0)
        end

        if item.Image_light then
            item.Image_light:loadTexture("Image/BaseUI/bt-yellow-select.png", 0)
        end
    end
end

function TeacherBuildListUI:setListViewBuildList(array)
    self.ListView_task:removeAllItems()
    for i, v in ipairs(array) do
        local button = self.Button_task:clone()
        Helper:convertUIByParent(button)

        if self.__skinConfig and self.__skinConfig.FamilyBuildList then
            local texture_list = string.split(self.__skinConfig.FamilyBuildList, ";")
            local texture_border = texture_list[1] or "Image/BaseUI/bt-yellow-select.png"
            local texture_button = texture_list[2] or "Image/UI/ActionUI/panelBg.png"

            button.Image_light:loadTexture(texture_border, 0)
            button.Image_kuang:loadTexture(texture_button, 0)
        end

        button.Text_name:setString(v.name)
        button.Text_exp:setString(v.exp)
        button.Text_state:setString(v.isState)

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

function TeacherBuildListUI:setButtonItems(func)
    self.Button_items:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function TeacherBuildListUI:setButtonInfo(func)
    self.Button_info:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

return TeacherBuildListUI
00000000000
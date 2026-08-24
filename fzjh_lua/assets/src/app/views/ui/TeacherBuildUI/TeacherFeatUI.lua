local TeacherFeatUI = class("TeacherFeatUI", LayerEx)

function TeacherFeatUI:create()
    local p = TeacherFeatUI:new()
    p:init()
    return p
end

function TeacherFeatUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherFeatUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherFeatUI:updateSkin(skin_config)
    self.__skinConfig = skin_config
end

function TeacherFeatUI:setTextFeatPoint(text)
    self.Text_featPoint:setString(text)
end

function TeacherFeatUI:setTextFeatClass(text)
    self.Text_featClass:setString(text)
end


local DEFAULT_BG_TEXTURE = "Image/BaseUI/panel-grey-bg.png"
function TeacherFeatUI:setListViewFeat(array)
    self.ListView_feat:removeAllItems()

    local bgTexture = DEFAULT_BG_TEXTURE

    if self.__skinConfig and self.__skinConfig.FamilyExpLIst then
        bgTexture = self.__skinConfig.FamilyExpLIst or DEFAULT_BG_TEXTURE

        if not cc.FileUtils:getInstance():isFileExist(bgTexture) then
            bgTexture = DEFAULT_BG_TEXTURE
        end
    end

    for i, v in ipairs(array) do
        local panel = self.Panel_feat:clone()

        Helper:convertUIByParent(panel)

        panel.Image_kuang:loadTexture(bgTexture, 0)

        panel.Text_name:setString(v.name)

        panel.Text_dsc:setString(v.dsc)

        panel.Text_awardText1:setString(v.awardText1)

        panel.Text_awardText2:setString(v.awardText2)

        panel.Text_state:setString(v.stateText)

        panel.Image_lingqu:setVisible(v.butVisible)

        panel:setTouchEnabled(v.butVisible)

        panel.Panel_di:setVisible(v.pdVisible)

        panel:releaseFunc(
            function()
                if v.func then
                    v.func()
                end
            end
        )

        self.ListView_feat:pushBackCustomItem(panel)
    end

    self.ListView_feat:jumpToTop()
end

function TeacherFeatUI:refreshItem(index, data)
    local item = self.ListView_feat:getItem(index - 1)

    item.Text_state:setString(data.stateText)

    item.Image_lingqu:setVisible(data.butVisible)

    item:setTouchEnabled(data.butVisible)

    item.Panel_di:setVisible(data.pdVisible)
end

function TeacherFeatUI:setPanelLabel1(text, func)
    self.Image_1.Panel_label.Text_name:setString(text)

    self.Image_1.Panel_label:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function TeacherFeatUI:setPanelLabel1Color(color)
    self.Image_1.Panel_label.Text_name:setTextColor(color)
end

function TeacherFeatUI:setPanelLabel2(text, func)
    self.Image_2.Panel_label.Text_name:setString(text)

    self.Image_2.Panel_label:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function TeacherFeatUI:setPanelLabel2Color(color)
    self.Image_2.Panel_label.Text_name:setTextColor(color)
end

return TeacherFeatUI
000
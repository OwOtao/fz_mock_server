local TeacherBuildInfoUI = class("TeacherBuildInfoUI", LayerEx)

function TeacherBuildInfoUI:create()
    local p = TeacherBuildInfoUI:new()
    p:init()
    return p
end

function TeacherBuildInfoUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherBuildInfoUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherBuildInfoUI:setTextLv(text)
    self.Text_lv:setString(text)
end

function TeacherBuildInfoUI:setTextExp(text)
    self.Text_exp:setString(text)
end

function TeacherBuildInfoUI:setPercent(percent)
    self.LoadingBar:setPercent(percent)
end

function TeacherBuildInfoUI:setTextDesc(text)
    self.Image_diKuang.Text_desc:setString(text)
end

function TeacherBuildInfoUI:setTextSupTitle1(text)
    self.Image_diKuang.Text_supTitle1:setString(text)
end

function TeacherBuildInfoUI:setTextEffectDsc1(text)
    self.Image_diKuang.Text_effectDsc1:setString(text)
end

function TeacherBuildInfoUI:setTextSupTitleCon1(text)
    self.Image_diKuang.Text_supTitleCon1:setString(text)
end

function TeacherBuildInfoUI:setTextCondition1(text)
    self.Image_diKuang.Text_condition1:setString(text)
end

function TeacherBuildInfoUI:setTextCondition2(text)
    self.Image_diKuang.Text_condition2:setString(text)
end

function TeacherBuildInfoUI:setTextCondition3(text)
    self.Image_diKuang.Text_condition3:setString(text)
end

function TeacherBuildInfoUI:setTextCondition4(text)
    self.Image_diKuang.Text_condition4:setString(text)
end

function TeacherBuildInfoUI:setTextSupTitle2(text)
    self.Image_diKuang.Text_supTitle2:setString(text)
end

function TeacherBuildInfoUI:setTextEffectDsc2(text)
    self.Image_diKuang.Text_effectDsc2:setString(text)
end

function TeacherBuildInfoUI:setTextSupTitleCon2(text)
    self.Image_diKuang.Text_supTitleCon2:setString(text)
end

function TeacherBuildInfoUI:setTextOpenLv(text)
    self.Image_diKuang2.Text_lv:setString(text)
end

function TeacherBuildInfoUI:setTextOpenCon(text)
    self.Image_diKuang2.Text_con:setString(text)
end

function TeacherBuildInfoUI:setButtonEffect1(isVisible, name, func)
    self.Button_effect1:setVisible(isVisible)
    self.Image_effect1:setVisible(not isVisible)
    if isVisible then
        self.Button_effect1.Text_buttonName:setString(name)
        self.Button_effect1:releaseFunc(
            function()
                func()
            end
        )
    end
end

function TeacherBuildInfoUI:setButtonEffect2(isVisible, name, func)
    self.Button_effect2:setVisible(isVisible)
    self.Image_effect2:setVisible(not isVisible)
    if isVisible then
        self.Button_effect2.Text_buttonName:setString(name)
        self.Button_effect2:releaseFunc(
            function()
                func()
            end
        )
    end
end

function TeacherBuildInfoUI:setButtonEffect3(isVisible, name, func)
    self.Button_effect3:setVisible(isVisible)
    self.Image_effect3:setVisible(not isVisible)
    if isVisible then
        self.Button_effect3.Text_buttonName:setString(name)
        self.Button_effect3:releaseFunc(
            function()
                func()
            end
        )
    end
end

function TeacherBuildInfoUI:setButtonBuild(func)
    self.Button_build:releaseFunc(
        function()
            func()
        end
    )
end

function TeacherBuildInfoUI:setButtonBuildName(name,nameColor)
    self.Button_build.Text_buttonName:setString(name)
    self.Button_build.Text_buttonName:setTextColor(nameColor)
end

function TeacherBuildInfoUI:setButtonBuildTexture(texture)
    self.Button_build:loadTextureNormal(texture,0)
    self.Button_build:setSize({width = 281.0000, height = 90.0000})
end

function TeacherBuildInfoUI:setButtonBuildScale9(capInsets)
    self.Button_build:setScale9Enabled(true)
    self.Button_build:setCapInsets(capInsets)
end

function TeacherBuildInfoUI:setButtonDonate(name, func)
    self.Button_donate.Text_buttonName:setString(name)
    self.Button_donate:releaseFunc(
        function()
            func()
        end
    )
end

function TeacherBuildInfoUI:setButtonUpgrade(name, func)
    self.Button_upgrade.Text_buttonName:setString(name)
    self.Button_upgrade:releaseFunc(
        function()
            func()
        end
    )
end

return TeacherBuildInfoUI
000000000
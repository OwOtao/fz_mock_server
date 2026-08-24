local TeacherBuildMenuPresenter = class("TeacherBuildMenuPresenter", cc.Layer)

function TeacherBuildMenuPresenter:create()
    local p = TeacherBuildMenuPresenter:new()
    p:init()
    return p
end

function TeacherBuildMenuPresenter:init()
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherBuildMenuUI"):create()

    self.__ui:addTo(self)
end

function TeacherBuildMenuPresenter:updateLayerSkinUI(skin_config)
    self.__MiddlebgPic = skin_config.MiddlebgPic
end

function TeacherBuildMenuPresenter:showLayer()
    self:setFamilyImageBack()

    self:initButton()

    self.__ui:show()
end

function TeacherBuildMenuPresenter:onEnable()
    self:setTextLv()

    self:setExp()

    self:setTextMaterial1()

    self:setTextMaterial2()

    self:setTextMaterial3()

    self:setTextMaterial4()

    self:initFamilyStates()
end

function TeacherBuildMenuPresenter:setRole(role)
    self.__role = role
end

function TeacherBuildMenuPresenter:setTextLv()
    local lv = self.__role:getTeacherBuildSystem():getSectLv()

    self.__ui:setTextLv("师门等级: "..lv)
end

function TeacherBuildMenuPresenter:setExp()
    local exp = self.__role:getTeacherBuildSystem():getGbpoint()
    
    local currMax = self.__role:getTeacherBuildSystem():getNextLevelNeedGbpoint()

    self.__ui:setTextExp(exp.."/"..currMax)

    local percet = exp/currMax
    
    self.__ui:setPercent(percet*100)
end

function TeacherBuildMenuPresenter:setTextMaterial1()
    local name = self.__role:getTeacherBuildSystem():getReputationName()

    local reputation = self.__role:getTeacherBuildSystem():getReputation()

	self.__ui:setTextMaterial1(name..":"..reputation)
end

function TeacherBuildMenuPresenter:setTextMaterial2()
    local name = self.__role:getTeacherBuildSystem():getSgbpointName()

    local sgbpoint = self.__role:getTeacherBuildSystem():getSgbpoint()
    
	self.__ui:setTextMaterial2(name..":"..sgbpoint)
end

function TeacherBuildMenuPresenter:setTextMaterial3()
	local name = self.__role:getTeacherBuildSystem():getRenownName()

    local renown = self.__role:getTeacherBuildSystem():getRenown()
    
	self.__ui:setTextMaterial3(name..":"..renown)
end

function TeacherBuildMenuPresenter:setTextMaterial4()
    local name = self.__role:getTeacherBuildSystem():getDonateName()

    local donate = self.__role:getTeacherBuildSystem():getDonate()

	self.__ui:setTextMaterial4(name..":"..donate)
end

function TeacherBuildMenuPresenter:setFamilyImageBack()
    local texturePath = self.__MiddlebgPic

    local imagePath = nil
    if texturePath == "family" then
        local familyId = self.__role:getTeacherBuildSystem():getFamilyId()
        imagePath = "Image/UI/MainUI/back/"..familyId..".png"     
    end
    
    -- 如果配置不为空，但文件却不存在则使用默认
    if imagePath ~= nil and not cc.FileUtils:getInstance():isFileExist(imagePath) then
        imagePath = "Image/UI/MainUI/back/mingyueshenjiao.png"
    end
    
    self.__ui:setImageBack(imagePath)
end

function TeacherBuildMenuPresenter:initButton()
    self.__ui:setButtonTask("师门\n日常",function()
        self:taskButton()
    end)

    self.__ui:setButton1("师门\n建筑",function()
        self:buildButton()
    end)

    self.__ui:setButton2("",function()
        self:unopenButton()
    end)

    self.__ui:setButton3("师门\n指点",function()
        self:guidanceButton()
    end)

    self.__ui:setButton4("师门\n建树",function()
        self:featButton()
    end)

end

function TeacherBuildMenuPresenter:taskButton()
    if self.__role:getTeacherBuildSystem():isGuaJi() then
        MainControllLayer:pushLayer("TeacherBuildGuaJiPresenter")
        local teacherBuildGuaJiPresenter = MainControllLayer:getLayer("TeacherBuildGuaJiPresenter")
        teacherBuildGuaJiPresenter:setRole(self.__role)
        teacherBuildGuaJiPresenter:showLayer()
    else
        self.__role:getTeacherBuildSystem():getTeacherBuildTasks(
            function(isOk,msg,data)
                if isOk then
                    MainControllLayer:pushLayer("TeacherBuildTaskPresenter")
                    local teacherBuildTaskPresenter = MainControllLayer:getLayer("TeacherBuildTaskPresenter")
                    teacherBuildTaskPresenter:setRole(self.__role)
                    teacherBuildTaskPresenter:setTasks(data.list)
                    teacherBuildTaskPresenter:showLayer()
                else
                    PopText(msg)
                end
            end
        )
    end
end

function TeacherBuildMenuPresenter:buildButton()
    self.__role:getTeacherBuildSystem():getTeacherBuildData(
        function(isOk,msg)
            if isOk then
                MainControllLayer:pushLayer("TeacherBuildListPresenter")
                local teacherBuildListPresenter = MainControllLayer:getLayer("TeacherBuildListPresenter")
                teacherBuildListPresenter:setRole(self.__role)
                teacherBuildListPresenter:showLayer()
            else
                PopText(msg)
            end
        end
    )
end

function TeacherBuildMenuPresenter:featButton()
    self.__role:getTeacherBuildSystem():getTeacherFeatData(
        function(isOk,msg)
            if isOk then
                MainControllLayer:pushLayer("TeacherFeatPresenter")
                local teacherFeatPresenter = MainControllLayer:getLayer("TeacherFeatPresenter")
                teacherFeatPresenter:setRole(self.__role)
                teacherFeatPresenter:showLayer()
            else
                PopText(msg)
            end
        end
    )
end

function TeacherBuildMenuPresenter:unopenButton()
    PopText("尚未开启，请耐心等待")
end

function TeacherBuildMenuPresenter:initFamilyStates()
    local states = self.__role:getTeacherBuildSystem():getFamilyStates()
    local TeacherBuildConst = require("app.models.TeacherBuildSystem.TeacherBuildConst")
    local count = TeacherBuildConst.FamilyStateUICount

    if #states > 0 then
        self.__ui:setFamilyStatePanelVisible(true)
    else
        self.__ui:setFamilyStatePanelVisible(false)
    end

    self.__ui:setFamilyStateDescPanelFunc(function()
        self.__ui:setFamilyStateDescPanelVisible(false)
    end)

    for i = 1, count do
        local state = states[i]
        if state then
            self.__ui:setFamilyStateVisible(i, true)
            self.__ui:setFamilyStateTexture(i, state:getIcon())
            self.__ui:setFamilyStateFunc(i, function()
                self.__ui:setFamilyStateDescPanelVisible(true)
                self.__ui:setFamilyStateDescName(state:getName())
                self.__ui:setFamilyStateDescText(state:getText())
            end)
        else
            self.__ui:setFamilyStateVisible(i, false)
        end
    end
end

function TeacherBuildMenuPresenter:guidanceButton()
    local teacherGuidance = require("app.models.TeacherBuildSystem.Guidance.TeacherGuidance"):create()
    teacherGuidance:setRole(self.__role)
    teacherGuidance:init(function()
        MainControllLayer:pushLayer("TeacherGuidancePresenter")
        local teacherBuildGuaJiPresenter = MainControllLayer:getLayer("TeacherGuidancePresenter")
        teacherBuildGuaJiPresenter:setInput(teacherGuidance)
        teacherBuildGuaJiPresenter:showLayer()
    end)
end

Helper:classDefNodeGetInstance(TeacherBuildMenuPresenter)
return TeacherBuildMenuPresenter
0000000000
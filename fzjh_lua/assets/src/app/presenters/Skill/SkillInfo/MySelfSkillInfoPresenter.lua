local class = require("third.class.NewClass")

local RoleSkillInfoTabBarUI = require("app.views.ui.SkillUI.RoleSkillInfoTabBarUI")

local RoleSkillInfoListBarUI = require("app.views.ui.SkillUI.RoleSkillInfoListBarUI")

local BaseSkillInfoPresenter = require("app.presenters.Skill.SkillInfo.BaseSkillInfoPresenter")

local SkillConst = require("app.models.skill.SkillConst")

local MySelfSkillInfoPresenter = {}

function MySelfSkillInfoPresenter:create(mainPresenter, viewModel)
    local p = MySelfSkillInfoPresenter:new()
    p:__init(mainPresenter, viewModel)
    return p
end

--@desc: init 初始化
--@author:Seven
--@time:2024-10-31 15:20:16
--@mainPresenter: [SkillInfoLayer]
--@viewModel: [src.app.models.skill.SkillInfoViewModel.SkillInfoViewModel#SkillInfoViewModel]
--@return:
function MySelfSkillInfoPresenter:__init(mainPresenter, viewModel)
    --@RefType [SkillInfoLayer]
    self.__mainPresenter = mainPresenter

    self.__ui = mainPresenter:getUI()

    self.__viewModel = viewModel

    self.__viewModel:setPresenter(self)

    self.__role = viewModel:getRole()
end

function MySelfSkillInfoPresenter:showPresenter()
    self:setCurrTabIndex(1)

    self.__ui:setTitleTabListViewScrollBarEnabled(false)

    self:setTitleName()

    self:showTitleTabList()

    self:setButtonTab()

    self:setButtonLianGong()

    self:setButtonSkillBreak()

    self:setButtonPrepare()
end

function MySelfSkillInfoPresenter:update()
    if self.__mainPresenter:getCurrSkillInfoPresenter() == self then
        self:setButtonLianGong()
    end
end

function MySelfSkillInfoPresenter:setTitleName()
    MainControllLayer:getLayer("TitleLayer"):setTextTitle("我的技能")
end

function MySelfSkillInfoPresenter:showTitleTabList()
    self.__ui:removeTitleTabListViewAllItems()

    local skillListTab = self.__viewModel:getSkillListTab()

    for i, skillTab in ipairs(skillListTab) do
        local skillTabBar = RoleSkillInfoTabBarUI:create()

        self.__ui:insertPanelToTitleTabListView(skillTabBar)

        skillTabBar:setName(skillTab.name)

        skillTabBar:releaseFunc(
            function()
                Audio:playEffect("xiaoAnNiu")

                self:setCurrTabIndex(i)

                self.__skillListPos = nil

                self:lightTab()

                self:setSkillList()

                self:hideSkillInfoPopUI()
            end
        )
    end

    self:lightTab()

    self:setSkillList()
end

function MySelfSkillInfoPresenter:setSkillList()
    local skillList = self.__viewModel:getCurrSkillList()

    local skillType = self.__viewModel:getCurrTabSkillType()

    skillList = self.__viewModel:sortSkill(skillList, skillType)

    local skillListView = self.__ui:getSkillListView()

    skillListView:removeAllItems()

    if MapIsEmpty(skillList) then
        self:unListViewSchedule()
        return
    else
        for index, roleSkill in ipairs(skillList) do
            -- 即时更新面板经验值及等级状态
            do
                roleSkill = self.__role:getSkill(roleSkill.id)
                skillList[index] = roleSkill
            end
        end
    end

    local skillInfoBarUI = RoleSkillInfoListBarUI

    skillListView:setSwallowTouches(false)

    local roleItemNum = #skillList
    local listSize = skillListView:getContentSize()
    local itemSize = skillInfoBarUI:create():getContentSize()
    local itemsMargin = skillListView:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height / (itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

    skillListView:setItemHeight(itemSize.height)

    skillListView:setItemInitFunc(
        function(skillPanel, skillInfo)
            self:initSkillPanelInfo(
                skillPanel,
                skillInfo,
                function()
                    Audio:playEffect("daAnNiu")

                    self:hideSkillInfoPopUI()

                    self:showSkillInfo(skillInfo)

                    self:hideSkillListImageBack()

                    skillPanel:setImageBack(true)
                end
            )
        end
    )

    skillListView:setItemCreateFunc(
        function()
            return skillInfoBarUI:create()
        end
    )

    skillListView:showListView(skillList, itemMaxCount)

    if isSchedule then
        if self.__skillListPos then
            if self.__skillListPos.y > skillListView:getInnerContainerPosition().y then
                skillListView:setInnerContainerPosition(self.__skillListPos)
            end
        else
            skillListView:jumpToTop()
        end

        local isTrue = skillListView:refreshReuseItems()
        while isTrue do
            isTrue = skillListView:refreshReuseItems()
        end

        self:unListViewSchedule()

        self.listViewSchedule =
            self.__mainPresenter:schedule(
            function()
                skillListView:refreshReuseItems()
                self.__skillListPos = skillListView:getLastInnerContainerPosition()
            end
        )
    end
end

function MySelfSkillInfoPresenter:initSkillPanelInfo(skillPanel, roleSkill, callback)
    local skillId = roleSkill.id
    local skill = self.__viewModel:getSkill(skillId)
    local skillLv
    if skill:checkIsSpecialZhiShiSkill() then
        skillLv = self.__role:getSpecialZhiShiSkillLv(skillId)
    else
        skillLv = self.__role:getSkillLvWithRoleLvLimit(skillId)
    end

    skillPanel:setExpDsc(skillLv .. "级")

    skillPanel:setName(skill:getName())
    skillPanel:setStageDsc(self.__viewModel:getSkillStageDsc(skillId))
    skillPanel:setImageBack(false)

    skillPanel:releaseFunc(
        function()
            callback()
        end
    )

    local prepareSkills = self.__role:getSkillPrepare()

    local state = false

    local skillType = self.__viewModel:getCurrTabSkillType()

    local prepareList = SkillConst.PrepareList

    for k, v in pairs(prepareSkills) do
        if prepareList[k] ~= nil then
            if (k == skillType or (k == "quanjiao2" and skillType == "quanjiao1")) and ((skill.type == SKILL_TYPE_BASE and prepareList[k] == skill.id) or v == skill.id) then
                state = true
            elseif
                skillType == "bingqi" and ((skill.type == SKILL_TYPE_BASE and prepareList[k] == skill.id) or v == skill.id) and
                    (k ~= "quanjiao1" and k ~= "quanjiao2" and k ~= "zhaojia" and k ~= "neigong" and k ~= "qinggong")
             then
                state = true
            end
        end
    end

    skillPanel:setDian(state)
end

function MySelfSkillInfoPresenter:showSkillInfo(roleSkill)
    if roleSkill == nil then
        return
    end

    local SkillInfoPopPresenterFactory = require("app.models.skill.SkillInfoViewModel.SkillInfoPopPresenterFactory")

    local skillId = roleSkill.id

    self.__viewModel:setSkillId(skillId)

    local skillInfoPopPresenter = SkillInfoPopPresenterFactory:createMySkillInfoPopPresenter(self)

    skillInfoPopPresenter:setParentPresenter(self)

    skillInfoPopPresenter:updateSkin(self.__mainPresenter:getSkinConfig())

    self:setPopPresenter(skillInfoPopPresenter)

    local popUI = skillInfoPopPresenter:getUI()

    popUI:addTo(self.__mainPresenter)

    skillInfoPopPresenter:showLayer()
end

function MySelfSkillInfoPresenter:refreshCurSelectItem()
    local curSelectIndex = self.__ui:getSkillListView():getCurSelectedIndex()

    local curSelectItem = self.__ui:getSkillListView():getItem(curSelectIndex)

    if curSelectItem then
        local skill = self.__viewModel:getSkill()

        local skillLv

        if skill:checkIsSpecialZhiShiSkill() then
            skillLv = self.__role:getSpecialZhiShiSkillLv(self.__viewModel:getSkillId())
        else
            skillLv = self.__role:getSkillLvWithRoleLvLimit(self.__viewModel:getSkillId())
        end

        curSelectItem:setExpDsc(skillLv .. "级")

        curSelectItem:setStageDsc(skill:getStageDsc(self.__role))
    end
end

function MySelfSkillInfoPresenter:setButtonTab()
    local isVisible = self.__role:getAttr("teacherName") ~= nil and true or false

    local buttonName = "请师\n教父"

    local callback = function()
        Audio:playEffect("daAnNiu")

        self:hideSkillInfoPopUI()

        if self.__role:checkTeacherIsChanged() == true then
            PopText("你找不到你的师傅了，请重新拜师再来。")
        else
            self.__mainPresenter:showTeacherSkillInfoPresenter()
        end
    end

    self.__ui:setButtonTab(isVisible, buttonName, callback)
end

function MySelfSkillInfoPresenter:setButtonLianGong()
    local isVisible = false

    local buttonName = ""

    local callback = EMPTY_FUNC

    if self.__role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
        isVisible = true

        buttonName = "正闭\n在关"

        callback = function()
            Audio:playEffect("daAnNiu")

            self:hideSkillInfoPopUI()

            local biGuanSkillId = self.__role:getFlag("当前武功")

            self:showBiGuanLayer(biGuanSkillId)
        end
    elseif self.__role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
        isVisible = true

        buttonName = "正练\n在功"

        callback = function()
            Audio:playEffect("daAnNiu")

            self:hideSkillInfoPopUI()

            self:showLianGongingLayer()
        end
    elseif self.__role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
        isVisible = true

        buttonName = "正修\n在炼"

        callback = function()
            Audio:playEffect("daAnNiu")

            self:hideSkillInfoPopUI()

            self:showXiuLianingLayer()
        end
    else
    end

    self.__ui:setButtonLianGong(isVisible, buttonName, callback)
end

function MySelfSkillInfoPresenter:setButtonSkillBreak()
    local isVisible = self.__role:getLv() >= 1000 and true or false

    local buttonName = "突\n破"

    local callback = function()
        Audio:playEffect("daAnNiu")

        self:hideSkillInfoPopUI()

        if self.__role:getSkillBreakThroughSystem():isBreakThrough() then
            self:showSkillBreakLayer()
        else
            PopText("所需基本武学都达到1000级才能武学突破")
        end
    end

    self.__ui:setButtonSkillBreak(isVisible, buttonName, callback)

    self.__ui:setButtonSkillBreakTexture("Image/UI/TeacherUI/lotus_shape_button.png")
end

function MySelfSkillInfoPresenter:setButtonPrepare()
    local function PrepareButtonIsVisible()
        local skills = self.__role:getSkills()

        if MapIsEmpty(skills) == false then
            for k, v in pairs(skills) do
                local skill = Skill:getSkill(v.id)
                -- 至少有一个基本类型的武功才显示准备武功按钮
                if skill and skill.type == SKILL_TYPE_NORMAL then
                    return true
                end
            end
        end

        return false
    end

    local isVisible = PrepareButtonIsVisible()

    local buttonName = "准武\n备功"

    local callback = function()
        Audio:playEffect("daAnNiu")

        self:hideSkillInfoPopUI()

        self:showSkillPrepareLayer()
    end

    self.__ui:setButtonPrepare(isVisible, buttonName, callback)
end

function MySelfSkillInfoPresenter:showBiGuanLayer(skillId)
    local BiGuanModel = require("app.models.BiGuan.BiGuanModel")

    --@RefType [src.app.models.BiGuan.BiGuanModel#BiGuanModel]
    local biGuan = BiGuanModel:create(skillId)

    if biGuan:checkCanBiGuan() == false then
        return
    end

    PopupLayerController:showLayer(
        "BiGuanLayer",
        function(layer)
            layer:showLayer(biGuan)
            layer:setCallback(
                function()
                    self:setSkillList()
                end
            )
        end
    )
end

function MySelfSkillInfoPresenter:showLianGongingLayer()
    self.__role:getXinShenSystem():getXinShenValue(
        function(ok, data)
            if ok then
                self.__role:getLianGongSystem():getLianGongTiLi(
                    function(ok, errmsg, tiliData)
                        if ok then
                            PopupLayerController:showLayer(
                                "LianGongDetailPresenter",
                                function(layer)
                                    layer:setXinShen(data.curr)
                                    layer:setXinShenMax(data.max)
                                    layer:setTiLi(tiliData.currTiLi)
                                    layer:setTiLiMax(tiliData.maxTiLi)
                                    layer:showLayer()
                                    layer:setCallBack(
                                        function()
                                            if self.__mainPresenter:getCurrSkillInfoPresenter() == self then
                                                self:setSkillList()
                                            end
                                        end
                                    )
                                end
                            )
                        else
                            PopText(errmsg)
                        end
                    end
                )
            else
                local msg = data
                PopText(msg)
            end
        end
    )
end

function MySelfSkillInfoPresenter:showXiuLianingLayer()
    self.__role:getXinShenSystem():getXinShenValue(
        function(ok, data)
            if ok then
                self.__role:getXiuLianSystem():getXiuLianTiLi(
                    function(ok, errmsg, tiliData)
                        if ok then
                            PopupLayerController:showLayer(
                                "XiuLianDetailPresenter",
                                function(layer)
                                    layer:setXinShen(data.curr)
                                    layer:setXinShenMax(data.max)
                                    layer:setTiLi(tiliData.currTiLi)
                                    layer:setTiLiMax(tiliData.maxTiLi)
                                    layer:showLayer()
                                    layer:setCallBack(
                                        function()
                                            if self.__mainPresenter:getCurrSkillInfoPresenter() == self then
                                                self:setSkillList()
                                            end
                                        end
                                    )
                                end
                            )
                        else
                            PopText(errmsg)
                        end
                    end
                )
            else
                local msg = data
                PopText(msg)
            end
        end
    )
end

function MySelfSkillInfoPresenter:showSkillBreakLayer()
    HttpManagerEx:getSkillBreakCurrency(
        self.__role:getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local SkillBreakThroughPresent = MainControllLayer:getLayer("SkillBreakThroughPresent")
                SkillBreakThroughPresent:setRole(self.__role)
                SkillBreakThroughPresent:initData(data)

                if data.currencyVersion then
                    self.__role:setCurrencyVersion(data.currencyVersion)
                end

                MainControllLayer:pushLayer("SkillBreakThroughPresent")
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function MySelfSkillInfoPresenter:showSkillPrepareLayer()
    local skillPrepareLayer = MainControllLayer:getLayer("SkillPrepareLayer")
    MainControllLayer:pushLayer("SkillPrepareLayer")
    skillPrepareLayer:setRole(self.__role)
    skillPrepareLayer:initPrepareSkills()
end

return class("MySelfSkillInfoPresenter", {BaseSkillInfoPresenter}, MySelfSkillInfoPresenter)
00000
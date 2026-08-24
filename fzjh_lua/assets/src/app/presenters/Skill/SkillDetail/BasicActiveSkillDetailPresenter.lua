--[[
    author:Seven
    time:2022-11-03 16:09:30
    desc: 技能详情展示界面
]]
local BasicActiveSkillDetailPresenter = class("BasicActiveSkillDetailPresenter", LayerEx)

function BasicActiveSkillDetailPresenter:create()
    local p = BasicActiveSkillDetailPresenter.new()
    return p:__init()
end

function BasicActiveSkillDetailPresenter:__init()
    --@RefType [ActiveSkillDetailUI]
    self.__ui = require("app.views.ui.SkillUI.ActiveSkillDetailUI"):create()

    self.__ui:addTo(self)

    self.__ui:setPanelBackClickFunc(
        function()
            self:hideLayer()
        end
    )

    return self
end

function BasicActiveSkillDetailPresenter:showLayer(act_id)
    --@RefType [src.app.presenters.Skill.SkillDetail.BasicActiveSkillDetail#BasicActiveSkillDetail]
    self.__basicActiveSkillDetail = require("app.presenters.Skill.SkillDetail.BasicActiveSkillDetail"):create(act_id)

    self.__ui:setTitleName(self.__basicActiveSkillDetail:getName())

    self.__ui:setActiveSkillDetailText(self.__basicActiveSkillDetail:getActiveText())

    self:__initLearnConditionsArea()

    self:__initUseConditionsArea()

    self.__ui:setThirdListSize(800, 260)

    self:show()
end

function BasicActiveSkillDetailPresenter:__initLearnConditionsArea()
    self.__ui:setSecondTitleName("学习条件：")

    self.__ui:clearSecondList()

    local learnTexts = self.__basicActiveSkillDetail:getLearnConditionTexts()

    if #learnTexts == 0 then
        table.insert(learnTexts, "此主动招式获取武学后直接领悟，无需额外学习")
    end

    for _, text in ipairs(learnTexts) do
        local textUI = self.__ui:getNewItemRowUI()

        textUI:setString(text)

        self.__ui:addSecondItemUI(textUI)
    end

    self.__ui:secondListJumpToTop()
end

function BasicActiveSkillDetailPresenter:__initUseConditionsArea()
    self.__ui:setThirdTitleName("使用条件：")

    self.__ui:clearThirdList()

    local learnTexts = self.__basicActiveSkillDetail:getUseConditionTexts()

    for _, text in ipairs(learnTexts) do
        local textUI = self.__ui:getNewItemRowUI()

        textUI:setString(text)

        self.__ui:addThirdItemUI(textUI)
    end
end

function BasicActiveSkillDetailPresenter:hideLayer()
    self.__ui:setThirdListSize(800, 275)

    PopupLayerController:hideLayer(
        "BasicActiveSkillDetailPresenter",
        function(layer)
            layer:hide()
        end
    )
end

Helper:classDefNodeGetInstance(BasicActiveSkillDetailPresenter)
return BasicActiveSkillDetailPresenter
000
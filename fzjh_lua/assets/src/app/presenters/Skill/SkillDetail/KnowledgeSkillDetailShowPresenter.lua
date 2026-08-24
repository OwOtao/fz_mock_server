--[[
    author:Seven
    time:2024-01-11 17:47:17
    desc: 一个知识类武学暂时界面（暂只适配先天属性切换知识类武学）
]]
local KnowledgeSkillDetailShowPresenter = class("KnowledgeSkillDetailShowPresenter", LayerEx)

function KnowledgeSkillDetailShowPresenter:create()
    return KnowledgeSkillDetailShowPresenter:new():__init()
end

function KnowledgeSkillDetailShowPresenter:__init()
    --@RefType [src.app.views.ui.SkillUI.SkillDetailInfoShowUI1#SkillDetailInfoShowUI1]
    self.__ui = require("app.views.ui.SkillUI.SkillDetailInfoShowUI1"):create()

    self.__ui:getUINode():addTo(self)

    self.__ui:setPanelBackClickFunc(
        function()
            self:hideLayer()
        end
    )

    return self
end

function KnowledgeSkillDetailShowPresenter:showLayer(role, skill)
    self.__skillId = skill.id

    self.__skillName = skill:getName()

    self.__skill = skill

    self.__role = role

    local roleSkillData = role:getSkill(self.__skillId)

    self.__exp = roleSkillData.exp

    self.__lv = skill:getLv(self.__exp)

    self.__ui:setTitleName(self.__skillName)

    self.__ui:setSkillDetailText(skill:getDsc())

    self:__setExpAndLevelShow(self.__exp, self.__lv)

    self:__showSkillStageInfo()

    self:show()
end

function KnowledgeSkillDetailShowPresenter:__setExpAndLevelShow(exp, lv)
    self.__ui:setExpText(tostring(Helper:mathFloor(exp)) .. "/" .. tostring(lv) .. "级")
end

function KnowledgeSkillDetailShowPresenter:__showSkillStageInfo()
    self.__ui:removeAllItems()

    --@RefType [src.app.models.skill.SkillStage.BasicSkillStage#BasicSkillStage]
    local currStage = self.__skill:getSkillStageBySkillLv(self.__lv)

    local currStagePanel = self.__ui:getPanelItem1()

    currStagePanel.Text_detailTitle:setString(tostring(self.__skillName) .. tostring(self.__lv) .. "级")

    currStagePanel.Text_detailDsc:setString(currStage:getStageText())

    self.__ui:addPanelItem(currStagePanel)

    local maxStageLv = self.__skill:getMaxStageLv()

    if currStage:getStageLevel() == maxStageLv then
        return
    end

    --@RefType [src.app.models.skill.SkillStage.BasicSkillStage#BasicSkillStage]
    local nextStage = self.__skill:getSkillStageById(currStage:getStageLevel() + 1)

    local nextStagePanel = self.__ui:getPanelItem1()

    nextStagePanel.Text_detailTitle:setString(tostring(self.__skillName) .. tostring(nextStage:getLevel()) .. "级解锁")

    nextStagePanel.Text_detailDsc:setString(nextStage:getStageText())

    self.__ui:addPanelItem(nextStagePanel)
end

function KnowledgeSkillDetailShowPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "KnowledgeSkillDetailShowPresenter",
        function(layer)
            self:hide()
        end
    )
end

Helper:classDefNodeGetInstance(KnowledgeSkillDetailShowPresenter)
return KnowledgeSkillDetailShowPresenter
0000000
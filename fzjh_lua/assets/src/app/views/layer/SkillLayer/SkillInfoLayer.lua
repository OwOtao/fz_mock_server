--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-08-01 18:16:50
--]]
local SkillInfoLayer = class("SkillInfoLayer", require("app.views.base.BaseLayer"))

local SkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.SkillInfoViewModel")

local TeacherSkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.TeacherSkillInfoViewModel")

local SkillConst = require("app.models.skill.SkillConst")

function SkillInfoLayer:create()
    local p = SkillInfoLayer:new()
    p:init()
    return p
end

function SkillInfoLayer:init()
    self.__ui = require("app.views.ui.SkillUI.SkillInfoUI"):create()

    self.__ui:addTo(self)

    self.__role = User:getRole()

    self:setPanelDiCallback()
end

function SkillInfoLayer:updateLayerSkinUI(skin_config)
    self.__ui:updateSkinUI(skin_config)

    self.__skinConfig = skin_config
end

function SkillInfoLayer:getSkinConfig()
    return self.__skinConfig
end

function SkillInfoLayer:getUI()
    return self.__ui
end

function SkillInfoLayer:showMySelfSkillInfoPresenter()
    self:hideCurrSkillInfoPresenter()

    local viewModel = SkillInfoViewModel:create(self.__role)

    self.__currSkillInfoPresenter = require("app.presenters.Skill.SkillInfo.MySelfSkillInfoPresenter"):create(self, viewModel)

    self.__currSkillInfoPresenter:showPresenter()
end

function SkillInfoLayer:showTeacherSkillInfoPresenter()
    self:hideCurrSkillInfoPresenter()

    local viewModel = TeacherSkillInfoViewModel:create(self.__teacherRole, self)

    self.__currSkillInfoPresenter = require("app.presenters.Skill.SkillInfo.TeacherSkillInfoPresenter"):create(self, viewModel)

    self.__currSkillInfoPresenter:showPresenter()
end

function SkillInfoLayer:getCurrSkillInfoPresenter()
    return self.__currSkillInfoPresenter
end

function SkillInfoLayer:hideCurrSkillInfoPresenter()
    if self.__currSkillInfoPresenter then
        self.__currSkillInfoPresenter:hideSkillInfoPresenter()

        self.__currSkillInfoPresenter = nil
    end
end

function SkillInfoLayer:onEnable()
    self.__mainSchedule =
        self:schedule(
        function(ft)
            self:update(ft)

            if self.__currSkillInfoPresenter then
                self.__currSkillInfoPresenter:update(ft)
            end
        end,
        0.1
    )
end

function SkillInfoLayer:onDisable()
    self:unschedule(self.__mainSchedule)
end

function SkillInfoLayer:setSkillList()
    if self.__currSkillInfoPresenter then
        self.__currSkillInfoPresenter:setSkillList()
    end
end

function SkillInfoLayer:getRole()
    return self.__role
end

function SkillInfoLayer:setTeacherRole(teacherRole)
    self.__teacherRole = teacherRole
end

function SkillInfoLayer:getTeacherRole()
    return self.__teacherRole
end

function SkillInfoLayer:update()
    self:showTextExp()

    self:showTextPot()

    self:refreshBiGuanText()
end

function SkillInfoLayer:showTextExp()
    local exp = self.__role:getNumAttr("exp")

    self.__ui:setTextExp("『经验』" .. exp)
end

function SkillInfoLayer:showTextPot()
    local pot = self.__role:getNumAttr("pot")

    self.__ui:setTextPot("『潜能』" .. pot)
end

function SkillInfoLayer:setPanelDiCallback()
    self.__ui:setPanelDi(
        function()
            self:hideSkillInfoPopUI()
        end
    )
end

function SkillInfoLayer:refreshBiGuanText()
    -- 闭关时文本不断刷新
    if self.__role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
        if not self._useTime then
            self._useTime = GetTime()
        end
        local tab = {
            "你默默运转内力，隐隐有些感觉。",
            "你将内力运出丹田，过紫宫、入泥丸、透十二重楼，遍布奇经八脉，然后收回丹田。",
            "你将内力运经诸穴，抵四肢百骸，然后又回收丹田。",
            "你在丹田中不断积蓄内力，只觉得浑身燥热。",
            "你缓缓呼吸吐纳，将空气中水露皆收为己用。"
        }

        if GetTime() - self._useTime > 1 then
            if not self._cuaNum or self._cuaNum > table.getn(tab) then
                self._cuaNum = 1
            end
            RichPrint("main", tab[self._cuaNum])
            self._cuaNum = self._cuaNum + 1
            self._useTime = GetTime()
        end
    end
end

function SkillInfoLayer:hideSkillInfoPopUI()
    if self.__currSkillInfoPresenter then
        self.__currSkillInfoPresenter:hideSkillInfoPopUI()
    end
end

Helper:classDefNodeGetInstance(SkillInfoLayer)
return SkillInfoLayer
000
--[[
    author:Seven
    time:2022-11-03 16:09:30
    desc: 技能详情展示界面
]]
local BasicSkillDetailPresenter = class("BasicSkillDetailPresenter", LayerEx)

local BasicSkillDetail = require("app.presenters.Skill.SkillDetail.BasicSkillDetail")

local BattleSceneRes = require("script.newbattle.demo.battleSceneConf")["战斗场景"]

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")

local FightFormula = require("app.FightSystem.FightFormula")

local SkillDetailAnimUI = require("app.views.ui.SkillUI.SkillDetailAnimUI")

function BasicSkillDetailPresenter:create()
    local p = BasicSkillDetailPresenter.new()
    return p:__init()
end

function BasicSkillDetailPresenter:__init()
    --@RefType [SkillDetailUI]
    self.__ui = require("app.views.ui.SkillUI.SkillDetailUI"):create()
    self.__ui:addTo(self)

    self:setVisible(false)

    self.__ui:setPanelBackClickFunc(
        function()
            self:hideLayer()
        end
    )

    self.__ui:setAnimAreaBackground(BattleSceneRes["默认通用"].fightBackground)

    return self
end

function BasicSkillDetailPresenter:showLayer(role, skillId)
    if role == nil then
        assert(false, "BasicSkillDetailPresenter:showLayer 参数错误，角色参数不可为空")
    end

    self.__role = role

    --@RefType [src.app.presenters.Skill.SkillDetail.BasicSkillDetail#BasicSkillDetail]
    self.__basicSkillDetail = BasicSkillDetail:create(skillId)

    self:__initTitle()
    self:__initSkillDetailText()
    self:__initActiveSkillDetail()
    self:__initAutoZhaoCombDetail()

    self:__initAnimArea()

    self.__moveTime = 0

    self:show(
        function()
            if self.__basicSkillDetail:isShowAnim() then
                self.__handle =
                    self:schedule(
                    function(ft)
                        if self.__rightAnim and self.__leftAnim then
                            self.__leftAnim:update(ft)
                            self.__rightAnim:update(ft)

                            self["__" .. self.__currUpdateFuncName](self, ft)
                        end
                    end,
                    1 / 30
                )
            end
        end
    )
end

function BasicSkillDetailPresenter:__initTitle()
    self.__ui:setTitleName(self.__basicSkillDetail:getName())
    self.__ui:titleEnableOutline(cc.c4b(31, 31, 31), 5)
end

function BasicSkillDetailPresenter:__initSkillDetailText()
    self.__ui:setSkillDetailText(self.__basicSkillDetail:getSkillDetailText())
end

function BasicSkillDetailPresenter:__initActiveSkillDetail()
    self.__ui:setSecondTitleName("特殊招式：")

    self.__ui:clearSecondDetailList()

    local activeCombList = self.__basicSkillDetail:getActiveSkillCombList()

    --@desc 临时列表
    local temp_list = {}
    for i, v in ipairs(activeCombList) do
        --@RefType [src.app.models.skill.BasicSkill.BasicActiveSkill#BasicActiveSkill]
        local activeComb = v
        table.insert(temp_list, activeComb)
        if i % 2 == 0 or i == table.getn(activeCombList) then
            local itemPanel = self.__ui:createNewSecondItemPanel()

            for comb_index, comb in ipairs(temp_list) do
                --@RefType [src.app.models.skill.BasicSkill.BasicActiveSkill#BasicActiveSkill]
                local comb = comb

                local activeSkillPanel = self.__ui:createNewSecondItemDetailPanel()

                activeSkillPanel.Text_3:enableOutline(cc.c4b(0, 0, 0, 255), 5)
                activeSkillPanel.Text_3:setString(comb:getActiveName())

                if Helper:getDef(self.__role:getSkillZhaoExp(comb:getActiveId()), 0) <= 0 then
                    activeSkillPanel.Text_3:setTextColor(cc.c4b(123, 123, 123, 255))
                else
                    activeSkillPanel.Text_3:setTextColor(cc.c4b(208, 208, 208, 255))
                end

                if comb_index == 1 then
                    activeSkillPanel:setPosition(0, 0)
                else
                    activeSkillPanel:setPosition(350, 0)
                end
                activeSkillPanel:setVisible(true)

                activeSkillPanel:releaseFunc(
                    function()
                        PopupLayerController:showLayer(
                            "BasicActiveSkillDetailPresenter",
                            function(layer)
                                layer:showLayer(comb:getActiveId())
                            end
                        )
                    end
                )

                itemPanel:addChild(activeSkillPanel)
            end

            self.__ui:addSecondDetailListItem(itemPanel)

            temp_list = {}
        end
    end
end

function BasicSkillDetailPresenter:__initAutoZhaoCombDetail()
    local autoZhaoList = self.__basicSkillDetail:getAutoZhaoList()

    self.__ui:setThirdTitleName("被动招式：")

    local count = table.getn(autoZhaoList)
    if count > 0 then
        self.__ui:setThirdDetailVisible(true)
        self.__ui:setThirdDetailText("共有" .. Helper:numberCast(count) .. "招")
        self.__ui:setThirdDetailClickFunc(
            function()
                local desc = ""
                for _, autoZhao in ipairs(autoZhaoList) do
                    -- --@RefType[src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination#AutoZhaoCombination]
                    -- local autoZhao = autoZhao
                    desc = desc .. autoZhao:getZhaoIdText() .. ": " .. autoZhao:getZhaoName() .. "\n" .. self.__basicSkillDetail:getCombActionText(autoZhao:getId()) .. "\n  \n"
                end

                local DialogKlayer = require("app.views.layer.DialogLayer.DialogKLayer")

                local dialog = DialogKlayer:getInstance()

                dialog:hide()

                dialog:showLayer("CYN" .. self.__basicSkillDetail:getName() .. "武学招式：共有" .. Helper:numberCast(count) .. "招", desc)
            end
        )
    else
        self.__ui:setThirdDetailVisible(false)
    end
end

function BasicSkillDetailPresenter:__initAnimArgs()
    --@desc 前跳执行的时间
    self.__moveTime = 0
    self.__leftAnimStartPos = cc.p(220, 174)
    self.__rightAnimStartPos = cc.p(794, 174)

    self.__attackAnimList = {}

    local attackerWeaponId = self.__basicSkillDetail:getWeaponResId()

    local weaponRes = WeaponTypesResManager:getWeaponInfo(attackerWeaponId)

    self.__weaponModule = weaponRes.weaponModule

    self.__weaponSkin = weaponRes.weaponSkin

    for i, v in ipairs(self.__basicSkillDetail:getAttackAnimResIdList()) do
        local attackAnim = AnimResManager:getAttackAnimName(v, self.__weaponModule)

        local offset = AnimResManager:getAttackAnimOffset(attackAnim)

        table.insert(self.__attackAnimList, {attackAnim, offset})
    end

    local firstOffset = self.__attackAnimList[1][2]

    self.__jumpForwardTargetPos = cc.p(self.__rightAnimStartPos.x - firstOffset, self.__rightAnimStartPos.y)

    self.__highest = math.abs((self.__jumpForwardTargetPos.x - self.__leftAnimStartPos.x)) / 1080 * 30

    self.__currUpdateFuncName = "animMoveUpdate"
end

function BasicSkillDetailPresenter:__animMoveUpdate(ft)
    if self.__moveTime == 0 then
        self.__leftAnim:playAnim(self.__basicSkillDetail:getBattleRunAnim(), false)
    end

    local percent = math.min(self.__moveTime / (3 / 10), 1)
    local next_pos = FightFormula:jumpFoward(self.__leftAnimStartPos, self.__jumpForwardTargetPos, percent)
    local hight = FightFormula:jumpHeight(self.__highest, percent)
    self.__leftAnim:setPosition(next_pos.x, next_pos.y, hight)
    if percent >= 1 then
        self.__currUpdateFuncName = "animAttackUpdate"
        return
    end
    self.__moveTime = self.__moveTime + ft
end

function BasicSkillDetailPresenter:__animAttackUpdate(ft)
    if self.__currAttackIndex == nil then
        self.__currAttackIndex = 1
        self.__playing = false
    end

    if self.__playing == false then
        local offset = self.__attackAnimList[self.__currAttackIndex][2]
        self.__leftAnim:setPosition(self.__rightAnimStartPos.x - offset, self.__rightAnimStartPos.y, 0)

        self.__leftAnim:playAnim(
            self.__attackAnimList[self.__currAttackIndex][1],
            false,
            function()
                if self.__currAttackIndex == table.getn(self.__attackAnimList) then
                    self.__currAttackIndex = 1
                else
                    self.__currAttackIndex = self.__currAttackIndex + 1
                end
                self.__playing = false
            end
        )

        self.__leftAnim:setEventCallback(
            function(event)
                if event.name == "Hurt" then
                    self.__rightAnim:playAnim(AnimResManager:getOtherAnimName(BattleConstConf:get("hurtChestAnimScarecrow")))
                end
            end
        )
        self.__playing = true
    end
end

function BasicSkillDetailPresenter:__initAnimArea()
    if not self.__basicSkillDetail:isShowAnim() then
        self.__ui:setAnimAreaVisible(false)
        return
    end
    self.__ui:setAnimAreaVisible(true)

    self:__initAnimArgs()

    --@RefType [src.app.views.ui.SkillUI.SkillDetailAnimUI#SkillDetailAnimUI]
    self.__leftAnim = SkillDetailAnimUI:create(self.__ui:getNewAnimNode())
    self.__leftAnim:playAnim(self.__basicSkillDetail:getStandAnimName(), false)
    self.__leftAnim:setPosition(self.__leftAnimStartPos.x, self.__leftAnimStartPos.y, 0)
    self.__leftAnim:setWeaponSkin(self.__weaponSkin)

    --@RefType [src.app.views.ui.SkillUI.SkillDetailAnimUI#SkillDetailAnimUI]
    self.__rightAnim = SkillDetailAnimUI:create(self.__ui:getNewAnimNode())

    self.__rightAnim:setPosition(794, 174, 0)

    self.__rightAnim:setAnimScaleX(-1)

    self.__rightAnim:setSkeletonAnimationPosition(15, 0)

    self.__rightAnim:playAnim(AnimResManager:getOtherAnimName(BattleConstConf:get("battleIdleAnimScarecrow")), false)

    self.__ui:addAnimNode(self.__leftAnim:getNode())
    self.__ui:addAnimNode(self.__rightAnim:getNode())
end

function BasicSkillDetailPresenter:hideLayer()
    if self.__handle then
        self:unschedule(self.__handle)
        self.__handle = nil
    end

    PopupLayerController:hideLayer(
        "BasicSkillDetailPresenter",
        function(layer)
            self.__currAttackIndex = nil

            if self.__rightAnim and self.__leftAnim then
                self.__rightAnim:getNode():removeFromParent()
                self.__leftAnim:getNode():removeFromParent()
                self.__rightAnim = nil
                self.__leftAnim = nil
            end

            self:hide()
        end
    )
end

Helper:classDefNodeGetInstance(BasicSkillDetailPresenter)
return BasicSkillDetailPresenter
000000000000000
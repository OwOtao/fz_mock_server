--@RefType[src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
local CharacterUICtrl = require("app.FightSystem.UICtrl.CharacterUICtrl")

--@RefType [src.app.FightSystem.UICtrl.UI.CharacterAnimUI#CharacterAnimUI]
local CharacterAnimUI = require("app.FightSystem.UICtrl.UI.CharacterAnimUI")

local CharacterInfoUI = require("app.FightSystem.UICtrl.UI.CharacterInfoUI")

local AnimCharacterInfoUI = require("app.FightSystem.UICtrl.UI.AnimCharacterInfoUI")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_UI_STATE = FightCommons.CHARACTER_UI_STATE

local CharacterCtrlFactory = {}

--@desc: 获取UI人物创建参数
--@author:Seven
--@time:2021-05-31 10:28:37
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function CharacterCtrlFactory:getCtrlBuilderParams(f_character)
    local targetId = f_character:getTarget():getId()

    local posIndex = f_character:getPosIndex()

    local pos = f_character:getPosition()

    local weapon = f_character:getWeapon()

    local weaponSkin = weapon:getWeaponSkin()

    --@region 主动技能按钮相关信息
    local activeSkillInfo = {}

    -- local prepActIds = f_character:getpre

    local actSkillMap = f_character:getPrepActiveSkillAtOrder()

    if MapIsEmpty(actSkillMap) == false then

        local ActiveSkillInfoVm = require("app.FightSystem.UICtrl.UIModel.ActiveSkillInfoVm")
        for prep_pos, act_id in pairs(actSkillMap) do
            --@RefType [src.app.FightSystem.FightSkill.NormalFightActiveSkill#NormalFightActiveSkill]
            local act_skill = f_character:getActiveSkill(act_id)

            --@RefType [src.app.FightSystem.UICtrl.UIModel.ActiveSkillInfoVm#ActiveSkillInfoVm]
            local act_vm = ActiveSkillInfoVm:create()

            act_vm:setType(FightCommons.CHARATER_CMD_TYPE.RELEASE_ACTIVE)

            act_vm:setId(act_skill:getId())

            act_vm:setName(act_skill:getName())

            act_vm:setDesc(act_skill:getDesc())

            act_vm:setLevel(act_skill:getLevel())

            act_vm:setConditionTexts(act_skill:getUseConditionTexts())

            act_vm:setCD(act_skill:getCD())

            act_vm:setCoolTime(act_skill:getCoolDownTime())

            act_vm:setEnable(false)

            act_vm:setCostNeili(act_skill:getNeiliCost())

            activeSkillInfo[prep_pos] = act_vm
        end
    end

    --@endregion

    --@RefType [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
    local weaponChangeVmInfo = require("app.FightSystem.UICtrl.UIModel.BtnInfoVm"):create("cWeapon")
    weaponChangeVmInfo:setType(FightCommons.CHARATER_CMD_TYPE.CHANGE_WEAPON)
    weaponChangeVmInfo:setName(BattleConstConf:get("battleAction_changeWeapon_name"))
    weaponChangeVmInfo:setCD(0)
    weaponChangeVmInfo:setCoolTime(1)
    if not f_character:standbyWeaponIsEmptyHand() then
        weaponChangeVmInfo:setEnable(true)
        weaponChangeVmInfo:setVisible(true)
    else
        weaponChangeVmInfo:setVisible(false)
        weaponChangeVmInfo:setEnable(false)
    end

    --@RefType [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
    local qiRecoverVmInfo = require("app.FightSystem.UICtrl.UIModel.BtnInfoVm"):create("cHealHp")
    qiRecoverVmInfo:setType(FightCommons.CHARATER_CMD_TYPE.QI_RECOEVE)
    qiRecoverVmInfo:setName(BattleConstConf:get("battleAction_healthy_name"))
    qiRecoverVmInfo:setCD(0)
    qiRecoverVmInfo:setCoolTime(BattleConstConf:get("battleAction_healthy_cd"))
    qiRecoverVmInfo:setVisible(true)
    qiRecoverVmInfo:setEnable(true)

    --@RefType [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
    local runawayVmInfo = require("app.FightSystem.UICtrl.UIModel.BtnInfoVm"):create("pRunaway")
    runawayVmInfo:setType(FightCommons.CHARATER_CMD_TYPE.RUNAWAY)
    runawayVmInfo:setName(BattleConstConf:get("battleAction_runAway_name"))
    runawayVmInfo:setCD(0)
    runawayVmInfo:setCoolTime(BattleConstConf:get("battleAction_runAway_cd"))
    runawayVmInfo:setVisible(true)
    runawayVmInfo:setEnable(true)

    return {
        targetId = targetId,
        posIndex = posIndex,
        pos = {x = pos.x, y = pos.y, h = pos.h},
        stand_anim = f_character:getStandAnimName(),
        join_anim = f_character:getJoinAnimName(),
        jumpForwardAnim = f_character:getJumpForwardAnimName(),
        jumpbackAnim = f_character:getJumpBackAnimName(),
        weaponSkin = weaponSkin,
        isPlayer = f_character:isPlayer(),
        controlledState = f_character:getControlledUIState(),
        species = f_character:getSpecies(),
        vm_attrs = {
            id = f_character:getId(),
            name = f_character:getAttr("name"),
            tili = f_character:getAttr("tili"),
            tiliMax = tonumber(BattleConstConf:get("tiliMax")) ,
            qi = f_character:getAttr("qi"),
            qiMax = f_character:getAttr("qiMax"),
            qiLimitBattle = f_character:getAttr("qiLimitBattle"),
            neili = f_character:getAttr("neili"),
            neiliMax = f_character:getAttr("neiliMax"),
            neiliLimit = f_character:getAttr("neiliLimit")
        },
        vm_activeSkill = activeSkillInfo,
        vm_qiRecover = qiRecoverVmInfo,
        vm_changeWeapon = weaponChangeVmInfo,
        vm_runawayVmInfo = runawayVmInfo,
        buffIdAndLevelArray = f_character:getBuffSystem():getRoleBuffIconAndLevelArray(f_character:getId())
    }
end

function CharacterCtrlFactory:createCharterUICtrl(animNode, characterCtrlBuilderParams)
    local animUICtrl = CharacterAnimUI:create(animNode)

    local ctrl = CharacterUICtrl:create()

    ctrl:setAnimUI(animUICtrl)

    local attrs = characterCtrlBuilderParams.vm_attrs
    for k, v in pairs(attrs) do
        ctrl:setVmAttr(k, v)
    end

    ctrl:setPosIndex(characterCtrlBuilderParams.posIndex)

    ctrl:setStandAnim(characterCtrlBuilderParams.stand_anim)

    ctrl:setJoinAnim(characterCtrlBuilderParams.join_anim)

    ctrl:setJumpForwardAnim(characterCtrlBuilderParams.jumpForwardAnim)

    ctrl:setJumpBackAnim(characterCtrlBuilderParams.jumpbackAnim)

    ctrl:setPosition(characterCtrlBuilderParams.pos.x, characterCtrlBuilderParams.pos.y, 0)

    ctrl:changeUIState(CHARACTER_UI_STATE.IDLE, characterCtrlBuilderParams.stand_anim, nil)

    ctrl:setWeaponSkin(characterCtrlBuilderParams.weaponSkin)

    ctrl:setTargetId(characterCtrlBuilderParams.targetId)

    ctrl:setActiveSkill(characterCtrlBuilderParams.vm_activeSkill)

    ctrl:setControlledState(characterCtrlBuilderParams.controlledState)

    ctrl:setSpecies(characterCtrlBuilderParams.species)

    ctrl:setChangeWeaponVmInfo(characterCtrlBuilderParams.vm_changeWeapon)

    ctrl:setRecoverQiVmInfo(characterCtrlBuilderParams.vm_qiRecover)

    ctrl:setRunawayVmInfo(characterCtrlBuilderParams.vm_runawayVmInfo)

    ctrl:setBuffIdAndLevelArray(characterCtrlBuilderParams.buffIdAndLevelArray)

    ctrl:initCharacterUI()

    ctrl:setAnimVisible(false)

    if characterCtrlBuilderParams.isPlayer then
        ctrl:setPlayer()
    end

    return ctrl
end

return CharacterCtrlFactory
000000000000000
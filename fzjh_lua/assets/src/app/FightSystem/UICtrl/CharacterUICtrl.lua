local NewClass = require("third.class.NewClass")

local DoTween = require("third.dotween.DoTween")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local CharacterDefaultConf = require("app.FightSystem.Configuration.CharacterDefaultConf")

local BuffIconMap = require("script.newbattle.demo.buffIcon")["Buff图标"]

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local CHARACTER_UI_STATE = FightCommons.CHARACTER_UI_STATE

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local CHARACTER_FIGHT_STATE = {
    OBSERVER = 0, --旁观者
    ATTACKER = 1, --攻击者
    TARGET = 2 --目标
}

local CharacterUICtrl = {
    --@desc 是否当前玩家控制的角色
    __isPlayer = false,
    __species = FightCommons.CHARACTER_SPECIES.MALE,
    __posIndex = -1,
    __targetId = nil,
    __isDead = false,
    __isRunAway = false,
    __pos = {
        x = 0,
        y = 0,
        h = 0
    },
    __vm_Attr = {
        id = "0",
        name = "",
        tili = 0,
        tiliMax = tonumber(BattleConstConf:get("tiliMax")),
        qi = 0,
        qiMax = 0,
        qiLimitBattle = 0,
        neili = 0,
        neiliMax = 0,
        neiliLimit = 0
    },
    --@desc 主动技能信息 type:[],element:{id= }
    __vm_activeSkill = {},
    --@desc 站立动画
    __standAnim = nil,
    --@desc 入场动画
    __joinAnim = nil,
    --@desc 前跳动画
    __jumpForwardAnim = nil,
    --@desc 后跳动画
    __jumpBackAnim = nil,
    --@RefType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
    __uiState = nil,
    --@desc 受控状态值
    __controlledState = FightCommons.CHARACTER_CONTROLLED_STATE.STAND,
    --@region UI控制器
    --@desc 信息面板
    __infoUI = nil,
    --@desc 角色动画UI
    __animUI = nil,
    --@desc 角色可操作按钮UI
    __ctrBtnUIs = {},
    --@endregion
    --@desc 体力条动画播放插值控制
    __tiliTween = nil,
    --@desc 存放主动技能CD插值对象
    __actBtnCDTween = {},
    __qiShieldVm = {
        isOpen = false,
        value = 0,
        animId = nil
    },
    __changeWeaponVmInfo = nil,
    __recoverQiVmInfo = nil,
    __runawayVmInfo = nil
}

--@desc:
--@author:Seven
--@time:2021-05-21 14:38:01
--@return [src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
function CharacterUICtrl:create()
    local p = self.new()

    return p
end

function CharacterUICtrl:ctor()
    --@RefType [src.third.dotween.DoTween#DoTween]
    self.__doTween = DoTween:create()
end

function CharacterUICtrl:setFightUICtrl(ctrl)
    --@RefType [Fight2Layer]
    self.__fightUICtrl = ctrl
end

function CharacterUICtrl:getId()
    return tostring(self:getVmAttr("id"))
end

function CharacterUICtrl:setTargetId(targetId)
    self.__targetId = targetId
end

function CharacterUICtrl:getTargetId()
    return self.__targetId
end

function CharacterUICtrl:setTheDead(bool)
    self.__isDead = bool
end

function CharacterUICtrl:isDead()
    return self.__isDead
end

function CharacterUICtrl:setSpecies(species)
    self.__species = species
end

function CharacterUICtrl:getSpecies()
    return self.__species
end

function CharacterUICtrl:setControlledState(controlledState)
    self.__controlledState = controlledState
end

function CharacterUICtrl:getControlledState()
    return self.__controlledState
end

function CharacterUICtrl:runAway()
    self.__isRunAway = true
end

function CharacterUICtrl:isRunAway()
    return self.__isRunAway
end

--@desc: 获取对方UI Ctrl
--@author:Seven
--@time:2021-05-31 17:27:52
--@targetId: 目标id
--@return [src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
function CharacterUICtrl:getTarget(targetId)
    if targetId ~= self.__targetId then
        assert(false, "CharacterUICtrl:getTarget : 传入目标id与记录目标id不相等，检查代码")
    end
    return self.__fightUICtrl:getCharacterUICtrl(targetId)
end

function CharacterUICtrl:changeTarget(targetId)
    self:setTargetId(targetId)
    self.__fightUICtrl:characterChangeTarget(self:getId(), targetId)
end

function CharacterUICtrl:showAnimTagView(tag)
    self.__animUI:setTagImgType(tag)
end

function CharacterUICtrl:getVmAttr(name)
    return self.__vm_Attr[name]
end

function CharacterUICtrl:__attrLimit(name, finalValue)
    if name == "qi" then
        local limitValue = self:getVmAttr("qiMax")
        if finalValue > limitValue then
            return limitValue
        end

        if finalValue < 0 then
            return 0
        end
    elseif name == "qiMax" then
        local limitValue = self:getVmAttr("qiLimitBattle")
        if finalValue > limitValue then
            return limitValue
        end

        if finalValue < 0 then
            return 0
        end
    elseif name == "neili" then
        local limitValue = self:getVmAttr("neiliLimit")

        if finalValue > limitValue then
            return limitValue
        end

        if finalValue < 0 then
            return 0
        end
    else
        if finalValue < 0 then
            return 0
        end
    end

    return finalValue
end

function CharacterUICtrl:addVmAttr(name, value)
    local currValue = self:getVmAttr(name)

    -- local finalValue = self:__attrLimit(name, currValue + value)

    self:setVmAttr(name, currValue + value)
end

function CharacterUICtrl:setVmAttr(name, value)
    if self.__vm_Attr[name] == nil then
        assert(false, "角色UI控制器,VM属性未定义：" .. name)
    end

    self.__vm_Attr[name] = value
end

function CharacterUICtrl:setStandAnim(animName)
    self.__standAnim = animName
end

function CharacterUICtrl:setJoinAnim(animName)
    self.__joinAnim = animName
end

function CharacterUICtrl:setJumpForwardAnim(animName)
    self.__jumpForwardAnim = animName
end

function CharacterUICtrl:setJumpBackAnim(animName)
    self.__jumpBackAnim = animName
end

function CharacterUICtrl:getJumpForwardAnim()
    return self.__jumpForwardAnim
end

function CharacterUICtrl:getJumpBackAnim()
    return self.__jumpBackAnim
end

function CharacterUICtrl:setPosIndex(index)
    self.__posIndex = index
end

function CharacterUICtrl:getPosIndex()
    return self.__posIndex
end

function CharacterUICtrl:setPosition(x, y, h)
    self.__pos.x = x
    self.__pos.y = y
    self.__pos.h = 0

    self:getAnimUI():setPosition(self.__pos.x, self.__pos.y, h)
end

function CharacterUICtrl:getPosition()
    return {
        x = self.__pos.x,
        y = self.__pos.y,
        h = self.__pos.h
    }
end

function CharacterUICtrl:setBuffIdAndLevelArray(buffIdAndLevelArray)
    self.__buffIdAndLevelArray = buffIdAndLevelArray
end

function CharacterUICtrl:setInfoUI(infoUI)
    --@RefType[src.app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI#ICharacterInfoUI]
    self.__infoUI = infoUI

    self.__infoUI:registerClickFunc(
        function()
            self.__infoUI:showAllBuffPanel()
        end,
        function()
            self.__infoUI:hideAllBuffPanel()
        end,
        function()
            self.__infoUI:hideAllBuffPanel()
        end
    )
end

--@desc: 获取角色信息面板
--@author:Seven
--@time:2021-05-21 14:51:45
--@return [src.app.FightSystem.UICtrl.UI.CharacterInfoUI#CharacterInfoUI]
function CharacterUICtrl:getInfoUI()
    return self.__infoUI
end

function CharacterUICtrl:setAnimUI(animUI)
    --@RefType[src.app.FightSystem.UICtrl.UI.CharacterAnimUI#CharacterAnimUI]
    self.__animUI = animUI
end

--@desc: 获取角色动画对象
--@author:Seven
--@time:2021-05-26 20:37:52
--@return [src.app.FightSystem.UICtrl.UI.CharacterAnimUI#CharacterAnimUI]
function CharacterUICtrl:getAnimUI()
    return self.__animUI
end

--@desc: 添加角色控制按钮
--@author:Seven
--@time:2021-07-09 14:36:25
--@btnUI: [src.app.FightSystem.UICtrl.UI.CharacterControllerBtnUI#CharacterControllerBtnUI]
function CharacterUICtrl:addControllerBtnUI(id, btnUI)
    self.__ctrBtnUIs[id] = btnUI
end

--@desc:
--@author:Seven
--@time:2021-07-09 14:37:56
--@id: id
--@return [src.app.FightSystem.UICtrl.UI.CharacterControllerBtnUI#CharacterControllerBtnUI]
function CharacterUICtrl:getControllerBtnUI(id)
    return self.__ctrBtnUIs[id]
end

--@desc: 获取角色UI状态
--@author:Seven
--@time:2021-05-26 20:46:18
--@return [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
function CharacterUICtrl:getUIState()
    return self.__uiState
end

function CharacterUICtrl:getCharacterFightStateMap()
    return CHARACTER_FIGHT_STATE
end

function CharacterUICtrl:updateBuffInfos(buffIdAndLevelArray)
    self.__buffIdAndLevelArray = buffIdAndLevelArray
    if self.__infoUI then
        local buffIconAndCountArray =
            table.map(
            buffIdAndLevelArray,
            function(item)
                local iconInfo = BuffIconMap[item.icon]
                if iconInfo == nil then
                    error("buff 图标信息未找到：icon（" .. tostring(item.icon) .. "）")
                end
                item.imagePath = iconInfo.iconRes
                item.count = item.level
                return item
            end
        )

        self.__infoUI:updateBuffIcon(buffIconAndCountArray)
    end
end

--初始化角色相关UI
function CharacterUICtrl:initCharacterUI()
    self:__updateCharacterInfo()
    self:__updateTiliProgress()

    self:updateBuffInfos(self.__buffIdAndLevelArray)

    if self.__infoUI then
        self.__infoUI:hideAllBuffPanel()
    end
end

function CharacterUICtrl:popOverHeadText(text, color)
    self.__animUI:popOverHeadText(text, color)
end

function CharacterUICtrl:setAnimScaleX(value)
    self.__animUI:setAnimScaleX(value)
    self.__animUI:setStatusAnchorPointType(value)
end

function CharacterUICtrl:beAttack(results)
    if MapIsEmpty(results) then
        return
    end

    for attrName, value in pairs(results) do
        if attrName == "qi" or attrName == "neili" or attrName == "qiMax" then
            self:addVmAttr(attrName, value)
        end
    end

    self:__updateCharacterInfo()

    local currQi = self:getVmAttr("qi")

    if currQi <= 0 and self:isDead() == false then
        self:setTheDead(true)
    end
end

function CharacterUICtrl:syncViewAndValue()
    local curr_qiMax = self:getVmAttr("qiMax")
    local qiMaxStr = self:__attrLimit("qiMax", curr_qiMax)
    if qiMaxStr ~= curr_qiMax then
        self:setVmAttr("qiMax", qiMaxStr)
    end

    local curr_qi = self:getVmAttr("qi")
    local qiStr = self:__attrLimit("qi", curr_qi)
    if curr_qi ~= qiStr then
        self:setVmAttr("qi", qiStr)
    end

    local curr_neili = self:getVmAttr("neili")
    local neiliStr = self:__attrLimit("neili", curr_neili)
    if curr_neili ~= neiliStr then
        self:setVmAttr("neili", neiliStr)
    end
    
    self:__updateCharacterInfo()
end

function CharacterUICtrl:__updateCharacterInfo()
    local curr_qi = self:getVmAttr("qi")

    local curr_qiMax = self:getVmAttr("qiMax")

    local qiLimit = self:getVmAttr("qiLimitBattle")

    local curr_neili = self:getVmAttr("neili")

    local curr_neiliMax = self:getVmAttr("neiliMax")

    local qiStr = Helper:mathFloor(self:__attrLimit("qi", curr_qi))

    local qiMaxStr = Helper:mathFloor(self:__attrLimit("qiMax", curr_qiMax))

    local neiliStr = Helper:mathFloor(self:__attrLimit("neili", curr_neili))

    if self.__infoUI then
        self.__infoUI:setRoleQiAndQiMaxValue(qiStr, qiMaxStr)
        self.__infoUI:setRoleQiProgress(qiStr / qiLimit * 100)
        self.__infoUI:setRoleQiMaxProgress(qiMaxStr / qiLimit * 100)
        self.__infoUI:setRoleNeiLiAndNeiLiMaxValue(neiliStr, curr_neiliMax)
        self.__infoUI:setRoleNeiLiProgress(neiliStr / curr_neiliMax * 100)
        self.__infoUI:setRoleName(self:getVmAttr("name"))
    end

    self.__animUI:setQiProgress(qiStr / qiMaxStr * 100)

    self.__animUI:setQiMaxProgress(qiMaxStr / qiLimit * 100)

    self.__animUI:setNeiLiProgress(neiliStr / curr_neiliMax * 100)
end

function CharacterUICtrl:__updateTiliProgress()
    --@desc 可出手的占比
    local attack_percent = BattleConstConf:get("autoUseSkillTili") / self:getVmAttr("tiliMax") * 100

    local percent = (self:getVmAttr("tili") / self:getVmAttr("tiliMax")) * 100

    if self.__infoUI then
        self.__infoUI:setTiliMaxProgress(percent)
        if percent <= attack_percent then
            self.__infoUI:setTiliProgress(percent)
        end
    end

    self.__animUI:setTiliMaxProgress(percent)
    if percent <= attack_percent then
        self.__animUI:setTiliProgress(percent)
    end
end

function CharacterUICtrl:setPlayer()
    self.__isPlayer = true
end

function CharacterUICtrl:isPlayer()
    return self.__isPlayer
end

function CharacterUICtrl:setAnimVisible(bool)
    return self.__animUI:setVisible(bool)
end

--@desc: 播放动画
--@author:Seven
--@time:2021-05-26 20:38:03
--@animName: 动画名称
--@isLoop: 是否循环
function CharacterUICtrl:playAnim(animName, isLoop, eventCallback, completeCallback)
    self.__animUI:setEventCallback(eventCallback)
    self.__animUI:setCompleteCallback(completeCallback)
    self.__animUI:playAnim(animName, isLoop)
end

function CharacterUICtrl:playOneOffEffect(animName)
    self.__animUI:playOneOffEffect(animName)
end

function CharacterUICtrl:recoverTili(recoverValue, ft)
    self:__killTiliTween()
    --@RefType [src.third.dotween.Tween#Tween]
    self.__tiliTween =
        self.__doTween:doNumber(
        function()
            return self:getVmAttr("tili")
        end,
        function(tili)
            self:setVmAttr("tili", tili)
            self:__updateTiliProgress()
        end,
        self:getVmAttr("tili") + recoverValue,
        ft
    )
end

function CharacterUICtrl:updateQiRecoverEnable(bool)
    local recoverVm = self:getRecoverQiVmInfo()
    if recoverVm:getEnable() == bool then
        return
    end

    recoverVm:setEnable(bool)

    self.__fightUICtrl:updateBtnEnable(self:getId(), recoverVm:getId(), bool)
end

function CharacterUICtrl:updateRecoverQiCD(preCD, endCdValue, ft)
    local recoverVm = self:getRecoverQiVmInfo()

    if self.__recovetQiTween then
        self.__recovetQiTween:kill()
        self.__recovetQiTween = nil
    end

    local doTween =
        self.__doTween:doNumber(
        function()
            return recoverVm:getCD()
        end,
        function(cd)
            self:__setRecoverQiVmCD(cd)
        end,
        endCdValue,
        ft
    ):onKill(
        function()
            self.__recovetQiTween = nil
        end
    )

    self.__recovetQiTween = doTween
end

function CharacterUICtrl:__setRecoverQiVmCD(cd)
    local recoverVm = self:getRecoverQiVmInfo()

    if recoverVm:getCD() == cd then
        return
    end

    recoverVm:setCD(cd)

    self.__fightUICtrl:updatePlayerBtnProgress(self:getId(), recoverVm:getId(), recoverVm:getCoolTime() - recoverVm:getCD(), recoverVm:getCoolTime())
end

function CharacterUICtrl:updateRunawayCD(preCD, endCdValue, ft)
    local runawayVm = self:getRunawayVmInfo()
    if self.__runawayTween then
        self.__runawayTween:kill()
        self.__runawayTween = nil
    end

    local doTween =
        self.__doTween:doNumber(
        function()
            return runawayVm:getCD()
        end,
        function(cd)
            self:__setRunawayVmCD(cd)
        end,
        endCdValue,
        ft
    ):onKill(
        function()
            self.__runawayTween = nil
        end
    )

    self.__runawayTween = doTween
end

function CharacterUICtrl:__setRunawayVmCD(cd)
    local runawayVm = self:getRunawayVmInfo()

    if runawayVm:getCD() == cd then
        return
    end

    runawayVm:setCD(cd)

    self.__fightUICtrl:updatePlayerBtnProgress(self:getId(), runawayVm:getId(), runawayVm:getCoolTime() - runawayVm:getCD(), runawayVm:getCoolTime())
end

function CharacterUICtrl:removeAllActiveSkills()
    if MapIsEmpty(self.__vm_activeSkill) then
        return
    end

    for i = 1, FightCommons.ACTIVE_UI_BTN_COUNT do
        local btnId = "-1"

        local vm = self.__vm_activeSkill[tostring(i)]
        if vm then
            btnId = vm:getId()
            local tween = self.__actBtnCDTween[btnId]

            if tween then
                tween:kill()
                self.__actBtnCDTween[btnId] = nil
            end
        end

        self.__fightUICtrl:removeBtn(self:getId(), btnId)
    end
end

function CharacterUICtrl:updateActiveSkillCD(act_id, preCD, endCdValue, ft)
    local vm_actSkill = self:getVMActiveSkill(act_id)

    if vm_actSkill == nil then
        local tween = self.__actBtnCDTween[act_id]

        if tween then
            tween:kill()
            self.__actBtnCDTween[act_id] = nil
        end
        return
    end

    self:__setActiveSkillCD(act_id, preCD)

    local tween = self.__actBtnCDTween[act_id]

    if tween then
        tween:kill()
        self.__actBtnCDTween[act_id] = nil
    end

    local doTween =
        self.__doTween:doNumber(
        function()
            local vm_actSkill = self:getVMActiveSkill(act_id)
            if vm_actSkill == nil then
                return 0
            end
            local act_cd = vm_actSkill:getCD()
            return act_cd
        end,
        function(newCd)
            self:__setActiveSkillCD(act_id, newCd)
        end,
        endCdValue,
        ft
    )

    doTween:onKill(
        function()
            self.__actBtnCDTween[act_id] = nil
        end
    )

    self.__actBtnCDTween[act_id] = doTween
end

function CharacterUICtrl:setActiveSkillCD(act_id, cd)
    local tween = self.__actBtnCDTween[act_id]

    if tween then
        tween:kill()
        self.__actBtnCDTween[act_id] = nil
    end

    self:__setActiveSkillCD(act_id, cd)
end

function CharacterUICtrl:__setActiveSkillCD(act_id, cd)
    local vm_actSkill = self:getVMActiveSkill(act_id)

    if vm_actSkill == nil then
        return
    end

    if vm_actSkill:getCD() == cd then
        return
    end

    vm_actSkill:setCD(cd)

    self.__fightUICtrl:updatePlayerBtnProgress(self:getId(), vm_actSkill:getId(), vm_actSkill:getCoolTime() - vm_actSkill:getCD(), vm_actSkill:getCoolTime())
end

function CharacterUICtrl:updateActiveSkillEnable(act_id, bool)
    local vm_actSkill = self:getVMActiveSkill(act_id)

    if vm_actSkill == nil then
        return
    end

    if vm_actSkill:getEnable() == bool then
        return
    else
        vm_actSkill:setEnable(bool)
    end

    self.__fightUICtrl:updateBtnEnable(self:getId(), vm_actSkill:getId(), bool)
end

function CharacterUICtrl:costTili(nowTili)
    self:__killTiliTween()
    self:setVmAttr("tili", nowTili)
    self:__updateTiliProgress()
end

function CharacterUICtrl:__killTiliTween()
    if self.__tiliTween then
        self.__tiliTween:kill()
        self.__tiliTween = nil
    end
end

function CharacterUICtrl:costNeili(value)
    self:addVmAttr("neili", value)
    self:__updateCharacterInfo()
    if self.__infoUI then
        self.__infoUI:showNeiliCost(value)
    end
end

function CharacterUICtrl:changeUIState(state_type, animName, params)
    if self.__uiState then
        self.__uiState:onLeave()
    end

    local next_state
    if state_type == CHARACTER_UI_STATE.IDLE then
        next_state = require("app.FightSystem.UICtrl.UI.CharacterUIState.IdleState"):create()
    elseif state_type == CHARACTER_UI_STATE.JOINING then
        next_state = require("app.FightSystem.UICtrl.UI.CharacterUIState.JoinFightState"):create()
    elseif state_type == CHARACTER_UI_STATE.JUMPING then
        next_state = require("app.FightSystem.UICtrl.UI.CharacterUIState.JumpState"):create()
    elseif state_type == CHARACTER_UI_STATE.ATTACK then
        next_state = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackState"):create()
    elseif state_type == CHARACTER_UI_STATE.ACTIVEREADY then
        next_state = require("app.FightSystem.UICtrl.UI.CharacterUIState.ActiveReadyUIState"):create()
    elseif state_type == CHARACTER_UI_STATE.RECOVERQI then
        next_state = require("app.FightSystem.UICtrl.UI.CharacterUIState.RecoverQiState"):create()
    elseif state_type == CHARACTER_UI_STATE.CHANGEWEAPON then
        next_state = require("app.FightSystem.UICtrl.UI.CharacterUIState.ChangeWeaponState"):create()
    end

    --@RefType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
    self.__uiState = next_state

    self.__uiState:setCharacterUICtrl(self)

    self.__uiState:setAnimName(animName)

    self.__uiState:onInit()

    self.__uiState:onEnter(params)
end

--@weapon: [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function CharacterUICtrl:changeWeapon(weapon)
    self:setWeaponSkin(weapon:getWeaponSkin())
end

function CharacterUICtrl:setWeaponSkin(weaponSkinName)
    self.__animUI:setWeaponSkin(weaponSkinName)
end

function CharacterUICtrl:getStandAnim()
    return self.__standAnim
end

function CharacterUICtrl:jump(animName, jump_info)
    -- self:setPosition(jump_info.start_pos.x, jump_info.start_pos.y, jump_info.start_pos.h)
    self:changeUIState(CHARACTER_UI_STATE.JUMPING, animName, jump_info)
end

function CharacterUICtrl:tryGetCharacterUICtrls(condition)
    return self.__fightUICtrl:tryGetCharacterUICtrls(condition)
end

--@desc: 受击处理
--@author:Seven
--@time:2021-07-15 20:43:25
function CharacterUICtrl:underAttack(hurts)
    for _, hurt in ipairs(hurts) do
        local attrName = hurt.attrName
        local value = hurt.value
        self:addVmAttr(attrName, -value)
    end
    self:__updateCharacterInfo()

    local currQi = self:getVmAttr("qi")

    if currQi <= 0 and self:isDead() == false then
        self:setTheDead(true)
    end
end

function CharacterUICtrl:buffUpdateTili(value)
    self:costTili(value)
end

function CharacterUICtrl:buffSetAttr(attrName, addValue)
    self:addVmAttr(attrName, addValue)
    self:__updateCharacterInfo()

    if attrName == "qi" then
        local currQi = self:getVmAttr("qi")

        if currQi <= 0 and self:isDead() == false then
            self:playDeadAnim(FightCommons.HIT_POS.CHEST)
            self:setTheDead(true)
        end
    end
end

function CharacterUICtrl:printDesces(desces)
    for _, desc in ipairs(desces) do
        self.__fightUICtrl:printFightMsg(desc:getString())
    end
end

--@desc: 攻击
--@author:Seven
--@time:2021-05-27 14:07:01
function CharacterUICtrl:attack(targetId, zhaoAtk)
    self:changeUIState(CHARACTER_UI_STATE.ATTACK, zhaoAtk:getAttackAnims():getAttackerAnim(), {targetId = targetId, zhaoAtk = zhaoAtk})
end

function CharacterUICtrl:activeReady(animName, params)
    self:changeUIState(CHARACTER_UI_STATE.ACTIVEREADY, animName, params)
end

--@desc: 进入战场
--@author:Seven
--@time:2021-06-14 16:29:57
function CharacterUICtrl:enterFight()
    self:changeUIState(CHARACTER_UI_STATE.JOINING, self.__joinAnim)
end

function CharacterUICtrl:setActiveSkill(activeSkillInfo)
    self.__vm_activeSkill = activeSkillInfo
end

function CharacterUICtrl:getVMActiveSkills()
    return self.__vm_activeSkill
end

--@desc: 获取主动技能ui数据
--@author:Seven
--@time:2021-08-31 16:17:31
--@act_id: 技能id
--@return [src.app.FightSystem.UICtrl.UIModel.ActiveSkillInfoVm#ActiveSkillInfoVm]
function CharacterUICtrl:getVMActiveSkill(act_id)
    if MapIsEmpty(self.__vm_activeSkill) then
        return
    end

    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        --@RefType [src.app.FightSystem.UICtrl.UIModel.ActiveSkillInfoVm#ActiveSkillInfoVm]
        local vm_actSkill = self.__vm_activeSkill[tostring(i)]

        if vm_actSkill and vm_actSkill:getId() == act_id then
            return vm_actSkill
        end
    end

    return nil
    -- error("CharacterUICtrl:getVMActiveSkill 获取主动技能数据错误 act_id : " .. act_id)
end

function CharacterUICtrl:getHurtAnim(hitPos)
    return CharacterDefaultConf:getHurtAnim(self.__species, hitPos)
end

function CharacterUICtrl:getHurtDeadAnim(hitPos)
    return CharacterDefaultConf:getDeadAnim(self.__species, hitPos)
end

function CharacterUICtrl:enterIdleState()
    if self:isDead() then
        return
    end

    if FightCommons.CHARACTER_CONTROLLED_STATE.STAND == self.__controlledState then
        return self:__stand()
    elseif FightCommons.CHARACTER_CONTROLLED_STATE.STUN == self.__controlledState then
        return self:__stun()
    elseif FightCommons.CHARACTER_CONTROLLED_STATE.CONFUSE == self.__controlledState then
        return self:__confuse()
    end
end

function CharacterUICtrl:__stand()
    self:changeUIState(CHARACTER_UI_STATE.IDLE, self.__standAnim, nil)
end

function CharacterUICtrl:__stun()
    local animName = CharacterDefaultConf:getControlledStunAnim(self.__species)
    self:changeUIState(CHARACTER_UI_STATE.IDLE, animName, nil)
end

function CharacterUICtrl:__confuse()
    local animName = CharacterDefaultConf:getControlledConfuseAnim(self.__species)
    self:changeUIState(CHARACTER_UI_STATE.IDLE, animName, nil)
end

function CharacterUICtrl:updateControlledState(controlledState)
    self:setControlledState(controlledState)
    self:enterIdleState()
end

function CharacterUICtrl:showStatusTips(str)
    self.__animUI:showStatusText(str)
end

function CharacterUICtrl:hideStatusTips()
    self.__animUI:hideStatusText()
end

function CharacterUICtrl:showOpertionName(name)
    if not self.__infoUI then
        return
    end

    self.__infoUI:showOperationName(name)
end

function CharacterUICtrl:removeOperationName()
    self.__infoUI:hideOperationName()
end

function CharacterUICtrl:removeAllOperationName()
    self.__infoUI:removeAllOperationName()
end

function CharacterUICtrl:playSound(audioName)
    Audio:playEffectWithFileName(audioName, false)
end

function CharacterUICtrl:getHurtSound()
    local soundName = CharacterDefaultConf:getHurtSound(self:getSpecies())
    return soundName
end

function CharacterUICtrl:getDieSound()
    local soundName = CharacterDefaultConf:getDieSound(self:getSpecies())
    return soundName
end

function CharacterUICtrl:playDeadAnim(hitPos)
    self:playAnim(self:getHurtDeadAnim(FightCommons.HIT_POS.CHEST), false)
    self:playSound(self:getDieSound())
    self:hideStatusTips()
    self:hideQiShieldAnim()
end

function CharacterUICtrl:setQiShieldValue(value)
    self.__qiShieldVm.value = value
end

function CharacterUICtrl:comsumeQiShieldValue(value)
    if value < 0 then
        error("UI 消耗护盾值，参数不可是负数")
    end
    local currValue = self.__qiShieldVm.value
    local acutalValue = math.max(currValue - value, 0)
    self:setQiShieldValue(acutalValue)

    if acutalValue <= 0 and self.__qiShieldVm.isOpen then
        self:hideQiShieldAnim()
    end
end

function CharacterUICtrl:showQiShieldAnim(animId)
    if self.__qiShieldVm.isOpen == false then
        self.__animUI:setShieldAnimVisible(true)
        self.__qiShieldVm.isOpen = true
    end

    if self.__qiShieldVm.animId ~= animId then
        local animName = AnimResManager:getOtherAnimName(animId)
        self.__animUI:playShieldAnim(animName)
        self.__qiShieldVm.animId = animId
    end
end

function CharacterUICtrl:hideQiShieldAnim()
    if self.__qiShieldVm.isOpen == true then
        self.__animUI:setShieldAnimVisible(false)
        self.__qiShieldVm.isOpen = false
    end

    self.__qiShieldVm.animId = nil
end

function CharacterUICtrl:showShadowEffect(animId)
    self.__animUI:setShadowEffectAnimVisible(true)
    local animName = AnimResManager:getOtherAnimName(animId)
    self.__animUI:playShadowEffectAnim(animName)
end

function CharacterUICtrl:hideShadowEffect()
    self.__animUI:setShadowEffectAnimVisible(false)
end

function CharacterUICtrl:update(ft)
    self.__animUI:onUpdate(ft)

    self.__doTween:update(ft)

    self.__uiState:onUpdate(ft)

    if self.__infoUI then
        self.__infoUI:onUpdate(ft)
    end
end

function CharacterUICtrl:setRunawayVmInfo(vmInfo)
    --@RefType [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
    self.__runawayVmInfo = vmInfo
end

--@return  [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
function CharacterUICtrl:getRunawayVmInfo()
    return self.__runawayVmInfo
end

function CharacterUICtrl:setRecoverQiVmInfo(vmInfo)
    --@RefType [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
    self.__recoverQiVmInfo = vmInfo
end

--@author:Seven
--@time:2022-01-14 16:23:42
--@return [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
function CharacterUICtrl:getRecoverQiVmInfo()
    return self.__recoverQiVmInfo
end

function CharacterUICtrl:setChangeWeaponVmInfo(vmInfo)
    --@RefType [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
    self.__changeWeaponVmInfo = vmInfo
end

--@author:Seven
--@time:2022-01-14 16:23:35
--@return [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
function CharacterUICtrl:getChangeWeaponVmInfo()
    return self.__changeWeaponVmInfo
end

function CharacterUICtrl:recoverQi(animName, value)
    self:changeUIState(CHARACTER_UI_STATE.RECOVERQI, animName, {value = value})
    self:addVmAttr("qi", value)
    self:__updateCharacterInfo()

    self:removeOperationName()
end

function CharacterUICtrl:characterChangedStandByWeapon(animName, weapon, nextActSkillsList, viewInfo)
    self:changeUIState(CHARACTER_UI_STATE.CHANGEWEAPON, animName, {weapon = weapon, nextActiveSkills = nextActSkillsList, viewInfo = viewInfo})

    self.__changeWeaponVmInfo:setVisible(false)

    self.__fightUICtrl:updateBtnVisible(self:getId(), self.__changeWeaponVmInfo:getId(), false)
end

function CharacterUICtrl:changeAllActiveSkills(activeSkillInfos)
    self:removeAllActiveSkills()
    self.__vm_activeSkill = activeSkillInfos
    self.__fightUICtrl:updatePlayerActiveSkillBtns(self:getId(), activeSkillInfos)
end

return NewClass("CharacterUICtrl", {}, CharacterUICtrl)
0000
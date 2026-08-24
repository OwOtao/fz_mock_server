local class = require("third.class.NewClass")
local AFightSystem = require("app.FightSystem.AFightSystem")

local FightTeam = require("app.FightSystem.FightDataModel.FightTeam")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

local FightCommons = require("app.FightSystem.FightCommons")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

--@RefType[src.app.FightSystem.FightBuff.Constants#Constants]
local BuffSystemConstants = require("app.FightSystem.FightBuff.Constants")

local FIGHT_CMD_TYPE = FightCommons.FIGHT_CMD_TYPE

local FIGHT_STATE = FightCommons.FIGHT_STATE

local CHARACTER_CMD_TYPE = FightCommons.CHARATER_CMD_TYPE

--@SuperType [src.app.FightSystem.AFightSystem#AFightSystem]
local CharacterSystem = {}

function CharacterSystem:init()
    -- self.__teams = {}

    self.__characters = {}

    --@desc 角色主动技能准备释放列表
    self.__prepReleaseActiveSkillList = {}

    --@desc 被动技能出手列表
    self.__can_autoattack_list = {}

    --@desc 逃跑列表
    self.__prepRunawayList = {}

    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__preAutoAttacker = nil

    --@desc 当前正在行动的角色id
    self.__actionCId = nil

    self.__activeAutoReleaseElapsed = 0

    --@RefType [src.app.FightSystem.FightRole.CharacterCmdSystem#CharacterCmdSystem]
    self.__characterCmdSys = require("app.FightSystem.FightRole.CharacterCmdSystem"):create()
end

function CharacterSystem:getTeams()
    return self.__teams
end

--@desc: 获取目标队伍
--@author:Seven
--@time:2021-05-11 16:52:10
--@character_team_id: 角色所在队伍id
function CharacterSystem:getTargetTeam(character_team_id)
    local leftTeamId = self.__fight:getLeftTeamId()
    local rightTeamId = self.__fight:getRightTeamId()

    if character_team_id == leftTeamId then
        return self.__fight:getFightTeamById(rightTeamId)
    end

    if character_team_id == rightTeamId then
        return self.__fight:getFightTeamById(leftTeamId)
    end

    assert(false, "CharacterSystem:getTargetTeam 获取对方队伍失败，角色队伍ID ：" .. character_team_id)
end

--@desc: 添加角色
--@author:Seven
--@time:2021-05-07 16:59:59
--@team_id: 队伍ID
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function CharacterSystem:addCharacter(f_character)
    f_character:setCharacterSystem(self)
    f_character:setBuffSystem(self:getFight():getBuffSystem())
    table.insert(self.__characters, f_character)
end

function CharacterSystem:getCharacters()
    return self.__characters
end

--@desc: 获取角色
--@author:Seven
--@time:2021-05-07 17:13:44
--@c_id: 角色id
function CharacterSystem:getCharacter(character_id)
    if #self.__characters <= 0 then
        error("Can't find the fight role : " .. character_id)
    end

    for i = 1, #self.__characters do
        --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
        local f_character = self.__characters[i]

        if f_character:getId() == character_id then
            return f_character
        end
    end

    error("Can't find the fight role : " .. character_id)
end

function CharacterSystem:startFight()
    --@desc 分配对手
    for i = 1, #self.__characters do
        --@RefType[src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
        local f_character = self.__characters[i]
        local target = f_character:selectTarget()
        f_character:setTarget(target)

        -- 添加主动技能携带buff
        for i, buff in ipairs(f_character:getCarryBuffArray()) do
            FightUtil:printLog("添加携带buff:", buff)
            f_character:getBuffSystem():addBuff(f_character, f_character, buff[1], 1, buff[2], buff[3], buff[4], 100)
        end
    end
end

function CharacterSystem:release()
    self.__teams = {}
    self.__characters = {}
end

function CharacterSystem:update(ft)
    if #self.__characters <= 0 then
        return
    end

    self:__checkCharacterRunaway()

    self:__checkCharacterChangeWeapon()

    self:__checkCharacterRecoverQi()

    self:__checkActiveRelease()

    self:__checkActiveAutoRelease()

    self:__checkAutoRelease()

    for i = 1, #self.__characters do
        --@RefType[src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
        local f_character = self.__characters[i]
        f_character:update(ft)
    end
end

function CharacterSystem:updateCharacterControlledState(c_id, state)
    local character = self:getCharacter(c_id)

    character:updateControlledUIState(state)
end

--@desc: 设置正在行动的角色
--@author:Seven
--@time:2021-06-28 16:22:58
--@c_id: 角色ID
function CharacterSystem:startAction(c_id)
    if self.__actionCId ~= nil then
        assert(false, "CharacterSystem:startAction 有角色行动未结束，请检查！")
    end

    self.__actionCId = c_id
end

--@desc: 角色行动结束
--@author:Seven
--@time:2021-06-28 16:23:16
--@c_id: 角色id
function CharacterSystem:finishAction(c_id)
    if self.__actionCId ~= nil and self.__actionCId ~= c_id then
        assert(false, "CharacterSystem:finishAction 结束行动调用者非当前行动角色，请检查。")
    end

    self.__actionCId = nil

    self:__checkCharacterRunaway()

    self:__checkActiveAutoRelease()
end

--@desc: 角色招式组合攻击开始
--@author:Seven
--@time:2021-06-28 17:26:55
function CharacterSystem:characterZhaoCombStart(c_id)
end

function CharacterSystem:doWhenZhaoCombFinish(c_id, skillAttack)
    for _, character in pairs(self.__characters) do
        --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
        local character = character
        if not character:isDead() then
            local AttackBuffExecutors = require("app.FightSystem.FightBuff.BuffExecutor.AttackBuffExecutors")
            
            --@RefType [src.app.FightSystem.FightBuff.BuffExecutor.AttackBuffExecutors#AttackBuffExecutors]
            local executor = AttackBuffExecutors:create()
            executor:setSkillAttack(skillAttack)
            executor:addExecutor(character:getBuffExecutor(BuffSystemConstants.BuffTriggerType.SomeBodyAttackEnd))
            executor:execute()
            character:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.SomeBodyAttackEnd)
        end
    end
end

--@desc: 角色招式组合攻击结束
--@author:Seven
--@time:2021-06-28 17:26:22
--@c_id: 完成招式组合攻击的角色id
--@skillAttack: [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.ISkillAttack#ISkillAttack]
function CharacterSystem:characterZhaoCombFinish(c_id, skillAttack)
    local character = self:getCharacter(c_id)

    if self:__checkContinueToActiveSkill(c_id, skillAttack) then
        return
    end

    self:__checkContinueToAutoSkill(c_id, skillAttack)

    local character = self:getCharacter(c_id)
    if character:isDead() then
        skillAttack:finishAttack()
        character:finishAction()
    end
end

function CharacterSystem:__checkContinueToActiveSkill(c_id, skillAttack)
    --@RefType [src.app.FightSystem.FightRole.CharacterCommands.CharacterReleaseActiveSkillCommand#CharacterReleaseActiveSkillCommand]
    local firstCmd = self.__characterCmdSys:getFirstCommand()

    if firstCmd == nil then
        return false
    end

    if firstCmd:getCmdType() ~= FightCommons.CHARATER_CMD_TYPE.RELEASE_ACTIVE then
        return false
    end

    firstCmd:getActiveSkillId()

    --@desc 当前攻击回合中的攻击者
    local character = self:getCharacter(c_id)

    local target = character:getTarget()

    local characterIsDead = false
    if character:isDead() then
        FightUtil:printLog("combfinish继续释放主动技能： 攻击者死亡 false")
        characterIsDead = true
    end

    local targetIsDead = false
    if target:isDead() then
        FightUtil:printLog("combfinish 继续释放主动技能： 受击者死亡 false")
        targetIsDead = true
    end

    local resleaseCId = firstCmd:getOwnerId()

    if resleaseCId == c_id then
        if characterIsDead then
            return false
        else
            if targetIsDead then
                return false
            else
                self.__characterCmdSys:removeCharacterCommand(firstCmd)

                local isMatch, tipText = firstCmd:isMatchCondition()

                if isMatch then
                    firstCmd:execute()
                else
                    if tipText ~= nil and character:isPlayer() then
                        self.__fight:popMessage(tipText)
                    end

                    FightUtil:printLog(character:getAttr("name"), " combfinish 继续释放主动技能： 主动技能释放不满足 false : ", tipText)

                    character:cancelReleaseActiveSkill(firstCmd:getActiveSkillId())
                end

                return isMatch
            end
        end
    else
        if characterIsDead then
            --@desc 删除当前出手记录，重新排序
            self.__preAutoAttacker = nil
            return false
        end

        local isMatch, tipText = firstCmd:isMatchCondition()

        if not isMatch then
            self.__characterCmdSys:removeCharacterCommand(firstCmd)

            local releaser = self:getCharacter(resleaseCId)

            if tipText ~= nil and releaser:isPlayer() then
                self.__fight:popMessage(tipText)
            end

            FightUtil:printLog(character:getAttr("name"), " combfinish 他人打断释放主动技能： 主动技能释放不满足 false : ", tipText)

            releaser:cancelReleaseActiveSkill(firstCmd:getActiveSkillId())

            return false
        end

        character:triggerEvent("ATTACK_JUMPBACK")
        self.__preAutoAttacker = nil
        FightUtil:printLog(character:getAttr("name"), " combfinish 他人打断释放主动技能：true")
        return true
    end
    FightUtil:printLog(character:getAttr("name"), " combfinish 继续释放主动技能 ：其它情况 false")
    return false
end

function CharacterSystem:__checkContinueToAutoSkill(c_id, skillAttack)
    --@desc 当前攻击回合中的攻击者
    local character = self:getCharacter(c_id)

    local target = character:getTarget()

    local characterIsDead = false
    if character:isDead() then
        FightUtil:printLog(character:getAttr("name"), " combfinish 继续释放被动技能： 攻击者死亡 false")
        characterIsDead = true
    end

    local targetIsDead = false
    if target:isDead() then
        FightUtil:printLog(character:getAttr("name"), " combfinish 继续释放被动技能： 目标死亡 false")
        targetIsDead = true
    end

    if characterIsDead then
        self.__preAutoAttacker = nil
        return false
    end

    if targetIsDead then
        character:triggerEvent("ATTACK_JUMPBACK")
        return false
    end

    if not skillAttack:canContinueUseAuto() then
        self.__preAutoAttacker = nil
        character:triggerEvent("ATTACK_JUMPBACK")
        return false
    end

    local isBuffBanAuto = character:getBuffSystem():roleIsBanAutoZhao(character:getId())
    if isBuffBanAuto then
        FightUtil:printLog(character:getAttr("name"), " combfinish 继续释放被动技能： 被禁止释放 false")
        self.__preAutoAttacker = nil
        character:triggerEvent("ATTACK_JUMPBACK")
        return false
    end

    --@desc 被中断的组合招式无法接着出手
    if not skillAttack:zhaoCombIsBeInterrupt() then
        --@desc 攻击者尝试出手下一招被动招式攻击
        local AutoZhaoFactory = require("app.FightSystem.Factory.FightSkillFactory.AutoZhaoFactory")
        local zhaoComb = AutoZhaoFactory:createAttackAutoZhaoComb(character)
        if zhaoComb:getTiliCost() <= character:getAttr("tili") then
            FightUtil:printLog(character:getAttr("name"), " combfinish 继续释放被动技能： true")
            local c_autoSkillAttack = character:getAutoSkillAttack()
            c_autoSkillAttack:setZhaoComb(zhaoComb)
            character:triggerEvent("NEXT_AUTOCOMB_ATTACK")
            return true
        end
        FightUtil:printLog(character:getAttr("name"), " combfinish 继续释放被动技能： 体力不足释放被动技能 false")
        self.__preAutoAttacker = nil
        character:triggerEvent("ATTACK_JUMPBACK")
        return false
    else
        FightUtil:printLog(character:getAttr("name"), " combfinish 继续释放被动技能： 被打断出手 false")
        character:triggerEvent("ATTACK_JUMPBACK")
        self.__preAutoAttacker = nil
        return false
    end

    FightUtil:printLog(character:getAttr("name"), " combfinish 继续释放被动技能： 其它情况 false")
    character:triggerEvent("ATTACK_JUMPBACK")
    return false
end

function CharacterSystem:getActionId()
    return self.__actionCId
end

function CharacterSystem:__checkActiveAutoRelease()
    self.__activeAutoReleaseElapsed = self.__activeAutoReleaseElapsed + 1

    if self.__fight:getFightState() ~= FIGHT_STATE.BATTLE then
        return
    end

    if self:getActionId() ~= nil then
        --@desc 有人处于行动中，无需检查
        return
    end

    if self.__activeAutoReleaseElapsed > 0 and self.__activeAutoReleaseElapsed < 10 then
        return
    end

    for i = 1, #self.__characters do
        --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
        local character = self.__characters[i]

        character:checkActiveReleaseAI()
    end

    self.__activeAutoReleaseElapsed = 0
end

--@desc: 遍历检查是否有主动技能释放申请
--@author:Seven
--@time:2021-07-15 14:18:52
function CharacterSystem:__checkActiveRelease()
    if self.__fight:getFightState() ~= FIGHT_STATE.BATTLE then
        return
    end

    if self:getActionId() ~= nil then
        --@desc 有人处于行动中，无需检查
        return
    end

    local firstCmd = self.__characterCmdSys:getFirstCommand()

    if firstCmd ~= nil and firstCmd:getCmdType() == FightCommons.CHARATER_CMD_TYPE.RELEASE_ACTIVE then
        self.__characterCmdSys:removeCharacterCommand(firstCmd)
        
        local isMatch, tipText = firstCmd:isMatchCondition()

        if isMatch then
            firstCmd:execute()
        else
            local owner = self:getCharacter(firstCmd:getOwnerId())
            if tipText ~= nil and owner:isPlayer() then
                self.__fight:popMessage(tipText)
            end
            owner:cancelReleaseActiveSkill(firstCmd:getActiveSkillId())
        end

    end
end

--@region 被动技能

function CharacterSystem:__selectAutoAttackRandom()
    local characters = self:getCharacters()

    -- --@desc 可出手队列
    -- local can_attack_list = {}
    if not MapIsEmpty(characters) then
        for i = 1, #characters do
            --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
            local character = characters[i]

            if character:canAutoAttack() then
                local attack_info = self:__getCanAttackInfo(character:getId())

                --@desc 是否处于排队中
                if attack_info == nil then
                    self:__addCanAutoAttackInfo({id = character:getId(), logicIndex = BattleGlobalData:getInstance():get("m_logic_index")})
                end
            else
                local attack_info = self:__getCanAttackInfo(character:getId())
                if attack_info ~= nil then
                    self:__removeCanAutoAttackInfo(character:getId())
                end
            end
        end
    end

    if MapIsEmpty(self.__can_autoattack_list) then
        return
    end

    --@desc 选择出手体力达到出手要求时间最早者出手。
    local attack_list = {}
    FightUtil:printLog("** LOGIC UPDATE  CharacterSystem ** 可出手列表：")
    for i = 1, #self.__can_autoattack_list do
        local attack_info = self.__can_autoattack_list[i]
        if MapIsEmpty(attack_list) then
            table.insert(attack_list, attack_info)
        else
            local first_attack_info = attack_list[1]

            if attack_info.logicIndex < first_attack_info.logicIndex then
                attack_list = {}
                table.insert(attack_list, attack_info)
            elseif attack_info.logicIndex == first_attack_info.logicIndex then
                table.insert(attack_list, attack_info)
            elseif attack_info.logicIndex > first_attack_info.logicIndex then
            end
        end

        FightUtil:printLog("** LOGIC UPDATE  CharacterSystem ** └ index : ", i, "，角色id : ", attack_info.id, "，体力满帧数：", attack_info.logicIndex)
    end

    if MapIsEmpty(attack_list) then
        assert(false, "出手列表为空，随机出错！！")
    end

    local randomIndex = FightUtil:random(1, #attack_list)

    local attacker_id = attack_list[randomIndex].id

    local attack_character = self:getCharacter(attacker_id)

    FightUtil:printLog("** LOGIC UPDATE  CharacterSystem ** 选择角色：", attack_character:getAttr("name"), "（id:", attack_character:getId(), "）出手被动攻击")

    self:__startAutoAttack(attack_character)

    self:__removeCanAutoAttackInfo(attack_character:getId())
end

function CharacterSystem:__checkAutoRelease()
    if self.__fight:getFightState() ~= FIGHT_STATE.BATTLE then
        return
    end

    if self:getActionId() then
        return
    end

    --@desc 攻击者只要还能攻击即继续
    if self.__preAutoAttacker and self.__preAutoAttacker:canAutoAttack() then
        FightUtil:printLog('** LOGIC UPDATE  CharacterSystem ** "', self.__preAutoAttacker:getAttr("name"), '"继续出手被动攻击')
        self:__startAutoAttack(self.__preAutoAttacker)
        return
    else
        self.__preAutoAttacker = nil
    end

    self:__selectAutoAttackRandom()
end

function CharacterSystem:__removeCanAutoAttackInfo(c_id)
    if #self.__can_autoattack_list == 0 then
        return nil
    end

    for i = #self.__can_autoattack_list, 1, -1 do
        local info = self.__can_autoattack_list[i]

        if c_id == info.id then
            table.remove(self.__can_autoattack_list, i)
            return
        end
    end
end

function CharacterSystem:__addCanAutoAttackInfo(info)
    table.insert(self.__can_autoattack_list, info)
end

function CharacterSystem:__getCanAttackInfo(c_id)
    if #self.__can_autoattack_list == 0 then
        return nil
    end

    for i = 1, #self.__can_autoattack_list do
        local info = self.__can_autoattack_list[i]

        if c_id == info.id then
            return info
        end
    end
end

--@desc: 出手攻击
--@author:Seven
--@time:2021-06-02 19:05:15
--@attack_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function CharacterSystem:__startAutoAttack(attack_character)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    local target = attack_character:getTarget()

    if target == nil or target:isDead() then
        target = attack_character:selectTarget()
        attack_character:setTarget(target)
    end

    attack_character:triggerEvent("START_AUTO_ATTACK")
    self.__preAutoAttacker = attack_character
end

--@endregion

function CharacterSystem:__applyCharacterCmd(cmd)
    self.__characterCmdSys:addCharacterCommand(cmd)
end

--@desc: 移除所有角色已有的命令
--@author:Seven
--@time:2022-01-13 15:37:45
--@c_id: 角色ID
function CharacterSystem:removeCharacterAllCommand(c_id)
    local count = self.__characterCmdSys:getCharacterCmdCount(c_id)

    if count > 0 then
        self.__characterCmdSys:removeCharacterAllCommand(c_id)

        self:getCharacter(c_id):removeAllPrepOpertion()
    end
end

function CharacterSystem:removeCharaterCommand(cmd)
    self.__characterCmdSys:removeCharacterCommand(cmd)
end

--@region 逃跑
function CharacterSystem:__checkCharacterRunaway()
    if self.__fight:getFightState() ~= FIGHT_STATE.BATTLE then
        return
    end

    if self:getActionId() ~= nil then
        return
    end

    local firstCmd = self.__characterCmdSys:getFirstCommand()

    if firstCmd ~= nil and firstCmd:getCmdType() == FightCommons.CHARATER_CMD_TYPE.RUNAWAY then
        self.__characterCmdSys:removeCharacterCommand(firstCmd)

        local isMatch, tip = firstCmd:isMatchCondition()

        if isMatch and not self.__fight:isFinish() then
            firstCmd:execute()
        else
            local owner = self:getCharacter(firstCmd:getOwnerId())

            if owner:isPlayer() and tip ~= nil then
                self.__fight:popMessage(tip)
            end

            owner:cancelRunAway()
        end
    end
end

--@desc: 通知角色准备逃跑
--@author:Seven
--@time:2022-01-13 16:18:30
function CharacterSystem:characterPrepRunaway(c_id)
    local cmd_count = self.__characterCmdSys:getCharacterCmdCountByCmdType(c_id, FightCommons.CHARATER_CMD_TYPE.RUNAWAY)

    if cmd_count > 0 then
        FightUtil:printLog("CharacterSystem:characterPrepRunaway 已有逃跑命令，无需申请。")
        return
    end

    local character = self:getCharacter(c_id)

    character:applyRunaway()
end

--@desc: 申请逃跑
--@author:Seven
--@time:2022-01-13 15:29:27
--@c_id: 角色ID
function CharacterSystem:applyRunaway(c_id)
    --@RefType [src.app.FightSystem.FightRole.CharacterCommands.CharacterRunawayCommand#CharacterRunawayCommand]
    local cmd = require("app.FightSystem.FightRole.CharacterCommands.CharacterRunawayCommand"):create()

    cmd:setCharacterSystem(self)

    cmd:setFrameIndex(BattleGlobalData:getInstance():get("m_logic_index"))

    cmd:setOwnerId(c_id)

    self:__applyCharacterCmd(cmd)
end
--@endregion

--@region 气血恢复相关
function CharacterSystem:characterPrepRecoverQi(c_id)
    local cmd_count = self.__characterCmdSys:getCharacterCmdCountByCmdType(c_id, FightCommons.CHARATER_CMD_TYPE.QI_RECOEVE)

    if cmd_count > 0 then
        FightUtil:printLog("CharacterSystem:characterPrepChangeWeapon 已有气血恢复命令，无需申请。")
        return
    end

    local runaway_cmd_count = self.__characterCmdSys:getCharacterCmdCountByCmdType(c_id, FightCommons.CHARATER_CMD_TYPE.RUNAWAY)
    if runaway_cmd_count > 0 then
        self.__fight:popMessage(TextResManager:getText("1012"))
        return
    end

    local character = self:getCharacter(c_id)

    local canAddCmd, tips = self.__characterCmdSys:checkCanAddList(c_id)
    if not canAddCmd then
        if character:isPlayer() and tips ~= nil then
            self.__fight:popMessage(tips)
        end
        return
    end

    character:applyQiRecover()
end

function CharacterSystem:applyRecoverQi(c_id)
    --@RefType [src.app.FightSystem.FightRole.CharacterCommands.CharacterQiRecoverCommand#CharacterQiRecoverCommand]
    local qi_cmd = require("app.FightSystem.FightRole.CharacterCommands.CharacterQiRecoverCommand"):create()

    qi_cmd:setCharacterSystem(self)

    qi_cmd:setFrameIndex(BattleGlobalData:getInstance():get("m_logic_index"))

    qi_cmd:setOwnerId(c_id)

    self:__applyCharacterCmd(qi_cmd)
end

function CharacterSystem:__checkCharacterRecoverQi()
    if self.__fight:getFightState() ~= FIGHT_STATE.BATTLE then
        return
    end

    if self:getActionId() ~= nil then
        return
    end

    local firstCmd = self.__characterCmdSys:getFirstCommand()

    if firstCmd ~= nil and firstCmd:getCmdType() == FightCommons.CHARATER_CMD_TYPE.QI_RECOEVE then
        
        self.__characterCmdSys:removeCharacterCommand(firstCmd)
        
        local isMatch, tip = firstCmd:isMatchCondition()
        if isMatch then
            firstCmd:execute()
        else
            local owner = self:getCharacter(firstCmd:getOwnerId())

            if owner:isPlayer() and tip ~= nil then
                self.__fight:popMessage(tip)
            end

            owner:cancelRecoverQi()
        end

    end
end

--@endregion

--@region 易武相关
function CharacterSystem:characterPrepChangeWeapon(c_id)
    local cmd_count = self.__characterCmdSys:getCharacterCmdCountByCmdType(c_id, FightCommons.CHARATER_CMD_TYPE.CHANGE_WEAPON)

    if cmd_count > 0 then
        FightUtil:printLog("CharacterSystem:characterPrepChangeWeapon 已有易武命令，无需申请。")
        return
    end

    local runaway_cmd_count = self.__characterCmdSys:getCharacterCmdCountByCmdType(c_id, FightCommons.CHARATER_CMD_TYPE.RUNAWAY)
    if runaway_cmd_count > 0 then
        self.__fight:popMessage(TextResManager:getText("1012"))
        return
    end

    local character = self:getCharacter(c_id)
    local canAddCmd, tips = self.__characterCmdSys:canAddCmd(c_id)
    if not canAddCmd then
        if character:isPlayer() and tips ~= nil then
            self.__fight:popMessage(tips)
        end
        FightUtil:printLog(string.format("characterPrepChangeWeapon 【%s】申请准备【易武】 队列已满，无法加入", character:getAttr("name")))
        return
    end

    character:applyChangeWeapon()
end

function CharacterSystem:applyChangeWeapon(c_id)
    --@RefType [src.app.FightSystem.FightRole.CharacterCommands.ChangeWeaponCommand#ChangeWeaponCommand]
    local cmd = require("app.FightSystem.FightRole.CharacterCommands.ChangeWeaponCommand"):create()

    cmd:setCharacterSystem(self)

    cmd:setFrameIndex(BattleGlobalData:getInstance():get("m_logic_index"))

    cmd:setOwnerId(c_id)

    self:__applyCharacterCmd(cmd)
end

function CharacterSystem:__checkCharacterChangeWeapon()
    if self.__fight:getFightState() ~= FIGHT_STATE.BATTLE then
        return
    end

    if self:getActionId() ~= nil then
        return
    end

    local firstCmd = self.__characterCmdSys:getFirstCommand()

    if firstCmd ~= nil and firstCmd:getCmdType() == FightCommons.CHARATER_CMD_TYPE.CHANGE_WEAPON then
        local isMatch, tip = firstCmd:isMatchCondition()

        if isMatch then
            firstCmd:execute()
        else
            local owner = self:getCharacter(firstCmd:getOwnerId())

            if owner:isPlayer() and tip ~= nil then
                self.__fight:popMessage(tip)
            end

            owner:cancelChangeStandbyWeapon()
        end
    -- self.__characterCmdSys:removeCharacterCommand(firstCmd)
    end
end
--@endregion

--@desc: 申请释放主动技能
--@author:Seven
--@time:2021-06-28 20:03:25
function CharacterSystem:characterPrepReleaseActiveSkill(c_id, act_id)
    local character = self:getCharacter(c_id)

    FightUtil:printLog(string.format("CharacterSystem:characterPrepReleaseActiveSkill %s 申请释放主动技能 【%s】", character:getAttr("name"), act_id))

    local list = self.__characterCmdSys:getCharacterCmdsByType(c_id, FightCommons.CHARATER_CMD_TYPE.RELEASE_ACTIVE)

    if table.getn(list) > 0 then
        for i = 1, table.getn(list) do
            --@RefType [src.app.FightSystem.FightRole.CharacterCommands.CharacterReleaseActiveSkillCommand#CharacterReleaseActiveSkillCommand]
            local cmd = list[i]
            local isPrepActId = cmd:getActiveSkillId()
            if isPrepActId == act_id then
                --@desc 重复申请
                FightUtil:printLog(string.format("CharacterSystem:characterPrepReleaseActiveSkill %s 队列中已有申请释放主动技能 【%s】", character:getAttr("name"), act_id))
                return
            end
        end
    end

    local canAddCmd, tips = self.__characterCmdSys:checkCanAddList(c_id)
    if not canAddCmd then
        if character:isPlayer() and tips ~= nil then
            self.__fight:popMessage(tips)
        end
        FightUtil:printLog(string.format("characterPrepReleaseActiveSkill 【%s】申请释放主动技能：%s 队列已满，无法加入", character:getAttr("name"), act_id))
        return
    end

    local activeSkill = character:getActiveSkill(act_id)

    if activeSkill:getCD() > 0 then
        if character:isPlayer() then
            --@desc CD中
            self.__fight:popMessage(TextResManager:getText("1010"))
        end
        FightUtil:printLog(string.format("characterPrepReleaseActiveSkill 【%s】申请释放主动技能：%s 技能正在CD，无法加入", character:getAttr("name"), act_id))
        return
    end

    local underBan, banTips = activeSkill:underBan()
    if underBan then
        if character:isPlayer() and banTips ~= nil then
            self.__fight:popMessage(banTips)
        end
        FightUtil:printLog(string.format("characterPrepReleaseActiveSkill 【%s】申请释放主动技能：%s 技能被禁用，无法加入", character:getAttr("name"), act_id))
        return
    end

    local isbool, failureText = activeSkill:releaseAreMet()
    if not isbool then
        if character:isPlayer() then
            self.__fight:popMessage(failureText)
        end
        FightUtil:printLog(string.format("characterPrepReleaseActiveSkill 【%s】申请释放主动技能：%s 技能无法满足释放条件：消耗不足，无法加入", character:getAttr("name"), act_id))
        return
    end

    character:prepReleaseActiveSkill(act_id)
end

function CharacterSystem:applyReleaseActiveSkill(c_id, act_id)
    --@RefType [src.app.FightSystem.FightRole.CharacterCommands.CharacterReleaseActiveSkillCommand#CharacterReleaseActiveSkillCommand]
    local cmd = require("app.FightSystem.FightRole.CharacterCommands.CharacterReleaseActiveSkillCommand"):create()

    cmd:setActiveSkillId(act_id)

    cmd:setCharacterSystem(self)

    cmd:setFrameIndex(BattleGlobalData:getInstance():get("m_logic_index"))

    cmd:setOwnerId(c_id)

    self:__applyCharacterCmd(cmd)
end

return class("CharacterSystem", {AFightSystem}, CharacterSystem)
0000000
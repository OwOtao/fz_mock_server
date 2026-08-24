--[[
    author:Seven
    time:2023-10-20 16:58:36
    desc:
]]
local ViewCharacter = require("app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter")

local FightCommons = require("app.FightSystem.FightCommons")

local ViewCharacterFactory = {}

--@desc: 创建视图角色
--@author:Seven
--@time:2023-10-20 17:00:26
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@return [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
function ViewCharacterFactory:createViewCharacter(character, fight)
    local id = character:getId()

    local name = character:getAttr("name")

    local teamId = character:getTeamId()

    local viewCharacter = ViewCharacter:create(id, name, teamId)

    viewCharacter:setOriginPosIndex(character:getPosIndex())

    self:__initViewAttrs(viewCharacter, character)

    self:__initActiveSkill(viewCharacter, character)

    self:__initQiRecover(viewCharacter, character)

    self:__initChangeWeapon(viewCharacter, character)

    self:__initRunaway(viewCharacter, character)

    self:__initAnim(viewCharacter, character)

    return viewCharacter
end

--@desc: 初始化视图角色属性
--@author:Seven
--@time:2023-10-20 17:04:31
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ViewCharacterFactory:__initViewAttrs(viewCharacter, character)
    local attrMap = viewCharacter:getAttrMap()

    for k, v in pairs(attrMap) do
        viewCharacter:setAttr(k, character:getAttr(k))
    end
end

--@desc: 初始化视图角色主动技能属性
--@author:Seven
--@time:2023-10-26 15:05:36
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ViewCharacterFactory:__initActiveSkill(viewCharacter, character)
    local ViewActiveSkillFactory = require("app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewActiveSkillFactory")

    local activeCount = FightCommons.PREP_ACT_MAX_COUNT

    for i = 1, activeCount do
        local activeskill = character:getPrepActiveSkillByPosIndex(i)

        if activeskill then
            local viewActiveSkill = ViewActiveSkillFactory:create(activeskill, i)
            viewCharacter:addViewActiveSkill(viewActiveSkill:getViewActivePosIndex(), viewActiveSkill)
        end
    end
end

--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ViewCharacterFactory:__initQiRecover(viewCharacter, character)
    local ViewQiRecover = require("app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewQiRecover")

    local recoverQi = character:getRecoverQi()

    local isOpen = character:isQiRecoverOpen()

    local viewModel = ViewQiRecover:create(recoverQi:getId(), recoverQi:getName(), recoverQi:getCoolDownTime(), 7, isOpen)

    viewCharacter:setQiRecover(viewModel)
end

--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ViewCharacterFactory:__initRunaway(viewCharacter, character)
    local ViewRunaway = require("app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewRunaway")

    local runaway = character:getRunaway()

    local isOpen = character:isRunawayOpen()

    local viewModel = ViewRunaway:create(runaway:getId(), runaway:getName(), runaway:getCoolDownTime(), 9, isOpen)

    viewCharacter:setRunaway(viewModel)
end

--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ViewCharacterFactory:__initChangeWeapon(viewCharacter, character)
    local ViewChangeWeapon = require("app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewChangeWeapon")

    local changeWeaponView = ViewChangeWeapon:create("changeStandByWeapon", "易武", 8, character:isChangeWeaponFuncOpen())

    viewCharacter:setChangeWeapon(changeWeaponView)
end

--@desc: 初始化视图角色小黄人动画属性
--@author:Seven
--@time:2023-10-23 11:40:12
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ViewCharacterFactory:__initAnim(viewCharacter, character)
    viewCharacter:setIdleAnim(character:getIdleAnimId())
    viewCharacter:setWeaponSkin(character:getWeapon():getWeaponSkin())
    viewCharacter:setJumpForwardAnim(character:getJumpForwardAnimId())
    viewCharacter:setJumpBackAnim(character:getJumpBackAnimId())
    viewCharacter:setHurtAnimAndSoundMap(character:getHurtAnimAndSoundMap())
    viewCharacter:setDeadAnimAndSound(character:getDeadAnimAndSoundMap())
    viewCharacter:setParryHurtAnimAndSound(character:getParryAnimAndSoundMap())
    viewCharacter:setDodgeAnimAndSound(character:getDodgeAnimAndSoundMap())
end

return ViewCharacterFactory
0
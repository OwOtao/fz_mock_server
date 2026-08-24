--[[
    author:Seven
    time:2022-09-14 16:55:12
    desc: 角色系统配置管理文件
]]
local newClass = require("third.class.NewClass")

local CharacterConfig = {
    SYSTEM_NAME = {
        ATTR_SYSTEM = "attrSystem",
        SKILL_SYSTEM = "skillSystem",
        EQUIP_SYSTEM = "equipSystem",
        FISTFOOT_SYSTEM = "fistFootSystem",
        BUFF_SYSTEM = "characterBuffSystem",
        TILI_UPDATE_FUNC = "tiliUpdateFunc",
        SWITCH_WEAPON_FUNC = "switchWeaponFunc",
        RUNAWAY_FUNC = "runawayFunc",
        SHIELD_SYSTEM = "shieldSystem",
        IDLE_STATE_ANIM_SYSTEM = "idleStateAnimSystem",
        HURT_STATE_ANIM_SYSTEM = "hurtStateAnimSystem",
        BOTTOM_OF_FOOT_ANIM_SYSTEM = "bottomOfFootAnimSystem",
        TOP_OF_HEAD_TEXT_SYSTEM = "topOfHeadTextSystem",
        ICON_SYSTEM = "iconSystem",
        RECOVER_QI_FUNC = "recoverQiFunc",
        CHANGE_WEAPON_FUNC = "changeWeaponFunc",
        CHARACTER_BATTLE_STATE_SYSTEM = "characterBattleStateSystem",
        ACTIVE_AUTO_RELEASE_AI_SYSTEM = "activeAutoReleaseAISystem",
        BAN_OPERATION_SYSTEM = "banOperationSystem",
        SKILL_RESISTANCE_SYSTEM = "skillResistanceSystem"
    }
}

function CharacterConfig:create(config)
    local p = CharacterConfig.new()

    p:__init(config)

    return p
end

function CharacterConfig:__init(config)
    self.__baseConfig = require("app.FightSystem.FightRole.CharacterConfigs.DefaultCharacterConfig")
    if config ~= nil then
        self.__config = config
    end

    --@desc 元素格式：{name = "xx",path=""}
    self.__systems = {}

    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.EQUIP_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.BUFF_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.ATTR_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.SKILL_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.FISTFOOT_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.TILI_UPDATE_FUNC)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.RECOVER_QI_FUNC)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.CHANGE_WEAPON_FUNC)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.SWITCH_WEAPON_FUNC)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.RUNAWAY_FUNC)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.SHIELD_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.IDLE_STATE_ANIM_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.HURT_STATE_ANIM_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.BOTTOM_OF_FOOT_ANIM_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.TOP_OF_HEAD_TEXT_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.ICON_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.CHARACTER_BATTLE_STATE_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.BAN_OPERATION_SYSTEM)
    self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.SKILL_RESISTANCE_SYSTEM)

    if self:__hasSystem(CharacterConfig.SYSTEM_NAME.ACTIVE_AUTO_RELEASE_AI_SYSTEM) then
        self:__insertSystemInfo(CharacterConfig.SYSTEM_NAME.ACTIVE_AUTO_RELEASE_AI_SYSTEM)
    end
end

function CharacterConfig:__insertSystemInfo(name)
    local info = self:__getSystemData(name)

    table.insert(self.__systems, {name = name, path = info.path, args = info.args})
end

function CharacterConfig:__getSystemData(name)
    local system_data

    if self.__config and self.__config.systemMap then
        system_data = self.__config.systemMap[name]
    end

    if system_data == nil then
        system_data = self.__baseConfig.systemMap[name]
    end

    if system_data == nil then
        assert(false, " CharacterConfig:__getSystemData 未知系统名：" .. tostring(name))
    end

    local path
    local args = {}
    if type(system_data) == "string" then
        path = system_data
    elseif type(system_data) == "table" then
        path = system_data.path
        args = system_data.args
    else
        assert(false, " CharacterConfig:__getSystemData 配置格式填写错误 , 系统名：" .. tostring(name))
    end

    return {
        path = path,
        args = args
    }
end

function CharacterConfig:__hasSystem(name)
    local system_data
    if self.__config and self.__config.systemMap then
        system_data = self.__config.systemMap[name]
    end

    if system_data == nil then
        system_data = self.__baseConfig.systemMap[name]
    end

    return system_data ~= nil
end

function CharacterConfig:getSystemInfos()
    return self.__systems
end

return newClass("CharacterConfig", {}, CharacterConfig)
0000000000000
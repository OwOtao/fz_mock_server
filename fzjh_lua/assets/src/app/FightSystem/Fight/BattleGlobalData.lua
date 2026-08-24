--[[
    白板
    战斗共用数据
]]
local class = require("third.class.NewClass")

local __instance

local BattleGlobalData = {
    __dicts = {
        m_logic_index = 0, --@desc 逻辑帧数
        m_battle_recover = false, --@desc 战场控制全部角色能否恢复
        m_auto_attacking = false, --@desc 战场是否有角色正在进行普通攻击
        m_active_attacking = false
    }
}

local __instance = nil

--@desc: 获取单例
--@author:Seven
--@time:2021-05-13 17:06:33
--@return [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
function BattleGlobalData:getInstance()
    if __instance == nil then
        __instance = BattleGlobalData.new()
    end

    return __instance
end

function BattleGlobalData:put(key, value)
    if self.__dicts[key] == nil then
        assert(false, "变量【" .. key .. "】未定义")
    end
    self.__dicts[key] = value
end

function BattleGlobalData:get(key)
    if self.__dicts[key] == nil then
        assert(false, "变量【" .. key .. "】未定义")
    end
    return self.__dicts[key]
end

function BattleGlobalData:destoryInstance()
    __instance = nil
end

return class("BattleGlobalData", {}, BattleGlobalData)
000000000000
--[[
    author:Seven
    time:2023-02-16 14:54:23
    desc: 气血恢复功能类
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local RecoverQi = {}

function RecoverQi:create(character)
    return RecoverQi.new():__init(character)
end

function RecoverQi:__init(character)
    self.__cd = 0

    self:setCharacter(character)

    return self
end

function RecoverQi:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

function RecoverQi:getId()
    return "qiHealthy"
end

function RecoverQi:getName()
    return BattleConstConf:get("battleAction_healthy_name")
end

function RecoverQi:getAttrCost()
    return {
        {
            attrName = "neili",
            value = math.ceil(20 + self.__character:getAttr("neiliMax") / 50)
        }
    }
end

function RecoverQi:getCoolDownTime()
    return BattleConstConf:get("battleAction_healthy_cd")
end

function RecoverQi:setCD(cd)
    if cd == nil then
        assert(false, self:getName() .. " 设置技能CD参数错误" .. cd)
    end

    if cd < 0 then
        assert(false, self:getName() .. "设置技能CD不可为负数")
    end

    self.__cd = cd
end

function RecoverQi:getCD()
    return self.__cd
end

--@desc: 是否可以是释放气血恢复
--@author:Seven
--@time:2023-02-16 16:55:33
--@return: true | false , false mseesge
function RecoverQi:releaseAreMet()
    local isBan, banMsg = self.__character:isBanOperation(FightCommons.BAN_OPERATION_TYPE.BAN_RECOVER_QI)
    if isBan then
        return false, banMsg
    end

    --@desc 是否cd中
    if self:getCD() > 0 then
        return false, ""
    end

    --@desc 是否满足消耗
    local costList = self:getAttrCost()
    local isCostMeet = true
    for i, v in ipairs(costList) do
        local attrName = v.attrName
        local value = v.value

        local currValue = self.__character:getAttr(attrName)
        if currValue < value then
            isCostMeet = false
            break
        end
    end
    if isCostMeet == false then
        return false, ""
    end

    if self.__character:getAttr("qi") == self.__character:getAttr("qiMax") then
        return false, TextResManager:getText("1014")
    end

    return true
end

return newClass("RecoverQi", {}, RecoverQi)
000000000000000
--[[
    战斗胜利 x 次后 触发效果。
    触发后清零。
]]
local BaseBuff = require("app.models.Buff.BaseBuff")
--@SuperType [BaseBuff]
local FightWinCountBuff = class("FightWinCountBuff", BaseBuff)

function FightWinCountBuff:create(luaData, manager)
    local p = FightWinCountBuff:new()
    p:init(luaData, manager)
    return p
end

function FightWinCountBuff:ctor()
    self.name = "FightWinCountBuff"

    self.fightWinCount = 0
end

function FightWinCountBuff:onInit()
    self.conditions = {}

    if self.luaData.scriptArgs == nil or self.luaData.scriptArgs == "" then
        assert(false, "buff id : " .. self:getId() .. "的脚本参数填写错误！！！")
    end

    --@desc 脚本参数
    self.scriptArg = self.luaData.scriptArgs
end

--@desc buff添加时
function FightWinCountBuff:onAdd()
end

function FightWinCountBuff:onCheck(context)
    if context.fightResult == 1 then
        self.fightWinCount = self.fightWinCount + 1

        if self.fightWinCount >= self.scriptArg then
            return true
        end
    end

    return false
end

function FightWinCountBuff:onTrigger()
    self.fightWinCount = 0
end

--@desc buff移除时
function FightWinCountBuff:onRemove()
end

function FightWinCountBuff:onSerialization(serialObject)
    serialObject.fightWinCount = self.fightWinCount
end

function FightWinCountBuff:onPrintInfo()
    print("     【战斗胜利场次】：" .. self.fightWinCount)
end

return FightWinCountBuff
0000000000000
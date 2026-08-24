--[[
    6 - 人物当前情绪状态
    arg1 : 情绪代码（具体查看情绪系统表）
]]
local BaseBuffCondition = require("app.models.Buff.Conditions.BaseBuffCondition")
--@SuperType [BaseBuffCondition]
local RoleEmotionCondition = class("RoleEmotionCondition", BaseBuffCondition)

function RoleEmotionCondition:create()
    local p = RoleEmotionCondition:new()
    p:init()
    return p
end

function RoleEmotionCondition:init()
    self.type = 6
end

function RoleEmotionCondition:onCheck()
    local currEmotion
    if self.context.currEmotionType == nil then
        if self.context.role.emotionMgr ~= nil then
            currEmotion = self.context.role.emotionMgr:getCurrEmotion():getType()
        end
    else
        currEmotion = self.context.currEmotionType
    end

    if currEmotion == nil then
        assert(false, "RoleEmotionCondition 上下文环境错误。")
    end

    if tonumber(currEmotion) ~= nil and tonumber(self.arg1) ~= nil and tonumber(currEmotion) == tonumber(self.arg1) then
        return true
    else
        return false
    end
end

return RoleEmotionCondition
0
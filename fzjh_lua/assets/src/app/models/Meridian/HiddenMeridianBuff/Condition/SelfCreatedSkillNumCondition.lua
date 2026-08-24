local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local SelfCreatedSkillNumCondition = {}

function SelfCreatedSkillNumCondition:create(...)
    local p = SelfCreatedSkillNumCondition.new()
    p:init(...)
    return p
end

function SelfCreatedSkillNumCondition:check()
    local sys = self:getRole():getSelfCreatedSkillSystem()

    local bookNum = 0
    
    if tonumber(self:getAttrId()) == 0 then
        bookNum = sys:getBookCount()
    else
        bookNum = sys:getBookCountByType(tonumber(self:getAttrId()))
    end
    
    return self:compare(bookNum)
end

return newClass("SelfCreatedSkillNumCondition", {BaseCondition}, SelfCreatedSkillNumCondition)
00000000000000
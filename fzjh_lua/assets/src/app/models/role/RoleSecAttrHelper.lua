local RoleSecAttrHelper = {}

--后天属性与相关武学等级关联
--规则：attrValue = math.floor(skillLv/10)
local SecAttrToSkillMap = {
    ["secCon"] = "jibenneigong",
    ["secDex"] = "jibenqinggong",
    ["secInt"] = "dushushizi",
    ["secStr"] = "jibenquanjiao",
}

function RoleSecAttrHelper:updateSecAttr(role, attr)
    if SecAttrToSkillMap[attr] then
        role:setAttr(attr, Helper:mathFloor(role:getSkillLv(SecAttrToSkillMap[attr])/10))
    end
end

function RoleSecAttrHelper:updateAllSecAttr(role)
    for attrId, skillId in pairs(SecAttrToSkillMap) do
        self:updateSecAttr(role, attrId)
    end
end

function RoleSecAttrHelper:updateSecAttrBySkillId(role, skillId)
    local attrId = self:__getSecAttrIdBySkillId(skillId)

    if attrId then
        self:updateSecAttr(role, attrId)
    end
end

function RoleSecAttrHelper:__getSecAttrIdBySkillId(skillId)
    for attrId, _skillId in pairs(SecAttrToSkillMap) do
        if skillId == _skillId then
            return attrId
        end
    end
end

return RoleSecAttrHelper0000000000
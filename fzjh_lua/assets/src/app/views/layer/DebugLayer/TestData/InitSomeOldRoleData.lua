--[[
    author:Seven
    time:2025-11-03 15:55:21
    desc: 用于生成一些旧存档的测试数据
]]
local InitSomeOldRoleData = {}

function InitSomeOldRoleData.initRoleData_Bug1007885(role, skillId)
    role:setFlag("当前武功", tostring(skillId))
    role:setFlag("练功时间", GetTime() - 3600)

    role:setInheritFlag("stopOldLianGong", 0)

    -- 使用旧状态数据格式
    role:setInheritFlag("roleStateChange", 0)
    role:setAttr(
        "roleCurrState",
        {
            tostring(ROLE_CURR_STATE_LIANGONG)
        }
    )

    local selfCreatingSkill = role:getSelfCreatedSkillSystem():getCreatedSkillBySkillDataId(skillId)

    if selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_QUANJIAO then
        role.skillPrepare["quanjiao1"] = skillId
    elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_JIAN then
        role.skillPrepare["jianfa"] = skillId
    elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_DAO then
        role.skillPrepare["daofa"] = skillId
    elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_GUN then
        role.skillPrepare["gunfa"] = skillId
    elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_ANQI then
        role.skillPrepare["anqi"] = skillId
    elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_BIANFA then
        role.skillPrepare["bianfa"] = skillId
    elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_SHUANGCHI then
        role.skillPrepare["shuangchi"] = skillId
    elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_QIN then
        role.skillPrepare["qinfa"] = skillId
    end

    User:save()

    PopText("已生成旧存档数据，请立即重启游戏！")
end

return InitSomeOldRoleData
0000
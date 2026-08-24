--[[
    author:Seven
    time:2024-01-05 19:46:55
    desc: 先天分配方案相关常量
]]
local NaturalAttrAdjustmentConst = {}

--- 方案类型
NaturalAttrAdjustmentConst.PLAN_TYPE = {
    BASE_PLAN = "base", -- 基础方案
    KONWLEDGE_SKILL_PLAN = "konwledgeSkill" -- 知识武学方案
}

NaturalAttrAdjustmentConst.ATTR_TYPE = {
    STR = "str",
    DEX = "dex",
    INT = "int",
    CON = "con"
}

NaturalAttrAdjustmentConst.PLAN_TYPE_NAME = {
    [NaturalAttrAdjustmentConst.PLAN_TYPE.BASE_PLAN] = "先天之资",
    [NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN] = "易天之赋"
}

return NaturalAttrAdjustmentConst
000000000000000
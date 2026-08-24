--[[
    author:Seven
    time:2022-09-16 15:56:09
    desc: NPC相关配置
]]
return inherit(
    {
        systemMap = {
            --@desc 角色属性系统
            attrSystem = "app.FightSystem.FightRole.CharacterAttr.NpcAttr",
            --@desc 武学技能系统
            skillSystem = "app.FightSystem.FightRole.CharacterSkillSystem.NpcSkillSystem",
            --@desc NPC主动技能自动释放系统
            activeAutoReleaseAISystem = "app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI"
        }
    },
    require("app.FightSystem.FightRole.CharacterConfigs.DefaultCharacterConfig")
)
00000000000000
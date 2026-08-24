local SelfCreatedSkillSystem = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillSystem")

local BuffManager = require("app.models.Buff.BuffManager")

local EmotionMgr = require("app.models.DreamWorldModel.EmotionStatus.EmotionMgr")

local Role = require("app.models.role.Role")

local RoleFactory = {}

--@desc 创建自创武学前置任务角色
function RoleFactory:createSelfCreatedSkillTaskRole()
    local SelfCreatedSkillTaskRole = require("src.app.models.role.SelfCreatedSkillTaskRole")
    return SelfCreatedSkillTaskRole:create(User:getRole():getTrimData())
end

--@desc 创建梦境角色
function RoleFactory:createDreamRole()
    local DreamRole = require("app.models.role.DreamRole")
    return DreamRole:create()
end

--@desc 创建南柯梦境角色
function RoleFactory:createFondDreamRole()
    local FondDreamRole = require("app.models.role.FondDreamRole")
    return FondDreamRole:create()
end

return RoleFactory
000
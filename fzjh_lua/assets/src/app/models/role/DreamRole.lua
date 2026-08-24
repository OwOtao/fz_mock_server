local class = require("third.class.NewClass")
local Role = require("app.models.role.Role")
local DreamRole = {}

function DreamRole:create()
    local p = DreamRole.new()
    p:init()
    return p
end

function DreamRole:init()
    self.isDreamRole = true 
    self.id = "dreamPlayer"
	self.onlyId = Helper:getOnlyId()

	table.mergeToLeft(self, require("app.models.DreamWorldModel.DreamRole.DrRole_Item")) -- 载入物品相关模块
	table.mergeToLeft(self, require("app.models.DreamWorldModel.DreamRole.DrRole_Skill")) -- 载入技能相关模块
	
	-- 给梦境角色添加模块
	local ModuleManager = require("third.module.ModuleManager")
	ModuleManager:addModule(self, "app.models.role.module.RoleModule")
	:addSubModuleWithPath("app.models.role.module.dream.RoleDreamPlayerModule")

	self:initIgnoreCloneTb()
end

function DreamRole:getZhaoLvLimit(zhaoId)
	return 9
end

return class("DreamRole", { Role }, DreamRole,true)0
local class = require("third.class.NewClass")
local Role = require("app.models.role.Role")
local FondDreamRole = {}

function FondDreamRole:create()
    local p = FondDreamRole.new()
    p:init()
    return p
end

function FondDreamRole:init()
    self.id = "dreamPlayer"
	self.onlyId = Helper:getOnlyId()

	table.mergeToLeft(self, require("app.models.DreamWorldModel.DreamRole.DrRole_Item")) -- 载入物品相关模块
	table.mergeToLeft(self, require("app.models.FondDream.role.FondDrRole_Skill")) -- 载入技能相关模块
	
	-- 给梦境角色添加模块
	local ModuleManager = require("third.module.ModuleManager")
	ModuleManager:addModule(self, "app.models.role.module.RoleModule")
	:addSubModuleWithPath("app.models.role.module.dream.RoleFondDreamPlayerModule")

	self:initIgnoreCloneTb()
end

function FondDreamRole:getZhaoLvLimit(zhaoId)
	return 11
end

return class("FondDreamRole", { Role }, FondDreamRole,true)00000
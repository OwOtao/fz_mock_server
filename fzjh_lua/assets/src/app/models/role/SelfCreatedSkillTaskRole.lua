local class = require("third.class.NewClass")
local Role = require("app.models.role.Role")
local SelfCreatedSkillTaskRole = {}

function SelfCreatedSkillTaskRole:create(roleData)
    local p = SelfCreatedSkillTaskRole.new(roleData)
    p:init()
    return p
end

function SelfCreatedSkillTaskRole:init()
    self.id = tostring(Helper:getOnlyId())
    self.userid = "liLianClonePlayer01"
    local ModuleManager = require("third.module.ModuleManager")
    ModuleManager:addModule(self, "app.models.role.module.RoleModule")

    local SelfCreatedSkillSystem = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillSystem")
    self._selfCreatedSkillSystem = SelfCreatedSkillSystem:create()

    -- 面具系统
	local MaskSystem = require("app.models.mask.MaskSystem")
    self._maskSystem = MaskSystem:create(self)
    
    local RoleBuff = require("app.models.role.RoleBuff")
    self._roleBuff = RoleBuff:create()

    local RoleTitleSystem = require("app.models.role.titleSystem.RoleTitleSystem")
	self._titleSystem = RoleTitleSystem:create(self)

    local RoleItemSystem = require("app.models.role.item.RoleItemSystem")
    self._roleItemSystem = RoleItemSystem:create(self)
    
    --@desc 情绪系统接入
    local EmotionMgr = require("app.models.FondDream.FondDreamEmotionMgr")
    self.emotionMgr = EmotionMgr:create(self)

    local BuffManager = require("app.models.Buff.BuffManager")
    self._buffManager = BuffManager:create()
    -- 监控buff状态变化
    self._buffManager:registerUpdateFunc(
        function()
            self:dispatchEvent("roleBuffUpdate")
        end
    )

    local LiLianMapPropSystem = require("app.models.SelfCreatedSkillSystem.LiLianMapPropSystem")
    self._selfCreatedSkillSystem:setPropSystem(LiLianMapPropSystem:create())
    self._selfCreatedSkillSystem:init(self)
    
    self._buffManager:init(self)

    local items = self:getItems()

    if MapIsEmpty(items) == false then
        local saveItems = {}
        for k,v in pairs(items) do
            local itemAttr = self:getOneItemByKey(v.itemId)
            if itemAttr.canEquip and itemAttr.canEquip == 1 then
                table.insert(saveItems,v)
            end
        end
    
        self:setAttr("items", saveItems)
    end

    local RoleViewBorderSys = require("app.models.HeadViewSystem.RoleViewBorderSys")
	self._roleViewBorderSys = RoleViewBorderSys:create(self)
	
	--@desc 武学突破系统
	local SkillBreakThroughSystem = require("app.models.skill.skillBreakThrough.SkillBreakThroughSystem")
	self._skillBreakThroughSys = SkillBreakThroughSystem:create(self)
    
    self._selfCreatedSkillSystem:updataSelfCreatedSkillMap()

    self.__teacherBuildSystem = User:getRole():getTeacherBuildSystem()

    self:updateRoleBuff()
    self:checkActiveZhaoIsDeblocking()
end

return class("SelfCreatedSkillTaskRole", { Role }, SelfCreatedSkillTaskRole,true)000000000
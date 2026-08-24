local BaseBuff = require("app.models.Buff.BaseBuff")

local CreateDrPlayerBuff = class("CreateDrPlayerBuff", BaseBuff)

function CreateDrPlayerBuff:create(luaData,manager)
    local p = CreateDrPlayerBuff:new()
    p:init(luaData,manager)
    return p
end

function CreateDrPlayerBuff:onInit()
    self.name = "CreateDrPlayerBuff"
    --@desc 触发后是否失效
    self.unActiveAfterTrigger = true
    self:addListener(
        "CreateNewDrPlayerEvent",
        function(event)
            local context = {role = event.role}
            self:trigger(context)
        end,
        self
    )
end

return CreateDrPlayerBuff
0000
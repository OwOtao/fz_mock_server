local newClass = require("third.class.NewClass")

local RoleBorderConfig = {}

function RoleBorderConfig:create(data)
    return RoleBorderConfig.new(data)
end

-- 边框id
function RoleBorderConfig:getId()
    return self.id
end

-- 主界面人物头像框
function RoleBorderConfig:getFramePath()
    return self.FramePath
end

-- 角色个人信息边框
function RoleBorderConfig:getInfoFramePath()
    return self.InfoFramePath
end

-- 是否默认角色个人信息边框(面具详情展示界面，默认边框不显示)
function RoleBorderConfig:isDefaultFrame()
    return self.defaultInfoFrame == 1
end

return newClass("RoleBorderConfig", {}, RoleBorderConfig)
00
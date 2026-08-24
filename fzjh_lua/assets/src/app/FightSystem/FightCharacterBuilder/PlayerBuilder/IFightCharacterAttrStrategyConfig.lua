--[[
    author:Seven
    time:2024-01-23 21:12:02
    desc: 角色存档属性策略配置获取接口
]]
local interface = require("third.class.interface")

local IFightCharacterAttrStrategyConfig = {}

--@desc: 获取属性值
--@author:Seven
--@time:2024-01-23 21:16:42
--@name: 属性名
--@return: number
function IFightCharacterAttrStrategyConfig:getRoleAttr(name)
end

return interface("IFightCharacterAttrStrategyConfig", IFightCharacterAttrStrategyConfig)
000000000000
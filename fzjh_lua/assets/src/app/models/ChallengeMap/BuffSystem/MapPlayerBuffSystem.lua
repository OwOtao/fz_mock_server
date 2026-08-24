--[[
    author:Seven
    time:2025-11-06 16:07:53
    desc: 副本玩家buff系统
]]
local MapPlayerBuffSystem = {}

function MapPlayerBuffSystem.new(...)
    local self = setmetatable({}, {__index = MapPlayerBuffSystem})
    self:__init(...)
    return self
end

function MapPlayerBuffSystem:__init(player)
    self.__buffArray = {}

    self.__player = player

    -- id 索引创建
    self.__createIndexId = 1000

    --@desc 属性加法加成
    self.__addAttrMap = {}

    --@desc 属性乘法加成
    self.__mulAttrMap = {}
end

--@desc: 给玩家添加buff
--@author:Seven
--@time:2025-11-06 16:17:08
--@buffId: buffId
--@return: number indexId
function MapPlayerBuffSystem:addBuff(buffId, ...)
    
end

--@desc: 通过buffId查找buff列表
--@author:Seven
--@time:2025-11-06 16:28:13
--@buffId: buffId
--@return: array
function MapPlayerBuffSystem:findByBuffId(buffId)

end

--@desc: 通过indexId查找buff
--@author:Seven
--@time:2025-11-06 16:28:53
--@indexId: 索引id
--@return: buff
function MapPlayerBuffSystem:findByIndexId(indexId)
end

function MapPlayerBuffSystem:removeBuff(buffId)
end

function MapPlayerBuffSystem:removeBuffByIndexId(indexId)
end

return MapPlayerBuffSystem
000000000000
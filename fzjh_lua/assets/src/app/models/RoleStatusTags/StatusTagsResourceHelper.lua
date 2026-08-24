--[[
    author:Seven
    time:2025-02-21 17:13:56
    desc: 负责读取策划配置表导出的文件，根据条件进行分类，并提供相关资源操作API。该模块主要处理静态资源数据，不涉及动态业务逻辑。
]]
local res = require("script.others.statustags")["st"]

local StatusTagsResourceHelper = {}

StatusTagsResourceHelper.TAG_TYPE = {
    MAPUSE = 1, -- 地图使用
    NPCUSE = 2, -- NPC使用
    NORMAL = 3, -- 玩家普通
    INHERIT = 4, -- 玩家继承
    TIMELIMIT = 5, -- 玩家非传承时间限制标识
    INHSTIMELIMIT = 6 -- 玩家传承时间限制标识
}

local function validateTagId(tagId)
    tagId = tostring(tagId)
    local tag = res[tagId]
    if not tag then
        error("Invalid tagId: " .. tagId .. " not found in resources.")
    end
    return tag
end

function StatusTagsResourceHelper:isNpcUseStatusTag(tagId)
    local tag = validateTagId(tagId)
    return tag.sttype == self.TAG_TYPE.NPCUSE
end

function StatusTagsResourceHelper:isMapUseStatusTag(tagId)
    local tag = validateTagId(tagId)
    return tag.sttype == self.TAG_TYPE.MAPUSE
end

--@desc: 判断是否为普通状态标识
--@author:Seven
--@time:2025-02-21 17:18:44
--@tagId: 状态标识id
--@return: true | false
function StatusTagsResourceHelper:isNormalStatusTag(tagId)
    local tag = validateTagId(tagId)
    return tag.sttype == self.TAG_TYPE.NORMAL
end

--@desc: 判断是否为继承状态标识（继承状态标识在传承时不会被清除）
--@author:Seven
--@time:2025-02-21 17:19:44
--@tagId: 状态标识id
--@return: true | false
function StatusTagsResourceHelper:isInheritStatusTag(tagId)
    local tag = validateTagId(tagId)
    return tag.sttype == self.TAG_TYPE.INHERIT
end

function StatusTagsResourceHelper:isTimeLimitStatusTag(tagId)
    local tag = validateTagId(tagId)
    return tag.sttype == self.TAG_TYPE.TIMELIMIT
end

function StatusTagsResourceHelper:isInheritTimeLimitStatusTag(tagId)
    local tag = validateTagId(tagId)
    return tag.sttype == self.TAG_TYPE.INHSTIMELIMIT
end

--@desc: 获取状态标识类型（普通/继承）
--@author:Seven
--@time:2025-02-21 17:22:33
--@tagId: 标识id
--@return [src.app.models.RoleStatusTags.RoleStatusTagsArchiveService#StatusTagsResourceHelper.TAG_TYPE]
function StatusTagsResourceHelper:getStatusTagType(tagId)
    local tag = validateTagId(tagId)
    return tag.sttype
end

function StatusTagsResourceHelper:getStatusTagRes(tagId)
    local tag = validateTagId(tagId)
    return tag
end

--@desc: 判断标识是否是作用于角色的状态标识
function StatusTagsResourceHelper:isRoleStatusTagsType(tagId)
    local tag = validateTagId(tagId)
    return tag.sttype == self.TAG_TYPE.NORMAL or tag.sttype == self.TAG_TYPE.INHERIT or tag.sttype == self.TAG_TYPE.TIMELIMIT or tag.sttype == self.TAG_TYPE.INHSTIMELIMIT
end

return StatusTagsResourceHelper
00000000
local BasicTitle = require("app.models.role.titleSystem.BasicTitle")
local basicTitleRes = require("script.roleTitle.newRoleTitleConf")["1"]
local changeTitleRes = require("script.roleTitle.titleChangeConf")["chenghao"]

local RoleTitleResManager = {
    _normalTitle = {},
    _officialTitle = {},
    _prestigeTitle = {},
    _basicTitleClassById = {}
}

--@desc 存放称号分类表
local BasicTitleGroupMap = {}

local function loadRoleTitleRes()
    --@region 玩家普通称号
    local normalTitle = require("script.roleTitle.chenghao")["chenghao"]
    RoleTitleResManager._normalTitle = normalTitle
    --@endregion

    --@region 官职
    local officialTitle = require("script.roleTitle.officialChenHao")["Sheet1"]
    for k, v in pairs(officialTitle) do
        if RoleTitleResManager._officialTitle[v.type] == nil then
            RoleTitleResManager._officialTitle[v.type] = {}
        end
          
        table.insert(RoleTitleResManager._officialTitle[v.type], {title = v.color .. "【" .. v.text .. "】", title2 = v.text, lv = v.number, value = v.integral, id = v.id, basicTitleId = v.basicTitleId})
    end
    --@endregion


    --@region 声望
    local prestigeTitle = require("script.roleTitle.shengwangtouxian")["Sheet1"]
    RoleTitleResManager._prestigeTitle = prestigeTitle
    --@endregion

    local BasicTitleGroup = require("app.models.role.titleSystem.BasicTitleGroup")
    for _, v in pairs(basicTitleRes) do
        if BasicTitleGroupMap[tostring(v.type)] == nil then
            BasicTitleGroupMap[tostring(v.type)] = BasicTitleGroup:create(v.type, v.typeName)
        end

        local group = BasicTitleGroupMap[tostring(v.type)]

        group:addTitleId(v.id)
    end
end

loadRoleTitleRes()

function RoleTitleResManager:getNormalTitle()
    return self._normalTitle
end

function RoleTitleResManager:getOfficialTitle()
    return self._officialTitle
end

function RoleTitleResManager:getPrestigeTitle()
    return self._prestigeTitle
end

function RoleTitleResManager:getBasicTitleClassById(titleId)
    local titleId = tostring(titleId)

    if self._basicTitleClassById[titleId] == nil then
        local titleRes = basicTitleRes[titleId]

        if titleRes == nil then
            error("RoleTitleResManager:getBasicTitleClassById 称号配置表没有找到该称号：" .. titleId)
        end

        local titleClass = BasicTitle:create(titleRes)

        self._basicTitleClassById[titleId] = titleClass

        return self._basicTitleClassById[titleId]
    end

    return self._basicTitleClassById[titleId]
end

--@desc: 获取称号组
--@author:Seven
--@time:2024-04-16 16:40:36
--@groupId: 称号类型
--@return [src.app.models.role.titleSystem.BasicTitleGroup#BasicTitleGroup]
function RoleTitleResManager:getBasicTitleGroup(groupId)
    local group = BasicTitleGroupMap[tostring(groupId)]

    if group == nil then
        error("没有找到该称号组：" .. tostring(groupId))
    end

    return group
end

--@desc: 获取所有称号组表
--@author:Seven
--@time:2024-04-16 16:41:51
--@return: [table]
function RoleTitleResManager:getBasicTitleGroupMap()
    return BasicTitleGroupMap
end

function RoleTitleResManager:getChangeTitleBasicTitleId(titleType, titleId)
    titleId = tonumber(titleId)
    titleType = tonumber(titleType)

    for __, title in pairs(changeTitleRes) do
        if title.titleType == titleType and title.id == titleId then
            return tostring(title.basicTitleId)
        end
    end
end

return RoleTitleResManager
000000
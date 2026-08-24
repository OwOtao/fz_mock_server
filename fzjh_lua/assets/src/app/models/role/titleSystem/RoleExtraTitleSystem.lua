local NewClass = require("third.class.NewClass")

local IRoleExtraTitleSystem = require("app.models.role.titleSystem.IRoleExtraTitleSystem")

local IGetRoleViewBorder = require("app.models.HeadViewSystem.IGetRoleViewBorder")

local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")

local BorderConfigManager = require("app.models.HeadViewSystem.BorderConfigManager")

local LogSystem = require("app.models.LogSystem.LogSystem")

local RoleExtraTitleSystem = {}

function RoleExtraTitleSystem:create(role)
    local p = RoleExtraTitleSystem.new()
    p.__isNotSerializable = true
    p:init(role)
    return p
end

function RoleExtraTitleSystem:init(role)
    self._role = role
end

-- @desc 是否存在某个称号
function RoleExtraTitleSystem:containsTitle(titleType, titleId)
    local extraTitleList = self._role:getExtraTitle()
    if not MapIsEmpty(extraTitleList[tostring(titleType)]) then
        for i, id in ipairs(extraTitleList[tostring(titleType)]) do
            if tostring(id) == tostring(titleId) then
                return true
            end
        end
    end

    return false
end

-- @desc 添加称号
function RoleExtraTitleSystem:addTitle(titleType, titleId)
    local extraTitleList = self._role:getExtraTitle()
    if extraTitleList[tostring(titleType)] == nil then
        extraTitleList[tostring(titleType)] = {}
    end
    table.insert(extraTitleList[tostring(titleType)], titleId)

    LogSystem:log("--------添加称号  titleType = ", titleType, "titleId = ", titleId)
end

-- @desc 删除指定称号
function RoleExtraTitleSystem:deletaTitle(titleType, titleId)
    local extraTitleList = self._role:getExtraTitle()
    if MapIsEmpty(extraTitleList[tostring(titleType)]) then
        LogSystem:log("没有要删除的称号")
        return
    end

    LogSystem:log("--------删除称号  titleType = ", titleType, "titleId = ", titleId)

    for i = #extraTitleList[tostring(titleType)], 1, -1 do
        if tostring(extraTitleList[tostring(titleType)][i]) == tostring(titleId) then
            table.remove(extraTitleList[tostring(titleType)], i)
        end
    end

    if #extraTitleList[tostring(titleType)] == 0 then
        self:deletaTitleByType(titleType)
    end
end

-- @desc 删除指定类型称号
function RoleExtraTitleSystem:deletaTitleByType(titleType)
    local extraTitleList = self._role:getExtraTitle()

    extraTitleList[tostring(titleType)] = nil
end

--@desc 获取称号资源数据
function RoleExtraTitleSystem:getSpecialTitle(titleType, titleId)
    local specialTitleTable = RoleTitleResManager:getSpecialTitle()
    local specialTitle = specialTitleTable[tostring(titleType)]
    if specialTitle == nil or specialTitle[tostring(titleId)] == nil then
        error("没有类型为：" .. titleType .. " id为：" .. titleId .. "的特殊称号")
    end
    return specialTitle[tostring(titleId)]
end

--@desc 获取称号类型名称
function RoleExtraTitleSystem:getSpTitleTypeName(titleType)
    local specialTitleTable = RoleTitleResManager:getSpecialTitle()
    local specialTitle = specialTitleTable[tostring(titleType)]
    if specialTitle == nil then
        error("没有类型为：" .. titleType .. "的特殊称号")
    end
    for k, v in pairs(specialTitle) do
        return v.typename
    end
end

function RoleExtraTitleSystem:transitionExtraTitle()
    local extraTitleList = self._role:getAttr("extraTitle")
    if MapIsEmpty(extraTitleList) then
        return
    end

    local newExtraTitle = {}

    for titleType, titleList in pairs(extraTitleList) do
        if newExtraTitle[tostring(titleType)] == nil then
            newExtraTitle[tostring(titleType)] = {}
        end
        for i, titleData in ipairs(titleList) do
            if tonumber(titleType) == RoleTitleConst.Type.Prestige then
                local titleTab = string.split(titleData.title, ";")

                for k, prestigeId in ipairs(titleTab) do
                    if prestigeId and prestigeId ~= "" then
                        table.insert(newExtraTitle[tostring(titleType)], prestigeId)
                    end
                end
            else
                table.insert(newExtraTitle[tostring(titleType)], titleData.id)
            end
        end
    end

    self._role:setExtraTitle(newExtraTitle)

    --@desc 转换完成删除历史数据
    self._role:setAttr("extraTitle", nil)
end

--@desc: 获取头像边框
--@author:Seven
--@time:2021-11-30 11:34:39
function RoleExtraTitleSystem:getBorder()
    local titleType = self._role:getAttr("title_type")

    local titleId = self._role:getAttr("title_id")

    local spTitleClass = RoleTitleResManager:getSpecialTitleClassByTypeAndOId(titleType, titleId)

    local borderId = spTitleClass:getBorderId()

    if borderId == nil then
        return BorderConfigManager:getBorderConf(self:getDefaultBorderId()):getFramePath()
    else
        return BorderConfigManager:getBorderConf(borderId):getFramePath()
    end
end

--@desc 获取头像边框Id
function RoleExtraTitleSystem:getBorderId()
    local titleType = self._role:getAttr("title_type")

    local titleId = self._role:getAttr("title_id")

    local spTitleClass = RoleTitleResManager:getSpecialTitleClassByTypeAndOId(titleType, titleId)

    local borderId = spTitleClass:getBorderId()

    return borderId or self:getDefaultBorderId()
end

function RoleExtraTitleSystem:getDefaultBorderId()
    return 10000
end

function RoleExtraTitleSystem:getInfoViewBorder()
    local titleType = self._role:getAttr("title_type")

    local titleId = self._role:getAttr("title_id")

    local spTitleClass = RoleTitleResManager:getSpecialTitleClassByTypeAndOId(titleType, titleId)

    local borderId = spTitleClass:getBorderId()

    if borderId == nil then
        return BorderConfigManager:getBorderConf(self:getDefaultBorderId()):getInfoFramePath()
    else
        return BorderConfigManager:getBorderConf(borderId):getInfoFramePath()
    end
end

return NewClass("RoleExtraTitleSystem", {IRoleExtraTitleSystem, IGetRoleViewBorder}, RoleExtraTitleSystem)
0000000000000
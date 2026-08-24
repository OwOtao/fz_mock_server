--[[
    角色称号系统，需重新规划，后续修改
]]
local newClass = require("third.class.NewClass")

local IGetRoleViewBorder = require("app.models.HeadViewSystem.IGetRoleViewBorder")

local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")

local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

local BorderConfigManager = require("app.models.HeadViewSystem.BorderConfigManager")

--@SuperType [src.app.models.role.titleSystem.IRoleTitleSystem#IRoleTitleSystem]
--@SuperType [src.app.models.HeadViewSystem.IGetRoleViewBorder#IGetRoleViewBorder]
local RoleTitleSystem = {}

function RoleTitleSystem:create(role)
    local p = RoleTitleSystem.new()
    p.__isNotSerializable = true
    p:__init(role)
    return p
end

function RoleTitleSystem:__init(role)
    self.__role = role
    self.__output = {}

    self.__basicTitleData = self.__role:getBasicTitleData()
    
    self:__addDefaultTitle()
end

function RoleTitleSystem:addOutput(output)
    if self:cheackOutput(output) == false then
        table.insert(self.__output, output)
    end
end

function RoleTitleSystem:deleteOutput(output)
    for i, v in ipairs(self.__output) do
        if v == output then
            table.remove(self.__output, i)
        end
    end
end

function RoleTitleSystem:cheackOutput(output)
    if MapIsEmpty(self.__output) then
        return false
    end
    for i, v in ipairs(self.__output) do
        if v == output then
            return true
        end
    end
    return false
end

function RoleTitleSystem:getInfoViewBorder()
    local borderId = self:getBorderId()

    return BorderConfigManager:getBorderConf(borderId):getInfoFramePath()
end

function RoleTitleSystem:getBorder()
    local borderId = self:getBorderId()

    return BorderConfigManager:getBorderConf(borderId):getFramePath()
end

function RoleTitleSystem:getBorderId()
    local basicTitle = self:getCurrBasicTitle()
    local borderId = basicTitle:getBorderId()

    if borderId then
        return borderId
    end

    return self:getDefaultBorderId()
end

function RoleTitleSystem:getDefaultBorderId()
    return 10000
end

function RoleTitleSystem:useBasicTitle(titleId)
    if not titleId then
        return
    end
    
    titleId = tostring(titleId)

    self.__basicTitleData.titleId = titleId

    --使用新版称号时，需取消旧版称号
    self.__role:setAttr("title_type", nil)
    self.__role:setAttr("title_id", nil)

    self:__updateBorderSys()
    self:__updateOutputUI()
end

function RoleTitleSystem:addBasicTitle(titleId)
    if not titleId then
        return
    end

    titleId = tostring(titleId)

    if self:hasBasicTitle(titleId) == false then
        table.insert(self.__basicTitleData.titleList, titleId)
    end
end

function RoleTitleSystem:deleteBasicTitle(titleId)
    if not titleId then
        return
    end

    titleId = tostring(titleId)

    if self:hasBasicTitle(titleId) then
        local titleList = self.__basicTitleData.titleList
        if MapIsEmpty(titleList) == false then
            for i = #titleList, 1, -1 do
                if titleList[i] == titleId then
                    table.remove(titleList, i)
    
                    if self.__basicTitleData.titleId == titleId then
                        self.__basicTitleData.titleId = self:getDefaultBasicId()
                    end
    
                    break
                end
            end
        end
    end
end

function RoleTitleSystem:hasBasicTitle(titleId)
    if not titleId then
        return false
    end

    titleId = tostring(titleId)

    local titleList = self.__basicTitleData.titleList

    if table.indexof(titleList, titleId) then
        return true
    end

    return false
end

function RoleTitleSystem:getBasicTitle(titleId)
    if self:hasBasicTitle(titleId) == false then
        assert(false, "角色没有该称号id:"..titleId)
    end

    local title = RoleTitleResManager:getBasicTitleClassById(titleId)

    return title
end

function RoleTitleSystem:getDefaultBasicId()
    local sex = self.__role:getAttr("sex")
    return switch(sex, {
        ["男"] = function()
            if self:hasBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Woman) then
                self:deleteBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Woman)
            end

            if self:hasBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Man) == false then
                self:addBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Man)
            end

            return RoleTitleConst.Role_Default.BasicTitleId_Man
        end,

        ["女"] = function()
            if self:hasBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Man) then
                self:deleteBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Man)
            end

            if self:hasBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Woman) == false then
                self:addBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Woman)
            end

            return RoleTitleConst.Role_Default.BasicTitleId_Woman
        end,

        default = function()
            if self:hasBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Woman) then
                self:deleteBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Woman)
            end

            if self:hasBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Man) == false then
                self:addBasicTitle(RoleTitleConst.Role_Default.BasicTitleId_Man)
            end

            return RoleTitleConst.Role_Default.BasicTitleId_Man
        end
    })

end

function RoleTitleSystem:getRoleBasicTitleList()
    local info = {}

    local titleList = self.__basicTitleData.titleList

    if titleList then
        for i, titleId in ipairs(titleList) do
            local title = self:getBasicTitle(titleId)

            table.insert(info, title)
        end
    end

    return info
end

function RoleTitleSystem:getCurrBasicTitle()
    local titleId = self.__basicTitleData.titleId

    if titleId and self:hasBasicTitle(titleId) == false then
        titleId = nil
        self.__basicTitleData.titleId = nil
    end

    if not titleId then
        titleId = self:getDefaultBasicId()
        self.__basicTitleData.titleId = titleId
    end

    local title = self:getBasicTitle(titleId)

    return title
end

function RoleTitleSystem:__addDefaultTitle()
    local defaultTitleId = self:getDefaultBasicId()
    if self:hasBasicTitle(defaultTitleId) == false then
        self:addBasicTitle(defaultTitleId)
    end
end

function RoleTitleSystem:__updateBorderSys()
    local borderId = self:getBorderId()

    if borderId ~= self:getDefaultBorderId() then
        self.__role:getRoleViewBorderSys():addShowClass("title")
    else
        self.__role:getRoleViewBorderSys():removeShowClass("title")
    end
end

function RoleTitleSystem:__updateOutputUI()
    if MapIsEmpty(self.__output) == false then
        for i, output in ipairs(self.__output) do
            output:changRoleTitle()
        end
    end
end

return newClass("RoleTitleSystem", {}, RoleTitleSystem)
00000000000
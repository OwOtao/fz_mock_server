local newClass = require("third.class.NewClass")

local IMeridianRoleSystem = require("app.models.Meridian.System.IMeridianRoleSystem")

local BasicMeridianImprintingPage = require("app.models.Meridian.BasicMeridianImprintingPage")

local BasicMeridianImprinting = require("app.models.Meridian.BasicMeridianImprinting")

--@desc 最大页数
local __MAX_PAGE_COUNT__ = 2

local ROLE_SAVE_DATA_COVERT_FLAG = "_MERIDATACOVERTVER_"

--@SuperType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
local MeridianRoleSystemImpl = {}

local function READONLY_TABLE(T)
    return setmetatable(
        T,
        {
            -- 捕获访问操作，直接从原始表获取数据
            __index = T,
            -- 捕获试图修改表的操作并抛出错误
            __newindex = function(_, key, value)
                error("Attempt to modify a read-only table ：READONLY_TABLE")
            end,
            -- 防止表被设置元表
            __metatable = "This is a read-only table"
        }
    )
end

function MeridianRoleSystemImpl:create(...)
    local p = MeridianRoleSystemImpl.new()
    return p:__init(...)
end

function MeridianRoleSystemImpl:__init(role)
    self.__role = assert(role, "MeridianRoleSystemImpl:__init role is nil")

    -- 角色经脉印记存档数据
    self.__roleSaveData = self.__role:getAttr("m_meridianImprintings")

    if self.__roleSaveData == nil then
        -- 只为防止一些特殊情况创建角色对象后，获取该系统前直接修改底层属性导致为空的情况
        self.__roleSaveData = clone(Role.m_meridianImprintings)
    end

    local count = 0
    for _, v in pairs(self.__roleSaveData.mPageList) do
        count = count + 1
    end
    if count < 1 then
        error("角色经脉印记页数据【m_meridianImprintings.mPageList】不正确，请检查是否被修改")
    end

    self:__convertSaveData()

    self:__initMeridianData()

    return self
end

function MeridianRoleSystemImpl:__initMeridianData()
    -- 经脉印记天赋页对象列表
    self.__meridianImprintingPages = {}

    self.__imprintingMap = {}

    self:__initMeridianImprintingMap()

    self:__initMeridianImprintingPages()
end

--@desc:
--@author:Seven
--@time:2025-02-20 19:11:48
--@pageNumber: 当前已开页数
function MeridianRoleSystemImpl:repairMeridianData(pageNumber)
    if type(pageNumber) ~= "number" then
        error("MeridianRoleSystemImpl:repairMeridianData pageNumber not type number")
    end

    local isRepair = false

    local repairMag = {before = clone(self.__roleSaveData)}

    --预防回档导致玩家已开启页数变成未开启,自动帮玩家开启
    for pageIndex = 1, pageNumber do
        if not self:isUnLockMeridianImprintingPage(pageIndex) then
            self:unlockMeridianImprintingPage()

            isRepair = true
        end
    end

    if isRepair then
        repairMag["after"] = clone(self.__roleSaveData)

        local Record = require("app.models.Record.Record")

        Record:addLogData(Record.RECORD_TYPE.MERIDIAN_PAGE_REPAIR, repairMag)
    end

    local isCheat = false

    local cheatMsg = {before = clone(self.__roleSaveData)}

    local __roleCount = 0
    for _, v in pairs(self.__roleSaveData.mPageList) do
        __roleCount = __roleCount + 1
    end

    if __roleCount > pageNumber then
        isCheat = true
        local removeList = {}
        for pageIndex, v in pairs(self.__roleSaveData.mPageList) do
            if tonumber(pageIndex) > pageNumber then
                table.insert(removeList, pageIndex)
            end
        end
        for k, v in pairs(removeList) do
            self.__roleSaveData.mPageList[v] = nil
        end
    end

    if isCheat then
        self.__roleSaveData.mImprintingMap = {}
        for _, page in pairs(self.__roleSaveData.mPageList) do
            if not MapIsEmpty(page) then
                for __, imprintingId in ipairs(page) do
                    self.__roleSaveData.mImprintingMap[imprintingId] = {}
                end
            end
        end

        --当前使用页数大于已开启页数时,自动帮玩家选择第一页
        if self.__roleSaveData.mCurrPage > pageNumber then
            self.__roleSaveData.mCurrPage = 1
        end

        --作弊数据修复后需要重新初始化系统数据
        self:__initMeridianData()

        self.__role:updateRoleBuff()

        cheatMsg["after"] = clone(self.__roleSaveData)

        local Record = require("app.models.Record.Record")

        Record:addLogData(Record.RECORD_TYPE.MERIDIAN_PAGE_CHEAT, cheatMsg)
    end
end

function MeridianRoleSystemImpl:__convertSaveData()
    local flagVer = self.__roleSaveData._MERIDATACOVERTVER_
    if flagVer == 0 then
        -- 旧数据转换
        local o_meridianImprinting = self.__role:getAttr("meridianImprinting")

        self.__roleSaveData.__convertBeforeTemp = {
            convertTime = GetTime(),
            list = {}
        }

        if o_meridianImprinting ~= nil and table.getn(o_meridianImprinting) > 0 then
            local l = self.__roleSaveData.__convertBeforeTemp.list
            for _, v in ipairs(o_meridianImprinting) do
                local id = v.imprintingId
                self.__roleSaveData.mImprintingMap[id] = {}
                for pageIndex, page in pairs(self.__roleSaveData.mPageList) do
                    table.insert(page, id)
                    table.insert(l, id)
                end
            end
        end

        self.__role:setAttr("meridianImprinting", nil)

        flagVer = 1
    end

    if self.__roleSaveData.__convertBeforeTemp ~= nil then
        -- clear temp data after 14 days
        if GetTime() - self.__roleSaveData.__convertBeforeTemp.convertTime > 3600 * 24 * 14 then
            self.__roleSaveData.__convertBeforeTemp = nil
        end
    end

    self.__roleSaveData._MERIDATACOVERTVER_ = flagVer
end

function MeridianRoleSystemImpl:__initMeridianImprintingMap()
    for imprId, v in pairs(self.__roleSaveData.mImprintingMap) do
        local impr = BasicMeridianImprinting:create(imprId, v)
        self.__imprintingMap[imprId] = impr
    end
end

function MeridianRoleSystemImpl:__initMeridianImprintingPages()
    for i = 1, __MAX_PAGE_COUNT__ do
        local imprintingDataList = self.__roleSaveData.mPageList[tostring(i)]

        local list = {}

        if imprintingDataList ~= nil then
            for _, imprId in ipairs(imprintingDataList) do
                local impr = self:__getMeridianImprinting(imprId)
                table.insert(list, impr)
            end
        else
            list = nil
        end

        local page = BasicMeridianImprintingPage:create(i, list)

        table.insert(self.__meridianImprintingPages, page)
    end
end

--@desc: 获取经脉印记对象
--@author:Seven
--@time:2025-01-16 21:14:15
--@imprId: 经脉印记ID
--@return [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
function MeridianRoleSystemImpl:__getMeridianImprinting(imprId)
    local impr = self.__imprintingMap[imprId]
    if not impr then
        error("MeridianRoleSystemImpl:__getMeridianImprinting impr is nil" .. tostring(imprId))
    end
    return impr
end

function MeridianRoleSystemImpl:getRole()
    return self.__role
end

function MeridianRoleSystemImpl:getMeridianImprintingPages()
    local list = {}
    for _, v in ipairs(self.__meridianImprintingPages) do
        table.insert(list, v)
    end
    return list
end

function MeridianRoleSystemImpl:addMeridianImprinting(meriImpId)
    if self:roleHasImpriting(meriImpId) then
        return
    end

    local basicMeridianImprinting = BasicMeridianImprinting:create(meriImpId)

    if not basicMeridianImprinting then
        return
    end

    self.__imprintingMap[meriImpId] = basicMeridianImprinting

    for i, v in ipairs(self.__meridianImprintingPages) do
        if v:isUnlock() then
            v:addImprinting(basicMeridianImprinting)
        end
    end

    self:__updateSaveData()
end

function MeridianRoleSystemImpl:replaceMeridianImprinting(meriImpPageIndex, oMeriImpId, nMeriImpId)
    oMeriImpId = assert(oMeriImpId, "MeridianRoleSystemImpl:replaceMeridianImprinting oMeriImpId is nil ")

    nMeriImpId = assert(nMeriImpId, "MeridianRoleSystemImpl:replaceMeridianImprinting nMeriImpId is nil ")

    local page = self:__getImprintingPage(meriImpPageIndex)

    if not page:isUnlock() then
        error("MeridianRoleSystemImpl:replaceMeridianImprinting page is not unlock pageIndex:" .. tostring(meriImpPageIndex))
    end

    --@RefType [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
    local newImprinting = BasicMeridianImprinting:create(nMeriImpId)

    local oldImpr = page:removeImprinting(oMeriImpId)

    page:addImprinting(newImprinting)

    if not self:roleHasImpriting(newImprinting:getImprintingId()) then
        self.__imprintingMap[newImprinting:getImprintingId()] = newImprinting
    end

    local isHasOldImpr = false

    self:__walkImpritingPage(
        function(v)
            if v:findImprinting(oMeriImpId) then
                isHasOldImpr = true
                return true
            end
        end
    )

    if not isHasOldImpr then
        self.__imprintingMap[oMeriImpId] = nil
    end

    self:__updateSaveData()

    return oldImpr
end

function MeridianRoleSystemImpl:switchMeridianImprintingPage(meriImpPageIndex)
    if meriImpPageIndex < 0 or meriImpPageIndex > self:getMeridianImprintingPageCount() then
        error("MeridianRoleSystemImpl:switchMeridianImprintingPage meriImpPageIndex is out of range")
    end

    local current = self.__roleSaveData.mCurrPage
    if current == meriImpPageIndex then
        return false, "你正在使用该页，无需切换"
    end

    self.__roleSaveData.mCurrPage = meriImpPageIndex

    return true
end

function MeridianRoleSystemImpl:getPageMeridianImprintings(meriImpPageIndex)
    local page = self:__getImprintingPage(meriImpPageIndex)

    return page:getImprintings()
end

function MeridianRoleSystemImpl:getCurrentPageMeridianImprintings()
    return self:getPageMeridianImprintings(self.__roleSaveData.mCurrPage)
end

function MeridianRoleSystemImpl:getCurrUsingMeridianImprintingPageNumber()
    return self.__roleSaveData.mCurrPage
end

function MeridianRoleSystemImpl:unlockMeridianImprintingPage()
    local page = nil
    --@desc 默认第一页一定是解锁的
    for i = 2, #self.__meridianImprintingPages do
        local m_page = self.__meridianImprintingPages[i]
        if not m_page:isUnlock() then
            page = m_page
            break
        end
    end

    if page == nil then
        return -1
    end

    page:clearImprintings()

    page:unlock()

    local list = self:getPageMeridianImprintings(1)

    for i = 1, #list do
        local impr = list[i]
        page:addImprinting(impr)
    end

    self:__updateSaveData()

    return page:getPageIndex()
end

function MeridianRoleSystemImpl:getMeridianImprintingPageCount()
    return __MAX_PAGE_COUNT__
end

function MeridianRoleSystemImpl:clearAllMeridianImprinting()
    self.__imprintingMap = {}
    self:__walkImpritingPage(
        function(page)
            if page:isUnlock() then
                page:clearImprintings()
            end
        end
    )
    self:__updateSaveData()
end

function MeridianRoleSystemImpl:getAllMeridianImprintings()
    return table.mapToArray(self.__imprintingMap)
end

function MeridianRoleSystemImpl:currPageHasMeridianImprinting(imprId)
    local impr = self:__getImprintingPage(self:getCurrUsingMeridianImprintingPageNumber()):findImprinting(imprId)
    if impr then
        return true
    end
    return false
end

function MeridianRoleSystemImpl:hasMeridianImprintingByPage(pageIndex, imprId)
    local impr = self:__getImprintingPage(pageIndex):findImprinting(imprId)
    if impr then
        return true
    end
    return false
end

function MeridianRoleSystemImpl:isUnLockMeridianImprintingPage(pageIndex)
    return self:__getImprintingPage(pageIndex):isUnlock()
end

--@keepSaveImpritingData: { {imprId , imprId} , {imprId , imprId} } || { {} ，nil } || { nil,nil}
function MeridianRoleSystemImpl:resetMeridianImpritings(keepSaveImpritingData)
    local keepSavaImpritingMap = {}

    for pageIndex = 1, __MAX_PAGE_COUNT__ do
        local page = self:__getImprintingPage(pageIndex)

        if page:isUnlock() then
            local keepImrpList = {}
            local imprIdList = keepSaveImpritingData[pageIndex]

            if not MapIsEmpty(imprIdList) then
                for _, imprId in ipairs(imprIdList) do
                    local __impr, m_index = page:findImprinting(imprId)

                    if __impr == nil then
                        error("MeridianRoleSystemImpl:resetMeridianImpritings imprId is not in page pageIndex:" .. tostring(pageIndex) .. " imprId:" .. tostring(imprId))
                    end

                    table.insert(keepImrpList, __impr)
                end
            end

            page:clearImprintings()

            for _, impr in ipairs(keepImrpList) do
                if keepSavaImpritingMap[impr:getImprintingId()] == nil then
                    keepSavaImpritingMap[impr:getImprintingId()] = impr
                end

                page:addImprinting(impr)
            end
        end
    end

    self.__imprintingMap = keepSavaImpritingMap

    self:__updateSaveData()
end

function MeridianRoleSystemImpl:roleHasImpriting(meriImpId)
    local impr = self.__imprintingMap[meriImpId]
    if impr then
        return true
    end
    return false
end

--@desc: 获取经脉印记天赋页对象
--@author:Seven
--@time:2025-01-16 20:42:40
--@index: 页数
--@return [src.app.models.Meridian.BasicMeridianImprintingPage#BasicMeridianImprintingPage]
function MeridianRoleSystemImpl:__getImprintingPage(index)
    local page = self.__meridianImprintingPages[index]
    if page == nil then
        error("MeridianRoleSystemImpl:__getImprintingPage page is nil" .. tostring(index))
    end

    return page
end

function MeridianRoleSystemImpl:__updateSaveData()
    self.__roleSaveData.mImprintingMap = {}
    for _, v in pairs(self.__imprintingMap) do
        --@RefType [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
        local v = v
        self.__roleSaveData.mImprintingMap[v:getImprintingId()] = v:getImprintingData()
    end

    self.__roleSaveData.mPageList = {}
    for index, v in ipairs(self.__meridianImprintingPages) do
        if v:isUnlock() then
            local list = v:getImprintings()
            local imprList = {}
            for _, vv in ipairs(list) do
                table.insert(imprList, vv:getImprintingId())
            end
            self.__roleSaveData.mPageList[tostring(index)] = imprList
        end
    end
end

function MeridianRoleSystemImpl:__walkImpritingPage(walkFunc)
    for _, v in ipairs(self.__meridianImprintingPages) do
        local isBreak = walkFunc(v)
        if isBreak == true then
            break
        end
    end
end

function MeridianRoleSystemImpl:__printMeridianData()
    print("================= MeridianRoleSystemImpl:__printMeridianData =================")
    print("mCurrPage:" .. self.__roleSaveData.mCurrPage)

    local count = 0
    for _, v in pairs(self.__roleSaveData.mPageList) do
        count = count + 1
    end
    print("mPageList:" .. count)
    for k, v in pairs(self.__roleSaveData.mPageList) do
        print("|-page:" .. k)
        for _, vv in ipairs(v) do
            print("|--imprId:" .. vv)
        end
    end
    print("mImprintingMap: ")
    local count = 0
    for k, v in pairs(self.__roleSaveData.mImprintingMap) do
        count = count + 1
        print("|-imprId:" .. k)
    end
    print("|-count:" .. count)

    print("=============================================================================")
end

return newClass("MeridianRoleSystemImpl", {IMeridianRoleSystem}, MeridianRoleSystemImpl)
000000000000000
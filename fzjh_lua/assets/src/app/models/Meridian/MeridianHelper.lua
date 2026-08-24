--[[
    author:Seven
    time:2025-01-17 17:46:55
    desc: 经脉相关辅助类
]]
--@RefType[MeridianResources]
local MeridianResources = require("app.models.Meridian.MeridianResources")

local MeridianHelper = {}

--使用定志丸能提升培元获得的几率列表
local addProbabilityList = {
    huajianyin = 18,
    huadaoyin = 18,
    huabianyin = 18,
    huaqiangyin = 18,
    huaanqiyin = 18,
    huashuangchiyin = 18,
    huayueqiyin = 18
}

local HUA_ZHI_IMPRIDS = {"huajianyin", "huadaoyin", "huabianyin", "huaqiangyin", "huaanqiyin", "huashuangchiyin", "huayueqiyin"}

--@desc: 排除当前页已拥有印记，获取随机培元列表(不包含已经拥有的印记)
--@author:Seven
--@time:2025-01-17 17:50:17
--@meridianSys: [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
--@return: list [imprIdList] 经脉印记ID列表
function MeridianHelper:getPeiYuanRandomList(pageIndex, meridianSys)
    assert(pageIndex, "pageIndex must not nil")
    assert(pageIndex > 0, "pageIndex must > 0")
    local list = {}

    local role = meridianSys:getRole()

    local inheritCount = role:getAttr("inheritCount")

    local roleAllImprList = meridianSys:getPageMeridianImprintings(pageIndex)

    local allImprList = MeridianResources:getAllMeridianImprintingRes()

    --对比两个列表，根据getImprintingId()来判断是否相同，把roleAllImprList中有的从allImprList的筛选中排除，重新生成一个随机列表
    for _, impr in ipairs(allImprList) do
        --@RefType [src.app.models.Meridian.MeridianImprintingRes#MeridianImprintingRes]
        impr = impr
        local isExist = false
        for _, roleImpr in ipairs(roleAllImprList) do
            if impr:getImprintingId() == roleImpr:getImprintingId() then
                isExist = true
                break
            end
        end

        if not isExist and impr:getPeiyuan() == 1 and impr:getInherit() <= inheritCount then
            table.insert(list, impr)
        end
    end

    return list
end

--@desc: 排除当前页已拥有印记，随机获得一个培元印记ID(不包含已经拥有的印记)
--@author:Seven
--@time:2025-01-17 18:12:17
--@meridianSys: [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
--@isUseDingWan: 是否使用了定志丸
--@return: nil or imprId
function MeridianHelper:getPeiYuanRandomImprintingId(pageIndex, meridianSys, isUseDingWan)
    assert(pageIndex, "pageIndex must not nil")
    assert(pageIndex > 0, "pageIndex must > 0")
    local randomList = self:getPeiYuanRandomList(pageIndex, meridianSys)

    if #randomList == 0 then
        return nil
    end

    local weightList = {}
    for i, impr in ipairs(randomList) do
        --@RefType [src.app.models.Meridian.MeridianImprintingRes#MeridianImprintingRes]
        impr = impr
        local imprId = impr:getImprintingId()
        local weight = impr:getProbability()

        --@desc 使用定志丸，对于规定印记，会额外加成概率值，否则为0
        if isUseDingWan == true then
            local addProbability = addProbabilityList[imprId]
            if addProbability then
                weight = weight + addProbability
            end
        end

        table.insert(weightList, weight)
    end
    local index = Helper:RandomByWeight(weightList)

    local imprId = randomList[index]:getImprintingId()

    return imprId
end

--@desc:获取指定页面随机的化指系列印记ID(不包含已经拥有的印记)
--@author:Seven
--@time:2025-01-17 20:16:48
--@meridianSys: [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
--@usedDingZhiWanNum: 已使用的定志丸数量
--@return: nil or imprId
function MeridianHelper:getRandomHuaZhiMeridianImprintId(pageIndex, meridianSys, usedDingZhiWanNum)
    assert(pageIndex, "pageIndex must not nil")
    assert(pageIndex > 0, "pageIndex must > 0")
    if usedDingZhiWanNum <= 0 then
        return nil
    end

    if (usedDingZhiWanNum % 21) ~= 0 then
        return nil
    end

    local list = {}

    local haveCount = 0
    for i, huaZhiId in ipairs(HUA_ZHI_IMPRIDS) do
        if not meridianSys:hasMeridianImprintingByPage(pageIndex, huaZhiId) then
            table.insert(list, huaZhiId)
        else
            haveCount = haveCount + 1
        end
    end

    if #list == 0 then
        return nil
    end

    local num = usedDingZhiWanNum / 21
    if num > haveCount then
        local index = math.random(1, #list)
        return list[index]
    end

    return nil
end

local function __doInherit(inheritRole, inheritImpriPageList)
    local ihMeridianImprintingsData = inheritRole:getAttr("m_meridianImprintings")

    if #inheritImpriPageList <= 0 then
        error("需传承的经脉印记列表为空")
    end

    local inheritImpriMap = {}

    local inheritImpriPageDataList = clone(Role.m_meridianImprintings.mPageList)

    for index, impriPage in ipairs(inheritImpriPageList) do
        --@RefType [src.app.models.Meridian.BasicMeridianImprintingPage#BasicMeridianImprintingPage]
        impriPage = impriPage
        local impriPageId = impriPage:getPageIndex()
        local impritings = impriPage:getImprintings()
        if #impritings > 0 then
            local idList = {}

            for __, impr in ipairs(impritings) do
                --@RefType [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
                impr = impr
                local imprId = impr:getImprintingId()
                if inheritImpriMap[imprId] == nil then
                    inheritImpriMap[imprId] = {}
                end
                table.insert(idList, imprId)
            end

            if inheritImpriPageDataList[tostring(index)] then
                inheritImpriPageDataList[tostring(index)] = idList
            else
                inheritImpriPageDataList[tostring(index)] = idList
            end
        end
    end

    ihMeridianImprintingsData.mImprintingMap = inheritImpriMap
    ihMeridianImprintingsData.mPageList = inheritImpriPageDataList

    inheritRole:setAttr("m_meridianImprintings", ihMeridianImprintingsData)
end

--@desc: 传承经脉处理 （非常规方案，如果inheritRole先初始化了经脉数据，这套处理可能会无效）
--@author:Seven
--@time:2025-01-18 15:45:44
--@inheritRole: 传承角色
--@inheritImpritingData : 传承数据 {{imprId,imprId},{imprId,imprId}}
function MeridianHelper:meridianDoInherit(inheritRole, inheritImpritingData)
    local BasicMeridianImprintingPage = require("app.models.Meridian.BasicMeridianImprintingPage")
    local BasicMeridianImprinting = require("app.models.Meridian.BasicMeridianImprinting")

    local pageList = {}

    for pageIndex, imprList in ipairs(inheritImpritingData) do
        local __list = {}

        for _, imprId in ipairs(imprList) do
            table.insert(__list, BasicMeridianImprinting:create(imprId))
        end

        local page = BasicMeridianImprintingPage:create(pageIndex, __list)

        table.insert(pageList, page)
    end

    __doInherit(inheritRole, pageList)
end

--@desc: 经脉印记重筑
--@author:Seven
--@time:2025-01-20 14:14:59
--@role: 需要重筑经脉印记的角色
--@keepImpritingList: { {imprId , imprId},{imprId,imprId} }
function MeridianHelper:doRebuildMeridian(role, keepImpritingList)
    --@RefType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
    local sys = role:getMeridianSystem()

    local count = sys:getMeridianImprintingPageCount()

    local keepPageCount = #keepImpritingList

    if keepPageCount > count then
        error("MeridianHelper:doRebuildMeridian 保留的页数大于已开放的页数")
    end

    local isSameCount = true
    local everyPageCount = -1
    for i, v in ipairs(keepImpritingList) do
        if everyPageCount == -1 then
            everyPageCount = #v
        else
            if everyPageCount ~= #v then
                isSameCount = false
                break
            end
        end
    end

    if not isSameCount then
        error("MeridianHelper:doRebuildMeridian 每页保留印记数量不一致")
    end

    sys:resetMeridianImpritings(keepImpritingList)
end

--@desc: 排除已拥有的印记，获取所有随机的新印记列表(不包含已经拥有的印记)
--@author:Seven
--@time:2025-02-20 16:44:09
--@meridianSys: [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
--@return:
function MeridianHelper:getAllRandomNewImprintList(meridianSys)
    local list = {}

    local role = meridianSys:getRole()

    local inheritCount = role:getAttr("inheritCount")

    local roleAllImprList = meridianSys:getAllMeridianImprintings()

    local allImprList = MeridianResources:getAllMeridianImprintingRes()

    --对比两个列表，根据getImprintingId()来判断是否相同，把roleAllImprList中有的从allImprList的筛选中排除，重新生成一个随机列表
    for _, impr in ipairs(allImprList) do
        --@RefType [src.app.models.Meridian.MeridianImprintingRes#MeridianImprintingRes]
        impr = impr
        local isExist = false
        for _, roleImpr in ipairs(roleAllImprList) do
            if impr:getImprintingId() == roleImpr:getImprintingId() then
                isExist = true
                break
            end
        end

        if not isExist and impr:getPeiyuan() == 1 and impr:getInherit() <= inheritCount then
            table.insert(list, impr)
        end
    end

    return list
end

--@desc: 在未拥有的印记中随机一个印记ID（不包含已经拥有的印记）
--@author:Seven
--@time:2025-02-20 16:29:28
--@meridianSys: [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
--@return:
function MeridianHelper:getAllRandomNewImprintId(meridianSys)
    local randomList = self:getAllRandomNewImprintList(meridianSys)

    if #randomList == 0 then
        return nil
    end

    local weightList = {}
    for i, impr in ipairs(randomList) do
        --@RefType [src.app.models.Meridian.MeridianImprintingRes#MeridianImprintingRes]
        impr = impr
        local imprId = impr:getImprintingId()
        local weight = impr:getProbability()

        table.insert(weightList, weight)
    end

    local index = Helper:RandomByWeight(weightList)

    local imprId = randomList[index]:getImprintingId()

    return imprId
end

return MeridianHelper
00000000
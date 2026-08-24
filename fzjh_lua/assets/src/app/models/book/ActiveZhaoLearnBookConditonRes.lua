--[[
    author:Seven
    time:2025-09-05 14:03:47
    desc: 对应res\script\book\bookSkills.lua中的activeZhao数据类
]]
local res_data = require("script.book.bookSkills")["activeZhao"]

local newClass = require("third.class.NewClass")

local lru = require("third.cache.lru")

local ActiveZhaoLearnBookConditonRes = {}

local __cache = lru.new(30)
function ActiveZhaoLearnBookConditonRes.getBookLearnConditionRes(skillId)
    assert(skillId ~= nil and skillId ~= "", "ActiveZhaoLearnBookConditonRes.getBookLearnConditionRes() - skillId 不能为空")
    local res = __cache:get(skillId)
    if res == nil then
        res = ActiveZhaoLearnBookConditonRes:create(skillId)
        __cache:set(skillId, res)
    end
    return res
end

--@author:Seven
--@time:2025-09-05 14:05:34
--@skillId: 武学ID
function ActiveZhaoLearnBookConditonRes:create(skillId)
    return ActiveZhaoLearnBookConditonRes.new():__init(skillId)
end

function ActiveZhaoLearnBookConditonRes:__init(skillId)
    self.__res = res_data[skillId]

    if not self.__res then
        error('配置表：bookSkills["activeZhao"] ActiveZhaoLearnBookConditonRes:__init() - 没有找到武学对应的学习残页配置:' .. tostring(skillId))
    end

    return self
end

function ActiveZhaoLearnBookConditonRes:getId()
    return self.__res.id
end

function ActiveZhaoLearnBookConditonRes:getName()
    return self.__res.name
end

function ActiveZhaoLearnBookConditonRes:getAllTypes()
    if self.__allTypes ~= nil then
        return self.__allTypes
    end

    self.__allTypes = {}

    for i = 1, 10 do
        local type = self.__res["type" .. i]
        if type and type ~= "" then
            table.insert(self.__allTypes, type)
        end
    end
end

local Page = {
    __pageItemId = nil,
    __pageNeedCount = nil
}

function Page:create(pageItemId, pageNeedCount)
    local newObj = setmetatable({}, {__index = Page})

    assert(pageItemId ~= nil, "pageItemId 不能为空")
    assert(pageNeedCount ~= nil and type(pageNeedCount) == "number", "pageNeedCount 不能为空且必须是数字")
    newObj.__pageItemId = pageItemId
    newObj.__pageNeedCount = pageNeedCount

    return newObj
end

--@desc: 所需残页ID
--@author:Seven
--@time:2025-09-05 14:32:09
--@return: 残页ID
function Page:getPageItemId()
    return self.__pageItemId
end

--@desc: 获取所需残页数量
--@author:Seven
--@time:2025-09-05 14:31:24
--@return: 所需残页数量
function Page:getPageNeedCount()
    return self.__pageNeedCount
end

function ActiveZhaoLearnBookConditonRes:getAllPages()
    if self.__allPages ~= nil then
        return self.__allPages
    end

    self.__allPages = {}

    for i = 1, 10 do
        local pageName = self.__res["pageName" .. i]
        local pageCount = self.__res["pageCount" .. i]
        if pageName and pageName ~= "" and pageCount and pageCount > 0 then
            local page = Page:create(pageName, pageCount)
            table.insert(self.__allPages, page)
        end
    end

    return self.__allPages
end

return newClass("ActiveZhaoLearnBookConditonRes", {}, ActiveZhaoLearnBookConditonRes)
0000000000000000
local classifyRes = require("script.newbattle.demo.skillClassify")["武学类型"]

local SkillConst = require("app.models.skill.SkillConst")

local SkillClassifyManager = {}

local FIRST_CLASSIFY_NAME_DICT = {}

local SECOND_CLASSIFY_NAME_DICT = {}

local THIRD_CLASSIFY_NAME_DICT = {}

--@desc 一级分类索引
local FIRST_CLASSIFY_RES = {}

--@desc 二级分类索引
local SECOND_CLASSIFY_RES = {}

--@desc 三级分类索引 （该级别类型唯一）
local THIRD_CLASSIFY_RES = {}

local function __addFirstClassify(firstType, res)
    if FIRST_CLASSIFY_RES[firstType] == nil then
        FIRST_CLASSIFY_RES[firstType] = {}
    end

    table.insert(FIRST_CLASSIFY_RES[firstType], res)
end

local function __addSecondClassify(secType, res)
    if SECOND_CLASSIFY_RES[secType] == nil then
        SECOND_CLASSIFY_RES[secType] = {}
    end

    table.insert(SECOND_CLASSIFY_RES[secType], res)
end

local function __addThirdClassify(thirType, res)
    if THIRD_CLASSIFY_RES[thirType] ~= nil then
        assert(false, "武功分类管理 id：" .. res.id .. "的武学三类型有重复，请检查")
    end

    THIRD_CLASSIFY_RES[thirType] = res
end

local function __sortFirstType()
    for firstType, firstClassify in pairs(FIRST_CLASSIFY_RES) do
        table.sort(
            firstClassify,
            function(a, b)
                return a.id < b.id
            end
        )
    end
end

local function __sortSecondType()
    for secondType, secondClassify in pairs(SECOND_CLASSIFY_RES) do
        table.sort(
            secondClassify,
            function(a, b)
                return a.id < b.id
            end
        )
    end
end

local function __initNameDict(res)
    FIRST_CLASSIFY_NAME_DICT[tostring(res.firstType)] = res.firstTypeName
    SECOND_CLASSIFY_NAME_DICT[tostring(res.secondType)] = res.secondTypeName
    THIRD_CLASSIFY_NAME_DICT[tostring(res.thirdType)] = res.thirdTypeName
end

local function initClassifyRes()
    for id, v in pairs(classifyRes) do
        __addFirstClassify(v.firstType, v)
        __addSecondClassify(v.secondType, v)
        __addThirdClassify(v.thirdType, v)

        __initNameDict(v)
    end

    __sortFirstType()
    __sortSecondType()
end

initClassifyRes()

--@desc: 获取分类信息
--@author:Seven
--@time:2021-06-24 14:45:52
--@id: 分类id
function SkillClassifyManager:getClassifyInfo(id)
    return classifyRes[id]
end

--@desc: 根据id获取对应的武学第一类型
--@author:Seven
--@time:2021-06-24 14:47:53
--@id: 分类id
function SkillClassifyManager:getClassifyFirstType(id)
    local classifyInfo = self:getClassifyInfo(id)

    if classifyInfo == nil then
        return nil
    end

    return classifyInfo.firstType
end

function SkillClassifyManager:getClassifySecondType(id)
    local classifyInfo = self:getClassifyInfo(id)

    if classifyInfo == nil then
        return nil
    end

    return classifyInfo.secondType
end

function SkillClassifyManager:getClassifyThirdType(id)
    local classifyInfo = self:getClassifyInfo(id)

    if classifyInfo == nil then
        return nil
    end

    return classifyInfo.thirdType
end

--@desc: 获取可准备武学的基本武学id
--@author:Seven
--@time:2021-06-24 14:33:23
--@secType: 武学二类型
--@return 基本武学id
function SkillClassifyManager:getBaseSkillIdBySecondType(secType)
    local res = SECOND_CLASSIFY_RES[secType]
    if res == nil then
        assert(false, "SkillClassifyManager:getBaseSkillIdBySecondType 获取基本武学id ，武学类型二参数错误：" .. tostring(secType))
    end

    return res[1].baseSkill
end

function SkillClassifyManager:getFirstTypeBySecondType(secType)
    local res = SECOND_CLASSIFY_RES[secType]
    if res == nil then
        assert(false, "SkillClassifyManager:getFirstTypeBySecondType 根据武学类型二获取武学类型一，武学类型二参数错误：" .. tostring(secType))
    end

    return res[1].firstType
end

function SkillClassifyManager:isAttackSkllTypeByFirstType(firstType)
    return firstType == SkillConst.SkillFirstType.QUAN_JIAO or self:isBingQiSkllTypeByFirstType(firstType)
end

function SkillClassifyManager:isBingQiSkllTypeByFirstType(firstType)
    return firstType == SkillConst.SkillFirstType.BING_QI
end

--@desc: 根据武学二类型转换成旧武学的metho属性
--@author:Seven
--@time:2022-09-23 15:30:58
--@secondType: 武学二类型
function SkillClassifyManager:getOldMethodTransFromClassifySecondType(secondType)
    local transList = {
        [SkillConst.SkillSecondType.QUAN_JIAO] = 1,
        [SkillConst.SkillSecondType.NEI_GONG] = 2,
        [SkillConst.SkillSecondType.QING_GONG] = 3,
        [SkillConst.SkillSecondType.ZHAO_JIA] = 4,
        [SkillConst.SkillSecondType.JIAN_FA] = 5,
        [SkillConst.SkillSecondType.DAO_FA] = 6,
        [SkillConst.SkillSecondType.GUN_FA] = 7,
        [SkillConst.SkillSecondType.AN_QI] = 8,
        [SkillConst.SkillSecondType.BIAN_FA] = 9,
        [SkillConst.SkillSecondType.SHUANG_CHI] = 10,
        [SkillConst.SkillSecondType.QIN_FA] = 11
    }

    return assert(transList[secondType], "没有武学类型二转换数据 secondType = " .. secondType)
end

--根据新武学的类型一装换成以前主动技能表methods字段
function SkillClassifyManager:getActiveMethodsByNewSkillFirstType(firstType)
    local SkillConst = require("app.models.skill.SkillConst")

    local activeMethods =
        switch(
        tonumber(firstType),
        {
            [SkillConst.SkillFirstType.QUAN_JIAO] = 1,
            [SkillConst.SkillFirstType.BING_QI] = 5,
            [SkillConst.SkillFirstType.NEI_GONG] = 2,
            [SkillConst.SkillFirstType.QING_GONG] = 3,
            [SkillConst.SkillFirstType.ZHAO_JIA] = 4
        }
    )
    return assert(activeMethods, "武学类型一没有对应的主动招式类型 firstType = " .. firstType)
end

function SkillClassifyManager:getFirstTypeName(skill_first_type)
    local name = FIRST_CLASSIFY_NAME_DICT[tostring(skill_first_type)]

    if name == nil then
        assert(false, "武学第一类型：" .. skill_first_type .. " 没有对应名字！！")
    end

    return name
end

function SkillClassifyManager:getSecondTypeName(skill_second_type)
    local name = SECOND_CLASSIFY_NAME_DICT[tostring(skill_second_type)]

    if name == nil then
        assert(false, "武学第二类型：" .. skill_second_type .. " 没有对应名字！！")
    end

    return name
end

function SkillClassifyManager:getThirdTypeName(skill_third_type)
    local name = THIRD_CLASSIFY_NAME_DICT[tostring(skill_third_type)]

    if name == nil then
        assert(false, "武学第三类型：" .. skill_third_type .. " 没有对应名字！！")
    end

    return name
end

function SkillClassifyManager:getAllSecondTypesByFirstType(firstType)
    local list = {}

    for f_type, resList in pairs(FIRST_CLASSIFY_RES) do
        if f_type == tonumber(firstType) then
            for _, res in ipairs(resList) do
                table.insert(list, res.secondType)
            end
        end
    end

    return list
end

local SkillConst = require("app.models.skill.SkillConst")
function SkillClassifyManager:getQuanJiaoSkillClassifyTypes()
    local list = {}

    for f_type, resList in pairs(FIRST_CLASSIFY_RES) do
        if f_type == tonumber(SkillConst.SkillFirstType.QUAN_JIAO) then
            for _, res in ipairs(resList) do
                table.insert(list, res.id)
            end
        end
    end

    return list
end

--@desc: 获取所有武学一类型列表
--@author:Seven
--@time:2022-09-19 14:21:25
--@return: [type1,type2,type3]
function SkillClassifyManager:getFirstTypes()
    local list = {}

    for f_type, _ in pairs(FIRST_CLASSIFY_RES) do
        table.insert(list, f_type)
    end

    table.sort(
        list,
        function(a, b)
            return tonumber(a) < tonumber(b)
        end
    )

    return list
end

function SkillClassifyManager:getSecondTypes()
    local list = {}

    for s_type, _ in pairs(SECOND_CLASSIFY_RES) do
        table.insert(list, s_type)
    end

    table.sort(
        list,
        function(a, b)
            return tonumber(a) < tonumber(b)
        end
    )

    return list
end

function SkillClassifyManager:getOldActiveMethodBySecondTypeName(secondTypeName)
    if not secondTypeName then
        assert(false, "SkillClassifyManager:getOldActiveMethodBySecondTypeName 参数为空")
    end

    for k, v in pairs(classifyRes) do
        if secondTypeName == v.secondTypeName then
            return self:getActiveMethodsByNewSkillFirstType(v.firstType)
        end
    end

    assert(false, "未找到该类型: "..secondTypeName)
end


function SkillClassifyManager:getBingQiPrepareTypeBySecondType(secondType)
    local transList = {
        [SkillConst.SkillSecondType.JIAN_FA] = "jianfa",
        [SkillConst.SkillSecondType.DAO_FA] ="daofa",
        [SkillConst.SkillSecondType.GUN_FA] = "gunfa",
        [SkillConst.SkillSecondType.AN_QI] = "anqi",
        [SkillConst.SkillSecondType.BIAN_FA] = "bianfa",
        [SkillConst.SkillSecondType.SHUANG_CHI] = "shuangchi",
        [SkillConst.SkillSecondType.QIN_FA] = "qinfa"
    }

    return assert(transList[secondType], "没有兵器武学类型二准备数据 secondType = " .. secondType)
end

return SkillClassifyManager
000000000000000
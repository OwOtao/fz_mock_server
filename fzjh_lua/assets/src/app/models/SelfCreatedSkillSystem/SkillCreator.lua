local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local ZhaoCreator = require("app.models.SelfCreatedSkillSystem.ZhaoCreator")
local newClass = require("third.class.NewClass")

local SkillCreator = {
    __id = nil,
    __name = "无名武学",
    __outputType = 1,  --1服务器自创，2历练副本配置
    __templateId = nil,--武学模板id
    __prop = nil, --使用的武学创作道具
    __unlocks = {},
    __zhaoCreator = {},
}

function SkillCreator:create(data)
    local p = SkillCreator.new()
    p:initialize(data)
    return p
end

function SkillCreator:initialize(data)
    if type(data) ~= "table" or MapIsEmpty(data) then
        return
    end

    self:setSkillId(data.id)
    self:setTemplateId(data.templateId)
    self:setZhaoCreator(data.zhaos)
    self:setPropId(data.prop)
    self:setOutputType(data.outputType)
    self:setUnlocks(data.unlocks)
end

function SkillCreator:deserializable()
end

function SkillCreator:getSkillCreatorData()
    return {
        id = self:getSkillId(),
        name = self.__name,
        templateId = self:getTemplateId(),
        zhaos = self:getZhaoDataList(),
        prop = self:getPropId(),
        outputType = self:getOutputType(),
        unlocks = self:getUnlocks()
    }
end

-- @desc 技能一级类型列表
function SkillCreator:getSkillFirstTypeList()
    local firstSkillTypeList = {
        {
            name = "拳脚",
            type = SelfCreatedSkillConstants.SkillFirstType.QUAN_JIAO
        },
        {
            name = "兵器",
            type = SelfCreatedSkillConstants.SkillFirstType.BING_QI
        },
        -- {
        --     name = "内功",
        --     type = SelfCreatedSkillConstants.SkillFirstType.NEI_GONG
        -- },
        -- {
        --     name = "轻功",
        --     type = SelfCreatedSkillConstants.SkillFirstType.QING_GONG
        -- },
    }
    return firstSkillTypeList
end

-- @desc 获得技能二级类型列表
function SkillCreator:getSkillThirdTypeListByFirstTypeName(firstTypeName)
    local secondSkillTypeNamesMap = {
        ["拳脚"] = {
            {
                name = "拳法",
                type = SelfCreatedSkillConstants.SkillThirdType.QUAN_FA
            },
            {
                name = "掌法",
                type = SelfCreatedSkillConstants.SkillThirdType.ZHANG_FA
            },
            {
                name = "爪法",
                type = SelfCreatedSkillConstants.SkillThirdType.ZHUA_FA
            },
            {
                name = "指法",
                type = SelfCreatedSkillConstants.SkillThirdType.ZHI_FA
            },
            {
                name = "腿法",
                type = SelfCreatedSkillConstants.SkillThirdType.TUI_FA
            }
        },
        ["兵器"] = {
            {
                name = "剑法",
                type = SelfCreatedSkillConstants.SkillThirdType.JIAN_FA
            },
            {
                name = "刀法",
                type = SelfCreatedSkillConstants.SkillThirdType.DAO_FA
            },
            {
                name = "棍法",
                type = SelfCreatedSkillConstants.SkillThirdType.GUN_FA
            },
            {
                name = "鞭法",
                type = SelfCreatedSkillConstants.SkillThirdType.BIAN_FA
            },
            {
                name = "暗器",
                type = SelfCreatedSkillConstants.SkillThirdType.AN_QI
            },
            {
                name = "双持",
                type = SelfCreatedSkillConstants.SkillThirdType.SHUANG_CHI
            },
            {
                name = "乐器",
                type = SelfCreatedSkillConstants.SkillThirdType.QIN_FA
            }
        },
        -- ["轻功"] = {
        --     {
        --         name = "轻功",
        --         type = SelfCreatedSkillConstants.SkillThirdType.QING_GONG
        --     }
        -- },
        -- ["内功"] = {
        --     {
        --         name = "内功",
        --         type = SelfCreatedSkillConstants.SkillThirdType.NEI_GONG
        --     }
        -- },
    }
    if secondSkillTypeNamesMap[firstTypeName] == nil then
        return {}
    end
    return secondSkillTypeNamesMap[firstTypeName]
end

-- @desc 设置技能模板id
function SkillCreator:setTemplateId(templateId)
    self.__templateId = templateId
end

-- @desc 获取技能模板id
function SkillCreator:getTemplateId()
    return self.__templateId
end

-- @desc 开始创建技能
function SkillCreator:creating()
    return true
end

-- @desc 完成创建武学
function SkillCreator:createComplete()
    return self:createSkill()
end

-- @desc 创建技能
function SkillCreator:createSkill()
    return self:getSkillCreatorData()
end

-- @desc 设置技能Id
function SkillCreator:setSkillId(id)
    self.__id = id
end

function SkillCreator:setPropId(prop)
    self.__prop = prop
end

function SkillCreator:getPropId()
    return self.__prop
end

function SkillCreator:setOutputType(outputType)
    self.__outputType = outputType
end

function SkillCreator:getOutputType()
    return self.__outputType
end

function SkillCreator:setUnlocks(unlocks)
    self.__unlocks = unlocks
end

function SkillCreator:getUnlocks()
    return self.__unlocks
end

-- @desc 获取技能Id
function SkillCreator:getSkillId()
    return self.__id
end

-- @desc 设置技能名字
function SkillCreator:setSkillName(name)
    self.__name = name
end

-- @desc 随机名称
function SkillCreator:createRandomName()
    local randomResult = {
        {"words1","words2"},
        {"words1","words3"},
        {"words2","words3"},
        {"words3","words1","words2"},
        {"words3"},
    }
    local result = randomResult[math.random(1,#randomResult)]
    local skillNameMap = SelfCreatedSkillManager:getSkillNameMap()

    local name = ""
    for i,v in ipairs(result) do
        name = name..skillNameMap[v][math.random(1,#skillNameMap[v])]
    end

    return name
end

-- @desc 创建招式
function SkillCreator:createZhao(data)
    local zhaoData = data.zhaos
    if zhaoData.index == 1 then
        self:initialize(data)
    end

    local zhaoCreator = ZhaoCreator:create()
    zhaoCreator:initialize(zhaoData)

    table.insert(self.__zhaoCreator,zhaoCreator)
end

-- @desc 招式数目是否到达下限
function SkillCreator:isCreateZhaoCompleted()
    local zhaoMinNum = SelfCreatedSkillManager:getParamsById("complete_all_num")   --招式数量下限
    return #self.__zhaoCreator >= zhaoMinNum
end

-- @desc 招式数目是否到达上限
function SkillCreator:isCreateZhaoUpperLimit()
    local thirdType = SelfCreatedSkillManager:getSkill(self:getTemplateId()).thirdType
    local zhaoMaxNum = SelfCreatedSkillManager:getZhaoNumUpperLimit(thirdType)
    return #self.__zhaoCreator >= zhaoMaxNum
end

--@desc  获取招式列表
function SkillCreator:getZhaoDataList()
    local zhaoDataList = {}
    for index,zhaoCreator in ipairs(self.__zhaoCreator) do
        table.insert(zhaoDataList,zhaoCreator:deserializable())
    end
    return zhaoDataList
end

--@desc 初始化招式数据
function SkillCreator:setZhaoCreator(zhaoDatas)
    if MapIsEmpty(zhaoDatas) == false then
        for index,zhaoData in ipairs(zhaoDatas) do
            local zhaoCreator = ZhaoCreator:create()
            zhaoCreator:initialize(zhaoData)
            table.insert(self.__zhaoCreator,zhaoCreator)
        end
    end 
end

function SkillCreator:getZhaoCreator(index)
    return self.__zhaoCreator[index]
end

function SkillCreator:deleteZhao(zhaoIndex)
    table.remove(self.__zhaoCreator,zhaoIndex)
end

function SkillCreator:updataZhao(zhaoIndex,newZhaoData)
    table.remove(self.__zhaoCreator,zhaoIndex)

    local zhaoCreator = ZhaoCreator:create()
    zhaoCreator:initialize(newZhaoData)
    table.insert(self.__zhaoCreator,zhaoIndex,zhaoCreator)
end                         
                   
function SkillCreator:getSucAnim()
    local thirdType = SelfCreatedSkillManager:getSkill(self:getTemplateId()).thirdType
    return switch(thirdType,{
        [SelfCreatedSkillConstants.SkillThirdType.JIAN_FA] = "jianfa_chenggong",
        [SelfCreatedSkillConstants.SkillThirdType.DAO_FA] = "daofa_chenggong",
        [SelfCreatedSkillConstants.SkillThirdType.GUN_FA] = "gunfa_chenggong",
        [SelfCreatedSkillConstants.SkillThirdType.BIAN_FA] = "bianfa_chenggong",
        [SelfCreatedSkillConstants.SkillThirdType.AN_QI] = "anqi_chenggong",
        [SelfCreatedSkillConstants.SkillThirdType.SHUANG_CHI] = "shuangchi_chenggong",
        [SelfCreatedSkillConstants.SkillThirdType.QIN_FA] = "qinfa_chenggong",
        default = "quanjiao_chenggong",
    })
end

function SkillCreator:getDefAnim()
    local thirdType = SelfCreatedSkillManager:getSkill(self:getTemplateId()).thirdType
    return switch(thirdType,{
        [SelfCreatedSkillConstants.SkillThirdType.JIAN_FA] = "jianfa_shibai",
        [SelfCreatedSkillConstants.SkillThirdType.DAO_FA] = "daofa_shibai",
        [SelfCreatedSkillConstants.SkillThirdType.GUN_FA] = "gunfa_shibai",
        [SelfCreatedSkillConstants.SkillThirdType.BIAN_FA] = "bianfa_shibai",
        [SelfCreatedSkillConstants.SkillThirdType.AN_QI] = "anqi_shibai",
        [SelfCreatedSkillConstants.SkillThirdType.SHUANG_CHI] = "shuangchi_shibai",
        [SelfCreatedSkillConstants.SkillThirdType.QIN_FA] = "qinfa_shibai",
        default = "quanjiao_shibai",
    })
end
return newClass("SkillCreator", {}, SkillCreator)
0000
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")

local SelfCreatedSkillManager = {
    _zhaoMap = {
        ["1"] = {
            id = 1,
            name = "招式1"
        },
        ["2"] = {
            id = 1,
            name = "招式2"
        }
    },
}

local function loadZhaoMap()
    local zhaoTemplate = require("script.selfCreatedSkill.zhaoTemplates")["招式"]

    local zhaoMap = {}
    local LiLianZhaoArray = {}
    for zhaoId, zhaoData in pairs(zhaoTemplate) do
        zhaoMap[zhaoId] = zhaoData

        if zhaoData.outputType == SelfCreatedSkillConstants.ZhaoOutputType.LILIANMAP_CREATE then
            table.insert(LiLianZhaoArray,zhaoData)
        end
    end

    SelfCreatedSkillManager._zhaoMap = zhaoMap
    SelfCreatedSkillManager._liLianZhaoArray = LiLianZhaoArray
end

local function loadZhaoDscMap()
    local ZhaoText = require("script.selfCreatedSkill.zhaosText")
    local ZhaoDscMap = ZhaoText["文本内容"]
    local ZhaoDscXiLieMap = ZhaoText["系列"]

    SelfCreatedSkillManager._zhaoDscMap = ZhaoDscMap
    SelfCreatedSkillManager._zhaoDscXiLieMap = ZhaoDscXiLieMap
end

local function loadZhaoAffix()
    local ZhaoAffix = require("script.selfCreatedSkill.zhaosTrait")["新版招式特性"]

    SelfCreatedSkillManager._zhaoAffixMap = ZhaoAffix
end

local function loadZhaoColor()
    local ZhaoColorMap = require("script.selfCreatedSkill.zhaoColors")["颜色表"]

    SelfCreatedSkillManager._zhaoColorMap = ZhaoColorMap
end

local function loadSkillNameAfterAffix()
    local SkillAfterAffixMap = require("script.selfCreatedSkill.skillAfterAffix")["后缀内容"]

    SelfCreatedSkillManager._skillNameAfterAffixMap = SkillAfterAffixMap
end

local function loadSkillMap()
    local SkillMap = require("script.selfCreatedSkill.skillTemplates")["skills"]

    SelfCreatedSkillManager._skillMap = SkillMap
end

local function loadNameMap()
    local ZhaoNameRes = require("script.selfCreatedSkill.nameLibrary")["招式"]
    local SkillNameRes = require("script.selfCreatedSkill.nameLibrary")["武学"]
    local ZhaoNameMap = {
        words1 = {},
        words2 = {},
        words3 = {},
        words4 = {},
    }
    local SkillNameMap = {
        words1 = {},
        words2 = {},
        words3 = {},
        words4 = {},
    }

    for k,v in pairs(ZhaoNameRes) do
        table.insert(ZhaoNameMap["words1"],v.words1)
        table.insert(ZhaoNameMap["words2"],v.words2)
        table.insert(ZhaoNameMap["words3"],v.words3)
    end

    for k,v in pairs(SkillNameRes) do
        table.insert(SkillNameMap["words1"],v.words1)
        table.insert(SkillNameMap["words2"],v.words2)
        table.insert(SkillNameMap["words3"],v.words3)
        table.insert(SkillNameMap["words4"],v.words4)
    end

    SelfCreatedSkillManager._zhaoNameMap = ZhaoNameMap
    SelfCreatedSkillManager._skillNameMap = SkillNameMap
end

local function loadParams()
    local ParamsRes = require("script.selfCreatedSkill.params")["通用参数"]

    SelfCreatedSkillManager._paramsMap = ParamsRes
    
    do
        local template_addOrder = SelfCreatedSkillManager._paramsMap["template_addOrder"].param
        local Orders = {}
        local addOrders = string.split(template_addOrder,"|")
        for i,v in ipairs(addOrders) do
            local addOrder = string.split(v,"#")
            table.insert(Orders,{min = tonumber(addOrder[1]),max = tonumber(addOrder[2]),value = tonumber(addOrder[3])})
        end

        local retOrders = {}
        for index,order in ipairs(Orders) do
            local min = Helper:getRange(order.min,1,99)
            local max = Helper:getRange(order.max,1,99)
            local value = order.value
            for i = min,max do
                table.insert(retOrders,value)
            end
        end
        
        SelfCreatedSkillManager._addOrders= retOrders
    end

    do
        local creat_zhao_numMax = SelfCreatedSkillManager._paramsMap["creat_zhao_numMax"].param
        local retMaxTab = {}
        local maxS = string.split(creat_zhao_numMax,"|")
        for i,v in ipairs(maxS) do
            local maxList = string.split(v,"#")
            retMaxTab[tostring(maxList[1])] = tonumber(maxList[2])
        end
        
        SelfCreatedSkillManager._zhaoMaxMap = retMaxTab
    end
end

local function loadConsumeResRate()
    local ConsumeResRate = require("script.selfCreatedSkill.createZhaoConsumeResRate")["等级资源消耗系数"]

    SelfCreatedSkillManager._consumeLvRate = ConsumeResRate
end

local function loadConsumeZhaoRate()
    local retMap = {}
    local ConsumeZhaoRate = require("script.selfCreatedSkill.createZhaoConsumeZhaoRate")["招式消耗系数"]
    for i,v in pairs(ConsumeZhaoRate) do
        retMap[tostring(v.zsNum)] = v
    end
    SelfCreatedSkillManager._consumeZhaoRate = retMap
end

local function loadPropMap()
    local PropMap = require("script.selfCreatedSkill.propMap")["Sheet1"]

    SelfCreatedSkillManager._propMap = PropMap
end

local function loadLiLianMapRes()
    local LiLianAffaixMap = require("script.selfCreatedSkill.liLianTaskZhaos")["词缀规则"]
    local LiLianZhaoRuleMap = require("script.selfCreatedSkill.liLianTaskZhaos")["招式规则"]

    local retLiLianRandomAffaixMap = {}
    for i,v in pairs(LiLianAffaixMap) do
        if v.isRandom == 1 then
            table.insert( retLiLianRandomAffaixMap,v)
        end
    end
    SelfCreatedSkillManager._liLianRandomAffaixMap = retLiLianRandomAffaixMap
    SelfCreatedSkillManager._liLianAffaixMap = LiLianAffaixMap
    SelfCreatedSkillManager._liLianZhaoRuleMap = LiLianZhaoRuleMap
end

local function loadSelfAutoZhaoInfo()
    local selfAutoZhaoInfo = require("script.selfCreatedSkill.selfAutoZhaoInfo")["自创招式模板被动招式"]
    
    SelfCreatedSkillManager._selfAutoZhaoInfo = selfAutoZhaoInfo
end 

loadZhaoMap()
loadZhaoDscMap()
loadZhaoAffix()
loadSkillMap()
loadZhaoColor()
loadSkillNameAfterAffix()
loadNameMap()
loadParams()
loadConsumeResRate()
loadConsumeZhaoRate()
loadPropMap()
loadLiLianMapRes()
loadSelfAutoZhaoInfo()

function SelfCreatedSkillManager:getZhaoMap()
    return self._zhaoMap
end

function SelfCreatedSkillManager:getSkillMap()
    return self._skillMap
end

function SelfCreatedSkillManager:getZhaoAffixMap()
    return self._zhaoAffixMap
end

function SelfCreatedSkillManager:getSkillNameAfterAffixMap(nameAffixId)
    return self._skillNameAfterAffixMap[tostring(nameAffixId)]
end

function SelfCreatedSkillManager:getZhaoColorMap(colorId)
    return self._zhaoColorMap[tostring(colorId)]
end

function SelfCreatedSkillManager:getZhaoDescByActionId(actionId)
    return self._zhaoDscMap[tostring(actionId)].action
end

function SelfCreatedSkillManager:getZhaoDscXiLieMap(dscXiLieId)
    return self._zhaoDscXiLieMap[tostring(dscXiLieId)]
end

function SelfCreatedSkillManager:getParamsById(id)
    return self._paramsMap[tostring(id)].param
end

function SelfCreatedSkillManager:getZhaoAddOrders()
    return self._addOrders
end

function SelfCreatedSkillManager:getZhaoNumUpperLimit(thirdType)
    return self._zhaoMaxMap[tostring(thirdType)]
end

function SelfCreatedSkillManager:getPropMap(propId)
    return self._propMap[tostring(propId)]
end

function SelfCreatedSkillManager:getLiLianZhaoRuleMap(id)
    return self._liLianZhaoRuleMap[tostring(id)]
end

function SelfCreatedSkillManager:getLiLianRandomAffaixArray()
    return self._liLianRandomAffaixMap
end

function SelfCreatedSkillManager:getLiLianAffaixMap(id)
    return assert(self._liLianAffaixMap[id], "历练任务招式模板表没有该词缀 : " .. id)
end

function SelfCreatedSkillManager:getConsumeLvRateMap(roleLv)
    for k,v in pairs(self._consumeLvRate) do
        if roleLv <= v.roleLvMax and roleLv >= v.roleLvMin then
            return v
        end
    end
    assert(nil,"等级有误  roleLv"..roleLv)
end

function SelfCreatedSkillManager:getConsumeZhaoRateMap(zhaoNum)
    return self._consumeZhaoRate[tostring(zhaoNum)]
end

function SelfCreatedSkillManager:getSkillNameMap()
    return self._skillNameMap
end

function SelfCreatedSkillManager:getZhaoNameMap()
    return self._zhaoNameMap
end

function SelfCreatedSkillManager:getUnsignedZhaoDescByActionId(actionId,zhao)
    local zhaoType = zhao:getType()
    local text = self:getZhaoDescByActionId(actionId)
    if string.find(text,"$N") then
        text = string.gsub(text, "$N", "你")
    end

    if string.find(text,"$n") then
        text = string.gsub(text, "$n", "对方")
    end

    if string.find(text,"$l") then
        text = string.gsub(text, "$l", zhao:getHitPosName(zhao:getHitPos1()))
    end

    if string.find(text,"$w") then
        local weaponName = switch(zhaoType,{
            [SelfCreatedSkillConstants.SkillThirdType.JIAN_FA] = "宝剑",
            [SelfCreatedSkillConstants.SkillThirdType.DAO_FA] = "宝刀",
            [SelfCreatedSkillConstants.SkillThirdType.GUN_FA] = "棍子",
            [SelfCreatedSkillConstants.SkillThirdType.BIAN_FA] = "鞭子",
            [SelfCreatedSkillConstants.SkillThirdType.AN_QI] = "暗器",
            [SelfCreatedSkillConstants.SkillThirdType.SHUANG_CHI] = "兵刃",
            [SelfCreatedSkillConstants.SkillThirdType.QIN_FA] = "乐器",
            ["default"] = "武器"
        })
        text = string.gsub(text, "$w", weaponName)
    end

    if string.find(text,"$M") then
        text = string.gsub(text, "$M", zhao:getName())
    end

    return text
end

function SelfCreatedSkillManager:getSkill(id)
    return inherit({}, self:getSkillMap()[tostring(id)])
end

function SelfCreatedSkillManager:getZhao(id)
    return inherit({}, self:getZhaoMap()[tostring(id)])
end

function SelfCreatedSkillManager:getZhaoAffix(id)
    return inherit({}, self:getZhaoAffixMap()[tostring(id)])
end

function SelfCreatedSkillManager:getLiLianZhaoArray()
    return self._liLianZhaoArray
end


local Trie = require("third.tree.Trie")
local skillNameMaskOffTrie = Trie:create()

local function initSelfCreatedSkillMaskWords()
    local MaskWordsConfig = require("app.models.Const.MaskWordsConfig")
    local skillNameMaskWords = MaskWordsConfig:getSelfCreateSkillMaskWords()
    if MapIsEmpty(skillNameMaskWords) == false then
        for i, v in ipairs(skillNameMaskWords) do
            skillNameMaskOffTrie:add(v)
        end
    end
end

initSelfCreatedSkillMaskWords()

function SelfCreatedSkillManager:checkIsMaskWords(skillName)
    local index, word = skillNameMaskOffTrie:findInStr(skillName)
    return index > 0, word
end

function SelfCreatedSkillManager:getSelfAutoZhaoInfoById(id)
    return assert(self._selfAutoZhaoInfo[tostring(id)], "招式模板新版被动招式没有这个id : " .. id)
end

return SelfCreatedSkillManager00000
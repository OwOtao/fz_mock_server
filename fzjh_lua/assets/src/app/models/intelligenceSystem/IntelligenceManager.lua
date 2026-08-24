local NewClass = require("third.class.NewClass")
local IntelligenceResManager = require("app.models.intelligenceSystem.IntelligenceResManager")
local IntelligenceConstants = require("app.models.intelligenceSystem.IntelligenceConstants")
local log = function(...)
    if DEBUG_MODE == 1 then
        print(...)
    end
end
local IntelligenceManager = {
    _bought_intelligence_list = {},
    _bought_technique_list = {},
    _activity_intelligenceArray = {},
    _plot_intelligenceArray = {},
    _technique_intelligenceMap = {},
}

function IntelligenceManager:create(system)
    local p = IntelligenceManager.new()
    p:init(system)
    return p
end

function IntelligenceManager:init(system)
    self._system = system
end

function IntelligenceManager:initIntelligenceData(data)
    for i,id in ipairs(data.bought_intelligence_list) do
        self._bought_intelligence_list[tostring(id)] = true
    end
    for i,id in ipairs(data.bought_technique_list) do
        self._bought_technique_list[tostring(id)] = true
    end
    self._activity_intelligenceArray = self:_get_activity_intelligenceArray()
    self._plot_intelligenceArray = self:_get_plot_intelligenceArray()
    self._technique_intelligenceMap = self:_get_technique_intelligenceMap()
end

--@desc 创建情报列表
function IntelligenceManager:_createIntelligenceList(activity_num,plot_num)
    local retList = {}
    local _activity_intelligenceArray = clone(self._activity_intelligenceArray)
    local _plot_intelligenceArray = clone(self._plot_intelligenceArray)
    if #_activity_intelligenceArray < activity_num then
        assert(nil,"活动类情报不足")
    end
    if #_plot_intelligenceArray < plot_num then
        assert(nil,"剧情类情报不足")
    end
    for i = 1,activity_num do
        local random_intelligence = table.remove(_activity_intelligenceArray,math.random(1,#_activity_intelligenceArray))
        local id = random_intelligence:getId()
        table.insert(retList,id)
    end

    for i = 1,plot_num do
        local random_intelligence = table.remove(_plot_intelligenceArray,math.random(1,#_plot_intelligenceArray))
        local id = random_intelligence:getId()
        table.insert(retList,id)
    end
    return retList
end

--@desc 创建秘辛列表（技巧类情报）
function IntelligenceManager:_create_technique_IntelligenceList(techniqueOpen)
    if techniqueOpen == IntelligenceConstants.TechniqueOpen.UnOpen then
        return {}
    end
    local retList = {}
    local _technique_intelligenceArray = {}
    for id,intelligence in pairs(self._technique_intelligenceMap) do
        table.insert(_technique_intelligenceArray,id)
    end
    if #_technique_intelligenceArray < IntelligenceConstants.Technique_num then
        assert(nil,"技巧类情报不足")
    end
    for i = 1,IntelligenceConstants.Technique_num do
        local id = table.remove(_technique_intelligenceArray,math.random(1,#_technique_intelligenceArray))
        table.insert(retList,id)
    end
    return retList
end

--@desc 生成随机情报模板
function IntelligenceManager:_createRandomMoBan()
    for id,boolean in pairs(self._bought_technique_list) do
        if self._technique_intelligenceMap[tostring(id)] then
            self._technique_intelligenceMap[tostring(id)] = nil
        end
    end
    local mobanArray = {}
    local weightArray = {}
    if MapIsEmpty(self._technique_intelligenceMap) then
        mobanArray = IntelligenceResManager:get_notTechnique_mobanArray()
    else
        mobanArray = IntelligenceResManager:get_all_mobanArray()
    end

    for i,intelligenceMoBan in ipairs(mobanArray) do
        table.insert(weightArray,intelligenceMoBan:getProbability())
    end
    return mobanArray[Helper:RandomByWeight(weightArray)]
end

function IntelligenceManager:_get_activity_intelligenceArray()
    local retArray = {}
    local intelligenceArray = IntelligenceResManager:get_activity_intelligenceArray()
    log("活动类情报数量 = ",#intelligenceArray)
    for i,intelligence in ipairs(intelligenceArray) do
        if self:_checkConIsUnlock(intelligence) then
            table.insert(retArray,intelligence)
        end
    end
    log("活动类情报 解锁数量 = ",#retArray)
    return retArray
end

function IntelligenceManager:_get_plot_intelligenceArray()
    local retArray = {}
    local intelligenceArray = IntelligenceResManager:get_plot_intelligenceArray()
    log("剧情类情报数量 = ",#intelligenceArray)
    for i,intelligence in ipairs(intelligenceArray) do
        if self:_checkConIsUnlock(intelligence) then
            table.insert(retArray,intelligence)
        end
    end
    log("剧情类情报 解锁数量 = ",#retArray)
    return retArray
end

function IntelligenceManager:_get_technique_intelligenceMap()
    local retMap = {}
    local intelligenceMap = IntelligenceResManager:get_technique_intelligenceMap()
    for id,intelligence in pairs(intelligenceMap) do
        if self:_checkConIsUnlock(intelligence) then
            retMap[id] = intelligence
        end
    end
    return retMap
end

--@desc 判断情报条件是否解锁
function IntelligenceManager:_checkConIsUnlock(intelligence)
    local function unlockResult(conType,value)
        return switch(conType,{
            [IntelligenceConstants.UnLockConType.UnCondition] = function()
                return true
            end,
            [IntelligenceConstants.UnLockConType.CompleteMap] = function()
                local mapId = value
                if Map:getMapState(value) == MAP_STATE.COMPLETE then
                    return true
                end
                return false
            end,
            [IntelligenceConstants.UnLockConType.RoleLv] = function()
                local roleLvArray = string.split(value,",")
                local role_minLv = tonumber(roleLvArray[1])
                local role_maxLv = tonumber(roleLvArray[2])
                local roleLv = User:getRole():getLv()
                if roleLv >= role_minLv and roleLv <= role_maxLv then
                    return true
                end
                return false
            end,
            [IntelligenceConstants.UnLockConType.InheritCount] = function()
                local inheritCount = User:getRole():getAttr("inheritCount")
                local inheritCountArray = string.split(value,",")
                local inheritCount_min = tonumber(inheritCountArray[1])
                local inheritCount_max = tonumber(inheritCountArray[2])
                if inheritCount >= inheritCount_min and inheritCount <= inheritCount_max then
                    return true
                end
                return false
            end,
            [IntelligenceConstants.UnLockConType.Intelligence] = function()
                local idList = string.split(tostring(value),",")
                for i,id in ipairs(idList) do
                    if self._bought_intelligence_list[id] == true then
                        return true
                    end
                    if self._bought_technique_list[id] == true then
                        return true
                    end
                end
                
                return false
            end,
            [IntelligenceConstants.UnLockConType.Family] = function()
                local roleFamily = User:getRole():getFamilyId()
                local familyArray = string.split(value,",")
                for i,family in ipairs(familyArray) do
                    if family == roleFamily then
                        return true
                    end
                end
                return false
            end,
            default = function()
                assert(nil,"未知解锁类型")
            end,
        })
    end

    local result1 = unlockResult(intelligence:getCondition1(),intelligence:getConditionArg1())
    local result2 = unlockResult(intelligence:getCondition2(),intelligence:getConditionArg2())
    local result3 = unlockResult(intelligence:getCondition3(),intelligence:getConditionArg3())

    log(intelligence:getId(),"条件1=",intelligence:getCondition1(),"参数1=",intelligence:getConditionArg1(),"解锁1",result1,
    "条件2=",intelligence:getCondition2(),"参数2=",intelligence:getConditionArg2(),"解锁2",result2,
    "条件3=",intelligence:getCondition3(),"参数3=",intelligence:getConditionArg3(),"解锁3",result3,
    "最终结果=",result1 and result2 and result3)
    
    return result1 and result2 and result3
end

--@desc 获取情报列表
function IntelligenceManager:getIntelligenceList(callback)
    HttpManagerEx:getIntelligenceData(function(status, errcode, errmsg, data)
        if status == 200 then
            -- errcode: 0 已购买，1已上传，2未上传 
            if errcode == 0 then
                if callback then
                    callback(data.intelligence_list)
                end
            elseif errcode == 1 then
                local currencyName = assert(IntelligenceConstants.CurrencyName[data.currency_type],"货币类型不存在")
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:hide()
                dialog:show("你还未购买今日的江湖情报，是否花费"..data.price..currencyName.."向徐书生购买本日江湖情报？")
                dialog:setButton1("确定",function()
                    self:buyIntelligence(data.price,data.currency_type,callback)
                end)
                dialog:setButton2("关闭",EMPTY_FUNC)
                dialog:setWeChatVisible(false)
            elseif errcode == 2 then
                --@desc 创建情报数据上传
                self:initIntelligenceData(data)
                local intelligenceMoBan = self:_createRandomMoBan()
                log("随机模板ID = ",intelligenceMoBan:getId())
                local currency_type = intelligenceMoBan:getCurrencyType()
                local price = intelligenceMoBan:getPrice()
                local activity_num = intelligenceMoBan:getActivityNum()
                local plot_num = intelligenceMoBan:getPlotNum()
                local techniqueOpen = intelligenceMoBan:getTechniqueOpen()
                local intelligence_list = self:_createIntelligenceList(activity_num,plot_num)
                local technique_list = self:_create_technique_IntelligenceList(techniqueOpen)
                local params = {
                    intelligence_list = intelligence_list,
                    technique_list = technique_list,
                    currency_type = currency_type,
                    price = price 
                }
                self:uploadIntelligenceData(params,function()
                    local currencyName = assert(IntelligenceConstants.CurrencyName[currency_type],"货币类型不存在")
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local dialog = DialogALayer:getInstance()
                    dialog:hide()
                    dialog:show("你还未购买今日的江湖情报，是否花费"..price..currencyName.."向徐书生购买本日江湖情报？")
                    dialog:setButton1("确定",function()
                        self:buyIntelligence(price,currency_type,callback)
                    end)
                    dialog:setButton2("关闭",EMPTY_FUNC)
                    dialog:setWeChatVisible(false)
                end)
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc 上传情报数据
function IntelligenceManager:uploadIntelligenceData(params,callback)
    HttpManagerEx:uploadIntelligenceData(params,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback()
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc 购买情报
function IntelligenceManager:buyIntelligence(price,currency_type,callback)
    if currency_type == IntelligenceConstants.CurrencyType.Suiyin then
        local role = User:getRole()
        if role:getAttr("money") < price then
            PopText("购买失败，你的碎银不足")
            return
        end
    end

    HttpManagerEx:buyIntelligence(function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if data.currency_type == IntelligenceConstants.CurrencyType.Suiyin then
                    local role = User:getRole()
                    role:addAttr("money",-data.remove_price)
                end
                PopText("")
                PopText("购买成功")
                PopText("消耗"..data.remove_price..IntelligenceConstants.CurrencyName[data.currency_type])

                do      --添加购买情报记录点
                    local record = AchievementSystem:getRecordById(5010)
                    AchievementSystem:add(record)
                end
                
                if callback then
                    callback(data.intelligence_list)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc 获取技巧类情报
function IntelligenceManager:getTechniqueList(callback)
    HttpManagerEx:getTechniqueList(function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback(data.technique_list)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc 阅读情报
function IntelligenceManager:readIntelligence(intelligence_id,intelligence_type,callback)
    HttpManagerEx:readIntelligence(intelligence_id,intelligence_type,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if callback then
                    callback()
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

return NewClass("IntelligenceManager", {}, IntelligenceManager)
0000000000000
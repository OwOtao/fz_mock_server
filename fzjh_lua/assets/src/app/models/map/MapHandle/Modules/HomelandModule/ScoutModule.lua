-- 情报人员模块
local ScoutModule = class("ScoutModule", require("app.models.map.MapHandle.Modules.BaseModule"))
local IntelligenceSystem = require("app.models.intelligenceSystem.IntelligenceSystem"):create()

--@desc 条件结果的方法
ScoutModule.doResult = {
    ["情报探子交谈"] = function(map, result, environment)
        IntelligenceSystem:talk(environment.currRole)
    end,
    ["购买江湖情报"] = function(map, result, environment)
        -- arg2:购买价格
        -- arg3:货币单位
        -- arg4:购买的情报列表
        -- arg5:购买的秘辛列表
        -- arg6:购买成功执行的结果集
        local price = result.arg2
        local currency_type = result.arg3
        local intelligenceIdStr = result.arg4
        local techniqueIdStrs = result.arg5
        local buy_resultsStrs = result.arg6
        if DEBUG_MODE == 1 then
            print("---购买江湖情报---")
            print("价格：",price)
            print("货币单位",currency_type)
            print("购买的情报列表",intelligenceIdStr)
            print("购买的秘辛列表",techniqueIdStrs)
            print("购买成功执行的结果集：",buy_resultsStrs)
        end
        local intelligence_list = string.split(intelligenceIdStr,",")
        local technique_list = string.split(techniqueIdStrs,",")
        local params = {
            intelligence_list = intelligence_list,
            technique_list = technique_list,
            currency_type = currency_type,
            price = price 
        }
        IntelligenceSystem:uploadIntelligenceData(params,function()
            IntelligenceSystem:buyIntelligence(price,currency_type,function()
                map:doNoRoleResults(buy_resultsStrs, environment)
            end)
        end)
    end,
    ["江湖情报"] = function(map, result, environment)
        IntelligenceSystem:getIntelligenceList(function(list)
            local presenter = require("app.presenters.intelligence.intelligence.IntelligencePresenter")
            PopupLayerController:showLayer("IntelligenceUI", function(layer)
                layer:showLayer(presenter:create(layer,IntelligenceSystem,list))
            end)
        end)
    end,
    ["江湖秘辛"] = function(map, result, environment)
        IntelligenceSystem:getTechniqueList(function(list)
            local presenter = require("app.presenters.intelligence.jianghuSecret.JiangHuSecretPresenter")
            PopupLayerController:showLayer("JiangHuSecretUI", function(layer)
                layer:showLayer(presenter:create(layer,IntelligenceSystem,list))
            end)
        end)
    end,
}

function ScoutModule:entryMap(map, currTime)
    local role = User:getRole()
    local roleLv = role:getLv()
    if map:isUserMap() then
        if map:getMapType() == MAP_TYPE.MYHOME and role:getInheritFlag("江湖情报开启") == 1 then 
            IntelligenceSystem:addNpc(map)
        end
    end
end


return ScoutModule000000
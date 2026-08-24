--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local SelfCreatedSkillModule = class("SelfCreatedSkillModule", require("app.models.map.MapHandle.Modules.BaseModule"))

local MapInfo = require("app.models.map.MapInfo")
--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
-- SelfCreatedSkillModule.mapId = "fb220"

--@desc 开启状态，默认开启
SelfCreatedSkillModule.status = 1

--@desc  家园公用条件结果
SelfCreatedSkillModule.doResult = {
    ["新增神功武学"] = function(map, result, environment)
        local player = map:getPlayer()
        local name = result.arg2
        local colorId = result.arg3
        local templateId = result.arg4
        local exp = result.arg5
        local outputType = result.arg6
        local skillDataId = result.arg7
        local demaMapSkillData = {
            id = skillDataId,
            name = name,
            colorId = colorId,
            templateId = templateId,
            outputType = outputType,
            zhaos = {}
        }
        local selfCreatedSkillSystem = player:getSelfCreatedSkillSystem()
        selfCreatedSkillSystem:addSelfCreatedSkillData(skillDataId, demaMapSkillData, exp)

        local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
        local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
        local SkillHelper = require("app.models.skill.SkillHelper")

        local secondType = SelfCreatedSkillManager:getSkill(templateId).secondType
        local skillType = SelfCreatedSkillConstants.SkillSecondPrepareIndex[secondType]
        local skillId = SkillHelper:selfCreatedSkillDataIdToSkillId(player:getAttr("userid"), skillDataId)

        player:prepareSkill(skillType, skillId)
    end,
    ["新增神功招式"] = function(map, result, environment)
        local player = map:getPlayer()
        local selfCreatedSkillSystem = player:getSelfCreatedSkillSystem()
        local createdSkillData = selfCreatedSkillSystem:getCreatedSkillData()
        local id = result.arg2
        local skillDataId = result.arg3

        if MapIsEmpty(createdSkillData) or MapIsEmpty(createdSkillData[skillDataId]) then
            print("结果【新增神功招式】：武学不存在 skillDataId = ",skillDataId)
            print(debug.traceback())
            return
        end

        local index = #createdSkillData[skillDataId].zhaos + 1
        local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
        local liLianZhaodata = SelfCreatedSkillManager:getLiLianZhaoRuleMap(id)
        if MapIsEmpty(liLianZhaodata) then
            print("神功招式为空  id = ", id)
            return
        end

        local name = liLianZhaodata.name
        local colorId = liLianZhaodata.colorId
        local dscId = liLianZhaodata.dscId
        local quality = liLianZhaodata.quality
        local useType = liLianZhaodata.useType
        local templateId = liLianZhaodata.templateId
        local atkAffixs = {}
        local defAffixs = {}
        local affixIdStr = liLianZhaodata.affix
        if affixIdStr and affixIdStr ~= 0 then
            local affixIds = string.split(affixIdStr, ",")
            for i, affixId in ipairs(affixIds) do
                local affixMap = SelfCreatedSkillManager:getLiLianAffaixMap(affixId)
                if affixMap then
                    local affixData = {
                        effectId = affixMap.affixId,
                        value1 = affixMap.effect1,
                        value2 = affixMap.effect2,
                        value3 = affixMap.effect3,
                        needLv = affixMap.needLv
                    }

                    if i <= 3 then
                        table.insert(atkAffixs, affixData)
                    else
                        table.insert(defAffixs, affixData)
                    end
                end
            end
        end

        local zhaoData = {
            index = index,
            name = name,
            colorId = colorId,
            dscId = dscId,
            quality = quality,
            useType = useType,
            templateId = templateId,
            atkAffixs = atkAffixs,
            defAffixs = defAffixs
        }

        table.insert(createdSkillData[skillDataId].zhaos, zhaoData)
        selfCreatedSkillSystem:updataSelfCreatedSkillMap()
    end,
    ["历练副本改良道具变化"] = function(map, result, environment)
        local player = map:getPlayer()
        local selfCreatedSkillSystem = player:getSelfCreatedSkillSystem()
        local propId = result.arg2
        local count = result.arg3

        selfCreatedSkillSystem:addProp(propId, count)
    end,
    ["完成古迹任务"] = function(map, result, environment)
        local guJiTaskPoint = Helper:getDef(result.arg2, 0)

        local successResults = result.arg3

        local failResults = result.arg4

        local SelfCreatedSkillTaskModel = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillTask.SelfCreatedSkillTaskModel")

        local env = environment
        SelfCreatedSkillTaskModel:completeTask(
            {
                extra = {
                    gujiPoint = guJiTaskPoint
                }
            },
            function(result, taskInfo)
                if result == 0 then
                    if successResults ~= nil then
                        map:doNoRoleResults(successResults, environment)
                    end
                elseif result == 2 then
                    if failResults ~= nil then
                        map:doNoRoleResults(failResults, environment)
                    end
                    PopText("任务未接取，无法完成")
                elseif result == 3 then
                    if failResults ~= nil then
                        map:doNoRoleResults(failResults, environment)
                    end
                    PopText("任务已提交，无法完成")
                end
            end
        )
    end
}

function SelfCreatedSkillModule:entryMap(map, currTime)
end

return SelfCreatedSkillModule
00000
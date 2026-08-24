local SegmentTree = require("third.tree.SegmentTree")
local ActionConstants = require("app.models.ActionSystem.ActionConstants")

-- 200 * potEfficiency / 3600 * duration

-- 练功经验计算器
local SkillLianGongExpCalculator = {}

function SkillLianGongExpCalculator:create(actionList, skillId)
    local p = setmetatable({}, {__index = SkillLianGongExpCalculator})
    local beginTime = os.clock()
    p:init(actionList, skillId)
    print("SkillLianGongExpCalculator:init duration:", os.clock() - beginTime)
    return p
end

function SkillLianGongExpCalculator:init(actionList, skillId)
    -- 去除掉最后一次开始挂机前的所有操作，减少计算量·
    -- for i = table.getn(actionList), 1, -1 do
    --     if actionList[i].type == ActionConstants.ActionType.GuaJi_Begin and i > 1 then
    --         table.removeRange(actionList,1, i - 1)
    --         break
    --     end
    -- end

    local segmentTree = SegmentTree:create(0, 99999999999, 0)

    local originAction = nil

    -- 开始练功
    local guajiBeginAction = nil
    local xingGongSanUseActions = {}
    local guajiEndAction = nil

    for i, action in ipairs(actionList) do
        if action.type == ActionConstants.ActionType.GuaJi_Begin then
            if action.skillId == skillId then
                guajiBeginAction = action
                if originAction == nil then
                    originAction = guajiBeginAction
                end
            end
        elseif action.type == ActionConstants.ActionType.XingGongSan_Use then
            table.insert(xingGongSanUseActions, action)
        elseif action.type == ActionConstants.ActionType.GuaJi_End then
            if action.skillId == skillId then
                guajiEndAction = action
                -- 初始值
                segmentTree:update(guajiBeginAction.time, guajiEndAction.time, 200 * guajiBeginAction.potEfficiency / 3600)
            -- xinggongsan额外值（num * RoleConstans.theSecondOfOneHour）
            -- for j = table.getn(xingGongSanUseActions), 1, -1 do
            --     local xingGongSanUseAction = xingGongSanUseActions[j]
            --     if xingGongSanUseAction.time >= guajiBeginAction.time and xingGongSanUseAction.time <= guajiEndAction.time then
            --         segmentTree:add(xingGongSanUseAction.time, guajiEndAction.time, xingGongSanUseAction.count)
            --     else
            --         table.remove(xingGongSanUseActions, j)
            --     end
            -- end
            end
        end
    end

    self.__originAction = originAction
    self.__finishTime = guajiEndAction.time
    self.__segmentTree = segmentTree

    -- self.__segmentTree:print()
end

function SkillLianGongExpCalculator:getFinishTime()
    return self.__finishTime
end

function SkillLianGongExpCalculator:hasFinished(time)
    return time > self.__finishTime
end

function SkillLianGongExpCalculator:getAddExp(time)
    return self.__originAction.skillExp + self.__segmentTree:sum(self.__originAction.time, time)
end

return SkillLianGongExpCalculator
0000
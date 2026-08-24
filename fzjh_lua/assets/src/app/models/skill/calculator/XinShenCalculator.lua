local SegmentTree = require("third.tree.SegmentTree")
local ActionConstants = require("app.models.ActionSystem.ActionConstants")

-- 200 * potEfficiency / 3600 * duration

-- 练功经验计算器
local XinShenCalculator = {}

function XinShenCalculator:create(actionList)
    local p = setmetatable({}, {__index = XinShenCalculator})
    local beginTime = os.clock()
    p:init(actionList)
    print("XinShenCalculator:init duration:", os.clock() - beginTime)
    return p
end

function XinShenCalculator:init(actionList)
    local segmentTree = SegmentTree:create(0, 99999999999, 0)

    -- 开始练功
    local guajiBeginAction = nil
    local xingGongSanUseActions = {}
    local guajiEndAction = nil

    local firstBeginAction = nil

    for i, action in ipairs(actionList) do
        if action.type == ActionConstants.ActionType.GuaJi_Begin then
            guajiBeginAction = action
            if firstBeginAction == nil then
                firstBeginAction = action
            end
        elseif action.type == ActionConstants.ActionType.GuaJi_End then
            guajiEndAction = action
            -- 初始值
            segmentTree:update(guajiBeginAction.time, guajiEndAction.time, 1)
            segmentTree:add(guajiBeginAction.time, guajiBeginAction.time, -100)
        end
    end

    self.__firstBeginAction = firstBeginAction
    self.__finishTime = guajiEndAction.time
    self.__segmentTree = segmentTree
end

function XinShenCalculator:getXinShen(time)
    return self.__firstBeginAction.xinShen + self.__segmentTree:sum(self.__firstBeginAction.time, time)
end

return XinShenCalculator
000000000000
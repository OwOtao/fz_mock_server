local ActiveZhaoRules = {}
local fubenai = require("script.npc.fubenai")["fubenai"]

local rulesList = {}

local updateRulesCdList = {}

local function parseCon(str)
    local con = {}

    if type(str) ~= "string" or str == nil then
        if DEBUG_MODE == 1 then
            assert(false, "arg1 str is nil or type is wrong")
        end
    end

    if str == "0" then
        return con
    end

    local compareSym = string.sub(str, 0, 1)
    local perSymbolIndex = string.find(str, "%%")

    local value, tag
    if perSymbolIndex then
        value = string.sub(str, 2, perSymbolIndex - 1) / 100
        tag = 0
    else
        value = string.sub(str, 2)
        tag = 1
    end

    local con = {
        --@desc 0标识百分比，1标识数值直接使用
        tag = tag,
        value = tonumber(value),
        symbol = compareSym
    }

    -- if DEBUG_MODE == 1 then
    --     print("------- parse start -----")
    --     print("parse pre:", str)
    --     print("parse after:")
    --     Helper:print_lua_table(con)
    --     print("------- parse end -----")
    -- end

    return con
end

-- 解析Buff效果ID判断条件
local function parseEffectCon(str)
    local con = {}
    if type(str) ~= "string" or str == nil or str == "0" then
        return con
    end

    -- 分割判断符和效果ID列表：or|YW#DX → {or, YW#DX}
    local sepIndex = string.find(str, "|")
    if not sepIndex then
        if DEBUG_MODE == 1 then
            assert(false, "effect配置格式错误：" .. str)
        end
        return con
    end

    local judgeType = string.sub(str, 1, sepIndex - 1)
    local effectIds = string.sub(str, sepIndex + 1)
    con.judgeType = judgeType -- and/or/no
    con.effectIds = string.split(effectIds, "#") -- 拆分效果ID列表
    return con
end

-- 解析标记类属性值判断条件
local function parseEffectNumCon(str)
    local con = {}
    if type(str) ~= "string" or str == nil or str == "0" then
        return con
    end

    -- 分割格式：易伤#fragile1num2#>#3 → {易伤, fragile1num2, >, 3}
    local parts = string.split(str, "#")
    if #parts ~= 4 then
        if DEBUG_MODE == 1 then
            assert(false, "effectNum配置格式错误：" .. str)
        end
        return con
    end

    con.tagType = parts[1] -- 增伤/易伤/叠加
    con.tagId = parts[2]   -- 标记ID
    con.symbol = parts[3]  -- 判断符 < />
    con.value = tonumber(parts[4]) -- 标记层数
    return con
end

local function initRulsList()
    for k, rule in pairs(fubenai) do
        rulesList[k] = {}
        for ruleid, str in pairs(rule) do
            if ruleid == "skillcd" then
                --@desc CD时间按照帧计算
                rulesList[k][ruleid] = tonumber(str * 30)
            elseif ruleid == "id" then
			elseif ruleid == "effect" then
                -- 解析NPC持有效果要求
                local con = parseEffectCon(tostring(str))
                if not MapIsEmpty(con) then
                    rulesList[k][ruleid] = con
                end
            elseif ruleid == "effectNum" then
                -- 解析NPC标记类属性值要求
                local con = parseEffectNumCon(tostring(str))
                if not MapIsEmpty(con) then
                    rulesList[k][ruleid] = con
                end
            elseif ruleid == "playerEffect" then
                -- 解析玩家持有效果要求
                local con = parseEffectCon(tostring(str))
                if not MapIsEmpty(con) then
                    rulesList[k][ruleid] = con
                end
            elseif ruleid == "playerEffectNum" then
                -- 解析玩家标记类属性值要求
                local con = parseEffectNumCon(tostring(str))
                if not MapIsEmpty(con) then
                    rulesList[k][ruleid] = con
                end
            else
                local con = parseCon(tostring(str))
                if not MapIsEmpty(con) then
                    rulesList[k][ruleid] = con
                end
            end
        end
    end
end

function ActiveZhaoRules:getRuleById(ruleId)
    if not rulesList[ruleId] then
        assert(false, ruleId .. "，没有该释放规则")
    end
    return rulesList[ruleId]
end

function ActiveZhaoRules:getRules()
    return rulesList
end

--@desc: 设置招式ID对应的规则CD时间
--@author:Liang SongQiang
--@time:2018-01-19 20:41:54
--@key: activeZhaoId_ruleId
function ActiveZhaoRules:setRuleCd(key)
    local tb = string.split(key, "_")

    local activeZhaoId = tb[1]
    local ruleId = tb[2]

    local rule = rulesList[ruleId]

    updateRulesCdList[key] = rule.skillcd
end

--@desc: 刷新规则列表的CD时间
--@author:Liang SongQiang
--@time:2018-01-19 20:46:42
--@frameIndex:
function ActiveZhaoRules:updateRulesCd(frameIndex)
    if MapIsEmpty(updateRulesCdList) then
        return
    end

    for k, cd in pairs(updateRulesCdList) do
        if cd <= 0 then
            updateRulesCdList[k] = nil
        else
            cd = cd - 1
            updateRulesCdList[k] = cd

            if PRINT_MODE == 1 then
                print("updateRulesCdList", k, cd)
            end
        end
    end
end

function ActiveZhaoRules:clearUpdateList()
    updateRulesCdList = {}
end

--@desc: 获取技能规则cd
--@author:Liang SongQiang
--@time:2018-01-19 20:56:44
function ActiveZhaoRules:getRulesCd(key)
    return updateRulesCdList[key]
end

--@desc: 检查角色气血是否符号条件
--@author:LvBin
--@time:2026-04-14 15:46:12
--@role:
	--@checkRule: 
--@return
function ActiveZhaoRules:checkRoleAttrQi(role, checkRule)
    -- 没有配置条件 = 直接通过
    if not checkRule or MapIsEmpty(checkRule) then
        return true
    end

    -- 获取当前值 & 最大值
    local current = role:getAttr("qi")
    local max  = role:getFinalAttr("qiMax")

    -- 百分比模式
    if checkRule.tag == 0 then
        local ratio = math.min(current / max, 1)
        if checkRule.symbol == ">" then
            return ratio > checkRule.value
        else
            return ratio < checkRule.value
        end
    else
        -- 固定数值模式
        if checkRule.symbol == ">" then
            return current > checkRule.value
        else
            return current < checkRule.value
        end
    end
end

--@desc: 检查角色内力是否符号条件
--@author:LvBin
--@time:2026-04-14 15:46:12
--@role:
--@checkRule: 
--@return
function ActiveZhaoRules:checkRoleAttrNeiLi(role, checkRule)
    -- 没有配置条件 = 直接通过
    if not checkRule or MapIsEmpty(checkRule) then
        return true
    end

    -- 获取当前值 & 最大值
    local current = role:getAttr("neili")
    local max  = role:getAttr("neiliMax")

    -- 百分比模式
    if checkRule.tag == 0 then
        local ratio = math.min(current / max, 1)
        if checkRule.symbol == ">" then
            return ratio > checkRule.value
        else
            return ratio < checkRule.value
        end
    else
        -- 固定数值模式
        if checkRule.symbol == ">" then
            return current > checkRule.value
        else
            return current < checkRule.value
        end
    end
end

--@desc: 检查角色是否持有指定效果ID
--@author:LvBin
--@time:2026-04-14 15:13:42
--@role:
--@return
function ActiveZhaoRules:checkEffect(role, effectCon)
    if MapIsEmpty(effectCon) then
        return true
    end

    local judgeType = effectCon.judgeType
    local effectIds = effectCon.effectIds

    if judgeType == "and" then
        -- 必须持有所有效果
		for _, effId in ipairs(effectIds) do
			if not role:getEffect(effId) then
				return false
			end
		end
		return true
    elseif judgeType == "or" then
        -- 持有任意一个效果
		for _, effId in ipairs(effectIds) do
			if role:getEffect(effId) then
				return true
			end
		end
        return false
    elseif judgeType == "no" then
        -- 没有所有效果
		for _, effId in ipairs(effectIds) do
			if role:getEffect(effId) then
				return false
			end
		end
        return true
    else
		assert(false, "无效的效果判断类型：" .. judgeType)

        return false
    end
end

--@desc: 检查角色标记类属性值
--@author:LvBin
--@time:2026-04-14 15:24:16
--@role:
	--@effectNumCon: 
--@return
function ActiveZhaoRules:checkEffectNum(role, effectNumCon)
    if MapIsEmpty(effectNumCon) then
        return true
    end

    local tagType = effectNumCon.tagType
    local tagId = effectNumCon.tagId
    local symbol = effectNumCon.symbol
    local targetValue = effectNumCon.value

    -- 传入标记类型+标记ID返回层数
    local currentNum = switch(
        tagType,
        {
            ["增伤"] = role:getAugmentValue(tagId),
            ["易伤"] = role:getFragileValue(tagId),
            ["叠加"] = role:getEffectMarkValue(tagId),
            default = 0
        }
    )

    currentNum = tonumber(currentNum) or 0

    if symbol == ">" then
        return currentNum > targetValue
    elseif symbol == "<" then
        return currentNum < targetValue
    else
        if DEBUG_MODE == 1 then
            assert(false, "无效的标记判断符：" .. symbol)
        end
        return false
    end
end

initRulsList()

return ActiveZhaoRules
0000000000000000
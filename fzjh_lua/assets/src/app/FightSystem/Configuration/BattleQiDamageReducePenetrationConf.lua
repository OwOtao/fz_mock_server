--[[
    author:Seven
    time:2026-03-17 15:38:51
    desc: 角色气血伤害免伤穿透配置
]]
local config_data = require("script.newbattle.demo.battleQiDamageReducePenetrationConf")["data"]

-- 运行时按维度缓存，避免每个受击帧都重复遍历原始配置表。
local data_map = {}
local data_group_map = {}
local stage_data_group_map = {}
local detail_data_map = {}
local max_stage_map = {}
local max_lv_map = {}

local function __getGroupKey(damageType, class)
    return tostring(damageType) .. "_" .. tostring(class)
end

local function __getStageGroupKey(damageType, class, stage)
    return __getGroupKey(damageType, class) .. "_" .. tostring(stage)
end

local function __getDetailKey(damageType, class, stage, lv)
    return __getStageGroupKey(damageType, class, stage) .. "_" .. tostring(lv)
end

local function __sortDataGroup(list)
    table.sort(
        list,
        function(a, b)
            if a.stage == b.stage then
                if a.lv == b.lv then
                    return a.id < b.id
                end

                return a.lv < b.lv
            end

            return a.stage < b.stage
        end
    )
end

local function __sortStageDataGroup(list)
    table.sort(
        list,
        function(a, b)
            if a.lv == b.lv then
                return a.id < b.id
            end

            return a.lv < b.lv
        end
    )
end

local function __initDataGroup()
    for _, data in pairs(config_data) do
        data_map[data.id] = data
        data_map[tostring(data.id)] = data

        local group_key = __getGroupKey(data.damageType, data.class)
        if data_group_map[group_key] == nil then
            data_group_map[group_key] = {}
        end
        table.insert(data_group_map[group_key], data)

        if max_stage_map[group_key] == nil or data.stage > max_stage_map[group_key] then
            max_stage_map[group_key] = data.stage
        end

        local stage_group_key = __getStageGroupKey(data.damageType, data.class, data.stage)
        if stage_data_group_map[stage_group_key] == nil then
            stage_data_group_map[stage_group_key] = {}
        end
        table.insert(stage_data_group_map[stage_group_key], data)

        local detail_key = __getDetailKey(data.damageType, data.class, data.stage, data.lv)
        if detail_data_map[detail_key] ~= nil then
            error(
                "BattleQiDamageReducePenetrationConf 配置重复：伤害类型为 "
                    .. tostring(data.damageType)
                    .. "、影响分类为 "
                    .. tostring(data.class)
                    .. "、阶段为 "
                    .. tostring(data.stage)
                    .. "、等级为 "
                    .. tostring(data.lv)
            )
        end
        detail_data_map[detail_key] = data

        if max_lv_map[stage_group_key] == nil or data.lv > max_lv_map[stage_group_key] then
            max_lv_map[stage_group_key] = data.lv
        end
    end

    -- 算法层依赖稳定顺序做阶段/等级循环，这里统一预排序。
    for _, list in pairs(data_group_map) do
        __sortDataGroup(list)
    end

    for _, list in pairs(stage_data_group_map) do
        __sortStageDataGroup(list)
    end
end
__initDataGroup()

local BattleQiDamageReducePenetrationConf = {}

local function __getDataById(id)
    local data = data_map[id]

    if data == nil then
        error("BattleQiDamageReducePenetrationConf:getDataById 未找到id为" .. tostring(id) .. "的配置")
    end

    return data
end

--@desc: 按配置 id 读取单条免伤/穿透配置
--@author:Codex
--@time:2026-03-17
--@id: 配置 id
function BattleQiDamageReducePenetrationConf:getDataById(id)
    return __getDataById(id)
end

--@desc: 读取配置默认值 attrDefault
--@author:Codex
--@time:2026-03-17
--@id: 配置 id
function BattleQiDamageReducePenetrationConf:getDefaultValue(id)
    local data = __getDataById(id)

    return data.attrDefault
end

--@desc: 读取配置展示文本 attrTag
--@author:Codex
--@time:2026-03-17
--@id: 配置 id
function BattleQiDamageReducePenetrationConf:getTipText(id)
    local data = __getDataById(id)

    return data.attrTag
end

--@desc: 读取指定伤害类型与影响分类下的全部配置
--@author:Codex
--@time:2026-03-17
--@damageType: 伤害类型，1=被动，2=主动
--@class: 影响分类，0=穿透值，1=免伤率，2=免伤值
function BattleQiDamageReducePenetrationConf:getDataByDamageTypeAndEffectType(damageType, class)
    local data_group = data_group_map[__getGroupKey(damageType, class)]

    if data_group == nil then
        error(
            "BattleQiDamageReducePenetrationConf:getDataByDamageTypeAndEffectType 未找到伤害类型为 "
                .. tostring(damageType)
                .. " 且影响分类为 "
                .. tostring(class)
                .. " 的配置"
        )
    end

    return data_group
end

--@desc: 读取指定伤害类型/影响分类/阶段/等级下的单条配置
--@author:Codex
--@time:2026-03-17
--@damageType: 伤害类型
--@class: 影响分类
--@stage: 阶段
--@lv: 等级
function BattleQiDamageReducePenetrationConf:getDataByDamageTypeAndClassAndStageAndLv(damageType, class, stage, lv)
    local data = detail_data_map[__getDetailKey(damageType, class, stage, lv)]

    if data == nil then
        error(
            "BattleQiDamageReducePenetrationConf:getDataByDamageTypeAndClassAndStageAndLv 未找到伤害类型为 "
                .. tostring(damageType)
                .. "、影响分类为 "
                .. tostring(class)
                .. "、阶段为 "
                .. tostring(stage)
                .. "、等级为 "
                .. tostring(lv)
                .. " 的配置"
        )
    end

    return data
end

--@desc: 读取指定伤害类型与影响分类下的最大阶段
--@author:Codex
--@time:2026-03-17
--@damageType: 伤害类型
--@class: 影响分类
function BattleQiDamageReducePenetrationConf:getMaxStageByDamageTypeAndClass(damageType, class)
    local max_stage = max_stage_map[__getGroupKey(damageType, class)]

    if max_stage == nil then
        error(
            "BattleQiDamageReducePenetrationConf:getMaxStageByDamageTypeAndClass 未找到伤害类型为 "
                .. tostring(damageType)
                .. " 且影响分类为 "
                .. tostring(class)
                .. " 的配置"
        )
    end

    return max_stage
end

--@desc: 读取指定伤害类型/影响分类/阶段下的配置列表
--@author:Codex
--@time:2026-03-17
--@damageType: 伤害类型
--@class: 影响分类
--@stage: 阶段
function BattleQiDamageReducePenetrationConf:getDataGroupByDamageTypeAndEffectTypeAndStage(damageType, class, stage)
    local data_group = stage_data_group_map[__getStageGroupKey(damageType, class, stage)]

    if data_group == nil then
        error(
            "BattleQiDamageReducePenetrationConf:getDataGroupByDamageTypeAndEffectTypeAndStage 未找到伤害类型为 "
                .. tostring(damageType)
                .. "、影响分类为 "
                .. tostring(class)
                .. "、阶段为 "
                .. tostring(stage)
                .. " 的配置"
        )
    end

    return data_group
end

--@desc: 读取指定伤害类型/影响分类/阶段下的最大等级
--@author:Codex
--@time:2026-03-17
--@damageType: 伤害类型
--@class: 影响分类
--@stage: 阶段
function BattleQiDamageReducePenetrationConf:getMaxLvByDamageTypeAndClassAndStage(damageType, class, stage)
    local max_lv = max_lv_map[__getStageGroupKey(damageType, class, stage)]

    if max_lv == nil then
        error(
            "BattleQiDamageReducePenetrationConf:getMaxLvByDamageTypeAndClassAndStage 未找到伤害类型为 "
                .. tostring(damageType)
                .. "、影响分类为 "
                .. tostring(class)
                .. "、阶段为 "
                .. tostring(stage)
                .. " 的配置"
        )
    end

    return max_lv
end

return BattleQiDamageReducePenetrationConf
000
local AnimResInfo = {
    attack_anim = {},
    other_anim = {},
    other_weapon_anim = {},
    anim_event_info = {},
    anim_time = {},
    --@desc 攻击距离（用于计算跳跃距离）
    atk_offset = {}
}

local ANIM_INIT_LOG = function(...)
    return require("app.FightSystem.FightUtil.FightUtil"):printLog(...)
end

local animRes = require("script.newbattle.demo.animRes")["动画资源"]

local FightCommons = require("app.FightSystem.FightCommons")

local function initAnimEventInfo(skeleton, animName, animType)
    assert(type(animName) == "string" and #animName > 0, "The animName length must be greater than 0")
    assert(type(animType) == "number", "The animType must be number")

    local events = skeleton:getAnimEvents(animName)

    if MapIsEmpty(events) and animType == 1 then
        assert(false, "攻击动画：" .. animName .. "无受击事件，请检查。")
    end

    ANIM_INIT_LOG("初始化 动画【" .. animName .. "】事件信息。", events)

    if AnimResInfo.anim_event_info[animName] == nil then
        AnimResInfo.anim_event_info[animName] = {}
    end

    local HIT_POS = FightCommons.HIT_POS
    for i, event in ipairs(events) do
        if event.name == "Hurt" then
            --@desc 攻击动画
            local eventHitPos = event.stringValue
            if not (eventHitPos == HIT_POS.CHEST or eventHitPos == HIT_POS.FOOT or eventHitPos == HIT_POS.HEAD) then
                assert(false, "攻击动画：" .. animName .. " 受击部位错误：" .. eventHitPos)
            end
        end

        table.insert(
            AnimResInfo.anim_event_info[animName],
            {
                name = event.name,
                stringValue = event.stringValue,
                time = event.time,
                floatValue = event.floatValue,
                intValue = event.intValue
            }
        )
    end
end

--@desc: 初始化动画时长信息
--@author:Seven
--@time:2021-05-31 20:23:40
local function initAnimTimeIndex(skeleton, animName)
    local time = Helper:preciseDecimal(skeleton:getAnimDuration(animName), 2)
    AnimResInfo.anim_time[animName] = time
    ANIM_INIT_LOG("初始化 动画【" .. animName .. "】时长 : " .. time)
end

local function initAtkOffset(skeleton, animName)
    ANIM_INIT_LOG("初始化 攻击动画【" .. animName .. "】攻击距离")
    local atk_point = skeleton:getBoneSetupPosePosition(animName, "AttackPosition")
    AnimResInfo.atk_offset[animName] = atk_point.x
end

--@desc 初始化动画表格资源
local function initAnimResInfo()
    -- 单元测试模式下,不需要初始化动画信息
    if UNIT_TEST then
        return
    end

    if spine38 == nil then
        return
    end

    local pathCache = {}

    for id, res in pairs(animRes) do
        ANIM_INIT_LOG("开始处理动画资源 ：{ id :" .. id .. "，path : " .. res.altlasPath .. "，animResId ：" .. res.animResId .. "，anim ：" .. res.anim .. "}")

        local skeletonAnimation = pathCache[res.altlasPath]
        if skeletonAnimation == nil then
            skeletonAnimation = assert(spine38.NewSkeletonAnimation:createWithBinaryFile(res.altlasPath .. ".skel", res.altlasPath .. ".atlas", 1), "动画初始化出错")
            pathCache[res.altlasPath] = skeletonAnimation
        end

        if res.animType == 1 then
            local index_str = tostring(res.animResId) .. "|" .. res.weaponModule
            if AnimResInfo.attack_anim[index_str] ~= nil then
                assert(false, "动画资源表 id ：" .. id .. "资源信息重复，请检查资源。")
            end

            AnimResInfo.attack_anim[index_str] = res

            initAtkOffset(skeletonAnimation, res.anim)
        elseif res.animType == 0 then
            AnimResInfo.other_anim[tostring(res.animResId)] = res
        elseif res.animType == 2 then
            local index_str = tostring(res.animResId) .. "|" .. res.weaponModule
            if AnimResInfo.other_weapon_anim[index_str] ~= nil then
                assert(false, "动画资源表 id ：" .. id .. "资源信息重复，请检查资源。")
            end

            AnimResInfo.other_weapon_anim[index_str] = res
        else
            assert(false, "动画资源表 id ：" .. id .. " [动作类型;animType ： " .. res.animType .. "] 未知，请检查。")
        end

        initAnimEventInfo(skeletonAnimation, res.anim, res.animType)
        initAnimTimeIndex(skeletonAnimation, res.anim)
    end
end

initAnimResInfo()

local AnimResManager = {}

function AnimResManager:getAttackAnimName(animResId, weaponModule)
    local attack_anim_info = AnimResInfo.attack_anim[tostring(animResId) .. "|" .. weaponModule]
    if attack_anim_info == nil then
        assert(false, "未找到该动画资源ID：" .. animResId .. " 和武器动作模组： " .. weaponModule .. " 所对应的攻击动画信息。")
    end
    return attack_anim_info.anim
end

function AnimResManager:getOtherAnimName(animResId)
    local other_anim_res = AnimResInfo.other_anim[tostring(animResId)]
    if other_anim_res == nil then
        assert(false, "未找到非攻击动画资源ID：" .. tostring(animResId) .. "所对应的动画信息。")
    end
    return other_anim_res.anim
end

function AnimResManager:getOtherAnimNameByWeapon(animResId, weaponModule)
    local attack_anim_info = AnimResInfo.other_weapon_anim[tostring(animResId) .. "|" .. weaponModule]
    if attack_anim_info == nil then
        assert(false, "未找到该动画资源ID：" .. animResId .. " 和武器动作模组： " .. weaponModule .. " 所对应的普通动画信息。")
    end
    return attack_anim_info.anim
end

function AnimResManager:getAnimHurtEvents(animName)
    local events = AnimResInfo.anim_event_info[animName]
    if events == nil then
        assert(false, "AnimResManager:getAnimHurtEvents: 动画【" .. animName .. "】没有动画事件。")
    end

    local eventlist = {}

    for i, v in ipairs(events) do
        if v.name == "Hurt" then
            table.insert(eventlist, v)
        end
    end

    return eventlist
end

function AnimResManager:getAnimEvents(animName)
    local events = AnimResInfo.anim_event_info[animName]
    if events == nil then
        assert(false, "AnimResManager:getAnimEvents: 动画【" .. animName .. "】没有动画事件。")
    end
    return events
end

function AnimResManager:getAnimTime(animName)
    local time = AnimResInfo.anim_time[animName]

    if time == nil then
        assert(false, "获取动画【" .. animName .. "】 时间失败。")
    end
    return time
end

function AnimResManager:getAttackAnimOffset(animName)
    local offset = AnimResInfo.atk_offset[animName]

    if offset == nil then
        assert(false, "该动画【" .. animName .. "】没有攻击距离。")
    end

    return offset
end

function AnimResManager:getAnimResInfo()
    return AnimResInfo
end

return AnimResManager
00
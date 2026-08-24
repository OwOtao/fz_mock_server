--[[
    author:Seven
    time:2025-04-11 15:00:24
    desc: 时间标识辅助工具
]]
local StatusTagsResourceHelper = require("app.models.RoleStatusTags.StatusTagsResourceHelper")

local LIMIT_TIME_TAG_TYPE = {
    DATE_NO_HOTFIX = 1,
    DATE_HOTFIX = 2,
    EXIST_TIME_NO_HOTFIX = 3,
    EXIST_TIME_HOTFIX = 4
}

local TimeLimitStatusTagHelper = {}

local function getTimeZoneAt(timestamp)
    local function get_timezone(ts)
        local utc_time = os.date("!*t", ts) -- UTC时间表
        local local_time = os.date("*t", ts) -- 本地时间表
        local_time.isdst = nil -- 禁用isdst自动修正
        return os.time(local_time) - os.time(utc_time)
    end
    return 28800 - get_timezone(timestamp) -- 东八区与本地时区偏移
end

local format_timestr_to_timestamp = function(time_str)
    -- 正则提取年、月、日、时、分、秒
    local year, month, day, hour, min, sec = string.match(time_str, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")

    -- 构造本地时间表，生成初步时间戳
    local preliminary_ts =
        os.time(
        {
            year = year,
            month = month,
            day = day,
            hour = hour,
            min = min,
            sec = sec
        }
    )

    -- 计算该时间戳对应的时区修正值
    local offset = getTimeZoneAt(preliminary_ts)

    -- 最终时间戳 = 初步时间戳 - 修正值
    return preliminary_ts - offset
end

local TIME_TAG_TYPE_FUNC = {
    [LIMIT_TIME_TAG_TYPE.DATE_NO_HOTFIX] = {
        new = function(tagRes, nowtime)
            return {
                extime = format_timestr_to_timestamp(tagRes.arg2)
            }
        end,
        isExpired = function(tagRes, tagObject, nowtime)
            local expiredTime = tagObject.extime

            if nowtime > expiredTime then
                return true
            end

            return false
        end
    },
    [LIMIT_TIME_TAG_TYPE.DATE_HOTFIX] = {
        new = function(tagRes, nowtime)
            return {}
        end,
        isExpired = function(tagRes, tagObject, nowtime)
            local expiredTime_str = tagRes.arg2

            -- 上次获取的版本时间
            local before_version_time_str = tagObject._rtime
            local before_version_time = format_timestr_to_timestamp(before_version_time_str)
            -- 转换为时间戳（单位：秒）
            local expiredTime = format_timestr_to_timestamp(expiredTime_str)

            if before_version_time < nowtime then
                -- 如果上次获取的版本时间小于当前时间，说明版本时间在过期后有更新，直接当做过期处理
                return true
            end

            if before_version_time_str ~= expiredTime_str then
                -- 版本时间有更新，说明版本时间在过期前有更新，当做延续
                tagObject._rtime = expiredTime_str
            end

            if nowtime > expiredTime then
                return true
            end

            return false
        end
    },
    [LIMIT_TIME_TAG_TYPE.EXIST_TIME_NO_HOTFIX] = {
        new = function(tagRes, nowtime)
            return {
                extime = nowtime + tonumber(tagRes.arg2)
            }
        end,
        isExpired = function(tagRes, tagObject, nowtime)
            local _nowTime = nowtime

            local expiredTime = tagObject.extime

            if _nowTime > expiredTime then
                return true
            end

            return false
        end
    },
    [LIMIT_TIME_TAG_TYPE.EXIST_TIME_HOTFIX] = {
        new = function(tagRes, nowtime)
            return {
                s_time = nowtime
            }
        end,
        isExpired = function(tagRes, tagObject, nowtime)
            local timeout = tagRes.arg2

            local expiredTime = tagObject.s_time + timeout

            if nowtime > expiredTime then
                return true
            end

            return false
        end
    }
}

function TimeLimitStatusTagHelper.format_timestr_to_timestamp(str)
    return format_timestr_to_timestamp(str)
end

function TimeLimitStatusTagHelper:isExpired(tagId, tagObject, nowtime)
    local tagRes = StatusTagsResourceHelper:getStatusTagRes(tagId)

    local time_type = tagRes.arg1

    local time_type_func = TIME_TAG_TYPE_FUNC[tonumber(time_type)]
    if not time_type_func then
        error("isExpired Invalid time type: " .. tagRes.arg1)
    end

    nowtime = nowtime or GetTime()

    local isExpired = time_type_func.isExpired(tagRes, tagObject, nowtime)

    if isExpired then
        return true
    end

    return false
end

function TimeLimitStatusTagHelper:newTimeLimitObject(tagId, nowtime)
    local tagRes = StatusTagsResourceHelper:getStatusTagRes(tagId)
    local time_type_func = TIME_TAG_TYPE_FUNC[tonumber(tagRes.arg1)]
    nowtime = nowtime or GetTime()

    if not time_type_func then
        error("newTimeLimitObject Invalid time type: " .. tagRes.arg1)
    end

    local obj = time_type_func.new(tagRes, nowtime)

    obj.value = -1

    obj._rtime = tagRes.arg2 -- 获取时版本时间

    return obj
end

return TimeLimitStatusTagHelper
00000000
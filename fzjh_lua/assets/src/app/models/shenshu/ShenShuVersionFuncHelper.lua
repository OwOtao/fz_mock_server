--[[
神书不同版本方法差异
1、刷新周期
2、周期内可完成次数
3、周期完成后提示
]]
local DebugHelper = require("app.views.layer.DebugLayer.DebugHelper")
local ShenShuVersionFuncHelper = {}
local ShenShuVersion = {
    NewVersion = 1,
    OldVersion = 0
}
--[[
    @desc: 周期内最大可完成次数
    author:tanqinjian
    time:2025-06-07 18:14:12
    --@version: 
    @return: number
]]
function ShenShuVersionFuncHelper:getMaxCount(version)
    if version == ShenShuVersion.NewVersion then
        return 7
    elseif version == ShenShuVersion.OldVersion then
        return 1
    end
end

--[[
    @desc: 周期内超过可完成次数提示
    author:tanqinjian
    time:2025-06-07 18:20:45
    --@version: 
    @return: string
]]
function ShenShuVersionFuncHelper:getCountLimitMsg(version)
    if version == ShenShuVersion.NewVersion then
        return "本周可寻找神书次数已满，请下周再尝试寻找"
    elseif version == ShenShuVersion.OldVersion then
        return "您今天已经开启过一次神书任务了。"
    end
end

--[[
    @desc: 是否需要周期更新
    author:tanqinjian
    time:2025-06-07 18:21:22
    --@version: 
    --@current_time：当前时间
    --@shenShuTime: 周期内第一次灵石开启时间
    @return: Boolean
]]
function ShenShuVersionFuncHelper:checkNeedResetTask(current_time, shenShuTime, version)
    if shenShuTime == -1 then
        return false
    end

    if not current_time then
        assert(false, "ShenShuVersionFuncHelper:checkNeedResetTask 参数错误，current_time不能为空")
    end

    if version == ShenShuVersion.OldVersion then
        if Helper:diffWithDate(current_time, shenShuTime) >= 1 then
            return true
        end

        return false
    elseif version == ShenShuVersion.NewVersion then
        local currWeekdy = tonumber(Helper:date("%w", current_time))
        local today = Helper:date("*t", current_time)
        local daysFromMonday = currWeekdy == 0 and 6 or (currWeekdy - 1)
        local monday = {
            year = today.year,
            month = today.month,
            day = today.day - daysFromMonday,
            hour = 0,
            min = 0,
            sec = 0
        }

        local time = os.time(monday)

        if shenShuTime < time then
            return true
        end

        return false
    end
end

return ShenShuVersionFuncHelper
0000
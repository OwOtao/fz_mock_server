local antiTime = require("script.others.antiTime")["1"]
local AntiAddictionSystem = {
    __currTime = nil,
    __holidays = {},
    __forbidDays = {}
}

local function initDaysConfig()
    for k, v in pairs(antiTime) do
        local info = {
            year = v.year,
            month = v.month,
            day = v.day
        }

        if v.state == 1 then
            table.insert(AntiAddictionSystem.__holidays,info)
        elseif v.state == 2 then
            table.insert(AntiAddictionSystem.__forbidDays,info)
        end
    end
end

initDaysConfig()

--是否开启防沉迷
--true 代表开启
function AntiAddictionSystem:isOpen()
    if not self.__currTime then
        error("防沉迷代码有误")
    end
    
    --法定加班日需要开启
    if self:isForbidDay() then
        return true
    end

    --正常星期五-星期日以及法定节假日晚上八点到九点
    local week = {Monday = false,Tuesday = false,Wednesday = false,Thursday = false,Friday = true,Saturday = true,Sunday = true}

    if (self:isHoliday() == true or week[Helper:date("%A", self.__currTime)] == true) and tonumber(Helper:date("%H", self.__currTime)) == 20 then
        return false
    end

    return true
end

function AntiAddictionSystem:setTime(time)
    self.__currTime = time
end

function AntiAddictionSystem:isForbidDay()
    local date = Helper:date("*t", self.__currTime)
    for k, v in pairs(self.__forbidDays) do
        if v.year == date.year and v.month == date.month and v.day == date.day then
            return true
        end
    end

    return false
end
    
function AntiAddictionSystem:isHoliday()
    local date = Helper:date("*t", self.__currTime)
    for k, v in pairs(self.__holidays) do
        if v.year == date.year and v.month == date.month and v.day == date.day then
            return true
        end
    end

    return false
end 

return AntiAddictionSystem00
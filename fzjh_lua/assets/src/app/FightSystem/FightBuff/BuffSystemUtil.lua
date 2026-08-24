local LogSystem = require("app.models.LogSystem.LogSystem")

local BuffSystemUtil = {}

function BuffSystemUtil:log(...)
    return LogSystem:logWithTab("增益日志:", ...)
end

return BuffSystemUtil
0000000000000
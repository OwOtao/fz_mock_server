local LianGongParamsManager = {}

function LianGongParamsManager:getConfContent(id)
    local paramConf = require("script.skill.liangongParamsConf")["通用参数"]

    if paramConf[tostring(id)] == nil then
        error("练功参数找不到 id = "..id)
    end
    
    return paramConf[tostring(id)].content
end

return LianGongParamsManager000000000
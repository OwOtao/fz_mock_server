local configRes = require("script.skill.activeZhaoMeditateConst")["data"]

local ActiveZhaoConst = {}

function ActiveZhaoConst:getConf(id)
    if configRes[tostring(id)] == nil then
        error("ActiveZhaoConst:getConf  常量id 找不到 id = "..id)
    end

    return configRes[tostring(id)].content
end

return ActiveZhaoConst
00000
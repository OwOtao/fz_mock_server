local EffectConst = {}

function EffectConst:getConstById(id)
    local paramConf = require("script.skill.activeZhaoEffectConst")["data"]

    if paramConf[tostring(id)] == nil then
        error("主动效果通用参数找不到 id = "..id)
    end
    
    return paramConf[tostring(id)].content
end

return EffectConst00
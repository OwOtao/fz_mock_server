local resConf = require("script.newbattle.demo.prepSkillQualityConf")["武学品质"]

local PrepSkillQualityConf = {}

function PrepSkillQualityConf:get(id)
    local info = resConf[tostring(id)]

    if info == nil then
        assert(false, "武功准备武学品质属性. 没有 id 为 ：" .. id .. " 的属性配置！")
    end

    return info
end

return PrepSkillQualityConf0
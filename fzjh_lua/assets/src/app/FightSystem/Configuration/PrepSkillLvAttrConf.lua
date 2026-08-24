local resConf = require("script.newbattle.demo.prepSkillLvAttrConf")["准备武学等级"]

local PrepSkillLvAttrConf = {}

function PrepSkillLvAttrConf:get(lv)
    local info = resConf[tostring(lv)]

    if info == nil then
        assert(false, "准备武学等级属性 没有 id 等级为 ：" .. lv .. " 的属性配置！")
    end

    return info
end

return PrepSkillLvAttrConf0000000000000000
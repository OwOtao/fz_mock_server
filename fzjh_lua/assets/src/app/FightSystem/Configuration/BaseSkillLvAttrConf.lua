local resConf = require("script.newbattle.demo.baseSkillLvAttrConf")["基本武学等级"]

local BaseSkillLvAttrConf = {}

function BaseSkillLvAttrConf:get(lv)
    local info = resConf[tostring(lv)]

    if info == nil then
        assert(false, "武功基本武学等级属性 没有 id 等级为 ：" .. lv .. " 的属性配置！")
    end

    return info
end

return BaseSkillLvAttrConf
00000000
--[[
    author:Seven
    time:2022-09-20 10:45:31
    desc: 技能系统相关检测
]]
local SkillCheckUtil = {}

function SkillCheckUtil.CheckOldSkillIdCompareNewSkillIdWithoutZhiShi()
    local old_skill_datas = require("script.skill.skill")["skills"]

    local new_skill_datas = require("script.newbattle.demo.skillRes")["武学"]

    local loseList = {}

    local old_count = 0
    local new_count = 0
    for k, v in pairs(new_skill_datas) do
        new_count = new_count + 1
    end

    for o_id, o_data in pairs(old_skill_datas) do
        local isNotZhishi = false
        if o_data.type == 1 or o_data.type == 2 then
            isNotZhishi = true
            old_count = old_count + 1
        end

        if isNotZhishi then
            if new_skill_datas[o_data.id] == nil then
                table.insert(loseList, o_data.id)
            end
        end
    end

    if table.getn(loseList) > 0 then
        PopText("数据不齐，详情请看控制台！")

        print("确实数据信息：")
        for i, v in ipairs(loseList) do
            print(i, v)
        end
    else
        PopText("检测完成，无缺失")
        
        print("旧武学检测非知识类数据数量：" .. old_count)
        print("新武学表总数据数量：" .. new_count)
    end
end

return SkillCheckUtil
000000000000000
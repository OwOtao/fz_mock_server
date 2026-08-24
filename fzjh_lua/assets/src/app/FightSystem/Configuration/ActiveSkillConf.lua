--[[
    author:Seven
    time:2022-09-22 16:40:30
    desc: 主动技能配置
]]
--@region 主动招式组合初始资源
local activeRes = require("script.newbattle.demo.activeZhaoComb")["主动招式组合"]
local active_comb_group = {}
local function initActiveCombGroup()
    for a_zhaoId, res in pairs(activeRes) do
        if active_comb_group[res.activeId] == nil then
            active_comb_group[res.activeId] = {}
        end
        if active_comb_group[res.activeId][res.activeLevel] ~= nil then
            assert(false, "主动招式组合 - 招式编号： " .. res.id .. "等级填写重复。请检查。")
        end
        active_comb_group[res.activeId][res.activeLevel] = res
    end
end
initActiveCombGroup()
--@endregion

local ActiveZhaoInfo_Res = require("script.newbattle.demo.activeZhaoInfo")["主动招式"]

local ActiveSkillConf = {}

function ActiveSkillConf:getActiveCombGroupRes()
    return active_comb_group
end

function ActiveSkillConf:getActiveCombGroupList(active_id)
    local active_group = active_comb_group[active_id]
    if active_group == nil then
        assert(false, "ActiveSkillConf:getActiveCombGroupRes 没有该主动技能招式组合相对应的信息 id：" .. tostring(active_id))
    end
    return active_group
end

function ActiveSkillConf:getActiveSkillResByAIdAndLevel(active_id, level)
    local group = self:getActiveCombGroupList(active_id)

    local active_res = group[level]
    if active_res == nil then
        assert(false, "ActiveSkillConf:getActiveSkillRes 没有该主动技能组合 id：" .. tostring(active_id) .. " 所对应的等级 ：" .. tostring(level))
    end

    return active_res
end

--@desc: 查找主动技能是否存在（由于旧版主动技能未完全移植，可能出现旧版主动技能投放但新版未投放的情况，因此该方法拿来判断该技能是否已投放）
--@author:Seven
--@time:2022-09-22 17:09:53
--@active_id: 主动技能id
--@return: true | false
function ActiveSkillConf:findActiveSkillRes(active_id)
    return active_comb_group[active_id] ~= nil
end

function ActiveSkillConf:getActiveZhaoInfo(zhao_info_id)
    local res = ActiveZhaoInfo_Res[zhao_info_id]

    if res == nil then
        assert(false, "武功主动招式 配置表中没有该id：" .. tostring(zhao_info_id) .. " 所对应的信息")
    end

    return res
end

function ActiveSkillConf:getActiveSkillResByCombId(active_comb_id)
    return assert(activeRes[tostring(active_comb_id)], "ActiveSkillConf:getActiveSkillResByCombId 无法找到 id " .. tostring(active_comb_id))
end

return ActiveSkillConf
00000000
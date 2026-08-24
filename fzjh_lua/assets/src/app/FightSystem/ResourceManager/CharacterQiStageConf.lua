local battleQiPercentConf = require("script.newbattle.demo.battleQiPercentConf")["角色气血状态"]

local qiPercentGroup = {}
local function initQiPercentConf()
    for _, v in pairs(battleQiPercentConf) do
        table.insert(qiPercentGroup, v)
    end

    table.sort(
        qiPercentGroup,
        function(a, b)
            return a.qiScale < b.qiScale
        end
    )
end

initQiPercentConf()

local CharacterQiStageConf = {}

function CharacterQiStageConf:getQiStageText(id)
    return battleQiPercentConf[tostring(id)].describe
end

function CharacterQiStageConf:getStage(percent)
    for i = 1, #qiPercentGroup do
        local qiPercentStage = qiPercentGroup[i]

        if percent < qiPercentStage.qiScale then
            local index = i - 1

            return qiPercentGroup[index].id
        else
            if i == #qiPercentGroup then
                return qiPercentStage.id
            end
        end
    end
end

return CharacterQiStageConf
000000000000
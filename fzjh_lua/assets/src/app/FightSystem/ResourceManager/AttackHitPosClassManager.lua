local attackHitPosRes = require("script.newbattle.demo.attackHitPosRes")["命中部位"]

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local posClassRes = {}
local initHitPosRes = function()
    for k, v in pairs(attackHitPosRes) do
        if posClassRes[v.hurtPosClass] == nil then
            posClassRes[v.hurtPosClass] = {}
        end

        table.insert(posClassRes[v.hurtPosClass], v)
    end

    for hurtPosClass, posClassInfos in pairs(posClassRes) do
        table.sort(
            posClassInfos,
            function(a, b)
                return a.id > b.id
            end
        )
    end
end
initHitPosRes()

local AttackHitPosManager = {}

function AttackHitPosManager:randomHitPosNameByPosClass(posClass)
    local posClassInfos = posClassRes[posClass]

    if posClassInfos == nil then
        error(string.format("AttackHitPosManager:randomHitPosNameByPosClass 没有命中部位系列（hurtPosClass）：%s 对应信息", posClass))
    end

    local randIndex = FightUtil:random(1,#posClassInfos)

    local hitPosClassInfo = posClassInfos[randIndex]

    return hitPosClassInfo.hurtPosName
end

return AttackHitPosManager
00
local FightRoleFormula = {
    caches = {},
    formulas = {
        --@desc 命中率
        hitRate = function(params)
            local selfHitRate = assert(params.selfHitRate)
            local selfZhaoHitRate = assert(params.selfZhaoHitRate)
            local selfExp = assert(params.selfExp)
            local targetExp = assert(params.targetExp)

            return selfHitRate * (1 + selfZhaoHitRate) * (2 / (1 + 3 ^ ((targetExp - selfExp) / (targetExp + selfExp))))
        end,
        --@desc 闪避百分比
        dodgePercent = function(params)
            local selfHitRate = assert(params.selfHitRate)
            local targetDodge = assert(params.dodgeRage)
            return math.floor(targetDodge / (targetDodge + selfHitRate) * 100)
        end,
        --@desc 招架百分比
        parryPercent = function(params)
            local selfHitRate = assert(params.selfHitRate)
            local targetDodge = assert(params.targetDodge)
            local targetParry = assert(params.targetParry)

            return math.floor((targetDodge + targetParry) / (targetDodge + targetParry + selfHitRate) * 100)
        end
    }
}

function FightRoleFormula:call(name, params)
    params = self:map(params)
    return self:get(name)(params)
end

function FightRoleFormula:map(params)
    for k, v in pairs(params) do
        if type(v) == "function" then
            params[k] = v()
        end
    end
    return params
end

function FightRoleFormula:get(name)
    return self.formulas[name]
end

-- local function test()
--     local qimax =FightRoleFormula:call("qiMax", {age = function()return 1 end, neiliMax = 1, factor = 1, neiLiLimit = 1, effectCon = 1, con = 1})
--     print(qimax)
-- end

-- test()

return FightRoleFormula
0
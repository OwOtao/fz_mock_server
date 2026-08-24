local familyFactorRes = require("script.family.family")["familys"]

local FamilyFactor = require("app.models.family.FamilyFactor")

local FamilyFactory = {
    factors = {}
}

--@desc: 获取门派信息
--@author:Seven
--@time:2021-10-22 16:08:28
--@id: 门派ID
--@return [src.app.models.family.FamilyFactor#FamilyFactor]
function FamilyFactory:getFamilyFactor(id)
    if self.factors[tostring(id)] == nil then
        local res = familyFactorRes[tostring(id)]

        if res == nil then
            assert(false, '门派系数表中未找到id为"' .. tostring(id) .. '" 的资源。')
        end

        local p = FamilyFactor:create(res)

        self.factors[tostring(id)] = p
    end

    return self.factors[tostring(id)]
end

return FamilyFactory
00000000000
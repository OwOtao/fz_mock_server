local Poison = {}

local res = require("script.others.poison")

local PoisonList = res["poison"]

local FormulaList = res["formula"]



--@desc: 获取毒药的效果id
--@author:Liang SongQiang
--@time:2018-01-07 22:06:52
--@poisonId: 毒药ID
function Poison:getEffectByPId(poisonId)
    local effectIdStrs = Item:getOneItemByKey(poisonId).effect_1

    if effectIdStrs == "" or effectIdStrs == nil then
        assert(false, poisonId .. "这个毒药没效果，检查资源")
        return
    end

    local _effectIdList = string.split(effectIdStrs, ";")

    local _effectList = {}

    for _, e_ids in ipairs(_effectIdList) do
        --@desc 增加随机效果
        local e_id_array = string.split(e_ids,",")
        local e_id = ""
        if #e_id_array > 1 then
            local index = math.random( 1,#e_id_array )
            e_id = e_id_array[index]
        else
            e_id = e_id_array[1]
        end
        local effect = assert(clone(Skill:getSkillEffect(e_id)), e_id .. "效果不存在，检查资源")
        table.insert(_effectList,effect)
    end

    return _effectList
end

--@desc: 获取毒药配方
--@author:Liang SongQiang
--@time:2018-01-07 21:23:29
--@poId: 毒药ID
function Poison:getPoisonFormula(poisonId)
    local pfId = Item:getOneItemByKey(poisonId).formula
    if pfId == nil or pfId == "" then
        assert(false, poisonId .. "配方ID有问题，检查资源")
    end

    if FormulaList[pfId] == nil then
        assert(false, pfId .. "配方不存在，检查毒药资源")
    end

    return FormulaList[pfId]
end

--@desc: 通过毒药ID获得毒药对应的技能
--@author:Liang SongQiang
--@time:2018-01-21 16:32:26
--@poisonId: 毒药ID
function Poison:getPoisonSkillById(poisonId)
    local pf = self:getPoisonFormula(poisonId)
    return pf.skillid
end

return Poison
00000000000
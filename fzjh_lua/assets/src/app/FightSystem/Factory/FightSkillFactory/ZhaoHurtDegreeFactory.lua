local ActiveZhaoHurtDegree_Res = require("script.newbattle.demo.activeZhaoHurtDegree")["动态伤害"]

local ActiveZhaoHurt_Res = require("script.newbattle.demo.activeZhaoHurt")["主动伤害组"]

--@region 伤害强度资源初始化
local hurtDegreeGroup_Res = {}
local function initHurtDegreeGroup()
    for k, v in pairs(ActiveZhaoHurtDegree_Res) do
        if hurtDegreeGroup_Res[v.hurtDegreeID] == nil then
            hurtDegreeGroup_Res[v.hurtDegreeID] = {}
        end

        if hurtDegreeGroup_Res[v.hurtDegreeID][v.order] ~= nil then
            assert(false, "伤害强度 id : " .. v.id .. " 条件判断顺序重复。")
        end

        hurtDegreeGroup_Res[v.hurtDegreeID][tonumber(v.order)] = v
    end
end
initHurtDegreeGroup()
--@endregion

local ActiveZhaoHurt = require("app.FightSystem.CharacterHurt.AttackHurt.ActiveZhaoHurt")

local HurtDegree = require("app.FightSystem.FightSkill.HurtDegree")

local ZhaoHurtDegreeFactory = {}

--@desc: 主动技能组合伤害创建工厂类
--@author:Seven
--@time:2021-06-17 20:31:56
--@id: 招式伤害id
--@return [src.app.FightSystem.CharacterHurt.AttackHurt.ActiveZhaoHurt#ActiveZhaoHurt]
function ZhaoHurtDegreeFactory:createActiveZhaoHurt(id)
    local hurt_res = ActiveZhaoHurt_Res[id]

    if hurt_res == nil then
        assert(false, "主动伤害 没有找到 id : " .. id .. " 资源")
    end

    --@RefType [src.app.FightSystem.CharacterHurt.AttackHurt.ActiveZhaoHurt#ActiveZhaoHurt]
    local zhao_hurt = ActiveZhaoHurt:create()

    zhao_hurt:setZhaoHurtRes(hurt_res)

    return zhao_hurt
end

--@desc: 
--@author:Seven
--@time:2021-07-05 12:02:39
--@id: id
--@character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@return [src.app.FightSystem.FightSkill.HurtDegreeGroup#HurtDegreeGroup]
function ZhaoHurtDegreeFactory:createHurtDegreeGroup(id, character)
    local HurtDegreeGroup = require("app.FightSystem.FightSkill.HurtDegreeGroup")

    local p = HurtDegreeGroup:create(id)

    p:setCharacter(character)

    return p
end

function ZhaoHurtDegreeFactory:createHurtDegreeByGroupID(hurtDegreeId)
    local groupRes = hurtDegreeGroup_Res[hurtDegreeId]
    assert(groupRes ~= nil, "伤害强度 id : " .. hurtDegreeId .. " 没有找到资源")

    local group = {}
    for i = 1, #groupRes do
        local hurtDegreeRes = groupRes[i]

        local hurtDegree = self:createHurtDegree(hurtDegreeRes.id)

        table.insert(group, hurtDegree)
    end

    return group
end

--@desc: 伤害强度对象创建
--@author:Seven
--@time:2021-06-17 20:51:25
--@degree_id: 攻击伤害强度id
--@return [src.app.FightSystem.FightSkill.HurtDegree#HurtDegree]
function ZhaoHurtDegreeFactory:createHurtDegree(degree_id)
    local degree_res = ActiveZhaoHurtDegree_Res[tostring(degree_id)]

    if degree_res == nil then
        assert(false, "伤害强度 没有找到 id : " .. degree_id .. " 资源")
    end

    --@RefType [src.app.FightSystem.FightSkill.HurtDegree#HurtDegree]
    local hurt_degree = HurtDegree:create()

    hurt_degree:setHurtDegreeRes(degree_res)

    return hurt_degree
end

function ZhaoHurtDegreeFactory:createHurtDegreeArray(hurtDegreeID)
    return table.map(
        hurtDegreeGroup_Res[hurtDegreeID],
        function(item)
            return self:createHurtDegree(item.id)
        end
    )
end

return ZhaoHurtDegreeFactory
000000000000000
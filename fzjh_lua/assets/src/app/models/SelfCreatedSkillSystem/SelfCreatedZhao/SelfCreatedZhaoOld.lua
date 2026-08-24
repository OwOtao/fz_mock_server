local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local inherit = require("third.inherit.inherit")
local SelfCreatedZhao = require("app.models.SelfCreatedSkillSystem.SelfCreatedZhao.SelfCreatedZhao")
local log = function(...)
    if DEBUG_MODE == 1 then
        print(...)
    end
end


local SelfCreatedZhaoOld = {}

local function combineFields(params, fieldNames)
    local combined = {}

    for i = 1, 99999 do
        local item = {}
        local hasValue = false
        for _, fieldName in ipairs(fieldNames) do
            local fieldNameInParams = fieldName .. tostring(i)
            item[fieldName] = params[fieldNameInParams]
            if params[fieldNameInParams] then
                hasValue = true
            end
        end
        if hasValue then
            table.insert(combined, item)
        else
            break
        end
    end

    return combined
end

function SelfCreatedZhaoOld:create(data,newSkill)
    local p = {}
    p._newZhao = SelfCreatedZhao:create(data)
    if newSkill then
        newSkill:setSkillUniverseValue(p._newZhao)
    end
    setmetatable(p, {
        __index = function(tb, key)
            if SelfCreatedZhaoOld[key] == nil then
                return nil
            end
            local value = SelfCreatedZhaoOld[key](tb)
            return value
        end
    })

    return inherit({}, p)
end

function SelfCreatedZhaoOld:name()
    return self._newZhao:getName()
end

function SelfCreatedZhaoOld:id()
    return self._newZhao:getId()
end

function SelfCreatedZhaoOld:lv()
    return self._newZhao:getGrade()
end

function SelfCreatedZhaoOld:atk()
    local factor = SelfCreatedSkillManager:getParamsById("transform_nAtk")
    log("-----------攻击性能,转换系数,转换后的数值-------------",self._newZhao:getAttack(),factor,self._newZhao:getAttack()*factor)
    return self._newZhao:getAttack()*factor
end

function SelfCreatedZhaoOld:hitRate()
    local factor = SelfCreatedSkillManager:getParamsById("transform_hit")
    log("-----------命中性能,转换系数,转换后的数值-------------",self._newZhao:getHit(),factor,self._newZhao:getHit()*factor)
    return self._newZhao:getHit()*factor
end

function SelfCreatedZhaoOld:dam()
    local factor = SelfCreatedSkillManager:getParamsById("transform_dam")
    log("-----------伤害性能,转换系数,转换后的数值-------------",self._newZhao:getTopLimit(),factor,self._newZhao:getTopLimit()*factor)
    return self._newZhao:getTopLimit()*factor
end

function SelfCreatedZhaoOld:parry()
    return SelfCreatedSkillManager:getParamsById("transform_zhaoparry")
end

function SelfCreatedZhaoOld:dodge()
    return SelfCreatedSkillManager:getParamsById("transform_zhaododge")
end

function SelfCreatedZhaoOld:preDuration()
    return SelfCreatedSkillManager:getParamsById("transform_preDuration")
end

function SelfCreatedZhaoOld:aftDuration()
    local factor = SelfCreatedSkillManager:getParamsById("transform_aftDuration")
    log("-----------体力消耗性能,转换系数,转换后的数值-------------",self._newZhao:getSpirit(),factor,self._newZhao:getSpirit()*factor)
    return self._newZhao:getSpirit()*factor
end

function SelfCreatedZhaoOld:skillText()
    return self._newZhao:getName()
end

function SelfCreatedZhaoOld:action()
    return self._newZhao:getAction()
end

function SelfCreatedZhaoOld:anims()
    local anims = combineFields(self._newZhao:getData(), { "anim", "offset", "speed", "hitPos" })
    return anims
end

function SelfCreatedZhaoOld:getHitPos1Name()
    return self._newZhao:getHitPosName(self._newZhao:getHitPos1())
end

function SelfCreatedZhaoOld:getAttackLevel()
    return self._newZhao:getAttackLevel()
end

function SelfCreatedZhaoOld:getHitLevel()
    return self._newZhao:getHitLevel()
end

function SelfCreatedZhaoOld:getTopLimitLevel()
    return self._newZhao:getTopLimitLevel()
end

function SelfCreatedZhaoOld:getSpiritLevel()
    return self._newZhao:getSpiritLevel()
end

function SelfCreatedZhaoOld:getAttackAddLevel()
    return self._newZhao:getAttackAddLevel()
end

function SelfCreatedZhaoOld:getHitAddLevel()
    return self._newZhao:getHitAddLevel()
end

function SelfCreatedZhaoOld:getDsc()
    return SelfCreatedSkillManager:getUnsignedZhaoDescByActionId(self._newZhao:getDscId(),self._newZhao)
end

function SelfCreatedZhaoOld:getAffixs()
    return self._newZhao:getAffixs()
end

function SelfCreatedZhaoOld:getIndex()
    return self._newZhao:getIndex()
end

return SelfCreatedZhaoOld0
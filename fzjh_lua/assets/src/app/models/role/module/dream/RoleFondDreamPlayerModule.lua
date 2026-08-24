local Module = require("third.module.Module")
local RoleFondDreamPlayerModule = class("RoleFondDreamPlayerModule", Module)

function RoleFondDreamPlayerModule:ctor()
    -- 模块名
    self._name = "RoleFondDreamPlayerModule"
end

function RoleFondDreamPlayerModule:onAttach(target)
    self:initAttrDepends(target)
    self:initAttrWatcher(target)
end

function RoleFondDreamPlayerModule:initAttrDepends(target)
    self._attrDepends = {
        exp = {
            lv = {},
        },
        lv = {
            exp = {}
        },
        qi = {},
        qiMax = {
            qi = {}
        },
        neili = {},
        secCon = {},
        secStr = {},
        secDex = {},
    }
end

function RoleFondDreamPlayerModule:initAttrWatcher(target)
    -- 先准备公式需要的参数, 写成方法的形式, 懒加载

    -- 内功生命系数
    local factor = function()
        return target:getPrepareSkillFactor("neigong", "HpRate")
    end
    local age = function()
        return target:getAttr("age")
    end
    local neiliMax = function()
        return target:getAttr("neiliMax")
    end
    local neiLiLimit = function()
        return target:getNeiLiLimit()
    end
    local effectCon = function()
        return target:getEffectCon()
    end
    local con = function()
        return target:getFinalAttr("con")
    end
    self._attrFunc = {
        exp = function()
            local lv = target:getLv()

            local skills = target:getSkills()
            for skillId, skillInfo in pairs(skills) do
                if Skill:isBaseAutoSkill(skillId) then
                    local skillLv = target:getSkillLv(skillId)
                    if skillLv ~= lv then
                        local maxLv = target:getSkillLvLimit()

                        local resultLv
                        if lv > maxLv then
                            resultLv = maxLv
                        else
                            resultLv = lv
                        end

                        if skillLv < resultLv then
                            local skillExp = target:conversionSkillExpAndLv("exp", resultLv)
                            skillInfo.exp = skillExp
                            target:setSkill(skillInfo.id, skillInfo)
                        end
                    end
                end
            end

            -- 经验影响角色等级
            target:setAttr("lv", target:getLv())
        end,
        lv = function(new, old, change)
            -- 角色等级影响经验
            target:setAttr("exp", target:getExp())

            if change > 0 then
                PopText(string.format("你的实力有所提升，等级增加%d级", change))
            end
        end,
        qi = function()
            if target:getAttr("qi") > target:getCurrQiMax() then
                target:setAttr("qi", target:getCurrQiMax())
            end
        end,
        qiMax = function(newValue, oldValue, valueChange)
            target:addAttr("qi", valueChange * target:getAttr("qiPercent"))

            -- 超过上限处理
            if target:getAttr("qi") > target:getCurrQiMax() then
                target:setAttr("qi", target:getCurrQiMax())
            end
        end,
        neili = function()
            -- 内力不能超过上限
            local neiliMax = target:getFinalAttr("neiliMax")
            if target:getAttr("neili") > neiliMax then
                target:setAttr("neili", neiliMax)
            end
        end,
        secCon = function()
            target:checkActiveZhaoIsDeblocking()
        end,
        secStr = function()
            target:checkActiveZhaoIsDeblocking()
        end,
        secDex = function()
            target:checkActiveZhaoIsDeblocking()
        end,
    }
end

function RoleFondDreamPlayerModule:initAttr(target)
    for attrName, func in pairs(self._attrFunc) do
        if type(func) == "function" then
            func(target:getFinalAttr(attrName), target:getFinalAttr(attrName), 0)
        end
    end
end

-- 初始化属性监控
function RoleFondDreamPlayerModule:initAttrMonitor(target)
    target:watchFinalAttrChangeWithDependMap(self._attrDepends, self._attrFunc)

    return true
end

function RoleFondDreamPlayerModule:acceptMapFightResult(target, role, fightType)
    return true
end

function RoleFondDreamPlayerModule:checkAttr(target, name)
    return true
end

return RoleFondDreamPlayerModule
000
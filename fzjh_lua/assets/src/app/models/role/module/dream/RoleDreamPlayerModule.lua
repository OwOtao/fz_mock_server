local Module = require("third.module.Module")
local RoleFormula = require("app.models.formula.RoleFormula")
local RoleDreamPlayerModule = class("RoleDreamPlayerModule", Module)
local SOBER_LIMIT = require("app.models.DreamWorldModel.DreamConst").SOBER_LIMIT


function RoleDreamPlayerModule:ctor()
    -- 模块名
    self._name = "RoleDreamPlayerModule"
end

function RoleDreamPlayerModule:onAttach(target)
    self:initAttrDepends(target)
    self:initAttrWatcher(target)
end

function RoleDreamPlayerModule:initAttrDepends(target)
    self._attrDepends = {
        exp = {
            lv = {},
            secDex = {
                neiLiLimit = {
                    neiliMax = {
                        qiMax = {},
                        neili = {}
                    },
                    qiMax = {},
                    neili = {}
                },
                qiMax = {}
            },
            secStr = {
                neiLiLimit = {
                    neiliMax = {
                        qiMax = {},
                        neili = {}
                    },
                    qiMax = {},
                    neili = {}
                },
                qiMax = {}
            },
            secCon = {
                neiLiLimit = {
                    neiliMax = {
                        qiMax = {},
                        neili = {}
                    },
                    qiMax = {},
                    neili = {}
                },
                qiMax = {}
            },
            secInt = {}
        },
        lv = {
            exp = {
                lv = {},
                secDex = {
                    neiLiLimit = {
                        neiliMax = {
                            qiMax = {},
                            neili = {}
                        },
                        qiMax = {},
                        neili = {}
                    },
                    qiMax = {}
                },
                secStr = {
                    neiLiLimit = {
                        neiliMax = {
                            qiMax = {},
                            neili = {}
                        },
                        qiMax = {},
                        neili = {}
                    },
                    qiMax = {}
                },
                secCon = {
                    neiLiLimit = {
                        neiliMax = {
                            qiMax = {},
                            neili = {}
                        },
                        qiMax = {},
                        neili = {}
                    },
                    qiMax = {}
                },
                secInt = {}
            }
        },
        jing = {},
        qi = {},
        qiMax = {
            qi = {}
        },
        age = {
            jingMax = {},
            qiMax = {}
        },
        con = {
            qiMax = {}
        },
        secCon = {
            neiLiLimit = {
                neiliMax = {
                    qiMax = {},
                    neili = {}
                },
                qiMax = {},
                neili = {}
            },
            qiMax = {}
        },
        secStr = {
            neiLiLimit = {
                neiliMax = {
                    qiMax = {},
                    neili = {}
                },
                qiMax = {},
                neili = {}
            },
            qiMax = {}
        },
        secDex = {
            neiLiLimit = {
                neiliMax = {
                    qiMax = {},
                    neili = {}
                },
                qiMax = {},
                neili = {}
            },
            qiMax = {}
        },
        neiLiLimit = {
            neiliMax = {
                qiMax = {},
                neili = {}
            },
            qiMax = {},
            neili = {}
        },
        neiliMax = {
            qiMax = {},
            neili = {}
        },
        neili = {},
        qiPercent = {},
        neigong = {
            qiMax = {},
            jiaLi = {},
            neiLiLimit = {
                neiliMax = {
                    qiMax = {},
                    neili = {}
                },
                qiMax = {},
                neili = {}
            }
        },
        leftRightFightExp = {},
        sober = {}
    }
end

function RoleDreamPlayerModule:initAttrWatcher(target)
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
            target:setAttr("qiMax", RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con}))
        end,
        lv = function(new, old, change)
            -- 角色等级影响经验
            target:setAttr("exp", target:getExp())

            if change > 0 then
                PopText(string.format("你的实力有所提升，等级增加%d级", change))
            end
        end,
        jing = function()
            if target:getAttr("jing") > target:getJingMax() then
                target:setAttr("jing", target:getJingMax())
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
        age = function()
            -- 先天根骨
            target:setJingMax()
            target:setAttr("qiMax", RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con}))
        end,
        con = function()
            target:setAttr("qiMax", RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con}))
        end,
        secCon = function()
            target:checkActiveZhaoIsDeblocking()
            target:calcNeiLiLimit()

            target:setAttr("qiMax", RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con}))
        end,
        secStr = function()
            target:checkActiveZhaoIsDeblocking()
            target:calcNeiLiLimit()

            target:setAttr("qiMax", RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con}))
        end,
        secDex = function()
            target:checkActiveZhaoIsDeblocking()
            target:calcNeiLiLimit()

            target:setAttr("qiMax", RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con}))
        end,
        neiLiLimit = function(newValue, oldValue, valueChange)
            local neiliMax_final = target:getFinalAttr("neiliMax")
            local neiLiLimit_final = target:getNeiLiLimit()

            -- 将neiliMax设置等于neiLiLimit
            target:addAttr("neiliMax", neiLiLimit_final - neiliMax_final)

            if target:getAttr("neili") > target:getFinalAttr("neiliMax") then
                target:setAttr("neili", target:getFinalAttr("neiliMax"))
            end
        end,
        neiliMax = function(newValue, oldValue, valueChange)
            local neiliMax_final = target:getFinalAttr("neiliMax")
            local neiLiLimit_final = target:getNeiLiLimit()

            -- 将neiliMax设置等于neiLiLimit
            target:addAttr("neiliMax", neiLiLimit_final - neiliMax_final)

            if target:getAttr("neili") > target:getFinalAttr("neiliMax") then
                target:setAttr("neili", target:getFinalAttr("neiliMax"))
            end
            -- 气血影响
            target:setAttr("qiMax", RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con}))
        end,
        neili = function()
            -- 内力不能超过上限
            local neiliMax = target:getFinalAttr("neiliMax")
            if target:getAttr("neili") > neiliMax then
                target:setAttr("neili", neiliMax)
            end
        end,
        qiPercent = function()
            -- 内功变换时气血上限受影响
            if target:getAttr("qiPercent") > 1 then
                target:setAttr("qiPercent", 1)
            elseif target:getAttr("qiPercent") < 0 then
                target:setAttr("qiPercent", 0)
            end
        end,
        neigong = function()
            -- 加力值需要变化
            local jiaLiMax = target:getJiaLiMax()
            local jiaLi = target:getFinalAttr("jiaLi")
            target:setAttr("jiaLi", math.min(jiaLi, jiaLiMax))
            target:calcNeiLiLimit() -- add by XiaoZhiWei 2017/07/19 09:43:02 基本内容发生变化时,重新计算一下内力上限

            -- 气血影响
            target:setAttr("qiMax", RoleFormula:call("qiMax", {age = age, neiliMax = neiliMax, factor = factor, neiLiLimit = neiLiLimit, effectCon = effectCon, con = con}))
        end,
        leftRightFightExp = function()
            -- 左右互搏经验不超过900
            if target:getAttr("leftRightFightExp") > 901 then
                target:setAttr("leftRightFightExp", 901)
            end
        end,
        sober = function(newValue, oldValue, valueChange)
            --@desc 清醒值消耗完，不再回复
            if oldValue <= 0 then
                target:setAttr("sober", 0)
            end

            --@desc 清醒值上限检查
            if target:getAttr("sober") > SOBER_LIMIT then
                target:setAttr("sober", SOBER_LIMIT)
            end
        end
    }
end

function RoleDreamPlayerModule:initAttr(target)
    print("RoleDreamPlayerModule:onAttach")

    for attrName, func in pairs(self._attrFunc) do
        if type(func) == "function" then
            func(target:getFinalAttr(attrName), target:getFinalAttr(attrName), 0)
        end
    end

    --初始化后恢复满状态
    target.qi = target:getCurrQiMax()
    target.neili = target:getNeiLiLimit()
    target.jing = target:getJingMax()
end

-- 初始化属性监控
function RoleDreamPlayerModule:initAttrMonitor(target)
    target:watchFinalAttrChangeWithDependMap(self._attrDepends, self._attrFunc)

    return true
end

function RoleDreamPlayerModule:acceptMapFightResult(target, role, fightType)
    local fightResultFunc = function(self)
        local qi = role:getAttr("qi")
        local neili = role:getAttr("neili")
        local map = User:getRole():getCurrMap()

        if fightType == "切磋" then
            --@desc 梦境内切磋死亡，血量设置为1
            if role:isDead() then
                qi = 1
                if role:getAttr("qiPercent") <= 0 then
                    role:setAttr("qiPercent",1/role:getAttr("qiMax"))
                end
            end
        else
            --@desc 正气值结算
            local killedRoles = role:getKilledRoles()
            if #killedRoles > 0 then
                local killedRole = killedRoles[1]
                local rZhengQi = self:getAttr("zhengqi")
                local tZhengQi = killedRole:getAttr("zhengqi")

                self:setAttr("zhengqi", tonumber(rZhengQi - tZhengQi))

                User:getRole():getDreamSystem():addDreamRoleSkillZhaoLv(role, target)
            end
        end

        self:setAttr("qiPercent", role:getAttr("qiPercent"))
        self:setAttr("neili", neili)
        self:setAttr("qi", qi)
        self:setFlag("战斗脱离时间", GetTime())

        --@desc 同步buff数据
        role:getRole()._buffManager:serialization()
        self:setAttr("buffs", role:getRole():getAttr("buffs"))
        role:getRole()._buffManager:destory()

        self._buffManager:destory()
        local BuffManager = require("app.models.Buff.BuffManager")
        self._buffManager = BuffManager:create()
        self._buffManager:registerUpdateFunc(
            function()
                self:dispatchEvent("roleBuffUpdate")
            end
        )
        self._buffManager:init(self)
    end
    return true, fightResultFunc(target)
end

function RoleDreamPlayerModule:checkAttr(target, name)
    return true
end

return RoleDreamPlayerModule
0000000
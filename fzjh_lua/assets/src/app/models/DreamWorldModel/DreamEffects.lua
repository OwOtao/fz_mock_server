local DreamEffects = {}

local Emotion = require("script.dreamworld.Emotion")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local EmotionType = DreamConst.EmotionType

local effects = Emotion.effects

local function addRoleAttr(role, attrName, value)
    role:addAttr(attrName, value)
end

local function recoverQi(role, value)
    local drFailRecoverQiRate = role:getFinalAttr("drFailRecoverQiRate")

    if drFailRecoverQiRate > 0 and drFailRecoverQiRate >= math.random(1, 100) then
        PopText("气血恢复失败")
        return
    end

    return addRoleAttr(role, "qi", value)
end

local function addDreamPoints(role, value)

    local addDrPointsPercent = role:getFinalAttr("drAddDreamPointsEffectAdditionPercent")

    value = Helper:mathFloor(value * addDrPointsPercent)

    addRoleAttr(role, "dreamPoints", value)
end

--@desc context = {role = {}, map = {}, roomId = ""}
function DreamEffects:triggerEffect(effectId, context)
    if effects[tostring(effectId)] == nil then
        error("梦境效果 : " .. effectId .. "未定义")
        return
    end

    print("触发效果： " .. effects[tostring(effectId)].name)

    switch(
        tonumber(effectId),
        {
            [1] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                addRoleAttr(role, "neili", math.random(param1, param2) / 100 * role:getAttr("neiliMax"))
            end,
            [2] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                addRoleAttr(role, "neili", math.random(param1, param2) / 100 * role:getAttr("neiliMax"))
            end,
            [3] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                addRoleAttr(role, "neili", -math.random(param1, param2) / 100 * role:getAttr("neiliMax"))
            end,
            [4] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                addRoleAttr(role, "neili", -math.random(param1, param2) / 100 * role:getAttr("neiliMax"))
            end,
            [5] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                recoverQi(role, math.random(param1, param2) / 100 * role:getAttr("qiMax"))
            end,
            [6] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                recoverQi(role, math.random(param1, param2) / 100 * role:getAttr("qiMax"))
            end,
            [7] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                addRoleAttr(role, "qi", -math.random(param1, param2) / 100 * role:getAttr("qiMax"))
            end,
            [8] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                addRoleAttr(role, "qi", -math.random(param1, param2) / 100 * role:getAttr("qiMax"))
            end,
            [9] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                recoverQi(role, math.random(param1, param2) / 100 * role:getAttr("qiMax"))
                addRoleAttr(role, math.random(param1, param2) / 100 * role:getAttr("neiliMax"))
            end,
            [10] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                recoverQi(role, math.random(param1, param2) / 100 * role:getAttr("qiMax"))
                addRoleAttr(role, "neili", math.random(param1, param2) / 100 * role:getAttr("neiliMax"))
            end,
            [11] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                addRoleAttr(role, "qi", -math.random(param1, param2) / 100 * role:getAttr("qiMax"))
                addRoleAttr(role, "neili", -math.random(param1, param2) / 100 * role:getAttr("neiliMax"))
            end,
            [12] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                local param2 = tonumber(effects[tostring(effectId)].param2)
                addRoleAttr(role, "qi", -math.random(param1, param2) / 100 * role:getAttr("qiMax"))
                addRoleAttr(role, "neili", -math.random(param1, param2) / 100 * role:getAttr("neiliMax"))
            end,
            [13] = function(context)
                local role = context.role
                role:addBuffV2(1002)
            end,
            [14] = function(context)
                local role = context.role
                role:addBuffV2(1001)
            end,
            [15] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                addDreamPoints(role,param1)
            end,
            [16] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                addDreamPoints(role,param1)
            end,
            [17] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                addDreamPoints(role,param1)
            end,
            [18] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                addRoleAttr(role, "dreamPoints", -param1)
            end,
            [19] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                addRoleAttr(role, "dreamPoints", -param1)
            end,
            [20] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                addRoleAttr(role, "dreamPoints", -param1)
            end,
            [21] = function(context)
                local role = context.role
                local param1 = tonumber(effects[tostring(effectId)].param1)
                --@desc 触发躲飞镖玩法
                local attackerName = "机关"
                local anqiName = "飞镖"
                local interval = 1.5
                local damagePercent = param1

                local DialogDodgeLayer = require("app.views.layer.MapLayer.DialogDodgeLayer")

                local dodgeLayer = DialogDodgeLayer:createInRunningScene()
                if dodgeLayer:isAvail() == false then
                    print("dodgeLayer is now busy")
                    return
                end

                dodgeLayer:reinit()
                dodgeLayer:setRole(role)
                dodgeLayer:setAttackerName(attackerName)
                dodgeLayer:setAnqiName(anqiName)
                dodgeLayer:setTime(interval)
                dodgeLayer:setDamagePercent(damagePercent)

                dodgeLayer:setResultCallback(
                    function(isSucc)
                        if isSucc == true then
                            print("成功")
                        else
                            print("失败")
                        end
                    end
                )
                dodgeLayer:show()
            end,
            [22] = function(context)
                local role = context.role
                role.emotionMgr:changeEmotion(EmotionType.None)
            end,
            [23] = function(context)
                local role = context.role
                role.emotionMgr:changeEmotion(EmotionType.Impressed)
            end,
            [24] = function(context)
                local role = context.role
                role.emotionMgr:changeEmotion(EmotionType.Ecstasy)
            end,
            [25] = function(context)
                local role = context.role
                role.emotionMgr:changeEmotion(EmotionType.Calmdown)
            end,
            [26] = function(context)
                local role = context.role
                role.emotionMgr:changeEmotion(EmotionType.Fear)
            end,
            [27] = function(context)
                local role = context.role
                role.emotionMgr:changeEmotion(EmotionType.Agitated)
            end,
            [28] = function(context)
                local role = context.role
                role.emotionMgr:changeEmotion(EmotionType.Sad)
            end,
            [29] = function(context)
                local role = context.role
                role:addBuffV2(1004)
            end,
            [30] = function(context)
                local role = context.role
                role:addBuffV2(1005)
            end,
            [31] = function(context)
                local role = context.role
                role:addBuffV2(1003)
            end,
            [35] = function(context)
                local role = context.role
                --@desc 随机一门武学 品级提升1
                -- 玩家任一武学品级+1，不可超过上限
                local skillList = {}
                local skills = role:getSkills()
                if MapIsEmpty(skills) then
                    return
                end
                for k, v in pairs(skills) do
                    if Skill:isBaseAutoSkill(k) == false then
                        table.insert(skillList, k)
                    end
                end
                local skillId = skillList[math.random(1, #skillList)]
                local skillName = Skill:getSkill(skillId).name
                User:getRole():getDreamSystem():addDreamSkillLevel(skillId, role, 1)
                PopText("顿悟武道，" .. skillName .. "进境提升。")
            end,
            default = function()
                error("梦境效果 effectId ：" .. effectId .. "尚未开发！")
            end
        },
        context
    )
end

return DreamEffects
00000000000000
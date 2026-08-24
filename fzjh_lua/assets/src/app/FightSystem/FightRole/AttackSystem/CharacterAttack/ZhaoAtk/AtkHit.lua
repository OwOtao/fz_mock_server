-- local class = require("third.class.NewClass")

-- local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

-- local AttackHurtInfo = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AttackHurtInfo")

-- local FightCommons = require("app.FightSystem.FightCommons")

-- local IZhaoAttack = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack")

-- local AllocHurt = require("app.FightSystem.AttackModel.AllocHurt")

-- local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

-- --@SuperType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
-- local AtkHit = {
--     __hurtType = ATTACK_HIT_TYPE.HIT,
--     __zhaoInfo = nil,
--     __duration = 0,
--     __animName = nil,
--     --@desc 该攻击执行后伤害统计数组(根据命中次数及伤害属性不同生成)
--     __hurtInfoCountArray = {},
--     --@desc 存放根据动画命中分摊伤害（即是动画攻击帧的次数）
--     __qiDamageHurtsByHit = {},
--     __hurts = {},
--     --@desc 存放对攻击者属性变更的结果
--     __attackerAttrHurts = {},
--     --@desc 受击者最终所受属性变更的结果
--     __targetAttrHurts = {},
--     --@desc 存放一次击中的结果对象
--     __hits = {}
-- }

-- function AtkHit:create()
--     return self.new()
-- end

-- function AtkHit:ctor()
-- end

-- --@desc: 攻击者
-- --@author:Seven
-- --@time:2021-12-14 16:03:31
-- --@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
-- function AtkHit:setAttacker(attacker)
--     self.__attacker = attacker
-- end

-- --@desc: 攻击目标
-- --@author:Seven
-- --@time:2021-12-14 16:03:03
-- --@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
-- function AtkHit:setTarget(target)
--     self.__target = target
-- end

-- function AtkHit:setAttackAnims(attackAnims)
--     --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
--     self.__attackAnims = attackAnims
-- end

-- --@return [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
-- function AtkHit:getAttackAnims()
--     return self.__attackAnims
-- end

-- function AtkHit:init()
--     self:__initOneHitAttacks()

--     self:__allocHurts()

--     self:__allocQiDamageHurtByAnimHit()

--     self:__allocAttackerEffectAttrsChangeCauseByQiDamageHurts()

--     self:__allocTargetEffectAttrsChangeCauseByQiDamageHurts()
-- end

-- function AtkHit:__initOneHitAttacks()
--     local animHurtTimes = self.__zhaoInfo:getAnimHurtTimes()
--     local OneHitAttack = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.OneHitAttack")

--     for i = 1, animHurtTimes do
--         table.insert(
--             self.__hits,
--             {
--                 target = OneHitAttack:create(),
--                 attacker = OneHitAttack:create()
--             }
--         )
--     end
-- end

-- --@desc: 根据动画击中次数分摊气血伤害值
-- --@author:Seven
-- --@time:2021-12-07 14:43:27
-- function AtkHit:__allocQiDamageHurtByAnimHit()
--     local totalWeight = self.__zhaoInfo:getTotalAnimHurtWeight()

--     local animHurtTimes = self.__zhaoInfo:getAnimHurtTimes()

--     local hurtTimeWeightArray = self.__zhaoInfo:getAnimHurtWeight()

--     for i = 1, animHurtTimes do
--         local weightValue = hurtTimeWeightArray[i]
--         local qiHurtsByHit = {}
--         --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.OneHitAttack#OneHitAttack]
--         local targetOneHitAttack = self.__hits[i].target

--         if #self.__qiDamageHurts > 0 then
--             for _, qiHurt in ipairs(self.__qiDamageHurts) do
--                 local newQiHurt = qiHurt:allocByWeight(weightValue, totalWeight)
--                 newQiHurt:calActualValue()
--                 table.insert(qiHurtsByHit, newQiHurt)
--                 targetOneHitAttack:addQiDamage(newQiHurt)
--             end
--         end
--         table.insert(self.__qiDamageHurtsByHit, qiHurtsByHit)
--     end
-- end

-- --@desc: 根据动画击中次数分配通用属性伤害
-- --@author:Seven
-- --@time:2021-07-16 22:24:07
-- function AtkHit:__allocHurts()
--     local totalWeight = self.__zhaoInfo:getTotalAnimHurtWeight()

--     local animHurtTimes = self.__zhaoInfo:getAnimHurtTimes()

--     local hurtTimeWeightArray = self.__zhaoInfo:getAnimHurtWeight()

--     for i = 1, animHurtTimes do
--         --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.OneHitAttack#OneHitAttack]
--         local targetOneHitAttack = self.__hits[i].target

--         local weightValue = hurtTimeWeightArray[i]
--         --@RefType [src.app.FightSystem.AttackModel.AllocHurt#AllocHurt]
--         local allocHurt = AllocHurt:create(self.__hurtInfos, totalWeight, weightValue)
--         local newHurts = allocHurt:alloc()

--         table.insert(self.__hurts, newHurts)

--         for _, hurt in ipairs(newHurts) do
--             targetOneHitAttack:addOtherAttrDamageHurt(hurt)
--         end
--     end
-- end

-- --@desc:
-- --@author:Seven
-- --@time:2021-12-03 17:29:58
-- --@array: [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
-- --@return
-- function AtkHit:setZhaoEffectAttrsForAttacker(array)
--     --@desc 攻击者攻击时buff的影响
--     --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
--     self.__attackerEffectAttrsArray = array
-- end

-- --@array: [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
-- function AtkHit:setZhaoEffectAttrsForTarget(array)
--     --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
--     self.__targetEffectAttrsArray = array
-- end

-- function AtkHit:getAnimHurtTimes()
--     return self.__zhaoInfo:getAnimHurtTimes()
-- end

-- function AtkHit:getId()
--     return self.__zhaoInfo:getId()
-- end

-- function AtkHit:getHurtType()
--     return self.__hurtType
-- end

-- function AtkHit:setZhaoInfo(zhaoInfo)
--     --@RefType [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
--     self.__zhaoInfo = zhaoInfo
-- end

-- --@desc: 设置招式本身造成的气血伤害对象
-- --@author:Seven
-- --@time:2021-07-17 16:50:10
-- function AtkHit:setQiDamageHurts(qiHurts)
--     self.__qiDamageHurts = qiHurts
-- end

-- function AtkHit:getQiDamageHurtsByHit()
--     return self.__qiDamageHurtsByHit
-- end

-- function AtkHit:getOneHitAttackByIndex(index)
--     if index <= 0 or index > #self.__hits then
--         error("AtkHit:getOneHitAttackByIndex 索引值小于0 或 大于实际击中次数！ " .. index)
--     end

--     return self.__hits[index]
-- end

-- function AtkHit:getAllQiDamageHurts()
--     local allQiHurts = {}

--     if #self.__qiDamageHurtsByHit <= 0 then
--         return allQiHurts
--     end

--     for _, qiHurts in ipairs(self.__qiDamageHurtsByHit) do
--         if #qiHurts > 0 then
--             for _, qiHurt in ipairs(qiHurts) do
--                 table.insert(allQiHurts, qiHurt)
--             end
--         end
--     end

--     return allQiHurts
-- end

-- function AtkHit:setDuration(duration)
--     self.__duration = duration
-- end

-- function AtkHit:getDuration()
--     return self.__duration
-- end

-- --@desc: 设置该招（一段）攻击的总伤害信息(气血除外)
-- --@author:Seven
-- --@time:2021-07-06 15:13:03
-- --@hurtInfos: 伤害数组 type:[] element:Hurt 存放不同属性伤害
-- function AtkHit:setTotalHurtInfos(hurtInfos)
--     self.__hurtInfos = hurtInfos
-- end

-- function AtkHit:getHurts()
--     return self.__hurts
-- end

-- function AtkHit:getAllOneAttackHit()
--     if #self.__hits <= 0 then
--         error("击中结果没有任何击中相关结果的对象，请检查代码")
--     end

--     return self.__hits
-- end

-- function AtkHit:getAllTargetOneAttackHit()
--     local oneHits = {}
--     for i = 1, #self.__hits do
--         local hit = self.__hits[i]

--         table.insert(oneHits, hit.target)
--     end

--     return oneHits
-- end

-- function AtkHit:getAllAttackerOneAttackHit()
--     local oneHits = {}
--     for i = 1, #self.__hits do
--         local hit = self.__hits[i]

--         table.insert(oneHits, hit.attacker)
--     end

--     return oneHits
-- end

-- function AtkHit:getAllHurts()
--     local allHurts = {}

--     if #self.__hurts <= 0 then
--         return allHurts
--     end

--     for _, hurts in ipairs(self.__hurts) do
--         if #hurts > 0 then
--             for _, hurt in ipairs(hurts) do
--                 table.insert(allHurts, hurt)
--             end
--         end
--     end

--     return allHurts
-- end

-- --@character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
-- function AtkHit:__doAttack(attrHurs, character)
--     if MapIsEmpty(attrHurs) then
--         return
--     end

--     for attrName, value in pairs(attrHurs) do
--         if attrName ~= "qi" and attrName ~= "qiMax" then
--             character:addAttr(attrName, value)
--         end
--     end

--     local qiMaxValue = attrHurs["qiMax"]
--     local qiValue = attrHurs["qi"]

--     if qiMaxValue == nil then
--         qiMaxValue = 0
--     end

--     if qiValue == nil then
--         qiValue = 0
--     end

--     if qiMaxValue > 0 then
--         character:addAttr("qiMax", qiMaxValue)
--     end

--     if qiValue > 0 then
--         character:addAttr("qi", qiValue)
--     end

--     if qiValue < 0 then
--         character:addAttr("qi", qiValue)
--     end

--     if qiMaxValue < 0 then
--         character:addAttr("qiMax", qiMaxValue)
--     end
-- end

-- function AtkHit:__allocAttackerEffectAttrsChangeCauseByQiDamageHurts()
--     local count = self.__attackerEffectAttrsArray:getCount()
--     if count <= 0 then
--         return
--     end

--     local animHurtTimes = self.__zhaoInfo:getAnimHurtTimes()

--     for i = 1, animHurtTimes do
--         local hitAttack = self.__hits[i]

--         for _, qiDamage in ipairs(hitAttack.target:getQiDamages()) do
--             local projectionValue = qiDamage:getProjectionValue()

--             for j = 1, count do
--                 --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
--                 local zhaoAttackAttrsEffect = self.__attackerEffectAttrsArray:get(j)

--                 local attrName = zhaoAttackAttrsEffect:getAttrName()

--                 local percent = zhaoAttackAttrsEffect:getValue()

--                 local targetType = zhaoAttackAttrsEffect:getTargetType()

--                 local value = Helper:mathFloor(projectionValue * percent)

--                 if targetType == "self" then
--                     hitAttack.attacker:addEffectAttrsByQiDamage(
--                         {
--                             ownerId = zhaoAttackAttrsEffect:getOwnerId(),
--                             targetId = self.__attacker:getId(),
--                             effectFuncId = zhaoAttackAttrsEffect:getEffectFuncId(),
--                             attraName = attrName,
--                             value = value
--                         }
--                     )
--                 elseif targetType == "def" then
--                     hitAttack.target:addEffectAttrsByQiDamage(
--                         {
--                             ownerId = zhaoAttackAttrsEffect:getOwnerId(),
--                             targetId = self.__target:getId(),
--                             effectFuncId = zhaoAttackAttrsEffect:getEffectFuncId(),
--                             attraName = attrName,
--                             value = value
--                         }
--                     )
--                 else
--                     error(' AtkHit:__doTargetEffectAttrs 不应该存在目标类型是 "self" 和 "atk" 外的类型，请检查代码。传入值：' .. targetType)
--                 end
--             end
--         end
--     end
-- end

-- function AtkHit:__allocTargetEffectAttrsChangeCauseByQiDamageHurts()
--     local count = self.__targetEffectAttrsArray:getCount()
--     if count <= 0 then
--         return
--     end

--     local animHurtTimes = self.__zhaoInfo:getAnimHurtTimes()

--     for i = 1, animHurtTimes do
--         local hitAttack = self.__hits[i]

--         for _, qiDamage in ipairs(hitAttack.target:getQiDamages()) do
--             local projectionValue = qiDamage:getProjectionValue()

--             for j = 1, count do
--                 --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
--                 local zhaoAttackAttrsEffect = self.__targetEffectAttrsArray:get(j)

--                 local attrName = zhaoAttackAttrsEffect:getAttrName()

--                 local percent = zhaoAttackAttrsEffect:getValue()

--                 local targetType = zhaoAttackAttrsEffect:getTargetType()

--                 local value = Helper:mathFloor(projectionValue * percent)

--                 if targetType == "self" then
--                     hitAttack.target:addEffectAttrsByQiDamage(
--                         {
--                             ownerId = zhaoAttackAttrsEffect:getOwnerId(),
--                             targetId = self.__target:getId(),
--                             effectFuncId = zhaoAttackAttrsEffect:getEffectFuncId(),
--                             attraName = attrName,
--                             value = value
--                         }
--                     )
--                 elseif targetType == "atk" then
--                     hitAttack.attacker:addEffectAttrsByQiDamage(
--                         {
--                             ownerId = zhaoAttackAttrsEffect:getOwnerId(),
--                             targetId = self.__attacker:getId(),
--                             effectFuncId = zhaoAttackAttrsEffect:getEffectFuncId(),
--                             attraName = attrName,
--                             value = value
--                         }
--                     )
--                 else
--                     error(' AtkHit:__doTargetEffectAttrs 不应该存在目标类型是 "self" 和 "atk" 外的类型，请检查代码。传入值：' .. targetType)
--                 end
--             end
--         end
--     end
-- end

-- --@desc:
-- --@author:Seven
-- --@time:2021-12-08 11:47:43
-- --@oneHitAttack: [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.OneHitAttack#OneHitAttack]
-- function AtkHit:__initAttackerResult(oneHitAttack)
--     local results = oneHitAttack:getHitAttackResult()

--     if not MapIsEmpty(results) then
--         for k, v in pairs(results) do
--             self:__addAttrModifyToAttacker(k, v)
--         end
--     end
-- end

-- --@desc:
-- --@author:Seven
-- --@time:2021-12-08 11:47:43
-- --@oneHitAttack: [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.OneHitAttack#OneHitAttack]
-- function AtkHit:__initTargetResult(oneHitAttack)
--     local results = oneHitAttack:getHitAttackResult()

--     if not MapIsEmpty(results) then
--         for k, v in pairs(results) do
--             self:__addAttrModifyToTarget(k, v)
--         end
--     end
-- end

-- function AtkHit:__initResults()
--     if #self.__hits <= 0 then
--         return
--     end

--     for i = 1, #self.__hits do
--         local oneHitAttackInfo = self.__hits[i]

--         self:__initAttackerResult(oneHitAttackInfo.attacker)

--         self:__initTargetResult(oneHitAttackInfo.target)
--     end
-- end

-- function AtkHit:__addAttrModifyToAttacker(attrName, value)
--     if self.__attackerAttrHurts[attrName] == nil then
--         self.__attackerAttrHurts[attrName] = 0
--     end

--     self.__attackerAttrHurts[attrName] = self.__attackerAttrHurts[attrName] + value
-- end

-- function AtkHit:__addAttrModifyToTarget(attrName, value)
--     if self.__targetAttrHurts[attrName] == nil then
--         self.__targetAttrHurts[attrName] = 0
--     end

--     self.__targetAttrHurts[attrName] = self.__targetAttrHurts[attrName] + value
-- end

-- --@desc: 执行攻击
-- --@author:Seven
-- --@time:2021-07-06 16:41:34
-- --@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
-- --@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
-- function AtkHit:doAttack(attacker, target)
--     self:__initResults()

--     self:__doAttack(self.__attackerAttrHurts, self.__attacker)
--     self:__doAttack(self.__targetAttrHurts, self.__target)

--     -- -- FightUtil:printLog(string.format("└ 【击中】 ( %d / %d ) 属性：%s ，伤害：%f", index, #calHurtInfos, attrName, hurtValue))
--     -- -- FightUtil:printLog(string.format(" └ 属性：%s 计算值：%f , 实际值：%f", attrName, value, realValue))
--     FightUtil:printLog("attack hit 击中统计 : ")
-- end

-- return class("AtkHit", {IZhaoAttack}, AtkHit)
000000000000
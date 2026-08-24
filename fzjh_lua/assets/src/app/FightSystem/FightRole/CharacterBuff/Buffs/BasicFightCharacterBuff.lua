--[[
    author:Seven
    time:2023-02-07 14:44:36
    desc: 角色buff类
]]
local newClass = require("third.class.NewClass")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")

local BuffMakeOnTrigger = require("app.FightSystem.FightRole.CharacterBuff.Buffs.MakeOnTrigger.BuffMakeOnTrigger")

local IFightCharacterBuff = require("app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
local BasicFightCharacterBuff = {}

--@desc:
--@author:Seven
--@time:2023-02-28 15:32:19
--@buffId: buff id
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
function BasicFightCharacterBuff:create(basicBuff)
    return BasicFightCharacterBuff.new():__init(basicBuff)
end

function BasicFightCharacterBuff:__init(basicBuff)
    --@RefType [src.app.FightSystem.FightBuff.BasicBuff.BasicBuff#BasicBuff]
    self.__basicBuff = isImpl(basicBuff, require("app.FightSystem.FightBuff.BasicBuff.BasicBuff"))

    self.__basicAppearence = BuffConf:getBuffEffectAppearence(self.__basicBuff:getEffectsId())

    --@desc 存活次数 （小于0 代表无限存活次数）
    self.__lives = 0

    --@desc 添加器设置的动态参数列表
    self.__dynamicArgMap = {}

    --@desc 存放效果监测生效节点
    self.__makeEffectOnByNode = {}

    --@desc 效果列表
    self.__effects = {}

    self.__isRemove = false

    for i, basicEffect in ipairs(self.__basicBuff:getEffects()) do
        local isSuccess, effectClassFile = pcall(require, "app.FightSystem.FightRole.CharacterBuff.Effects.BuffEffect" .. tostring(basicEffect:getEffectType()))

        if isSuccess then
            --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
            local effectClass = effectClassFile:create()

            effectClass:setBasicEffect(basicEffect)

            effectClass:setOwningBuff(self)

            self:__addEffect(effectClass)
        else
            print("！！！！！ 找不到buff效果类，effectType : " .. tostring(basicEffect:getEffectType()) .. " buffId : " .. tostring(self.__basicBuff:getId()))
        end
    end

    return self
end

function BasicFightCharacterBuff:setBuffContext(IBuffContext)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffContext.IBuffContext#IBuffContext]
    self.__buffContext = isImpl(IBuffContext, require("app.FightSystem.FightRole.CharacterBuff.BuffContext.IBuffContext"))
end

function BasicFightCharacterBuff:getBuffContext()
    return self.__buffContext
end

function BasicFightCharacterBuff:setOwner(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = isImpl(character, require("app.FightSystem.FightRole.NewFightCharacter"))

    self.__ownerName = self.__character:getAttr("name")

    self.__ownerId = self.__character:getId()
end

function BasicFightCharacterBuff:getBuffOwner()
    return self.__character
end

function BasicFightCharacterBuff:setBuffCreator(buffCreator)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__buffCreator = buffCreator
end

function BasicFightCharacterBuff:getBuffCreator()
    return self.__buffCreator
end

function BasicFightCharacterBuff:__addEffect(effect)
    table.insert(self.__effects, isImpl(effect, require("app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect")))
end

--@desc: 当前buff对象的onlyid
--@author:Seven
--@time:2023-03-06 20:38:17
function BasicFightCharacterBuff:getId()
    if self.__id == nil then
        error("BasicFightCharacterBuff:getId only id 未设置")
    end

    return tostring(self.__id)
end

function BasicFightCharacterBuff:setId(id)
    self.__id = id
end

--@desc: buff id
--@author:Seven
--@time:2023-03-06 20:38:09
function BasicFightCharacterBuff:getBuffId()
    return tostring(self.__basicBuff:getId())
end

function BasicFightCharacterBuff:getBuffClass()
    return tonumber(self.__basicBuff:getClass())
end

--@desc: 设置buff的存活次数
--@author:Seven
--@time:2023-03-06 20:39:32
--@value: 存活次数
function BasicFightCharacterBuff:setBuffLives(value)
    if type(value) ~= "number" then
        error("BasicFightCharacterBuff:setBuffLives 参数类型错误")
    end

    self.__lives = value
end

--@desc: 获取buff存活次数
--@author:Seven
--@time:2023-02-28 15:40:57
--@return 存活次数
function BasicFightCharacterBuff:getBuffLives()
    return self.__lives
end

--@desc: 获取叠加类型
--@author:Seven
--@time:2023-03-14 15:58:31
function BasicFightCharacterBuff:getStackType()
    return self.__basicBuff:getStackType()
end

--@desc: 获取叠加上限最大值 < 0 代表无上限或该叠加类型无需判断上限
--@author:Seven
--@time:2023-03-13 16:26:33
function BasicFightCharacterBuff:getStackTimesMax()
    if self.__stackMax == nil then
        if self:getStackType() == 0 then
            self.__stackMax = -1
        elseif self:getStackType() == 1 then
            self.__stackMax = self.__basicBuff:getStackTimes()

            if type(self.__stackMax) ~= "number" or self.__stackMax == 0 then
                error("BasicFightCharacterBuff:getStackTimesMax 1, buff 叠加类型1上限解析错误 ，buff id:" .. tostring(self.__stackMax))
            end
        elseif self:getStackType() == 2 then
            local value = self.__basicBuff:getStackTimes()

            if type(value) == "number" then
                self.__stackMax = value
            elseif type(value) == "string" then
                self.__stackMax = self:getBuffDynamicArg(value)
            end

            if type(self.__stackMax) ~= "number" then
                error("BasicFightCharacterBuff:getStackTimesMax , buff 叠加类型2上限解析错误 ，buff id:" .. tostring(self.__stackMax))
            end
        elseif self:getStackType() == 3 then
            self.__stackMax = -1
        else
            error("BasicFightCharacterBuff:getStackTimesMax , buff 叠加类型未知 ，buff id:" .. tostring(self.__stackMax) .. " buff stack : " .. tostring(self:getStackType()))
        end
    end

    return self.__stackMax
end

--@desc: 添加动态参数
--@author:Seven
--@time:2023-03-06 20:14:24
--@argName: 动态参数属性名
--@value: 动态参数值
function BasicFightCharacterBuff:setBuffDynamicArg(argName, value)
    if argName == "dynamicArg4" then
        self.__dynamicArgMap[argName] = value
        return
    end

    if type(value) ~= "number" then
        error("BasicFightCharacterBuff:setBuffDynamicArg （dynamicArg4除外）动态参数必须是数值！" .. tostring(value))
    end
    self.__dynamicArgMap[argName] = value
end

--@desc: 获取动态参数值
--@author:Seven
--@time:2023-03-06 20:15:24
--@argName: 动态参数属性名
function BasicFightCharacterBuff:getBuffDynamicArg(argName)
    if argName == "dynamicArg4" then
        return self.__dynamicArgMap[argName]
    end

    return Helper:getDef(self.__dynamicArgMap[argName], 0)
end

--@desc: 获取buff所携带的图标
--@author:Seven
--@time:2023-03-15 15:18:17
function BasicFightCharacterBuff:getBuffIcon()
    return self.__basicBuff:getIcon()
end

--@desc: 获取该buff所有效果
--@author:Seven
--@time:2023-03-06 17:26:21
--@return: ACharacterEffects 集合
function BasicFightCharacterBuff:getAllFightEffects()
    return self.__effects
end

function BasicFightCharacterBuff:__walkEffects(func)
    if table.getn(self.__effects) <= 0 then
        return
    end

    for i = 1, table.getn(self.__effects) do
        if func(self.__effects[i]) == true then
            break
        end
    end
end

--@region 存活次数相关操作
--@desc: 是否拥有无限存活次数（该类buff一般是其它系统带来）
--@author:Seven
--@time:2023-03-14 17:45:50
function BasicFightCharacterBuff:__hasInfiniteLives()
    return self:getBuffLives() < 0
end

--@desc: 是否可以删除
--@author:Seven
--@time:2023-03-14 17:49:52
function BasicFightCharacterBuff:isRemovable()
    return table.contains(self.__basicBuff:getDeleteBuffCon(), BUFF_CONSTANTS.DELETE_BUFF_CON_TYPE.LIVES_ZERO) and self:getBuffLives() == 0
end

--@desc: 是否可以减少存活次数
--@author:Seven
--@time:2023-03-14 17:58:45
function BasicFightCharacterBuff:__canReduceLives()
    return not self:__hasInfiniteLives() and table.contains(self.__basicBuff:getDeleteBuffCon(), BUFF_CONSTANTS.DELETE_BUFF_CON_TYPE.LIVES_ZERO) and self:getBuffLives() > 0
end

--@endregion

--@region 外观操作
function BasicFightCharacterBuff:__addCharacterAppearence()
    local idleExpressionType = self.__basicAppearence:getIdleExpressionType()
    if idleExpressionType > 0 then
        if idleExpressionType == 1 then
            local idleExpression = tonumber(self.__basicAppearence:getIdleExpression())
            if idleExpression > 0 then
                local CharacterDefaultConf = require("app.FightSystem.Configuration.CharacterDefaultConf")
                local AnimStateInfo = require("app.FightSystem.FightRole.AnimSystem.AnimStateInfo")
                if idleExpression == 1 then
                    local stateInfo = AnimStateInfo:create("buff", CharacterDefaultConf:getControlledStunAnim(self.__character:getSpecies()), self.__basicAppearence:getIdleSort())
                    self.__idleAnimId = self.__character:addIdleAnimStateInfo(stateInfo)
                elseif idleExpression == 2 then
                    local stateInfo = AnimStateInfo:create("buff", CharacterDefaultConf:getControlledConfuseAnim(self.__character:getSpecies()), self.__basicAppearence:getIdleSort())
                    self.__idleAnimId = self.__character:addIdleAnimStateInfo(stateInfo)
                end
            end
        elseif idleExpressionType == 2 then
            local idelExpression = tostring(self.__basicAppearence:getIdleExpression())
            if idelExpression ~= nil and idelExpression ~= "" then
                local AnimStateInfo = require("app.FightSystem.FightRole.AnimSystem.AnimStateInfo")
                local stateInfo = AnimStateInfo:create("buff", idelExpression, self.__basicAppearence:getIdleSort())
                self.__idleAnimId = self.__character:addIdleAnimStateInfo(stateInfo)
            end
        end
    end


    local hurtExpression = self.__basicAppearence:getHurtExpression()
    if hurtExpression > 0 then
        self.__hurtExpressionId = self.__character:addHurtExpression(hurtExpression, self.__basicAppearence:getHurtSort())
    end

    local roleHeadText = self.__basicAppearence:getActiveEffectRoleHeadText()
    if roleHeadText ~= nil then
        local TextStateInfo = require("app.FightSystem.FightRole.AnimSystem.TextStateInfo")
        self.__topTextId = self.__character:addTopTextInfo(TextStateInfo:create("buff", roleHeadText, self.__basicAppearence:getActiveEffectRoleHeadTextSort()))
    end

    local roleHalo = self.__basicAppearence:getActiveEffectRoleFeetHalo()
    if roleHalo ~= 0 then
        local AnimStateInfo = require("app.FightSystem.FightRole.AnimSystem.AnimStateInfo")
        local stateInfo = AnimStateInfo:create("buff", roleHalo, self.__basicAppearence:getActiveEffectRoleFeetHaloSort())

        self.__footHaloId = self.__character:addHaloOfFootAnim(stateInfo)
    end
end

function BasicFightCharacterBuff:__removeCharacterAppearence()
    if self.__idleAnimId ~= nil then
        self.__character:removeIdleAnimState(self.__idleAnimId)
        self.__idleAnimId = nil
    end

    if self.__hurtExpressionId ~= nil then
        self.__character:removeHurtExpression(self.__hurtExpressionId)
        self.__hurtExpressionId = nil
    end

    if self.__topTextId ~= nil then
        self.__character:removeTopTextInfo(self.__topTextId)
        self.__topTextId = nil
    end

    if self.__shieldId ~= nil then
        self.__character:removeQiShield(self.__shieldId)
        self.__shieldId = nil
    end

    if self.__footHaloId ~= nil then
        self.__character:removeHaloOfFootAnim(self.__footHaloId)
        self.__footHaloId = nil
    end
end
--@endregion

--@desc 标记该buff为删除状态
function BasicFightCharacterBuff:removeSelf()
    self.__isRemove = true
end

--@desc 是否为删除状态
function BasicFightCharacterBuff:isRemove()
    return self.__isRemove
end

function BasicFightCharacterBuff:getDeleteBuffDesc()
    --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
    local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

    desc:setBuffOwner(self.__character)

    desc:setText(self.__basicBuff:getDeleteBuffDesc())

    return desc:getString()
end

function BasicFightCharacterBuff:getAddBuffDesc()
    --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
    local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

    desc:setBuffOwner(self.__character)

    desc:setText(self.__basicBuff:getAddBuffDesc())

    return desc:getString()
end

--@desc: 注册buff效果生效节点监听器
--@author:Seven
--@time:2023-11-29 17:58:14
--@effectNode: [src.app.FightSystem.FightBuff.Constants#Constants.BUFF_MAKE_EFFECT_ON_NODE_TYPE]
--@listerner: function
function BasicFightCharacterBuff:registerMakeEffectListener(effectNode, listerner)
    if table.keyof(BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE, effectNode) == nil then
        error("BasicFightCharacterBuff:registerMakeEffectListener 未知的节点类型 ： " .. tostring(effectNode))
    end

    if self.__makeEffectOnByNode[tostring(effectNode)] == nil then
        self.__makeEffectOnByNode[tostring(effectNode)] = {}
    end

    table.insert(self.__makeEffectOnByNode[tostring(effectNode)], listerner)
end

function BasicFightCharacterBuff:buffMakeEffectOnNode(makeEffectOnNode, args)
    if table.keyof(BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE, makeEffectOnNode) == nil then
        error("BasicFightCharacterBuff:buffMakeEffectOnNode 未知的节点类型 ： " .. tostring(makeEffectOnNode))
    end

    local isUpdateValue = false
    local __buffUpdateEffectNodes = self.__basicBuff:getEffectUpdataNode()
    if
        table.keyof(
            {
                BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE.OnActiveCombStart,
                BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE.OnAutoCombStart,
                BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE.OnAnyCombStart
            },
            makeEffectOnNode
        ) and table.contains(__buffUpdateEffectNodes, BUFF_CONSTANTS.EffectUpdateNodeType.BeforeAttack)
     then
        isUpdateValue = true
    end

    if
        table.keyof(
            {
                BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE.OnAnyCombFinish,
                BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE.OnActiveCombFinish,
                BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE.OnAutoCombFinish
            },
            makeEffectOnNode
        ) and table.contains(self.__basicBuff:getEffectUpdataNode(), BUFF_CONSTANTS.EffectUpdateNodeType.AfterAttack)
     then
        isUpdateValue = true
    end

    self:__makeEffectOnBuffEffect(makeEffectOnNode, isUpdateValue, args)

    self:__triggerReduceLives(makeEffectOnNode, args)
end

function BasicFightCharacterBuff:__checkIsTriggerCons(makeOnNode, ...)
    return BuffMakeOnTrigger:isMakeOn(self, makeOnNode, self.__basicBuff:getTriggerBuffCons(), ...)
end

function BasicFightCharacterBuff:__triggerReduceLives(makeEffectOnNode, args)
    if not self:__canReduceLives() then
        return
    end

    if not self:__checkIsTriggerCons(makeEffectOnNode, table.unpack(args)) then
        return
    end

    local oldLive = self:getBuffLives()

    local newLive = oldLive - 1

    if newLive < 0 then
        error("BasicFightCharacterBuff:__triggerReduceLives(makeEffectOnNode) : new live 不可小于0 : " .. tostring(newLive) .. " , buff id : " .. tostring(self:getBuffId()))
    end

    self:setBuffLives(newLive)

    FightUtil:printFormatLog('%s(%s) buff【%s】 生效节点触发减少存活次数 old:"%s" new:"%s" ', tostring(self.__ownerName), tostring(self.__ownerId), tostring(self:getBuffId()), tostring(oldLive), tostring(newLive))
end

function BasicFightCharacterBuff:__makeEffectOnBuffEffect(makeEffectOnNode, isUpdateValue, args)
    if self.__makeEffectOnByNode[tostring(makeEffectOnNode)] == nil then
        return
    end

    if isUpdateValue then
        self:__walkEffects(
            function(effect)
                effect:updateEffectValue()
            end
        )
    end

    for _, listerner in ipairs(self.__makeEffectOnByNode[tostring(makeEffectOnNode)]) do
        listerner(table.unpack(args))
    end
end

--@desc: buff被添加时执行
--@author:Seven
--@time:2023-02-28 14:25:25
function BasicFightCharacterBuff:makeBuffEffectOnAdd()
    self:__addCharacterAppearence()

    if self.__basicBuff:getAddBuffEffect() ~= nil then
        local effectInfo = self.__basicBuff:getAddBuffEffect()
        self.__buffContext:addOneOffEffect(effectInfo[1], effectInfo[2], self.__character:getId())
    end

    for effect in self:getEffectIterator() do
        FightUtil:printFormatLog(
            "%s : buff-【%s】 Effect生效-onAdd id:【%s】 effectId:【%s】 , effectType:【%d】",
            self.__character:getAttr("name"),
            self:getBuffId(),
            effect:getResouceId(),
            effect:getEffectId(),
            effect:getEffectType()
        )
        effect:makeEffectOnAdd()
    end
end

function BasicFightCharacterBuff:makeBuffEffectOnRemove()
    self:__removeCharacterAppearence()

    for effect in self:getEffectIterator() do
        effect:makeEffectOnRemove()
    end
end

function BasicFightCharacterBuff:makeBuffEffectOnTransfer(newOwner)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
    local builder = require("app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder"):create()

    for k, v in pairs(self.__dynamicArgMap) do
        builder:setBuffDynamicArgValue(k, v)
    end

    local newBuff = builder:setBuffId(self:getBuffId()):setCharacter(newOwner):setBuffCreator(self:getBuffCreator()):setFight(self.__buffContext):build()

    newBuff:setBuffLives(self:getBuffLives())

    for effect, index in self:getEffectIterator() do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
        effect = effect

        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
        local newEffect = newBuff:getEffectByOrderIndex(index)

        if newEffect:getEffectId() ~= effect:getEffectId() then
            error(
                "BasicFightCharacterBuff:makeBuffEffectOnTransfer buff效果id不一致" ..
                    tostring(newEffect:getEffectId()) .. " " .. tostring(effect:getEffectId()) .. " buff id : " .. tostring(self:getBuffId())
            )
        end
        effect:makeEffectOnTransfer(newEffect)
    end

    return newBuff
end

--@desc: 效果列表迭代器
--@author:Seven
--@time:2023-11-29 20:49:39
function BasicFightCharacterBuff:getEffectIterator()
    local i = 0
    return function()
        i = i + 1
        local effect = self.__effects[i]
        return effect, i
    end
end

function BasicFightCharacterBuff:getEffectByOrderIndex(index)
    if index < 1 then
        error("BasicFightCharacterBuff:getEffectByOrderIndex index 不能小于1")
    end

    if index > table.getn(self.__effects) then
        error("BasicFightCharacterBuff:getEffectByOrderIndex index 超出范围" .. tostring(self:getBuffId()))
    end

    return self.__effects[index]
end

function BasicFightCharacterBuff:getShieldAnimAndPriority()
    local shieldId = self.__basicAppearence:getActiveEffectRoleShield()
    if shieldId ~= 0 then
        return shieldId, self.__basicAppearence:getActiveEffectRoleShieldSort()
    end
    return nil
end

function BasicFightCharacterBuff:getEffectClass()
    return self.__basicBuff:getEffectClass()
end

return newClass("BasicFightCharacterBuff", {IFightCharacterBuff}, BasicFightCharacterBuff)
000000
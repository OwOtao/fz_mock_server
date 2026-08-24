--[[
    author:Seven
    time:2023-02-07 14:23:53
    desc: 战斗角色buff系统
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local BasicBuffSystem = {}

function BasicBuffSystem:create()
    return BasicBuffSystem.new()
end

function BasicBuffSystem:onInit()
    --@desc buff数组
    self.__buffArray = {}

    self.__prepRemoveBuffArray = {}

    --@desc buffGroup buff组，同buffid共用属性相关功能及相同buffid的数量统计
    self.__buffGroupArray = {}

    --@desc 角色添加器组
    self.__adderGroups = {}

    --@desc 属性加法加成
    self.__addAttrMap = {}

    --@desc 属性乘法加成
    self.__mulAttrMap = {}

    --@desc 武器属性加法加成
    self.__weaponAddAttrMap = {}

    --@desc 武器属性乘法加成
    self.__weaponMulAttrMap = {}

    self.__buffIdCreateIndex = 0

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAttrs.BasicBuffAttrs#BasicBuffAttrs]
    self.__attrSys = require("app.FightSystem.FightRole.CharacterBuff.BuffAttrs.BasicBuffAttrs"):create(self)

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAttrs.AttrMaxValueMap#AttrMaxValueMap]
    self.__maxValueMap = require("app.FightSystem.FightRole.CharacterBuff.BuffAttrs.AttrMaxValueMap"):create(self)

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAttrs.AttrMinValueMap#AttrMinValueMap]
    self.__minValueMap = require("app.FightSystem.FightRole.CharacterBuff.BuffAttrs.AttrMinValueMap"):create(self)

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffImmuneFunc.BuffImmuneFunc#BuffImmuneFunc]
    self.__immuneFunc = require("app.FightSystem.FightRole.CharacterBuff.BuffImmuneFunc.BuffImmuneFunc"):create(self)
end

function BasicBuffSystem:onDestory()
end

function BasicBuffSystem:onUpdate(ft)
    self:__clearRemovedBuff()
end

function BasicBuffSystem:__getNewIndexId()
    self.__buffIdCreateIndex = self.__buffIdCreateIndex + 1

    return tostring(self.__buffIdCreateIndex)
end

--@desc: 获取buff系统属性
--@author:Seven
--@time:2023-03-15 20:52:13
--@name: 属性名
function BasicBuffSystem:getBuffSystemAttr(name)
    return self.__attrSys:getAttr(name)
end

--@desc: 获取一个新的buffgroup
--@author:Seven
--@time:2023-03-21 14:34:13
--@buffId: BUFF ID
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuffGroup#IFightCharacterBuffGroup]
function BasicBuffSystem:__getNewBuffGroup(buffId)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuffGroup#IFightCharacterBuffGroup]
    local buffGroup = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuffGroup"):create(buffId)
    buffGroup:setOwner(self.__character)
    return buffGroup
end

--@desc: 添加buffgroup
--@author:Seven
--@time:2023-12-03 15:20:24
--@buffGroup: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuffGroup#IFightCharacterBuffGroup]
function BasicBuffSystem:__addBuffGroup(buffGroup)
    table.insert(self.__buffGroupArray, isImpl(buffGroup, require("app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuffGroup")))
    self.__buffGroupArray[tostring(buffGroup:getBuffId())] = buffGroup
end

function BasicBuffSystem:__removeBuffGroup(buffId)
    for i = #self.__buffGroupArray, 1, -1 do
        local buffGroup = self.__buffGroupArray[i]
        if buffGroup:getBuffId() == buffId then
            table.remove(self.__buffGroupArray, i)
            break
        end
    end

    self.__buffGroupArray[tostring(buffId)] = nil
end

--@desc: 获取buff组
--@author:Seven
--@time:2023-12-03 15:47:02
--@buffId: buff id
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuffGroup#IFightCharacterBuffGroup]
function BasicBuffSystem:getBuffGroup(buffId)
    return self.__buffGroupArray[tostring(buffId)]
end

--@desc: 添加buff
--@author:Seven
--@time:2023-02-07 14:43:59
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
--@return: true, buff对象id | false
function BasicBuffSystem:addBuff(buff)
    table.insert(self.__buffArray, isImpl(buff, require("app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff")))

    buff:setId(self:__getNewIndexId())

    self.__buffArray[buff:getId()] = buff

    FightUtil:printFormatLog("BasicBuffSystem:addBuff 【%s】 添加buff:【%s】 , live:【%s】", self.__character:getAttr("name"), buff:getBuffId(), buff:getBuffLives())

    local buffId = buff:getBuffId()

    local buffGroup = self:getBuffGroup(buffId)
    if buffGroup == nil then
        buffGroup = self:__getNewBuffGroup(buffId)
        buffGroup:setBuffStackMax(buff:getStackTimesMax())
        self:__addBuffGroup(buffGroup)
    end

    buffGroup:addBuffToGroup(buff)

    buff:makeBuffEffectOnAdd()

    return buff:getId()
end

--@desc: 删除buff
--@author:Seven
--@time:2023-10-10 14:45:55
--@buffIndex: buff 的唯一索引
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function BasicBuffSystem:removeBuffByIndex(buffIndex)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
    local buff = self.__buffArray[buffIndex]
    if buff == nil then
        return
    end

    local buffId = buff:getBuffId()

    local buffGroup = self:getBuffGroup(buffId)
    if buffGroup == nil then
        assert(false, "buffGroup 不应该为空")
    end
    buffGroup:removeBuffFromGroup(buff)
    if buffGroup:getBuffCount() <= 0 then
        self:__removeBuffGroup(buffId)
    end

    buff:makeBuffEffectOnRemove()

    buff:removeSelf()

    return buff
end

function BasicBuffSystem:__clearRemovedBuff()
    for i = table.getn(self.__buffArray), 1, -1 do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
        local buff = self.__buffArray[i]

        if buff:isRemove() then
            table.remove(self.__buffArray, i)
            self.__buffArray[buff:getId()] = nil
        end
    end
end

--@desc: 根据buffid 获取角色当前拥有该buffid的数组
--@author:Seven
--@time:2023-10-10 14:46:35
--@buffid: buff ID
--@return: array
function BasicBuffSystem:getBuffByBuffId(buffid)
    local buffGroup = self:getBuffGroup(buffid)
    if buffGroup == nil then
        return {}
    end
    local buffIndexArray = buffGroup:getBuffIndexs()

    local buffArray = {}

    for _, buffIndex in ipairs(buffIndexArray) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
        local buff = self.__buffArray[buffIndex]
        if buff == nil then
            error("BasicBuffSystem:getBuffByBuffId buff is nil")
        end
        table.insert(buffArray, buff)
    end
    return buffArray
end

--@desc: 获取buff
--@author:Seven
--@time:2023-12-04 21:26:06
--@id: index id
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function BasicBuffSystem:getBuffById(id)
    return self.__buffArray[tostring(id)]
end

--@desc: 遍历
--@author:Seven
--@time:2023-03-15 20:38:19
--@func: 遍历回调方法
function BasicBuffSystem:walkAllBuff(func)
    for _, buff in self:__getBuffIterator() do
        if buff:isRemove() == false then
            if func(buff) == true then
                break
            end
        end
    end
end

--@desc: buff遍历迭代器
--@author:Seven
--@time:2023-12-04 10:57:03
function BasicBuffSystem:__getBuffIterator()
    local i = 1
    return function()
        local index = i
        local buff = self.__buffArray[index]
        if buff == nil then
            return nil
        end
        i = i + 1
        return index, buff
    end
end

--@desc: 生效buff效果
--@author:Seven
--@time:2023-10-17 16:06:17
--@effectNode: [src.app.FightSystem.FightBuff.Constants#Constants.BUFF_MAKE_EFFECT_ON_NODE_TYPE]
--@return:
function BasicBuffSystem:makeEffectOn(effectNode, ...)
    local args = {...}
    self:walkAllBuff(
        function(buff)
            --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
            buff = buff
            buff:buffMakeEffectOnNode(effectNode, args)
            if buff:isRemovable() then
                self:__addBuffToPrepRemove(buff)
            end
        end
    )
end

--@desc: 添加待删除buff
--@author:Seven
--@time:2023-12-04 21:27:41
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function BasicBuffSystem:__addBuffToPrepRemove(buff)
    table.insert(self.__prepRemoveBuffArray, buff:getId())
end

function BasicBuffSystem:tryRemoveBuffs()
    if #self.__prepRemoveBuffArray <= 0 then
        return
    end

    for i, buffIndexId in ipairs(self.__prepRemoveBuffArray) do
        self.__character:removeCharacterBuff(buffIndexId)
    end

    self.__prepRemoveBuffArray = {}
end

--@desc: 获取buffGroup迭代器方法
--@author:Seven
--@time:2023-12-03 15:57:56
--@return: iterator function
function BasicBuffSystem:getBuffGroupIterator()
    local i = 0
    return function()
        i = i + 1
        return self.__buffGroupArray[i]
    end
end

--@desc: 获取当前角色buff最大堆叠层数
--@author:Seven
--@time:2023-10-10 14:54:22
--@buffid: buff id
--@return: number
function BasicBuffSystem:getBuffMaxLayerCount(buffid)
    local buffGroup = self:getBuffGroup(buffid)

    if buffGroup == nil then
        return 0
    end

    return buffGroup:getBuffStackMax()
end

--@desc: 设置当前角色buff最大堆叠层数，返回设置后的值
--@author:Seven
--@time:2023-10-10 14:55:40
--@buffid: buff id
--@maxLayerCount: 最大堆叠层数
--@return: number 设置后的值
function BasicBuffSystem:setBuffMaxLayerCount(buffid, maxLayerCount)
    local buffGroup = self:getBuffGroup(buffid)

    if buffGroup == nil then
        error("BasicBuffSystem:setBuffMaxLayerCount buffGroup is nil")
    end

    buffGroup:setBuffStackMax(maxLayerCount)

    return maxLayerCount
end

--@region 添加器相关
--@desc: 添加角色公用添加器组
--@author:Seven
--@time:2023-03-09 21:03:41
--@buffAdderGroup: [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup#AFightCharacterBuffAdderGroup]
--@return 添加后buff添加器组在角色身上的唯一标识
function BasicBuffSystem:addBuffAdderGroup(buffAdderGroup)
    buffAdderGroup:setId("buffAdder|" .. tostring(self:__getNewIndexId()))
    table.insert(self.__adderGroups, isImpl(buffAdderGroup, require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup")))

    return buffAdderGroup:getId()
end

--@desc: 获取所有添加器组
--@author:Seven
--@time:2023-03-11 14:32:54
function BasicBuffSystem:getBuffAdderGroups()
    return self.__adderGroups
end

--@desc: 根据添加器触发类型获取添加器组
--@author:Seven
--@time:2023-10-07 15:38:42
--@triggerType:
--@return: array
function BasicBuffSystem:getAdderGroupByAdderTriggerType(triggerType)
    local list = {}

    for _, v in ipairs(self.__adderGroups) do
        if v:needTriggerByType(triggerType) then
            table.insert(list, v)
        end
    end

    return list
end

--@desc: 根据添加节点弹出待添加的buff
--@author:Seven
--@time:2023-10-08 12:06:36
--@addNode: [src.app.FightSystem.FightBuff.Constants#Constants.ADD_BUFF_NODE_TYEP]
--@return: array {buff = [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicCharacterBuff#BasicCharacterBuff], cid = number}
function BasicBuffSystem:popPrepAddBuffArrayByAddNode(addNode)
    local list = {}

    for _, v in ipairs(self.__adderGroups) do
        local adderList = v:buildAddBuffArrayByAddNode(addNode)

        table.appendArray(list, adderList)
    end

    return list
end

--@desc: 移除添加器组
--@author:Seven
--@time:2023-03-11 14:31:53
--@indexId: 添加器唯一id
function BasicBuffSystem:removeBuffAdderGroup(indexId)
    if table.getn(self.__adderGroups) <= 0 then
        error("当前添加器组为空，不该执行该代码")
    end

    for index, v in ipairs(self.__adderGroups) do
        if v:getId() == indexId then
            return table.remove(self.__adderGroups, index)
        end
    end
    error("没有在添加器组中找到添加器 index : " .. tostring(indexId))
end
--@endregion

--@desc: 获取buff相加的属性
--@author:Seven
--@time:2023-02-07 14:30:03
--@name: 属性名
function BasicBuffSystem:getAddAttr(name)
    local value = Helper:getDef(self.__addAttrMap[name], 0)

    return value
end

--@desc: 加减角色属性加法加成
--@author:Seven
--@time:2023-03-16 12:12:22
--@attrName: 属性名
--@name: 加减值
function BasicBuffSystem:addBuffAddAttr(name, value)
    local now = self:getAddAttr(name)

    self.__addAttrMap[name] = now + value

    return self.__addAttrMap[name]
end

--@desc: 获取buff相乘的属性
--@author:Seven
--@time:2023-02-07 14:29:24
--@name: 属性名
function BasicBuffSystem:getMulAttr(name)
    local value = Helper:getDef(self.__mulAttrMap[name], 0)

    return value
end

--@desc: 加减角色属性乘法加成
--@author:Seven
--@time:2023-03-16 12:12:22
--@attrName: 属性名
--@name: 加减值
function BasicBuffSystem:addBuffMulAttr(name, value)
    local now = self:getMulAttr(name)

    self.__mulAttrMap[name] = now + value

    return self.__mulAttrMap[name]
end

--@desc: 获取武器相加的属性
--@author:Seven
--@time:2025-09-06
--@name: 属性名
function BasicBuffSystem:getWeaponAddAttr(name)
    local value = Helper:getDef(self.__weaponAddAttrMap[name], 0)

    return value
end

--@desc: 加减武器属性加法加成
--@author:Seven
--@time:2025-09-06
--@attrName: 属性名
--@name: 加减值
function BasicBuffSystem:addBuffWeaponAddAttr(name, value)
    local now = self:getWeaponAddAttr(name)

    self.__weaponAddAttrMap[name] = now + value

    return self.__weaponAddAttrMap[name]
end

--@desc: 获取武器相乘的属性
--@author:Seven
--@time:2025-09-06
--@name: 属性名
function BasicBuffSystem:getWeaponMulAttr(name)
    local value = Helper:getDef(self.__weaponMulAttrMap[name], 0)

    return value
end

--@desc: 加减武器属性乘法加成
--@author:Seven
--@time:2025-09-06
--@attrName: 属性名
--@name: 加减值
function BasicBuffSystem:addBuffWeaponMulAttr(name, value)
    local now = self:getWeaponMulAttr(name)

    self.__weaponMulAttrMap[name] = now + value

    return self.__weaponMulAttrMap[name]
end

--@desc: 获取buff 层数（buff个数）
--@author:Seven
--@time:2023-03-16 11:37:51
--@buffId: buff id
function BasicBuffSystem:getBuffLayerCountByBuffId(buffId)
    local buffGroup = self:getBuffGroup(buffId)

    if buffGroup == nil then
        return 0
    end

    local value = buffGroup:getBuffCount()

    if value < 0 then
        error("BasicBuffSystem:getBuffLayerCountByBuffId 层数不该为负数，检查代码")
    end

    return value
end

--@desc: 检查是否拥有某类型buff
--@author:Seven
--@time:2023-03-16 14:09:28
--@buffClass: buff类型
function BasicBuffSystem:hasCharacterBuffByClass(buffClass)
    if MapIsEmpty(self.__buffGroupArray) then
        return false
    end

    buffClass = tonumber(buffClass)

    for _, buffGroup in ipairs(self.__buffGroupArray) do
        if buffGroup:getBuffClass() == buffClass then
            return true
        end
    end

    return false
end

--@desc: 添加buff免疫功能
--@author:Seven
--@time:2023-03-17 14:07:45
--@immuneType: 免疫类型
--@args: 相关参数
--@return: id
function BasicBuffSystem:addImmuneBuff(immuneType, ...)
    return self.__immuneFunc:addImmuneBuff(immuneType, ...)
end

--@desc: 删除免疫对象
--@author:Seven
--@time:2023-03-17 14:08:51
--@immuneType: 免疫类型
--@id: 免疫对象id
--@return: 被删除的免疫对象
function BasicBuffSystem:removeImmuneBuff(immuneType, id)
    return self.__immuneFunc:removeImmune(immuneType, id)
end

--@desc: 获取是否免疫
--@author:Seven
--@time:2023-03-17 14:09:57
--@immuneType: 免疫类型
--@args: 免疫相关参数
--@return: true | false , popText , printText
function BasicBuffSystem:isImmuneBuff(immuneType, ...)
    return self.__immuneFunc:isImmuneBuff(immuneType, ...)
end

function BasicBuffSystem:addMaxValue(attrName, value, effectId)
    return self.__maxValueMap:addMaxAttr(attrName, value, effectId)
end

function BasicBuffSystem:getMaxValue(attrName, defaultValue)
    return self.__maxValueMap:getMaxValue(attrName, defaultValue)
end

function BasicBuffSystem:removeMaxAttr(attrName, id)
    return self.__maxValueMap:removeMaxAttr(attrName, id)
end

function BasicBuffSystem:addMinValue(attrName, value, effectId)
    return self.__minValueMap:addMinAttr(attrName, value, effectId)
end

function BasicBuffSystem:getMinValue(attrName, defaultValue)
    return self.__minValueMap:getMinValue(attrName, defaultValue)
end

function BasicBuffSystem:removeMinAttr(attrName, id)
    return self.__minValueMap:removeMinAttr(attrName, id)
end

return newClass("BasicBuffSystem", {ABasicCharacterFuncSystem}, BasicBuffSystem)
000000
--[[
    author:Seven
    time:2023-10-09 11:48:35
    desc: 添加buff工具类
]]
local newClass = require("third.class.NewClass")

--@desc 用于添加BUFF时用的叠加规则检查类
local AddBuffStackMap = {}

local AddBuffUtil = {}

--@desc: 添加buff
--@author:Seven
--@time:2023-11-24 17:37:14
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@addNode: [src.app.FightSystem.FightBuff.Constants#Constants.ADD_BUFF_NODE_TYEP]
function AddBuffUtil:execAddBuff(fight, character, addNode)
    local prepAddBuffList = character:popPrepAddBuffArrayByAddNode(addNode)
    if table.getn(prepAddBuffList) <= 0 then
        return
    end

    for _, buff_info in ipairs(prepAddBuffList) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
        local buff = buff_info.buff
        self:addBuff(buff:getBuffOwner(), buff_info.buff)
    end
end

--@desc:
--@author:Seven
--@time:2024-01-15 21:18:18
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
--@return: 
function AddBuffUtil:addBuff(character, buff)
    local needAdd, printText, popText = self:__checkAddBuff(character, buff)
    local index
    if needAdd == true then
        index = character:addCharacterBuff(buff)
    end

    return {
        needAdd = needAdd,
        printText = printText,
        popText = popText,
        index = index
    }
end

--@desc: 检查buff 是否需要添加
--@author:Seven
--@time:2023-10-09 20:43:06
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
--@return: true | false
function AddBuffUtil:__checkAddBuff(character, buff)
    if character == nil then
        error("BuffUtil.addBuff character is nil")
    end

    if buff == nil then
        error("BuffUtil.addBuff buff is nil")
    end

    local isImmune, printText, popText = character:isImmuneBuff("BuffAll")
    if isImmune then
        return false, printText, popText
    end

    local isImmune, printText, popText = character:isImmuneBuff("BuffClass", buff:getBuffClass())
    if isImmune then
        return false, printText, popText
    end

    local isImmune, printText, popText = character:isImmuneBuff("BuffID", buff:getBuffId())
    if isImmune then
        return false, printText, popText
    end

    local addStackClass = self:__getAddStackType(buff:getBuffId(), buff:getStackType())

    if addStackClass:tryAddToCharacter(buff, character) == false then
        return false
    end

    return true
end

--@desc: 获取叠加工具类
--@author:Seven
--@time:2023-10-09 20:41:46
--@buffid: buffid
--@stackType: 叠加类型
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffAddStackTypes.IBuffAddStack#IBuffAddStack]
function AddBuffUtil:__getAddStackType(buffid, stackType)
    local addStackTypeClass = AddBuffStackMap[tostring(stackType)]

    if addStackTypeClass == nil then
        local addStackTypeClassFile = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffAddStackTypes.BuffAddStackType" .. tostring(stackType))
        if addStackTypeClassFile == nil then
            error("BuffUtil.addBuff( buff 叠加类型未知，buff id ：" .. tostring(buffid) .. " stackType : " .. tostring(stackType))
        end

        --@desc 添加策略类
        addStackTypeClass = addStackTypeClassFile:create()
    end

    return addStackTypeClass
end

return AddBuffUtil
000000000000000
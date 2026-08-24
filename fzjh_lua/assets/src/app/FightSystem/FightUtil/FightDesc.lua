local newClass = require("third.class.NewClass")

local Desc = require("app.FightSystem.FightBuff.Desc")

local FightDesc = {
    __isInit = false
}

function FightDesc:create()
    return FightDesc.new()
end

--@author:Seven
--@time:2021-12-14 10:50:32
function FightDesc:setAttacker(attacker)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__attacker = attacker
end

function FightDesc:setDefender(defender)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__defender = defender
end

function FightDesc:setHitPosName(posName)
    self.__hitPosName = posName
end

function FightDesc:setHurtValue(hurtValue)
    self.__hurtValue = hurtValue
end

function FightDesc:setBuffOwner(buffOwner)
    self.__buffOwner = buffOwner
end

function FightDesc:setBuffTarget(buffTarget)
    self.__buffTarget = buffTarget
end

function FightDesc:setBuffActualValue(value)
    self.__actualValue = value
end

function FightDesc:setText(text)
    self.__text = text
end

function FightDesc:setReduceStr(reduceStr)
    self.__reduceStr = reduceStr
end

function FightDesc:setZhaoCombName(name)
    self.__zhaoCombName = name
end

function FightDesc:setActiveZhaoNeedAttr(attrText, value)
    if attrText == nil or value == nil then
        error("FightDesc:setActiveZhaoNeedAttr 主动技能条件文本设置参数错误，检查代码")
    end

    self.__actAttrText = attrText

    self.__actValue = value
end

function FightDesc:__initReplaceArray()
    if self.__isInit then
        return
    end

    self.__replaceArray = {}

    if self.__attacker then
        table.insert(self.__replaceArray, {"$N", self.__attacker:getAttr("name")})
        local attackerWeapon = self.__attacker:getWeapon()
        table.insert(self.__replaceArray, {"$Nw", attackerWeapon:getName()})
    end

    if self.__defender then
        table.insert(self.__replaceArray, {"$n", self.__defender:getAttr("name")})
        -- $nw 受击者武器名称
        local defenderWeapon = self.__defender:getWeapon()
        table.insert(self.__replaceArray, {"$nw", defenderWeapon:getName()})
    end

    if self.__hitPosName then
        table.insert(self.__replaceArray, {"$l", self.__hitPosName})
    end

    if self.__hurtValue then
        table.insert(self.__replaceArray, {"$d", self.__hurtValue})
    end

    if self.__buffOwner then
        table.insert(self.__replaceArray, {"$BsN", self.__buffOwner:getAttr("name")})
    end

    if self.__buffTarget then
        table.insert(self.__replaceArray, {"$BtN", self.__buffTarget:getAttr("name")})
    end

    if self.__actualValue then
        table.insert(self.__replaceArray, {"$Bfd", self.__actualValue})
    end

    if self.__actAttrText and self.__actValue then
        table.insert(self.__replaceArray, {"$ArN", self.__actAttrText})
        table.insert(self.__replaceArray, {"$Ap", self.__actValue})
    end

    if self.__reduceStr then
        table.insert(self.__replaceArray, {"$dqR", self.__reduceStr})
    end

    if self.__zhaoCombName then
        table.insert(self.__replaceArray, {"$M", self.__zhaoCombName})
    end

    self.__isInit = false
end

function FightDesc:getString()
    if self.__text == nil then
        error("FightDesc:getString 没有设置文本，检查代码")
    end

    self:__initReplaceArray()

    -- $d 受击者受到的被动招式/主动招式直接气血伤害值
    -- $BsN 持有Buff角色姓名
    -- $BtN Buff效果目标角色名称
    -- $Bfd Buff效果造成实际伤害/恢复值
    -- $ArN 主动招式使用消耗需求资源名称
    -- $Ap 主动招式使用消耗需求资源数量

    --@RefType [src.app.FightSystem.FightBuff.Desc#Desc]
    local desc = Desc:create(self.__text, self.__replaceArray)

    return desc:getString()
end

-- 格式化减伤提示文字，供多处访问器复用
-- tipText 含 %d 时格式化拼入数值，否则直接返回原文本
function FightDesc.formatReduceText(tipText, value)
    if tipText == nil or tipText == "" then
        return nil
    end

    if string.find(tipText, "%%d") ~= nil then
        local formatValue = math.abs(math.ceil(value))
        return string.format(tipText, formatValue)
    end

    return tipText
end

return newClass("FightDesc", {}, FightDesc)
000000000000
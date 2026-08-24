local ItemDescInfo = {}

function ItemDescInfo:getShenBingDescInfo(itemAttr, role)
    local info = {}
    info.name = itemAttr.nameColor..itemAttr.name
    info.desc = ShenBingDesc:getShenBingDesc(itemAttr, true)
    info.damage = Helper:getDef(Helper:mathFloor(itemAttr:getWeaponDamage()),0)
    info.attrs = {}
    local yingduInfo = {
        name = "【硬度】",
        desc = "硬度：一把武器的硬度决定了它击碎他人的武器的难易程度。"
    }

    local yingDuDescInfo = ShenBingDesc:getYingDuDesc(itemAttr, role)

    if yingDuDescInfo then
        yingduInfo.state = yingDuDescInfo.hard1dsc
        yingduInfo.stateDesc = yingDuDescInfo.hard1text
    end
    
    yingduInfo.valueDesc = "硬度值："..Helper:mathFloor(itemAttr:getWeaponYingDu(role))
    table.insert(info.attrs, yingduInfo)

    local renDuInfo = {
        name = "【坚韧】",
        desc = "坚韧度：一把武器的坚韧度决定了它被他人武器击碎的难易程度。"
    }

    local renDuDescInfo = ShenBingDesc:getRenDuDesc(itemAttr, role)

    if renDuDescInfo then
        renDuInfo.state = renDuDescInfo.Tenacity1dsc
        renDuInfo.stateDesc = renDuDescInfo.Tenacity1text
    end

    renDuInfo.valueDesc = "坚韧值："..Helper:mathFloor(itemAttr:getWeaponRenDu(role))
    table.insert(info.attrs, renDuInfo)

    local stateInfo = {
        name = "【状态】",
        desc = "状态：一把武器状态决定它的伤害力，未达完美状态的武器可经修理达到完美状态。"
    }

    local wanhaodu = itemAttr.wanhaodu
    local maxWanHaodu = 100
    local state,stateDesc = ShenBingDesc:getShenBingStatusDesc({wanhaodu = wanhaodu})
    stateInfo.state = state
    stateInfo.stateDesc = string.gsub(stateDesc,state,"当前状态", 1)
    stateInfo.valueDesc = "完好度："..Helper:mathFloor(wanhaodu) .. "/" .. Helper:mathFloor(maxWanHaodu)
    table.insert(info.attrs, stateInfo)

    local weightInfo = {
        name = "【重量】",
        desc = "重量值：一把武器的重量值不仅决定了它是否容易被人击飞与击飞他人武器的难易程度，同时它也会影响攻击速度。"
    }

    local weightDescInfo = ShenBingDesc:getWeightDesc(itemAttr, role)
    if weightDescInfo then
        weightInfo.state = weightDescInfo.weight1level
        weightInfo.stateDesc = weightDescInfo.weight1text
    end

    weightInfo.valueDesc = "重量值："..Helper:mathFloor(itemAttr:getWeaponWeight(role))
    table.insert(info.attrs, weightInfo)

    local specialInfo = {
        name = "【基础特性】",
        desc = "基础特性：武器初始便具备的特点，可以给武器带来各种各样的加成效果。"
    }

    local effect = ShenBingDesc:getEffctOne(itemAttr)

    if effect then
        specialInfo.state = effect.name
        specialInfo.stateDesc = effect.specialdsc
    end

    specialInfo.valueDesc = "特性值："..Helper:mathFloor(itemAttr:getWeaponEffectNum(role))

    table.insert(info.attrs, specialInfo)

    local otherSpecialInfo = {
        name = "【附加特性】",
        desc = "附加特性：武器后续可改造的效果，可以给武器带来各种各样的加成效果。",
        state = "无",
        stateDesc = ""
    }

    local effect2 = ShenBingDesc:getEffctTwo(itemAttr)
    local effect3 = ShenBingDesc:getEffctThree(itemAttr)

    local str1,str2 = "",""

    if effect2 then
        str1 = effect2.name
        str2 = effect2.specialdsc
    end

    if effect3 then
        str1 = str1.."、"..effect3.name
        str2 = str2.."\n"..effect3.specialdsc
    end

    if str1 ~= "" then
        otherSpecialInfo.state = str1
        otherSpecialInfo.stateDesc = str2
    end

    otherSpecialInfo.valueDesc = "特性值："..Helper:mathFloor(itemAttr:getWeaponEffectNum(role))
    table.insert(info.attrs, otherSpecialInfo)

    return info
end

--isBreakage 是否破损
function ItemDescInfo:getNormalWeaponDescInfo(itemAttr, isBreakage, role)
    local info = {}
    info.name = itemAttr.name
    info.desc = itemAttr.dsc
    info.score = itemAttr.wuzang == -0 and 0 or itemAttr.wuzang
    info.damage = Helper:getDef(Helper:mathFloor(itemAttr:getWeaponDamage()),0)
    info.attrs = {}
    local yingduInfo = {
        name = "【硬度】",
        desc = "硬度：一把武器的硬度决定了它击碎他人的武器的难易程度。"
    }

    local yingDuDescInfo = ShenBingDesc:getYingDuDesc(itemAttr, role)

    if yingDuDescInfo then
        yingduInfo.state = yingDuDescInfo.hard1dsc
        yingduInfo.stateDesc = yingDuDescInfo.hard1text
    end

    yingduInfo.valueDesc = "硬度值："..Helper:mathFloor(itemAttr:getWeaponYingDu(role))

    table.insert(info.attrs, yingduInfo)

    local renDuInfo = {
        name = "【坚韧】",
        desc = "坚韧度：一把武器的坚韧度决定了它被他人武器击碎的难易程度。"
    }

    local renDuDescInfo = ShenBingDesc:getRenDuDesc(itemAttr, role)
    
    if renDuDescInfo then
        renDuInfo.state = renDuDescInfo.Tenacity1dsc
        renDuInfo.stateDesc = renDuDescInfo.Tenacity1text
    end

    renDuInfo.valueDesc = "坚韧值："..Helper:mathFloor(itemAttr:getWeaponRenDu(role))
    table.insert(info.attrs, renDuInfo)

    local stateInfo = {
        name = "【状态】",
        desc = "普通武器的状态主要描述武器的外观情况"
    }

    local wanhaodu = itemAttr.wanhaodu
    if isBreakage then
        wanhaodu = 0
    end
    local state,stateDesc = ShenBingDesc:getShenBingStatusDesc({wanhaodu = wanhaodu})
    stateInfo.state = state
    stateInfo.stateDesc = string.gsub(stateDesc,state,"当前状态", 1)
    stateInfo.valueDesc = "完好度："..Helper:mathFloor(wanhaodu) .. "/" .. Helper:mathFloor(itemAttr.wanhaodu)

    table.insert(info.attrs, stateInfo)

    local weightInfo = {
        name = "【重量】",
        desc = "重量值：一把武器的重量值不仅决定了它是否容易被人击飞与击飞他人武器的难易程度，同时它也会影响攻击速度。"
    }

    local weightDescInfo = ShenBingDesc:getWeightDesc(itemAttr, role)

    if weightDescInfo then
        weightInfo.state = weightDescInfo.weight1level
        weightInfo.stateDesc = weightDescInfo.weight1text
    end

    weightInfo.valueDesc = "重量值:"..Helper:mathFloor(itemAttr:getWeaponWeight(role))
    table.insert(info.attrs, weightInfo)

    local specialInfo = {
        name = "【基础特性】",
        desc = "基础特性：武器初始便具备的特点，可以给武器带来各种各样的加成效果。",
        state = "无",
        stateDesc = "",
        valueDesc = "特性值：0"
    }

    table.insert(info.attrs, specialInfo)

    local otherSpecialInfo = {
        name = "【附加特性】",
        desc = "附加特性：武器后续可改造的效果，可以给武器带来各种各样的加成效果。",
        state = "无",
        stateDesc = "",
        valueDesc = "特性值：0"
    }

    table.insert(info.attrs, otherSpecialInfo)

    return info
end

function ItemDescInfo:getArmorDescInfo(itemAttr)
    local info = {}
    info.name = itemAttr.name
    info.score = itemAttr.wuzang == -0 and 0 or itemAttr.wuzang
    info.protect = itemAttr.protect
    info.desc = itemAttr.dsc

    return info
end

return ItemDescInfo0000
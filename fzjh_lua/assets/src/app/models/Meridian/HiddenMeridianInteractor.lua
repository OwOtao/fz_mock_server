
local class = require("third.class.NewClass")

local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local HiddenMeridianInteractor = {}

function HiddenMeridianInteractor:create(role)
    local p = HiddenMeridianInteractor:new()
    p:__init(role)
    return p
end

function HiddenMeridianInteractor:ctor()
end

function HiddenMeridianInteractor:__init(role)
    self.__role = role

    self.__sys = role:getHiddenMeridianSystem()
end

function HiddenMeridianInteractor:getRole()
    return self.__role
end

function HiddenMeridianInteractor:getHiddenMeridianChartAcupointNum(chartLv,acupointLv)
    local hiddenMeridianChart = self.__sys:getHiddenMeridianChartByLv(chartLv)

    local acupointList = hiddenMeridianChart:getAcupointList()

    local num = 0

    for i,acupoint in ipairs(acupointList) do
        if acupoint:getClass() == acupointLv then
            num = num + 1
        end
    end

    return num
end

function HiddenMeridianInteractor:getRuleInfo()
    return [[
隐藏经脉可以提升拓展你的功法伤害和属性伤害能力。
每一个修炼的玄络图里面，都可以通过冲脉打开你的窍关，再从窍关上调整对应的玄络获得更强的武学收益。
每个窍关都需要利用冲脉进行解锁，解锁后才能调脉各种不同的玄络。
每个窍关适配的玄络都不同，【参伐】窍关颜色为红色，对应攻击形玄络。【守御】窍关颜色为蓝色，对应防守类玄络。【共贯】窍关颜色为绿色，对应通用形玄络。
不同的窍关等级也决定了可以调脉的玄络等级，高级窍关可以适配低级玄络。其中天门窍是最高级窍关，可适配目前等级下的全部玄络。
当玄络图中的窍关全部都冲脉解锁后，可以对你的玄络图进行破境，破境后可以提升为更高级的玄络图。
破境成功后，可以获得余炁效果，当余炁效果存在时，你可以获得前一个玄络图的综合属性提升，在余炁效果消失前，下一个玄络图的效果将暂时不会生效。
每个玄络都有对应的解锁条件，通过对江湖更多的探索，可以获得更强大适配的玄络。
冲脉和破境都需要时间修炼，使用养真丹可以对修炼有加速帮助。
每当你对破境后的玄络图冲脉成功后，余炁效果便会降低，直至你新的玄络图窍关全部冲脉完成后，余炁效果消失。
余炁效果也能手动取消，取消余炁效果后，将立刻使用当前玄络图的玄络效果。
玄络图在传承，离开师门时不会消失，重置角色后玄络图进度会同步消失。
]]
end

--@desc: 检查是否满足破境条件
--@author:LvBin
--@time:2025-02-20 15:49:03
--@return
function HiddenMeridianInteractor:canStartBreakThrough()
    if self.__sys:acupointAllActivate() == false then
        return false,"未达到破境需要，需要把当前脉络全部进行冲脉才能进行破境"
    end

    if self.__sys:isHiddenMeridianChartMaxLv() then
        return false,"当前玄络图已达最高级，暂时无法进行破境"
    end

    return true
end

function HiddenMeridianInteractor:getCurrHiddenMeridianBuffAttrList()
    local buffAttrList = {}

    local buffAttrs = self.__sys:getCurrHiddenMeridianBuffAttrs()

    if not MapIsEmpty(buffAttrs) then
        for damageId, v in pairs(buffAttrs) do
            for damageType, value in pairs(v) do
                local name = HiddenMeridianResources:getDamageAttrName(damageType,damageId)
                table.insert(buffAttrList, {name = name, value = value,damageId = damageId, damageType = damageType})
            end
        end
    end

    --@desc 排序映射表,攻击类型排在防御类型前面
    local typePriority = {
        atkDamageClass = 1,
        defDamageClass = 2
    }

    table.sort(buffAttrList,function(a,b)
        if a.damageId ~= b.damageId then
            return tonumber(a.damageId) < tonumber(b.damageId)
        else
            return typePriority[a.damageType] < typePriority[b.damageType]
        end
    end)

    return buffAttrList
end

function HiddenMeridianInteractor:getYuQiBuffAttrList()
    local buffAttrList = {}

    local buffAttrs = self.__sys:getYuQiBuffAttrs()

    if not MapIsEmpty(buffAttrs) then
        for damageId, v in pairs(buffAttrs) do
            for damageType, value in pairs(v) do
                local name = HiddenMeridianResources:getDamageAttrName(damageType,damageId)
                table.insert(buffAttrList, {name = name, value = value})
            end
        end
    end

    return buffAttrList
end

function HiddenMeridianInteractor:getHiddenMeridianBuffIdList(acupointId,buffLv)
    local acupoint = self.__sys:getAcupoint(acupointId)

    local acupointType = acupoint:getType()

    local acupointLv = acupoint:getClass()

    if acupointLv < buffLv then
        return {}
    end

    local buffIdList = {}

    local buffConfig = HiddenMeridianResources:getMeridianBuffConfig()

    for buffId,v in pairs(buffConfig) do
        if v.class == buffLv and v.type == acupointType then
            if self.__sys:isBuffAttach(buffId) or self.__sys:getHiddenMeridianBuff(buffId):canShow() then
                table.insert(buffIdList,buffId) 
            end
        end
    end

    --按照已解锁未装备、未解锁、已解锁已装备排序，然后再按buff ID排序。
    table.sort(
        buffIdList,
        function(a, b)
            local aPriority = 0
            local bPriority = 0
            local aUnlocked = self.__sys:isBuffUnlocked(a)
            local bUnlocked = self.__sys:isBuffUnlocked(b)
            local aAttach = self.__sys:isBuffAttach(a)
            local bAttach = self.__sys:isBuffAttach(b)

            if aUnlocked then
                aPriority = aAttach and 2 or 1
            else
                aPriority = 3
            end

            if bUnlocked then
                bPriority = bAttach and 2 or 1
            else
                bPriority = 3
            end

            -- 比较优先级
            if aPriority ~= bPriority then
                return aPriority < bPriority
            else
                -- 如果优先级相同，按 id 升序排序
                return tonumber(a) < tonumber(b)
            end
        end
    )

    return buffIdList
end

function HiddenMeridianInteractor:canAttachMeridianBuff(acupointId,meridianBuffId)
    local acupoint = self.__sys:getAcupoint(acupointId)

    if acupoint:isActivated() == false then
        return false, "需要进行冲脉才能进行调脉"
    end

    if acupoint:getAttachBuffId() == meridianBuffId then
        return false, "该玄络已装备在此窍关中，无需重复调脉"
    end

    return true
end

function HiddenMeridianInteractor:getAcupointTypeName(acupointType)
    return switch(acupointType,{
        [1] = "参伐",
        [2] = "守御",
        [3] = "共贯",
    })
end

function HiddenMeridianInteractor:getAcupointLvName(acupointLv)
    return switch(acupointLv,{
        [1] = "后土窍",
        [2] = "气渊窍",
        [3] = "天门窍",
    })
end

function HiddenMeridianInteractor:getAcupointLvUseText(acupointLv,acupointType)
    local acupointTypeName = self:getAcupointTypeName(acupointType)

    local useText = switch(acupointLv,{
        [1] = "正基"..acupointTypeName.."络可调脉使用。",
        [2] = "正基"..acupointTypeName.."络、中丹"..acupointTypeName.."络可调脉使用。",
        [3] = "正基"..acupointTypeName.."络、中丹"..acupointTypeName.."络、通元"..acupointTypeName.."络都可调脉使用。",
    })

    return useText
end

function HiddenMeridianInteractor:getMeridianBuffLvName(meridianBuffLv)
    return switch(meridianBuffLv,{
        [1] = "正基",
        [2] = "中丹",
        [3] = "通元",
    })
end

return class("HiddenMeridianInteractor", {}, HiddenMeridianInteractor)
0000000
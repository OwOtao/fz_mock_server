local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_Confirm = {}

function RoleUseItem_Confirm:__doUseItem()
    local role = self._role
    local item = self._item

    -----------------------------------------------------------
    ---------------  友盟接入
    if device.platform == "ios" then
        if item.priceUnit == "yuanbao" then
            Mob.use(item.id, 1, item.buyPrice)
        else
            Mob.use(item.id, 1, item.buyPrice)
        end
    end
    -----------------------------------------------------------------------------------------------------------
    -- @author GaoHanZheng
    -- @time 2017/06/20 14:37:01
    -- @desc 判断人物是否达到物品要求的最低等级
    if item.Norepeat ~= nil then
        if tonumber(role:getNumAttr("lv")) < tonumber(item.Norepeat) then
            self:__popText(item.Norepeattext)
            return
        end
    end

    item:__getItemAfterUse()

    if item.type == "节日酒" then
        if role:itemCanUse(item.id, 1) then
            item:__jieRiJiu()
        else
            self:__popText("物品不存在，可能已经消耗")
            return false
        end
    elseif item.canRewards == 1 then
        Item:getChestRewardByKey(item.id)

        if item.type == "食物" then
            local Meridian = require("app.models.Meridian.Meridian")
            Meridian:useFoodItem(role)
        elseif item.type == "宝箱" and item.famliyitem ~= nil then
            local list = string.split(item.famliyitem, ";")
            local familys = {}
            local items = {}
            if list[1] then
                familys = string.split(list[1], ",")
            end
            if list[2] then
                items = string.split(list[2], ",")
            end
            local familyId = role:getFamilyId()
            if not role:hasFamily() then
                familyId = "youxia"
            end
            for k, v in ipairs(familys) do
                if familyId == v then
                    local tabK = items[k]
                    if role:checkCanBuyTwoOrMoreThings({[tabK] = 1}) == true then --背包容量判断
                        role:addItemCount(items[k], 1)
                        self:__popText("获得物品" .. item.name .. "X" .. tostring(1))
                    else
                        -- role:addItemCount(item.id, 1)--如果容量不足要将扣除的物品重新加回来
                        self:__popText("背包空间不足")
                        return false
                    end
                end
            end
        end
    elseif item.type == "酒" then
        local Meridian = require("app.models.Meridian.Meridian")
        Meridian:useWineItem(role)
    end

    -- 属性加成
    if type(item.attr) == "table" and #item.attr >= 1 then
        local index = math.random(1, #item.attr)
        local attr = item.attr[index]

        local value = 0
        if type(item.value) == "string" then
            value = tonumber(Helper:GetValueFromScript(item.value, {qi = role:getAttr("qi"), lv = role:getLv(), meridianLevel = role:getMeridianLevel()}))
        elseif type(item.value) == "number" then
            value = item.value
        end

        if attr == "looks" and role:checkRoleIsPolymorph() then --容貌发生改变会取消易容
            role:cancelPolymorph()

            self:__richPrint("main", "因为某些原因，你的易容术失效了。")
            
            role:addAttr(attr, value)

            if MapIsEmpty(item.afterDesc) then
                role._iOutput:showAttrChangePopText(role, attr, value, 1)
            else
                role._iOutput:showAttrChangePopText(role, attr, value, #item.afterDesc)
            end
        elseif attr then
            if item.id == "jingmai101" then
                local Meridian = require("app.models.Meridian.Meridian")
                value = value + Meridian:useZhenQiDan(role, value, attr)
            elseif item.id == "jingmai103" then
                local Meridian = require("app.models.Meridian.Meridian")
                value = value + Meridian:useJingMaiDan(role, value, attr)
            end

            if attr == "neiliMax" then
                value = value + value * role:getNeiliItemRecoveryAddition() / 100
            end
            
            role:addAttr(attr, value)

            if MapIsEmpty(item.afterDesc) then
                role._iOutput:showAttrChangePopText(role, attr, value, 1)
            else
                role._iOutput:showAttrChangePopText(role, attr, value, #item.afterDesc)
            end
        end
    end

    role:addItemCount(item.id, -1, nil, nil, "物品使用")

    if item.id == "qiannengdan" then
        local QianNengDanUseRecord = require("app.models.Record.QianNengDanUseRecord.QianNengDanUseRecord")
        QianNengDanUseRecord:record(role, 1)
    end

    -- 使用道具 添加标记
    if item.flagType and item.flagValue then
        local flags = string.split(item.flagType, ";")

        if flags[1] == "Flag" then
            print("设置标记 " .. flags[2] .. " val = " .. item.flagValue)

            role:setFlag(flags[2], tonumber(item.flagValue))
        elseif flags[1] == "DayFlag" then
            print("设置每日标记 " .. flags[2] .. " val = " .. item.flagValue)

            role:setDayFlag(flags[2], tonumber(item.flagValue))
        elseif flags[1] == "TimeLimitFlag" then
            print("设置限时标记 " .. flags[2] .. " val = " .. item.flagValue .. " time = " .. item.flagTime)

            role:setTimeLimitFlag(flags[2], tonumber(item.flagValue), item.flagTime)
        end
    end

    -- add by XiaoZhiWei 2018/05/08 20:14:59 用于记录限制物品使用限制的次数,使用传承标记
    do
        if item.timesLimit ~= nil then
            local status = role:getInheritFlag("tLimit_" .. item.id)
            if status.times == 0 then
                -- add by XiaoZhiWei 2018/05/08 20:13:37 如果在查看的时候已经刷新,查看的时候会更新时间.此处为正式使用的节点,需要再次刷新使用时间
                status.updateTime = GetTime()
            end
            status.times = status.times + 1
            role:setInheritFlag("tLimit_" .. item.id, status)
        end
    end

    self:__onUseAft()

    -- 使用物品统计
    local Record = require("app.models.Record.Record")
    Record:checkUseItemNeedRecord(item.id)

    role:updateRoleBuff()

    return true
end

return NewClass("RoleUseItem_Confirm", {AbstractUseItem}, RoleUseItem_Confirm)
000000000000000
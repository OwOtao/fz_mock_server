local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_Composite = {}

function RoleUseItem_Composite:__canUseItem()
    local role = self._role

    local items = role:getAttr("items")
    local weight = role:getAttr("weight")
    if weight - #items < 1 then
        self:__popText("背包剩余容量不足 无法合成")
        return false
    end

    local materials = self:__getMaterialsAndRewardSchemeIdList()

    for k, v in pairs(materials) do
        if role:getItem(v.itemId) == nil or role:getItemCount(v.itemId) < v.count then
            print("itemId = " .. v.itemId .. " count = " .. v.count)
            self:__popText("材料不足，制作失败")
            return false
        end
    end

    return true
end

function RoleUseItem_Composite:__doUseItem()
    local item = self._item
    local role = self._role

    local materials,dropSchemeIdArray = self:__getMaterialsAndRewardSchemeIdList()

    -- 消耗材料
    for k, v in pairs(materials) do
        role:addItemCount(v.itemId, - v.count)
    end

    -- 获取策略奖励
    if #dropSchemeIdArray > 0 then
        for i, rewardSchemeId in ipairs(dropSchemeIdArray) do
            local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(rewardSchemeId, role:getAttr("exp"), role:getFinalAttr("luck"), role:getKongfu())
            for i, reward in ipairs(rewardArray) do
                if reward.type == "物品" then

                    self:__popText("获得了 " .. role:getOneItemByKey(reward.id).name)

                    role:addItemCount(reward.id, reward.value)
                elseif reward.type == "属性" then
                    if type(role:getCHAttrName(reward.id)) == "string" then
                        self:__popText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
                    end
                    role:addAttr(reward.id, reward.value)
                else
                    error()
                end
            end
        end
    end

    self:__richPrint(item.useDsc)
    self:__onUseAft()
    return true
end

function RoleUseItem_Composite:__getMaterialsAndRewardSchemeIdList()
    local item = self._item
    if type(item.compositeFormula) ~= "string" then
        assert(false,"不是合成物品 itemid:"..item.id)
    end
    local mapStr = string.split(item.compositeFormula, ";")
    local materials = {}
    local dropSchemeIdArray = {}
    if #mapStr >= 2 then
        mapStr[1] = string.gsub(mapStr[1], "{", "")
        mapStr[1] = string.gsub(mapStr[1], "}", "")

        mapStr[2] = string.gsub(mapStr[2], "{", "")
        mapStr[2] = string.gsub(mapStr[2], "}", "")

        -- 材料
        local materialStrs = string.split(mapStr[1], ":")

        if MapIsEmpty(materialStrs) == false then
            for k, v in pairs(materialStrs) do
                local str = string.split(v, ",")
                local itemId = str[1]
                local count = str[2]
                table.insert(materials, {itemId = itemId, count = tonumber(count)})
            end
        else
            assert(false,"合成材料有问题 itemid:"..item.id)
        end

        dropSchemeIdArray = string.split(mapStr[2], ",")

        if MapIsEmpty(dropSchemeIdArray) then
            assert(false,"物品合成奖励有问题 itemid:"..item.id)
        end
    end

    return materials, dropSchemeIdArray
end

return NewClass("RoleUseItem_Composite", {AbstractUseItem}, RoleUseItem_Composite)
0000000000000000
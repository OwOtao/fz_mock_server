local DreamEquip = {}

local SkillConst = require("app.models.skill.SkillConst")

function DreamEquip:_getDreamEquipRes()
    return User:getRole():getDreamSystem():getDreamEquipRes()
end

function DreamEquip:findNextStageItemId(itemId)
    --@region 查找当前兵器所属的兵器组并找出下一阶段物品id
    local dreamEquip_res = self:_getDreamEquipRes()
    local item_info = dreamEquip_res[itemId]
    local now_stage = item_info.armsstage
    local next_state = now_stage + 1

    local new_itemId
    for itemId, itemAttr in pairs(dreamEquip_res) do
        if item_info.id ~= itemId and next_state == itemAttr.armsstage and itemAttr.type == item_info.type then
            new_itemId = itemAttr.id
        end
    end

    if new_itemId == nil then
        error("梦境兵器查找下一等级错误，当前id : " .. itemId)
    end
    --@endregion

    return new_itemId
end

function DreamEquip:changeNextStageWeapon(role)
    local currFloor = role.dreamWorld.cFloor

    local stageFloorMap = {
        [5] = 2,
        [10] = 3,
        [15] = 4
    }

    if stageFloorMap[currFloor] == nil then
        return
    end

    --@desc 删除当前兵器
    local items = role:getItems()

    local dreamEquip_res = self:_getDreamEquipRes()
    for i = #items, 1, -1 do
        local roleItem = items[i]
        if dreamEquip_res[roleItem.itemId] ~= nil and dreamEquip_res[roleItem.itemId].armsstage < stageFloorMap[currFloor] then
            local equipItem = role:getEquipByName("weapon")
            local currItem = role:getOneItemByKey(roleItem.itemId)
            local currItemType2 = currItem.type2

            local nextItemId = self:findNextStageItemId(roleItem.itemId)
            local nextItem = role:getOneItemByKey(nextItemId)
            local onlyId = role:getItemOnlyId()

            nextItem.type2 = currItemType2
            if equipItem and equipItem.itemId == roleItem.itemId then
                roleItem.itemId = nextItemId
                roleItem.id = onlyId

                equipItem.itemId = nextItemId
                equipItem.id = onlyId
                role:setEquipByName("weapon", equipItem)
            else
                roleItem.itemId = nextItemId
                roleItem.id = onlyId
            end
        end
    end
end

-- --@desc: 淬炼当前装备的武器
-- --@author:Liang SongQiang
-- --@time:2019-09-25 11:08:30
-- function DreamEquip:cuilian(role, equip_data)
--     if equip_data == nil then
--         PopText("没有装备的武器")
--         return false
--     end

--     local equip_itemId = equip_data.itemId

--     local item_info = dreamEquip_res[equip_itemId]

--     local errmsg

--     local upgradeItem = item_info.upgradeItem
--     if upgradeItem ~= nil then
--         local count = role:getItemCount(upgradeItem)
--         if count <= 0 then
--             local item = role:getOneItemByKey(upgradeItem)
--             errmsg = "缺少淬炼材料" .. item.name
--             return false, errmsg
--         end
--     else
--         print("无需材料升级！")
--     end

--     local new_itemId = self:findNextStageItemId(equip_itemId)

--     if new_itemId == nil then
--         errmsg = "此兵器已无需淬炼了。"
--         return false, errmsg
--     end

--     self:changeWeapon(role, equip_data, new_itemId)

--     return true
-- end

-- --@desc: 武器重铸
-- --@author:Liang SongQiang
-- --@time:2019-09-25 14:48:07
-- --@target_weapon_type: 目标类型子类型
-- function DreamEquip:refactorWeapon(role, equip_data, target_weapon_type, target_weapon_subtype, callback)
--     local now_itemId = equip_data.itemId

--     local item_info = dreamEquip_res[now_itemId]

--     local now_stage = item_info.armsstage

--     local refactor_rand_list = {}
--     for itemId, item_attr in pairs(dreamEquip_res) do
--         if item_attr.id ~= now_itemId and item_attr.type == target_weapon_type and item_attr.type2 == target_weapon_subtype and item_attr.armsstage == now_stage then
--             table.insert(refactor_rand_list, item_attr)
--         end
--     end

--     if MapIsEmpty(refactor_rand_list) then
--         PopText("无法重铸成该类型。")
--         return callback(false)
--     end

--     local refactor_itemId = refactor_rand_list[math.random(1, #refactor_rand_list)].id

--     local now_item = role:getOneItemByKey(now_itemId)
--     local target_item = role:getOneItemByKey(refactor_itemId)

--     local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
--     local dialog = DialogALayer:getInstance()
--     dialog:hide()
--     dialog:show("您确定把" .. now_item.name .. "重铸成一" .. target_item.unit .. Item.WEAPON_GROUP[target_weapon_type][target_weapon_subtype] .. "吗？")
--     dialog:setButton1(
--         "确定",
--         function()
--             if self:changeWeapon(role, equip_data, refactor_itemId) == true then
--                 callback(true)
--             else
--                 callback(false)
--             end
--         end
--     )

--     dialog:setButton2(
--         "取消",
--         function()
--             dialog:hide()
--             callback(false)
--         end
--     )
-- end

function DreamEquip:changeByPrepareSkill(prepareType, skillId, role)
    local currEquipWeapon = role:getEquipByName("weapon")
    --@desc 没有装备兵器不用管
    if not currEquipWeapon then
        return
    end

    local skill = Skill:getSkill(skillId)
    if skill == nil then
        error("drequip change weapon error , prepareSkillId is wrong : " .. skillId)
    end

    local dreamEquip_res = self:_getDreamEquipRes()

    --@desc 如果不是装备的梦境的兵器，不需处理。
    local currWeaponInfo = dreamEquip_res[currEquipWeapon.itemId]
    if currWeaponInfo == nil then
        return
    end

    local subType = 1
    if MapIsEmpty(skill.weapontype) == false then
        local skillWeaponSubType = skill.weapontype[1]
        subType = tonumber(string.sub(skillWeaponSubType, -1))
    end
    
    local weaponType = SkillConst:getWeaponItemType(prepareType)

    local now_item = role:getOneItemByKey(currEquipWeapon.itemId)
    
    --@desc 当前兵器和准备的武学对应，什么都不用做
    if currWeaponInfo.type == weaponType then
        if subType ~= nil and subType == now_item.type2 then
            return
        end
    end

    for itemId, itemInfo in pairs(dreamEquip_res) do
        --@desc 根据准备的兵器类武学，转换成同品级对应的兵器
        if itemInfo.type == weaponType and currWeaponInfo.armsstage == itemInfo.armsstage then
            self:changeWeapon(role, currEquipWeapon, itemId, subType)
            break
        end
    end
end

function DreamEquip:equipWeapon(role,equip_data)
    if role == nil or equip_data == nil then
        return
    end

    local prepareSkills = role:getSkillPrepare()
    --@desc 获取装备的兵器武学，梦境副本中角色只能装备一个兵器武学
    local prepareSkillsTb = SkillConst:getPrepareWeaponSkills(prepareSkills)

    if MapIsEmpty(prepareSkillsTb) == true then
        --@desc 如果没有装备兵器武学什么都不用做
        return
    end

    --@desc 根据装备的兵器武学获取对应的兵器类型
    local skillId, prepareType
    for k, v in pairs(prepareSkillsTb) do
        prepareType = k
        skillId = v
        break
    end

    local skill = Skill:getSkill(skillId)
    if skill == nil then
        error("drequip change weapon error , prepareSkillId is wrong : " .. skillId)
    end

    local dreamEquip_res = self:_getDreamEquipRes()
    
    --@desc 如果不是装备的梦境的兵器，不需处理。
    local currWeaponInfo = dreamEquip_res[equip_data.itemId]
    if currWeaponInfo == nil then
        return
    end

    local subType = 1
    if MapIsEmpty(skill.weapontype) == false then
        local skillWeaponSubType = skill.weapontype[1]
        subType = tonumber(string.sub(skillWeaponSubType, -1))
    end

    local weaponType = SkillConst:getWeaponItemType(prepareType)

    local now_item = role:getOneItemByKey(equip_data.itemId)
    --@desc 当前兵器和准备的武学对应，什么都不用做
    if currWeaponInfo.type == weaponType then
        if subType ~= nil and subType == now_item.type2 then
            return
        end
    end

    for itemId, itemInfo in pairs(dreamEquip_res) do
        --@desc 根据准备的兵器类武学，转换成同品级对应的兵器
        if itemInfo.type == weaponType and currWeaponInfo.armsstage == itemInfo.armsstage then
            self:changeWeapon(role, equip_data, itemId, tonumber(subType))
            break
        end
    end
end


--@desc: 给角色替换武器,针对已装备的武器
--@author:Liang SongQiang
--@time:2019-09-25 11:06:57
function DreamEquip:changeWeapon(role, equip_data, new_itemId, type2)
    if role == nil or equip_data == nil or new_itemId == nil then
        print("参数错误！！！")
        return false
    end

    --@region 卸下当前装备并从背包删除
    local role_item, index = role:getItemWithOnlyId(equip_data.id)

    if role_item == nil then
        print("equip_data.id is not in role.items : " .. equip_data.id)
        PopText("武器更换异常")
        return false
    end

    if type2 ~= nil then
        local item = role:getOneItemByKey(new_itemId)
        item.type2 = type2
    end

    local onlyId = role:getItemOnlyId()
    role.items[index].itemId = new_itemId
    role.items[index].id = onlyId

    equip_data.itemId = new_itemId
    equip_data.id = onlyId
    role:setEquipByName("weapon", equip_data)
end

return DreamEquip
0
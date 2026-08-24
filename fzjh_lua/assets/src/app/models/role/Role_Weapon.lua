local Role_Weapon = {}

-- 获得当前武器名称
function Role_Weapon:getCurrWeaponName()
    local weapon = self:getEquipByName("weapon")
    if not weapon then
        return "拳脚"
    end
    local item = self:getOneItemByKey(weapon.itemId)
    if item == nil then
        return "拳脚"
    end

    if item.wpType == "神兵" then
        if string.len(item.name) > 21 then --最长名字五个汉字 两个颜色字符 长度最长21
            item.name = "普通神兵"
        end
    end
    return item.name
end

-- 获得当前武器类型
function Role_Weapon:getCurrWeaponType()
    local weapon = self:getEquipByName("weapon")
    if not weapon then
        return "拳脚"
    end

    local item = self:getOneItemByKey(weapon.itemId)
    if item == nil then
        return "拳脚"
    end
    return item.type
end

--获得当前武器子类型
function Role_Weapon:getCurrWeaponType2()
    local weapon = self:getEquipByName("weapon")
    if not weapon then
        return nil
    end

    local item = self:getOneItemByKey(weapon.itemId)
    if item == nil then
        return nil
    end
    return item.type2
end

-- 根据当前武器获取基础类型
function Role_Weapon:getCurrTypeByWeapon()
    local wtype = self:getCurrWeaponType()
    if wtype == "刀" then
        return "daofa"
    elseif wtype == "剑" then
        return "jianfa"
    elseif wtype == "暗器" then
        return "anqi"
    elseif wtype == "棍" then
        return "gunfa"
    elseif wtype == "鞭" then
        return "bianfa"
    elseif wtype == "双持" then
        return "shuangchi"
    elseif wtype == "乐器" then
        return "qinfa"
    else
        return "quanjiao"
    end
end

-- 根据当前武器获取基础子类型
function Role_Weapon:getCurrSubtypeByWeapon()
    local subType = self:getCurrWeaponType2()
    local baseType = self:getCurrTypeByWeapon()

    return baseType == "quanjiao" and "quanjiao" or baseType .. subType
end

function Role_Weapon:getMethodByWeaponType(weaponType)
    local method = switch(weaponType, {["拳脚"]=1, ["剑"]=5, ["刀"]=6, ["棍"]=7, ["鞭"]=9, ["暗器"]=8, ["双持"]=10, ["乐器"]=11, default = nil})
    return method
end

function Role_Weapon:setShenBingItems(shenBingItems)
    if MapIsEmpty(shenBingItems) == false then
        self.shenBingItems = TableProxy:createDataValidationTableRecursive(shenBingItems)
    end
end

--[[
    @desc: 判断物品是否为神兵
    author:TangJian
    time:2022-01-17 20:21:58
    --@itemId: 
    @return:
]]
function Role_Weapon:isShengBing(itemId)
    if self.shenBingItems then
        for i, v in ipairs(self.shenBingItems) do
            if itemId == v.id then
                return true
            end
        end
    end
    return false
end

-- 获取默认神兵
function Role_Weapon:getDefaultShenBing()
    if not self.defaultShenBingItemId then
        return 
    end

    local shenBing = self:getOneItemByKey(self.defaultShenBingItemId)
    if not shenBing then
        self.defaultShenBingItemId = nil
    end

    return shenBing
end

return Role_Weapon
000000000000000
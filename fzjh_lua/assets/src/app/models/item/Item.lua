local mapList = {}

local Item = {}
function Item:getItemsList()
	return mapList
end

Item.ITEM_TYPE = {
    --@desc 兵器类型
    WEAPON_TYPE = {
        DAO = "刀",
        JIAN = "剑",
        GUN = "棍",
        BIAN = "鞭",
        ANQI = "暗器",
        SHUANGCHI = "双持",
        QIN = "乐器"
    },

    --@desc 兵器子类
    WEAPON_SUBTYPE = {
        CHANGDAO = 1,
        DUANDAO = 2,
        WANDAO = 3,
        DAHUANDAO = 4,
        SHUANGRENFU = 5,

        CHANGJIAN = 1,
        DUANJIAN = 2,
        RUANJIAN = 3,
        ZHONGJIAN = 4,
        CIJIAN = 5,

        CHANGGUN = 1,
        CHANGQIANG = 2,
        SANJIEGUN = 3,
        LANGYABANG = 4,
        ZHANJI = 5,

        CHANGBIAN = 1,
        RUANBIAN = 2,
        JIUJIEBIAN = 3,
        GANZIBIAN = 4,
        LIANJIA = 5,

        SHUANGHUAN = 1,
        DUIJIAN = 2,
        SHUANGGOU = 3,

        ZUIXINGANQI =  1,
        YUANXINGANQI = 2,
        ZHENXINGANQI = 3,

        GUQIN = 1,
        DIZI = 2,
    }
}

Item.WEAPON_GROUP = {
    [Item.ITEM_TYPE.WEAPON_TYPE.DAO] = {
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGDAO] = "长刀",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.DUANDAO] = "短刀",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.WANDAO] = "弯刀",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.DAHUANDAO] = "大环刀",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.SHUANGRENFU] = "双刃斧",
    },
    [Item.ITEM_TYPE.WEAPON_TYPE.JIAN] = {
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGJIAN] = "长剑",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.DUANJIAN] = "短剑",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.RUANJIAN] = "软剑",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.ZHONGJIAN] = "重剑",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.CIJIAN] = "刺剑",
    },
    [Item.ITEM_TYPE.WEAPON_TYPE.GUN] = {
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGGUN] = "长棍",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGQIANG] = "长枪",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.SANJIEGUN] = "三节棍",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.LANGYABANG] = "狼牙棒",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.ZHANJI] = "战戟",
    },
    [Item.ITEM_TYPE.WEAPON_TYPE.BIAN] = {
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGBIAN] = "长鞭",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.RUANBIAN] = "软鞭",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.JIUJIEBIAN] = "九节鞭",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.GANZIBIAN] = "杆子鞭",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.LIANJIA] = "链枷",
    },
    [Item.ITEM_TYPE.WEAPON_TYPE.ANQI] = {
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.ZUIXINGANQI] = "锥形暗器",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.YUANXINGANQI] = "圆形暗器",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.ZHENXINGANQI] = "针形暗器",
    },
    [Item.ITEM_TYPE.WEAPON_TYPE.SHUANGCHI] = {
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.SHUANGHUAN] = "双环",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.DUIJIAN] = "对剑",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.SHUANGGOU] = "双钩",
    },
    [Item.ITEM_TYPE.WEAPON_TYPE.QIN] = {
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.GUQIN] = "古琴",
        [Item.ITEM_TYPE.WEAPON_SUBTYPE.DIZI] = "笛子"
    }
}

function Item:getOneItemByKey(key)
    -- key为nil或者空串的时候直接返回nil
    if key == nil or key == "" then
        return nil
    end

    -- add by XiaoZhiWei 2017/11/28 16:33:54 检查是否是神兵
    local role = User:getRole()


    local fq = role:getHomelandAttr("fq")
    if not MapIsEmpty(fq) and fq.id == key then
        return role:getOneItemByKey(key)
    end

    local dq = role:getHomelandAttr("dq")
    if dq and not MapIsEmpty(dq) then
        for k, dqData in pairs(dq) do
            if key == dqData.id then
                return role:getOneItemByKey(key)
            end
        end
    end


    local shenBingItems = role:getAttr("shenBingItems")
    for k, weapen in pairs(shenBingItems) do
        if key == weapen.id then
            return role:getOneItemByKey(key)
        end
    end

    local yq = role:getHomelandAttr("yq")
    if yq and not MapIsEmpty(yq) then
        for k,v in pairs(yq) do
            if key == v.id then
                return role:getOneItemByKey(key)
            end
        end
    end

    local str = string.find( key,"shihe_" )
    if str then
        local temp = {
            id = key,
            name = "食盒",
            dsc = "这是一个带着热气、尚有余温的食盒，里面装着家中厨子做好的饭食。",
            type = "食盒",
            timeend = 3600 * 2
        }
        local item = Helper:tableCover(require("app.models.item.BaseItem"):create(),temp)
        item.canUse = ITEM_STATE_TRUE
        item.deposit = false
        mapList[item.id] = item
        return item
    end

    if mapList[key] ~= nil then
        return mapList[key]
    else
        -- add by XiaoZhiWei 2018/12/03 17:25:11 初始化指定物品
        self:initOneItem(key)
        if mapList[key] ~= nil then
            return mapList[key]
        end
    end

    -- if not mapList[key] then
    -- assert(nil, "Item:getOneItemByKey(key) -> 物品不存在。"..tostring(key))
    if PRINT_MODE == 1 then
        print("物品不存在。   ->   " .. tostring(key))
    end
    -- 	return
    -- end
    -- return mapList[key]
end

function Item:getItemByKey(key)
    if mapList[key] ~= nil then
        return mapList[key]
    else
        local str = string.find( key,"shihe_" )
        if str then
            local temp = {
                id = key,
                name = "食盒",
                dsc = "这是一个带着热气、尚有余温的食盒，里面装着家中厨子做好的饭食。",
                type = "食盒",
                timeend = 3600 * 2
            }
            local item = Helper:tableCover(require("app.models.item.BaseItem"):create(),temp)
            item.canUse = ITEM_STATE_TRUE
            item.deposit = false
            mapList[item.id] = item
            return item
        end

        -- add by XiaoZhiWei 2018/12/03 17:25:11 初始化指定物品
        self:initOneItem(key)
        if mapList[key] ~= nil then
            return mapList[key]
        end
    end
end

function Item:getOneItemByKeyWithEncrypted(key)
    local item = self:getOneItemByKey(key)

    if not item then
        return nil
    end

    return inherit(TableProxy:createEncryptedTableRecursive(item), item)
end

function Item:getItemsByType(tyName)
    if not tyName then
        return
    end
    local rTab = {}
    for k, v in pairs(mapList) do
        if v.type and v.type == tyName then
            table.insert(rTab, v)
        end
    end
    return rTab
end

-- 商城物品基本属性解析
function Item:analysisStoreItems(item)
    if not item then
        return
    end
    local index = 0
    local attr = {}
    if item.att then
        local str = tostring(item.att)
        while string.find(str, ",", index) ~= nil do
            local send = string.find(str, ",", index)
            table.insert(attr, string.sub(str, index, send - 1))
            index = send + 1
        end
        table.insert(attr, string.sub(str, index))
    end
    item.attr = attr

    local afterDesc = {}
    for i = 1, 100 do
        if item["effectDsc_" .. i] == nil then
            break
        end
        table.insert(afterDesc, item["effectDsc_" .. i])
    end
    item.afterDesc = afterDesc
end

function Item:initItemAttr(item, itemListAttr,source)
    self:analysisStoreItems(item)

    if item.type == nil or MapIsEmpty(itemListAttr) then
        return
    end

    local itemAttr = itemListAttr[item.type]
    if MapIsEmpty(itemAttr) then
        return
    end

    for key, attr in pairs(itemAttr) do
        if not item[key] then
            item[key] = attr
        end
    end

    if item.zhaoId ~= nil then
        item.skillid = Skill:getSkillIdByZhaoId(item.zhaoId)
	end
	
	if item.type == "毒药" then
		local PoisonList = require("script.others.poison")["poison"]
		Helper:tableCover(item,PoisonList[item.id])
	end
    --@desc 初始化家具表
    if item.type == "家具" then
        --@RefType [src.app.models.HomelandModel.FurnitureModel.FurnitureModel#FurnitureModel]
        local FurnitureModel = require("app.models.HomelandModel.FurnitureModel.FurnitureModel")
        FurnitureModel:initItemData(item)
    end

    item.source = source

    --加入词缀
    -- item.cizhui = setCiZhui(item)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/12/03 17:15:52
-- @params 
-- @desc 初始化指定的物品
function Item:initOneItem(itemId)
    if itemId == nil then
        return
    end

    if itemId == "byfenshenfu" then
        return
    end

    -- 商城物品初始化
    local dataList = assert(requireWithEncrypt("script.store.storeItem"))
    -- 副本物品
    local itemList = assert(require("script.map.mapItemAttr"))
    -- 副本物品类型
    local itemListAttr = itemList["TypeAndAttr"]
    -- 初始化程序定义资源
    local itemRes = assert(require("app.models.item.ItemResource"))


    local item = {}
    if MapIsEmpty(dataList.shangchengwupin) == false and dataList.shangchengwupin[itemId] ~= nil then
        item = dataList.shangchengwupin[itemId]
        -- add by XiaoZhiWei 2018/12/03 17:18:02 itemId不传,保持原有逻辑,全部初始化,传递了itemId则只初始化指定ID物品
        self:initItemAttr(item)

        do
            local tab = {
                dundifu = 1,
                dabuwan = 1,
                fenshenfu = 1,
                jingxinwan = 1,
                sancaidan = 1,
                xinggongsan = 1
            }
            if tab[item.id] ~= nil then
                item.canEquip = ITEM_STATE_FALSE
                item.canUse = ITEM_STATE_FALSE
                item.canUseSpecial = ITEM_STATE_TRUE
            else
                item.canUse = ITEM_STATE_TRUE
            end
        end
        item.type = "消耗品"
    end

    --@desc 策划定义资源
    local itemResList = {
        "Items",
        "drItems",
        "drequipment",
        "mask",
        "equipment",
        "homeland",
        "appearance",
        "created",
        "fondDrItems",
        "fondDrequipment",
    }

    for _,sheetName in ipairs(itemResList) do
        if MapIsEmpty(itemList[sheetName]) == false and itemList[sheetName][itemId] ~= nil then
            item = itemList[sheetName][itemId]
            self:initItemAttr(item, itemListAttr,sheetName)
        end
    end

    --@desc 程序定义资源
    if MapIsEmpty(itemRes) == false and itemRes[itemId] ~= nil then
        item = itemRes[itemId]
        self:initItemAttr(item, itemListAttr,"ItemResource")
    end

    -- 找不到物品的时候不赋值
    if MapIsEmpty(item) == true then
        return
    end
    
    mapList[itemId] = Helper:tableCover(require("app.models.item.BaseItem"):create(), item)

    mapList[itemId] = inherit(TableProxy:createEncryptedTableRecursive(mapList[itemId]),mapList[itemId])

    self:initChestReward(itemId)

    --@desc 判断是否武器
    if Item:itemIsWeapon(mapList[itemId]) then
        self:initWeaponFlyAndBreak(mapList[itemId],mapList[itemId].type,mapList[itemId]:getCurrWeaponType2())
    end
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/12/03 17:19:07
-- @params 
-- @desc 初始化所有物品
function Item:initStoreItem()
    -- 商城物品初始化
    local dataList = assert(require("script.store.storeItem"))
    for sheetName, list in pairs(dataList) do
        for k, v in pairs(list) do
            list[k] = createEncryptTable(v)
        end
    end

    local itemList = assert(require("script.map.mapItemAttr"))
    -- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 买卖价格,是否放入仓库等属性)
    for sheetName, list in pairs(itemList) do
        for k, v in pairs(list) do
            list[k] = createEncryptTable(v)
        end
    end
end

-- 初始化宝箱奖励
function Item:initChestReward(itemId)
    if mapList[itemId] == nil then
        return 
    end

    -- for id, item in pairs(mapList) do
    local item = mapList[itemId]
    if item.canRewards == 1 then
        do
            -- 道具奖励索引
            local rewardIndex = 1

            item.rewardID = {}
            item.rewardPR = {}
            -- 开启宝箱所需的背包空间
            item.rewardNeedSpace = 0
            while true do
                local str = "rwId" .. rewardIndex
                if item[str] == nil then
                    break
                end

                local strMap = string.split(item[str], ";")

                -- 奖励ID
                local rwID = strMap[1]
                -- 概率
                local pr = strMap[2]
                if pr == nil then
                    pr = 1
                end

                rwID = string.gsub(rwID, "{", "")
                rwID = string.gsub(rwID, "}", "")

                -- 奖励ID
                item.rewardID[rewardIndex] = rwID
                -- 奖励概率
                item.rewardPR[rewardIndex] = pr
                rewardIndex = rewardIndex + 1
            end

            --item.dropScheme = "fubenxiangzi;fubenxiangzi;fubenxiangzi;fubenxiangzi;fubenxiangzi"
            -- 初始化策略奖励
            if type(item.dropScheme) == "string" and #item.dropScheme > 0 then
                local dropSchemeIdArray = string.split(item.dropScheme, ";")
                item.dropSchemeIdArray = dropSchemeIdArray
            else
                item.dropSchemeIdArray = {}
            end
        end

        -- add by XiaoZhiWei 2018/12/04 15:34:27 上面步骤做完了,做下面步骤. (按两大步骤分块)
        do
            -- 计算开启宝箱所需要的背包位置
            local itemReward = assert(requireWithEncrypt("script.map.mapItemAttr")["Rewards"])
            for k, v in pairs(item.rewardID) do
                --print(item.name .. "奖励 = ")
                local strMap = string.split(v, ",")
                local itemcount = 0

                for j, n in ipairs(strMap) do
                    if itemReward[n].rwType == "物品" then
                        itemcount = itemcount + 1
                    end
                end

                if itemcount > item.rewardNeedSpace then
                    item.rewardNeedSpace = itemcount
                end
            end
        end
    end
end

-- 打开宝箱奖励
function Item:getChestRewardByKey(key)
    local item = self:getOneItemByKey(key)
    local itemReward = assert(requireWithEncrypt("script.map.mapItemAttr")["Rewards"])
    local role = User:getRole()

    if item.canRewards == 1 then
        local UseItemDirectRewardGet = require("app.models.reward.UseItemDirectRewardGet")

        UseItemDirectRewardGet:create(item,role):doGetReward(function (rewardArray)
            for i, reward in ipairs(rewardArray) do
                local rid = reward.rid
                local rewardInfo = itemReward[rid]
                -- 显示文本
                if rewardInfo.rwText ~= nil then
                    local textDesc = string.split(rewardInfo.rwText, ";")
                    local num = math.random(1, #textDesc)
                    RichPrint("main", textDesc[num])
                end

                if reward.type == "属性" then
                    role:addAttr(reward.id, reward.value)
                    PopText(role:getCHAttrName(reward.id) .. " + " .. reward.value)
                elseif reward.type == "物品" then
                    role:addItemCount(reward.id, reward.value)
                    PopText("获得了 " .. self:getOneItemByKey(reward.id).name .. "X" .. reward.value)
                else
                    assert(false, "未知奖励类型")
                end
            end
        end)

        -- 获取策略奖励
        if #item.dropSchemeIdArray > 0 then
            --@RefType [src.app.models.Record.Reward.ARewardRecord#ARewardRecord]
            local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")

            --@RefType [src.app.models.reward.OpenRewardGet#OpenRewardGet]
            local openRewardGet =
                require("app.models.reward.OpenRewardGet"):create(
                role,
                item.dropSchemeIdArray,
                ARewardRecord.RTYPE.USE_ITEM,
                "rewardArrayWithRewardScheme",
                {
                    itemid = item.id
                }
            )

            openRewardGet:doGetReward(
                function(rewardArray)
                    for i, reward in ipairs(rewardArray) do
                        if reward.type == "物品" then
                            -- PopText("掉落物品: " .. reward.id .. reward.value)
                            PopText("获得了 " .. self:getOneItemByKey(reward.id).name .. "X" .. reward.value)
                            role:addItemCount(reward.id, reward.value)
                        elseif reward.type == "属性" then
                            local value = reward.value
                            if type(role:getCHAttrName(reward.id)) == "string" then
                                PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(value))
                            end
                            role:addAttr(reward.id, value)
                        else
                            error("Item:getChestRewardByKey 开出未知的奖励类型 ：" .. item.id)
                        end
                    end
                end
            )
        end
    end
end


-- 获取物品使用上限
function Item:getItemUseLimit(iType,itemId)
    local limitMap = {
        ["商城物品使用限制"] = 3,
        ["经验潜能次数"] = 20
    }

    local result = limitMap[iType]
    if result == nil then
        result = 1000
    end

    local role = User:getRole()
    if role:yueKaIsValid() == true then
        result = result + 1
    end

    --明玉功被动效果，提高每日服用洗颜水的数量上限
    if itemId == "xiyanshui" then
        if role:getSkill("xinmingyugong") ~= nil then
            local skillLv = role:getSkillLv("xinmingyugong")
            local mingyugongConfig = requireWithEncrypt("script.zhishiSkills.mingyugongAddConf")["天机诀属性"]
            local addCount = 0
            for k, v in pairs(mingyugongConfig) do
                if skillLv >= v.level and addCount < v.num then
                    addCount = v.num
                end
            end

            result = result + addCount
        end
    end

    return result
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/12/03 16:19:51
-- @params 
-- @desc 初始化方法
function Item:init()
    self:initStoreItem()
end

local weaponFlyAndBreakMaps = {}

local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")

--初始化武器打断打飞属性
-- flyWeapon:
-- 1=该类型武器可在战斗中打飞对方武器
-- 0=该类型武器不能在战斗中打飞对方武器
-- beflyWeapon:
-- 1=该类型武器可在战斗中被对方武器打飞
-- 0=该类型武器不能在战斗中被对方武器打飞
-- breakWeapon:
-- 1=该类型武器可在战斗中打断对方武器
-- 0=该类型武器不能在战斗中打断对方武器
-- brokenWeapon:
-- 1=该类型武器可在战斗中被对方武器打断
-- 0=该类型武器不能在战斗中被对方武器打断
function Item:initWeaponFlyAndBreak(weapon, firstType, secordType)
    --@desc 武器分类管理表一级类型琴已经改成乐器，数据此时还没有转，需要特殊处理
    if firstType == "琴" then
        firstType = "乐器"
    end

    if weaponFlyAndBreakMaps[firstType .. "|" .. secordType] then
        weapon.breakWeapon = weaponFlyAndBreakMaps[firstType .. "|" .. secordType].breakWeapon --打断武器
        weapon.flyWeapon = weaponFlyAndBreakMaps[firstType .. "|" .. secordType].flyWeapon --打飞武器
        weapon.brokenWeapon = weaponFlyAndBreakMaps[firstType .. "|" .. secordType].brokenWeapon --被打断武器
        weapon.beflyWeapon = weaponFlyAndBreakMaps[firstType .. "|" .. secordType].beflyWeapon --被打飞武器
        return
    end
    
    local weaponBaseInfo = WeaponTypesResManager:getWeaponInfoByTypeAndType2(firstType, secordType)

    local weaponTypeRes = {}
    weapon.breakWeapon = weaponBaseInfo.breakWeapon --打断武器
    weapon.flyWeapon = weaponBaseInfo.flyWeapon --打飞武器
    weapon.brokenWeapon = weaponBaseInfo.brokenWeapon --被打断武器
    weapon.beflyWeapon = weaponBaseInfo.beflyWeapon --被打飞武器

    weaponTypeRes.breakWeapon = weaponBaseInfo.breakWeapon --打断武器
    weaponTypeRes.flyWeapon = weaponBaseInfo.flyWeapon --打飞武器
    weaponTypeRes.brokenWeapon = weaponBaseInfo.brokenWeapon --被打断武器
    weaponTypeRes.beflyWeapon = weaponBaseInfo.beflyWeapon --被打飞武器

    weaponFlyAndBreakMaps[firstType .. "|" .. secordType] = weaponTypeRes
end

function Item:itemIsWeapon(item)
    local firstType = item.type

    local secType = item:getCurrWeaponType2()

    if WeaponTypesResManager:itemIsWeaponType(firstType,secType) then
        return true
    end

    return false
end

--需服务器验证道具
function Item:isServerOnlyCheckItem(itemId)
    local ServerItemConst = require("app.models.item.ServerItemConst")
    if table.keyof(ServerItemConst.SERVER_ONLY_CHECK_ITEM_ID, itemId) ~= nil then
        return true
    end

    return false
end

--需服务器验证且消耗道具
function Item:isServerCheckAndUseItem(itemId)
    local ServerItemConst = require("app.models.item.ServerItemConst")
    if table.keyof(ServerItemConst.SERVER_ITEM_ID, itemId) ~= nil then
        return true
    end

    return false
end
-- 加密标记
Item.isEncrypted = true
return Item
0000000
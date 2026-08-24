--[[
    author:Seven
    time:2022-08-02 14:11:25
    desc: 数据修复相关
]]
local newClass = require("third.class.NewClass")

local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")

local anqiFixConfig = require("script.others.godweaponDebuganqi")["config"]

local godweaponDebugtypeDesc = require("script.others.godweaponDebugtypeDesc")["config"]

local godweaponAttrRepair = requireWithEncrypt("script.others.godweaponAttrRepair")["config"]

local ShenBingRepair = {}

function ShenBingRepair:create(role)
    local p = ShenBingRepair.new()

    p:__init(role)

    return p
end

function ShenBingRepair:__init(role)
    self.__role = role
end

function ShenBingRepair:repair()
    if self.__role.repairXuanBingDong == nil then
        self:__repairXuanBingDong()
    end

    if self.__role.repairXuanBingDong == 1 then
        self:__repairAnQiData()
    end

    if self.__role.repairXuanBingDong == 2 then
        self:__repairShenBingType()
    end

    if self.__role.repairXuanBingDong == 3 then
        self:__repaireShenBingDescAndDuanZaoItems()
    end

    if self.__role.repairXuanBingDong == 4 then
        self:__repairShenBingDuanZaoItems()
    end

    if self.__role.repairXuanBingDong == 5 then
        self:__repeatRepairShenBingTypeDesc()
    end

    if self.__role.repairXuanBingDong == 6  then
        self:__repaireBagShenBingWanHaoDu()
    end

    if self.__role.repairXuanBingDong == 7  then
        self:__repaireShenBingCuiLianAttr()
    end

    if self.__role.repairXuanBingDong == 8  then
        self:__repaireShenBingDamage()
    end

    self:__popTextShenBingErrorTips()
end

function ShenBingRepair:printFixDataDiff()
    print("本地数据修复：")
    if not MapIsEmpty(self.__anqiFixData.fix_local) then
        for i, fix_itemId in ipairs(self.__anqiFixData.fix_local) do
            print("修复物品id：", fix_itemId)
            local prev_item
            local aft_item
            for i, v in ipairs(self.__anqiFixData.prev_local) do
                if v.id == fix_itemId then
                    prev_item = v
                    break
                end
            end

            for i, v in ipairs(self.__anqiFixData.aft_local) do
                if v.id == fix_itemId then
                    aft_item = v
                    break
                end
            end

            for attrName, value in pairs(prev_item) do
                if type(value) ~= "table" and value ~= aft_item[attrName] then
                    print(string.format("神兵描述：%s, 属性（%s）, prev : %s , aft : %s", prev_item.typeDesc, attrName, tostring(value), tostring(aft_item[attrName])))
                end
            end
        end
    end
    print("本地数据修复结束")

    print("玄兵洞数据修复：")
    if not MapIsEmpty(self.__anqiFixData.fix_xbd) then
        for i, fix_itemId in ipairs(self.__anqiFixData.fix_xbd) do
            print("修复物品id：", fix_itemId)
            local prev_item
            local aft_item
            for i, v in ipairs(self.__anqiFixData.prev_xbd) do
                if v.id == fix_itemId then
                    prev_item = v
                    break
                end
            end

            for i, v in ipairs(self.__anqiFixData.aft_xbd) do
                if v.id == fix_itemId then
                    aft_item = v
                    break
                end
            end

            for attrName, value in pairs(prev_item) do
                if type(value) ~= "table" and value ~= aft_item[attrName] then
                    print(string.format("神兵描述：%s, 属性（%s）, prev : %s , aft : %s", prev_item.typeDesc, attrName, tostring(value), tostring(aft_item[attrName])))
                end
            end
        end
    end
    print("玄兵洞数据修复结束")
end

function ShenBingRepair:__getAnqiFixConfig(typeDesc)
    for _, v in pairs(anqiFixConfig) do
        if typeDesc == v.typeDesc then
            return v
        end
    end
end

function ShenBingRepair:__repairXuanBingDong()
    local role = self.__role
    -- add by XiaoZhiWei 2018/02/09 17:46:13 修复背包中神兵不存在的情况
    do
        local items = role:getItems()
        -- add by XiaoZhiWei 2018/02/09 18:14:42 神兵列表不为空
        if MapIsEmpty(items) == false then
            local removeItems = {}
            for i, item in ipairs(items) do
                -- add by XiaoZhiWei 2018/02/09 18:14:48 神兵资源获取不到.直接移除掉该神兵.后面的修复会将角色身上的神兵上传至藏兵阁
                if item.type == "神兵" and role:getOneItemByKey(item.itemId) == nil then
                    -- add by XiaoZhiWei 2018/02/09 18:18:37 判断神兵是否被装备, 如果被装备,则直接摘除
                    if role:getEquipByName("weapon") ~= nil and role:getEquipByName("weapon").itemId == item.itemId then
                        role:setEquipByName("weapon", nil)
                    end
                    table.insert(removeItems, i)
                end
            end

            if MapIsEmpty(removeItems) == false then
                for i, index in ipairs(removeItems) do
                    table.remove(items, index)
                end
            end
        end
    end

    -- add by XiaoZhiWei 2018/02/09 18:19:30 神兵系统历史问题修复
    do
        local shenBingItems = role:getAttr("shenBingItems")
        local updateList = {}
        local forgeCount = role:getAttr("forgeCount")
        local tmpShenBing = {}
        for k, shenBing in pairs(shenBingItems) do
            if tmpShenBing[shenBing.id] ~= true then
                tmpShenBing[shenBing.id] = true
                if role:getItemCount(shenBing.id) > 0 then
                else
                    table.insert(updateList, shenBing)
                end
            else
                shenBing.id = "weapon_" .. forgeCount
                forgeCount = forgeCount + 1
                role:addAttr("forgeCount", 1)
                table.insert(updateList, shenBing)
            end
        end
        if updateList[1] ~= nil then
            ShenBingDuanZao:updateDataToXuanBingDong(updateList[1].id, updateList[1], updateList)
        end
    end
    role.repairXuanBingDong = 1
end

function ShenBingRepair:__repairAnQiData()
    self.__anqiFixData = {
        prev_local = {},
        aft_local = {},
        fix_local = {},
        prev_xbd = {},
        aft_xbd = {},
        fix_xbd = {}
    }
    --@desc 修正本地神兵数据
    self:__repaireLocalAnQiData()
    --@desc 修正玄兵洞数据（修正玄兵洞存放的数据，此举只为避免本地回档后可能以玄兵洞数据为准的情况）
    self:__repairAnQiInXuanBingDong()

    print("修复神兵暗器数据")
    self:printFixDataDiff()

    HttpManagerEx:uploadWeaponRepairLog(
        self.__anqiFixData,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                return true
            else
                PopText(errmsg)

                print(errcode, errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )

    self.__role.repairXuanBingDong = 2
end

function ShenBingRepair:__repaireLocalAnQiData()
    local shenbingItems = self.__role.shenBingItems
    local shenbingItemsCache = self.__role._shenbingCache

    if MapIsEmpty(shenbingItems) then
        return
    end
    local preShengBingItems = clone(shenbingItems)

    self.__anqiFixData.prev_local = preShengBingItems

    for _, shenbingdata in ipairs(shenbingItems) do
        if shenbingdata.type == Item.ITEM_TYPE.WEAPON_TYPE.ANQI then
            self:__correctionAnQiData(shenbingdata)
            --神兵缓存也同步修改
            if shenbingItemsCache and shenbingItemsCache[shenbingdata.id] then
                self:__correctionAnQiData(shenbingItemsCache[shenbingdata.id])
            end
            table.insert(self.__anqiFixData.fix_local, shenbingdata.id)
        end
    end

    local aftShenbingItems = clone(shenbingItems)

    self.__anqiFixData.aft_local = aftShenbingItems
end

function ShenBingRepair:__repairAnQiInXuanBingDong()
    HttpManagerEx:getCkItemsList(
        "xuanbingdong",
        self.__role.sCk_ver.xuanbingdong,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__role.sCk_ver.xuanbingdong = data.ver
                    if MapIsEmpty(data.list) then
                        return true
                    end
                    -- 找神兵 ， 出库，再入库
                    for _, v in pairs(data.list) do
                        if v.info ~= nil and v.info.wpType == "神兵" then
                            table.insert(self.__anqiFixData.prev_xbd, clone(v.info))
                            if v.info.type == Item.ITEM_TYPE.WEAPON_TYPE.ANQI then
                                self:__outgoingXuanBingDong(v.info.id)
                                local fixData = self:__correctionAnQiData(v.info)
                                self:__ingoingXuanBingDong(fixData)
                                table.insert(self.__anqiFixData.fix_xbd, fixData.id)
                            end
                            table.insert(self.__anqiFixData.aft_xbd, clone(v.info))
                        end
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                print("get CkItemsList error", errcode, status)
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function ShenBingRepair:__outgoingXuanBingDong(itemId)
    HttpManagerEx:outGoingCkItems(
        {itemId = itemId},
        "xuanbingdong",
        self.__role.sCk_ver.xuanbingdong,
        function(status, errcode, errmsg, data)
            local result = false
            if status == 200 then
                if errcode == 0 then
                    self.__role.sCk_ver.xuanbingdong = data.ver
                    return true
                elseif errcode == -1 then
                    self.__role.sCk_ver.xuanbingdong = data.ver
                    self:__outgoingXuanBingDong(itemId)
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function ShenBingRepair:__ingoingXuanBingDong(itemData)
    HttpManagerEx:bePutCkItems(
        {itemId = itemData.id, info = itemData},
        "xuanbingdong",
        self.__role.sCk_ver.xuanbingdong,
        function(status, errcode, errmsg, data)
            local result = false
            if status == 200 then
                if errcode == 0 then
                    self.__role.sCk_ver.xuanbingdong = data.ver
                    result = true
                elseif errcode == -1 then
                    self.__role.sCk_ver.xuanbingdong = data.ver
                    self:__ingoingXuanBingDong(itemData)
                    result = false
                else
                    PopText(errmsg)
                    result = false
                end
            else
                PopText(errmsg)
                result = false
            end

            return result
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function ShenBingRepair:__correctionAnQiData(data)
    local config = self:__getAnqiFixConfig(data.typeDesc)

    if config == nil then
        print("暗器修复，配置未找到！！！" .. data.typeDesc)
        return data
    end

    local fixData = data
    if fixData.status ~= 3 then
        -- 当前硬度 = 配置.打造硬度 + 当前硬度
        fixData.yindu = config.hardnessForging + fixData.yindu
        -- 当前韧度 = 配置.打造韧度 + 当前韧度 
        fixData.rendu = config.tenacityForging + fixData.rendu
        -- 当前重量 = 配置.打造重量 + 当前重量
        fixData.weight = config.weightForging + fixData.weight
    else
        -- 当前重量 = min( (配置.重铸后最小基础重量+淬炼成功次数*0.017), 配置.神兵满淬最大重量 )
        fixData.weight = math.min((config.weightBaseMin + fixData.cuilianCount * 0.017), config.weightMax)
        -- 当前硬度 = min ( max(当前硬度, 配置.淬炼后最小硬度) , 配置.淬炼后最大硬度 )
        fixData.yindu = math.min(math.max(fixData.yindu, config.hardnessMin), config.hardnessMax)
        -- 当前韧度 = min ( max(当前韧度, 配置.淬炼后最小韧度) , 配置.淬炼后最大韧度 )
        fixData.rendu = math.min(math.max(fixData.rendu, config.tenacityMin), config.tenacityMax)
    end

    return fixData
end

function ShenBingRepair:__repairShenBingType()
    --@desc 修正本地神兵类型
    self:__repaireLocalShenBingType()
    --@desc 修正玄兵洞神兵类型
    self:__repairShenBingTypeInXuanBingDong()

    self.__role.repairXuanBingDong = 3
end

function ShenBingRepair:__repaireLocalShenBingType()
    local shenbingItems = self.__role.shenBingItems
    local shenbingItemsCache = self.__role._shenbingCache

    if MapIsEmpty(shenbingItems) then
        return
    end

    for _, shenbingdata in ipairs(shenbingItems) do
        if shenbingdata.type == "琴" then
            shenbingdata.type = "乐器"
            --神兵缓存也同步修改
            if shenbingItemsCache and shenbingItemsCache[shenbingdata.id] then
                shenbingItemsCache[shenbingdata.id].type = "乐器"
            end
        end
    end
end

function ShenBingRepair:__repairShenBingTypeInXuanBingDong()
    HttpManagerEx:getCkItemsList(
        "xuanbingdong",
        self.__role.sCk_ver.xuanbingdong,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__role.sCk_ver.xuanbingdong = data.ver
                    if MapIsEmpty(data.list) then
                        return true
                    end
                    -- 找神兵 ， 出库，再入库
                    for _, v in pairs(data.list) do
                        if v.info ~= nil and v.info.wpType == "神兵" then
                            if v.info.type == "琴" then
                                self:__outgoingXuanBingDong(v.info.id)
                                v.info.type = "乐器"
                                self:__ingoingXuanBingDong(v.info)
                            end
                        end
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                print("get CkItemsList error", errcode, status)
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function ShenBingRepair:__repaireShenBingDescAndDuanZaoItems()
    self:__repaireShenBingTypeDesc()
    self:__repaireLocalShenBingDescAndDuanZaoItems()
    self:__repairXuanBingDongShenBingDescAndDuanZaoItems()
    self.__role.repairXuanBingDong = 4
end

--修复本地神兵的描述与添加当前神兵锻造材料
function ShenBingRepair:__repaireLocalShenBingDescAndDuanZaoItems()
    local shenBingItems = self.__role.shenBingItems
    local shenbingItemsCache = self.__role._shenbingCache
    
    if MapIsEmpty(shenBingItems) == false then
        for k, shenBing in pairs(shenBingItems) do
            print(shenBing.name,shenBing.typeDesc)
            if shenBing.typeDesc ~= nil then
                self:__reinitShenBingDescAndDuanZaoItems(shenBing)
             --神兵缓存也同步修改
                if shenbingItemsCache and shenbingItemsCache[shenBing.id] then
                    self:__reinitShenBingDescAndDuanZaoItems(shenbingItemsCache[shenBing.id])
                end
            end
        end
    end
end

--修复悬兵洞神兵的描述与添加当前神兵锻造材料
function ShenBingRepair:__repairXuanBingDongShenBingDescAndDuanZaoItems()
    HttpManagerEx:getCkItemsList(
        "xuanbingdong",
        self.__role.sCk_ver.xuanbingdong,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__role.sCk_ver.xuanbingdong = data.ver
                    if MapIsEmpty(data.list) then
                        return true
                    end
                    -- 找神兵 ， 出库，再入库
                    for _, v in pairs(data.list) do
                        if v.info ~= nil and v.info.wpType == "神兵" then
                            if v.info.typeDesc ~= nil then
                                self:__outgoingXuanBingDong(v.info.id)
                                self:__reinitShenBingDescAndDuanZaoItems(v.info)
                                self:__ingoingXuanBingDong(v.info)
                            end                           
                        end
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                print("get CkItemsList error", errcode, status)
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

local function getShenBingDuanZaoCaiLiao(shenBingTypeDesc)
    if not shenBingTypeDesc then
        print("-----------getShenBingDuanZaoCaiLiao:描述为空")
        return
    end

    local itemId, itemName
    for _, v in pairs(godweaponDebugtypeDesc) do
        if shenBingTypeDesc == v.typeDesc then
            itemId = v.itemid
            itemName = v.itemName
            break
        end
    end

    if not itemId then
        Collection:memoryCheat(User:getUserId(), "shenBingError.shenBingTypeDesc"..shenBingTypeDesc)
        error("ShenBingRepair getShenBingDuanZaoCaiLiao:  配置表描述对应材料为空"..shenBingTypeDesc)
    end

    return itemId, itemName
end

local function getShenBingTypeDesc(duanZaoCaiLiaoId, weaponBtype)
    local itemFurnaceList = require("script.others.godweapon")["itemOfFurnaceInfo"]
    for k,itemProperty in pairs(itemFurnaceList) do
        if itemProperty.itemid == duanZaoCaiLiaoId and itemProperty.forgingweapon == weaponBtype then
            print("getShenBingTypeDesc:",duanZaoCaiLiaoId,weaponBtype,itemProperty.Forgingdsc)
            return itemProperty.Forgingdsc
        end
    end
end

-- 重置神兵描述与神兵锻造材料
function ShenBingRepair:__reinitShenBingDescAndDuanZaoItems(shenBing)
    local duanzaoItemId, duanzaoItemName = getShenBingDuanZaoCaiLiao(shenBing.typeDesc)

    if not duanzaoItemId then
        print("神兵"..shenBing.name.."数据异常，请联系客服！")
        return
    end

    shenBing.duanzaoitems = {itemId = duanzaoItemId, num = 1}

    local typeDesc = getShenBingTypeDesc(duanzaoItemId, shenBing.bType)
    
    if typeDesc then
        shenBing.typeDesc = typeDesc
        local desc = ShenBingDesc:getShenBingDesc(shenBing,true)
        shenBing.desc = desc
    end
end

function ShenBingRepair:__repairShenBingDuanZaoItems()
    self:__repaireLocalShenBingDuanZaoItems()
    self:__repairXuanBingDongShenBingDuanZaoItems()
    self.__role.repairXuanBingDong = 5
end

function ShenBingRepair:__repaireLocalShenBingDuanZaoItems()
    local shenBingItems = self.__role.shenBingItems
    local shenbingItemsCache = self.__role._shenbingCache
    
    if MapIsEmpty(shenBingItems) == false then
        for k, shenBing in pairs(shenBingItems) do
            if MapIsEmpty(shenBing.duanzaoitems) == true and shenBing.typeDesc then
                local duanzaoItemId, duanzaoItemName = getShenBingDuanZaoCaiLiao(shenBing.typeDesc)
                if duanzaoItemId then
                    shenBing.duanzaoitems = {itemId = duanzaoItemId, num = 1}
                    --神兵缓存也同步修改
                    if shenbingItemsCache and shenbingItemsCache[shenBing.id] then
                        shenbingItemsCache[shenBing.id].duanzaoitems = {itemId = duanzaoItemId, num = 1}
                    end
                end
            end
        end
    end
end

function ShenBingRepair:__repaireShenBingTypeDesc()
    HttpManagerEx:getUserShenBings(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local shenBings = data.shenBingItems
            
            if MapIsEmpty(shenBings) == false then
                local shenBingDesc = {}
                for k, shenBing in pairs(shenBings) do
                    shenBingDesc[shenBing.id] = shenBing.typeDesc
                end

                local shenBingItems = self.__role.shenBingItems
                local shenbingItemsCache = self.__role._shenbingCache
                for k, shenBing in pairs(shenBingItems) do
                    if shenBing.typeDesc == nil then
                        if shenBingDesc[shenBing.id] then
                            shenBing.typeDesc = shenBingDesc[shenBing.id]
                            if shenbingItemsCache and shenbingItemsCache[shenBing.id] then
                                shenbingItemsCache[shenBing.id].typeDesc = shenBingDesc[shenBing.id]
                            end
                        end
                    end
                end 
            end
        else
            PopText(errmsg)
        end
    end,
    IS_SHOW_WAITING)
end

function ShenBingRepair:__repairXuanBingDongShenBingDuanZaoItems()
    HttpManagerEx:getCkItemsList(
        "xuanbingdong",
        self.__role.sCk_ver.xuanbingdong,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__role.sCk_ver.xuanbingdong = data.ver
                    if MapIsEmpty(data.list) then
                        return true
                    end
                    -- 找神兵 ， 出库，再入库
                    for _, v in pairs(data.list) do
                        if v.info ~= nil and v.info.wpType == "神兵" then
                            if MapIsEmpty(v.info.duanzaoitems) == true and v.info.typeDesc then
                                local duanzaoItemId, duanzaoItemName = getShenBingDuanZaoCaiLiao(v.info.typeDesc)
                                if duanzaoItemId then
                                    self:__outgoingXuanBingDong(v.info.id)
                                    v.info.duanzaoitems = {itemId = duanzaoItemId, num = 1}
                                    self:__ingoingXuanBingDong(v.info)
                                end
                            end
                        end
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                print("get CkItemsList error", errcode, status)
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function ShenBingRepair:__popTextShenBingErrorTips()
    local shenBingItems = self.__role.shenBingItems
    for k, shenBing in pairs(shenBingItems) do
        if shenBing.typeDesc == nil then
            PopText("神兵"..shenBing.name.."数据异常，请联系客服！")
        end
    end 
end

--重新修复神兵typeDesc描述
function ShenBingRepair:__repeatRepairShenBingTypeDesc()
    self:__repaireShenBingDescAndDuanZaoItems()
    self:__repairShenBingDuanZaoItems()
    self.__role.repairXuanBingDong = 6
end

--修复背包物品神兵完好度数据
function ShenBingRepair:__repaireBagShenBingWanHaoDu()
    local shenBingItems = self.__role.shenBingItems
    local itemId, wanhaodu
    for k, shenBing in pairs(shenBingItems) do
        if self.__role:getItemCount(shenBing.id) > 0 then
            itemId = shenBing.id
            wanhaodu = shenBing.wanhaodu
            break
        end
    end

    if itemId then
        local bagItems = self.__role:getItems()
        for k, item in pairs(bagItems) do
            if MapIsEmpty(item) == false then
                if item.itemId == itemId and item.wanhaodu then
                    item.wanhaodu = wanhaodu
                    break
                end
            end
        end
    end
    
    self.__role.repairXuanBingDong = 7
end

function ShenBingRepair:__repaireShenBingCuiLianAttr()
    self:__repaireXuanBingDongShenBingCuiLianAttr()
    self:__repaireLocalShenBingCuiLianAttr()

    self.__role.repairXuanBingDong = 8
end

function ShenBingRepair:__repaireXuanBingDongShenBingCuiLianAttr()
    HttpManagerEx:getCkItemsList(
        "xuanbingdong",
        self.__role.sCk_ver.xuanbingdong,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__role.sCk_ver.xuanbingdong = data.ver
                    if MapIsEmpty(data.list) then
                        return true
                    end
                    -- 找神兵 ， 出库，再入库
                    for _, v in pairs(data.list) do
                        if v.info ~= nil and v.info.wpType == "神兵" then
                            local type = v.info.type
                            local bType = v.info.bType

                            if v.info.damage >= 462 and v.info.damage < 470 then
                                v.info.damage = 460
                            end

                            local yinduMax = self:__getShenBingAttrThresholdValue(type,bType,"hardnessMax")
                            local yinduMin= self:__getShenBingAttrThresholdValue(type,bType,"hardnessMin")
                            v.info.yindu = Helper:getRange(v.info.yindu, yinduMin, yinduMax)

                            local renduMax = self:__getShenBingAttrThresholdValue(type,bType,"tenacityMax")
                            local renduMin= self:__getShenBingAttrThresholdValue(type,bType,"tenacityMin")
                            v.info.rendu = Helper:getRange(v.info.rendu, renduMin, renduMax)
                            
                            local weightMax = self:__getShenBingAttrThresholdValue(type,bType,"weightMax")
                            v.info.weight = Helper:getRange(v.info.weight, 0, weightMax)

                            local specialMax = self:__getShenBingAttrThresholdValue(type,bType,"specialMax")
                            v.info.effctNum = Helper:getRange(v.info.effctNum, 0, specialMax)

                            self:__outgoingXuanBingDong(v.info.id)
                            self:__ingoingXuanBingDong(v.info)
                        end
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                print("get CkItemsList error", errcode, status)
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function ShenBingRepair:__repaireLocalShenBingCuiLianAttr()
    local shenBingItems = self.__role.shenBingItems
    local shenbingItemsCache = self.__role._shenbingCache
    
    if MapIsEmpty(shenBingItems) == false then
        for k, shenBing in pairs(shenBingItems) do
            local type = shenBing.type
            local bType = shenBing.bType

            if shenBing.damage >= 462 and shenBing.damage < 470 then
                shenBing.damage = 460
            end

            local yinduMax = self:__getShenBingAttrThresholdValue(type,bType,"hardnessMax")
            local yinduMin= self:__getShenBingAttrThresholdValue(type,bType,"hardnessMin")
            shenBing.yindu = Helper:getRange(shenBing.yindu, yinduMin, yinduMax)

            local renduMax = self:__getShenBingAttrThresholdValue(type,bType,"tenacityMax")
            local renduMin= self:__getShenBingAttrThresholdValue(type,bType,"tenacityMin")
            shenBing.rendu = Helper:getRange(shenBing.rendu, renduMin, renduMax)
            
            local weightMax = self:__getShenBingAttrThresholdValue(type,bType,"weightMax")
            shenBing.weight = Helper:getRange(shenBing.weight, 0, weightMax)

            local specialMax = self:__getShenBingAttrThresholdValue(type,bType,"specialMax")
            shenBing.effctNum = Helper:getRange(shenBing.effctNum, 0, specialMax)

            if shenbingItemsCache and shenbingItemsCache[shenBing.id] then
                shenbingItemsCache[shenBing.id].damage = shenBing.damage
                shenbingItemsCache[shenBing.id].yindu = shenBing.yindu
                shenbingItemsCache[shenBing.id].rendu = shenBing.rendu
                shenbingItemsCache[shenBing.id].weight = shenBing.weight
                shenbingItemsCache[shenBing.id].effctNum = shenBing.effctNum
            end
        end
    end
end


function ShenBingRepair:__getShenBingAttrThresholdValue(type1,type2,index)
    local value = nil

    for k,v in pairs(godweaponAttrRepair) do
        if v.type1 == type1 and v.type2 == type2 and v[index] then
            value = v[index]

            value = string.format("%.3f",math.floor(value * 1000 + 0.5) / 1000)

            value = string.format("%g",value)

            value = tonumber(value)

            break
        end
    end

    return assert(value,"-----ShenBingRepair:__getShenBingAttrThresholdValue----神兵阈值不存在"..index)
end

function ShenBingRepair:__repaireShenBingDamage()
    self:__repaireXuanBingDongShenBingDamage()
    self:__repaireLocalShenBingDamage()

    self.__role.repairXuanBingDong = 9
end

function ShenBingRepair:__repaireXuanBingDongShenBingDamage()
    HttpManagerEx:getCkItemsList(
        "xuanbingdong",
        self.__role.sCk_ver.xuanbingdong,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__role.sCk_ver.xuanbingdong = data.ver
                    if MapIsEmpty(data.list) then
                        return true
                    end
                    -- 找神兵 ， 出库，再入库
                    for _, v in pairs(data.list) do
                        if v.info ~= nil and v.info.wpType == "神兵" then
                            local type = v.info.type
                            local bType = v.info.bType

                            local hurtMax = self:__getShenBingAttrThresholdValue(type,bType,"hurtCanMax")

                            if v.info.damage >= 462 and v.info.damage <= hurtMax then
                                v.info.damage = 460
                            end

                            self:__outgoingXuanBingDong(v.info.id)
                            self:__ingoingXuanBingDong(v.info)
                        end
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                print("get CkItemsList error", errcode, status)
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function ShenBingRepair:__repaireLocalShenBingDamage()
    local shenBingItems = self.__role.shenBingItems
    local shenbingItemsCache = self.__role._shenbingCache
    
    if MapIsEmpty(shenBingItems) == false then
        for k, shenBing in pairs(shenBingItems) do
            local type = shenBing.type
            local bType = shenBing.bType

            local hurtMax = self:__getShenBingAttrThresholdValue(type,bType,"hurtCanMax")

            if shenBing.damage >= 462 and shenBing.damage <= hurtMax then
                shenBing.damage = 460
            end

            if shenbingItemsCache and shenbingItemsCache[shenBing.id] then
                shenbingItemsCache[shenBing.id].damage = shenBing.damage
            end
        end
    end
end

return newClass("ShenBingRepair", {}, ShenBingRepair)
0000000000000000
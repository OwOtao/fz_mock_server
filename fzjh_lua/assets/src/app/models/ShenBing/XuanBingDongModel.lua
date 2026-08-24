local class = require("third.class.NewClass")
local PoisonUtil = require("app.models.Poison.PoisonUtil")
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
local LimitConfig = require("script.others.xuanbingdongLimit")["Sheet1"]
local weaponTypeSort = {
    ["刀"] = 1,
    ["剑"] = 2,
    ["棍"] = 3,
    ["鞭"] = 4,
    ["双持"] = 5,
    ["暗器"] = 6,
    ["乐器"] = 7
}

local currencyType = {
    ["1"] = "碎银",
    ["2"] = "元宝"
}

local XuanBingDongModel = {}

--@desc: 获取单例
--@author:Seven
--@time:2025-09-19 15:55:24
--@return [src.app.models.ShenBing.XuanBingDongModel#XuanBingDongModel]
function XuanBingDongModel:getInstance()
    if not self._instance then
        self._instance = XuanBingDongModel:create()

        self._instance:setRole(User:getRole())
    end

    return self._instance
end

function XuanBingDongModel:create()
    return XuanBingDongModel.new()
end

function XuanBingDongModel:ctor()
    self._isInit = false

    self._ckType = "xuanbingdong"
    self._itemIdList = {}
    self._list = {}
    self._numLimit = 1000
    self.__itemCount = nil
end

function XuanBingDongModel:isInit()
    return self._isInit
end

function XuanBingDongModel:setRole(role)
    self._role = role
end

function XuanBingDongModel:getOneItemByKey(itemId)
    return self._role:getOneItemByKey(itemId)
end

function XuanBingDongModel:getCollectDesc()
    local desc = ShenBingDesc:getRoleCollectDesc(self._role)
    return "『收藏评价』" .. desc
end

function XuanBingDongModel:getRoleNeiLiDesc()
    local neili, neiliMax = math.ceil(self._role:getAttr("neili")), math.ceil(self._role:getFinalAttr("neiliMax"))
    return "『内力』" .. tostring(neili) .. "/" .. tostring(neiliMax)
end

function XuanBingDongModel:getNumDesc()
    local desc = "存储上限：" .. tostring(#self._list) .. "/" .. tostring(self._numLimit)
    return desc
end

function XuanBingDongModel:getNormalTextDesc()
    return "这里是玄兵古洞，里面传来阵阵的捶打声似乎在锻造着什么。隐隐的透着一股肃杀的气息。"
end

function XuanBingDongModel:getHomeLandTextDesc()
    local HomeLandDesc = require("app.models.HomelandModel.HomelandDesc")
    local text = HomeLandDesc:getCangJianShiDesc(ShenBingDesc:getCollectScore(self._role:getAttr("collectScore")))
    return text
end

function XuanBingDongModel:checkShenBingIsDefault(itemId)
    local defaultShenBingItemId = self._role:getAttr("defaultShenBingItemId")
    if not defaultShenBingItemId then
        return false
    end
    return defaultShenBingItemId == itemId
end

function XuanBingDongModel:getListFromServer(successFunc)
    HttpManagerEx:getCkItemsList(
        self._ckType,
        self._role.sCk_ver[self._ckType],
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self._isInit = true
                    self.__itemCount = {}
                    self._role.sCk_ver[self._ckType] = data.ver
                    self:initItemsList(data.list)
                    self._numLimit = data.size

                    if successFunc then
                        successFunc()
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
    return true
end

function XuanBingDongModel:initItemsList(serverItemList)
    self._role:setAttr("weaponScore", 0)
    self._itemIdList = {}
    --['shenbin1'=>['total'=>1, 'info'=>[], 'itemId'=>'shenbin1']]

    if MapIsEmpty(serverItemList) then
        return
    end

    for k, v in pairs(serverItemList) do
        if v.total > 1 then
            print("========================================", v.itemId, v.total)
            v.total = 1
        end

        if v.total == 1 then
            local temp = {}
            temp.itemId = v.itemId
            temp.update_time = v.update_time

            self:__updateItemCount(v.itemId, v.total)

            if v.info and v.info ~= "" then
                temp.info = v.info
                --@desc 删除背包内有一把跟同ID的神兵
                if self._role:getItemCount(v.itemId) > 0 then
                    self._role:addItemCount(v.itemId, -1)
                end
            end

            local baseInfo = ShenBingDuanZao:getWeaponBaseInfo(v.itemId)
            if baseInfo == nil and v.info ~= nil and v.info ~= "" then
                ShenBingDuanZao:getNewShenBingWeapen(v.info)
                self._role:addAttr("forgeCount", 1)
            elseif baseInfo ~= nil and (v.info == nil or v.info == "") then
                if self._role:getItemCount(v.itemId) > 0 then
                    self._role:addItemCount(v.itemId, -1)
                end
            end

            if not self._itemIdList[temp.itemId] then
                local score = self:getItemScore(temp.itemId)
                self:refreshScore(score)

                table.insert(self._list, temp)
                self._itemIdList[temp.itemId] = true
            end
        end
    end
end

function XuanBingDongModel:checkItemCanPut(item)
    if self._role:checkItemIsEquip(item.onlyid) == true then
        PopText("请先将武器脱下")
        return false
    end

    if self._role:checkIsPrepareWeapon(item.onlyid) == true then
        PopText("请先将武器取消准备")
        return false
    end

    local itemData = self._role:getOneItemByKey(item.itemId)

    if itemData and itemData.wpType ~= "神兵" and itemData.shoucang ~= 1 then
        PopText("该武器不能收藏")
        return false
    end

    if self._itemIdList[item.itemId] == true then
        PopText("一把兵器悬兵洞只能收藏一把")
        return false
    end

    if PoisonUtil:checkWeaponIsPoison(item.onlyid) then
        PopText("淬毒的兵器无法放入悬兵洞")
        return false
    end

    if item.type ~= "神兵" and item.wanhaodu == 0 then
        PopText("破损的兵器无法放入悬兵洞")
        return false
    elseif item.type == "神兵" then
        if itemData.wanhaodu == 0 then
            PopText("破损的兵器无法放入悬兵洞")
            return false
        end
    end

    return true
end

function XuanBingDongModel:putItem(item, func)
    local itemId = item.itemId
    local info = item.info

    HttpManagerEx:bePutCkItems(
        {itemId = itemId, info = info},
        self._ckType,
        self._role.sCk_ver[self._ckType],
        function(status, errcode, errmsg, data)
            local result = false
            if status == 200 then
                if errcode == 0 then
                    self._role.sCk_ver[self._ckType] = data.ver
                    self._role:addItemCount(itemId, -1, nil, item.onlyid, "神兵入库")
                    self:__updateItemCount(itemId, 1)

                    if self:checkShenBingIsDefault(itemId) then
                        self._role:setAttr("defaultShenBingItemId", nil)
                    end

                    local temp = {}
                    temp.itemId = itemId
                    if info then
                        temp.info = info
                    end

                    temp.update_time = data.update_time

                    table.insert(self._list, temp)

                    if not self._itemIdList[item.itemId] then
                        self._itemIdList[item.itemId] = true

                        local itemAttr = self._role:getOneItemByKey(item.itemId)
                        if itemAttr and itemAttr.shoucang == 1 then
                            self._role:addAttr("collectScore", tonumber(itemAttr.wuzang))
                            self:refreshScore(itemAttr.wuzang)
                            self:uploadUserCollectScore()
                        end

                        if func then
                            func()
                        end
                    else
                        print("有错，库中已有一把，不应该运行到此处。")
                    end
                    result = true
                elseif errcode == -1 then
                    self._role.sCk_ver[self._ckType] = data.ver
                    PopText("网络异常，请重试。")
                    result = true
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

function XuanBingDongModel:checkItemCanOut(itemId)
    if self._role:checkCanBuyThings(itemId, 1) == false then
        PopText("背包空间不足")
        return false
    end

    local itemAttr = self._role:getOneItemByKey(itemId)
    if itemAttr.wpType == "神兵" then
        local items =
            self._role:getItems(
            function(item)
                if item.type == "神兵" then
                    return true
                else
                    return false
                end
            end
        )

        if #items >= self._role:getAttr("bagShenBingNumLimit") then
            PopText("背包携带神兵已达上限")
            return false
        end
    end

    return true
end

function XuanBingDongModel:outItem(itemId, func)
    HttpManagerEx:outGoingCkItems(
        {itemId = itemId},
        self._ckType,
        self._role.sCk_ver[self._ckType],
        function(status, errcode, errmsg, data)
            local result = false
            if status == 200 then
                if errcode == 0 then
                    self._role.sCk_ver[self._ckType] = data.ver

                    local _, roleItem = self._role:addItemCount(data.itemId, data.total, nil, nil, "神兵出库")

                    self:__updateItemCount(itemId, -1)

                    for i, v in ipairs(self._list) do
                        if v.itemId == itemId then
                            table.remove(self._list, i)
                            break
                        end
                    end

                    self._itemIdList[itemId] = false
                    local itemAttr = self._role:getOneItemByKey(itemId)
                    if itemAttr and itemAttr.shoucang == 1 then
                        local score = 0 - tonumber(itemAttr.wuzang)
                        self._role:addAttr("collectScore", score)
                        self:refreshScore(score)
                        self:uploadUserCollectScore()
                    end

                    if func then
                        func()
                    end
                    result = true
                elseif errcode == -1 then
                    self._role.sCk_ver[self._ckType] = data.ver
                    PopText("网络异常，请重试。")
                    result = true
                else
                    PopText(errmsg)
                    result = true
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

function XuanBingDongModel:getShenBingItems()
    local shenBingItems = {}

    if MapIsEmpty(self._list) == false then
        for index, itemData in ipairs(self._list) do
            local itemAttr = self._role:getOneItemByKey(itemData.itemId)
            if itemAttr and itemAttr.wpType == "神兵" then
                local item = {}
                item.itemId = itemData.itemId
                item.name = itemAttr.nameColor .. itemAttr.name
                item.damage = Helper:mathFloor(itemAttr:getWeaponDamage(self._role))
                item.cuilianCount = itemAttr.cuilianCount
                item.type = itemAttr.type
                table.insert(shenBingItems, item)
            end
        end
    end

    table.sort(
        shenBingItems,
        function(a, b)
            if a.damage == b.damage then
                if a.cuilianCount == b.cuilianCount then
                    if weaponTypeSort[a.type] == weaponTypeSort[b.type] then
                        return a.itemId > b.itemId
                    else
                        return weaponTypeSort[a.type] < weaponTypeSort[b.type]
                    end
                else
                    return a.cuilianCount > b.cuilianCount
                end
            else
                return a.damage > b.damage
            end
        end
    )

    return shenBingItems
end

function XuanBingDongModel:getShenBingItemsByType(shenBingType)
    local shenBingItems = {}

    if MapIsEmpty(self._list) == false then
        for index, itemData in ipairs(self._list) do
            local itemAttr = self._role:getOneItemByKey(itemData.itemId)
            if itemAttr and itemAttr.wpType == "神兵" and itemAttr.type == shenBingType then
                local item = {}
                item.itemId = itemData.itemId
                item.name = itemAttr.nameColor .. itemAttr.name
                item.damage = Helper:mathFloor(itemAttr:getWeaponDamage(self._role))
                item.cuilianCount = itemAttr.cuilianCount
                item.type = itemAttr.type
                table.insert(shenBingItems, item)
            end
        end
    end

    table.sort(
        shenBingItems,
        function(a, b)
            if a.damage == b.damage then
                if a.cuilianCount == b.cuilianCount then
                    return a.itemId > b.itemId
                else
                    return a.cuilianCount > b.cuilianCount
                end
            else
                return a.damage > b.damage
            end
        end
    )

    return shenBingItems
end

function XuanBingDongModel:getNormalItems()
    local normalItems = {}

    if MapIsEmpty(self._list) == false then
        for index, itemData in ipairs(self._list) do
            local itemAttr = self._role:getOneItemByKey(itemData.itemId)
            if itemAttr and itemAttr.wpType ~= "神兵" then
                local item = {}
                item.itemId = itemData.itemId
                item.name = itemAttr.name
                item.damage = Helper:mathFloor(itemAttr:getWeaponDamage(self._role))
                item.type = itemAttr.type
                item.bType = itemAttr.bType
                table.insert(normalItems, item)
            end
        end
    end

    table.sort(
        normalItems,
        function(a, b)
            if a.damage == b.damage then
                if weaponTypeSort[a.type] == weaponTypeSort[b.type] then
                    return a.itemId > b.itemId
                else
                    return weaponTypeSort[a.type] < weaponTypeSort[b.type]
                end
            else
                return a.damage > b.damage
            end
        end
    )

    return normalItems
end

function XuanBingDongModel:getNormalItemsByType(itemType)
    local normalItems = {}

    if MapIsEmpty(self._list) == false then
        for index, itemData in ipairs(self._list) do
            local itemAttr = self._role:getOneItemByKey(itemData.itemId)
            if itemAttr and itemAttr.wpType ~= "神兵" and itemAttr.type == itemType then
                local item = {}
                item.itemId = itemData.itemId
                item.name = itemAttr.name
                item.damage = Helper:mathFloor(itemAttr:getWeaponDamage(self._role))
                item.bType = itemAttr.bType
                table.insert(normalItems, item)
            end
        end
    end

    table.sort(
        normalItems,
        function(a, b)
            if a.damage == b.damage then
                return a.itemId > b.itemId
            else
                return a.damage > b.damage
            end
        end
    )

    return normalItems
end

function XuanBingDongModel:getItemScore(itemId)
    local score = 0

    local itemAttr = self._role:getOneItemByKey(itemId)
    if itemAttr and itemAttr.shoucang == 1 then
        score = tonumber(itemAttr.wuzang)
    end

    return score
end

function XuanBingDongModel:refreshScore(score)
    self._role:addAttr("weaponScore", tonumber(score))

    local weaponScore = tonumber(self._role:getAttr("weaponScore"))
    local armorScore = tonumber(self._role:getAttr("armorScore"))
    local collectScore = tonumber(self._role:getAttr("collectScore"))

    if collectScore ~= weaponScore + armorScore then
        self._role:setAttr("collectScore", weaponScore + armorScore)
    end
end

function XuanBingDongModel:uploadUserCollectScore()
    local fq = self._role:getHomelandAttr("fq")

    if MapIsEmpty(fq) then
        return
    end

    local mid = fq.mid

    local nowScore = Helper:getDef(self._role:getAttr("collectScore"), 1)

    local UserMap = require("app.models.map.UserMap")

    UserMap:updateMapExtraAttr(mid, {collectScore = nowScore}, 0)
end

function XuanBingDongModel:getCurrLimit()
    return self._numLimit
end

function XuanBingDongModel:getCurrLevel()
    local currLevel = 0
    for i, v in pairs(LimitConfig) do
        if v.bagcount == self._numLimit then
            currLevel = v.id
            return currLevel
        end
    end
    error("当前玄兵洞上限异常：" .. tostring(self._numLimit))
end

function XuanBingDongModel:checkCanUpgrade()
    for i, v in pairs(LimitConfig) do
        if v.bagcount > self._numLimit then
            return true
        end
    end

    return false
end

function XuanBingDongModel:getNextLevelInfo()
    local nextLevel = self:getCurrLevel() + 1
    for i, v in pairs(LimitConfig) do
        if v.id == nextLevel then
            return v
        end
    end
end

function XuanBingDongModel:getCurrencyName(type)
    return currencyType[tostring(type)]
end

function XuanBingDongModel:__updateItemCount(itemId, count)
    local current_count = Helper:getDef(self.__itemCount[itemId], 0)
    local _count = current_count + count

    if _count < 0 then
        _count = 0
        print("玄兵洞物品数量异常，物品ID：" .. tostring(itemId) .. "，数量变动：" .. tostring(count) .. "，当前数量：" .. tostring(current_count) .. "，变动后数量：" .. tostring(_count) .. "，请检查 \n" .. debug.traceback())
    end

    if _count == 0 then
        self.__itemCount[itemId] = nil
    else
        self.__itemCount[itemId] = _count
    end
end

function XuanBingDongModel:queryItemCount(itemId)
    return Helper:getDef(self.__itemCount[itemId], 0)
end

-- 新的异步版本
function XuanBingDongModel.getItemCountById(role, itemId)
    assert(role ~= nil, "XuanBingDongModel.getItemCountById role 不能为空")
    assert(itemId ~= nil, "XuanBingDongModel.getItemCountById itemId 不能为空")

    -- 只有玩家主角色才有效
    if role ~= User:getRole() then
        return 0
    end

    local model = XuanBingDongModel:getInstance()
    if not model:isInit() then
        local count = 0
        model:getListFromServer(
            function()
                count = model:queryItemCount(itemId)
            end
        )

        return count
    else
        return model:queryItemCount(itemId)
    end
end

return class("XuanBingDongModel", {}, XuanBingDongModel)
0000000000
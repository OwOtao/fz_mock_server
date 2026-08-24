local class = require("third.class.NewClass")

local CangYiGeModel = {}

local CKTYPE = "cangyige"

function CangYiGeModel:create()
    return CangYiGeModel:new()
end

function CangYiGeModel:ctor()
    self.__itemCount = {}
    self.__itemList = {}
    self._isInit = false
end

--@return [src.app.models.ShenBing.CangYiGeModel#CangYiGeModel]
function CangYiGeModel:getInstance()
    if not self._instance then
        self._instance = CangYiGeModel:create()

        self._instance:setRole(User:getRole())
    end

    return self._instance
end

function CangYiGeModel:isInit()
    return self._isInit
end

function CangYiGeModel:setRole(role)
    self._role = role
end

function CangYiGeModel:getListFromServer(successCallback)
    HttpManagerEx:getCkItemsList(
        CKTYPE,
        self._role.sCk_ver[CKTYPE],
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self._isInit = true

                    self._role.sCk_ver[CKTYPE] = data.ver

                    self:__initList(data.list)

                    successCallback()
                    return true
                else
                    PopText(errmsg)
                    return false
                end
                return true
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

function CangYiGeModel:__initList(list)
    if MapIsEmpty(list) then
        return
    end

    self._role:setAttr("armorScore", 0)

    self.__itemList = {}

    local temp_item_id_map = {}

    local need_remove_item_id = {}

    for k, item_data in pairs(list) do
        local itemAttr = Item:getOneItemByKey(item_data.itemId)
        if itemAttr == nil then
            print("藏衣阁物品数据异常，物品ID：" .. tostring(item_data.itemId) .. "，请检查 \n" .. debug.traceback())
            table.insert(need_remove_item_id, item_data.itemId)
            goto __continue__
        end

        if item_data.total > 1 then
            print("藏衣阁物品数量异常，物品ID：" .. tostring(item_data.itemId) .. "，数量：" .. tostring(item_data.total) .. "，请检查 \n" .. debug.traceback())
            item_data.total = 1
        end

        local t = {}

        t.itemId = item_data.itemId

        t.updateTime = item_data.update_time

        self:__updateItemCount(item_data.itemId, item_data.total)

        if item_data.info and item_data.info ~= "" then
            t.info = item_data.info
        end

        if not temp_item_id_map[item_data.itemId] then
            temp_item_id_map[item_data.itemId] = true

            table.insert(self.__itemList, t)

            self:__addScore("add", t.itemId)
        end

        ::__continue__::
    end

    table.sort(
        self.__itemList,
        function(a, b)
            local a_time = 0

            local b_time = 0

            if type(a.updateTime) == "number" then
                a_time = a.updateTime
            end

            if type(b.updateTime) == "number" then
                b_time = b.updateTime
            end
            return a_time < b_time
        end
    )

    if MapIsEmpty(need_remove_item_id) == false then
        for _, __item_id__ in ipairs(need_remove_item_id) do
            HttpManagerEx:outGoingCkItems(
                {itemId = __item_id__},
                CKTYPE,
                self._role:getAttr("sCk_ver")[CKTYPE],
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            local local_ver = self._role:getAttr("sCk_ver")
                            local_ver[CKTYPE] = data.ver
                            self._role:setAttr("sCk_ver", local_ver)
                        else
                            PopText(errmsg)
                        end
                    else
                        PopText(errmsg)
                    end
                end
            )
        end
    end
end

function CangYiGeModel:getCangYiGeList()
    return self.__itemList
end

function CangYiGeModel:__addScore(flag, itemId)
    local itemAttr = Item:getOneItemByKey(itemId)
    if itemAttr == nil or itemAttr.shoucang ~= 1 then
        return
    end

    if flag == "add" then
        self._role:addAttr("armorScore", tonumber(itemAttr.wuzang))
    elseif flag == "remove" then
        self._role:addAttr("armorScore", 0 - tonumber(itemAttr.wuzang))
    end

    local weaponScore = tonumber(self._role:getAttr("weaponScore"))
    local armorScore = tonumber(self._role:getAttr("armorScore"))
    local collectScore = tonumber(self._role:getAttr("collectScore"))

    if collectScore ~= weaponScore + armorScore then
        self._role:setAttr("collectScore", weaponScore + armorScore)
    end
end

function CangYiGeModel:__updateItemCount(itemId, count)
    local current_count = self:queryItemCount(itemId)
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

function CangYiGeModel:outItem(itemId, successCallback)
    if not itemId then
        return
    end

    local itemAttr = Item:getOneItemByKey(itemId)
    if itemAttr == nil then
        print("藏衣阁物品数据异常，物品ID：" .. tostring(itemId) .. "，请检查 \n" .. debug.traceback())
        return
    end

    PopupLayerController:showLayer(
        "GlobalShadeLayer",
        function(layer)
            layer:showLayer()
        end
    )

    HttpManagerEx:outGoingCkItems(
        {itemId = itemId},
        CKTYPE,
        self._role:getAttr("sCk_ver")[CKTYPE],
        function(status, errcode, errmsg, data)
            local result = false
            if status == 200 then
                if errcode == 0 then
                    self._role.sCk_ver[CKTYPE] = data.ver

                    local _, roleItem = self._role:addItemCount(data.itemId, data.total, nil, nil, "藏衣阁出库")

                    self:__updateItemCount(itemId, -1)

                    for index, v in ipairs(self.__itemList) do
                        if v.itemId == itemId then
                            table.remove(self.__itemList, index)
                            break
                        end
                    end

                    self:__addScore("remove", itemId)

                    self:__uploadUserCollectScore()

                    if successCallback and type(successCallback) == "function" then
                        successCallback()
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
                print("out CkItems error", errcode, status)
                PopText(errmsg)
                result = false
            end

            PopupLayerController:hideLayer(
                "GlobalShadeLayer",
                function(layer)
                    layer:hideLayer()
                end
            )
            return result
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function CangYiGeModel:putItem(item, successCallback)
    local itemId = item.itemId

    PopupLayerController:showLayer(
        "GlobalShadeLayer",
        function(layer)
            layer:showLayer()
        end
    )

    HttpManagerEx:bePutCkItems(
        {itemId = itemId, info = {}},
        CKTYPE,
        self._role.sCk_ver[CKTYPE],
        function(status, errcode, errmsg, data)
            local result = false
            if status == 200 then
                if errcode == 0 then
                    self._role.sCk_ver[CKTYPE] = data.ver

                    self._role:addItemCount(itemId, -1, nil, item.onlyid, "藏衣阁入库")

                    if self:queryItemCount(itemId) <= 0 then
                        self:__updateItemCount(itemId, 1)

                        local temp = {}

                        temp.itemId = itemId

                        temp.updateTime = data.update_time

                        table.insert(self.__itemList, temp)

                        self:__addScore("add", item.itemId)

                        if DEBUG_MODE == 1 then
                            print("===================收藏评分=======================", self._role:getAttr("collectScore"))
                        end

                        if successCallback and type(successCallback) == "function" then
                            successCallback()
                        end
                    else
                        print("有错，库中已有一件，不应该运行到此处。")
                    end

                    result = true
                else
                    PopText(errmsg)
                    result = false
                end
            elseif errcode == -1 then
                self._role.sCk_ver[CKTYPE] = data.ver
                PopText("网络异常，请重试。")
                result = true
            else
                PopText(errmsg)
                result = false
            end
            PopupLayerController:hideLayer(
                "GlobalShadeLayer",
                function(layer)
                    layer:hideLayer()
                end
            )
            return result
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function CangYiGeModel:__uploadUserCollectScore()
    local fq = self._role:getHomelandAttr("fq")

    if MapIsEmpty(fq) then
        return
    end

    local mid = fq.mid

    local nowScore = Helper:getDef(self._role:getAttr("collectScore"), 1)

    local UserMap = require("app.models.map.UserMap")

    UserMap:updateMapExtraAttr(mid, {collectScore = nowScore}, 0)
end

function CangYiGeModel:getUserCollectScore()
    return Helper:getDef(self._role:getAttr("collectScore"), 1)
end

function CangYiGeModel:queryItemCount(itemId)
    return Helper:getDef(self.__itemCount[itemId], 0)
end

function CangYiGeModel.getItemCountById(role, itemId)
    assert(role ~= nil, "CangYiGeModel.getItemCountById role 不能为空")
    assert(itemId ~= nil, "CangYiGeModel.getItemCountById itemId 不能为空")

    -- 只有玩家主角才有效
    if role ~= User:getRole() then
        return 0
    end

    local instance = CangYiGeModel:getInstance()
    if not instance:isInit() then
        local count = 0

        instance:getListFromServer(
            function()
                count = instance:queryItemCount(itemId)
            end
        )

        return count
    end

    return instance:queryItemCount(itemId)
end

return class("CangYiGeModel", {}, CangYiGeModel)
000000000000
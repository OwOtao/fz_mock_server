local DiQiModel = {}

local dpListInfo = requireWithEncrypt("script.others.familylist")["房屋地皮"]
local dpList = {}

local function initDpList()
    for k, v in pairs(dpListInfo) do
        dpList[v.dpId] = v
    end
end

initDpList()
--@desc: 获取地皮相关信息
--@author:Liang SongQiang
--@time:2018-08-02 17:39:57
--@dpId: 地皮ID
function DiQiModel:getDpInfoById(dpId)
    return assert(dpList[dpId], "配置表没有该地皮信息：" .. dpId)
end

--@desc: 获取地皮对应的城池ID
--@author:Liang SongQiang
--@time:2018-08-02 17:41:23
--@dpId: 地皮ID
function DiQiModel:getDpMapId(dpId)
    local dp = self:getDpInfoById(dpId)

    return dp.fbId
end

--@desc: 获取地皮对应的出口
--@author:Liang SongQiang
--@time:2018-08-02 17:40:10
--@dpId: 地皮ID
function DiQiModel:getCommonMapLocation(dpId)
    local dp = self:getDpInfoById(dpId)

    local dpRoomId = dp.dpRoomId

    local value = string.split(dpRoomId, ";")

    if #value ~= 2 then
        assert(false, "房屋地皮出口编号填写错误，请检查资源，地皮ID：" .. dpId)
    end

    local mapId = value[1]
    local roomId = value[2]

    return mapId, roomId
end

--@desc 获取地契名字的颜色
function DiQiModel:getNameColor(dqId)
    local data = self:getDpInfoById(dqId)

    local name = ""
    if data.color and data.color ~= "" then
        name = data.color .. data.name .. "NOR"
    else
        name = data.name
    end

    return name
end

--@desc: 更新地契信息
--@author:Liang SongQiang
--@time:2018-05-21 21:35:27
function DiQiModel:updateInfo(data)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local dqInfo = role:getHomelandAttr("dq")
    local roleData

    if MapIsEmpty(data) then
        return
    end

    for k, v in pairs(dqInfo) do
        if v.id == data.id then
            roleData = v
        end
    end

    -- local _dqCache = role:getOneItemByKey(data.id)

    for k, v in pairs(data) do
        roleData[k] = v
        -- _dqCache[k] = v
    end
end

function DiQiModel:deleteDiQiItem(itemId)
    local role = User:getRole()

    role:addItemCount(itemId, -1)
end

--@desc: 删除地契相关的数据
--@author:Liang SongQiang
--@time:2018-06-19 17:11:16
--@itemId:
function DiQiModel:deleteDiQi(itemId)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local dq = role:getHomelandAttr("dq")

    if not dq or MapIsEmpty(dq) then
        return
    end

    for i, dqInfo in ipairs(dq) do
        if dqInfo.id == itemId then
            table.remove(dq, i)
            role._ItemCache[itemId] = nil
            break
        end
    end
end

--@desc: 领取地契,可有多份地契
--@author:Liang SongQiang
--@time:2018-05-23 16:10:31
--@data: 地契信息
function DiQiModel:getDiQi(data)
    --@desc [src.app.models.role.Role#Role]
    local role = User:getRole()

    local dq = Helper:getDef(role:getHomelandAttr("dq"), {})

    local temp = {
        name = "HIY地契NOR",
        id = "dq_" .. data.dpId,
        type = "地契",
        dpId = data.dpId,
        timeend = 3600 * 24 * 3
    }

    table.insert(dq, temp)
    role:setHomelandAttr("dq", dq)

    local items =
        role:getItems(
        function(item)
            return item.itemId == temp.id
        end
    )

    if #items == 0 then
        role:addItemCount(temp.id, 1, GetTime() + temp.timeend)
    else
        items[1].time = GetTime() + temp.timeend
    end

    self:updateInfo(temp)
end

--@desc 查看欠了多少管理费
function DiQiModel:checkManagementCost(dpId, callback)
    HttpManagerEx:getManagePayment(
        dpId,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                --@desc 欠费的天数
                local day = Helper:getDef(data.day, 0)

                --@desc 欠费总数
                local total = Helper:getDef(data.total_pay, 0)

                if callback then
                    callback(day, total)
                end
                return true
            else
                print("errcode : ", errcode)
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function DiQiModel:moveHomeland(dpId, itemId,callback)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local dq = role:getHomelandAttr("dq")

    if not dq or MapIsEmpty(dq) then
        PopText("此地皮已被回收")
        return
    end

    local isCanShow = false
    for i, dqInfo in ipairs(dq) do
        if dqInfo.id == itemId then
            isCanShow = true
            break
        end
    end

    if isCanShow == false then
        PopText("此地皮已被回收")
        return
    end
    
    local currMap = role:getCurrMap()
    if currMap and currMap:getMapType() == MAP_TYPE.MYHOME and MainControllLayer:getCurrLayer() == "MapLayer" then
        PopText("搬家前，需要先离开自己的房屋！")
        return
    end

    local fq = role:getHomelandAttr("fq")

    local function move(dpId, itemId)
        if not dpId then
            assert(false, "move dpId is nil")
            return
        end

        HttpManagerEx:moveHomeland(
            dpId,
            fq.mid,
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        --@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
                        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

                        local text = HomelandDesc:getMoveLandText(dpId)

                        User:getRole():setFlag("PVP活动状态", "忙碌")

                        PopupLayerController:showLayer(
                            "TextAnimLayer",
                            function(layer)
                                layer:setAfterAnimCallback(
                                    function()
                                        User:getRole():setFlag("PVP活动状态", "空闲中")
                                        PopText("您成功搬入该土地。")
                                    end
                                )
                                layer:showLayer(text)
                            end
                        )

                        local dpInfo = self:getDpInfoById(dpId)
                        local location = dpInfo.place .. dpInfo.name

                        --@RefType [src.app.models.HomelandModel.FangQiModel#FangQiModel]
                        local FangQiModel = require("app.models.HomelandModel.FangQiModel")
                        FangQiModel:updateInfo({location = location, dpId = dpId})

                        --@desc 删除角色保存的地契信息，只需把有用的信息融入房契信息中
                        self:deleteDiQiItem(itemId)
                        self:deleteDiQi(itemId)

                        if callback then
                            callback()
                        end

                        -- --@desc 清除缓存
                        -- do
                        --     local mapId = self:getCommonMapLocation(dpId)
                        --     --@RefType [src.app.models.map.UserMap#UserMap]
                        --     local UserMap = require("app.models.map.UserMap")
                        --     UserMap:clearCache("commMap"..self:getDpMapId(dpId))
                        -- end
                    else
                        print("errcode : ", errcode)
                        PopText(errmsg)
                    end
                else
                    print("errcode : ", errcode)
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
    end

    if not fq.dpId then
        move(dpId, itemId)
        return
    end

    self:checkManagementCost(
        fq.dpId,
        function(day, total_pay)
            if total_pay > 0 then
                local title =
                    "您之前欠了" .. Helper:numberCast(day) .. "天的地税，共" .. Helper:numberCast(total_pay) .. "元宝。确定支付吗？"

                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:hide()
                dialog:show(title)
                -- dialog:setRichText(title)
                dialog:setButton1(
                    "确定",
                    function()
                        move(dpId, itemId)
                    end
                )

                dialog:setButton2(
                    "取消",
                    function()
                        dialog:hide()
                    end
                )
            else
                move(dpId, itemId)
            end
        end
    )
end

--@desc 地契领取成功后限定时间内未搬入。
function DiQiModel:recycleLand(itemId)
    --[[
        1、删除背包地契
        2、清除地契结构
        3、服务地皮重新回归库存
    ]]
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local itemAttr = Item:getOneItemByKey(itemId)
    if not itemAttr then
        assert(false, "没有地契信息：" .. itemId)
    end

    self:deleteDiQi(itemId)

    HttpManagerEx:recycleLand(
        itemAttr.dpId,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                PopupLayerController:hideLayer(
                    "PopTextLayer2",
                    function(layer)
                        layer:hide()
                    end
                )
                RichPrint("main", "您购买的地皮超过时间未搬入，已被系统收回。")
            else
                -- PopText(errmsg)
                print("errcode : ", errcode, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 获取地契描述
--@author:Liang SongQiang
--@time:2018-06-07 14:25:47
function DiQiModel:getDsc(dpId)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local dpInfo = self:getDpInfoById(dpId)

    local text = "这是一张地契，地契上写着：\n"
    text = text .. "此地为" .. dpInfo.place .. dpInfo.name .. "。\n"
    text = text .. "当前持有者为：" .. role:getName() .. "。\n"
    text = text .. "入住需缴地税：" .. dpInfo.cost .. "元宝/天。"

    return text
end

--@desc 获取玩家管理费
function DiQiModel:getUserDiQiCost(dpId)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local cost = 0

    local dpInfo = self:getDpInfoById(dpId)

    cost = dpInfo.cost

    return cost
end

function DiQiModel:getMoveTimeLimitDsc(itemId)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local item = role:getItem(itemId)

    if item.time <= GetTime() then
        return 0
    end

    local year, month, day, hour, minute, second = Helper:getExpiredTime(item.time, GetTime())
    return Helper:changeNumberDateToStringDate(year, month, day, hour, minute, second)
end

function DiQiModel:getCheckDsc(itemId, dpInfo)
    local dpPlace = dpInfo.place

    local text = "此地为" .. dpPlace .. dpInfo.name .. "，上天三丈，下土三丈均归地主所有。\n   \n"

    text = text .. "入住需缴地税：" .. self:getUserDiQiCost(dpInfo.dpId) .. "元宝。\n"

    local timeDsc = self:getMoveTimeLimitDsc(itemId)

    if type(timeDsc) == "string" then
        text = text .. "搬入剩余时间：" .. timeDsc .. "。（到时若是没有搬入该地，土地将会被回收。）"
    end

    return text
end

--@desc: 查看地契
--@author:Liang SongQiang
--@time:2018-06-07 16:59:07
function DiQiModel:viewDiQi(itemId, dpId,move_land_callback)

    if JIAYUAN_SYSTEM_IS_OPEN == false then
        PopText("该功能暂时未开放")
        return
    end

    local role = User:getRole()

    local dq = role:getHomelandAttr("dq")

    if not dq or MapIsEmpty(dq) then
        PopText("此地皮已被回收")
        return
    end

    local isCanShow = false
    for i, dqInfo in ipairs(dq) do
        if dqInfo.id == itemId then
            isCanShow = true
            break
        end
    end

    if isCanShow == false then
        PopText("此地皮已被回收")
        return
    end

    local dpInfo = self:getDpInfoById(dpId)

    local dpName = self:getNameColor(dpInfo.dpId)

    PopupLayerController:showLayer(
        "PopTextLayer2",
        function(layer)
            layer:showLayer()
            layer:pushSchedule(
                function()
                    local text = self:getCheckDsc(itemId, dpInfo)
                    layer:print(text)
                end
            )
            local text = self:getCheckDsc(itemId, dpInfo)
            layer:print(text)
            layer:setTitle(dpName)
            layer:setTitle2("持有者:" .. role:getName())
            layer:setLogVisible(true)
            layer:setBtn1(
                "搬入",
                function()
                    layer:hideLayer()
                    self:moveHomeland(dpId, itemId,move_land_callback)
                end
            )
            layer:setBtn2(
                "关闭",
                function()
                    layer:hideLayer()
                end
            )
        end
    )
end

--@desc:补领地契 
--@author:Liang SongQiang
--@time:2018-10-22 12:28:42
function DiQiModel:reapplyDiQi(npc)
    
    HttpManagerEx:getLandInfo(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if MapIsEmpty(data) then
                        PopText("你没有地契需要补领。")
                        return
                    end

                    Helper:print_lua_table(data)

                    --@RefType [src.app.models.role.Role#Role]
                    local role = User:getRole()

                    local roleDqInfo = role:getHomelandAttr("dq")

                    local roleDqMap = {}

                    for index,v in ipairs(roleDqInfo) do
                        roleDqMap[v.dpId] = index
                    end

                    for index,dqData in ipairs(data) do
                        local now_time = dqData.now_time

                        SetTime(now_time)

                        local create_time = dqData.create_time

                        local expire_time = dqData.create_time + 3600 * 24 * 3

                        local timeEnd = expire_time - now_time
                        
                        if roleDqMap[dqData.dpId] ~= nil then
                            local roleIndex = roleDqMap[dqData.dpId]

                            local roleDq = roleDqInfo[roleIndex]

                            roleDq.timeend = timeEnd
                        else
                            local temp = {
                                name = "HIY地契NOR",
                                id = "dq_" .. dqData.dpId,
                                type = "地契",
                                dpId = dqData.dpId,
                                timeend = timeEnd
                            }

                            table.insert(roleDqInfo,temp)
                        end
                    end


                    local needAddItemList = {}
                    for _,roleDq in ipairs(roleDqInfo) do
                        local items = role:getItems(function (item)
                            return item.itemId == roleDq.id
                        end)

                        if #items == 0 then
                            table.insert( needAddItemList,roleDq )
                        end
                    end


                    if MapIsEmpty(needAddItemList) then
                        PopText("你没有地契需要补领。")
                        return
                    end

                    local reapplyCount = #needAddItemList

                    if role:checkCanBuyTwoOrMoreThings({jian100 = #needAddItemList}) == false then
                        return
                    end

                    for i,v in ipairs(needAddItemList) do
                        role:addItemCount(v.id,1,GetTime() + v.timeend)
                    end
                    
                    local cn_num = Helper:numberCast(reapplyCount)
                    
                    PopText("你补领了"..cn_num.."张地契。")

                    RichPrint("main","YEL"..npc.name.."：地契，可是身家性命一样珍贵的东西啊。有房有地，才有立身之本。拿好了，切莫疏于保管。")
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )

end

return DiQiModel
0000000
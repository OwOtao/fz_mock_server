local FangQiModel = {}

local familylist = requireWithEncrypt("script.others.familylist")

local _fqTemplate = {}
local function iniFangQiTemplate()
    local list = familylist["房契模板"]

    for k, v in pairs(list) do
        _fqTemplate[v.fqId] = v
        -- v.fqId = v.fdId
    end
end
iniFangQiTemplate()

function FangQiModel:getFangQiTemplateById(fqId)
    return _fqTemplate[fqId]
end

function FangQiModel:getLevel(fqId)
    local fqAttr = self:getFangQiTemplateById(fqId)

    return fqAttr.level or 0
end

--@desc: 更新房契信息
--@author:Liang SongQiang
--@time:2018-05-21 21:35:27
function FangQiModel:updateInfo(data)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local fqInfo = role:getHomelandAttr("fq")

    -- local _fqCache = role:getOneItemByKey("fq100")

    if MapIsEmpty(data) then
        return
    end

    for k, v in pairs(data) do
        if v == "nil" then
            -- _fqCache[k] = nil
            fqInfo[k] = nil
        else
            -- _fqCache[k] = v
            fqInfo[k] = v
        end

        if k == "location" or k == "dpId" then
        -- _fqCache.dsc = self:getDsc()
        end
    end
end

--@desc: 领取房契
--@author:Liang SongQiang
--@time:2018-05-21 21:35:58
--@data: 房契信息
function FangQiModel:getFangQi(data)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local fq = Helper:getDef(role:getHomelandAttr("fq"), {})

    local fqTemplate = self:getFangQiTemplateById(data.fqId)

    fq.id = "fq100"

    fq.name = fqTemplate.name

    --@desc 房屋ID
    fq.mid = tonumber(data.mid)

    --@desc 房契模板ID
    fq.fqId = data.fqId

    fq.type = "房契"

    --@desc 房契对应的副本
    fq.mapId = data.mapId

    role:setHomelandAttr("fq", fq)

    --@desc 判断是否有地，如果有地则不需要更新位置信息
    if not fq.dpId or fq.dpId ~= "" then
        fq.location = data.location
    end

    local items =
        role:getItems(
        function(item)
            return item.itemId == "fq100"
        end
    )

    if #items == 0 then
        --@desc 是否雇佣初始管家
        fq.isDispose = false
        fq.houseName = "普通房屋"
        fq.isRename = false
        fq.status = 0 --@搬家状态
        role:addItemCount(fq.id, 1)
    end

    role:setMapWithId("user_fb_" .. fq.mid, nil)

    self:updateInfo(fq)
end

--@desc 房契改名
function FangQiModel:fangJianGaiMing()
    if JIAYUAN_SYSTEM_IS_OPEN == false then
        PopText("该功能暂时未开放")
        return
    end

    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")
    local mid = fq.mid
    -- actionType  1 获取房间数量， 2 获取仆人数量 3 获取房间总量和仆人数量
    local actionType = 3
    HttpManagerEx:getPuRenNumAndRoomNum(
        mid,
        actionType,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if DEBUG_MODE == 1 then
                        Helper:print_lua_table(data)
                    end
                    PopupLayerController:showLayer(
                        "FangJianGaiMingLayer",
                        function(layer)
                            layer:showLayer(data.rnum, data.pnum)
                        end
                    )
                else
                    print(errcode)
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function FangQiModel:viewFangQi()
    if JIAYUAN_SYSTEM_IS_OPEN == false then
        PopText("该功能暂时未开放")
        return
    end

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local fq = role:getHomelandAttr("fq")

    local mid = role:getHouseId()

    HttpManagerEx:getHomelandCost(
        mid,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    Helper:print_lua_table(data)

                    local ser_pay = data.servants_pay

                    local land_pay = data.land_pay
                    
                    local name = role:getName()

                    local location = fq.location
                
                    local text = "此地位于" .. location .. "，上天三丈，下土三丈均归地主所有。\n   \nHIW每日固定开支：NOR\n"
                
                    -- if fq.dpId then
                    --     local DiQiModel = require("app.models.HomelandModel.DiQiModel")
                    --     text = text .. "每日地税：" .. DiQiModel:getUserDiQiCost(fq.dpId) .. "元宝/天\n   \n"
                    -- end

                    local ser_pay_text = "仆役薪资："
                        
                    for cost_unit,cost in pairs(ser_pay) do
                        ser_pay_text = ser_pay_text .. cost .. role:getCHAttrName(cost_unit) .. "，"
                    end

                    ser_pay_text = string.sub(ser_pay_text, 1, -4)

                    text = text .. "HIY".. ser_pay_text .. "NOR\n"

                    local land_pay_text = "需缴地税：" .. land_pay.daily .. "元宝/天"

                    if land_pay.total > 0 then
                        land_pay_text = land_pay_text.."（总计"..land_pay.total.."元宝）"
                    end

                    text = text .. "HIY".. land_pay_text .. "NOR"

                    PopupLayerController:showLayer(
                        "PopTextLayer2",
                        function(layer)
                            layer:showLayer()
                
                            layer:setTitle(fq.houseName)
                            layer:setTitle2("持有者:" .. name)
                            layer:print(text)
                
                            layer:setLogVisible(true)
                            layer:setBtn1(
                                "改名",
                                function()
                                    layer:hideLayer()
                                    self:fangJianGaiMing()
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
                else
                    print(errcode)
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )

end

--@desc: 获取房契描述
--@author:Liang SongQiang
--@time:2018-06-07 14:10:06
function FangQiModel:getDsc()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local fq = role:getHomelandAttr("fq")
    local text = "这是一张房契，房契上写着：\n"
    --text = text .. "房屋名叫" .. fq.houseName .. "。\n"

    local location = fq.location or ""

    text = text .. "此地为" .. location .. "。\n"
    text = text .. "当前持有者为：" .. role:getName() .. "。\n"

    if fq.dpId then
        local DiQiModel = require("app.models.HomelandModel.DiQiModel")
        text = text .. "每日地税：" .. DiQiModel:getUserDiQiCost(fq.dpId) .. "元宝/天"
    end

    return text
end

--@desc 搬家流程
--@role: 管家
function FangQiModel:moveHouse(npc, map)
    -- --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local fq = role:getHomelandAttr("fq")

    local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
    local str = HomelandDesc:getMoveHouseText()

    PopupLayerController:showLayer(
        "TextAnimLayer",
        function(layer)
            layer:setAfterAnimCallback(
                function()
                    User:getRole():setFlag("PVP活动状态", "空闲中")
                    --@RefType [src.app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate#HomelandRoleTemplate]
                    local HomelandRoleTemplate =
                        require("app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate")
                    HomelandRoleTemplate:unlockRoleFunc(npc, map)
                end
            )
            layer:setMusicName("banjia")
            layer:showLayer(str)
        end
    )

    self:updateInfo({status = 1})
end

--@desc 在房契中使用前往进入玩家副本
function FangQiModel:useItemToUserMap(callback)
    if JIAYUAN_SYSTEM_IS_OPEN == false then
        HttpManagerEx:getHomeSwitch(
            function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    JIAYUAN_SYSTEM_IS_OPEN = true
                    self:useItemToUserMap(callback)
                else
                    PopText(errmsg or "该功能暂时未开放")
                end
            end,
            IS_SHOW_WAITING
        )
        return
    end

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")

    local useId = User:getUserId()

    local mapId = "user_fb_" .. fq.mid

    local currLayer = MainControllLayer:getCurrLayer()

    if role:getCurrMapId() == mapId and currLayer == "MapLayer" then
        PopText("你在家中，无需传送。")
        if callback then
            callback()
        end
        return
    end

    if currLayer == "BiWuMainLayer" or currLayer == "BiWuWatchLayer" then
        PopText("不能从这里前往自家住宅！")
        if callback then
            callback()
        end
        return
    end
    
    if currLayer=="AttrLayer" and fq.status == 1 then
        local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
        if RoleTaskControllor:clickMapLayer(role) == false then
            return
        end
         local UserMap = require("app.models.map.UserMap")
         UserMap:getUserMap(fq.mid,User:getUserId(),function (map,isSuccess)
                if isSuccess == false then
                    return
                end
                
                map._isComingIn = true
                map:setCallBackAndConnect(function()
                    local mapLayer = MainControllLayer:getLayer("MapLayer")
                    mapLayer:hide()
                    mapLayer:setMap(map)       
                    MainControllLayer:pushLayer("MapLayer")
                    MessageCenter:notify("EnterMap",{map=map})
                end)

            end)
         return 
    end
    -- Helper:print_lua_table(fq)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    local text = "你的房屋地址为" .. fq.location .. "，" .. "可寻找各大城市车夫前往，也可使用遁地符或者五行遁法前往。是否立即前往？"
    dialog:show(text)
    dialog:setButton1(
        "前往",
        function()
            local Item = require("app.models.item.Item")
            local item = Item:getOneItemByKey("dundifu")
            if not item then
                return
            end
            item:useDunDiFu(role, mapId, nil, callback)
        end
    )
    dialog:setButton2(
        "取消",
        function()
        end
    )
    dialog:setWeChatVisible(false)
end

--@desc:补领房契 
--@author:Liang SongQiang
--@time:2018-10-22 12:28:51
function FangQiModel:reapplyFangQi(npc)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local fq_item =
        role:getItems(
        function(item)
            return item.itemId == "fq100"
        end
    )

    if MapIsEmpty(fq_item) == false then
        PopText("您的背包中已有一张房契，无需补领。")
        return
    end

    --@desc 只为检查是否可以加入一件物品
    if role:checkCanBuyTwoOrMoreThings({["jian111"] = 1}) == false then
        return
    end

    HttpManagerEx:getHouseInfo(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local fq = role:getHomelandAttr("fq")
                    local fqTemplate = self:getFangQiTemplateById(data.fqId)

                    fq.id = "fq100"

                    fq.type = "房契"

                    fq.fqId = data.fqId

                    fq.mid = tonumber(data.mid)

                    local loc_mark = data.loc_mark

                    if data.dpId ~= nil and data.dpId ~= "" then
                        --@RefType [src.app.models.HomelandModel.DiQiModel#DiQiModel]
                        local DiQiModel = require("app.models.HomelandModel.DiQiModel")
                        local dpInfo = DiQiModel:getDpInfoById(data.dpId)
                        fq.mapId = dpInfo.fbId
                    else
                        if type(loc_mark) == "table" then
                            local UserMapRelation = require("app.models.map.UserMapRelation")
                            local fbId = UserMapRelation:getFbIdByCityDir(tonumber(loc_mark[1]))
                            fq.mapId = fbId
                        end
                    end

                    fq.name = fqTemplate.name

                    if data.name == "普通房屋" then
                        fq.isRename = false
                    end

                    fq.location = data.location

                    fq.houseName = data.name

                    if data.person == true then
                        fq.isDispose = true
                    else
                        fq.isDispose = false
                    end

                    fq.status = 0

                    self:updateInfo(fq)

                    role:addItemCount(fq.id, 1)

                    PopText("你获得了一张房契")

                    RichPrint("main","YEL"..npc.name.."：房契要保管好，这可是能当成传家宝的物件，切记收好别弄丢了。如果弄丢，额，那再来找我吧。")
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

return FangQiModel
00000
local FurnitureModel = {}

--@RefType [src.app.models.HomelandModel.FurnitureModel.SpecialFurnitureModel#SpecialFurnitureModel]
local SpecialFurnitureModel = require("app.models.HomelandModel.FurnitureModel.SpecialFurnitureModel")

--@RefType [src.app.models.HomelandModel.FurnitureModel.FunitureTemplate#FunitureTemplate]
local FunitureTemplate = require("app.models.HomelandModel.FurnitureModel.FunitureTemplate")

--@RefType [src.app.models.HomelandModel.HomelandRoomUtil#HomelandRoomUtil]
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

local f_res_data = {}

local function initResList()
    local familyList = requireWithEncrypt("script.others.familylist")["家具"]
    for k, v in pairs(familyList) do
        f_res_data[v.jjId] = v
    end
end

initResList()

--@desc: 检查家具是否放置在规定的房间
--@author:Liang SongQiang
--@time:2018-06-28 20:47:20
--@itemAttr:[src.app.models.item.BaseItem#BaseItem]
--@map:[src.app.models.map.BaseMap#BaseMap]
function FurnitureModel:checkFurIsInRightRoom(itemAttr, map, roomId)
    if not itemAttr.takelimit then
        --@desc 没有限制
        return true
    end

    local currRoom = map:getRoomById(roomId)

    local takeLimitPlace = string.split(itemAttr.takelimit, ";")

    for i, v in ipairs(takeLimitPlace) do
        if currRoom.roomType == v then
            return true
        end
    end

    return false
end

--@desc:检查该家具能否放置该房间
--@author:Liang SongQiang
--@time:2018-05-29 20:44:56
function FurnitureModel:checkCanPlace(itemAttr, map, currRoomId)
    local bool = self:checkFurIsInRightRoom(itemAttr, map, currRoomId)
    return bool
end

function FurnitureModel:pickUpLocalMap(furniture, map)
    local currRoomId = map:getCurrRoomId()

    local furnitureId = furniture.jjId

    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    if not player:checkCanBuyTwoOrMoreThings({[furnitureId] = 1}) then
        PopText("您的背包空间已满，无法收起")
        return
    end

    local itemAttr = Item:getOneItemByKey(furnitureId)
    local furnitureType = itemAttr.iType

    -- --@desc 特殊家具收起条件
    -- local specialTb = SpecialFurnitureModel:getSpecialFurnitureByType(furnitureType)
    -- if specialTb then
    --     if specialTb.pickUpCondition then
    --         local bool, msg = specialTb.pickUpCondition(furnitureId, furniture.id, map, currRoomId)
    --         if not bool then
    --             PopText(msg)
    --             return
    --         end
    --     end

    --     --@desc 收起前要进行的操作
    --     if specialTb.prePickUp then
    --         specialTb.prePickUp(furnitureId, map, currRoomId)
    --     end
    -- end

    map:removeRoomRole(currRoomId, furniture.id)
    local isAdd, item = player:addItemCount(furnitureId, 1)

    -- if specialTb and specialTb.aftPickUp then
    --     specialTb.aftPickUp(item, map, currRoomId)
    -- end

    RichPrint("main", "你把" .. Item:getOneItemByKey(item.itemId).name .. "放入背包中")
    map.roles[furniture.id] = nil
    map.__MapLayer:refreshMap()
end

--@desc:收起玩家副本逻辑
--@author:Liang SongQiang
--@time:2018-06-10 14:28:58
--@furniture:
--@map:[src.app.models.map.BaseMap#BaseMap]
function FurnitureModel:pickUpUserMap(furniture, map)
    local currRoomId = map:getCurrRoomId()

    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    if not player:checkCanBuyTwoOrMoreThings({[furniture.jjId] = 1}) then
        PopText("您的背包空间已满，无法收起")
        return
    end

    local itemAttr = Item:getOneItemByKey(furniture.jjId)
    local furnitureType = itemAttr.iType

    local specialOperation = SpecialFurnitureModel:getSpecialFurnitureByType(furnitureType)
    if specialOperation then 
        if specialOperation.pickUpCondition(furniture, map, currRoomId) ==false then 
            return 
        end
        specialOperation.befPickUp(furniture, map, currRoomId)
    end 
    
    local furnitureId = furniture.jjId

    local fq = player:getHomelandAttr("fq")

    local localVer = player:getAttr("sCk_ver")

    HttpManagerEx:removeFurniture(
        fq.mid,
        furniture.fid,
        localVer["homeland"],
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local itemAttr = Item:getOneItemByKey(furnitureId)

                    local local_ver = player:getAttr("sCk_ver")
                    local_ver["homeland"] = data.ver
                    player:setAttr("sCk_ver", local_ver)

                    map:addFurTypeCount(furniture.itype,-1)
                    
                    map:removeRoomRole(currRoomId, furniture.id)

                    local isAdd, item = player:addItemCount(furnitureId, 1, nil, nil, "家具收起")

                    if specialOperation then
                        specialOperation.aftPickUp(furniture, map, currRoomId)
                    end

                    RichPrint("main", itemAttr.shouqitext)
                    map.roles[furniture.id] = nil
                    map.__MapLayer:refreshMap()
                    return true
                else
                    print("errcode", errcode)

                    PopText(errmsg)
                end
                return true
            else
                print("errcode", errcode)
                PopText(errmsg)
                return true
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

--@desc: 收拾家具
--@author:Liang SongQiang
--@time:2018-05-08 14:09:27
--@map:[src.app.models.map.BaseMap#BaseMap]
--@furnitureId: 家具Id
function FurnitureModel:pickUp(furniture, map)
    if map.mid == nil then
        self:pickUpLocalMap(furniture, map)
    else
        self:pickUpUserMap(furniture, map)
    end
end

local canPlaceInLocalMap = {
    ["副本木人"] = true,
    ["永久木人"] = true
}
function FurnitureModel:placeLocalMap(map, item, callback)
    local itemAttr = Item:getOneItemByKey(item.itemId)
    local furnitureType = itemAttr.iType
    -- local itemAttr = Item:getOneItemByKey(item.itemId)
    local furnitureId = item.itemId

    local currRoomId = map:getCurrRoomId()

    local roomRoleList = map:getRoomRoleList(currRoomId)

    if not canPlaceInLocalMap[furnitureType] then
        PopText("该副本无法安放家具。")
        return
    end

    local furnitureData = {
        fid = Helper:getOnlyId(),
        jjId = item.itemId
    }

    local itemBox = self:initFurnitureForUserMap(map, furnitureData)
    -- local itemBox = self:initFurnitureData(map, furnitureData)
    map:createRole(itemBox)
    map:addRoomRole(currRoomId, itemBox.id, true)
    map.__MapLayer:refreshMap()

    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()
    player:addItemCount(furnitureId, -1,nil, item.id)

    if callback then
        callback()
    end
end

--@desc:在用户房间放置逻辑
--@author:Liang SongQiang
--@time:2018-06-09 20:26:16
--@map:[src.app.models.map.BaseMap#BaseMap]
function FurnitureModel:palceUserMap(map, item, callback)
    -- local itemAttr = Item:getOneItemByKey(item.itemId)
    local furnitureId = item.itemId

    local currRoomId = map:getCurrRoomId()

    local roomRoleList = map:getRoomRoleList(currRoomId)

    local itemAttr = Item:getOneItemByKey(item.itemId)
    local furnitureType = itemAttr.iType

    if map:getMapType() ~= MAP_TYPE.MYHOME then
        PopText("该副本无法安放家具。")
        return
    end

    do
        local room = map:getRoomById(currRoomId)
        local typeValue = self:getItypeNum(furnitureType)
        if not HomelandRoomUtil:checkCanPlaceFurnitureType(room.roomType, typeValue) then
            PopText("该房间不可放置该类型家具。")
            return
        end
    end

    --@desc 检查家具是否是否可以放置该房间
    do
        local bool = self:checkCanPlace(itemAttr, map, currRoomId)
        if not bool then
            PopText("该家具不可放置到当前房间。")
            return
        end
    end

    --@desc 检查房间上限控制
    do
        --@RefType [src.app.models.HomelandModel.HomelandRoomUtil#HomelandRoomUtil]
        local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
        local placeLimit = HomelandRoomUtil:getRoomFurnitureLimit(map:getRoomById(currRoomId).roomType)
        local count = HomelandRoomUtil:getRoomFurnitureCount(map, currRoomId)

        if PRINT_MODE == 1 then
            print("当前房间可放置家具数量为：", placeLimit)
            print("当前房间已放置家具数量为：", count)
        end

        if count >= placeLimit then
            PopText("当前房间家具放置已达上限，不可放入。")
            return
        end
    end

    local extraAttr = {}

    local specialOperation = SpecialFurnitureModel:getSpecialFurnitureByType(furnitureType)
    if specialOperation then 
        if specialOperation.placeCondition(item, map, currRoomId) ==false then 
            return
        end
        extraAttr=specialOperation.befPlace(item, map, currRoomId)
    end

    local localVer = User:getRole():getAttr("sCk_ver")

    HttpManagerEx:putinFurniture(
        map.mid,
        currRoomId,
        furnitureId,
        extraAttr,
        localVer["homeland"],
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    -- local itemBox = self:initFurnitureData(map, data.furn_info)
                    local itemBox = self:initFurnitureForUserMap(map, data.furn_info)

                    local local_ver = User:getRole():getAttr("sCk_ver")
                    local_ver["homeland"] = data.ver
                    User:getRole():setAttr("sCk_ver", local_ver)

                    map:addFurTypeCount(data.furn_info.itype,1)
                    
                    map:createRole(itemBox)
                    map:addRoomRole(currRoomId, itemBox.id, true)
                    map.__MapLayer:refreshMap()
                    if specialOperation then 
                        specialOperation.aftPlace(furnitureId, map, currRoomId)
                    end 
                    --@RefType [src.app.models.role.Role#Role]
                    local player = User:getRole()
                    player:addItemCount(furnitureId, -1,nil,item.id,"家具放下")

                    local text = itemAttr.fangzhitext

                    text = string.gsub(text, "#rn#", map.room[currRoomId].name)

                    RichPrint("main", text)

                    if callback then
                        callback()
                    end
                else
                    print("errcode", errcode)

                    PopText(errmsg)
                end
            else
                print("errcode", errcode)
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 放置家具
--@author:Liang SongQiang
--@time:2018-05-08 14:11:19
--@map:[src.app.models.map.BaseMap#BaseMap]
--@furnitureId: 角色身上的itemsA
--@callback: 回调
function FurnitureModel:place(map, item, callback)
    if map.mid == nil then
        return self:placeLocalMap(map, item, callback)
    else
        return self:palceUserMap(map, item, callback)
    end
end

--@desc:初始化家具对应模板
--@author:Liang SongQiang
--@time:2018-06-01 11:19:41
--@fid:only Id in map
--@furnitureId:家具id
function FurnitureModel:initFurnitureData(map, furniture)
    local itemAttr = Item:getOneItemByKey(furniture.jjId)

    local roomId
    if map.mid == nil then
        roomId = map:getCurrRoomId()
    else
        if not itemAttr then
            error("数据错误, 家具ID : " .. tostring(furniture.jjId) .. "不存在")
        end

        if not furniture.fjId then
            error("数据错误, 家具放置房间ID 不存在")
        end
        roomId = furniture.fjId
    end

    local f_template = {
        type = "item",
        subType = itemAttr.type,
        itype = itemAttr.itype,
        iType = itemAttr.iType,
        id = "f_" .. furniture.fid,
        -- fid = furniture.fid,
        -- jjId = furniture.jjId,
        fjId = roomId,
        name = itemAttr.name,
        dsc = itemAttr.dsc,
        usedsc = itemAttr.usedsc,
        value = itemAttr.value,
        canSee = true, -- 可见
        canPickUp = false, -- 拾取
        canUse = false, -- 使用
        canExtract = false, -- 提取
        canOpen = false, -- 打开
        canPushIn = false, -- 能放入
        backImg = 1,
        btnImg = 0
    }

    if itemAttr.grade == 2 then
        f_template.btnImg = 1
    elseif itemAttr.grade == 3 then
        f_template.btnImg = 2
    end

    Helper:tableCover(f_template,furniture)

    f_template = FunitureTemplate:intTemplate(f_template, map:getRoomById(f_template.fjId), map)

    return f_template
end

--@desc:初始化用户地图中的家具信息
--@author:Liang SongQiang
--@time:2018-06-01 09:43:46
--@map:用户地图
--@furnitrue:家具(副本Role结构)
function FurnitureModel:initFurnitureForUserMap(map, furnitrue)
    if not furnitrue.conditionAndResults then
        furnitrue.conditionAndResults = {}
    end

    local f = self:initFurnitureData(map, furnitrue)

    --@desc 储物箱的处理
    FurnitureModel:initChuWuXiang(f)
    self:initRoleItem(f)
    self:checkXiangLuIsInMap(f,map)
    --@desc 初始化按钮UI
    if f.grade == 2 then
        f.btnImg = 1
    elseif f.grade == 3 then
        f.btnImg = 2
    end

    map:createRole(f)

    return f
end

function FurnitureModel:getItypeCN(value)
    local CN =
        switch(
        value,
        {
            [0] = "普通家具",
            [1] = "床",
            [2] = "书案",
            [3] = "药炉",
            [4] = "蒲团",
            [5] = "熔炼炉",
            [6] = "储物箱",
            [7] = "土地",
            [8] = "背包木人",
            [9] = "副本木人",
            [10] = "永久木人",
            [11] = "灶台",
            [12] = "门",
            [13] = "饰品箱",
            [14] = "茶案",
            [15] = "井",
            [16] = "饭桌",
            [17] = "庭院",
            [18] = "锻造炉",
            [19] = "墙壁",
            [20] = "衣柜",
            [21] = "晶台",
            [22] = "书柜",
            [23] = "香炉",
            [24] = "假人",
            [25] = "梦境香炉",
            [26] = "神功书案",
            [27] = "神功书架",
        }
    )

    return CN
end

function FurnitureModel:getItypeNum(cName)
    local value =
        switch(
        cName,
        {
            ["普通家具"] = 0,
            ["床"] = 1,
            ["书案"] = 2,
            ["药炉"] = 3,
            ["蒲团"] = 4,
            ["熔炼炉"] = 5,
            ["储物箱"] = 6,
            ["土地"] = 7,
            ["背包木人"] = 8,
            ["副本木人"] = 9,
            ["永久木人"] = 10,
            ["灶台"] = 11,
            ["门"] = 12,
            ["饰品箱"] = 13,
            ["茶案"] = 14,
            ["井"] = 15,
            ["饭桌"] = 16,
            ["庭院"] = 17,
            ["锻造炉"] = 18,
            ["墙壁"] = 19,
            ["衣柜"] = 20,
            ["晶台"] = 21,
            ["书柜"] = 22,
            ["香炉"] = 23,
            ["假人"] = 24,
            ["梦境香炉"] = 25,
            ["神功书案"] = 26,
            ["神功书架"] = 27,
        }
    )

    return value
end

function FurnitureModel:initItemData(item)
    local res_data = f_res_data[item.id]

    if not res_data then
        assert(false, "家具表中不存在" .. item.id)
    end

    
    Helper:tableCover(item, res_data)
    local CN = self:getItypeCN(res_data.itype)
    item.iType = CN
end

--@desc: 使用食材的条件结果
--@author:Liang SongQiang
--@time:2018-06-14 10:54:23
function FurnitureModel:dinner(func)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local dinner = role:getHomelandAttr("dinner")

    if not dinner or MapIsEmpty(dinner) then
        assert(false, "没有做饭保存的数据，请检查代码流程")
    end

    local rate = dinner.rate

    local lv = dinner.lv

    --@desc 当前气血最大值
    local currQiMax = role:getCurrQiMax()

    local qi = role:getNumAttr("qi")

    --@desc 气血最大值
    local qiMax = role:getFinalAttr("qiMax")

    local currQipercent = role:getAttr("qiPercent")

    local jingMax = role:getJingMax()

    local currJing = role:getAttr("jing")

    local currNeili = role:getAttr("neili")
    local neiliMax = role:getFinalAttr("neiliMax")

    local reuslt = {}

    if rate >= 1 and rate <= 15 then
    elseif rate > 15 and rate <= 45 then
        -- if qi >= currQiMax then
        --     return {
        --         msg = "你气血充沛，无需恢复。"
        --     }
        -- end

        local addQi = qiMax * 0.2 + math.floor((lv ^ 2) / 8) * 1000
        if qi + addQi > currQiMax then
            addQi = currQiMax - qi
        end
        role:addAttr("qi", addQi)
        reuslt = {
            name = "恢复气血 ",
            value = math.floor(addQi)
        }
    elseif rate > 45 and rate <= 60 then
        --@desc 恢复当前伤势
        local addQiMax = qiMax * 0.2 + math.floor((lv ^ 2) / 8) * 1000

        if currQiMax + addQiMax > qiMax then
            addQiMax = qiMax - currQiMax
        end

        local aftQiPercent = (currQiMax + addQiMax) / qiMax

        local addQiPercent = aftQiPercent

        role:setAttr("qiPercent", aftQiPercent)

        reuslt = {
            name = "恢复伤势",
            value = math.floor(addQiMax)
        }
    elseif rate > 60 and rate <= 80 then
        -- if currJing >= jingMax then
        --     return {
        --         msg = "你精力充沛，无需恢复。"
        --     }
        -- end

        -- 立即恢复精力=8+math.floor(k^2/8) *10+random(3,8)
        local addJing = 8 + math.floor((lv ^ 2) / 8) * 10 + math.random(3, 8)

        if currJing + addJing > jingMax then
            addJing = jingMax - currJing
        end

        role:addAttr("jing", addJing)

        reuslt = {
            name = "精力增加",
            value = math.floor(addJing)
        }
    elseif rate > 80 and rate <= 90 then
        -- if currNeili >= neiliMax then
        --     return {
        --         msg = "你内力充足，无需恢复。"
        --     }
        -- end

        -- 立即恢复内力=内力上限*0.25+math.floor(k^2/8) *2000
        local addNeili = neiliMax * 0.25 + math.floor((lv ^ 2) / 8) * 2000

        if currNeili + addNeili > 2* neiliMax then
            addNeili = math.max(2*neiliMax - currNeili,0)
        end

        role:setAttr("neili", currNeili + addNeili)

        reuslt = {
            name = "内力恢复",
            value = math.floor(addNeili)
        }
    elseif rate > 90 and rate <= 95 then
        -- 即降低血量=血量上限*0.35，但不能减少到0
        local subQi = qiMax * 0.35

        if qi - subQi <= 0 then
            subQi = qi - 1
        end
        
        role:setAttr("qi", qi - subQi)

        reuslt = {
            name = "气血降低",
            value = math.floor(subQi)
        }
    elseif rate > 95 and rate <= 98 then
        -- 立即降低内力=内力上限*0.25，但不能减少到0
        local subNeili = neiliMax * 0.25

        if currNeili - subNeili <= 0 then
            subNeili = currNeili - 1
        end

        role:setAttr("neili", currNeili - subNeili)

        reuslt = {
            name = "内力降低",
            value = math.floor(subNeili)
        }
    elseif rate <= 99 then
        -- 立即损失当前气血上限=当前气血上限*0.5
        
        local subQiMax = currQiMax * 0.5

        role:setAttr("qiPercent", (role:getFinalAttr("qiMax") * role:getAttr("qiPercent") - subQiMax) / role:getFinalAttr("qiMax"))

        if role:getAttr("qi") > role:getCurrQiMax() then
            role:setAttr("qi", role:getCurrQiMax())
        end

        reuslt = {
            name = "当前气血最大值降低",
            value = math.floor(subQiMax)
        }
    elseif rate == 100 then
        -- 损失 random（10，25）点精力

        local subJing = math.random(10, 25)

        if currJing - subJing <= 0 then
            subJing = currJing - 1
        end

        role:setAttr("jing", currJing - subJing)

        reuslt = {
            name = "精力减少",
            value = math.floor(subJing)
        }
    end

    reuslt.rate = rate

    dinner.times = dinner.times - 1

    if dinner.times == 0 then
        role:setHomelandAttr("dinner", {})

        if func then
            func()
        end
    end

    return reuslt
end

--@desc:检查玩家角色的做饭数据
--@author:Liang SongQiang
--@time:2018-06-14 14:10:08
function FurnitureModel:checkDinnerData()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local dinner = role:getHomelandAttr("dinner")

    if not dinner or MapIsEmpty(dinner) then
        return
    end

    --@desc 如果没有装盒，直接删除
    if dinner.status == 1 then
        role:setHomelandAttr("dinner", {})
    end
end

--@desc: 闯门进入别人玩家的房间处理
--@author:Liang SongQiang
--@time:2018-06-15 14:28:40
--@map: [src.app.models.map.BaseMap#BaseMap]
function FurnitureModel:entryOtherUserMap(map, item)
    local handleMap = {
        ["床"] = function(item)
            item.canUse1 = 0
            item.canUse2 = 0
        end,
        ["书案"] = function(item)
            item.canUse1 = 0
        end,
        ["药炉"] = function(item)
            item.canUse1 = 0
        end,
        ["蒲团"] = function(item)
            item.canUse1 = 0
            item.canUse2 = 0
        end,
        ["熔炼炉"] = function(item)
            item.canUse1 = 0
        end,
        ["储物箱"] = function(item)
            item.canUse1 = 0
        end,
        ["土地"] = function(item)
            item.canUse1 = 0
            item.canUse2 = 0
            item.canUse3 = 0
            item.canUse4 = 0
            item.canUse5 = 0
        end,
        ["背包木人"] = function(item)
            item.canUse1 = 0
        end,
        ["副本木人"] = function(item)
            item.canUse1 = 0
        end,
        ["永久木人"] = function(item)
            item.canUse1 = 0
        end,
        ["灶台"] = function(item)
            item.canUse1 = 0
            item.canUse2 = 0
            item.canUse3 = 0
        end,
        ["门"] = function(item)
            item.canUse1 = 0
            item.canUse2 = 0
        end,
        ["饰品箱"] = function(item)
            item.canUse1 = 0
        end,
        ["茶案"] = function(item)
            item.canUse1 = 0
        end,
        ["井"] = function(item)
            item.canUse1 = 0
        end,
        ["饭桌"] = function(item)
            item.canUse1 = 0
        end,
        ["庭院"] = function(item)
            item.canUse1 = 0
        end,
        ["锻造炉"] = function(item)
            item.canUse1 = 0
            item.canUse2 = 0
            item.canUse3 = 0
            item.canUse4 = 0
        end,
        ["晶台"] = function(item)
            item.canUse1 = 0
        end,
        ["香炉"] = function(item)
            item.canUse1 = 0
        end,
        ["书柜"] = function ( item )
            item.canUse1 = 0
            item.canUse2 = 0
        end,
        ["假人"] = function ( item )
            item.canUse1 = 0
            item.canUse2 = 0
        end,
        ["梦境香炉"] = function ( item )
            item.canUse1 = 0
            item.canUse2 = 0
        end,
        ["神功书案"] = function ( item )
            item.canUse1 = 0
            item.canUse2 = 0
            item.canUse3 = 0
        end,
        ["神功书架"] = function ( item )
            item.canUse1 = 0
        end,
    }

    if handleMap[item.iType] then
        handleMap[item.iType](item)
    end
end

--@desc: 检查家具在当前房间可进行的操作（自己房屋内）
--@author:Liang SongQiang 
--@time:2018-06-28 20:51:15
--@map: [src.app.models.map.BaseMap#BaseMap]
function FurnitureModel:checkFurInRoomAction(item, map)
    local filterType = {
        ["门"] = true,
        ["墙壁"] = true,
        ["衣柜"] = true,
        ["储物箱"] = true
    }
    local itemAttr = Item:getOneItemByKey(item.jjId)
    if not itemAttr then
        print("------------------", item.jjId)
    end

    if not self:checkFurIsInRightRoom(itemAttr, map, item.fjId) and not filterType[item.iType] then
        for i = 1, 8 do
            item["canUse" .. i] = 0
        end
    end
    --香炉可收起
    if item.iType == "梦境香炉" then
        item.canUse2 = 1
    elseif item.iType == "神功书案" then
        item.canUse3 = 1
    end
end


function FurnitureModel:initChuWuXiang(item)
    if item.iType ~= "储物箱" then
        return
    end

    --@RefType [src.app.models.HomelandModel.FurnitureModel.StorageBox#StorageBox]
    local StorageBox = require("app.models.HomelandModel.FurnitureModel.StorageBox")

    local storageBoxId = item.extra.itemId

    local storageBox = StorageBox:getBox(storageBoxId)

    for k,v in pairs(storageBox) do
        if k ~= "id" then
            item[k] = v
        else
            item.itemId = v
        end


    end
end

--假人
function FurnitureModel:initRoleItem(item)
    if item.iType ~= "假人" then
        return
    end
    if item.extra and item.extra.durable then 
        item.durable = item.extra.durable
    else
        local itemAttr = Item:getOneItemByKey(item.jjId)
        item.durable = itemAttr.att
    end  
end

function FurnitureModel:checkXiangLuIsInMap(item,map)
    if item.iType == "梦境香炉" and item.fjId then
        map:addMapLock(item.fjId.."dream_xianglu","您的香炉中有香正在燃烧，无法进行")
    end
end

return FurnitureModel
000000000000
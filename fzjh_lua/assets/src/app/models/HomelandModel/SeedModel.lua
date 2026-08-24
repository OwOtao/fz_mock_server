local SeedModel = {}

local seedList = requireWithEncrypt("script.others.familylist")["种植表"]

--@desc:根据Id获取种植信息
--@author:Liang SongQiang
--@time:2018-06-26 22:42:59
function SeedModel:getPlantInfoById(id)
    if not self._cache then
        self._cache = {}
    end

    if self._cache[id] then
        return self._cache[id]
    end

    for k, v in pairs(seedList) do
        if v.Plantid == id then
            self._cache[id] = v
            return v
        end
    end

    assert(false, "种植表没有种植信息，ID：" .. id)
end

--@desc: 种植条件
--@author:Liang SongQiang
--@time:2018-06-27 15:11:34
--@item: 种植的物品
function SeedModel:seedConditon(item)
    local plantInfo = self:getPlantInfoById(item.itemId)

    local bool, msg = false, ""

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local bagItem = role:getItem(plantInfo.Plantitem)

    if bagItem == nil then
        local itemAttr = Item:getOneItemByKey(plantInfo.Plantitem)
        bool = false
        msg = "种植此种子需要" .. itemAttr.name
        return bool, msg
    end

    local skillLv = role:getSkillLv("zhongzhizhishu")
    if skillLv < plantInfo.Plantlevel then
        bool = false
        msg = "您的种植之术等级不足，您无法种植该种子。"
        return bool, msg
    end

    return true
end

--@desc: 种植
--@author:Liang SongQiang
--@time:2018-06-26 22:39:31
--@item:播种的物品。
function SeedModel:seed(item, land,map)
    local plantInfo = self:getPlantInfoById(item.itemId)
    local bool_seed, msg = self:seedConditon(item)
    if not bool_seed then
        return bool_seed, msg
    end

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local rolePlantInfo = Helper:getDef(role:getHomelandAttr("plant"), {})

    rolePlantInfo[land.id] = {
        landId = land.id,
        itemId = item.itemId,
        status = 1,
        roomId = land.fjId
    }

    if plantInfo.Growtype == "时间成长" then
        --@desc 时间成长为结束时间。
        rolePlantInfo[land.id].endTime = GetTime() + plantInfo.Growtime
    elseif plantInfo.Growtype == "非时间成长" then
        --@desc 非时间成长为剩余时间
        rolePlantInfo[land.id].reTime = plantInfo.Growtime
    end

    role:addItemCount(item.itemId, -1)
    role:addItemCount(plantInfo.Plantitem, -1)
    self:changLandStatus(land, rolePlantInfo[land.id].status)

    role:setHomelandAttr("plant", rolePlantInfo)

    local itemAttr = Item:getOneItemByKey(plantInfo.Plantitem)
    local seed = Item:getOneItemByKey(item.itemId)
    PopText("您消耗了 " .. itemAttr.name .. " X1")
    PopText("您消耗了 " .. seed.name .. " X1")
    RichPrint("main", "你在药田上挖开一个小土坑，种上了" .. plantInfo.Plantname .. "埋土之后，取来洒水壶，浇上了水。")

    --@desc 锁门
    map:lockCurrRoom("您有土地正在种植或者有植物未收取，无法进行")

    return true
end

--@desc 照料田地
--@role: 仆人
function SeedModel:tendLand(land, map, item, role)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()
    local rolePlantInfo = player:getHomelandAttr("plant")[land.id]
    local plantInfo = self:getPlantInfoById(rolePlantInfo.itemId)

    if not rolePlantInfo then
        PopText("该土地没有种植任何植物。")
        return
    end

    local costJing = plantInfo.Takecast or 0
    if player:getAttr("jing") < costJing then
        PopText("您的精力不够，无法照料。")
        return
    end

    --@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    local tend_cd = 0

    --@desc 忠诚度等级
    local lv = 0
    if role then
        lv = HomelandRoleUtil:getFidelityLv(role.defaultZhongCheng)
    end

    local rate = 1

    local endTime = 0
    if plantInfo.Growtype == "时间成长" then
        endTime = rolePlantInfo.endTime
    elseif plantInfo.Growtype == "非时间成长" then
        endTime = rolePlantInfo.reTime
    end

    local subCD = 0
    if item then 
        if plantInfo.Growtype == "时间成长" then
            subCD = rolePlantInfo.endTime
        elseif plantInfo.Growtype == "非时间成长" then
            subCD = rolePlantInfo.reTime
        end
    else
        subCD = self:getTendReduceTime(plantInfo.Growtime, lv, rate,role)
    end

    if plantInfo.Growtype == "时间成长" then 
        rolePlantInfo.endTime = math.max(endTime - subCD, 0)
    elseif plantInfo.Growtype == "非时间成长" then 
        rolePlantInfo.reTime = math.max(endTime - subCD, 0)
    end
    

    local tend_cd_reduce = 0
    if role then
        --老农特性，减少照料功能CD
        tend_cd_reduce = role:getBuffAttr("zhaoliaoCDReduce")
    end
    
    tend_cd = 3600 * (math.max(8 * (1 - lv / 10), 3)) * (1-tend_cd_reduce)
    player:setTimeLimitFlag("tend_" .. land.id, 1, tend_cd)
    player:addAttr("jing", -costJing)

    if role then
        local addZc = lv / 2 + 1
        HomelandRoleUtil:addFidelityFree(role, map, addZc)
    end

    self:checkLandIsFish(map)

    PopText("照料成功，"..plantInfo.Plantname.."成长时间减少！")

    RichPrint("main", "你消耗了" .. costJing .. "点精力。")
    RichPrint("main", plantInfo.Taketext)
end

--@desc: 获取照料所减少的成长时间
--@author:Liang SongQiang
--@time:2018-06-27 15:05:00
--@growTime:标准成长时间
--@lv: 忠诚度等级
function SeedModel:getTendReduceTime(growTime, lv, rate,role)
    if not rate then
        rate = 1
    end

    if not lv then
        lv = 0
    end

    print("SeedModel:getTendReduceTime , 系数: ", rate, "人物等级:", lv)

    local time = growTime * ((lv + 1) * 3 / 100) * rate

    print("照料降低成长时间：", time)

    return time
end

--@desc: 检查该地是否可以收取植物
--@author:Liang SongQiang
--@time:2018-06-27 14:40:12
function SeedModel:checkLandCanHarvest(land)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    local rolePlantInfo = player:getHomelandAttr("plant")

    if MapIsEmpty(rolePlantInfo) then
        return
    end

    if rolePlantInfo[land.id] and rolePlantInfo[land.id].status == 2 then
        return true
    end

    return false
end

--@desc: 检查土地种植是否完成
--@author:Liang SongQiang
--@time:2018-06-27 18:14:56
--@map: [src.app.models.map.BaseMap#BaseMap]
function SeedModel:checkLandIsFish(map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local rolePlantInfo = role:getHomelandAttr("plant")

    if not rolePlantInfo or MapIsEmpty(rolePlantInfo) then
        return
    end

    local nowTime = GetTime()
    for landId, info in pairs(rolePlantInfo) do
        local plantInfo = self:getPlantInfoById(info.itemId)
        if plantInfo.Growtype == "时间成长" then
            if info.endTime <= nowTime and info.status == 1 then
                info.status = 2
            end
        elseif plantInfo.Growtype == "非时间成长" then
            if info.reTime == 0 and info.status == 1 then
                info.status = 2
            end
        end
        self:changLandStatus(map:getRole(landId), info.status)
    end
end

function SeedModel:checkLandStatusByEntryMap(map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local rolePlantInfo = role:getHomelandAttr("plant")

    if not rolePlantInfo or MapIsEmpty(rolePlantInfo) then
        return
    end

    for landId, info in pairs(rolePlantInfo) do
        local plantInfo = self:getPlantInfoById(info.itemId)
        self:changLandStatus(map:getRole(landId), info.status)
    end
end

function SeedModel:clearLandInfo(land,map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local landId = land.id

    local plantInfo = role:getHomelandAttr("plant")[landId]

    if not plantInfo then
        assert(false, "SeedModel:clearLandInfo ，没有该土地的种植信息：" .. landId)
    end
    
    local landRoomId = plantInfo.roomId
    if landRoomId == nil then
        assert(false, "SeedModel:clearLandInfo ，该土地没有对应房间")
    end

    role:setTimeLimitFlag("tend_" .. landId, 0, 0)
    role:getHomelandAttr("plant")[landId] = nil

    self:changLandStatus(land, 0)

    local isUnLock = true
    for Id, info in pairs(role:getHomelandAttr("plant")) do
        if info and info.roomId == landRoomId then
            isUnLock = false
        end
    end
    
    --解锁
    if isUnLock == true then
        map:unlockRoom(landRoomId)
    end
end

--@desc 获取种植剩余的完成时间
function SeedModel:getRePlantTimeStr(land)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local plantInfo = role:getHomelandAttr("plant")[land.id]

    if not plantInfo then
        assert(false, "该地没有种植信息，不应该有查看按钮，" .. land.id)
    end

    local nowTime = GetTime()
    local itemAttr = Item:getOneItemByKey(plantInfo.itemId)
    local timeStr
    local reTime = 0
    if plantInfo.endTime then
        reTime = math.max(plantInfo.endTime - nowTime, 0)
        if reTime==0 then 
            self:changLandStatus(land, 2)
            return "你的".. itemAttr.name .."已经成熟了"
        end
    elseif plantInfo.reTime then
        reTime = plantInfo.reTime
        if reTime==0 then 
            self:changLandStatus(land, 2)
            return "你的".. itemAttr.name .."已经成熟了"
        end
    else
        print("种植没有剩余时间或结束时间，检查代码。")
        print(debug.traceback())
    end

    if reTime == 0 then
        return ""
    end

    local time = math.floor(reTime)
    local hour = math.floor(time / 3600)
    local min = math.floor((time - hour * 3600) / 60)
    local sec = math.floor(time - hour * 3600 - min * 60)

    timeStr = hour .. "小时" .. min .. "分钟" .. sec .. "秒"

    local str = ""

    str = "你观察了" .. itemAttr.name .. "长势颇好，估摸着还有" .. timeStr .. "长成。"

    return str
end

--@desc:更改土地的状态
--@author:Liang SongQiang
--@time:2018-06-27 18:05:02
--@land:
--@status: 状态 0(空闲)，1（种植），2（可收取）
function SeedModel:changLandStatus(land, status)
    if status == 0 then
        land.canUse1 = 1
        land.canUse2 = 0
        land.canUse3 = 0
        land.canUse4 = 0
        land.canUse5 = 0
    elseif status == 1 then
        land.canUse1 = 0
        land.canUse2 = 1
        land.canUse3 = 1
        land.canUse4 = 1
        land.canUse5 = 0
    elseif status == 2 then
        land.canUse1 = 0
        land.canUse2 = 0
        land.canUse3 = 0
        land.canUse4 = 0
        land.canUse5 = 1
    end
end

--@desc 检查老农能否收取。
function SeedModel:checkFarmerCanHarvest(map, role)
    --@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

    local lv = HomelandRoleUtil:getFidelityLv(role.defaultZhongCheng)

    if lv >= 4 then
        HomelandRoleUtil:openRoleBtnFunc(role,"老农收取")
    end
end

function SeedModel:checkFarmerCanHarvestLand(map, role)
    local player = User:getRole()

    local rolePlantInfo = player:getHomelandAttr("plant")

    if MapIsEmpty(rolePlantInfo) then
        return false
    end
    
    for k, v in pairs(rolePlantInfo) do
        if v.status == 2 and map:checkRoleIsInRoom(v.roomId, role.id) == true then
            return true
        end
    end
    
    return false
end

--@desc:收成
--@author:Liang SongQiang
--@time:2018-06-26 23:49:50
--@land:收取的田地
--@role:[src.app.models.role.Role#Role]
function SeedModel:harvest(land, role, map)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    
    local rolePlantInfo = player:getHomelandAttr("plant")[land.id]

    if not rolePlantInfo then
        return
    end

    local plantInfo = self:getPlantInfoById(rolePlantInfo.itemId)

    local lv = 0
    local params = 0
    local roleFactor = 1
    if role then
        lv = HomelandRoleUtil:getFidelityLv(role.defaultZhongCheng)
        params = lv
        if lv < 3 then
            params = 0
        end
        roleFactor = roleFactor + role:getBuffAttr("tianpuchanliangAdd")
    end

    local getItems = string.split(plantInfo.Getitem,";")
    local count = math.floor(plantInfo.getvalue * (1 + params ^ 2 / 40) * roleFactor)

    local itemList = {}
    for k,itemId in pairs(getItems) do
        itemList[itemId] = count
    end

    if not player:checkCanBuyTwoOrMoreThings(itemList) then
        return
    end

    for itemId,_count in pairs(itemList) do
        player:addItemCount(itemId, _count)
        local itemAttr = Item:getOneItemByKey(itemId)
        PopText("你获得了 " .. itemAttr.name .. "X" .. _count)
    end

    if role then
        local addZc = 1
        HomelandRoleUtil:addFidelityFree(role, map, addZc)
    end

    local skillId = "zhongzhizhishu"
    local addExp = Helper:GetValueFromScript(plantInfo.Growexp,{lv = lv})
    local nowExp = player:getSkillExp(skillId)

    local affExp = addExp + nowExp

    player:addSkillExp(skillId, addExp)

    self:changLandStatus(land, 0)

    self:clearLandInfo(land,map)
end


--@desc: 检查是否有种植的情况。
--@author:Liang SongQiang
--@time:2018-06-28 14:49:31
function SeedModel:checkHavePlant(roomId)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local plantInfo = role:getHomelandAttr("plant")
    if roomId == nil then
        if plantInfo and not MapIsEmpty(plantInfo) then
            return true
        end
    else
        if plantInfo and not MapIsEmpty(plantInfo) then
            for k,v in pairs(plantInfo) do
                if v.roomId == roomId then
                    return true
                end
            end
        end
    end

    return false
end

--@desc: 进入副本时检查是否需要上锁房间
function SeedModel:checkNeedLockRoom(map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local plantInfo = role:getHomelandAttr("plant")
    
    if MapIsEmpty(plantInfo) then
        return
    end

    for landId, info in pairs(plantInfo) do
        local roomId = info.roomId
        local room = map:getRoomById(roomId)
        if room.lock ~= true then
            map:lockRoom(roomId,"您有土地正在种植或者有植物未收取，无法进行")
        end
        
    end
end

return SeedModel
000000000000
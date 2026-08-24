local SpecialFurnitureModel = {}

--@RefType [src.app.models.HomelandModel.HomelandRoomUtil#HomelandRoomUtil]
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

local specialPlaceByType = {
    ["假人"] = {
        placeCondition = function(furniture, map, currRoomId)
            return true
        end,

        befPlace = function(item, map, roomId)
            local attTab = {}
            local role = User:getRole()
            local isExist = false
            local jiarenNum={}

            local function removejiaRenData(jjId,num)
                local currNum = 0 
                num = num or 1
                local currjiaRenData = role:getAttr("jiaRenData")
                for index,info in pairs(currjiaRenData) do 
                    if info and info.jjId == jjId then 
                        if currNum < num then 
                            currNum = currNum + 1
                            currjiaRenData[index] = nil
                        end
                    end
                end
            end

            local jiaRenData = role:getAttr("jiaRenData")

            for index,info in pairs(jiaRenData) do 
                if info and jiarenNum[info.jjId] then 
                    jiarenNum[info.jjId] = jiarenNum[info.jjId] + 1
                else
                    jiarenNum[info.jjId] = 1
                end
            end

            if jiarenNum[item.itemId] then  --删除因为售卖而多余的数据
                local jiaRenItemNum = role:getItemTotalCount(item.itemId) 
                if jiarenNum[item.itemId] > jiaRenItemNum then 
                    removejiaRenData(item.itemId,jiarenNum[item.itemId]-jiaRenItemNum)
                end
            end

            for index,info in pairs(jiaRenData) do 
                if info and info.jjId == item.itemId then 
                    attTab.durable = info.durable
                    isExist =true
                    break
                end
            end

            if isExist == false then 
                local itemAttr = Item:getOneItemByKey(item.itemId)
                attTab.durable = itemAttr.att
            end
           
            return attTab
        end,

        aftPlace = function(jjId, map, roomId)
        --删除存档中对应数据
            local role = User:getRole()
            local jiaRenData = role:getAttr("jiaRenData")
            for index,info in pairs(jiaRenData) do 
                if info.jjId == jjId then 
                    jiaRenData[index] = nil 
                    return
                end
            end
        end,

        pickUpCondition = function(furniture, map, currRoomId)
            return true
        end,

        befPickUp = function(furniture, map, currRoomId)
        --假人耐久为零时变成破损假人
            if furniture.durable <= 0 then 
                furniture.jjId = "jiaren999"
            end
        end,

        aftPickUp = function(furniture, map, currRoomId)
        --背包保存收回家具对应的数据
            local role = User:getRole()
            local jiaRenData = role:getAttr("jiaRenData")
            local jiarenInfo ={}
            jiarenInfo.fid = furniture.fid
            jiarenInfo.jjId = furniture.jjId
            jiarenInfo.durable = furniture.durable
            table.insert(jiaRenData,jiarenInfo)
            role:setAttr("jiaRenData", jiaRenData)
        end
    },
    ["梦境香炉"] ={
        placeCondition = function(furniture, map, currRoomId)
            local xiangLus = HomelandRoomUtil:getCurrRoomFurnitureByType(map,25)
            if MapIsEmpty(xiangLus) then 
                return true
            end
            PopText("当前房间仅可摆放一个香炉")
            return false  
        end,

        befPlace = function(item, map, roomId)
        end,

        aftPlace = function(jjId, map, roomId)
            map:addMapLock(roomId.."dream_xianglu","您的香炉中有香正在燃烧，无法进行")
            local role = User:getRole()
        end,

        pickUpCondition = function(furniture, map, currRoomId)
            return true
        end,

        befPickUp = function(furniture, map, currRoomId)
        end,

        aftPickUp = function(furniture, map, currRoomId)
            map:deleteOneMapLock(currRoomId.."dream_xianglu")
            local role = User:getRole()
        end
    },
}

specialPlaceByType["永久木人"] = specialPlaceByType["副本木人"]

--@desc: 获取特殊家具的条件
--@author:Liang SongQiang
--@time:2018-05-29 21:01:58
--@f_type: 家具类型
function SpecialFurnitureModel:getSpecialFurnitureByType(f_type)
    return specialPlaceByType[f_type]
end

return SpecialFurnitureModel
00000000000
--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local DreamWorldModule = class("DreamWorldModule", require("app.models.map.MapHandle.Modules.BaseModule"))

local MapInfo = require("app.models.map.MapInfo")

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
DreamWorldModule.mapId = nil

--@desc 开启状态，默认开启
DreamWorldModule.status = 1

--@desc 子模块
DreamWorldModule.childModule = {}

--@desc 条件结果的方法
DreamWorldModule.doResult = {
    ["进入下一层"] = function(map, result, environment)
        local drSystem = User:getRole():getDreamSystem()
        local strList= Helper:getDef(result.arg2,"")
        local showStr
        strList = string.split(strList,";")
        if MapIsEmpty(strList) == false then
            showStr = strList[math.random(1,#strList)]
        end
        drSystem:enterNextMap(map,showStr)
    end,
    ["梦境结算"] = function(map, result, environment)
        local drSystem = User:getRole():getDreamSystem()
        local dreamRole = map:getPlayer()
        local role = User:getRole()
        local drCompleteLevel = dreamRole.dreamWorld.eFloor
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show("是否要进行梦境结算？")
        dialog:setButton1("确定",function()
            drSystem:mapComplete(map,function()
                map.__MapLayer.TotalMapBtn_IsInit = false
                map.__MapLayer:quit()
            end)
        end)
        dialog:setButton2("取消",function()
        end)
        dialog:setWeChatVisible(false)
    end,
    ["获取梦境积分"] = function(map, result, environment)
        local value = Helper:getDef(tonumber(result.arg2), 0)
        local role = map:getPlayer()
        role:addAttr("dreamPoints", value)
    end,
    ["梦境获取奖励"] = function(map, result, environment)
        local rewardTypeId = result.arg2
        local role = map:getPlayer()

        local context = {
            params = {
                rewardType = 1,
                rewardId = rewardTypeId,
                roleAttr = {lv = role:getLv(), menpaiId = role:getFamilyId(), qiMax = role:getFinalAttr("qiMax"), neiliMax = role:getFinalAttr("neiliMax")}
            },
            role = role,
            map = map,
            callback = function(rewardData)
                -- local mapLayer = MainControllLayer:getLayer("MapLayer")
                -- mapLayer:quit()
            end
        }
    
        User:getRole():getDreamSystem():getWebReward(context)
    end,
    ["宝箱开锁"] = function(map, result, environment)
        local itemId = result.arg2
        local successStr = result.arg3
        local failStr = result.arg4
        local role = map:getPlayer()
        local finalStr

        local item = Item:getOneItemByKey(itemId)
        if not item then
            print("没有物品资源 itemId = ",itemId)
            return
        end
        
        local operations = {}
        if environment.currRole ~= nil then
            operations = environment.currRole.operations
        end

        if MapIsEmpty(operations) == true then
            local currRoom = map:getRoomAttr(environment.currRoomId)
            operations = currRoom.operations
        end

        if MapIsEmpty(operations) == true then
            return
        end

        if role:getItemCount(itemId) >= 1 then
            finalStr = successStr
            role:addItemCount(itemId ,-1)
            PopText("消耗"..item.name.."X1")
        else
            finalStr = failStr
        end

        local operationList = string.split(finalStr, ";")
        if not MapIsEmpty(operationList) then
            for i, operationId in ipairs(operationList) do
                map:doOperationById(operationId, operations, environment)
            end
        end
    end,
    ["生成梦境商品列表"] = function(map, result, environment)
        --@RefType [src.app.models.DreamWorldModel.DreamSalesModel2#DreamSalesModel2]
        local DreamSalesModel2 = require("app.models.DreamWorldModel.DreamSalesModel2")
        local itemType = result.arg2
        local saleNum = result.arg3
        local salesType = result.arg4
        if string.find(saleNum,";") then
            local strList = string.split(saleNum,";")
            saleNum = math.random(tonumber(strList[1]),tonumber(strList[2]))
        else
            saleNum = tonumber(saleNum)
        end
        DreamSalesModel2:getSaleGoodsAndOpenLayer(map, environment.currRole,itemType,saleNum,salesType)
    end,
    ["周公之术"] = function(map, result, environment)
        local currRole = environment.currRole
        local name = currRole.name
        local TitleLayer = MainControllLayer:getLayer("TitleLayer")
        TitleLayer:setLayerTitleName("DreamTalentLayer",name)

        MainControllLayer:pushLayer("DreamTalentLayer")
        local DreamTalentLayer = MainControllLayer:getLayer("DreamTalentLayer")
        DreamTalentLayer:showLayer(map)
    end,
    ["房间转成空房"] = function (map,result,environment)
        local currRoomId =  map:getCurrRoomId()

        local room = map:getRoomMap()[currRoomId]

        if room == nil then
            error("当前房间id不存在："..currRoomId)
        end

        --@desc 事件类型
        local EVENT_TYPE = require("app.models.DreamWorldModel.DreamConst").RoomEventType
        room.roomType = EVENT_TYPE.EMPTY
        
        --@desc 修改成空房后需进入随机事件生成流程
        local DreamModel = require("app.models.DreamWorldModel.DreamModel")
        DreamModel:triggerEvent(map,currRoomId,1)
    end,
    ["梦境交谈"] = function (map,result,environment)
        local player = map:getPlayer()
        player.emotionMgr:talk({map = map,target = environment.currRole,roomId = environment.currRoomId})
    end,
    ["梦境瓶罐开启"] = function (map,result,environment)
        local player = map:getPlayer()
        player.emotionMgr:triggerOpenBoxEvent({map = map,roomId=environment.currRoomId,target = environment.currRole})
    end,
    ["梦境完成任务"] = function (map,result,environment)
        local currRoomId =  map:getCurrRoomId()
        local drSystem = User:getRole():getDreamSystem()
        drSystem:finishTask(map,currRoomId)
    end,
    ["梦境经验奖励"] = function (map,result,environment)
        local player = map:getPlayer()
        local floor = player.dreamWorld.cFloor
        local drSystem = User:getRole():getDreamSystem()
        local exp =  drSystem:getExpReward(floor)
        
        player:addAttr("exp",exp)
    end,

    ["梦境治疗"] = function (map,result,environment)
        local player = map:getPlayer()
        player:setAttr("qiPercent", 1)
        player:setAttr("qi", player:getCurrQiMax())
        player:setAttr("neili", player:getFinalAttr("neiliMax"))

        --@TODO 2020-07-27 18:16:52 临时刷新方法
        local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
        mapRoleLayer:refreshDreamRoleAttrUI()
    end,
    ["梦境武学奖励"] = function (map,result,environment)
        local role = map:getPlayer()
        local floor = role.dreamWorld.cFloor

        local context = {
            params = {
                rewardType = 4,
                rewardId = floor,
                roleAttr = {lv = role:getLv(), menpaiId = role:getFamilyId(), qiMax = role:getFinalAttr("qiMax"), neiliMax = role:getFinalAttr("neiliMax")}
            },
            role = role,
            map = map,
            callback = function(rewardData)
            end
        }
    
        User:getRole():getDreamSystem():getWebReward(context)
    end,
    ["梦境摆设开启"] = function (map,result,environment)
        local EmotionUtil = require("app.models.DreamWorldModel.EmotionStatus.EmotionUtil")

        local effectsInfos = EmotionUtil:getBoseEffects(environment.currRole.id)

        if #effectsInfos <= 0 then
            print("该NPC" .. environment.currRole.id .. "没有boseffect")
            return
        end

        local index = Helper:RandomByWeight(effectsInfos, "weight")

        local effect_info = effectsInfos[index]

        if effect_info.effects ~= nil and effect_info.effects ~= 0 then
            local effects = string.split(effect_info.effects, tostring(effect_info.effects))

            local DreamEffects = require("app.models.DreamWorldModel.DreamEffects")
            for i = 1, #effects do
                local effectId = effects[i]
                if tonumber(effectId) ~= nil and tonumber(effectId) ~= 0 then
                    DreamEffects:triggerEffect(effectId, {role = map:getPlayer(), map = map, roomId = environment.currRoomId})
                end
            end
        end
    end,
    ["输出清醒值提示文本"] = function(map,result,environment)
        local player = map:getPlayer()
        local sober = player:getAttr("sober")
        local text = ""
        if sober >= 76 then
            text = "四周平静而祥和，你的内心平静无比。"
        elseif sober >= 51 then
            text = "周围依旧平静无比，但你的内心却多了一丝不安。"
        elseif sober >= 26 then
            text = "周遭的一切变得不真实起来，你感觉到了一丝异样。"
        elseif sober >= 1 then
            text = "周围一切开始变得模糊，一股力量正将你从此抽离。"
        else
            text = "你已然清醒，却任处于梦中，清醒楼层为本次梦境最终闯荡楼层。"
        end

        RichPrint("main",text)
    end
}

--@desc: 进入地图
--@author:Liang SongQiang
--@time:2019-06-05 10:39:04
--@map: [src.app.models.EMap.EMap#EMap]
function DreamWorldModule:entryMap(map, currTime)
    if map:getMapType() ~= MAP_TYPE.DREAMMAP then
        return
    end

    local DreamModel = require("app.models.DreamWorldModel.DreamModel")

    DreamModel:enterMap(map)


	-- 初始化副本观察者
    map:initObserver()
    
    map:setSchedule(function (tag)
        local player = map:getPlayer()
        if player._buffManager then
            player._buffManager:update()
        end
    end)
end

return DreamWorldModule
00
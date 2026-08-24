--@desc 家园系统共用模块

--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local HomelandModule = class("HomelandModule", require("app.models.map.MapHandle.Modules.BaseModule"))

local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

--@RefType [src.app.models.HomelandModel.HomelandUtil#HomelandUtil]
local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")

--@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local MapInfo = require("app.models.map.MapInfo")
--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
HomelandModule.mapId = nil

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
HomelandModule.roomId = nil

--@desc 开启状态，默认开启
HomelandModule.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
HomelandModule.activityTime = 0

--@desc 子模块
HomelandModule.childModule = {
    --@desc 管家
    ["GuanJiaModule"] = "app.models.map.MapHandle.Modules.HomelandModule.GuanJiaModule",
    --@desc 仆人
    ["ServantModule"] = "app.models.map.MapHandle.Modules.HomelandModule.ServantModule",
    --@desc 门客
    ["RetainerModule"] = "app.models.map.MapHandle.Modules.HomelandModule.RetainerModule",
    --@desc 家具
    ["FurnitureModule"] = "app.models.map.MapHandle.Modules.HomelandModule.FurnitureModule",
    --@desc 副本偶遇
    ["MapOuYuModule"] = "app.models.map.MapHandle.Modules.HomelandModule.MapOuYuModule",
    --@desc 江湖怪客
    ["JiangHuGuaiKeModule"] = "app.models.map.MapHandle.Modules.HomelandModule.JiangHuGuaiKeModule",
    --@desc 情报人员
    ["ScoutModule"] = "app.models.map.MapHandle.Modules.HomelandModule.ScoutModule"
}

--@desc  家园公用条件结果
HomelandModule.doResult = {
    ["回城"] = function ( map, result, environment )
        if JIAYUAN_SYSTEM_IS_OPEN == false then
            PopText("该功能暂时未开放")
            return
        end
        local UserMapRelation = require("app.models.map.UserMapRelation")
        local toMapId = UserMapRelation:getFbIdByCityDir(map.cityIndex)

        local role = User:getRole()
        local toMap = role:getMapById(toMapId)

        if toMap == nil then
            return
        end
        if Map:getMapState(toMapId) ~= MAP_STATE.COMPLETE then
            local volumeId = Map:getVolumeIdByMapId(toMapId)
    
            local volumeInfo = Map:getVolumeByVolumeId(volumeId)
    
            local mapDefaultInfo = Map:getDefaultMapById(toMapId)
    
            PopText("请先通关“"..volumeInfo.name.."”"..mapDefaultInfo.title.."主线任务")

            return
        end


        local entryMapLayer = map.__MapLayer.ControllLayer:getLayer("EntryMapLayer")
        entryMapLayer:maxZ()
        entryMapLayer:show()

        local jumpToMap = function ()
            toMap._isComingIn = true
            toMap:setCallBackAndConnect(function()
                map.__MapLayer:setMap(toMap)
                -- FubenClient:comeIn(toMap.id, map.__MapLayer._currRoom.id, toMap:getRoomNameById(map.__MapLayer._currRoom.id), Helper:getOnlyId())
                map.__MapLayer:delayRefreshMap()
				entryMapLayer:hide(function()
					RichPrint("main", "HIC你身形一转，跃下马来，姿势十分优美。")
                end) -- 隐藏界面
                -- 释放地图动画层
				MainControllLayer:pushLayer("MapLayer")
                MainControllLayer:removeLayer("EntryMapLayer")
                MessageCenter:notify("EnterMap",{map=toMap})
            end)
        end

        --@desc 延迟保证动画播放
        map.__MapLayer:delayFunc(1,function ()
            jumpToMap()
            map.__MapLayer.TotalMapBtn_IsInit = false
        end)
        
    end,
    ["询址"] = function(map, result, environment)
        if JIAYUAN_SYSTEM_IS_OPEN == false then
            PopText("该功能暂时未开放")
            return
        end
    

        --@RefType [src.app.models.map.UserMapRelation#UserMapRelation]
        local UserMapRelation = require("app.models.map.UserMapRelation")
        --@RefType [src.app.models.map.UserMap#UserMap]
        local UserMap = require("app.models.map.UserMap")

        local mapIndex = switch(map.id,{
            fb10 = 1, -- 扬州
            fb15 = 2, -- 苏州
            fb20 = 3, --襄阳
            fb25 = 4, -- 长安
            default = 1,
        })

        local startIndex = switch(map.id,{
            fb10 = 1,
            fb15 = 5,
            fb20 = 9,
            fb25 = 13,
            default = 1,
        })


        local function goVillage(limit)
            PopupLayerController:showLayer("CheFuQianWangLayer",function ( layer )
                layer:setTitle("这位少侠，你想去哪")
                layer:setTotalList(startIndex,limit)
                layer:setBtnClickFunc(function (retList)
                    -- Helper:print_lua_table(retList)
                    UserMap:goVillageMap(map,retList,true)
                end)
                layer:showLayer()
            end)
        end

        local limitCache = {}
        -- local limitCache = UserMap:getCache("askCache"..map.id)
        -- local limitMax = {}
        -- if limitCache ~= 0 then
        --     limitMax = limitCache

        --     goVillage(limitCache)
        -- end


        HttpManagerEx:getLocationMax(mapIndex,function (status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then

                    limitCache = data.max
                    if MapIsEmpty(limitCache) then
                        limitCache = {startIndex,1,1,1}
                    elseif #limitCache ~= 4 then
                        PopText("数据获取失败！")
                        return true
                    end
                    --TODO 暂时不设置缓存
                    -- UserMap:setCache("askCache"..map.id,limitCache)
                    goVillage(limitCache)
                    return true
                else
                    PopText(errmsg)
                    print("errcode：",errcode)
                    return true
                end
            else
                PopText(errmsg)
                return true
            end

        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY)


	end,
    ["购房"] = function(map, result, environment)
        -- 参数1：购房
        -- 参数2：购房地点，NPC可能在公共副本内，此时策划自身指定。

        --@desc [src.app.models.role.Role#Role]
        local role = User:getRole()
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen() == false then
            return
        end

        local mapId = result.arg2 or map.id
        PopupLayerController:showLayer(
            "BuyHouseLayer",
            function(layer)
                layer:showLayer(environment.currRole.baseId,mapId)
            end
        )
    end,
    ["信差事务"] = function(map, result, environment)
        local currRoomId = environment.currRoomId

        local currRole = environment.currRole

        local affair_type = 3

        local limit = 5

        HttpManagerEx:getAffairList(affair_type,map.mid,limit,function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if not MapIsEmpty(data) then
                        PopupLayerController:showLayer(
                            "PostmanAffairLayer",
                            function(layer)
                                layer:setFinshHandleAllCallback(function ()
                                    map:removeRoomRole(currRoomId,currRole.id)
                                    map.__MapLayer:delayRefreshMap()
                                end)
                                layer:showLayer(data)
                            end
                        )
                    else
                        print("当前没有邀请函")
                    end 
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end, IS_SHOW_WAITING)

    end,
    
    ["银票票据兑换"] = function(map, result, environment)
        
        if not result.arg2 then 
            print("银票票据兑换条件出错")
            return 
        end
        print("银票票据"..result.arg2)
        local homemoneyType={[1]="homemoney200",[2]="homemoney1500",[3]="homemoney2500",[4]="homemoney5000"}
        if User:getRole():getItemCount(homemoneyType[result.arg2])<1 then 
            PopText("你没有这种票据！")
            return 
        else
            HttpManagerEx:exchangeYinPiao(
               result.arg2-1,
                "cheque",
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("获得银票 +"..tostring(data.get_yinpiao))
                             User:getRole():addItemCount(homemoneyType[result.arg2], -1)
                        else
                            print(errcode,errmsg)
                            PopText(errmsg)
                        end
                    else
                        print(errcode,errmsg)
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
       
    end,

    ["元宝兑换银票"] = function(map, result, environment)
        --@desc [src.app.models.role.Role#Role]
        local role = User:getRole()
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen() == false then
            return
        end

        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        local yinpiaoNum=0
        local yuanbaoNum=0
        HttpManagerEx:getYuanBao(function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    yuanbaoNum = data.yuanbao

                    HttpManagerEx:viewCurrencyByType("yinpiao", User:getRole():getCurrencyVersion(),function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                yinpiaoNum = data.number
                                local DialogGLayer = require("app.views.layer.DialogLayer.DialogGLayer")
                                local dialog = DialogGLayer:getInstance()
                                dialog:initPanel("")
                                dialog:setText_desc_1("是否使用元宝兑换"..tostring(50).."银票？")
                                local costYb = data.costYb
                                if costYb == nil then
                                    return
                                end
                                dialog:setText_desc_4(tostring(costYb).."元宝")
                                dialog:setPanel2_desc("YEL当前拥有元宝："..tostring(yuanbaoNum).."NOR","YEL当前拥有银票："..tostring(yinpiaoNum).."NOR")
                                dialog:SetVisible()
                                dialog:setButton2(
                                    function()
                                        --不刷新
                                    end
                                )
                                dialog:setButton1(
                                    function()
                                        HttpManagerEx:exchangeYinPiao(
                                            costYb,
                                            "yuanbao",
                                            function(status, errcode, errmsg, data)
                                                if status == 200 then
                                                    if errcode == 0 then
                                                        PopText("获得银票 +"..tostring(data.get_yinpiao))
                                                        dialog:setText_desc_4(data.next_yuanbao.."元宝")
                                                        print("costYb:"..costYb)
                                                        yuanbaoNum=yuanbaoNum-costYb
                                                        yinpiaoNum=yinpiaoNum+data.get_yinpiao
                                                        dialog:setPanel2_desc("YEL当前拥有元宝："..tostring(yuanbaoNum).."NOR","YEL当前拥有银票："..tostring(yinpiaoNum).."NOR")
                                                        costYb = data.next_yuanbao
                                                    else
                                                        print(errcode,errmsg)
                                                        PopText(errmsg)
                                                    end
                                                else
                                                    print(errcode,errmsg)
                                                    PopText(errmsg)
                                                end
                                            end,
                                            IS_SHOW_WAITING
                                        )
                                    end,1
                                )
                            else
                               PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end, IS_SHOW_WAITING)

                else
                   PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end, IS_SHOW_WAITING
        )
    end,
    ["回家"] = function(map, result, environment)
        if JIAYUAN_SYSTEM_IS_OPEN == false then
            PopText("该功能暂时未开放")
            return
        end
    
		local role = User:getRole()
		local maplayer = map.__MapLayer
        
        local mid = role:getHouseId()
		
		if mid == nil then
			RichPrint("main","YEL车夫：少侠，您还没有房子嘞，您要不去本城市侩那看看房屋？")
			return
		end

		local UserMap = require("app.models.map.UserMap")
		local useId = User:getUserId()
        UserMap:getUserMap(mid,useId,function(myMap,isSuccess)
            if isSuccess == false then
                return
            end
            
			myMap._isComingIn = true
			RichPrint("main", "HIC你进入大车，对车夫吆喝了几句。")
			RichPrint("main", "HIC车夫扬起手中鞭，吆喝道：看车！去"..tostring(myMap.name).."了。")

			local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
			entryMapLayer:maxZ()
			entryMapLayer:show()

			local titleLayer = MainControllLayer:getLayer("TitleLayer")
			local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
			mapRoleLayer:onResume()
			titleLayer:hide(true)

			maplayer:delayFunc(1,
			function(obj)
				myMap:setCallBackAndConnect(function()
					local mapLayer = MainControllLayer:getLayer("MapLayer")
					-- map:setMapForTask()	--主动任务，地图调整
					mapLayer:setMap(myMap)
                    -- FubenClient:comeIn(myMap.id, mapLayer._currRoom.id, myMap:getRoomNameById(mapLayer._currRoom.id), Helper:getOnlyId())
					entryMapLayer:hide(function()
						RichPrint("main", "HIC你身形一转，跃下马来，姿势十分优美。")
					end) -- 隐藏界面

					-- 释放地图动画层
					MainControllLayer:removeLayer("EntryMapLayer")						
                    MainControllLayer:pushLayer("MapLayer")
                    MessageCenter:notify("EnterMap",{map=myMap})
					-- titleLayer:changeTitleUI()
				end)
			end)
		end)
	end,
    ["购地"] = function(map, result, environment)
        -- 参数1：购地
        -- 参数2：购地额度限制
        -- 参数3：购地地点
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen() == false then
            return
        end

        PopupLayerController:showLayer(
            "BuyLandLayer",
            function(layer)
                layer:showLayer(map.id, environment.currRole.id)
            end
        )
    end,
    ["购地查询"] = function(map, result, environment)
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen() == false then
            return
        end
    
        -- 参数1：购地
        -- 参数2：购地额度限制
        -- 参数3：购地地点
        PopupLayerController:showLayer(
            "BiddingQueryLayer",
            function(layer)
                layer:showLayer()
            end
        )
    end,
    ["入侵战斗"] =  function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
		local player = User:getRole()
        local currRole = environment.currRole
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(currRole.name .. "要和你切磋。")
        dialog:setBack(false)
        dialog:setButton1(
            "切磋",
			function()
				Audio:playEffect("jiaoHu")
				local role = currRole
				local currMap = map

				role:initNpcAttr() -- NPC状态初始化
				map.mapLayer = map.__MapLayer
				map:afterFightWithQieCuo(
					player,
					role,
					function ( winTeamId )
						if winTeamId == 1 then

							RichPrint("main","你三拳两脚便将"..role.name .."打翻在地，"..role.name.."见势不好，立马溜走了。")
							local roles = map:getRoles()

							map.mapLayer:delayRefreshMap()
							map:removeRoomRole(environment.currRoomId,role.id)
                            map:doRoomConditionAndResult(environment.currRoomId)
                            
						elseif winTeamId == 2 then
							RichPrint("main","YEL"..role.name.."：就你这点功夫也敢闯门？还是回家练练再来吧。")
                            map.__MapLayer:quit(false)
						elseif winTeamId == 3 then
                            RichPrint("main","你灰溜溜的逃跑了。")
                            map.__MapLayer:quit(false)
						end
					end
				)

            end
		)
		dialog:setButton2()
		dialog:setWeChatVisible(false)
    end,
    ["家园开启"] = function (map, result, environment)
        --@desc 开启成功执行的条件结果集
        local successStr = result.arg2

        --@desc 开启失败执行的条件结果集
        local failStr = result.arg3

        HttpManagerEx:getHomeSwitch(
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then

                        if data.yinpiao and data.yinpiao > 0 then
                           PopText("你获得了"..data.yinpiao.."银票") 
                        end

                        if successStr then
                            map:doNoRoleResults(successStr,environment)
                        end
                        print("-----家园开启成功。")
                    else
                        if failStr then
                            map:doNoRoleResults(failStr,environment)
                        else
                            PopText(errmsg)
                        end
                    end
                else
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
    end,
    ["房契寻回"] = function (map, result, environment)
        --@RefType [src.app.models.HomelandModel.FangQiModel#FangQiModel]
        local FangQiModel = require("app.models.HomelandModel.FangQiModel")

        local currRole = environment.currRole

        FangQiModel:reapplyFangQi(currRole)
    end,
    ["地契寻回"] = function (map, result, environment)
        local DiQiModel = require("app.models.HomelandModel.DiQiModel")

        DiQiModel:reapplyDiQi(environment.currRole)
    end

}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/10 21:38:14
-- @params
-- @desc 测试接口
function HomelandModule:test()
    local role = User:getRole()
    local currMap = role:getMapById("fb01")
    self:changeMapInfo(currMap, {fb01_01c = {name = "测试的房子", dsc = "这是一个测试的房子,装饰的很豪华", mid = "45", uid = 3047214172}})
end

--@desc:
--@author:Liang SongQiang
--@time:2018-04-27 14:19:29
--@RefType [src.app.models.map.BaseMap#BaseMap]
function HomelandModule:entryMap(map, currTime)
    if PRINT_MODE == 1 then
        print("EntryMap(): id: " .. map.id, "name: " .. map.name)
    end

    self:entryCommonMap(map, currTime)
    self:getPostmanAffair(map, currTime)

    
    --@desc 更新屋外的跳转信息
    HomelandRoomUtil:updateDoorOutInfo(map)
    
    local FurnitureModel = require("app.models.HomelandModel.FurnitureModel.FurnitureModel")
    if map:getMapType() == MAP_TYPE.MYHOME then
        self:repairData(map)
        
        --@RefType 更新家园副本相关的标记
        HomelandUtil:updatePlayerFlag(map)
        
        --@desc 检查做饭数据
        FurnitureModel:checkDinnerData()

        if HomelandUtil:isJobTypeFromFlag("guanjia001") == true then
            local FangQiModel = require("app.models.HomelandModel.FangQiModel")
            FangQiModel:updateInfo({isDispose = true})
        end

        local roles = map:getRoles()
        for k,role in pairs(roles) do
            if role.type == "item" then
                --@desc 处理不再规定房间内的家具
                FurnitureModel:checkFurInRoomAction(role,map)
            elseif role.type == "role" and role.jobType ~= nil then
                HomelandRoleUtil:checkRoleInRoomAction(role,map)
            end
        end

    elseif map:getMapType() == MAP_TYPE.OTHERHOME then
        for k,item in pairs(map:getRoles()) do
            if item.type =="item" then
                FurnitureModel:entryOtherUserMap(map,item)
            end
        end
    end

    MapPVPRoles._needRefresh = true --需要刷新一下江湖人士列表
end

--@desc: 家园数据检查修复
--@author:Liang SongQiang
--@time:2018-06-08 14:05:53
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandModule:repairData(map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local mapRoles = map:getRoles()

    local fq = role:getHomelandAttr("fq")

    --@RefType [src.app.models.HomelandModel.FangQiModel#FangQiModel]
    local FangQiModel = require("app.models.HomelandModel.FangQiModel")

    local update_fq_list = {}

    if fq.houseName ~= map.name then
        update_fq_list["houseName"] = map.name
    end

    if tostring(map.location) ~= tostring(fq.location) then
        update_fq_list["location"] = map.location
    end

    if map.dpId ~= fq.dpId then
        if map.dpId == "" and fq.dpId ~= nil then
            -- FangQiModel:updateInfo({dpId = "nil"})
            update_fq_list["dpId"] = "nil"
        end
    end

    if map.fqId ~= fq.fqId then
        --@desc 房契模板ID不同步，扩建时导致
        update_fq_list["fqId"] = map.fqId
        local fqtemplate = FangQiModel:getFangQiTemplateById(map.fqId)
        update_fq_list["name"] = fqtemplate.name
    end

    if MapIsEmpty(update_fq_list) ~= nil then
        FangQiModel:updateInfo(update_fq_list)
    end

    do
        --@RefType [src.app.models.HomelandModel.FurnitureModel.StorageBox#StorageBox]
        local StorageBox = require("app.models.HomelandModel.FurnitureModel.StorageBox")
        local chuWuXiangCount = 0
        local prMaxIndex = 0

        --[[
                @desc
                门客是否在副本中出现的标记，
                需修复回档造成数据与服务器不一致导致副本中和家园都不存在或家园存在副本中也存在的情况
                策划需要产出副本门客需通知程序配置

                true:表示家园中存在
                false:表示家园中不存在
            ]]
        local retainerFlag = {
            fb16zm1 = false,
            fb19zm1 = false,
            fb32zm1 = false,
            fb301zm1 = false,
            fb304zm1 = false
        }

        for k, v in pairs(mapRoles) do
            if v.type == "item" and v.iType == "储物箱" then
                local addCount = StorageBox:getAddCapacity(v.itemId)

                print("===========================", v.itemId, addCount)

                chuWuXiangCount = chuWuXiangCount + addCount
            end

            if v.jobType ~= nil then
                if v.type == "role" and v.jobType and v.jobType ~= "guanjia001" then
                    local indexId = string.split(v.id, "_")[2]
                    if tonumber(indexId) > prMaxIndex then
                        prMaxIndex = tonumber(indexId)
                    end
                end

                --@desc 检查庄稼收成
                if v.jobType == "laonong001" then
                    local SeedModel = require("app.models.HomelandModel.SeedModel")
                    map:setSchedule(
                        function()
                            SeedModel:checkFarmerCanHarvest(map, v)
                        end,
                        1
                    )
                end

                if v.extra and v.extra.inheritFlag ~= nil and v.jobType and v.jobType == "menke001" then
                    if retainerFlag[v.extra.inheritFlag] ~= nil then
                        retainerFlag[v.extra.inheritFlag] = true
                    else
                        if Game:isTesting() == true then
                            assert(false, "该门客的flag没有配置，程序请添加：" .. v.extra.inheritFlag)
                        end
                    end
                end
            end

            for flag, isInHome in pairs(retainerFlag) do
                local flagValue = role:getInheritFlag(flag)
                if isInHome == true then
                    if flagValue == 0 then
                        role:setInheritFlag(flag, 1)
                    end
                elseif isInHome == false then
                    if flagValue == 1 then
                        role:setInheritFlag(flag, 0)
                    end
                end
            end
        end

        --@desc 预防仓库上限出错的问题。
        local ckLimit = role:getAttr("ckLimit")
        local baseCkLimit = role:getAttr("baseCkLimit")
        if baseCkLimit + chuWuXiangCount ~= tonumber(ckLimit) then
            role:setAttr("ckLimit", baseCkLimit + chuWuXiangCount)
        end

        if prMaxIndex > 0 then
            role:setHomelandAttr("prIdIndex", prMaxIndex)
        end
    end

    do
        --@RefType [src.app.models.HomelandModel.MapMeetModel.ShenShiTask#ShenShiTask]
        local ShenShiTask = require("app.models.HomelandModel.MapMeetModel.ShenShiTask")
        ShenShiTask:repairData(map)
    end

end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/10 17:45:29
-- @params map 当前副本
-- @params currTime 当前进入副本的时间
-- @desc 进入公共地图
local commonMapList = {
    fb301 = "fb10",
    fb302 = "fb15",
    fb303 = "fb20",
    fb304 = "fb25"
}
function HomelandModule:entryCommonMap(map, currTime)
    if not commonMapList[map.id] then
        return
    end

    local UserMap = require("app.models.map.UserMap")

    HttpManagerEx:getCommonFuben(
        commonMapList[map.id],
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self:changeMapInfo(map, data)
                return true
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/10 17:48:54
-- @params data 服务器返回的公共地图相关信息
-- @desc 根据服务器数据改造地图
function HomelandModule:changeMapInfo(map, data)
    local mapState = User:getRole():getMapState(map.id)
    mapState.isCompleted = true
    
    if MapIsEmpty(data) == true or MapIsEmpty(map) == true then
        if PRINT_MODE == 1 then
            error("服务器返回数据不正确 data = " .. type(data))
        end
        return
    end

    --[[
		data结构:
		{
            roomId = {name = "XXX的房子", userMapId = 1, userid = 123, desc = "这是XXX的豪宅,很有气派", roomId = fb301_01, }
            {"mid":68,"uid":3047215835,"name":"房契(豪宅)","desc":"这是一座豪宅，门阔屋高， 十分大气，内置仓库、书房、藏剑室、藏衣室、卧室、客房、调息室、炼器室、炼药房、闭关室等房间，内里宽敞大气，里间庭院，皆是上品。","entryRoom":"fb45_02",dpRoomId:"fb301;fb301_2"
		}
	]]
    if MapIsEmpty(data.usermap) == true then
        return
    end

    local UserMap = require("app.models.map.UserMap")
    local room
    local rooms = map:getRoomMap()
    for index, roomInfo in pairs(data.usermap) do
        -- local roomId = string.split(roomInfo.dpRoomId,";")[2]
        for mRoomId,mRoomInfo in pairs(rooms) do
            if mRoomInfo.flag and mRoomInfo.flag == roomInfo.dpId then
                room = Helper:tableCover(map:getRoomById(mRoomId), roomInfo)
                break
            end
        end
        -- 考虑是否存在不需要修改的情况
        -- UserMap:changeFullFigure(map, roomId, room.name)
    end

	for k, room in pairs(rooms) do
		if room.mapHide == 1 then
			-- add by XiaoZhiWei 2018/05/25 16:49:54 隐藏的副本不需要设置可见
		else
			room.haveBeenTo = true -- add by XiaoZhiWei 2018/05/18 20:58:38 全部都需要设置成已进入
		end
	end
end

function HomelandModule:createPostman(map)
    local roleId = "Postman"
    local roomId = ""
    local mapRoom = map:getRoomMap()
    for k,v in pairs(mapRoom) do
        if v.name == "大门" then
            roomId = k
        end
    end
    local role =
        Helper:tableCover(
        require("app.models.npc.BaseNpc"):create(),
        {
            id = roleId,
            sex = "野兽",
            type = "role",
            name = "信差",
            dsc = "他就是信差，背着一个半人高的竹篓，竹篓的外层和盖子用毡布和稻草扎成，整个人看起来风尘仆仆的。",
            canSee = true,
            canTalk = false,
            canKill = false,
            caozuo1 = 1,
            caozuoName1 = "对话",
            conditionAndResults = {
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "操作1"
                        }
                    },
                    results = {
                        {
                            arg1 = "信差事务",
                        }
                    }
                }
            }
        }
    )
    MapInfo:addMapRole(map, role)
    MapInfo:addRoleToRoom(map, roomId, roleId)

end

function HomelandModule:getPostmanAffair(map, currTime)
    if not map:isUserMap() then
        return
    end
    local mid = map.mid
    if mid == nil then
        return
    end

    local type = 3
    local limit = 5
    HttpManagerEx:getAffairList(type,mid,limit,function(status, errcode, errmsg, data)
    	if status == 200 then
    		if errcode == 0 then
                if not MapIsEmpty(data) then
                    map._isPostman = 1
                    self:createPostman(map)
                else
                    print("当前没有邀请函")
                end 
            else
                PopText(errmsg)
        	end
        else
        	PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

return HomelandModule0
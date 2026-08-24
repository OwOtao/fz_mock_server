local PingAnTown = {}


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/25 17:27:02
-- @params 
-- @desc 检查是否符合进入条件
function PingAnTown:checkIsCanComeIn(role, map)
	local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
	if RoleTaskControllor:clickMapLayer(role, function()end) == false then
		return false
    end
    
	-- add by XiaoZhiWei 2017/12/21 10:28:31 小镇开启条件
	do
		-- add by XiaoZhiWei 2018/02/10 17:45:45 ios老端没有偶遇系统 
		if ((Game:isOpenEncounter() == true or (Game:isOpenEncounter() == false and Game:getPlatformId() == "ios")) and  GetTime() - Helper:getDef(User:getRoleAttr("createTime"), GetTime()) > 3600 * 24) then
			-- add by XiaoZhiWei 2017/09/25 17:13:54 
			--[[
					是否通关开启偶遇;ouyuopen
					填0或者没填，通关方可开启，填1为，无需通关开启，填2为，通关后也不开启
			]]
			if ((map.ouyuopen == 0 or map.ouyuopen == nil) and  Map:getMapState(map.id) == MAP_STATE.COMPLETE) or map.ouyuopen == 1 then
				-- add by XiaoZhiWei 2017/06/16 17:05:38 只有该副本完成主线的情况下才能开启偶遇功能  离线模式不能链接服务器
			else
				if DEBUG_MODE == 1 then
					PopText("测试可见: 该副本没有通关或配置为不开启偶遇系统")
				end
				return false
			end
		elseif User:getRoleAttr("role_is_cheat") == true then
			DataBase:setDataByString("MapPvp", "OFFLINE")
			role:setFlag("PVP战斗状态", "离线模式")
			PopText("由于你的数据异常，已经自动切换成江湖隐者模式！")
			return false
		else
			-- if role:getFlag("PVP战斗状态") == "离线模式" and DEBUG_MODE ~= 1 then
			-- 	PopText("需设置为“江湖浪客”模式方可进入平安小镇")
			-- elseif Game:isOpenEncounter() == false then
			-- 	if DEBUG_MODE == 1 then
			-- 		PopText("调试模式可见: 该平台暂未开启偶遇系统")
			-- 	end
			-- else
			if  GetTime() - Helper:getDef(User:getRoleAttr("createTime"), GetTime()) < 3600 * 24 and DEBUG_MODE ~= 1 then
				PopText("角色创建一天之后，方可进入平安小镇")
			end
			return false
		end
	end
	return true
end


function PingAnTown:entryTown(node)
    local role = User:getRole()
    local map = role:getMapById("fb205")
    if MapIsEmpty(map) then
        PopText("没有找到该副本(fb205)")
        return
    end

    -- add by XiaoZhiWei 2018/05/25 17:29:51 检查是否能够进入
    if self:checkIsCanComeIn(role, map) == false then
        return
    end

    -- add by XiaoZhiWei 2017/12/21 10:28:56 副本冷却及刷新
    do
        local lastTime = role:getFlag(map.id)
        if DEBUG_MODE == 2 then
            if lastTime ~= 0 and GetTime() - lastTime < MAP_REFRESH_INTERVAL and map._isComingIn == nil then
                local remainTime = MAP_REFRESH_INTERVAL - GetTime() + lastTime
                local second = math.floor(remainTime % 60)
                local min = math.floor(remainTime / 60)

                PopText("副本冷却中，剩余冷却时间 "..tostring(min).." 分".. tostring(second).." 秒")
                return
            elseif map._isComingIn == true and lastTime ~= 0 and GetTime() - lastTime > MAP_REFRESH_INTERVAL then
                --  副本冷却时间到达，做刷新处理
                map = role:initMapById(map.id)
            end
        end
    end
    map._isComingIn = true
    MainControllLayer:getLayer("PrintLayer"):initRichText()
    -- 输出文本
    RichPrint("main", "你沿着碎石路向前走，没过多时便来到平安小镇，看着人来人往的热闹景象，心情也舒畅了不少。")
    -- RichPrint("main", "HIR你顺着这一路的大红牌坊，进到了平安小镇，发现这儿张灯结彩，好不热闹，心情也畅快了不少。")

    -- 播放进入地图动画
    local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
    entryMapLayer:maxZ()
    entryMapLayer:setCenterText("你近来感到无所事事，实在是无聊至极，\n于是决定到平安小镇上走一走，散散心情。")
    entryMapLayer:show()

    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
    mapRoleLayer:onResume()
    titleLayer:hide(true)

    -- 隐藏当前层
    -- self:fadeOut(0.3)

    entryMapLayer:delayFunc(1,
    function(obj)
        map:setCallBackAndConnect(function()

            local mapLayer = MainControllLayer:getLayer("MapLayer")
            -- map:setMapForTask()	--主动任务，地图调整
            mapLayer:setMap(map)

            FubenClient:comeIn(map.id, mapLayer._currRoom.id, map:getRoomNameById(mapLayer._currRoom.id), Helper:getOnlyId())
            entryMapLayer:hide(function()
                RichPrint("main", "HIC你身形一转，跃下马来，姿势十分优美。")
            end) -- 隐藏界面

            -- 释放地图动画层
            MainControllLayer:removeLayer("EntryMapLayer")
            
            MainControllLayer:pushLayer("MapLayer")
            -- titleLayer:changeTitleUI()
            MessageCenter:notify("EnterMap",{map=map})
        end)
    end)
end


return  PingAnTown0000
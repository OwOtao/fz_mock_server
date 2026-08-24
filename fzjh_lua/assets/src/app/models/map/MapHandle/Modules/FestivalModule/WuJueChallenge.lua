--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local WuJueChallenge = class("WuJueChallenge", require("app.models.map.MapHandle.Modules.BaseModule"))
local WuJueChallengeTool = require("app.models.Action.WuJueChallenge")
--@desc 开启状态，默认开启
WuJueChallenge.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
WuJueChallenge.activityTime = 0

WuJueChallenge.doResult = {
	["彩蛋副本跳转"] = function(map, result, environment)
        local role = Helper:getDef(map:getPlayer(),User:getRole())
		local fbId = result.arg2 -- 副本ID
		local roomId = result.arg3 -- 房间ID
		local text = result.arg4 -- 输出文本

        local isRefresh = false
		
        --@desc 如果为1强制刷新，不然遵循5分钟刷新规则。
        if result.arg5 == 1 then
            isRefresh = true
        end
		
		--控制是否输出跳转后房间的进入文本,默认为输出
		local isShowText = true 
		if result.arg6 == 1 then
			isShowText = false
		end
		
        local maplayer = map.__MapLayer
        
        --@RefType [src.app.models.role.Role#Role]
        local role = Helper:getDef(map:getPlayer(),User:getRole())
        
        local toMap = role:getMapById(fbId)

        if isRefresh == true then
            toMap = role:initMapById(fbId)
        else
            local lastTime = role:getFlag(fbId)
            if lastTime == 0 and toMap._isComingIn == nil then
                print("副本跳转 第一次进入副本 初始化 " .. toMap.id)
                toMap = role:initMapById(fbId)
            elseif (lastTime ~= 0 and GetTime() - lastTime >= MAP_REFRESH_INTERVAL) or toMap._isComingIn == nil then
                print("副本跳转 超过副本时间 或者游戏重新启动 初始化 " .. toMap.id)
                toMap = role:initMapById(fbId)
            else
                print("副本跳转 直接进入")
            end
        end

        WuJueChallengeTool:init(function()
            toMap:setCallBackAndConnect(
                function()
                    maplayer:setMap(toMap)
                    maplayer:replaceRoom(roomId,"center",isShowText)
                    toMap:setCurrRoomId(roomId)
                    maplayer:delayRefreshMap()
                    MessageCenter:notify("EnterMap",{map = toMap})
                    --@desc 跳转后执行房间的条件结果
                    local results =
                        toMap:doRoomConditionAndResult(
                        roomId,
                        {
                            operation = "进入房间",
                            roomId = roomId,
                            currRoomId = nil,
                            mapLayer = maplayer,
                            currRole = nil
                        }
                    )
                    if text then
                        RichPrint("main", text)
                    end
                end
            )
        end)
    end,

    ["五绝挑战"] = function (map, result, environment)
        if WuJueChallengeTool:checkIsActionTime() ~= true then
            PopText("活动已结束")
            return
        end
		if WuJueChallengeTool:checkCanChallenge() then
			local npc = environment.currRole

			local player = User:getRole()

			npc:initNpcAttr() -- NPC状态初始化

			local qiPercent = npc:getAttr("qiPercent")
			local qi = npc:getAttr("qi")
			local neili = npc:getAttr("neili")
			local weapon = npc.weapon

			local afterChallenge = function()
				npc:setAttr("qiPercent", qiPercent)
				npc:setAttr("neili", neili)
				npc:setAttr("qi", qi)
				npc.weapon = weapon 
			end

			map:afterFightWithQieCuo(player, npc, function(winTeamId)
				-- 战斗胜利条件结果
				if winTeamId == 1 then
					WuJueChallengeTool:afterChallenge(npc.id,function()
						npc.wuJueChallengeCount = npc.wuJueChallengeCount + 1
						afterChallenge()
						if result.arg2 then
							RichPrint("main","YEL"..npc.name.."："..result.arg2) 
						end
					end)
				else
					afterChallenge()
				end
			end)
		else
			PopText("本日挑战次数已经用完，请明天再次尝试")
		end
    end,
}

function WuJueChallenge:entryMap(map, currTime)
    if WuJueChallengeTool:checkIsActionMap(map.id) and WuJueChallengeTool:checkIsActionTime() then
		self:initWujueInfo(map)
	end
end

function WuJueChallenge:initWujueInfo(map)
	local npcList = WuJueChallengeTool:getNpcList()
	for __,npcId in ipairs(npcList) do
		local npc = map:getRole(npcId)
		if npc then
			npc.wuJueChallengeCount = WuJueChallengeTool:getNpcChallengeAllCount(npcId)
        end
	end
end

return WuJueChallenge
0000000
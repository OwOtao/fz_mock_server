local FightLayer = require("app.views.layer.FightLayer.FightLayer")

local ChallengeMapOldFightBuilder = {}

function ChallengeMapOldFightBuilder:startFight(map,player,npc,finishCallback,winCallback,loseCallback)
	local backgroundSceneId = map:getRoom(map:getCurrRoomId()).fightBackground

	FubenClient:setValue("isFighting", true)
    
	player:updateFightStatus("战斗中")
	
	FightLayer:startMapFight(
		{player},
		{npc},
    	function(fightLayer, eventType, ...)
			local fight = fightLayer:getFight()
			if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
				-- 暂停地图场景渲染
				map._mapLayer:pauseSelfAndChildren()
				map._mapLayer:setVisible(false)
				MainControllLayer:pauseUpdate()

				-- 战斗开始的时候设置下玩家
				local role1 = fight:getRoleByTeamIdAndInTeamId(1, 1)
				fight:setPlayer(role1)
			elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then
				PopText("开始战斗")
			elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH then
				local winTeamId, teams = ...

				FubenClient:setValue("isFighting", false)
				User:getRole():updateFightStatus("战斗结束")

				-- 隐藏按钮区域
				fightLayer:callUIMemFunc("setButtonAreaVisble", false)
				-- 显示战斗结束文本区域
				fightLayer:callUIMemFunc("showFightEndTextArea")

				if finishCallback then
					local fightPlayer = fight:getRoleByTeamIdAndInTeamId(1, 1)
					finishCallback(fightPlayer)
				end
				
				if winTeamId == 1 then
					fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "胜利")
					fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你战胜了" .. npc:getName() .. "。")
					if winCallback then
						winCallback()
					end
				elseif winTeamId == 2 then
					fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "失败")
					fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你被" .. npc:getName() .. "击败了。")
					if loseCallback then
						loseCallback()
					end
				end

				fightLayer:callUIMemFunc("setFightEndTextAreaReleaseFunc", function()
					map._mapLayer:delayRefreshMap()
					map._mapLayer:resumeSelfAndChildren()
					map._mapLayer:setVisible(true)
					MainControllLayer:resumeUpdate()

					fightLayer:hide(
						function()
							fightLayer:destroyInstance()
						end
					)
				end)
			elseif eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
				FubenClient:setValue("isFighting", false)
				player:updateFightStatus("战斗结束")
				-- 隐藏按钮区域
				fightLayer:callUIMemFunc("setButtonAreaVisble", false)
				-- 显示战斗结束文本区域
				fightLayer:callUIMemFunc("showFightEndTextArea")

				-- 设置战斗结束文本区域的文本
				fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "逃跑")
				fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, player.name .. "大喝一声：“三十六计，走为上计")

				fightLayer:callUIMemFunc(
					"setFightEndTextAreaReleaseFunc",
					function()
						if map._mapLayer then
							map._mapLayer:resumeSelfAndChildren()
							map._mapLayer:setVisible(true)
						end

						fightLayer:hide(
							function()
								fightLayer:destroyInstance()
								cleanTable(fightLayer)
							end
						)
					end
				)
			end
    	end,
		3,
		backgroundSceneId
	)
end

return ChallengeMapOldFightBuilder
00
local BiWu = require("app.models.BiWu.BiWu")
local BiWuStartUI = require("app.views.ui.BiWuUI.BiWuStartUI")


local BiWuStartLayer = class("BiWuStartLayer",cc.Layer)

function BiWuStartLayer:create()
	local p = BiWuStartLayer:new()
	p:init()
	return p
end

function BiWuStartLayer:init()
	local BiWuStartUI = BiWuStartUI:create()
	self._UI = BiWuStartUI
	BiWuStartUI:addTo(self)

	self:setButtonWuGuanGuanJia()
	self:setDesc()
	self:setButtonNotice()
	self:setButtonPeople()
	self:setButtonExit()
	self:setWeekRenQi()

	self._UI.Sprite_bottom:setVisible(false)

	self:schedule(function ()
		self:update()
	end, 1)

	--隐藏公告
	self:hideNotice()
end

function BiWuStartLayer:show()

	self:setWeekRenQi()

	-----如果是切换存档应该初始化输出框
	if BiWu:isChangFIleIsTrue("BiWuStartLayer") == true then
		self._UI:initRichText()
		BiWu._changeFileBiWuStartLayer = nil
	end
end
--武馆管家
function BiWuStartLayer:setButtonWuGuanGuanJia()
	self._UI:setButtonWuGuanGuanJia("武馆管家",function ()
		PopupLayerController:showLayer("BiWuGuanJiaLayer", function(layer)
			layer:show()
		end)
	end)
end
--动画
function BiWuStartLayer:runBackImage(func)
end

function BiWuStartLayer:showNotice()
	self._UI.Panel_attr:setVisible(true)
end

function BiWuStartLayer:hideNotice()
	---点击背景隐藏公告界面
	self._UI.Panel_attr.Panel_hide:setTouchEnabled(true)
	self._UI.Panel_attr.Panel_hide:releaseFunc(function ()
		self._UI.Panel_attr:setVisible(false)
	end)
end
--描述
function BiWuStartLayer:setDesc()
	local str = BiWu:getStartLayerDescText()
	self._UI:setDesc(str,nil)
end

--公告。历史榜单
function BiWuStartLayer:setButtonNotice(str,func)
	self._UI:setButtonNotice("公告",function()
		self:showNotice()
	end)
end

--人气榜
function BiWuStartLayer:setButtonPeople(str,func)
	self._UI:setButtonPeople("人气榜",function()
		PopupLayerController:showLayer("BiWuRankingLayer", function(layer)
			local mark ,list = {}
			-----从服务器获取list列表，数据
			BiWu:initRankings(2,function(mark,list)
				if mark == true then
					BiWu.list = "people"
					layer:show(BiWu.list)
					layer._UI:createListViews(2,list)
					layer:showPeopleTop()
				else
					if PRINT_MODE ==1 then
						PopText("从服务器获取比武排行数据失败")
					end
					return
				end
			end,function ()
				layer:hide()
			end)
		end)
	end)
end
--本周人气值
function BiWuStartLayer:setWeekRenQi(str)
	local fightAllData = BiWu:getfightAllData()
	-----使用最新的人气值 
	if fightAllData.renqi then 
		self._UI:setWeekRenQi(fightAllData.renqi)
	else
		if fightAllData and fightAllData.week_renqi then
			self._UI:setWeekRenQi(fightAllData.week_renqi)
		end
	end
end

--入场   从服务器获取剩余挑战次数  如果挑战一次，有没有刷新这个值
function BiWuStartLayer:setButtonExit()
	self._UI:setButtonExit("入场", function ()
		local role=User:getRole()  --防止长生诀恢复上限与打坐冲突bug
		if role:isInCurrState(ROLE_CURR_STATE_DAZUO) then  
			role:stopDaZuo()
		end
		----播放声音
		Audio:playMusic("biwu_leitai",true)
		local currTime = GetTime()
		-- 新增 当前时间超过23点 提示无法入场
		if Helper:date("%H", currTime) == "23" then

			self._UI:print("比武擂台暂时关闭 \n开放时间为0点-23点 \n大侠可早些歇息 多保重身体\n明日再来切磋武艺")
			return
		end

		--从服务器获取次数并保存到一个文件里fidAndtimes
		BiWu:getBiWuFightTimes(function()

			----------入场前处理上次没有结束的战斗
			BiWu:resolveUnnormalFightResult()

				---从本地获取数据，
			local fightAllData = BiWu:getfightAllData()
		

			MainControllLayer:pushLayer("BiWuMainLayer")
			local biWuMainLayer = MainControllLayer:getLayer("BiWuMainLayer")
			if fightAllData and fightAllData.left_times then
				biWuMainLayer:setTimesNumber(fightAllData.left_times)
			end
			biWuMainLayer:show()
			local str = BiWu:getstartLayerTextToMainLayerText()
			biWuMainLayer._UI:print(str)
			if fightAllData and fightAllData.fightExpired_time and currTime < fightAllData.fightExpired_time and fightAllData.result == "lose" then
				biWuMainLayer:setButtonStage("挑战")
			end
		end)
	end)
end
function BiWuStartLayer:printFightText()
end
--------------------------------------------------------------------------------------------
function BiWuStartLayer:update()
	self:printFightText()
end

function BiWuStartLayer:onResume()
	Audio:stopMusic()
	self:setWeekRenQi()
	self._UI.Panel_attr:setVisible(false)
end

Helper:classDefNodeGetInstance(BiWuStartLayer)

return  BiWuStartLayer
00000000
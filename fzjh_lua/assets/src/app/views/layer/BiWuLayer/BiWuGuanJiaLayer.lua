local BiWu = require("app.models.BiWu.BiWu")
local BiWuGuanJiaUI = require("app.views.ui.BiWuUI.BiWuGuanJiaUI")

local BiWuGuanJiaLayer = class("BiWuGuanJiaLayer",cc.Layer)

function BiWuGuanJiaLayer:create()
	local p = BiWuGuanJiaLayer:new()
	p:init()
	return p
end

function BiWuGuanJiaLayer:init()
	local BiWuGuanJiaUI = BiWuGuanJiaUI:create()
	self._UI = BiWuGuanJiaUI
	BiWuGuanJiaUI:addTo(self)

	self:setButtonTiaoZhan()
	self:setButtonTalk()
	self:setButtonpresent()
	self:setButtonRule()

	self._UI.Panel_attr_Rule.Panel_hide:releaseFunc(function ()
		PopupLayerController:hideLayer("BiWuGuanJiaLayer", function(layer)
			self._UI:hide()
			self._UI.Panel_attr_Rule:setVisible(false)
		end)
	end)
end





---------------------------------------------------------------------------------
--显示
function BiWuGuanJiaLayer:show()
	self._UI:show()
	self:setVisible(true)
	self._UI.Panel_attr_Rule:setVisible(false)
end

--交谈
function BiWuGuanJiaLayer:setButtonTalk()
	self._UI:setButtonTalk("交谈",function()
		Audio:playEffect("xiaoAnNiu")
		local strArry = BiWu:getwuGuanTalkText()
		local figure = math.random(1,#strArry)
		local startLayer = MainControllLayer:getLayer("BiWuStartLayer")
		startLayer._UI:print(strArry[figure])
		PopupLayerController:hideLayer("BiWuGuanJiaLayer", function(layer)
			self:hide()
		end)
	end)
end

--送礼
function BiWuGuanJiaLayer:setButtonpresent()
	self._UI:setButtonpresent("送礼",function ()
		Audio:playEffect("xiaoAnNiu")

		---r如果有挑战，则
		local currTime = GetTime()
		local fightAllData = BiWu:getfightAllData()
		if fightAllData and fightAllData.fightExpired_time and currTime < fightAllData.fightExpired_time and fightAllData.result == "lose" then
			BiWu:payYuanBao(function ()
				----使用元宝后，挑战消失，上台
				local fightAllData = BiWu:getfightAllData()
				fightAllData.fightExpired_time = nil
				

				local str = "武馆管家跑了进去，跳上擂台，身子出奇的轻快。“待老夫来会会你”，话才说完，人已经跃到台上，一把拎起$b,往台下一扔。$b并没有反应过来，一脸懵然。"
				if fightAllData.user and fightAllData.user.name then
					str = string.gsub(str,"$b",tostring(fightAllData.user.name))
				end

				local startLayer = MainControllLayer:getLayer("BiWuStartLayer")
				startLayer._UI:print(str)
				self:delayFunc(2,function ()
					startLayer._UI:print("下一位请入场！")
				end)
				----武馆管家赶走擂主的标识
				BiWu._guanJiaThrowOutBattle = true 
				BiWu:savefightAllData(fightAllData)
			end)
		else
			PopText("老夫不接受你的礼物")
		end
	end)
end




--挑战纪录
function BiWuGuanJiaLayer:setButtonTiaoZhan()
	self._UI:setButtonTiaoZhan(nil,function()
		Audio:playEffect("xiaoAnNiu")
		------如果没有记录，就不让进去
		do 
			local fightWeekAllData = BiWu:getfightWeekAllData()
			if fightWeekAllData.weekUserData and fightWeekAllData.weekUserData.list and #fightWeekAllData.weekUserData.list < 1 then
				PopText("你还没上台比武过！")
				return
			end
		end

		PopupLayerController:showLayer("BiWuRankingLayer", function(layer)
			local mark ,list = {}
			-----从服务器获取list列表，数据
			BiWu:initRankings(3,function(mark,list)
				if mark == true then
					BiWu.list = "week"
					layer:show(BiWu.list)
					layer._UI:createListViews(3,list)
					layer:showWeekTop(
						function ()
							PopupLayerController:hideLayer("BiWuGuanJiaLayer", function(layer)
								self:hide()
							end)
						end)

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

----规则
function BiWuGuanJiaLayer:setButtonRule()
	self._UI:setButtonRule(function ()
		Audio:playEffect("xiaoAnNiu")
		self._UI.Panel_attr_Rule:setVisible(true)
	end)
end

function BiWuGuanJiaLayer:setRoleShow()
	self._UI.Panel_attr_Rule:setVisible(true)	
end
Helper:classDefNodeGetInstance(BiWuGuanJiaLayer)
return  BiWuGuanJiaLayer


000000000
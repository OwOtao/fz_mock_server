local QiXiActionUI = require("app.views.layer.ActionLayer.QiXiFestival_2019.QiXiActionUI")

local QiXiLoveLetterLayer = class("QiXiLoveLetterLayer", LayerEx)

function QiXiLoveLetterLayer:create()
	local p = QiXiLoveLetterLayer:new()
	p:init()
	return p
end

function QiXiLoveLetterLayer:init()
	self._UI = QiXiActionUI:create()
	self._UI:addTo(self)

	self:setButton1()
end

function QiXiLoveLetterLayer:showLayer(actionId)
	self:maxZ()
	self._UI:initRichText()

	self:setActionTime(actionId)

end

function QiXiLoveLetterLayer:setActionTime(actionId)
	if actionId == nil then
		return
	end
	
	HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
        Helper:print_lua_table(data)
        if status == 200 and errcode == 0  then
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
				local startYear = tonumber(Helper:date("%Y", tonumber(data.start)))
        		local startMonth = tonumber(Helper:date("%m", tonumber(data.start)))
        		local startDay = tonumber(Helper:date("%d", tonumber(data.start)))
				local endYear =  tonumber(Helper:date("%Y", tonumber(data["end"])))
        		local endMonth = tonumber(Helper:date("%m", tonumber(data["end"])))
        		local endDay = tonumber(Helper:date("%d", tonumber(data["end"])))
				local detailStrList = data.detail_desc
				self._UI.Text_title:setString(data.name)
				HttpManagerEx:getQiXiTaskInFo("QiXiLoveLetter",function(status, errcode, errmsg, data1)
					Helper:print_lua_table(data1)
					print("status, errcode = ",status, errcode)
					if status == 200 and errcode == 0  then
						local text1 = "活动时间："..startYear.."年"..startMonth.."月"..startDay.."日 ~ "..endYear.."年"..endMonth.."月"..endDay.."日"
						local text2 = ""
						if not MapIsEmpty(detailStrList) then
							for i,desc in ipairs(detailStrList) do
								text2 = text2 .. i.."、".. desc .. "。\n"
							end
						end
						text2 = "活动内容：\n"..text2
						local text3 = "当前已完成次数："..data1.day_times.."/"..data1.day_limit
						-- full_days，全勤总天数，finish_days，完成全勤的天数
						local text4 = "全勤奖天数："..data1.finish_days.."/"..data1.full_days
						self:setRichText(text1.."\n \n"..text2)
						-- self:setButton2()
						self:setButton3(data1)
						self._UI:show()
					else
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING)
				
            end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end

function QiXiLoveLetterLayer:setRichText(text)
	self._UI:setRichText(text)
end

function QiXiLoveLetterLayer:hideLayer()
	self._UI:hide()
end

function QiXiLoveLetterLayer:setButton1()
	self._UI:setButton("Button_1", "关闭", function()
		self:hideLayer()
	end)
end

function QiXiLoveLetterLayer:setButton2()
	self._UI:setButton("Button_2", "查看榜单", function()
		PopupLayerController:showLayer("QiXiRankLayer", function(layer)
            layer:showLayer()
        end)
	end)
end

function QiXiLoveLetterLayer:setButton3(data1)
	local state = data1.state
	if state == 1 then --已领取
		self._UI:setButton("Button_3", "进行中", function()
			local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
			if RoleTaskControllor:clickMapLayer(User:getRole()) == false then
				return
			end
			local mapId = User:getRole():getInheritFlag("七夕情书随机副本id")
			if mapId == 0 or mapId == nil then
				--回档有可能导致 任务状态进行中，但没有随机副本，重新再随机
				mapId = self:getRandomMapId()
				if mapId == nil then
					return
				end
			end
			User:getRole():setInheritFlag("七夕情书随机副本id",mapId)
			self:hideLayer()
			MainControllLayer:pushLayer("SelectMapLayer")
			local selectMapLayer = MainControllLayer:getLayer("SelectMapLayer")

			selectMapLayer:setMap(mapId)
		end)
	else --未领取
		self._UI:setButton("Button_3", "领取任务", function()
			local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
			if RoleTaskControllor:clickMapLayer(User:getRole()) == false then
				return
			end
			local mapId = self:getRandomMapId()
			if mapId == nil then
				return
			end

			HttpManagerEx:TakeQiXiTask("QiXiLoveLetter",function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0  then
					self:hideLayer()
					MainControllLayer:pushLayer("SelectMapLayer")
					local selectMapLayer = MainControllLayer:getLayer("SelectMapLayer")

					User:getRole():setInheritFlag("七夕情书随机副本id",mapId)
					selectMapLayer:setMap(mapId)
					
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)

		end)
	end
end

function QiXiLoveLetterLayer:getRandomMapId()
	local resource =  require("script.others.monsterCreate").Sheet1

	local canRandomMapList = {} --已解锁能随机出来的副本id列表

	local roleId = "zhangsheng"

	for k,v in pairs(resource) do
		if v.monster == roleId then
			local mapstr = v.map
			local mapAndRoom = string.split(mapstr,";")

			for i,v in ipairs(mapAndRoom) do
				local mapAndRoomStr = v
				local mapAndRoomList = string.split(mapAndRoomStr,"|")
				local mapid = mapAndRoomList[1]
				local roomList = mapAndRoomList[2]
				
				local mapState = Map:getMapState(mapid)

				print("mapid = ",mapid,"roomList = ",roomList,"mapState = ",mapState)
				--已完成
				if mapState == MAP_STATE.COMPLETE then
					table.insert(canRandomMapList,mapid)
				end
			end

		end
	end 

	if MapIsEmpty(canRandomMapList) then
		PopText("您等级过低，无法参加该活动")
		return
	end

	local randomMapId = canRandomMapList[math.random(1,#canRandomMapList)]
	print("randomMapId = ",randomMapId)

	return randomMapId
end


Helper:classDefNodeGetInstance(QiXiLoveLetterLayer)
return QiXiLoveLetterLayer00000000000
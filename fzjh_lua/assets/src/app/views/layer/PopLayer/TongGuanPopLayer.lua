

local TongGuanPopLayer = class("TongGuanPopLayer", cc.Layer)

function TongGuanPopLayer:create()
	local p = TongGuanPopLayer:new()
	p:init()
	return p
end

function TongGuanPopLayer:init()
	self._round = require("Layer/PopUI/TongGuanPopUI.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUIByParent(self) -- 获得所有子节点

	self:initButton()
end

function TongGuanPopLayer:show(role, currRoom, type)
	assert((role and currRoom and type), "TongGuanPopLayer:show(role, currRoom, type) -> 数据异常，必须设置角色 当前房间 以及类型")
	self:setVisible(true)

	self:setPanel_selectMapDetailItemUI(role, currRoom, type)
	self.__Role = role
	self.__CurrRoom = currRoom
	if type == "离开" then
		self:setLeaveMainText()
	else
		self:setCompleteMainText()
	end
end

function TongGuanPopLayer:hide()
	PopupLayerController:hideLayer("TongGuanPopLayer", function(layer)
		self:setVisible(false)
	end)
end

function TongGuanPopLayer:setTitle(name)
	if not name then
		return
	end
	self.Text_33:setString(name)
end

function TongGuanPopLayer:setPanel_selectMapDetailItemUI(role, currRoom, type)
	assert((role and currRoom and type), "TongGuanPopLayer:setPanel_selectMapDetailItemUI(role, currRoom, type) -> 数据异常，必须设置角色以及当前地图")
	local map = User:getRole():getCurrMap()
	local item = self.Panel_selectMapDetailItemUI
	item.Text_title:setString(map.title)
	item.Text_name:setString(map.name)
	
	if map:getMapType() == MAP_TYPE.MYHOME or map:getMapType() == MAP_TYPE.OTHERHOME then
		item.Text_stateDsc:setString("已完成")
	else
		if type == "离开" then
			local mapState = role:getMapState(map.id)
			if mapState.isCompleted then
				item.Text_stateDsc:setString("已完成")
			else
				item.Text_stateDsc:setString("进行中")
			end
		elseif type == "通关" then
			item.Text_stateDsc:setString("过关")
		end
		item.Text_stateDsc:setString(map.desc)
	end

	-- itemUI:setTitle(map.title)
	-- itemUI:setName(map.name)

	-- local mapState = player:getMapState(map.id)
	-- if mapState.isCompleted then
	-- 	itemUI:setState("已完成")
	-- else
	-- 	itemUI:setState("未解锁")
	-- end
end

local LEVAVE_MONEY = 100

function TongGuanPopLayer:calcStepAndMoney(currRoom,map)
	if not currRoom then
		return
	end
	
	local player = assert(self.__Role)
	local map = User:getRole():getCurrMap()

	local defaultRoom = map:getDefaultRoomId()
	local mapType = map:getMapType()

	if currRoom.id == defaultRoom or mapType == MAP_TYPE.MYHOME or mapType == MAP_TYPE.OTHERHOME or mapType == MAP_TYPE.TEACHERMAP then
		return ""
	end
	-- local step = map:getStep(currRoom.id, defaultRoom)
	return "您强制离开副本，将消耗您"..tostring(LEVAVE_MONEY).."碎银"
end

function TongGuanPopLayer:setQuitFunc(name, func)	
	if not name then
		self.Button_quit:setVisible(false)
	else
		self.Button_quit:setVisible(true)
	end
	self.Button_quit.Text_34:setString(name)
	self.Button_quit:releaseFunc(
		function()
			self:hide(true)
			local map = assert(User:getRole():getCurrMap())
			if name == "离开" and self:calcStepAndMoney(self.__CurrRoom) ~= "" then
				local money = User:getRoleAttr("money")
				-- local defaultName = map:getRoomById(map:getRoomById()).name
				if tonumber(money) < LEVAVE_MONEY then
					-- PopText("你的盘缠不够你直接离开副本，请前往"..tostring(defaultName).."处离开")
					PopText("你的盘缠不够你直接离开副本，请前往出口处离开")
					return
				end
				User:addRoleAttr("money", -LEVAVE_MONEY)
			end			
			if func then
				func()
			end
		end)
end

function TongGuanPopLayer:setCompleteMainText(str)
	if not str then
		str = "你未获得任何奖励"	
	else
		str = "获得奖励： "..str
	end
	self.kuang_1.Text_main:setString(str)
end

function TongGuanPopLayer:setLeaveMainText()
	local Item = require("app.models.item.Item")
	local role = assert(self.__Role)
	local map = assert(User:getRole():getCurrMap())
	local list = map.__itemList
	local str = ""
	--删除数量为零或者为负数的物品
	if not MapIsEmpty(list) then 
		for k,v in pairs(list) do 
			if v <= 0 then 
				list[k] = nil
			end
		end
	end
	
	if not MapIsEmpty(list) then
		str = "您获得了"
		for k,v in pairs(list) do
			local itemAttr = Item:getOneItemByKey(k)
			if itemAttr then
				str = str.." "..tostring(itemAttr.name).." X "..tostring(v)
			end
		end
	else
		str = "您没有获得任何物品"
	end
	str = str.."\n\n"..self:calcStepAndMoney(self.__CurrRoom,map)
	self.kuang_1.Text_main:setString(str)
end

function TongGuanPopLayer:initButton()
	local button = self.Button_quit:clone()
	Helper:convertUI(button)
	self:addChild(button)
	button.Text_34:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	button:move(cc.p(540, 500))
	self.Button_2 = button
end

function TongGuanPopLayer:setButton2(name, func)
	if not name then
		self.Button_2:setVisible(false)
	else
		self.Button_2:setVisible(true)
	end
	self.Button_2.Text_34:setString(name)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
		self:hide()
	end)
end

Helper:classDefNodeGetInstance(TongGuanPopLayer)
return TongGuanPopLayer00
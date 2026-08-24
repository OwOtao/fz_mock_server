local SelectMapDetailItemUI = require("app.views.ui.MapUI.SelectMapDetailItemUI")
--@SuperType [src.app.views.base.LayerEx#LayerEx]
local SelectMapDetailLayer = class("SelectMapDetailLayer", LayerEx)

--@RefType [src.app.models.map.SelectMapModel#SelectMapModel]
local SelectMapModel = require("app.models.map.SelectMapModel")

function SelectMapDetailLayer:create()
	local p = SelectMapDetailLayer:new()
	p:init()
	return p
end

function SelectMapDetailLayer:init()
	self._UI = require("Layer/MapUI/SelectMapDetailUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUI(self)

	self:setShowAndHideAnimType(1)

	-- UI列表
	self.uiList = {}

	self:setBackButton()
end


function SelectMapDetailLayer:showLayer()
	self.mapVolume = SelectMapModel:getMapVolume()

	local mapId = SelectMapModel:getCurrMapId()

	local volumeId = SelectMapModel:getCurrVolumeId()

	self._handle=self:schedule(function()
		self:ShowResetTime()
	end, 1)
	
	local role = User:getRole()

	local m_volume = role:getAttr("m_volume")

	for i,vol in ipairs(self.mapVolume) do
		local isFold = true
		if volumeId == vol.id then
			isFold = false
			self.__currVolumeId = vol.id
			self.Text_title:setString(vol.name)
		end

		self.uiList[vol.id] = {isFold = isFold,isOpen = vol.isOpen}
	end

	self:setMapList()

	self:show()
end

function SelectMapDetailLayer:hideLayer()
	PopupLayerController:hideLayer("SelectMapDetailLayer", function(layer)
		if self._handle then
			self:unschedule(self._handle)
		end
		self:hide()
	end)
end

function SelectMapDetailLayer:setDetailClickCallback( callback)
	self.itemClickCallback = callback
end


function SelectMapDetailLayer:setMapList()
	self.ListView_map:removeAllItems()

	for i, v in ipairs(self.mapVolume) do
		self:createPanelVolume(v.id,v.name)
		if self.uiList[v.id] and self.uiList[v.id].isFold == false then
			local mapIdList = Map:getMapIdListInVolume(v.id)
			if not MapIsEmpty(mapIdList) then
				for i , mapId in ipairs(mapIdList) do
					self:createPanelChapter(mapId)
				end
			end
		end
	end
	self:ShowResetTime()
end

--创建券按钮
function SelectMapDetailLayer:createPanelVolume(index,name)
	local panel = self.Panel_Button:clone()
	Helper:convertUIByParent(panel)

	panel.Text_name:setString(name)

	panel.Image_37:setColor({r = 0, g = 0, b = 0})
	panel.Image_1:setColor({r = 255, g = 255, b = 255})

	if index == self.__currVolumeId and self.uiList[index].isFold == false then
		panel.Text_name:setTextColor({r = 255, g = 235, b = 57})
	end

	if self.uiList[index].isOpen == false then
		panel:setColor({r = 127, g = 127, b = 127})
		panel.Image_37:setColor({r = 127, g = 127, b = 127})
		panel.Image_1:setColor({r = 127, g = 127, b = 127})
		panel.Text_name:setColor({r = 127, g = 127, b = 127})
	end

	panel.isParent = true

	self.ListView_map:pushBackCustomItem(panel)

	panel:releaseFunc(function()
		if self.uiList[index].isOpen == false then
			PopText(name.."未解锁，请到商城购买")
			return
		end
		if self.uiList[index] and self.uiList[index].isFold == true then
			for k,v in pairs(self.uiList) do
				--让所有卷都折叠
				v.isFold = true
			end
		end

		self.Text_title:setString(name)

		self.__currVolumeId = index
		self.uiList[index].isFold = not self.uiList[index].isFold
		self:setMapList()
	end)
end

--创建章节按钮
function SelectMapDetailLayer:createPanelChapter(mapId)
	local player = User:getRole()

	local itemUI = SelectMapDetailItemUI:create()
	self.ListView_map:pushBackCustomItem(itemUI)

	local map = Map:getDefaultMapById(mapId)

	itemUI.isParent = false
	itemUI.mapId = mapId
	itemUI:setTitle(map.title)
	itemUI:setName(map.name)


	itemUI:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			itemUI:setHightLight(true)
		elseif eventType == ccui.TouchEventType.ended then
			itemUI:setHightLight(false)
			if self.itemClickCallback then
				self.itemClickCallback(map.id)
				self:hideLayer()
			end
			
		elseif eventType == ccui.TouchEventType.canceled then
			itemUI:setHightLight(false)
		end
	end)
end


-- 重置时间显示
function SelectMapDetailLayer:ShowResetTime()
	-- local Map = require("app.models.map.Map")
	--如果只是刷新时间text不起作用，因为text是在ListView列表里，只有刷新这个LIst才会有作用
	local items = self.ListView_map:getItems()
 	local currTime = GetTime()
 	local role = User:getRole()
 	local index = 0
	for i,itemUI in pairs(items) do
		if itemUI.isParent ~= true then
			local mapName = itemUI:getName()
			
			local mapId = itemUI.mapId
			
			local mapState = Map:getMapState(mapId)

			local mapVersion = Map:getMapVersionByMapId(mapId)

			if mapVersion == EDITOR_MAP_VERSION then
				itemUI:HideResetTime()
				if mapState == MAP_STATE.COMPLETE then
					itemUI:setState("已完成")
				elseif mapState == MAP_STATE.WORKING then
					itemUI:setState("正在进行")
				elseif mapState == MAP_STATE.UNLOCK then
					itemUI:setState("未解锁")
				end
			else
				-- 刷新itemUI:setState
				--刷新时间
				local time = Map:getMapRefreshTime(mapId)
				if time <= 0 then
					itemUI:HideResetTime()
					role:setFlag(mapName,"false")
					if mapState == MAP_STATE.COMPLETE then
						itemUI:setState("已完成")
					elseif mapState == MAP_STATE.WORKING then
						itemUI:setState("正在进行")
					elseif mapState == MAP_STATE.UNLOCK then
						itemUI:setState("未解锁")
					end
				else
					itemUI:HideState()
					itemUI:ShowResetTime()
					itemUI:setResetTime(SelectMapModel:getRefreshTimeDsc(time))
					itemUI:HideState()
				end
			end
			
		end
	end

end

--设置返回按钮
function SelectMapDetailLayer:setBackButton()
	self.Button_back_JH:releaseFunc(
		function()
			self:hide(true)
		end
		)
end

Helper:classDefNodeGetInstance(SelectMapDetailLayer)
return SelectMapDetailLayer000000
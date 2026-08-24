local Resource = require("app.Resource")
--
local Npc = require("app.models.npc.Npc")


local Item = require("app.models.item.Item")
local User = require("app.models.user.User")

local SkillConst = require("app.models.skill.SkillConst")

local MapRoleLayer = class("MapRoleLayer", require("app.views.base.BaseLayer"))

local prepareList = SkillConst.PrepareList


function MapRoleLayer:create()
	local p = MapRoleLayer:new()
	p:init()
	return p
end

function MapRoleLayer:init()
	self._UI = require("Layer/MapRoleUI/MapRoleUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUI(self)
	-- self:setItemDscSize()
	self:__initButtonTitle()
	self:__initDreamButtonTitle()
	self:statusButtonFunc(true)

	self.Panel_back:setTouchEnabled(false)

	-- 背景点击
	self.Panel_back:releaseFunc(function()
		self:hide()
	end)

	local role = self._role

	self._uiType = 0

	MessageCenter:addListener(
		"EnterMap",
		function(event)
			local map = event.map
			
			self._role = map:getPlayer()

			if map:getMapType() == MAP_TYPE.DREAMMAP then
				self.Panel_roleQi:move(cc.p(160, 1870))
				self.Panel_roleNeili:move(cc.p(160, 1845))
				self.Panel_roleQi:setVisible(true)
				self.Panel_roleNeili:setVisible(true)

				self._uiType = 1

				self:refreshDreamRoleAttrUI()
			elseif map:getMapType() == MAP_TYPE.FONDDREAMMAP then
				self.Panel_roleQi:move(cc.p(160, 1870))
				self.Panel_roleNeili:move(cc.p(160, 1845))
				self.Panel_roleQi:setVisible(true)
				self.Panel_roleNeili:setVisible(true)

				self._uiType = 2

				self:refreshDreamRoleAttrUI()
			else
				self.Panel_roleQi:setVisible(false)
				self.Panel_roleNeili:setVisible(false)
				self._uiType = 0
			end

		end,
		self
	)

	MessageCenter:addListener("EnterBiWu",function (event)
		self._role = User:getRole()
		self.Panel_roleQi:setVisible(false)
		self.Panel_roleNeili:setVisible(false)
		self._uiType = 0
	end,self)

	MessageCenter:addListener("LeaveMap",function ()
	end,self)

end

function MapRoleLayer:__showTitle()
	if self._uiType == 1 or self._uiType == 2 then
		self.Panel_title:setVisible(false)
		self.Panel_title_1:setVisible(true)	
	else
		self.Panel_title:setVisible(true)
		self.Panel_title_1:setVisible(false)	
	end
end

function MapRoleLayer:__hideTitle()
	self.Panel_title:setVisible(false)
	self.Panel_title_1:setVisible(false)	
end

function MapRoleLayer:__initButtonTitle()
	--状态
	self.Panel_attr_title:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(1)
	end)

	--背包
	self.Panel_bag_title:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(2)
	end)

	--技能
	self.Panel_skill_title:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(3)

	end)
end

function MapRoleLayer:__initDreamButtonTitle()
	--信息
	self.Panel_info_title_1:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(1)
	end)
	--属性
	self.Panel_attr_title_1:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(4)
	end)

	--背包
	self.Panel_bag_title_1:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(2)
	end)

	--技能
	self.Panel_skill_title_1:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(3)
	end)
end

function MapRoleLayer:refreshDreamRoleAttrUI()
	local role = self._role
	if role == nil then
		return
	end
	local qi, qiMax, neili, neiliMax = role:getNumAttr("qi"), Helper:mathFloor(role:getFinalAttr("qiMax")), role:getNumAttr("neili"), Helper:mathFloor(role:getFinalAttr("neiliMax"))
	self.LoadingBar_3:setPercent((qi / qiMax) * 100)
	self.LoadingBar_2:setPercent(Helper:mathFloor(role:getAttr("qiPercent") * 100))
	self.LoadingBar_5:setPercent(neili / neiliMax * 100)
end

function MapRoleLayer:onResume()
	self._role = Helper:getDef(self._role,User:getRole())
end

function MapRoleLayer:onPause()
end

function MapRoleLayer:show()
	self:setVisible(true)
	self.__IsInit = false
	self.Panel_leave:setVisible(true)
	self._role = Helper:getDef(self._role,User:getRole())
	
	local item = self.Panel_14
	item:setScale(1, 0.1)

	self:changeTab(0)
end

function MapRoleLayer:hide(isStopDaZuo)
	if self.__IsShow then
		local item = self.Panel_14
		local actionTag = item:getActionTagByName("move")
		self:changeTab(0)
		self:__hideTitle()	
		self.Panel_back:setTouchEnabled(false)
		item:setScale(1, 1)
		item:stopActionByTag(actionTag)
		local action = cc.Sequence:create(
		cc.ScaleTo:create(0.2, 1, 0.1),
		cc.CallFunc:create(function()
		end)
		)
		action:setTag(actionTag)
		item:runAction(action)
		self.Text_look_attr:setColor(cc.c3b(255, 255, 255))
		self.__IsShow = false
	end
	if isStopDaZuo == true then
	else
		self._role:setFlag("地图打坐", nil)
		self._role:stopDaZuo()
	end
end

function MapRoleLayer:hidePanelDreamRoleInfo()
	self.Text_info:setColor(cc.c3b(255, 255, 255))

	if self.__dreamMapRoleInfoPresenter then
		self.__dreamMapRoleInfoPresenter:hidePresenter()

		self.__dreamMapRoleInfoPresenter = nil
	end
end

function MapRoleLayer:hidePanelDreamRoleAttr()
	self.Text_attr_1:setColor(cc.c3b(255, 255, 255))

	if self.__dreamMapRoleAttrPresenter then
		self.__dreamMapRoleAttrPresenter:hidePresenter()

		self.__dreamMapRoleAttrPresenter = nil
	end
end

-- 切换表头时渲染控制
function MapRoleLayer:changeTab(num)
	if not num or type(num) ~= "number" then
		num = 1
	end
	self.__currNum = num 	-- 记录当前栏目
	local panel, text

	self:hidePanelAttr()
	self:hidePanelBag()
	self:hidePanelSkill()
	self:setWeight()

	self:hidePanelDreamRoleAttr()
	self:hidePanelDreamRoleInfo()

	switch(self._uiType,{
		[1] = function()
			if num == 1 then
				self:__showPanelDreamRoleInfo() 
			elseif num == 2 then
				self:showPanelBag()
			elseif num == 3 then
				self:showPanelSkill()
			elseif num == 4 then
				self:showPanelDreamRoleAttr()
			else
				return
			end
		end,
		[2] = function()
			if num == 1 then
				self:__showPanelDreamRoleInfo() 
			elseif num == 2 then
				self:showPanelBag()
			elseif num == 3 then
				self:showPanelSkill()
			elseif num == 4 then
				self:showPanelDreamRoleAttr()
			else
				return
			end
		end,
		default = function()
			if num == 1 then
				self:showPanelAttr()
			elseif num == 2 then
				self:showPanelBag()
			elseif num == 3 then
				self:showPanelSkill()
			else
				return
			end
		end
	})
end

--------------------------------------------------------------------------------------------------------------   人物属性
function MapRoleLayer:showPanelAttr()
	self.Text_attr:setColor(cc.c3b(242, 255, 32))

	if self.__mapRoleAttrPresenter == nil then
		local MapRoleAttrPresenter = require("app.presenters.MapRole.RoleAttr.MapRoleAttrPresenter"):create()
		self.__mapRoleAttrPresenter = MapRoleAttrPresenter
	end
	
	local MapRoleAttr = require("app.models.MapRole.MapRoleAttr"):create()
	MapRoleAttr:setRole(self._role)
	self.__mapRoleAttrPresenter:setInput(MapRoleAttr)
	self.__mapRoleAttrPresenter:setMainPresenter(self)
	self.__mapRoleAttrPresenter:showPresenter()
end

function MapRoleLayer:hidePanelAttr()
	self.Text_attr:setColor(cc.c3b(255, 255, 255))

	if self.__mapRoleAttrPresenter then
		self.__mapRoleAttrPresenter:hidePresenter()
	end
end

--梦境人物详情
function MapRoleLayer:__showPanelDreamRoleInfo()
	self.Text_info:setColor(cc.c3b(242, 255, 32))

	local DreamMapRoleInfo = require("app.models.MapRole.DreamMapRoleInfo"):create()
	DreamMapRoleInfo:setRole(self._role)

	local DreamMapRoleInfoPresenter

	if self._uiType == 1 then
		DreamMapRoleInfoPresenter = require("app.presenters.MapRole.RoleInfo.DreamMapRoleInfoPresenter"):create()
	elseif self._uiType == 2 then
		DreamMapRoleInfoPresenter = require("app.presenters.MapRole.RoleInfo.FoodDreamMapRoleInfoPresenter"):create()
	end

    DreamMapRoleInfoPresenter:setInput(DreamMapRoleInfo)
	DreamMapRoleInfoPresenter:showPresenter()

	self.__dreamMapRoleInfoPresenter = DreamMapRoleInfoPresenter
end

--梦境人物属性
function MapRoleLayer:showPanelDreamRoleAttr()
	self.Text_attr_1:setColor(cc.c3b(242, 255, 32))

	local iInput

	local DreamMapRoleAttrPresenter = require("app.presenters.MapRole.RoleAttr.DreamMapRoleAttrPresenter"):create()

	if self._uiType == 1 then
		iInput = require("app.models.MapRole.DreamMapRoleAttr"):create()
	elseif self._uiType == 2 then
		iInput = require("app.models.MapRole.FoodDreamMapRoleAttr"):create()
	end

    iInput:setRole(self._role)
    DreamMapRoleAttrPresenter:setInput(iInput)
	DreamMapRoleAttrPresenter:showPresenter()

	self.__dreamMapRoleAttrPresenter = DreamMapRoleAttrPresenter
end

--needRefresh 切换装备时需重新刷新排序
function MapRoleLayer:showPanelBag()
	local MapBag,MapRoleBagPresenter

	if self._uiType == 1 then
		self.Text_bag_1:setColor(cc.c3b(242, 255, 32))

		MapBag = require("app.models.bag.DreamMapBag"):create()

		MapRoleBagPresenter = require("app.presenters.MapRole.Bag.DreamMapRoleBagPresenter"):create()
	elseif self._uiType == 2 then
		self.Text_bag_1:setColor(cc.c3b(242, 255, 32))

		MapBag = require("app.models.bag.FondDreamMapBag"):create()

		MapRoleBagPresenter = require("app.presenters.MapRole.Bag.DreamMapRoleBagPresenter"):create()
	elseif MainControllLayer:getCurrLayer() == "BiWuMainLayer" then
		self.Text_bag:setColor(cc.c3b(242, 255, 32))

		MapBag = require("app.models.bag.BiWuMapBag"):create()

		MapRoleBagPresenter = require("app.presenters.MapRole.Bag.BiWuMapRoleBagPresenter"):create()
	else
		self.Text_bag:setColor(cc.c3b(242, 255, 32))

		MapBag = require("app.models.bag.MapBag"):create()
		
		MapRoleBagPresenter = require("app.presenters.MapRole.Bag.MapRoleBagPresenter"):create()
	end

    MapBag:setRole(self._role)
    MapRoleBagPresenter:setInput(MapBag)
    MapRoleBagPresenter:setMainPresenter(self)
	MapRoleBagPresenter:showPresenter()

	self.__mapBagPresenter = MapRoleBagPresenter
end


-- 装备一件物品
function MapRoleLayer:equipOneItem(desc)
	RichPrint("main", "WHT" .. tostring(desc))
	
	if self._biWuMainLayerMark == true then
		self._biWuMainLayer:print("WHT" .. tostring(desc))
	end

	if self.ControllLayer ~= nil then
		local currMap = User:getRole():getCurrMap()
		local mapLayer = self.ControllLayer:getLayer("MapLayer")
		--触发条件 使用背包物品 判断是否在可使用的房间内
		currMap:doRoomConditionAndResult(mapLayer._currRoom.id,
		{
			operation = "装备变更",
			useItemId = self.id,
			currRoomId = mapLayer._currRoom.id,
			mapLayer = mapLayer,
		})
	end
end

function MapRoleLayer:hidePanelBag()
	self.Text_bag:setColor(cc.c3b(255, 255, 255))
	self.Text_bag_1:setColor(cc.c3b(255, 255, 255))

	if self.__mapBagPresenter then
		self.__mapBagPresenter:hidePresenter()

		self.__mapBagPresenter = nil
	end
end

function MapRoleLayer:hideBagItemInfo()
	if self.__mapBagPresenter then
		self.__mapBagPresenter:hideItemInfoUI()
	end
end

--------------------------------------------------------------------------------------------------------------   人物技能
function MapRoleLayer:showPanelSkill()
	local skillInfoPresenter

	if self._uiType == 1 then
		self.Text_skill_1:setColor(cc.c3b(242, 255, 32))

		local dreamSkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.DreamSkillInfoViewModel"):create(self._role)

		skillInfoPresenter = require("app.presenters.Skill.SkillInfo.DreamMapSkillInfoPresenter"):create(self,dreamSkillInfoViewModel)
	elseif self._uiType == 2 then
		self.Text_skill_1:setColor(cc.c3b(242, 255, 32))

		local dreamSkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.DreamSkillInfoViewModel"):create(self._role)

		skillInfoPresenter = require("app.presenters.Skill.SkillInfo.FondDreamMapSkillInfoPresenter"):create(self,dreamSkillInfoViewModel)
	elseif MainControllLayer:getCurrLayer() == "BiWuMainLayer" then
		self.Text_skill:setColor(cc.c3b(242, 255, 32))

		local mapSkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.MapSkillInfoViewModel"):create(self._role)

		skillInfoPresenter = require("app.presenters.Skill.SkillInfo.BiWuMapSkillInfoPresenter"):create(self,mapSkillInfoViewModel)
	else
		self.Text_skill:setColor(cc.c3b(242, 255, 32))

		local mapSkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.MapSkillInfoViewModel"):create(self._role)

		skillInfoPresenter = require("app.presenters.Skill.SkillInfo.MapSkillInfoPresenter"):create(self,mapSkillInfoViewModel)
	end

	self.__mapSkillInfoPresenter = skillInfoPresenter

	self.__mapSkillInfoPresenter:showPresenter()
end

function MapRoleLayer:hideSkillInfo()
	if self.__mapSkillInfoPresenter then
		self.__mapSkillInfoPresenter:hideSkillInfoPopUI()
	end
end

function MapRoleLayer:hidePanelSkill()
	self.Text_skill:setColor(cc.c3b(255, 255, 255))

	self.Text_skill_1:setColor(cc.c3b(255, 255, 255))

	if self.__mapSkillInfoPresenter then
		self.__mapSkillInfoPresenter:hidePresenter()

		self.__mapSkillInfoPresenter = nil
	end
end

--------------------------------
function MapRoleLayer:setTitle(str)
	if not str then
		return
	end
	self.Text_title:setString(str)
end

function MapRoleLayer:setWeight()
	local role = self._role
	local items = role:getItems()
	local weight = role:getAttr("weight")
	if MapIsEmpty(items) then
		items = {}
	end

	if tonumber(weight) == nil or tonumber(weight) < 0 then
		weight = 0
	end

	if self._uiType == 1 or self._uiType == 2 then
		self.Text_weight_1:setString(tostring(#items) .. "/" .. tostring(weight))
	else
		self.Text_weight:setString(tostring(#items) .. "/" .. tostring(weight))
	end
end

function MapRoleLayer:statusButtonFunc(canClick,func, name)
	canClick = Helper:getDef(canClick, true)
	name = Helper:getDef(name, "HIW状态")
	self.Text_look_attr:setString(name)
	self.Panel_look_attr:releaseFunc(function()
		self:clickStatusButton(canClick,func)
	end)
end

function MapRoleLayer:clickStatusButton(canClick,func,titleIndex)
	self:hideSkillInfo()
	if canClick then

		do
			--@desc 人物状态检查
			--@RefType [app.models.map.UserStatusMapRelation#UserStatusMapRelation]
			local UserStatusMapRelation = require("app.models.map.UserStatusMapRelation")
			--@RefType [app.models.role.Role#Role]
			local role = self._role

			local currMap = Map:getCurrMap()

			if currMap ~= nil and MainControllLayer:getCurrLayer() == "MapLayer" then
				if UserStatusMapRelation:checkRoleStatus(currMap, role) == false then
					return
				end
			end
		end

		local item = self.Panel_14
		local actionTag = item:getActionTagByName("move")
		
		if not self.__IsShow then
			item:setScale(1, 0.1)
			item:stopActionByTag(actionTag)
			local action = cc.Sequence:create(
			cc.ScaleTo:create(0.2, 1, 1),
			cc.CallFunc:create(function()
				self:changeTab(titleIndex)
				self:__showTitle()
				self.Panel_back:setTouchEnabled(true)
			end)
			)
			action:setTag(actionTag)
			item:runAction(action)
			self.Text_look_attr:setColor(cc.c3b(242, 255, 32))
			self.__IsShow = true
		else
			self:changeTab(0)
			self:__hideTitle()
			self.Panel_back:setTouchEnabled(false)
			item:setScale(1, 1)
			item:stopActionByTag(actionTag)
			local action = cc.Sequence:create(
			cc.ScaleTo:create(0.2, 1, 0.1),
			cc.CallFunc:create(function()
			end)
			)
			action:setTag(actionTag)
			item:runAction(action)
			self.Text_look_attr:setColor(cc.c3b(255, 255, 255))
			self.__IsShow = false
			self._role:setFlag("地图打坐", nil)
			self._role:stopDaZuo()
		end
	end

	if func then
		func()
	end
end

----离开按钮功能的实现
function MapRoleLayer:exitButtonFunc(itype, func, name)
	name = Helper:getDef(name, "HIW离开")

	self.Text_leave:setString(name)
	self.Panel_leave:releaseFunc(function()
			self:hideSkillInfo()
			Audio:playEffect("fanHuiQuXiao")
			if itype == true then
				local function leaveFuben(mapLayer)
					if self:checkCanLeave() == false then
							return
					end
					if self.__IsShow then
						self:hide()
					end

					local mapType = mapLayer._currMap:getMapType()
					if mapType == MAP_TYPE.BASE then
						mapLayer:quit()
					else
						mapLayer:quit(false)
					end
					self:setVisible(false) -- 离开副本需要隐藏副本状态栏
				end
				local mapLayer = MainControllLayer:getLayer("MapLayer")
				if mapLayer._currMap:getMapType()==MAP_TYPE.MYHOME then 
					leaveFuben(mapLayer)
				elseif mapLayer._currMap:getMapType() == MAP_TYPE.DREAMMAP then
					PopupLayerController:showLayer("LeaveDreamMapLayer", function(layer)
						layer:maxZ()
						layer:showLayer()
						layer:setBtn1Func("关闭",function ()
							layer:hideLayer()
						end)
						layer:setBtn2Func("抽身离去",function()
							local drSystem = User:getRole():getDreamSystem()
							drSystem:mapComplete(mapLayer._currMap,function()
								leaveFuben(mapLayer)
								layer:hideLayer()
							end)
						end)
						local player = mapLayer._currMap:getPlayer()
						layer:setCurrfloorNum("("..player.dreamWorld.cFloor.."层)")
					end)
				elseif mapLayer._currMap:getMapType() == MAP_TYPE.FONDDREAMMAP then
					PopupLayerController:showLayer("ChessLeaveLayer", function(layer)
						layer:maxZ()
						layer:showLayer(function()
							local drSystem = User:getRole():getDreamSystem()
							drSystem:mapComplete(mapLayer._currMap,function()
								leaveFuben(mapLayer)
								layer:hideLayer()
							end)
						end)
						local player = mapLayer._currMap:getPlayer()
						layer:setCurrFloorText("当前楼层数："..player.dreamWorld.cFloor.."层")
					end)
				else
					PopupLayerController:showLayer("TongGuanPopLayer", function(layer)
						layer:maxZ()
						layer:show(User:getRole(), mapLayer._currRoom, "离开")
						-- layer.Panel_selectMapDetailItemUI.Text_stateDsc:setString("进行中")
						layer:setTitle("离开副本")
						layer:setQuitFunc("离开",function ()
							leaveFuben(mapLayer)
						end)
						layer:setButton2("取消")
					end)
				end
			end

			if func then
				func()
			end
	end)
end
function MapRoleLayer:getBiWuMainLayerMark(BiWuMainLayer, str)
	self._biWuMainLayer = BiWuMainLayer
	self._biWuMainLayerMark = str
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/22 12:26:45
-- @desc 判断是否能够离开副本
function MapRoleLayer:checkCanLeave()
	if DEBUG_MODE == 1 then
		return true
	end

	local mapLayer = MainControllLayer:getLayer("MapLayer")
	local currMap = User:getRole():getCurrMap()
	local canNotLeaveMapList =
	{
		["fb201"] = function() PopText("这里十分诡异，不可正常离开，请另寻他法。") end,
		["fb203"] = function() PopText("这里十分特殊，不可正常离开，请另寻他法。") end,
		["fb210"] = function() PopText("你无法离开这里。") end,
		["fb214"] = function() PopText("你无法离开这里。") end,
		["fb217"] = function() PopText("四处都是险峰、密林，看来只能寻人帮助离开。") end,
	}
	if canNotLeaveMapList[currMap.id] ~= nil then
		return false, canNotLeaveMapList[currMap.id]()
	else
		return true
	end
end
function MapRoleLayer:exitMap()
	local mapLayer = MainControllLayer:getLayer("MapLayer")
	self:changeTab(0)
	if self.__IsShow then
		self:hide()
	end
	self:setVisible(false)
	mapLayer:quit()
end

function MapRoleLayer:onRemove()
	MessageCenter:removeObjListener(self)
end

Helper:classDefNodeGetInstance(MapRoleLayer)
return MapRoleLayer0000000
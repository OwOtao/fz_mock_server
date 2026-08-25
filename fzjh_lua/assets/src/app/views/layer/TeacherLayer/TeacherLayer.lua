--@RefType [src.app.models.family.Family#Family]
local Family = require("app.models.family.Family")
local TeacherLayer = class("TeacherLayer", cc.Layer)
local Meridian = require("app.models.Meridian.Meridian")
local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")

function TeacherLayer:create()
	local p = TeacherLayer:new()
	p:init()
	return p
end

function TeacherLayer:init()
	self._UI = require("Layer/TeacherUI/TeacherUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点

	self:initMonitorPool()
	self:show()
	-- Helper:print_lua_table(family:getNpcList())
	self:setBottomEventList()

	self.Text_gongxian:setString("")

	self.Text_prestige:setString("")

	self:schedule(
    	function(ft)
    		if not self._time then
    			self._time = ft
    		else
    			self._time = ft + self._time
    		end
			self:isShow()
    		if self._time >= 0.5 then
    			self:update(ft)
    		end
    	end, 0)
end

function TeacherLayer:setTopDsc(dsc)
	dsc = Helper:getDef(dsc,"")
	self.Text_topDsc:setString(dsc)
end

function TeacherLayer:updateLayerSkinUI(skin_config)
	if skin_config.familytextpic then
		self.Image_Desc:loadTexture(skin_config.familytextpic, 0)
	else
		self.Image_Desc:loadTexture("Image/UI/TeacherUI/DescBack.png", 0)
	end

	self.__NpcBtnTextue = skin_config.Npcbtn or "Image/UI/TeacherUI/anniu01.png"

	self.__Basicbtnpic = skin_config.Basicbtnpic or "Image/UI/TeacherUI/anniu02.png"

	for ix = 1, 4 do
		local eventButton = self["Button_"..ix]
		if eventButton then
			eventButton:loadTextureNormal(self.__Basicbtnpic,0)
		end
	end

	if self._currButton then
		self._currButton:loadTextureNormal(self.__Basicbtnpic,0)
	end

	if skin_config.fontcolor then
		local fontColor = skin_config.fontcolor[1]
		local outlineColor = skin_config.fontcolor[2]
		self.Text_topDsc:setTextColor(cc.c4b(fontColor[1], fontColor[2], fontColor[3], 255))
		self.Text_topDsc:enableOutline(cc.c4b(outlineColor[1], outlineColor[2], outlineColor[3], 255), 5)
	else
		self.Text_topDsc:setTextColor(cc.c4b(0, 0, 0, 255))
		self.Text_topDsc:enableOutline(cc.c4b(79, 93, 93, 255), 5)
	end
end

function TeacherLayer:createNpcButton()
	local npcButton = Resource:getUIByName("Button_3")
	Helper:convertUI(npcButton)
	if self.__NpcBtnTextue then
		npcButton:loadTextureNormal(self.__NpcBtnTextue,0)
	end
	npcButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return npcButton
end

function TeacherLayer:setNpcList(npcList)
	self.Panel_centerNpcArea:removeAllChildren()

	local salesList = Teacher:getTeacherSalers()

	local areaSize = self.Panel_centerNpcArea:getContentSize()
	local countX, countY = 3, 4
	local edgeGapX, edgeGapY = 10, 10
	local itemSize = self:createNpcButton():getContentSize()
	local gapX = (areaSize.width - edgeGapX * 2 - countX * itemSize.width) / (countX - 1)
	local gapY = (areaSize.height - edgeGapY * 2 - countY * itemSize.height) / (countY - 1)
	local npcMax = #npcList
	local currNpcIndex = 1
	if self.showType=="highLevel" then 
		local POSITION_CONFIG = {
			{x = 280,y=325},
			{x = 800,y=325},
		}
		local list = {}
		for i=1,npcMax do
			local npcId = npcList[i]
			local currNpc = Npc:getNpc(npcId)
			if currNpc and User:getRoleAttr("teacherId") == currNpc:getAttr("id") or salesList[npcId] == true then
				table.insert( list,currNpc )
			end
		end


		for i=1,2 do
			local npc = list[i]
			if npc ~= nil then
				local npcButton = self:createNpcButton()
				local config  --师父摆前面 商人后面
				if User:getRoleAttr("teacherId") == npc:getAttr("id") then 
					config = POSITION_CONFIG[1]
				else
					config = POSITION_CONFIG[2]
				end
				npcButton:setPosition(config.x,config.y)	
				self.Panel_centerNpcArea:addChild(npcButton)
				npcButton.Text_buttonName:setString(npc:getName())
				npcButton:releaseFunc(
					function()
						PopupLayerController:showLayer("RoleObserveLayer", function(layer)
							layer:showLayer(npc,"TEACHER")
						end)
					end
					)
			end
		end
		--提示
		local helpImage = ccui.ImageView:create("Image/UI/AttrUI/help.png")
		helpImage:setPosition(itemSize.width/2+310,325)
		helpImage:setEnabled(true)
		helpImage:setTouchEnabled(true)
		self.Panel_centerNpcArea:addChild(helpImage)
		helpImage:releaseFunc(function()
			local desc=self:getfamilyInfo()
			helpImage:loadTexture("Image/UI/AttrUI/help2.png",0)
			local dialog = DialogELayer:getInstance()
			dialog:show(desc)
			dialog:setPanelBack(function()
				helpImage:loadTexture("Image/UI/AttrUI/help.png",0)
			end)
		end)
	elseif self.showType=="lowLevel" then
		local isMapTeacher =true  
		for i=1,npcMax do 
			if User:getRoleAttr("teacherId") == npcList[i] then 
				isMapTeacher=false
			end
		end
		if isMapTeacher then  --隐藏师傅替换规则 当前配置表与师傅同辈则直接替换为隐藏师傅 未找到同辈则替换配置表中辈分最低
			local isHaveSameLevel = false
			local maxLevelIndex = 1
			local minLevel,minLevelIndex = 0,1 --辈分最低师傅
			local roleFamilyLv = User:getRole():getFamilyLevel()
			for i=1,npcMax do 
				local npcName = npcList[i]
				local currShowNpc = Npc:getNpc(npcName)
				local npcFamilyLv = currShowNpc:getFamilyLevel()
				if npcFamilyLv == roleFamilyLv-1 then  --与师傅同辈则直接替换为隐藏师傅
					maxLevelIndex = i
					isHaveSameLevel = true
					break
				end
				if minLevel < npcFamilyLv then  --未找到同辈则替换辈分最低
					minLevel = npcFamilyLv
					minLevelIndex = i
				end
			end
			if isHaveSameLevel then
				npcList[maxLevelIndex] = User:getRoleAttr("teacherId")
			else
				npcList[minLevelIndex] = User:getRoleAttr("teacherId")
			end
		end
		for iy = 1,countY do  -- 横排遍历
			local xIndex = 1
			for ix = 1,npcMax do -- 竖排遍历
				if currNpcIndex > npcMax or xIndex > countX then  -- 当前NPC序号大于NPC列表长度 或者 竖排数量已满
					break
				end
				local npc = npcList[currNpcIndex]
				local currNpc = Npc:getNpc(npc)
				currNpcIndex = currNpcIndex + 1
	-- 		if currNpc and  ( currNpc.canSee == 1 or currNpc.canSee == true or User:getRoleAttr("teacherId") == currNpc:getAttr("id") ) then
				local npcButton = self:createNpcButton()
				self.Panel_centerNpcArea:addChild(npcButton)
				npcButton.Text_buttonName:setString(currNpc:getName())

				local x = edgeGapX + (xIndex - 1) * (gapX + itemSize.width) + itemSize.width / 2
				local y = edgeGapY + (iy - 1) * (gapY + itemSize.height) + itemSize.height / 2
				npcButton:move(x, areaSize.height - y)
				print("gapX:",x,"gapY:",areaSize.height - y)
				npcButton:releaseFunc(
					function()
						PopupLayerController:showLayer("RoleObserveLayer", function(layer)
							layer:showLayer(currNpc,"TEACHER")
						end)
					end
					)
				xIndex = xIndex + 1
			end
	-- 	end
			if currNpcIndex > npcMax then
				break
			end
		end
	end
end

function TeacherLayer:show()
end

function TeacherLayer:createEventButton()
	local eventButton = Resource:getUIByName("Button_2")
	Helper:convertUI(eventButton)
	eventButton:setVisible(true)
	-- eventButton.Text_buttonName:setTextColor(cc.c4b())
	if self.__Basicbtnpic then
		eventButton:loadTextureNormal(self.__Basicbtnpic,0)
	end
	eventButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return eventButton
end

function TeacherLayer:setBottomEventList()
	for ix = 1, 4 do
		local eventButton = self:createEventButton()
		self:addChild(eventButton)
		self["Button_"..ix] = eventButton
		do
			if ix == 1 then
				eventButton:move(cc.p(150, 670))
				eventButton:setVisible(true)
				eventButton.Text_buttonName:setString("师门\n建设")
				eventButton:releaseFunc(
				function()
					Audio:playEffect("daAnNiu")
					User:getRole():getTeacherBuildSystem():getTeacherBuildInFo(function(isOk,msg)
						if isOk then
							MainControllLayer:pushLayer("TeacherBuildMenuPresenter")
							local teacherBuildMenuPresenter = MainControllLayer:getLayer("TeacherBuildMenuPresenter")
							teacherBuildMenuPresenter:setRole(User:getRole())
							teacherBuildMenuPresenter:showLayer()
						else
							PopText(msg)
						end
					end)
				end)
			elseif ix == 2 then
				eventButton:move(cc.p(410, 670))
				eventButton.Text_buttonName:setString("技\n能")
				eventButton:releaseFunc(
				function()
					Audio:playEffect("daAnNiu")
					if PRINT_MODE == 1 then
						print("技能")
					end
					local teacher = Npc:getNpc(User:getRoleAttr("teacherId"))
					local cloneTeacher = Helper:tableCover(Role:create(),teacher)
					cloneTeacher:setAttr("skills",cloneTeacher:getAttr("tSkills"))
					MainControllLayer:pushLayer("SkillInfoLayer")
					local skillInfoLayer = MainControllLayer:getLayer("SkillInfoLayer")
					skillInfoLayer:setTeacherRole(cloneTeacher)
					skillInfoLayer:showMySelfSkillInfoPresenter()
				end)
			elseif ix == 3 then
				eventButton:move(cc.p(670, 670))
				eventButton.Text_buttonName:setString("任\n务")
				local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
				--等级低于100级或者江湖进度小于11,任务按钮不显示
				eventButton:setVisible(true)
				eventButton:releaseFunc(function()
					if TEACHER_GUAJI_TASK_IS_OPEN == true then
						PopupLayerController:showLayer("TeacherGuaJiTaskListLayer", function(layer)
							layer:showLayer()
						end)
					else
						PopText("该功能暂未开放,敬请期待")
					end
				end)
			else
				eventButton:move(cc.p(930, 670))
				eventButton.Text_buttonName:setString("磕\n头")
				eventButton:releaseFunc(
				function()
					Audio:playEffect("daAnNiu")
					local role=User:getRole()
					if role:checkTeacherIsChanged() == true then
						PopText("你找不到你的师傅了，请重新拜师再来。")
					else
						local teacher = assert(Npc:getNpc(role:getAttr("teacherId")))
						role:keTou(teacher)
					end
				end)
			end
		end
	end
end

function TeacherLayer:update()
	-- self:refreshUI()
	self.monitorPool:update()
	self:instantlyRefresh()
end

function TeacherLayer:isShow()
	if DEBUG_MODE == 1 then
		return true
	end
	local role = User:getRole()
	local skills = role:getSkills()
	if not skills or _G.next(skills) == nil then
		self.Button_2:setVisible(false)
	else
		self.Button_2:setVisible(true)
	end
end
function TeacherLayer:initMonitorPool()
	local role = User:getRole()
	self.monitorPool = MonitorPool:create("TeacherLayer")
	self.monitorPool:add(role, "exp", self, self.refreshUI)
	self.monitorPool:add(role, "pot", self, self.refreshUI)
	self.monitorPool:add(role.ignoreCloneTb._finalAttr, "touxian", self, self.refreshUI)
	-- self.monitorPool:add(role.ignoreCloneTb._finalAttr, "chenghao", self, self.refreshUI)
	-- self.monitorPool:add(role.ignoreCloneTb._finalAttr, "name", self, self.refreshUI)
end
function TeacherLayer:refreshUI()
	local exp = User:getRole():getNumAttr("exp")
	local pot = User:getRole():getNumAttr("pot")

	self.Text_exp:setString("『经验』"..exp)
	self.Text_pot:setString("『潜能』"..pot)
end

function TeacherLayer:instantlyRefresh()
	local role = User:getRole()
	if not (role:isInCurrState(ROLE_CURR_STATE_BIGUAN) or role:isInCurrState(ROLE_CURR_STATE_LIANGONG) or role:isInCurrState(ROLE_CURR_STATE_XIULIAN)) then
		self:removeButton()
	elseif not self._currButton then
		local button = self:createEventButton()
		self._currButton = button
		Helper:convertUI(button)
		self:addChild(button)
		button:move(cc.p(950,920))
		if role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
			local currSkillId = role:getFlag("当前武功")
			local roleSkill=role:getSkill(currSkillId)
			button.Text_buttonName:setString("正闭\n在关")
			button:releaseFunc(function()
					local BiGuanModel = require("app.models.BiGuan.BiGuanModel")

					--@RefType [src.app.models.BiGuan.BiGuanModel#BiGuanModel]
					local biGuan = BiGuanModel:create(currSkillId)

					PopupLayerController:showLayer("BiGuanLayer",function (layer)
						layer:showLayer(biGuan)
					end)

					self:removeButton()
				end)
		elseif role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
			local currSkillId = role:getLianGongSystem():getSkillId()
			local roleSkill=role:getSkill(currSkillId)
			button.Text_buttonName:setString("正练\n在功")
			button:releaseFunc(function()
				role:getXinShenSystem():getXinShenValue(function(ok, data)
					if ok then
						role:getLianGongSystem():getLianGongTiLi(function(ok,errmsg,tiliData)
							if ok then
								PopupLayerController:showLayer("LianGongDetailPresenter",function(layer)
									layer:setXinShen(data.curr)
									layer:setXinShenMax(data.max)
									layer:setTiLi(tiliData.currTiLi)
									layer:setTiLiMax(tiliData.maxTiLi)
									layer:setCallBack()
									layer:showLayer()
								end)
							else
								PopText(errmsg)
							end
						end)
					else
						local msg = data
						PopText(msg)
					end
				end)

				self:removeButton()
			end)
		elseif role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
			button.Text_buttonName:setString("正修\n在练")
			button:releaseFunc(function()
					role:getXinShenSystem():getXinShenValue(function(ok, data)
						if ok then
							role:getXiuLianSystem():getXiuLianTiLi(function(ok,errmsg,tiliData)
								if ok then
									PopupLayerController:showLayer("XiuLianDetailPresenter",function(layer)
										layer:setXinShen(data.curr)
										layer:setXinShenMax(data.max)
										layer:setTiLi(tiliData.currTiLi)
										layer:setTiLiMax(tiliData.maxTiLi)
										layer:showLayer()
										layer:setCallBack(nil)
									end)
								else
									PopText(errmsg)
								end
							end)
						else
							local msg = data
							PopText(msg)
						end
					end)
					self:removeButton()
				end)
		else
		end
	end
end

-- 移除闭关 练功 按钮
function TeacherLayer:removeButton()
	if self._currButton ~= nil then
		self:removeChild(self._currButton)
		self._currButton = nil
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 23:00:25
-- @desc 刷新贡献点数
function TeacherLayer:refreshGongXian(func)
    self:delayFunc(1 / 60, function()
        HttpManagerEx:getDevotePoint(function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.Text_gongxian:setString("『师门贡献点』"..tonumber(data.dev_point))
                if func then
                    func()
                end
            else
                PopText(errmsg)
            end
        end, IS_SHOW_WAITING)
    end)
end


-- @desc 刷新门派声望
function TeacherLayer:refreshPrestige(func)
    self:delayFunc(1 / 60, function()
        local FamilyPrestige=require("app.models.family.FamilyPrestige")
        FamilyPrestige:getUserPrestige(function(data)
            self.Text_prestige:setString("『"..User:getRole():getCHAttrName("prestige").."』"..tonumber(data.total))
            if func then
                func()
            end
        end)
    end)
end

function TeacherLayer:onResume()
	local role = User:getRole()
	if role:getLv()>=300 then 
		self.showType="highLevel"
	else
		self.showType="lowLevel"
	end
	self:removeButton()
	self:refreshTeacherTaskButton()
	self:refreshGongXian()
	self:refreshPrestige()
	self:setTitleNameAndTopDesc()
	local npcList={}
	if self.showType == "lowLevel" then
	 	npcList=Family:getLowLevelShowNpcList()
	elseif self.showType == "highLevel" then 
		local family = role:getFamily()
	 	npcList=family:getNpcList()
	end
	self:setNpcList(npcList)
end

function TeacherLayer:onPause()
	local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")
	TeacherGuaJiTaskUtil:unRegisterObserver("updateBtn")
end

function TeacherLayer:setTitleNameAndTopDesc()
	local fbId,roomId = Family:getFamilyMapIdAndRoomId()
	--@RefType [src.app.models.map.BaseMap#BaseMap]
	local map = Family:getFamilyMap()
	if MapIsEmpty(map) == false then
		local room = map:getRoomAttr(roomId)
		local currTitleName,currTopDsc,imageInfo
		local TitleLayer = MainControllLayer:getLayer("TitleLayer")
		if self.showType == "lowLevel" then
		 	currTitleName,imageInfo,currTopDsc=Family:getLowLevelShowTitleInfo()
		elseif self.showType == "highLevel" then 
			currTitleName = room.name
			currTopDsc = room.dsc
		end
		TitleLayer:setLayerTitleName("TeacherLayer",currTitleName)
		self:setTopDsc(currTopDsc)
	end
end

function TeacherLayer:refreshTeacherTaskButton()
	local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")
	local role = User:getRole()
	if role:getLv() >= 200 then
		self.Button_3:setVisible(true)
	else
		self.Button_3:setVisible(false)
	end

	if TeacherGuaJiTaskUtil:cheakTaskStateIsIdleOrSubMit() == true then
		self.Button_3:loadTextureNormal("Image/UI/MeridianUI/zhiliao.png",0)
	else
		self.Button_3:loadTextureNormal(self.__Basicbtnpic,0)
	end

	TeacherGuaJiTaskUtil:registerObserver("updateBtn",function ()
		if TeacherGuaJiTaskUtil:cheakTaskStateIsIdleOrSubMit() == true then
			self.Button_3:loadTextureNormal("Image/UI/MeridianUI/zhiliao.png",0)
		else
			self.Button_3:loadTextureNormal(self.__Basicbtnpic,0)
		end
	end)
end

function TeacherLayer:getfamilyInfo()
	local family = User:getRole():getFamily()
	local desc=family:getDsc()
	return desc
end
return TeacherLayer
00000000000000
local PlayerListLayer = class("PlayerListLayer", LayerEx)
local defaultRoleCount = 8 -- add by XiaoZhiWei 2018/05/02 14:42:54 副本默认角色数量
local rowRoleCount = 10 -- add by XiaoZhiWei 2017/06/07 15:50:58 每行角色数量
local pageRoleCount = 10 -- add by XiaoZhiWei 2017/06/23 19:37:51 每页角色数量


function PlayerListLayer:createInRunningScene()
	local layer = PlayerListLayer:getInstance()
	return layer
end

function PlayerListLayer:create()
	local p = PlayerListLayer:new()
	p:init()
	return p
end

function PlayerListLayer:init()
	self.UI = require("Layer/MapPVPUI/PlayerListUI.lua").create()['root']
	self.UI:addTo(self)
	Helper:convertUI(self) -- 获得所有子节点

	self:setLastButton()
	self:setNextButton()
	self:setPanelBack()
	self:setPageNum()
	self:hide()

	self:setShowAndHideAnimType(3)

	self:schedule( function()
		if MapPVPRoles._needRefresh == true and self.mapLayer ~= nil then
			self:setList()
			self:setTextDesc("当前共有"..tostring(#MapPVPRoles:getMapRoomRoleList(self.mapLayer._currMap.id , self.mapLayer._currRoom.id) + self.__npcNum).."人在此逗留，他们是：")
			self.mapLayer:refreshButtonJiangHu()
			MapPVPRoles._needRefresh = false
		end
	end, 0.1)

	self.__currPage = 1 -- add by XiaoZhiWei 2017/06/23 19:26:14 记录当前翻页页数
	self.__currRoomId = nil -- add by XiaoZhiWei 2017/08/10 12:06:48 记录当前房间Id,如果当前房间Id不最新房间ID不一致,则代表换了房间,需要把页数初始化为1, NPC数量初始化为0
	self.__npcNum = 0 -- add by XiaoZhiWei 2017/08/10 12:08:07 记录当前房间的Npc数量,Npc需要显示在江湖人士列表中
	self.__npcList = {} -- add by XiaoZhiWei 2017/08/14 16:00:35 缓存当前房间的npc列表,不包含玩家
	self.__userNum = 0
	self.__userList = {}
end

-- 滚动显示
function PlayerListLayer:showWithRollLeft(endFunc)
    local width = display.width
    self:lazyInit()
    -- self:resumeSelfAndChildren()-- 显示前恢复
    self:move(cc.p(width, 0))
	self:setVisible(true)
    self:resumeSelfAndChildren()-- 显示前恢复

    self:runActionWithName("showAndHide",
        cc.Sequence:create(
            cc.MoveTo:create(self._showAndHideAnimDuration, cc.p(0, 0)),
            cc.CallFunc:create(function()
		        self:delayFunc(0, function()
		            self:hideTouchSwallowLayer()
		            if endFunc then
		            	endFunc()
		           	end
		        end)
            end)))
end

-- 滚动隐藏
function PlayerListLayer:hideWithRollRight(endFunc)
	PopupLayerController:showLayer("PlayerListLayer", function(layer)
		local width = display.width
	    self:lazyInit()
	    -- self:resumeSelfAndChildren()-- 显示前恢复
	    self:runActionWithName("showAndHide",
	        cc.Sequence:create(
	            cc.MoveTo:create(self._showAndHideAnimDuration, cc.p(width, 0)),
	            cc.CallFunc:create(function()
		            self:hideTouchSwallowLayer()
		            self:setVisible(false)
		            self:pauseSelfAndChildren()-- 隐藏后暂停
		            if endFunc then
		            	endFunc()
		           	end
	            end)))
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/06 16:29:25
-- @desc  设置文本
function PlayerListLayer:setTextDesc(text)
	text = Helper:getDef(text, "")
	self.Text_desc:setString(text)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/06 16:44:10
-- @desc 创建头像框
function PlayerListLayer:createHeadPanel()
	local panel = self.Panel_head:clone()
	Helper:convertUI(panel)
	panel.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return panel
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/06 16:34:03
-- @desc 设置头像
function PlayerListLayer:setRoleHead(panel, role)
	if panel == nil or MapIsEmpty(role) == true then
		return 
	end
	role = Helper:tableCover(Role:create(), role)

	panel.Text_name:setString(role.name)
	local present = require("app.presenters.HeadView.HVRPresent"):create(panel.Image_head,panel.Image_di,role)
    present:showAnim()
	present:playEffect()
    
    local imagePath = role:getFaceInfoFrame()
	panel.Image_kuang:loadTexture(imagePath)

	-- 设置图片大小
    local texture = cc.TextureCache:getInstance():getTextureForKey(imagePath);
    panel.Image_kuang:setSize(texture:getContentSize())

    imagePath = role:getFaceFrame()
    panel.Image_frame:loadTexture(imagePath)

     -- 设置图片大小
    local texture = cc.TextureCache:getInstance():getTextureForKey(imagePath);
    panel.Image_frame:setSize(texture:getContentSize())

	panel:releaseFunc(function()
    	if User:getRole():getFlag("副本状态") == "忙碌" and role.needState ~= 1 then
    		PopText("您正在做别的事情，无法进行此操作。")
    		return
    	end
		PopupLayerController:showLayer("RoleObserveLayer", function(layer)
	    	-- add by XiaoZhiWei 2017/06/22 17:01:06 只需要从服务器获取一次
	    	if role.inheritRoleDsc == nil then
	        	local map = User:getRole():getCurrMap()
				local onlyId = Helper:getOnlyId()
	        	map:setCallBack(function(eventName, params)
	        		if eventName == "成功查看" then
	        			role.inheritRoleDsc = Helper:getDef(jsonpvp.decode(params.body), {}).inheritRoleDsc
		    			role.isFromWeb = true
						role.type = "role"
						role.canCompete = 1
	                    layer:showLayer(role,"MAP")
	        		end
	        	end)
	        	FubenClient:chakan(role.userid, onlyId)
	    	else
	            layer:showLayer(role,"MAP")
	    	end
		end)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/07 09:51:52
-- @desc 创建行列表
function PlayerListLayer:createListRow()
	return self.ListView_row:clone()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/07 09:33:02
-- @desc 设置行
function PlayerListLayer:setListRow(listView, roles)
	if listView == nil or MapIsEmpty(roles) == true then
		return
	end
	local index = 0
	for userid,role in pairs(roles) do
		local panel = listView:getItem(index)
		if panel == nil then
			panel = self:createHeadPanel()
			listView:pushBackCustomItem(panel)
		end
		self:setRoleHead(panel, role)
		index = index + 1
	end

	-- add by XiaoZhiWei 2017/06/07 11:00:31 删除多余的头像框
	for i=index, #listView:getItems() - 1 do
		listView:removeLastItem()
	end
end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/06/15 12:32:17
-- -- @desc 刷新列表数据
-- function PlayerListLayer:refreshList()
-- 	local currMp = User:getRole():getCurrMap()
-- 	currMp:setCallBack(function(eventName, params)
-- 		if eventName == "获取房间玩家成功" then
-- 			local body = Helper:getDef(jsonpvp.decode(params.body), {}) 
-- 			local users = Helper:getDef(body.users, {})
-- 			self:setTextDesc("当前共有 "..tostring(users.size - 1).." 人在此逗留,他们是:")
-- 			self:setList(users.list)
-- 		end
-- 	end)
-- end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/03 19:04:51
-- @desc 创建角色栏目
function PlayerListLayer:creaetPanelItem()
	local panel = self.Panel_item:clone()
	Helper:convertUI(panel)
	panel:setVisible(true)
	return panel
end

-- add by XiaoZhiWei 2017/07/04 14:19:31 转换战斗状态文本
local function changeFightStatusText(isFighting)
	if isFighting == true then
		return "战斗中"
	else
		return "闲逛中"
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/03 19:06:53
-- @desc 设置角色栏目数值
function PlayerListLayer:setPanelItem(item, roleData)
	if item == nil or MapIsEmpty(roleData) == true then
		return
	end
	roleData = Helper:tableCover(Role:create(), roleData)
	if roleData.isFromWeb == true then
		item.Text_menpai:setString(roleData:getFamilyName())
		item.Text_status:setString(changeFightStatusText(roleData.isFighting))
		item.Image_1:setVisible(true)
		item.Button_roleName:loadTextureNormal("Image/UI/MapUI/anniulan.png",0)
	else
		if roleData.btnImg then
			if roleData.btnImg == 1 then
				item.Button_roleName:loadTextureNormal("Image/UI/MapUI/jiajuanniu01.png", 0)
			elseif roleData.btnImg == 2 then
				item.Button_roleName:loadTextureNormal("Image/UI/MapUI/jiajuanniu02.png", 0)
			else
				item.Button_roleName:loadTextureNormal("Image/UI/MapUI/anniu05.png", 0)
			end
		else
			item.Button_roleName:loadTextureNormal("Image/UI/MapUI/anniu05.png", 0)
		end
		item.Text_menpai:setString("")
		item.Text_status:setString("")
		item.Image_1:setVisible(false)

	end
	item.Text_roleName:setString(roleData:getName())
	
	item:releaseFunc(function()
    	if User:getRole():getFlag("副本状态") == "忙碌" and roleData.needState ~= 1 then
    		PopText("您正在做别的事情，无法进行此操作。")
    		return
    	end
		PopupLayerController:showLayer("RoleObserveLayer", function(layer)
			-- add by XiaoZhiWei 2017/06/22 17:01:06 只需要从服务器获取一次
	    	if roleData.isFromWeb == true and roleData.inheritRoleDsc == nil then
	        	local map = User:getRole():getCurrMap()
				local onlyId = Helper:getOnlyId()
	        	map:setCallBack(function(eventName, params)
	        		if eventName == "成功查看" then
	        			roleData.inheritRoleDsc = Helper:getDef(jsonpvp.decode(params.body), {}).inheritRoleDsc
		    			roleData.isFromWeb = true
						roleData.type = "role"
						roleData.canCompete = 1
	                    layer:showLayer(roleData,"MAP")
	        		end
	        	end)
	        	FubenClient:chakan(roleData.userid, onlyId)
	    	else
				layer:showLayer(roleData,"MAP")
		    end
		end)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/14 15:21:37
-- @desc 获取NPC的数量
function PlayerListLayer:getMapNpcListAndNum()
	local result, retList = 0, {}
	if self.mapLayer == nil then
		return retList, result
	end

	local map = self.mapLayer._currMap
	retList, result = map:getCurrRoomNpcListAndNumber()
	local denglong = {}
	for i = #retList,1,-1 do 
		if retList[i].x_type == "denglong" then
			table.insert(denglong,retList[i])
			table.remove(retList,i)
		end
	end
	for k,v in ipairs(denglong) do 
		table.insert(retList,1,v)
	end


	self.__npcNum = Helper:getRange(result - defaultRoleCount, 0)  -- add by XiaoZhiWei 2017/08/14 15:44:20 记录NPC的数量
	self.__npcList = retList
	return retList, result
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/07 12:05:48
-- @desc  设置列表数据
function PlayerListLayer:setList(roleList)
	if self.mapLayer == nil then
		self:hide()
		return
	end

	if MapIsEmpty(roleList) == true then

		-- if self.__currPage > 1   then
		-- 	self.__currPage = 1
		self:setPageNum(self.__currPage)
		-- end
		
		roleList = self:getMapRoomUserAndNpcList(self.mapLayer._currMap.id , self.mapLayer._currRoom.id, (self.__currPage - 1) * pageRoleCount + 1, self.__currPage * pageRoleCount)

		-- roleList = Helper:getDef(roleList, {})
		-- local npcList, npcNumber = self:getMapNpcListAndNum()
		-- -- add by XiaoZhiWei 2017/08/14 17:35:02 NPC占据了多页数据的情况
		-- if npcNumber - defaultRoleCount  > self.__currPage * pageRoleCount then
		-- 	for i = math.max((self.__currPage - 1) * pageRoleCount, 1), self.__currPage  * pageRoleCount do
		-- 		table.insert(roleList, npcList[i + pageRoleCount])
		-- 	end
		-- else
  --           if npcNumber - defaultRoleCount <= pageRoleCount then
		-- 		-- body
		-- 		for i =  math.max((self.__currPage - 1) * pageRoleCount, 1),  npcNumber do
		-- 			table.insert(roleList, npcList[i + pageRoleCount])
					
		-- 		end
		-- 	-- elseif npcNumber - 8 ==  pageRoleCount then
  --  			--	for i =  math.max((self.__currPage - 1) * pageRoleCount, 1),  npcNumber  do
		-- 	-- 		table.insert(roleList, npcList[i+8])	
		-- 	-- 	end
		-- 		--return
		-- 	end
		
            
		-- 	-- add by XiaoZhiWei 2017/08/14 17:39:00 方便查看 4个参数
		-- 	local list = MapPVPRoles:getMapRoomRoleList(self.mapLayer._currMap.id,
		-- 												self.mapLayer._currRoom.id,
		-- 												math.max((self.__currPage - 1) * pageRoleCount - Helper:getRange(npcNumber - defaultRoleCount, 0), 1),
		-- 												self.__currPage * pageRoleCount - Helper:getRange(npcNumber - defaultRoleCount, 0))
		-- 	-- for i,v in ipairs(list) do
		-- 	-- 	if i <= (pageRoleCount - npcNumber) then
		-- 	-- 		-- body
		-- 	-- 		v.isFromWeb = true
		-- 	-- 		table.insert(roleList, v)
		-- 	-- 	end

		-- 	-- end
		-- 	if npcNumber - defaultRoleCount >= (self.__currPage - 1) * pageRoleCount and npcNumber - defaultRoleCount <= (self.__currPage  * pageRoleCount) then
		-- 		for i,role in ipairs(list) do
		-- 			if  i <= (self.__currPage  * pageRoleCount-(npcNumber - defaultRoleCount)) then
		-- 				role.isFromWeb = true
		-- 				table.insert(roleList, role)
						
		-- 			end	
		-- 		end
				
		-- 	elseif npcNumber - defaultRoleCount <  (self.__currPage - 1) * pageRoleCount then	
		-- 		local num =  ((self.__currPage  * pageRoleCount) - (npcNumber - defaultRoleCount))%10 + (math.ceil(((self.__currPage  * pageRoleCount) - (npcNumber - defaultRoleCount))/10 )-2)*10 
		-- 		-- PopText("num:"..math.ceil((toNum - npcNumber)/10 ))
		-- 		for i= num +1,#list do
		-- 			if i <= num+10 then
		
		-- 				list[i].isFromWeb = true
		-- 				table.insert(roleList, list[i])
		-- 			end
		-- 		end
		-- 	end
		-- end
		-- -- 列表页码自动更新
		-- if self.__currPage > 1  and #roleList == 0   then
			
		-- 	self.__currPage = self.__currPage -1
		-- 	if (npcNumber - defaultRoleCount)   > self.__currPage * pageRoleCount then
		-- 		for i = (self.__currPage - 1) * pageRoleCount, self.__currPage  * pageRoleCount do
		-- 			table.insert(roleList, npcList[i + pageRoleCount])
		-- 		end
		-- 	else
		-- 		if (npcNumber - defaultRoleCount)  < pageRoleCount then
		-- 			-- body
		-- 			for i =  math.max((self.__currPage - 1) * pageRoleCount, 1), npcNumber  do
		-- 				table.insert(roleList, npcList[i+pageRoleCount])
						
		-- 			end
		-- 		elseif (npcNumber - defaultRoleCount)  ==  pageRoleCount then
		-- 			for i =  math.max((self.__currPage - 1) * pageRoleCount, 1), npcNumber  do
		-- 				table.insert(roleList, npcList[i+pageRoleCount])	
		-- 			end
		-- 			return
		-- 		end
			
				
		-- 		-- add by XiaoZhiWei 2017/08/14 17:39:00 方便查看 4个参数
		-- 		local list = MapPVPRoles:getMapRoomRoleList(self.mapLayer._currMap.id,
		-- 													self.mapLayer._currRoom.id,
		-- 													math.max((self.__currPage - 1) * pageRoleCount - Helper:getRange(npcNumber - defaultRoleCount, 0), 1),
		-- 													self.__currPage * pageRoleCount - Helper:getRange(npcNumber - defaultRoleCount, 0))
		-- 		-- for i,v in ipairs(list) do
		-- 		-- 	if i <= (pageRoleCount - npcNumber) then
		-- 		-- 		-- body
		-- 		-- 		v.isFromWeb = true
		-- 		-- 		table.insert(roleList, v)
		-- 		-- 	end

		-- 		-- end

		-- 		if (npcNumber - defaultRoleCount)  >= (self.__currPage - 1) * pageRoleCount and  (npcNumber - defaultRoleCount)  <= (self.__currPage  * pageRoleCount) then
		-- 			for i,role in ipairs(list) do
		-- 				if  i <= (self.__currPage  * pageRoleCount-(npcNumber - defaultRoleCount)) then
		-- 					role.isFromWeb = true
		-- 					table.insert(roleList, role)
							
		-- 				end	
		-- 			end
					
		-- 		elseif (npcNumber - defaultRoleCount)  <  (self.__currPage - 1) * pageRoleCount then	
		-- 			local num =  ((self.__currPage  * pageRoleCount) - (npcNumber - defaultRoleCount))%10 + (math.ceil(((self.__currPage  * pageRoleCount) -  (npcNumber - defaultRoleCount))/10 )-2)*10 
		-- 			-- PopText("num:"..math.ceil((toNum - npcNumber)/10 ))
		-- 			for i= num +1,#list do
		-- 				if i <= num+10 then
			
		-- 					list[i].isFromWeb = true
		-- 					table.insert(roleList, list[i])
		-- 				end
		-- 			end
		-- 		end
				
		-- 	end

		-- 	-- roleList = self:getMapRoomUserAndNpcList(self.mapLayer._currMap.id , self.mapLayer._currRoom.id, 1, pageRoleCount)

		-- 	self:setPageNum(self.__currPage)
	        
		-- end
	end

	local index, listLength = 0, #self.ListView_list:getItems()
	local length = math.max(listLength, #roleList)
	for i=1,length do
		if i > #roleList then
			self.ListView_list:removeLastItem()
		else
			local role = roleList[i]
			-- add by XiaoZhiWei 2017/08/15 11:50:49 
			if role.isFromWeb == true then
				role.id = role.userid
			else
			end

			if role.userid == tostring(User:getUserId()) then
			else
				local item = self.ListView_list:getItem(i - 1)
				if item == nil then
					item = self:creaetPanelItem()
					self.ListView_list:pushBackCustomItem(item)
				else
				end
				self:setPanelItem(item, role)
				
			end
		end
		-- item不显示，让其插入在前面
		self.ListView_list:jumpToTop()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/23 19:26:36
-- @desc 设置上一页按钮
function PlayerListLayer:setLastButton()
	self.Button_last:releaseFunc(function()
		local num = self.__currPage
		if num <= 1 then
			PopText("已经是第一页")
		else
			num = num - 1
			--local list = MapPVPRoles:getMapRoomRoleList(self.mapLayer._currMap.id , self.mapLayer._currRoom.id, (num - 1) * pageRoleCount + 1, num * pageRoleCount)
			local list = self:getMapRoomUserAndNpcList(self.mapLayer._currMap.id , self.mapLayer._currRoom.id, (num - 1) * pageRoleCount + 1, num * pageRoleCount)
	
			if MapIsEmpty(list) == false then
				self:setPageNum(num)
				self:setList(list)
			end
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/23 19:27:03
-- @desc 设置下一页按钮
function PlayerListLayer:setNextButton()
	self.Button_next:releaseFunc(function()
		local num = self.__currPage
		if num >= 10 then
			PopText("已经是最后一页")
		else
			
			-- local list = MapPVPRoles:getMapRoomRoleList(self.mapLayer._currMap.id , self.mapLayer._currRoom.id, num * pageRoleCount + 1, (num + 1) * pageRoleCount)
			local list = self:getMapRoomUserAndNpcList(self.mapLayer._currMap.id , self.mapLayer._currRoom.id, num * pageRoleCount + 1, (num + 1) * pageRoleCount)
			num = num + 1
			if MapIsEmpty(list) == false then
				self:setPageNum(num)
				self:setList(list)
			end
		
		end
	end)
end

-- 将MapPVPRoles中获得到的userlist和PlayerListLayer获得的npclist整合成一个新的列表list
function PlayerListLayer:getMapRoomUserAndNpcList(mapId, roomId, from, to)
	local roleList = {}
	-- local num = self.__currPage
	local userList = MapPVPRoles:getMapRoomRoleList(mapId, roomId)
	local npcList, npcNumber = self:getMapNpcListAndNum()

	local fromNum, toNum = 1,#userList
	if type(from) ~= "number" then
	elseif type(to) ~= "number" then
		fromNum = 1
		toNum = from
	else
		fromNum = from
		toNum = to
	end
	local extraCount = #userList + npcNumber - defaultRoleCount
	if extraCount <= 0 or extraCount < fromNum then
		return roleList
	end
	--在roleList中插入npc
	for i,role in ipairs(npcList) do
		if i >= fromNum + defaultRoleCount and i <= toNum + defaultRoleCount then
			table.insert(roleList, npcList[i])
		end
		if i == toNum + defaultRoleCount or #roleList == (toNum - fromNum + 1) then
			return roleList
		end
	end
	--在roleList中已经插入npc满足条件下，插入玩家role
	if npcNumber - defaultRoleCount >= fromNum and npcNumber - defaultRoleCount  <= toNum then
		for i,role in ipairs(userList) do
			if  i <= toNum - (npcNumber - defaultRoleCount)  then
				role.isFromWeb = true
				table.insert(roleList, role)
			end	
		end
		
	elseif npcNumber -defaultRoleCount < fromNum and #userList ~= 0 then	
		local num =  (toNum - (npcNumber - defaultRoleCount))%10 + fromNum-- + (math.ceil((toNum - (npcNumber - defaultRoleCount))/10 )-1)*10 
		-- PopText("num:"..math.ceil((toNum - npcNumber)/10 ))
		for i= num,#userList do
			if i <= num+10 then

				userList[i].isFromWeb = true
				table.insert(roleList, userList[i])
			end
		end
	end
	return roleList

end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/23 19:27:16
-- @desc 设置页数
function PlayerListLayer:setPageNum(num)
	num = Helper:getDef(num, 1)
	self.Text_page:setString(num .. "/10")
	self.__currPage = num
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/07 12:06:01
-- @desc 设置背景点击
function PlayerListLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:hideWithRollRight()
	end)
end


Helper:classDefNodeGetInstance(PlayerListLayer)
return PlayerListLayer
000000000000000
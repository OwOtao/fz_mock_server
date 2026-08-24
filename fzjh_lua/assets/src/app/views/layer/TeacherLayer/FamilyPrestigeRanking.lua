--
-- Author: TanQinJian
-- Date: 2019-05-18 10:04:45
--
-- 声望排行榜
local FamilyPrestigeRanking = class("FamilyPrestigeRanking", cc.Layer)


local SortList = {}

function FamilyPrestigeRanking:create()
	local p = FamilyPrestigeRanking:new()
	p:init()
	return p
end

function FamilyPrestigeRanking:init()
	local UI = require("Layer/ActionUI/FlyKiteRankListUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self.rankData = nil
	self.flag = 13 --13 类别

	self:setVisible(false)
	self:setButton()

	self.Button_pageUp:setPositionY(150)
	self.Button_pageDown:setPositionY(150)
	self.Text_page:setPositionY(150)
end

function FamilyPrestigeRanking:initUI()
	local header = self.rankData.header
	local title = self.rankData.title
	self.Panel_category.Text_Title:setString(title)
	self.Button_Reward_Preview:setVisible(false)
	self.Text_RenQi:setString(header[3])
	self.Text_RenQi:setPositionX(800)
end

function FamilyPrestigeRanking:initRank(tab)
	local table = tab["body"]["list"]
	local function gradeCast(num)
		local tab = {"壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾"}
		if tab[num] == nil then
			if type(num) == "string" then
				return num
			end
			if num > 9999 then
				return "9999+"
			end
			return tostring(num)
		end
		return tab[num]
	end

	local function setTextSizeFont(panel, index)
		if type(index) == "string" then
			panel.Text_mingci:setFontSize(48)
		else 
			if index <= 3 then
				panel.Text_mingci:setFontSize(72)
			elseif index <= 10 then
				panel.Text_mingci:setFontSize(60)
			elseif string.len(index) >=4 then
				panel.Text_mingci:setFontSize(48)
			else
				panel.Text_mingci:setFontSize(48)
			end
		end
		
	end

	self.ListView_ranking:removeAllItems()
	if table ~= nil then
		for i,v in ipairs(table) do
			local panel = self:createPanel(v)
			if panel == nil then
				print("createPanel() == nil")
			end
			local sort = i + (self.pageNum - 1) * 10
			panel.Text_mingci:setString(gradeCast(sort))
			setTextSizeFont(panel,sort)
			self.ListView_ranking:pushBackCustomItem(panel)
		end
		if MapIsEmpty(self.rankData) == true or MapIsEmpty(self.rankData.body) == true  then
			self.Panel_attr_preview.Button_Reward:setEnabled(true)
		else
			if self.rankData["body"].is_get == nil or  self.rankData["body"].is_get == "Y" then
				self.Panel_attr_preview.Button_Reward:setEnabled(false)
			elseif self.rankData["body"].is_get == "N" then
				self.Panel_attr_preview.Button_Reward:setEnabled(true)
			else
				self.Panel_attr_preview.Button_Reward:setEnabled(true)
			end
		end
	end

	local mine = tab["body"]["mine"]
	if mine ~= nil and MapIsEmpty(mine) ~= true then
		local panel = self:createPanel(mine)
		local sort = mine.sort
		panel.Text_mingci:setString(gradeCast(sort))
		setTextSizeFont(panel,sort)
		self.ListView_ranking:pushBackCustomItem(panel)
	end
end

function FamilyPrestigeRanking:clonePanel(panel)
	if panel == nil then
		return
	end

	local row = panel:clone()
	Helper:convertUI(row)
	row.Text_mingci:enableOutline(cc.c4b(221, 215, 151, 255), 5)
	row.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	row.Text_pingjia:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return row
end

function FamilyPrestigeRanking:createPanel(userData)
	--Helper:print_lua_table(userData)
	if MapIsEmpty(userData) then
		return nil
	end
	self.Panel_item:setTouchEnabled(true)
	local panel = self.Panel_item:clone()
	Helper:convertUI(panel)
	panel.Text_mingci:enableOutline(cc.c4b(221, 215, 151, 255), 5)
	panel.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	panel.Text_pingjia:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	local role = User:getRole()
	panel:setVisible(true)
	panel.Text_time:setVisible(false)
	panel.Text_mingci:setString(tostring(userData.grade))

	local headUI = require("app.views.ui.HeadView.HeadView"):create()
	panel:addChild(headUI)
	headUI:setPosition(cc.p(164,70))
	headUI:setScaleX(0.4)
    headUI:setScaleY(0.4)

	local headpresenter = require("app.presenters.HeadView.HeadViewPresenter"):create(Role:create(userData),headUI)
	headpresenter:setHeadClickFunc(
		function()
			----本周排行从本地取数据
			print("人物的UserId:", userData.userid)
			HttpManagerEx:getUserInfo(
				tonumber(userData.userid),
				0,
				function(status, errcode, errmsg, data)
					if 200 == status then
						if 0 == errcode then
							-- 以排行榜缓存数据为准
							data = Helper:tableCover(data,userData)
							-- 头部以排行榜为准
							if MapIsEmpty(data.equips) == false then
								data.equips.head = userData.head
							end
							PopupLayerController:showLayer(
								"RoleInfoLayer",
								function(layer)
									layer:show(true)
									layer:setRoleInfo(data)
								end
							)
						else
							PopText(tostring(errmsg))
						end
					else
						PopText("网络请求出错,请换个网络环境再试!")
					end
				end,
				IS_SHOW_WAITING
			)
		end
	)

	
	local playerName=userData.name
	if not playerName then 
		local sex = tostring(userData.sex)  ---== nil and "男" or userData.sex
		if sex=="男" then 
			playerName="无名小子"
		else
			playerName="无名小辈"
		end
	end
	panel.Text_name:setString(playerName)
	--声望
	panel.Text_pingjia:setString(userData.dsc) --math.floor(userData.shengwang)
	-- local chenghao = "白身"
	-- local chenghaoList = User:getRole():getConditionMatchOfficialChengHaoList(userData.guanzhi, userData.zhengji)
	-- if userData.guanzhi ~= 0 and MapIsEmpty( chenghaoList ) ~= true then
	-- 	chenghao = chenghaoList[#chenghaoList].title2
	-- end
	if userData.real_menpai == nil then
		userData.real_menpai = "江湖散人"
	end
	--userData.real_menpai
	panel.Text_menpai:setString(userData.dsc)
	panel.Text_menpai:setVisible(false)

    -------空的名字查看玩家资料
	panel.Text_name:setTouchEnabled(true)
	panel.Text_name:releaseFunc(function()
		----本周排行从本地取数据
		print("人物的UserId:",userData.userid)
		HttpManagerEx:getUserInfo(tonumber(userData.userid), 0, function(status, errcode, errmsg, data)
				if status == 200 then
					if 0 == errcode then
						-- 以排行榜缓存数据为准
						data = Helper:tableCover( userData,data)
						-- 头部以排行榜为准
						if MapIsEmpty(data.equips) == false then
							data.equips.head = userData.head
						end
						PopupLayerController:showLayer("RoleInfoLayer", function(layer)
							layer:show(true)
							layer:setRoleInfo(data)
						end)
					else
						PopText(tostring(errmsg))
					end
				else
		    		PopText("网络请求出错,请换个网络环境再试!")
				end
		end, IS_SHOW_WAITING)
	end)

	return panel
end

function FamilyPrestigeRanking:getPageData(num)
	if num == nil then
		num = 0
	end
	local tab = clone(SortList)
	tab.body.list = {}
	for i = (num-1)*10+1,num*10 do
		if SortList.body and SortList.body.list then
			if SortList.body.list[i] then
				table.insert(tab.body.list,#tab.body.list+1,SortList.body.list[i])
			end
		end
	end
	return tab
end

function FamilyPrestigeRanking:setButtonPageUp()
	self.Button_pageUp:releaseFunc(function()
		if not self._pageUpTime then
			self._pageUpTime = GetTime() -10
		end
		if (GetTime() - self._pageUpTime) <=1 then
			PopText("请稍等")
			return
		end
		if not self.pageNum then
			self.pageNum = 1
		end
		if self.pageNum == 1 then
			-- PopText("请稍等")
			return
		end
		self.pageNum = self.pageNum-1
		self:initUI()
		self:initRank(self:getPageData(self.pageNum))
		self:setPageNum(self.pageNum)
		self._pageUpTime = GetTime()
	end)
	self.Button_pageUp:hide()
end

function FamilyPrestigeRanking:setButtonPageDdown()
	self.Button_pageDown:releaseFunc(function()
		if not self._pageDownTime then
			self._pageDownTime = GetTime() -10
		end
		if  (GetTime() - self._pageDownTime) <=1 then
			PopText("请稍等")
			return
		end
		if not self.pageNum then
			self.pageNum = 1
		end

		self.pageNum = self.pageNum+1

		if not SortList.body.list then
			self.pageNum = self.pageNum - 1
			return
		end
		if #SortList.body.list < (self.pageNum-1)*10+1 then
			self.pageNum = self.pageNum - 1
			return
		end
		self:initUI()
		self:initRank(self:getPageData(self.pageNum))
		self:setPageNum(self.pageNum)
		self._pageDownTime = GetTime()

	end)
	self.Button_pageDown:hide()
end

function FamilyPrestigeRanking:setPageNum(num)
	if not num then
		num = 1
	end
	self.Text_page:setString(tostring(num).."/10")
	self.Text_page:hide()
end

function FamilyPrestigeRanking:showLayer(isUpLoad)
	local function showSetNameLayer()
		local SetNameLayer = require("app.views.layer.SetNameLayer")
		local setNameLayer = SetNameLayer:getInstance()
		setNameLayer:show(true)

		-- 结束
		setNameLayer.Button_cancel:releaseFunc(function()
			setNameLayer:hide()
			self:hide()
		end)

		-- 随机姓名
		setNameLayer._isEditing = false
		setNameLayer.Button_randomName:releaseFunc(function()
			if setNameLayer._isEditing == false then
	    		local role = User:getRole()
		    	setNameLayer.editBox:setText(Helper:getRandomName(role.sex))
			end
		end)

		-- 确认
		local existNameMap = {}
  		setNameLayer.Button_confirm:releaseFunc(function()
			setNameLayer._editBoxString = setNameLayer.editBox:getText()

		    if setNameLayer._editBoxString == nil or setNameLayer._editBoxString == "" then
		    	PopText("名字不能为空")
		    	return
		    end

		    if PRINT_MODE == 1 then
		    	print("setNameLayer._editBoxString = "..setNameLayer._editBoxString)
		    end

		    if not Helper:isChinese(setNameLayer._editBoxString) then
		    	PopText("名字必须是中文")
		     	return
		    end

		    -- 一个 utf－8的中文字，占3个字节
		    if string.len(setNameLayer._editBoxString) > 4 * 3 then
		    	if PRINT_MODE == 1 then
		    		print("string.len(setNameLayer._editBoxString) = "..tostring(string.len(setNameLayer._editBoxString)))
		    	end
		    	PopText("名字最多四个字")
		    	return
		    end
			if Helper:isMaskOff(setNameLayer._editBoxString) then
				-- PopText("名字包含不合法字符!")
				PopText(tostring(setNameLayer._editBoxString) .. " 是非法词汇，请更换后再试。")
		      	return
			end

		    if existNameMap[setNameLayer._editBoxString] then
		      	PopText("名字已经存在")
		      	return
		    end

		    setNameLayer.Button_confirm:setTouchEnabled(false)
		    HttpManagerEx:updataUserName(setNameLayer._editBoxString, function(status, errcode, errmsg, data)
		    	setNameLayer.Button_confirm:setTouchEnabled(true)
				if status == 200 then
					if errcode == 0 then
						local role = User:getRole()
						role:setAttr("name",setNameLayer._editBoxString)

						local inheritHistory = role:getAttr("inheritHistory")

						for i,v in ipairs(inheritHistory) do
							if i == #inheritHistory then
								v.inheritName = setNameLayer._editBoxString
							end
						end

						PopText("姓名设置成功")
						setNameLayer:hide()
						self:initData(isUpLoad)
					elseif errcode == 540 then
						if type(errmsg) == "string" then
							PopText(errmsg)
						end
					elseif errcode == 541 then
						if type(errmsg) == "string" then
							PopText(errmsg)
						end
					elseif errcode == 542 then
						if type(errmsg) == "string" then
							PopText(errmsg)
						end
					elseif errcode == 543 then
						if type(errmsg) == "string" then
							PopText(errmsg)
						end
					else
						-- PopText("名字已经存在!!")
						existNameMap[setNameLayer._editBoxString] = true
					end
				else
		    		PopText("网络请求出错,请换个网络环境再试!")
				end
		    end, IS_SHOW_WAITING)
	  	end)
	end

	-- 判断是否可以改名
	HttpManagerEx:getIsChangedName(function(status, errcode, errmsg, data)
			if 200 == status then
				if 0 == errcode then
					showSetNameLayer()
				else
					self:initData(isUpLoad)
				end
			else
	    		PopText("网络请求出错,请换个网络环境再试!")
				self:hide()
			end
	end, IS_SHOW_WAITING)
end

function FamilyPrestigeRanking:initData(isUpLoad)
	if isUpLoad then 
		HttpManagerEx:uploadUserData("paihang", function(status, errcode, errmsg, data, isEncrypted)
			if status == 200 and errcode == 0 then
				self:initFamilyPrestigeRank()
			else
				PopText("网络请求出错,请换个网络环境再试!")
				self:hide()
			end
		end, IS_SHOW_WAITING)
	else
		self:initFamilyPrestigeRank()
	end
end

function FamilyPrestigeRanking:initFamilyPrestigeRank()
	HttpManagerEx:getRankingListByOne(self.flag, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				if data then
					SortList = Helper:getDef(data, {})
					self.pageNum = 1
					self.rankData = data
					self:initUI()
					self:initRank(self:getPageData(self.pageNum))
					self:setPageNum(self.pageNum)
					self:setButtonPageUp()
					self:setButtonPageDdown()
					self:show()
				end
			else
				PopText(errmsg)
			end  
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

function FamilyPrestigeRanking:setButton()
	self.Button_quit:releaseFunc(function()
		PopupLayerController:hideLayer("FamilyPrestigeRanking", function(layer)
			self:hide()
		end,0)
	end)
end

Helper:classDefNodeGetInstance(FamilyPrestigeRanking)

return FamilyPrestigeRanking0000000
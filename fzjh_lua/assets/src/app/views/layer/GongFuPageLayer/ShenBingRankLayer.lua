-- 神兵榜排行
local ShenBingRankLayer = class("ShenBingRankLayer", cc.Layer)


local SortList = {}

function ShenBingRankLayer:create()
	local p = ShenBingRankLayer:new()
	p:init()
	return p
end
--武藏   8，神兵   9
function ShenBingRankLayer:init()
	local UI = require("Layer/ActionUI/FlyKiteRankListUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self.rankData = nil

	self:setVisible(false)
	self:setButton()

	self.Button_pageUp:setPositionY(150)
	self.Button_pageDown:setPositionY(150)
	self.Text_page:setPositionY(150)
end

function ShenBingRankLayer:initUI()
	local header = self.rankData.header
	local title = self.rankData.title
	self.Panel_category.Text_Title:setString(title)
	self.Button_Reward_Preview:setVisible(false)
	self.Text_RenQi:setString(header[3])
	self.Text_RenQi:setPositionX(800)
end

function ShenBingRankLayer:initRank(tab)
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

function ShenBingRankLayer:clonePanel(panel)
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

function ShenBingRankLayer:createPanel(userData)
	Helper:print_lua_table(userData)
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

	panel.Text_name:setString(userData.name)
	panel.Text_pingjia:setString(userData.dsc)
	-- local chenghao = "白身"
	-- local chenghaoList = User:getRole():getConditionMatchOfficialChengHaoList(userData.guanzhi, userData.zhengji)
	-- if userData.guanzhi ~= 0 and MapIsEmpty( chenghaoList ) ~= true then
	-- 	chenghao = chenghaoList[#chenghaoList].title2
	-- end
	if userData.real_menpai == nil then
		userData.real_menpai = "江湖散人"
	end
	panel.Text_menpai:setString(userData.real_menpai)

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

function ShenBingRankLayer:getPageData(num)
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

function ShenBingRankLayer:setButtonPageUp()
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

function ShenBingRankLayer:setButtonPageDdown()
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

function ShenBingRankLayer:setPageNum(num)
	if not num then
		num = 1
	end
	self.Text_page:setString(tostring(num).."/10")
	self.Text_page:hide()
end

function ShenBingRankLayer:showLayer(flag)
	HttpManagerEx:getRankingListByOne(flag, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				if data then
					SortList = Helper:getDef(data, {})
					-- local listCount = #SortList.body.list
					-- for i=1,listCount do
					-- 	table.insert(SortList.body.list, SortList.body.list[1])
					-- end
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

function ShenBingRankLayer:setButton()
	self.Button_quit:releaseFunc(function()
		PopupLayerController:hideLayer("ShenBingRankLayer", function(layer)
			self:hide()
		end,0)
	end)
end

Helper:classDefNodeGetInstance(ShenBingRankLayer)

return ShenBingRankLayer0000000
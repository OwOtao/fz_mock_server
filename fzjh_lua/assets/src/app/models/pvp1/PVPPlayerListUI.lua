local RankingUI = class("RankingUI", cc.Layer)

-- local function print()
-- end

function RankingUI:create()
	local p = RankingUI:new()
	p:init()
	return p
end

local rankingsConfig =
{
}

function RankingUI:init()
	self._round = require("Layer/RankingUI/RankingUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点

	-- 初始化变量
	self._rankings = {} -- 存储当前的排行榜信息


	-- -- 初始化排行榜界面
	-- self:initRankings(rankingsConfig)

	-- 初始化按钮
	self:setButtonQuit()

	self:schedule(
    	function(ft)
    		self:updateCategory()
    	end, 0)
	self:setVisible(false)
end

function RankingUI:initData(func)

	-- 首先移除所有page, 避免闪烁的效果
	self:removeAllPages()
	self.Panel_category:removeAllChildren()

	-- self.PageView_ranking:setTouchEnabled(true)
	self:resumeSelfAndChildren()

	local player = User:getRole()
	-- 显示设置名字界面
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
						User:getRole().name = setNameLayer._editBoxString
						PopText("姓名设置成功")

						setNameLayer:hide()
						-- 初始化排行榜界面
						HttpManagerEx:uploadUserData("paihang", function(status, errcode, errmsg, data, isEncrypted)
							if status == 200 and errcode == 0 then
								self:initRankings(func)
							else
	    						PopText("网络请求出错,请换个网络环境再试!")
								self:hide()
							end
						end, IS_SHOW_WAITING)
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
			if PRINT_MODE == 1 then
				print("······getIsChangedName:")
				print("errcode = "..tostring(errcode))
				print("status = "..tostring(status))
			end
			if 200 == status then
				if 0 == errcode then
					showSetNameLayer()
				else
					HttpManagerEx:uploadUserData("paihang", function(status, errcode, errmsg, data, isEncrypted)
						if PRINT_MODE == 1 then
							print("······uploadUserData:")
							print("errcode = "..tostring(errcode))
							print("status = "..tostring(status))
						end
						if status == 200 and errcode == 0 then
							self:initRankings(func)
						else
							PopText(errmsg)
							self:hide()
						end
					end, IS_SHOW_WAITING)
				end
			else
	    		PopText("网络请求出错,请换个网络环境再试!")
				self:hide()
				-- self:initRankings()
			end
		end, IS_SHOW_WAITING)
end

function RankingUI:hide()
	-- self.PageView_ranking:setTouchEnabled(false)
	self:setVisible(false)
	self:pauseSelfAndChildren()
end

-- 初始化self._rankings
function RankingUI:initRankings(func)
	-- if self._rankingsConfig == nil then
	-- 	self._rankingsConfig = rankingsConfig
	-- -- else
	-- -- 	return
	-- end

	-- for i, rankingConfig in ipairs(rankingsConfig) do
	-- 	self._rankings[i] =
	-- 	{
	-- 		category = rankingConfig.category,
	-- 		rankingUIPath = rankingConfig.rankingUIPath,
	-- 		requestUrl = rankingConfig.requestUrl,
	-- 	}
	-- end

	-- 江湖榜列表
	self._JiangHuList = {}
	-- 门派榜列表
	self._MengPaiList = {}

	local function initResponseData(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				local list = data
				for k,listData in pairs(list) do
					if listData.type == "menpai_board" then
						table.insert(self._MengPaiList, listData)
					else
						table.insert(self._JiangHuList, listData)
					end
				end
				return true
			else
				PopText(errmsg)
			end
		else
    		PopText("网络请求出错,请换个网络环境再试!")
		end
		return false
	end


	HttpManagerEx:getRankingList(function(status, errcode, errmsg, data)
		if initResponseData(status, errcode, errmsg, data) == true then
			self:initRankingAllPage(self._JiangHuList)
			self._currType = "江湖"
			self.Text_mpName:setString("门派榜")
			self:updateCategory()
			-- self:setVisible(true)
			if func then
				func()
			end

		else
			self:hide()
		end
	end, IS_SHOW_WAITING)

	-- 初始化排行布局
	-- 初始化类别菜单
	-- self:initCategory()
end

-- 初始化rankingPage
function RankingUI:initRankingAllPage(list)
	if MapIsEmpty(list) then
		return
	end

	self.Panel_category:removeAllChildren()
	self.PageView_ranking:removeAllPages()
	local index =1
	self._rankings = {}
	for k,v in pairs(list) do
		self._rankings[index] =
		{
			category = ""
		}
		self:createOnePage(index, v)
		index = index + 1
	end
	-- 添加页面
	-- for i = 1, list do
	-- 	self:createOnePage(i, params)
	-- 	-- for i=1,20 do
	-- 	-- 	rankingChildUI.ListView_ranking:pushBackDefaultItem()
	-- 	-- end
	-- end
end

local rankingUITab =
{
	total_board = "Layer/RankingUI/RankingChildUI1.lua",
	menpai_board = "Layer/RankingUI/RankingChildUI1.lua",
}

-- 排行榜单页初始化
function RankingUI:createOnePage(index, params)
	if index == nil or MapIsEmpty(params) then
		return
	end

	-- 必须存在,不然会导致require报错
	if params.type == nil or rankingUITab[params.type] == nil then
		return
	end

	local layout = ccui.Layout:create()
	if self.PageView_ranking:getPage(index-1) then
		layout = self.PageView_ranking:getPage(index-1)
	end
	self.PageView_ranking:addPage(layout)


	if PRINT_MODE == 1 then
		print("rankingUITab[params.type] = "..tostring(params.type))
		print("rankingUITab[params.type] = "..tostring(rankingUITab[params.type]))
	end
	local rankingChildUI = require(rankingUITab[params.type]).create()['root']
	Helper:convertUI(rankingChildUI)
	rankingChildUI.ListView_ranking:setSwallowTouches(false)
	-- 设置itemModel
	local itemModel = rankingChildUI.ListView_ranking:getItem(0)
	rankingChildUI.ListView_ranking:setItemModel(itemModel)
	rankingChildUI.ListView_ranking:removeAllItems()

	-- 根据UI类型获得排行榜列表UI
	-- ranking.rankingChildUI = rankingChildUI
	layout:addChild(rankingChildUI)

	self:createCategory(index, params.title)
	self:createHead(rankingChildUI, params.header)
	self:createListView(rankingChildUI, params.body)
end

-- 移除所有
function RankingUI:removeAllPages()
	if self.PageView_ranking then
		self.PageView_ranking:removeAllPages()
	end
end

-- 创建标题
function RankingUI:createCategory(index, title)
	if index == nil or title == nil then
		return
	end
	local ranking = self._rankings[index]
	local text = ccui.Text:create(title, "Font/HYCFS.ttf", 60)
	text:setColor(cc.c3b(208, 208, 208))
	text:setAnchorPoint(0.5000, 0.5000)
	if index == 1 then
		text:setFontSize(60)
		text:setOpacity(255)
	else
		text:setFontSize(48)
		text:setOpacity(125)
	end
	self.Panel_category:addChild(text)
	text:enableOutline(cc.c4b(0, 0, 0, 255), 5) -- 描边无效, 不知道咋了.
	ranking.categoryText = text

	text:setTouchEnabled(true)
	text:releaseFunc(function()
		self.PageView_ranking:playScrollPageAnim(index-1)
		self:delayFunc(0, function()
			local list = self.PageView_ranking:getPage(index-1)
			-- if not list or _G.next(list) == nil then
			-- 	createOnePage(i-1)
			-- end
		end)
	end)
end

-- 创建抬头
function RankingUI:createHead(ui, headers)
	if ui == nil and headers == nil then
		return
	end
	ui.Text_mingci:setString(headers[1])
	ui.Text_nicheng:setString(headers[2])
	ui.Text_desc:setString(headers[3])
end

-- 创建列表
function RankingUI:createListView(ui, data)
	if ui == nil or MapIsEmpty(data) then
		return
	end

	local function gradeCast(num)
		local tab = {"壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾"}
		if tab[num] == nil then
			return tostring(num)
		end
		return tab[num]
	end

	for i,listData in ipairs(data.list) do
		listData.sort = i
		listData.grade = gradeCast(i)
		local row = self:createPanel(ui, listData)
		ui.ListView_ranking:pushBackCustomItem(row)
	end

	if data.list ~= nil and #data.list < 10 then
		return
	end

	local mine = data.mine
	if mine == nil or mine.sort == nil then
		return
	end

	if mine.sort > 10 then
		if mine.sort > 9999 then
			mine.grade = "9999+"
		else
			mine.grade = mine.sort
		end
	else
		mine.grade = gradeCast(mine.sort)
	end

	local row = self:createPanel(ui, mine)
	if row ~= nil then
		ui.ListView_ranking:pushBackCustomItem(row)
	end
end

-- 创建一行记录信息
function RankingUI:createPanel(ui, userData)
	if ui == nil or MapIsEmpty(userData) then
		return nil
	end

	local panel = ui.Panel_item:clone()
	Helper:convertUI(panel)
	panel.Text_mingci:enableOutline(cc.c4b(221, 215, 151, 255), 5)
	panel.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	panel.Text_pingjia:enableOutline(cc.c4b(0, 0, 0, 255), 5)

	local role = User:getRole()
	panel:setVisible(true)

	-- print("userData.grade = "..userData.grade)
	panel.Text_mingci:setString(tostring(userData.grade))
	if userData.sort <= 3 then
		panel.Text_mingci:setFontSize(72)
	elseif userData.sort <= 10 then
		panel.Text_mingci:setFontSize(60)
	elseif string.len(userData.sort) >=4 then
		panel.Text_mingci:setFontSize(48)
	end

	local imagePath
	if userData.yueka == "YES" then
		imagePath = role:getFaceRankFrame(userData.portrait, true)
	else
		imagePath = role:getFaceRankFrame(userData.portrait, false)
	end

	panel.Image_kuang:loadTexture(imagePath)

    -- 设置图片大小
    local texture = cc.TextureCache:getInstance():getTextureForKey(imagePath);
    panel.Image_kuang:setSize(texture:getContentSize())
	local present = require("app.presenters.HeadView.HVDPresent"):create(panel.Image_looks,userData)
	present:showHead()
	
	panel.Text_name:setString(userData.name)
	panel.Text_pingjia:setString(userData.dsc)
	panel.Text_menpai:setString(userData.menpai)

	--点击名字查看玩家资料  头像 Image_looks
	panel.Text_name:releaseFunc(function()
		HttpManagerEx:getUserInfo(tonumber(userData.userid), 0, function(status, errcode, errmsg, data)
			if status == 200 then
				if 0 == errcode then
					-- 以排行榜缓存数据为准
					data = Helper:tableCover(data, userData)
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
    --点击查看玩家资料  头像 Image_looks
    panel.Image_looks:setTouchEnabled(true)
	panel.Image_looks:releaseFunc(function()
	HttpManagerEx:getUserInfo(tonumber(userData.userid), 0, function(status, errcode, errmsg, data)
		if status == 200 then
			if 0 == errcode then
				-- 以排行榜缓存数据为准
				data = Helper:tableCover(data, userData)
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

-- 根据rankingPage刷新类别菜单
function RankingUI:updateCategory()
	if self.PageView_ranking == nil then
		return
	end

	local page1 = self.PageView_ranking:getPage(0)
	if page1 then
		-- print("page0 positionX ="..tostring(page1:getPositionX()))

		local offsetX = page1:getPositionX() -- 页面位移

		local totalWidth = #self._rankings * 1080
		local gapWidth = 200
		for i = 1, #self._rankings do
			local ranking = self._rankings[i]
			if ranking.categoryText then
				ranking.categoryText:setPositionY(self.Panel_category:getContentSize().height / 2)
				ranking.categoryText:setPositionX((offsetX / 1080) * gapWidth + (i - 1) * gapWidth + display.width / 2 )--+ 340)

				-- 缩放效果
				local posX = ranking.categoryText:getPositionX()
				if posX > display.width / 2 - gapWidth and posX < display.width / 2 + gapWidth then
					local scale = 1 + 0.3 * (1 - math.abs(display.width / 2 - posX) / gapWidth)
					-- ranking.categoryText:setScale(scale)

					if scale > 1.2 then
						ranking.categoryText:setZ(5) -- 层级有点问题需要调整
						ranking.categoryText:setFontSize(60)
						ranking.categoryText:setOpacity(255)
					else
						ranking.categoryText:setZ(1)
						ranking.categoryText:setFontSize(48)
						ranking.categoryText:setOpacity(125)
					end
				else
					ranking.categoryText:setScale(1)
				end
			end
		end
	end
end

-- 关闭按钮
function RankingUI:setButtonQuit()
	self.Button_quit:releaseFunc(function()
		MainControllLayer:popLayer()
	end)
end



Helper:classDefNodeGetInstance(RankingUI)
return RankingUI
00
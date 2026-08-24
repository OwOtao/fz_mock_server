local RankingUI = class("RankingUI", cc.Layer)
local Resource = require("app.Resource")
local RoleInfoLayer = require("app.views.layer.RoleLayer.RoleInfoLayer")

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

	-- add by XiaoZhiWei 2017/06/30 13:26:14 add with ios 1.0
	self.PageView_ranking:setScrollDurationWithNumber(0.5)

	-- 初始化变量
	self._rankings = {} -- 存储当前的排行榜信息


	-- -- 初始化排行榜界面
	-- self:initRankings(rankingsConfig)

	-- 初始化按钮
	self:setButtonQuit()
	self:setButtonBack()
	self:setButtonMengPai()

	self:schedule(
    	function(ft)
    		self:updateCategory()

    		self:updateCurrPageData()
    		-- add by XiaoZhiWei 2017/08/09 13:18:18 总页数大于1的有分页
    		if Helper:getDef(self:getCurrPageInfoByKey(self.__currTitle, "totalPage"), 0) > 1 then
    			self:setPageShowOrHide(true)
    		else
    			self:setPageShowOrHide(false)
    		end

    		-- print(self.__currTitle, self.Text_page:getString(), self:getCurrPageNum(self.__currTitle))

    	end, 0)
	self:setVisible(false)

	self.__cacheTime = 10 * 60 -- add by XiaoZhiWei 2017/05/09 17:53:57 数据缓存时间
	-- self.__dataCount = 100 -- add by XiaoZhiWei 2017/05/09 17:55:22 每次或数据条数 注:这个条数不能小于10条
	-- self.__totalCount = 100 -- add by XiaoZhiWei 2017/05/10 11:46:37 数据总体条数
	self.__currTitle = "" -- add by XiaoZhiWei 2017/05/15 21:36:41 当前界面标题
	self.__oldOffset = 0 -- add by XiaoZhiWei 2017/06/26 21:25:29 记录上一次抬头的坐标值

	self.__pageInfo = {} -- add by XiaoZhiWei 2017/05/16 14:50:39 记录当前页面信息 pageNum 页码 pageTitle 页面标题 totalCount 页面总条数 boardType 排行榜类型 totalPage 排行榜总页数 nums 当前页面的数量
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/08 11:26:13
-- @desc 及时更新列表数据
local lastTitle = ""
function RankingUI:updateCurrPageData()
	if lastTitle == "" then
		lastTitle = self.__currTitle
	end

	if lastTitle ~= self.__currTitle then
		self:initOnePageWithNum(self:getCurrPageNum(self.__currTitle))
		lastTitle = self.__currTitle
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/19 13:19:22
-- @desc 翻页条显示隐藏控制
function RankingUI:setPageShowOrHide(bool)
	bool = Helper:getDef(bool, true)
	self.Button_menpai:setVisible(bool)
	self.Text_page:setVisible(bool)
	self.Button_quit:setVisible(bool)
	self.Image_page_back:setVisible(bool)
end

function RankingUI:initData(func)

	-- 首先移除所有page, 避免闪烁的效果
	-- self:removeAllPages()
	-- self.Panel_category:removeAllChildren()

	self.PageView_ranking:setTouchEnabled(true)
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
	--@desc setVisible失效，需把PageView_ranking的触控单独关闭，不然退出界面后会把主界面的按钮挡住
	self.PageView_ranking:setTouchEnabled(false)
	self:setVisible(false)
	self:pauseSelfAndChildren()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/15 21:19:02
-- @desc 判断数据列表是否为空
function RankingUI:checkDataListIsEmpty(data)
	if MapIsEmpty(data) == true then
		return true
	end

	for k,listData in pairs(data) do
		if listData.isEmpty ~= true and listData.title == self.__currTitle then
			return false
		end
	end

	return true
end

-- 初始化self._rankings
function RankingUI:initRankings(func)
	-- 初始化排行布局
	-- 初始化类别菜单
	-- self:initCategory()
	-- self:initOnePageWithNum(1, func)
	self.__currTitle = "高手榜"
	local totalPage = self:getCurrPageInfoByKey(self.__currTitle, "totalPage")
	if totalPage == nil then
		self:getRankingDataFromWeb(function(isSuccess)
			if isSuccess == true then
				self:initOnePageWithNum(1, func)
			else
				self:hide()
			end
		end)
	else
		self:initOnePageWithNum(1, func, function() self:hide() end)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/15 18:03:56
-- @desc 初始化指定页码页面
function RankingUI:initOnePageWithNum(pageNum, successFunc, failedFunc)
	pageNum = Helper:getRange(Helper:getDef(pageNum, 1), 1, Helper:getDef(self:getCurrPageInfoByKey(self.__currTitle, "totalPage"), 10))
	local function showPage()
		local data = self:getRankDataWithPage(pageNum)
		-- if self:checkDataListIsEmpty(data) == true then
		-- 	if failedFunc then
		-- 		failedFunc()
		-- 	end
		-- else
			self:setCurrPageNum(self.__currTitle, pageNum)
			self:initRankingAllPage(data)
			self:updateCategory()
			if successFunc then
				successFunc()
			end
		-- end
	end

	local data = self:getRankDataWithPage(pageNum)
	if MapIsEmpty(data) == true then
		-- add by XiaoZhiWei 2017/08/10 16:14:45 数据过期的情况
		self:getRankingDataFromWeb(function(isSuccess)
			if isSuccess == true then
				self:initOnePageWithNum(1, function() showPage() end)
			else
				self:hide()
			end
		end)
	elseif self:checkDataListIsEmpty(data) == true then
		self:getBoardData(pageNum, function() 
			showPage()
		end)
	else
		showPage()
	end
end

-- 初始化rankingPage
function RankingUI:initRankingAllPage(list)
	if MapIsEmpty(list) then
		return
	end

	-- self.Panel_category:removeAllChildren()
	-- self.PageView_ranking:removeAllPages()
	local index =1
	self._rankings = Helper:getDef(self._rankings, {})
	for k,v in pairs(list) do
		self._rankings[index] = Helper:getDef(self._rankings[index], {})
		self._rankings[index].name = v.title
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

	local layout = self.PageView_ranking:getPageByIndex(index-1) --ccui.Layout:create()
	local rankingChildUI
	if layout == nil then
		layout = ccui.Layout:create()
		self.PageView_ranking:addPage(layout)
		rankingChildUI = require("Layer/RankingUI/RankingChildUI1.lua").create()['root']
		Helper:convertUI(rankingChildUI)
		rankingChildUI.ListView_ranking:setSwallowTouches(false)
		-- 设置itemModel
		local itemModel = rankingChildUI.ListView_ranking:getItem(0)
		rankingChildUI.ListView_ranking:setItemModel(itemModel)
		rankingChildUI.ListView_ranking:removeAllItems()

		-- 根据UI类型获得排行榜列表UI
		-- ranking.rankingChildUI = rankingChildUI
		layout:addChild(rankingChildUI)
	else
		rankingChildUI = layout:getChildren()[1]
	end

	if PRINT_MODE == 1 then
		print("rankingUITab[params.type] = "..tostring(params.type))
		print("rankingUITab[params.type] = "..tostring(rankingUITab[params.type]))
	end

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
	local text = ranking.categoryText
	if text == nil then
		text = ccui.Text:create(title, "Font/HYCFS.ttf", 60)
		text:setColor(cc.c3b(208, 208, 208))
		text:setAnchorPoint(0.5000, 0.5000)
		self.Panel_category:addChild(text)
		ranking.categoryText = text
		text:enableOutline(cc.c4b(0, 0, 0, 255), 5) -- 描边无效, 不知道咋了.
		text:setTouchEnabled(true)
	end

	if index == 1 then
		text:setFontSize(60)
		text:setOpacity(255)
	else
		text:setFontSize(48)
		text:setOpacity(125)
	end

	text:releaseFunc(function()
		-- self.__currTitle = title -- add by XiaoZhiWei 2017/05/15 21:36:01 记录当前界面
		-- if title ~= "高手榜" then
		-- 	self:setCurrentPage(1)
		-- else
		self:setCurrentPage(self:getCurrPageNum(title))
		self:initOnePageWithNum(self:getCurrPageNum(title), function()
			self.PageView_ranking:playScrollPageAnim(index-1)
			self:delayFunc(0, function()
				self.PageView_ranking:getPageByIndex(index-1)
				-- if not list or _G.next(list) == nil then
				-- 	createOnePage(i-1)
				-- end
			end)
		end)
		-- end
		-- self.PageView_ranking:playScrollPageAnim(index-1)
		-- self:delayFunc(0, function()
		-- 	self.PageView_ranking:getPage(index-1)
		-- 	-- if not list or _G.next(list) == nil then
		-- 	-- 	createOnePage(i-1)
		-- 	-- end
		-- end)
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
local tabNum = {"壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾"}
function RankingUI:createListView(ui, data)
	if ui == nil or MapIsEmpty(data) then
		return
	end

	local function gradeCast(num)
		if tabNum[num] == nil then
			return tostring(num)
		end
		return tabNum[num]
	end

	-- add by XiaoZhiWei 2017/05/19 16:52:36 优化 列表部分只需要改变文本即可,无需清空再重新创建,浪费资源
	local length = #ui.ListView_ranking:getItems()
	length = math.max(length, #data.list)

	--@desc 当排行榜上无人时
	if length == 0 then
		ui.ListView_ranking:setVisible(false)
		ui.Text_Tips:setVisible(true)
	else
		ui.ListView_ranking:setVisible(true)
		ui.Text_Tips:setVisible(false)
	end

	for i=1,length do
		if i > #data.list then
			ui.ListView_ranking:removeLastItem()
		else
			local listData = data.list[i]
			listData.grade = gradeCast(listData.sort)
			local row = ui.ListView_ranking:getItem(i - 1)
			if row == nil then
				row = self:createPanel(ui)
				ui.ListView_ranking:pushBackCustomItem(row)
			end
			self:updateOnePanelItem(row, listData)
		end
	end

	if data.list ~= nil and #data.list < 10 then
		return
	end

	local mine = data.mine
	if mine == nil or mine.sort == nil then
		return
	end

	if type(mine.sort) == "number" then
		if mine.sort > 10 then
			if mine.sort > 9999 then
				mine.grade = "9999+"
			else
				mine.grade = mine.sort
			end
		else
			mine.grade = gradeCast(mine.sort)
		end
	elseif type(mine.sort) == "string" then
		mine.grade = Helper:getDef(mine.sort, "未入榜")
	else
		mine.grade = "9999+"
	end

	local row = ui.ListView_ranking:getItem(#data.list)
	if row == nil then
		row = self:createPanel(ui)
		ui.ListView_ranking:pushBackCustomItem(row)
	end
	self:updateOnePanelItem(row, mine)

end

-- add by XiaoZhiWei 2017/05/09 10:33:31 查看玩家资料
local lookUserInfo = function(userData)
	HttpManagerEx:getUserInfo(tonumber(userData.userid), 0, function(status, errcode, errmsg, data)
		if status == 200 then
			if 0 == errcode then
				-- 以排行榜缓存数据为准
				data = Helper:tableCover(data, userData)
				local roleInfoLayer = RoleInfoLayer:getInstance()
				roleInfoLayer:show(true)
				roleInfoLayer:setRoleInfo(data)
			else
				PopText(tostring(errmsg))
			end
		else
    		PopText("网络请求出错,请换个网络环境再试!")
		end
	end, IS_SHOW_WAITING)
end

-- add by XiaoZhiWei 2017/05/22 16:16:23 传承次数名字颜色
local nameColorTab =
{
    [1] = "HIB",
    [2] = "HIC",
    [3] = "HIG",
    [4] = "HIY",
    [5] = "HIW",
	default = "DWT"
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/19 16:40:34
-- @desc 更新一条记录信息
function RankingUI:updateOnePanelItem(panel, userData)
	local role = User:getRole()

	-- print("userData.grade = "..userData.grade)
	panel.Text_mingci:setPositionX(98)
	panel.Text_mingci:setString(tostring(userData.grade))
	if type(userData.sort) == "string" then
		panel.Text_mingci:setFontSize(48)
	else
		if userData.sort <= 3 then
			panel.Text_mingci:setFontSize(72)
		elseif userData.sort <= 10 then
			panel.Text_mingci:setFontSize(60)
		elseif string.len(userData.sort) >=4 then
			panel.Text_mingci:setFontSize(48)
			panel.Text_mingci:setPositionX(110)
		else
			panel.Text_mingci:setFontSize(48)
		end
	end	

	local headView = panel:getChildByName("headView")

	local titleId = userData.title_id
	local titleType = userData.title_type

	if titleId == nil or titleType == nil then
		userData.title_id = 160
		userData.title_type = 2
	end

	--@RefType [src.app.presenters.HeadView.HeadViewPresenter#HeadViewPresenter]
	local headViewPresenter = require("app.presenters.HeadView.HeadViewPresenter"):create(Role:create(userData),headView)

	headViewPresenter:setHeadClickFunc(function ()
		lookUserInfo(userData)
	end)

	local inheritCount = Helper:getDef(userData.inheritCount, 0)
	local name = switch(inheritCount, nameColorTab)..tostring(userData.name)

	panel.Text_name:setString(name)
	panel.Text_pingjia:setString(userData.dsc)
	panel.Text_menpai:setString(userData.menpai)

	--点击名字查看玩家资料  头像 Image_looks
	panel.Text_name:releaseFunc(function()
		lookUserInfo(userData)
	end)
    --点击查看玩家资料  头像 Image_looks
    panel.Image_looks:setTouchEnabled(true)
	panel.Image_looks:releaseFunc(function()
		lookUserInfo(userData)
	end)
end

-- 创建一行记录信息
function RankingUI:createPanel(ui)
	if ui == nil then
		return nil
	end

	local panel = ui.Panel_item:clone()
	Helper:convertUI(panel)
	panel.Text_mingci:enableOutline(cc.c4b(221, 215, 151, 255), 5)
	panel.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	panel.Text_pingjia:enableOutline(cc.c4b(0, 0, 0, 255), 5)

	local headUI = require("app.views.ui.HeadView.HeadView"):create()

	headUI:setName("headView")

	headUI:setPosition(cc.p(ui.Node_HeadPos:getPosition()))

	local headUISize = headUI:getContentSize()

	local scaleX = 118 / headUISize.width

	local scaleY = 118 /headUISize.height

	headUI:setScaleX(scaleX)

	headUI:setScaleY(scaleY)

	panel:addChild(headUI)

	panel:setVisible(true)

	return panel
end

-- 根据rankingPage刷新类别菜单
function RankingUI:updateCategory()
	-- print("function RankingUI:updateCategory()")
	if self.PageView_ranking == nil then
		return
	end
		
	local offsetX = self.PageView_ranking:getInnerContainerPosX()

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

					if self.__oldOffset == offsetX then
						self.__currTitle = ranking.name
					else
						self.__oldOffset = offsetX
					end
				else
					ranking.categoryText:setZ(1)
					ranking.categoryText:setFontSize(48)
					ranking.categoryText:setOpacity(125)
				end
			else
				-- ranking.categoryText:setScale(1)
				ranking.categoryText:setZ(1)
				ranking.categoryText:setFontSize(48)
				ranking.categoryText:setOpacity(125)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/08 10:33:19
-- @desc 设置当前页面数据总条数
--pageNum 页码 pageTitle 页面标题 totalCount 页面总条数 boardType 排行榜类型 totalPage 排行榜总页数 nums 当前页面的数量


function RankingUI:setCurrPageInfo(pageTitle, key, value)
	if pageTitle == nil or key == nil or value == nil then
		return
	end
	self.__pageInfo[pageTitle] = Helper:getDef(self.__pageInfo[pageTitle], {})
	self.__pageInfo[pageTitle].pageTitle = pageTitle
	self.__pageInfo[pageTitle][key] = value
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/08 10:35:08
-- @desc 获取当前页面数据总条数
function RankingUI:getCurrPageInfoByKey(pageTitle, key)
	if pageTitle == nil or MapIsEmpty(self.__pageInfo[pageTitle]) == true or key == nil then
		return nil
	end
	return self.__pageInfo[pageTitle][key]
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/16 14:51:45
-- @desc 设置当前页面信息
function RankingUI:setCurrPageNum(pageTitle, pageNum)
	if pageTitle == nil or pageNum == nil then
		return
	end
	self.__pageInfo[pageTitle] = Helper:getDef(self.__pageInfo[pageTitle], {})
	self.__pageInfo[pageTitle].pageTitle = pageTitle
	self.__pageInfo[pageTitle].pageNum = pageNum

	self:setCurrentPage(pageNum)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/16 14:54:06
-- @desc 获取当前页面的页码
function RankingUI:getCurrPageNum(pageTitle)
	if pageTitle == nil or MapIsEmpty(self.__pageInfo[pageTitle]) == true then
		return 1
	end
	return Helper:getDef(self.__pageInfo[pageTitle].pageNum, 1)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/15 17:19:42
-- @desc 设置当前页码
function RankingUI:setCurrentPage(pageNum)
	pageNum = Helper:getDef(pageNum, 0)
	self.Text_page:setString(pageNum.."/10")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/15 17:18:58
-- @desc 下一页
function RankingUI:setButtonQuit()
	self.Button_quit:releaseFunc(function()
		local currPage = self:getCurrPageNum(self.__currTitle)
		if self.Button_quit.__clickTIme ~= nil and GetTime() - self.Button_quit.__clickTIme < 1 then
			PopText("请稍候...")
			return
		end
		self.Button_quit.__clickTIme = GetTime()
		if currPage >= Helper:getDef(self:getCurrPageInfoByKey(self.__currTitle, "totalPage"), 10) then
		else
			self:initOnePageWithNum(currPage + 1)
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/15 17:19:10
-- @desc 上一页
function RankingUI:setButtonMengPai()
	self.Button_menpai:releaseFunc(function()
		local currPage = self:getCurrPageNum(self.__currTitle)
		if self.Button_menpai.__clickTIme ~= nil and GetTime() - self.Button_menpai.__clickTIme < 1 then
			PopText("请稍候...")
			return
		end
		self.Button_menpai.__clickTIme = GetTime()
		if  currPage <= 1 then
		else
			self:initOnePageWithNum(currPage - 1)
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/15 17:18:02
-- @desc 返回按钮
function RankingUI:setButtonBack()
	self.Button_back:releaseFunc(function()
		MainControllLayer:popLayer()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/10 11:52:18
-- @desc 从服务器获取排行榜数据
function RankingUI:getRankingDataFromWeb(func)
	HttpManagerEx:getRankingList(1, function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then

			
			if MapIsEmpty(data) == false then
				self:initAndSaveData(data, 1, func)
			else
				PopText("未能成功获取服务器数据，请检查您的网络环境！")
				func(false)
			end
		else
			if type(errmsg ) == "string" and errmsg ~= "" then
				PopText(errmsg)
			end
			func(false)
		end
	end, IS_SHOW_WAITING)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/09 11:58:02
-- @desc 获取指定排行榜的下一页数据
function RankingUI:getBoardData(pageNum, func)
	if pageNum == nil then
		return
	end
	-- PopText("pageNum = "..tostring(pageNum))
	HttpManagerEx:getBoard(self:getCurrPageInfoByKey(self.__currTitle, "boardType") , pageNum, function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			if MapIsEmpty(data) == false then
				self:initAndSaveData({data}, pageNum, func)
			else
			end
		end
	end)
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/10 11:44:36
-- @desc 获取指定页数的数据
function RankingUI:getRankDataWithPage(pageNum)
	local retMap = {}
	if pageNum == nil then
		return retMap
	end
	local cacheTime, totalPage = self:getCacheTime(), Helper:getDef(self:getCurrPageInfoByKey(self.__currTitle, "totalPage"), 10) 
	local data = self:getData()
	--[[
		情况 : 空表 , 非空,但是没有当前页, 非空,已有当前页,但是已过期, 非空,已有当前页,并且没过期
		结构 :
		data =
		{
			title =
			{
				...
				body = {},
				mine = {}
			}
		}
	]]

	pageNum = Helper:getRange(pageNum, 1, totalPage)

	-- add by XiaoZhiWei 2017/05/10 12:19:43 没有存储数据
	if MapIsEmpty(data) == true then
	else
		-- add by XiaoZhiWei 2017/05/10 12:19:52 已过期
		if math.abs(GetTime() - Helper:getDef(data.time, 0)) >= cacheTime or data.userid ~= User:getUserId() or data.version < UpdateManager:getVersion() then
			-- add by XiaoZhiWei 2017/05/10 14:12:17 需清空
		else
			for key,pageInfo in pairs(data) do
				if type(pageInfo) ~= "table" then
				else
					local map = {}
					for k,v in pairs(pageInfo) do
						if k == "body" then
							-- add by XiaoZhiWei 2017/06/05 12:33:35 不是当前排行榜的不需要获取
							if key == self.__currTitle then
								map.body = Helper:getDef(map.body, {})
								map.body.list = Helper:getDef(map.body.list, {})
								-- self:setCurrPageDataTotalCount(self.__currTitle, Helper:getDef(#v.list, 0))

								for i=(pageNum - 1) * 10 + 1,pageNum * 10 do
									local userData = v.list[i]
									if MapIsEmpty(userData) == false then
										userData.sort = i
										table.insert(map.body.list, userData)
									end
								end
								map.body.mine = v.mine
							end
						else
							map[k] = v
						end
					end

					if MapIsEmpty(map.body) == true or MapIsEmpty(map.body.list) == true then
						map.isEmpty = true -- add by XiaoZhiWei 2017/05/15 21:17:43 标识是否为空
					end
					table.insert(retMap, map)
				end
			end
		end
	end

	-- add by XiaoZhiWei 2017/05/15 21:24:59 重新排序
	table.sort(retMap, function(a, b)
		return a.index < b.index
	end)

	return retMap
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/10 14:54:56
-- @desc 格式化数据并存储缓存
function RankingUI:initAndSaveData(webData, webPage, func)
	if webData == nil or webPage == nil then
		return
	end
	local data = Helper:getDef(self:getData(), {})
	local cacheTime = self:getCacheTime()
	-- add by XiaoZhiWei 2017/05/10 15:37:28 存储数据为空  缓存时间已过  版本已更新过 已切换角色或重置角色

	if MapIsEmpty(data) == true or math.abs(GetTime() - Helper:getDef(data.time, 0)) >= cacheTime or data.version < UpdateManager:getVersion() or data.userid ~= User:getUserId() then
	data =
		{
			time = GetTime(),
			version = UpdateManager:getVersion(),
			userid = User:getUserId()
		}
	else
	end

	--[[
		data =
		{
			title =
			{
				...
				body = {},
				mine = {}
			}
		}
	]]
	-- add by XiaoZhiWei 2017/05/10 17:09:52
	for j,list in pairs(webData) do
		data[list.title] = Helper:getDef(data[list.title], {})
		if data[list.title].index == nil then
			data[list.title].index =  j -- add by XiaoZhiWei 2017/05/15 21:30:00 排序作用
		end
		for k,v in pairs(list) do
			if k == "body" then
				if MapIsEmpty(v) == false then
					data[list.title].body = Helper:getDef(data[list.title].body, {})
					data[list.title].body.list = Helper:getDef(data[list.title].body.list, {})
					if MapIsEmpty(v.list) == false then
						for i,userData in ipairs(v.list) do
							local index = Helper:getRange((webPage - 1) * list.nums + i, 1, list.total_nums)
							data[list.title].body.list[index] = userData
						end
					end

					if v.mine ~= nil then
						data[list.title].body.mine = v.mine
					end
				end
			else
				data[list.title][k] = v
			end
		end
		if list.title ~= nil and list.total_nums ~= nil and list.board_type ~= nil and list.total_page ~= nil and list.nums ~= nil then
			--pageNum 页码 pageTitle 页面标题 totalCount 页面总条数 boardType 排行榜类型 totalPage 排行榜总页数 nums 当前页面的数量
			self:setCurrPageInfo(list.title, "totalCount", list.total_nums)
			self:setCurrPageInfo(list.title, "boardType", list.board_type)
			self:setCurrPageInfo(list.title, "totalPage", list.total_page)
			self:setCurrPageInfo(list.title, "nums", list.nums)
		end
	end

	self:saveData(data)

	if func then
		func(true)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/09 17:52:09
-- @desc 设置缓存时间
function RankingUI:setCacheTime(sec)
	self.__cacheTime = Helper:getDef(sec, 10 * 60)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/09 18:00:35
-- @desc 获取缓存时间
function RankingUI:getCacheTime()
	return Helper:getDef(self.__cacheTime, 10 * 60)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/09 18:11:02
-- @desc 存储数据
function RankingUI:saveData(data)
	data = Helper:getDef(data, {})
	DataBase:setLuaTable("rankingData", data)
	self.__data = data -- add by XiaoZhiWei 2017/08/09 13:59:12 稍微占一点点内存,但能提高效率
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/10 09:40:05
-- @desc 获取数据
function RankingUI:getData()
	if MapIsEmpty(self.__data) == true then
		self.__data = DataBase:getLuaTable("rankingData")
	else
	end
	return self.__data	
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/10 15:01:45
-- @desc 页面唤醒方法
function RankingUI:onResume()
	self:setCurrentPage(self:getCurrPageNum(self.__currTitle))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/12 17:07:04
-- @desc 测试 模拟
function RankingUI:getTestData()
	local jsonData = [[{"errcode":0,"data":[{"title":"高手榜","type":"total_board","header":["名次","昵称","武学造诣"],"body":{"list":[{"userid":3046228744,"lv":1262,"wuxing":20,"gengu":19,"shenfa":1900,"liliang":22000,"qianneng":12456764,"jingyan":202913319,"sex":"男","looks":27,"fuyuan":41,"menpai":"天山派","real_menpai":"天山派","kongfu":1031.7222222222,"name":"死**人","exp":202913319,"money":30460439,"yueli":9270,"xiayi":13018,"gold":30620,"portrait":"","head":{"itemId":"mao110","id":1547},"dsc":"HIW返璞归真","yueka":"NO"},{"userid":3046228750,"lv":1255,"wuxing":23,"gengu":25,"shenfa":17,"liliang":15,"qianneng":45446476.945798,"jingyan":199739151.19551,"sex":"男","looks":40,"fuyuan":27,"menpai":"华山宗","real_menpai":"华山宗","kongfu":971.22222222222,"name":"西门狗蛋","exp":199739151.19551,"money":30996633.947191,"yueli":8888,"xiayi":27348,"gold":9000,"portrait":"mianju1000","head":"","dsc":"HIW返璞归真","yueka":"NO"},{"userid":3046228854,"lv":1251,"wuxing":23,"gengu":25,"shenfa":17,"liliang":15,"qianneng":45496664.886549,"jingyan":197918190.89665,"sex":"男","looks":40,"fuyuan":27,"menpai":"华山宗","real_menpai":"华山宗","kongfu":946.22222222222,"name":"司空叫兽","exp":197918190.89665,"money":31113171,"yueli":8798,"xiayi":27396.6,"gold":3600,"portrait":"mianju1000","head":"","dsc":"HIW返璞归真","yueka":"NO"},{"userid":3046228718,"lv":1183,"wuxing":29,"gengu":26,"shenfa":15,"liliang":10,"qianneng":21294245,"jingyan":167431135,"sex":"女","looks":101,"fuyuan":52,"menpai":"峨眉派","real_menpai":"峨眉派","kongfu":936.27777777778,"name":"莫云","exp":167431135,"money":7503057,"yueli":10297,"xiayi":11654,"gold":127570,"portrait":"mianju1002","head":{"id":7115,"itemId":"mao110"},"dsc":"HIW返璞归真","yueka":"NO"},{"userid":3046228704,"lv":1097,"wuxing":25,"gengu":27,"shenfa":16,"liliang":12,"qianneng":4008445.5951363,"jingyan":133797569.17898,"sex":"男","looks":50,"fuyuan":32,"menpai":"少林寺","real_menpai":"少林寺","kongfu":897.83333333333,"name":"汪山河","exp":133797569.17898,"money":5227682.9418555,"yueli":7940,"xiayi":7646.5,"gold":155220,"portrait":"","head":"","dsc":"HIW返 璞归真","yueka":"NO"},{"userid":3046228706,"lv":1092,"wuxing":25,"gengu":27,"shenfa":16,"liliang":12,"qianneng":3085346.2653927,"jingyan":131935121.11074,"sex":"男","looks":50,"fuyuan":32,"menpai":"少林寺","real_menpai":"少林寺","kongfu":896.61111111111,"name":"你好世界","exp":131935121.11074,"money":4650333,"yueli":7940,"xiayi":7646.5,"gold":155220,"portrait":"mianju1018","head":"","dsc":"HIW返璞归真","yueka":"NO"},{"userid":3046228710,"lv":1112,"wuxing":24,"gengu":18,"shenfa":16,"liliang":22,"qianneng":98898.995778018,"jingyan":139066553.83085,"sex":"男","looks":100,"fuyuan":35,"menpai":"桃花岛","real_menpai":"桃花岛","kongfu":856.66666666667,"name":"家丑","exp":139066553.83085,"money":32474463.560512,"yueli":5580,"xiayi":4853,"gold":2674,"portrait":"","head":{"id":1126,"itemId":"mianju1005"},"dsc":"HIW返璞归真","yueka":"NO"},{"userid":3046228316,"lv":1080,"wuxing":20,"gengu":24,"shenfa":21,"liliang":15,"qianneng":1559216.4700079,"jingyan":127629855.09637,"sex":"男","looks":21,"fuyuan":41,"menpai":"日月神教","real_menpai":"日月神教","kongfu":825.44444444444,"name":"哈哈哈","exp":127629855.09637,"money":21585108,"yueli":5668,"xiayi":2153,"gold":22730,"portrait":"","head":{"id":1912,"itemId":"mianju1015"},"dsc":"HIW深不可测","yueka":"NO"},{"userid":3046228334,"lv":964,"wuxing":23,"gengu":21,"shenfa":16,"liliang":20,"qianneng":18568361.523624,"jingyan":90768257.63065,"sex":"女","looks":60,"fuyuan":33,"menpai":"华山宗","real_menpai":"华山宗","kongfu":771.83333333333,"name":"顾小萱","exp":90768257.63065,"money":18281317,"yueli":5324,"xiayi":4460,"gold":2700,"portrait":"","head":{"id":493,"itemId":"mao108"},"dsc":"HIW天人合一","yueka":"NO"},{"userid":3046228433,"lv":810,"wuxing":25,"gengu":35,"shenfa":20,"liliang":70,"qianneng":3506549.1150334,"jingyan":54094186.368973,"sex":"男","looks":50,"fuyuan":40,"menpai":"慕容山庄","real_menpai":"慕容山庄","kongfu":727,"name":"夜 寰","exp":54094186.368973,"money":8116913.6881203,"yueli":21226.75,"xiayi":10941.5,"gold":252,"portrait":"mianju1007","head":"","dsc":"HIW空前绝后","yueka":"NO"}],"mine":{"userid":3046228767,"lv":1264,"wuxing":22,"gengu":21,"shenfa":15,"liliang":111111,"qianneng":71692159,"jingyan":204081638,"sex":"男","looks":51,"fuyuan":51,"menpai":"少林寺","real_menpai":"少林寺","kongfu":953.33333333333,"name":"柏伟帮","exp":204081638,"money":14440622,"yueli":5835,"xiayi":4812,"gold":88096,"portrait":"mianju1023","head":"","dsc":"HIW返璞归真","sort":24,"yueka":"NO"}}},{"title":"少林寺","type":"menpai_board","header":["名次","昵称","武学造 诣"],"body":{"list":[{"userid":3046228704,"lv":1097,"wuxing":25,"gengu":27,"shenfa":16,"liliang":12,"qianneng":4008445.5951363,"jingyan":133797569.17898,"sex":"男","looks":50,"fuyuan":32,"menpai":"少林寺","real_menpai":"少林寺","kongfu":897.83333333333,"name":"汪山河","exp":133797569.17898,"money":5227682.9418555,"yueli":7940,"xiayi":7646.5,"gold":155220,"portrait":"","head":"","dsc":"HIW返璞归真","yueka":"NO"},{"userid":3046228706,"lv":1092,"wuxing":25,"gengu":27,"shenfa":16,"liliang":12,"qianneng":3085346.2653927,"jingyan":131935121.11074,"sex":"男","looks":50,"fuyuan":32,"menpai":"少林寺","real_menpai":"少林寺","kongfu":896.61111111111,"name":"你好世界","exp":131935121.11074,"money":4650333,"yueli":7940,"xiayi":7646.5,"gold":155220,"portrait":"mianju1018","head":"","dsc":"HIW返璞归真","yueka":"NO"},{"userid":3046228614,"lv":996,"wuxing":26,"gengu":2000,"shenfa":150,"liliang":2500,"qianneng":7873251,"jingyan":100121278,"sex":"男","looks":23,"fuyuan":17,"menpai":"少林寺","real_menpai":"少林寺","kongfu":497.44444444444,"name":"祖明轩","exp":100121278,"money":9047955,"yueli":681,"xiayi":-4,"gold":0,"portrait":"xinwu200_06","head":"","dsc":"RED所向披靡","yueka":"NO"}],"mine":{"userid":3046228767,"lv":1264,"wuxing":22,"gengu":21,"shenfa":15,"liliang":111111,"qianneng":71692159,"jingyan":204081638,"sex":"男","looks":51,"fuyuan":51,"menpai":"少林寺","real_menpai":"少林寺","kongfu":953.33333333333,"name":"柏伟帮","exp":204081638,"money":14440622,"yueli":5835,"xiayi":4812,"gold":88096,"portrait":"mianju1023","head":"","dsc":"HIW返璞归真","sort":4,"yueka":"NO"}}},{"title":"财富榜","type":"total_board","header":["名次","昵称","财富描述"],"body":{"list":[{"userid":3046228595,"lv":476,"wuxing":9999999999999,"gengu":111111,"shenfa":111111,"liliang":111111,"qianneng":1111302,"jingyan":11111111,"sex":"女","looks":24,"fuyuan":19,"menpai":"官府","real_menpai":"官府","kongfu":174.22222222222,"name":"童颜","exp":11111111,"money":99999997599,"yueli":20,"xiayi":9999999988,"gold":0,"portrait":"","head":"","dsc":"HIY富HIG甲天HIY下","yueka":"NO"},{"userid":3046228744,"lv":1262,"wuxing":20,"gengu":19,"shenfa":1900,"liliang":22000,"qianneng":12456764,"jingyan":202913319,"sex":"男","looks":27,"fuyuan":41,"menpai":"天山派","real_menpai":"天山派","kongfu":1031.7222222222,"name":"死**人","exp":202913319,"money":30460439,"yueli":9270,"xiayi":13018,"gold":30620,"portrait":"","head":{"itemId":"mao110","id":1547},"dsc":"HIY财可通神","yueka":"NO"},{"userid":3046228710,"lv":1112,"wuxing":24,"gengu":18,"shenfa":16,"liliang":22,"qianneng":98898.995778018,"jingyan":139066553.83085,"sex":"男","looks":100,"fuyuan":35,"menpai":"桃花岛","real_menpai":"桃花岛","kongfu":856.66666666667,"name":"家丑","exp":139066553.83085,"money":32474463.560512,"yueli":5580,"xiayi":4853,"gold":2674,"portrait":"","head":{"id":1126,"itemId":"mianju1005"},"dsc":"HIY财可通神","yueka":"NO"},{"userid":3046228750,"lv":1255,"wuxing":23,"gengu":25,"shenfa":17,"liliang":15,"qianneng":45446476.945798,"jingyan":199739151.19551,"sex":"男","looks":40,"fuyuan":27,"menpai":"华山宗","real_menpai":"华山宗","kongfu":971.22222222222,"name":"西门狗蛋","exp":199739151.19551,"money":30996633.947191,"yueli":8888,"xiayi":27348,"gold":9000,"portrait":"mianju1000","head":"","dsc":"HIY财可通神","yueka":"NO"},{"userid":3046228854,"lv":1251,"wuxing":23,"gengu":25,"shenfa":17,"liliang":15,"qianneng":45496664.886549,"jingyan":197918190.89665,"sex":"男","looks":40,"fuyuan":27,"menpai":"华山宗","real_menpai":"华山宗","kongfu":946.22222222222,"name":"司空叫兽","exp":197918190.89665,"money":31113171,"yueli":8798,"xiayi":27396.6,"gold":3600,"portrait":"mianju1000","head":"","dsc":"HIY财可通神","yueka":"NO"},{"userid":3046228316,"lv":1080,"wuxing":20,"gengu":24,"shenfa":21,"liliang":15,"qianneng":1559216.4700079,"jingyan":127629855.09637,"sex":"男","looks":21,"fuyuan":41,"menpai":"日月神教","real_menpai":"日月神教","kongfu":825.44444444444,"name":"哈哈哈","exp":127629855.09637,"money":21585108,"yueli":5668,"xiayi":2153,"gold":22730,"portrait":"","head":{"id":1912,"itemId":"mianju1015"},"dsc":"HIY财可通神","yueka":"NO"},{"userid":3046228704,"lv":1097,"wuxing":25,"gengu":27,"shenfa":16,"liliang":12,"qianneng":4008445.5951363,"jingyan":133797569.17898,"sex":"男","looks":50,"fuyuan":32,"menpai":"少林寺","real_menpai":"少林寺","kongfu":897.83333333333,"name":"汪山河","exp":133797569.17898,"money":5227682.9418555,"yueli":7940,"xiayi":7646.5,"gold":155220,"portrait":"","head":"","dsc":"HIY财可通神","yueka":"NO"},{"userid":3046228718,"lv":1183,"wuxing":29,"gengu":26,"shenfa":15,"liliang":10,"qianneng":21294245,"jingyan":167431135,"sex":"女","looks":101,"fuyuan":52,"menpai":"峨眉派","real_menpai":"峨眉派","kongfu":936.27777777778,"name":"莫云","exp":167431135,"money":7503057,"yueli":10297,"xiayi":11654,"gold":127570,"portrait":"mianju1002","head":{"id":7115,"itemId":"mao110"},"dsc":"HIY财可通神","yueka":"NO"},{"userid":3046228706,"lv":1092,"wuxing":25,"gengu":27,"shenfa":16,"liliang":12,"qianneng":3085346.2653927,"jingyan":131935121.11074,"sex":"男","looks":50,"fuyuan":32,"menpai":"少林寺","real_menpai":"少林寺","kongfu":896.61111111111,"name":"你好世界","exp":131935121.11074,"money":4650333,"yueli":7940,"xiayi":7646.5,"gold":155220,"portrait":"mianju1018","head":"","dsc":"HIY财可通神","yueka":"NO"},{"userid":3046228334,"lv":964,"wuxing":23,"gengu":21,"shenfa":16,"liliang":20,"qianneng":18568361.523624,"jingyan":90768257.63065,"sex":"女","looks":60,"fuyuan":33,"menpai":"华山宗","real_menpai":"华山宗","kongfu":771.83333333333,"name":"顾小萱","exp":90768257.63065,"money":18281317,"yueli":5324,"xiayi":4460,"gold":2700,"portrait":"","head":{"id":493,"itemId":"mao108"},"dsc":"HIG富甲一方","yueka":"NO"}],"mine":{"userid":3046228767,"lv":1264,"wuxing":22,"gengu":21,"shenfa":15,"liliang":111111,"qianneng":71692159,"jingyan":204081638,"sex":"男","looks":51,"fuyuan":51,"menpai":"少林寺","real_menpai":"少林寺","kongfu":953.33333333333,"name":"柏伟帮","exp":204081638,"money":14440622,"yueli":5835,"xiayi":4812,"gold":88096,"portrait":"mianju1023","head":"","dsc":"HIY财可通神","sort":26,"yueka":"NO"}}},{"title":"名人堂","type":"total_board","header":["名次","昵称","江湖阅历"],"body":{"list":[{"userid":3046228408,"lv":844,"wuxing":10000000,"gengu":10000000,"shenfa":10000000,"liliang":10000000,"qianneng":359280,"jingyan":61026672,"sex":"女","looks":31,"fuyuan":18,"menpai":"古墓派","real_menpai":"古墓派","kongfu":614.66666666667,"name":"无名烧酒","exp":61026672,"money":69,"yueli":99999,"xiayi":50000,"gold":300,"portrait":"","head":"","dsc":"HIY阅尽繁华","yueka":"NO"},{"userid":3046228433,"lv":810,"wuxing":25,"gengu":35,"shenfa":20,"liliang":70,"qianneng":3506549.1150334,"jingyan":54094186.368973,"sex":"男","looks":50,"fuyuan":40,"menpai":"慕容山庄","real_menpai":"慕容山庄","kongfu":727,"name":"夜寰","exp":54094186.368973,"money":8116913.6881203,"yueli":21226.75,"xiayi":10941.5,"gold":252,"portrait":"mianju1007","head":"","dsc":"HIY通晓天下","yueka":"NO"},{"userid":3046228718,"lv":1183,"wuxing":29,"gengu":26,"shenfa":15,"liliang":10,"qianneng":21294245,"jingyan":167431135,"sex":"女","looks":101,"fuyuan":52,"menpai":"峨眉派","real_menpai":"峨眉派","kongfu":936.27777777778,"name":"莫云","exp":167431135,"money":7503057,"yueli":10297,"xiayi":11654,"gold":127570,"portrait":"mianju1002","head":{"id":7115,"itemId":"mao110"},"dsc":"HIW饱经沧桑","yueka":"NO"},{"userid":3046228744,"lv":1262,"wuxing":20,"gengu":19,"shenfa":1900,"liliang":22000,"qianneng":12456764,"jingyan":202913319,"sex":"男","looks":27,"fuyuan":41,"menpai":"天山派","real_menpai":"天山派","kongfu":1031.7222222222,"name":"死**人","exp":202913319,"money":30460439,"yueli":9270,"xiayi":13018,"gold":30620,"portrait":"","head":{"itemId":"mao110","id":1547},"dsc":"HIW万里留踪","yueka":"NO"},{"userid":3046228750,"lv":1255,"wuxing":23,"gengu":25,"shenfa":17,"liliang":15,"qianneng":45446476.945798,"jingyan":199739151.19551,"sex":"男","looks":40,"fuyuan":27,"menpai":"华山宗","real_menpai":"华山宗","kongfu":971.22222222222,"name":"西门狗蛋","exp":199739151.19551,"money":30996633.947191,"yueli":8888,"xiayi":27348,"gold":9000,"portrait":"mianju1000","head":"","dsc":"HIB阅人无数","yueka":"NO"},{"userid":3046228854,"lv":1251,"wuxing":23,"gengu":25,"shenfa":17,"liliang":15,"qianneng":45496664.886549,"jingyan":197918190.89665,"sex":"男","looks":40,"fuyuan":27,"menpai":"华山宗","real_menpai":"华山宗","kongfu":946.22222222222,"name":"司空叫兽","exp":197918190.89665,"money":31113171,"yueli":8798,"xiayi":27396.6,"gold":3600,"portrait":"mianju1000","head":"","dsc":"HIB阅人无数","yueka":"NO"},{"userid":3046228706,"lv":1092,"wuxing":25,"gengu":27,"shenfa":16,"liliang":12,"qianneng":3085346.2653927,"jingyan":131935121.11074,"sex":"男","looks":50,"fuyuan":32,"menpai":"少林寺","real_menpai":"少林寺","kongfu":896.61111111111,"name":"你好世界","exp":131935121.11074,"money":4650333,"yueli":7940,"xiayi":7646.5,"gold":155220,"portrait":"mianju1018","head":"","dsc":"HIB历经风雨","yueka":"NO"},{"userid":3046228704,"lv":1097,"wuxing":25,"gengu":27,"shenfa":16,"liliang":12,"qianneng":4008445.5951363,"jingyan":133797569.17898,"sex":"男","looks":50,"fuyuan":32,"menpai":"少林寺","real_menpai":"少林寺","kongfu":897.83333333333,"name":"汪山河","exp":133797569.17898,"money":5227682.9418555,"yueli":7940,"xiayi":7646.5,"gold":155220,"portrait":"","head":"","dsc":"HIB历经风雨","yueka":"NO"},{"userid":3046228316,"lv":1080,"wuxing":20,"gengu":24,"shenfa":21,"liliang":15,"qianneng":1559216.4700079,"jingyan":127629855.09637,"sex":"男","looks":21,"fuyuan":41,"menpai":"日月神教","real_menpai":"日月神教","kongfu":825.44444444444,"name":"哈哈哈","exp":127629855.09637,"money":21585108,"yueli":5668,"xiayi":2153,"gold":22730,"portrait":"","head":{"id":1912,"itemId":"mianju1015"},"dsc":"YEL见多识广","yueka":"NO"},{"userid":3046228824,"lv":623,"wuxing":22,"gengu":23,"shenfa":17,"liliang":18,"qianneng":262716.73021796,"jingyan":24651086.263753,"sex":"男","looks":20,"fuyuan":31,"menpai":"丐帮","real_menpai":"丐帮","kongfu":501.11111111111,"name":"死**人","exp":24651086.263753,"money":2262674,"yueli":5586,"xiayi":1076.5,"gold":800,"portrait":"mianju1010","head":{"id":2034,"itemId":"mao110"},"dsc":"YEL见多识广","yueka":"NO"}],"mine":{"userid":3046228767,"lv":1264,"wuxing":22,"gengu":21,"shenfa":15,"liliang":111111,"qianneng":71692159,"jingyan":204081638,"sex":"男","looks":51,"fuyuan":51,"menpai":"少林寺","real_menpai":"少林寺","kongfu":953.33333333333,"name":"柏伟帮","exp":204081638,"money":14440622,"yueli":5835,"xiayi":4812,"gold":88096,"portrait":"mianju1023","head":"","dsc":"YEL见多识广","sort":26,"yueka":"NO"}}}],"sig":{"time":1494579933.1174,"nouce":"cQkvsz","signature":"e0dd4b08d10998fe8e2b351bef7459f8"}}]]
	local data = json.decode(jsonData).data
	return data
end

-- add by XiaoZhiWei 2017/05/12 17:11:39 测试插入接口
function RankingUI:testInsertData()
	print("RankingUI:dInsertData()")
	for i=1,1 do
		self:initAndSaveData(self:getTestData(), i)
	end
end

-- add by XiaoZhiWei 2017/05/12 17:55:56 测试清除数据
function RankingUI:testClearData()
	print("RankingUI:testClearData()")
	self:saveData(nil)
end

-- add by XiaoZhiWei 2017/05/15 15:35:15 测试获取指定页数的数据
function RankingUI:testGetOnePageData()
	print("RankingUI:testGetOnePageData()")
	local tab =
	{
		{
			"高手榜",
			1,
			function()  end
		},
		{
			"金钱榜",
			2,
			function()end
		},
		{
			"少林寺",
			2,
			function()end
		}
	}


	for k,v in pairs(tab) do
		print("self:getRankDataWithPage(v[1], v[2], v[3])", self:getRankDataWithPage(v[1], v[2], v[3]))
		Helper:print_lua_table(self:getRankDataWithPage(v[1], v[2], v[3]))
	end
end


Helper:classDefNodeGetInstance(RankingUI)
return RankingUI
0000000000000
local QiXiRankLayer = class("QiXiRankLayer", LayerEx)

function QiXiRankLayer:create()
	local p = QiXiRankLayer:new()
	p:init()
	return p
end

function QiXiRankLayer:init()
	self._round = require("Layer/ActionUI/QiXiRankLayerUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点

	self.PageView_ranking:setScrollDurationWithNumber(0.5)
	-- 初始化变量
	self._rankings = {}-- 存储当前的排行榜信息

    self:setButtonback()

	self:setVisible(false)

	self:schedule(
    	function(ft)
    		self:updateCategory()
    	end, 0)
end

function QiXiRankLayer:showLayer()
	self.PageView_ranking:setTouchEnabled(false)
    self.rankType = 1 --1:每日排行，2:总排行
    self.rankTypeMap = {
        {title ="今日榜"},
	    {title ="总榜"}
    }

	-- 校准服务器时间
	HttpManagerEx:getTime(function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 and errcode == 0 and data.time ~= nil then
			SetTime(tonumber(data.time))
			self:getData()		
		else
			PopText(tostring(errmsg))
		end
	end)
end

--获取排行榜信息
function QiXiRankLayer:getData()
	--获取排行榜信息
	HttpManagerEx:getQiXiRankBoard(function(status, errcode, errmsg, data)
		print(status,errcode)
		if status == 200 then
			if 0 == errcode then
				if DEBUG_MODE == 1 then
					Helper:print_lua_table(data)
				end
				self:initRankingAllPage(data)
				
				self._showLayerTime = GetTime() --@desc 用来记录页面打开时间，避免用户在0点前点开界面后，0点后再领取奖励的情况。
				self.PageView_ranking:setTouchEnabled(true)
				self:show()
			else
				PopText(tostring(errmsg))
			end
		else
			PopText("网络请求出错,请换个网络环境再试!")
		end
	end, IS_SHOW_WAITING)
end

-- 初始化rankingPage
function QiXiRankLayer:initRankingAllPage(data)
	self.Panel_category:removeAllChildren()
	self.PageView_ranking:removeAllPages()

	self._rankings = {}

	for i,v in ipairs(data) do
		self._rankings[i] =
		{
			category = ""
		}
		self:createOnePage(i, v)
	end
end

-- 排行榜单页初始化
function QiXiRankLayer:createOnePage(index, params)
	if index == nil or MapIsEmpty(params) then
		return
	end

	local layout = self.PageView_ranking:getPageByIndex(index-1)
	local rankingChildUI
	if layout == nil then
		layout = ccui.Layout:create()
		self.PageView_ranking:addPage(layout)
		rankingChildUI = require("Layer/RankingUI/RankingChildUI2.lua").create()['root']
		Helper:convertUI(rankingChildUI)
		rankingChildUI.ListView_ranking:setSwallowTouches(false)
		-- 设置itemModel
		local itemModel = rankingChildUI.ListView_ranking:getItem(0)
		rankingChildUI.ListView_ranking:setItemModel(itemModel)
		rankingChildUI.ListView_ranking:removeAllItems()

		layout:addChild(rankingChildUI)
	else
		rankingChildUI = layout:getChildren()[1]
	end

	self:createCategory(index, rankingChildUI,params,self.rankTypeMap[tonumber(params.type)].title)

	self:createListView(index,rankingChildUI,params)
end

-- 创建标题
function QiXiRankLayer:createCategory(index,rankingChildUI,data,title)
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
		text:enableOutline(cc.c4b(0, 0, 0, 255), 5)
		text:setTouchEnabled(true)
	end

	if index == 1 then
		text:setFontSize(60)
		text:setOpacity(255)
	else
		text:setFontSize(60)
		text:setOpacity(125)
	end

	text:releaseFunc(function()
		self.rankType = index

		self:createListView(index,rankingChildUI,data)
	end)
end

-- 创建列表
function QiXiRankLayer:createListView(index,rankingChildUI,data)
	local function gradeCast(num)
		local tab = {"壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾"}
		if tab[num] == nil then
			return tostring(num)
		end
		return tab[num]
	end

	self:updateCategory()
	self.PageView_ranking:playScrollPageAnim(self.rankType-1)
	self:delayFunc(0, function()
		self.PageView_ranking:getPageByIndex(self.rankType-1)
	end)

	rankingChildUI.ListView_ranking:removeAllItems()

	if MapIsEmpty(data.body.list) then
		rankingChildUI.ListView_ranking:setVisible(false)
		rankingChildUI.Text_Tips:setVisible(true)
	else
		rankingChildUI.ListView_ranking:setVisible(true)
		rankingChildUI.Text_Tips:setVisible(false)

		for i,listData in ipairs(data.body.list) do
			listData.sort = i
			listData.grade = gradeCast(i)
			local row = self:createPanel(listData)
			rankingChildUI.ListView_ranking:pushBackCustomItem(row)
		end
	end

	self:setButtonQuit(data, rankingChildUI)
	self:setDscTextAndAwardText(tonumber(data.type),data.body.jiangli,rankingChildUI)
	self:rankDsc(tonumber(data.type),data.body.my_score,rankingChildUI)
end

-- 创建一行记录信息
function QiXiRankLayer:createPanel(userData)
	if MapIsEmpty(userData) then
		return nil
	end

	local panel = self.Panel_item:clone()
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
		imagePath = role:getFaceRankFrame(userData.portrait, true, userData.title_type, userData.title_id)
	else
		imagePath = role:getFaceRankFrame(userData.portrait, false, userData.title_type, userData.title_id)
	end

	panel.Image_kuang:loadTexture(imagePath)

    -- 设置图片大小
    local texture = cc.TextureCache:getInstance():getTextureForKey(imagePath);
    panel.Image_kuang:setSize(texture:getContentSize())

	local present = require("app.presenters.HeadView.HVDPresent"):create(panel.Image_looks,userData)
	present:showHead()

	panel.Text_name:setString(userData.name)
	panel.Text_pingjia:setString(userData.dsc)
	panel.Text_jifen:setString(userData.score)

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
function QiXiRankLayer:updateCategory()
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

-- 关闭按钮
function QiXiRankLayer:setButtonback()
	self.Button_back:releaseFunc(function()
        PopupLayerController:hideLayer("QiXiRankLayer", function(layer)
            self.PageView_ranking:setTouchEnabled(false)
            self:hide()
        end)
	end)
end

-- 领取按钮
function QiXiRankLayer:setButtonQuit(data,rankingChildUI)
	local isget = data.body.is_get
	local awardList = data.body.jiangli
	local rankType = tonumber(data.type)

    if isget == nil or isget == "Y" then
        rankingChildUI.Button_linqu:setEnabled(false)
    elseif isget == "N" then
        rankingChildUI.Button_linqu:setEnabled(true)
    else
        rankingChildUI.Button_linqu:setEnabled(false)
    end

    rankingChildUI.Button_linqu:releaseFunc(function()
		local role = User:getRole()
		if not MapIsEmpty(awardList) then
			if role:checkCanBuyTwoOrMoreThings(awardList) == false then
				return
			end
		end
		if Helper:diffWithDate(GetTime(), self._showLayerTime) >= 1 then
			PopText("奖励已刷新，请重新进入")
			return
		end
		
        TransCheck:getTransIdFromWeb(function(transId)
            HttpManagerEx:getQiXiRankBoatReward(transId,rankType,function(status, errcode, errmsg, data1)
                if status == 200 then
                    if 0 == errcode then
                        if not MapIsEmpty(data1) then
                            for itemId,num in pairs(data1) do
                                local item = Item:getOneItemByKey(itemId)
								if item then
									role:addItemCount(itemId,tonumber(num))
									PopText("获得物品"..item.name.."X"..tostring(num))
								end
                            end
                        else
                            print("没有奖励")
                        end
						data.body.is_get = "Y" --设置为已领取状态
						self:createListView(rankType,rankingChildUI,data)
                    else
                        PopText(tostring(errmsg))
                    end
                else
                    PopText("网络请求出错,请换个网络环境再试!")
                end
            end, IS_SHOW_WAITING)
        end)
    end)
end

function QiXiRankLayer:rankDsc(rankType,myScore,rankingChildUI)
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	rankingChildUI.Panel_tips:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			rankingChildUI.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
            local text = ""
			local text1 = ""
            if rankType == 1 then
                text = "完成一次七夕情书任务，时间越短，积分越高！\n \n每日排行榜奖励：\n1、前3名玩家可以获得七夕结缘礼盒！\n2、后7名玩家可以获得七夕缘起礼盒！"
				text1 = "我的今日积分："
            else
                text = "总排行榜奖励：\n1、总积分最高的玩家将会获得七夕缘定礼盒，可开出金牌家丁面具！\n2、2-10名玩家将会获得七夕情缘礼盒，可开出西厢记和风流家丁面具！\n3、每天完成5次任务、且至少参与活动8天的玩家，如果未上榜，可领到一个风流家丁面具，已兑换过面具的玩家则能领取一个诚挚礼盒。"
				text1 = "我的总积分："
            end
			text = text.."\n"..text1..myScore
			dialog:show(text)
			dialog:setPanelBack(function()
				rankingChildUI.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			rankingChildUI.Image_7:setVisible(true)
		end
	end)
end

function QiXiRankLayer:setDscTextAndAwardText(rankType,awardList,rankingChildUI)
    if rankType == 1 then
        rankingChildUI.Text_award:setString("七夕结缘礼盒*1")
        rankingChildUI.Text_dsc:setString("奖励说明和我的积分查询")
    else
        rankingChildUI.Text_award:setString("七夕缘定礼盒*1")
        rankingChildUI.Text_dsc:setString("奖励说明和我的积分查询")
    end
	if not MapIsEmpty(awardList) then
		local count = 1
		local awardText = ""
		for itemId,num in pairs(awardList) do
			local item = Item:getOneItemByKey(itemId)
			if item then
				local itemName = item:getNcname(item.name) --去除名字颜色
				if item then
					if count == 1 then
						awardText = itemName.."*"..tostring(num)
					else
						awardText = awardText.."、"..itemName.."*"..tostring(num)
					end
					count = count + 1
				end
			end
		end
		rankingChildUI.Text_award:setString(awardText)
	end
end

Helper:classDefNodeGetInstance(QiXiRankLayer)
return QiXiRankLayer
000000
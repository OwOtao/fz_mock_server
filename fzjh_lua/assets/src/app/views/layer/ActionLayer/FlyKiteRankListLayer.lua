local FlyKiteRankListLayer = class("FlyKiteRankListLayer", cc.Layer)
function FlyKiteRankListLayer:create()
	local p = FlyKiteRankListLayer:new()
	p:init()
	return p
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 16:08:09
-- @desc 奖励列表
local rewardList =
{

}
local SortList = {}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:03:50
-- @desc 首充页面测试方法
function FlyKiteRankListLayer:test()
	-- local layer = self:getInstance()
	self:getReward()
end

function FlyKiteRankListLayer:init()
	local UI = require("Layer/ActionUI/FlyKiteRankListUI.lua").create()['root']
	UI:addTo(self)
	self:setVisible(false)
	-- self:hide()
	Helper:convertUIByParent(self)
	self.Button_pageUp:setVisible(true)
	self.Button_pageDown:setVisible(true)
	self.Text_page:setVisible(true)
end
function FlyKiteRankListLayer:initUI(tab)
	local table = tab["body"]["list"]
	local function gradeCast(num)
		local tab = {"壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾"}
		if tab[num] == nil then
			return tostring(num)
		end
		return tab[num]
	end
	local function setTextSizeFont(panel,userData)
		if userData.sort <= 3 then
			panel.Text_mingci:setFontSize(72)
		elseif userData.sort <= 10 then
			panel.Text_mingci:setFontSize(60)
		elseif string.len(userData.sort) >=4 then
			panel.Text_mingci:setFontSize(48)
		end
	end
	-- self.Panel_category.Text_Title:setString("春分积分榜")
	self.Panel_category.Text_Title:setString("门派积分排行榜")
	self.ListView_ranking:removeAllItems()
	if table ~= nil then
		for k,v in pairs(table) do
			local panel = self:createPanel(v)
			panel.Text_mingci:setString(gradeCast(v.sort))
			setTextSizeFont(panel,v)
			self.ListView_ranking:pushBackCustomItem(panel)
		end
		if MapIsEmpty(tab) == true or MapIsEmpty(tab.body) == true  then
			self.Panel_attr_preview.Button_Reward:setEnabled(true)
		else
			if tab["body"].is_get == nil or  tab["body"].is_get == "Y" then
				self.Panel_attr_preview.Button_Reward:setEnabled(false)
			elseif tab["body"].is_get == "N" then
				self.Panel_attr_preview.Button_Reward:setEnabled(true)
			else
				self.Panel_attr_preview.Button_Reward:setEnabled(false)
			end
		end
	end
end
function FlyKiteRankListLayer:clonePanel(panel)
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
function FlyKiteRankListLayer:setBack()
	self.Button_quit:releaseFunc(function()
		self:hide()
	end)
end
function FlyKiteRankListLayer:createPanel(userData)
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
	panel.Text_pingjia:setString(userData.score)
	panel.Text_menpai:setString(userData.menpai)
	-- panel.Text_time:setString(userData.dataTime)
	--点击名字查看玩家资料
	panel.Image_looks:setTouchEnabled(true)
	panel.Image_looks:releaseFunc(function()
		----本周排行从本地取数据
		print("人物的UserId:",userData.userid)
		HttpManagerEx:getUserInfo(tonumber(userData.userid), 0, function(status, errcode, errmsg, data)
				if 200 == status then
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

	--点击对手的信息
	-- panel.Text_pingjia:setString(userData.daily_point)
	return panel
end
function FlyKiteRankListLayer:getLongZhouDailyBoard()
	--排名的接口
	HttpManagerEx:getLongZhouDailyBoard(1,function(status, errcode, errmsg, data)
		if status == 200 then
			if 0 == errcode then
				SortList = Helper:getDef(data, {})
				self.pageNum = 1
				self:initUI(self:getPageData(self.pageNum))
				self:setPageNum(self.pageNum)
				self:setButtonPageUp()
				self:setButtonPageDdown()
				self:show()
			else
				PopText(tostring(errmsg))
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end
function FlyKiteRankListLayer:getPageData(num)
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
function FlyKiteRankListLayer:setButtonPageUp()
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
		self:initUI(self:getPageData(self.pageNum))
		self:setPageNum(self.pageNum)
		self._pageUpTime = GetTime()
	end)
end
function FlyKiteRankListLayer:setButtonPageDdown()
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
		if self.pageNum == 3 then
			return
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
		if PRINT_MODE == 1 then
			print(" ",self.pageNum)
		end
		self:initUI(self:getPageData(self.pageNum))
		self:setPageNum(self.pageNum)
		self._pageDownTime = GetTime()

	end)
end
function FlyKiteRankListLayer:setPageNum(num)
	if not num then
		num = 1
	end
	self.Text_page:setString(tostring(num).."/10")
end
--奖励预览
function FlyKiteRankListLayer:previeReward()
	self.Button_Reward_Preview:releaseFunc(function ()
		HttpManagerEx:getDuanwuRewardNotice(1,function(status, errcode, errmsg, data)--getBoatPreviewRewardList
			if PRINT_MODE == 1 then
				print("strstrstr.........FlyKiteRankListLayer.........")
				Helper:print_lua_table(data)
			end
			if status == 200 then
			    if 0 == errcode then
					local str = self:dealString(data["content"])
					rewardList = Helper:getDef(data.jiangli, {})
					rewardList.is_get =Helper:getDef(data.is_get, "Y")
					if data.is_get == "N" then
						self.Panel_attr_preview.Button_Reward:setEnabled(true)
					else
						self.Panel_attr_preview.Button_Reward:setEnabled(false)
					end
					self:initRichTextPreview()
					self:printPreview(str)
					self.Panel_attr_preview:setVisible(true)
					self.Panel_attr_preview.Text_Preview_Title:setString("门派积分奖励")
					self.Panel_attr_preview.Panel_back:releaseFunc(function()
						self.Panel_attr_preview:setVisible(false)
					end)
				else
					PopText(tostring(errmsg))
				end
			else
				PopText(errmsg)	
			end
			if PRINT_MODE == 1 then
				Helper:print_lua_table(data)
			end
		end, IS_SHOW_WAITING)

	end)
end
function FlyKiteRankListLayer:getReward()
	self:getLongZhouDailyBoard()
	self:setBack()
	self:previeReward()
	self.Panel_attr_preview.Button_Reward:releaseFunc(function()
		-- if GetTime() > Helper:getTimeStampWithStringDate("20180401", 12) then
			if rewardList.is_get == "N" then
				self.Panel_attr_preview.Button_Reward:setEnabled(true)
				print("奖励没有领取，可以领取奖励")
				self.Panel_attr_preview.Button_Reward:setTouchEnabled(true)
				self:getDailyReward(rewardList)
			else
				self.Panel_attr_preview.Button_Reward:setEnabled(false)
				self.Panel_attr_preview.Button_Reward:setTouchEnabled(false)
				PopText("奖励已经领取")
			end
		-- else
		-- 	PopText("活动未结束，请于4月1日12点后-4月2日内再来领取奖励")
		-- end
	end)
end
function FlyKiteRankListLayer:dealString(str)
	if str == nil or str == "" then
		return
	end
	local strNotice = ""
	strNotice = string.gsub(str,"?","\n")
	return strNotice
end
function FlyKiteRankListLayer:printPreview(str, verticalSpace)
	print(str)
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_Print:getRichText():getNewContentSizeHeight()
	if textHeight >= 4000 then
		self:initRichTextPreview()
	end
	self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 48)
	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_Print:pushBackNewLine()
		self.RichText_Print:pushBackNewLine(verticalSpace)
		-- self.Panel_attr_preview.Panel_shelter:setVisible(true)
		self.RichText_Print:setCascadeOpacity(0)
		self:delayFunc(0.4,function ()
			self.RichText_Print:jumpToTop()
			-- self.Panel_attr_preview.Panel_shelter:setVisible(false)
			self.RichText_Print:setCascadeOpacity(255)
		end)
	end
end
function FlyKiteRankListLayer:initRichTextPreview()
	local x, y = self.Panel_attr_preview.Panel_dscArea:getPosition()
	local size = self.Panel_attr_preview.Panel_dscArea:getContentSize()
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_attr_preview.Panel_dscArea:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_attr_preview.Panel_dscArea:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
end
function FlyKiteRankListLayer:getDailyReward(itemList)
	local function getBoatReward(transId)
		local role = User:getRole()
		local canReward = true
		itemList.daoju = Helper:getDef(itemList.daoju,{})
		if MapIsEmpty(itemList.daoju) == false then
			canReward = role:checkCanBuyTwoOrMoreThings(itemList.daoju)
		end
		if canReward == false then
			-- PopText("背包空间不足,无法领取")
			self.Panel_attr_preview.Button_Reward:setEnabled(true)
			self.Panel_attr_preview.Button_Reward:setTouchEnabled(true)
			return
		end

		HttpManagerEx:getBoatReward(transId,1,function(status,errcode,errmsg,data)--getBoatReward
			if status == 200 then
				if errcode == 0 then
					if not MapIsEmpty(data.daoju) then
						for k,v in pairs(itemList.daoju) do
							local itemAttr = Item:getOneItemByKey(k)
							PopText("获得物品 "..tostring(itemAttr.name).. " X "..tostring(v))
							role:addItemCount(k, v)
						end
					end
					for k, v in pairs(itemList.shuxing) do
						role:addAttr(k,tonumber(v))
						PopText(role:getCHAttrName(k).."+"..tostring(v))
					end

					self.Panel_attr_preview.Button_Reward:setTouchEnabled(false)
					self.Panel_attr_preview.Button_Reward:setEnabled(false)
				else
					PopText(tostring(errmsg))
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end
	TransCheck:getTransIdFromWeb(function(transId)
		getBoatReward(transId)
	end)
end
Helper:classDefNodeGetInstance(FlyKiteRankListLayer)
return FlyKiteRankListLayer
00000000000000
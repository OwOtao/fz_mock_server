local BiWu = require("app.models.BiWu.BiWu")
local RoleInfoLayer = require("app.views.layer.RoleLayer.RoleInfoLayer")

local BoatPersonalRankingLayer = class("BoatPersonalRankingLayer",cc.Layer)

function BoatPersonalRankingLayer:create()
	local p = BoatPersonalRankingLayer:new()
	p:init()
	return p
end

local rewardList =
{

}

function BoatPersonalRankingLayer:init()
	local UI = require("Layer.BiWuUI.BiWuRankingUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setButtonQuit()
	self:initRichText()
	self:initRichTextPreview()

	self:rewardGetButton()
	self:previeReward()
	-----点击背景隐藏奖励领取界面
	self.Panel_attr.Panel_back:releaseFunc(function ()
		self.Panel_attr:setVisible(false)
	end)

	-----点击背景隐藏奖励预览界面
	self.Panel_attr_preview.Panel_back:releaseFunc(function ()
		self.Panel_attr_preview:setVisible(false)
	end)
    
    self.Panel_category.Text_Title:setString("个人积分排行榜")
	self:setVisible(false)
end

-- 关闭按钮
function BoatPersonalRankingLayer:setButtonQuit()
	self.Button_quit:releaseFunc(function()
		Audio:playEffect("fanHuiQuXiao")
		self:hide()
		----删除所有排行信息
		self.ListView_ranking:removeAllItems()
	end)
end

------奖励预览的打印
function BoatPersonalRankingLayer:initRichTextPreview()
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

--------------------------三个榜单的调用
---获取人气榜 GET get_fight_board/{type} 1历史人气 2本周人气 3挑战记录 
--人气榜
-- function BoatPersonalRankingLayer:showPeopleTop()
-- 	self:Ranking("本周人气榜")
-- end
-------------------------------------------------------------------------------------------------
function BoatPersonalRankingLayer:showLayer()
	self:setVisible(true)
	self:setCascadeOpacity(0)
	local action = cc.Sequence:create(
		cc.FadeIn:create(0.5)
		)
	self:runAction(action)
	self.Panel_attr_preview:setVisible(false)
	self.Panel_attr:setVisible(false)

	self.Panel_item.Text_pingjia:setFontSize(54)
	self.Text_RenQi:setVisible(true)
    self.Text_RenQi:setString("积分")
	-- self.Text_Time:setVisible(true)

	self.Text_people:setVisible(false)
	self.Text_Ranking:setVisible(false)

	self.Panel_item.Text_mingci:setVisible(true)

	self.Text_MingCi:setVisible(true)
	self.Text_NiCheng:setVisible(true)
end

----从这里提出标题  人气   排行数据
function BoatPersonalRankingLayer:createListViews(body)
	self.rankingData = Helper:getDef(body.jiangli, {})
	-- self.is_get = body.is_get
	self:createListView(body)
end

--创建一个列表显示对战记录
-- 创建列表
function BoatPersonalRankingLayer:createListView(data)
	-- Helper:print_lua_table(data)
	if MapIsEmpty(data) then
		return
	end

	local function gradeCast(num)
		local tab = {"壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾"}
		if tab[num] == nil then
			return tostring(num)
		end
		return tab[num]
	end


	if data and data.list then
		for i,listData in ipairs(data.list) do
			listData.sort = i
			listData.grade = gradeCast(i)
			local row = self:createPanel(listData)
			self.ListView_ranking:pushBackCustomItem(row)
		end
	else
	end

	if data.list ~= nil and #data.list < 10 then
		return
	end

    --自己的排名处理
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

	local row = self:createPanel(mine)
	if row ~= nil then
		self.ListView_ranking:pushBackCustomItem(row)
	end

	--领奖按钮是否可点击
	if data.is_get == "N" then
		self.Button_Reward:setTouchEnabled(true)
	    self.Button_Reward:setEnabled(true)
	else
		self.Button_Reward:setTouchEnabled(false)
	    self.Button_Reward:setEnabled(false)
	end

end

----------创建list显示的一行数据
-- 创建一行记录信息
function BoatPersonalRankingLayer:createPanel(userData)
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

	-- print("userData.grade = "..userData.grade)
	panel.Text_mingci:setString(tostring(userData.grade))
	if userData.sort <= 3 then
		panel.Text_mingci:setFontSize(72)
	elseif userData.sort <= 10 then
		panel.Text_mingci:setFontSize(60)
	elseif string.len(userData.sort) >=4 then
		panel.Text_mingci:setFontSize(48)
	end
	
	local headUI = require("app.views.ui.HeadView.HeadView"):create()
	panel:addChild(headUI)
	headUI:setPosition(cc.p(164,70))
	headUI:setScaleX(0.4)
    headUI:setScaleY(0.4)

	local headpresenter = require("app.presenters.HeadView.HeadViewPresenter"):create(Role:create(userData),headUI)
	headpresenter:setHeadClickFunc(
		function()
			HttpManagerEx:getUserInfo(tonumber(userData.userid), 0, function(status, errcode, errmsg, data)
				if 200 == status then
					if 0 == errcode then
						-- 以排行榜缓存数据为准
						data = Helper:tableCover(data, userData)
						-- 头部以排行榜为准
						if MapIsEmpty(data.equips) == false then
							data.equips.head = userData.head
						end
	
						local roleInfoLayer = RoleInfoLayer:getInstance()
						roleInfoLayer:show(true)
						roleInfoLayer:setInfo(data)
	
					else
						PopText(tostring(errmsg))
					end
				else
					PopText("网络请求出错,请换个网络环境再试!")
				end
			end, IS_SHOW_WAITING)
		end
	)
	
	panel.Text_name:setString(userData.name)

	panel.Text_pingjia:setString(userData.score)


	panel.Text_menpai:setString(userData.menpai)

    -------空的名字查看玩家资料
	panel.Text_name:setTouchEnabled(true)
	panel.Text_name:releaseFunc(function()
		----本周排行从本地取数据
		HttpManagerEx:getUserInfo(tonumber(userData.userid), 0, function(status, errcode, errmsg, data)
			if status == 200 then
				if 0 == errcode then
					-- 以排行榜缓存数据为准
					data = Helper:tableCover(data, userData)
					-- 头部以排行榜为准
					if MapIsEmpty(data.equips) == false then
						data.equips.head = userData.head
					end

					local roleInfoLayer = RoleInfoLayer:getInstance()
					roleInfoLayer:show(true)
					roleInfoLayer:setInfo(data)
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

function BoatPersonalRankingLayer:hide()
	PopupLayerController:hideLayer("BoatPersonalRankingLayer", function(layer)
		self:hide()
	end)
end

function BoatPersonalRankingLayer:hide()
	self:setCascadeOpacity(255)
	local action1 = cc.Sequence:create(
		cc.FadeOut:create(0.5),
		cc.CallFunc:create(function ()
			self:setVisible(false)
		end)
		)
	self:runAction(action1)
end

----设置标题
function BoatPersonalRankingLayer:setTitle(str)
	if not str then
		return
	end
	self.Panel_category.Text_Title:setString(tostring(str))
end
----------------------------------------------人气奖励-------------------------------------------------------------------------------------------
----奖励领取按钮,查看自己的奖励情况
function BoatPersonalRankingLayer:rewardGetButton( )
	self.Button_Reward:releaseFunc(function ()
			--领奖按钮是否可点击
		self.Panel_attr_preview:setVisible(false)
		Audio:playEffect("xiaoAnNiu")
		self:initRichText()
		self:printMineReward()
	end)
end

function BoatPersonalRankingLayer:initRichText()
	local x, y = self.Panel_attr.Panel_dscArea:getPosition()
	local size = self.Panel_attr.Panel_dscArea:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_attr.Panel_dscArea:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_attr.Panel_dscArea:getPosition())
   	richTextScroll:move(point)

   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)

end

-----奖励预览
function BoatPersonalRankingLayer:previeReward()
	self.Button_Reward_Preview:releaseFunc(function ()
		self.Panel_attr:setVisible(false)
		Audio:playEffect("xiaoAnNiu")
		self:initRichTextPreview()
		self:printRewardPreview()
		self.Panel_attr_preview.Text_Preview_Title:setString("个人积分奖励")
	end)
end


-----------------打印出从服务器获取的  自己能得到的奖励
function BoatPersonalRankingLayer:printMineReward()
	local function getBoatReward(transId)
		local role = User:getRole()
		local canReward = true
		local  itemList= self.rankingData
		itemList.daoju = Helper:getDef(itemList.daoju,{})
		if MapIsEmpty(itemList.daoju) == false then
			canReward = role:checkCanBuyTwoOrMoreThings(itemList.daoju)
		end

		if canReward == false then--判断背包	
			self.Button_Reward:setTouchEnabled(true)
	        self.Button_Reward:setEnabled(true)
	        return
		end

		HttpManagerEx:getBoatReward(transId,2,function(status,errcode,errmsg,data)
			if status == 200 then
				if errcode == 0 then
					if not MapIsEmpty(data.daoju) then
						for k,v in pairs(data.daoju) do
							local itemAttr = Item:getOneItemByKey(k)
							PopText("获得物品"..tostring(itemAttr.name).." X "..tostring(v))
							role:addItemCount(k, v)
						end
					end
					
					for k,v in pairs(data.shuxing) do
						role:addAttr(k,tonumber(v))
						PopText(role:getCHAttrName(k)..""..tostring(v))
					end

					for k,v in pairs(data.currency) do
						PopText(role:getCHAttrName(k)..""..tostring(v))
					end

					self.Button_Reward:setTouchEnabled(false)
	                self.Button_Reward:setEnabled(false)
	            else
	            	print("errcode :",errcode)
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

-----------------打印出从服务器获取的  奖励预览
function BoatPersonalRankingLayer:printRewardPreview()
	HttpManagerEx:getDuanwuRewardNotice(2,function(status,errcode,errmsg,data)
		if status == 200 then
			if errcode == 0 then
				local str = self:dealString(data["content"])
				self:initRichTextPreview()
				self:printPreview(str)
				self.Panel_attr_preview:setVisible(true)
			else
				PopText(tostring(errmsg))
			end
		else
			PopText(errmsg)
        end
	end,IS_SHOW_WAITING)
end

function BoatPersonalRankingLayer:dealString(str)
	if PRINT_MODE == 1 then
		print("strstrstr.........22222222222222222........",str)
		-- Helper:print_lua_table(data)
	end
	if str == nil or str == "" then
		return
	end
	local strNotice = ""
	strNotice = string.gsub(str,"?","\n")
	return strNotice
end

local textColor = cc.c3b(159,159,159)
function BoatPersonalRankingLayer:printPreview(str, verticalSpace)
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
		self.Panel_attr_preview.Panel_shelter:setVisible(true)
		self.RichText_Print:setCascadeOpacity(0)
		self:delayFunc(0.4,function ()
			self.RichText_Print:jumpToTop()
			self.Panel_attr_preview.Panel_shelter:setVisible(false)
			self.RichText_Print:setCascadeOpacity(255)
		end)
	end
end

Helper:classDefNodeGetInstance(BoatPersonalRankingLayer)
return  BoatPersonalRankingLayer


000000000000
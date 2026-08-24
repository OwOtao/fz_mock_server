local Resource = require("app.Resource")
local BiWu = require("app.models.BiWu.BiWu")
local Helper = require("app.Helper")
local RoleInfoLayer = require("app.views.layer.RoleLayer.RoleInfoLayer")


local BiWuRankingUI = class("BiWuRankingUI",cc.Layer)

function BiWuRankingUI:create(  )
	local p = BiWuRankingUI:new()
	p:init()
	return p
end


function BiWuRankingUI:init()
	self._UI = require("Layer.BiWuUI.BiWuRankingUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setButtonQuit()
	self:initRichText()
	self:initRichTextPreview()
end

-- 关闭按钮
function BiWuRankingUI:setButtonQuit()
	self.Button_quit:releaseFunc(function()
		Audio:playEffect("fanHuiQuXiao")
		self:hide()
		----删除所有排行信息
		self.ListView_ranking:removeAllItems()
	end)
end
---根据传进来的参数决定要显示排行榜那些数据信息
--type 是BiWu.list 的值
function BiWuRankingUI:show(curryType,callback)
	self:setVisible(true)
	self:setCascadeOpacity(0)
	local action = cc.Sequence:create(
		cc.FadeIn:create(0.5)
		)
	self:runAction(action)
	self.Panel_attr_preview:setVisible(false)
	self.Panel_attr:setVisible(false)

	if curryType == "people" then
		-- self.Panel_item.Text_Time:setVisible(false)
		self.Panel_item.Text_pingjia:setFontSize(54)
		self.Text_RenQi:setVisible(true)
		-- self.Text_Time:setVisible(true)

		self.Text_people:setVisible(false)
		self.Text_Ranking:setVisible(false)

		self.Panel_item.Text_mingci:setVisible(true)

		self.Text_MingCi:setVisible(true)
		self.Text_NiCheng:setVisible(true)

	elseif curryType == "week" then
		-- self.Panel_item.Text_Time:setVisible(false)
		self.Panel_item.Text_pingjia:setFontSize(80)
		self.Text_RenQi:setVisible(false)
		self.Text_Time:setVisible(false)

		self.Text_people:setVisible(true)
		self.Text_Ranking:setVisible(true)

		self.Panel_item.Text_mingci:setVisible(false)

		self.Text_MingCi:setVisible(false)
		self.Text_NiCheng:setVisible(false)

	elseif curryType == "history" then
		-- self.Panel_item.Text_Time:setVisible(true)
		self.Panel_item.Text_pingjia:setFontSize(54)
		self.Text_RenQi:setVisible(true)
		self.Text_Time:setVisible(false)
		self.Text_people:setVisible(false)
		self.Text_Ranking:setVisible(false)

		self.Panel_item.Text_mingci:setVisible(true)

		self.Text_MingCi:setVisible(true)
		self.Text_NiCheng:setVisible(true)

	end
	callback = Helper:getDef(callback, EMPTY_FUNC)
	callback()
end

function BiWuRankingUI:hide()
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
function BiWuRankingUI:setTitle(str)
	if not str then
		return
	end
	self.Panel_category.Text_Title:setString(tostring(str))
end

-----设置左上角当前人气
function BiWuRankingUI:setTextPeople(num)
	if num ==nil or num == "" then
		self.Text_people:setVisible(false)
	else
		self.Text_people:setVisible(true)
		self.Text_people.Text_People_Number:setString(tostring(num))
	end
end

----设置排名
function BiWuRankingUI:setRanking(num)
	if not num or num == "" then
		self.Text_Ranking:setVisible(false)
	else
		self.Text_Ranking.Text_Ranking_Number:setVisible(true)
		self.Text_Ranking.Text_Ranking_Number:setString(tostring(num))
	end
end
----设置右上角人气标题tile
function BiWuRankingUI:setTitleRenQiShow(str)
	if not str or str == "false" then
		self.Text_RenQi:setVisible(false)
	else
		self.Text_RenQi:setVisible(true)
	end
end
----设置左上角剩余时间的标题
function BiWuRankingUI:setTitleTimeShow(str)
	if not str or str =="false" then
		self.Text_Time:setVisible(false)
	else
		self.Text_Time:setVisible(true)
	end
end

---------------------------------------------------------------------------------------------
--创建一个列表显示对战记录
-- 创建列表
function BiWuRankingUI:createListView(type,data)

	-- Helper:print_lua_table(data)
	if MapIsEmpty(data) then
		if PRINT_MODE ==1 then
			print("---------function RankingUI:createListView(data)-------空的")
		end
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
			local row = self:createPanel(type,listData)
			self.ListView_ranking:pushBackCustomItem(row)

			-----本周对战记录最多显示100条
			if type == 3 and i >= 100 then
				if PRINT_MODE ==1 then
					PopText("超出一百条记录，只显示最新的100条")
				end
				break
			end

		end
	else
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

	local row = self:createPanel(type,mine)
	if row ~= nil then
		self.ListView_ranking:pushBackCustomItem(row)
	end

end
----------创建list显示的一行数据
-- 创建一行记录信息
function BiWuRankingUI:createPanel(type,userData)
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
			----本周排行从本地取数据
			if type == 3 then
				local roleInfoLayer = RoleInfoLayer:getInstance()
				roleInfoLayer:show(true)
				roleInfoLayer:setInfo(userData)
			else
				HttpManagerEx:getUserInfo(
					tonumber(userData.userid),
					0,
					function(status, errcode, errmsg, data)
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
					end,
					IS_SHOW_WAITING
				)
			end
		end
	)



	panel.Text_name:setString(userData.name)

	panel.Text_pingjia:setString(userData.dsc)

	if type == 3 then
		panel.Text_menpai:setString(userData.dataTime)
	else
		panel.Text_menpai:setString(userData.menpai)
	end
	
    -------空的名字查看玩家资料
	panel.Text_name:setTouchEnabled(true)
	panel.Text_name:releaseFunc(function()
		----本周排行从本地取数据
		if type == 3 then
			local roleInfoLayer = RoleInfoLayer:getInstance()
			roleInfoLayer:show(true)
			roleInfoLayer:setInfo(userData)
		else
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
		end
	end)

	--点击对手的信息
	do
	-------只有本周对战记录的时候，才能查看对手信息
		if type == 3 then
			panel.Text_pingjia:releaseFunc(function()
				local roleInfoLayer = RoleInfoLayer:getInstance()
				roleInfoLayer:show(true)
				roleInfoLayer:setInfo(userData)
			end)
		end
	end

	return panel
end

----从这里提出标题  人气   排行数据
function BiWuRankingUI:createListViews(Type,list)
	local fightWeekAllData = BiWu:getfightWeekAllData()
	if Type == 3 then
		self:createListView(Type,fightWeekAllData.weekUserData)
		self:setTextPeople(list[2])
		self:setRanking(list[1])
	else
		for i,v in ipairs(list) do
			self:createListView(Type,list[i])
			local userdata = list[i]
			if userdata and userdata.sort and userdata.renqi then
				self:setTextPeople(userdata.renqi)
				self:setRanking(userdata.sort)
			end
		end
	end

end

------------------------------------人气奖励
---奖励领取按钮，查看自己的奖励情况
function BiWuRankingUI:rewardGetButton(func)
	self.Button_Reward:releaseFunc(function ()
		if func then
			func()
		end
	end)
end

----领取奖励
---奖励领取按钮
function BiWuRankingUI:getRewardButton(func)
	self.Panel_attr.Button_Reward_Get:releaseFunc(function ()
		if func then
			func()
		end
	end)
end
--奖励预览
function BiWuRankingUI:previeReward(func)
	self.Button_Reward_Preview:releaseFunc(function ()
		if func then
			func()
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------
-- ----打印自己的奖励
function BiWuRankingUI:initRichText()
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

local textColor = cc.c3b(159,159,159)
function BiWuRankingUI:print(str, verticalSpace)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 4000 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 48)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

------奖励预览的打印
function BiWuRankingUI:initRichTextPreview()
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

local textColor = cc.c3b(159,159,159)
function BiWuRankingUI:printPreview(str, verticalSpace)
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


Helper:classDefNodeGetInstance(BiWuRankingUI)
return BiWuRankingUI0000000000000000
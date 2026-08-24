local BiWu = require("app.models.BiWu.BiWu")
local BiWuRankingtUI = require("app.views.ui.BiWuUI.BiWuRankingUI")

local BiWuRankingLayer = class("BiWuRankingLayer",cc.Layer)

function BiWuRankingLayer:create()
	local p = BiWuRankingLayer:new()
	p:init()
	return p
end

function BiWuRankingLayer:init()
	local BiWuRankingtUI = BiWuRankingtUI:create()
	self._UI = BiWuRankingtUI
	BiWuRankingtUI:addTo(self)


	self:rewardGetButton()
	self:getRewardButton()
	self:previeReward()
	-----点击背景隐藏奖励领取界面
	self._UI.Panel_attr.Panel_back:releaseFunc(function ()
		self._UI.Panel_attr:setVisible(false)
	end)

	-----点击背景隐藏奖励预览界面
	self._UI.Panel_attr_preview.Panel_back:releaseFunc(function ()
		self._UI.Panel_attr_preview:setVisible(false)
	end)

	self:setVisible(false)
end

--------------------------三个榜单的调用
---获取人气榜 GET get_fight_board/{type} 1历史人气 2本周人气 3挑战记录 
--人气榜
function BiWuRankingLayer:showPeopleTop()
	self:Ranking(2,"本周人气榜","people")
end

--本周对栈记录
function BiWuRankingLayer:showWeekTop(callback)
	self:Ranking(3,"本周对战记录","week",callback)
end

---历史人气榜
function BiWuRankingLayer:showHistoryTop()
	self:Ranking(1,"历史人气最高榜","history")
end

-------------------------------------------------------------------------------------------------
function BiWuRankingLayer:show(Type)
	self:setVisible(true)
	self._UI:show(Type)
end
function BiWuRankingLayer:hide()
	PopupLayerController:hideLayer("BiWuRankingLayer", function(layer)
		self._UI:hide()
	end)
end
----设置标题
function BiWuRankingLayer:setTitle(str)
	self._UI:setTitle(str)
end

-----设置左上角当前人气
function BiWuRankingLayer:setTextPeople()

end

----设置排名
function BiWuRankingLayer:setRanking()

end
----设置右上角人气标题tile
function BiWuRankingLayer:setTitleRenQiShow()

end
----设置左上角剩余时间的标题
function BiWuRankingLayer:setTitleTimeShow()

end

---------------------------------------------------------------------------------------------
---创建一个列表显示对战记录
function BiWuRankingLayer:Ranking(type,titlename,curryType,callback)
	self:setTitle(titlename)
	self._UI:show(curryType,callback)
end


----------------------------------------------人气奖励-------------------------------------------------------------------------------------------
----奖励领取按钮,查看自己的奖励情况
function BiWuRankingLayer:rewardGetButton( )
	self._UI:rewardGetButton(function ()
		self._UI.Panel_attr_preview:setVisible(false)
		Audio:playEffect("xiaoAnNiu")
		self._UI:initRichText()
		self:printMineReward()
	end)
end

---领取自己的奖励
function BiWuRankingLayer:getRewardButton()
	self._UI:getRewardButton(function ()
		--领取奖励
		Audio:playEffect("xiaoAnNiu")
		local fightAllData = BiWu:getfightAllData()
		local role = User:getRole()
		local thisWeekRewardData = {}
		if fightAllData.thisWeekRewardData then
			thisWeekRewardData = fightAllData.thisWeekRewardData
		end
		---已经领取，不然点击按钮
		if thisWeekRewardData.is_get == "Y" then
			PopText("已经领取过本周的奖励了")
			return
		end

		--判断条件要改变
		-- if thisWeekRewardData.money and thisWeekRewardData.qiannengdan and thisWeekRewardData.yuanbao then
		if thisWeekRewardData then
			--判断背包满了没有，满了给一个提示，for 循环，判断所有能领取的丹药,两种丹药都加，怎么判断
			if thisWeekRewardData.danyao then
				if role:checkCanBuyTwoOrMoreThings(thisWeekRewardData.danyao) == false then
					return 
				else
					if PRINT_MODE == 1 then
						print("能加入背包")
					end
				end 
			else
				print("没有丹药奖励")
			end				
			------奖励LIst信息
			BiWu:getFightSelfReward(function (rewardList,renqi,danyao)
				---加HIW碎银DWT
				if thisWeekRewardData.money then
					role:addAttr("money", tonumber(thisWeekRewardData.money))
				end
				--加HIG潜能丹DWT
				for k,v in pairs(danyao) do
					if v and k then
						role:addItemCount(k, tonumber(v))
					end
				end

				local meili = 0
				if type(renqi) == "number" and renqi then
					meili = math.ceil(renqi * 0.1)
					role:addAttr("meili", meili)
					PopText("增加风度魅力值 "..tostring(meili))
				end
				if not MapIsEmpty(rewardList) then
					for i=1,#rewardList do
						self:delayFunc(0.5*i,function ()
							PopText(tostring(rewardList[i]))
						end)
					end
				end
				---按钮UI
				self._UI.Panel_attr.Button_Reward_Get.Text_GetPreviewName:setString("已领取")

			end)
		else
			PopText("错误，获取奖励失败，请重试")
		end
			

	end)
end

-----奖励预览
function BiWuRankingLayer:previeReward()
	self._UI:previeReward(function ()
		self._UI.Panel_attr:setVisible(false)
		Audio:playEffect("xiaoAnNiu")
		self._UI:initRichTextPreview()
		self:printRewardPreview()
	end)
end


-----------------打印出从服务器获取的  自己能得到的奖励
function BiWuRankingLayer:printMineReward()
	-- local str = "?\n上周总人气：0\n\n上周排名：0\n\n排名奖励：未领取\n\n碎银：0；HIG潜能丹WHT：0；元宝：0"
	local dataList =  {}
	local printStr = ""
	local isGetReward = ""
	local role = User:getRole()
	local name = role:getName()
	local menPai = role:getFamilyName()
	if menPai == nil then
		menPai = "江湖散人"
	end
	-----从服务器获取奖励情况
	BiWu:getFightRewardList(function(dataList)
		if dataList.is_get == "Y" then
			self._UI.Panel_attr.Button_Reward_Get.Text_GetPreviewName:setString("已领取")
			isGetReward = "已领取"
		else
			self._UI.Panel_attr.Button_Reward_Get.Text_GetPreviewName:setString("领取")
			isGetReward = "未领取"
		end
		---------显示奖励情况
		if dataList.last_renqi and dataList.last_sort and dataList.reward then
			printStr ="\n门派："..tostring( menPai ).."\n\n".."角色名："..tostring(name).."\n\n上周总人气："..dataList.last_renqi.."\n\n上周排名："
			local str1 = dataList.last_sort.."\n\n排名奖励："..isGetReward.."\n\n"..dataList.reward
			printStr = printStr..str1
		end
		-------
		if dataList.current_renqi and dataList.current_sort then
			self._UI.Panel_attr.Text_Week_RenQi:setString("本周当前人气："..dataList.current_renqi)
			self._UI.Panel_attr.Text_Week_Rank:setString("本周当前排名："..dataList.current_sort)
		end
		-----输出文本和显示奖励列表
		self._UI:print(printStr)
		self._UI.Panel_attr:setVisible(true)
	end)
end

-----------------打印出从服务器获取的  奖励预览
function BiWuRankingLayer:printRewardPreview()
	local str1 = "YEL人气值达到15000以及以上的为宗师组?人气在6000~14999内的为高手组?人气在1200~5999内的为新秀组??NOR宗师组且排行榜第1名：?HIW碎银DWT：1000000  HIG潜能丹DWT：3  HIY元宝DWT：500??NOR宗师组且排行榜第2名：?HIW碎银DWT：400000  HIG潜能丹DWT：3  HIY元宝DWT：450??NOR宗师组且排行榜第3名：?HIW碎银DWT：300000  HIG潜能丹DWT：3  HIY元宝DWT：430??NOR宗师组且排行榜第4名：?HIW碎银DWT：260000  HIG潜能丹DWT：2  HIY元宝DWT：420??NOR宗师组且排行榜第5名：?HIW碎银DWT：250000  HIG潜能丹DWT：2  HIY元宝DWT：410??NOR宗师组且排行榜第6名：?HIW碎银DWT：240000  HIG潜能丹DWT：2  HIY元宝DWT：400??NOR宗师组且排行榜第7名：?HIW碎银DWT：230000  HIG潜能丹DWT：2  HIY元宝DWT：390??NOR宗师组且排行榜第8名：?HIW碎银DWT：220000  HIG潜能丹DWT：2  HIY元宝DWT：380??NOR宗师组且排行榜第9名：?HIW碎银DWT：210000  HIG潜能丹DWT：2  HIY元宝DWT：370??NOR宗师组且排行榜第10名：?HIW碎银DWT：200000  HIG潜能丹DWT：2  HIY元宝DWT：360??NOR宗师组且排行榜第11-100名：?HIW碎银DWT：170000  HIG潜能丹DWT：1  HIY元宝DWT：350??NOR宗师组且排行榜第101-500名：?HIW碎银DWT：140000  HIG潜能丹DWT：1  HIY元宝DWT：300??NOR宗师组且排行榜第501-1000名：?HIW碎银DWT：110000  HIG潜能丹DWT：1  HIY元宝DWT：250??NOR宗师组且排行榜1000以外：?HIW碎银DWT：80000  HIG潜能丹DWT：1  HIY元宝DWT：200??NOR高手组：?HIW碎银DWT：50000  HIY元宝DWT：100??NOR新秀组：?HIW碎银DWT：30000  HIY元宝DWT：50"
	local str2 = "YEL人气值达到15000以及以上的为宗师组?人气在6000~14999内的为高手组?人气在1200~5999内的为新秀组??NOR宗师组且排行榜第1名：?HIW碎银DWT：1000000  HIG天香玉露DWT：7  RED醉梦生DWT：3??NOR宗师组且排行榜第2名：?HIW碎银DWT：400000  HIG天香玉露DWT：6  RED醉梦生DWT：2??NOR宗师组且排行榜第3名：?HIW碎银DWT：300000  HIG天香玉露DWT：6  RED醉梦生DWT：2??NOR宗师组且排行榜第4名：?HIW碎银DWT：260000  HIG天香玉露DWT：4  RED醉梦生DWT：2??NOR宗师组且排行榜第5名：?HIW碎银DWT：250000  HIG天香玉露DWT：4  RED醉梦生DWT：2??NOR宗师组且排行榜第6名：?HIW碎银DWT：240000  HIG天香玉露DWT：4  RED醉梦生DWT：2??NOR宗师组且排行榜第7名：?HIW碎银DWT：230000  HIG天香玉露DWT：4  RED醉梦生DWT：2??NOR宗师组且排行榜第8名：?HIW碎银DWT：220000  HIG天香玉露DWT：4  RED醉梦生DWT：2??NOR宗师组且排行榜第9名：?HIW碎银DWT：210000  HIG天香玉露DWT：4  RED醉梦生DWT：2??NOR宗师组且排行榜第10名：?HIW碎银DWT：200000  HIG天香玉露DWT：4  RED醉梦生DWT：2??NOR宗师组且排行榜第11-100名：?HIW碎银DWT：170000  HIG天香玉露DWT：2  RED醉梦生DWT：2??NOR宗师组且排行榜第101-500名：?HIW碎银DWT：140000  HIG天香玉露DWT：2  RED醉梦生DWT：1??NOR宗师组且排行榜第501-1000名：?HIW碎银DWT：110000  HIG天香玉露DWT：2  RED醉梦生DWT：1??NOR宗师组且排行榜1000以外：?HIW碎银DWT：80000  HIG天香玉露DWT：2  RED醉梦生DWT：1??NOR高手组：?HIW碎银DWT：50000  RED醉梦生DWT：1??NOR新秀组：?HIW碎银DWT：30000  RED醉梦生DWT：1"
	local strNotice = ""
	BiWu:getFightWeekNotice(function(strNotice)
		if strNotice == "" or strNotice == nil then
			strNotice = str2 
		end
		strNotice = string.gsub(strNotice,"?","\n")
		self._UI:printPreview(strNotice)
		self._UI.Panel_attr_preview:setVisible(true)
	end)
	
end

Helper:classDefNodeGetInstance(BiWuRankingLayer)
return  BiWuRankingLayer


000000000
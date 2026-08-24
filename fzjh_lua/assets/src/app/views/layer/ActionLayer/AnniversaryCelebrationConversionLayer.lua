-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/16 16:14:54
-- @desc 周年庆

local AnniversaryCelebrationConversionLayer = class("AnniversaryCelebrationConversionLayer", LayerEx)
local GoodsHelper = require("app.models.Store.GoodsHelper")

function AnniversaryCelebrationConversionLayer:create()
	local p = AnniversaryCelebrationConversionLayer:new()
	p:init()
	return p
end
local tab = {

}
local allGoods = {
	
}
local DEFAULT_LIST = 0
local M_DISCOUNT = 1

local special = 
{
	{
		id = "meiyu",
		name = "HIW江湖美誉NOR",
		dsc = "江湖美誉可在盛唐阁获得，用以换取信物材料，乃是江湖中人人欲得之物。"
	},
	{
		id = "yuanbao",
		name = "HIY元宝NOR",
		dsc = "元宝是江湖中的硬通货，身携万两元宝，行走江湖不慌。"

	},
	{
		id = "gongxiandian",
		name = "HIC师门贡献点NOR",
		dsc = "师门贡献点可以在门派处换得诸多物事。"

	},
	{
		id = "mingbi",
		name = "HIM冥币NOR",
		dsc = "冥币乃是阴间所用的货币，可在酆都城内获得，用以换取诸多物事。"

	},
	{id ="jinchanzhu",name = "金蟾珠",dsc = "这是一颗金蟾珠，以赤金铸成的三足金蟾，寓意着招财纳宝，虽只有拇指大小，但栩栩如生。"},
	{id ="zongheng",name = "雪矾",dsc = "这是精制的雪矾，可以用在戏曲面具上，使其焕然如新。"},
	{id ="ningshendan",name = "凝神丹",dsc = "一颗褐色浑圆的丹药，散发出淡淡的药味，服用后静心凝神，练功事半功倍。"},
	{id ="chuangzuodaoju001",name = "启发卷轴",dsc = "此乃启发卷轴。使用后使自创成功率小幅提升，已创招式越少提升效果越强。每次自创招式仅可使用一个卷轴，招式完成效果将消失。"},
	{id ="chuangzuodaoju002",name = "灵感卷轴",dsc = "此乃灵感卷轴，使用后使自创成功率大幅提升，已创招式越少提升效果越强。每次自创招式仅可使用一个卷轴，招式完成效果将消失。"},
	{id ="chuangzuodaoju003",name = "神思卷轴",dsc = "此乃神思卷轴，使用该卷轴自创必定成功，每次自创招式仅可使用一个卷轴，招式完成效果将消失。"},
	{id ="mianfeichuangzuo",name = "节源卷轴",dsc = "此乃节源卷轴，使用该卷轴自创可不再需要其他额外消耗，每次自创招式仅可使用一个卷轴，招式完成效果将消失。"},
	{id ="glczwanquanchongzhi001",name = "复思之书",dsc = "此乃复思之书，使用该书卷可以将任何招式完全重置。但招式品质不会发生变化。"},
	{id ="glczwanquanchongzhi002",name = "弃定之书",dsc = "此乃弃定之书，使用该书卷可以将精妙招式完全重置，但招式品质不会发生变化。"},
	{id ="glczwanquanchongzhi003",name = "重思之书",dsc = "此乃重思之书，使用该书卷可以将超凡招式完全重置，但招式品质不会发生变化。"},
	{id ="gailiangshengpin001",name = "精研之书",dsc = "此乃精研之书，使用该书卷可以将普通招式提升至精妙招式。"},
	{id ="gailiangshengpin002",name = "起群之书",dsc = "此乃超群之书，使用该书卷可以将普通招式提升至超凡招式。"},
	{id ="gailiangshengpin004",name = "跃兴之书",dsc = "此乃跃兴之书，使用该书卷可以将精妙招式提升至超凡招式。"},
	{id ="minditem1",name = "清心散",dsc = "一包用白色油纸包裹的朱色粉末，据说出自名声显赫的医药世家，服用可令人舒心安神。"},
	{id ="minditem2",name = "谧心丸",dsc = "通体青色的药丸，闻之似有淡淡幽香，服用后可使人心神安定。"},
	{id ="minditem3",name = "凝心露",dsc = "翠绿透彻的玉瓶中装着的半透明药液，闻之清香阵阵，凝心露功效颇为奇特，服用令可人心神饱满全身清爽。"},
	{id ="minditem4",name = "聚心丹",dsc = "一个精致的紫金葫芦中装着的丹药，取之伴有阵阵奇特香气，相传服用此丹可使人神清气爽心旷神怡。"},
	{id ="duzhijiasu",name = "笃志",dsc = "潜心笃志，可以叫练功事半功倍。"},
	{id ="accpoint",name = "固身元气",dsc = "固本体之元气，可叫修行时事半功倍。"},
	{id ="characterPoint",name = "特性见解",dsc = "可快速领悟特性之精髓。"},
}
local specialmap2 = 
{
	yujianliuwuzang = "yidaoliu",
	sanhuatu = "tiannvsanhuashou"
}
local specialmap = 
{
	yidaoliu = "yujianliuwuzang",
	tiannvsanhuashou = "sanhuatu"
}
function AnniversaryCelebrationConversionLayer:init()
	local UI = require("Layer/ActionUI/AnniversaryCelebrationConversionUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setVisible(false)
	self.transType = 12
	self:setButtonBack()
	self:chongZhiBtnFunc()
	self:__setRuleFunc()
end

function AnniversaryCelebrationConversionLayer:showLayer(shop_id,actionId)
	self.currDate = Helper:date("%Y%m%d",GetTime())
	self:setShopId(shop_id)
	self:rollBackExchage(self.transType)
	-- self:show()
	self:setActionTime(actionId,shop_id)

	if self._handle==nil then 
		self._handle = self:schedule(function (ft)
			self:updateTime(ft)
		end,1)
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/21 15:08:26
-- @desc 设置shop_Id
function AnniversaryCelebrationConversionLayer:setShopId(shop_id)
	if not shop_id then
		shop_id = "zhounianqin_cz"
	end
	self._shopId = shop_id
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/20 18:24:29
-- @desc 将从服务器获取的数据装换成测试数据格式
function AnniversaryCelebrationConversionLayer:changeInfoList(goodsList,typeList)
	if not goodsList then
		return
	end
	tab = {}
	allGoods = {}
	local function initList(list)
		local tempList = {}

		if MapIsEmpty(list) == false then
			for k,v in pairs(list) do 
				tempList[k] = {}
				for i,value in pairs(v) do 
					if i == "itemId" then
						tempList[k].itemId = value
					elseif i == "dsc" then
						tempList[k].dsc = value
					elseif i == "name" then
						tempList[k].name = value
					elseif i == "itype" then
						tempList[k].itype = value
					elseif i == "price" then
						tempList[k].score = value
					elseif i == "number" then
						tempList[k].number = value
					elseif i == "gid" then
						tempList[k].goodsId = value
					elseif i == "is_again" then
						if value == "N" then
							tempList[k].max = list[k].times
							tempList[k].limit = list[k].times
						else
							tempList[k].max = 100000
						end
					elseif i == "inde" then
						tempList[k].id = value
					end
				end
				tempList[k].words = "您已经达到购买上限"
			end
		end

		return tempList
	end

	for k,v in pairs(goodsList) do 
		allGoods[k] = initList(v)
	end

	self:showList(allGoods["tuijian"])
	self.currTitle = "tuijian"
	self:initTitleList(typeList,initList)
end

function AnniversaryCelebrationConversionLayer:showList(list)
	tab = list
	tab = self:colationList(tab)
	tab = self:sortList(tab)
	self:__showItemList(tab)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/21 14:32:13
-- @desc 回滚失败订单
function AnniversaryCelebrationConversionLayer:rollBackExchage(transType)
	TransCheck:checkTransWithType(transType,function()
		-- HttpManagerEx:
	end)
end

function AnniversaryCelebrationConversionLayer:getChangeFlag()
	local currDate = tonumber(Helper:date("%Y%m%d",GetTime()))--进入页面记录的日期不是20171001且当前的日期大于等于20171001 需要让玩家退出页面重新进入
	if tonumber(self.currDate) < 20171001 and currDate >= 20171001 then
		return false
	end
	--时间到达活动结束日期 提示玩家
	if self.endTime and self.endTime - GetTime() <=0 then 
		return false 
	end

	return true
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/20 17:06:31
-- @desc 获取积分兑换列表
function AnniversaryCelebrationConversionLayer:getShopInfo(shopId,actionId)
	shopId = self._shopId
	HttpManagerEx:getShopInfo(shopId ,function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			data = Helper:getDef(data,{})
			data.shop_info = Helper:getDef(data.shop_info,{})
			self:changeInfoList(data.shop_info.goods,data.shop_info.typeName)
			self:setTotalScore(data.total_points)
			self:show()
		else
			self:hide()
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/21 15:19:07
-- @desc 获取活动时间
function AnniversaryCelebrationConversionLayer:setActionTime(actionId,shop_id)--设置活动时间
	if actionId == nil then
		return
	end
	HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
        		self:setActionDsc(data.start,data["end"],shop_id,data.name)
        		self.endTime = data["end"]
				self:getShopInfo(shop_id,actionId)
        	end
		else
			self:hide()
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/16 16:34:03
-- @desc 
function AnniversaryCelebrationConversionLayer:setOneItem(list)
	local row = self:getItemPanel()
	return row
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/16 16:24:53
-- @desc 设置活动时间描述
function AnniversaryCelebrationConversionLayer:setActionDsc(startTime,endTime,tag,name)
	local str1 = "但凡是在$y年$m月$d日到$Y年$M月$D日内充值的玩家\n，根据对应的充值数额均可获得充值积分，而充值积分可在\n商城活动界面内兑换珍贵稀有的物品。\n充值1元=10充值积分"
		  str1 = "在$y年$m月$d日活动上线后到$Y年$M月$D日充值的玩\n家，根据对应的充值数额均可获得充值积分，充值积分可兑\n换珍贵物品，RED充值积分将会在活动结束后清零NOR。\n充值1元=10充值积分。"
	-- local str2 = "但凡是在$y年$m月$d日到$Y年$M月$D日进\n行周年庆玩法、飞贼横行、南阳匪乱都可获得活\n动积分，活动积分可兑换诸多稀有道具。"
	local currDate = tonumber(Helper:date("%Y%m%d",GetTime()))
	-- if currDate >= 20171001 then
	-- 	str1 = str1 .. "，HIY江湖名士兑换享有折扣NOR。"
	-- end
	local str2 = "在$y年$m月$d日到$Y年$M月$D日可使用周年庆活动积分兑换诸多道具，其中不乏珍贵稀有之物，各位大侠千万不可错过。"
	local str3 = "在$y年$m月$d日到$Y年$M月$D日,充值1元可获得10武道值，消耗100元宝也可获得10武道值。武道值可用于兑换武林先贤的精品收藏，不容错过！RED武道值在活动结束后清零。"
	self:initRichTextPreview()
	-- print(self:getActionDscWithTime(startTime,endTime,str3))
	if tag == "zhounianqin_jf" then
		print(self:getActionDscWithTime(startTime,endTime,str2))
		-- self.Text_dsc:setString(self:getActionDscWithTime(startTime,endTime,str2),42)
		self:printPreview(self:getActionDscWithTime(startTime,endTime,str2),42)
		self.RichText_Print:setPositionY(1629)
		self.Text_time:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
		-- self.Image_back:setPositionY(859)
		-- self.Text_score:setPositionY(336.8)
		-- self.ListView_1:setPositionY(878)
		-- self.Button_close:setPositionY(133)
		-- self.Button_add:setPositionY(133)
		-- self.Text_time:setPositionY(269.3)
		-- self.Panel_title:setPositionY(1429.2)
		-- self.RichText_Print:setFontSize(42)
		self.Text_title:setString(name)
		-- self.Text_score:setPositionX(60)
		-- self.Text_time:setPositionX(60)
		--self.Button_1:setPositionY(1419)
	elseif tag == "zhounianqin_cz" then
		-- self.Text_dsc:setString(self:getActionDscWithTime(startTime,endTime,str1))
		self:printPreview(self:getActionDscWithTime(startTime,endTime,str1),36)
		 self.RichText_Print:setPositionY(1629)
		 self.Text_time:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
		-- self.Image_back:setPositionY(859)
		-- self.Text_score:setPositionY(336.8)
		-- self.ListView_1:setPositionY(878)
		-- self.Button_close:setPositionY(133)
		-- self.Button_add:setPositionY(133)
		-- self.Text_time:setPositionY(269.3)
		-- self.Panel_title:setPositionY(1429.2)
		-- self.Text_score:setPositionX(60)
		-- self.Text_time:setPositionX(60)
		-- self.Text_dsc:setFontSize(36)
		self.Text_title:setString(name)
		--self.Button_1:setPositionY(1419)
	elseif tag == "wudaoshop" then
		-- self.Text_dsc:setString(self:getActionDscWithTime(startTime,endTime,str1))
		self:printPreview(self:getActionDscWithTime(startTime,endTime,str3),36)

		 self.RichText_Print:setPositionY(1629)
		 self.Text_time:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
		-- self.Image_back:setPositionY(859)
		-- self.Text_score:setPositionY(336.8)
		-- self.ListView_1:setPositionY(878)
		-- self.Button_close:setPositionY(133)
		-- self.Button_add:setPositionY(133)
		-- self.Text_time:setPositionY(269.3)
		-- self.Panel_title:setPositionY(1429.2)
		-- self.Text_score:setPositionX(60)
		-- self.Text_time:setPositionX(60)
		-- self.Text_dsc:setFontSize(36)
		self.Text_title:setString(name)
		--self.Button_1:setPositionY(1419)
	end
end
function AnniversaryCelebrationConversionLayer:printPreview(str,frontSize , verticalSpace)
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_Print:getRichText():getNewContentSizeHeight()
	if textHeight >= 4000 then
		self:initRichTextPreview()
	end
	frontSize = Helper:getDef(frontSize,36)
	self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), frontSize)
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
function AnniversaryCelebrationConversionLayer:initRichTextPreview()
	local x, y = self.Text_dsc:getPosition()
	local size = self.Text_dsc:getContentSize()
	size.width = 980
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	self.Text_dsc:setVisible(false)
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Text_dsc:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Text_dsc:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
   	self.RichText_Print:setTouchEnabled(false)
end
function AnniversaryCelebrationConversionLayer:getActionDscWithTime(startTime,endTime,str)
	if not startTime or not endTime then
		return 
	end
	if not str or str == "" then
		return
	end
	--开始时间
	str = string.gsub(str,"$y",tostring(Helper:date("%Y",startTime)))
	str = string.gsub(str,"$m",tostring(Helper:date("%m",startTime)))
	str = string.gsub(str,"$d",tostring(Helper:date("%d",startTime)))
	--结束时间
	str = string.gsub(str,"$Y",tostring(Helper:date("%Y",endTime)))
	str = string.gsub(str,"$M",tostring(Helper:date("%m",endTime)))
	str = string.gsub(str,"$D",tostring(Helper:date("%d",endTime)))
	return str
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/16 17:33:40
-- @desc 设置当前总积分
function AnniversaryCelebrationConversionLayer:setTotalScore(score)
	score = Helper:getDef(tonumber(score),0)
	self.Text_score_num:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	if self._shopId == "zhounianqin_jf" then
		self.Text_score:setString("当前活动积分：")
		self.Text_score_num:setString(tostring(score))
	elseif self._shopId == "zhounianqin_cz" then
		self.Text_score:setString("当前充值积分：") 
		self.Text_score_num:setString(tostring(score))
	elseif self._shopId == "wudaoshop" then
		self.Text_score:setString("当前武道值：")
		self.Text_score_num:setString(tostring(score))
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/16 16:26:07
-- @desc 
function AnniversaryCelebrationConversionLayer:getItemPanel()
	local row = self.Panel_item:clone()
	Helper:convertUI(row)
	row.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	row.Text_name:setColor(cc.c3b(208, 208, 208))
	row.Text_score:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	row.Text_score:setColor(cc.c3b(196, 179, 93))
	row.Text_1:setColor(cc.c3b(241, 16, 16))
	row.Text_1:enableOutline({r = 17, g = 1, b = 18, a = 255}, 5)
	return row
end
function AnniversaryCelebrationConversionLayer:setButtonBack()
	self.Button_close:releaseFunc(function()
		PopupLayerController:hideLayer("AnniversaryCelebrationConversionLayer")
		self:hide()
	end)
end

function AnniversaryCelebrationConversionLayer:getTitleItem()
	local titleItem = self.Panel_titleItem:clone()
	Helper:convertUI(titleItem)
	return titleItem
end

function AnniversaryCelebrationConversionLayer:initTitleList(typeList,func)
	local titleList = {}
	if not func then 
		print("积分兑换数据转换出错")
		return 
	end
	local initList = func 
	if MapIsEmpty(typeList) then
		 typeList = {
		 	["tuijian"] ="推荐",
		 	["shuxing"] ="属性",
		 	["wuxue"] ="武学",
		 	["shenbing"] ="神兵",
		 	["yuetehui"] ="月特惠",
		 	["qita"] ="其他",
		}
		return
	end

	local titleTab = {}
	for k,v in pairs(typeList) do 
		local titleInfo = v
		titleInfo.id = k 
		table.insert(titleTab,titleInfo)
	end
	table.sort(titleTab,function(a,b)
			if a.index < b.index then 
				return true
			end
			return false
		end)

	self.Panel_title.ListView_title:setClippingEnabled(true)
	self.Panel_title.ListView_title:setItemsMargin(5)
	self.Panel_title.ListView_title:removeAllItems()
	for k,v in pairs(titleTab) do 
		local rowItem = self:getTitleItem()
		self.Panel_title.ListView_title:pushBackCustomItem(rowItem)
		rowItem.Text_name:setString(v.name)
		rowItem.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
		rowItem.Text_name:setColor(cc.c3b(218,218,218))
		if v.name == "推荐" then 	--推荐一直显示
			rowItem.Image_bg:setVisible(true)
			rowItem.Text_name:setColor(cc.c3b(245,180,83))
		else
			rowItem.Image_bg:setVisible(false)
		end
		rowItem:releaseFunc(function()
			self.currTitle = v.id
			self:setTitleItemBgHide()
			rowItem.Image_bg:setVisible(true)
			rowItem.Text_name:setColor(cc.c3b(245,180,83))
			self:showList(allGoods[v.id])
		end)
	end
end

function AnniversaryCelebrationConversionLayer:setTitleItemBgHide()
	local items = self.Panel_title.ListView_title:getItems()
	if MapIsEmpty(items) == false then 
		for k, item in pairs(items) do
			item.Image_bg:setVisible(false)
			item.Text_name:setColor(cc.c3b(218,218,218))
		end
	end
end

function AnniversaryCelebrationConversionLayer:updateTime(dt)
	if self.endTime then 
		local durationTime =  self.endTime - GetTime()
		if durationTime<=0 then 
			if self._handle ~= nil then
				self:unschedule(self._handle)
				self._handle = nil
				self.Text_time:setString("活动已结束")
				return
			end
		end
		local day = math.floor(durationTime/86400)
        local hour = math.floor(durationTime%86400/3600)
        local minute = math.floor(durationTime%3600/60)
        local second = math.floor(durationTime%60)
		local timeStr = "剩余时间："..tostring(day).."天"..tostring(hour).."时"..tostring(minute).."分"
		self.Text_time:setString(timeStr)
	end
end

function AnniversaryCelebrationConversionLayer:chongZhiBtnFunc()
	self.Button_add.Text_buttonName:setString("去充值")
	self.Button_add:releaseFunc(function()
		MainControllLayer:pushLayer("StoreLayer")
		local StoreLayer=MainControllLayer:getLayer("StoreLayer")
		StoreLayer:showWithAction(function()
		end)
		PopupLayerController:hideLayer("AnniversaryCelebrationConversionLayer")
		self:hide()
	end)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/27 12:17:58
-- @desc 去掉已经拥有的武功和面具
function AnniversaryCelebrationConversionLayer:colationList(list)
	--宝箱
	--技能宝箱 开技能
	local skillbaoxiang = {
		[1] = {
			"yuanxiaoleiji1",
			"yuanxiaoleiji2",
			"chunjieleiji4",
			"yuanxiaoleiji3",
			"yuanxiaoleiji5",
			"yuanxiaoleiji4",
			"yidaoliu",
			"yujianliuwuzang",
			"sanhuatu",
			"tiannvsanhuashou",
			"xinbawangqiangfa",
			"wuhenjinbox",
			"xiaolifeidao",
			"chunjieleiji3",
			"yuxianjue",
			"wuxingquan1",
			"lingxiyizhi",
			"jiayishengong",
			"tiancantuifa",
			"tianleipo1",
			"tingfengjing",
			"geludaofa",
			"wuxingquan1",
			"chunjieleiji2",
			-- "badaozhancanye1",
			"yirongshubox1",
			"zouxuejingbox1",
			"xiaoyaowuxiangjian1",
			"xianyindaofa1",
			"huaxuyinbox",
			"szjdj2",
			"shimenbuff2",
			"jiutianxianglongtui",
			"tianwangbuxinzhenfa",
			"qianlongfeidun",
			"jiangxingpoegou",
			"jiulongbianfa",
			"chilianlingbobox2",
			"hujiadaofa1",
			"yuenvjianfabox1",
			"xinmingyugong",
			"qishadaofa1",
			"wuxudaofa",
			"yinyangdaoluanren",
			"feixianjianfa",
			"baiyuanjianfa",
			"wuhenjinbox2",
			"zouxuezhenfa1",
			"zhengaoxuanjing",
			"yirongshu",
			"yinfengzhuabox1",
			"cangfengdaofa",
			"duohunmice",
			"tiexueshijian",
			"wangshenggong",
			"niyangong",
			"yilanshizhang",
			"dankuixuangong",
			"jingbogunfa",
			"canghubu",
			"yinyangguiyihuan",
			"mengtianzhang",
			"qianhunlie",
			"xiangmozhangfa",
			"qinlonggong",
			"jiangshibufa1",
			"aomeijue1",
			"lingyuanxinfa1",
			"lingxiaoxinfa1",
			"baiyuantongbeiquan",
			"jiugongliuhezhang",
			"wulangbaguagunbox1",
			"baimangbianfabox1",
			"chilianlingbobox1",
			"caiweijianfabox1",
			"fengbaojinxingqubox1",
			"zhuxianqinyinbox1",
			"qixingmizongbubox1",
			"kwTransform",
			"peripateticismgunbox",
		},
		[2] = {
			"liehuobianfa",
			"hualingliushuizhang",
			"takongxubu",
			{"changshengjue","changshengjueyin","changshengjueyang"},
			"fanliangyidaofa",
			"wuxingdunfa",
			"yidaoliu",
			"yidaoliu",
			"tiannvsanhua",
			"tiannvsanhua",
			"xinbawangqiangfa",
			"wuhenjin",
			"xiaolifeidao",
			"yechagunfa",
			"yuxianjue2",
			"wuxingquan",
			"lingxiyizhi",
			"jiayishengong",
			"tiancantuifa",
			"tianleipo",
			"tingfengjing",
			"geludaofa",
			"wuxingquan",
			"taixuangong",
			"yirongshu",
			"zouxueshisijing",
			"xiaoyaowuxiangjian",
			"xianyindaofa",
			"huaxuyin",
			{"shenzhaojing001","shenzhaojing002","shenzhaojing003"},
			"",
			"jiutianxianglongtui",
			"tianwangbuxinzhenfa",
			"qianlongfeidun",
			"jiangxingpoegou",
			"jiulongbianfa",
			"chilianlingbo",
			"hujiadaofa1",
			"yuenvjianfa",
			"xinmingyugong",
			"qishadaofa",
			"wuxudaofa",
			"yinyangdaoluanrenfa",
			"feixianjianfa",
			"baiyuanjianfa",
			"wuhenjin",
			"zouxueshisijing",
			"zhengaoxuanjing",
			"yirongshu",
			"yinfengzhua",
			"cangfengdaofa",
			"duohunmice",
			"tiexueshijian",
			"wangshenggong",
			"niyangong",
			"yilanshizhang",
			"dankuixuangong",
			"jingbogunfa",
			"canghubu",
			"yinyangguiyihuan",
			"mengtianzhang",
			"qianhunlie",
			"xiangmozhangfa",
			"qinlonggong",
			"jiangshibufa",
			"meihuashengong",
			"lingyuanxinfa",
			"lingxiaoxinfa",
			"baiyuantongbeiquan",
			"jiugongliuhezhang",
			"wulangbaguagun",
			"baimangbianfa",
			"chilianlingbo",
			"caiweijianfa",
			"fengbaojinxingqu",
			"zhuxianqinyin",
			"qixingmizongbu",
			"kwTransform",
			"peripateticismgun",
		}
	}
	--挂饰道具检测对应投放宝箱
	local appearanceItems = {
		["waiguan1"] = {"2021guashilihe1"},
		["waiguan2"] = {"2020guashi01","2021guashilihe2"},
		["waiguan3"] = {"2020guashi02","2021guashilihe3"},
		["waiguan4"] = {"2020guashi03","2021guashilihe4"},
		["waiguan5"] = {"2020guashi04","2021guashilihe5"},
		["waiguan6"] = {"2020guashi05","2021guashilihe13"},
		["waiguan7"] = {"2020guashi06","2021guashilihe6"},
		["waiguan8" ] = {"2021guashilihe12"},
		["waiguan9"] = {"2020guashi07","2021guashilihe7"},
		["waiguan10"] = {"2020guashi08","2021guashilihe8"},
		["waiguan11"] = {"2020guashi09","2021guashilihe9"},
		["waiguan12"] = {"2021guashilihe14","2021guashilihe10"},
		["waiguan13"] = {"2021guashilihe15"},
		["waiguan14"] = {"2021guashilihe11"},
		["waiguan15"] = {"2021guashilihe18"},
		["waiguan16"] = {"2021guashilihe16"},
		["waiguan17"] = {"2021guashilihe17"},
		["waiguan21"] = {"2022guashilihe20"},
		["waiguan20"] = {"2022guashilihe19"},
		["waiguan22"] = {"2022guashilihe21"},
	}

	-- Helper:print_lua_table(list)
	if list and type(list) == "table" then
		for k,v in pairs(list) do 
			local itemAttr = User:getRole():getOneItemByKey(v.itemId)
			if itemAttr ~= nil then
				if specialmap[v.itemId] ~= nil then
					if User:getRole():getItem(specialmap[v.itemId]) ~= nil then
						list[k].words = "你已经拥有该"..tostring(itemAttr.type)
						list[k].max = 0
						list[k].limit = 0
					end
				end

				if itemAttr.type == "面具" or itemAttr.type == "信物" or itemAttr.type == "挂饰" then
					if User:getRole():getItem(v.itemId) ~= nil then
						list[k].words = "你已经拥有该"..tostring(itemAttr.type)
						list[k].max = 0
						list[k].limit = 0
					end
					if User:getRole():getDecorative(v.itemId) ~= nil then
						list[k].words = "你已经拥有该"..tostring(itemAttr.type)
						list[k].max = 0
						list[k].limit = 0
					end

					if list[k].limit ~= 0 and itemAttr.type == "挂饰" then
						local itemIdList = appearanceItems[v.itemId]

						if MapIsEmpty(itemIdList) == false then
							local isTrue = false

							for i, itemId in ipairs(itemIdList) do
								if User:getRole():getItem(itemId) then
									isTrue = true
									break
								end

								if User:getRole():getckItem(itemId) then
									isTrue = true
									break
								end
							end

							if isTrue then
								list[k].words = "你已经拥有该"..tostring(itemAttr.type)
								list[k].max = 0
								list[k].limit = 0
							end
						end
					end

					list[k].limit = nil
				elseif itemAttr.type == "特殊道具" then
					if User:getRole():getItem(v.itemId) ~= nil then
						list[k].words = "你已经拥有该道具"
						list[k].max = 0
						list[k].limit = 0
					end
				elseif itemAttr.type == "宝箱" or itemAttr.type == "任务" then
					for i,value in pairs(skillbaoxiang[1]) do
						if value == v.itemId then
							local alreadyPurchased=false  --是否已购买
							if User:getRole():getItem(value) ~= nil then
								list[k].words = "你已经拥有该武学"
								list[k].max = 0
								list[k].limit = 0
								alreadyPurchased=true
							end
							if type(skillbaoxiang[2][i]) == "table" then
								for num,skillId in pairs(skillbaoxiang[2][i]) do 
									if User:getRole():getSkill(skillId) ~= nil then
										list[k].words = "你已经拥有该武学"
										list[k].max = 0
										list[k].limit = 0
										alreadyPurchased=true
										break
									end
								end
							else
								if User:getRole():getSkill(skillbaoxiang[2][i]) ~= nil then
									list[k].words = "你已经拥有该武学"
									list[k].max = 0
									list[k].limit = 0
									alreadyPurchased=true
								end
							end
							if alreadyPurchased==true and itemAttr.type == "任务" then 
								list[k].words="你已经拥有过该道具"
							end
						end

					end
				end

			end			
		end

		return list
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng	
-- @time 2017/06/28 16:22:35
-- @desc 物品排列顺序
--规则：兑换积分从低到高，id从低到高
function AnniversaryCelebrationConversionLayer:sortList(list)
	table.sort(list,function(a,b)
		return tonumber(a.id) < tonumber(b.id)
	end)
	return list
end

function AnniversaryCelebrationConversionLayer:checkItemIsSpcial(itemId)
	if type(itemId) ~= "string" then
		return
	end
	for k,v in pairs(special) do 
		if v.id == itemId then
			return true,v.name
		end
	end
	return false
end
function AnniversaryCelebrationConversionLayer:getSpecialItemDsc(itemId)
	if type(itemId) ~= "string" then
		return
	end
	for k,v in pairs(special) do 
		if v.id == itemId then
			return v.dsc
		end
	end
	return ""	
end

function AnniversaryCelebrationConversionLayer:__shopExchangeGoods(itemInfo, transId, successFunc)
	PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
		layer:setPopText("")
		layer:showLayer()
	end)

	HttpManagerEx:shopExchangeGoods(itemInfo ,function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			data = Helper:getDef(data,{})

			if Helper:getDef(data.isDis,false) == true then
				PopText("江湖名士兑换8.8折,实际花费"..tostring(data.romove_point).."积分")
			end

			local role = User:getRole()

			local reward = data.reward

			if MapIsEmpty(reward) == false then
				if reward.itype == 1 or reward.itype == 2 then
					role:addItemCount(reward.itemId, reward.number)
				elseif reward.itype == 3 then
					role:addAttr(reward.itemId, reward.number)
				end
	
				PopText("获得"..reward.name.."X"..tostring(reward.number))
			end
			
			if data.dataVer then
				role:getServerActionSystem():setDataVersion(data.dataVer)
			end

			if data.yashi_expired_time then  --江湖雅士体验卡额外处理
                role:updateYaShiStatus(data.yashi_expired_time)
            end

			if data.currencyVersion then
				role:setCurrencyVersion(data.currencyVersion)
			end

			if data.msg then
				PopText(data.msg)
			end

			TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)

			if successFunc then
				local callbackInfo = {
					totalScore = data.total_points
				}
				successFunc(callbackInfo)
			end
		elseif status == 200 and errcode == 1 then
			TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
			PopText(errmsg)
		else
			PopText(errmsg)
		end
		PopupLayerController:hideLayer("GlobalShadeLayer",function (layer)
			layer:hideLayer()
		end)
	end,IS_SHOW_WAITING)
end

function AnniversaryCelebrationConversionLayer:__showItemList(list)
	local count = 0
	self._itemInfoList = {}
	self.ListView_1:setScrollBarAutoHideEnabled(false)
	for i,v in ipairs(list) do
		count = count + 1

		local row = self.ListView_1:getItem(i-1)
		if row == nil then
			row = self:getItemPanel()
			self.ListView_1:pushBackCustomItem(row)
		end

		v.infoIndex = i

		local itemInfo = self:__getItemInfo(v)
		
		self:__initListItem(row, itemInfo)
	end


	local row_count = #self.ListView_1:getItems()
    if row_count - count > 0  then
        for i=row_count-1,count,-1 do
            self.ListView_1:removeItem(i)
        end
    end
end

function AnniversaryCelebrationConversionLayer:__getItemInfo(item)
	local itemInfo = {}
	itemInfo.text1 = item.name

	if self._shopId == "wudaoshop" then
		itemInfo.text2 = tostring(item.score).."武道值"
	else
		itemInfo.text2 = tostring(item.score).."积分"
	end

	itemInfo.color1 = cc.c3b(255, 255, 255)
	itemInfo.color2 = cc.c3b(186, 179, 93)

	if item.max and item.max <= 0 then
		itemInfo.color1 = cc.c3b(159, 159, 159)
		itemInfo.color2 = cc.c3b(159, 159, 159)
	end

	itemInfo.visible = true
	if item.limit ~= nil then
		if item.limit == 0 then
			itemInfo.visible = false
		else
			itemInfo.text3 = "(限购"..tostring(item.limit).."次)"
		end
	else
		itemInfo.visible = false
	end

	itemInfo.func = function()
		if item.max > 0 then
			self:__showItem(item)
		else
			PopText(item.words)
		end
	end

	return itemInfo
end

function AnniversaryCelebrationConversionLayer:__checkCanGetReward(item)
	local items = {}

	if item.itype == 1 or item.itype == 2 then
		items[item.itemId] = item.number
	end

    if User:getRole():checkCanBuyTwoOrMoreThings(items,true) == false then
        return false
    else
        return true
    end
end

function AnniversaryCelebrationConversionLayer:__initListItem(item, itemInfo)
	item.Text_name:setString(itemInfo.text1)
	item.Text_score:setString(itemInfo.text2)
	item.Text_name:setTextColor(itemInfo.color1)
	item.Text_score:setTextColor(itemInfo.color2)
	item.Text_1:setVisible(itemInfo.visible)
	item.Text_1:setString(itemInfo.text3)
	item:releaseFunc(function()
		if itemInfo.func then
			itemInfo.func()
		end
	end)
end

function AnniversaryCelebrationConversionLayer:__refreshListView(index)
	local item = tab[index]
	local itemInfo = self:__getItemInfo(item)
	local panel = self.ListView_1:getItem(index-1)
	self:__initListItem(panel, itemInfo)
end

function AnniversaryCelebrationConversionLayer:__refreshList(num, buyNumber)
	if not num then
		return
	end

	if tab[num].max ~= nil then
		tab[num].max = tab[num].max - buyNumber
	end

	if tab[num].limit ~= nil then
		tab[num].limit = tab[num].limit - buyNumber
	end

	for k,v in pairs(allGoods) do  --不同分类下同种物品同步删除
		if self.currTitle ~= k then 
			for index, goodsInfo in pairs(v) do 
				if tab[num].itemId == goodsInfo.itemId then 
					if goodsInfo.max ~= nil then
						goodsInfo.max = goodsInfo.max - buyNumber
					end
					if goodsInfo.limit ~= nil then
						goodsInfo.limit = goodsInfo.limit - buyNumber
					end
				end
			end
		end
	end
end

function AnniversaryCelebrationConversionLayer:__showItem(itemInfo)
	local goods = GoodsHelper:getGoodsResClass(itemInfo.goodsId)
	local viewType = goods:getViewType()
	local isShowView = viewType ~= 0
	print("isShowView:",viewType, isShowView,itemInfo.goodsId)

	PopupLayerController:showLayer("ChongZhiJiFenGoodsPresenter",function(layer)
		layer:setTitle("请确定兑换")
		layer:setTextDesc_1("    "..itemInfo.dsc)
		layer:setTextDesc_2("兑换可获得")
		layer:setTextDesc_3(itemInfo.name,itemInfo.number)

		layer:setTextDesc_4Visible(isShowView)
		if isShowView then
			layer:setTextDesc_4Func(function()
				PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
					layer:showLayer({{id = itemInfo.goodsId}})
				end)
			end)
		end

		layer:setText_1Str("将花费：")
		layer:setItemName(itemInfo.name)
		layer:setUnitPrice(itemInfo.score)
		layer:setBuyNumber(itemInfo.number)
		layer:setMaxBuyNumber(itemInfo.max)
		layer:setSelectText(tostring(itemInfo.number).."/"..tostring(itemInfo.max))

		if self._shopId == "wudaoshop" then
			layer:setPriceName("武道值")
			layer:setText_2Str(tostring(itemInfo.score).."武道值")
		else
			layer:setPriceName("积分")
			layer:setText_2Str(tostring(itemInfo.score).."积分")
		end

		layer:showLayer()
		layer:setButton_1Func(function(buyNumber)
			if self:getChangeFlag() == false then
				PopupLayerController:hideLayer("AnniversaryCelebrationConversionLayer")
				PopText("当前奖励列表已更换，请重新进入")
				self:hide()
				return
			end

			if not buyNumber then
				buyNumber = itemInfo.number
			end

			if buyNumber > itemInfo.max then
				PopText("当前购买次数已超上限！")
				return
			end

			if self:__checkCanGetReward(itemInfo) then
				TransCheck:setTransWithWebOrderId(function(transId)
					local goodsInfo = {
							itemId = itemInfo.itemId,
							client_trans_id = transId,
							shop_id = self._shopId,
							number = buyNumber,
							dataVer = User:getRole():getServerActionSystem():getDataVersion(),
							currencyVersion = User:getRole():getCurrencyVersion()
						}
						self:__shopExchangeGoods(goodsInfo,transId,function(data)
							self:__refreshList(itemInfo.infoIndex, buyNumber)
							self:__refreshListView(itemInfo.infoIndex)
							self:setTotalScore(data.totalScore)
					end)
					end, itemInfo.itemId, buyNumber, self.transType)
			end
		end)

		layer:setButton_2Func(function()
			layer:hideLayer()
		end)
	end)
end

function AnniversaryCelebrationConversionLayer:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function AnniversaryCelebrationConversionLayer:__setRuleFunc()
	self.Image_rule:releaseFunc(function()
        self:__showRule()
    end)
end

function AnniversaryCelebrationConversionLayer:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self.__ruleInfo)
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

Helper:classDefNodeGetInstance(AnniversaryCelebrationConversionLayer)

return AnniversaryCelebrationConversionLayer000
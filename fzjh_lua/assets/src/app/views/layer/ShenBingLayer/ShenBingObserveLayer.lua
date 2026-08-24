local Item = require("app.models.item.Item")
local Resource = require("app.Resource")

local  ShenBingObserveLayer = class("ShenBingObserveLayer",cc.Layer)

function ShenBingObserveLayer:create()
	local p = ShenBingObserveLayer:new()
	p:init()
	return p
end

function ShenBingObserveLayer:init()
	self._UI = require("Layer/ShenBing/ShenBingObserveUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUI(self)
	--点击背景打造界面隐藏
	self.Panel_back:releaseFunc(function (ref,eventType)
		PopupLayerController:hideLayer("ShenBingObserveLayer", function(layer)
			self:hide()
		end)
	end)
	self.Button_JiaGong:setVisible(false)
	self.Button_XiuLi:setVisible(false)
	self.Button_CuiLian:setVisible(false)

	self:show()

	self:ButtonJiaGong()
	

	self:initRichText()	
	self:print("他看起来约三十几岁，他生得HIG神清气爽，骨格清奇，宛若仙人NOR。\n他的武功看不出强弱，出手似乎HIG很轻NOR。\n曾机缘巧合得欧冶子授得几式锻造之术，为报恩情，便一直跟随其左右。欧冶子云游四海之时便会留下他看守玄兵古洞。")
	
	if User:getRole():getInheritFlag("开始神兵任务") ==2 then
		self.Button_JiaGong:setVisible(true)
		self.Button_XiuLi:setVisible(true)
		self.Button_CuiLian:setVisible(true)
	end
end
function ShenBingObserveLayer:show(ControllLayer)
	-- MainControllLayer = ControllLayer
	self:setVisible(true)

	self:ButtonTalk()
	self:ButtonXiuLi()
	self:ButtonCuiLian()
	self:ButtonXiuLi()
end

function ShenBingObserveLayer:initRichText()
	local x, y = self.Panel_Desc:getPosition()
	local size = self.Panel_Desc:getContentSize()
	
	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
   	self.Panel_Desc:getParent():addChild(richTextScroll)
   	richTextScroll:move(cc.p(90,730))
   	richTextScroll:setSize(size)   	
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)

   	-- self.RichText_print:setVerticalSpace(-5)

	-- self:print("HIY【HIB江HIM湖HIC通HIW告RAN】:RED欢GRN迎YEL来BLU到MAG天CYN下WHT第HIR一HIG.")
	-- self:print("测试")
end
local textColor = cc.c3b(159,159,159)
function ShenBingObserveLayer:print(str, verticalSpace)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 400 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end


-- 神兵界面控制隐藏 当前装备界面
function ShenBingObserveLayer:isShow()
	local shenBingLayer = MainControllLayer:getLayer("ShenBingLayer")
	if shenBingLayer.Panel_DuanZao:isVisible() then
		shenBingLayer.Panel_DuanZaoZhong:setVisible(false)
		shenBingLayer.Text_desc:setVisible(false)
		shenBingLayer.Button_1:setVisible(false)
	else
		shenBingLayer.Text_desc:setVisible(true)
		shenBingLayer.Panel_DuanZaoZhong:setVisible(true)
		shenBingLayer.Button_1:setVisible(true)
	end
    
    -- 如果装备了神兵显示 shenBingLayer.Panel_DuanZaoZhong 可以查看神兵详情
end

local talkList = {
	"YEL铁匠：珍稀的锻造材料可在江湖中获得，这个还是得看机缘呐。",
	"YEL铁匠：若是寻常材料，在城中铁匠处便能购到了。",
	"YEL铁匠：少侠，欧冶子大师吩咐我，以后跟着你，你有什么需要的直接使唤我便是了。"	
}
--交谈
function ShenBingObserveLayer:ButtonTalk()
	self.Button_Talk:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_Talk:releaseFunc(function()
		local shenBingLayer = MainControllLayer:getLayer("ShenBingLayer")
		local  role  = User:getRole()
			if   role:getInheritFlag("开始神兵任务") == 0 then
				local itemAttr = Item:getOneItemByKey("shenitem1")
				if itemAttr ~= nil  then
					if role:checkCanBuyThings("shenitem1",1) == true then
						role:setInheritFlag("开始神兵任务",1)
						role:addItemCount("shenitem1",1)
						shenBingLayer:print("HIY铁匠:不久就是华山沐清风前辈的生辰，欧冶子前辈与沐前辈有几分交情，前几日已经动身去华山了。只是他走得匆忙，忘了带贺礼，少侠能否去华山走一遭？")
						PopText("获得物品"..itemAttr.name.."X 1")
					else
						PopText("背包空间不足")
						
					end
				end
			elseif role:getInheritFlag("开始神兵任务") == 2 then
				local str = talkList[math.random(1,#talkList)]
				shenBingLayer:print(str)

			-- 如果副本中开启神兵任务道具丢失 重新给予一个
			elseif role:getInheritFlag("开始神兵任务") == 1 and  role:getInheritFlag("送给欧冶子") == 0 and role:getItemCount("shenitem1") == 0 then
				local itemAttr = Item:getOneItemByKey("shenitem1")
				if itemAttr ~= nil  then
					if role:checkCanBuyThings("shenitem1",1) == true then
						role:addItemCount("shenitem1",1)					
						shenBingLayer:print("HIY铁匠:刚刚那份贺礼我给错了，这才是要给沐清风前辈的贺礼，麻烦少侠再跑一趟华山给欧冶子前辈送过去。")
						PopText("获得物品"..itemAttr.name.."X 1")
					else
						PopText("背包空间不足")
						
					end
				end
			else
				shenBingLayer:print("HIY铁匠:少侠已经拿了贺礼，赶快去华山走一遭吧！")
			end
			PopupLayerController:hideLayer("ShenBingObserveLayer", function(layer)
				self:hide()
			end)
		-- end
	end)
end

function ShenBingObserveLayer:GoldCastAndNeiLiCast()
	local role = User:getRole()
	if role.shenBingweapon.material == "tie102" then
		role.shenBingweapon.neilicast = 100
		role.shenBingweapon.goldcast = 100
	elseif role.shenBingweapon.material == "tie103" then
		role.shenBingweapon.goldcast = 200
	elseif role.shenBingweapon.material == "tie104" then
		role.shenBingweapon.neilicast = 200
	end	
end

--加工
function ShenBingObserveLayer:ButtonJiaGong()
	self.Button_JiaGong:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_JiaGong:releaseFunc(function()
		local role = User:getRole()
		local items = role:getItems()
		local isTrue = false
		for k, itemData in pairs(items) do 
			if itemData.type == "神兵" then
				isTrue = true
				break
			end
		end 
		
		PopupLayerController:hideLayer("ShenBingObserveLayer", function(layer)
			self:hide()
		end)
		
		if isTrue == false then
			PopText("背包中没有神兵，无法使用该功能！")
		else
			local defaultShenBingItemId = role:getAttr("defaultShenBingItemId")
			if not defaultShenBingItemId then
				PopText("您还没有装上默认神兵，无法进行操作")
				return
			end
			PopupLayerController:showLayer("JiaGong", function(layer)
				layer:show()
			end)
		end
	
		
	end)
end
--修理
function ShenBingObserveLayer:ButtonXiuLi()
	self.Button_XiuLi:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_XiuLi:releaseFunc(function()
		require("app.views.layer.ShenBingLayer.FixLayer.ShenBingFixLayer"):showLayer(3)
		PopupLayerController:hideLayer("ShenBingObserveLayer", function(layer)
			self:hide()
		end)
	end)
end


-- 淬炼
function ShenBingObserveLayer:ButtonCuiLian()
	self.Button_CuiLian:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_CuiLian:releaseFunc(function()
		local role = User:getRole()

		local items = role:getItems(function(item)
			return item.type == "神兵"
		end)

		if MapIsEmpty(items) == false then
			local shenBing = role:getDefaultShenBing()

			if shenBing == nil then
				PopText("您还没有装上默认神兵，无法进行操作")
				return
			end
			-- ShenBingNPCCuiLianLayer
			PopupLayerController:showLayer("ShenBingNPCCuiLianLayer",function(layer)
				print("-----------------------------",shenBing.yindu)
				layer:showLayer(shenBing,3)
			end)
		else
			PopText("你身上没有神兵")
		end
		PopupLayerController:hideLayer("ShenBingObserveLayer", function(layer)
			self:hide()
		end)
	end)
end
function ShenBingObserveLayer:hideShenBing()
	self.Button_CuiLian:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_CuiLian:releaseFunc(function()	
		PopupLayerController:hideLayer("ShenBingObserveLayer", function(layer)
			self:hide()
		end)
	end)	
end

Helper:classDefNodeGetInstance(ShenBingObserveLayer)
return  ShenBingObserveLayer00
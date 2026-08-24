local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
local Item = require("app.models.item.Item")
local Resource = require("app.Resource")
local isGet = true

local  ShenBingMainObserveLayer = class("ShenBingMainObserveLayer",cc.Layer)

function ShenBingMainObserveLayer:create()
	local p = ShenBingMainObserveLayer:new()
	p:init()
	return p
end
--
function ShenBingMainObserveLayer:init()
	self._UI = require("Layer/ShenBing/ShenBingOuYeZiUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUI(self)
	--点击背景打造界面隐藏
	self.Panel_back:releaseFunc(function (ref,eventType)
		PopupLayerController:hideLayer("ShenBingMainObserveLayer", function(layer)
			self:hide(true)
		end)
	end)
	self:setVisible(true)
	self._talk = 1

	-- self:print("他头上包着头巾，三缕长髯飘洒胸前，面目清瘦但红晕有光，二目炯炯有神，烁烁闪着竟似是凛凛的剑光，浑身似乎都包围在一股剑气之中。\n他看起来约六十多岁，他生得HIG神清气爽，骨格清奇，宛若仙人NOR。\n他的武功看不出强弱，出手似乎HIG很轻NOR。")
end
function ShenBingMainObserveLayer:showLayer(npc_flag,flag)
	--npc_flag  : 1是铁匠，2为欧治子
	--flag 唐门之乱标记
	self:ButtonTalk(npc_flag,flag)
	self:ButtonDuanJian(npc_flag,flag)
	self:ButtonXiuLi(npc_flag,flag)
	self:ButtonCuiLian(npc_flag,flag)
	self:ButtonDuanDao(npc_flag,flag)
	self:ButtonDuanBian(npc_flag,flag)
	self:ButtonDuanGun(npc_flag,flag)
	self:ButtonJiaGong(npc_flag,flag)
	self:setButtonDuanQi(npc_flag,flag)
	self:setNpcDsc(npc_flag,flag)
	-- self:setVisible(true)
	self:show(true)
end

function ShenBingMainObserveLayer:setButtonDuanQi(npc_flag,flag)
	if npc_flag == 1 then 
		self.Button_DuanQi:setVisible(false)
	else
		self.Button_DuanQi:setVisible(true)
		self.Button_DuanQi:releaseFunc(function()
			PopupLayerController:hideLayer("ShenBingMainObserveLayer",function(layer)
				layer:hide()
			end)
			local ShenBingFixLayer = require("app.views.layer.ShenBingLayer.FixLayer.ShenBingDuanQiLayer")
			ShenBingFixLayer:showLayer(1,"欧冶子")
		end)

	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/22 10:03:09
-- @desc npc锻造等级
function ShenBingMainObserveLayer:setNPCForgeSkillLv(flag)
	if flag == 2 then
		self.forgeSkillLv = 300
	else

	end
end


function ShenBingMainObserveLayer:setNpcDsc(npc_flag,flag)
	npc_flag = Helper:getDef(npc_flag,1)
	local npcs = {
		[1] = {
			name = "铁匠",
			ch = "【锻造宗师】",
			dsc = "他头上包着头巾，三缕长髯飘洒胸前，面目清瘦但红晕有光，二目炯炯有神，烁烁闪着竟似是凛凛的剑光，浑身似乎都包围在一股剑气之中。\n他看起来约六十多岁，他生得HIG神清气爽，骨格清奇，宛若仙人NOR。\n他的武功看不出强弱，出手似乎HIG很轻NOR。"
		},
		[2] = {
			name = "欧冶子",
			ch = "【赤心剑胆】",
			dsc = "他头上包着头巾，三缕长髯飘洒胸前，面目清瘦但红晕有光，二目炯炯有神，烁烁闪着竟似是凛凛的剑光，浑身似乎都包围在一股剑气之中。\n他看起来约六十多岁，他生得HIG神清气爽，骨格清奇，宛若仙人NOR。\n他的武功看不出强弱，出手似乎HIG很轻NOR。"
		},
	}
	self:initRichText()	
	self:print(npcs[npc_flag].dsc)
	self.Text_OuYeZi_title:setString(npcs[npc_flag].ch)
	self.Text_title:setString(npcs[npc_flag].name)
end

function ShenBingMainObserveLayer:initRichText()
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
function ShenBingMainObserveLayer:print(str, verticalSpace)
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



-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:52:39
-- @desc 锻剑
function ShenBingMainObserveLayer:ButtonDuanJian(npc_flag,flag)
	if npc_flag == 1 then
		self.Button_DuanJian:setVisible(false)
	else
		self.Button_DuanJian:setVisible(true)
		self.Button_DuanJian:releaseFunc(function()
			self:weapenForge("剑")
		end)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:52:39
-- @desc 锻刀
function ShenBingMainObserveLayer:ButtonDuanDao(npc_flag,flag)
	if npc_flag == 1 then
		self.Button_DuanDao:setVisible(false)
	else
		self.Button_DuanDao:setVisible(true)
		self.Button_DuanDao:releaseFunc(function()
			self:weapenForge("刀")
		end)
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:52:39
-- @desc 锻棍
function ShenBingMainObserveLayer:ButtonDuanGun(npc_flag,flag)
	if npc_flag == 1 then
		self.Button_DuanGun:setVisible(false)
	else
		self.Button_DuanGun:setVisible(true)
		self.Button_DuanGun:releaseFunc(function()
			self:weapenForge("棍")
		end)
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:52:39
-- @desc 锻鞭
function ShenBingMainObserveLayer:ButtonDuanBian(npc_flag,flag)
	if npc_flag == 1 then
		self.Button_DuanBian:setVisible(false)
	else
		self.Button_DuanBian:setVisible(true)
		self.Button_DuanBian:releaseFunc(function()
			self:weapenForge("鞭")
		end)
	end
end

function ShenBingMainObserveLayer:weapenForge(weapenType)
	assert(type(weapenType) == "string")
	local canforge,text = self:canDuanzao()
	if canforge == false then
		RichPrint("main",text)
		PopupLayerController:hideLayer("ShenBingMainObserveLayer",function(layer)
			layer:hide()
		end)
		return
	end
	local itemAttr = Item:getOneItemByKey(canforge.itemId)
	PopupLayerController:showLayer("DialogUseLayer", function(layer)
		layer:show()
		layer:setTextDesc()
		layer:setTextUseGoods("将消耗"..itemAttr.name)
		--确定按钮
		layer:setButton1(function()
			--删除玩家背包中的物品
			local role = User:getRole()
			if role:addItemCount(itemAttr.id,-1)  then
				PopText("消耗了"..itemAttr.name)
			else
				PopText("扣除物品出错，锻造失败，请再次尝试锻造")
				return
			end
			-- PopupLayerController:hideLayer("ShenBingMainObserveLayer",)
			self:hide(true)
			self:printForgeText(canforge.itemId,weapenType)
		end)
		--取消按钮
		layer:setButton2()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/22 10:40:44
-- @desc 锻造过程中输出文本
function ShenBingMainObserveLayer:printForgeText(itemId,weapenType)
	assert(Item:getOneItemByKey(itemId))
	weapenType = Helper:getDef(weapenType,"刀")
	User:getRole():setFlag("PVP活动状态", "忙碌")
	local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
	local maplayer = MainControllLayer:getLayer("MapLayer")
	MapRoleLayer:statusButtonFunc(
		false,
		function ()
			RichPrint("main","锻造神兵中。")
		end
	)
	MapRoleLayer:exitButtonFunc(false,function()
		 RichPrint("main","锻造神兵中。")
	end)
	maplayer:setUnmoveRoom(true,function()
		RichPrint("main","锻造神兵中。")
	end)
	maplayer._currMap:setCanLeave(false)
	maplayer:setNPCTouchEnabled(true,function()
		RichPrint("main","锻造神兵中。")
	end)	
	local text_ =
	{
		[29] = "YEL欧冶子：好我们现在就开始造$w。侍$w！",
		[28] = "CYN欧冶子招来一位白衣少年，对他耳语几句。",
		[26] ="YEL侍$w点了点头。说：好吧！",
		[25] = "CYN侍$w回过身，转向身后的一个巨大的火炉，鼓动真气燃起了熊熊的大火。说：开始！",
		[23] = "BLU你双手握住一个巨大的铁锤，猛的向炉中渐渐红热起来的$Q挥去！ ",
		[22] = "RED只听得棚的一声巨响，锤头和$Q粘在了一起。",
		[21] = "YEL你只觉得掌心一热，浑身的血液似乎都沸腾了起来！",
		[20] = "HIM一身精血胶合着汩汩的内气，源源不断的向炉中的$Q涌去！",
		[19] = "HIR突然$N觉得气血一阵翻涌，一口真气接不上来。。。。",
		[13] = "HIR只听咯的一声轻响，$w从炉中倏然跃起。化作一道青电猛的向你的前胸刺来！！",
		[12] = "YEL侍$w见状大叫：神$w初成，人血以祭！！闪开！",
		[11] = "CYN你只觉得眼前一花，一条白影迅捷无比的挡在了你的身前。",
		[10] = "CYN$w透胸穿出，侍$w惨号一声，鲜血溅得你满脸都是！",
		[9] = "RED侍$w脚下一个不稳，倒在了地上。侍$w已经奄奄一息了。",
		[8] = "CYN$w又飞了起来，飞到半空，当的一声落回到地上。",
		[7] = "CYN炉中的火灭了。一室的劲气化于无形，一切又归于沉寂。" ,
		[5] = "YEL侍$w摸起地上带着斑斑血迹还有些烫手的$w，说：$w。。已。。成。。，侍$w的任务。。。也就完成了。。。。",
		[3] = "YEL侍$w艰难的说：$w。。您。。收好，我该走了。。。",
		[2] = "CYN侍$w说完。倏的便不见了。",
	}
	if weapenType == "剑" then
		text_[28] = "CYN欧冶子招来一位表情冷峻的白衣少年，对他耳语几句。"
		text_[11] = "CYN你只觉得眼前一花，一条白影迅捷无比的挡在了你的身前。"
	elseif weapenType == "鞭" then
		text_[28] = "CYN欧冶子招来一位身着青衣的妙龄少女，对他耳语几句。"
		text_[11] = "CYN你只觉得眼前一花，一条青影迅捷无比的挡在了你的身前。"
	elseif weapenType == "棍" then
		text_[28] = "CYN欧冶子招来一位外表憨厚的年轻小伙，对他耳语几句。"
		text_[11] = "CYN你只觉得眼前一花，一条白影迅捷无比的挡在了你的身前。"
	else
		text_[28] = "CYN欧冶子招来一位皮肤黝黑的蓝衣少年，对他耳语几句。"
		text_[11] = "CYN你只觉得眼前一花，一条蓝影迅捷无比的挡在了你的身前。"
	end
	for i = 1,30 do
		self:delayFunc(i,function()
			local num = 30 - i 
			if text_[num] then
				text_[num] = string.gsub(text_[num], "$N", "你")
				text_[num] = string.gsub(text_[num], "$w",weapenType)
				text_[num] = string.gsub(text_[num], "$W", weapenType)
				text_[num] = string.gsub(text_[num], "$Q", "长"..weapenType)
				RichPrint("main",text_[num])
			end
		end)
	end
	self:delayFunc(31,function()
		self:createWeapenBaseInfo(itemId,weapenType)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/22 10:52:23
-- @desc 根据使用的材料，类型生成基本属性
function ShenBingMainObserveLayer:createWeapenBaseInfo(itemId,weapenType)
	assert(Item:getOneItemByKey(itemId))
	weapenType = Helper:getDef(weapenType,"刀")
	-- self.weapen.id = "weapon_"..tostring(Helper:getDef(User:getRole():getAttr("forgeCount"),0))
	local bType = "长刀"
	if weapenType == "剑" then
		bType = "长剑"
	elseif weapenType == "鞭" then
		bType = "长鞭"
	elseif weapenType == "棍" then
		bType = "长棍"
	end
	--硬度	坚韧度	特性值	重量
	local yingdu,rendu,texing,weight,damage = self:randomAttribute(weapenType)
	local baseInfo = ShenBingDuanZao:getShenBingFurnaceProperty(itemId,bType)
	local forgeCount = Helper:getDef(User:getRole():getAttr("forgeCount"),0)
	local weapen = {
		id = "weapon_"..tostring(forgeCount), 	-- 必须唯一
		name = Helper:getDef(baseInfo.forgingweapon,"")	,		-- 名字 
		type = weapenType,	-- 武器类型
		wpType = "神兵", 	-- 类型 (用于区分神兵和普通兵器)
		bType = bType,--
		nameColor = Helper:getDef(baseInfo.Forgingcolor,"WHT"),
		damage =  damage,		-- 伤害值
		yindu = yingdu, 		-- 硬度值
		rendu =  rendu, 		-- 韧度值
		weight = weight,		-- 重量值
		effctNum = texing,	-- 特性值 (计算得出,到达一定值可开启特效)
		naijiu = 100,	-- 当前耐久度 (耐久度小于等于0表示已损坏,需要修理,同时完好度需变为0.耐久度一般由硬度和渐坚韧度计算得出)
		wanhaodu = 100,	-- 完好度 (损坏完好度为0, 修理后耐久度修复,完好度根据计算得出)
		effct1 = "",		-- 特效1
		effct2 = "",		-- 特效2
		effct3 = "",		-- 特效3 (暂定三个特效,特效效果读取资源配置表)
		cuilianitems = {},  -- 加工使用的物品列表 {itemid = count}
		useNeiLi = 0,		-- 注入的内力值
		desc = "",			-- 武器的描述,在第一次载入的时候计算生成(生成规则查看策划案)
		lookDesc = "", 		-- 外观描述
		equipDescId = "",	--装备描述与拖下描述 的Id
		weaponLookId = "",
		typeDesc = Helper:getDef(baseInfo.Forgingdsc,""),
		status = 2, 		-- 铸造状态 0 铸造中,1 铸造完成未取名,2 铸造完成已取名
		canEquip = 1 ,		-- 可装备
		cuilianCount = 0,    -- 淬炼成功次数
		cuilianFailedCount = 0,   -- 淬炼失败次数
		--- 预备属性 (不知要以后会不会要用,建议保存记录到本地,并且定期上传至服务器)
		duanzaoitems = {itemId = baseInfo.itemid, num = 1},	-- 锻造使用的物品列表 {itemid = count}
		cuilian = {}	-- 淬炼统计,列表,每次淬炼记录一条 {xlType = "欧冶子", itemid = "", cost = 500, result = "success"}
	}
	-- User:getRole():setAttr("forgeCount",forgeCount+1)
	--穿上脱下描述
	local descList = ShenBingDesc:getRandomWeaponWeardes(weapen)
	--特效1
	local specialId,key = ShenBingDuanZao:getWeapenSpecialId(weapen)
	if key ~= nil then
		weapen[key] = specialId
	end
	assert(descList)
	weapen.equipDescId = descList.desid
	--生成描述
	weapen.desc = ShenBingDesc:getShenBingDesc(weapen)
	local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
	local maplayer = MainControllLayer:getLayer("MapLayer")
	
	if isGet then
		isGet = false
		PopupLayerController:showLayer("ShenBingNameLayer",function(layer)
			layer:showLayer(1,weapen,function(rweapen)
				User:getRole():setFlag("PVP活动状态", "空闲中")
				MapRoleLayer:statusButtonFunc(true)
				MapRoleLayer:exitButtonFunc(true)
				maplayer:setUnmoveRoom(false)
				maplayer._currMap:setCanLeave(traceback)
				maplayer:setNPCTouchEnabled(false)
				weapen = rweapen
				ShenBingDuanZao:getNewShenBingWeapen(weapen)
				if User:getRole():addItemCount(weapen.id,1) == true then
					ShenBingDuanZao:setShenBingStateInShenBingItems(weapen.id,3)
				end
				isGet = true
				PopText("获得神兵"..weapen.name)
				PopupLayerController:hideLayer("ShenBingMainObserveLayer",function(layer)
	
				end)
			end)
		end)
	end
	
	User:getRole():addAttr("forgeCount",1)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/22 14:21:50
-- @desc 随机属性
function ShenBingMainObserveLayer:randomAttribute(weapenType)
	weapenType = Helper:getDef(weapenType,"刀")
	--返回值 硬度	坚韧度	特性值	重量,伤害力
	if weapenType == "刀" then
		return math.random(40,60),math.random(40,60),math.random(18,30),math.random(16,20),math.random(50,70)
	elseif weapenType == "剑" then
		return math.random(45,70),math.random(45,70),math.random(15,25),math.random(27,32),math.random(40,80)
	elseif weapenType == "鞭" then
		return math.random(50,80),math.random(35,60),math.random(10,18),math.random(40,45),math.random(45,65)
	else
		return math.random(30,40),math.random(30,40),math.random(10,30),math.random(15,18),math.random(20,60)
	end
end
-- -----------------------------------------------------------------------------------------------------------
-- -- @author GaoHanZheng
-- -- @time 2017/12/22 11:37:06
-- -- @desc 最终的属性描述
-- function ShenBingMainObserveLayer
local talkText = {
	{"YEL在我这可用HIG寒丝羽竹NOR，HIM海底金母NOR，RED千年神木NOR铸造兵器，但你也需有材料，我方可帮你。"},
	{
		"YEL欧冶子抚剑而歌：巨阙神兵兮，人铸就。盖世宝剑兮，配英雄！",
		"YEL欧冶子低头沉吟，似乎在思考什么。",
		"YEL欧冶子叹了一口气：神兵配英雄，可英雄。。。。。。"
	},
	{"YEL铸造兵器可用HIG寒丝羽竹NOR，HIM海底金母NOR，RED千年神木NOR。但效果各不一样。"},
	{"YEL据说苏州水底可寻到HIG寒丝羽竹NOR，HIM海底金母NOR，RED千年神木NOR，也不知真假与否啊。"},
	{"老夫云游四海，便是要寻得珍稀之材来锻造绝世神兵。"},
	{"唉，这江湖之中，名匠已是不多了。"},
	{"老夫行走江湖多载，吃饭靠的是这手艺。"},
	{"哼，让老夫淬炼可得准备好金子，你还别嫌贵，老夫这手艺在这江湖上可是独一份。"}
}

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:52:39
-- @desc 交谈
function ShenBingMainObserveLayer:ButtonTalk(npc_flag,flag)
	if npc_flag == 1 then
		self.Button_Talk:setPositionX(524)
	else
		self.Button_Talk:setPositionX(733.60)
	end
	self.Button_Talk:releaseFunc(function()
		local  role  = User:getRole()
			local text = talkText[math.random(1,#talkText)]
			for k,str in pairs(text) do 
				RichPrint("main",str)
			end
			--设置标记
			PopupLayerController:hideLayer("ShenBingMainObserveLayer", function(layer)
				self:hide()
			end)
		-- end
	-- end)
		-- PopupLayerController:hideLayer("ShenBingMainObserveLayer",function(layer)
		-- 	layer:hide()
		-- end)
	end)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:52:39
-- @desc 加工
function ShenBingMainObserveLayer:ButtonJiaGong(npc_flag,flag)
	if npc_flag == 1 then
		self.Button_JiaGong:setPositionX(524)
	else
		self.Button_JiaGong:setPositionX(733.60)
	end
	self.Button_JiaGong:setVisible(Helper:getDef(flag,false))
	self.Button_JiaGong:releaseFunc(function()
		local items = User:getRole():getItems()
		local isTrue = false

		for k, itemData in pairs(items) do 
			if itemData.type == "神兵" then
				isTrue = true
				break
			end
		end 

		PopupLayerController:hideLayer("ShenBingMainObserveLayer", function(layer)
			self:hide()
		end)

		if isTrue == false then
			PopText("背包中没有神兵，无法使用该功能！")
		else
			if not User:getRole():getDefaultShenBing() then
				PopText("您还没有装上默认神兵，无法进行操作")
				return
			end

			PopupLayerController:showLayer("JiaGong", function(layer)
				layer:show()
			end)
		end
	end)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:52:39
-- @desc 修理
function ShenBingMainObserveLayer:ButtonXiuLi(npc_flag,flag)
	if npc_flag == 1 then
		self.Button_XiuLi:setPositionX(524)
	else
		self.Button_XiuLi:setPositionX(733.60)
	end
	self.Button_XiuLi:setVisible(Helper:getDef(flag,false))
	self.Button_XiuLi:releaseFunc(function()
		PopupLayerController:hideLayer("ShenBingMainObserveLayer",function(layer)
			layer:hide()
		end)
		local ShenBingFixLayer = require("app.views.layer.ShenBingLayer.FixLayer.ShenBingFixLayer")
		ShenBingFixLayer:showLayer(2)
	end)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:52:39
-- @desc 淬炼
function ShenBingMainObserveLayer:ButtonCuiLian(npc_flag,flag)
	if npc_flag == 1 then
		self.Button_YiShi:setPositionX(524)
	else
		self.Button_YiShi:setPositionX(733.60)
	end
	self.Button_YiShi:setVisible(Helper:getDef(flag,false))
	self.Button_YiShi:releaseFunc(function()
		PopupLayerController:hideLayer("ShenBingMainObserveLayer",function(layer)
			layer:hide()
		end)

		local role = User:getRole()

		local items = role:getItems(function(item)
			return item.type == "神兵"
		end)
		
		if MapIsEmpty(items) == false then
			local shenBing = role:getDefaultShenBing()

			if not shenBing then
				PopText("您还没有装上默认神兵，无法进行操作")
				return
			end
			
			PopupLayerController:showLayer("ShenBingNPCCuiLianLayer",function(layer)
				layer:showLayer(shenBing,2)
			end)
		else
			PopText("背包中没有可淬炼的兵器")
		end	
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/22 10:12:15
-- @desc 背包空间
function ShenBingMainObserveLayer:checkCanForgeShenBing()
	-- local result,text = true,""
	local role = User:getRole()
	if #role:getItems() >= role:getAttr("weight") then
		return false,"背包空间不足"
	end

end



--能锻造的条件
function ShenBingMainObserveLayer:canDuanzao()
	--判断是否能打造的  还要判断是有物品
	local role = User:getRole()
	-- if not User:getRole():getFlag("神兵") == "Y"  then
	-- 	return false
	-- end
	if #role:getItems() >= role:getAttr("weight") then
		return false,"背包空间不足"
	end

	if ShenBingDuanZao:checkBagCanAddShenBing() == false then
		return false, "背包神兵已达到可携带上限"
	end

	local shenBingNumLimit = role:getAttr("shenBingNumLimit")
	if #role:getAttr("shenBingItems") >= shenBingNumLimit then
		return false,"你已经拥有足够多的神兵了"
	end
	
	local tie102,tie103,tie104 = role:getItemsWithItemId("tie102"),role:getItemsWithItemId("tie103"),role:getItemsWithItemId("tie104")
	if not MapIsEmpty(tie102) then
		return tie102[1]
	end
	if not MapIsEmpty(tie103) then
	
		return tie103[1]
	end
	if not MapIsEmpty(tie104) then
		return tie104[1]
	end
	return false,"打造兵器需要材料，你可以询问一下欧冶子，看看有没有什么线索。"
end



Helper:classDefNodeGetInstance(ShenBingMainObserveLayer)
return  ShenBingMainObserveLayer000000000000
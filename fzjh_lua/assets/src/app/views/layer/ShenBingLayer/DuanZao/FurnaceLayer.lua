
local  FurnaceLayer = class("FurnaceLayer",cc.Layer)
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
local Meridian = require("app.models.Meridian.Meridian")

function FurnaceLayer:create()
	local p = FurnaceLayer:new()
	p:init()
	return p
end

function FurnaceLayer:init()
	self._UI = require("Layer/ShenBing/FurnaceUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setVisible(false)
	self:initRichText()
	-- self:ButtonBack()
	self:setFurnaceDsc()
	self.tmp = 800
	self.isHomeLandDZ = nil
	self.gjZcLv = nil
	self.Panel_duanshao.Button_neili:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
	self.Panel_duanshao.Button_ranliao:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
	self.Panel_duanshao.Button_qiaoda:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
	self.Panel_duanshao.Button_cuihuo:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
	self:setNeiLiAndGold()
	self:setRongBingBtn()
	self:setShenBingNumLimitUpgradeBtn()
	self:setShenBingLimitDesc()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 20:19:13
-- @desc 入口
function FurnaceLayer:entryLayer(tmp,isHomeLandDZ,gjZcLv)
	self:initReplacement()
	self.tmp = Helper:getDef(tmp,800)
	self.isHomeLandDZ = Helper:getDef(isHomeLandDZ,false)
	self.gjZcLv = gjZcLv

	Audio:pauseMusic()
end


function FurnaceLayer:showLayer()
	self.Button_duanzao:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
	self:setNeiLiAndGold()
	self:chooseItem()
	self:setFurnaceButton()
	self:reSetPanelAndButton()
	self:initNewWeapen()
	self:setBackButton()
	self:setFurnaceItemList({})
	self:setShenBingLimitDesc()
	self._furnace = {}
	self._left = {}
	self._right = {}
	self:show()


	--测试功能，正常流程不应该放在此处
	-- self:print("RED测试数据")
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 10:18:46
-- @desc 补领
function FurnaceLayer:initReplacement()
	local flag = User:getRole():getInheritFlag("神兵锻造")

	if type(flag) == "table" then
		-- Helper:print_lua_table(flag)
		if flag.name == "锻造失败" then
			self.Panel_duanshao:setVisible(false)
			self.Button_duanzao:setVisible(true)
			self.Button_duanzao.Text_buttonName:setString("领取")
			self:setCaiLisoListVisible(true)
			local item = Item:getOneItemByKey(flag.itemId)
			print("---------------补领神兵------------------",item.name)
			Helper:print_lua_table(item)
			if item ~= nil then
				self:setFurnaceItemList(item.name,false)
				self.Button_duanzao:releaseFunc(function()
					User:getRole():setInheritFlag("神兵锻造",0)
					if User:getRole():checkCanBuyThings(flag.itemId,1) == true then
						User:getRole():addItemCount(flag.itemId,1)
						PopText("获得物品"..item.name.."X 1")
						self:showLayer()
					else
						PopText("背包空间不足")
					end
				end)
			else
				self:showLayer()
			end
		elseif flag.name == "锻造神兵" then
			self.Panel_duanshao:setVisible(false)
			self.Button_duanzao:setVisible(true)
			self.Button_duanzao.Text_buttonName:setString("领取")
			self:setCaiLisoListVisible(true)
			local weapen = ShenBingDuanZao:getShenBingWeapenUnreceive()
			if weapen ~= nil then
				local list = {
					-- { name = ""},
					{ name = ""},
					{ name = "HIC"..weapen.name},
					{ name = "伤害力+"..tostring(weapen.damage)},
					{ name = ShenBingDesc:getWeightDesc(weapen).weight1dsc},
					{ name = ShenBingDesc:getYingDuDesc(weapen).hard1dsc},
					{ name = ShenBingDesc:getRenDuDesc(weapen).Tenacity1dsc}
				}
				self:setFurnaceItemList(list,false)
				local isGet = true
				self.Button_duanzao:releaseFunc(function()
					if isGet then
						isGet = false
						if #User:getRole():getItems() < User:getRole():getAttr("weight") then
							if ShenBingDuanZao:checkBagCanAddShenBing() == true then
								PopupLayerController:showLayer("ShenBingNameLayer",function(layer)
									layer:showLayer(1,weapen,function(rweapen)
										weapen.status = 2
										weapen = rweapen
										isGet = true
										ShenBingDuanZao:updateShenBingInfo(weapen)
										if User:getRole():addItemCount(weapen.id,1) == true then
											User:getRole():setInheritFlag("神兵锻造",0)
											PopText("领取神兵"..weapen.name)
											ShenBingDuanZao:setShenBingStateInShenBingItems(weapen.id,3)
											self:showLayer()
										end
									end)
								end)
							else
								isGet = true
								PopText("背包神兵已达到可携带上限")
								return
							end
						else
							isGet = true
							PopText("背包空间不足")
							return
						end
					end
				end)
			end
		else
			self:showLayer()
		end
	else
		self:showLayer()
	end


end


function FurnaceLayer:initNewWeapen()
	self.weapen = {
		id = onlyid, 	-- 必须唯一
		name = "",		-- 名字 
		type = "刀",	-- 武器类型
		wpType = "神兵", 	-- 类型 (用于区分神兵和普通兵器)
		damage = 0,		-- 伤害值
		yindu = 0, 		-- 硬度值
		rendu = 0, 		-- 韧度值
		weight = 0,		-- 重量值
		effctNum = 0,	-- 特性值 (计算得出,到达一定值可开启特效)
		wanhaodu = 100,	-- 完好度 (损坏完好度为0, 修理后耐久度修复,完好度根据计算得出)
		effct1 = "",		-- 特效1
		effct2 = "",		-- 特效2
		effct3 = "",		-- 特效3 (暂定三个特效,特效效果读取资源配置表)
		cuilianitems = {},  -- 加工使用的物品列表 {itemid = count}
		useNeiLi = 0,		-- 注入的内力值
		desc = "",			-- 武器的描述,在第一次载入的时候计算生成(生成规则查看策划案)
		equipDescId = "",	--装备描述与拖下描述 的Id
		weaponLookId = "",	--外观描述
		getoffDesc = "", 		-- 拖下描述
		status = 0, 		-- 铸造状态 0 铸造中,1 铸造完成未取名,2 铸造完成已取名
		canEquip = 1 ,		-- 可装备
		cuilianCount = 0  ,  -- 淬炼成功次数
		cuilianFailedCount = 0  , -- 淬炼失败次数
		--- 预备属性 (不知要以后会不会要用,建议保存记录到本地,并且定期上传至服务器)
		duanzaoitems = {},	-- 锻造使用的物品列表 {itemid = count}
		cuilian = {}	-- 淬炼统计,列表,每次淬炼记录一条 {xlType = "欧冶子", itemid = "", cost = 500, result = "success"}
	}
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/19 12:04:34
-- @desc 退出按钮
function FurnaceLayer:setBackButton()
	local titleLayer = MainControllLayer:getLayer("TitleLayer")
	titleLayer:ButtonBack(function()
		if self.canLeave == false then
			PopText("锻造神兵怎能分心，不要浪费了神物")
		else
			titleLayer:setTitleBack()
			MainControllLayer:popLayer()
		end
	end)

end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 11:18:19
-- @desc 重置空间状态以及按钮名称
function FurnaceLayer:reSetPanelAndButton()
	self:setFurnaceItemList({})
	self.Panel_duanshao:setVisible(false)
	self.Button_duanzao:setVisible(true)
	self.Panel_Furnace:setVisible(false)
	self.Panel_duanshao.Button_neili:setTouchEnabled(false) 
	self.Panel_duanshao.Button_ranliao:setTouchEnabled(false)  
	self.Panel_duanshao.Button_qiaoda:setTouchEnabled(false)  
	self.Panel_duanshao.Button_cuihuo:setTouchEnabled(false)
	self.Panel_tips:setVisible(false)
	self.Panel_tip:setVisible(false)
	self.Panel_duanshao.Button_neili:releaseFunc(function()

	end) 
	self.Panel_duanshao.Button_ranliao:releaseFunc(function()

	end)   
	self.Panel_duanshao.Button_qiaoda:releaseFunc(function()

	end)  
	self.Panel_duanshao.Button_cuihuo:releaseFunc(function()

	end) 
	self:setCaiLisoListVisible(true)
	for i=1,4 do 
		self.Panel_duanshao["Text_dsc"..tostring(i)]:setVisible(false)
	end
	self.Button_duanzao.Text_buttonName:setString("开始锻造")
	self.Button_duanzao:setPositionX(300)
	self.Button_rongbing:setVisible(true)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:19:14
-- @desc 设置内力和金钱数值
function FurnaceLayer:setNeiLiAndGold()
	local role = User:getRole()
	local neili,neiliMax = math.ceil(role:getAttr("neili")),math.ceil(role:getFinalAttr("neiliMax"))
	local gold = role: getAttr("gold")
	self.Text_neili_num:setString(tostring(neili).."/"..tostring(neiliMax))
	self.Text_gold_num:setString(tostring(gold))
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 20:22:10
-- @desc 锻造炉描述
function FurnaceLayer:setFurnaceDsc()
	self.Text_dsc:setString("这是一个巨大的锻造炉，锻造炉中炉火常年不熄，旁边还有诸多锻造所用的工具，在这似乎可以打造自己想要的东西。")
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 20:26:32
-- @desc 锻造炉中已经投放的材料
function FurnaceLayer:setFurnaceItemList(items,flag)
	if flag ~= false then
		if type(items) ~= "table" then
			return
		end
		self.ListView_1:removeAllItems()
		if MapIsEmpty(items) == true then
			local list = {
				{ name = ""},
				{ name = ""},
				{ name = ""},
				{ name = "WHT点击放入材料"},
			}
			self:setFurnaceButton({})
			self:setFurnaceItemList(list,false)
			return
		end
		if #items == 1 then
			--增加两个空panel
			self.ListView_1:pushBackCustomItem(self:createItemPanel("Panel_item",{name = ""},1))
			self.ListView_1:pushBackCustomItem(self:createItemPanel("Panel_item",{name = ""},1))
			self.ListView_1:pushBackCustomItem(self:createItemPanel("Panel_item",{name = ""},1))
		end
		for k, itemData in pairs(items) do 
			-- Helper:print_lua_table(items)
			local item = Item:getOneItemByKey(itemData.itemId)
			if item == nil then
				assert(nil,"显示锻造炉中已投放材料时，遇到一个不存在的物品，终止流程,itemd = "..tostring(itemData.itemId))
			end
			print(item.name,itemData.count)
			local row = self:createItemPanel("Panel_item",item,itemData.count)
			if row == nil then
				assert(nil)
			else
				row.Text_item:enableOutline(cc.c4b(17, 18, 18, 255), 5)
				row:setVisible(true)
			end
			self.ListView_1:pushBackCustomItem(row)
			print("----------------------:",row:getPositionX(),row:getPositionY())
		end
		self.ListView_1:jumpToTop()
		self:setFurnaceButton(items)
	else
		self.ListView_1:removeAllItems()
		if type(items) == "table" then
			for k,v in pairs(items) do 
				print(v.name)
				self.ListView_1:pushBackCustomItem(self:createItemPanel("Panel_item",{name = v.name},1))
			end
		else
			self.ListView_1:pushBackCustomItem(self:createItemPanel("Panel_item",{name = items},1))
		end
	end
end


function FurnaceLayer:onResume()
	local list = {
		["android"] = true,
		-- ["ios"] = {},
		-- ["fzjh"] = {},
	}

	local titleLayer = MainControllLayer:getLayer("TitleLayer")
	if titleLayer then
		titleLayer:setTipFunc(function(func)
			if list[device.platform] ~= nil and (list[device.platform] == true or list[device.platform][CURR_DEVICE_CHANNEL] == true) then
				local DialogKlayer = require("app.views.layer.DialogLayer.ShenBingGuiZe")
				local dialog = DialogKlayer:getInstance()
				dialog:hide()
				local str = "CYN锻造规则：\n锻造兵器需经历投入材料、熔炼、锻打、淬火四个步骤。\n \n投入材料规则：\n只有特定的锻造材料方可放入锻造炉进行煅烧，锻造材料可从江湖熔炼、江湖购买、历练任务、黑市商人、江湖掉落获得。\n \n熔炼规则：\n熔炼分为锻造熔炼和副本熔炼，锻造熔炼专门熔炼锻造材料，通过当前炉温与材料熔点来决定熔炼阶段的优劣，如果炉温远低于材料熔点，将导致锻造熔炼失败。\n江湖熔炼可产出所有锻造材料，可将材料放入熔炼中煅烧，通过当前炉温与材料熔点来决定熔炼阶段的成败，高级锻材需要多种材料进行煅烧。\n炉温可通过注入内力和投入燃料进行提升，注入内力需消耗内力最大上限，普通燃料可在各大城市的铁匠处购买，高级燃料可从黑商和江湖掉落获得。\n \n锻打规则：\n锻打熔炼好的材料可将其打造成兵器，锻造等级越高，兵器锻造属性就越高，锻造属性有一定随机波动，一次锻造最多锻打5次，5次后继续锻打，材料将损毁，若不想继续锻打点击淬火完成锻造。"
				

				dialog:showLayer("锻造规则",str,func)
			else
				local DialogKlayer = require("app.views.layer.DialogLayer.DialogKLayer")
				local dialog = DialogKlayer:getInstance()
				dialog:hide()
				local str = "锻造规则：\n锻造兵器需经历投入材料、熔炼、锻打、淬火四个步骤。\n \n投入材料规则：\n只有特定的锻造材料方可放入锻造炉进行煅烧，锻造材料可从江湖熔炼、江湖购买、历练任务、黑市商人、江湖掉落获得。\n \n熔炼规则：\n熔炼分为锻造熔炼和副本熔炼，锻造熔炼专门熔炼锻造材料，通过当前炉温与材料熔点来决定熔炼阶段的优劣，如果炉温远低于材料熔点，将导致锻造熔炼失败。\n江湖熔炼可产出所有锻造材料，可将材料放入熔炼中煅烧，通过当前炉温与材料熔点来决定熔炼阶段的成败，高级锻材需要多种材料进行煅烧。\n炉温可通过注入内力和投入燃料进行提升，注入内力需消耗内力最大上限，普通燃料可在各大城市的铁匠处购买，高级燃料可从黑商和江湖掉落获得。\n \n锻打规则：\n锻打熔炼好的材料可将其打造成兵器，锻造等级越高，兵器锻造属性就越高，锻造属性有一定随机波动，一次锻造最多锻打5次，5次后继续锻打，材料将损毁，若不想继续锻打点击淬火完成锻造。"
				

				dialog:showLayer("锻造规则",str,func)
			end
		end)

		self:setBackButton()
	end

end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 20:33:52
-- @desc 
function FurnaceLayer:createItemPanel(name,item,count)
	assert(self[name],"没有名为"..name.."的控件")
	if type(item) ~= "table" then
		return
	end
	local row = self[name]:clone()
	row:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
	Helper:convertUIByParent(row)
	local str = item.name
	if count ~= nil and count > 1 then
		str = str .. "X"..tostring(count)
	end
	row.Text_item:setString(str)
	row.Text_item:enableOutline(cc.c4b(26, 26, 26, 255), 5)
	return row
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 20:52:16
-- @desc 选择材料
function FurnaceLayer:chooseItem(items)
	self.Panel_touch:releaseFunc(function()
		if self.start == true then
			PopText("炉火已经燃起，不能再更换锻造材料")
			return
		end
		PopupLayerController:showLayer("ShenBingBagLayer",function(layer)
			layer:btnLeftClickFunc(function()
				layer:destory()
				-- layer:hide()
			end, "取消")
			
			layer:btnRightClickFunc(function(leftList,rightList)
				print("右边列表")
				if DEBUG_MODE == 1 then
					Helper:print_lua_table(rightList)
				end
				if #rightList == 1 then
					if ShenBingDuanZao:checkItemCanFurnace(rightList[1].itemId) == false then
						PopText("该物品不可被锻造")
						return
					else
					end
					self:setFurnaceItemList({{itemId = rightList[1].itemId,count = rightList[1].count}})
					self._furnace.cailiao = rightList[1].itemId
					self:chooseItem(rightList)
				else
					self:setFurnaceItemList({})
					self:chooseItem()
				end
				self._left = leftList
				self._right = rightList
				layer:destory()
			end, "确定")
			
			layer:setCondiPushRightList(function(leftList, rightList,item)
				local itemAttr = Item:getOneItemByKey(item.itemId)

				if itemAttr.melting == nil then
					PopText("该物品不可被锻造")
					return false
				end
				if ShenBingDuanZao:checkItemCanFurnace(item.itemId) == false then
					PopText("该物品不可被锻造")
					return false
				end

				if #rightList >= 1 then
					PopText("锻造只能选择投入一件材料")
					return false
				end
				return true
			end)
			
			if not MapIsEmpty(self._left) == true then
				-- self._left = ShenBingDuanZao:deleteEquipItem(User:getRole():getItems())
				for k, itemData in pairs(self._left) do
					layer:pushItemToLeftList(itemData, function(item,func)
						if func then
							func()
						end
					end)
				end
			else
				local allItems=User:getRole():getSmeltBoxItems()
				for i,v in pairs(allItems) do
					local itemAttr = Item:getOneItemByKey(v.itemId)
					if ShenBingDuanZao:checkItemCanFurnace(v.itemId)==true then
						local duanzaoItem = inherit({},v)
						table.insert(self._left,duanzaoItem)
					end
				end

				if MapIsEmpty(self._right) == false then
					local rightItem = self._right[1] --目前设计是只能放一个
					for k, itemData in pairs(self._left) do
						if itemData.itemId == rightItem.itemId then
							itemData.count = itemData.count - rightItem.count
							if itemData.count <= 0 then
								self._left[k] =nil
							end 
							break
						end
					end
				end

				for k, itemData in pairs(self._left) do
					layer:pushItemToLeftList(itemData, function(item,func)
						if func then
							func()
						end
					end)
				end
			end
			if MapIsEmpty(items) ~= true then
				for k,itemData in pairs(items) do 
					layer:pushItemToRightList(itemData,function(item,func)
					if func then
						func()
					end
					end)
				end
			end
			layer:setRightName("锻造炉")
			layer:setLeftName("冶炼箱")
			layer:setTextMoney("黄金："..User:getRole():getAttr("gold"))
			
			layer:showLayer()
		end)
	end)
end



-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 20:54:30
-- @desc 开始锻造按钮
function FurnaceLayer:setFurnaceButton(items)
	if MapIsEmpty(items) == true then
		self.Button_duanzao:releaseFunc(function()
			PopText("请先选择材料")
		end)
	else
		self.Button_duanzao:releaseFunc(function()
			local role = User:getRole()
			local shenBingItems = Helper:getDef(role:getAttr("shenBingItems"),{})
			local shenBingNumLimit = role:getAttr("shenBingNumLimit")
			if #shenBingItems >= shenBingNumLimit then
				PopText("已达到拥有上限，无法再锻造新神兵")
				return 
			end
			self:startFurnace(items[1].itemId)
		end)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/03 14:29:16
-- @desc 界面变化动画
function FurnaceLayer:setPanelAnimation(itemId,itemAttr)
	self.canLeave = false
	self._right = {}
	self.Panel_touch:releaseFunc(function()

	end)
	self.Panel_duanshao.Panel_touch:setPosition(540,835)
	self.Panel_duanshao.Text_name:setPosition(540,1342)
	self.ListView_1:setVisible(false)
	self.Panel_duanshao:setVisible(true) 
	self.Panel_duanshao.Button_neili:setOpacity(0) 
	self.Panel_duanshao.Button_ranliao:setOpacity(0) 
	self.Panel_duanshao.Button_qiaoda:setOpacity(0) 
	self.Panel_duanshao.Button_cuihuo:setOpacity(0) 
	local MOVE_TOUCH_TIME = 0.5
	local NODE_FADE_TIME = 1
	local animation = cc.Sequence:create(cc.CallFunc:create(function()
			-- self:startFurnace(itemId)
		end),cc.CallFunc:create(function()
			local item = Item:getOneItemByKey(self._furnace.cailiao)
			local base = ShenBingDuanZao:getShenBingFurnaceProperty(self._furnace.cailiao,itemId)
			self._furnace.base = base
			self:setWeapenBaseInfo(base)
			if item ~= nil then
				self:setRongLianShenBingName(item.name)
			end
			local moveTo = cc.MoveTo:create(MOVE_TOUCH_TIME,cc.p(330,678))
			self.Panel_duanshao.Panel_touch:runActionWithName("animation",moveTo)
			local moveTo = cc.MoveTo:create(MOVE_TOUCH_TIME,cc.p(330,1185))
			self.Panel_duanshao.Text_name:runActionWithName("animation",moveTo)
		end),cc.DelayTime:create(MOVE_TOUCH_TIME),cc.CallFunc:create(function()
			local fadeIn = cc.FadeTo:create(NODE_FADE_TIME,255)
			self.Panel_duanshao.Button_neili:runActionWithName("fadeIn1",fadeIn)
			self:delayFunc(NODE_FADE_TIME,function()
				fadeIn = cc.FadeTo:create(NODE_FADE_TIME,255)
				self.Panel_duanshao.Button_ranliao:runActionWithName("fadeIn2",fadeIn)
			end)
			self:delayFunc(2*NODE_FADE_TIME,function()
				fadeIn = cc.FadeTo:create(NODE_FADE_TIME,255)
				self.Panel_duanshao.Button_qiaoda:runActionWithName("fadeIn3",fadeIn)
			end)
			self:delayFunc(3*NODE_FADE_TIME,function()
				fadeIn = cc.FadeTo:create(NODE_FADE_TIME,255)
				self.Panel_duanshao.Button_cuihuo:runActionWithName("fadeIn4",fadeIn)
			end)
		end),cc.DelayTime:create(4*NODE_FADE_TIME),cc.CallFunc:create(function()
			self.Panel_duanshao.Text_state:setVisible(true)
			self.Panel_duanshao.Text_time:setVisible(true)
			self.Panel_duanshao.Button_neili:setTouchEnabled(true) 
			self.Panel_duanshao.Button_ranliao:setTouchEnabled(true)  
			self.Panel_duanshao.Button_qiaoda:setTouchEnabled(true)  
			self.Panel_duanshao.Button_cuihuo:setTouchEnabled(true) 
			self:initDuanShao(itemId)

			local itemAttr = Item:getOneItemByKey(self._furnace.cailiao)
			if itemAttr.melting ~= nil then

				self:setDuanShaoState("【煅烧程度】"..tostring(self:getFurnaceState(self.temperature - tonumber(itemAttr.melting))))
			end
		end))
	self.Panel_duanshao:runActionWithName("animation",animation)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 21:20:32
-- @desc 锻造炉中的材料可锻造兵器预览
function FurnaceLayer:setPreviewFurnaceList(itemid)
	self.Panel_Furnace:setVisible(true)
	self.Panel_Furnace.Panel_back:releaseFunc(function()
		self.Panel_Furnace:setVisible(false)
	end)
	self.Panel_Furnace.ListView_2:removeAllItems()
	local testItems = ShenBingDuanZao:getAllLearnFurnaceByItem(itemid)
	local panel,posX
	if MapIsEmpty(testItems) == true then
		PopText("你尚未学习对应技艺，无法锻造材料")
		self.Panel_Furnace:setVisible(false)
		self.Button_duanzao:setVisible(true)
		return
	end
	for k, itemId in pairs(testItems) do 
		if k % 2 == 1 then
			panel = self.Panel_Furnace_item:clone()
			self.Panel_Furnace.ListView_2:pushBackCustomItem(panel)
			posX = 200
		else
			posX = 720 -200
		end
		local itemAttr = {
			name = itemId.weapontype1
		}
		-- assert(itemAttr,"FurnaceLayer:setPreviewFurnaceList,itemId = "..tostring(itemId.forgingid))
		local row = self:createItemPanel("Button_item",itemAttr)
		row:addTo(panel)
		row:setPosition(posX,59)
		row:releaseFunc(function()
			local itemData = Item:getOneItemByKey(itemid)
			-- 你确定要用XX（材料名）制作XX（兵器类型）嘛？
			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			local dialog = DialogALayer:getInstance()
			dialog:hide()
			local str = "你确定要用HIC"..itemData:getNcname(itemData.name).."NOR制作HIC"..itemId.weapontype1.."NOR吗？"
			print("----------------------------------------------------------------:",str)
			-- dialog:setRichText(str)
			dialog:show(str)
			dialog:setBack(false)
			dialog:setButton2("取消",function()

			end)
			dialog:setButton1("确定",function()		
				self.Button_duanzao:setVisible(false)
				self.Button_rongbing:setVisible(false)
				self.Button_duanzao:setPositionX(540)
				self.Panel_Furnace:setVisible(false)
				User:getRole():setFlag("锻造状态","忙碌")
				self:setPanelAnimation(itemId.weapontype1,itemAttr)
			end)
		end)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/19 18:10:03
-- @desc 记录神兵的基本信息
function FurnaceLayer:setWeapenBaseInfo(base)
	assert(type(base) == "table")
	self.weapen.id = "weapon_"..tostring(Helper:getDef(User:getRole():getAttr("forgeCount"),0))
	User:getRole():addAttr("forgeCount",1)
	self.weapen.name = Helper:getDef(base.forgingweapon,"")		-- 名字 
	self.weapen.bType = Helper:getDef(base.forgingweapon,"")
	self.weapen.type = Helper:getDef(base.type,"刀")	-- 武器类型
	self.weapen.wpType = "神兵"	-- 类型 (用于区分神兵和普通兵器)
	self.weapen.damage = Helper:getDef(base.Forgingdamage,0)		-- 伤害值
	self.weapen.yindu = Helper:getDef(base.Forginghardness,0)		-- 硬度值
	self.weapen.rendu = Helper:getDef(base.Forgingtoughness,0) 		-- 韧度值
	self.weapen.weight = Helper:getDef(base.Forgingweight,0)	-- 重量值
	self.weapen.effctNum = Helper:getDef(tonumber(base.Forgingcharacteristics),0) -- 特性值
	self.weapen.nameColor = Helper:getDef(base.Forgingcolor,"WHT")
	self.weapen.typeDesc = Helper:getDef(base.Forgingdsc,"")
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 12:11:24
-- @desc 退出页面要关闭schedule
	function FurnaceLayer:onPause()
		if self.handle ~= nil then
			self:unschedule(self.handle)
			self.handle = nil
		end
	end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 09:48:07
-- @desc 设置状态
function FurnaceLayer:setFurnaceState(str)
	assert(type(str) == "string","FurnaceLayer:setFurnaceState str = "..tostring(str))
	self.Text_state:setString(tostring(str))
end



-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/19 20:45:53
-- @desc 设置煅烧程度
function FurnaceLayer:setDuanShaoState(str)
	assert(type(str) == "string")
	self.Panel_duanshao.Text_state:setString(str)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 10:21:30
-- @desc 开始锻造
function FurnaceLayer:startFurnace(item)
	self:setPreviewFurnaceList(item)

end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 12:15:14
-- @desc 熔炼时描述
function FurnaceLayer:setDuanZaoDsc(flag,dsc)
	flag = Helper:getDef(tonumber(flag),1)
	dsc = Helper:getDef(dsc,"")
	self.Panel_duanshao["Text_dsc"..tostring(flag)]:setVisible(true)
	self.Panel_duanshao["Text_dsc"..tostring(flag)]:setString(dsc)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 12:18:20
-- @desc 设置熔炼神兵名称
function FurnaceLayer:setRongLianShenBingName(name)
	name = Helper:getDef(name,"")
	self.Panel_duanshao.Text_name:setString(name)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 10:33:43
-- @desc 初始化煅烧
function FurnaceLayer:initDuanShao(itemName)
	self:setCaiLisoListVisible(false)
	self.time = 60--煅烧持续时间
	if DEBUG_MODE == 1 then
		self.time = 10
	end

	self.temperature = Helper:getDef(self.tmp,800)
	--初始温度
	if DEBUG_MODE == 1 then
		self.temperature = 5050
	end
	self.upperTemperature = 100000000 --上线温度
	self.canLeave = false --是否可以离开页面
	self.fur_state = "良好"--煅烧状态
	self.start = true --是否开始锻造
	self.smelt = 0 --熔炼值
	self.extraSmelt = 0--额外熔炼值
	self.qiaodaCount = 0

	self.textNum = 1--文本输出编号
	self.Textstate = "极差" --上一次输出是哪一种文本

	self:setDuanShaoButton()
	self:setFurnaceItemList(itemName,false)
	self:setSchedule()
	User:getRole():addItemCount(self._furnace.cailiao,-1)
end

function FurnaceLayer:setCaiLisoListVisible(loop)
	loop = Helper:getDef(loop,true)
	self.Panel_touch:setVisible(loop)
	self.ListView_1:setVisible(loop)
	self.Panel_list:setVisible(loop)
end

--获取锻打提示文本
function FurnaceLayer:getDuanDaMessage()
	local text = {
		[1] = "HIW该锻材刚被熔炼完成，十分适合锻打成兵器，是否开始锻打？",
		[2] = "HIW该锻材已被锻打过一次，犹可继续锻打重塑，是否开始锻打？",
		[3] = "HIW该锻材已被锻打过两次，犹可继续锻打重塑，是否开始锻打？",
		[4] = "HIW该锻材已被锻打过三次，犹可继续锻打重塑，是否开始锻打？",
		[5] = "HIW该锻材已被锻打过四次，只可再承受一次锻打，是否开始锻打？"
	}
	local str = Helper:getDef(text[self.qiaodaCount + 1],"HIR该锻材已无法承受锻打，如再锻打将会导致锻材损毁，是否继续？")
	return str
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 15:36:31
-- @desc 设置时间调度
function FurnaceLayer:setSchedule()
	self.Panel_duanshao.Text_time:setString("【剩余时间】"..tostring(self.time).."s")
	local itemAttr = Item:getOneItemByKey(self._furnace.cailiao)
	self:print(string.gsub("你将炉火点燃，$S瞬间被火焰吞噬，锻造熔炼开始了！","$S",itemAttr.name))
	self.time = self.time - 1
	self.musicId = Audio:playEffect("RongLian",true)
	self.handle = self:schedule(function()
		local baseinfo = ShenBingDuanZao:getShenBingFurnaceProperty(self._furnace.cailiao,self.weapen.bType)
		self.smelt = math.min(ShenBingDuanZao:getItemSmelt(self.temperature,tonumber(itemAttr.melting)),assert(tonumber(baseinfo.ronglianmax)))
		if PRINT_MODE == 1 then
			print("--------------------当前温度与材料熔点-----------------------",self.temperature,itemAttr.melting)
		end
		if self.time > 0 then
			self.Panel_duanshao.Text_time:setString("【剩余时间】"..tostring(self.time).."s")
			self.time = self.time - 1
			self:setFurnaceText(self.temperature-itemAttr.melting,itemAttr)
		else
			if self.musicId then
				Audio:stopEffect(self.musicId)
				self.musicId = nil
			end
			self:setDuanShaoState("【锻打程度】无")
			self.Panel_duanshao.Text_time:setString("【剩余时间】"..tostring(self.time).."s")
			self:unschedule(self.handle)
			self.handle = nil
			self._furnace.smeltInfo = ShenBingDuanZao:getItemRongLianInfo(self._furnace.cailiao)
			self.DuanDaTime = 0
			local addList,addLv
			if PRINT_MODE == 1 then
				print("-------------------------锻造之术等级:",User:getRole():getSkillLv("duanzaozhishu"))
				print("-------------------------熔炼值:",self.smelt)
				print("-------------------------额外熔炼值:",self.extraSmelt)
			end
			local skillLv = ShenBingDuanZao:getWeapenForgeLv(User:getRole():getSkillLv("duanzaozhishu"),self.smelt,self.extraSmelt)--武器锻造等级
			if PRINT_MODE == 1 then
				print("--------------------------本次武器锻造等级-----------------------------:",skillLv)
			end
			self:printDuanshaoResultText()
			if tonumber(self.temperature - itemAttr.melting)  > -100 then
				if PRINT_MODE == 1 then
					print("-----------------------材料模板伤害力----------------------------",self.weapen.damage)
				end
				--duanzaoitems 记录当前锻造材料与数量，数量默认为1 {锻造材料id = 数量}
				self.weapen.duanzaoitems = {itemId = baseinfo.itemid, num = 1}
				self.weapen.damage = ShenBingDuanZao:getWeaponDamage(self.weapen,skillLv)
				if PRINT_MODE == 1 then
					print("---------------神兵最终基础伤害力-------------------------",self.weapen.damage)
				end
				self.Panel_duanshao.Button_qiaoda:releaseFunc(function()
					if GetTime() - self.DuanDaTime >= 10 then
						local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
						local dialog = DialogALayer:getInstance()
						dialog:hide()
						dialog:show(self:getDuanDaMessage())
						dialog:setBack(false)
						dialog:setButton2("取消",function()

						end)
						dialog:setButton1("锻打",function()
							if self.qiaodaCount < 5  then
								if GetTime() - self.DuanDaTime >= 10 then
									self.musicId = Audio:playEffect("DuanDa",true)
									addList,addLv = ShenBingDuanZao:getRandomDuanDaResult(skillLv)
									local tempWeapon = clone(self.weapen)
									if addList ~= nil then
										for key,value in pairs(addList) do 
											if tempWeapon[key] ~= nil then
												tempWeapon[key] = tempWeapon[key] + value
											end
										end
									end
									self.DuanDaTime = GetTime()
									self.qiaodaCount = self.qiaodaCount + 1
									self:delayFunc(10.5,function()
										self:setDuanZaoDsc(1,"伤害力+"..tostring(tempWeapon.damage))
										self:setDuanZaoDsc(2,ShenBingDesc:getWeightDesc(tempWeapon).weight1dsc)
										self:setDuanZaoDsc(3,ShenBingDesc:getYingDuDesc(tempWeapon).hard1dsc)
										self:setDuanZaoDsc(4,ShenBingDesc:getRenDuDesc(tempWeapon).Tenacity1dsc)
										self:setRongLianShenBingName(self.weapen.name)
										self:setDuanDaState(addLv)
										self:setPanelTipsFunc()
										self:setDuanDaWeaponInfo(tempWeapon)
									end)
									for i = 1,10 do
										self:delayFunc(i*1 ,function()
											self.Panel_duanshao.Text_time:setString("【剩余时间】"..tostring(10-i).."s")
										end)
									end
									self:printDuanDaText(addLv)
								else
									PopText("锻打中")
								end
							else
								if GetTime() - self.DuanDaTime >= 10 then
									self:addFurnaceSkillExpByDuanZao(true)
									User:getRole():setFlag("锻造状态","空闲")
									self.Panel_tips:setVisible(false)
									self.Panel_tip:setVisible(false)
									self.Panel_duanshao:setVisible(false)
									self.Button_duanzao:setVisible(true)
									self.Button_duanzao.Text_buttonName:setString("领取")
									self:setCaiLisoListVisible(true)
									local item = Item:getOneItemByKey("rongliianshibai1")
									self:setFurnaceItemList(item.name,false)
									User:getRole():setInheritFlag("神兵锻造",{name = "锻造失败",itemId = "rongliianshibai1"})
									self.canLeave = true
									self.start = false
									-- ShenBingDuanZao:addFurnaceSkillExpByDuanZao(false)
									self.Button_duanzao:releaseFunc(function()
										if User:getRole():checkCanBuyThings("rongliianshibai1",1) == true then
											User:getRole():setInheritFlag("神兵锻造",0)
											local itemData = Item:getOneItemByKey("rongliianshibai1")
											User:getRole():addItemCount("rongliianshibai1",1)
											PopText("获得物品"..itemData.name .."X 1")
											self.ListView_1:removeAllItems()
											self:showLayer()
										else
											PopText("背包空间不足")
										end
									end)
								else
									PopText("锻打中")
								end
							end
						end)
					else
						PopText("锻打中")
					end
				end)
				--淬火
				self.Panel_duanshao.Button_cuihuo:releaseFunc(function()
					if GetTime() - self.DuanDaTime < 10 then
						PopText("锻打中请稍后")
						return
					end
					if self.qiaodaCount == 0 then
						PopText("请先进行锻打")
						return
					end
					self:addFurnaceSkillExpByDuanZao(true)
					self:printCuiHuoText()
					self.Panel_tips:setVisible(false)
					self.Panel_tip:setVisible(false)
					self.Panel_duanshao:setVisible(false)
					self.Button_duanzao:setVisible(true)
					User:getRole():setFlag("锻造状态","空闲")
					User:getRole():setInheritFlag("神兵锻造",{name = "锻造神兵"})
					self.Button_duanzao.Text_buttonName:setString("领取")
					--穿上脱下描述
					local descList = ShenBingDesc:getRandomWeaponWeardes(self.weapen)
					--特效1
					local specialId,key = ShenBingDuanZao:getWeapenSpecialId(self.weapen)
					if key ~= nil then
						self.weapen[key] = specialId
					end
					--锻打加成
					if addList ~= nil then
						for key,value in pairs(addList) do 
							if self.weapen[key] ~= nil then
								self.weapen[key] = self.weapen[key] + value
							end
						end
					end

					assert(descList)
					self.weapen.equipDescId = descList.desid
					self.weapen.effctNum = ShenBingDuanZao:getWeapenEffctNum(self.weapen,skillLv,self.smelt,self.extraSmelt)
					--生成描述
					self.weapen.desc = ShenBingDesc:getShenBingDesc(self.weapen)
					self:setCaiLisoListVisible(true)
					local list = {
						-- { name = ""},
						{ name = ""},
						{ name = "HIC"..self.weapen.name},
						{ name = "伤害力+"..tostring(self.weapen.damage)},
						{ name = ShenBingDesc:getWeightDesc(self.weapen).weight1dsc},
						{ name = ShenBingDesc:getYingDuDesc(self.weapen).hard1dsc},
						{ name = ShenBingDesc:getRenDuDesc(self.weapen).Tenacity1dsc}
					}
					self:setFurnaceItemList(list,false)
					self.weapen.status = 2
					ShenBingDuanZao:getNewShenBingWeapen(self.weapen)
					self.canLeave = true
					self.start = false
					local isGet = true
					self.Button_duanzao:releaseFunc(function()
						if isGet then
							isGet = false
							if #User:getRole():getItems() < User:getRole():getAttr("weight") then
								if ShenBingDuanZao:checkBagCanAddShenBing() == true then
									PopupLayerController:showLayer("ShenBingNameLayer",function(layer)
										layer:showLayer(1,self.weapen,function(weapen)
											weapen.status = 3
											ShenBingDuanZao:updateShenBingInfo(weapen)
											self.weapen = weapen
											print("-------------------updateShenBingInfo-------------------------------")
											isGet = true
											if User:getRole():addItemCount(weapen.id,1) == true then
												User:getRole():setInheritFlag("神兵锻造",0)
												PopText("领取神兵"..weapen.name)
												self:showLayer()
											end
										end)
									end)
								else
									isGet = true
									PopText("背包神兵已达到可携带上限")
								end
							else
								isGet = true
								PopText("背包空间不足")
							end
						end
					end)
				end)
			else--熔炼失败
				User:getRole():setFlag("锻造状态","空闲")
				self.Panel_duanshao:setVisible(false)
				self.Button_duanzao:setVisible(true)
				self.Button_duanzao.Text_buttonName:setString("领取")
				self:setCaiLisoListVisible(true)
				self:setFurnaceItemList({{itemId = self._furnace.smeltInfo.meltingfail,count = 1}})
				User:getRole():setInheritFlag("神兵锻造",{name = "锻造失败",itemId = self._furnace.smeltInfo.meltingfail})
				self.canLeave = true
				self.start = false
				self:addFurnaceSkillExpByDuanZao(false)
				self.Button_duanzao:releaseFunc(function()
					if User:getRole():checkCanBuyThings(self._furnace.smeltInfo.meltingfail,1) == true then
						User:getRole():setInheritFlag("神兵锻造",0)
						local itemData = Item:getOneItemByKey(self._furnace.smeltInfo.meltingfail)
						PopText("获得物品"..itemData.name .."X 1")
						User:getRole():addItemCount(self._furnace.smeltInfo.meltingfail,1)
						self.ListView_1:removeAllItems()
						self:showLayer()
					else
						PopText("背包空间不足")
					end
				end)
			end
			self.Panel_duanshao.Button_neili:releaseFunc(function()
				PopText("熔炼已经完成了")
			end)
			self.Panel_duanshao.Button_ranliao:releaseFunc(function()
				PopText("熔炼已经完成了")
			end)
		end
	end,1.0)
end

--增加锻造之术的经验   
function FurnaceLayer:addFurnaceSkillExpByDuanZao(bool)

	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()
	local addExp,upLv = ShenBingDuanZao:addFurnaceSkillExpByDuanZao(bool,self.isHomeLandDZ,self.gjZcLv)
	local skillName = Skill:getSkill("duanzaozhishu").name
	if addExp > 0 then
		if addExp < 1 then
			addExp = math.ceil( addExp )
		else
			addExp = math.floor( addExp )
		end
		self:print("你的 【"..skillName.."】 经验 +"..tostring(addExp))
	end

	if upLv > 0 then
		self:print("你的 【"..skillName.."】 等级 +"..tostring(upLv))
	end

	local skillName = Skill:getSkill("duanzaozhishu").name

	local MAX_ROLE_SKILL_EXP = role:conversionSkillExpAndLv("exp", role:getSkillLvLimit("duanzaozhishu"))
	local nowExp = role:getSkillExp("duanzaozhishu")
	if nowExp >= MAX_ROLE_SKILL_EXP then
		self:print("您的"..skillName.."已出神入化，无法再提升！")
	end	

	local todayExp = role:getDayFlag("duanzao")
	
	if tonumber(todayExp) >= DUANZAO_EXP_MAX_DAY then
		self:print("RED已达到每日锻造可获得经验的上限，本日内锻造无法再增加锻造之术经验")
	end

end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/25 13:54:34
-- @desc 锻打过程中的tips
function FurnaceLayer:setPanelTipsFunc()
	self.Panel_tips:setVisible(true)
	self.Panel_tips:releaseFunc(function()
		self.Panel_tips.Image_7:setVisible(false)
		self.Panel_tip:setVisible(true)
	end)
	self.Panel_tip:releaseFunc(function()
		self.Panel_tips.Image_7:setVisible(true)
		self.Panel_tip:setVisible(false)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/25 14:10:59
-- @desc tip中的详细信息
function FurnaceLayer:setDuanDaWeaponInfo(weapon)
	assert(weapon)
	self.Panel_tip.Image_tip.Text_dsc_0:setString("【伤害力】".. tostring(weapon.damage))
	self.Panel_tip.Image_tip.Text_dsc_1:setString("【重量值】".. tostring(weapon.weight))
	self.Panel_tip.Image_tip.Text_dsc_2:setString("【硬度值】".. tostring(weapon.yindu))
	self.Panel_tip.Image_tip.Text_dsc_3:setString("【坚韧度】".. tostring(weapon.rendu))
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/25 13:21:06
-- @desc 煅烧结束后结果文本
function FurnaceLayer:printDuanshaoResultText()
	local itemAttr = Item:getOneItemByKey(self._furnace.cailiao)
	if itemAttr.melting ~= nil then
		local state = self:getFurnaceState(self.temperature - tonumber(itemAttr.melting))
		local list = {
			["极差"] = {
				desc = "HIR$N在炉中煅烧了许久，根本没有被融化的迹象，本次锻造失败了。",
				dsc= ""
			},
			["差"] = {
				desc = "HIB$NHIB经过这长时间的煅烧，成为了一块劣势的锻材，现在可以开始锻打了。",
				dsc = "HIB劣质的锻材"
			},
			["普通"] = {
				desc = "BLU$NBLU经过这长时间的煅烧，成为了一块普通的锻材，现在可以开始锻打了。",
				dsc = "BLU普通的锻材"
			},
			["好"] = {
				desc = "HIC$NHIC经过这长时间的煅烧，成为了一块良好的锻材，现在可以开始锻打了。",
				dsc = "HIC良好的锻材"
			},
			["极好"] = {
				desc = "HIW$NHIW经过这长时间的煅烧，成为了一块极佳的锻材，现在可以开始锻打了。",
				dsc = "HIW极佳的锻材"
			}
		}

		local str = assert(list[state].desc)
		str = string.gsub(str,"$N",itemAttr.name)
		self:print(str)
		if state ~= "极差" then
			self:setRongLianShenBingName(list[state].dsc)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 17:38:04
-- @desc 设置锻打程度
function FurnaceLayer:setDuanDaState(addlv)
	local list = {
		"极差","差","普通","好","极好"
	}
	if list[addlv] then
		self:setDuanShaoState("【锻打程度】".. list[addlv])
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/25 09:48:01
-- @desc 煅烧文本
function FurnaceLayer:setFurnaceText(diff,itemAttr)
	diff = assert(diff)--炉温-材料熔点
	local text = {
		["极差"] = {
			"HIR炉火煅烧着$SHIR,但$SHIR一点融化的迹象都没有，看来炉子的温度还是太低了！",
			"HIR熔炉内火焰大盛，但$SHIR丝毫未被这火焰所消融，看来炉温还是不够！",
			"HIR炉火灼烧着$SHIR，但$SHIR丝毫未被这高温熔化，看来炉温需要更高一些。"
		},
		["差"] = {
			"HIB炉火充斥着整个熔炉，$SHIB正在被缓慢融化着，但效率实在太低，看来温度还需更高一些才行。",
			"HIB熔炉火焰吞噬着一切，你透过火焰，隐约能见$SHIB正被缓慢炼化，但速度极慢，看来炉火还需再旺一些。",
			"HIB炉内火焰肆虐，$SHIB在这炉火温度下缓缓融化，但速度极慢，等到炼成也不知多久。"
		},
		["普通"] = {
			"熔炉内火焰呼啸着，$S在这高温下慢慢融化，看这熔炼情况。在时间结束后，定是一块可造之材。",
			"$S在熔炉中煅烧着，你透过风口隐约能看到$S正在慢慢变红，想必结束后应该可以进行打造。",
			"你看向炉内，$S正被煅烧着，看这情况，还需很久方能开始锻打。"
		},
		["好"] = {
			"HIC火焰煅烧着$SHIC，$SHIC在炉中不断地变红，以现在的情况看来，在煅烧结束之后，定能以此打造一柄良兵。",
			"HIC熔炉中的火焰煅烧着$SHIC，$SHIC在火焰中不断地变形变热，看来再过不久，便可以此打造一把好兵器了。",
			"HIC熔炉中的温度极高，$SHIC在这高温下渐渐地变红，正是熔炼良好的表现，相信这定能助你打造成一柄好兵器。"
		},
		["极好"] = {
			"HIW炉火煅烧着$SHIW，在这熊熊烈火下，$SHIW被熔炼得极佳，想必定能打造成一柄神兵利器。",
			"HIW火焰吞没了$SHIW，$SHIW在熊熊烈火中，熔炼得极快，效果显著！",
			"HIW$SHIW在熔炉中被煅烧得火红，看来材料已被熔炼得十分完美了。"
		}
	}
	local state = self:getFurnaceState(diff)
	local str = ""
	local name = Item:getOneItemByKey(self._furnace.cailiao).name
	assert(text[state],"煅烧状态有问题:"..state)
	local random = math.random(1,#text[state])
	str = string.gsub(text[state][random],"$S",name)
	self:print(str)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/25 10:43:54
-- @desc 获得煅烧状态
function FurnaceLayer:getFurnaceState(diff)
	local state = ""
	if diff <= -100 then
		state = "极差"
	elseif diff > -100 and diff <= -80 then
		state = "差"
	elseif diff > -80 and diff <= -40 then
		state = "普通"
	elseif diff > -40 and diff <= 0 then
		state = "好"
	elseif diff > 0 then
		state = "极好"
	else
		assert(nil)
	end
	return state
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/25 11:46:57
-- @desc  淬火文本
function FurnaceLayer:printCuiHuoText()
	local text = {
		"HIW你将通红的武器放入水槽之中，白烟腾起，嗤然有声，不多时武器冷却，一把兵器便淬火完成。",
		"HIW打好的武器被你放入水槽，只听得嗤然有声，四周蒸腾起雾气，再捞起来时，兵器淬火已经完成。"
	}
	local random = math.random(1,#text)
	self:print(text[random])
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/25 19:24:15
-- @desc 投入材料增加温度文本
function FurnaceLayer:addTemperatureText(temperature)
	local text = {
		{
			"GRN你将燃料一股脑投入火炉，火炉瞬间便将其吞噬殆尽，但似乎效果较差。",
			"GRN你将燃料投入火炉，但火炉温度似乎变化不大。"
		},

		{
			"HIG你将燃料放入炉中，熔炉的温度提高了,而且火焰颜色居然也发生了变化，不知是什么情况。",
			"HIG你将燃料放入炉中，炉火似乎大了不少，而且火焰颜色居然也发生了变化，不知是什么情况，看来效果不错。"
		},


		{
			"HIC你将燃料投入火炉，火炉温度骤然提升，火苗几乎要从炉中蹿出来，火焰颜色居然也发生了变化，不知是什么情况。"
		}
	}

	local random,str = nil,nil
	if temperature <= 100 then
		random = math.random(1,#text[1])
		str = text[1][random]
	elseif temperature >= 101 and temperature <= 200 then
		random = math.random(1,#text[2])
		str = text[2][random]
	else
		random = math.random(1,#text[3])
		str = text[3][random]
	end
	self:print(str)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/22 21:50:32
-- @desc 注入内力增加温度文本
function FurnaceLayer:addTemperatureByNeiLiText(temperature)
	local text = {
		{
			"GRN你将一股内力注入熔炉，熔炉温度骤然提升。",
			"GRN你运起真气，灌入炉中，在你的内力催动下，炉温提高了。"
		},

		{
			"HIG你提功运气，将一股精纯真气灌入炉中，却见炉火刹那间变大，温度骤然提升。"
		},


		{
			"HIC你猛运一股真气，将其注入炉中，只见炉火猛然变大，炉温骤然提升。"
		}
	}

	local random,str = nil,nil
	if temperature <= 100 then
		random = math.random(1,#text[1])
		str = text[1][random]
	elseif temperature >= 101 and temperature <= 200 then
		random = math.random(1,#text[2])
		str = text[2][random]
	else
		random = math.random(1,#text[3])
		str = text[3][random]
	end
	self:print(str)
	self:print("温度增加"..temperature.."度。")
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/25 11:50:01
-- @desc 锻打文本
function FurnaceLayer:printDuanDaText(addlv)
	local text = {
		["极差"] = {
			"CYN你将烧得火红的锻材用钳子夹出，却不小心掉在了地下，你忙将其用钳子夹起。",
			"HIB你将锻材按在打造台上，开始敲打起来，但却总是抓不到规律，毫无章法让你不由得心神燥乱。",
			"BLU你持续敲打，锻材在你的锻造下缓慢成型，但整体却极不工整。",
			"HIG你仍不放弃，用心锻打，但仍是掌握不了锻造的节奏。",
			"HIR在你的不懈努力下，一把根本称不上武器的兵器被你打造了出来。"
		},
		["差"] = {
			"CYN你手忙脚乱地将通红的锻材取出，不小心烫了手，锻材差点掉在地上。",
			"HIB你将锻材放在打造台上，一阵敲打，武器在你敲打中慢慢成型。",
			"BLU你一锤一锤敲打在锻材之上，锻材被打得火花四溅。",
			"HIG但你此时却没了之前的状态，一会用力过猛一会绵软无力，一块好好的锻材被你打得稀烂。",
			"WHT你挥了挥汗，一把奇形怪状的武器已经打造完成。"
		},
		["普通"] = {
			"CYN你算好时间，将烧得火红的锻材用钳子夹出，开始锻造兵器。",
			"HIB你将锻材置于打造台上，有节奏地敲打起来，锻材在你的敲打下慢慢成型。",
			"BLU你聚气凝神，一锤一锤敲打在锻材之上，兵器的形状渐渐显现出来。",
			"GRN你只觉心身俱疲，但手中锻造锤仍未停止，咬牙坚持，兵器即将打造完毕！",
			"HIG一阵忙碌之后，一把中规中矩地武器被你打造了出来。"
		},
		["好"] = {
			"CYN你算好时间，将烧得火红的锻材用钳子夹出，这锻材被煅烧得十分良好，想必定能锻造成一把好兵器。",
			"HIB你将锻材置于锻造台上，举起铁锤猛击在锻材之上，火花四溅。",
			"BLU你心意合一，挥动铁锤，浑然忘我地锻造了起来，锻材在你的锻造下快速成型！",
			"HIG你越打越觉得得心应手，敲打速度愈来愈快，一把武器在你面前慢慢成型。",
			"HIC你将铁锤放下，一把精良的武器出现在你面前。"
		},
		["极好"] = {
			"CYN你算好时间，将烧得火红的锻材用钳子夹出，这锻材被煅烧得十分良好，想必定能锻造HIB成一把好兵器。",
			"BLU你将锻材置于锻造台上，举起铁锤猛击在锻材之上，火花四溅。",
			"HIG你心意合一，挥动铁锤，浑然忘我地锻造了起来，锻材在你的锻造下快速成型！",
			"突然你心神一动，似乎明白了什么，举起铁锤一锤敲下，兵器竟发出清鸣，异象频出。",
			"HIW你将铁锤放下，一把绝世之兵已是铸造完成。"
		}
	}


	local textList = {}
	if addlv == 1 then
		textList = text["极差"]
	elseif addlv == 2 then
		textList = text["差"]
	elseif addlv == 3 then
		textList = text["普通"]
	elseif addlv == 4 then
		textList = text["好"]
	elseif addlv == 5 then
		textList = text["极好"]
	end
	print("-------------------------addlv---------------------------",addlv)
	for k,_text in pairs(textList) do 
		self:delayFunc(k*2,function()
			self:print(_text)
			if k == #textList then
				if self.musicId then
					Audio:stopEffect(self.musicId)
					self.musicId = nil
				end
			end
		end)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 10:36:08
-- @desc 设置煅烧界面的按钮
function FurnaceLayer:setDuanShaoButton()
	local role = User:getRole()
	--敲打
	self.Panel_duanshao.Button_qiaoda:releaseFunc(function()
		-- self:print()
		PopText("材料尚未熔炼完成，请再稍等一会吧")
	end)

	--淬火
	self.Panel_duanshao.Button_cuihuo:releaseFunc(function()
		-- self:print("材料尚未熔炼完成，请再稍等一会吧")
		PopText("材料尚未熔炼完成，请再稍等一会吧")
		-- self.start = false
	end)

	--添加燃料
	self.Panel_duanshao.Button_ranliao:releaseFunc(function()
		if self.handle ~= nil then
			self:pauseSchedulerAndActions(self.handle)
		end
		PopupLayerController:showLayer("ShenBingBagLayer",function(layer)

			layer:btnLeftClickFunc(function()
				if self.handle ~= nil then
					self:resumeSchedulerAndActions(self.handle)
				end
				layer:destory()
				-- layer:hide()
			end, "取消")
			local temperature = self.temperature
			layer:btnRightClickFunc(function(leftList,rightList)
				-- Helper:print_lua_table(rightList)
				if self.handle ~= nil then
					self:resumeSchedulerAndActions(self.handle)
				end
				local temp = self.temperature
				for k,itemData in pairs(rightList) do 
					User:getRole():addItemCount(itemData.itemId,0-itemData.count)
					self.temperature = self.temperature + itemData.temperature * itemData.count
					self.extraSmelt = self.extraSmelt + itemData.itemmelting * itemData.count
				end
				self.extraSmelt = math.min(self.extraSmelt,100)
				if self.temperature - temp > 0 then
					Audio:playEffect("ZengWen")
				end
				self:addTemperatureText(self.temperature - temp)
				local itemAttr = Item:getOneItemByKey(self._furnace.cailiao)
				if itemAttr.melting ~= nil then
					self:setDuanShaoState("【煅烧程度】"..tostring(self:getFurnaceState(self.temperature - tonumber(itemAttr.melting))))
				end
				if PRINT_MODE == 1 then
					print("--------------------------投放材料确定后计算出的当前温度--------------------------------",self.temperature)
					print("------------------投放的材料一个可以增加温度------------",self.temperature - temp)
				end
				layer:destory()
			end, "确定")
			
			layer:setCondiPushRightList(function(leftList, rightList,item)--从左向右放
				print("========================================:",item,type(item))
				Helper:print_lua_table(item)
				if #rightList >= 20 then
					PopText("一次最多投放20种材料")
					return
				end
				if PRINT_MODE == 1 then
					print("---------最大温度,当前温度,材料增加的温度,投放此材料后的温度--------------------------",self.upperTemperature,temperature,item.temperature,temperature +item.temperature)
				end
				if item.downTemp <= temperature and item.upTemp >= temperature then
					if self.upperTemperature >= temperature +item.temperature then
						temperature = temperature +item.temperature
						print("============ true=============")
						return true
					else
						PopText("此炉已无法再承受更高的温度")
						return false
					end
				end
				PopText("此燃料已经无法增加炉温了")
				return false
			end)
			layer:setCondiPushLeftList(function(leftList, rightList,item)--从右向左放
				temperature = temperature - item.temperature
				return true
			end)
			-- for k, itemData in pairs(User:getRole():getItems()) do
			-- 	layer:pushItemToLeftList(itemData, function(t)
			-- 	end)
			-- end
			 for k,itemData in pairs(User:getRole():getItems()) do 
			 	local itemmelting = ShenBingDuanZao:getItemmelting(itemData.itemId)
			 	if itemmelting ~= nil then
			 		Helper:tableCover(itemData,itemmelting)
			 		Helper:print_lua_table(itemData)
					layer:pushItemToLeftList(itemData,function(item,func)
						if func then
							func()
						end
					end)
			 	end
			 end
			-- if MapIsEmpty(items) ~= true then
			-- 	for k,itemData in pairs(items) do 
					-- layer:pushItemToRightList(itemData,function(f)

					-- end)
			-- 	end
			-- end
			layer:setRightName("锻造炉")
			layer:setTextMoney("黄金："..User:getRole():getAttr("gold"))
			
			layer:showLayer()
		end)


	end)

	--注入内力
	self.Panel_duanshao.Button_neili:releaseFunc(function()
		-- self:print("注入内力")
		self.addNeiliTime = Helper:getDef(self.addNeiliTime,0)
		local neiliMax = math.ceil(role:getFinalAttr("neiliMax"))
		if GetTime() - self.addNeiliTime >= 0.5 then
			self.addNeiliTime = GetTime()
			local cost,add,needMax = 0,0,10000
			if self.temperature >= 800 and self.temperature <= 1000 then
				cost,add,needMax = 100,40,3000
			elseif self.temperature >= 1001 and self.temperature <= 1200 then
				cost,add,needMax = 150,35,5000
			elseif self.temperature >= 1201 and self.temperature <= 1500 then
				cost,add,needMax = 180,30,8000
			elseif self.temperature >= 1501 and self.temperature <= 2000 then
				cost,add,needMax = 200,25,10000
			elseif self.temperature >= 2001 and self.temperature <= 2300 then
				cost,add,needMax = 300,20,12000
			elseif self.temperature >= 2301 and self.temperature <= 30000 then
				cost,add,needMax = 400,10,16000
			else
				PopText("内力已经无法提升熔炉温度")
				return 
			end
			if neiliMax <= needMax then
				PopText("内力最大值低于内力需求最大值，不能注入内力")
				return
			end
			if User:getRole():isHaveImprintingId("xuanbingyin") then
				local meridianBuffValue = Meridian:getMeridianBuffValue("xuanbingyin")
				cost = math.ceil(cost * meridianBuffValue)
			end
			if neiliMax >= cost then
				Audio:playEffect("ZengWen")
				self.temperature = self.temperature + add
				self.weapen.useNeiLi = self.weapen.useNeiLi + cost
				role:addAttr("neiliMax",0-cost)
				self:print("消耗内力"..cost.."点。")
				self:addTemperatureByNeiLiText(add)
				self:setNeiLiAndGold()
				local itemAttr = Item:getOneItemByKey(self._furnace.cailiao)
				if itemAttr.melting ~= nil then
					self:setDuanShaoState("【煅烧程度】"..tostring(self:getFurnaceState(self.temperature - tonumber(itemAttr.melting))))
				end
			else
				PopText("内力不足")
			end
		else
			PopText("真气运转不流畅，还是等一下吧")
		end
	end)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 15:54:45
-- @desc 初始化RichText
function FurnaceLayer:initRichText()
	local x, y = self.Image_help.Panel_talk:getPosition()
	local size = self.Image_help.Panel_talk:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
   	self.Image_help.Panel_talk:getParent():addChild(richTextScroll)
   	richTextScroll:move(cc.p(27, 22))
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(true)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 15:54:04
-- @desc RichText 输出文本
local textColor = cc.c3b(102, 153, 153)
function FurnaceLayer:print(str, verticalSpace)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6888 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end

function FurnaceLayer:setRongBingBtn()
	self.Button_rongbing:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_rongbing:releaseFunc(function()
		local rongBing = require("app.views.layer.ShenBingLayer.RongBingLayer.RongBingLayer")
		rongBing:setBackFunc(function()
			self:setShenBingLimitDesc()
		end)
		rongBing:showLayer()
	end)
end

function FurnaceLayer:setShenBingLimitDesc()
	local role = User:getRole()
	local currLimit = role:getAttr("shenBingNumLimit")
	local shenBingItems = role:getAttr("shenBingItems")
	local num = 0
	for i, shenBing in ipairs(shenBingItems) do
		if shenBing.status == 3 then
			num = num + 1
		end
	end

	self.Text_shenbing_num:setString("拥有神兵："..num.."/"..currLimit)
end

function FurnaceLayer:setShenBingNumLimitUpgradeBtn()
	self.Button_add:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_add:releaseFunc(function()
		if self.canLeave == false then
			PopText("锻造神兵怎能分心，不要浪费了神物")
			return
		end
		
		local role = User:getRole()
		local currLimit = role:getAttr("shenBingNumLimit")
		if ShenBingDuanZao:checkCanUpgradeShenBingLimit(currLimit) == false then
			PopText("当前可拥有神兵数量已达最大升级上限")
			return
		end

		local currLevel = ShenBingDuanZao:getShenBingLevelByLimit(currLimit)
		local cost, costName = ShenBingDuanZao:getShenBingUpgradeCostByLevel(currLevel + 1)
		local nextLimit = ShenBingDuanZao:getShenBingLimitByLevel(currLevel + 1)

		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:show("当前神兵可拥有上限为"..tostring(currLimit) .. "把".."\n\n".."\n花费"..tostring(cost) .. costName .. "可升级到"..tostring(nextLimit) .. "把")
		dialog:setButton1("升级", function() 
			ShenBingDuanZao:upgradeShenBingLimit(role,function()
				self:setShenBingLimitDesc()
			end)
		end)
		dialog:setButton2("否")
		dialog:setWeChatVisible(false)
	end)
end

Helper:classDefNodeGetInstance(FurnaceLayer)
return  FurnaceLayer0000000
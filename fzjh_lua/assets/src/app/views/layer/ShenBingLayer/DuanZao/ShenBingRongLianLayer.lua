local  ShenBingRongLianLayer = class("FurnaceLayer",cc.Layer)
local ShenBingRongLian = require("app.models.ShenBing.RongLian.ShenBingRongLian")
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
function ShenBingRongLianLayer:create()
	local p = ShenBingRongLianLayer:new()
	p:init()
	return p
end

function ShenBingRongLianLayer:init()
	self._UI = require("Layer/ShenBing/ShenBingRongLianUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setVisible(false)
	self:initRichText()
end

function ShenBingRongLianLayer:showLayer(temperature,upperTemperature)
	User:getRole():setFlag("PVP活动状态", "忙碌")
	self.tmp = temperature
	self:setInitValue(temperature,upperTemperature)
	self:initLayer()
	self:setNeiLiAndGold()
	self:setBackButton()
	self:show()
	self.itemCount = 0

	Audio:pauseMusic()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 19:59:53
-- @desc 初始值
function ShenBingRongLianLayer:setInitValue(temperature,upperTemperature)
	self.time = 5--煅烧持续时间
	self.temperature = self.tmp--初始温度
	self.upperTemperature = upperTemperature --上线温度
	self.rl_list = {}
	self.cailiao = {}
	-- self.start = false
	self.canLeave = true
	self.leftList = {}
	--背包和冶炼箱的物品都能被熔炼
	local items = table.mergeArray(User:getRole():getItems(), User:getRole():getAttr("smeltBox"))
	for k,itemData in ipairs(items) do 
		 	local itemAttr = Item:getOneItemByKey(itemData.itemId)
		 	if itemAttr ~= nil and itemAttr.melting ~= nil and User:getRole():checkItemIsEquip(itemData.id) == false and User:getRole():checkIsPrepareWeapon(itemData.id)==false then
		 		itemData.melting = itemAttr.melting
		 		table.insert(self.leftList,itemData)
		 	end
		end
	end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 20:07:27
-- @desc 空间显示控制
function ShenBingRongLianLayer:initLayer()
	-- self.Button_ranliao:setVisible(false)--Button_neili
	-- self.Button_neili:setVisible(false)
	self.Button_ronglian:setVisible(true)
	self:setStartRongLianButton()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 20:09:53
-- @desc 开始熔炼/领取物品按钮
function ShenBingRongLianLayer:setStartRongLianButton()
	local flag = User:getRole():getFlag("熔炼结果")
	if flag == 0 then
		self:setRongLianListView({})
		self:chooseItemToRongLian()
		self:setRongLianListView(self.rl_list)
		self.Button_ronglian.Text_buttonName:setString("开始熔炼")
		self.Button_ronglian:releaseFunc(function()
			if #self.rl_list == 0 then
				PopText("请选投入需要熔炼的材料")
				return
			else
				if User:getRole():getAttr("jing") < 10 then
					PopText("精力不足")
					return
				end
				User:getRole():addAttr("jing",-10)
				local prepareWeapon = User:getRole():getPrepareWeapon()
				for k,itemData in pairs(self.rl_list) do
					if User:getRole():checkItemIsEquipbyItemId(itemData.itemId) then
						User:getRole():addItemCount( itemData.itemId,0-itemData.count,nil,itemData.id)
					elseif MapIsEmpty(prepareWeapon)==false and prepareWeapon.itemId == itemData.itemId then 
						User:getRole():addItemCount( itemData.itemId,0-itemData.count,nil,itemData.id)
					else
						User:getRole():addItemCount( itemData.itemId,0-itemData.count)
					end
				end
				self:setStart()
			end
		end)
	else
		self.Panel_touch:setTouchEnabled(false)
		self.Button_ronglian.Text_buttonName:setString("领取材料")
		self:setRongLianRewardListView(flag)
		self.Button_ronglian:releaseFunc(function()
				local reward = {}
				for k,itemData in pairs(flag) do 
					reward[itemData.itemId] = itemData.count
				end
				if User:getRole():checkCanBuyTwoOrMoreThings(reward) == true then
					self:print("你打开熔炉，将里面的东西取出。")
					User:getRole():setFlag("熔炼结果",0)
					for k,itemData in pairs(flag) do 
						User:getRole():addItemCount(itemData.itemId,itemData.count)
						local itemAttr = Item:getOneItemByKey(itemData.itemId) 
						if itemAttr ~= nil then
							PopText("获得物品"..itemAttr.name.."X"..tostring(itemData.count))
						end
					end
					self.Panel_touch:setTouchEnabled(true)
					self:showLayer(self.tmp,self.upperTemperature)
				else
					PopText("背包空间不足")
				end
		end)
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 11:08:28
-- @desc 退出按钮
function ShenBingRongLianLayer:setBackButton()
	self.Image_title.Button_back:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BACKBUTTON)
	self.Image_title.Button_back:releaseFunc(function()
		if self.canLeave == false then
			PopText("锻造神兵怎能分心，不要浪费了神物")
		else
			PopupLayerController:hideLayer("ShenBingRongLianLayer",function(layer)
				User:getRole():setFlag("PVP活动状态", "空闲中")
				layer:hide(true)
				Audio:resumeMusic()
			end,0)
		end
	end)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 09:45:13
-- @desc 选择熔炼物品
function ShenBingRongLianLayer:chooseItemToRongLian()
	self.Panel_touch:setTouchEnabled(true)
	self.Panel_touch:releaseFunc(function()
		local tmpCount = self.itemCount
		PopupLayerController:showLayer("ShenBingBagLayer",function(layer)
			layer:btnLeftClickFunc(function()
				layer:destory()
			end, "取消")
			layer:btnRightClickFunc(function(leftList,rightList)
				self.rl_list = rightList
				self.leftList = leftList
				self:setRongLianListView(rightList)
				if DEBUG_MODE == 1 then
					print("---------------------熔炼材料的信息----------------------------")
					Helper:print_lua_table(rightList)
				end
				self.itemCount = tmpCount
				layer:destory()
			end, "确定")
			local temperature = self.temperature
			layer:setCondiPushRightList(function(leftList, rightList,item)--从左向右放
				if tmpCount >= 20 then
					PopText("一次最多熔炼20个物品")
					return false
				end
				tmpCount = tmpCount + 1
				return true
			end)

			layer:setCondiPushLeftList(function(leftList, rightList,item)--从右向左放
				-- User:getRole():addItemCount(item.itemId,1)
				tmpCount = tmpCount - 1
				return true
			end)
			 for k,itemData in pairs(self.leftList) do 
				layer:pushItemToLeftList(itemData,function(item,func)
					if func then
						func()
					end
				end)
			 end

			 for k, itemData in pairs(self.rl_list) do 
				layer:pushItemToRightList(itemData,function(item,func)
					if func then
						func()
					end
				end)
			 end
			layer:setRightName("铁匠")
			layer:setTextMoney("黄金："..User:getRole():getAttr("gold"))
			
			layer:showLayer()
		end)
	end)
end

function ShenBingRongLianLayer:setListViewHelp()
	for i = 1,3 do 
		local panel = self.Panel_item:clone()
		Helper:convertUIByParent(panel)
		panel.Text_item:enableOutline(cc.c4b(17, 18, 18, 255), 5)
		panel.Text_item_0:enableOutline(cc.c4b(17, 18, 18, 255), 5)
		panel.Text_item_num:enableOutline(cc.c4b(17, 18, 18, 255), 5)
		if i == 3 then
			panel.Text_item:setString("点击放入材料")
		else
			panel.Text_item:setString("")
		end
		panel.Text_item_num:setString(1)
		self.ListView_1:pushBackCustomItem(panel)
	end

end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 09:49:04
-- @desc 显示选择的熔炼物品
function ShenBingRongLianLayer:setRongLianListView(items)
	assert(items)
	self.ListView_1:removeAllItems()
	if MapIsEmpty(items) == true then
		self:setListViewHelp()
		return
	end
	for k,item in pairs(items) do 
		local panel = self.Panel_item:clone()
		Helper:convertUIByParent(panel)
		panel.Text_item:enableOutline(cc.c4b(17, 18, 18, 255), 5)
		local itemAttr = Item:getOneItemByKey(item.itemId)
		if itemAttr then
			panel.Text_item:setString(itemAttr.name)
			panel.Text_item_num:setString(item.count)
		end
		self.ListView_1:pushBackCustomItem(panel)
	end
	self.ListView_1:jumpToTop()
end

function ShenBingRongLianLayer:setRongLianRewardListView(items)
	assert(items)
	self.ListView_1:removeAllItems()
	-- self:setListViewHelp()
	for k,item in pairs(items) do 
		local panel = self.Panel_item:clone()
		Helper:convertUIByParent(panel)
		panel.Text_item:setVisible(false)
		panel.Text_item_0:setVisible(true)
		panel.Text_item_num:setVisible(true)
		panel.Text_item_0:enableOutline(cc.c4b(17, 18, 18, 255), 5)
		panel.Text_item_num:enableOutline(cc.c4b(17, 18, 18, 255), 5)
		local itemAttr = Item:getOneItemByKey(item.itemId)
		if itemAttr then
			panel.Text_item_0:setString(itemAttr.name)
			panel.Text_item_num:setString(item.count)
		end
		self.ListView_1:pushBackCustomItem(panel)
	end
	self.ListView_1:jumpToTop()
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 20:16:57
-- @desc 开始熔炼
function ShenBingRongLianLayer:setStart()
	self.Button_ronglian:setVisible(false)
	self.ListView_1:setVisible(false)
	self.Image_11:setVisible(false)
	self.canLeave = false
	-- self:setListView()
	PopupLayerController:showLayer("RongLianDialogLayer",function(layer)
		layer:setRefreshNeiLiAndGoldFunc(function()
			self:setNeiLiAndGold()
		end)
		layer:setPrintFunc(function(str)
			self:print(str)
		end)
		layer:setForging(self:getForging())
		self.Panel_touch:setTouchEnabled(false)

		layer:showLayer(function(temperature)
			self.canLeave = true
			self.ListView_1:setVisible(true)
			self.Image_11:setVisible(true)
			local result = self:getRongLianResult(temperature)
			self:setRongLianRewardListView(result)
			User:getRole():setFlag("熔炼结果",result)
			--@RefType [app.models.role.Role#Role]
			local role = User:getRole()
			local addExp,upLv = ShenBingDuanZao:addFurnaceSkillExpByRongLian()
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
			
			local MAX_ROLE_SKILL_EXP = role:conversionSkillExpAndLv("exp", role:getSkillLvLimit("duanzaozhishu"))
			local nowExp = role:getSkillExp("duanzaozhishu")
			if nowExp >= MAX_ROLE_SKILL_EXP then
				self:print("您的"..skillName.."已出神入化，无法再提升！")
			end	

			local todayRonglianExp = role:getDayFlag("ronglian")
			if todayRonglianExp >= RONGLIAN_EXP_MAX_DAY then
				self:print("RED已达到每日熔炼可获得经验的上限，本日内熔炼无法再增加锻造之术经验")
			end

			self.Button_ronglian:setVisible(true)
			self.Button_ronglian.Text_buttonName:setString("领取材料")
			self.Button_ronglian:releaseFunc(function()
				local reward = {}
				for k,itemData in pairs(result) do 
					reward[itemData.itemId] = itemData.count
				end
				if User:getRole():checkCanBuyTwoOrMoreThings(reward) == true then
					User:getRole():setFlag("熔炼结果",0)
					self:print("你打开熔炉，将里面的东西取出。")
					for k,itemData in pairs(result) do 
						-- reward[itemData.itemId] = itemData.count
						User:getRole():addItemCount(itemData.itemId,itemData.count)
						local itemAttr = Item:getOneItemByKey(itemData.itemId) 
						if itemAttr ~= nil then
							PopText("获得物品"..itemAttr.name.."X"..tostring(itemData.count))
						end
					end
					self.Panel_touch:setTouchEnabled(true)
					self:showLayer(self.tmp,self.upperTemperature)
				else
					PopText("背包空间不足")
				end
			end)
		end,self.temperature,self.upperTemperature )
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 14:55:40
-- @desc 生成熔炼结果
function ShenBingRongLianLayer:getRongLianResult(temperature)
	return ShenBingRongLian:getResult(temperature,self.rl_list)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 21:26:45
-- @desc 获取熔炼材料中熔点温度最高的物品
function ShenBingRongLianLayer:getForging()
	local max,itemId = 0,""
	for k,itemData in pairs(self.rl_list) do 
		if itemData.melting > max then
			max = itemData.melting
			itemId = itemData.itemId
		end
	end
	max = ShenBingRongLian:getMaxTemperature(max,clone(self.rl_list))
	return itemId,max
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:19:14
-- @desc 设置内力和金钱数值
function ShenBingRongLianLayer:setNeiLiAndGold()
	local role = User:getRole()
	local neili,neiliMax = math.ceil(role:getAttr("neili")),math.ceil(role:getFinalAttr("neiliMax"))
	local gold = role: getAttr("gold")
	self.Text_neili_num:setString(tostring(neili).."/"..tostring(neiliMax))
	self.Text_gold_num:setString(tostring(gold))
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 15:54:45
-- @desc 初始化RichText
function ShenBingRongLianLayer:initRichText()
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
function ShenBingRongLianLayer:print(str, verticalSpace)
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
Helper:classDefNodeGetInstance(ShenBingRongLianLayer)
return  ShenBingRongLianLayer00000000000000
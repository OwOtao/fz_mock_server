local MaskResManager = require("app.models.mask.MaskResManager")

local MaskConst = require("app.models.mask.MaskConst")

-- 装饰箱
local DecorativeBoxLayer = class("DecorativeBoxLayer", LayerEx)

local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Resource = require("app.Resource")
local mask = require("script.others.tujian")

local TitleTable =
{
	{name = "戏曲面具",		type = "mianju", 	list = nil},
	{name = "武学云镜",	type = "yunjing",		list = nil},
}

function DecorativeBoxLayer:create()
	local p = DecorativeBoxLayer:new()
	p:init()
	return p
end

function DecorativeBoxLayer:init()
	local UI = require("Layer/DecorativeUI/DecorativeBoxUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setVisible(false)

	self:DecorativeBoxDsc()

	self:setShowAndHideAnimType("ROLL")

	self.DecorativeTableView = self:initTableView()

	-- 头像UI列表
	self.portraitListItems = {}

	-- 选中的头像
	self.imageGou = nil

	self._titleVector = {}

	self.portraitList = {}

	self.currPageIndex = 1

	self.Panel_bg:releaseFunc(function()
		if self.Is_show == false then
			self:itemDescHide()
		end
	end)

	self:initPortraitList()

	self:initTabView(TitleTable)
	self:setTitleImageShow()
	self:setBack()
	self:setButton()
	self:createShowList()
end

function DecorativeBoxLayer:onAwake()
	self:initCurrencies()
end

-- 显示界面 -- refreshFunc背包刷新
function DecorativeBoxLayer:showLayer(refreshFunc)
	if refreshFunc == nil then
		refreshFunc = function()
		end
	end
	self.refreshFunc = function()
		refreshFunc()
	end

	self.imageGou = nil
	self:initPortraitList()
	self:createShowList()
	self:show()
end

function DecorativeBoxLayer:initTableView()
	local panel = self.Panel_5

	local size = panel:getContentSize()
	local tableView = cc.TableView:create(size)
	tableView:setAnchorPoint(cc.p(0,0))
	tableView:setPosition(0,0)
	tableView:setDirection(1)
	tableView:setVerticalFillOrder(0)
	tableView:setDelegate()
	tableView:setBounceable(false)	-- 取消回弹
	tableView._maxCount = 0
	tableView._panelMap = {}
	tableView._onlyId = 1

	--滚动时的回掉函数
	tableView:registerScriptHandler(function()
		tableView._isScroll = true
	end, cc.SCROLLVIEW_SCRIPT_SCROLL)

	--列表项的尺寸
	tableView:registerScriptHandler(function()
		return 1000, 260
	end, cc.TABLECELL_SIZE_FOR_INDEX)

	--列表项的数量
	tableView:registerScriptHandler(function()
		return tableView._maxCount
	end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	--创建列表项
	tableView:registerScriptHandler(function(view,index)
		local panelItem = nil
		local cell = view:dequeueCell()
		if nil == cell then
			cell = cc.TableViewCell:new()

			panelItem = self.Panel_title:clone()
			Helper:convertUIByParent(panelItem)
			panelItem:setTag(123)
	        cell:addChild(panelItem)
	        panelItem:setPosition(500, 130)

			panelItem._stateFunc = nil
			panelItem._func = nil

			panelItem:setSwallowTouches(false)

			tableView._panelMap[tostring(tableView._onlyId)] = panelItem
			tableView._onlyId = tableView._onlyId + 1
		end

		if tableView.refreshPanelFunc then
			tableView.refreshPanelFunc(cell, index)
		end

		return cell
	end, cc.TABLECELL_SIZE_AT_INDEX)

	panel:addChild(tableView)
	panel._tableView = tableView
	return tableView
end

-- 创建头像列表
function DecorativeBoxLayer:createPortraitList(portraitList)
	if portraitList == nil then
		portraitList = self.currPageIndex
	end

	if type(portraitList) == "number" then
		portraitList = TitleTable[portraitList].list
	end

	-- 排序 将佩戴的放第一位
	local role = User:getRole()
	local portrait = role:getPortraitId()
	local topItem = nil
	local looksItem = nil
	local newList = {}
	-- 容貌第一 然后是装备的头像
	if role:checkHeadIsMask() == false then
		for i,v in ipairs(portraitList) do
			if v.portraitType == "looks" then
				looksItem = v
				table.insert(newList, looksItem)
			end
			if v.itemId == portrait and v.portraitType ~= "looks" then
				topItem = v
				table.insert(newList, topItem)
			end
		end

		-- 重新插入新的列表中
		for i,v in ipairs(portraitList) do
			if (topItem == nil or v.itemId ~= topItem.itemId) and v.portraitType ~= "looks" then
				table.insert(newList, v)
			end
		end
		portraitList = newList
	end

	if self.currPageIndex == 1 then
		-- 添加按钮
		table.insert(newList, {itemId = nil, portraitType = "add"})
	end

	local function initPanel(portraitData, di, frame, kuang, head, gou, text, add, rong)
		local defColor = cc.c3b(208, 208, 208)
		local textColor = cc.c3b(48, 206, 205)
		local outlineColor = cc.c4b(0, 0, 0, 255)

		di:setVisible(false)
		frame:setVisible(false)
		head:setVisible(false)
		gou:setVisible(false)
		kuang:setVisible(false)
		add:setVisible(false)
		rong:setVisible(false)
		text:setColor(defColor)
		text:setString("")
		frame:setSwallowTouches(false)
		frame:releaseFuncTotally(function()
			self.DecorativeTableView._isScroll = false
			end,
			function()
			end
		)

		if portraitData ~= nil then
			local item = Item:getOneItemByKey(portraitData.itemId)
			if portraitData.unOwn == true then
				-- 未拥有的面具
				frame:setVisible(true)
				frame:loadTexture(item.bgPath)
				frame:setSwallowTouches(false)
				frame:releaseFuncTotally(function()
					self.DecorativeTableView._isScroll = false
					end,
					function()
						if self.DecorativeTableView._isScroll == false then
							if portraitData.unOwn == true then
								PopText("你尚未拥有该装饰")
							end
						end
					end
				)
				
			elseif portraitData.portraitType == "add" then
				-- 添加装饰箱容量
				add:setVisible(true)
				add:setSwallowTouches(false)
				add:releaseFuncTotally(function()
					self.DecorativeTableView._isScroll = false
					end,
					function()
						if self.DecorativeTableView._isScroll == false then
							local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
							local dialog = DialogALayer:getInstance()
							dialog:hide()
							dialog:show("是否消耗一个天工石，增加一个装饰箱容量？")
							dialog:setRichText("是否消耗一个天工石，增加一个装饰箱容量？")
							dialog:setButton1("是", function()
								if role:getItemCount("tiangongshi1") >= 1 then
									if not role:addItemCount("tiangongshi1", -1) then
										return
									end
									PopText("装饰箱容量 + 1" )
									role:addAttr("decorativeLimit", 1)
									self:initPortraitList()
									self:createPortraitList()
									self.refreshFunc()
								else
									PopText("道具数量不足")
								end
							end)
							dialog:setButton2("否", function()
								dialog:hide()
							end)
						end
					end
				)
			elseif portraitData.portraitType == "none" then
				frame:setVisible(true)
				frame:loadTexture("Image/UI/MaskUI/dikuanghei.png")
			else
				if role:checkHeadIsMask() == false then
					if portrait == "" and portraitData.portraitType == "looks" then
						gou:setVisible(true)
						kuang:setVisible(true)
						self.imageGou = gou
						text:setColor(textColor)
					elseif portrait == portraitData.itemId then
						gou:setVisible(true)
						kuang:setVisible(true)
						self.imageGou = gou
						text:setColor(textColor)
					end
				end
				if portraitData.portraitType == "looks" then
					rong:setVisible(true)
					rong:loadTexture("Image/UI/MaskUI/rong.png")
					rong:setSize(113,56)
				elseif item and role:getMaskSystem():getMaskGrade(item.gradeId,1):canUpgrcade() then
					rong:setVisible(true)
					rong:loadTexture("Image/UI/MaskUI/yan.png")
					rong:setSize(49,53)
				end
				di:setVisible(true)
				frame:setVisible(true)
				head:setVisible(true)
				frame:loadTexture("Image/UI/MaskUI/dikuanghei.png")
				local present = require("app.presenters.HeadView.HVPPresent"):create(head,di,{
					sex = role:getAttr("sex"),
					looks = role:getFinalAttr("looks"),
					portrait = portraitData.itemId,
					polymorph = role:getAttr("polymorph")
				})
				present:showHead()
			end

			if item then
				local maskGrade = role:getMaskSystem():getMaskGrade(item.gradeId,1)
				text:setString(maskGrade:getMaskName())
			elseif portraitData.portraitType == "looks" then
				text:setString(User:getRoleAttr("name"))
			end
			text:enableOutline(outlineColor, 5)

			-- 点击头像
			head:setSwallowTouches(false)
			head:releaseFuncTotally(function()
					self.DecorativeTableView._isScroll = false
				end,
				function()
					if self.DecorativeTableView._isScroll == false then
						local buttonFunc = function()
							if portraitData.unOwn == true then
								PopText("你尚未拥有该头像。")
								return
							end
							if role:checkHeadIsMask() then
								PopText("你已经穿戴了面具， 请先卸下面具才可更换头像")
								return
							end

							-- 重复点击不处理
							if role:getPortraitId() == portraitData.itemId then
								PopText("你已经穿戴了该面具")
								return
							end
							local updataMaskUI = function()
								if self.imageGou ~= nil then
									self.imageGou:setVisible(false)
								end
								self.imageGou = gou
								self.imageGou:setVisible(true)

								role:updateRoleBuff()
								self:createPortraitList()
								self:itemDescHide()
							end

							----------------- 更换头像描述 -----------------
							local str
							if portraitData.itemId == nil or portraitData.itemId == "" then
								str = role:getMaskSystem():getMaskGrade(role:getPortraitId(),role:getPortraitLv()):getUnwieldText()
								str = string.gsub(str, "$N", "你")
								str = string.gsub(str, "$w", Item:getOneItemByKey(role:getPortraitId()).name)
								RichPrint("main", str)
								role:unwearMask()
								updataMaskUI()
							else
								self:showAffirmLayer(portraitData.itemId,1,function()
									updataMaskUI()
								end)
							end
						end

						if item and role:getMaskSystem():getMaskGrade(item.gradeId,1):canUpgrcade() then
							self:itemDescShow(portraitData,function()
								PopupLayerController:showLayer("MaskUpgradeLayer", function(layer)
									layer:setItem(item)
									layer:setWearCallback(function(maskLv)
										if self.imageGou ~= nil then
											self.imageGou:setVisible(false)
										end
										self.imageGou = gou
										self.imageGou:setVisible(true)
			
										----------------- 更换头像描述 -----------------
										local str
										if portraitData.itemId == nil or portraitData.itemId == "" then
											role:getMaskSystem():getMaskGrade(role:getPortraitId(),role:getPortraitLv()):getUnwieldText()
											str = string.gsub(str, "$N", "你")
											str = string.gsub(str, "$w", Item:getOneItemByKey(role:getPortraitId()).name)
											RichPrint("main", str)
										else
			
											str = role:getMaskSystem():getMaskGrade(portraitData.itemId,maskLv):getEquipText()
											str = string.gsub(str, "$N", "你")
											str = string.gsub(str, "$w", Item:getOneItemByKey(portraitData.itemId).name)
											RichPrint("main", str)
										end
										self:createPortraitList()
									end)
									layer:setCostCurrencyUICallback(function()
										self:initCurrencies()
									end)
									layer:showLayer()
									self:itemDescHide()
								end)
							end,"换\n颜")
						else
							self:itemDescShow(portraitData,buttonFunc,"佩\n戴")
						end 
					end
				end
			)
		end
	end
	
	self.DecorativeTableView.refreshPanelFunc = function(cell, index)
		print("index = ",index)
		local panel = cell:getChildByTag(123)
		for i = 1,4 do
			local portraitData = portraitList[index*4+i]
			initPanel(portraitData, panel["Image_di_"..i], panel["Image_frame_"..i], panel["Image_kuang_"..i], panel["Image_head_"..i],
			panel["Image_gou_"..i],panel["Text_name_"..i],panel["Image_add_"..i],panel["Image_rong_"..i])
		end
	end
	local mod, remainder = math.modf(#portraitList / 4)
    if math.ceil(remainder) == 1 then
        mod = mod + 1
    end

	self.DecorativeTableView._maxCount = mod
	self.DecorativeTableView:reloadData()
end

-- 创建皮肤列表
function DecorativeBoxLayer:createSkinList(skinList)
	if skinList == nil then
		skinList = self.currPageIndex
	end

	if type(skinList) == "number" then
		skinList = TitleTable[skinList].list
	end

	if MapIsEmpty(skinList) then
		return
	end
	
	local role = User:getRole()
	local appearance = role:getAttr("appearance")

	if #skinList > 1 then
		table.sort(skinList, function(a, b)
			if a.itemId == appearance then
				return true
			elseif b.itemId == appearance then
				return false
			else
				return a.itemId < b.itemId
			end
		end)
	end
	
	for i,v in ipairs(skinList) do
		local itemId = v.itemId
		local item = Item:getOneItemByKey(itemId)
		if not MapIsEmpty(item) then
			local panel = self.ListView_skin:getItem(i - 1)
			if panel == nil then
				panel = self.Panel_skin:clone()
				Helper:convertUIByParent(panel)
				self.ListView_skin:pushBackCustomItem(panel)
			end

			panel.Text_name:setString(item.name)
			panel.Text_type:setString(item.effectType)
			
			if appearance == itemId then
				panel.dian:setVisible(true)
				panel:releaseFunc(function()
					PopupLayerController:showLayer("DialogOLayer", function(layer)
						layer:setTitle(item.name)
						layer:setTalentTypeText(item.type)
						layer:setTalentDsc(item.dsc)
						layer:setDesc4(item.dscAdd)
						if appearance == "waiguan0" then
							layer:setButton(nil)
						else
							layer:setButton("卸下",function()
								role:setAttr("appearance","waiguan0") --默认装备 初始外观
								self:createSkinList()
							end)
						end
						layer:showLayer()
					end)
					return 
				end)
			else
				panel.dian:setVisible(false)
				panel:releaseFunc(function()
					PopupLayerController:showLayer("DialogOLayer", function(layer)
						layer:setTitle(item.name)
						layer:setTalentTypeText(item.type)
						layer:setTalentDsc(item.dsc)
						layer:setDesc4(item.dscAdd)
						layer:setButton("装备",function()
							role:setAttr("appearance",itemId)
							self:createSkinList()
						end)
						layer:showLayer()
					end)
					return 
				end)
			end
		end
	end
end

--创建展示列表
function DecorativeBoxLayer:createShowList(list)
	if list == nil then
		list = self.currPageIndex
	end

	if type(list) == "number" then
		list = TitleTable[list].list
	end

	if self.currPageIndex == 1 then
		self:createPortraitList(list)
		self.ListView_skin:setVisible(false)
		self.DecorativeTableView:setVisible(true)
		self.Button_Pokedex:setVisible(true)
	elseif self.currPageIndex == 2 then
		self:createSkinList(list)
		self.ListView_skin:setVisible(true)
		self.DecorativeTableView:setVisible(false)
		self.Button_Pokedex:setVisible(false)
	else
		assert(nil,"未知页面")
	end
end

-- 初始化头像列表
function DecorativeBoxLayer:initPortraitList()
	local role = User:getRole()
	local decorative = role:getAttr("decorative")
	self:sortTable(decorative)

	local mianJuList = {}
	local appearanceList = {}

	TitleTable[1].list = mianJuList
	TitleTable[2].list = appearanceList

	table.insert(mianJuList,   {itemId = "", portraitType = "looks"})
	table.insert(appearanceList,   {itemId = "waiguan0", portraitType = "appearance"})
	
	if MapIsEmpty(decorative) == true then
		--return
	end

	-- 装饰箱上限
	local limit = role:getDecorativeLimit() - 1

	for k,v in pairs(decorative) do
		if v.portraitType == "appearance" then
			table.insert(appearanceList, v)
		else
			limit = limit - 1
			table.insert(mianJuList, v)
		end
	end

	-- 剩余格子
	for i=1,limit do
		table.insert(mianJuList,   {itemId = nil, portraitType = "none"})
	end
end

---排序
function DecorativeBoxLayer:sortTable(decorative)
	if type(decorative) ~= "table" then
		return nil
	end
	local role = User:getRole()
	if not MapIsEmpty(decorative) then
		table.sort( decorative, function(a, b)
			local itemAttr_a=Item:getOneItemByKey(a.itemId)
	    	local itemAttr_b=Item:getOneItemByKey(b.itemId)
	    	if not itemAttr_a or not itemAttr_b then
	    		return false
	    	end
	    	local rest = true
	    	rest = a.itemId < b.itemId
			return rest
		end)
	end
	return decorative
end

-- 初始化标签页
function DecorativeBoxLayer:initTabView(titleTable)
	local outlineWidth = 5
	local textColor = cc.c3b(234,234, 234)
	local outlineColor = cc.c4b(44, 51, 54, 255)
	local tag = 999
	for k,table in ipairs(titleTable) do
		local panel = self.Image_tab["Panel_back_title_"..k]
		Helper:convertUIByParent(panel)
		panel:setTag(tag)
		panel.Text_title:setString(table.name)
		panel.Text_title:setColor(textColor)
		panel.Text_title:enableOutline(outlineColor, outlineWidth)
		panel.Image_back:setVisible(false)

		panel:releaseFunc(function()
			self.imageGou = nil
			self.currPageIndex = k
			self:createShowList(TitleTable[k].list)
			self:setTitleImageShow(panel)
		end)
		self._titleVector[#self._titleVector + 1 ] = panel
		tag = tag + 1
	end
end

-- 高亮选择标题
function DecorativeBoxLayer:setTitleImageShow(panel)
	if panel then
		local tag = panel:getTag()
		if not MapIsEmpty(self._titleVector) and tag then
			for i,v in ipairs(self._titleVector) do
				if v:getTag() and v:getTag()  == tag then
					v.Image_back:setVisible(true)
				else
					v.Image_back:setVisible(false)
				end
			end
		end
	else
		if not MapIsEmpty(self._titleVector) then
			for i,v in ipairs(self._titleVector) do
				if i == 1 then
					self._titleVector[i].Image_back:setVisible(true)
				else
					self._titleVector[i].Image_back:setVisible(false)
				end
			end
		end
	end
end

-- 设置返回
function DecorativeBoxLayer:setBack()
	self.Image_back:releaseFunc(function()
	end)

	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("DecorativeBoxLayer", function(layer)
			self:hide()
		end, 0)
	end)
end

function DecorativeBoxLayer:setButton()
	self.Button_Pokedex:releaseFunc(function()
		PopupLayerController:showLayer("DecorativePokedexLayer", function(layer)
			layer:showLayer()
		end)
	end)
end

function DecorativeBoxLayer:initCurrencies()
	HttpManagerEx:viewCurrencyByType(
        "zongheng", User:getRole():getCurrencyVersion(),
		function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then

					self.Text_currencyNum_1:setString(data.number.."/"..data.limitNumber)

				else
					print("viewCurrencyByType",errmsg,errcode)
				end
			else
				print("viewCurrencyByType",errmsg,errcode)
			end
        end,
        IS_SHOW_WAITING
    )

	HttpManagerEx:viewCurrencyByType(
		"spcl", User:getRole():getCurrencyVersion(),
		function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					local num = Helper:getDef(data.number,0)
					self.Text_ShiPingNum:setString(num)
				else
					print("viewCurrencyByType",errmsg,errcode)
				end
			else
				print("viewCurrencyByType",errmsg,errcode)
			end
		end,
		IS_SHOW_WAITING
	)
end

--装饰箱描述
function DecorativeBoxLayer:DecorativeBoxDsc()
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self.Panel_tips.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			dialog:show("装饰道具可通过签到、购买获得。\n装备装饰将使得你的外形发生变化。")
			dialog:setPanelBack(function()
				self.Panel_tips.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			self.Panel_tips.Image_7:setVisible(true)
		end
	end)
end

-- 物品描述显示
function DecorativeBoxLayer:itemDescShow(portraitData,func,name)
	local role = User:getRole()
	self.Panel_itemDesc:setTouchEnabled(true)
	self.Panel_bg:setVisible(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(402.70, 1523.10))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(402.70, 1503.10)),
			cc.FadeIn:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
				self.Is_show = false
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
	Panel_itemDesc.Image_back.Image_button.Text_chuan:setString(name)
	Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
			if func then
				func()
			end
		end
	)
	
	if portraitData then
		local portrait = {id = portraitData.itemId,lv = 1}
		if role:getPortraitId() == portraitData.itemId then
			portrait.lv = role:getPortraitLv()
		end
		local present = require("app.presenters.HeadView.HVPPresent"):create(Panel_itemDesc.Image_back.Image_head,Panel_itemDesc.Image_back.Image_di,{
			sex = role:getAttr("sex"),
			looks = role:getFinalAttr("looks"),
			portrait = portrait,
			polymorph = role:getAttr("polymorph")
		})
		present:showAnim()
		present:playEffect()

		local imagPath = Resource:getImgPath("headFrame01")
		
		local name ,type,maskDesc= "","",""
		if portraitData.portraitType == "looks" then
			name = role:getName()
			type = "江湖容貌"
			maskDesc = role:getJiangHuFaceDsc(role:getAttr("sex"),role:getAttr("looks")).."。"
		else
			local item = Item:getOneItemByKey(portraitData.itemId)
			if item then
				if item.gradeId then
					local headAttr = role:getMaskSystem():getMaskAttrByMaskIdAndLv(item.gradeId,portrait.lv)
					if headAttr and headAttr:getFramePath() then
						imagPath = headAttr:getFramePath()
					end
					if headAttr and headAttr:getMaskDesc() then
						maskDesc = headAttr:getMaskDesc().."。"
					end
				end
				if item.name then
					name = item.name
				end
				if item.type then
					type = item.type
				end
			end
		end
		Panel_itemDesc.Image_back.Panel_title.Text_name:setString(name)
		Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(type)
		Panel_itemDesc.Image_back.TextField_desc:setString(maskDesc)
		Panel_itemDesc.Image_back.Image_frame:loadTexture(imagPath)
		local texture = cc.TextureCache:getInstance():getTextureForKey(imagPath);
		Panel_itemDesc.Image_back.Image_frame:setSize(texture:getContentSize())
	end
end

-- 物品描述隐藏
function DecorativeBoxLayer:itemDescHide()
	self.Panel_itemDesc:setTouchEnabled(false)
	self.Panel_bg:setVisible(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(402.70, 1503.10))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(402.70, 1523.10)),
			cc.FadeOut:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
				self.Panel_itemDesc:setVisible(false)
				self.Panel_bg:setVisible(false)
				self.Is_show = false
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
end

function DecorativeBoxLayer:showAffirmLayer(maskId,maskLv,callback)
	--@desc 有新框体需要更换时，弹出提示
	if User:getRole():getMaskSystem():isChangeMaskBorder(maskId,maskLv) then
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		local text = "佩戴此面具会改变当前主界面头像框，排行榜头像框，个人简介背景框，是否确认更换？"
		dialog:show(text)
		dialog:setButton1("确定",
			function()
				self:changeMask(maskId,maskLv,callback)
			end
		)
		dialog:setButton2("取消")
		dialog:setWeChatVisible(false)
	else
		self:changeMask(maskId,maskLv,callback)
	end
end

function DecorativeBoxLayer:changeMask(maskId,maskLv,callback)
    local maskGrade = User:getRole():getMaskSystem():getMaskGrade(maskId,maskLv)

    local isResult,msgList = User:getRole():getMaskSystem():checkMaskConditions(maskGrade:getWearCondition())

    if isResult then
        User:getRole():wearMask(maskId,maskLv)
		
		local str = maskGrade:getEquipText()
		str = string.gsub(str, "$N", "你")
		str = string.gsub(str, "$w", Item:getOneItemByKey(maskId).name)
		RichPrint("main", str)

		if callback then
			callback()
		end
    else
		for i,msgText in ipairs(msgList) do
			PopText(msgText)
		end
		PopText("佩戴面具失败!")
    end
end


Helper:classDefNodeGetInstance(DecorativeBoxLayer)

return DecorativeBoxLayer000000000000000
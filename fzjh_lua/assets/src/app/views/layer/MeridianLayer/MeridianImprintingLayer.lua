local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Role = require("app.models.role.Role")
local Meridian = require("app.models.Meridian.Meridian")

local MeridianConstans = TableProxy:createEncryptedTableRecursive({
	breathValCost = 180000
})

-- 经脉印记
local MeridianImprintingLayer = class("MeridianImprintingLayer", LayerEx)

local TitleTable =
{
	{name = "已拥有",	type = "own", 	list = nil},
}

function MeridianImprintingLayer:create()
	local p = MeridianImprintingLayer:new()
	p:init()
	return p
end

function MeridianImprintingLayer:init()
	self._UI = require("Layer/MeridianUI/MeridianImprintingUI.lua").create()['root']
	self._UI:addTo(self)

	self._titleVector = {}

	self.currPageIndex = 1

	self.selectPanelDrak = nil

	Helper:convertUIByParent(self)

	self.Panel_bg:releaseFunc(function()
		if self.Is_show == false then
			self:imprintingDescHide()

			if self.selectPanelDrak ~= nil then
				self.selectPanelDrak:setVisible(false)
			end
		end
	end)

	self:initRichText()

	self:refreshUI()

	self:initTabView(TitleTable)
	self:setTitleImageShow()
end

function MeridianImprintingLayer:onResume()
	self.Panel_bg:setVisible(false)
	self.Panel_itemDesc:setVisible(false)

	self:MeridianImprintingDsc()
end

--经脉天赋描述
function MeridianImprintingLayer:MeridianImprintingDsc()
	local titleLayer = MainControllLayer:getLayer("TitleLayer")
    if titleLayer then
        titleLayer:setTipFunc(
            function(func)
                local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
				local dialog = DialogELayer:getInstance()
				dialog:show("每打通一条经脉便可获得一个经脉天赋，培元可以将一条经脉天赋随机更换成新的经脉天赋。\n已打通的经脉传承不保留，传承时保留对应传承次数的经脉天赋数量。\n互搏神通天赋学习条件为人物至少传承一次且打通八条经脉。")
				dialog:setPanelBack(function()
					if func then
						func()
					end
					
				end)
            end
        )
    end
end

-- 初始化输出框
function MeridianImprintingLayer:initRichText()
	local x, y = self.Image_help.Panel_talk:getPosition()
	local size = self.Image_help.Panel_talk:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Image_help.Panel_talk:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Image_help.Panel_talk:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)
end

function MeridianImprintingLayer:print(str, verticalSpace)
	if str == "" then
		return
	end

	if self.RichText_print == nil then
		return
	end
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 36)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end

-- 初始化印记
function MeridianImprintingLayer:initImprinting()
	local role = User:getRole()

	local meridian = role:getAttr("meridian")
	local meridianImprinting = role:getAttr("meridianImprinting")

	-- 已拥有的经脉印记
	local OwnList = {}
	TitleTable[1].list = OwnList

	-- 左右互搏开启
	if Meridian:checkCanOpenLeftRightFight() == true and role:isHaveImprintingId("zuoyouhuboyin") ~= true then
		table.insert(OwnList, Meridian:getImprintingId("zuoyouhuboyin"))
	end

	for i,v in ipairs(meridianImprinting) do
		if v.imprintingId ~= nil then
			table.insert(OwnList, Meridian:getImprintingId(v.imprintingId))
		end
	end

	for i,v in ipairs(meridianImprinting) do
		if v.imprintingId == nil then
			table.insert(OwnList, {name = "经脉印记", text = "培元可获得新的经脉印记", imprintingId = nil, peiyuan = 1, type = ""})
		end
	end
end

-- 初始化列表
function MeridianImprintingLayer:initListItem(imprintingList)
	if imprintingList == nil then
		imprintingList = self.currPageIndex
	end

	if type(imprintingList) == "number" then
		imprintingList = TitleTable[imprintingList].list
	end

	self.selectPanelDrak = nil
	-- self.Panel_bg:setVisible(false)
	-- self.Panel_itemDesc:setVisible(false)

	if MapIsEmpty(imprintingList) then
		self.ListView_titlelistArea:setVisible(false)
		return
	else
		self.ListView_titlelistArea:setVisible(true)
	end

	local index = 0
	for i,v in ipairs(imprintingList) do
		self:createPanel(index, v)
		index = index + 1
	end

	-- 移除多余的panel
	for i = index + 1,#self.ListView_titlelistArea:getItems() do
		self.ListView_titlelistArea:removeLastItem()
	end
end

function MeridianImprintingLayer:createPanel(index, imprintingData)
	local listItems = self.ListView_titlelistArea:getItems()
	local panel
	if #listItems > index then
		panel = self.ListView_titlelistArea:getItem(index)
	else
		panel = self.Panel_imprinting:clone()
		Helper:convertUIByParent(panel)
		self.ListView_titlelistArea:pushBackCustomItem(panel)
	end

	panel.Panel_name.Text_name:setString(imprintingData.name)
	panel.Text_type:setString(imprintingData.type)

	if imprintingData.type == "战斗类" then
		panel.Text_type:setColor({r = 219, g = 57, b = 57, a = 255})
	else
		panel.Text_type:setColor({r = 102, g = 153, b = 153, a = 255})
	end

	panel.Panel_name.Text_name:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
	panel.Text_type:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)

	panel.Image_dark:setVisible(false)

	panel:releaseFunc(function()
		if self.selectPanelDrak ~= nil then
			self.selectPanelDrak:setVisible(false)
		end
		self.selectPanelDrak = panel.Image_dark:setVisible(true)
		self:setImprintingDesc(imprintingData)
		self:imprintingDescShow()
	end)
end

-- 初始化标签页
function MeridianImprintingLayer:initTabView(titleTable)
	local outlineWidth = 5
	local textColor = cc.c3b(234,234, 234)
	local outlineColor = cc.c4b(44, 51, 54, 255)
	local tag = 999
	for k,table in pairs(titleTable) do
		local panel = self.Panel_back_title:clone()
		Helper:convertUIByParent(panel)
		panel:setTag(tag)
		panel.Text_title:setString(table.name)
		panel.Text_title:setColor(textColor)
		panel.Text_title:enableOutline(outlineColor, outlineWidth)
		panel.Image_back:setVisible(false)

		self.Image_tab.ListView_tab:pushBackCustomItem(panel)
		panel:releaseFunc(function()
			self.currPageIndex = k
			self:initListItem(TitleTable[k].list)
			self:setTitleImageShow(panel)
		end)
		self._titleVector[#self._titleVector + 1 ] = panel
		tag = tag + 1
	end
end

-- 高亮选择标题
function MeridianImprintingLayer:setTitleImageShow(panel)
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

-- 刷新UI
function MeridianImprintingLayer:refreshUI()
	local role = User:getRole()

	local meridian = role:getAttr("meridian")
	local breathVal = math.floor(role:getAttr("breathVal"))
	local meridianLevel = role:getAttr("meridianLevel")
	local meridianExp = role:getAttr("meridianExp")

	self.Text_MeridianLv_num:setString(Meridian:getMeridianLv(role:getAttr("meridianExp")))
	self.Text_zhenqi_num:setString(breathVal)
end

-- 印记描述设置
function MeridianImprintingLayer:setImprintingDesc(imprintingData)
	local titlePanel = self.Panel_itemDesc.Image_back.Panel_title
	titlePanel.Text_name:setString(imprintingData.name)
	titlePanel.Text_zhuangbei:setString(imprintingData.type)
	titlePanel.Text_lv:setString("")

	-- 左右互搏特殊处理
	if imprintingData.imprintingId == "zuoyouhuboyin" then
		self.Panel_itemDesc.Image_back.Text_speed:setString("")

		if imprintingData.type == "战斗类" then
			titlePanel.Text_zhuangbei:setColor({r = 219, g = 57, b = 57, a = 255})
		else
			titlePanel.Text_zhuangbei:setColor({r = 102, g = 153, b = 153, a = 255})
		end

		self.Panel_itemDesc.Image_back.TextField_desc:setString(imprintingData.text)

		local role = User:getRole()
		if role:isHaveImprintingId("zuoyouhuboyin") == false then
			self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString("开\n启")
			self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
				local role = User:getRole()
				local inheritCount = role:getAttr("inheritCount")

				if role:getFlag("左右互搏入门贴获取") == 0 and inheritCount < 3 then
					-- 获取左右互搏入门贴
					local count = 0
					if inheritCount == 1 then
						count = 3
					elseif inheritCount == 2 then
						count = 5
					end
					if role:getAttr("weight") - #role:getItems() < count then
						PopText("背包空间不足")
						return
					end
					role:addItemCount("zuoyouhubo1", count)
					PopText("获得福禄寿酒 X " .. count)
					role:setFlag("左右互搏入门贴获取", 1)
				end

				self:imprintingDescHide()
				self:initImprinting()
				self:initListItem()
				self:refreshUI()
				self:print("HIC玄之又玄，众妙之门。在修炼经脉的过程中，你福至心灵，无师自通，领悟了一些互搏神通的门道，但仍不得其法。作为一种特殊的行功方式，互搏神通可谓博大精深，而武林奇人无名老者正精于此道，现在就前往落英谷向其请教一二吧！")
			end)
		else
			local leftRightFightExp = role:getAttr("leftRightFightExp")
			local lv = math.ceil(Helper:getDef(leftRightFightExp, 0) / 100)

			--@desc 熟练度
			local leftRightFightDegree = leftRightFightExp % 100

			if leftRightFightExp > 99 and leftRightFightDegree == 0 then
				lv = lv + 1
			end

			if lv > 10 then
				lv = 10
			end

			titlePanel.Text_lv:setString(lv .. "级")
			self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString("升\n级")
			self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
				self:imprintingDescHide()
				if lv >= 10 then
					PopText("互搏神通已经满级")
				else
					self:initImprinting()
					self:initListItem()
					self:refreshUI()
					self:print("HIC现在就前往落英谷向无名老者请教一二吧！")
				end
			end)
		end


		return
	end

	if imprintingData.imprintingId == nil then
		self.Panel_itemDesc.Image_back.Text_speed:setString("")
	else
		self.Panel_itemDesc.Image_back.Text_speed:setString("消耗"..MeridianConstans.breathValCost.."真气")
	end

	if imprintingData.type == "战斗类" then
		titlePanel.Text_zhuangbei:setColor({r = 219, g = 57, b = 57, a = 255})
	else
		titlePanel.Text_zhuangbei:setColor({r = 102, g = 153, b = 153, a = 255})
	end

	self.Panel_itemDesc.Image_back.TextField_desc:setString(imprintingData.text)
	self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString("培\n元")
	self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
		PopupLayerController:showLayer("DiscountLayer",function(layer)
			local role = User:getRole()
			local buttonFunc = function(item)
				local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
				local dialog = DialogALayer:getInstance()
				dialog:hide()
				if item == "sancaidan" then
					dialog:show("服用三才丹，可直接进行经脉培元，确定要对此经脉天赋进行培元吗？(将消耗一颗三才丹)")
				elseif item == "dingzhiwan" then
					dialog:show("服用定志丸，可直接进行经脉培元，确定要对此经脉天赋进行培元吗？(将消耗一颗定志丸)")
				elseif item == "breathVal" then
					dialog:show("运转真气进行经脉培元，确定要对此经脉天赋进行培元吗？(将消耗"..MeridianConstans.breathValCost.."真气)")
				else
				end
				dialog:setButton1("确定", function()
					if imprintingData.imprintingId ~= nil then
						if imprintingData.peiyuan == 0 then
							PopText("当前经脉天赋 无法培元")
							return
						end

					end

					local peiyuanSucFunc = function(itemId,useDingZhiWan,useDingZhiWanNum)
						local imprintingId = Meridian:peiyuan(imprintingData.imprintingId,useDingZhiWan,useDingZhiWanNum)

						-- 没有可获取的经脉印记
						if imprintingId == nil then
							PopText("培元失败")
							self:initImprinting()
							self:initListItem()
							self:refreshUI()
							return
						end

						if itemId == "sancaidan" then
							PopText("消耗 三才丹 X 1")
							role:addItemCount("sancaidan", -1)
						elseif itemId == "dingzhiwan" then
							PopText("消耗 定志丸 X 1")
							role:addItemCount("dingzhiwan", -1)
						elseif item == "breathVal" then
							role:addAttr("breathVal", -MeridianConstans.breathValCost)
						else
							assert(false,"未知选项")
						end

						local strDesc =
							{
								[1] = {"GRN仙人抚我顶，", "GRN结发受长生。"},
								[2] = {"GRN载营魄抱一，能无离乎？", "GRN专气致柔，能如婴儿乎？"},
							}
						local num = math.random(1,#strDesc)

						self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()end)
						self.Is_show = true
						self:delayFunc(0.5, function()
							self:print("HIC你突然心有所感、福至心灵，真气在周身各大经脉中流转，若此时有人在旁，只会觉得你的神情突然凝重起来，却不知你体内正掀起惊涛骇浪，一种巨大的变化已然发生！")
						end)
						self:delayFunc(1, function()
							self:print(strDesc[num][1])
						end)
						self:delayFunc(1.5, function()
							self:print(strDesc[num][2])
						end)
						self:delayFunc(2, function()
							self:initImprinting()
							self:initListItem()
							self:refreshUI()

							self:print("YEL获得经脉天赋WHT" .. Meridian:getImprintingId(imprintingId).name .. "HIC！")
							-- 刷新弹窗信息
							self:setImprintingDesc(Meridian:getImprintingId(imprintingId))
							self.Is_show = false
						end)

						-- 培元统计
						local Record = require("app.models.Record.Record")
						Record:addRecordCount("jingmai", "event", "peiyuan")
					end

					if item == "sancaidan" then
						peiyuanSucFunc(item)
					elseif item == "dingzhiwan" then
						local itemId = "dingzhiwan"
						local itemNum = 1
						HttpManagerEx:checkItemIsCanUse(
							itemId,
							itemNum,
							function(status, errcode, errmsg, data)
								if status == 200 then
									if errcode == 0 then
										local useDingZhiWan = true
										local useDingZhiWanNum = tonumber(data.dingzhiwannum)
										if DEBUG_MODE == 1 then
											Helper:print_lua_table(data)
											print("useDingZhiWanNum = ",useDingZhiWanNum)
										end
										peiyuanSucFunc(item,useDingZhiWan,useDingZhiWanNum)
									else
										PopText(errmsg)
										print("errmsg", errmsg, "errcode", errcode)
									end
								else
									PopText(errmsg)
								end
							end,
							IS_SHOW_WAITING)
					elseif item == "breathVal" then
						peiyuanSucFunc(item)
					else
						assert(false,"未知选项")
					end
				end)

				dialog:setButton2("取消", function()
					dialog:hide()
				end)
				dialog:setWeChatVisible(false)
			end
			layer:setButton("Button_1", "真气培元", function()
				if role:getAttr("breathVal") < MeridianConstans.breathValCost then
					PopText("真气不足，无法培元")
					return
				end
				layer:hide()
				buttonFunc("breathVal")
			end)
			layer:setButton("Button_2", "三才丹", function()
				if role:getItemCount("sancaidan") < 1 then
					PopText("您没有三才丹")
					return 
				end
				layer:hide()
				buttonFunc("sancaidan")
			end)
			layer:setButton("Button_3", "定志丸", function()
				local inheritCount = role:getAttr("inheritCount")
				if role:getItemCount("dingzhiwan") < 1 then
					PopText("您没有定志丸")
					return
				elseif inheritCount <= 0 then
					PopText("你的体内没有来自他人的内力，恐怕无法承受此药。")
					return
				end
				layer:hide()
				buttonFunc("dingzhiwan")
			end)
			layer:setButton("Button_4", "取消", function()
				layer:hide()
			end)
			layer:showLayer("培元经脉天赋后，该天赋会消失，同时重新获得一个新的经脉天赋")
			layer:setBack(false)
		end)



	end)

end

-- 印记描述显示
function MeridianImprintingLayer:imprintingDescShow()
	self.Panel_itemDesc:setTouchEnabled(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	self.Panel_bg:setVisible(true)
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(300, 1710))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(300, 1540)),
			cc.FadeIn:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
				self.Is_show = false
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
end

-- 印记描述隐藏
function MeridianImprintingLayer:imprintingDescHide()
	self.Panel_itemDesc:setTouchEnabled(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	self.Panel_bg:setVisible(true)
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(300, 1540))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(300, 1710)),
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

Helper:classDefNodeGetInstance(MeridianImprintingLayer)

return MeridianImprintingLayer000
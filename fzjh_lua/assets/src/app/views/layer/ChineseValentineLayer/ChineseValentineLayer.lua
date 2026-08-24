local ChineseValentineLayer = class("ChineseValentineLayer", require("app.views.base.BaseLayer"))


local CVModel = require("app.models.Action.ChineseValentine.CVModel")
local qiyuanMap = CVModel:getQiyuanMap()
local tape = CVModel:getTapeMap()


local tb_item = {
	["财源广进_qixiqiyuan1"] = "qixiqifu1",
	["武功有成_qixiqiyuan1"] = "qixiqifu2",
	["花容月貌_qixiqiyuan1"] = "qixiqifu3",
	["精力充沛_qixiqiyuan1"] = "qixiqifu4",
	["绝学招式_qixiqiyuan1"] = "qixiqifu5",
	["上等好酒_qixiqiyuan1"] = "qixiqifu6",
	["神兵利器_qixiqiyuan1"] = "qixiqifu7",
	["美食佳肴_qixiqiyuan1"] = "qixiqifu8",
	["学富五车_qixiqiyuan1"] = "qixiqifu9",
	["师门兴旺_qixiqiyuan1"] = "qixiqifu10",
	["江湖美誉_qixiqiyuan1"] = "qixiqifu11",
	["经脉有成_qixiqiyuan1"] = "qixiqifu12",
	["财源广进_qixiqiyuan2"] = "qixiqifu13",
	["武功有成_qixiqiyuan2"] = "qixiqifu14",
	["花容月貌_qixiqiyuan2"] = "qixiqifu15",
	["精力充沛_qixiqiyuan2"] = "qixiqifu16",
	["绝学招式_qixiqiyuan2"] = "qixiqifu17",
	["上等好酒_qixiqiyuan2"] = "qixiqifu18",
	["神兵利器_qixiqiyuan2"] = "qixiqifu19",
	["美食佳肴_qixiqiyuan2"] = "qixiqifu20",
	["学富五车_qixiqiyuan2"] = "qixiqifu21",
	["师门兴旺_qixiqiyuan2"] = "qixiqifu22",
	["江湖美誉_qixiqiyuan2"] = "qixiqifu23",
	["经脉有成_qixiqiyuan2"] = "qixiqifu24",
	["财源广进_qixiqiyuan3"] = "qixiqifu25",
	["武功有成_qixiqiyuan3"] = "qixiqifu26",
	["花容月貌_qixiqiyuan3"] = "qixiqifu27",
	["精力充沛_qixiqiyuan3"] = "qixiqifu28",
	["绝学招式_qixiqiyuan3"] = "qixiqifu29",
	["上等好酒_qixiqiyuan3"] = "qixiqifu30",
	["神兵利器_qixiqiyuan3"] = "qixiqifu31",
	["美食佳肴_qixiqiyuan3"] = "qixiqifu32",
	["学富五车_qixiqiyuan3"] = "qixiqifu33",
	["师门兴旺_qixiqiyuan3"] = "qixiqifu34",
	["江湖美誉_qixiqiyuan3"] = "qixiqifu35",
	["经脉有成_qixiqiyuan3"] = "qixiqifu36",	
}

--打乱排序
local function selectQiyuan()
	local temp = clone(qiyuanMap)
	local l = #temp
	local tab = {}
	local index = 1
	while #temp ~= 0 do
		local n = math.random(0, #temp)
		if temp[n] ~= nil then
			tab[index] = temp[n]
			table.remove(temp, n)
			index = index + 1
		end
	end
	return tab
end

function ChineseValentineLayer:create()
	local p = ChineseValentineLayer:new()
	p:init()
	return p
end

local btn_paryItems, btn_selectList, textX, textY, textSize
function ChineseValentineLayer:init()
	self._UI = require("Layer/ChineseValentineUI/CVActionQiyuanUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	
	self._isShow = false --控制界面显示
	self._isThinking = false -- 控制刷新时的操作
	
	btn_paryItems = {
		["qixiqiyuan1"] = self.Panel_Pray.Panel_ButtonView.Button_Rough,
		["qixiqiyuan2"] = self.Panel_Pray.Panel_ButtonView.Button_Delicate,
		["qixiqiyuan3"] = self.Panel_Pray.Panel_ButtonView.Button_Special,
	}
	btn_selectList = {
		self.Panel_Pray.Panel_ButtonView.Button_Seclect_0,
		self.Panel_Pray.Panel_ButtonView.Button_Seclect_1,
		self.Panel_Pray.Panel_ButtonView.Button_Seclect_2,
		self.Panel_Pray.Panel_ButtonView.Button_Seclect_3,
	}
	self:setPanelBack()
	self:setClickBtn()
	
	local animOffset = 5
	local interval = 0.111
	local action = cc.RepeatForever:create(
	cc.Sequence:create(
	cc.MoveBy:create(interval, cc.p(0, animOffset + 3)),
	cc.MoveBy:create(interval, cc.p(0, -(animOffset + 3))),
	cc.MoveBy:create(interval, cc.p(0, animOffset)),
	cc.MoveBy:create(interval, cc.p(0, - animOffset)),
	cc.MoveBy:create(interval, cc.p(0, animOffset)),
	cc.MoveBy:create(interval, cc.p(0, - animOffset)),
	cc.MoveBy:create(interval, cc.p(0, animOffset)),
	cc.MoveBy:create(interval, cc.p(0, - animOffset))))
	self.Panel_Pray.Text_Desc:runAction(action)
	
	textX, textY = self.Panel_UseConfirm.Panel_desc.Text_name:getPosition()
	textSize = self.Panel_UseConfirm.Panel_desc.Text_name:getContentSize()
	self.Panel_UseConfirm.Panel_desc.Text_name:setVisible(false)
end


function ChineseValentineLayer:onResume()
	self:showPanelPray()
end

--注册按钮事件
function ChineseValentineLayer:setClickBtn()	
	self.Panel_Pray.Button_Cancel:releaseFunc(function()
		if self._isShow then
			self:showPanelPray()
		else
			PopupLayerController:hideLayer("ChineseValentineLayer", function(layer)
				self:hide(true)
			end)
		end
		
		Audio:playEffect("fanHuiQuXiao")
	end)
	
	self.Panel_UseConfirm.Button_Cancel:releaseFunc(function()
		self.Panel_UseConfirm:setVisible(false)
		Audio:playEffect("fanHuiQuXiao")
	end)
	
	for type, btn in pairs(btn_paryItems) do
		btn:releaseFunc(function()
			self.Panel_Pray.Button_Cancel:setTouchEnabled(false)
			self:clickPrayItem(type)
			Audio:playEffect("xiaoAnNiu")
		end)
	end
	
end

local interval = 0.2
--丝带选择事件
function ChineseValentineLayer:clickPrayItem(type)
	local role = User:getRole()
	--判断背包是否拥有该物品
	local bagItem = role:getItem(type)
	if not bagItem then
		PopText("您没有该道具")
		self.Panel_Pray.Button_Cancel:setTouchEnabled(true)
		return
	end
	
	
	self.Panel_Pray.Text_title:setString("你要祈福什么")
	for k, v in pairs(btn_paryItems) do
		v:setVisible(false)
	end
	self._isShow = true
	local selected = selectQiyuan()
	for k, v in pairs(btn_selectList) do
		local x, y = v:getPosition()
		v:setPosition(993.63 / 2, 586.79 / 2)
		v:setVisible(true)
		v:setTouchEnabled(false)
		v.Text_Name:setString(selected[k].name)
		local action = cc.Sequence:create(
		cc.MoveTo:create(interval, cc.p(x, y)),
		cc.CallFunc:create(function()
			v:setTouchEnabled(true)
			self.Panel_Pray.Button_Refresh:setTouchEnabled(true)
			self.Panel_Pray.Button_Cancel:setTouchEnabled(true)
		end)
		)
		v:runAction(action)
		v:releaseFunc(function()
			self:clickQifuItem(selected[k], type)
		end)
		
	end
	self.Panel_Pray.Button_Refresh:setVisible(true)
	self.Panel_Pray.Button_Refresh:releaseFunc(function()
		self:clickRefresh(type)
		Audio:playEffect("xiaoAnNiu")
	end)
end

--刷新事件
function ChineseValentineLayer:clickRefresh(type)
	self.Panel_Pray.Text_Desc:setVisible(true)
	self.Panel_Pray.Panel_ButtonView:setVisible(false)
	self.Panel_Pray.Button_Refresh:setTouchEnabled(false)
	self.Panel_Pray.Button_Cancel:setTouchEnabled(false)
	self._isThinking = true
	
	local selected = selectQiyuan()
	local action = cc.Sequence:create(
	cc.DelayTime:create(0.7),
	cc.CallFunc:create(function()
		self.Panel_Pray.Text_Desc:setVisible(false)
		self.Panel_Pray.Panel_ButtonView:setVisible(true)
		for k, v in pairs(btn_selectList) do
			local x, y = v:getPosition()
			v:setPosition(993.63 / 2, 586.79 / 2)
			v:setVisible(true)
			v:setTouchEnabled(false)
			v.Text_Name:setString(selected[k].name)
			local action = cc.Sequence:create(
			cc.MoveTo:create(interval, cc.p(x, y)),
			cc.CallFunc:create(function()
				v:setTouchEnabled(true)
				self.Panel_Pray.Button_Refresh:setTouchEnabled(true)
				self.Panel_Pray.Button_Cancel:setTouchEnabled(true)
				self._isThinking = false
			end))
			v:runAction(action)
			v:releaseFunc(function()
				self:clickQifuItem(selected[k], type)
			end)
		end
		
	end))
	
	self.Panel_Pray.Text_Desc:runAction(action)
end


--祈福按钮事件
function ChineseValentineLayer:clickQifuItem(data, type)	
	Audio:playEffect("xiaoAnNiu")
	self.Panel_UseConfirm.Panel_desc:removeAllChildren()
	
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint(0.5, 0.5)
	richTextScroll:setTag(800)
	self.Panel_UseConfirm.Panel_desc:addChild(richTextScroll)
	local pos = cc.p(textX, textY)
	richTextScroll:setPosition(pos)
	richTextScroll:setSize(textSize)
	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
	richTextScroll:getRichText():setVerticalSpace(5)
	richTextScroll:setBounceEnabled(true)
	local textColor = {r = 208, g = 208, b = 208}
	-- richTextScroll:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	local name = "HIY" .. data.name .. "NOR"
	local str = "你确定要选择" .. name .. "进行题字么？"
	richTextScroll:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 60)
	
	self.Panel_UseConfirm:setVisible(true)
	self.Panel_UseConfirm.Button_Confirm:releaseFunc(function()
		local key = data.name .. "_" .. type
		local v = tb_item[key]
		local item = Item:getOneItemByKey(v)
		
		local role = User:getRole()
		local bagItem = role:getItem(type)
		local itemAttr = Item:getOneItemByKey(bagItem.itemId)
		
		if role:checkCanBuyTwoOrMoreThings({[v] = 1}) then
			role:addItemCount(bagItem.itemId, -1)
			role:addItemCount(v, tonumber(1))
			
			PopText("你获得了一个" .. item.name)
			local dataText = data.text
			if data.name == "花容月貌" then
				local sex = role:getAttr("sex")
				local str = ""
				if sex == "男" then
					str = string.gsub(dataText, "$N", "帅哥")
				elseif sex == "女" then
					str = string.gsub(dataText, "$N", "美女")
				end
				
				local text = "CYN你将祈福带交给了张先生，张先生提笔在祈福带上提上了你的愿望“HIY" .. str .. "NOR”。"
				RichPrint("main", text)
			else
				local text = "CYN你将祈福带交给了张先生，张先生提笔在祈福带上提上了你的愿望“HIY" .. data.text .. "NOR”。"
				RichPrint("main", text)
			end
		end
		
		PopupLayerController:hideLayer("ChineseValentineLayer", function(layer)
			self.Panel_UseConfirm:setVisible(false)
			self:hide(true)
			Audio:playEffect("xiaoAnNiu")
		end)
	end)
end


--祈福界面显示
function ChineseValentineLayer:showPanelPray()
	self.Panel_Pray.Text_title:setString("你要用哪条祈福条进行题字")
	self.Panel_Pray.Text_Desc:setVisible(false)
	self.Panel_UseConfirm:setVisible(false)
	self.Panel_Pray.Button_Refresh:setVisible(false)
	self.Panel_Pray.Panel_ButtonView:setVisible(true)
	for _, v in pairs(btn_paryItems) do
		v:setVisible(true)
	end
	for _, v in pairs(btn_selectList) do
		v:setVisible(false)
	end
	self._isShow = false --控制界面显示
	self.Panel_Pray:setVisible(true)
end

--空白地区点击
function ChineseValentineLayer:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		if self._isThinking == true then
			return
		end
		PopupLayerController:hideLayer("ChineseValentineLayer", function(layer)
			self:hide()
		end)
		if func then
			func()
		end
	end)
end


Helper:classDefNodeGetInstance(ChineseValentineLayer)
return ChineseValentineLayer 000000000


local JiangHuYiRenLuLayer = class("JiangHuYiRenLuLayer", cc.Layer)

function JiangHuYiRenLuLayer:create()
	local p = JiangHuYiRenLuLayer:new()
	p:init()
	return p
end

function JiangHuYiRenLuLayer:init()
	local UI = require("Layer/ActionUI/JiangHuYiRenLuUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

	-- 返回按钮
	self.Button_back:releaseFunc(function()
		self:hideLayer()
	end)

	-- 一开始隐藏
	self:setVisible(false)
	
	-- 配置表
	self.data = require("script.others.jianghuyirenlu.lua")["Sheet1"]

	-- 当前兑换序号
	self.index = 1

	-- 兑换总数量
	self.count = 0
	for k,v in pairs(self.data) do
		self.count = self.count + 1
	end
	
	-- 拜见异人的标记
	self.flagName = "baijianyiren"

	-- 兑换的按钮
	self.Button_reward:releaseFunc(function()
		self:getRewards()
	end)

	-- 名帖道具ID
	self.needItemId = "yirenitem1"

	-- 拥有名帖数量
	self.numOfNeed = 0
	self:setTextNum()
	
	--上次活动标记转化
	self:fixFlag()

	-- 初始化界面（数据从配置表获得）
	self:setNowPanelAndNextPanel()
	self:setRewardPanel()
end

function JiangHuYiRenLuLayer:showLayer(actionData, itemData)
    self:setActionDsc(actionData.name, actionData.start, actionData["end"], actionData.desc)
	self.numOfNeed = tonumber(itemData.numbers)
	self:setTextNum()
	self:show()
end

function JiangHuYiRenLuLayer:hideLayer()
    self:hide()
    self:destroyInstance()
end

-- 设置界面的活动描述
function JiangHuYiRenLuLayer:setActionDsc(name, starTime, endTime, desc)
	self.Text_title:setString(name)

	local str = ""
	str = str .. tostring(Helper:date("%m",starTime)).."月"
	str = str .. tostring(Helper:date("%d",starTime)).."日更新后"

	str = str .."~".. tostring(Helper:date("%m",endTime)).."月"
	str = str .. tostring(Helper:date("%d",endTime)).."日期间，"..desc
	self.Text_desc:setString(str)
end

function JiangHuYiRenLuLayer:initPanel(panel)
	local info = self.data[tostring(self.index)]

	panel.Image_face:loadTexture(info.pic)
	panel.Text_name:setString(info.name)
	panel.Text_title:setString(info.title)

	local function setRichText(owner, richTextName, uiText, text, textColor, textAlpha, fontName, fontSize)
		uiText:setString("")

		if owner[richTextName] ~= nil then
			owner[richTextName]:removeFromParent()
		end

		local x, y = uiText:getPosition()
		local size = uiText:getContentSize()

		owner[richTextName] = ExtRichTextScroll:create()
		owner[richTextName]:move(cc.p(x, y))
		owner[richTextName]:setSize(size)
		owner[richTextName]:setAnchorPoint(cc.p(0.5, 0.5))
		owner[richTextName]:setDirection(kCCScrollViewDirectionVertical)
		owner[richTextName]:getRichText():setVerticalSpace(20)
		
		uiText:getParent():addChild(owner[richTextName])

		owner[richTextName]:pushBackText(text, textColor, textAlpha, Resource:getFontPath(fontName), fontSize)
	end

	setRichText(panel, "RichText_intro", panel.Text_intro, info.introText, cc.c3b(255, 255, 255), 255, "default", 30)
end

function JiangHuYiRenLuLayer:setNowPanelAndNextPanel()
    self._nowPanel = self.Panel_kuang.Panel_1
    self._nextPanel = self.Panel_kuang.Panel_2
end

function JiangHuYiRenLuLayer:setRewardPanel(tag)
	if tag == nil then
        self:initPanel(self._nowPanel)
	elseif tag == "left" then
		self._nextPanel:setPosition(-400, 415)
		self:initPanel(self._nextPanel)
	elseif tag == "right" then
		self._nextPanel:setPosition(1200, 415)
        self:initPanel(self._nextPanel)
	end 
	self:createActionByTag(tag)

    self:setLeftButton()
	self:setRightButton()
	self:setRewardButton()
	self:setTextNeed()
	self:setTextNum()
end

function JiangHuYiRenLuLayer:createActionByTag(tag)
	self.Panel_right:setTouchEnabled(false)
	self.Panel_left:setTouchEnabled(false)
	local movePos 
	if tag == "left" then
		movePos = cc.p(1200, 415)
	elseif tag == "right" then
		movePos = cc.p(-400, 415)
	else
		self.Panel_right:setTouchEnabled(true)
		self.Panel_left:setTouchEnabled(true)
		return 
	end
	local time = 0.5
	local action = nil

	if false then
		action = cc.Sequence:create(cc.Spawn:create(cc.CallFunc:create(function()
			self._nowPanel:runAction(cc.MoveTo:create(time, movePos))
		end),cc.CallFunc:create(function()
			self._nextPanel:runAction(cc.MoveTo:create(time, cc.p(400, 415)) )
		end)),cc.CallFunc:create(function()
        	local tmpPanel = self._nextPanel
        	self._nextPanel = self._nowPanel
        	self._nowPanel = tmpPanel
		end))

	else
		action = cc.Sequence:create(cc.Spawn:create(cc.CallFunc:create(function()
				self._nowPanel:runActionWithName("move", 
					YXEaseAction:create( cc.Spawn:create(
							cc.MoveTo:create(time, movePos) ,
							cc.FadeOut:create(time)
						),  Expo_EaseOut ) )
	        end),cc.CallFunc:create(function()

				self._nextPanel:runActionWithName("move", 
					YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(time, cc.p(400, 415)) ,
						cc.FadeIn:create(time)
					),  Expo_EaseIn ) )

	        end)),cc.CallFunc:create(function()
	        	local tmpPanel = self._nextPanel
	        	self._nextPanel = self._nowPanel
	        	self._nowPanel = tmpPanel
	        end)

		)
	end
	self:runActionWithName("move", action)
	self:delayFunc(time,function()
		self.Panel_right:setTouchEnabled(true)
		self.Panel_left:setTouchEnabled(true)
	end)
end

function JiangHuYiRenLuLayer:setLeftButton()
	if self.index <= 1 then
		self.Panel_left:releaseFunc(function()
		end)
	else
		self.Panel_left:releaseFunc(function()
            self.index = self.index - 1
			self:setRewardPanel("left")
		end)
	end
end

function JiangHuYiRenLuLayer:setRightButton()
	if self.index >= self.count then
		self.Panel_right:releaseFunc(function()
		end)
	else
		self.Panel_right:releaseFunc(function()
            self.index = self.index + 1
			self:setRewardPanel("right")
		end)
	end
end

function JiangHuYiRenLuLayer:setRewardButton()
	local records = User:getRole():getInheritFlag(self.flagName)
	if MapIsEmpty(records) == false and records[self.data[tostring(self.index)].mianju] == true then
		self.Button_reward:setEnabled(false)
		self.Button_reward.Text_buttonName:setString("已拜会")
	else
		self.Button_reward:setEnabled(true)
		self.Button_reward.Text_buttonName:setString("拜会")
	end
end

function JiangHuYiRenLuLayer:setTextNeed()
	local info = self.data[tostring(self.index)]
	self.Panel_text1.Text_need:setString(tostring(info.need))
end

function JiangHuYiRenLuLayer:setTextNum()
	self.Panel_text2.Text_num:setString(tostring(self.numOfNeed))
end

--领取奖励
function JiangHuYiRenLuLayer:getRewards()
	local info = self.data[tostring(self.index)]
	local role = User:getRole()
	
	-- 检查条件
	local function CheckCondition()
		local items = role:getAttr("items")
		if role:getAttr("weight") - #items < 1 then
			PopText("背包剩余容量不足" .. 1)
			return false
		end
	
		if self.numOfNeed < tonumber(info.need) then
			PopText("你没有足够的异人名帖！")
			return false
		end
		
		local records = User:getRole():getInheritFlag(self.flagName)
		if MapIsEmpty(records) == false and records[self.data[tostring(self.index)].mianju] == true then
			PopText("你已经拜见过了！")
			return false
		end

		return true
	end

	if CheckCondition() == false then
		return
	end

	-- 弹窗确认
	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
	local dialog = DialogALayer:getInstance()
	dialog:hide()
	local str1 = "是否要花费" .. tostring(info.need) .. "张异人名帖拜会【" .. tostring(info.title) .. "】" .. tostring(info.name) .. "？"
	local str2 = "是否要花费YEL" .. tostring(info.need) .. "NOR张异人名帖拜会【" .. tostring(info.title) .. "】" .. tostring(info.name) .. "？"
	dialog:show(str1)
	dialog:setRichText(str2)
	dialog:setBack(false)
	dialog:setButton2("取消",function()
	end)
	dialog:setButton1("确定",function()
		-- 检查条件
		if CheckCondition() == false then
			return
		end

		self:guard(info, function()
			-- 设置标记
			local records = User:getRole():getInheritFlag(self.flagName)
			if records == nil or type(records) ~= "table" then
				records = {}
			end
			records[info.mianju] = true
			User:getRole():setInheritFlag(self.flagName, records)
			
			-- 给面具
			role:addItemCount(info.mianju, 1)

			-- 更新剩余名帖数量
			self.numOfNeed = self.numOfNeed - tonumber(info.need)
			self:setTextNum()

			-- 更新按钮状态
			self:setRewardButton()

			-- 弹出答谢界面
			self:showThankDialog(info)
		end)
	end)
end

-- 防作弊
function JiangHuYiRenLuLayer:guard(info, successCallback)
	HttpManagerEx:detectionGoods(self.needItemId, function(status, errcode, errmsg, data)
		if DEBUG_MODE == 1 then
			print("获取名帖数量的服务端返回信息：")
			print("状态：", status)
			print("错误码：", errcode)
			print("错误信息：", errmsg)
			print("data：")
			Helper:print_lua_table(data)
		end
		if status == 200 then
			if errcode == 0 then
				if tonumber(data.numbers) < tonumber(info.need) then
					PopText("你没有足够的异人名帖！")
				else
					HttpManagerEx:checkItemIsCanUse(self.needItemId, info.need, function(status, errcode, errmsg, data)
						if DEBUG_MODE == 1 then
							print("扣除名帖的服务端返回信息：")
							print("状态：", status)
							print("错误码：", errcode)
							print("错误信息：", errmsg)
							print("data：")
							Helper:print_lua_table(data)
						end
						if status == 200 then
							if errcode == 0 then
								successCallback()
							else
								PopText(errmsg)
							end
						else
							PopText(errmsg)
						end
					end, IS_SHOW_WAITING)
				end
			else
				PopText(errmsg)
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

function JiangHuYiRenLuLayer:showThankDialog(info)
	PopupLayerController:showLayer(
		"TextAnimLayer",
		function(layer)
			layer:setAfterAnimCallback(
				function()
					PopText("获得 " .. Item:getOneItemByKey(info.mianju).name .. " x " .. 1)
				end
			)
			layer:showLayer(info.thankText)
		end
	)
end

function JiangHuYiRenLuLayer:fixFlag()
	local records = User:getRole():getInheritFlag("baijianyiren")
	
	if records == 0 then
		return
	end

	local lastActivity_mianju = {
		["1"] = "mianju1074",
		["2"] = "mianju1015",
		["3"] = "mianju1084",
		["4"] = "mianju1065",
		["5"] = "mianju1019",
	}
	for k,v in pairs(lastActivity_mianju) do
		if records[k] then
			records[v] = true
			records[k] = nil
		end
	end
end

Helper:classDefNodeGetInstance(JiangHuYiRenLuLayer)
return JiangHuYiRenLuLayer000000000
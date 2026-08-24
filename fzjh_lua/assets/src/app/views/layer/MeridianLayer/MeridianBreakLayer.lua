-- 冲穴界面
local MeridianBreakLayer = class("MeridianBreakLayer", LayerEx)
local Meridian = require("app.models.Meridian.Meridian")

local resPath =
{
	point1 = "Image/UI/MeridianUI/point1.png",
	point2 = "Image/UI/MeridianUI/point2.png",
	point3 = "Image/UI/MeridianUI/point3.png",
	select1 = "Image/UI/MeridianUI/select1.png",
	select2 = "Image/UI/MeridianUI/select2.png",
	select3 = "Image/UI/MeridianUI/select3.png",
	line1 = "Image/UI/MeridianUI/hui1.png",
	line2 = "Image/UI/MeridianUI/lan1.png",
	line3 = "Image/UI/MeridianUI/huang1.png",
	heidi = "Image/UI/MeridianUI/heidi.png",
	chongxue = "Image/UI/AttrUI/xiaoanniu2.png",
	guben = "Image/UI/MeridianUI/guben.png",
	peiyuan = "Image/UI/MeridianUI/peiyuan.png",
	pingfu = "Image/UI/MeridianUI/pingfu.png",
	zhiliao = "Image/UI/MeridianUI/zhiliao.png",
}

function MeridianBreakLayer:create()
	local p = MeridianBreakLayer:new()
	p:init()
	return p
end

function MeridianBreakLayer:init()
	self._UI = require("Layer/MeridianUI/MeridianBreakUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	-- 选中的穴道
	self.selectPoint = nil
	self.selectAcupointIndex = 0

	self.meridianIndex = 1

--------------------------------------------------------
	-- 冲穴动画效果 add by ZhangShengTang 2017/07/01 10:32:06
	-- 当前穴位状态
	self.currState = 0

	-- 按钮时间
	self.touchTime = nil

	-- 计算时间
	self.caleTime = nil

	--
	self.touchState = nil

	-- 当前按下时需要的真气数量
	self.totalVal = 0

	-- 一个标记，处理文本
	self.textFlag = false
--------------------------------------------------------

	self:setButton()
	self:initRichText()

	-- self._handle = self:schedule(function (ft)
	-- 	self:update(ft)
	-- end,1/30)
end

function MeridianBreakLayer:onResume()
	self.Panel_action:setVisible(false)
	local TitleLayer = MainControllLayer:getLayer("TitleLayer")
	TitleLayer:setTouchEnabled(true)
end

-- 初始化输出框
function MeridianBreakLayer:initRichText()
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

function MeridianBreakLayer:print(str, fontSize, verticalSpace)
	if str == "" then
		return
	end
	if fontSize == nil then
		fontSize = 36
	end
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), fontSize)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end

-- 初始化输出框
function MeridianBreakLayer:initAttrRichText()
	local x, y = self.Image_kuang.layout_text:getPosition()
	local size = self.Image_kuang.layout_text:getContentSize()

	if self.RichText_printAttr then
		self.RichText_printAttr:removeFromParent()
		self.RichText_printAttr = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Image_kuang.layout_text:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Image_kuang.layout_text:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_printAttr = richTextScroll

   	self.RichText_printAttr:setBounceEnabled(false)
end

function MeridianBreakLayer:printAttr(str, fontSize, verticalSpace)
	if str == "" then
		return
	end
	if fontSize == nil then
		fontSize = 36
	end
	local textColor = cc.c3b(255,255,255)
	local textHeight = self.RichText_printAttr:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initRichText()
	end

	self.RichText_printAttr:pushBackText(str, textColor, 255, Resource:getFontPath("HYCFS"), fontSize)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_printAttr:pushBackNewLine(verticalSpace)
	else
		self.RichText_printAttr:pushBackNewLine()
	end
end

-- 创建穴位列表
function MeridianBreakLayer:createAcupointList(index)
	local role = User:getRole()
	local meridian = role:getAttr("meridian")

	--@region 
	--@desc 修复存档出错导致界面出错无法冲穴的情况
	local meridianCount = meridian.meridianCount
	local count = 0
	for i,v in ipairs(meridian.attrList) do
		if v.meridianIndex == meridianCount + 1 then
			count = count + 1
		end
	end
	
	if meridian.acupointCount ~= count then
		meridian.acupointCount = count
	end
	--@endregion

	if index then
		self.meridianIndex = index
	else
		index = self.meridianIndex
	end

	self.ListView_acupointList:removeAllItems()

	self.selectPoint = nil
	self.selectAcupointIndex = 0

	-- 获取所选经脉所有穴道
	local acupointData = Meridian:getAcupointList(index)

	if MapIsEmpty(acupointData) == true then
		return
	end

	self.Text_zhenqi_num:setString(math.floor(role:getAttr("breathVal")))

	-- 自定义穴道位置
	-- local pos = {}
	-- local topY = (#acupointData + 1) * 200
	-- for i,v in ipairs(acupointData) do
	-- 	table.insert(pos, cc.p( math.random(225, 425), topY - i * 200))
	-- end

	local pos = {}
	for i,v in ipairs(acupointData) do
		table.insert(pos, cc.p(v.posX, v.posY))
	end

	-- 7,269
	local lineWidth = 7
	local lineHeight = 269

	local panel = self.Panel_acupoint:clone()
	panel:setSize({width = 650, height = pos[1].y + 50})
	self.ListView_acupointList:pushBackCustomItem(panel)

	local lastLine = nil

	for i,v in ipairs(acupointData) do
		-- state 1 未激活 1 待冲穴 2 待固本 3 完成
		local state = 0
		if meridian.meridianCount >= index then
			state = 3
		elseif meridian.meridianCount + 1 == index then
			if meridian.acupointCount == i and meridian.acupointState == 7 then
				state = 7
			elseif meridian.acupointCount >= i then
				state = 3
			elseif meridian.acupointCount + 1 == i then
				state = meridian.acupointState
			else
				state = 0
			end
		end

		-- 穴道点图片资源
		local pointRes = resPath["point2"]
		local selectRes = resPath["select2"]
		if state == 0 then
			pointRes = resPath["point1"]
			selectRes = resPath["select1"]
		elseif state == 3 then
			pointRes = resPath["point3"]
			selectRes = resPath["select3"]
		end
		local Image_point = self:createImage(pos[i], 3, pointRes, panel)
		local Image_select = self:createImage(pos[i], 2, selectRes, panel)
		Image_select:setVisible(false)

		local offset = 125
		if pos[i].x < 325 then
			offset = - 125
		end
		local Image_textdi = self:createImage(cc.p(pos[i].x + offset, pos[i].y), 1, resPath["heidi"], panel)
		local color = {r = 42, g = 179, b = 178}
		if state == 3 then
			color = {r = 219, g = 187, b = 57}
		elseif state == 0 then
			color = {r = 137, g = 137, b = 137}
		end
		local text = self:createText(cc.p(pos[i].x + offset, pos[i].y), 2, v.name, color, panel)

		-- 连线
		if lastLine and state ~= 0 then
			lastLine:loadTexture(resPath["line3"])
		end
		if i < #pos then
			local Image_line = ccui.ImageView:create()
			Image_line:loadTexture(resPath["line1"])
			if state == 1 or state == 2 or state == 4 or state == 5 then
				Image_line:loadTexture(resPath["line2"])
			end
			lastLine = Image_line
			-- 计算两点距离
			local z = math.sqrt(((pos[i].x - pos[i + 1].x) * (pos[i].x - pos[i + 1].x)) + ((pos[i].y - pos[i + 1].y) * (pos[i].y - pos[i + 1].y)))
			Image_line:setScaleY(z / 269)

			Image_line:setAnchorPoint(cc.p(0.5, 1))
			Image_line:setPosition(pos[i])

			-- 计算角度
			local skew = math.deg(math.acos(math.abs(pos[i].y - pos[i + 1].y) / z))
			if pos[i].x < pos[i + 1].x then
				skew = skew * -1
			elseif pos[i].x == pos[i + 1].x then
				skew = 0
			end

			-- 角度处理
			if pos[i + 1].y > pos[i].y then
				skew = 180 - skew
			end

			Image_line:setRotationSkewX(skew)
			Image_line:setRotationSkewY(skew)
			panel:addChild(Image_line, 1)
		end

		local function selectAcupoint()
			if self.selectPoint == Image_select then
				return
			end

			if state == 0 then
				return
			end

			if self.selectPoint ~= nil then
				self.selectPoint:setVisible(false)
			end
			self.Text_MeridianName:setString(v.name)

			self.selectPoint = Image_select
			self.selectAcupointIndex = i
			self.selectPoint:setVisible(true)

			self.Button_action:setVisible(true)
			self.Text_consume:setString("")
			local outlineWidth = 5
			local outlineColor = cc.c4b(85, 97, 97, 255)
			self.Button_action:setTouchAnimEnabled(true)
			if state == 0 then
			elseif state == 1 then
				self.Button_action.Text_buttonName:setString("冲\n穴")
				local zhengqi = math.ceil(Meridian:getAcupointBreakBreathVal(self.meridianIndex, i) - role:getFlag("冲穴真气"))
				self.Text_consume:setString("需要真气" .. zhengqi)
				self.Text_MeridianDesc:setString("BLK这个穴位现在是闭合状态，需注入真气将其冲开。")
				self.Text_MeridianDesc:enableOutline(outlineColor, outlineWidth)
				self.Button_action:loadTextureNormal(resPath["chongxue"])
				self.Button_action:setTouchAnimEnabled(false)
			elseif state == 2 then
				self.Button_action.Text_buttonName:setString("固\n本")
				self.Text_consume:setString("需要潜能" .. Meridian:getAcupointBreakPot(self.meridianIndex, i))
				self.Text_MeridianDesc:setString("HIC这个穴位已经冲开了，是时候进行固本了。")
				outlineColor = cc.c4b(17, 18, 18, 255)
				self.Text_MeridianDesc:enableOutline(outlineColor, outlineWidth)
				self.Button_action:loadTextureNormal(resPath["guben"])
			elseif state == 3 then
				self.Button_action:setVisible(false)
				self.Text_MeridianDesc:setString("YEL这个穴位已经固本完成了。")
				outlineColor = cc.c4b(17, 18, 18, 255)
				self.Text_MeridianDesc:enableOutline(outlineColor, outlineWidth)
			elseif state == 4 then
				self.Button_action.Text_buttonName:setString("治\n疗")
				self.Text_MeridianDesc:setString("RED这个穴位有暗疾，需要先治疗，方可进行冲穴。")
				outlineColor = cc.c4b(17, 18, 18, 255)
				self.Text_MeridianDesc:enableOutline(outlineColor, outlineWidth)
				self.Button_action:loadTextureNormal(resPath["zhiliao"])
			elseif state == 5 then
				self.Button_action.Text_buttonName:setString("平\n复")
				self.Text_MeridianDesc:setString("RED现在真气有些紊乱，没法正常冲穴。")
				outlineColor = cc.c4b(17, 18, 18, 255)
				self.Text_MeridianDesc:enableOutline(outlineColor, outlineWidth)
				self.Button_action:loadTextureNormal(resPath["pingfu"])
			elseif state == 7 then
				self.Button_action.Text_buttonName:setString("培\n元")
				self.Text_MeridianDesc:setString("BLK这条经脉已经培养完成了。现在可以培元了。")
				self.Text_MeridianDesc:enableOutline(outlineColor, outlineWidth)
				self.Button_action:loadTextureNormal(resPath["peiyuan"])
			end

			self.Button_action:setScale(0.5)
				self.Button_action:runAction(
					cc.Sequence:create(
						cc.ScaleTo:create(0.2, 1, 1)
					)
				)

			self.currState = state


			local half = (375 / (pos[1].y + 50)) * 100
			local percent = ( 1 - ( ( pos[i].y - 375 ) / ( pos[1].y + 50 - 750 ) ) )  * 100
			if percent < half then
				percent = 0
			elseif percent > 100 - half then
				percent = 100
			end

			if percent < 0 then
				percent = 0
			elseif percent > 100 then
				percent = 100
			end
			-- print("half = " .. half)
			-- print("pos[i].y = " .. pos[i].y)
			-- print("pos[1].y = " .. pos[1].y + 50)
			-- print("percent = " .. percent)
			self.ListView_acupointList:jumpToPercentVertical(percent)
		end

		Image_point:releaseFunc(function()
			selectAcupoint()
		end)

		Image_textdi:releaseFunc(function()
			selectAcupoint()
		end)

		if (state == 1 or state == 2 or state == 4 or state == 5) or self.selectPoint == nil and i == #acupointData then
			selectAcupoint()
		end
	end
end

-- 显示穴位属性数据
function MeridianBreakLayer:showAttrData()
	self:initAttrRichText()

	local role = User:getRole()
	local meridian = role:getAttr("meridian")

	-- 经脉属性列表
	local attrList =
	{
		[1] = "qiMax", 			-- 气血上限
		[2] = "neiLiLimit", 	-- 内力上限
		[3] = "atk", 			-- 攻击力
		[4] = "dodge", 			-- 闪躲力
		[5] = "def", 			-- 防御力
		[6] = "damage", 		-- 伤害力
		[7] = "protect",		-- 防护力
	}

	local attrDesc =
	{
		["qiMax"] = "气血上限", 		-- 气血上限
		["neiLiLimit"] = "内力上限",	-- 内力上限
		["atk"] = "攻击力",			-- 攻击力
		["dodge"] = "闪躲力",			-- 闪躲力
		["def"] = "防御力",			-- 防御力
		["damage"] = "伤害力",		-- 伤害力
		["protect"] = "防护力",		-- 防护力
	}

	self:printAttr("YEL累计增加\n ", 48)

	for i,v in ipairs(attrList) do
		if meridian.attrTotal[v] > 0 then -- 219 187 57
			local str = "DWT" .. attrDesc[v] .. "+YELL" .. meridian.attrTotal[v]
			self:printAttr(str, 40)
		end
	end
end

function MeridianBreakLayer:createImage(pos, zorder, resPath, parent)
	local image = ccui.ImageView:create()
	image:setTouchEnabled(true)
	image:loadTexture(resPath)
	image:setAnchorPoint(cc.p(0.5, 0.5))
	image:setPosition(pos)
	parent:addChild(image, zorder)
	return image
end

function MeridianBreakLayer:createText(pos, zorder, desc, color, parent)
	local text = ccui.Text:create()
	text:setTextAreaSize({width = 0, height = 0})
	text:setFontName("Font/HYCFS.ttf")
	text:setFontSize(42)
	text:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
	text:setTextColor(color)
	text:setString(desc)
	text:setAnchorPoint(cc.p(0.5, 0.5))
	text:setPosition(pos)
	parent:addChild(text, zorder)
	return text
end

-- 冲穴
function MeridianBreakLayer:setButton()
	self.Button_action:releaseFuncTotally(
		function()
			Audio:playEffect("xiaoAnNiu")
			-- beganFunc
			local TitleLayer = MainControllLayer:getLayer("TitleLayer")
			TitleLayer:setTouchEnabled(false)
			self.Panel_action:setVisible(true)
			self:beganBreak()
		end,
		function()
			-- endedFunc
			self:delayFunc(0.21, function()
				self.Panel_action:setVisible(false)
				local TitleLayer = MainControllLayer:getLayer("TitleLayer")
				TitleLayer:setTouchEnabled(true)
			end)
			if self._handle ~= nil then
				self:unschedule(self._handle)
				self._handle = nil
			end

			if self.touchState ~= nil then
				self:stopAnimation()
				-- 真气未注入满
				if self.touchState == 1 then
					self:print("HIW你取消了注入真气。")
					PopText("取消注入")
					self:delayFunc(0.1, function()
						Audio:stopAllEffects()
					end)
				elseif self.touchState == 2 then
					self:print("HIW你停止了注入真气。")
					PopText("停止注入")
					self:delayFunc(0.1, function()
						Audio:stopAllEffects()
					end)
				elseif self.touchState == 3 then
					self:delayFunc(0.1, function()
						Audio:stopAllEffects()
					end)
				end
				self.touchState = nil
				return
			end
			if self.currState ~= 1 then
				local flag = Meridian:acupointBreak(self.meridianIndex, self.selectAcupointIndex, function(str)
					if str then
						self:print(str)

						self:showAttrData()
						self:createAcupointList()
					end
				end)
			end
		end,
		function()
			-- canceledFunc
			self:delayFunc(0.21, function()
				self.Panel_action:setVisible(false)
				local TitleLayer = MainControllLayer:getLayer("TitleLayer")
				TitleLayer:setTouchEnabled(true)
			end)
			if self._handle ~= nil then
				self:unschedule(self._handle)
				self._handle = nil
			end

			if self.touchState ~= nil then
				self:stopAnimation()
				-- 真气未注入满
				if self.touchState == 1 then
					self:print("HIW你取消了注入真气。")
					PopText("取消注入")
					self:delayFunc(0.1, function()
						Audio:stopAllEffects()
					end)
				elseif self.touchState == 2 then
					self:print("HIW你停止了注入真气。")
					PopText("停止注入")
					self:delayFunc(0.1, function()
						Audio:stopAllEffects()
					end)
				elseif self.touchState == 3 then
					self:delayFunc(0.1, function()
						Audio:stopAllEffects()
					end)
				end
				self.touchState = nil
				return
			end
		end
	)
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/07/01 10:40:09
-- @desc 开始点击冲穴
function MeridianBreakLayer:beganBreak()
	if self.currState == 1 and self.touchState == nil then
		local role = User:getRole()
		local Acupoint = Meridian:getAcupoint(self.meridianIndex, self.selectAcupointIndex)
		if role:getAttr("breathVal") <= 0 then
			PopText("没有真气！")
			return
		end

		-- 更新剩余时间
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

		self._handle = self:schedule(function (ft)
			self:update(ft)
		end,1/10)

		self:showAnimation()
		self.touchTime = GetTime()
		self.touchState = 2

		self.textFlag = false

		-- 冲穴所需时间
		self.needTime = 3
		-- 当前所需真气值
		local currNeedBV = Meridian:getAcupointBreakBreathVal(self.meridianIndex, self.selectAcupointIndex) - role:getFlag("冲穴真气")
		if currNeedBV > 30000 then
			self.needTime = 10
		elseif currNeedBV > 25000 then
			self.needTime = 8
		elseif currNeedBV > 20000 then
			self.needTime = 6
		elseif currNeedBV > 15000 then
			self.needTime = 5
		elseif currNeedBV > 10000 then
			self.needTime = 4
		end
		self.currNeedBV = currNeedBV
		local color = Meridian:getAcupointColor(self.meridianIndex, self.selectAcupointIndex)
		self:print("HIC你尝试着导引体内的真气，注入" .. color .. Meridian:getAcupointName(self.meridianIndex, self.selectAcupointIndex))
		self:update()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/07/01 10:19:21
-- @desc 穴位动画
function MeridianBreakLayer:showAnimation()
	if self.selectPoint then
		self.selectPoint:runAction(
			cc.RepeatForever:create(
				cc.Sequence:create(
					cc.ScaleTo:create(0.5 , 2 , 2 ),
					cc.ScaleTo:create(0.5 , 1 , 1 )
				)
			)
		)
	end


	self.Button_action:runAction(
		cc.RepeatForever:create(
			cc.Sequence:create(
				cc.RotateBy:create(2, 360)
			)
		)
	)
	self.Button_action.Text_buttonName:setVisible(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/07/01 10:26:34
-- @desc 停止动画
function MeridianBreakLayer:stopAnimation()
	if self.selectPoint then
		self.selectPoint:setScale(1.0)
		self.selectPoint:stopAllActions()
	end

	self.Button_action:setScale(1)
	self.Button_action:stopAllActions()
	self.Button_action:setRotationSkewX(0)
	self.Button_action:setRotationSkewY(0)
	self.Button_action.Text_buttonName:setVisible(true)
end

function MeridianBreakLayer:refreshUI()
	local role = User:getRole()
	local zhengqi = math.floor(Meridian:getAcupointBreakBreathVal(self.meridianIndex, self.selectAcupointIndex) - role:getFlag("冲穴真气"))
	self.Text_consume:setString("需要真气" .. zhengqi)
	self.Text_zhenqi_num:setString(math.floor(role:getAttr("breathVal")))
end

function MeridianBreakLayer:update()
	local currTime = GetTime()
	-- state 1 不扣真气 2 开始扣真气 3 真气不足 4 完成
	if self.touchState ~= 4 then
		local time = currTime - self.touchTime
		if true then
			if self.textFlag == false then
				self.caleTime = GetTime()
				self:print("HIC你体内的真气在快速消耗中。")
				self.textFlag = true
				Audio:playEffect("meridianBreaking", true)
			end
			local role = User:getRole()
			local breathVal = role:getAttr("breathVal")
			-- 已经注入的真气
			local surplusBreathVal = Meridian:getAcupointBreakBreathVal(self.meridianIndex, self.selectAcupointIndex) - role:getFlag("冲穴真气")
			-- 所需真气少于等于1500，每秒扣减真气500
			-- 所需真气大于1500、少于等于6000，每秒扣减真气2000
			-- 所需真气大于6000，少于等于15000，每秒扣减真气3000
			-- 所需真气大于15000，每秒扣减真气5000
			-- 真气为0，立即停止跳数字
			-- 真气可以分多次注入
			local value = self.currNeedBV / (self.needTime)
			value = value * ( (self.needTime + time * 2) / self.needTime)

			-- 本次扣除的真气
			local interval = currTime - self.caleTime
			local subBreathVal = math.ceil(interval * value)
			-- print("value = " .. value)
			-- print("subBreathVal = " .. subBreathVal)
			-- print("surplusBreathVal = " .. surplusBreathVal)

			-- 真气到达要求 开始冲穴
			if subBreathVal >= surplusBreathVal then
				subBreathVal = surplusBreathVal
				self.touchState = 4
			end

			if breathVal < subBreathVal then
				-- 停止刷新
				if self._handle ~= nil then
					self:unschedule(self._handle)
					self._handle = nil
				end
				self.Panel_action:setVisible(false)

				subBreathVal = breathVal
				self.touchState = 3
				self:print("HIW你停止了注入真气。")
				PopText("没有真气！")
				self:stopAnimation()
				Audio:stopAllEffects()
			end
			role:setFlag("冲穴真气", role:getFlag("冲穴真气") + subBreathVal)
			role:addAttr("breathVal", - subBreathVal)

			self.caleTime = GetTime()
			self:refreshUI()

			if self.touchState == 4 then
				role:setFlag("冲穴真气", 0)

				-- 停止刷新
				if self._handle ~= nil then
					self:unschedule(self._handle)
					self._handle = nil
				end
				self.Panel_action:setVisible(false)
				self:stopAnimation()

				local flag = Meridian:acupointBreak(self.meridianIndex, self.selectAcupointIndex, function(str)
					if str then
						self:print(str)

						self:showAttrData()
						self:createAcupointList()
					end
				end)


			end
		end
	end
end

Helper:classDefNodeGetInstance(MeridianBreakLayer)

return MeridianBreakLayer000000000
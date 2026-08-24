local  ShenBingMainLayer = class("ShenBingMainLayer",cc.Layer)

function ShenBingMainLayer:create()
	local p = ShenBingMainLayer:new()
	p:init()
	return p
end

function ShenBingMainLayer:init()
	self._UI = require("Layer/ShenBing/ShenBingUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setVisible(false)
	self:initRichText()
	self:ButtonBack()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:19:38
-- @desc 界面入口
function ShenBingMainLayer:showLayer()
	self:setLayerNPC()
	self:setNeiLiAndGold()
	self:show()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 15:51:49
-- @desc 界面中的NPC
function ShenBingMainLayer:setLayerNPC()
	local flag = true  --剧情标记
	--铁匠
	self.Button_1:setButtonType(WIDGET_TOUCH_VOICE_SMALLBUTTON)
	self.Button_1.Text_buttonName:setString("铁匠")
	self.Button_1:releaseFunc(function()
		PopupLayerController:showLayer("ShenBingMainObserveLayer", function(layer)
			layer:show(MainControllLayer,1,flag)
		end)
	end)

	if flag == true or flag == 1 then
		--锻造炉
		self.Button_2:setVisible(true)
		self.Button_2.Text_buttonName:setString("锻造炉")
		self.Button_2:releaseFunc(function()
			self:print("这是锻造炉")
		PopupLayerController:showLayer("ShenBingMainObserveLayer", function(layer)
			layer:show(MainControllLayer,2,true)
		end)
		end)

		--玄兵洞
		self.Button_3:setVisible(true)
		self.Button_3.Text_buttonName:setString("玄兵洞")
		self.Button_3:releaseFunc(function()
			self:print("这是玄兵洞")
		end)

		--藏衣室
		self.Button_4:setVisible(true)
		self.Button_4.Text_buttonName:setString("藏衣室")
		self.Button_4:releaseFunc(function()
			self:print("这是藏衣室")
		end)
	else
		self.Button_2:setVisible(false)
		self.Button_3:setVisible(false)
		self.Button_4:setVisible(false)
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:19:14
-- @desc 设置内力和金钱数值
function ShenBingMainLayer:setNeiLiAndGold()
	local role = User:getRole()
	local neili,neiliMax = math.ceil(role:getAttr("neili")),math.ceil(role:getFinalAttr("neiliMax"))
	local gold = role: getAttr("gold")
	self.Text_NeiLi:setString("『内力』"..tostring(neili).."/"..tostring(neiliMax))
	self.Text_Gold:setString("『黄金』"..tostring(gold))
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 16:19:21
-- @desc 返回按钮
function ShenBingMainLayer:ButtonBack()
	self.Image_titleShenBing.Button_back:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BACKBUTTON)
	self.Image_titleShenBing.Button_back:releaseFunc(function()
		self:hide()
	end)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 15:54:45
-- @desc 初始化RichText
function ShenBingMainLayer:initRichText()
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
function ShenBingMainLayer:print(str, verticalSpace)
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

-- ---进入界面播放声音
function ShenBingMainLayer:playEffectEnter()
	Audio:playEffect("jinrujiemian")
	self:delayFunc(0.5,function()
		Audio:playEffect("jinrujiemian")
	end)
	self:delayFunc(1.5,function()
		Audio:playEffect("jinrujiemian")
	end)
end
Helper:classDefNodeGetInstance(ShenBingMainLayer)
return  ShenBingMainLayer
00000000000
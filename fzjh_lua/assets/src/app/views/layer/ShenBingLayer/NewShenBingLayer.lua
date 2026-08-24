--新神兵页面， 铁匠取代欧冶子，但是功能只有 锻造，交谈，修理，淬炼
local  DialogUseLayer = require("app.views.layer.ShenBingLayer.DialogUseLayer")
local Item = require("app.models.item.Item")

local  NewShenBingLayer = class("NewShenBingLayer",cc.Layer)


function NewShenBingLayer:create()
	local p = NewShenBingLayer:new()
	p:init()
	return p
end

function NewShenBingLayer:init()
	self._UI = require("Layer/ShenBing/NewShenBingUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self.Sprite_background:setVisible(false)
	self.Sprite_bottom:setVisible(false)
	self.Button_duanzaolu:setVisible(false)
	self.Button_xuanbing:setVisible(false)
	self.Button_cangyi:setVisible(false)
	
	self:initRichText()
	--初始化调用函数
	self:ButtonBack()
	self:ButtonTeJiang()
	self:ButtonXuanbing()
	self:ButtonDuanZhaoLu()
	self:setChangeWeaponFunc()
	self:setAddShenBingNumLimitFunc()
	
	self:setBtnCondition(true)

	self:update()
	self:schedule(function(ft)
		self:update(ft)
	end, 1)


	-- --如果没有onlyId，生成一个onlyId
	-- local role = User:getRole()
	-- if role.shenBingweapon.onlyId == nil then
	-- 	role.shenBingweapon.onlyId = User:getRoleAttr("userid")..role:getItemOnlyId()
	-- 	print("----role.shenBingweapon.onlyId---------------------"..tostring(role.shenBingweapon.onlyId))
	-- end
end

local function setBtnCanClick(cond,text)
	if cond == nil then
		cond = true
	end
	return function(self)
		if cond == false then
			PopText(text)
		end
		return cond
	end
end

local textTalk =
{

	[1] = "HIC前方一个巨大的炉子前站着一位长髯老者正看着炉火想着什么心事。\n旁边几个彪形大汉正挥舞着锤头敲打着一块似乎总也烧不红的什么金属。\n旁边仔细的放着几把刚刚出炉的兵器。那种骇人的杀气竟是从这些兵器上散发出来的。"

}

-- 身上神兵界面控制隐藏 当前装备界面
function NewShenBingLayer:isShow()
	local role = User:getRole()
	if role:getInheritFlag("开始神兵任务") ~= 2 then 
		self.Panel_DuanZaoZhong:setVisible(false)
		return
	end
	local items = role:getItems(function(item)
			if item.type == "神兵" then
				return true
			end
	end)

	if MapIsEmpty(items) == false then
		self.Panel_DuanZaoZhong:setVisible(true)

		local num = #items
		self:setWeaponNumDesc("携带神兵数量：".. tostring(num).."/"..tostring(role:getAttr("bagShenBingNumLimit")))

		local wepaon = role:getDefaultShenBing()
		if wepaon then
			self:setWeaponName(wepaon.nameColor..wepaon.name)
		else
			self:setWeaponName("DWT无")
		end
	else
		self.Panel_DuanZaoZhong:setVisible(false)
	end
end

local beginPrintTalkTextNum
function NewShenBingLayer:onResume()
	if User:getRole():getInheritFlag("开始神兵任务") ==2 then
		self.Button_duanzaolu:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
		self.Button_duanzaolu:setVisible(true)
		self.Button_xuanbing:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
		self.Button_xuanbing:setVisible(true)
		self.Button_cangyi:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
		self.Button_cangyi:setVisible(true)
	end

	self:isShow()
	self:setNeiLiAndGold()
	self:toCuiLian()
	-- self:show()

    beginPrintTalkTextNum = 1
    --处理打造中欧冶子说话内容
    -- if User:getRole().shenBingweapon.status == "10" then
    -- 	self:DaZaoTalkText()
    -- end
end

function NewShenBingLayer:DaZaoTalkText()

	local  role = User:getRole()
	if role.shenBingweapon and role.shenBingweapon.beginDazaoTime then
		local interval = 30 / #text
		local dazaoElapse = math.ceil(GetTime() -  role.shenBingweapon.beginDazaoTime)

		local index = math.ceil(dazaoElapse / interval) + 1

		for i = 1, index do
			if text[i] then
				self:print(text[i])
			end
		end
	end
end

function NewShenBingLayer:update()
	self:isShow()
	self:setNeiLiAndGold()
end
-- ---进入界面播放声音
function NewShenBingLayer:playEffectEnter()
	Audio:playEffect("jinrujiemian")
	self:delayFunc(0.5,function()
		Audio:playEffect("jinrujiemian")
	end)
	self:delayFunc(1.5,function()
		Audio:playEffect("jinrujiemian")
	end)
end
function NewShenBingLayer:show()
	self:setVisible(true)
	-- self.Panel_DuanZao:setVisible(false)
	self.Text_desc:setVisible(true)
	
	self.Button_1:setVisible(true)
	self.Button_1:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
	--神兵界面对打造显示的控制
	
	-- if User:getRole().shenBingweapon.status ~= "0"  then
	-- 	self.Panel_DuanZaoZhong:setVisible(true)
	-- elseif User:getRole().shenBingweapon.status == "0" and User:getRole().shenBingweapon.type == nil then
	-- 	self.Panel_DuanZaoZhong:setVisible(false)
	-- end

end
function NewShenBingLayer:initRichText()
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

   	-- self.RichText_print:setVerticalSpace(-5)

	-- self:print("HIY【HIB江HIM湖HIC通HIW告RAN】:RED欢GRN迎YEL来BLU到MAG天CYN下WHT第HIR一HIG.")
	-- self:print("测试")
end
local textColor = cc.c3b(102, 153, 153)
function NewShenBingLayer:print(str, verticalSpace)
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
--点击铁匠
function NewShenBingLayer:ButtonTeJiang()
	self.Button_1:setButtonType(WIDGET_TOUCH_VOICE_SMALLBUTTON)
	self.Button_1:releaseFunc(function()
		if not self:clickCond() then
			return
		end
		PopupLayerController:showLayer("ShenBingObserveLayer", function(layer)
			layer:show(MainControllLayer)
		end)
	end)
end
--点击锻造炉
function NewShenBingLayer:ButtonDuanZhaoLu()
	self.Button_duanzaolu:releaseFunc(function()
		if not self:clickCond() then
			return
		end
		PopupLayerController:showLayer("DuanZaoLuObserveLayer", function(layer)
			layer:show(MainControllLayer)
		end)
	end)
end
--点击悬兵洞和藏衣阁
function NewShenBingLayer:ButtonXuanbing()
	self.Button_xuanbing:setButtonType(WIDGET_TOUCH_VOICE_SMALLBUTTON)
	self.Button_xuanbing:releaseFunc(function()
		if not self:clickCond() then
			return
		end

		HttpManagerEx:getClientData({type = "xuanbingdong"},function(status, errcode, errmsg, data)
			-- print("------------------------------getClientData-----------------------------")
			-- Helper:print_lua_table(data)
			if status == 200 then
				if errcode == 0 then
					if MapIsEmpty(data) == false then
						if data.flag == 1 then
							MainControllLayer:pushLayer("XuanBingDong")
							local XuanBingDong = MainControllLayer:getLayer("XuanBingDong")
							XuanBingDong:setInRoom(false)
							XuanBingDong:show()
						else
							MainControllLayer:pushLayer("XuanBingDongOld")
							local XuanBingDongOld = MainControllLayer:getLayer("XuanBingDongOld")
							XuanBingDongOld:show(data.item)
						end
					end
				else
					PopText(errmsg)
				end
				return true
			else
				PopText(errmsg)
				return false
			end
		end, IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)

	end)
	self.Button_cangyi:setButtonType(WIDGET_TOUCH_VOICE_SMALLBUTTON)
	self.Button_cangyi:releaseFunc(function()
		if not self:clickCond() then
			return
		end

		HttpManagerEx:getClientData({type = "cangyige"},function(status, errcode, errmsg, data)
			-- print("------------------------------getClientData-----------------------------")
			-- Helper:print_lua_table(data)
			if status == 200 then
				if errcode == 0 then
					if MapIsEmpty(data) == false then
						if data.flag == 1 then
							MainControllLayer:pushLayer("CangYiGe")
							local CangYiGe = MainControllLayer:getLayer("CangYiGe")
							CangYiGe:show()
						else
							MainControllLayer:pushLayer("CangYiGeOld")
							local CangYiGeOld = MainControllLayer:getLayer("CangYiGeOld")
							CangYiGeOld:show(data.item)
						end
					end
				else
					PopText(errmsg)
				end
				return true
			else
				PopText(errmsg)
				return false
			end
		end, IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)

	end)
end
--设置内力和黄金
function NewShenBingLayer:setNeiLiAndGold()
	local role = User:getRole()
	local neili,neiliMax = math.floor(role:getAttr("jing")),math.floor(role:getJingMax())
	local gold = role: getAttr("gold")
	self.Text_NeiLi:setString("『精力』"..tostring(neili).."/"..tostring(neiliMax))
	self.Text_Gold:setString("『黄金』"..tostring(gold))
end

-- --已学技艺按钮
-- function NewShenBingLayer:ButtonJiYi()
-- 	self.Button_change:setVisible(true)
-- 	-- self.Button_change.Text_buttonName:setString("武功书页")
-- 	self.Button_change:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BACKBUTTON)
-- 	self.Button_change:releaseFunc(function()
-- 		PopText("更改锻造术配置文件")
-- 		MainControllLayer:pushLayer("ShenBingSkilledLayer")
-- 		local ShenBingSkilledLayer = MainControllLayer:getLayer("ShenBingSkilledLayer")
-- 		ShenBingSkilledLayer:show()
-- 		-- PopupLayerController:showLayer("ShenBingSkilledLayer", function(layer)
-- 		-- 	layer:show(MainControllLayer)
-- 		-- end)
-- 	end)
-- end
--返回按钮
function NewShenBingLayer:ButtonBack()
	
	self.Image_titleShenBing.Button_back:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BACKBUTTON)
	self.Image_titleShenBing.Button_back:releaseFunc(function()
		if not self:clickCond() then
			return
		end
		self:hide()
	end)
end


-- 淬炼
function NewShenBingLayer:toCuiLian()
	self.Panel_DuanZaoZhong.Button_2:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
	self.Panel_DuanZaoZhong.Button_2:releaseFunc(function()
		if not self:clickCond() then
			return
		end

		local role = User:getRole()
		local weapon = role:getDefaultShenBing()

		if weapon == nil then
			PopText("您还没有装上默认神兵，无法进行操作")
			return
		end

		PopupLayerController:showLayer("ShenBingCuiLianLayer",function(layer)
				layer:showLayer(weapon)
		end)
	end)
end

function NewShenBingLayer:setWeaponName(str)
	self.Panel_DuanZaoZhong.Text_Weapon_Name:setString(str)
end

function NewShenBingLayer:setWeaponNumDesc(desc)
	self.Panel_DuanZaoZhong.Text_My_Weapon:setString(desc)
end

function NewShenBingLayer:setBtnCondition(condition,text)
	self.clickCond = setBtnCanClick(condition,text)
end

function NewShenBingLayer:setChangeWeaponFunc()
	self.Panel_DuanZaoZhong.Button_3:releaseFunc(function()
		if not self:clickCond() then
			return
		end

		PopupLayerController:showLayer("ShenBingWareHouseLayer",function(layer)
			layer:setBackConditionFunc()
			layer:showUI()
		end)
	end)
end

function NewShenBingLayer:setAddShenBingNumLimitFunc()
	self.Panel_DuanZaoZhong.Button_4:releaseFunc(function()
		if not self:clickCond() then
			return
		end
		
		local ShenBingWareHouse = require("app.models.ShenBing.ShenBingWareHouse"):create()
		local role = User:getRole()
		ShenBingWareHouse:setRole(role)

		local currLimit = ShenBingWareHouse:getShenBingLimit()
		local currLevel = ShenBingWareHouse:getLevelByLimit(currLimit)
		local maxLevel = ShenBingWareHouse:getMaxLevel()

		if currLevel >= maxLevel then
			PopText("当前背包神兵携带数量已达最大升级上限")
			return
		end

		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()


		local nextLimit = ShenBingWareHouse:getLimitByLevel(currLevel + 1)
		local cost,costName = ShenBingWareHouse:getCostByLimit(nextLimit)
		dialog:show("当前神兵携带上限为"..tostring(currLimit) .. "把".."\n\n".."\n花费"..tostring(cost) .. costName .. "可升级到"..tostring(nextLimit) .. "把")
		dialog:setButton1("升级", function() 
			ShenBingWareHouse:upgrade(function()
				local items = role:getItems(function(item)
					if item.type == "神兵" then
						return true
					end
				end)
				self:setWeaponNumDesc("携带神兵数量：".. tostring(#items).."/"..tostring(role:getAttr("bagShenBingNumLimit")))
			end)
		end)
		dialog:setButton2("否")
		dialog:setWeChatVisible(false)
	end)
end


Helper:classDefNodeGetInstance(NewShenBingLayer)
return  NewShenBingLayer000000
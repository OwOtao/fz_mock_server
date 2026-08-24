
local FestivalGiveGiftLayer = class("FestivalGiveGiftLayer", cc.Layer)

function FestivalGiveGiftLayer:create()
	local p = FestivalGiveGiftLayer:new()
	p:init()
	return p
end

function FestivalGiveGiftLayer:init()
	self._UI = require("Layer/VisitTaskUI/VisitTaskUI.lua").create()['root']
    self._UI:addTo(self)
    Helper:convertUI(self) -- 获得所有子节点
end

--隐藏无用UI
function FestivalGiveGiftLayer:hideUselessUI()
	self.Text_title:setVisible(false)
	self.Text_npc_name:setVisible(false)
	self.Text_reward:setVisible(false)
	self.Text_discount:setVisible(false)
end

--初始化显示UI
function FestivalGiveGiftLayer:initShowUI(btnTitle,spendText,showText)
	if self.RichText then
        self.RichText:removeFromParent()
    end
    if type(btnTitle)~="table" then 
		btnTitle[1]="按钮1"
		btnTitle[2]="按钮2"
		btnTitle[3]="按钮3"
	end

	if type(spendText)~="table" then 
		spendText[1]="说明1"
		spendText[2]="说明2"
	end

	local showText= showText or "新年快乐"

    local x, y = self.ListView_listArea:getPosition()
    local size = self.ListView_listArea:getContentSize()
	self.RichText = ExtRichTextScroll:create()
    self.ListView_listArea:getParent():addChild(self.RichText)
    self.RichText:move(cc.p(x, y))
    self.RichText:setSize(size)
    self.RichText:setAnchorPoint(cc.p(0.5, 0.5))
    self.RichText:setDirection(kCCScrollViewDirectionVertical)
    self.RichText:getRichText():setVerticalSpace(20)

	local textColor = cc.c3b(208, 208, 208)
    self.RichText:pushBackText(showText, textColor, 255, Resource:getFontPath("default"), 60)
	self.Text_button_1_Name:setString(btnTitle[1] or "")
	self.Text_button_2_Name:setString(btnTitle[2] or "")
	self.Text_button_3_Name:setString(btnTitle[3] or "")
	self.Button_1:setPositionY(1000+50)
	self.Button_2:setPositionY(750+50)
	self.Button_3:setPositionY(500+50)
	self.Text_spend:setString(spendText[1] or "")
	self.Text_spend:setColor(cc.c3b(219, 57, 57))
	self.Text_spend_1:setString(spendText[2] or "")
	self.Text_spend_1:setColor(cc.c3b(219, 57, 57))
	self.Text_spend:setPositionY(900+50)
	self.Text_spend_1:setPositionY(650+50)
end

--初始化相关按钮功能
function FestivalGiveGiftLayer:initBtnFunction(bindingType,bindingSpendNum,bindingFunc)
	if type(bindingFunc)~="function" then 
	 	bindingFunc=function ()
	 	end
	end

	if type(bindingType)~="table" then 
	 	bindingType = {[1]="money",[2]="gold"}
	end

	if type(bindingSpendNum)~="table" then 
	 	bindingSpendNum = {[1]=288888,[2]=3888}
	end

	self.Button_1:releaseFunc(function ()
		local func=function ()
			self:giveGiftSpend(bindingType[1],bindingSpendNum[1])
			--保存礼包类型
			User:getRole():setDayFlag("giftType", 1)
			if bindingFunc then 
				bindingFunc()
			end
			self:hideLayer()
		end
		self:checkCanGiveGift(bindingType[1],bindingSpendNum[1],func)

	end)
	self.Button_2:releaseFunc(function ()
		local func=function ()
			self:giveGiftSpend(bindingType[2],bindingSpendNum[2])
			--保存礼包类型
			User:getRole():setDayFlag("giftType", 2)
			if bindingFunc then 
				bindingFunc()
			end
			self:hideLayer()
		end
		self:checkCanGiveGift(bindingType[2],bindingSpendNum[2],func)
	end)
	self.Button_3:releaseFunc(function ()
		self:hideLayer()
	end)

	self.Panel_back:releaseFunc(function ()
		self:hideLayer()
	end)
end

--检测是否可以放置礼包
function FestivalGiveGiftLayer:checkCanGiveGift(type,num,func)
	if not type then
		print("检测货币为空")
		return false
	end
	if not func then 
		func=function ()
		end
	end
	local strType={
		["yinpiao"]="银票",
		["yuanbao"]="元宝"
	}
	local needNum=num or 0
	local role=User:getRole()
	if type=="money" or type=="gold" then 
		local haveNum=role:getAttr(type)
		if haveNum>=needNum then
			if func then 
				func()
			end
			return true
		else
			PopText("碎银不足")	
		end
	elseif type=="yinpiao" then
	elseif type=="yuanbao" then 
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        local commands = Resource:getColorTb()
        dialog:show("你确定要花费"..needNum..strType[type].."吗？")
        dialog:setDescColor(commands["YEL"].color)
        dialog:setButton1("确定", function()
        	if func then 
				func()
			end 
        end)
        dialog:setButton2("取消", function()
            dialog:hide()
        end)
        dialog:setWeChatVisible(false) 
	end
	
	return false
end

--送礼开销
function FestivalGiveGiftLayer:giveGiftSpend(type,num)
	if not type then
		print("检测货币为空")
		return false
	end
	local needNum=num or 0
	if type=="money" or type=="gold" then
		User:addRoleAttr(type, -needNum)
	elseif type=="yinpiao" then  --服务器扣
	elseif type=="yuanbao" then 
	end
end

function FestivalGiveGiftLayer:showLayer(btnTitle,spendText,showText,spendType,spendNum,func)
	 self:hideUselessUI()
	 self:initShowUI(btnTitle,spendText,showText)
	 self:initBtnFunction(spendType,spendNum,func)
	 self:show()
end

function FestivalGiveGiftLayer:hideLayer()
	PopupLayerController:hideLayer("FestivalGiveGiftLayer",function (layer)
        layer:hide()
     end)
end


Helper:classDefNodeGetInstance(FestivalGiveGiftLayer)
return FestivalGiveGiftLayer0000000
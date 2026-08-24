local  JiaGong = class("JiaGong",cc.Layer)

local godweapon = require("script.others.godweapon")
local ShenBingDesc = require("app.models.ShenBing.ShenBingDesc")
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
local Item = require("app.models.item.Item")


function JiaGong:create()
	local p = JiaGong:new()
	p:init()
	return p
end

-- local list = 
-- {
-- 	weapon_in = "这是一个收的特效",
-- 	out = "这是一个拔的特效"
-- }

function JiaGong:show()
	self:setVisible(true)
	self.weapen = User:getRole():getDefaultShenBing()
	-- 如果神兵存在，获取所有描述显示
	if self.weapen then	
		local shenBingDesc = ShenBingDesc:getWeaponFacade(self.weapen) --获得神兵描述
		local weapon_out = ShenBingDesc:getWeaponEquipText(self.weapen)   --获取神兵拔剑文本
		local weapon_in  = ShenBingDesc:getWeaponTakeOffText(self.weapen) --获取当前收鞘文本
		self:setDesc(shenBingDesc,weapon_out,weapon_in)
		self:setTitle()
	end
end
function JiaGong:init()
	self._UI = require("Layer/ShenBing/JiaGongUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUI(self)
	--点击背景打造界面隐藏
	self.Layer_back:releaseFunc(function()
		self:hide()
	end)

	self.weapen = nil       --神兵
	self.shenBingDesc = nil
	self.weapon_out = nil
	self.weapon_in  = nil
	self.baskLookid = nil
	self.descType = 1      -- 神兵外观描述默认 不锁定  （1不锁定 0锁定）        
	self.weaponType = 1    -- 神兵出鞘收回描述默认 不锁定  （1不锁定 0锁定） 
	self:ButtonProcess()
	self:Button()
	self:ButtonYes()
	self:changBaHui()
	self:changWeapon()	
	self:initChangeDefaultShenBingBtnFunc()
end

--取消按钮
function JiaGong:ButtonProcess()
	self.Button_Process:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_Process:releaseFunc(function()
		self:hide()
	end)
end

--设置标题
function JiaGong:setTitle()
	if not self.weapen then
		return
	end
	local shenBingWeapon = self.weapen
	self.Text_WeaponName:setString(shenBingWeapon.name)
end

function  JiaGong:setShenBingWeapon_inAnd_out(desid,lookid)
	if not self.weapen then
		return
	end

    if desid then
		self.weapen.equipDescId = desid
		print("改变神兵equipDescId为："..desid)
	end

	if lookid then
		self.weapen.weaponLookId = lookid
		print("改变神兵lookid为："..lookid)
	end

	self:saveLookAndDes()
end

--加工按钮
function JiaGong:ButtonYes()
	self.Text_buttonYesName:setString("加工")
	self.Button_Yes:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_Yes:releaseFunc(function()
		print("......................加工")
			if 	self.weaponType ==0 and  self.descType ==0 then
				PopText("神兵外观，拔出回鞘特效全部被锁定，无法使用该功能！")
			else
				local desc, str = "加工\n\n加工会改变神兵的装备、脱下以及外观的文字描述。", "将消耗50元宝，是否确定？"
				local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
				local dialog = DialogALayer:getInstance()
				dialog:show(desc, str)
				dialog:setButton1("是", function()
					--现拔剑回鞘的特效的描述，从配置文件读取 排除当前特效
					local descList = {}
					print(self.weaponType, self.descType, self.baskLookid)
					if self.weaponType ==1 then
						descList = ShenBingDesc:getRandomWeaponWeardes(self.weapen)
						assert(descList)
						self.weapon_out = Helper:getDef(descList.Weardes,"") 
						self.weapon_in =  Helper:getDef(descList.Takedes,"") 
					end
					if self.descType == 1 then
						self.baskLookid = ShenBingDesc:getRandomWeaponFacade(self.weapen)
					end

					print("当前神兵的拔剑id1", self.weapen.weaponLookId)

					PopYuanBaoBuyItemLayer("jiagongwupin1", function(eventType)
						if eventType == "success" then
							self:setShenBingWeapon_inAnd_out(descList.desid,self.baskLookid)
							-- 使用描述
							PopText("保存当前外观成功！")
						else
							PopText("加工失败，无法载入新外观！")
						end
					end)
				end)
				dialog:setButton2("否", function()
					-- 取消使用物品
					dialog:hide()
				end)
			end
		
	end)
	
end


--修理界面（修理界面的描述添加）（加工）
function JiaGong:setDesc(strAppearance,strBa,strHui)
	self.Text_Appearance_Desc:setString(strAppearance)
	self.Text_BaJian_desc:setString(strBa)
	self.Text_HuiQiao_Desc:setString(strHui)
end
-- 锁定按钮
function JiaGong:Button()
	self.Text_BaHui_color:releaseFunc(function()
		if self.weaponType == 0 then
			self.weaponType =1
		else
			self.weaponType =0
		end 
		self:changBaHui()
	end)
	self.Text_Weapon_color:releaseFunc(function()
		if self.descType == 0 then
			self.descType =1
		else
			self.descType =0
		end 
		self:changWeapon()
	end)
end

-- 拔剑回鞘描述锁定
function JiaGong:changBaHui()
	local str = ""
	if  self.weaponType == 0 then
		str = "已锁定"
		self.Text_BaHui_color:setColor({r = 255, g = 195, b = 0})
	elseif  self.weaponType == 1 then
		str = "锁定"
		self.Text_BaHui_color:setColor({r = 219, g = 57, b = 57})
	end
	self.Text_BaHui_color:setString(str)
end
-- 外观描述锁定
function JiaGong:changWeapon()
	local str = ""
	if  self.descType == 0 then
		str = "已锁定"
		self.Text_Weapon_color:setColor({r = 255, g = 195, b = 0})
	elseif  self.descType == 1 then
		str = "锁定"
		self.Text_Weapon_color:setColor({r = 219, g = 57, b = 57})
	end
	self.Text_Weapon_color:setString(str)
end

-- 保存
function JiaGong:saveLookAndDes()
	if self.weapen then	
		ShenBingDuanZao:updateShenBingInfo(self.weapen)

		print("当前神兵的外观id", self.weapen.equipDescId)
		print("当前神兵的拔剑id", self.weapen.weaponLookId)

		local shenBingDesc = ShenBingDesc:getWeaponFacade(self.weapen,true) --获得神兵描述
		local weapon_out = ShenBingDesc:getWeaponEquipText(self.weapen)   --获取神兵拔剑文本
		local weapon_in  = ShenBingDesc:getWeaponTakeOffText(self.weapen) --获取当前收鞘文本
		self:setDesc(shenBingDesc,weapon_out,weapon_in)
	end

end

function JiaGong:initChangeDefaultShenBingBtnFunc()
	self.Image_back_ChangeWeapon:releaseFunc(function()
		PopupLayerController:showLayer("ShenBingWareHouseLayer",function(layer)
			layer:setBackConditionFunc(function()
				local role = User:getRole()
				local shenBing = role:getDefaultShenBing()
				if shenBing then
					self.weapen = shenBing
					local shenBingDesc = ShenBingDesc:getWeaponFacade(self.weapen) --获得神兵描述
					local weapon_out = ShenBingDesc:getWeaponEquipText(self.weapen)   --获取神兵拔剑文本
					local weapon_in  = ShenBingDesc:getWeaponTakeOffText(self.weapen) --获取当前收鞘文本
					self:setDesc(shenBingDesc,weapon_out,weapon_in)
					self:setTitle()

					return true
				else
					PopText("请设置默认神兵，否则无法进行操作！")
					return false
				end
			end)
			layer:showUI()
		end)
	end)
end

Helper:classDefNodeGetInstance(JiaGong)
return  JiaGong0000000000000000
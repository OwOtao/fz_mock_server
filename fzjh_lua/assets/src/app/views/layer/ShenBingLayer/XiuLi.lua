local  XiuLi = class("XiuLi",cc.Layer)  

function XiuLi:create()
	local p = XiuLi:new()
	p:init()
	return p
end

-- local list = 
-- {
-- 	weapon_in = "这是一个收的特效",
-- 	out = "这是一个拔的特效"
-- }
local strAppearance = 
{
	[1] =  --剑
	{
		[1] = -- 红
		"这是一把略泛红光的宝剑",

		[2] = --绿
		 "这把宝剑泛着墨绿",

		[3] =--黄
		"这是一把略泛金光的宝剑",

		[4] =--蓝
		"这把剑上隐显微蓝，",

		[5] =--紫
		"这把宝剑透着暗紫之色",

		[6] =--青
		 "这把宝剑微泛暗青",

		[7] = --亮红
		"这把宝剑映着血光，如梦似幻",

		[8] =--亮绿
		"此剑闪烁着幽幽绿光",

		[9] = --亮黄
		"此剑通体金黄，引人注目",

		[10] =--亮蓝
		 "此剑散发着淡淡蓝光",

		[11] =--亮紫
		 "此剑散发出荧荧紫光",

		[12] = --亮青
		"此剑在阳光照耀下散发出明澈的青光",

		[13] =--亮白
		 "此剑散发出灼眼的白光",

		[14] =--灰色
		 "这把剑散发着蒙蒙灰光",

		 ---------------------------默认拔剑和回鞘的描述
    },
	[2] =  --刀
	{
		[1] = -- 红
		"这把刀色泽暗红",
		[2] = --绿
		 "此刀泛着铜绿，略显不俗",

		[3] =--黄
		"此刀色泽暗金，惹人注目",

		[4] =--蓝
		"这把刀透着淡淡蓝光",

		[5] =--紫
		"这把刀透着些许暗紫之色",

		[6] =--青
		 "这把刀色泽泛青，",

		[7] = --亮红
		"这把刀红光布体",

		[8] =--亮绿
		"这把刀倒映着青光",

		[9] = --亮黄
		"这把刀金光亮眼",

		[10] =--亮蓝
		 "这把刀透着璀璨蓝光",

		[11] =--亮紫
		 "这把刀闪着盈盈紫光",

		[12] = --亮青
		"此刀青光灼眼",

		[13] =--亮白
		 "此刀白光亮眼",

		[14] =--灰色
		 "此刀透着些许灰光",
    },
    [3] =  --棍
	{
		[1] = -- 红
		"此棍色泽暗红，似乎掺入了熟铜",
		[2] = --绿
		 "这根棍子泛着铜绿",

		[3] =--黄
		"此棍透着暗金，煞是晃眼",

		[4] =--蓝
		"这棍子色泽微蓝，惹人注目",

		[5] =--紫
		"这根棍子透着些许淡紫",

		[6] =--青
		 "这是一根暗青色的长棍",

		[7] = --亮红
		"此棍通体泛红，不知是用何打造",

		[8] =--亮绿
		"此棍呈亮绿之色",

		[9] = --亮黄
		"此棍呈亮金之色",

		[10] =--亮蓝
		 "此棍呈深蓝之色",

		[11] =--亮紫
		 "此棍呈深紫之色",

		[12] = --亮青
		"此棍呈亮青之色",

		[13] =--亮白
		 "此棍通体泛白",

		[14] =--灰色
		 "此棍遍体泛灰",
    },
    [4] =  --鞭
	{
		[1] = -- 红
		"此鞭透着暗红",
		[2] = --绿
		 "此鞭透着暗绿",

		[3] =--黄
		"此鞭透着暗金之色",

		[4] =--蓝
		"此鞭透着淡蓝之色",

		[5] =--紫
		"此鞭透着微紫之色",

		[6] =--青
		 "此鞭呈现暗青之色",

		[7] = --亮红
		"此鞭全身通红",

		[8] =--亮绿
		"此鞭闪烁着青绿之光",

		[9] = --亮黄
		"此鞭通体泛金",

		[10] =--亮蓝
		 "此鞭色泽深蓝",

		[11] =--亮紫
		 "此鞭倒映着紫光",

		[12] = --亮青
		"此鞭闪着盈盈青光",

		[13] =--亮白
		 "此鞭通体雪白",

		[14] =--灰色
		 "此鞭呈灰蒙之色",
    },
	
}
function XiuLi:show()
	self:setVisible(true)
	self:ButtonYes()
	self:setTitle()
	self:ButtonProcess()
end
function XiuLi:init()
	self._UI = require("Layer/ShenBing/XiuLiUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUI(self)

		--点击背景打造界面隐藏
	self.Layer_back:releaseFunc(function()
		self:hide()
	end)
	
	--初始化这个界面的时候，如果没有加工过，应该显示这样
	local role = User:getRole()
	local shenBingweapon = role.shenBingweapon
	if PRINT_MODE ==1 then
		print("----------------------------------------------------------------")
		print("role.shenBingweapon.payYuanBao"..tostring(shenBingweapon.payYuanBao))
	end
	if role.shenBingweapon.payYuanBao == 0 then
		print("----------------------------------------------------------------")
		if role.shenBingweapon.type == "剑" then
			self:setDesc(strAppearance[1][self.colorid],"你抽出一把剑握在手中。","你将手中的剑插回腰间。")
			role.shenBingweapon.strAppearance = strAppearance[1][self.colorid]
			-- self.Text_Appearance_Desc:setColor(role.shenBingweapon.color)
		elseif role.shenBingweapon.type == "刀" then
			self:setDesc(strAppearance[2][self.colorid],"你抽出一把刀握在手中。","你将手中的刀插回腰间。")
			role.shenBingweapon.strAppearance = strAppearance[1][self.colorid]
			-- self.Text_Appearance_Desc:setColor(role.shenBingweapon.color)
		elseif role.shenBingweapon.type == "棍" then
			print("----------------------------------------------------------------")
			self:setDesc(strAppearance[3][self.colorid],"你拿出一根棍，握在手中。","你放下手中的棍。")
			role.shenBingweapon.strAppearance = strAppearance[1][self.colorid]
			-- self.Text_Appearance_Desc:setColor(role.shenBingweapon.color)
		elseif role.shenBingweapon.type == "鞭" then
			self:setDesc(strAppearance[4][self.colorid],"你拿出一根鞭，握在手中。","你放下手中的鞭。")
			role.shenBingweapon.strAppearance = strAppearance[1][self.colorid]
			-- self.Text_Appearance_Desc:setColor(role.shenBingweapon.color)						
		end
		--如果武器已经有外观和拔剑特效。直接显示
	else
		self:setDesc(shenBingweapon.strAppearance,shenBingweapon.weapon_out,shenBingweapon.weapon_in)
	end
end
--确定按钮
function XiuLi:ButtonYes()
	self.Button_Yes:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_Yes:releaseFunc(function()
		self:hide()
	end)
end

--设置标题
function XiuLi:setTitle()
	local shenBingWeapon = User:getRole():getAttr("shenBingweapon")
	self.Text_WeaponName:setString(shenBingWeapon.name)
	self.Text_WeaponName:setColor(shenBingWeapon.color)
end

function  XiuLi:setShenBingWeapon_inAnd_out(weapon_in,weapon_out)
	local role = User:getRole()
	role.shenBingweapon.weapon_in = weapon_in
	role.shenBingweapon.weapon_out = weapon_out
	if role.shenBingweapon.type == "剑" then
			print("---------------------------------------------")
			self:setDesc(strAppearance[1][role.shenBingweapon.colorid],weapon_out,weapon_in)
			-- self.Text_Appearance_Desc:setColor(role.shenBingweapon.color)
		elseif role.shenBingweapon.type == "刀" then
			self:setDesc(strAppearance[2][role.shenBingweapon.colorid],weapon_out,weapon_in)
			-- self.Text_Appearance_Desc:setColor(role.shenBingweapon.color)
		elseif role.shenBingweapon.type == "棍" then
			self:setDesc(strAppearance[3][role.shenBingweapon.colorid],weapon_out,weapon_in)
			self.Text_Appearance_Desc:setColor(role.shenBingweapon.color)
		elseif role.shenBingweapon.type == "鞭" then
			self:setDesc(strAppearance[4][role.shenBingweapon.colorid],weapon_out,weapon_in)
			-- self.Text_Appearance_Desc:setColor(role.shenBingweapon.color)						
		end	
end

--加工按钮
function XiuLi:ButtonProcess()
	local role = User:getRole()
	self.Button_Process:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_Process:releaseFunc(function()
	
		local weapon_out = ""
		local weapon_in = ""
		--点加工按钮，访问服务器，获得拔剑回鞘的特效的描述
		--访问服务器
		HttpManagerEx:getRandomWeaponDesc(1, function(status, errcode, errmsg, data)
			if status == 200 then
				local role = User:getRole()
				--点击颜色选取后，武器的描述跟着改变
				data.weapon_out = string.gsub(data.weapon_out, "$N", "你")
				data.weapon_out = string.gsub(data.weapon_out, "$w", role.shenBingweapon.colorname..role.shenBingweapon.name.."NOR")
				data.weapon_out = string.gsub(data.weapon_out, "$W", role.shenBingweapon.colorname..role.shenBingweapon.name.."NOR")

				data.weapon_in = string.gsub(data.weapon_in, "$N", "你")
				data.weapon_in = string.gsub(data.weapon_in, "$w", role.shenBingweapon.colorname..role.shenBingweapon.name.."NOR")
				data.weapon_in = string.gsub(data.weapon_in, "$W", role.shenBingweapon.colorname..role.shenBingweapon.name.."NOR")
				--保存服务器下载下来的数据
				weapon_in = data.weapon_in
				weapon_out = data.weapon_out
			else
				--访问错误
				PopText(tostring(errmsg))
			end
		end)		
		local DialogYuanbaoLayer = require("app.views.layer.ShenBingLayer.DialogYuanbaoLayer")
		local dialog = DialogYuanbaoLayer:getInstance()

-------------------------------------------有错---------------------------------------------------------
		dialog:setText_desc_weapon_in(weapon_in)
		dialog:setText_desc_weapon_out(weapon_out)
		dialog:show()

		-- 弹出框的弹出文
		-- local desc, str = tostring(self.dsc), "将消耗"..tostring(self.unit)..tostring(self.name).."，是否确定？", ""
		-- 判断物品是否存在	
		dialog:setButton1(function()

			local DialogILayer = require("app.views.layer.DialogLayer.DialogILayer")
			dialog = DialogILayer:getInstance()
			dialog:show()
			dialog:setText("请稍后...")
			dialog:delayFunc(20, function()
				dialog:hide()
			end)

			local transId = TransCheck:setTrans(SHENBING_JIAGONG_PAYYUANBAO, 1, 1)
			if transId == nil or (type(transId) == "number" and transId <= 0) then
				return
			end
			--流程，扣除元宝访问服务器一次，加工访问服务器一次，只有扣除元宝访问服务器成功后，才继续技工访问服务器，如果成，扣除元宝，下载描述
			HttpManagerEx:getRemoveYuanBao(SHENBING_JIAGONG_PAYYUANBAO, transId, function(status, errcode, errmsg, data)
				dialog:hide()
				if status == 200 then
					if MapIsEmpty(data) then
						PopText("网络异常")
						return
					end

					if errcode == 0 or errcode == "0" then
						TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
					else
						PopText(tostring(errmsg))
						TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
						return
					end

					--确定后，设置武器的拔剑回特效
					self:setShenBingWeapon_inAnd_out(weapon_in,weapon_out)
					-- 使用描述
					PopText("消费30元宝")
					-- RichPrint("main", )
					-- dialog:delayFunc(1,function()
					-- 	self:use(dialog)
					-- end)
				end
			end)
		end)
		dialog:setButton2(function()
		end)
	end)
end


--修理界面（修理界面的描述添加）（加工）
function XiuLi:setDesc(strAppearance,strBa,strHui)
	self.Text_Appearance_Desc:setString(strAppearance)
	self.Text_BaJian_desc:setString(strBa)
	self.Text_HuiQiao_Desc:setString(strHui)
end


Helper:classDefNodeGetInstance(XiuLi)
return  XiuLi

0000000
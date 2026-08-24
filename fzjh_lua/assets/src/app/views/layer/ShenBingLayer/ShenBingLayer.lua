local  DialogUseLayer = require("app.views.layer.ShenBingLayer.DialogUseLayer")
local Item = require("app.models.item.Item")
local Meridian = require("app.models.Meridian.Meridian")
local  ShenBingLayer = class("ShenBingLayer",cc.Layer)


function ShenBingLayer:create()
	local p = ShenBingLayer:new()
	p:init()
	return p
end
-- local list =
-- {
-- 	desc = "这是一个武器描述"
-- }
--  此表是加强需要的等级和黄金
local lv =
{
[1]   ={  payNeiLi =2	, payGold = 2,	           neiLiLimit =2500 },
[2]   ={  payNeiLi =2	,  payGold =2,	           neiLiLimit =        2500 },
[3]   ={ payNeiLi = 2	,  payGold =2,	           neiLiLimit =        2500 },
[4]   ={  payNeiLi =2	,  payGold =2,	           neiLiLimit =          2500 },
[5]   ={ payNeiLi = 2	,  payGold =2,	           neiLiLimit =      2500 },
[6]   ={ payNeiLi = 2	,  payGold =2,	           neiLiLimit =        2500 },
[7]   ={  payNeiLi =2	,  payGold =2,	           neiLiLimit =        2500 },
[8]   ={  payNeiLi =2	,  payGold =2,	           neiLiLimit =        2500 },
[9]   ={  payNeiLi =2	,  payGold =2,	           neiLiLimit =        2500 },
[10]={   payNeiLi = 20 ,   payGold =10,            neiLiLimit =        2500 },
[11]={   payNeiLi =  20,	payGold =10,	       neiLiLimit =        2500 },
[12]={   payNeiLi =  20,	payGold =10	,          neiLiLimit =        2500 },
[13]={   payNeiLi  = 20,	payGold =10,           neiLiLimit =        2500 },
[14]={   payNeiLi =  20,    payGold = 10,	       neiLiLimit =        2500 },
[15]={   payNeiLi =  	20, payGold = 	10,	       neiLiLimit =        2500 },
[16]={   payNeiLi =  	20, payGold = 	10,	       neiLiLimit =        2500 },
[17]={   payNeiLi =  	20, payGold = 	10,	       neiLiLimit =        2500 },
[18]={   payNeiLi =  	20, payGold = 	10,	       neiLiLimit =        2500 },
[19]={   payNeiLi =  	20, payGold = 	10,	       neiLiLimit =        2500 },
[20]={   payNeiLi =  	40, payGold = 	30,	       neiLiLimit =        2500 },
[21]={   payNeiLi =  	40, payGold = 	30,	       neiLiLimit =        2500 },
[22]={   payNeiLi =  	40, payGold = 	30,	       neiLiLimit =        2500 },
[23]={   payNeiLi =  	40, payGold = 	30,	       neiLiLimit =        2500 },
[24]={   payNeiLi =  	40, payGold = 	30,	       neiLiLimit =        2500 },
[25]={   payNeiLi =  	40, payGold = 	30,	       neiLiLimit =        2500 },
[26]={   payNeiLi =  	40, payGold = 	30,	       neiLiLimit =        2500 },
[27]={   payNeiLi =  	40, payGold = 	30,	       neiLiLimit =        2500 },
[28]={   payNeiLi =  	40, payGold = 	30,	       neiLiLimit =        2500 },
[29]={   payNeiLi =  	40, payGold = 	30,	       neiLiLimit =        2500 },
[30]={   payNeiLi =  	60, payGold = 	60,	       neiLiLimit =        2500 },
[31]={   payNeiLi =  	60, payGold = 	60,	       neiLiLimit =        2500 },
[32]={   payNeiLi =  	60, payGold = 	60,	       neiLiLimit =        2554 },
[33]={   payNeiLi =  	60, payGold = 	60,	       neiLiLimit =        2633 },
[34]={   payNeiLi =  	60, payGold = 	60,	       neiLiLimit =        2719 },
[35]={   payNeiLi =  	60, payGold = 	60,	       neiLiLimit =        2799 },
[36]={   payNeiLi =  	60, payGold = 	60,	       neiLiLimit =        2885 },
[37]={   payNeiLi =  	60, payGold = 	60,	       neiLiLimit =        2965 },
[38]={   payNeiLi =  	60, payGold = 	60,	       neiLiLimit =        3052 },
[39]={   payNeiLi =  	60, payGold = 	60,	       neiLiLimit =        3133 },
[40]={   payNeiLi =  	80, payGold = 	90,	       neiLiLimit =        3220 },
[41]={   payNeiLi =  	80, payGold = 	90,	       neiLiLimit =        3301 },
[42]={   payNeiLi =  	80, payGold = 	90,	       neiLiLimit =        3388 },
[43]={   payNeiLi =  	80, payGold = 	90,	       neiLiLimit =        3469 },
[44]={   payNeiLi =  	80, payGold = 	90,	       neiLiLimit =        3557 },
[45]={   payNeiLi =  	80, payGold = 	90,	       neiLiLimit =        3638 },
[46]={   payNeiLi =  	80, payGold = 	90,	       neiLiLimit =        3727 },
[47]={   payNeiLi =  	80, payGold = 	90,	       neiLiLimit =        3808 },
[48]={   payNeiLi =  	80, payGold = 	90,	       neiLiLimit =        3898 },
[49]={   payNeiLi =  	80, payGold = 	90,	       neiLiLimit =        3979 },
[50]  ={  	payNeiLi = 100  , payGold = 130	,      neiLiLimit =         4068 },
[51]  ={  	payNeiLi = 100  ,payGold = 130	,       neiLiLimit =        4150 },
[52]  ={  	payNeiLi = 100  , payGold = 130	,       neiLiLimit =        4241 },
[53]  ={  	payNeiLi = 100  , payGold = 130	,       neiLiLimit =        4322 },
[54]  ={  	payNeiLi = 100	, payGold = 130,	    neiLiLimit =           4413 },
[55]  ={  	payNeiLi = 100	, payGold = 130,	       neiLiLimit =        4495 },
[56]  ={  	payNeiLi = 100	, payGold = 130,	       neiLiLimit =        4586 },
[57]  ={  	payNeiLi = 100	, payGold = 130,	       neiLiLimit =        4668 },
[58]  ={  	payNeiLi = 100	, payGold = 130,	       neiLiLimit =        4760 },
[59]  ={  	payNeiLi = 100	, payGold = 130,	       neiLiLimit =        4842 },
[60]  ={  	payNeiLi = 120	, payGold = 180,	       neiLiLimit =        4935 },
[61]  ={  	payNeiLi = 120	, payGold = 180,	       neiLiLimit =        5017 },
[62]  ={  	payNeiLi = 120	, payGold = 180,	       neiLiLimit =        5110 },
[63]  ={  	payNeiLi = 120	, payGold = 180,	       neiLiLimit =        5193 },
[64]  ={  	payNeiLi = 120	, payGold = 180,	       neiLiLimit =        5286 },
[65]  ={  	payNeiLi = 120	, payGold = 180,	       neiLiLimit =        5369 },
[66]  ={  	payNeiLi = 120	, payGold = 180,	       neiLiLimit =        5463 },
[67]  ={  	payNeiLi = 120	, payGold = 180,	       neiLiLimit =        5545 },
[68]  ={  	payNeiLi = 120	, payGold = 180,	       neiLiLimit =        5641 },
[69]  ={  	payNeiLi = 120	, payGold = 180,	       neiLiLimit =        5723 },
[70]  ={  	payNeiLi = 140	, payGold = 240,	       neiLiLimit =        5818 },
[71]  ={  	payNeiLi = 140	, payGold = 240,	       neiLiLimit =        5902 },
[72]  ={  	payNeiLi = 140	, payGold = 240,	       neiLiLimit =        5998 },
[73]  ={  	payNeiLi = 140	, payGold = 240,	       neiLiLimit =        6081 },
[74]  ={  	payNeiLi = 140	, payGold = 240,	       neiLiLimit =        6177 },
[75]  ={  	payNeiLi = 140	, payGold = 240,	       neiLiLimit =        6260 },
[76]  ={  	payNeiLi = 140	, payGold = 240,	       neiLiLimit =        6357 },
[77]  ={  	payNeiLi = 140	, payGold = 240,	       neiLiLimit =        6441 },
[78]  ={  	payNeiLi = 140	, payGold = 240,	       neiLiLimit =        6538 },
[79]  ={  	payNeiLi = 140	, payGold = 240,	       neiLiLimit =        6622 },
[80]  ={  	payNeiLi = 160	, payGold = 300,	       neiLiLimit =        6720 },
[81]  ={  	payNeiLi = 160	, payGold = 300,	       neiLiLimit =        6804 },
[82]  ={  	payNeiLi = 160	, payGold = 300,	       neiLiLimit =        6902 },
[83]  ={  	payNeiLi = 160	, payGold = 300,	       neiLiLimit =        6986 },
[84]  ={  	payNeiLi = 160	, payGold = 300,	       neiLiLimit =        7085 },
[85]  ={  	payNeiLi = 160	, payGold = 300,	       neiLiLimit =        7169 },
[86]  ={  	payNeiLi = 160	, payGold = 300,	       neiLiLimit =        7269 },
[87]  ={  	payNeiLi = 160	, payGold = 300,	       neiLiLimit =        7354 },
[88]  ={  	payNeiLi = 160	, payGold = 300,	       neiLiLimit =        7454 },
[89]  ={  	payNeiLi = 160	, payGold = 300,	       neiLiLimit =        7538 },
[90]  ={  	payNeiLi = 180	, payGold = 380,	       neiLiLimit =        7638 },
[91]  ={  	payNeiLi = 180	, payGold = 380,	       neiLiLimit =        7723 },
[92]  ={  	payNeiLi = 180	, payGold = 380,	       neiLiLimit =        7825 },
[93]  ={  	payNeiLi = 180	, payGold = 380,	       neiLiLimit =        7909 },
[94]  ={  	payNeiLi = 180	, payGold = 380,	       neiLiLimit =        8011 },
[95]  ={  	payNeiLi = 180	, payGold = 380,	       neiLiLimit =        8096 },
[96]  ={  	payNeiLi = 180	, payGold = 380,	       neiLiLimit =        8198 },
[97]  ={  	payNeiLi = 180	, payGold = 380,	       neiLiLimit =        8284 },
[98]  ={  	payNeiLi = 180	, payGold = 380,	       neiLiLimit =        8386 },
[99]  ={  	payNeiLi = 180	, payGold = 380,	       neiLiLimit =        8471 },
[100]  ={  	payNeiLi = 200	, payGold = 480,           neiLiLimit =        8575 }
}

function ShenBingLayer:init()
	self._UI = require("Layer/ShenBing/ShenBingUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self.Sprite_background:setVisible(false)
	self.Sprite_bottom:setVisible(false)

	self:initRichText()
	--初始化调用函数
	self:ButtonBack()
	self:ButtonOuYeZi()

	if not User:getRole().shenBingweapon.changeEquipTextUnwieldText then
		self:changeEquipTextUnwieldText()
	end

	self:schedule(function(ft)
	self:update(ft)
	end, 1)


	--如果没有onlyId，生成一个onlyId
	local role = User:getRole()
	if role.shenBingweapon.onlyId == nil then
		role.shenBingweapon.onlyId = User:getRoleAttr("userid")..role:getItemOnlyId()
		print("----role.shenBingweapon.onlyId---------------------"..tostring(role.shenBingweapon.onlyId))
	end
end
function ShenBingLayer:changeEquipTextUnwieldText()
	local role = User:getRole()
	local shenBingweapon = role.shenBingweapon
	shenBingweapon.changeEquipTextUnwieldText = true
	if role.shenBingweapon.status == "2" then
		if role.shenBingweapon.type == "剑" then
			shenBingweapon.unwieldText = "WHT$N手中"..shenBingweapon.colorname..shenBingweapon.name.."WHT迎风一抖，眨眼间已然不见影踪。" ---回鞘特效
			shenBingweapon.equipText = "WHT$N往腰中一带，抽出了一口"..shenBingweapon.colorname..shenBingweapon.name.."WHT握在手中。" --拔剑特效
		elseif role.shenBingweapon.type == "刀" then
			shenBingweapon.unwieldText = "WHT$N手中"..shenBingweapon.colorname..shenBingweapon.name.."WHT迎风一抖，眨眼间已然不见影踪。"---回鞘特效
			shenBingweapon.equipText =  "WHT$N往腰中一带，抽出了一口"..shenBingweapon.colorname..shenBingweapon.name.."WHT握在手中。" --拔剑特效
		elseif role.shenBingweapon.type == "鞭" then
			shenBingweapon.unwieldText = "WHT$N手中"..shenBingweapon.colorname..shenBingweapon.name.."WHT一抖，眨眼间卷回腰间不见了影踪。" ---回鞘特效
			shenBingweapon.equipText = "WHT$N往腰中一摸，刷的抖出了一根"..shenBingweapon.colorname..shenBingweapon.name.."WHT。"--拔剑特效
		else
			shenBingweapon.unwieldText = "WHT$N手中"..shenBingweapon.colorname..shenBingweapon.name.."WHT抖出一个棍花，眨眼间已然不见影踪。"  ---回鞘特效
			shenBingweapon.equipText =  "WHT$N往腰中一摸，拿出了一把"..shenBingweapon.colorname..shenBingweapon.name.."WHT，端在手中。"  --拔剑特效
		end
	end
end
function  ShenBingLayer:refushUI()
	local role = User:getRole()
	local Type = role.shenBingweapon.type

	if Type then
		if  role.shenBingweapon.status == "10"   then

			self.Panel_DuanZaoZhong:setVisible(true)
			self.Panel_DuanZaoZhong.Text_Time1:setVisible(true)

		elseif role.shenBingweapon.status == "1"   then

			self.Panel_DuanZaoZhong.Button_2.Text_button2Name:setString("领取")
			self.Panel_DuanZaoZhong:setVisible(true)
			self.Panel_DuanZaoZhong.Text_Time1:setVisible(false)
			self:print("YEL欧冶子："..User:getRole().shenBingweapon.type.."已造好，神兵有名方能传，你的兵器该什么名？")
		elseif role.shenBingweapon.status == "2" then

		end
	end
end


local textTalk =
{

	[1] = "HIC前方一个巨大的炉子前站着一位长髯老者正看着炉火想着什么心事。\n旁边几个彪形大汉正挥舞着锤头敲打着一块似乎总也烧不红的什么金属。\n旁边仔细的放着几把刚刚出炉的兵器。那种骇人的杀气竟是从这些兵器上散发出来的。"

}

function ShenBingLayer:printTextInTime(text,time)


end
local beginPrintTalkTextNum
function ShenBingLayer:onResume()
	self:setNeiLiAndGold()
	self:DuanZaoZhong()
	self:DuanZao()
	self:show()

    beginPrintTalkTextNum = 1
    --处理打造中欧冶子说话内容
    -- if User:getRole().shenBingweapon.status == "10" then
    -- 	self:DaZaoTalkText()
    -- end
end
local text =
{
	[29] = "YEL欧冶子：好我们现在就开始造$w。侍$w！",
	[28] = "CYN欧冶子招来一位白衣少年，对他耳语几句。",
	[26] ="YEL侍$w点了点头。说：好吧！",
	[25] = "CYN侍$w回过身，转向身后的一个巨大的火炉，鼓动真气燃起了熊熊的大火。说：开始！",
	[23] = "BLU你双手握住一个巨大的铁锤，猛的向炉中渐渐红热起来的$Q挥去！ ",
	[22] = "RED只听得棚的一声巨响，锤头和$Q粘在了一起。",
	[21] = "YEL你只觉得掌心一热，浑身的血液似乎都沸腾了起来！",
	[20] = "HIM一身精血胶合着汩汩的内气，源源不断的向炉中的$Q涌去！",
	[19] = "HIR突然$N觉得气血一阵翻涌，一口真气接不上来。。。。",
	[13] = "HIR只听咯的一声轻响，$w从炉中倏然跃起。化作一道青电猛的向你的前胸刺来！！",
	[12] = "YEL侍剑见状大叫：神$w初成，人血以祭！！闪开！",
	[11] = "CYN你只觉得眼前一花，一条白影迅捷无比的挡在了你的身前。",
	[10] = "CYN$w透胸穿出，侍$w惨号一声，鲜血溅得你满脸都是！",
	[9] = "RED侍$w脚下一个不稳，倒在了地上。侍$w已经奄奄一息了。",
	[8] = "CYN$w又飞了起来，飞到半空，当的一声落回到地上。",
	[7] = "CYN炉中的火灭了。一室的劲气化于无形，一切又归于沉寂。" ,
	[5] = "YEL侍$w摸起地上，带着斑斑血迹还有些烫手的$w，说：$w。。已。。成。。，侍$w的任务。。。也就完成了。。。。",
	[3] = "YEL侍$w艰难的说：$w。。您。。收好，我该走了。。。",
	[2] = "CYN侍$w说完。倏的便不见了。",
}
function ShenBingLayer:DaZaoTalkText()

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
function ShenBingLayer:replaceText()
	local role = User:getRole()
	if role.shenBingweapon.type == "剑" then
		text[28] = "CYN欧冶子招来一位表情冷峻的白衣少年，对他耳语几句。"
		text[11] = "CYN你只觉得眼前一花，一条白影迅捷无比的挡在了你的身前。"
	elseif role.shenBingweapon.type == "鞭" then
		text[28] = "CYN欧冶子招来一位身着青衣的妙龄少女，对他耳语几句。"
		text[11] = "CYN你只觉得眼前一花，一条青影迅捷无比的挡在了你的身前。"
	elseif role.shenBingweapon.type == "棍" then
		text[28] = "CYN欧冶子招来一位外表憨厚的年轻小伙，对他耳语几句。"
		text[11] = "CYN你只觉得眼前一花，一条白影迅捷无比的挡在了你的身前。"
	else
		text[28] = "CYN欧冶子招来一位皮肤黝黑的蓝衣少年，对他耳语几句。"
		text[11] = "CYN你只觉得眼前一花，一条蓝影迅捷无比的挡在了你的身前。"
	end
end
function ShenBingLayer:update()


	--d打印聊天的文本
	-- if beginPrintTalkTextNum <= #textTalk then
	-- 	self:print(textTalk[beginPrintTalkTextNum])
	-- 	beginPrintTalkTextNum = beginPrintTalkTextNum +1
	-- end

	local  role  = User:getRole()
	--"10"表示正在打造中
	if role.shenBingweapon.status == "10" then
		local time =math.ceil(GetTime() -  role.shenBingweapon.beginDazaoTime)
		local i = tonumber(FIRST_DUANZAO - time)
		self.Panel_DuanZaoZhong.Text_Time1:setString(tostring(tonumber(FIRST_DUANZAO - time)))

		--输出打造语句
		do
			local name = Item:getOneItemByKey(role.shenBingweapon.material).name
			-- if tonumber(FIRST_DUANZAO - time)%2 == 0 and i <= #text then
			if text[i]  then
				self:replaceText()
				text[i] = string.gsub(text[i], "$N", "你")
				text[i] = string.gsub(text[i], "$w",role.shenBingweapon.type)
				text[i] = string.gsub(text[i], "$W", role.shenBingweapon.type)
				text[i] = string.gsub(text[i], "$Q", name)
				self:print(text[i])
				text[i] = nil
			end

		end

		if time >= FIRST_DUANZAO then
			role.shenBingweapon.status = "1"
		end
		-- 刷新UI
		self:refushUI()
	elseif role.shenBingweapon.status == "1" then

	elseif role.shenBingweapon.status == "2" then

	end
	-- if tonumber(time) <= 0 then
	-- 	-- self.Panel_DuanZaoZhong:setVisible(true)
	-- 	-- self.Panel_DuanZaoZhong.Text_Time1:setVisible(false)
	-- 	-- shenBingLayer.Panel_DuanZaoZhong:setVisible(false)
	-- 	-- --这里处理兵器打造完成后，应该显示的界面
	-- 	--神兵已经存在，名字为命名
	-- 	User:getRole().shenBingweapon.status = "1"
	-- 	if PRINT_MODE ==1  then
	-- 		print("888888888888***********************"..tostring(User:getRole().shenBingweapon.status))
	-- 	end

	-- 	-- self:print("YEL欧冶子："..User:getRole().shenBingweapon.type.."已造好，请给它取个名字吧！")
	-- 	-- self.Panel_DuanZaoZhong.Button_2.Text_button2Name:setString("领取")
	-- end
	-- self.Panel_DuanZaoZhong.Text_Time1:setString(tostring(tonumber(time)-1))
end
-- ---进入界面播放声音
function ShenBingLayer:playEffectEnter()
	Audio:playEffect("jinrujiemian")
	self:delayFunc(0.5,function()
		Audio:playEffect("jinrujiemian")
	end)
	self:delayFunc(1.5,function()
		Audio:playEffect("jinrujiemian")
	end)
end
function ShenBingLayer:show()
	self:setVisible(true)
	self.Panel_DuanZao:setVisible(false)
	self.Text_desc:setVisible(true)
	self.Button_1:setVisible(true)
	--神兵界面对打造显示的控制
	if PRINT_MODE ==1 then
		print("------------------------------------"..tostring(User:getRole().shenBingweapon.status))
	end

	if User:getRole().shenBingweapon.status ~= "0"  then
		self.Panel_DuanZaoZhong:setVisible(true)
	elseif User:getRole().shenBingweapon.status == "0" and User:getRole().shenBingweapon.type == nil then
		self.Panel_DuanZaoZhong:setVisible(false)
	end

	--打造中按钮特殊处理
	if User:getRole().shenBingweapon.status == "2" then
		self.Panel_DuanZaoZhong.Button_2.Text_button2Name:setString("强化")
		self.Panel_DuanZaoZhong.Image_myweapon.Text_Weapon1:setString(User:getRole().shenBingweapon.name)
		self.Panel_DuanZaoZhong.Image_myweapon.Text_Weapon1:setColor(User:getRole().shenBingweapon.color)
	elseif User:getRole().shenBingweapon.status == "1" then
		self.Panel_DuanZaoZhong.Button_2.Text_button2Name:setString("领取")
		self.Panel_DuanZaoZhong.Image_myweapon.Text_Weapon1:setString("我的"..User:getRole().shenBingweapon.type)

	else
		-- self.Panel_DuanZaoZhong.Text_Weapon1:setString(User:getRole().shenBingweapon.name)
		if User:getRoleAttr("shenBingweapon").type ~= nil then -- add by XiaoZhiWei 2017/03/14 10:24:13 修复神兵文本错误 , 细化名称
			self.Panel_DuanZaoZhong.Image_myweapon.Text_Weapon1:setString("自制的长剑")
		elseif User:getRoleAttr("shenBingweapon").type == "刀" then
			self.Panel_DuanZaoZhong.Image_myweapon.Text_Weapon1:setString("自制的钢刀")
		elseif User:getRoleAttr("shenBingweapon").type == "鞭" then
			self.Panel_DuanZaoZhong.Image_myweapon.Text_Weapon1:setString("自制的长鞭")
		elseif User:getRoleAttr("shenBingweapon").type == "棍" then
			self.Panel_DuanZaoZhong.Image_myweapon.Text_Weapon1:setString("自制的钢棍")
		else
			self.Panel_DuanZaoZhong.Image_myweapon.Text_Weapon1:setString("自制的神兵")
		end

		self.Panel_DuanZaoZhong.Button_2.Text_button2Name:setString("正在打造")
	end
	--对显示时间的控制
	if User:getRole().shenBingweapon.status == "0"  and tonumber(self.Panel_DuanZaoZhong.Text_Time1:getString()) ~= nil and tonumber(self.Panel_DuanZaoZhong.Text_Time1:getString()) > 0 then
		self.Panel_DuanZaoZhong.Text_Time1:setVisible(true)
		self.Panel_DuanZaoZhong.Button_2.Text_button2Name:setString("打造中")
	else
		self.Panel_DuanZaoZhong.Text_Time1:setVisible(false)
	end

end
function ShenBingLayer:initRichText()
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
function ShenBingLayer:print(str, verticalSpace)
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
--点击欧冶子
function ShenBingLayer:ButtonOuYeZi()
	self.Button_1:setButtonType(WIDGET_TOUCH_VOICE_SMALLBUTTON)
	self.Button_1:releaseFunc(function()
		PopupLayerController:showLayer("ShenBingObserveLayer", function(layer)
			layer:show(MainControllLayer)
		end)
	end)
end

--设置内力和金钱数值
function ShenBingLayer:setNeiLiAndGold()
	if PRINT_MODE ==1  then
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	end
	local role = User:getRole()
	local neili,neiliMax = math.ceil(role:getAttr("neili")),math.ceil(role:getFinalAttr("neiliMax"))
	local gold = role: getAttr("gold")
	self.Text_NeiLi:setString("『内力』"..tostring(neili).."/"..tostring(neiliMax))
	self.Text_Gold:setString("『黄金』"..tostring(gold))
end

--返回按钮
function ShenBingLayer:ButtonBack()
	self.Image_titleShenBing.Button_back:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BACKBUTTON)
	self.Image_titleShenBing.Button_back:releaseFunc(function()
		self:hide()
	end)
end



---点击强化的后升级点数的确定（跟福缘有关）
--1次增加1 点概率= 1-min（ 0.6*（福缘-20 ），24） *66/5000
--1次增加2 点概率=min（ 0.6*（福缘-20 ），24） /100
--1次增加3 点概率= min（ 0.6*（福缘-20 ），24） /500
--1次增加4 点概率= min（ 0.6*（福缘-20 ），24） /1000
--1次增加5 点概率= min（ 0.6*（福缘-20 ），24） /5000

function ShenBingLayer:times()
	local  role  = User:getRole()
	local str
	local luck = role:getFinalAttr("luck")
	local x = math.random(0,1000)/1000
	print("---------------------------"..tostring(x))
	if luck <= 20 then
		return 2
	end
	if x >=0 and x  <= math.min(0.6 * (luck -20),24)/50000 then
		return 10
	elseif  x > math.min(0.6 * (luck -20),24)/50000 and x <= math.min(0.6 * (luck -20),24)/1000 then
		return 8
	elseif x > math.min(0.6 * (luck -20),24)/1000 and x < math.min(0.6 * (luck -20),24)/500  then
		return  6
	elseif x > math.min(0.6 * (luck -20),24)/500 and x <	math.min(0.6 * (luck -20),24)/100 then
		return 4
	else
		return 2
	end
end
-- function ShenBingLayer:strPop(times)
-- 	local str
-- 	if times == 5 then str ="你深深的吸了一口气，全身心的投入了进去，强化成功，进度 +5"
-- 	elseif times == 4 then str = "你有节奏的强化着，强化成功，进度 +4"
-- 	elseif times ==3 then str = "你突然领悟了什么，强化成功，进度 +3"
-- 	elseif times ==2 then str ="你觉得这样可能更好，强化成功，进度 +2"
-- 	else str = 	"强化成功 进度+1"
-- 	end
-- 	return str
-- end
--c初始化的时候显示神兵的描述
function ShenBingLayer:ShenBingDesc()
	--初始化的时候，如果神兵没有升级过，就是原始描述，根据类别设置一个最原始的描述
	local role = User:getRole()
	local str
	if role.shenBingweapon.name ~=nil and role.shenBingweapon.name~="" and role.shenBingweapon.lv <= 1 then

		if role.shenBingweapon.type == "剑" then
			str = "这是一把剑，重约五斤，尚未开刃，似乎一碰即碎，无甚奇异。"
		end
		if role.shenBingweapon.type == "刀" then
			str = "这是一把刀，重约七斤，尚未开刃，似乎一碰即碎，无甚奇异。"
		end
		if role.shenBingweapon.type == "棍" then
			str = "这是一根棍，重约七斤，看上去极易折断无甚奇异。"
		end
		if role.shenBingweapon.type == "鞭" then
			str = "这是一跟鞭，重约两斤，鞭身似乎十分松散，一拉即断，无甚奇异。"
		end
		self:setWeaponDesc(str)
		if PRINT_MODE ==1 then
			print("self:setWeaponDesc(str)8888888888888888888888888888888888888")
		end
	end
end

function ShenBingLayer:goldTimesReminder(times)
	local  role = User:getRole()
	if times ==2 then
		--弹出语句的特殊处理
		if role.shenBingweapon.type == "鞭" or role.shenBingweapon.type == "剑" then
			self:print("HIY"..role.shenBingweapon.type.."身忽的一亮，一道金光隐入"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIY的"..role.shenBingweapon.type.."体，不见了！")
		elseif role.shenBingweapon.type == "刀" then
			self:print("HIY刀身忽的一闪，一道银光隐入"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIY的刀中，不见了！")
		else
			self:print("HIY棍身忽的一亮，似乎一种新生的力量在"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIY中涌动起来！")
		end

		if role.shenBingweapon.type == "剑" or role.shenBingweapon.type == "刀" then
			self:print("RED你的"..role.shenBingweapon.colorname..role.shenBingweapon.name.."RED的"..role.shenBingweapon.type.."气提升了!")
		else
			self:print("RED你的"..role.shenBingweapon.colorname..role.shenBingweapon.name.."RED的质地提升了!")
		end
	else
		--弹出语句的特殊处理
		if role.shenBingweapon.type == "鞭" then
			self:print("HIY鞭身闪烁着奇异的光芒，几种新生力量在"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIY中的涌动变得剧烈无比！")
		elseif role.shenBingweapon.type == "剑" then
			self:print("HIY剑身闪烁着奇异的光芒，数条金色的细流缓缓地融入了"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIY的剑体，消失不见了！")
		elseif role.shenBingweapon.type == "刀" then
			self:print("HIY刀身闪烁着奇异的光芒，数条金色的细流缓缓地融入了"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIY的剑体，消失不见了！")
		else
			self:print("HIY棍身闪烁着奇异的光芒，几种新生力量在"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIY中的涌动变得剧烈无比！")
		end

		if role.shenBingweapon.type == "剑" or role.shenBingweapon.type == "刀" then
			self:print("HIR你的"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIR的"..role.shenBingweapon.type.."气明显提升了!")
		else
			self:print("HIR你的"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIR的质地提升了!")
		end
	end
end
function ShenBingLayer:neiLiTimesReminder(times)
	local  role = User:getRole()
	if times == 2 then --如果是进度加一
		if role.shenBingweapon.type == "鞭" then
			self:print("HIR手指"..role.shenBingweapon.type.."HIR稍，一股内力丝丝的传了进去。")
		else
			self:print("HIR手指"..role.shenBingweapon.type.."脊，一股内力丝丝的传了进去。")
		end

		if role.shenBingweapon.type == "剑" or role.shenBingweapon.type == "刀" then
			self:print("RED你的"..role.shenBingweapon.colorname..role.shenBingweapon.name.."RED的"..role.shenBingweapon.type.."气提升了!")
		else
			self:print("RED你的"..role.shenBingweapon.colorname..role.shenBingweapon.name.."RED的质地提升了!")
		end
	else
		if role.shenBingweapon.type == "鞭" then
			self:print("HIR你手捏"..role.shenBingweapon.type.."稍，心念合一，一股纯净的内力丝丝的透了进去。")
		else
			self:print("HIR你手指"..role.shenBingweapon.type.."脊，心念合一，一股纯净的内力丝丝的透了进去。")
		end

		if role.shenBingweapon.type == "剑" or role.shenBingweapon.type == "刀" then
			self:print("HIR你的"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIR的"..role.shenBingweapon.type.."气提升了!")
		else
			self:print("HIR你的"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIR的质地明显改善了!!")
		end
	end
end
--锻造界面的控制
function ShenBingLayer:DuanZao()
	-- self:ShenBingDesc()

	local role = User:getRole()
	local persent
	local times --,strPop --点击一次实质增加的点数


	-- if role.shenBingweapon.dsc ~= " "  then
		self:setWeaponDesc(role.shenBingweapon.dsc)
	-- end
	--神兵打造完成后才有强化界面
	if role.shenBingweapon.status == "2" then
		--界面初始化
		self.Panel_DuanZao.Text_jianqi:setString(role.shenBingweapon.type.."气")
		self.Panel_DuanZao.Text_Weapon1:setString(role.shenBingweapon.name)
		self.Panel_DuanZao.Text_Weapon1:setColor(role.shenBingweapon.color)
		self.Panel_DuanZao.Text_Damage:setString("伤害力+"..role.shenBingweapon.damage)
		--刷新内力黄金
		self:setNeiLiAndGold()

		--进来的时候设置百分显示
		self.Panel_DuanZao.Image_LoadingBar_jianqi.LoadingBar_jianqi:setPercent(role.shenBingweapon.loadingBarPersent)



		--进来的时候应该显示当前需要消耗的内力和黄金
		print("::::::::::::::::::::::::::::::"..tostring(role.shenBingweapon.lv))
		if tonumber(role.shenBingweapon.lv) >= SHENBING_LV_LIMIT and role.shenBingweapon.loadingBarPersent >=100 then
			self.Panel_DuanZao.Button_NeiLi.Text_neili:setString("神兵等级已经最高了")
			self.Panel_DuanZao.Button_Gold.Text_Gold:setString("神兵等级已经最高了")
		else
			local needNeiLi = lv[role.shenBingweapon.lv].payNeiLi
			local needGold = lv[role.shenBingweapon.lv].payGold

			-- 经脉印记效果 内力 黄金消耗-10%
			if role:isHaveImprintingId("xuanbingyin") then
				local meridianBuffValue = Meridian:getMeridianBuffValue("xuanbingyin")
				needNeiLi = math.ceil(needNeiLi * meridianBuffValue)
			end
			if role:isHaveImprintingId("lingbingyin") then
				local meridianBuffValue = Meridian:getMeridianBuffValue("lingbingyin")
				needGold = math.ceil(needGold * meridianBuffValue)
			end

			self.Panel_DuanZao.Button_NeiLi.Text_neili:setString("消耗内力上限" .. needNeiLi)
			self.Panel_DuanZao.Button_Gold.Text_Gold:setString("消耗黄金" .. needGold)
		end


		-- self.Panel_DuanZao.Button_NeiLi:setButtonType(WIDGET_TOUCH_VOICE_SMALLBUTTON)
		self.Panel_DuanZao.Button_NeiLi:releaseFunc(function ()


			--按钮间隔时间处理
			if DEBUG_MODE ==2  then
				if not self._currNeiLiTime or GetTime() - self._currNeiLiTime >= 0.5 then
					self._currNeiLiTime = GetTime()
				else
					PopText("你动作太快了，精炼神兵切勿急躁，请稍定心神。")
					return
				end
			end
			local qi = role:getAttr("qi")
			local jing = role:getAttr("jing")
			local neiliMax = role:getFinalAttr("neiliMax") -- 目前所有的内力 ，，记得测试，是否数值正确neiliMax
			local neili = role:getAttr("neili")

			local needNeiLi = lv[role.shenBingweapon.lv].payNeiLi
			local needGold = lv[role.shenBingweapon.lv].payGold

			-- 经脉印记效果 内力 黄金消耗-10%
			if role:isHaveImprintingId("xuanbingyin") then
				local meridianBuffValue = Meridian:getMeridianBuffValue("xuanbingyin")
				needNeiLi = math.ceil(needNeiLi * meridianBuffValue)
			end
			if role:isHaveImprintingId("lingbingyin") then
				local meridianBuffValue = Meridian:getMeridianBuffValue("lingbingyin")
				needGold = math.ceil(needGold * meridianBuffValue)
			end

			--按按钮的时候就判断，如果等级大于等于100并且getpersent大于等于100,则返回
			if role.shenBingweapon.lv >= SHENBING_LV_LIMIT and role.shenBingweapon.loadingBarPersent >=100 then
				PopText("最高升级等级为100级！！！")
				-- print("9999999999999999999999999999999999999999999")
				--处理已经消耗的内力，退还给玩家
				return
			end

			--判断内力上限
			-- print("...................................."..tostring(neiLiLimit).."         "..tostring(lv[role.shenBingweapon.lv].neiLiLimit))
			if role.shenBingweapon.lv <= SHENBING_LV_LIMIT and neiliMax < lv[role.shenBingweapon.lv].neiLiLimit then
				PopText("你的内力上限太低了，无法锻炼兵器！")
				return
			end
			--判断气血和精力
			if role.shenBingweapon.lv <= SHENBING_LV_LIMIT and jing < SHENBING_PAY_JING then
				PopText("你的精力太低了，无法集中精力锻炼！")
				return
			end
						--判断气血和精力
			if role.shenBingweapon.lv <= SHENBING_LV_LIMIT and qi < SHENBING_PAY_QI then
				PopText("你的气血太少了，再练下去怕是有生命危险！")
				return
			end
			--判断是否有足够的内力来升级
			if role.shenBingweapon.lv <= SHENBING_LV_LIMIT
					and (neiliMax < needNeiLi or neili < needNeiLi) then

				PopText("你的内力不足以支持你继续强化武器，请打坐后再来")
				return
			end


			--剑气的进度条
			times= self:times()
			--弹出话语的确定
			-- local strPop = self:strPop(times)

			local neiliToCast
			--c处理黄金内力消耗的效果属性
			if role.shenBingweapon.loadingBarPersent/10 + times >= 10 then
				neiliToCast = 10 - role.shenBingweapon.loadingBarPersent/10
			else
				neiliToCast = times
			end

			--剑气满了以后，这次升级完成，应该清零剑气，神兵等级加一,并告诉服务器
			if role.shenBingweapon.loadingBarPersent + neiliToCast*10 < 100 then


				--播放升级声音
				Audio:playEffect("qianghua")
				if role.shenBingweapon.lv <= SHENBING_LV_LIMIT then
					--内力成长值的统计
					role.shenBingweapon.neilicast = role.shenBingweapon.neilicast + neiliToCast
					role.shenBingweapon.neili_level = role.shenBingweapon.neili_level + lv[role.shenBingweapon.lv].payNeiLi
				end

				--打印信息
				--弹出语句的特殊处理
				self:neiLiTimesReminder(times)



				if role.shenBingweapon.lv <= SHENBING_LV_LIMIT then
					PopText("消耗掉"..tostring(needNeiLi).."内力上限")
				end
				if role.shenBingweapon.lv <= SHENBING_LV_LIMIT then
					--消耗内力 和 内力最大值
					User:addRoleAttr("neili",tonumber(- needNeiLi ))
					User:addRoleAttr("neiliMax",tonumber(- needNeiLi))
					User:addRoleAttr("qi",tonumber( math.ceil(- SHENBING_PAY_QI)))
					User:addRoleAttr("jing",tonumber(- SHENBING_PAY_JING))
				end

				persent = role.shenBingweapon.loadingBarPersent + times*10
				role.shenBingweapon.loadingBarPersent = persent
				self.Panel_DuanZao.Image_LoadingBar_jianqi.LoadingBar_jianqi:setPercent(persent)

				--升级点数的提示
				-- PopText(strPop)
				-- self:print(strPop)

				--刷新面板数值
				self.Panel_DuanZao.Text_Damage:setString("伤害力+"..role.shenBingweapon.damage)
				--刷新内力黄金
				self:setNeiLiAndGold()


			else
				--不能超过一百级
				if role.shenBingweapon.lv +1 > SHENBING_LV_LIMIT  then
					print("::@@@@@@@@@@@@@@@@@@@@@@@@"..tostring(role.shenBingweapon.lv))
					--对最后升级满了，剑气应该设置成100，
					role.shenBingweapon.loadingBarPersent = 100
					self.Panel_DuanZao.Image_LoadingBar_jianqi.LoadingBar_jianqi:setPercent(100)
					self.Panel_DuanZao.Button_NeiLi.Text_neili:setString("神兵等级已经最高了")
					self.Panel_DuanZao.Button_Gold.Text_Gold:setString("神兵等级已经最高了")
					PopText("最高升级等级为100级！！！")
					--处理已经消耗的内力，退还给玩家
					return
				end

				--向服务器发送的等级(升级后发送)
				-- 升级
			    local  Type =1
			    if role.shenBingweapon.type == "剑" then Type = 1 end
			    if role.shenBingweapon.type == "刀" then Type = 2 end
			    if role.shenBingweapon.type == "棍" then Type = 3 end
			    if role.shenBingweapon.type == "鞭" then Type = 4 end

				local params2 =
				{

					weapon_type = Type,
					weapon_name = role.shenBingweapon.name,
					weapon_color = role.shenBingweapon.colorid,
					weapon_gold_level = role.shenBingweapon.gold_level,
					weapon_neili_level = role.shenBingweapon.neili_level,
					weapon_neilicast = role.shenBingweapon.neilicast + neiliToCast,
					weapon_goldcast = role.shenBingweapon.goldcast,
				}

				HttpManagerEx:upgradeWeapon(params2, function(status, errcode, errmsg, data)
					if 200 == status  then
						if 0 == errcode then
							self:setWeaponDesc(data.desc)
							--处理进入界面时候，武器描述为原始的情况，应该记录最新的描述，下次进来设置上去
							role.shenBingweapon.dsc = data.desc
							-- ---处理第一批的神兵没有描述的问题
							-- role.shenBingweapon.dsc = role.shenBingweapon.strDesc -- 武器描述

							--播放升级声音
							Audio:playEffect("shengji")
							--只有向服务器申请成功才能升级

							if role.shenBingweapon.lv <= SHENBING_LV_LIMIT then
								--内力成长值的统计
								role.shenBingweapon.neilicast = role.shenBingweapon.neilicast + neiliToCast
								role.shenBingweapon.neili_level = role.shenBingweapon.neili_level + lv[role.shenBingweapon.lv].payNeiLi
							end

							--打印信息
							--升级点数的提示
							-- PopText(strPop)
							-- self:print(strPop)

							self:neiLiTimesReminder(times)


							if role.shenBingweapon.lv <= SHENBING_LV_LIMIT then
								PopText("消耗掉"..tostring(needNeiLi).."内力上限")
							end

							role.shenBingweapon.loadingBarPersent = 0
							self.Panel_DuanZao.Image_LoadingBar_jianqi.LoadingBar_jianqi:setPercent(0)

							--升级一次伤害力加一
							role.shenBingweapon.damage = role.shenBingweapon.damage +1
							role.shenBingweapon.lv =role.shenBingweapon.lv +1
							if PRINT_MODE ==1 then
								print("8***************************************目前我的等级"..tostring(role.shenBingweapon.lv))
							end
							self:print("HIG你的"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIG的等级提高了！")

							--内力消耗
							if role.shenBingweapon.lv <= SHENBING_LV_LIMIT then
								--消耗内力 和 内力最大值   精力和气血
								User:setRoleAttr("neili",tonumber(neili - needNeiLi ))
								User:setRoleAttr("neiliMax",tonumber(neiliMax - needNeiLi))
								User:setRoleAttr("qi",tonumber(tonumber(qi) - SHENBING_PAY_QI ))
								User:setRoleAttr("jing",tonumber(tonumber(jing) -SHENBING_PAY_JING ))
							end

							--更新黄金显示数量
							if tonumber(role.shenBingweapon.lv) >= SHENBING_LV_LIMIT and role.shenBingweapon.loadingBarPersent >=100  then
								self.Panel_DuanZao.Button_NeiLi.Text_neili:setString("神兵等级已经最高了")
								self.Panel_DuanZao.Button_Gold.Text_Gold:setString("神兵等级已经最高了")
							else
								local needNeiLi = lv[role.shenBingweapon.lv].payNeiLi
								local needGold = lv[role.shenBingweapon.lv].payGold

								-- 经脉印记效果 内力 黄金消耗-10%
								if role:isHaveImprintingId("xuanbingyin") then
									local meridianBuffValue = Meridian:getMeridianBuffValue("xuanbingyin")
									needNeiLi = math.ceil(needNeiLi * meridianBuffValue)
								end
								if role:isHaveImprintingId("lingbingyin") then
									local meridianBuffValue = Meridian:getMeridianBuffValue("lingbingyin")
									needGold = math.ceil(needGold * meridianBuffValue)
								end

								self.Panel_DuanZao.Button_NeiLi.Text_neili:setString("消耗内力上限" .. needNeiLi)
								self.Panel_DuanZao.Button_Gold.Text_Gold:setString("消耗黄金" .. needGold)
							end

							--刷新面板数值
							self.Panel_DuanZao.Text_Damage:setString("伤害力+"..role.shenBingweapon.damage)
							--刷新内力黄金
							self:setNeiLiAndGold()


							if PRINT_MODE ==1 then
								print("****************************************************"..tostring(role.shenBingweapon.neilicast))
								print("****************************************************"..tostring(role.shenBingweapon.goldcast))
							end
						else
							PopText(tostring(errmsg))
						end
						return true
					else
			    		PopText("网络请求出错,请换个网络环境再试!")
					end
				end,IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)

			end

		end)

		-- self.Panel_DuanZao.Button_Gold:setButtonType(WIDGET_TOUCH_VOICE_SMALLBUTTON)
		self.Panel_DuanZao.Button_Gold:releaseFunc(function ()


			--按钮间隔时间处理
			if DEBUG_MODE ==2 then
				if not self._currGoldTime or GetTime() - self._currGoldTime >= 0.5 then
					self._currGoldTime = GetTime()
				else
					PopText("你动作太快了，精炼神兵切勿急躁，请稍定心神。")
					return
				end
			end
			local gold = role:getAttr("gold")

			local needNeiLi = lv[role.shenBingweapon.lv].payNeiLi
			local needGold = lv[role.shenBingweapon.lv].payGold

			-- 经脉印记效果 内力 黄金消耗-10%
			if role:isHaveImprintingId("xuanbingyin") then
				local meridianBuffValue = Meridian:getMeridianBuffValue("xuanbingyin")
				needNeiLi = math.ceil(needNeiLi * meridianBuffValue)
			end
			if role:isHaveImprintingId("lingbingyin") then
				local meridianBuffValue = Meridian:getMeridianBuffValue("lingbingyin")
				needGold = math.ceil(needGold * meridianBuffValue)
			end

			--按按钮的时候就判断，如果等级大于等于100并且getpersent大于等于100,则返回
			if role.shenBingweapon.lv >= SHENBING_LV_LIMIT and role.shenBingweapon.loadingBarPersent >=100 then
				PopText("最高升级等级为100级！！！")
				print("::@!!!!!!!!!!!!!!!!!!!!!!!!!!!"..tostring(role.shenBingweapon.lv))
				--处理已经消耗的内力，退还给玩家
				return
			end
			if role.shenBingweapon.lv <= SHENBING_LV_LIMIT and gold < needGold then
				PopText("你的黄金不够，去苏州城王合计处看看吧")
				return
			end
			--剑气的进度条
			times = self:times()
			-- local strPop = self:strPop(times)

			--c处理黄金内力消耗的效果属性
			local  goldToCast
			if role.shenBingweapon.loadingBarPersent/10 + times >= 10 then
				goldToCast = 10 - role.shenBingweapon.loadingBarPersent/10
			else
				goldToCast = times
			end


			--剑气满了以后，这次升级完成，应该清零剑气，神兵等级加一,并告诉服务器
			if role.shenBingweapon.loadingBarPersent + goldToCast*10 <100 then
				--升级点数的提示
				-- PopText(strPop)
				-- self:print(strPop)
				--提示描述
				self:goldTimesReminder(times)


				--播放升级声音
				Audio:playEffect("qianghua")

				if role.shenBingweapon.lv <= SHENBING_LV_LIMIT then
					User:setRoleAttr("gold",tonumber(gold - needGold))
					PopText("消耗掉" .. tostring(needGold).."黄金")
				end

				--百分比设置
				persent = role.shenBingweapon.loadingBarPersent + times*10
				role.shenBingweapon.loadingBarPersent = persent
				self.Panel_DuanZao.Image_LoadingBar_jianqi.LoadingBar_jianqi:setPercent(persent)

							--黄金成长值的统计
				if role.shenBingweapon.lv <= SHENBING_LV_LIMIT then
					role.shenBingweapon.goldcast = role.shenBingweapon.goldcast + goldToCast
					role.shenBingweapon.gold_level = role.shenBingweapon.gold_level + lv[role.shenBingweapon.lv].payGold
				end

				--伤害值得刷新
				self.Panel_DuanZao.Text_Damage:setString("伤害力+"..role.shenBingweapon.damage)
				--刷新内力黄金
				self:setNeiLiAndGold()
				if PRINT_MODE ==1 then
					print("****************************************************"..tostring(role.shenBingweapon.neilicast))
					print("****************************************************"..tostring(role.shenBingweapon.goldcast))
					print("&&&&&&"..tostring(role.shenBingweapon.material))
				end
			else
				if role.shenBingweapon.lv >= SHENBING_LV_LIMIT  then
					role.shenBingweapon.loadingBarPersent = 100
					self.Panel_DuanZao.Image_LoadingBar_jianqi.LoadingBar_jianqi:setPercent(100)
					self.Panel_DuanZao.Button_NeiLi.Text_neili:setString("神兵等级已经最高了")
					self.Panel_DuanZao.Button_Gold.Text_Gold:setString("神兵等级已经最高了")
					PopText("最高升级等级为100级！！！")
					return
				end

				--向服务器发送的等级(升级后发送)
				-- 升级
			    local  Type = 1
			    if role.shenBingweapon.type == "剑" then Type = 1 end
			    if role.shenBingweapon.type == "刀" then Type = 2 end
			    if role.shenBingweapon.type == "棍" then Type = 3 end
			    if role.shenBingweapon.type == "鞭" then Type = 4 end

				local params2 =
				{

					weapon_type = Type, ---武器类别
					weapon_name = role.shenBingweapon.name,---武器名称
					weapon_color = role.shenBingweapon.colorid,--武器颜色序号
					weapon_gold_level = role.shenBingweapon.gold_level,--累计的黄金消耗数量
					weapon_neili_level = role.shenBingweapon.neili_level,--累计的内力消耗
					weapon_neilicast = role.shenBingweapon.neilicast,--消耗内力产生的效果数（累计）
					weapon_goldcast = role.shenBingweapon.goldcast + goldToCast,--消耗黄金产生的效果数（累计）
				}

				HttpManagerEx:upgradeWeapon(params2, function(status, errcode, errmsg, data)
					if 200 == status then
						if 0 == errcode then
							self:setWeaponDesc(data.desc)
							--处理进入界面时候，武器描述为原始的情况，应该记录最新的描述，下次进来设置上去
							role.shenBingweapon.dsc = data.desc
							---处理第一批的神兵没有描述的问题
							-- role.shenBingweapon.dsc = role.shenBingweapon.strDesc -- 武器描述

							--播放升级声音
							Audio:playEffect("shengji")
							--升级点数的提示
							-- PopText(strPop)
							-- self:print(strPop)
							--只有向服务器申请成功才能升级
							--描述更改
							self:goldTimesReminder(times)

							-- if role.shenBingweapon.lv <= SHENBING_LV_LIMIT then
								User:setRoleAttr("gold",tonumber(gold - needGold))
								PopText("消耗掉"..tostring(needGold).."黄金")
							-- end

							role.shenBingweapon.loadingBarPersent = 0
							self.Panel_DuanZao.Image_LoadingBar_jianqi.LoadingBar_jianqi:setPercent(0)
							role.shenBingweapon.damage = role.shenBingweapon.damage +1
							role.shenBingweapon.lv =role.shenBingweapon.lv +1
							self:print("HIG你的"..role.shenBingweapon.colorname..role.shenBingweapon.name.."HIG的等级提高了！")

							--黄金成长值的统计
							if role.shenBingweapon.lv <= SHENBING_LV_LIMIT then
								role.shenBingweapon.goldcast = role.shenBingweapon.goldcast + goldToCast
								role.shenBingweapon.gold_level = role.shenBingweapon.gold_level + lv[role.shenBingweapon.lv].payGold
							end

						 --更新内力显示
							if tonumber(role.shenBingweapon.lv) >= SHENBING_LV_LIMIT and role.shenBingweapon.loadingBarPersent >=100 then
								self.Panel_DuanZao.Button_NeiLi.Text_neili:setString("神兵等级已经最高了")
								self.Panel_DuanZao.Button_Gold.Text_Gold:setString("神兵等级已经最高了")
							else
								local needNeiLi = lv[role.shenBingweapon.lv].payNeiLi
								local needGold = lv[role.shenBingweapon.lv].payGold

								-- 经脉印记效果 内力 黄金消耗-10%
								if role:isHaveImprintingId("xuanbingyin") then
									local meridianBuffValue = Meridian:getMeridianBuffValue("xuanbingyin")
									needNeiLi = math.ceil(needNeiLi * meridianBuffValue)
								end
								if role:isHaveImprintingId("lingbingyin") then
									local meridianBuffValue = Meridian:getMeridianBuffValue("lingbingyin")
									needGold = math.ceil(needGold * meridianBuffValue)
								end

								self.Panel_DuanZao.Button_NeiLi.Text_neili:setString("消耗内力上限" .. needNeiLi)
								self.Panel_DuanZao.Button_Gold.Text_Gold:setString("消耗黄金" .. needGold)
							end


							--伤害值得刷新
							self.Panel_DuanZao.Text_Damage:setString("伤害力+"..role.shenBingweapon.damage)
							--刷新内力黄金
							self:setNeiLiAndGold()
						else
							PopText(tostring(errmsg))
						end
						return true
					else
			    		PopText("网络请求出错,请换个网络环境再试!")
					end
				end,IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
			end
		end)
	end
end


--锻造中的界面的控制
function ShenBingLayer:DuanZaoZhong()
	-- local role = user:getRole()
	-- local bagItems = User:getRole():getItems()


	-- local dialog = DialogUseLayer:getInstance()
	-- dialog:show()
	-- dialog:setTextUseGoods("将消耗"..itemAttr.name)
	-- --确定按钮
	-- dialog:setButton_1(function()
	-- 	--删除玩家背包中的物品
	-- 	for i,item in ipairs(bagItems) do
	-- 		local item,i=role:getItemWithOnlyId(item.id)
	-- 		if item.id == itemAttr.id then
	-- 			table.remove(bagItems,i)
	-- 			break
	-- 		end
	-- 	end
	-- 	Poptext("消耗了"..itemAttr.name)
	-- 	--显示正在打造的界面

	-- end)
	-- --取消按钮
	-- dialog:setButton_2()

	--点击进入强化界面 或者取名界面
	self.Panel_DuanZaoZhong.Button_2:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		--在显示打造界面（强化界面时候）应该调用强化初始化一次
		self:DuanZao()
		local role = User:getRole()
		if User:getRole().shenBingweapon.status == "2" then
			self.Panel_DuanZaoZhong:setVisible(false)
			self.Panel_DuanZao:setVisible(true)
			self.Text_desc:setVisible(false)
			self.Button_1:setVisible(false)
		elseif User:getRole().shenBingweapon.status == "1" then
			---判断如果背包已经满了。不允许进入领取界面
			if #role:getItems() >= tonumber(role:getAttr("weight")) then
				PopText("背包已经满了，无法放下神兵")
				return
			end

			local role = User:getRole()
			if role.shenBingweapon.type == "剑" then
				Audio:playEffect("jianfaStart")
			elseif role.shenBingweapon.type == "刀" then
				Audio:playEffect("daofaStart")
			elseif role.shenBingweapon.type == "鞭" then
				Audio:playEffect("bianfaStart")
			elseif role.shenBingweapon.type == "棍" then
				Audio:playEffect("gunfaStart")
			elseif role.shenBingweapon.type == "双持" then
				Audio:playEffect("shuangchiStart")
			elseif role.shenBingweapon.type == "乐器" then
				Audio:playEffect("qinfaStart")
			end
			PopupLayerController:showLayer("DaZao", function(layer)
				layer:show(MainControllLayer)	
			end)
		else
			-- self.Panel_DuanZaoZhong.Button_2.Text_button2Name:setString("打造中")
			-- local daZao = DaZao:getInstance()
			-- daZao:show(MainControllLayer)
		end

	end)
end

function ShenBingLayer:weaponJifei(arg1,arg2)
    --击飞概率计算
    local jifeiOdds = "通过攻方和守方的武器重量值通过公式计算"
    if jifeiOdds >= math.random(1,100)/100 then
        return true
    end
    return false
end

function ShenBingLayer:weaponDaduan(arg1,arg2)
    -- 攻方武器耐久度受损=守方武器硬度*（1-攻方武器坚韧度*0.8）
    -- 守方武器耐久度受损=攻方武器硬度*1.2*（1-守方武器坚韧度*0.8/最高武器坚韧度）
    -- 若耐久度为0，则武器被打断。
    -- 当攻方兵器被打断时，该次攻击会立刻停止，并将攻方兵器设置为打断状态。
    -- 当守方兵器被打断时，将其视为无兵器状态，使用拳脚作为准备招式，并将守方兵器设置为打断状态。
    -- 当同时打断时，攻方攻击停止，攻方兵器设置为打断状态，守方将其视为无兵器状态，使用拳脚作为准备招式，并将守方兵器设置为打断状态。
    -- 兵器耐久度在战斗结束后会恢复满值，但打断状态会保留。
	--当兵器耐久度为0的时候，则武器被打断 当攻方兵器被打断时，该次攻击会立刻停止，并将攻方兵器设置为打断状态 当同时打断时，使用拳脚作为准备招式，并将守方兵器设置为段
end
function ShenBingLayer:weapontexin()
	
end

function ShenBingLayer:setWeaponDesc(str)
	self.Panel_DuanZao.Text_Weapon_Desc:setString(str)
end

Helper:classDefNodeGetInstance(ShenBingLayer)
return  ShenBingLayer00000000000
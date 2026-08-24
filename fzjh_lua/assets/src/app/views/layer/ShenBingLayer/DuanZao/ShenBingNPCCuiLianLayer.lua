local ShenBingNPCCuiLianLayer = class("ShenBingNPCCuiLianLayer", cc.Layer)
--@RefType [app.models.ShenBing.ShenBingDesc#ShenBingDesc]
local ShenBingDesc = require("app.models.ShenBing.ShenBingDesc")
--@RefType [app.models.ShenBing.DuanZao.ShenBingDuanZao#ShenBingDuanZao]
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
local Meridian = require("app.models.Meridian.Meridian")
local godweapon = requireWithEncrypt("script.others.godweapon")
local ShenBingCuiLianModel = require("app.models.ShenBing.CuiLian.ShenBingCuiLianModel")

function ShenBingNPCCuiLianLayer:create()
	local p = ShenBingNPCCuiLianLayer:new()
	p:init()
	return p
end


local function setBtnCanClick(cond)
	if cond == nil then
		cond = true
	end
	return function(self)
		if cond == false then
			self:print("YEL您稍等片刻，淬炼马上便好。")
		end
		return cond
	end
end
local successByNPCList = ShenBingDesc:getShenBingCuiLianText(3)

local failTextByNPCList = ShenBingDesc:getShenBingCuiLianText(4)

function ShenBingNPCCuiLianLayer:init()
	self._UI = require("Layer/ShenBing/NewShenBingCuiLianUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)	
	-- self:setShowAndHideAnimType("ROLL")
	
	self:initRichText()
	self.btnCanClick = setBtnCanClick()
	self:setVisible(false)
end

local weapon = {
}

local _worker = {
	name = "",
	skilv = 0,
	costGold = 0,
	roleType = 0,
	nickName = "少侠"
}

function ShenBingNPCCuiLianLayer:showLayer(_weapon, roleType, skilv,name,costFactor)
	User:getRole():setFlag("PVP活动状态", "忙碌")
	if _weapon == nil then
		assert(false, "武器没有传入，请检查")
		return
	end

	self:initWeapon(_weapon)

	_worker.nickName = "少侠"

	if roleType == 2 then
		--欧冶子
		_worker.name = "欧冶子"
		_worker.skilv = OU_SKILL_LV
	elseif roleType == 3 then
		_worker.name = name or "铁匠"
		_worker.skilv = skilv or TIEJIANG_SKILL_LV
	elseif roleType == 4 then
		local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
		_worker.name = name or "铁匠"
		_worker.skilv = skilv or TIEJIANG_SKILL_LV
		_worker.nickName = HomelandDesc:subChengHuText("#ch#")
	else
		error("淬炼角色类型有误 roleType = "..roleType)
	end

	self.Image_title.Text_auto:setVisible(true)
	self.Image_title.Text_auto:setString("自动淬炼")

	self.Image_title.Text_auto:releaseFunc(function()
		PopupLayerController:showLayer(
			"ShenBingNpcAutoCuiLianLayer",
			function(layer)
				layer:setWeapon(weapon)
				layer:setPlayer(User:getRole())
				layer:setWorker(_worker)
				layer:setCallBack(function()
					self:setShenBingDesc()
					self:setRolAttr()
				end)
				layer:showLayer()
			end
		)
	end)

	_worker._costFactor = Helper:getDef(costFactor,0)

	_worker.roleType = roleType

	self.Image_title.Text_ShenBing:setString("淬炼")
	self:setWeaponName()
	self:setShenBingDesc()
	self:setRolAttr()
	self:setGiveCaiLiaoButton()
	self:setTitleLayerTipFunc()
	self:setBackButton()
	self:initChangeDefaultShenBingBtnFunc()
	self:show(true)

	Audio:pauseMusic()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/26 16:49:14
-- @desc tip
function ShenBingNPCCuiLianLayer:setTitleLayerTipFunc()
	self.Image_title.Panel_tips.Image_7:setVisible(true)
	local list = {
		["android"] = true,
		-- ["ios"] = {},
		-- ["fzjh"] = {},
		-- ["windows"] = true
	}
	self.Image_title.Panel_tips:releaseFunc(function()
		self.Image_title.Panel_tips.Image_7:setVisible(false)
		if list[device.platform] ~= nil and (list[device.platform] == true or list[device.platform][CURR_DEVICE_CHANNEL] == true) then
			local DialogKlayer = require("app.views.layer.DialogLayer.ShenBingGuiZe")
			local dialog = DialogKlayer:getInstance()
			dialog:hide()

			local str = "CYN淬炼规则：\n淬炼分为自己淬炼与铁匠淬炼。\n自己淬炼可在锻造炉中点击淬炼进行，淬炼需消耗精力和对应淬炼材料，淬炼成功概率与自身锻造之术等级相关。\n \n铁匠淬炼可在铁匠处点击淬炼进行，淬炼需消耗黄金和对应淬炼材料，淬炼成功概率与消耗的黄金都和铁匠的锻造之术等级相关。\n在江湖之中也有不少名匠大师，他们的淬炼成功率会更高。\n \n淬炼材料：\n淬炼材料可通过历练任务、黑市商人等方式获得。"

			dialog:showLayer("淬炼规则",str,function()
				self.Image_title.Panel_tips.Image_7:setVisible(true)
			end)
		else
			local DialogKlayer = require("app.views.layer.DialogLayer.DialogKLayer")
			local dialog = DialogKlayer:getInstance()
			dialog:hide()

			local str = "淬炼规则：\n淬炼分为自己淬炼与铁匠淬炼。\n自己淬炼可在锻造炉中点击淬炼进行，淬炼需消耗精力和对应淬炼材料，淬炼成功概率与自身锻造之术等级相关。\n \n铁匠淬炼可在铁匠处点击淬炼进行，淬炼需消耗黄金和对应淬炼材料，淬炼成功概率与消耗的黄金都和铁匠的锻造之术等级相关。\n在江湖之中也有不少名匠大师，他们的淬炼成功率会更高。\n \n淬炼材料：\n淬炼材料可通过历练任务、黑市商人等方式获得。"

			dialog:showLayer("淬炼规则",str,function()
				self.Image_title.Panel_tips.Image_7:setVisible(true)
			end)
		end
	end)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/25 16:25:03
-- @desc 设置给予材料按钮
function ShenBingNPCCuiLianLayer:setGiveCaiLiaoButton()
	self.Button_geiyucailiao:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_geiyucailiao:releaseFunc(function()
		if not self:btnCanClick() then
			return 
		end
		self.Panel_5:setVisible(true)
		local str = "你可以交给".._worker.name.."以下材料，求他帮忙淬炼："
		self.Panel_5.Panel_3.Text_desc:setString(str)
		self:setCaiLiaoButton()
	end)
	self.Panel_5:releaseFunc(function()
		self.Panel_5:setVisible(false)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 16:35:20
-- @desc 设置退出按钮
function ShenBingNPCCuiLianLayer:setBackButton()
	self.Image_title.Button_back:releaseFunc(function()
		if self:btnCanClick() then
			User:getRole():setFlag("PVP活动状态", "空闲中")
			self:hide()
			Audio:resumeMusic()
		end
	end)
end

--@desc: 设置神兵相关描述
--@author:Liang SongQiang
--@time:2017-12-22 15:28:23
function ShenBingNPCCuiLianLayer:setShenBingDesc()
	self:setweaponYingDuDsc()
	self:setweaponJianRenDsc()
	self:setweaponZhuangTaiDsc()
	self:setweaponZhongLiangDsc()
	
	local cuilianCount = weapon.cuilianCount == -0 and 0 or weapon.cuilianCount

	self.Panel_back.Text_num:setString("该神兵已成功淬炼：" .. tostring(cuilianCount) .. "次")
	self.Panel_back.Panel_backImage.Text_damge:setString("伤害力+" .. assert(tostring(Helper:mathFloor(weapon:getWeaponDamage())), "神兵数据异常，没有伤害力"))
	self.Panel_back.Panel_backImage.Text_dsc:setString(ShenBingDesc:getShenBingDesc(weapon))
end

--@desc: 设置神兵属性
--@author:Liang SongQiang
--@time:2017-12-21 10:22:44
function ShenBingNPCCuiLianLayer:setRolAttr()
	local role = User:getRole()

	local neili,neiliMax = math.ceil(role:getAttr("jing")),math.ceil(role:getJingMax())
	local gold = role:getAttr("gold")
	-- self.Panel_back.Text_neili_num:setString(tostring(neili).."/"..tostring(neiliMax))
	self.Panel_back.Text_gold_num:setString(tostring(gold))
end


--@desc:神兵属性淬炼增加 
--@author:Liang SongQiang
--@time:2017-12-27 10:22:03
local changeList = {}

-- 执行字符串脚本
local function getValueFromScript(inputScript, param)    
	-- 判断输入脚本是否合法 add by TangJian 2018/01/22 20:59:24
	if inputScript == nil then
		return nil
	elseif type(inputScript) ~= "string" then
		return inputScript
	end

	-- 判断table是否为空 add by TangJian 2018/01/22 21:00:04
	if type(param) ~= "table" or next(param) == nil then
		param = nil
	end

	-- 判断table是否为空 
	local tempScript = ""
	if param then
		tempScript = "local paramTb = ...\n" -- 接收参数table                        
		do -- 遍历赋值参数                
			for k, v in pairs(param) do
				tempScript = tempScript .. "local " .. k .. " = " .. "paramTb." .. k .. "\n"
			end                
		end
	end

	-- 整合输入脚本
	if string.find(inputScript, "return ") then
		tempScript = tempScript .. inputScript
	else
		tempScript = tempScript .. "return " .. inputScript
	end

	local scriptFunc = loadstring(tempScript)
	if type(scriptFunc) == "function" then
		return scriptFunc(param)
	else
		print("出错!!!!!", "type(scriptFunc) = ", type(scriptFunc))
		return nil
	end
end

function ShenBingNPCCuiLianLayer:addWeaponAttr(res)
	changeList = {}

	local params = {
		hardness = weapon.yindu,
		Tenacity = weapon.rendu,
		weight = weapon.weight,
		Hurt = weapon.damage,
		special = weapon.effctNum
	}
	
	if PRINT_MODE == 1 then
		print("--------- 淬炼前 -----------")
		print("硬度：", weapon.yindu)
		print("韧度：", weapon.rendu)
		print("重量值：", weapon.weight)
		print("伤害力：", weapon.damage)
		print("特性值：", weapon.effctNum)
	end

	changeList.yindu = getValueFromScript(res.Cuilianhardness, params)
	changeList.rendu = getValueFromScript(res.cuilianTenacity, params)
	changeList.weight = getValueFromScript(res.cuilianweight, params)
	changeList.damage = getValueFromScript(res.cuilianHurt, params)
	changeList.effctNum = getValueFromScript(res.cuilianspecial, params)

	weapon.yindu = math.max(weapon.yindu + changeList.yindu, 0)
	weapon.rendu = math.max(weapon.rendu + changeList.rendu, 0)
	weapon.weight = math.max(weapon.weight + changeList.weight, 0)
	weapon.damage = math.max(weapon.damage + changeList.damage, 0)
	weapon.effctNum = math.max(weapon.effctNum + changeList.effctNum, 0)
	weapon.cuilianCount = weapon.cuilianCount + 1

	ShenBingCuiLianModel:weaponAttrRoundPreciseDecimal(weapon)

	if weapon.effctNum >= 100 and weapon.effctNum < 200 then
		if weapon.effct2 ~= nil and weapon.effct2 == "" then
			local specialid, key, name = ShenBingDuanZao:getWeapenSpecialId(weapon)
			weapon[key] = specialid

			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			local dialog = DialogALayer:getInstance()
			dialog:hide()
			dialog:show("你的神兵已解锁" .. name .. "特性")
			dialog:setBack(false)
			dialog:setButton1("确定" , function()

			end)
		end

	elseif weapon.effctNum >= 200 then
		if weapon.effct3 ~= nil and weapon.effct3 == "" then
			local specialid, key, name = ShenBingDuanZao:getWeapenSpecialId(weapon)
			weapon[key] = specialid
			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			local dialog = DialogALayer:getInstance()
			dialog:hide()
			dialog:show("你的神兵已解锁" .. name .. "特性")
			dialog:setBack(false)
			dialog:setButton1("确定" , function()

			end)
		end
	end
	ShenBingDuanZao:updateShenBingInfo(weapon)
	if PRINT_MODE == 1 then
		print("--------- 淬炼后 -----------")
		print("硬度：", weapon.yindu)
		print("韧度：", weapon.rendu)
		print("重量值：", weapon.weight)
		print("伤害力：", weapon.damage)
		print("特性值：", weapon.effctNum)
	end
	
	self:setRolAttr()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 12:03:14
-- @desc 淬炼武器数值变化文本
function ShenBingNPCCuiLianLayer:printCuiLianText(changeList)
	if DEBUG_MODE == 1 then
		Helper:print_lua_table(changeList)
	end

	local cName = {
		yindu = "硬度",
		rendu = "韧度",
		weight = "重量值",
		damage = "伤害力",
		effctNum = "特性值"
	}
	local str,text = "" ,"你的兵器在本次淬炼下"
	local addList = {}
	for name ,var in pairs(changeList) do 
		if var > 0 then
			addList[name] = var
		end
	end
	for name ,var in pairs(addList) do 
		if str == nil then
			str = cName[name]
		else
			str = str .. "，" .. cName[name]
		end
	end
	self:print(text..str.."似乎变得更强了。")
	for name ,var in pairs(changeList) do 
		var = Helper:preciseDecimal(var,3)
		
		if var >= 0 then
			self:print("HIW"..cName[name].."+"..var)
		else
			self:print("HIW"..cName[name]..tostring(var))
		end
	end
end


--@desc: 
--@author:Liang SongQiang
--@time:2018-03-05 14:38:59
--@role: [app.models.role.Role#Role]
local function addSkillExp( role,exp )
	local ret = role:canLevelUp("duanzaozhishu", exp)
	
	if not ret then
		return
	end

	--@desc 直接获取锻造之术增加经验、上层已经做了过滤如果没有技能的情况，此处不再处理
	local roleOldSkill = role:getSkill("duanzaozhishu")

	local roleNewSkill = {id = "duanzaozhishu",exp = roleOldSkill.exp + exp}

	-- 修正:等级不能为负
	if roleNewSkill.exp <= 0 then
		roleNewSkill.exp = 1
	end

	local oldLv = role:conversionSkillExpAndLv("lv",roleOldSkill.exp)

	local newLv = role:conversionSkillExpAndLv("lv",roleNewSkill.exp)

	local skillName = Skill:getSkill("duanzaozhishu").name

	role.skills["duanzaozhishu"] = roleNewSkill

	if newLv - oldLv > 0 then
		return newLv - oldLv
	end

	return 0

end

--@desc: NPC淬炼
--@author:Liang SongQiang
--@time:2017-12-26 15:35:35
--@item: 淬炼用的物品
--@res: 淬炼武器资源列表内的数据结构
function ShenBingNPCCuiLianLayer:startCuilianByNPC(item, res)
	if _worker.roleType == 2 then
		local todayCount = User:getRole():getDayFlag("欧冶子淬炼")
		if todayCount >= ShenBingCuiLianModel:getOuYeZiCuiLianCountDayLimit() then
			PopText("欧冶子淬炼次数已达今日上限！")
			self:print("YEL欧冶子：今日老夫已经累了，".._worker.nickName.."还是下次再来吧。NOR")
			return
		end
	end

	local itemNum = User:getRole():getSmeltBoxItemCount(item.id)
	if itemNum < 1 then
		PopText("冶炼箱没有该物品")
		return
	end
	
	local function setPrint(cond)
		
		local text = {}
		
		if cond then
			text = successByNPCList[math.random(1,#successByNPCList)]
		else
			text = failTextByNPCList[math.random(1,#failTextByNPCList)]
		end
		
		local count = 1
		
		return function(self)
			local str = string.gsub(text[count], "#name#", _worker.name)
			str = string.gsub(str, "#nickName#", _worker.nickName)
			self:print(str)
			count = count + 1
		end
	end
	
	
	PopupLayerController:showLayer("PopConfirmLayer", function(layer)
		local successRate = ShenBingCuiLianModel:getNpcCuiLianSuccessRate(weapon.cuilianCount,_worker.skilv)
		local text = self:dealCuiLianSuccessRate(successRate)
		layer:showRefreshPannel()
		layer:setDesc1("淬炼需消耗")
		layer:setDesc2(item.name.."X 1")

		_worker.costGold = ShenBingCuiLianModel:getEverytimeCostGold(_worker.skilv,weapon.cuilianCount,_worker._costFactor)

		layer:setDsc(_worker.name .. "：".._worker.nickName.."，本次使用" .. item.name .. "我" .. text .. "把握成功，需要收取HIY" .. tostring(_worker.costGold) .. "NOR两黄金作为辛苦费，".._worker.nickName.."可曾愿意？")
		
		layer:setButtonNameAndCallFunc("确认", function()
			if User:getRole():getNumAttr("gold") < _worker.costGold then
				PopText("黄金不足")
				return
			end

			local rate = math.random(1, 100)
			local isSuccess
			local results
			if rate > successRate then
				self.PrintText = setPrint(false)
				isSuccess = 2

				results = {[item.id] = {sucNum = 0,defNum = 1}}
			else
				self.PrintText = setPrint(true)
				isSuccess = 1

				results = {[item.id] = {sucNum = 1,defNum = 0}}
			end

			self.btnCanClick = setBtnCanClick(false)
			
			--@desc NPC淬炼成功
			print("````````````````````````````````````````",weapon.id, item.id)
			HttpManagerEx:incrWeaponCuilianNum(weapon.id, results,weapon.cuilianCount, function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0 then
					if errcode == 0 then
						self.musicId = Audio:playEffect("DuanDa",true)
						--@RefType [app.models.role.Role#Role]
						local role = User:getRole()
						role:addAttr("gold",0 - _worker.costGold)
						if _worker.roleType == 2 then
							role:setDayFlag("欧冶子淬炼",role:getDayFlag("欧冶子淬炼") + 1)
						end
						local gold = role:getAttr("gold")
						role:addItemCount(item.id, - 1)
						self.Panel_back.Text_gold_num:setString(tostring(gold))
						
						if isSuccess == 1 then
							self:addWeaponAttr(res)
						elseif isSuccess == 2 then
							print("淬炼失败")
						end
						
						if DEBUG_MODE == 1 then
							print("successRate :",successRate)
							print("随机数：",rate)
						end
						
						local skillLv = role:getSkillLv("duanzaozhishu")
						local addExp = 0
						local addLv = 0
						local MAX_ROLE_SKILL_EXP = role:conversionSkillExpAndLv("exp", role:getSkillLvLimit("duanzaozhishu"))
						if skillLv and skillLv > 0 then
							local todayExp = role:getDayFlag("淬炼经验")
							if todayExp < MAX_CUILIAN_DAY_EXP then
								local skillExp = role:getSkillExp("duanzaozhishu")
								addExp = math.floor((skillLv^1.5)/6 + 500)
								if skillExp + addExp > MAX_ROLE_SKILL_EXP then
									addExp = MAX_ROLE_SKILL_EXP - skillExp
								end
								
								if addExp + todayExp > MAX_CUILIAN_DAY_EXP then
									addExp = MAX_CUILIAN_DAY_EXP - todayExp
								end
								role:setDayFlag("淬炼经验", todayExp + addExp)
								if addExp > 0  then
									addLv = addSkillExp(role,addExp)
								end
							end
						else
							print("你没有锻造之术，不增加经验")
						end
						
						self.btnCanClick = setBtnCanClick(false)
						self:setSchedule(function()
							if isSuccess == 1 then
								self:printCuiLianText(changeList)
							elseif isSuccess == 2 then
								print("淬炼失败")
							end
							if self.musicId then
								Audio:stopEffect(self.musicId)
								self.musicId = nil
							end
							local skillName = Skill:getSkill("duanzaozhishu").name
							
							if addExp > 0 then
								if addExp < 1 then
									addExp = math.ceil(addExp)
								else
									addExp = math.floor(addExp)
								end
								self:print("你的 【"..skillName.."】 经验 +"..tostring(addExp))
							end
							
							if addLv > 0 then
								self:print("你的 【"..skillName.."】 等级 +"..tostring(addLv))
							end
							
							local afterExp = role:getSkillExp("duanzaozhishu")
							if afterExp >= MAX_ROLE_SKILL_EXP then
								self:print("您的"..skillName.."已出神入化，无法再提升！")
							end
							
							if role:getDayFlag("淬炼经验") >= MAX_CUILIAN_DAY_EXP then
								self:print("RED已达到每日淬炼可获得经验的上限，本日内淬炼无法再增加锻造之术经验")
							end
							self:setShenBingDesc()
						end)
						return true
					else
						if DEBUG_MODE == 1 then
							print("incrWeaponCuilianNum() errcode : ", errcode)
							PopText(errmsg)
						end
						self.btnCanClick = setBtnCanClick(true)
						return true
					end
				else
					print(errmsg,errcode)
					self.btnCanClick = setBtnCanClick(true)
					return true
				end
			end)
			
		end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
		layer:setCanelButtonNameAndCallFunc()
	end)
	
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 16:08:06
-- @desc 设置材料按钮
function ShenBingNPCCuiLianLayer:setCaiLiaoButton()
	local t = ShenBingCuiLianModel:getCuiLianItemList(weapon.bType)

	local panel = self.Panel_5.Panel_3
	for k, v in ipairs(t) do
		if panel["Button_cailiao" .. tostring(k)] ~= nil then
			local item = Item:getOneItemByKey(v.Cuilianid)
			panel["Button_cailiao" .. tostring(k)] ["Text_buttonName"]:setString(item.name)
			local count = User:getRole():getSmeltBoxItemCount(v.Cuilianid)
			panel["Text_count_".. tostring(k)]:setString("数量："..count)
			-- if count == 0 then
			-- 	-- self["Button_cailiao" .. tostring(k)]:setEnabled(false)
			-- 	panel["Button_cailiao" .. tostring(k)]:loadTextureNormal("Image/UI/TeacherUI/anniu02.png",0)
			-- 	panel["Button_cailiao" .. tostring(k)]:loadTexturePressed("Image/UI/TeacherUI/anniu02.png",0)
			-- end
			panel["Button_cailiao" .. tostring(k)]:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
			panel["Button_cailiao" .. tostring(k)]:releaseFunc(function()
				self.Panel_5:setVisible(false)
				if not self:btnCanClick() then
					return
				end

				if weapon.typeDesc == nil then
					PopText("神兵"..weapon.name.."数据异常，请联系客服！")
					return
				end
				
				assert(weapon.wanhaodu,"神兵数据异常，没有完好度")
				if weapon.wanhaodu == 0 then
					PopText("您的神兵已被损坏，无法被淬炼。")
					return
				end
				if weapon.cuilianCount >= 300 then
					PopText("该神兵已经淬炼300次了")
					return
				end
				if _worker.roleType ~= 1 then
					self:startCuilianByNPC(item, v)
				end
			end)
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/08 15:08:12
-- @desc 淬炼成功率提示处理
function ShenBingNPCCuiLianLayer:dealCuiLianSuccessRate(rate)
	assert(type(rate) == "number")
	rate = rate / 10
	local text = ""
	if rate < 1 then
		text = "RED没有多少NOR"
	else
		rate = math.floor(rate)
		text = "有RED"..Helper:numberCast(rate).."成NOR"
	end
	return text
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 16:24:07
-- @desc 淬炼过程中输出文本
function ShenBingNPCCuiLianLayer:setSchedule(func)
	if self.handle ~= nil then
		return
	end

	local time = 3
	
	if self.PrintText then
		self:PrintText()
	else
		if DEBUG_MODE == 1 then
			assert(false, "检查代码，没有输出文本")
		end
	end

	self.handle = self:schedule(function()
		print(time)
		

		if time > 0 then
			if self.PrintText then
				self:PrintText()
			else
				if DEBUG_MODE == 1 then
					assert(false, "检查代码，没有输出文本")
				end
			end
		
			time = time - 1.5
		else
			print("!!!!!!!!!!!!!!!!!!!")
			func = func or EMPTY_FUNC
			
			func()
			-- Audio:stopEffect("DuanDa")
			self.btnCanClick = setBtnCanClick(true)
			self.PrintText = nil
			self:unschedule(self.handle)
			self.handle = nil
			
		end
	end, 1.5)
end



-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 15:45:45
-- @desc 设置神兵硬度描述
function ShenBingNPCCuiLianLayer:setweaponYingDuDsc()
	print("----------------设置神兵硬度描述----------------",weapon.yindu)
	local descList = ShenBingDesc:getYingDuDesc(weapon)
	
	self.Panel_back.Panel_backImage.Panel_yingdu.Text_name_dsc:setString(descList.hard1level)
	self.Panel_back.Panel_backImage.Panel_yingdu.Panel_touch:releaseFunc(function()
		self.Panel_tip.Image_tip.Text_desc1:setString("一把武器的硬度决定了它击碎他人的武器的难易程度。")
		self.Panel_tip.Image_tip.Text_desc2:setString(descList.hard1text)
		self.Panel_tip:setVisible(true)
		self.Panel_tip.Image_tip.Text_Val:setVisible(true)
		self.Panel_tip.Image_tip.Text_Val:setString("硬度值：" .. Helper:mathFloor(weapon:getWeaponYingDu()))
		self.Panel_back.Panel_backImage.Panel_yingdu.Image_7:setVisible(false)
		self.Panel_tip:releaseFunc(function()
			self.Panel_tip:setVisible(false)
			self.Panel_back.Panel_backImage.Panel_yingdu.Image_7:setVisible(true)
		end)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 15:45:45
-- @desc 设置神兵坚韧度描述
function ShenBingNPCCuiLianLayer:setweaponJianRenDsc()
	local descList = ShenBingDesc:getRenDuDesc(weapon)
	
	self.Panel_back.Panel_backImage.Panel_jianren.Text_name_dsc:setString(descList.Tenacity1level)
	self.Panel_back.Panel_backImage.Panel_jianren.Panel_touch:releaseFunc(function()
		self.Panel_tip.Image_tip.Text_desc1:setString("一把武器的坚韧度决定了它被他人武器击碎的难易程度。")
		self.Panel_tip.Image_tip.Text_desc2:setString(descList.Tenacity1text)
		self.Panel_tip:setVisible(true)
		self.Panel_tip.Image_tip.Text_Val:setVisible(true)
		self.Panel_tip.Image_tip.Text_Val:setString("韧度值：" .. Helper:mathFloor(weapon:getWeaponRenDu()))
		self.Panel_back.Panel_backImage.Panel_jianren.Image_7:setVisible(false)
		self.Panel_tip:releaseFunc(function()
			self.Panel_tip:setVisible(false)
			self.Panel_back.Panel_backImage.Panel_jianren.Image_7:setVisible(true)
		end)
		
	end)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 15:45:45
-- @desc 设置神兵状态描述
function ShenBingNPCCuiLianLayer:setweaponZhuangTaiDsc()
	local str, text = ShenBingDesc:getShenBingStatusDesc(weapon)
	
	self.Panel_back.Panel_backImage.Panel_zhuangtai.Text_name_dsc:setString(str)
	self.Panel_back.Panel_backImage.Panel_zhuangtai.Panel_touch:releaseFunc(function()
		self.Panel_tip.Image_tip.Text_desc1:setString("一把武器状态决定它的伤害力，未达完美状态的武器可经修理达到完美状态。")
		self.Panel_tip.Image_tip.Text_desc2:setString(text)
		self.Panel_tip:setVisible(true)
		self.Panel_tip.Image_tip.Text_Val:setVisible(false)
		self.Panel_back.Panel_backImage.Panel_zhuangtai.Image_7:setVisible(false)
		self.Panel_tip:releaseFunc(function()
			self.Panel_tip:setVisible(false)
			self.Panel_back.Panel_backImage.Panel_zhuangtai.Image_7:setVisible(true)
		end)
		
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 15:45:45
-- @desc 设置神兵重量描述
function ShenBingNPCCuiLianLayer:setweaponZhongLiangDsc()
	local descList = ShenBingDesc:getWeightDesc(weapon)
	self.Panel_back.Panel_backImage.Panel_zhongliang.Text_name_dsc:setString(descList.weight1level)
	self.Panel_back.Panel_backImage.Panel_zhongliang.Panel_touch:releaseFunc(function()
		self.Panel_tip.Image_tip.Text_desc1:setString("一把武器的重量值不仅决定了它是否容易被人击飞与击飞他人武器的难易程度，同时它也会影响攻击速度。")
		self.Panel_tip.Image_tip.Text_desc2:setString(descList.weight1text)
		self.Panel_tip.Image_tip.Text_Val:setVisible(true)
		self.Panel_tip.Image_tip.Text_Val:setString("重量值：" .. Helper:mathFloor(weapon:getWeaponWeight()))
		self.Panel_tip:setVisible(true)
		self.Panel_back.Panel_backImage.Panel_zhongliang.Image_7:setVisible(false)
		self.Panel_tip:releaseFunc(function()
			self.Panel_tip:setVisible(false)
			self.Panel_back.Panel_backImage.Panel_zhongliang.Image_7:setVisible(true)
		end)
	end)
end





-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 15:54:45
-- @desc 初始化RichText
function ShenBingNPCCuiLianLayer:initRichText()
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
function ShenBingNPCCuiLianLayer:print(str, verticalSpace)
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

function ShenBingNPCCuiLianLayer:initWeapon(_weapon)
	weapon = _weapon
end

function ShenBingNPCCuiLianLayer:initChangeDefaultShenBingBtnFunc()
	self.Panel_back.Image_back_ChangeWeapon:releaseFunc(function()
		PopupLayerController:showLayer("ShenBingWareHouseLayer",function(layer)
			layer:setBackConditionFunc(function()
				local role = User:getRole()
				local shenBing = role:getDefaultShenBing()
				if shenBing then
					self:initWeapon(shenBing)
					self:refreshUI()
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

function ShenBingNPCCuiLianLayer:setWeaponName()
	self.Panel_back.Panel_backImage.Text_name:setString(assert(weapon.name, "神兵数据异常，没有名称"))
end

function ShenBingNPCCuiLianLayer:refreshUI()
	self:setWeaponName()
	self:setShenBingDesc()
end

Helper:classDefNodeGetInstance(ShenBingNPCCuiLianLayer)

return ShenBingNPCCuiLianLayer000000000
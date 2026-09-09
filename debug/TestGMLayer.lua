-- 测试界面
local TestGMLayer = class("TestGMLayer", LayerEx)
local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
local Inherit = require("app.models.inherit.Inherit")
local Meridian = require("app.models.Meridian.Meridian")

function TestGMLayer:create()
	local p = TestGMLayer:new()
	p:init()
	return p
end

function TestGMLayer:init()
	self._UI = require("Layer/DebugUI/TestUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	
	self:setButton()
end

function TestGMLayer:showLayer()
	self:setMainBtn()
	self:show()
end

function TestGMLayer:setMainBtn()
	self.ListView:removeAllItems()
	self:setTestGMButton()
end
--重置师门任务免费刷新次数，重置师门任务完成次数，重置师门任务获得的贡献点
function TestGMLayer:setTestGMButton()
	self.ListView:removeAllItems()
	local role = User:getRole()
	-- self:addButton("升级至可传承",function()
	-- 	local inheritCount = Helper:getDef(role:getAttr("inheritCount"),0)
	-- 	-- print("-----------------------------------:",inheritCount)
	-- 	local lv = 600
	-- end)
	self:updateBookLv()
	self:addButton("一键系列",function()
		self:yiJianButtons()
	end)
	self:addButton("武  学",function()
		self:getWuXueButtons()
	end)

	self:addButton("增加人物一千万经验", function()
		local role=User:getRole()
		role:addAttr("exp",10000000)
		PopText("增加人物一千万经验")
	end)

	self:addButton("减少人物一千万经验", function()
		local role=User:getRole()
		if role:getAttr("exp")<=10000000 then
			PopText("经验不足")
			return 
		end 
		role:addAttr("exp",-10000000)
		PopText("减少人物一千万经验")
	end)

	self:addButton("添加经脉天赋", function()
		self:setMeridianBtn()
	end)

	self:addButton("拜访任务", function()

		self:setVisitTaskButton()
	end)
	self:addButton("黑市商人", function()
		PopupLayerController:showLayer("BlackStorePresenter",function(layer)
			layer:setRole(User:getRole())
			layer:showLayer()
		end)
	end)
	self:addButton("制药材料添加",function()
		local role = User:getRole()
		for i = 1, 59 do
			local item = {}
			if i < 10 then
				item = Item:getOneItemByKey("duyaoyc00" .. i)
			else
				item = Item:getOneItemByKey("duyaoyc0" .. i)
			end
			if item ~= nil then
				role:addItemCount(item.id, 10)
			end
		end
		PopText("制药材料添加成功")
	end)
	self:addButton("锻造之术等级500级",function()
		local role = User:getRole()
		local value = role:getSkillLv("duanzaozhishu")
		
		role:addSkillLv("duanzaozhishu",500 - value)
		PopText("锻造之术等级500级")
	end)
	self:addButton("内力回满",function()
		local role = User:getRole()
		local neiLiLimit = role:getAttr("neiLiLimit")
		
		role:setAttr("neiliMax",neiLiLimit)

		local neiliMax = role:getAttr("neiliMax")
		role:setAttr("neili",neiliMax)
		PopText("内力回满")
	end)
	self:addButton("神兵",function()
		self:setWeaponButton()
	end)
	self:addButton("物品添加列表",function()
		self:setAddItemButton()
	end)
	self:addButton("家园系统",function()
		self:setJiaYuanButton()
	end)
	self:addButton("增加神照经道具",function()
		local role =User:getRole()
		 if role:getAttr("weight") - #role:getItems() < 1 then
			PopText("背包已满，无法获取")
			return
		end
		HttpManagerEx:testExchangeGoods("szjdj2", 1, function(status, errcode, errmsg, data)
			if status == 200 and errcode == 0 then
				role:addItemCount("szjdj2",1)
				PopText("获得信笺道具")
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end)
	self:addButton("增加神照经经验1000000",function()
		local role=User:getRole()
		role:addSkillExp("shenzhaojing003", 1000000)
	end)

	self:addButton("增加洗髓道具",function()
		self:addXiSuiDan()
	end)

	self:addButton("删除指定技能", function()
		self:removeSkills()
	end)

	self:setAttrButton()
end

function TestGMLayer:removeSkills()
	self.ListView:removeAllItems()
	local role = User:getRole()
	local roleSkills = role:getSkills()
	for k,v in pairs(roleSkills) do 
		local skill = Skill:getSkill(v.id)
		self:addButton("删除"..skill.name,function()
			if role:getSkill(v.id) then 
				role:removeSkill(v.id)
				PopText("删除成功")
			else
				PopText("技能已经删除")
			end
		end)
	end
end

function TestGMLayer:addXiSuiDan()
	self.ListView:removeAllItems()

		local xisuidanItem={ 
		["xisuidan01"]="臂力洗髓丹",
		["xisuidan02"]="根骨洗髓丹",
		["xisuidan03"]="身法洗髓丹",
		["xisuidan04"]="悟性洗髓丹",
		["xisuidan05"]="臂力洗髓丹(小)",
		["xisuidan06"]="根骨洗髓丹(小)",
		["xisuidan07"]="身法洗髓丹(小)",
		["xisuidan08"]="悟性洗髓丹(小)",
		} 
		for i,v in pairs(xisuidanItem) do 
			self:addButton("增加"..v,function()
				local role = User:getRole()
				if role:getAttr("weight") - #role:getItems() < 1 then
					PopText("背包已满，无法获取")
					return
				end

				HttpManagerEx:testExchangeGoods(i, 1,function(status, errcode, errmsg, data)
					if status == 200 and errcode == 0 then
						role:addItemCount(i,1)
						PopText("获得"..v)
					else
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING)
			end)
		end
	
end

function TestGMLayer:setVisitTaskButtonList(list)
	self.ListView:removeAllItems()

	for k,v in pairs(list) do
		self:addButton(v, function()
			local VisitTask=require("app.models.task.visitTask.VisitTask")
			VisitTask:startTask(nil, v)
		end)
	end

	self:addButton("返回",function()
		self:setVisitTaskButton()
	end)
end

function TestGMLayer:setVisitTaskButton()
	self.ListView:removeAllItems()
	self:addButton("任务型",function()
		local visitTaskInfo = assert(require("script.others.bfrw"))
		local visitTaskContent = visitTaskInfo["拜访任务"]
		local list = {}
		for k,v in pairs(visitTaskContent) do
			if v.type == "任务型" then
				table.insert(list, k)	
			end
		end

		table.sort(list, function(a, b)
			local numA = tonumber(string.sub(a, 3)) 
			local numb = tonumber(string.sub(b, 3)) 
			return a < b
		end)

		self:setVisitTaskButtonList(list)
	end)
	self:addButton("消费型",function()
		local visitTaskInfo = assert(require("script.others.bfrw"))
		local visitTaskContent = visitTaskInfo["拜访任务"]
		local list = {}
		for k,v in pairs(visitTaskContent) do
			if v.type == "消费型" then
				table.insert(list, k)
			end
		end

		table.sort(list, function(a, b)
			local numA = tonumber(string.sub(a, 3)) 
			local numb = tonumber(string.sub(b, 3)) 
			return a < b
		end)

		self:setVisitTaskButtonList(list)
	end)
	self:addButton("免费型",function()
		local visitTaskInfo = assert(require("script.others.bfrw"))
		local visitTaskContent = visitTaskInfo["拜访任务"]
		local list = {}
		for k,v in pairs(visitTaskContent) do
			if v.type == "免费型" then
				table.insert(list, k)
			end
		end

		table.sort(list, function(a, b)
			local numA = tonumber(string.sub(a, 3)) 
			local numb = tonumber(string.sub(b, 3)) 
			return a < b
		end)

		self:setVisitTaskButtonList(list)
	end)




	self:addButton("返回",function()
		self:setTestGMButton()
	end)
end

function TestGMLayer:setMeridianBtn()
	self.ListView:removeAllItems()
	
	self:addButton("返回",function()
		self:setTestGMButton()
	end)
	
	self:addButton("获取所有经脉印记", function()
		local role = User:getRole()
		local meridianImprinting = Meridian:getAllMeridianImprinting()
		role:setAttr("meridianImprinting", meridianImprinting)
		role:updateRoleBuff()
		self:setMeridianBtn()
	end)
	
	self:addButton("清空经脉印记", function()
		local role = User:getRole()
		role:setAttr("meridianImprinting", {})
		role:updateRoleBuff()
		self:setMeridianBtn()
	end)
	
	for k, v in pairs(Meridian:getImprinting()) do
		local role = User:getRole()
		local meridianImprinting = role:getAttr("meridianImprinting")
		
		if role:isHaveImprintingId(v.imprintingId) ~= true then
			self:addButton("添加" .. v.name, function()
				table.insert(meridianImprinting, {imprintingId = v.imprintingId})
				role:setAttr("meridianImprinting", meridianImprinting)
				role:updateRoleBuff()
				self:setMeridianBtn()
			end)
		else
			self:addButton("移除" .. v.name, function()
				for i, imprinting in ipairs(meridianImprinting) do
					if v.imprintingId == imprinting.imprintingId then
						table.remove(meridianImprinting, i)
						role:setAttr("meridianImprinting", meridianImprinting)
						role:updateRoleBuff()
						break
					end
				end
				self:setMeridianBtn()
			end)
		end	
	end
end

function TestGMLayer:setWeaponButton()
	self.ListView:removeAllItems()
	self:addButton("锻造材料添加",function()
		self:setDuanZaoButton()
	end)
	self:addButton("淬炼材料添加",function()
		self:setCuiLianButton()
	end)
	self:addButton("燃料材料添加",function()
		self:setRanLiaoButton()
	end)

	self:addButton("增加每日淬炼锻造熔炼上限经验",function ()
		--@RefType [app.models.role.Role#Role]
		local role = User:getRole()

		role:setDayFlag("ronglian",RONGLIAN_EXP_MAX_DAY - 100)
		role:setDayFlag("淬炼经验",MAX_CUILIAN_DAY_EXP - 100)
		role:setDayFlag("duanzao",DUANZAO_EXP_MAX_DAY - 100)

		PopText("今日熔炼经验设置为"..RONGLIAN_EXP_MAX_DAY - 100)
		PopText("今日淬炼经验设置为"..MAX_CUILIAN_DAY_EXP - 100)
		PopText("今日锻造经验设置为"..DUANZAO_EXP_MAX_DAY - 100)
	end)
	self:addButton("解锁特性二",function()
		local items = User:getRole():getItems(function(item)
			if item.type == "神兵" then
				return true
			else
				return false
			end
		end)
		if MapIsEmpty(items) == true then
			PopText("背包中没有神兵")
			return
		end	
		local weapon = Item:getOneItemByKey(items[1].itemId)
		if weapon ~= nil then
			weapon.effctNum = 101
		end
		weapon.effct2 = ShenBingDuanZao:getWeapenSpecialId(weapon)
		local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
		ShenBingDuanZao:updateShenBingInfo(weapon)
	end)
	self:addButton("解锁特性三",function()
		local items = User:getRole():getItems(function(item)
			if item.type == "神兵" then
				return true
			else
				return false
			end
		end)
		if MapIsEmpty(items) == true then
			PopText("背包中没有神兵")
			return
		end	
		local weapon = Item:getOneItemByKey(items[1].itemId)
		if weapon ~= nil then
			weapon.effctNum = 201
		end
		weapon.effct3 = ShenBingDuanZao:getWeapenSpecialId(weapon)
		local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
		ShenBingDuanZao:updateShenBingInfo(weapon)
	end)
	self:addButton("当前神兵属性调整",function()
		self:setShenBingAttrBtn()
	end)
	self:addButton("黄金 + 500",function()
		User:addRoleAttr("gold", 500)
		PopText("黄金 + 500")
	end)
	self:addButton("内力上限 + 1000",function()
		local role = User:getRole()
		print("neiLiLimit=",role:getAttr("neiLiLimit"),"neiliMax=",role:getAttr("neiliMax"))
		-- role:addAttr("neiLiLimit",2000)
		role:addAttr("neiliMax", 1000)
		PopText("内力上限 + 1000")
	end)
	self:addButton("每日锻造经验设为 11000",function()
		role:setDayFlag("duanzao",11000)	
		PopText("设置成功")
	end)
	self:addButton("每日熔炼经验设为 11000",function()
		role:setDayFlag("ronglian",11000)	
		PopText("设置成功")
	end)
	self:addButton("每日淬炼经验设为 39000",function()
		role:setDayFlag("淬炼经验",39000)
		PopText("设置成功")
	end)

	self:addButton("返回",function()
		self:setTestGMButton()
	end)
end

function TestGMLayer:setShenBingAttrBtn()
	self.ListView:removeAllItems()

	-- damage = 0,		-- 伤害值
	-- yindu = 0, 		-- 硬度值
	-- rendu = 0, 		-- 韧度值
	-- weight = 0,		-- 重量值
	-- wanhaodu         -- 完好度
	local role =  User:getRole()
	local items = role:getItems(function(item)
	if item.type == "神兵" then
		return true
	else
		return false
	end
	end)
	if MapIsEmpty(items) == true then
		PopText("背包中没有神兵")
		return
	end
	Helper:print_lua_table(items)	
	local weapon = Item:getOneItemByKey(items[1].itemId)
	if weapon == nil then
		return
	end
	local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
	self:addButton("神兵伤害值 + 10",function()
		weapon.damage = weapon.damage + 10
        ShenBingDuanZao:updateShenBingInfo(weapon,role)
		PopText("神兵伤害值 + 10")
	end)
	self:addButton("神兵硬度值 + 10",function()
		weapon.yindu = weapon.yindu + 10
		ShenBingDuanZao:updateShenBingInfo(weapon,role)
		PopText("神兵硬度值 + 10")
	end)
	self:addButton("神兵韧度值 + 10",function()
		weapon.rendu = weapon.rendu + 10
		ShenBingDuanZao:updateShenBingInfo(weapon,role)
		PopText("神兵韧度值 + 10")
	end)
	self:addButton("神兵重量值 + 10",function()
		weapon.weight = weapon.weight + 10
		ShenBingDuanZao:updateShenBingInfo(weapon,role)
		PopText("神兵重量值 + 10")
	end)
	self:addButton("神兵完好度设为100",function()
		weapon.wanhaodu = 100
		ShenBingDuanZao:updateShenBingInfo(weapon,role)
		PopText("神兵完好度设为100")
	end)
	self:addButton("神兵完好度设为0",function()
		weapon.wanhaodu = 0
		ShenBingDuanZao:updateShenBingInfo(weapon,role)
		role:setEquipByName("weapon", nil)
		PopText("神兵完好度设为0")
	end)
	self:addButton("淬炼次数次数 + 50",function()
		weapon.cuilianCount = weapon.cuilianCount + 50 
		ShenBingDuanZao:updateShenBingInfo(weapon,role)
		PopText("淬炼次数 + 50")
	end)
	self:addButton("淬炼次数次数 + 20",function()
		weapon.cuilianCount = weapon.cuilianCount + 20 
		ShenBingDuanZao:updateShenBingInfo(weapon,role)
		PopText("淬炼次数 + 20")
	end)
	self:addButton("淬炼次数次数 + 1",function()
		weapon.cuilianCount = weapon.cuilianCount + 1 
		ShenBingDuanZao:updateShenBingInfo(weapon,role)
		PopText("淬炼次数 + 1")
	end)
	self:addButton("神兵特性值 + 10",function()
		weapon.effctNum = weapon.effctNum + 10
		ShenBingDuanZao:updateShenBingInfo(weapon,role)
		print("神兵特性值 = ",weapon.effctNum)
		PopText("神兵特性值 + 10")
	end)
	self:addButton("神兵特性值 + 1",function()
		weapon.effctNum = weapon.effctNum + 1
		ShenBingDuanZao:updateShenBingInfo(weapon,role)
		print("神兵特性值 = ",weapon.effctNum)
		PopText("神兵特性值 + 1")
	end)
	self:addButton("返回", function()
		self:setWeaponButton()
	end)
end

function TestGMLayer:setJiaYuanButton()
	self.ListView:removeAllItems()
	
	self:addButton("银票 +10000",function ()
		HttpManagerEx:updateCurrencyByType("add","yinpiao",10000,nil, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					PopText("银票".."+"..tostring(10000))
				else
					PopText(errmsg)
				end
			end
		end, IS_SHOW_WAITING)
	end)

	self:addButton("返回", function()
		self:setTestGMButton()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/04/02 19:39:14
-- @desc 武学系列按钮
function TestGMLayer:getWuXueButtons()
	self.ListView:removeAllItems()
	local role = User:getRole()
	local skills = require("script.skill.skill").skills
	local MenPaiMap = {}
	local sanRenSkills = {   -- 散人技能列表
		["虚空踏步"] = true,
		["嫁衣神功"] = true,
		["天残腿法"] = true,
		["灵犀一指"] = true,
		["花零流水掌"] = true,
		["傲梅诀"] = true,
		["五行拳"] = true,
		["烟云缥缈步法"] = true,
		["九宫六合掌"] = true,
		["割鹿刀法"] = true,
		["一刀流"] = true,
		["七杀刀法"] = true,
		["轩辕斧法"] = true,
		["日月轮"] = true,
		["霸王枪法"] = true,
		["流石陨星身法"] = true,
		["小李飞刀"] = true,
		["逍遥无相剑"] = true,
		["弦音刀法"] = true,
		["无痕劲"] = true,
		["五煞神掌"] = true,
		["太玄功"] = true,
		["羽仙诀"] = true,
		["戊戌刀法"] = true,
		["白猿剑法"] = true,
		["小夜叉棍法"] = true,
		["阴阳倒乱刃法"] = true,
		["七伤拳"] = true,
		["凌霄心法"] = true,
	}
	local SanRenSkillsMap = {}
	for k,v in pairs(skills) do
		if sanRenSkills[v.name] == true then
			MenPaiMap["散人"] = Helper:getDef(MenPaiMap["散人"], {})
			table.insert(MenPaiMap["散人"], v)
		else
			if v.familyList == "灵鹫宫" or v.familyList == "逍遥" then
				MenPaiMap["天山"] = Helper:getDef(MenPaiMap["天山"], {})
				table.insert(MenPaiMap["天山"], v)	
			else
				MenPaiMap[v.familyList] = Helper:getDef(MenPaiMap[v.familyList], {})
				table.insert(MenPaiMap[v.familyList], v)
			end	
		end 
	end

	local addList = {
		["官府"] = true,
		["少林"] = true,
		["全真教"] = true,
		["大理"] = true,
		["丐帮"] = true,
		["峨眉"] = true,
		["武当"] = true,
		["华山"] = true,
		["昆仑"] = true,
		["五毒教"] = true,
		["铁掌帮"] = true,
		["日月神教"] = true,
		["雪山寺"] = true,
		["星宿"] = true,
		["白驼山"] = true,
		["姑苏慕容"] = true,
		["明教"] = true,
		["唐门"] = true,
		["桃花岛"] = true,
		["古墓"] = true,
		["崆峒"] = true,
		["海鲸帮"] = true,
		["幽冥教"] = true,
		["天山"] = true,
		["落月山庄"] = true,
		["金钱帮"] = true,
		["散人"] = true,
	}

	for k,v in pairs(MenPaiMap) do
		if addList[k] == true then
			self:addButton(k,function()
				self:getMengPaiButtons(v)
			end)
		end
	end

	self:addButton("返回", function()
		self:setTestGMButton()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/04/02 19:43:28
-- @desc 门派系列武学
function TestGMLayer:getMengPaiButtons(list)
	self.ListView:removeAllItems()
	local role = User:getRole()
	local skillMap = {}
	self.__mengpaiList = list
	for k,v in pairs(list) do
		local methods = string.split(v.methods, ",")
		for j,n in pairs(methods) do
			skillMap[n] = Helper:getDef(skillMap[n], {})
			table.insert(skillMap[n], v)
		end
	end


	local listName = {"拳脚","内功","轻功","招架","剑法","刀法","棍法","暗器","鞭法"}
	for k,v in pairs(skillMap) do
		self:addButton(listName[tonumber(k)], function()
			self:setOneTypeSkills(v)
		end)
	end

	self:addButton("返回", function()
		self:getWuXueButtons()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/04/02 19:52:42
-- @desc 一个武学
function TestGMLayer:setOneTypeSkills(list)
	self.ListView:removeAllItems()
	local role = User:getRole()
	self.__OneSkillList = list
	for k,v in pairs(list) do
		self:addButton(v.name, function()
			self:getOneSkillZhao(v.id)
		end)
	end
	self:addButton("返回", function()
		self:getMengPaiButtons(self.__mengpaiList)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/04/02 20:27:48
-- @desc 武学相关招式
function TestGMLayer:getOneSkillZhao(skillId)
	self.ListView:removeAllItems()
	local role = User:getRole()
	self:addButton("获取武功", function()
		role:addSkillLv(skillId, 1000 - role:getSkillLv(skillId))
	end)
	local zhaoList = Skill:getSkillZhaoList(skillId)
	for k,v in pairs(zhaoList) do
		self:addButton("【" .. v.name .. "】 熟练度 + 10", function()
			role:addSkillZhaoExp(v.id, 10)
		end)
		self:addButton("【" .. v.name .. "】 熟练度 + 100", function()
			role:addSkillZhaoExp(v.id, 100)
		end)
		self:addButton("【" .. v.name .. "】 熟练度 + 1000", function()
			role:addSkillZhaoExp(v.id, 1000)
		end)
	end
	self:addButton("返回", function()
		self:setOneTypeSkills(self.__OneSkillList)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/04/02 18:05:53
-- @desc 一键系列
function TestGMLayer:yiJianButtons()
	self.ListView:removeAllItems()
	local role = User:getRole()
	self:addButton("恢复孩童疲劳值", function()
		local role = User:getRole()
		local inherit = role:getAttr("inherit")
		inherit.endurance = 1000
		PopText("成功恢复疲劳值")
	end)
	self:addButton("一键升级",function()
		local inheritCount = Helper:getDef(role:getAttr("inheritCount"),0)
		local useCount = Helper:getDef(role:getFlag("测试升级次数"),0) - 1
		local lvList = {
			[1] = 1001,
			[2] = 1001,
			[3] = 1001,
			[4] = 1001,
			[5] = 1001,
			[6] = 1001,
		}
		-- if inheritCount >= 5 then
		-- 	PopText("你已不可使用该功能")
		-- end
		local lv = lvList[inheritCount + 1]
		local exp = (0.1 * (lv+4) ^ 3+1)
		if useCount < inheritCount then
			role:setAttr("exp",exp)
			-- role:setAttr("exp",12802408)
			local skills = {"jibenanqi", "jibenbianfa", "jibendaofa", "jibengunfa", "jibenjianfa", "jibenneigong", "jibenqinggong", "jibenquanjiao", "jibenzhaojia", "jibenshuangchi", "jibenqinfa"}
			for k,v in pairs(skills) do 
				role:setSkill(v,{id = v, exp = Skill:getExp(lv - 1)})
			end
			role:setAttr("money",10000000)
			role:setAttr("pot",10000000)
			role:setFlag("测试升级次数",inheritCount + 1)
			PopText("升级完成")
			print("================================",role:getAttr("lv"),role:getNumAttr("lv"),role:getLv())
		else
			PopText("每次传承只能使用一次该功能")			
		end
	end)

	self:addButton("升级武功",function()
		local role = User:getRole()
		local skills = role:getSkills()
		for skillId,skill in pairs(skills) do
			role:addSkillLv(skillId, 1000 - role:getSkillLv(skillId))
		end
		PopText("武功等级1000级")
	end)

	self:addButton("一键互博",function()
		if role:isHaveImprintingId("zuoyouhuboyin") == true then
			PopText("已经拥有互搏神通印记")
			return
		end
		local meridianImprinting = role:getAttr("meridianImprinting")
		table.insert(meridianImprinting, {imprintingId = "zuoyouhuboyin"})
		role:setAttr("meridianImprinting", meridianImprinting)
		role:setAttr("leftRightFightExp", 901)
	end)

	self:addButton("一键五转",function()
		role:setAttr("inheritCount", 5)
	end)

	self:addButton("容貌+100", function()
		if role:getAttr("looks") <= 5500 then
			role:addAttr("looks", 100)
		else
			PopText("您已经宇宙无敌漂亮了,不要再加了!!!!!!!!!!")
		end
	end)

	self:addButton("年龄 + 5岁", function()
		if role:getAge() <= 200 then
			role:addAttr("gamingTime", 5 * 6 * 24 * 3600)
			role:getAgeWithChinese()
		else
			PopText("我没看错???200多岁的仙人!!!!!!!!!!!")
		end
	end)

	self:addButton("返回", function()
		self:setTestGMButton()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/01/29 15:47:03
-- @desc 神兵材料添加
function TestGMLayer:setDuanZaoButton()
	self.ListView:removeAllItems()
	local items = {
		{id = "duanzaocailiao1", count = 1},
		{id = "duanzaocailiao2", count = 1},
		{id = "duanzaocailiao3", count = 1},
		{id = "duanzaocailiao4", count = 1},
		{id = "duanzaocailiao5", count = 1},
		{id = "duanzaocailiao6", count = 1},
		{id = "duanzaocailiao7", count = 1},
		{id = "duanzaocailiao8", count = 1},
		{id = "duanzaocailiao9", count = 1},
		{id = "duanzaocailiao10", count = 1},
		{id = "duanzaocailiao11", count = 1},
		{id = "duanzaocailiao12", count = 1},
	}
	for k,v in pairs(items) do 
		local item = Item:getOneItemByKey(v.id)
		if item ~= nil then
			self:addButton(item.name,function()
				self:addRoleItem(v.id,Helper:getDef(v.count,99))
			end)
		else
			print("-----------------:",v.id,"不存在此物品")
		end
	end
	self:addButton("返回", function()
		self:setTestGMButton()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/01/29 15:57:05
-- @desc 淬炼材料添加
function TestGMLayer:setCuiLianButton()
	self.ListView:removeAllItems()
	local items = {
		{id = "cuiliancailiao1", count = 30},
		{id = "cuiliancailiao2", count = 30},
		{id = "cuiliancailiao3", count = 30},
		{id = "cuiliancailiao4", count = 30},
		{id = "cuiliancailiao5", count = 30},
		{id = "cuiliancailiao6", count = 30},
		{id = "cuiliancailiao7", count = 30},
		{id = "cuiliancailiao8", count = 30},
		{id = "cuiliancailiao9", count = 30},
		{id = "cuiliancailiao10", count = 30},
		{id = "cuiliancailiao11", count = 30},
		{id = "cuiliancailiao12", count = 30},
	}
	for k,v in pairs(items) do 
		local item = Item:getOneItemByKey(v.id)
		if item ~= nil then
			self:addButton(item.name,function()
				self:addRoleItem(v.id,Helper:getDef(v.count,99))
			end)
		else
			print("-----------------:",v.id,"不存在此物品")
		end
	end
	self:addButton("返回", function()
		self:setTestGMButton()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/02/01 18:06:58
-- @desc 燃料按钮列表
function TestGMLayer:setRanLiaoButton()
	self.ListView:removeAllItems()
	local items = {
		{id = "duanzaoranliao1", count = 30},
		{id = "duanzaoranliao2", count = 30},
		{id = "duanzaoranliao3", count = 30},
		{id = "duanzaoranliao4", count = 30}
	}
	for k,v in pairs(items) do 
		local item = Item:getOneItemByKey(v.id)
		if item ~= nil then
			self:addButton(item.name,function()
				self:addRoleItem(v.id,Helper:getDef(v.count,99))
			end)
		else
			print("-----------------:",v.id,"不存在此物品")
		end
	end
	self:addButton("返回", function()
		self:setTestGMButton()
	end)
end

function TestGMLayer:updateBookLv()
	local BookLiterary = require("app.models.book.BookLiterary")
	self:addButton("文学书籍300级",function()
		local role = User:getRole()
		
		local literaryBox = role:getAttr("literaryBox")
		
		for i, v in ipairs(literaryBox) do
			literaryBox[i].exp = BookLiterary:getExp(300)
		end
		local userList = PoisonFormula:getUserPoisonFormula()
		userList = {}
		PoisonFormula:init()
		role:setSkill("dushushizi",  {id = "dushushizi", exp = Skill:getExp(500)})

		-- local pfSkill = ForgeSkill:getUserFoegeKnowledge()
		-- pfSkill = {}

		-- local unpfSkill = ForgeSkill:getUserForgeUnLearnKnowledge()
		-- unpfSkill = {}
		ForgeSkill:clear()

		ForgeSkill:init()

	end)
end
function TestGMLayer:setAttrButton()
	local role = User:getRole()
	local attrList = {
		["jing"] = {name = "精力回满",maxId = function() return role:getJingMax() end},
	}
	for k,v in pairs(attrList) do
		self:addButton(v.name,function()
			if type(v.maxId) == "function" then
				role:setAttr(k, v.maxId())
			else
				role:setAttr(k,tonumber(role:getFinalAttr(v.maxId)))
			end
			PopText(role:getCHAttrName(k).."已满")
		end)
	end
end
function TestGMLayer:setAddItemButton() 
	self.ListView:removeAllItems()
	local items = {
		{id = "qiannengdan"},
		{id = "tainxiangyulu1"},
		-- {id = "fenshenfu"},
		{id = "dundifu"},
		{id = "jingxinwan"},
		{id = "menpaicanye1"},
		{id = "menpaicanye2"},
		{id = "menpaicanye3"},
		{id = "menpaicanye4"},
		{id = "chunjie504",count = 1},
		{id = "suoyoushuji1",count = 1},
		{id = "jingmai100"},
		{id = "jingmai101"},
		{id = "jingmai102"},
		{id = "jingmai103"},
		{id = "jingmai104"},
		{id = "jingmai105"},
		{id = "jingmai106"},
		{id = "jingmai107"},
		{id = "jian120",count = 1},
		{id = "dao119",count = 1},
		{id = "gun116",count = 1},
		{id = "bian112",count = 1},
		{id = "anqi109",count = 1},
		{id = "yuanxiaoleiji3",count = 1},
		{id = "yuanxiaoleiji4",count = 1},
		{id = "xinggongsan"},
		{id = "cglingpai1",count = 1},
		{id = "cglingpai2",count = 1},
		{id = "cglingpai3",count = 1},
		{id = "cglingpai4",count = 1},
		{id = "zouxuezhenfa1",count = 1},
		{id = "wabaojiangli4",count = 1},
	}
	for k,v in pairs(items) do 
		local item = Item:getOneItemByKey(v.id)
		if item ~= nil then
			self:addButton(item.name,function()
				self:addRoleItem(v.id,Helper:getDef(v.count,99))
			end)
		else
			print("-----------------:",v.id,"不存在此物品")
		end
	end
	self:addButton("返回", function()
		self:setTestGMButton()
	end)
end
function TestGMLayer:addRoleItem(itemId,count)
	if type(itemId) ~= "string" or type(count) ~= "number" then
		PopText("请勿修改数据")
		return
	end
	local item = Item:getOneItemByKey(itemId)
	local role = User:getRole()
	if item ~= nil then
		if role:checkCanBuyThings(itemId,count) == true then
			role:addItemCount(itemId,count)
			PopText("物品"..item.name.."增加"..tostring(count))
		end
	end
end
function TestGMLayer:addButton(name, func)
	if name then
		if GameChannelContext:checkGMIsOpen(name) == false then
			return
		end
	else
		return 
	end

	local panel = self.Panel:clone()
	Helper:convertUIByParent(panel)

	if func == nil then
		return
	end

	panel.Text_button_1:setString(name)
	panel.Button_1:releaseFunc(function()
		func()
	end)
	panel.Button_1:setSize(800,100)

	self.ListView:pushBackCustomItem(panel)
end

function TestGMLayer:setButton()
	self.Text_return:releaseFunc(function()
		self:hide(function()
			self:removeFromParent(true)
		end)
	end)
end

Helper:classDefNodeGetInstance(TestGMLayer)

return TestGMLayer
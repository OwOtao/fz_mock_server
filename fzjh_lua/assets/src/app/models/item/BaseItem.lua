local BaseItem =
{
	id = "id", 			-- 编号
	type = "", 			-- 类型
	bType = "",			-- 子类型
	name = "", 			-- 名称
	include = "",			-- 包含物品（ID）
	dsc = "", 	-- 描述
	useDsc = "",			-- 使用描述
	pickDesc = "",			-- 捡拾描述
	equipText = "",			-- 装备描述
	unwieldText = "",		-- 卸下描述
	sex = 0,				-- 性别需求
	damage = 0,				-- 伤害力
	protect = 0,			-- 保护力
	secStr = 0,				-- 力道
	secCon = 0,				-- 根骨
	secDex = 0, 			-- 身法
	secInt = 0, 			-- 悟性
	ap = 0,					-- 命中值
	parry = 0,				-- 招架值
	dodge = 0,				-- 闪避值
	unit = "",				-- 单位
	salePrice = 0, 			-- 出售价格
	buyPrice = 0,			-- 购买价格
	addExp = 0,				-- 经验增加量
	addPoint = 0,			-- 潜能增加量
	reHp = 0,				-- 气血回复量
	reMp = 0,				-- 内力回复量
	reJingli = 0,			-- 精力回复量
	addLooks = 0, 			-- 相貌增加量
	addLucky = 0,			-- 福缘增加量
	canFold = 0,			-- 可堆叠
	canUse = 0,				-- 可使用
	canEquip = 0,			-- 可装备
	combo = 0, 				-- 可合成
	canSell = 0,			-- 可出售
	canDrop = 0,			-- 可丢弃
	itemList = "",			-- 随机列表
	probability = "",		-- 概率列表
	deposit = true,			-- 是否允许移动至仓库 0 不可以 1 可以
	itemCanSale = 1, 		-- 能否出售/丢弃 0 不可以 1 可以(默认为可出售/丢弃)
	rewardNeedSpace = 0,	-- 宝箱类需要占用的空间
	timeend = nil,			-- 时间限制,过期删除 拥有两种填写格式 数字 : 填写秒数 字符串: 填写到达日期 例: 3600(存在时间为3600秒) $S20171111(字符串类型,2017年11月11日23时59分 消失)
	type2 = 0,				--[[ 剑-1长剑，2短剑，3软剑，4重剑，5刺剑。
								刀-1长刀，2短刀，3弯刀，4大环刀，5双刃斧。
								棍-1长棍，2长枪，3三节棍，4狼牙棒，5战戟。
								鞭-1长鞭，2软鞭，3九节鞭，4杆子鞭，5链枷。
								双持-1双环，2对剑 3双钩。]]
	canBatchUse = 0,		--能否批量使用

	treasure = 0, 			-- 是否宝物 0 不是 1 是
	buffid = nil,			-- 附带buffid
	rewardid = "",			-- 奖励id
	rewardIds = "",			-- 奖励组id,
	armsstage = 0,          -- 兵器品级
	canRewards = 0,         --0=不可调用奖励ID字段、1=可调用奖励ID字段
}

function BaseItem:create()
	-- local p = clone(BaseItem)
	local p = {}

	for k,v in pairs(self) do
		if type(v) ~= "function" then
			if type(v) == "table" then
				p[k] = clone(v)
			else
				p[k] = v
			end
		end
	end

	setmetatable(p,
	{
		__index = function(tb, k)
			local value = rawget(tb, k)
			if value == nil then
				value = clone(BaseItem[k])
				tb[k] = value
			end
			return value
		end
	})

	return p
end

function BaseItem:getId()
    return self.id
end

function BaseItem:getFlag(name)
	if self._flags == nil then
		self._flags = {}
	end
	if self._flags[name] == nil then
		self._flags[name] = 0
	end
	return self._flags[name]
end

function BaseItem:setFlag(name, value)
	if self._flags == nil then
		self._flags = {}
	end
	if self._flags[name] == nil then
		self._flags[name] = 0
	end
	self._flags[name] = value
end

function BaseItem:getItemAttr(name)
	return self[name]
end

-- 获得物品描述
function BaseItem:getDsc()
	if self.type == "宝物" then
		return Helper:getDef(self:__baoYuItemDsc(), self.dsc)
	end
	if self.wpType == "神兵" then
		return ShenBingDesc:getShenBingDesc(self,true)
	end
	return self.dsc
end

--去除物品名字颜色
function BaseItem:getNcname(itemName)
	local str = itemName

	for _, v in pairs(GetColorList()) do
		local s, e = string.find(str, v.id)
		if s ~= nil and e ~= nil then
			str = string.gsub(str,v.id,"")
		end
	end

	return str
end

-- 宝物类型道具描述修改
function BaseItem:__baoYuItemDsc()
	local gongxianShangRen =
	{
		wudang = "柳溪然",
		emei = "华研",
		huashan = "许阡陌",
		kunlun = "何明清",
		xingxiu = "高畅",
		baituoshan = "秦巳",
		tianshan = "肖燕",
		quanzhen = "钟珏",
		dali = "玉真",
		gaibang = "明长歌",
		mizong = "虚弥",
		wudu = "洛浅桑",
		tiezhang = "段天溟",
		riyueshenjiao = "莫离",
		mingjiao = "苏伏",
		kongtong = "杜岩",
		murong = "慕容杰",
		taohuadao =	"权大有",
		tangmen = "唐十八",
		gumu = "严风",
		haijing = "史龙",
		youming = "青冥",
		shaolin = "妙言",
		guanfu = "江毅",
		jinqianbang = "黑市商人",
	}
	if self.dsc then
		return self.dsc
	end
	local role = User:getRole()
	local familyId = role:getFamilyId()
	if gongxianShangRen[familyId] ~= nil and self.id == "gongxiandian100" then
		return "这是一块宝玉，价值不菲，若送与" .. gongxianShangRen[familyId] .. "可获得门派贡献点。"
	end
	return "这是一块宝玉，价值不菲，需要拜入师门才可使用。"
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/08 19:43:51
-- @desc 判断使用限制
function BaseItem:__checkUseLimit(role)
	if self.timesLimit == nil or type(self.timesLimit) ~= "string" then
		return true
	end

	local limits = string.split(self.timesLimit, ";")
	local status = role:getInheritFlag("tLimit_"..self.id)
	if status == 0 then
		status = {
			times = 0,
			updateTime = GetTime()
		}
    	role:setInheritFlag("tLimit_"..self.id, status)
	end
	local ret = switch(limits[1], {
        ["一周"] = function()
            return Helper:isThisWeek(GetTime(), status.updateTime) == false
        end,
        ["一个月"] = function()
            return Helper:isThisMonth(GetTime(), status.updateTime) == false
        end,
        ["default"] = function()
            return Helper:diffWithDate(GetTime(), status.updateTime) >= Helper:getDef(limits[1], 1)
        end
    })
    if ret == true then
    	status.times = 0
    	status.updateTime = GetTime()
    	role:setInheritFlag("tLimit_"..self.id, status)
    end
	return status.times < Helper:getDef(tonumber(limits[2]), 0) 
end


-- 判断是否能使用
function BaseItem:__checkCanUse(func,role)
	local role = Helper:getDef(role,User:getRole())
	local Item = require("app.models.item.Item")

	--处理限时道具
	if type(Item:getOneItemByKey(self.id).timeend) == "number" or type(Item:getOneItemByKey(self.id).timeend) == "string" then
		-- add by XiaoZhiWei 2017/10/21 15:32:44 只有背包中存在限时道具,并且时间已过期,才需要删除道具
		if (role:getItem(self.id) == nil and role:getZhaoShuXiang(self.id) == nil) or (type(role:getItem(self.id).time) == "number" and role:getItem(self.id).time <= GetTime()) then
			if func then
				role:refreshItems()
				func()
			end
			return false
		end
	end
	-- 特殊处理  只加气血的药品
	if self.type == "药品" and self.attr[1] == "qiPercent" then
		if (self.cooldown ~= nil and role:getFlag("药品使用时间") ~= 0 and GetTime() - role:getFlag("药品使用时间") > self.cooldown) or role:getFlag("药品使用时间") == 0 then
			return true
		else
			local descs =
			{
				"你还要等待一段时间才能再次服药",
				"你药性还未散，暂时还不能服用",
				"是药三分毒，此物不可过度服用"
			}
			PopText(descs[math.random(1, #descs)])
			return false
		end
	end

	if self.canRewards == 1 then
		local items = role:getAttr("items")
		if role:getAttr("weight") - #items < self.rewardNeedSpace then
			PopText("背包剩余容量不足" .. self.rewardNeedSpace .. "，无法使用物品")
			return false
		end
	end

	if self.type == "奇遇" then
		if (self.cooldown ~= nil and role:getFlag("奇遇道具使用时间") ~= 0 and GetTime() - role:getFlag("奇遇道具使用时间") > self.cooldown) or role:getFlag("奇遇道具使用时间") == 0 then
			return true
		else
			local descs =
			{
				"你还要等待一段时间才能再次饮酒",
				"酒物不可过度饮用",
			}
			PopText(descs[math.random(1, #descs)])
			return false
		end
	end

	local count = role:getFlag("商城物品使用限制")
	if count >= Item:getItemUseLimit("商城物品使用限制",self.id) and self.itype == "限制消耗品" then
		PopText("你的药性未散，再吃要中毒了！")
		return false
	end

	local count2 = role:getFlag("经验潜能次数")
	if count2 >= Item:getItemUseLimit("经验潜能次数") and (self.id == "qiannengdan" or self.id == "xuanhuangziqingdan") then
		PopText("你今天吃的太多，再吃就上瘾了！")
		return false
	end

	if (self.id == "tianxiangyulu1" or self.id == "jinglidan" or self.id == "liuyunganlu" or self.id =="2018jiaozi003" ) and role:getAttr("jing") >= role:getJingMax() then
		PopText("精力已满无法使用")
		return false
	end

	if self.id == "putizi1" and(role:getFinalAttr("neiliMax") + 300) > role:getNeiLiLimit() then
		PopText("你的内力已接近上限，无法再服用此药")
		return false
	end

	--
	if self.attr and self.attr[1] and self.attr[1] == "neiliMax" and(role:getFinalAttr("neiliMax") + 110) > role:getNeiLiLimit() then
		PopText("你的内力最大值已接近上限，请提升上限后再来服药")
		return false
	end

	-- 紧急修复
	if self.id == "guanfugongwen" then
		RichPrint("main", "你打开公文，上面龙飞凤舞写着一排草字：\n户籍销毁，批准。\n扬州知府 程药发")
		return false
	end

	-- 左右互搏速成丹
	local Meridian = require("app.models.Meridian.Meridian")
	if self.id == "zuoyouhubo3" and (Meridian:checkCanOpenLeftRightFight() ~= true or  role:getAttr("leftRightFightExp") >= 901)then
		PopText("这种丹药现在对你来说没什么效果")
		return false
	end

	-- 香薰炉
	if self.id == "jingmai100" then
		if role:getLv() < 350 and role:getFlag("开启经脉系统") == 0 then
			PopText("现在的你还不适合使用")
			return false
		end

		if role:getTimeLimitFlag("真气加成") ~= 0 then
			PopText("香薰炉还在烧着，不用再点香了")
			return false
		end
	end

	-- 真元丹
	if self.id == "jingmai105" and role:getLv() < 350 and role:getFlag("开启经脉系统") == 0 then
		PopText("这种丹药现在对你来说没什么效果")
		return false
	end

	-- 经脉丹
	if self.id == "jingmai103" then
		if role:getLv() < 350 and role:getFlag("开启经脉系统") == 0 then
			PopText("现在的你还不适合服用这种丹药")
			return false
		end

		if role:getDayFlag("经脉丹使用次数") >= 15 then
			PopText("已达到本日服用上限！")
		return false
		end
	end

	-- 真气丹
	if self.id == "jingmai101" then
		if role:getDayFlag("真气丹使用次数") >= 5 then
			PopText("已达到本日服用上限！")
			return false
		end

		if role:getLv() < 350 and role:getFlag("开启经脉系统") == 0 then
			PopText("现在的你还不适合服用这种丹药")
			return false
		end
	end


	-- 渡元丹
	if self.id == "jingmai105" and role:getTimeLimitFlag("冲穴加成") == 1 then
		PopText("渡元丹药劲未散，是药三分毒，适可而止吧！")
		return false
	end

	--
	if self.id == "jingmai107" then
		if role:getLv() < 350 and role:getFlag("开启经脉系统") == 0 then
			PopText("现在的你还不适合服用这种丹药")
			return false
		end

		if role:getTimeLimitFlag("冲穴成功") ~= 0 then
			PopText("活络丸药劲未散，是药三分毒，还是少服用为妙！")
			return false
		end
	end

	if self:__checkUseLimit(role) == false then
		PopText("已达到本周期使用次数上限！")
		return false
	end

	if self.type == "笔记" then
		local skillRange = string.split(self.skillcondition,";")
		if MapIsEmpty(skillRange) then
			return true
		end
		local rangeText = string.split(self.skilltext,";")

		local min = tonumber(skillRange[1])
		local minText = rangeText[1]
		
		local max = tonumber(skillRange[2])
		local maxText = rangeText[2]
		
		local skillLv = role:getSkillLv(self.skillid)

		if skillLv == 0 then
			PopText(minText)
			return false
		end

		if skillLv <= min then
			PopText(minText)
			return false
		else
			if max ~= nil and skillLv >= max then
				PopText(maxText)
				return false
			end
		end
	end

	return true
end

-- 限制类物品记录初始化
function BaseItem:__initRoleFlag(role)
	local role = Helper:getDef(role,User:getRole())
	-- 使用限制初始化
	--限制消耗品 一天3次
	if Helper:diffWithDate(GetTime(), role:getFlag("限制消耗品服用时间")) >= 1 then
		role:setFlag("商城物品使用限制", 0)
		role:setFlag("限制消耗品服用时间", GetTime())
	end

	--潜能丹，经验丹 一天20颗
	if Helper:diffWithDate(GetTime(), role:getFlag("经验潜能服用时间")) >= 1 then
		role:setFlag("经验潜能次数", 0)
		role:setFlag("经验潜能服用时间", GetTime())
	end
end

-- 限制类物品记录更新
function BaseItem:__updateRoleFlag(role)
	if role == nil then
		role = User:getRole()
	end
	-- 限制消耗品数量统计
	local count = role:getFlag("商城物品使用限制")
	if self.itype == "限制消耗品" then
		role:setFlag("商城物品使用限制", count + 1)
	end

	local count2 = role:getFlag("经验潜能次数")
	if self.id == "xuanhuangziqingdan" or self.id == "qiannengdan" then
		role:setFlag("经验潜能次数", count2 + 1)
	end


	if self.type == "药品" and self.attr[1] == "qiPercent" then
		role:setFlag("药品使用时间", GetTime())
	end

	-- 真气丹 限制
	if self.id == "jingmai101" then
		role:setDayFlag("真气丹使用次数", role:getDayFlag("真气丹使用次数") + 1)
	end

	-- 经脉丹
	if self.id == "jingmai103" then
		role:setDayFlag("经脉丹使用次数", role:getDayFlag("经脉丹使用次数") + 1)
	end
end

-- 元宝替代消耗
function BaseItem:__yuanBaoInsteadGoods(func)
	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
	local dialog = DialogALayer:getInstance()

	local desc, str
	desc = "你的背包没有" .. tostring(self.name)
	str = "是否需要购买使用？"

	dialog:show(desc, str)

	dialog:setButton1("是", function()
		PopYuanBaoBuyItemLayer(self.id, function(eventType)
			if eventType == "success" then
				-- 限制消耗品数量统计
				self:__updateRoleFlag()

				-- 使用描述
				self:itemUseDescShow()

				-- 特殊函数回调（分身符，遁地符等）
				if func then
					func()
				end
			end
		end)
	end)
	dialog:setButton2("否", function()
	end)
	dialog:setBack(false)
end

-- 使用物品
-- itemMaxCount 一组物品的最大使用数量
function BaseItem:useItem(func, layer, isShowDialog, isShowPrintMsg, role,itemMaxCount)
	if isShowDialog == nil then
		isShowDialog = true
	end
	if isShowPrintMsg == nil then
		isShowPrintMsg = true
	end

	if role == nil then
		role = User:getRole()
	end

	-- 限制类物品记录初始化
	self:__initRoleFlag(role)

	-- 检查是否能够使用 类型为可使用时，才允许使用  （canUseSpecial 特殊能使用类型：能使用，但不能在仓库中直接使用的类型）
	if not(self.canUse == 1 or self.canUse == true or self.canUseSpecial == 1) or self:__checkCanUse(func,role) == false then
		print("检查为不可使用", self.canUse, self.canUseSpecial)
		if self.id == "shimenwupin29" or self.id == "shimenwupin30" or self.id == "shimenwupin32" or self.id == "shimenwupin33" then
		else
			print("检查为不可使用", self.canUse, self.canUseSpecial)
			return
		end
	end

	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
	local dialog = DialogALayer:getInstance()
	dialog:hide()

	if self.type == "玩偶" then
		isShowDialog = false
	end

	local itemUseType

	if isShowDialog == false and isShowPrintMsg == false then
		itemUseType = ITEM_USE_TYPE.USE_ITEM_CONFIRM
	elseif isShowDialog == false then
		itemUseType = ITEM_USE_TYPE.USE_ITEM_ONLY_SHOW_DESC
	else
		if self.canBatchUse == 1 and type(itemMaxCount) == "number" and itemMaxCount > 1 then
			itemUseType = ITEM_USE_TYPE.USE_ITEM_BATCH
		else
			itemUseType = ITEM_USE_TYPE.USE_ITEM_SHOW_DIALOG
		end
	end

	-- @desc 添加role输出对象
	do
		local RoleGlobalLayer = require("app.views.layer.RoleLayer.RoleGlobalLayer")
		RoleGlobalLayer:create(role)
	end

	role:useItem(self.id, func, itemUseType, itemMaxCount)

end

-- 使用物品描述 文本提示
function BaseItem:itemDescShow(func)

	RichPrint("main", self.useDsc)

	if func ~= nil then

	end

	if MapIsEmpty(self.afterDesc) then
		return
	end
	for i = 1, #self.afterDesc do
		if self.afterDesc[i] ~= nil then
			MainControllLayer:delayFunc(i, function()
				local stringList = string.split(self.afterDesc[i], "#suiji")
				local str = ""
				if MapIsEmpty(stringList) == true then
					str = self.afterDesc[i]
				else
					str = stringList[math.random(1, #stringList)]
				end

				RichPrint("main", tostring(str))
				-- RichPrint("main", self.afterDesc[i])
			end)
		end
	end
end

-- 可使用物品
function BaseItem:storeItemUse(func, isShowDialog)
	if PRINT_MODE == 1 then
		print("self.canUse = " .. tostring(self.canUse))
	end
	if isShowDialog == nil then
		isShowDialog = true
	end

	-- 限制类物品记录初始化
	self:__initRoleFlag()


	-- 检查是否能够使用 类型为可使用时，才允许使用  （canUseSpecial 特殊能使用类型：能使用，但不能在仓库中直接使用的类型）
	if not(self.canUse == 1 or self.canUse == true or self.canUseSpecial == 1) or self:__checkCanUse(func) == false then
		return
	end

	if self.type == "节日酒" then
		self:__useJuHuaJiu(func)
		return
	end

	local role = User:getRole()
	local item = role:getItem(self.id)
	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
	local dialog = DialogALayer:getInstance()
	dialog:hide()

	-- 弹出框的弹出文本
	local desc, str = tostring(self.dsc), "将消耗" .. tostring(self.unit) .. tostring(self.name) .. "，是否确定？", ""

	--  判断的开关
		do
		-- 判断是否有包月分身符
		if PRINT_MODE == 1 then
			print("role:monthFenShenFuIsValid() == " .. tostring(role:monthFenShenFuIsValid()))
			print("self.id == " .. tostring(self.id))
		end
		if role:monthFenShenFuIsValid() == true and self.id == "fenshenfu" then
			HttpManagerEx:checkGoodsValid({"byfenshenfu"}, function(status, errcode, errmsg, data)
				if 200 == status and 0 == errcode then
					local is_byfenshenfu = false
					for k,v in pairs(data) do 
                        if "byfenshenfu" == v.itemId and v.number > 0 then 
                            is_byfenshenfu = true
                        end
                    end
					if is_byfenshenfu then
						-- 显示使用后文本
						local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
						local dialog = DialogALayer:getInstance()
						dialog:hide()
						RichPrint("main", self.useDsc)
						if MapIsEmpty(self.afterDesc) then
							return
						end
						for i = 1, #self.afterDesc do
							if self.afterDesc[i] ~= nil then
								dialog:delayFunc(i, function()
									RichPrint("main", self.afterDesc[i])
								end)
							end
						end
						PopText("正在使用包月分身符")

						-- 特殊函数回调（分身符，遁地符等）
						if func then
							func()
						end
					else
						role:updateMonthFenShenFuStatus(0)
						self:storeItemUse(func)
					end
				else
					PopText("网络请求出错,请换个网络环境再试!")
				end
			end, IS_SHOW_WAITING)
			return true
		end
	end

	-- 判断物品是否存在
	if(not item or MapIsEmpty(item) == true) then
		-- 暂时只有分身符能够使用removeYuanBao接口
		if self.priceUnit == "yuanbao" then
			-- 元宝替代消耗
			self:__yuanBaoInsteadGoods(func)
		else
			PopText("物品不存在，可能已经消耗")
		end
		return
	end

	-- 直接使用类型
	if self.type == "书信" or isShowDialog == false then
		-- 限制消耗品数量统计
		self:__updateRoleFlag()
		
		-- 使用描述
		self:itemUseDescShow(func)
		return
	end

	-- 弹出框主体
	dialog:show(desc, str)
	dialog:setButton1("是", function()

		-- 限制消耗品数量统计
		self:__updateRoleFlag()

		-- 使用描述
		self:itemUseDescShow(func)

		-- -- 特殊函数回调（分身符，遁地符等）
		-- if func then
		-- 	func()
		-- end
	end)
	dialog:setButton2("否", function()
	end)
	dialog:setBack(false)
end

-- 弹出文本
function BaseItem:__showPopText(attr, value, role)
	if attr == nil or value == nil then
		return
	end
	if role == nil then
		role = User:getRole()
	end
	local text = role:getCHAttrName(attr)
	if attr == "qiPercent" then
		if role:getAttr("onlyId") == User:getRoleAttr("onlyId") then
			text = "你的伤势好了不少，伤势回复"
		else
			text = role:getAttr("name") .. "的伤势好了不少，伤势回复"
		end
		if value <= 1 then
			value = math.floor(value * role:getFinalAttr("qiMax"))
		end
	end

	if text ~= nil and tonumber(value) ~= nil then
		if tonumber(value) > 0 then
			PopText(tostring(text) .. " + " .. tostring(value))
		else
			PopText(tostring(text) .. " - " .. tostring(math.abs(value)))
		end
	end
end

--
function BaseItem:__getItemAfterUse(isMapUse,role)
	if role == nil then
		role = User:getRole()
	end
	-- 非副本使用情况 并且 列表不为空
	if isMapUse ~= true and self.itemList ~= nil and string.len(self.itemList) > 0 then
		local Item = require("app.models.item.Item")
		local itemId, count = self:randomItemsAndCount()
		local item = Item:getOneItemByKey(itemId)
		if item then
			-- role:addItemCount(self.id, 1)
			role:addItemCount(item.id, count)

			local str = "获得物品" .. item.name
			if count > 1 then
				str = str .. " X" .. tostring(count)
			end
			PopText(str)
		end
		-- return
	end
end

-- 物品使用
function BaseItem:__use(dialog, func, isMapUse,role)
	if role == nil then
		role = User:getRole()
	end

	-----------------------------------------------------------
	---------------  友盟接入
	if device.platform == "ios" then
		if self.priceUnit == "yuanbao" then
			Mob.use(self.id, 1, self.buyPrice)
		else
			Mob.use(self.id, 1, self.buyPrice)
		end
	end

	self:__getItemAfterUse(isMapUse)
	-- -- 非副本使用情况 并且 列表不为空
	-- if isMapUse ~= true and self.itemList ~= nil and string.len(self.itemList) > 0 then
	-- 	local Item = require("app.models.item.Item")
	-- 	local itemId, count = self:randomItemsAndCount()
	-- 	local item = Item:getOneItemByKey(itemId)
	-- 	if item then
	-- 		-- role:addItemCount(self.id, 1)
	-- 		role:addItemCount(item.id, count)
	-- 		local str = "获得物品"..item.name
	-- 		if count > 1 then
	-- 			str = str.." X"..tostring(count)
	-- 		end
	-- 		PopText(str)
	-- 	end
	-- 	-- return
	-- end
	if type(self.attr) == "table" then
		local index, attr = 1
		if #self.attr > 1 then
			index = math.random(1, #self.attr)
			attr = self.attr[index]

			local function jieRiJiu()
				local randomCount = 1	-- 限制随机次数,放置死循环
				
				if Map:getMapState("fb15") == MAP_STATE.COMPLETE then
					-- 当前进度小于 16 不能触发论剑战斗奖励加成
					while attr == "chufa101" do
						index = math.random(1, #self.attr)
						attr = self.attr[index]
						randomCount = randomCount + 1
						if randomCount > 20 then
							index = #self.attr + 1
							attr = self.attr[index]
							break
						end
					end
				elseif Map:getMapState("fb10") == MAP_STATE.COMPLETE then
					-- 当前进度小于11 不能触发奖励加成效果
					while attr == "chufa100" or attr == "chufa101" do
						index = math.random(1, #self.attr)
						attr = self.attr[index]
						randomCount = randomCount + 1
						if randomCount > 20 then
							index = #self.attr + 1
							attr = self.attr[index]
							break
						end
					end
				end

				-- 任务效果加成BUFF
				local rewardBuff = role:getFlag("奖励翻倍") == 0 and 1 or Helper:getDef(role:getFlag("奖励翻倍"), 1)
				if attr then
					if attr == "chufa100" then
						role:setFlag("飞贼任务奖励加成", 2 * rewardBuff)
					elseif attr == "chufa101" then	-- 论剑效果加成BUFF
						role:setFlag("论剑战斗奖励加成", 2 * rewardBuff)
					else
						role:addAttr(attr, self.value * rewardBuff)
						self:__showPopText(attr, self.value * rewardBuff)
					end
				end

				-- 数量减1
				role:addItemCount(self.id, - 1)
				if func then
					func()
				end

				if MapIsEmpty(self.afterDesc) then
					return
				end
				if rewardBuff > 1 then
					index = index + 5
				end

				if self.afterDesc[index] ~= nil then
					local stringList = string.split(self.afterDesc[index], "#suiji")
					local str = ""
					if MapIsEmpty(stringList) == true then
						str = self.afterDesc[index]
					else
						str = stringList[math.random(1, #stringList)]
					end

					RichPrint("main", tostring(str))
				end
			end

			-- 节日酒特殊处理
			if self.type == "节日酒" then
				if role:itemCanUse(self.id, 1) then
					jieRiJiu()
				else
					PopText("物品不存在，可能已经消耗")
				end
				return
			end


			if isMapUse ~= true then
				if attr then
					role:addAttr(attr, self.value)
					self:__showPopText(attr, self.value)
				end

				-- 数量减1
				role:addItemCount(self.id, - 1)
			else
				--不影响玩家属性
			end

			if func then
				func()
			end

			if MapIsEmpty(self.afterDesc) then
				return
			end
			if self.afterDesc[index] ~= nil then
				local stringList = string.split(self.afterDesc[index], "#suiji")
				local str = ""
				if MapIsEmpty(stringList) == true then
					str = self.afterDesc[index]
				else
					str = stringList[math.random(1, #stringList)]
				end

				RichPrint("main", tostring(str))
			end
		else
			if self.canRewards == 1 then
				Item:getChestRewardByKey(self.id)
			end

			local value = 0
			if type(self.value) == "string" then
				value = tonumber(Helper:GetValueFromScript(self.value, {lv = role:getLv()}))
			elseif type(self.value) == "number" then
				value = self.value
			end

			if isMapUse ~= true then
				if self.attr[1] then
					role:addAttr(self.attr[1], value)
					self:__showPopText(self.attr[1], value)
				end

				-- 数量减1
				role:addItemCount(self.id, - 1)
			end
			if func then
				func()
			end

			if MapIsEmpty(self.afterDesc) then
				return
			end

			if value == 0 then
				RichPrint("main", self.afterDesc[1])
			else
				if MapIsEmpty(self.afterDesc) then
					return
				end
				for i = 1, #self.afterDesc do
					if self.afterDesc[i] ~= nil then
						dialog:delayFunc(i, function()
							RichPrint("main", self.afterDesc[i])
						end)
					end
				end
			end
		end
	else
		-- 数量减1
		if isMapUse ~= true then
			role:addItemCount(self.id, - 1)
			if func then
				func()
			end
		end
		if MapIsEmpty(self.afterDesc) then
			return
		end
		for i = 1, #self.afterDesc do
			if self.afterDesc[i] ~= nil then
				dialog:delayFunc(i, function()
					RichPrint("main", self.afterDesc[i])
				end)
			end
		end
	end
end

-- 副本物品直接使用
function BaseItem:itemUseDescShow(func, isMapUse, delayTime,role)
	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
	local dialog = DialogALayer:getInstance()
	dialog:hide()
	RichPrint("main", self.useDsc)
	self:__use(dialog, func, isMapUse,role)
end

-- 宝箱类物品的随机方法
function BaseItem:randomItemsAndCount()
	if self.itemList == nil then
		return nil
	end
	local count, countList = 1, {}
	-- 判断物品数量是否为空
	if self.itemCount ~= nil then
		-- 数字类型,直接赋值
		if type(self.itemCount) == "number" then
			count = self.itemCount
			-- 字符串类型 拆分
		elseif type(self.itemCount) == "string" then
			countList = string.split(self.itemCount, ";")
		end
	end

	local list = string.split(self.itemList, ";")
	local index = Helper:RandomIndexByPercentWithString(self.probability)
	if index == nil then
		return nil, count
	end
	-- 判断数量列表是否存在,存在则取值
	if MapIsEmpty(countList) == false then
		count = countList[index]
	end

	-- 纠正: 数量为空或者不是数字类型时,赋值为1   (为负数的情况未处理)
	if count == nil or type(count) ~= "number" then
		count = 1
	end

	return list[index], count
end



------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-------------------          重阳节活动 菊花酒 方法
function BaseItem:__useJuHuaJiu(func,role)
	local Item = require("app.models.item.Item")
	local item = Item:getOneItemByKey(self.id .. "_da")
	if item ~= nil and item.itemList ~= nil then
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:show("面对醇香的菊花酒，你决定")
		dialog:setButton1("小口抿", function()
			RichPrint("main", "你将酒倒入杯中并抿了一小口。")

			role:setFlag("奖励翻倍", 1)
			self:itemUseDescShow(
			function()
				local item = Item:getOneItemByKey(self.id .. "_xiao")
				if item ~= nil then
					-- 物品使用后获取物品列表
					item:__getItemAfterUse()
				end
				if func then
					func()
				end
			end,nil,nil,role)
		end)
		dialog:setButton2("大口喝", function()
			RichPrint("main", "你开始抱着酒坛大口大口地喝酒。")
			--  一定概率全部消耗完
			if math.random(1, 10) > 1 then
				role:setFlag("奖励翻倍", 3)
				self:itemUseDescShow(
				function()
					local item = Item:getOneItemByKey(self.id .. "_da")
					if item ~= nil then
						-- 物品使用后获取物品列表
						item:__getItemAfterUse()
					end
					if func then
						func()
					end
				end,nil,nil,role)
			else
				-- 一口喝光，什么都不加
				role:addItemCount(self.id, - 1)
				role:setFlag("奖励翻倍", 1)
				RichPrint("main", "你喝了一口酒，感觉酒香醇厚，真乃美酒佳酿，干脆抱起酒坛一饮而尽，不想这酒后劲甚足，不一会你便呼呼大睡不省人事了，醒来一瞧整整一坛酒已经空空如也了。")
				if func then
					func()
				end
			end
		end)
	else
		role:setFlag("奖励翻倍", 1)
		self:itemUseDescShow(
		function()
			local item = Item:getOneItemByKey(self.id .. "_xiao")
			if item ~= nil then
				-- 物品使用后获取物品列表
				item:__getItemAfterUse()
			end
			if func then
				func()
			end
		end,nil,nil,role)
	end
end

function BaseItem:__jieRiJiu()
	local randomCount = 1	-- 限制随机次数,放置死循环
	-- 当前进度小于11 不能触发奖励加成效果
	if Map:getMapState("fb15") == MAP_STATE.COMPLETE then
		-- 当前进度小于 16 不能触发论剑战斗奖励加成
		while attr == "chufa101" do
			index = math.random(1, #self.attr)
			attr = self.attr[index]
			randomCount = randomCount + 1
			if randomCount > 20 then
				index = #self.attr + 1
				attr = self.attr[index]
				break
			end
		end
	elseif Map:getMapState("fb10") == MAP_STATE.COMPLETE then
		-- 当前进度小于11 不能触发奖励加成效果
		while attr == "chufa100" or attr == "chufa101" do
			index = math.random(1, #self.attr)
			attr = self.attr[index]
			randomCount = randomCount + 1
			if randomCount > 20 then
				index = #self.attr + 1
				attr = self.attr[index]
				break
			end
		end
	end


	-- if role:getAttr("jindu") < 11 then
	-- 	while attr == "chufa100" or attr == "chufa101" do
	-- 		index = math.random(1, #self.attr)
	-- 		attr = self.attr[index]
	-- 		randomCount = randomCount + 1
	-- 		if randomCount > 20 then
	-- 			index = #self.attr + 1
	-- 			attr = self.attr[index]
	-- 			break
	-- 		end
	-- 	end

	-- 	-- 当前进度小于 16 不能触发论剑战斗奖励加成
	-- elseif role:getAttr("jindu") < 16 then
	-- 	while attr == "chufa101" do
	-- 		index = math.random(1, #self.attr)
	-- 		attr = self.attr[index]
	-- 		randomCount = randomCount + 1
	-- 		if randomCount > 20 then
	-- 			index = #self.attr + 1
	-- 			attr = self.attr[index]
	-- 			break
	-- 		end
	-- 	end
	-- end

	-- 任务效果加成BUFF
	local rewardBuff = role:getFlag("奖励翻倍") == 0 and 1 or Helper:getDef(role:getFlag("奖励翻倍"), 1)
	if attr then
		if attr == "chufa100" then
			role:setFlag("飞贼任务奖励加成", 2 * rewardBuff)
		elseif attr == "chufa101" then	-- 论剑效果加成BUFF
			role:setFlag("论剑战斗奖励加成", 2 * rewardBuff)
		else
			role:addAttr(attr, self.value * rewardBuff)
			self:__showPopText(attr, self.value * rewardBuff)
		end
	end

	-- 数量减1
	role:addItemCount(self.id, - 1)
	if func then
		func()
	end

	if MapIsEmpty(self.afterDesc) then
		return
	end
	if rewardBuff > 1 then
		index = index + 5
	end

	if self.afterDesc[index] ~= nil then
		local stringList = string.split(self.afterDesc[index], "#suiji")
		local str = ""
		if MapIsEmpty(stringList) == true then
			str = self.afterDesc[index]
		else
			str = stringList[math.random(1, #stringList)]
		end

		RichPrint("main", tostring(str))
	end
end


local function checkCanUseLuoPan(mapId,listStr)
	if type(mapId) ~= "string" or type(listStr) ~= "string" then
		return true
	end
	local list = string.split(listStr,",")
	for k,v in pairs(list) do 
		if v == mapId then
			return false
		end
	end
	return true
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/02 10:48:49
-- @desc 遁地符的使用
local checkListStr
local specialRoom = {
	["fb33_19"] = "fb33_16",
}
function BaseItem:useDunDiFu(role, mapId, roomId, func,useType,isShow)
	func = Helper:getDef(func,EMPTY_FUNC)
	--@desc 跳转特殊房间，如随机到33章剑湖宫，跳转到石板路
	if specialRoom[roomId] then
		roomId = specialRoom[roomId]
	end

	role = Helper:getDef(role, User:getRole())
	
	local isUserMap = false
	if string.find( mapId,"user_fb_" ) ~= nil then
		isUserMap = true
	end

	--增加不能使用遁地符的副本
	do
		local  TreasureList = require("script.others.Treasure")
		if checkListStr == nil then
			checkListStr = Helper:getDef(TreasureList["挖宝禁止"],{})
			checkListStr = Helper:getDef(checkListStr["1"],{})
			checkListStr = Helper:getDef(checkListStr["stopcopy"],"")
		end
		local map = User:getRole():getCurrMap()
		if map ~= nil and not MapIsEmpty(map) and map:getRoleIsInMap() == true and checkCanUseLuoPan(User:getRole():getCurrMapId(),checkListStr) == false then
			PopText("你心想遁地前往，但不料遁地失败，看来此地无法遁行。")
			return
		end
	end

	-- add by XiaoZhiWei 2017/07/31 19:10:08 找时间提取出去
	local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
	if RoleTaskControllor:clickMapLayer(role) == false then
		return
	end

	-- 地图刷新
	if isUserMap == false then
		local map = role:getMapById(mapId)
		local lastTime = role:getFlag(mapId)
		-- add by XiaoZhiWei 2017/05/02 17:27:58 去掉副本状态判断,解决遁地符使用问题
		if(lastTime ~= 0 and GetTime() - lastTime > MAP_REFRESH_INTERVAL) or lastTime == 0 then
		else
			--副本在冷却中，提示玩家刷新副本或等待副本自动刷新
			PopText("副本冷却中，请等待或手动重置后再执行任务")
			return
		end
		if map:canLeaveRoom() == false then
			PopText("当前不能使用遁地符")
			return
		end
	end

	local useFunc = function()
		if isUserMap then
			--@RefType [src.app.models.map.UserMap#UserMap]
			local UserMap = require("app.models.map.UserMap")
			UserMap:getUserMap(string.split(mapId,"user_fb_")[2],User:getUserId(),function (map,isSuccess)
				if isSuccess == false then
					return
				end

				map._isComingIn = true
				-- RichPrint("main", "HIC你进入大车，对车夫吆喝了几句。")
				-- RichPrint("main", "HIC车夫扬起手中鞭，吆喝道：看车！去"..tostring(map.name).."了。")
		
				local titleLayer = MainControllLayer:getLayer("TitleLayer")
				local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
				mapRoleLayer:show()
				mapRoleLayer:onResume()
				mapRoleLayer:maxZ()
				titleLayer:hide(true)
		
				-- 隐藏当前层
				-- self:fadeOut(0.3)
				map:setCallBackAndConnect(function()
					local mapLayer = MainControllLayer:getLayer("MapLayer")
					-- map:setMapForTask()	--主动任务，地图调整
					mapLayer:setMap(map)

					MainControllLayer:pushLayer("MapLayer")
					MessageCenter:notify("EnterMap",{map=map})
					if func then
						func(true)
					end
				end)

			end)
			return
		end

		--  副本冷却时间到达，做刷新处理
		local map = role:initMapById(mapId)
		map:setCallBackAndConnect(function()
			-- map:enterMap()
			map._isComingIn = true

			local ControllLayer = MainControllLayer
			local layer = ControllLayer:getLayer("MapLayer")
			layer:setMap(map)
			map:setCurrRoomId(roomId) -- 遁地符传送到指定的房间			
			layer:replaceRoom(roomId)
			ControllLayer:pushLayer("MapLayer")
			MessageCenter:notify("EnterMap",{map=map})

			User:setRoleAttr("currMapId", map.id)

			local titleLayer = ControllLayer:getLayer("TitleLayer")
			titleLayer:hide(true)

			local MapRoleLayer = ControllLayer:getLayer("MapRoleLayer")
			MapRoleLayer:show()
			MapRoleLayer:onResume()
			MapRoleLayer:maxZ()

			local layer = ControllLayer:getLayer("PrintLayer")
			layer:show(true)
			layer:setLocalZOrder(10)
			Audio:stopMusic()

			if func then
				func(true)
			end
		end)
	end

	if useType== SKILL_ITEM_DUNDIFU_TYPE then 
		if isShow == true then 
			self:storeItemUse(useFunc)    --二次确认使用遁地符
		else
			self:storeItemUse(useFunc,false)    --使用遁地符
		end
			
	else
		
		local limitCount = 49
		if DEBUG_MODE == 1 then
			limitCount = 5
		end
		local skillLv = role:getSkillLv("wuxingdunfa")
		local percent, addExp, addJing = 70, 0, - 5
		if skillLv < 100 then
			percent = 70
			addExp = 153
			addJing = - 5
		elseif skillLv < 200 then
			percent = 80
			addExp = 536
			addJing = - 4
		elseif skillLv < 300 then
			percent = 90
			addExp = 969
			addJing = - 3
		elseif skillLv < 400 then
			percent = 95
			addExp = 1416
			addJing = - 2
		elseif skillLv < 500 then
			percent = 98
			addExp = 1867
			addJing = - 1
		else
			percent = 100
			addExp = 0
			addJing = 0
		end

		-- add by XiaoZhiWei 2017/06/02 18:27:35 判断武学 判断精力 判断概率
		if role:getSpecialSkillEffect(SKILL_TYPE_DUNDI) ~= true or role:getAttr("jing") < math.abs(addJing)  then 
			if role:getAttr("jing") < math.abs(addJing) then -- addJing的值是小于等于0, role:getAttr("jing")不可能小于addJing
				if SKILL_ITEM_TYPE ~= useType then
					self:storeItemUse(useFunc)
				end
				func(false)

				PopText("您的精力不足，无法使用五行遁法")
			else
				if SKILL_ITEM_TYPE ~= useType then
					self:storeItemUse(useFunc)
				end
			end
		else
			-- add by XiaoZhiWei 2017/06/12 17:24:53 修改为先判断次数,再判断是否失败
			if role:getDayFlag("wuxingdunfa") >= limitCount then
				PopText("五行遁法一日只能使用四十九次，你今日使用已达上限。")
				if SKILL_ITEM_TYPE ~= useType then
					self:storeItemUse(useFunc)
				end
				func(false)
			elseif math.random(1, 100) > percent then
				RichPrint("main", "HIY你心中默念五行遁法的口诀，但却什么都没有发生，看来此次施术似乎是失败了。")
				PopText("五行遁法使用失败")
				role:addAttr("jing", addJing)
				func(false)
			else
				RichPrint("main", "HIY你心中默念五行遁法的口诀，只见金光一闪，你已经消失不见了。")
				useFunc()
				role:setDayFlag("wuxingdunfa", role:getDayFlag("wuxingdunfa") + 1)
				role:addAttr("jing", addJing)
				role:addSkillExp("wuxingdunfa", addExp)
			end
		end
	end
end

-- add by ZhangShengTang 2017/06/19 11:38:20
-- 物品升级功能 func 删除旧物品
function BaseItem:upgradeItem(role, func)
	if self.upgrade == nil then
		return false
	end

	if role == nil then
		role = User:getRole()
	end

	local strList = string.split(self.upgrade, ";")

	-- 升级材料
	local materialMap = {}

	-- 得到的新物品
	local itemMap = {}

	for i, v in ipairs(string.split(strList[1], ":")) do
		local itemId = string.split(v, ",") [1]
		local count = tonumber(string.split(v, ",") [2])
		table.insert(materialMap, {itemId = itemId, count = count})
	end

	for i, v in ipairs(string.split(strList[2], ":")) do
		local itemId = string.split(v, ",") [1]
		local count = tonumber(string.split(v, ",") [2])
		table.insert(itemMap, {itemId = itemId, count = count})
	end

	if role:getAttr("weight") - #role:getItems() < #itemMap then
		PopText("背包空间不足,无法升级")
		return false
	end

	local flag = true

	for i, v in ipairs(materialMap) do
		if role:getItemCount(v.itemId) < v.count then
			flag = false
			break
		end
	end

	if flag == false then
		return false
	else
		-- 删除旧物品
		func()

		for i, v in ipairs(materialMap) do
			local item = Item:getOneItemByKey(v.itemId)
			PopText("消耗" .. item.name .. " X " .. v.count)
			role:addItemCount(v.itemId, - v.count)
		end

		for i, v in ipairs(itemMap) do
			local item = Item:getOneItemByKey(v.itemId)
			PopText("获得" .. item.name .. " X " .. v.count)
			role:addItemCount(v.itemId, v.count)
		end
		self:itemDescShow()
	end

	return true
end



------------------------------ 神兵系统
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/11 14:07:22
-- @desc 兵器的基础属性
--硬度
function BaseItem:getWeaponYingDu(user,onlyBaseValue)
	if onlyBaseValue == nil then
		onlyBaseValue = false
	end
	if user == nil then
		user = User:getRole()
	end
	local baseValue = Helper:getDef(self.yindu,0)
	if onlyBaseValue then
		return baseValue
	end
	local addVaule = Helper:getDef(ShenBingEffct:getWeaponExtraYingDu(self,user),0)
	-- if DEBUG_MODE == 1 then
	-- 	print("------------------------兵器特性提升武器硬度----------------------------------",addVaule)
	-- end
	return baseValue + addVaule
end

--坚韧度
function BaseItem:getWeaponRenDu(user,onlyBaseValue)
	if onlyBaseValue == nil then
		onlyBaseValue = false
	end
	if user == nil then
		user = User:getRole()
	end
	local baseValue = Helper:getDef(self.rendu,0)
	if onlyBaseValue then
		return baseValue
	end
	local addVaule = Helper:getDef(ShenBingEffct:getWeaponrendu(self,user),0)
	-- if DEBUG_MODE == 1 then
	-- 	print("------------------------兵器特性提升武器坚韧度----------------------------------",addVaule)
	-- end
	return baseValue + addVaule
end

--重量
function BaseItem:getWeaponWeight(user,onlyBaseValue)
	if onlyBaseValue == nil then
		onlyBaseValue = false
	end
	if user == nil then
		user = User:getRole()
	end
	local baseValue = Helper:getDef(self.weight,0)
	if onlyBaseValue then
		return baseValue
	end
	local addVaule = Helper:getDef(ShenBingEffct:getWeaponExtraWeight(self,user),0)
	-- if DEBUG_MODE == 1 then
	-- 	print("------------------------兵器特性提升武器重量----------------------------------",addVaule)
	-- end
	return baseValue + addVaule
end

--伤害力(只是加持了兵器效果加成)
function BaseItem:getWeaponDamage(user,onlyBaseValue,fightRole)
	if onlyBaseValue == nil then
		onlyBaseValue = false
	end
	if user == nil then
		user = User:getRole()
	end
	local baseValue = Helper:getDef(self.damage,0)
	if onlyBaseValue then
		return baseValue
	end
	local addVaule = Helper:getDef(ShenBingEffct:getWeaponExtraDamage(self,user),0)
	-- if DEBUG_MODE == 1 then
	-- 	print("------------------------兵器特性提升武器伤害力----------------------------------",addVaule)
	-- end
	local value = baseValue + addVaule
	-- if DEBUG_MODE == 1 then
	-- 	print("name = "..self.name.."武器伤害力 = ",value)
	-- end
	return Helper:getRange(value,0) 
end 

--特性值
function BaseItem:getWeaponEffectNum(user,onlyBaseValue)
	return Helper:getDef(self.effctNum,0)
end

function BaseItem:initShenbingType2()
	local bType = self.bType
	if bType == nil or bType == "" then
		return
	end

	local type2
	switch(bType,
	{
		["长剑"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGJIAN end,
		["短剑"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.DUANJIAN end,
		["软剑"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.RUANJIAN end,
		["重剑"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.ZHONGJIAN end,
		["刺剑"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.CIJIAN end,

		["长刀"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGDAO end,
		["短刀"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.DUANDAO end,
		["弯刀"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.WANDAO end,
		["大环刀"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.DAHUANDAO end,
		["双刃斧"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.SHUANGRENFU end,

        ["长棍"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGGUN end,
		["长枪"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGQIANG end,
		["三节棍"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.SANJIEGUN end,
		["狼牙棒"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.LANGYABANG end,
		["战戟"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.ZHANJI end,

		["长鞭"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGBIAN end,
		["软鞭"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.RUANBIAN end,
		["九节鞭"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.JIUJIEBIAN end,
		["杆子鞭"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.GANZIBIAN end,
		["链枷"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.LIANJIA end,

		["双环"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.SHUANGHUAN end,
		["对剑"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.DUIJIAN end,
		["双钩"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.SHUANGGOU end,

		["锥形暗器"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.ZUIXINGANQI end,
		["圆形暗器"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.YUANXINGANQI end,
		["针形暗器"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.ZHENXINGANQI end,

		["古琴"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.GUQIN end,
		["笛子"] = function() type2 = Item.ITEM_TYPE.WEAPON_SUBTYPE.DIZI end,
	})

	self.type2 = type2
end

function BaseItem:getFlyWeapon()
    if self.flyWeapon == nil then
        error("非武器，不可调用该方法 getFlyWeapon " .. self.id)
    end
    return self.flyWeapon * ShenBingEffct:getWeaponFlyValue(self)
end

function BaseItem:canFlyWeapon()
    if self.flyWeapon == nil then
        error("非武器，不可调用该方法 canFlyWeapon " .. self.id)
    end
    return self:getFlyWeapon() == 1
end

function BaseItem:getBeFlyWeapon()
    if self.beflyWeapon == nil then
        error("非武器，不可调用该方法 getBeFlyWeapon" .. self.id)
    end

    return self.beflyWeapon * ShenBingEffct:getBeFlyWeapon(self)
end

function BaseItem:canBeFlyWeapon()
    if self.beflyWeapon == nil then
        error("非武器，不可调用该方法 canBeFlyWeapon" .. self.id)
    end
    return self:getBeFlyWeapon() == 1
end

function BaseItem:getBreakWeapon()
    if self.breakWeapon == nil then
        error("非武器，不可调用该方法 getBreakWeapon" .. self.id)
    end
    return self.breakWeapon * ShenBingEffct:getBreakWeapon(self)
end

function BaseItem:canBreakWeapon()
    if self.breakWeapon == nil then
        error("非武器，不可调用该方法 canBreakWeapon")
    end
    return self:getBreakWeapon() == 1
end

function BaseItem:getBrokenWeapon()
    if self.brokenWeapon == nil then
        error("非武器，不可调用该方法 canBrokenWeapon" .. self.id)
    end
    return self.brokenWeapon * ShenBingEffct:getBrokenWeapon(self)
end

function BaseItem:canBrokenWeapon()
    if self.brokenWeapon == nil then
        error("非武器，不可调用该方法 canBrokenWeapon")
    end
    return self:getBrokenWeapon() == 1
end

--获取兵器子类型
function BaseItem:getCurrWeaponType1()
    return self.type
end

--获取兵器子类型
function BaseItem:getCurrWeaponType2()
    return self.type2
end

--获取兵器子类型中文名
function BaseItem:getItemShowType()
    local type = self.type
	print("type =",type)
    if WEAPONSUBTYPE_IS_OPEN ~= true then
        return type
    end
    local type2 = self:getCurrWeaponType2()
    print("type2 = ",type2)
	local name 

    if type == Item.ITEM_TYPE.WEAPON_TYPE.DAO then
        switch(tostring(type2),
        {
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGDAO)] = function() name = "长刀" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.DUANDAO)] = function() name = "短刀" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.WANDAO)] = function() name = "弯刀" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.DAHUANDAO)] = function() name = "大环刀" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.SHUANGRENFU)] = function() name = "双刃斧" end,
        })
    elseif type == Item.ITEM_TYPE.WEAPON_TYPE.JIAN then
        switch(tostring(type2),
        {
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGJIAN)] = function() name = "长剑" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.DUANJIAN)] = function() name = "短剑" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.RUANJIAN)] = function() name = "软剑" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.ZHONGJIAN)] = function() name = "重剑" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.CIJIAN)] = function() name = "刺剑" end,
        })
    elseif type == Item.ITEM_TYPE.WEAPON_TYPE.GUN then
        switch(tostring(type2),
        {
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGGUN)] = function() name = "长棍" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGQIANG)] = function() name = "长枪" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.SANJIEGUN)] = function() name = "三节棍" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.LANGYABANG)] = function() name = "狼牙棒" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.ZHANJI)] = function() name = "战戟" end,
        })
    elseif type == Item.ITEM_TYPE.WEAPON_TYPE.BIAN then
        switch(tostring(type2),
        {
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.CHANGBIAN)] = function() name = "长鞭" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.RUANBIAN)] = function() name = "软鞭" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.JIUJIEBIAN)] = function() name = "九节鞭" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.GANZIBIAN)] = function() name = "杆子鞭" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.LIANJIA)] = function() name = "链枷" end,
        })
    elseif type == Item.ITEM_TYPE.WEAPON_TYPE.SHUANGCHI then
        switch(tostring(type2),
        {
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.SHUANGHUAN)] = function() name = "双环" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.DUIJIAN)] = function() name = "对剑" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.SHUANGGOU)] = function() name = "双钩" end,
        })
	elseif type == Item.ITEM_TYPE.WEAPON_TYPE.ANQI then
        switch(tostring(type2),
        {
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.ZUIXINGANQI)] = function() name = "锥形暗器" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.YUANXINGANQI)] = function() name = "圆形暗器" end,
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.ZHENXINGANQI)] = function() name = "针形暗器" end,
		})
	elseif type == Item.ITEM_TYPE.WEAPON_TYPE.QIN then
        switch(tostring(type2),
        {
            [tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.GUQIN)] = function() name = "古琴" end,
			[tostring(Item.ITEM_TYPE.WEAPON_SUBTYPE.DIZI)] = function() name = "笛子" end,
        })
	elseif type == "家具" then
		name = self.showType or type
	else
		name = type
    end
    return name
end

--设置每日道具的结束剩余时间
function BaseItem:setDayItemTimeend()
	local id = self.id
	if id ~="tlyaos" then
		return 
	end

	local currTime = GetTime()

	local Hour = Helper:date("%H",currTime)
	local Minute = Helper:date("%M",currTime)
	local Second = Helper:date("%S",currTime)

	local startTime =  Hour*3600 + Minute*60 + Second

	self.timeend = 86400 - startTime
end

-- 加密标记
BaseItem.isEncrypted = true
return BaseItem
00000000000
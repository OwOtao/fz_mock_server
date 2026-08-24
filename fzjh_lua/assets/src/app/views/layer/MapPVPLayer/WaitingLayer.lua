local WaitingLayer = class("WaitingLayer", require("app.views.base.BaseLayer"))

-- add by XiaoZhiWei 2017/07/19 09:59:29 加载项
-- local Map = require("app.models.map.Map")

local WAITING_TIME = 10 -- add by XiaoZhiWei 2017/06/15 15:05:17 等待时间10秒
local handle, actionTag -- add by XiaoZhiWei 2017/06/20 17:49:09 用来记录调度器以及动作

function WaitingLayer:createInRunningScene()
	local layer = WaitingLayer:getInstance()
	return layer
end

function WaitingLayer:create()
	local p = WaitingLayer:new()
	p:init()
	return p
end

function WaitingLayer:init()
	self.UI = require("Layer/MapPVPUI/YingZhanUI.lua").create()['root']
	self.UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点

	self:replaceToRichText(self.Panel_wait, "Text_desc_role")
	self:replaceToRichText(self.Panel_wait, "Text_desc_target")
	self:replaceToRichText(self.Panel_choose, "Text_desc_role")
	self:replaceToRichText(self.Panel_choose, "Text_desc_target")
	self:replaceToRichText(self.Panel_choose, "Text_desc_qiecuo")

	self:hide()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/20 17:51:12
-- @desc 共同接口,以供一些统一处理
function WaitingLayer:beforeShow()
	if actionTag ~= nil then
		self:stopActionByTag(actionTag)
	end
		
	if handle ~= nil then
		self:unschedule(handle)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 15:43:47
-- @desc 设置人物头像
function WaitingLayer:setRoleHead(panelName, role)
	if MapIsEmpty(role) == true or self[panelName] == nil or self[panelName].Node_HeadViewPos == nil then
		return
	end

	local headUI = require("app.views.ui.HeadView.HeadView"):create()
	headUI:setPosition(cc.p(self[panelName].Node_HeadViewPos:getPosition()))
	local headUISize = headUI:getContentSize()
	local scaleX = 280 * 0.8 / headUISize.width
	local scaleY = 280 * 0.8 / headUISize.height
	headUI:setScaleX(scaleX)
	headUI:setScaleY(scaleY)

	self[panelName]:addChild(headUI)

	role = Helper:tableCover(Role:create(), role)

	--@RefType [src.app.presenters.HeadView.HeadViewPresenter#HeadViewPresenter]
	self.__headpresenter = require("app.presenters.HeadView.HeadViewPresenter"):create(role,headUI)
	self.__headpresenter:setClickEnable(false)
end


local textColor = cc.c3b(255,255,255)
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 10:18:36
-- @desc 战斗确认界面
-- function WaitingLayer:showYingZhan(role, acceptFunc, rejectFunc)
function WaitingLayer:showYingZhan(userid, actionCode, time, key, onlyId)
	-- if MapIsEmpty(role) == true then
	-- 	self:hide()
	-- else
	self:beforeShow()
	if userid == nil or actionCode == nil or time == nil or key == nil or onlyId == nil then
		PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
			self:hide()
		end)
	else

		local map = User:getRole():getCurrMap()
		if MapIsEmpty(map) == true then
			PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
				self:hide()
			end)
			return
		end

		local role = map:getRole(userid)

		if MapIsEmpty(role) == true then
			PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
				self:hide()
			end)
			return
		end

		-- local function getRoleDesc()
		-- 	local str = ""
		-- 	str = role:getTouXian().."\n".."所学武学：\n"
		-- 	local skills = Helper:getDef(role:getSkills(), {}) 
		-- 	local index = 0
		-- 	for skillId,roleSkill in pairs(skills) do

		-- 		local skill = Skill:getSkill(skillId)
		-- 		str = str .. "	□" .. tostring(skill.name) .. "\n"

		-- 		index = index + 1
		-- 		-- add by XiaoZhiWei 2017/06/13 17:58:07 暂时只显示3个技能
		-- 		if index >= 3 then
		-- 			break
		-- 		end
		-- 	end
		-- 	return str
		-- end
		local cl = "WHT"
		local sex = "他"
		if role.sex == "女" then
			sex = "她"
		-- elseif role.sex == "野兽" then
		-- 	return (role.dsc == nil and "" or tostring(role.dsc))
		end
		if role:checkRoleIsPolymorph() then  --易容改貌
			if role.polymorph.sex == "女" then
				sex = "她"
			else
				sex = "他"
			end
		end
		local function getTargetDesc()
			local str = ""
			local title = role.title or "WHT【普通百姓】"
			str = str .. cl .. sex .."是"..role:getTouXian().."\n江湖人称" .. title .. cl .. "。\n"
			return str
		end

		local function getRoleDesc()
			local str = ""
			local jiaLiDsc = role.jiaLiDsc or "HIG很微妙"
			str = str .. str..cl..sex.."的武功看来"..role:getKongfuDesc(role.kongfu)..cl.."，出手似乎"..jiaLiDsc..cl.."。\n"

			--武器
			str = str.."WHT"..sex.."身上装备着：\n"
			local weapoonName = role.weaponName or "拳脚"
			str = str .. cl .. "	□" .. weapoonName .. cl .. "\n"

			local equipsTab =
			{
				[1] = "head",		-- 头帽
				[2] = "cloth",		-- 上装
				[3] = "pants",		-- 下装
				[4] = "belt",		-- 腰带
				[5] = "yaozhui",	-- 腰坠
				[6] = "shoes",		-- 鞋子
				[7] = "necklace",	-- 项链
				[8] = "hand",		-- 手部
				[9] = "ring",		-- 戒指
			}
			local function nameNoHaveColor(name)
				if name == nil then
					return "	           "
				elseif #name < 6 then
					return name .. "	           "
				elseif #name < 9 then
					return name .. "            "
				elseif #name < 12 then
					return name .. "         "
				elseif #name < 15 then
					return name .. "      "
				elseif #name < 18 then
					return name .. "   "
				else
					return name
				end
			end

			local function nameBuQi(name) --要算上名字的颜色字符
				if string.find(name,"NOR") == nil then
					return nameNoHaveColor(name)
				end

				if name == nil then
					return "	              "
				elseif #name < 9 then
					return name .. "	              "
				elseif #name < 12 then
					return name .. "               "
				elseif #name < 15 then
					return name .. "            "
				elseif #name < 18 then
					return name .. "         "
				elseif #name < 21 then
					return name .. "      "
				elseif #name < 24 then
					return name .. "   "
				else
					return name
				end
			end

			local index = 0
			for i,v in ipairs(equipsTab) do
				local equip = role:getEquipByName(v)
				if equip and role:getOneItemByKey(equip.itemId) then
					str = str .. "	□" .. nameBuQi(role:getOneItemByKey(equip.itemId).name) .. cl.."	"
					index = index + 1
				else
				end

				if index % 2 == 0 then
					str = str .. "\n"
				end
			end

			--装备外观
			local appearance = role:getAttr("appearance")
			if appearance and appearance ~= "" and appearance ~= "waiguan0" then
				str = str .. "	□" .. role:getOneItemByKey(appearance).name .. cl .. "\n"
			end

			return str
		end


		self:hideWaiting()
		self:hideHistory()
		self:setPanelBackEnabled()
		self:showButtons("应战", "拒绝", "收起")
		self:setRoleHead("Panel_choose", role)
		self.Text_yingzhan_msg:setVisible(true)

		self.Panel_choose.Text_name:setString(role:getName())
		self.Panel_choose.Text_desc_target:getRichText():removeAllElement()
		self.Panel_choose.Text_desc_role:getRichText():removeAllElement()
		self.Panel_choose.Text_desc_qiecuo:getRichText():removeAllElement()
		self.Panel_choose.Text_desc_target:pushBackText(getTargetDesc(), textColor, 255, Resource:getFontPath("default"), 42)
		self.Panel_choose.Text_desc_role:pushBackText(getRoleDesc(), textColor, 255, Resource:getFontPath("default"), 42)
		self.Panel_choose.Text_desc_qiecuo:pushBackText("在下".. role:getName() .. "，见阁下身手不凡，一时技痒，愿切磋武艺、点到为止，可否？", textColor, 255, Resource:getFontPath("default"), 42)

		self.Panel_choose:setVisible(true)
		self:setButtonsFunc(
			function() 
				if GetTime() - time > WAITING_TIME then
					PopText("已超出响应时间")
				else
					local roleDatas = {
						selfCreatedSkillData = User:getRole():getAttr("selfCreatedSkillData"), --自创武学数据
						roleAttrData = {
							looks = User:getRole():getAttr("looks"),
							jingMax = User:getRole():getJingMax(),
							neiLiLimit = User:getRole():getNeiLiLimit(),
							qiMax = User:getRole():getCurrQiMax(),
							atk = User:getRole():getAtk(),
							dodge = User:getRole():getDodge(),
							def = User:getRole():getDef(),
							damage = User:getRole():getPowerDamage(),
							protect = User:getRole():getFangHu(),
							str = User:getRole():getAttr("str"),
							dex = User:getRole():getAttr("dex"),
							int = User:getRole():getAttr("int"),
							con = User:getRole():getAttr("con"),
							currStr = User:getRole():getEffectStr(),
							currDex = User:getRole():getEffectDex(),
							currInt = User:getRole():getFinalAttr("currInt"),
							currCon = User:getRole():getEffectCon(),
							inheritCount = User:getRole():getNumAttr("inheritCount"),
							age = User:getRole():getAttr("age")
						}
					} 

					if PRINT_MODE == 1 then
						print("人物属性详情")
						Helper:print_lua_table(roleDatas.roleAttrData)
					end

					--@desc 校验接受切磋者数据是否作弊
					HttpManagerEx:pvpRoleDataVerify(roleDatas,function(status, errcode, errmsg, data, isEncrypted)
						if status == 200 then
							if errcode == 0 then
								FubenClient:accept(userid, actionCode, time * 1000, key, onlyId) 
								User:getRole():updateFightStatus("战斗开始") 
								MapPVP:updateFightMsg(key, {status = "接受战斗"})
							elseif errcode == 2 then
								FubenClient:reject(userid, actionCode, time * 1000, key, "战斗异常，请联系客服查询对手是否数据异常", onlyId)
								PopText("请公平公正的参与游戏")

								if PRINT_MODE == 1 then
									print("作弊属性详情")
									Helper:print_lua_table(data)
								end
							else
								PopText(errmsg)
							end
						else
							PopText(errmsg)
						end
					end, IS_SHOW_WAITING)
				end
				PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
					self:hide()
				end)
			end,
			function() 
				if GetTime() - time > WAITING_TIME then
					-- PopText("对方已经飘然远去，难觅其踪")
				else
					FubenClient:reject(userid, actionCode, time * 1000, key, User:getRoleAttr("name").."拒绝了你的切磋请求", onlyId) 
					User:getRole():updateFightStatus("战斗结束")  
					MapPVP:updateFightMsg(key, {reason = "拒绝战斗", result = 62})
				end
				PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
					self:hide()
				end)
			end,
			function() 
				-- add by XiaoZhiWei 2017/06/14 10:52:40 收起的时候需要存储一下,以供下次展开时使用
				PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
					self:hide()
				end)
			end
		)

		-- add by XiaoZhiWei 2017/06/19 17:28:57 倒计时10秒处理,没用schedule 用的delay
		local num = math.min(math.ceil(WAITING_TIME - GetTime() + time), WAITING_TIME) -- add by XiaoZhiWei 2017/06/19 17:26:51 剩余的秒数
		if num <= 0 then
			-- PopText("对方已经飘然远去，难觅其踪")
			PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
				self:hide()
			end)
		else
			self.Text_yingzhan_msg:setString(num.."秒钟后自动拒绝") 
			handle = self:schedule(function(ft)
				num = num - 1
				self.Text_yingzhan_msg:setString(num.."秒钟后自动拒绝")
				if num <= 0 then
					FubenClient:reject(userid, actionCode, time * 1000, key, User:getRoleAttr("name").."拒绝了你的切磋请求", onlyId) 
					User:getRole():updateFightStatus("战斗结束")  
					MapPVP:updateFightMsg(key, {reason = "拒绝战斗", result = 62})
					PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
						self:hide()
					end)
				end
			end, 1)
			-- actionTag = self:delayFunc(num, function()
			-- 	self:unschedule(handle)
			-- end)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 10:22:39
-- @desc 战斗确认界面隐藏
function WaitingLayer:hideYingZhan()
	self.Panel_choose:setVisible(false)
	self.Text_yingzhan_msg:setVisible(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 10:24:40
-- @desc 确认等待界面
function WaitingLayer:showWaiting(role, key, fightFunc)
	self:beforeShow()
	if MapIsEmpty(role) == true or key == nil then
		PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
			self:hide()
		end)
	else
		-- role = Helper:tableCover(Role:create(), role)
		self:hideYingZhan()
		self:hideHistory()
		self:showButtons()
		self:setPanelBackEnabled()

		-- add by XiaoZhiWei 2017/07/03 16:11:53 更新阅读状态
		MapPVP:updateDataReadStatus({key})

		self:setRoleHead("Panel_wait", role)

		local function getFightDesc()
			return "江湖同道，以武会友，请赐教！"
		end

		local msgInfo = MapPVP:getOneDataWithKey(key)
		local str = ""
		if msgInfo.startRole == "ME" then
			str = role:getName() .. "WHT同意了的切磋请求。出手吧！"
		else
			str = "WHT你同意了"..role:getName() .. "的切磋请求。出手吧！"
		end

		self.Panel_wait.Text_name:setString(role:getName() .. "：")
		self.Panel_wait.Text_desc_target:getRichText():removeAllElement()
		self.Panel_wait.Text_desc_role:getRichText():removeAllElement()
		self.Panel_wait.Text_desc_target:pushBackText(getFightDesc(), textColor, 255, Resource:getFontPath("default"), 42)
		self.Panel_wait.Text_desc_role:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
		local CNNum = {"叁", "贰", "壹"}
		local index = 1
		self.Panel_wait.Text_time:setString(CNNum[index])
		handle = self:schedule(function(ft)
			index = index + 1
			self.Panel_wait.Text_time:setString(CNNum[index])
			if index > 3 then
				Helper:getDef(fightFunc, EMPTY_FUNC)()
			end
		end, 1)

		-- actionCode = self:delayFunc(4, function()
		-- 	self:unschedule(handle)
		-- end)

		self.Panel_wait:setVisible(true)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 10:25:21
-- @desc 等待界面隐藏
function WaitingLayer:hideWaiting()
	self.Panel_wait:setVisible(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 10:30:18
-- @desc 战斗历史界面
function WaitingLayer:showHistory(msgList)
	self:beforeShow()
	self:hideYingZhan()
	self:hideWaiting()
	self:showButtons()
	self:setPanelBack()

	-- add by XiaoZhiWei 2017/07/03 16:07:47 更新所有记录的阅读状态为已读
	MapPVP:updateAllReadStatus()

	-- add by XiaoZhiWei 2017/06/14 18:58:39 获取时间描述
	local function getTimsDesc(time)
		if time == nil then
			return
		end
		local sec = Helper:diffWithSecond(GetTime(), time)
		local year, month, day, hour, minute, second = Helper:getExpiredTime(GetTime(), time)
		print(time, sec, year, month, day, hour, minute, second)
		if sec > 24 * 3600 then
			return "一天之前："
		elseif hour > 0 then
			return hour.."小时之前："
		elseif minute > 30 then
			return "半小时之前："
		elseif minute > 0 then
			return minute.."分钟之前："
		else
			return "刚刚："
		end
	end

	self.Text_history_msg:setVisible(true)

	-- add by XiaoZhiWei 2017/06/17 09:32:34 暂定只显示10条
	local length = math.min(math.max(#msgList, #self.Panel_history.ListView_list:getItems()), 10)
	for i=1,length do
		if i > #msgList then
			self.Panel_history.ListView_list:removeLastItem()
		else
			local msgInfo = msgList[i]
			local panel = self.Panel_history.ListView_list:getItem(i - 1)
			if panel == nil then
				panel = self:createHistoryPanelItem()
				self.Panel_history.ListView_list:pushBackCustomItem(panel)
			end
			panel.Text_time_desc:setString(getTimsDesc(msgInfo.time))

			local str = ""
			panel.Button_fight:setVisible(false)
			if msgInfo.result == 0 then
				-- add by XiaoZhiWei 2017/06/14 00:53:50 情况 还未战斗
				str = tostring(msgInfo.targetName).."WHT向你发起切磋请求。"
				panel.Button_fight:setVisible(true)
				-- add by XiaoZhiWei 2017/06/17 10:28:26  超过10秒 变为发起请求
				if GetTime() - msgInfo.time > WAITING_TIME then
					panel.Button_fight.Text_fight:setString("发起"..tostring(msgInfo.fightType))
					panel.Button_fight:releaseFunc(function()
						local currMap = User:getRole():getCurrMap()
						if Map:checkRoomCanQieCuo(currMap:getCurrRoomId()) == true then
							-- PopText("这里需要发起切磋")
							if msgInfo.fightType == "切磋" then
								FubenClient:qieCuo(msgInfo.userid)
							else
								FubenClient:jueDou(msgInfo.userid)
							end
						else
                        	PopText("此乃文教之地，不可动武！")
						end
					end)
				else
					panel.Button_fight.Text_fight:setString("应战")
					panel.Button_fight:releaseFunc(function()
						local currMap = User:getRole():getCurrMap()
						if Map:checkRoomCanQieCuo(currMap:getCurrRoomId()) == true then
							-- PopText("这里需要去应战")
							if GetTime() - msgInfo.time > WAITING_TIME then
								FubenClient:qieCuo(msgInfo.userid)
							else
								self:showYingZhan(msgInfo.userid, msgInfo.actionCode, msgInfo.time, msgInfo.key, msgInfo.id)
							end
						else
                        	PopText("此乃文教之地，不可动武！")
						end
					end)
				end
			elseif msgInfo.result == 1 or msgInfo.result == 4 then
				-- add by XiaoZhiWei 2017/06/14 00:54:04 情况 战斗结束,已有战斗结果
				if msgInfo.startRole == "ME" then
					str = "WHT你向NOR"..tostring(msgInfo.targetName).."WHT发起切磋并取得了胜利。"
				else
					str = tostring(msgInfo.targetName).."WHT向你发起切磋请求。\n你应战了，并取得了胜利。"
				end
			elseif msgInfo.result == 2 or msgInfo.result == 5  then
				-- add by XiaoZhiWei 2017/06/14 00:54:04 情况 战斗结束,已有战斗结果
				if msgInfo.startRole == "ME" then
					str = "WHT你向NOR"..tostring(msgInfo.targetName).."WHT发起切磋，可惜技不如人。"
				else
					str = tostring(msgInfo.targetName).."WHT向你发起切磋请求。\n你应战了，可惜技不如人。"
				end
				panel.Button_fight:setVisible(true)
				panel.Button_fight.Text_fight:setString("发起"..tostring(msgInfo.fightType))
				panel.Button_fight:releaseFunc(function()
					local currMap = User:getRole():getCurrMap()
					if Map:checkRoomCanQieCuo(currMap:getCurrRoomId()) == true then
						-- PopText("这里需要发起切磋")
						if msgInfo.fightType == "切磋" then
							FubenClient:qieCuo(msgInfo.userid)
						else
							FubenClient:jueDou(msgInfo.userid)
						end
					else
                    	PopText("此乃文教之地，不可动武！")
					end
				end)
			elseif msgInfo.result == 3 then
				-- add by XiaoZhiWei 2017/06/14 00:54:04 情况 战斗结束,已有战斗结果
				if msgInfo.startRole == "ME" then
					str = "WHT你向NOR"..tostring(msgInfo.targetName).."WHT发起切磋，可惜技不如人。"
				else
					str = tostring(msgInfo.targetName).."WHT向你发起切磋请求。\n你应战了，可惜技不如人。"
				end
				panel.Button_fight:setVisible(true)
				panel.Button_fight.Text_fight:setString("发起"..tostring(msgInfo.fightType))
				panel.Button_fight:releaseFunc(function()
					local currMap = User:getRole():getCurrMap()
					if Map:checkRoomCanQieCuo(currMap:getCurrRoomId()) == true then
						-- PopText("这里需要发起切磋")
						if msgInfo.fightType == "切磋" then
							FubenClient:qieCuo(msgInfo.userid)
						else
							FubenClient:jueDou(msgInfo.userid)
						end
					else
                    	PopText("此乃文教之地，不可动武！")
					end
				end)
			elseif msgInfo.result == nil then
				-- add by XiaoZhiWei 2017/06/14 00:54:04 情况 战斗结束,已有战斗结果
				if msgInfo.startRole == "ME" then
					if msgInfo.sex == "男" then
						str = "WHT你向NOR"..tostring(msgInfo.targetName).."WHT发起切磋，可惜他拒绝了你。"
					else
						str = "WHT你向NOR"..tostring(msgInfo.targetName).."WHT发起切磋，可惜她拒绝了你。"
					end
					
				else
					str = tostring(msgInfo.targetName).."WHT向你发起切磋请求。\n你没有应战。"
				end
				panel.Button_fight:setVisible(true)
				panel.Button_fight.Text_fight:setString("发起"..tostring(msgInfo.fightType))
				panel.Button_fight:releaseFunc(function()
					local currMap = User:getRole():getCurrMap()
					if Map:checkRoomCanQieCuo(currMap:getCurrRoomId()) == true then
						-- PopText("这里需要发起切磋")
						if msgInfo.fightType == "切磋" then
							FubenClient:qieCuo(msgInfo.userid)
						else
							FubenClient:jueDou(msgInfo.userid)
						end
					else
                    	PopText("此乃文教之地，不可动武！")
					end
				end)
			else
				-- add by XiaoZhiWei 2017/06/14 00:54:04 情况 战斗结束,已有战斗结果
				str = tostring(msgInfo.targetName).."WHT向你发起切磋请求。"
				panel.Button_fight:setVisible(true)
				panel.Button_fight.Text_fight:setString("发起"..tostring(msgInfo.fightType))
				panel.Button_fight:releaseFunc(function()
					local currMap = User:getRole():getCurrMap()
					if Map:checkRoomCanQieCuo(currMap:getCurrRoomId()) == true then
						-- PopText("这里需要发起切磋")
						if msgInfo.fightType == "切磋" then
							FubenClient:qieCuo(msgInfo.userid)
						else
							FubenClient:jueDou(msgInfo.userid)
						end
					else
                    	PopText("此乃文教之地，不可动武！")
					end
				end)
			end

			panel.Text_msg:setString(str)
		end
	end

	self.Panel_history:setVisible(true)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 10:31:00
-- @desc 战斗历史界面隐藏
function WaitingLayer:hideHistory()
	self.Panel_history:setVisible(false)
	self.Text_history_msg:setVisible(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 00:29:45
-- @desc 创建历史战斗栏目
function WaitingLayer:createHistoryPanelItem()
	local panel = self.Panel_item:clone()
	Helper:convertUIByParent(panel)
	return panel
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 10:34:03
-- @desc 设置按钮名称
function WaitingLayer:setButtonName(buttonName, textName)
	if buttonName == nil or self[buttonName] == nil then
		return
	end
	if textName == nil then
		self[buttonName]:setVisible(false)
		self[buttonName]:setTouchEnabled(false)
	else
		self[buttonName]:setVisible(true)
		self[buttonName]:setTouchEnabled(true)
	end
	self[buttonName].Text_buttonName:setString(textName)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 10:33:20
-- @desc 按钮控制,当按钮名称为空的时候,按钮将隐藏
function WaitingLayer:showButtons(name1, name2, name3)
	self:setButtonName("Button_start", name1)
	self:setButtonName("Button_GO", name2)
	self:setButtonName("Button_cancel", name3)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 11:02:49
-- @desc 设置按钮点击事件
function WaitingLayer:setButtonFunc(buttonName, buttonFunc)
	if buttonName == nil or self[buttonName] == nil then
		return
	end
	buttonFunc = Helper:getDef(buttonFunc, EMPTY_FUNC)
	self[buttonName]:releaseFunc(function()
		buttonFunc()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 11:04:18
-- @desc 按钮事件控制
function WaitingLayer:setButtonsFunc(func1, func2, func3)
	self:setButtonFunc("Button_start", func1)
	self:setButtonFunc("Button_GO", func2)
	self:setButtonFunc("Button_cancel", func3)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 22:36:38
-- @desc 设置抬头标题
function WaitingLayer:setTitleText(text)
	text = Helper:getDef(text, "江湖切磋")
	self.Panel_title.Text_title:setString(text)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 10:53:10
-- @desc 设置背景点击无效
function WaitingLayer:setPanelBackEnabled()
	self.Panel_back:releaseFunc(function()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/07 12:06:01
-- @desc 设置背景点击
function WaitingLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
			self:hide()
		end)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/13 16:03:31
-- @desc 将文本区域替换为richtext
function WaitingLayer:replaceToRichText(parentUi, uiName)
	-- add by XiaoZhiWei 2017/06/13 17:30:41 isCreateRichText 用来标记richText是否已经创建,创建了则无需再次创建
	if parentUi == nil or uiName == nil or parentUi[uiName] == nil or parentUi[uiName].isCreateRichText == true then
		return
	end
	local richTextScroll = ExtRichTextScroll:create()
   	parentUi:addChild(richTextScroll)

	richTextScroll:setAnchorPoint( parentUi[uiName]:getAnchorPoint() )
   	richTextScroll:move(parentUi[uiName]:getPosition())
   	richTextScroll:setSize(parentUi[uiName]:getContentSize())
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	parentUi[uiName]:setVisible(false)

   	parentUi[uiName] = richTextScroll
   	parentUi[uiName]:setBounceEnabled(false)
   	parentUi[uiName].isCreateRichText = true
end

Helper:classDefNodeGetInstance(WaitingLayer)
return WaitingLayer
00000000
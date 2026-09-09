local MainLayer = class("MainLayer", cc.Layer)
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local CoroutinePool = require("third.coroutine.CoroutinePool")
local AsyncFunction = require("third.async.AsyncFunction")

-- add by XiaoZhiWei 2017/11/29 16:20:04 拜访任务相关时间控制
local FirstVisitTaskTime = 1800			-- 第一次在线拜访任务时间 1800
local VisitTaskLimit = 6				-- 拜访任务每日限制次数 6
local VisitTaskMapLimit = 3  			-- 副本开启拜访任务每次限制次数 3
local VisitTaskInterval = 900 			-- 拜访任务最低间隔时间 600

function MainLayer:create()
	local p = MainLayer:new()
	p:init()
	return p
end

function MainLayer:init()
	if Game:isTesting() then
		-- 注册调试按键
		self:setFightEventListener()
	end

    local data = {
        isClick = "Y",--是否有新活动
        isSign = "Y",--是否签到
    }
    
    local MainUI = require("app.views.ui.MainUI"):create()
    MainUI:addTo(self)
    self._UI = MainUI

    self.__role = User:getRole()
    local headUI = require("app.views.ui.HeadView.HeadView"):create()
    headUI:setPosition(cc.p(self._UI.Node_HeadViewPos:getPosition()))
    self._UI:addChild(headUI)
    --@RefType [src.app.presenters.HeadView.HeadViewPresenter#HeadViewPresenter]
    self.__headpresenter = require("app.presenters.HeadView.HeadViewPresenter"):create(self.__role,headUI)
    self.__headpresenter:setClickEnable(false)

    self._tag = nil
    self:initMonitorPool()
    -- 检测是否有官职 只会检测一次
    self.isCanCheckOfficial = true
    --检测是否师门声望第一 只会检测一次 
    self.CheckPrestigeRankingTop=true 
    -- 公告是否已显示
    self._gongGaoIsShow = false

    self.isFirstOpen = true
    
    self:initButtons() -- add by XiaoZhiWei 2017/11/29 16:05:50 初始化所有按钮

	self.__uiInitState = 1  --1 创建时初始化 2第一次onEnable 3其他onEnable

	self:initButtonWithResume()

	self:isShow()

	self:delayFunc(1, function()

		Game:addBlockAsyncFunc(
			"ddd",
			function()
				local OfflineProfit = require("app.models.OfflineProfit.OfflineProfit")

				--神兵锻造知识初始化 ，根据玩家存档数据来生成
				ForgeSkill:init()
				-----------------------------------------------------------------------------------------------------------
				-- @author GaoHanZheng
				-- @time 2018/01/21 10:50:22
				-- @desc 神兵转换
				local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
				ShenBingDuanZao:transOldShenBingToNewShenBing()

				require("app.models.ShenBing.ShenBingRepair"):create(User:getRole()):repair()
				require("app.models.shenshu.ShenShuRepair"):create(User:getRole()):repair()
				require("app.models.skill.SkillRepair"):create(User:getRole()):repair()
				require("app.models.ShenBing.WuZangScoreRepair"):create(User:getRole()):repair()

				-- 刷新角色buff
				User:getRole():updateRoleBuff()

				--@desc 确保离线收益显示前offline 模块已收集到离线数据
				local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
				RoleTaskControllor:update()

				OfflineProfit:show(self)
				self:showGongGao()

				PoisonFormula:init()

				-- User:setRoleAttr("openVisitTaskTime",GetTime() - 1790)

				self.initFinish = true

				self:checkCanOpenVisitTask()
				--御汇令上限处理
				local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")
				ActivityCalendarUtils:setYuHuiLingLimit()

				--手艺人剧情开始标记
				if User:getRole():getInheritFlag("shouyiren_start") == 0 then
					User:getRole():setInheritFlag("shouyiren_start", User:getRole():getAttr("inheritCount"))
				end

				require("app.models.user.UserCheatDetection"):checkSaveData()
			end,
			nil
		)

	end)
end

function MainLayer:updateLayerSkinUI(skin_config)
	self._UI:updateSkinUI(skin_config)
end

function MainLayer:onAwake()
    self:delayFunc(1 / 60, function()
        -- 清除开始游戏页面图片缓存
        if YXSkeletonAnimationCache and YXSkeletonAnimationCache.getInstance ~= nil and YXSkeletonAnimationCache.removeAllAnimCache ~= nil then
            YXSkeletonAnimationCache:getInstance():removeAnimCache("Anim/ep2/skeleton.json", "Anim/ep2/skeleton.atlas")
        end

        self:initCheck() -- add by XiaoZhiWei 2017/11/29 16:09:46 初始化检查

        self.isShowDengLu = true -- 控制新春登陆送元宝只显示一次

        --创建协程来刷新UI
        self.coroutinePool = CoroutinePool:create()
        self.coroutinePool:add("MainLayer", function()
            while true do
                self:__createAsyncRefreshUI():await()
            end
        end)

        self:__createAsyncRefreshUI():call()

        self:schedule(
        function(ft)
            self.coroutinePool:update(ft)
			self._UI:updataSkinAnim(ft)
        end, 0)

        -- 如果没有取名，在排名处显示红点 
        local name = User:getRole():getAttr("name")
        if name == "无名小辈" or name == "无名少女" then
            self._UI.Image_hongdian_paihang:setVisible(true)
        else
            self._UI.Image_hongdian_paihang:setVisible(false)
        end 

    end)
end

-- 公告界面弹出
function MainLayer:showGongGao()
	-- 公告页面的弹出
	if User:getRole():isMapCompleted("fb01") == true and User:getRoleAttr("notice_url") ~= nil and string.len(tostring(User:getRoleAttr("notice_url"))) > 0 then
		local layer = require("app.views.layer.CommunityLayer.CommunityLayer"):getInstance()
		layer:setUrl(User:getRoleAttr("notice_url"))
		layer:setOnPauseCallback(function()
			User:setRoleAttr("notice_url", nil)
			self._gongGaoIsShow = false
		end)
		layer:setTitle("最新公告")
		layer:show()
		self._gongGaoIsShow = true
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/29 15:58:31
-- @desc  红点
function MainLayer:setStroeTexture()
	local role = User:getRole()
	--商城红点（江湖名士、观影堂）
	local yueKaHongDian = false
	local guanYingTangHongDian = role:isShowViewingHallHongDian()
	local yaShiBenefitHongDian = false

	if role:yueKaIsValid() == true and role:getDayFlag("yueKa_reward") == 0 then 
		yueKaHongDian = true
	else
		yueKaHongDian = false
	end

	local YaShiBenefit = require("app.models.YaShiBenefit.YaShiBenefit")
	yaShiBenefitHongDian = YaShiBenefit:getCanExchange()

	if yueKaHongDian or guanYingTangHongDian or yaShiBenefitHongDian then
		self._UI.Image_hongdian_shangcheng:setVisible(true)
	else
		self._UI.Image_hongdian_shangcheng:setVisible(false)
	end

	local hongDianType = 1

	if self.isFirstOpen == false then
		hongDianType = 2
	end

	HttpManagerEx:getEventList(hongDianType, role:getCurrencyVersion(), function(status, errcode, errmsg, data)
		if status ==200 and errcode == 0 then
			if data.isSign == "N" or data.isClick == "Y" then
				self._tag = true
			else
				self._tag = false
			end
			local titleLayer =MainControllLayer:getLayer("TitleLayer")
			titleLayer:setMainLayerActivityInfo(self._tag)
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/29 16:06:35
-- @desc 初始化检查操作
function MainLayer:initCheck()
	-- 红点
	self:setStroeTexture()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/29 15:58:39
-- @desc 按钮初始化
function MainLayer:initButtons()

	-- 任务系统
	do
		self._UI.Button_task:releaseFunc(
		function()
			Audio:playEffect("daAnNiu")
			MainControllLayer:pushLayer("MainTaskPresenter")
		end)

		local Text_task = Resource:getTextByStyleName("taskButton")
		self._UI.Button_task:addChild(Text_task)
		Text_task:move(cc.p(786, self._UI.Button_task:getContentSize().height / 2))
		self._UI.Text_task = Text_task
	end

	-- 头像系统
	do
		self._UI.Button_head:releaseFunc(
		function()
			Audio:playEffect("daAnNiu")
			MainControllLayer:pushLayer("AttrLayer")
		end)
	end

	-- 江湖系统
	do
		self._UI.Button_jianghu:releaseFunc(
		function()
			Audio:playEffect("daAnNiu")
			local role = User:getRole()
			local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
			if RoleTaskControllor:clickMapLayer(role, EMPTY_FUNC) == false then
				return
			end
			MainControllLayer:pushLayer("SelectMapMenuPresenter")
		end)
	end

	-- 师门系统
	do
		self._UI.Button_shimen:releaseFunc(function()
			Audio:playEffect("daAnNiu")
			if User:getRole():hasFamily() then
				local layer = MainControllLayer:getLayer("TeacherLayer")
				layer:hide()
				layer:refreshGongXian(function()
					layer:show()
					MainControllLayer:pushLayer("TeacherLayer")
				end)
			else
				
				-- 新手引导
				RichPrint("main", "YEL你仔细想了想，或许也可以先返回酒馆继续打杂一段时间，等HIR积攒了一些经验NORYEL以后再去闯荡江湖，那时说不定还能了解到HIR更多的门派NORYEL。")
				local Teacher = require("app.models.teacher.Teacher")
				MainControllLayer:pushLayer("SelectTeacherLayer_type")
				MainControllLayer:getLayer("SelectTeacherLayer_type"):initWithFamilyList(Teacher:getSelectTeachers())
			end
		end)
	end

	-- 神兵系统
	do
		self._UI.Button_shenbing:releaseFunc(function()
			Audio:playEffect("daAnNiu")
			--转到神兵系统
			if SHENBINGSYS == true then
				MainControllLayer:pushLayer("ShenBingLayer")
				local ShenBingLayer = MainControllLayer:getLayer("ShenBingLayer")
				ShenBingLayer:show()
				ShenBingLayer:playEffectEnter()
			else
				PopText("神兵功能暂未开放")
			end
		end)
	end

	-- 经脉系统
	do
		self._UI.Button_meridian:releaseFunc(function()
			Audio:playEffect("daAnNiu")
			local QuietRoomLayer = MainControllLayer:getLayer("QuietRoomLayer")
	
			local Meridian = require("app.models.Meridian.Meridian")
			Meridian:initMerdian()

			MainControllLayer:pushLayer("QuietRoomLayer")
		end)
	end

	-- 排行榜按钮
	do
		self._UI.Button_paihang:releaseFunc(function()
			local function limitedTimeExperienceFunc()
				local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")

				if LimitedTimeExperience:checkTaskIsOpen("paihangbang") then
					LimitedTimeExperience:setRole(User:getRole())
					LimitedTimeExperience:finishTaskByTaskType("paihangbang")
				end
			end

			Audio:playEffect("daAnNiu")
			if Game:isCheckNewPackage() == NEED_CHECK_AND_IS_OPEN then
				local rankingLayer = MainControllLayer:getLayer("RankingLayer")
				rankingLayer:initData(function ()
					MainControllLayer:pushLayer("RankingLayer")
					rankingLayer:show()
					limitedTimeExperienceFunc()
				end)
			else
				Account:getEmail(
				function(eventName, errmsg, email, isBind, isLogout)
					if eventName == "有邮箱" then
						-- isBind 为true的时候 才是已绑定邮箱
						if isBind == true or DEBUG_MODE == 1 then
							if self._IsUpload ~= nil and GetTime() - self._IsUpload <= 600 then
								local rankingLayer = MainControllLayer:getLayer("RankingLayer")
								rankingLayer:initData(function ()
									MainControllLayer:pushLayer("RankingLayer")
									rankingLayer:show()
									limitedTimeExperienceFunc()
								end)
								if PRINT_MODE == 1 then
									print("请不要重复上传存档")
								end
							else
								local rankingLayer = MainControllLayer:getLayer("RankingLayer")
								rankingLayer:initData(function ()
									MainControllLayer:pushLayer("RankingLayer")
									rankingLayer:show()
									limitedTimeExperienceFunc()
								end)
								self._IsUpload = GetTime()
							end
							self._UI.Image_hongdian_paihang:setVisible(false)
							return
						else
						end
					elseif eventName == "找不到帐号" then
					elseif eventName == "无邮箱" then
					else
					end
					PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
				end)
			end
		end)
	end

	-- 商城
	do
		self._UI.Button_shangcheng:setTouchEnabled(true)
		self._UI.Button_shangcheng:releaseFunc(function()
			Audio:playEffect("daSuanPan")
			if cc.UserDefault:getInstance():getStringForKey("personalInfo") == "Y" or Game:isCheckNewPackage() == NEED_CHECK_AND_IS_OPEN or DEBUG_MODE == 1 then
				local storeLayer = MainControllLayer:getLayer("StoreLayer")
				--storeLayer:show()
				storeLayer:showWithShowAction(self._tag,function()
					self:setStroeTexture()
				end)
			else
				cc.UserDefault:getInstance():setStringForKey("personalInfo", "Y")
				Account:getBindInfo(
				function(eventName, errmsg, email, phone, isBind, isLogout)
					-- if Game:isOpenShiMing() ~= true then
						local storeLayer = MainControllLayer:getLayer("StoreLayer")
						--storeLayer:show()
						storeLayer:showWithShowAction(self._tag,function()
							self:setStroeTexture()
						end)
					-- else
					-- 	if (tonumber(phone) == 0 or tonumber(phone) ==nil) and Game:isOpenPhoneBind() == true then
					-- 		PopupLayerController:showLayer("BindingShiMingLayer", function(layer)
					-- 			layer:show()
					-- 			layer:addCallback(
					-- 			function(eventName)
					-- 				if eventName == "绑定成功" then
					-- 					if self.__isShow == false then
					-- 						self.__isShow = true
					-- 						PopText("请前往商城领取实名认证奖励礼包")
					-- 					end
					-- 					return true
					-- 				end
					-- 			end)
					-- 		end)
					-- 	else	
					-- 		local storeLayer = MainControllLayer:getLayer("StoreLayer")
					-- 		--storeLayer:show()
					-- 		storeLayer:showWithShowAction(self._tag,function()
					-- 			self:setStroeTexture()
					-- 		end)
					-- 	end
					-- end
				end)
			end
		end)
	end

	-- 梦境
	do
		self._UI.Button_dream:setTouchEnabled(true)
		self._UI.Button_dream:releaseFunc(function()
			Audio:playEffect("daAnNiu")
			local DreamWorldPreConditionUtils = require("app.models.DreamWorldModel.DreamWorldPreConditionUtils")
			if DreamWorldPreConditionUtils:checkCanOpenPreTask() then 
				local state = DreamWorldPreConditionUtils:checkCanToHome()
				if state == 2 then 
					DreamWorldPreConditionUtils:goHome()
				elseif state == 0 then
					DreamWorldPreConditionUtils:startPreTask()
				elseif state == 1 then
					PopText("少侠尚且未有家园，听闻华山村北石室的石床亦可入梦。")
				end
			end
		end)
	end

	-- 神功(自创武学)
	do
		self._UI.Button_selfCreatedSkill:setTouchEnabled(true)
		self._UI.Button_selfCreatedSkill:releaseFunc(function()
			Audio:playEffect("daAnNiu")
			local selfCreatedSkillSystem = User:getRole():getSelfCreatedSkillSystem()
			selfCreatedSkillSystem:downloadData(function()
				AchievementSystem:updateRecord(function()
					AchievementSystem:updateTujianTypeRecord()
					MainControllLayer:pushLayer("SelfCreatedSkillMenuUI")
					local layer = MainControllLayer:getLayer("SelfCreatedSkillMenuUI")
					layer:showLayer(selfCreatedSkillSystem)
				end)
			end)
		end)
	end

	--拳脚系统
	do
		self._UI.Button_quanJiao:setTouchEnabled(true)
		self._UI.Button_quanJiao:releaseFunc(function()
			User:getRole():getFistFootSystem():repairFistFootFlag(function(isOk,msg)
				if isOk then
					User:getRole():getFistFootSystem():pullData(function(isOk,msg)
						if isOk then
							Audio:playEffect("daAnNiu")
							MainControllLayer:pushLayer("FistFootMenuPresenter")
							local fistFootMenuPresenter = MainControllLayer:getLayer("FistFootMenuPresenter")
							fistFootMenuPresenter:setRole(User:getRole())
							fistFootMenuPresenter:showLayer()
						else
							PopText(msg)
						end
					end)
				else
					PopText(msg)
				end
			end)
		end)
	end

	-- 测试包测试使用
	do
		self._UI.Button_test:setTouchEnabled(true)
		self._UI.Button_test:releaseFunc(function()
			MainControllLayer:pushLayer("DebugLayer")
		end)
	end
end

-- add by XiaoZhiWei 2017/11/29 16:25:44 刷新方法
function MainLayer:__createAsyncRefreshUI(ft)
	return AsyncFunction:create(function(thread)
		self.monitorPool:update()

		thread:yield()

		self:isShow()

		thread:yield()

		self:checkIsHaveOfficial()

		thread:yield()

		self:checkIsFamilyPrestige()

		thread:yield()

		self:checkCanOpenDengLuJiangLi(EMPTY_FUNC)

		thread:yield()

		self:checkCanOpenVisitTask()

		thread:yield()

		if self._gongGaoIsShow == true then
			require("app.views.layer.CommunityLayer.CommunityLayer"):getInstance():maxZ()
		end

		if self.isFirstOpen then
			self.isFirstOpen = false
		end

		thread:finish()
	end)
	
end

-- add by XiaoZhiWei 2017/11/29 16:26:56 UI界面刷新
function MainLayer:refreshUI(ft)
	local role = User:getRole()
	local jing, jingMax = role:getNumAttr("jing"), math.floor(role:getJingMax())
	local qi, qiMax = role:getNumAttr("qi"), role:getCurrQiMax()
	local neili, neiliMax = role:getNumAttr("neili"), role:getNumAttr("neiliMax")
	local exp = role:getNumAttr("exp")
	local pot = role:getNumAttr("pot")
	local lv = role:getNumAttr("lv")
	local money = role:getNumAttr("money")
	local sex = role:getAttr("sex")
	local looks = role:getFinalAttr("looks")

	local qiPercent = role:getAttr("qiPercent")

	self:__initName()
	self._UI:setTextJing(jing, jingMax)
	self._UI:setTextQi(qi, qiMax, qiPercent)

	if role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
		if role:getNumAttr("jiaLi") ~= nil and role:getNumAttr("jiaLi") > 0 then
			self._UI:setTextNeili("『内力』"..neili.."/"..neiliMax.."("..tostring(role:getNumAttr("jiaLi"))..")打坐中")
		else
			self._UI:setTextNeili("『内力』"..neili.."/"..neiliMax.."打坐中")
		end
	else
		self._UI:setTextNeili("『内力』"..neili.."/"..neiliMax)
	end
	self._UI:setTextExp(exp)
	self._UI:setTextPot(pot)
	self._UI:setTextLv(lv)
	self._UI:setTextMoney(money)
end

-- add by XiaoZhiWei 2017/11/29 16:26:38 按钮是否显示
function MainLayer:isShow()
	local role = User:getRole()
	if role.exp >= 1000 and not self.Curr_Button_State then
		self.Curr_Button_State = true
		self._UI.Button_shimen:setVisible(true)
	end

	if not self.Curr_Button_State2 then
		self.Curr_Button_State2 = true
		if role:getAttr("teacherName") ~= nil then
			self._UI.Image_shimen:loadTexture("Image/UI/MainUI/anniuword04.png",0)
		else
			self._UI.Image_shimen:loadTexture("Image/UI/MainUI/anniuword03.png",0)
		end
	end

	if (role:getAttr("teacherName") ~= nil or role:getExp() >= 5000) and not self.Curr_Button_State3 then
		self.Curr_Button_State3 = true
		self._UI.Button_jianghu:setVisible(true)
	end

	if Map:getMapState("fb01") == MAP_STATE.COMPLETE and not self.Curr_Button_State4 then
		self.Curr_Button_State4 = true
		self._UI.Button_paihang:setVisible(true)
		self._UI.Button_shangcheng:setVisible(true)
	end


	--判断神兵系统是否开启
	if role:getInheritFlag("可进入苏州水底") == 1 and not self.Curr_Button_State5 then
		self.Curr_Button_State5 = true
		role:setFlag("神兵","Y")
		self._UI.Button_shenbing:setVisible(true)
	else
		if (role:getFlag("开启神兵系统") == 1 or role:getExp() > CAN_SHENBING_EXP) and not self.Curr_Button_State5 then
			self.Curr_Button_State5 = true
			role:setFlag("神兵","Y")
			self._UI.Button_shenbing:setVisible(true)
		end
	end

	-- 经脉系统 
	if ( role:getLv() >= 350 or role:getFlag("开启经脉系统") ~= 0 ) and not self.Curr_Button_State6 then
		self.Curr_Button_State6 = true
		self._UI.Button_meridian:setVisible(true)
	end

	-- --判断论剑是否开启
	-- if Map:getMapState("fb01") == MAP_STATE.COMPLETE and not self.Curr_Button_State10 then
	-- 	self._UI.Button_lunjian:setVisible(true)
	-- 	self.Curr_Button_State10 = true
	-- end

	--判断梦境按钮是否开启
	if (role:getLv() > 200 and Map:getMapState("fb10") == MAP_STATE.COMPLETE) and not self.Curr_Button_State8 then
		self.Curr_Button_State8 = true
		self._UI.Button_dream:setVisible(true)
	end

	--判断神功按钮是否开启
	if role:getSelfCreatedSkillSystem():isOpenSystem() then
		self.Curr_Button_State9 = true
		self._UI.Button_selfCreatedSkill:setVisible(true)
	end

	--判断拳脚按钮是否开启
	if role:getFistFootSystem():isOpenSystem() and not self.Curr_Button_State10 then
		self.Curr_Button_State10 = true
		self._UI.Button_quanJiao:setVisible(true)
	end
	
	
	-- 新手引导 提示
	if role.exp <= 100 and not self.Curr_Button_State7 and role:getInheritFlag("新手引导") == 0  then
		self.Curr_Button_State7 = true
		role:setInheritFlag("新手引导",1)
		RichPrint("main", "YEL初来乍到，你决定先HIR打些零工NORYEL维生。")
	end
	if role:getAttr("teacherName") == nil and role:getExp() >= 5000 and role:getInheritFlag("新手引导") == 2 then
		role:setInheritFlag("新手引导",3)
		RichPrint("main", "YEL你认为自己已经累积了足够的经验，可以去HIR江湖NORYEL上走一走了。",30)
	end
	--  新手引导	通关第一章后返回界面提示玩家取名
	if Map:getMapState("fb01") == MAP_STATE.COMPLETE and  role:getInheritFlag("新手引导") == 3 then
		role:setInheritFlag("新手引导",4)
		RichPrint("main", "YEL行走江湖需要个名号，去HIR排名NORYEL处登记一下吧。\n之后的路就由少侠自行探索了。\n少侠日后要是遇到了什么困难，就去右上角新开张的HIR攻略客栈NORYEL看一看吧。")
	end
end

function MainLayer:initMonitorPool()
	local role = User:getRole()
	self.monitorPool = MonitorPool:create("MainLayer")
	self.monitorPool:add(role, "jing", self, self.refreshUI)
	self.monitorPool:add(role.ignoreCloneTb._finalAttr, "jingMax", self, self.refreshUI)
	self.monitorPool:add(role, "qi", self, self.refreshUI)
	self.monitorPool:add(role.ignoreCloneTb._finalAttr, "qiMax", self, self.refreshUI)
	self.monitorPool:add(role, "neili", self, self.refreshUI)
	self.monitorPool:add(role.ignoreCloneTb._finalAttr, "neiliMax", self, self.refreshUI)
	self.monitorPool:add(role, "exp", self, self.refreshUI)
	self.monitorPool:add(role, "pot", self, self.refreshUI)
	self.monitorPool:add(role, "lv", self, self.refreshUI)
	self.monitorPool:add(role, "money", self, self.refreshUI)
	self.monitorPool:add(role, "sex", self, self.refreshUI)
	self.monitorPool:add(role, "looks", self, self.refreshUI)
	self.monitorPool:add(role, "qiPercent", self, self.refreshUI)
end

function MainLayer:refreshButtonTaskText()
	--@RefType[Role_Task]
	local role = User:getRole()

	--@RefType [src.app.models.Task2.HangUpTaskSystem#HangUpTaskSystem]
	local hangUpSystem = role:getHangUpSystem()

	if hangUpSystem:isHangUping() then
		local currHangTask = hangUpSystem:getHangUpTask(hangUpSystem:getCurrHangUpTaskId())
		local taskName = currHangTask:getName()

		local str = taskName .. "\n"

		local CalAfterStartExceptReward = require("app.models.Task2.HangUpReward.CalAfterStartExceptReward")
		local calExceptRewardClass = CalAfterStartExceptReward:create()
		calExceptRewardClass:setPlayerHangUpTask(currHangTask)
		calExceptRewardClass:setPlayer(role)
		for i,reward in ipairs(calExceptRewardClass:getRewards()) do
			--@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
			local reward = reward
			if reward:getAttrName() == "exp" then
				str = str .. reward:getNameText() .. "：" .. Helper:mathFloor(reward:getValue() * 3600) .. "/小时"
			end
		end
		self._UI.Text_task:setString(str)
	else
		self._UI.Text_task:setString("啥事没有")
	end
end

-- 访问服务器，查看是否拥有官职 称号等
function MainLayer:checkIsHaveOfficial()
	if self.isCanCheckOfficial == false then
		return
	end

	self.isCanCheckOfficial = false

	HttpManagerEx:getChenHao(function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				if data then
					local role = User:getRole()
					-- 官职相关
					if role:getAttr("officialType") ~= 0 and data.exam.guanzhi == 0 then
						RichPrint("main", "HIC因为政绩过低，你的官职已经被罢免了。想要重新踏上仕途，七日后可再参加科举、考取功名。")
					end
					role:setAttr("officialType", data.exam.guanzhi)
					role:setAttr("officialAchievement", data.exam.zhengji)
					role:updateOfficialChengHao()

					-- 佳人称号
					if data.jiaren then
						local pertyGirlTitleBasicId = RoleTitleConst.SpecialBasicTitleId.PertyGirl
						local isTrue = role:hasBasicTitle(pertyGirlTitleBasicId)

						if isTrue == true and data.jiaren.is_list == 0 then
							role:deleteBasicTitle(pertyGirlTitleBasicId)
						elseif isTrue == false and data.jiaren.is_list ~= 0 then
							role:addBasicTitle(pertyGirlTitleBasicId)
						end
					end

					-- 公子称号
					if data.gongzi then
						local gongZiTitleBasicId = RoleTitleConst.SpecialBasicTitleId.GongZi
						local isTrue = role:hasBasicTitle(gongZiTitleBasicId)

						if isTrue == true and data.gongzi.is_list == 0 then
							role:deleteBasicTitle(gongZiTitleBasicId)
						elseif isTrue == false and data.gongzi.is_list ~= 0 then
							role:addBasicTitle(gongZiTitleBasicId)
						end
					end
				end
			else
				PopText(errmsg)
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

--检测是否开启拜访任务
function MainLayer:checkCanOpenVisitTask()
	if self.initFinish ~= true then
		return
	end

	local role = User:getRole()
	local fq=role:getHomelandAttr("fq")

	-- 未通过13章和不曾买房不开启拜访
	if Map:getMapState("fb13") ~= MAP_STATE.COMPLETE or MapIsEmpty(fq) then
		return
	end

	--@RefType [src.app.models.task.visitTask.VisitTask#VisitTask]
	local visitTask = require("app.models.task.visitTask.VisitTask")

	--@desc 生成任务时提醒
	if PRINT_MODE == 1 then
		print( GetTime() - User:getRoleAttr("openVisitTaskTime"),role:getDayFlag("拜访任务每日限制"),role:getAttr("visitTaskId"))
	end
	if GetTime() - User:getRoleAttr("openVisitTaskTime") > 1800 and role:getDayFlag("拜访任务每日限制") < VisitTaskLimit then
		visitTask:createTask()
		RichPrint("main","HIC屋外传来一阵敲门声，应是有人前来拜访。")
		self.printOpenTask = true
	else
		--@desc 重新登录游戏时提醒
		if self.printOpenTask == nil then
			local taskId = role:getAttr("visitTaskId")
			if taskId ~= nil then
				local task = visitTask:getTaskById(taskId)

				if MapIsEmpty(task) == false and role:getTimeLimitFlag(task.flag) > 0 then
					RichPrint("main","HIC屋外传来一阵敲门声，应是有人前来拜访。")
				end

				print("重新登录游戏时提醒",role:getTimeLimitFlag(task.flag))
			end

		end
		self.printOpenTask = true
	end
end

--检测是否开启 新春登陆送元宝活动 (当登陆 拜访任务不启用时走这里)
function MainLayer:checkCanOpenDengLuJiangLi(callback)
	-- if  User:getRoleAttr("firstCompleteMap") or User:getRoleAttr("openVisitTaskByMap") or self.offlineVisitTask then
	-- 	return
	-- end
		
	callback = Helper:getDef(callback,EMPTY_FUNC)

	if GetTime() < Helper:getTimeStampWithStringDate("20200928", 0) or GetTime() > Helper:getTimeStampWithStringDate("20201025", 24) then
		callback()
		return
	end

	local role = User:getRole()

	--@desc 此标记不需要改动。
	if  role:getFlag("pop_login") == 0 or Helper:diffWithDate(GetTime(),  role:getFlag("pop_login")) >= 1 then
		role:setFlag("pop_login",GetTime())
		self.isShowDengLu = true
	end

	-- 让这个借口在游戏重启前只调用一次
	if role:getDayFlag("login_reward") == 0 then
		if self.isShowDengLu  then
			self.isShowDengLu = false
			HttpManagerEx:getLoginRewardInfo(function(status, errcode, errmsg, data)
				if status ==200 and errcode == 0 then
					-- "name":"周年庆登陆得奖励","dsc":"谨此献上一份薄礼，还望大侠笑纳。","item":{"exp":10000,"gold":888}
					if data.name and data.dsc and data.item then
						--记录
						PopupLayerController:showLayer("DengLuJiangLiLayer", function(layer)
							layer:showlayer(data.dsc,data.item,callback)
						end)
					end
				else
					-- PopText(errmsg)
					print(errmsg,errcode)
					callback()
				end
			end,IS_SHOW_WAITING)
		end
	else
		callback()
	end
end

function MainLayer:checkIsFamilyPrestige()
	if self.CheckPrestigeRankingTop == false then
		return
	end

	self.CheckPrestigeRankingTop = false

	local FamilyPrestige=require("app.models.family.FamilyPrestige")
	FamilyPrestige:getUserPrestige(function(data)
		self:__initName()
	end)

end

function MainLayer:__initName()
    local chenghao = self.__role:getChengHaoColorName()
    local name = self.__role:getName()

	self._UI:setTextUserName(name)

	self._UI:setTextName(chenghao)
end

-- 按钮初始化及控制
function MainLayer:initButtonWithResume()
	if self.__uiInitState == 1 or self.__uiInitState == 3 then
		self._UI.Button_jianghu:setVisible(false)
		self._UI.Button_shimen:setVisible(false)
		-- self._UI.Button_lunjian:setVisible(false)
		self._UI.Button_shenbing:setVisible(false)
		self._UI.Button_shangcheng:setVisible(false)
		self._UI.Button_paihang:setVisible(false)
		self._UI.Button_meridian:setVisible(false)
		self._UI.Button_dream:setVisible(false)
		self._UI.Button_test:setVisible(false)
		self._UI.Button_selfCreatedSkill:setVisible(false)
		self._UI.Button_quanJiao:setVisible(false)
	end

	if User:getRole():getSelfCreatedSkillSystem():isOpenSystem() then
		-- self._UI.Button_lunjian:setPosition(988,680)
		self._UI.Button_shenbing:setPosition(837,680)
		self._UI.Button_shangcheng:setPosition(90,680)
		self._UI.Button_paihang:setPosition(238,680)
		self._UI.Button_meridian:setPosition(387,680)
		self._UI.Button_dream:setPosition(688,680)
		self._UI.Button_selfCreatedSkill:setPosition(538,680)
		self._UI.Button_quanJiao:setPosition(988,680)
	else
		-- self._UI.Button_lunjian:setPosition(960,680)
		self._UI.Button_shenbing:setPosition(792,680)
		self._UI.Button_shangcheng:setPosition(120,680)
		self._UI.Button_paihang:setPosition(288,680)
		self._UI.Button_meridian:setPosition(456,680)
		self._UI.Button_dream:setPosition(624,680)
		self._UI.Button_quanJiao:setPosition(960,680)
	end

	self.Curr_Button_State = false	-- 控制师门按钮
	self.Curr_Button_State2 = false	-- 控制师门按钮图片
	self.Curr_Button_State3 = false	-- 控制江湖按钮
	self.Curr_Button_State4 = false	-- 控制排行，商城
	self.Curr_Button_State5 = false	-- 控制神兵按钮
	self.Curr_Button_State6 = false	-- 控制经脉按钮
	self.Curr_Button_State7 = false	-- 控制新手引导提示
	self.Curr_Button_State8 = false	-- 控制梦境按钮
	self.Curr_Button_State9 = false	-- 控制神功按钮
	self.Curr_Button_State10 = false-- 控制拳脚按钮


	if DEBUG_MODE == 1 then
		self._UI.Button_jianghu:setVisible(true)
		self._UI.Button_shimen:setVisible(true)
		-- self._UI.Button_lunjian:setVisible(true)
		self._UI.Button_shangcheng:setVisible(true)
		self._UI.Button_paihang:setVisible(true)
		self._UI.Button_shenbing:setVisible(true)
		self._UI.Button_meridian:setVisible(true)
		self._UI.Button_dream:setVisible(true)
	end

	self._UI.Button_test:setVisible(true) -- patched by mock server: always show
	-- self._UI.Button_test:setVisible(false)


	self.isCanCheckVisitTask = true
	self._gongGaoIsShow = false

end

-- 心跳控制
function MainLayer:heartBeatFunc(...)
	local heartTime = {...}
	local currTime = GetTime()
	local role = User:getRole()
	-- 获取奖励
	if currTime - role:getFlag("获取奖励时间") > heartTime[1] and role:getAttr("userid") ~= nil then
		role:setFlag("获取奖励时间", currTime)

		-- 校准服务器时间
		HttpManagerEx:getTime(function(status, errcode, errmsg, data, isEncrypted)
			if status == 200 and errcode == 0 and data.time ~= nil then
                SetTime(tonumber(data.time))
				NETWORK_STATE = 1
			end
		end)
	end
end

local  index  = 1
-- 按键注册 -----------------------------------------------------------------------------------
function MainLayer:setFightEventListener()
	if self._layerInScene == nil then
		local runningScene = cc.Director:getInstance():getRunningScene()
		self._layerInScene = cc.Layer:create()
		runningScene:addChild(self._layerInScene)
	end

	-- 以下为按键监听
	local eventDispatcher = self._layerInScene:getEventDispatcher()

	if self._layerInScene.touchListener ~= nil then
		eventDispatcher:removeEventListener(self._layerInScene.touchListener)
		self._layerInScene.touchListener = nil
	end

	self._layerInScene.touchListener = cc.EventListenerKeyboard:create()

	local listener = self._layerInScene.touchListener

	local testTab = 
	{
	}
	listener:registerScriptHandler(
	function(keyCode)
        Game:addBlockAsyncFunc("MainMenuShortcutKey", function()
			-- 玩家按键
			local role = User:getRole()
			if keyCode == cc.KeyCode.KEY_T then --师门任务GMLayer
				local TestFuncLayer = require("app.views.layer.DebugLayer.GMLayer")
				TestFuncLayer:getInstance():showLayer()
			elseif keyCode == cc.KeyCode.KEY_Q then
				local testLayer = require("app.views.layer.DebugLayer.TestLayer"):getInstance()
				if testLayer:isVisible() then
					testLayer:setVisible(false)
				else
					testLayer:showLayer()
				end
			elseif keyCode == cc.KeyCode.KEY_W then
				local gMLayer = require("app.views.layer.DebugLayer.GMLayer"):getInstance()
				if gMLayer:isVisible() then
					gMLayer:setVisible(false)
				else
					gMLayer:showLayer()
				end
			elseif keyCode == cc.KeyCode.KEY_C then
				local file = io.open("command.lua", "r")
				if file == nil then
					io.open("command.lua", "w")
				else
					local script = file:read("*a")
					loadstring(script)()
				end
			end
        end, true)
	end, cc.Handler.EVENT_KEYBOARD_PRESSED)

	listener:registerScriptHandler(
	function(keyCode)
		keyCode = keyCode - 3
	end, cc.Handler.EVENT_KEYBOARD_PRESSED + 1)
	eventDispatcher:addEventListenerWithSceneGraphPriority( self._layerInScene.touchListener, self._layerInScene )
end


function MainLayer:changRoleTitle(titleType,titleId)
	self.__headpresenter:showTheHead()
	self:refreshUI()
end

function MainLayer:changWearMask(maskId, lv)
	self.__headpresenter:showTheHead()
end

function MainLayer:onEnable()
	--1 创建时初始化 2第一次onEnable 3其他onEnable

	if self.__uiInitState == 1 then
		self.__uiInitState = 2
	elseif self.__uiInitState == 2 then
		self.__uiInitState = 3
	end

    self:initButtonWithResume()
	-- add by XiaoZhiWei 2017/07/17 18:48:15 测试服务器不需要增加心跳校准
	if Game:isTesting() == false then
		self:heartBeatFunc(300)
	end

	--暂定进入主界面刷新一次
	AchievementSystem:update()
	AchievementSystem:updateTujianTypeRecord()


	self:refreshButtonTaskText()
	self.__role:getTitleSystem():addOutput(self)
	self.__role:getMaskSystem():addOutput(self)
	self.__headpresenter:showTheHead()
	self:refreshUI()
end

function MainLayer:onDisable()
	self.__role:getTitleSystem():deleteOutput(self)
	self.__role:getMaskSystem():deleteOutput(self)
end

Helper:classDefNodeGetInstance(MainLayer)

-- 加密标记
MainLayer.isEncrypted = true
return MainLayer
0000000
local Resource = require("app.Resource")
local Skill = require("app.models.skill.Skill")
local BiWu = require("app.models.BiWu.BiWu")
local Npc = require("app.models.npc.Npc")
---
-- 文字战斗界面
-- @author Tangjian
-- @time 2016/4/14 0014 20:34
local WordFightLayer = class("WordFightLayer", require("app.views.base.BaseLayer"))

---
-- 创建实例方法
-- @author Tangjian
-- @time 2016/4/14 0014 20:34
function WordFightLayer:create()
    local p = WordFightLayer:new()
    p:init()
    return p
end

---
-- 初始化
-- @author Tangjian
-- @time 2016/4/14 0014 20:35
function WordFightLayer:init()
	self._UI = require("Layer/WordFightUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

	self.Panel_8.LoadingBar_2:releaseFunc(function()
		-- 跑方经验^(1/3)*跑方身法/（跑方经验^(1/3)*跑方身法+敌方经验^(1/3)*敌方身法）
		if self._updateFightEnable == false then
			return
		end
		local state = false
		local num = 0
		if num <= 100 then
			state = true
		end

		if state then
			self.Panel_9.Text_52:setString("失败！")
			self.Panel_9.Text_desc:setString("你大喝一声：“三十六计，走为上计”")
			self:endFight(3)
		else
			self:outputText("逃跑失败")
		end
	end)

	self.Panel_8.Button_win:setVisible(false)
	self.Panel_8.Button_win:releaseFunc(function()
		if self._updateFightEnable == false then
			return
		end
			self:endFight(1)
			-- self:hide()
		end)


	self.Panel_8.Button_lose:setVisible(false)
	self.Panel_8.Button_lose:releaseFunc(function()
		if self._updateFightEnable == false then
			return
		end
			self:endFight(2)
			-- self:hide()
		end)

	-- 恢复按钮
	-- self.Panel_8.LoadingBar_2:releaseFunc(function()

	-- 	local role = assert(self.__user)
	-- 	local currTime = GetTime()
	-- 	if not self.useTime then
	-- 		self.useTime = GetTime()
	-- 	end
	-- 	if role.Is_Lose then
	-- 		return
	-- 	end
	-- 	local addNeiLi = 20+tonumber(role:getNumAttr("neili")/50)
	-- 	if role:getNumAttr("neili") < addNeiLi then
	-- 		PopText("内力不足，不能回血")
	-- 		return
	-- 	end

	-- 	if self.useTime	and currTime - self.useTime >= 3 then
	-- 		local addQi = tonumber(addNeiLi*role:getSkillFactor("neigong", "neili")/100)
	-- 		role:addAttr("qi", addQi)
	-- 		role:addAttr("neili", -addNeiLi)
	-- 		self:outputText("（"..tostring(role:getName()).."使用回复技能，回复血量GRN"..math.floor(addQi).."NOR）")

	-- 		self:showNum("HP", math.floor(addQi), role)
	-- 		self:showNum("MP", - math.floor(addNeiLi), role)
	-- 		self.useTime = GetTime()
	-- 	else
	-- 		PopText("冷却中！")
	-- 	end
	-- end)

	self.Panel_8.LoadingBar_1:releaseFunc(
		function()
			if self.useTime then
				return
			end
			local role = assert(self.__user)
			if role.Is_Lose then
				return
			end
			local addNeiLi = 20 + tonumber(role:getNumAttr("neili")/50)
			if PRINT_MODE == 1 then
				if PRINT_MODE == 1 then
					print("addNeiLi == "..addNeiLi)
				end
			end
			if role:getNumAttr("neili") < addNeiLi then
				PopText("内力不足，不能回血")
				return
			end

			local addQi = tonumber(addNeiLi*role:getSkillFactor("neigong", "neili")/60 + 5)
			role:addAttr("qi", addQi)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 以逸待劳, 不消耗内力
            if role:getFlag("以逸待劳") == true then
                PopText("以逸待劳")
            else
                role:addAttr("neili", -addNeiLi)
            end

			self:outputText("（"..tostring(role:getName()).."使用回复技能，回复血量GRN"..math.floor(addQi).."NOR）")

			self:showNum("HP", math.floor(addQi), role)
			self:showNum("MP", - math.floor(addNeiLi), role)
			self:refreshUI(self._fightRoles[1], self._fightRoles[2])
			self.useTime = GetTime()


			----记录是否点击了恢复气血
			BiWu:countFightDataMap(role:getName(),"isSkillBloode",true)
		end)


    self:initMemberVariable() -- 初始化成员变量
	self:initRichText()

    -- 设置调度器
    self:schedule(function(ft)
        self:update(ft)

        if not self.useTime then
        	return
        end
		local currTime = GetTime()
		local needTime = currTime - self.useTime
		local percent
		percent = math.min(math.floor(needTime / 2 * 100), 100)
		self.Panel_8.LoadingBar_1:setPercent(percent)
		if percent == 100 then
			self.useTime = nil
		end
    end,0)

end

---
-- 刷新
-- @author Tangjian
-- @time 2016/4/14 0014 22:32
function WordFightLayer:update(ft)
--    print("WordFightLayer:update("..tostring(ft)..")")

	if not self._updateFightEnable and not self.__state then
		self.__state = true
		self:delayFunc(0, function() self:startFightShow() end)
	end

    -- 刷新战斗
    if self._updateFightEnable then
        self:updateFight(ft)
        -- self:updateLoading()
    end



end

-------------------------------------------------------------------------------------------------------------
-- 主要流程
-- @author Tangjian
-- @time 2016/4/14 0014 22:08
---

---
-- 开始战斗
-- @params teamRoles1:队伍1人物; teamRoles2:队伍2人物;
-- @author Tangjian
-- @time 2016/4/14 0014 20:42
function WordFightLayer:startFight(teamRoles1, teamRoles2, callResultFunc, isClickHide, isCanRun)
	if isClickHide == nil then
		isClickHide = false
	end
	if isCanRun == nil then
		isCanRun = true
	end
	self._isCanRun = isCanRun
	self._isClickHide = isClickHide

	-- 初始化richtext
	self:initRichText()

    assert(type(teamRoles1) == "table" and type(teamRoles2) == "table" and type(callResultFunc) == "function", "type(teamRoles1) = "..tostring(type(teamRoles1)).."type(teamRoles2) = "..tostring(type(teamRoles2)).."type(callResultFunc) = "..tostring(type(callResultFunc)))
    -- 初始化战斗开始
    do
        self:initMemberVariable() -- 初始化成员变量,以免被之前的数据影响
        self._callResultFunc = callResultFunc -- 设置战斗结束回调
        self:initTeams(teamRoles1, teamRoles2) -- 初始化队伍
    end
    -- 初始化战斗完成

    self.__Team1 = teamRoles1
    self.__Team2 = teamRoles2

    self:refreshUI(self._fightRoles[1], self._fightRoles[2])

    self.Panel_me.Text_2:setString(teamRoles1[1].name)
    self.Panel_he.Text_3:setString(teamRoles2[1].name)

    self.Panel_8.LoadingBar_2:setVisible(self._isCanRun)
    self.Panel_8.Button_1:setVisible(self._isCanRun)

    -- 执行战斗主要流程
    self:fightMain()
end

function WordFightLayer:startFightNpcToNpc(teamRoles1, teamRoles2, callResultFunc)
	self._isClickHide = false  -- 传承不需要 战斗结束后的点击隐藏效果

	-- 初始化richtext
	self:initRichText()

    assert(type(teamRoles1) == "table" and type(teamRoles2) == "table" and type(callResultFunc) == "function")
    -- 初始化战斗开始
    do
        self:initMemberVariable() -- 初始化成员变量,以免被之前的数据影响
        self._callResultFunc = callResultFunc -- 设置战斗结束回调
        self:initTeams(teamRoles1, teamRoles2) -- 初始化队伍
    end
    -- 初始化战斗完成

    self.__Team1 = teamRoles1
    self.__Team2 = teamRoles2

    self:refreshUI(self._fightRoles[1], self._fightRoles[2])

    self.Panel_me.Text_2:setString(teamRoles1[1].name)
    self.Panel_he.Text_3:setString(teamRoles2[1].name)

    self.Panel_8:setVisible(false)
    self.Panel_9:setVisible(false)

    self._isNpcToNpc = true

    -- 执行战斗主要流程
    self:fightMain()
end

-- 战斗结束
function WordFightLayer:endFight(winTeamId, msg)
	self:setFightUpdateEnable(false)
	self:richTextShowAllFightStatusString()

	-- 战斗中影响的属性，战斗结束时设置上去
	local function convertRole(role1, role2)
		if role1:getAttr("onlyId") == role2:getAttr("onlyId") then
			local qi = role2:getAttr("qi")
			local neili = role2:getAttr("neili")
			local qiMax = role2:getCurrQiMax()

			if qi < qiMax*0.2 and self.From_Type == "切磋" then
				qi = qiMax * 0.2
			end

			role1:setAttr("qi", qi)
			role1:setAttr("qiPercent", role2:getAttr("qiPercent"))
			role1:setAttr("neili", neili)
			role1:setFlag("战斗脱离时间", GetTime())

            -- 设置被什么技能杀死
            role1:setAttr("zhengqi", role2:getAttr("zhengqi"))
            role1:setAttr("dead", role2:getAttr("dead"))
            role1:setAttr("deadReason", role2:getAttr("deadReason"))
            role1:setAttr("kill", role2:getAttr("kill"))
            role1:setAttr("killedBySkillName", role2:getAttr("killedBySkillName"))
		end
	end

	local function convertTeam(team1, team2)
		for k,roles in pairs(team2) do
			if MapIsEmpty(roles) then
			else
				for k1,role1 in pairs(team1) do
					for k2,role2 in pairs(roles) do
						if not role1 or not role2 then
						else
							convertRole(role1, role2)
						end
					end
				end
			end
		end
	end

	convertTeam(self.__Team1, self._teams[1])
	convertTeam(self.__Team2, self._teams[2])


	-- 判断是否需要 点击隐藏 效果
	if self._isClickHide == false then
		self:endFightShow(function()
			self:hide(function()
				self._callResultFunc(winTeamId, self._teams)
			end)
		end)
	else
		self:endFightShow()
		-- 点击结果模块,隐藏战斗界面
		self.Panel_9:setTouchEnabled(true)
		self.Panel_9:releaseFunc(function()
			if self.canHide == true then
				self:hide(function()
					self._callResultFunc(winTeamId, self._teams)
				end)
				self.canHide = false -- 只能点击一次
			end
		end)
	end
end

---
-- 战斗主要流程: 开场白 -> 刷新战斗
-- @author Tangjian
-- @time 2016/4/14 0014 22:40
function WordFightLayer:fightMain()
    -- 开场白
    self:showPrologue(function()
        -- -- 开始刷新战斗
        -- self:setFightUpdateEnable(true)
    end)
end

---
-- 显示开场白
-- @author Tangjian
-- @time 2016/4/14 0014 22:09
function WordFightLayer:showPrologue(endFunc)
    -- self:outputText("开场白!")

    local team1 = self._teams[1]
    local team2 = self._teams[2]

    -- 队伍1的人对队伍2的人说开场白
	for k, team1FightRole in pairs(team1.roles) do
		for k, team2FightRole in pairs(team2.roles) do
			local prologue = team1FightRole:getFightPrologue(team2FightRole, self.From_Type)
			self:printFightStatus(prologue, team1FightRole.name, team2FightRole.name)
		end
    end

    endFunc() -- 开场白显示显示结束调用回调
end

---
-- 设置刷新战斗
-- @author Tangjian
-- @time 2016/4/14 0014 22:30
function WordFightLayer:setFightUpdateEnable(b)
    self._updateFightEnable = b
end

---
-- 刷新战斗
-- @author Tangjian
-- @time 2016/4/14 0014 22:29
function WordFightLayer:updateFight(ft)
    -- print("updateFight(" .. tostring(ft) .. ")")

    -- 刷新战斗中的每一个角色
    self:updateAllFightRole(ft)
end

-------------------------------------------------------------------------------------------------------------
-- 渲染部分
-- @author Tangjian
-- @time 2016/4/14 0014 21:41

function WordFightLayer:show(bool, fType)
	-- self.richPrint:getRichText():removeAllElement()
	self.From_Type = fType
	self:setVisible(true)
	self:setOpacity(255)
	self.Panel_8:setVisible(true)
	self.Panel_9:setVisible(false)

	self.Panel_8.LoadingBar_1:setPercent(100)

	self.__delayTime = nil
	self.__state = false
	self.__state2 = false
	self.__state3 = false
	self.canHide = false -- 控制是否允许隐藏
end

function WordFightLayer:hide(callBack)
	local PanelBackLayer = require("app.views.ui.PanelBackUI")
	local layer = PanelBackLayer:getInstance()
	layer:showAndHide(0.5, 0.5, function()
		--self:setVisible(false)
		self:setSelfAndChildrenCascadeOpacityEnabled(true)
		self:runAction(
			cc.Sequence:create(
				YXEaseAction:create( cc.FadeOut:create( 0.5 ) ,  Sine_EaseOut ) ,
				cc.CallFunc:create( function()
						self:setVisible(false)
						if callBack then
							self:delayFunc(0, callBack)
						end
					end)
			 	)
			)
	end)

	self.is_Init = false

	-- -- 当前界面隐藏
	-- local actionTag = self:getActionTagByName("hide")
	-- self:stopActionByTag(actionTag)
	-- self:setCascadeOpacityEnabled(true)
	-- self:callAllChild(function(child)
	-- 		child:setCascadeOpacityEnabled(true)
	-- 	end)
	-- local action = cc.Sequence:create(
	-- 	cc.FadeOut:create(0.5),
	-- 	cc.CallFunc:create(function()
	-- 		local item = self.Panel_back
	-- 		local actionTag1 = item:getActionTagByName("show")
	-- 		item:stopActionByTag(actionTag1)
	-- 		local action1 = cc.Sequence:create(
	-- 			cc.FadeOut:create(0.5)
	-- 			,cc.CallFunc:create(function()
	-- 			end)
	-- 		)
	-- 		action1:setTag(actionTag1)
	-- 		item:runAction(action1)
	-- 	end)
	-- )
	-- action:setTag(actionTag)
	-- self:runAction(action)
end

function WordFightLayer:initRichText()
	if self.richPrint then
		self.richPrint:removeFromParent()
		self.richPrint = nil
	end
	self.Image_2.Text_1:setVisible(false)
	self.richPrint = ExtRichTextScroll:create()
	self.Image_2:addChild(self.richPrint)

	local size = self.Image_2.Text_1:getContentSize()
	local x, y = self.Image_2.Text_1:getPosition()

    -- 设置richtext位置到self.Image_2.Text_1中心位置
    self.richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
	self.richPrint:setSize(size)

	self.richPrint:setScrollBarEnabled(false)
    
    -- 设置最大显示高度
    self.richPrint:setTextMaxHeight(size.height)
    
    -- 记录文本, 用作战斗结束回顾
    self.richPrint.fightStatusStringArray = {}

	-- 一直显示文本最下方
	self.richPrint.scheduleHandle = self:scheduleUnique(function(elapsed)
        self.richPrint:scrollToBottom(0, false)
        self.richPrint:jumpToBottom()                        
    end, 0, "self.richPrint:setPosition")
end

-- 开始战斗渲染
function WordFightLayer:startFightShow()
	local item = self.Panel_9.Text_52:clone()
	self:addChild(item)
	item:move(cc.p(540, 960))
	item:setString("开始战斗")
	local actionTag = item:getActionTagByName("scale")
	item:stopActionByTag(actionTag)
	item:setScale(0.8)
	local action = cc.Sequence:create(
			cc.Sequence:create(
				cc.ScaleTo:create(0.3, 1.2),
				cc.ScaleTo:create(0.2, 1.0)
			),
			cc.CallFunc:create(function()
				self:removeChild(item)
	        	self:setFightUpdateEnable(true)
	        	-- 开始战斗时CD初始化
    			self.useTime = GetTime()
			end)
		)
	action:setTag(actionTag)
	item:runAction(action)
end

-- UI刷新
function WordFightLayer:refreshUI(fightRole, target)
	if not fightRole or not target then
		assert(nil, "WordFightLayer:refreshUI(fightRole, target)")
	end

	local user, npc
    if fightRole.teamId == 1 then
        user = fightRole
		npc = target
		self.__user = fightRole
		self.__npc = target
    else
        user = target
		npc = fightRole
		self.__user = target
		self.__npc = fightRole
    end

	if not self.is_Init then
		local mQiPercent, mCurrQiPercent, mNlPercent, tQiPercent, tCurrQiPercent, tNlPercent
		mQiPercent = math.floor(user:getNumAttr("qi")/user:getNumAttr("qiMax")*100)
		mCurrQiPercent = math.floor(Helper:getDef(user:getAttr("qiPercent"), 1)*100)
		mNlPercent = math.floor(user:getNumAttr("neili")/user:getNumAttr("neiliMax")*100)

		-- print(fightRole:getName())
		-- print(fightRole:getAttr("exp"))
		-- print(fightRole:getExp())
		-- print(fightRole:getAttr("lv"))
		-- print(fightRole:getLv())

		-- if user:getAttr("qi") > user:getAttr("qiMax") then
		-- 	user:setAttr("qiMax", user:getAttr("qi"))
		-- end

		-- if user:getAttr("neili") > user:getAttr("neiliMax") then
		-- 	user:setAttr("neiliMax", user:getAttr("neili"))
		-- end

		-- if npc:getAttr("qi") > npc:getAttr("qiMax") then
		-- 	npc:setAttr("qiMax", npc:getAttr("qi"))
		-- end

		-- if npc:getAttr("neili") > npc:getAttr("neiliMax") then
		-- 	npc:setAttr("neiliMax", npc:getAttr("neili"))
		-- end

		tQiPercent = math.floor(npc:getNumAttr("qi")/npc:getNumAttr("qiMax")*100)
		tCurrQiPercent = math.floor(Helper:getDef(npc:getAttr("qiPercent"), 1)*100)
		tNlPercent = math.floor(npc:getNumAttr("neili")/npc:getNumAttr("neiliMax")*100)


		self.Panel_me.Panel_1.LoadingBar_2:setPercent(mCurrQiPercent)
		self.Panel_me.Panel_1.LoadingBar_3:setPercent(mQiPercent)
		self.Panel_me.Panel_2.LoadingBar_3:setPercent(mNlPercent)
		self.Panel_he.Panel_3.LoadingBar_2:setPercent(tCurrQiPercent)
		self.Panel_he.Panel_3.LoadingBar_3:setPercent(tQiPercent)
		self.Panel_he.Panel_4.LoadingBar_3:setPercent(tNlPercent)
		self.is_Init = true
	end
	self.Panel_me.Panel_1.Text_num:setString(user:getNumAttr("qi").."/"..math.floor(user:getCurrQiMax()))
	self.Panel_me.Panel_2.Text_num:setString(user:getNumAttr("neili").."/"..user:getNumAttr("neiliMax"))


	self.Panel_he.Panel_3.Text_num:setString(npc:getNumAttr("qi").."/"..math.floor(npc:getCurrQiMax()))
	self.Panel_he.Panel_4.Text_num:setString(npc:getNumAttr("neili").."/"..npc:getNumAttr("neiliMax"))
end

-- 读条效果
function WordFightLayer:updateLoading(role)
	local currTime = GetTime()
	assert(role, "WordFightLayer:updateLoading(role)")

	if not self.userTime then
		self.userTime = currTime
	end
	if not self.npcTime then
		self.npcTime = currTime
	end

	local target = self:fightRoleGetTarget(role)
	if role.Is_Lose or target.Is_Lose then
		return
	end

	if not role.totalSwingDuration then
		return
	end

	local item, useTime
	local userLoading = role.totalSwingDuration
	if role.teamId == 1 then
		item = self.Panel_me.LoadingBar_jing1
		useTime = self.userTime
	else
		item = self.Panel_he.LoadingBar_jing2
		useTime = self.npcTime
	end
	local uPercent = math.max((userLoading - currTime + useTime)/userLoading * 100, 0)
	item:setPercent(uPercent)

	-- local npcLoading = npc.preSwingDuration+aftSwingDuration

	-- local nPercent = math.max((npcLoading - currTime + self.npcTime)/npcLoading * 100, 0)
	-- self.Panel_he.LoadingBar_jing2:setPercent(nPercent)
end

-- 血条 扣血效果
function WordFightLayer:showLoadingBar(nType, role)
	if not nType or not role then
		assert(nil, "WordFightLayer:showLoadingBar(item, nType)")
	end

	local item ,to
	if role.teamId == 1 then
		if nType == "HP" then
			to = role:getAttr("qi")/role:getAttr("qiMax") * 100
			item = self.Panel_me.Panel_1.LoadingBar_3
		elseif nType == "HPMax" then
			to = role:getAttr("qiPercent") * 100
			item = self.Panel_me.Panel_1.LoadingBar_2
		else
			to = role:getAttr("neili")/role:getAttr("neiliMax") * 100
			item = self.Panel_me.Panel_2.LoadingBar_3
		end
	else
		if nType == "HP" then
			to = role:getAttr("qi")/role:getAttr("qiMax") * 100
			item = self.Panel_he.Panel_3.LoadingBar_3
		elseif nType == "HPMax" then
			to = role:getAttr("qiPercent") * 100
			item = self.Panel_he.Panel_3.LoadingBar_2
		else
			to = role:getAttr("neili")/role:getAttr("neiliMax") * 100
			item = self.Panel_he.Panel_4.LoadingBar_3
		end
	end
	local times, from = 60, item:getPercent()

	local actionTag = item:getActionTagByName("move")
	item:stopActionByTag(actionTag)
	item:setPercent(from)
	local action = cc.Repeat:create(
		cc.Sequence:create(
			cc.DelayTime:create( 1 / times ),
			cc.CallFunc:create(
				function()
					item:setPercent(item:getPercent() - (from - to) / times )
				end)
		 ), times)
	action:setTag(actionTag)
	item:runAction(action)
end

-- 加减数字效果控制
function WordFightLayer:showNum(nType, num, role, delayTime)
    self:delayFunc(delayTime, function()
        if not nType or not num or type(num) ~= "number" or not role then
    		assert(nil, "WordFightLayer:showNum(nType, num, role)")
    	end
    	if num == 0 then
    		return
    	end

    	local tab =
    	{
    		white = cc.c4b(255, 255, 255, 255),
    		blue = cc.c4b(11,128,246, 255),
    		green = cc.c4b(57, 219, 92, 255),
    		yellow = cc.c4b(175,145,25, 255)
    	}

    	-- local posX, posY
    	local item
    	if role.teamId == 1 then
    		-- posX = 230
    		if nType == "HP" then
    			item = self.Text_num_show:clone()
                item:addTo(self.Text_num_show:getParent())
                item:setPosition(cc.p(self.Text_num_show:getPosition()))
                item:enableOutline(cc.c4b(0, 0, 0, 255), 5)

    			-- 抖动效果
    			self:showShake(role)
    		else
                item = self.Text_num_show2:clone()
                item:addTo(self.Text_num_show2:getParent())
                item:setPosition(cc.p(self.Text_num_show2:getPosition()))
                item:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    		end
    	else
    		if nType == "HP" then
                item = self.Text_num_show3:clone()
                item:addTo(self.Text_num_show3:getParent())
                item:setPosition(cc.p(self.Text_num_show3:getPosition()))
                item:enableOutline(cc.c4b(0, 0, 0, 255), 5)

    			-- 抖动效果
    			self:showShake(role)
    		else
                item = self.Text_num_show4:clone()
                item:addTo(self.Text_num_show4:getParent())
                item:setPosition(cc.p(self.Text_num_show4:getPosition()))
                item:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    		end
    		-- posX = 820
    	end

        -- 随机一下横向位置
        item:setPositionX(item:getPositionX() + math.random(-50, 50))

    	local color
    	if nType == "HP" then
    		-- posY = 1800
    		if num >= 0 then
    			color = tab.green
    		else
    			color = tab.white
    		end
    	elseif nType == "MP" then
    		-- posY = 1755
    		color = tab.blue
    	else
    		color = tab.yellow
    	end
    	item:setVisible(true)

    	local posX, posY = item:getPosition()
    	self:showLoadingBar(nType, role)

    	-- Helper:convertUI(item)
    	item:setString(num)
    	item:setColor(color)

    	item:setOpacity(255)

    	local actionTag = item:getActionTagByName("move")
    	item:stopActionByTag(actionTag)
    	local action
    	if nType == "HP" and num < 0 then
    		action= cc.Sequence:create(
    		cc.Sequence:create(
    			cc.Sequence:create(
    				cc.ScaleTo:create(0.15, 1.5),
    				cc.ScaleTo:create(0.15, 1)
    			),
    			cc.Spawn:create(
    				cc.MoveTo:create(0.5, cc.p(posX, posY + 50)),
    				cc.FadeOut:create(0.5)
    			)
    		))
    	else
    		action = cc.Sequence:create(
    		cc.Spawn:create(
    			cc.MoveTo:create(0.5, cc.p(posX, posY + 50)),
    			cc.FadeOut:create(0.5)
    		))
    	end

    	action:setTag(actionTag)
    	item:runAction(action)
    end)
end

-- 血条震动效果
function WordFightLayer:showShake(role)
	local item
	if role.teamId == 1 then
		item = self.Panel_me
	else
		item = self.Panel_he
	end

    if item.originY == nil then
        item.originY = item:getPositionY()
    end

	local posX, posY = item:getPosition()
	local actionTag = item:getActionTagByName("Shake")
	item:stopActionByTag(actionTag)
	local action = cc.Sequence:create(
            cc.MoveTo:create(0.1, cc.p(posX, item.originY)),
			cc.MoveTo:create(0.1, cc.p(posX, item.originY-5)),
			cc.MoveTo:create(0.2, cc.p(posX, item.originY))
		)
	action:setTag(actionTag)
	item:runAction(action)
end

-- 战斗胜利效果
function WordFightLayer:endFightShow(callBack)
	self.Panel_8:setVisible(false)
	if self._isNpcToNpc == false then
		self.Panel_9:setVisible(true)
	end
	self.Panel_9.Text_desc:setVisible(false)

	-- 显示胜利
	local item = self.Panel_9
	local actionTag = item:getActionTagByName("scale")
	item:stopActionByTag(actionTag)
	item:setScale(0.8)
	local action = cc.Sequence:create(
			cc.ScaleTo:create(0.1, 1.2),
			cc.ScaleTo:create(0.1, 1.0)
		)
	action:setTag(actionTag)
	item:runAction(action)

	-- 显示死亡原因
	self:delayFunc(0.3, function ()
		item = self.Panel_9.Text_desc
		item:setVisible(true)
		item:setOpacity(0)

		actionTag = item:getActionTagByName("show")
		action = cc.Sequence:create(
			cc.FadeIn:create(0.2),
			cc.CallFunc:create(function()
				-- -- 等待1秒钟 才允许点击隐藏
				self:delayFunc(1, function()
					self.canHide = true
					if callBack then
						callBack()
					end
					-- self:hide(callBack)
					-- self:delayFunc(1, callBack)
				end)
			end)
		)
		action:setTag(actionTag)
		item:runAction(action)
	end)

	-- self:delayFunc(2, function()
	-- 	self:hide()
	-- end)
end

---
-- 输出文本
-- @author Tangjian
-- @time 2016/4/14 0014 22:59
local textColor = cc.c3b(159,159,159) -- 战斗输出默认文字颜色
function WordFightLayer:outputText(text)
	if type(text) == "string" then
		-- 记录战斗字符串
		if self.richPrint.fightStatusStringArray then
			table.insert(self.richPrint.fightStatusStringArray, text.."NOR\n")
		end

		self.richPrint:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 42)
		self.richPrint:pushBackNewLine(0)
	else
		print("type(text) = ", type(text))
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 16:55:52
-- @desc 得到战斗状态字符串
function WordFightLayer:getFightStatusString()
	local maxLine = 50
	-- PopText("条数: "..tostring(#self.richPrint.fightStatusStringArray))
	if #self.richPrint.fightStatusStringArray > maxLine then
		local from, to = Helper:getRange(#self.richPrint.fightStatusStringArray - maxLine, 0, maxLine), #self.richPrint.fightStatusStringArray
    	return table.concat(self.richPrint.fightStatusStringArray, nil, from, to)
   	else
   		return table.concat(self.richPrint.fightStatusStringArray)
	end	
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 17:08:12
-- @desc 富文本中显示战斗所有文本
function WordFightLayer:richTextShowAllFightStatusString()
    local fightStatusString = self:getFightStatusString()

    print("1111111111111111111111111111111 == "..tostring(fightStatusString))

    local scheduleHandle = self.richPrint.scheduleHandle

    if self.richPrint then
		self.richPrint:removeFromParent()
		self.richPrint = nil
	end
	self.Image_2.Text_1:setVisible(false)
	self.richPrint = ExtRichTextScroll:create()
	self.Image_2:addChild(self.richPrint)

	local size = self.Image_2.Text_1:getContentSize()
	local x, y = self.Image_2.Text_1:getPosition()

    -- 设置richtext位置到self.Image_2.Text_1中心位置
    self.richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
	self.richPrint:setSize(size)
    
    -- 设置最大显示高度
    self.richPrint:setTextMaxHeight(9999999999)    
    
    self:outputText(fightStatusString)

    self:delayFunc(0.1, function()
        self:unschedule(scheduleHandle)
    end)
end

-- 战况输出
function WordFightLayer:printFightStatus(text, role1Name, role2Name, weapon1Name, weapon2Name, attackPart)
	local role = User:getRole()

	if role1Name == role:getName() then
		role1Name = "你"
	elseif role2Name == role:getName() then
		role2Name = "你"
	end

	if role1Name then
		text = string.gsub(text, "$N", role1Name)
		text = string.gsub(text, "$P", role1Name)
	end

	if role2Name then
		text = string.gsub(text, "$n", role2Name)
		text = string.gsub(text, "$p", role2Name)
	end

	if weapon1Name then
		if role.shenBingweapon.name == weapon1Name then
			text = string.gsub(text, "$w", tostring(role.shenBingweapon.colorname)..tostring(weapon1Name).."NOR")
		else
			text = string.gsub(text, "$w", weapon1Name)
		end
	end

	if weapon2Name then
		text = string.gsub(text, "$W", weapon2Name)
	end

	if attackPart then
		text = string.gsub(text, "$l", attackPart)
	end

	self:outputText(text)
end




-------------------------------------------------------------------------------------------------------------
-- 以下纯数和据逻辑,无渲染
-- @author Tangjian
-- @time 2016/4/14 0014 21:41

---
-- 初始化所有成员变量
-- @author Tangjian
-- @time 2016/4/14 0014 21:19
function WordFightLayer:initMemberVariable()
    -- 成员变量全部在这定义
    self._player = nil -- 玩家
    self._fightRoles = {} -- 战斗角色
    self._teams = {} -- 队伍
    self._callResultFunc = nil -- 战斗结果回调

    self._onlyId = 0 -- 唯一Id

    self._updateFightEnable = false -- 是否刷新战斗
   	self._isNpcToNpc = false			-- 是否是NPC战斗
end

---
-- 获得唯一的Id
-- @author Tangjian
-- @time 2016/4/14 0014 22:05
function WordFightLayer:getOnlyid()
    self._onlyId = self._onlyId + 1
    return self._onlyId
end

-------------------------------------------------------------------------------------------------------------
-- 队伍
-- @author Tangjian
-- @time 2016/4/14 0014 21:17

---
-- 添加队伍
-- @params team为一个,Role对象组成的数组
-- @author Tangjian
-- @time 2016/4/14 0014 21:23
function WordFightLayer:initTeams(...)
    for index, teamRoles in ipairs({ ... }) do
        self:addTeam(index, teamRoles)
    end
end

---
-- 添加队伍
-- @params teamId:队伍Id;teamRoles:队角伍色
-- @author Tangjian
-- @time 2016/4/14 0014 21:27
function WordFightLayer:addTeam(teamId, teamRoles)
    assert(type(teamRoles) == "table" and #teamRoles > 0)

    local fightRoles = {}
    do -- 初始化所有Role, 创建FightRole
	    for i, role in ipairs(teamRoles) do
	    	if PRINT_MODE == 1 then
	    		print("添加角色:"..role.name.."到队伍"..tostring(teamId))
	    	end
	        local fightRole = self:createFightRole(role, teamId)

	        -- NPC自动回血
	        if fightRole.teamId ~= 1 and fightRole:getFlag("战斗脱离时间") ~= 0 then
	        	local qiMax = fightRole:getAttr("qiMax")
	        	local qi = fightRole:getAttr("qi")
	        	local neiliMax = fightRole:getAttr("neiliMax")
	        	local neili = fightRole:getAttr("neili")
	        	local useTime = GetTime() - fightRole:getFlag("战斗脱离时间")

	        	fightRole:setAttr("qi", math.min(qiMax,math.max(0.2,qi)+0.04*neiliMax+(useTime/2)*(18+0.018*neiliMax)))
	        	fightRole:setAttr("qiPercent", math.min(qiMax,math.max(0.2,qi)+0.04*neiliMax+(useTime/2)*(18+0.018*neiliMax))/qiMax)

	        	local currQi = fightRole:getAttr("qi")
				fightRole:setAttr("neili", math.min(neiliMax,neili+(useTime-2*(currQi-math.max(0.2,qi))/(18+0.018*neiliMax)*2)*(0.02*neiliMax+10)))
	        end
	        table.insert(fightRoles, fightRole)

	        -- 把队伍中的人添加到战斗角色列表中
	        self:addFightRole(fightRole, teamId)
	    end
    end

    -- 队伍
    local team =
    {
        id = teamId,
        roles = fightRoles
    }

    if self._fightRoles[1] then
    	if PRINT_MODE == 1 then
    		print("self._fightRoles[1] = "..self._fightRoles[1].name)
    	end
    end
    if self._fightRoles[2] then
    	if PRINT_MODE == 1 then
			print("self._fightRoles[2] = "..self._fightRoles[2].name)
		end
    end

    -- for k, fightRole in pairs(team.roles) do
    -- 	print(fightRole.role.name)
    -- end
    table.insert(self._teams, team) -- 添加队伍
end

-- 获得队伍
function WordFightLayer:getTeam(id)
	return self._teams[id]
end

-- 获得队伍中随机的角色
function WordFightLayer:getTeamRandRole(team)
	return team.roles[math.random(1, #team.roles)]
end

---
-- 获得队伍数目
-- @author Tangjian
-- @time 2016/4/14 0014 22:20
function WordFightLayer:getTeamCount()
    assert(type(self._teams) == "table")
    return #self._teams
end

-------------------------------------------------------------------------------------------------------------
-- 战斗角色
-- @author Tangjian
-- @time 2016/4/14 0014 21:45
local FIGHT_ROLE_STATE_READY = 1
local FIGHT_ROLE_STATE_PRE_SWING = 2
local FIGHT_ROLE_STATE_ATTACKING = 3
local FIGHT_ROLE_STATE_AFT_SWING = 4
local FIGHT_ROLE_STATE_DEAD = 5
function WordFightLayer:createFightRole(role, teamId)

	local fightParam = -- 战斗数据
	{
		teamId = teamId, -- 队伍

		state = FIGHT_ROLE_STATE_READY, -- 状态

		stateElapsedTime = 0, -- 当前经过时间
        -- preSwingDuration = math.random(0.5, 3), -- 前摇时间
        -- aftSwingDuration = math.random(0.5, 3), -- 后摇时间
	}

    -- return Helper:tableCover(role, fightParam)
    return Helper:tableCover(clone(role), fightParam)
end

---
-- 添加战斗角色
-- @author Tangjian
-- @time 2016/4/14 0014 22:02
function WordFightLayer:addFightRole(fightRole, roleId)
    assert(type(fightRole) == "table")

    -- 添加战斗角色
    table.insert(self._fightRoles, fightRole)
end

-- 设置角色状态
function WordFightLayer:fightRoleSetState(fightRole, state)
	if fightRole.state ~= state then
		fightRole.state = state
		-- 状态改变,stateElapsedTime设置为0
		fightRole.stateElapsedTime = 0
	end
end

-- -- 刷新战斗角色
-- function WordFightLayer:updateFightRole(fightRole, ft)
-- 	assert(fightRole)

-- 	-- print("刷新角色:"..fightRole.name)

-- 	-- 目标获取
-- 	local target = self:fightRoleGetTarget(fightRole)
-- 	-- print("targetName = "..target.name)

-- 	if fightRole.state == FIGHT_ROLE_STATE_READY then
-- 		-- 准备状态,选择招式
-- 		self:fightRoleSelectAttackSkill(fightRole)
-- 		self:fightRoleSelectAutoSkill(fightRole)
-- 		fightRole._Is_Attacked = false

-- 		-- self:updateLoading()
-- 		-- 改变状态到前摇
-- 		self:fightRoleSetState(fightRole, FIGHT_ROLE_STATE_PRE_SWING)
-- 	elseif fightRole.state == FIGHT_ROLE_STATE_PRE_SWING then
-- 		-- print("fightRole.state == FIGHT_ROLE_STATE_PRE_SWING")

-- 		-- 前摇时间
-- 		if fightRole.stateElapsedTime < fightRole.preSwingDuration then
-- 		else
-- 			-- 前摇结束,进入攻击状态
-- 			self:fightRoleSetState(fightRole, FIGHT_ROLE_STATE_ATTACKING)
-- 		end
-- 	elseif fightRole.state == FIGHT_ROLE_STATE_ATTACKING or not fightRole._Is_Attacked then
-- 		-- print("fightRole.state == FIGHT_ROLE_STATE_ATTACKING")

-- 		fightRole._Is_Attacked = true

-- 		-- 攻击
-- 		self:fightRoleAttack(fightRole, target)

-- 		-- 攻击结束,进入后摇状态
-- 		self:fightRoleSetState(fightRole, FIGHT_ROLE_STATE_AFT_SWING)
-- 	elseif fightRole.state == FIGHT_ROLE_STATE_AFT_SWING then
-- 		-- print("fightRole.state == FIGHT_ROLE_STATE_AFT_SWING")

-- 		-- 后摇时间
-- 		if fightRole.stateElapsedTime < fightRole.aftSwingDuration then
-- 		else
-- 			-- 后摇结束,进入前摇状态
-- 			self:fightRoleSetState(fightRole, FIGHT_ROLE_STATE_READY)
-- 		end
-- 	elseif fightRole.state == FIGHT_ROLE_STATE_DEAD then
-- 		-- print("fightRole.state == FIGHT_ROLE_STATE_DEAD")
-- 	end

-- 	-- 状态时间改变
-- 	fightRole.stateElapsedTime = fightRole.stateElapsedTime + ft
-- end


-- 刷新战斗角色
function WordFightLayer:updateFightRole(fightRole, ft)
	assert(fightRole)

	-- print("刷新角色:"..fightRole.name)

	-- 目标获取
	local target = self:fightRoleGetTarget(fightRole)
	-- print("targetName = "..target.name)
    local roleWeapon1 ,roleWeapon2 = fightRole:getCurrTypeByWeapon(), target:getCurrTypeByWeapon()
    Audio:wordFightPlayEffect(roleWeapon1, "start")
    Audio:wordFightPlayEffect(roleWeapon2, "start")


	if fightRole.state == FIGHT_ROLE_STATE_READY then
		-- 没有准备技能时 需要给玩家准备一个技能
		if not fightRole.attackSkill then
			self:fightRoleSelectAttackSkill(fightRole)
		end

		if not fightRole.autoSkill then
			self:fightRoleSelectAutoSkill(fightRole)
		end
		fightRole._Is_Attacked = false

		if fightRole:getFlag("先发制人") == true and not fightRole.Is_FastFight then
			fightRole.Is_FastFight = true
			fightRole.state = FIGHT_ROLE_STATE_ATTACKING
		end

		-- self:updateLoading()
		-- 改变状态到前摇
		self:fightRoleSetState(fightRole, FIGHT_ROLE_STATE_PRE_SWING)
	elseif fightRole.state == FIGHT_ROLE_STATE_PRE_SWING then
		-- print("fightRole.state == FIGHT_ROLE_STATE_PRE_SWING")

		-- 前摇时间
		if fightRole.stateElapsedTime < fightRole.preSwingDuration then
		else
			-- 前摇结束,进入攻击状态
			self:fightRoleSetState(fightRole, FIGHT_ROLE_STATE_ATTACKING)
		end
	elseif fightRole.state == FIGHT_ROLE_STATE_ATTACKING or not fightRole._Is_Attacked then
		-- print("fightRole.state == FIGHT_ROLE_STATE_ATTACKING")

		fightRole._Is_Attacked = true

        -- 左右互搏, 再打一次
        if fightRole.doubleAttackSkill then
            if PRINT_MODE == 1 then
                print("左右互搏攻击!!!!!!!!")
            end
            self:fightRoleAttack(fightRole, target, nil, nil, true)
            Audio:wordFightPlayEffect(roleWeapon1, "start")

            -- 判断能否打第二下
            if self._updateFightEnable then
                self:fightRoleAttack(fightRole, target, fightRole.doubleAttackSkill, fightRole.doubleAutoSkill, true, 0.3)
                Audio:wordFightPlayEffect(roleWeapon1, "start")
            end
        else
            -- 攻击
            self:fightRoleAttack(fightRole, target)
            Audio:wordFightPlayEffect(roleWeapon1, "start")
        end

		-- if target:getAttr("qi") > 0 then
			-- 攻击完成后，准备下一个技能
			self:fightRoleSelectAttackSkill(fightRole)
			self:fightRoleSelectAutoSkill(fightRole)
		-- end

		-- 攻击结束,进入后摇状态
		self:fightRoleSetState(fightRole, FIGHT_ROLE_STATE_AFT_SWING)
	elseif fightRole.state == FIGHT_ROLE_STATE_AFT_SWING then
		-- print("fightRole.state == FIGHT_ROLE_STATE_AFT_SWING")

		-- 后摇时间
		if fightRole.stateElapsedTime < fightRole.aftSwingDuration then
		else
			-- 后摇结束,进入前摇状态
			self:fightRoleSetState(fightRole, FIGHT_ROLE_STATE_READY)
		end
	elseif fightRole.state == FIGHT_ROLE_STATE_DEAD then
		-- print("fightRole.state == FIGHT_ROLE_STATE_DEAD")
	end

	-- 状态时间改变
	fightRole.stateElapsedTime = fightRole.stateElapsedTime + ft
end

-- 更新玩家状态
function WordFightLayer:fightRoleUpdateState(fightRole)
	fightRole.preSwingDuration = fightRole:getSwingDuration("begin", fightRole.autoSkill)

    -- 左右互搏, 前摇时间计算
    if fightRole.doubleAttackSkill then
        fightRole.preSwingDuration = (fightRole.preSwingDuration + fightRole:getSwingDuration("begin", fightRole.doubleAutoSkill)) / 2
    end

	-- 总时间间隔 = 上一个技能的后摇 + 当前技能的前摇
	if not fightRole.aftSwingDuration then
		fightRole.preSwingDuration = 1 + fightRole.preSwingDuration
		fightRole.totalSwingDuration = fightRole.preSwingDuration
	else
		fightRole.totalSwingDuration = fightRole.aftSwingDuration + fightRole.preSwingDuration
	end

	fightRole.aftSwingDuration = fightRole:getSwingDuration("after", fightRole.autoSkill)

    -- 左右互搏, 后摇时间计算
    if fightRole.doubleAttackSkill then
        fightRole.aftSwingDuration = (fightRole.aftSwingDuration + fightRole:getSwingDuration("after", fightRole.doubleAutoSkill)) / 2
    end

	-- fightRole.preSwingDuration = 0.1
	-- fightRole.aftSwingDuration = 0.1
	-- fightRole.totalSwingDuration = 0.2
	if fightRole.teamId == 1 then
		self.userTime = nil
	else
		self.npcTime = nil
	end
end

-- 获得目标
function WordFightLayer:fightRoleGetTarget(fightRole)
	local enemyTeam
	-- print("fightRole.teamId = "..fightRole.teamId)
	if fightRole.teamId == 1 then
		enemyTeam = self:getTeam(2)
	else
		enemyTeam = self:getTeam(1)
	end
	return self:getTeamRandRole(enemyTeam)
end

-- 选择进攻招式
function WordFightLayer:fightRoleSelectAttackSkill(fightRole)
    print("WordFightLayer:fightRoleSelectAttackSkill(fightRole)")
	fightRole.attackSkill, fightRole.doubleAttackSkill = fightRole:getPrepareAttackSkill()
end

-- 选择自动招式
function WordFightLayer:fightRoleSelectAutoSkill(fightRole)
	fightRole.autoSkill = fightRole.attackSkill:getRandomAttackZhao(fightRole)

    -- 左右互搏处理
    if fightRole.doubleAttackSkill then
        fightRole.doubleAutoSkill = fightRole.doubleAttackSkill:getRandomAttackZhao(fightRole)
    end

	self:fightRoleUpdateState(fightRole)
end

local function setStringColor(skill)
	if not skill then
		return ""
	end
	if skill.textColor == nil or skill.textColor == "" or skill.textColor == "默认" then
		skill.action = "WHT"..tostring(skill.action)
	else
		skill.action = skill.textColor..tostring(skill.action)
	end
end

-- 攻击目标
function WordFightLayer:fightRoleAttack(fightRole, target, attackSkill, autoSkill, isDoubleAttack, popNumDelay)
    local showNumDelayTime = 0 -- 数字动画延时
    local targetPreSwingDurationFactor = 1.25 -- 对方前摇时间系数
    local qiMaxAtkFactor = 1 -- 上限伤害系数
    local qiAtkFactor = 1 -- 气血伤害系数
    local jiaLiConsumeFactor = 1 -- 家里消耗内力系数
    if isDoubleAttack then
        targetPreSwingDurationFactor = math.sqrt(1.25)
        qiAtkFactor = 0.8
        qiMaxAtkFactor = 0.6
        jiaLiConsumeFactor = 0.5

        -- 左右互搏, 前期, 削弱
        local lv = fightRole:getLv()
        if lv < 60 then
            qiAtkFactor = 0.6
        elseif lv < 75 then
            qiAtkFactor = 0.65
        elseif lv < 80 then
            qiAtkFactor = 0.7
        elseif lv < 85 then
            qiAtkFactor = 0.75
        else
            qiAtkFactor = 0.8
        end
    end

    --是否为玩家自己
    local fightRoleName, targetName
	local player = User:getRole()

	if player.onlyId == fightRole.onlyId then
		fightRoleName = "你"
	else
		fightRoleName = fightRole:getName()
	end

	if player.onlyId == target.onlyId then
		targetName = "你"
	else
		targetName = target:getName()
	end

    -- 设置弹出数字延时
    if popNumDelay == nil then
        popNumDelay = 0
    else
        showNumDelayTime = popNumDelay
    end
    showNumDelayTime = popNumDelay

    attackSkill = Helper:getDef(attackSkill, fightRole.attackSkill)
    autoSkill = Helper:getDef(autoSkill, fightRole.autoSkill)

	-- local selfAttackSkill =
	local selfWeaponName = fightRole:getCurrWeaponName()
	local targetWeaponName = target:getCurrWeaponName()
	local selfAttackPositionPart = attackSkill:getRandomAttackPositionPart()
	local targetDodgeSkill = target:getPrepareDodgeSkill()
	local targetParrySkill = target:getPrepareParrySkill()

    local roleWeapon1 ,roleWeapon2 = fightRole:getCurrTypeByWeapon(), target:getCurrTypeByWeapon()

	local dodgeSkill = targetDodgeSkill:getRandomDodgeSkill(target)
	local parrySkill = targetParrySkill:getRandomParrySkill(target)
	if not dodgeSkill then
		dodgeSkill = Skill:getSkill("jibenqinggong"):getRandomDodgeSkill(target)
	end
	if not parrySkill then
		local skill = Skill:getSkill("jibenzhaojia")
		parrySkill = skill:getRandomParrySkill(target)
	end

	if not dodgeSkill or not parrySkill then
		assert(nil, "WordFightLayer:fightRoleAttack(fightRole, target) -> 数据异常")
	end


	local fightHitRate = fightRole:getHitRate()*(1+Helper:getDef(autoSkill.hitRate, 0))*(2/(1+3^((target:getExp()-fightRole:getExp())/(target:getExp()+fightRole:getExp()))))
	local targetDodge = target:getDodge()*(1+Helper:getDef(tonumber(autoSkill.dodge), 0))
	local targetParry = target:getParry()*(1+Helper:getDef(tonumber(autoSkill.parry), 0))

	local percent = math.random(1, 100)
	Audio:wordFightPlayEffect(roleWeapon1, "other")

	setStringColor(autoSkill)
	setStringColor(dodgeSkill)
	setStringColor(parrySkill)
	self.richPrint:pushBackNewLine(-25)
	self:printFightStatus(autoSkill.action, fightRole.name, target.name, selfWeaponName, targetWeaponName, selfAttackPositionPart)

	--------------------------------统计出手次数-------------------------
	-- fightRole.fightTimes = fightRole.fightTimes == nil and 1 or fightRole.fightTimes + 1
	BiWu:countFightDataMap(fightRole:getName(),"times",1)
-------------------------------------------------------------------------------------------------------------------
	-- 判断闪避
	if percent < math.floor(targetDodge/(targetDodge + fightHitRate)*100) then
   		Audio:wordFightPlayEffect(roleWeapon1, "miss")
		-- 闪避成功
		self:printFightStatus(dodgeSkill.action, fightRole.name, target.name, selfWeaponName, targetWeaponName, selfAttackPositionPart)
		-- self:outputText(target:getName().."闪避成功")
		fightRole.aftSwingDuration = fightRole.aftSwingDuration * 1.25
		self:refreshUI(fightRole, target)
		return

	-- 判断招架
	elseif percent < math.floor((targetDodge + targetParry)/(targetDodge + targetParry + fightHitRate)*100) then
		-- 招架成功
   		Audio:wordFightPlayEffect(roleWeapon2, "dodge")
  		self:printFightStatus(parrySkill.action, fightRole.name, target.name, selfWeaponName, targetWeaponName, selfAttackPositionPart)
        -- 对手前摇时间影响
  		target.preSwingDuration = target.preSwingDuration * targetPreSwingDurationFactor
  		fightRole.aftSwingDuration = fightRole.aftSwingDuration * 1.25
  		self:refreshUI(fightRole, target)
		-- self:outputText(target:getName().."招架成功")
		return
    end

	-- self:outputText("打中了")
	-- 击中对手
	local qiMaxAtk = fightRole:getQiMaxAtk(autoSkill, target, selfAttackPositionPart) * qiMaxAtkFactor
	local atk = fightRole:getQiAtk(autoSkill, target, selfAttackPositionPart) * qiAtkFactor
	atk = atk + qiMaxAtk

    -- 攻击力取整
    atk = math.floor(atk)

    if fightRole:getFlag("暗中下毒") == true and math.random(1,100) < 15 then
    	fightRole:setFlag( "暗中下毒" , false)
    	atk = 999999
    	PopText("暗中下毒")
    end

    if fightRole:getFlag("让你三招") > 0 then
    	fightRole:setFlag( "让你三招" , fightRole:getFlag("让你三招") - 1)
    	atk = 0
    	qiMaxAtk = 0
    	PopText("让你三招")
    end

    ----------步步高升，攻击力随着出手的次数增加而增加
    if fightRole:getFlag("步步高升") == true then
    	if fightRole.attackScaleFactor  == nil then
    		fightRole.attackScaleFactor  = 1.0
    	end
    	if type(fightRole.attackScaleFactor) == "number" and not Helper:isNan(fightRole.attackScaleFactor) then
	    	fightRole.attackScaleFactor = fightRole.attackScaleFactor + 0.05
	    	PopText("步步高升 伤害提高" .. tostring(math.floor( ( fightRole.attackScaleFactor ) * 100 ) ).. "%" )
	    end
    end
	----在比武阶段，给机器人加百分之十的攻击力 （只给机器人出手的时候加力）userType=[[robot_user]]

	-- qiMaxAtk = 0
	-- atk = 1

	-- print(target:getName())
	-- print(target:getAttr("qi"))

	Audio:wordFightPlayEffect(roleWeapon2, "attack")
	target:addAttr("qi", -atk)
	-- print(target:getAttr("qi"))
	local qiPercent = target:getAttr("qiPercent")
	if not qiPercent then
		qiPercent = 1
	end
	target:setAttr("qiPercent", (target:getAttr("qiMax")*qiPercent - qiMaxAtk)/target:getAttr("qiMax"))
    -- 对手前摇时间影响
	target.preSwingDuration = target.preSwingDuration * targetPreSwingDurationFactor

	self:showNum("HP", -atk, target, showNumDelayTime)
	if qiMaxAtk > 0 then
		local jiaLi = fightRole:getNumAttr("jiaLi") * jiaLiConsumeFactor
        jiaLi = math.floor(jiaLi)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 以逸待劳, 不消耗内力
        if fightRole.neiliCostScale ~= nil then
        		if type( fightRole.neiliCostScale ) == "number" and fightRole.neiliCostScale > -10 and fightRole.neiliCostScale < 10 then
        			fightRole:addAttr("neili", - (jiaLi * fightRole.neiliCostScale) )
        		else
        			fightRole.neiliCostScale = nil
        		end
        else
            fightRole:addAttr("neili", - jiaLi)
        end
		self:showNum("MP", -jiaLi, fightRole, showNumDelayTime)
		self:showLoadingBar("HPMax", target)
	end


	local dmgType = autoSkill.damageType
	local str = "WHT"..tostring(Skill:getAttactResultDesc(dmgType, atk))
	self:printFightStatus(str, fightRole.name, target.name, selfWeaponName, targetWeaponName, selfAttackPositionPart)
	self:outputText("HIR造成了HIW"..atk.."HIR点伤害。")
	self:refreshUI(fightRole, target)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 九转大还
    if target.qi <= 0 then
        if target:getFlag("九转大还") == true then
            target:setFlag("九转大还", false)
            target.qi = target.qiMax * 0.3
            target.qiPercent = 1
            self:showLoadingBar("HPMax", target)
            PopText("RED九转大还!!")
        end
    end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 垂死挣扎
    if target.qi <= 0 then
        if target:getFlag("垂死挣扎") == true then
            target:setFlag("垂死挣扎", false)
            target.qi = 1

            self:roleAttackTarget(target, fightRole)

            self:delayFunc(0.1,function()
		        if fightRole.qi > 0 then
            		self:roleAttackTarget(target, fightRole)
		        end
            	end)

            self:delayFunc(0.2,function()
		        if fightRole.qi > 0 then
	        		self:roleAttackTarget(target, fightRole)
		        end
            	end)

            PopText("垂死挣扎")
        end
    end

    if target.qi <= 0 then
    	if target:getFlag("饮鸩止渴") == true then
    		target:setAttr("qiPercent",  1/target:getAttr("qiMax") )
    		target:setAttr("qi",1)
    		PopText("饮鸩止渴")
    	end
    end

    -- 判断是否战败
	if target.qi > 0 then
		self:printFightStatus("（"..target:getName()..target:getFightQiDesc().."NOR）", fightRole.name, target.name)
		-- self:outputText(fightRole.name.."对"..target.name.."".."造成了 "..atk.." 点伤害")
		-- self:printFightStatus(autoSkill.action, fightRole.name, target.name, selfWeaponName, selfAttackPositionPart)
	else
		-- 做一些数据记录
		local function saveAttr()
			-- 杀死人数
			fightRole:addAttr("kill", 1)

			-- 侠义正气
			local rZhengQi = fightRole:getFinalAttr("zhengqi")
			local tZhengQi = target:getFinalAttr("zhengqi")

			fightRole:setAttr("zhengqi", tonumber(rZhengQi - tZhengQi))

            -- 记录对方死法
            print("attackSkill.name = "..tostring(attackSkill.name))
            target:setAttr("killedBySkillName", attackSkill.name)
		end

		local endStr = ""
		str = ""
		-- 经验及正气值影响文字颜色
		if target.exp > fightRole.exp then
			if target.zhengqi < -10000 then
				str = ""
			else
				str = "HIY"
			end
		else
			if target.zhengqi < -10000 then
				str = "HIW"
			else
				str = "RED"
			end
		end

		if fightRole.teamId == 1 then
			self.Panel_9.Text_52:setString("胜利！")
			if self.From_Type == "切磋" then
				str = str.. fightRoleName .. "哈哈哈大笑三声，抱拳说道：承让！"
				endStr = endStr.. fightRoleName .. "打败了".. targetName
			else

				str = str.. targetName .."「啪」的一声倒在地上，嘴角溢出几丝鲜血，痛苦的挣扎了几下就死了。"
				endStr = endStr.. targetName .."被" .. fightRoleName

				saveAttr()
				end
		else
			self.Panel_9.Text_52:setString("失败！")
			if self.From_Type == "切磋" then

				str = str.. fightRoleName .."哈哈哈大笑三声，抱拳说道：承让！"
				endStr = endStr.. targetName .. "败给了".. fightRoleName
			else

				str = str.. targetName .. "眼前一黑，然后什么都不知道了！"
				endStr = endStr.. targetName .. "被".. fightRoleName

				-- 死亡次数
				target:addAttr("dead", 1)
				target:setAttr("deadReason", fightRole:getName())
			end
		end

		if self.From_Type == "杀死" then
			if dmgType == "擦伤" or dmgType == "割伤" then
				endStr = endStr.."砍倒了。"
			elseif dmgType == "刺伤" then
				endStr = endStr.."刺倒了。"
			elseif dmgType == "瘀伤" then
				endStr = endStr.."击倒了。"
			elseif dmgType == "内伤" then
				endStr = endStr.."震倒了。"
			else
				endStr = endStr.."打败了。"
			end
		else
			target:setAttr("qi", math.max(1, target:getAttr("qi")))
			target:setAttr("qiMax", math.max(1, target:getAttr("qiMax")))
			-- target:setAttr("qiMax", 1)
		end

		--endStr = string.gsub(endStr, User:getRoleAttr("name"), "你")

		--[[
			判断文本中是否有 "你" 字,有则代表存在玩家
			位置等于1时代表左边的是玩家
			位置在文本中间代表右边的是玩家
		]]
		local function getStr(winTeamId, fightRoleName, targetName)
			local str2 = ""
			if winTeamId == 1 and fightRoleName == "你" then
				str2 = "胜利！"
			elseif winTeamId == 1 and targetName == "你" then
				str2 = "失败！"
			elseif winTeamId == 2 and fightRoleName == "你" then
				str2 = "失败！"
			elseif winTeamId == 2 and targetName == "你" then
				str2 = "胜利！"
			else
				str2 = "结束！"
			end
			-- if string.find(endStr, "你") == nil then
			-- 	str2 = "结束！"
			-- elseif string.find(endStr, "你") == 1 and winTeamId == 1 then
			-- 	str2 = "胜利！"
			-- elseif string.find(endStr, "你") == 1 and winTeamId == 2 then
			-- 	str2 = "失败！"
			-- elseif string.find(endStr, "你") > 2 and winTeamId == 1 then
			-- 	str2 = "失败！"
			-- elseif string.find(endStr, "你") > 2 and winTeamId == 2 then
			-- 	str2 = "胜利！"
			-- else
			-- 	str2 = "结束！"
			-- end
			return str2
		end



		self.Panel_9.Text_desc:setString(endStr)
		target.Is_Lose = true

		self:outputText(str)

		-- self:outputText("战斗结束,"..fightRole.name.."战胜了"..target.name)
		self:endFight(fightRole.teamId)
	end

	-- -- 被打
	-- self:fightRoleHurt(target, fightRole)
end

-- 被打中
function WordFightLayer:fightRoleHurt(fightRole, target)
	if fightRole.qi <= 0 then

	end
end

-- 死亡
function WordFightLayer:fightRoleDead(fightRole)
	-- fightRole
end

-------------------------------------------------------------------------------------------------------------
-- 战斗
-- @author Tangjian
-- @time 2016/4/14 0014 21:32

---
-- 更新所有角色逻辑
-- @author Tangjian
-- @time 2016/4/14 0014 22:15
function WordFightLayer:updateAllFightRole(ft)
	if self._updateFightEnable then
    	for i, fightRole in ipairs(self._fightRoles) do
    		-- 刷新战斗角色
    		self:updateFightRole(fightRole, ft)
    		self:updateLoading(fightRole)
    	end
    end
end

---
-- 角色选择目标
-- @author Tangjian
-- @time 2016/4/14 0014 21:34
function WordFightLayer:roleSelectTarget(fightRole, teams)
end

---
-- 角色进攻目标
-- @author Tangjian
-- @time 2016/4/14 0014 21:35
function WordFightLayer:roleAttackTarget(fightRole, target)
    -- 左右互搏, 再打一次
    if fightRole.doubleAttackSkill then
        if PRINT_MODE == 1 then
            print("左右互搏攻击!!!!!!!!")
        end
        self:fightRoleAttack(fightRole, target, nil, nil, true)
        Audio:wordFightPlayEffect(roleWeapon1, "start")

        -- 判断能否打第二下
        if self._updateFightEnable then
            self:fightRoleAttack(fightRole, target, fightRole.doubleAttackSkill, fightRole.doubleAutoSkill, true, 0.3)
            Audio:wordFightPlayEffect(roleWeapon1, "start")
        end
    else
        -- 攻击
        self:fightRoleAttack(fightRole, target)
        Audio:wordFightPlayEffect(roleWeapon1, "start")
    end
end

Helper:classDefNodeGetInstance(WordFightLayer)
return WordFightLayer
000000000000000
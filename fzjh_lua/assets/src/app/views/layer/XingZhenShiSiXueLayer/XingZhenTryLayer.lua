local XingZhenTryLayer = class("XingZhenTryLayer", cc.Layer)
local XingZhen = require("app.models.XingZhenEffects.XingZhenEffects")

function XingZhenTryLayer:create()
	local p = XingZhenTryLayer:new()
	p:init()
	return p
end

function XingZhenTryLayer:init()
	self._UI = require("Layer/DialogDodge.lua").create()['root']
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
end
local npcZhenFaXueweiKeys = {}
local npcZhenFaXueweiValues = {}
local effects = {}
-- function XingZhenTryLayer:showLayer(id,npcXuewei,npcZhenFa, npcEffect, skill, afterCallback)
function XingZhenTryLayer:showLayer(npcXuewei,npcZhenFa, npcEffect,allXueWei,afterCallback)
	self.allXueWei = allXueWei --在列表界面显示出来的穴位
	self.updateListCallback = afterCallback

	self.failedTime = 0
	self.npcEffect = npcEffect
	for k,v in pairs(npcZhenFa) do
		local values = string.split(v.xuewei, ";")
		table.insert(npcZhenFaXueweiValues, values)--每套zhenfa的xuewei

		table.insert(npcZhenFaXueweiKeys, k)
	end

    self.npcXuewei = npcXuewei

	local role = User:getRole()
	local skillLv = role:getSkillLv("zouxueshisijing")--走穴十四经的等级
	local npcDatas = require("script.others.zouxuejing")
    local npcList = npcDatas.list
	local num = 0
	local list
	if skillLv <= 600 and skillLv >= 500 then
		num = 6
		list = npcList.list1
	elseif skillLv <= 800 and skillLv >= 601 then
		num = 7
		list = npcList.list2
	else
		num = 8
		list = npcList.list3
	end

	self.num = num

	-- self.xueweiDatas = {}
	self.curList = string.split(list.xuewei, ";")
	self.testXueweiDatas = {}

	self.currNumIndex = 1

	--点击停针的时候，返回列表界面
	self.Button_Practice:setVisible(true)
	self.Button_Practice:releaseFunc(function()
		self:hide()
		self:stopTime()
		local role = User:getRole()
		local count = role:getDayFlag("停针次数")
		count = count + 1
		if count >= 6 then
			role:setDayFlag("停针次数", 0)
			--停针设置CD时间10分钟
			local stopTimeCD = 600 + GetTime()
			XingZhen:setXingZhen("停针10分钟CD",stopTimeCD)
			PopText("不知不觉间你在身上试了许多针，如继续试针可能会有危险，休息一段时间吧。")	
		else
			role:setDayFlag("停针次数",count)
			PopupLayerController:showLayer("XingZhenLayer",function(layer)
				layer:showLayer()
				PopText("你停止了试针！")
			end)
		end
	end)
	self.Text_text_1:setString("试针")
	self.Text_text:setString("你屏气凝神，手上捻着银针，脑子回忆着走穴十四经里所载的经络知识，刺入——")
	self.LoadingBar:setVisible(false)

	self:initUI()

	self:show()

end

function XingZhenTryLayer:initUI()
	self:setTime(15)
	self:showButton()
end

--界面的处理
function XingZhenTryLayer:showButton()

	self.LoadingBar:setVisible(true)

	local xueweiIds = self:getXueweiIds()--获取到的当前的穴位
	local downText = self.Button_Down:getChildByName("Text_name")
	local upText = self.Button_Up:getChildByName("Text_name")
	local leftText = self.Button_Left:getChildByName("Text_name")
	local rightText = self.Button_Right:getChildByName("Text_name")

	-- print(",............downText.......",self.npcXuewei[xueweiIds[1]].name..",xueweiIds[1]:"..xueweiIds[1])
	-- print(".............upText.........",self.npcXuewei[xueweiIds[2]].name..",xueweiIds[2]:"..xueweiIds[2])
	-- print(".............leftText.......",self.npcXuewei[xueweiIds[3]].name..",xueweiIds[3]:"..xueweiIds[3])
	-- print(".............rightText......",self.npcXuewei[xueweiIds[4]].name..",xueweiIds[4]:"..xueweiIds[4])

	downText:setString(self.npcXuewei[xueweiIds[1]].name)
	upText:setString(self.npcXuewei[xueweiIds[2]].name)
	leftText:setString(self.npcXuewei[xueweiIds[3]].name)
	rightText:setString(self.npcXuewei[xueweiIds[4]].name)
 
 	--点击按钮的时候把当前的穴位传过去
	self.Button_Down:releaseFunc(
		function()
			self:directionButtonPress( 1 , xueweiIds)
		end)

	self.Button_Up:releaseFunc(
		function()
			self:directionButtonPress( 2  , xueweiIds)
		end)

	self.Button_Left:releaseFunc(
		function()
			self:directionButtonPress( 3  , xueweiIds)
		end)

	self.Button_Right:releaseFunc(
		function()
			self:directionButtonPress( 4 , xueweiIds)			
		end)

	self:buttomAction()
	self:delayFunc(0, function()
		local offset = cc.p( 0 , display.height*2/3 - display.height/2 )
		-- self.Text_text:runAction( YXEaseAction:create( cc.MoveBy:create( 0.25 , offset ) , Sine_EaseInOut )  )
		self:delayFunc(0.5, function()
			
	 		self.scheduleHandle = self:schedule( function(ft)
				self:update(ft)
			end, 30/1000 )	
		end)
	end)
end


function XingZhenTryLayer:setTime( time )
	self.totalTicks = time * 1000 / 30
	self.ticksRemain = self.totalTicks

	self.LoadingBar:setPercent( 100 )
	
	--self:showButtons()

	self.timeCounting = true
end

function XingZhenTryLayer:stopTime()
	if self.scheduleHandle then
		self:unschedule( self.scheduleHandle )
		self.scheduleHandle = nil
	end

	self.timeCounting = false
end
--进度条
function XingZhenTryLayer:update()
	--在规定的时间还没点击
	if self.timeCounting == true then
		self.ticksRemain = self.ticksRemain - 1
		self.LoadingBar:setPercent( self.ticksRemain * 100 / self.totalTicks )

		if self.ticksRemain <= 0 then
			self.LoadingBar:setVisible( false )
			self:showFailed()
		end
	end
end

--按钮动画
function XingZhenTryLayer:buttomAction()
	if self.timeCounting then
		self.Button_Down:setPosition(540.0, 325.0 - 200)
		self.Button_Down:setOpacity( 0 )
		self.Button_Up:setPosition(540.0, 577.0897-200)
		self.Button_Up:setOpacity( 0 )
		self.Button_Left:setPosition(535.0-200, 451.0)
		self.Button_Left:setOpacity( 0 )
		self.Button_Right:setPosition(545.0+200, 451.0)
		self.Button_Right:setOpacity( 0 )

		self.Button_Down:setVisible( true )
		self.Button_Up:setVisible( true )
		self.Button_Left:setVisible( true )
		self.Button_Right:setVisible( true )

		local animDuration = 0.5
		self.Button_Down:runAction(  
				YXEaseAction:create( cc.Spawn:create(
							cc.MoveTo:create(animDuration, cc.p( 540.0000 , 320) ) ,
							cc.FadeIn:create(animDuration)
						),  Sine_EaseOut ) )		 		

		self.Button_Up:runAction(  
				YXEaseAction:create(
					cc.Spawn:create(
							cc.MoveTo:create(animDuration, cc.p( 540.0000 , 577) ) ,
							cc.FadeIn:create(animDuration)
						),  Sine_EaseOut ) )		 		

		self.Button_Left:runAction(  
				YXEaseAction:create( cc.Spawn:create(
							cc.MoveTo:create(animDuration, cc.p( 535.0000 , 451) ) ,
							cc.FadeIn:create(animDuration)
						),  Sine_EaseOut ) )		 		

		self.Button_Right:runAction(  
				YXEaseAction:create( cc.Spawn:create(
							cc.MoveTo:create(animDuration, cc.p( 545.0000 , 451) ) ,
							cc.FadeIn:create(animDuration)
						),  Sine_EaseOut ) )
	else
	end		 		
end

--点击按钮
function XingZhenTryLayer:directionButtonPress(direction, xueweiIds)
	self:showDodgeSuccessfull( direction, xueweiIds )
end

function XingZhenTryLayer:showDodgeSuccessfull( direction, xueweiIds)
	local xueweiId = xueweiIds[direction]
	table.insert(self.testXueweiDatas, xueweiId)
	--插对的效果
	-- local rightEffect = self.npcXuewei[xueweiId].righteffect
	-- --插错的效果
	-- local wrongEffect = self.npcXuewei[xueweiId].wrongeffect
	-- --概率
	-- -- local badrate = self.zhenfaData.badrate
	-- local randomNum = math.random(1, 100)

	-- table.insert(effects, rightEffect)
	-- if badrate == nil then
	-- else
	-- 	if randomNum <= badrate then
	-- 		table.insert(effects, wrongEffect)
	-- 	end
	-- end

	self.Text_xuewei:setVisible(true)
	self.Text_xuewei:setString(self.npcXuewei[xueweiId].name)
	self.Button_Down:setTouchEnabled( false )
	self.Button_Up:setTouchEnabled( false )
	self.Button_Left:setTouchEnabled( false )
	self.Button_Right:setTouchEnabled( false )

	self:stopTime()
	self:delayFunc(0.7, function()
		self:goOn()
		--试针点击穴位文本循环
		local shiTryList = {"你感到神清气爽，捻针准备继续行针，痛快的将针刺入了——",
						"你感到无比寒冷，仿佛置身与冰窟之中，但依然冷静地继续行针，这一针应该刺入——",
						"你眼前一黑，一阵晕厥，差点昏死过去。稍事休息后已经清醒过来，你决定将下一针刺入——", 
						"你感觉有不尽的力量在身体中流动，兴奋之余你还想继续行针，颤抖的将针刺入——",
						"行针至此，你突然觉得胸口发闷，呼吸困难。就在快要倒下时，竭尽所剩不多的力气将针精准的刺入了——",
					    "你感到一阵清凉席卷全身，好像浑身病痛都被带走了。你期待着什么一般，迫不及待地将下一针刺入了——"}
		self.Text_text:setString(shiTryList[math.random(1,#shiTryList)])	

		self.Text_xuewei:setVisible(false)
		self.Button_Down:setTouchEnabled( true )
		self.Button_Up:setTouchEnabled( true )
		self.Button_Left:setTouchEnabled( true )
		self.Button_Right:setTouchEnabled( true )
	end)
end

--进度条走完没点击，默认失败
function XingZhenTryLayer:showFailed()
	self.failedTime = self.failedTime + 1
	self:stopTime()
	if self.failedTime >= 3 then
		self:goOver(false)
	else
		--试针没有点击穴位
		local TextTryList = {"你脑中有些混乱，竟一时犹豫无法下针，待稍事休息重新平静后，小心翼翼地将针刺入——",
							"不知为何，你握着针的手就是不听使唤。犹豫了许久后，你摇了摇头决定继续行针，这一针刺入了——",
							"你胸有成竹，知道此时不该下针，于是闭目养神，静修片刻后待时机成熟，准确的将针刺入——"}
		self.Text_text:setString(TextTryList[math.random(1,#TextTryList)])
		self:goOn()
	end
end

--小游戏结束
function XingZhenTryLayer:goOver(succ)
	-- DataBase:setLuaTable("xingzhenzouxueEffects", effects) 

	local role = User:getRole()

	self:hide()
	if self.afterCallback then
		self.afterCallback()
	end

	--点击了穴位,散装的效果
	if succ then
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:show("试针次数已用完")
		dialog:setButton1("行针", function() --处理散装针效果    
			--要传散装针的效果
			self:sanZhenReward(self.testXueweiDatas)
		end)
		dialog:setButton2("放弃", function()
			dialog:hide()
			--试针失败设置CD时间2分钟
			local failedTimeCD = 1800 + GetTime()
			XingZhen:setXingZhen("行针失败2分钟CD",failedTimeCD)
		end)
		dialog:setBack(false)
	else --3次没有点击 失败退出到最初的界面
		local failedTimeCD = 1800 + GetTime()
		XingZhen:setXingZhen("行针失败2分钟CD",failedTimeCD)
		PopText("你拿着针犹豫不决迟迟无法下手，已经错过了下针时机。")
	end
end

--散装针的效果 结算界面
function XingZhenTryLayer:sanZhenReward(testXueweiDatas)
	--testXueweiDatas所有点击的穴位 如：xuewei10,xuewei3,xuewei12,xuewei7
	local effectDatas = {}
	local role = User:getRole()
	for i,v in pairs(testXueweiDatas) do
		--每个穴位对应的信息	
		local typeList = self.npcXuewei[v]
		self.xueWeiData = typeList
		if MapIsEmpty(self.xueWeiData) then
			return
		end	
		
		XingZhen:insertRandomEffects(self.xueWeiData.testeffect,effectDatas)
	end
	 
	local function sameAdd(t)
	    local n = {}
	    local values = {}
		for i ,v in ipairs(t) do
			--每个穴位对应的信息
			local effectData = self.npcEffect[v]
			table.insert( n,v)
			table.insert(values,effectData.value)
		end

	    return n,values
	end

	local tmpeffectDatas = sameAdd(effectDatas)
	local effectsCD = {}
	for k,v in pairs(tmpeffectDatas) do
		local effectData = self.npcEffect[v] --拿到效果的一条数据
		local time = effectData.time + GetTime() --修改当前的CD时间
		
		table.insert(effectsCD, {before = effectData.time, after = time, effectId = v})
	end
	XingZhen:setXingZhen("行针走穴EffectsCD",effectsCD)
	-- role:setFlag("行针走穴Effects", {effects = effects, badeffects = self.badffects}) 
	XingZhen:setXingZhen("行针走穴Effects",tmpeffectDatas)
	
	--testXueweiDatas走过的穴位 tmpeffectDatas穴位的效果
	PopupLayerController:showLayer("XingZhenRewardLayer",function(layer)
	    layer:showLayer(testXueweiDatas,1,function()

	    	local npcDatas = require("script.others.zouxuejing")
	  --   	table.sort(tmpeffectDatas, function(a, b) 
			-- 	local time1 = npcDatas.effect[a].time
			-- 	local time2 = npcDatas.effect[b].time
			-- 	return time1 < time2
			-- end)
			
			-- local xueweiTime = tmpeffectDatas[#tmpeffectDatas]
			-- local longTime = npcDatas.effect[xueweiTime].time
			local longTime = 21600
			local longTimeCD = longTime + GetTime()
	    	--可能需要做标记散针效果CD的时间
	    	XingZhen:setXingZhen("散针的效果CD",longTimeCD)
	    	--散针的穴位的效果
	    	XingZhen:setXingZhen("散针的效果",testXueweiDatas)

			--散装增加经验 获取最长的时间除以18小时
			local skillLv = role:getSkillLv("zouxueshisijing")
			local exp = role:getSkillExp("zouxueshisijing") * (0.09 + role:getFinalAttr("currInt")/8000)*(longTime/64800)
			if skillLv >= 1 and skillLv < 500 then
				exp = (role:getSkillExp("zouxueshisijing") * (0.05 + role:getFinalAttr("currInt")/8000) + 10000)*(longTime/64800)
			elseif skillLv >= 500 and skillLv < 800 then
				exp = role:getSkillExp("zouxueshisijing") * (0.01 + role:getFinalAttr("currInt")/9000)*(longTime/64800)
			else
				exp = role:getSkillExp("zouxueshisijing") * (0.006 + role:getFinalAttr("currInt")/12000)*(longTime/64800)
			end
			role:addSkillExp("zouxueshisijing", exp)

			--提交行针效果
			XingZhen:submitXingZhenEffects(role)
			PopText("行针成功!")
		end)
	end)
end

--通针
function XingZhenTryLayer:tongZhen(func)
	local role = User:getRole()
	local matchIndex = -1
	local num = #self.testXueweiDatas

	local isSeriesArray = function(array)--是连续整数
		table.sort(array)
		local len = #array
		local num = array[len] - array[1]
		return num == (len - 1)
	end
	local isZhenFaNotExisit = function(matchIndex)
		local zhenfa = npcZhenFaXueweiKeys[matchIndex]
		local notsame = 1
		for i,v in pairs(self.allXueWei) do
			--判断当前通针的针法，是否在列表上
			if zhenfa == v then
				--当前的针法和已经存在的针法，重合
				notsame = 0
				break
			end
		end
		return notsame
	end
	--index是表示，针法列表对应的第几个，比如4就是说第四个针法
	for index, xueweiValue in pairs(npcZhenFaXueweiValues) do
		local match = true 
		local order = {}
		-- if num == #xueweiValue then --个数一样
		for k, v in pairs(xueweiValue) do 
			local found = false
			for tk, tv in pairs(self.testXueweiDatas) do
				if v == tv then
					found = true
					table.insert(order, tk)--存储对应的数组下标号，用于判断是否连续
					break
				end
			end

			if not found then 
				match = false
				break
			end
		end
		-- else
		-- 	match = false
		-- end

		if match and isSeriesArray(order) and isZhenFaNotExisit(index) == 1 then
			matchIndex = index
			break
		end
	end
	-- matchIndex = 12
	if matchIndex > 0 then --通针，记录是否第一次通针，否则跳过则重新初始化界面数据
		local zhenfa = npcZhenFaXueweiKeys[matchIndex]--保存zhenfa
		-- local zhenfaName = self.npcZhenFa[zhenfa]
		--通针成功 弹框 判断是否是第一次通这个针法
		local notsame = 1
		for i,v in pairs(self.allXueWei) do
			--判断当前通针的针法，是否在列表上
			if zhenfa == v then
				--当前的针法和已经存在的针法，重合
				notsame = 0
				break
			end
			-- return notsame
		end
		if notsame == 1 then
			PopupLayerController:showLayer("ShiZhenTextLayer",function(layer)
			    layer:showLayer(notsame,zhenfa, function(data)
			    	if func then
						func(data)
					end
			    end)
			end)
		else
			if func then
				func(1)
			end
		end
	else
		if func then
			func(1)
		end
	end
end

--继续游戏
function XingZhenTryLayer:goOn()
	self:tongZhen(function(data)
		if data == 1 then
			--num总的次数 currNumIndex试针的次数
			self.currNumIndex = self.currNumIndex + 1
			if self.currNumIndex > self.num then
				self:goOver(true)
			else
				self:initUI()
			end
		else
			self:hide()
		end
	end)
end

--获取随机穴位
function XingZhenTryLayer:getXueweiIds()

	local currNumIndex = self.currNumIndex
	local count = 4
	local buttonIndexs = {}
	-- local index = math.random(1,  4)
	local tmpInitIndex = 1

	-- buttonIndexs[index] = self.xueweiDatas[currNumIndex]
	-- self.correctDirection = index

	local num = #self.curList
	while count > 0 do
		local buttonIndex = math.random(1,  num)
		local xueweiId = self.curList[buttonIndex]
		local isFound = false
		for k,tmpId in pairs(buttonIndexs) do
			if xueweiId == tmpId then
				isFound = true
				break
			end
		end
		for k,tmpId in pairs(self.testXueweiDatas) do--已经试过的针
			if xueweiId == tmpId then
				isFound = true
				break
			end
		end
		
		if not isFound then
			buttonIndexs[tmpInitIndex] = xueweiId
			tmpInitIndex = tmpInitIndex + 1
			count = count - 1
		end
	end

	return buttonIndexs
end

Helper:classDefNodeGetInstance(XingZhenTryLayer)

return XingZhenTryLayer0
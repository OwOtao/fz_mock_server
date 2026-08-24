local NewDialogDodgeLayer = class("NewDialogDodgeLayer", require("app.views.base.BaseLayer"))


function NewDialogDodgeLayer:createInRunningScene()

	local layer = NewDialogDodgeLayer:getInstance()

	return layer

	-- local layer = nil
	-- local runningScene = cc.Director:getInstance():getRunningScene()
	-- if runningScene then
	--     layer = DialogDodgeLayer:create()
	--     -- 添加到当前scene
	--     runningScene:addChild(layer)

	--     -- 设置为置顶
	--     layer:setGlobalZOrder(1)
	--     layer:maxZ()
	--     -- 显示
	--     --layer:show()


	--     layer:reinit()
	-- end
	-- return layer
	--end
end

function NewDialogDodgeLayer:create()
	local p = NewDialogDodgeLayer:new()
	p:init()
	return p
end

function NewDialogDodgeLayer:init()
	self.UI = require("Layer/DialogDodge.lua").create()['root']
	self.UI:addTo(self)
	--Helper:convertUI(self) -- 获得所有子节点
	Helper:convertUIByParent(self)
end

function NewDialogDodgeLayer:reinit()

	--阶段0 显示文本
	--阶段1 文本移到上方弹出文字，弹出进度条和按钮
	--阶段3 失败

	--阶段4  成功躲避
	self.status = 0
	self.attackerName = "蒙面人"
	self.anqiName = "飞镖"
	self.damagePercent = 0.1
	self.succResult = nil
	self.failedResult = nil
	self.resultCallback = nil
	self.correctDirectionIndex = 0 -- 固定的成功方向索引，非0时生效，有效值1-4

	-- 初始化文本
	-- 动作文本
	self.dodgeTextList =
	{
		["up"] = { "你身形陡然纵起，凌空一跃。" , "你身体向上笔直纵身，跃起数丈。" } ,
		["down"] = { "你足跟一支，全身后仰。" , "你飘然向下一闪，身体贴向地面。" } ,
		["left"] = { "你身体晃动，向左一偏。" , "你身随意转，向左一闪。" } ,
		["right"] = { "你向右，侧身一摆。" , "你足不点地，向右窜开。" } ,
		["still"] = { "你停留在原地，什么也没做！" , "你尚未回过神来！" }
	}

	-- 受伤文本
	self.hurtTextList =
	{
		"你虽然反应极快，但$w还是擦伤了你，你受到了$z点伤害",
		"$w来势甚猛，你躲闪不及，受到了$z点伤害",
		"你一个躲避不及，还是被$w所击中，受到了$z点伤害",
		"你身法虽快，却未快过这$w，你受到了$z点伤害",
		"$w打中了你造成了$z点伤害，你痛苦不堪"
	}

	-- 成功文本
	self.succTextList =
	{
		"十分轻松地躲过了暗器！",
		"犹如鬼魅一般，十分利索地躲过了暗器！",
		"暗器擦着你的身体而过，你并没受到伤害！",
		"电光火石之间躲过了暗器的攻击",
		"暗器已然落空！"
	}


	-- 发射文本
	self.fireTextsList =
	{
		[[$N单手一翻，$w散射而出，击向你的$d。]] ,
		[[$N向你的$d发射了一枚$w，快闪开！]] ,
		[[$N一个转身，$w飞快地向你的$d射来，快躲开！]] ,
		[[$N飞身而起，双手如散花般发射了数枚$w,暗器以极快的速度向你的$d袭来！]] ,
		[[$N手中$w激射而出，向你的$r飞来，只听“叮”地一声，暗器在空中突然转向，向你的$d射来！原来是$N再发一枚暗器，将先前暗器方向打偏！]] ,
		[[$N单手一翻，$w散射而出，快往$D！]] ,
		[[$N一个转身，$w飞快地向你射来，快$D！]] ,
		[[$N向你的头部发射了一枚$w，快$R！暗器飞至一半，却不知为何转向向你的$d打来！]],
		[[快$D！$N飞快地向你射出了数枚暗器！]] ,
		[[$N向你射出了数枚$w！快$R！不对不对！应该是$D]] ,


		[[$N腾空而起，手中$w飞速打向你的$d！]] ,
		[[$N眼中冷芒闪过，手中的$w已无踪迹，再看时，暗器已经离你$d半步之遥！]] ,
		[[$N微微一笑，$w脱手而出，只刹那便至$d！快闪开！]] ,
		[[$N凌空一掷！手中$w已经朝你的$r飞来，眼看就快靠近，暗器突地一转，打向你的$d！]] ,
		[[快闪开！$N手指弹出数枚$w,极快打向你的$r！不好！暗器在空中方向突变，打向了你的$d！]] ,
		[[$N腾空而起，手中$w飞速打向你，快$D！]] ,
		[[$N眼中冷芒闪过，手中的$w已无踪迹，再看时，暗器已经离你$d半步之遥！快$D！]] ,
		[[快$D！暗器已朝你飞速射来，只见$N冷笑一声，暗器竟然偏离方向朝你的$d射来！]]
	}

	-- 方向 发射方向 正确方向
	self.directionToFireTextList = { "下身" , "头部", "右侧" , "左侧" }
	self.directionToDodgeTextList = { "上跳" , "下蹲" , "左闪" , "右闪" }

	self.btnNameList = { "跳起" , "下蹲" , "左闪" , "右闪" }


	self:hideButtons()
	self:hide()
end

function NewDialogDodgeLayer:isAvail( )
	if self.status == nil then
		self.status = 0
	end

	if self.status >= 1 and self.status < 3 then
		return false
	else
		return true
	end
end

function NewDialogDodgeLayer:setAttackerName( attackerName )
	self.attackerName = attackerName
end

function NewDialogDodgeLayer:setAnqiName( anqiName )
	self.anqiName = anqiName
end

function NewDialogDodgeLayer:setDamagePercent( damagePercent )
	self.damagePercent = damagePercent
end

function NewDialogDodgeLayer:setSuccResult( succResult )
	self.succResult = succResult
end

function NewDialogDodgeLayer:setFailedResult( failedResult )
	self.failedResult = failedResult
end

function NewDialogDodgeLayer:setResultCallback( resultCallback )
	self.resultCallback = resultCallback
end

-- 躲避文本 dodgeTexts
function NewDialogDodgeLayer:setDodgeTexts( textList )
	self.dodgeTextList = textList
end

-- 成功躲避动作文本 succTexts
function NewDialogDodgeLayer:setSuccTexts( textList )
	self.succTextList = textList
end

-- 失败伤害文本 hurtTexts
function NewDialogDodgeLayer:setHurtTexts( textList )
	self.hurtTextList = textList
end

-- 发射暗器文本 FireTexts
function NewDialogDodgeLayer:setFireTexts( textList )
	self.fireTextsList = textList
end

-- 射击方向
function NewDialogDodgeLayer:setToFireTexts( textList )
	self.directionToFireTextList = textList
end

-- 躲避方向
function NewDialogDodgeLayer:setToDodgeTexts( textList )
	self.directionToDodgeTextList = textList
end

-- 按钮文本
function NewDialogDodgeLayer:setBtnName( textList )
	self.btnNameList = textList
end

-- 设置正确的方向，设置后就不随机了，directionName为上下左右
function NewDialogDodgeLayer:setCorrectDirection( directionName )
	if directionName == "上" then 
		self.correctDirectionIndex = 1
	elseif directionName == "下" then
		self.correctDirectionIndex = 2
	elseif directionName == "左" then
		self.correctDirectionIndex = 3
	elseif directionName == "右" then
		self.correctDirectionIndex = 4
	else
		if PRINT_MODE == 1 then
			print(string.format("错误: 躲避暗器，参数方向 '%s' 不是有效的值（上下左右），DialogDodgeLayer:setCorrectDirection( directionName )", directionName))
		end
	end
end

function NewDialogDodgeLayer:showButtons()
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

	local animDuration = 0.25
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

	self.Button_Down:releaseFunc(
		function()
			self:directionButtonPress( "down" )
		end)

	self.Button_Up:releaseFunc(
		function()
			self:directionButtonPress( "up" )
		end)

	self.Button_Left:releaseFunc(
		function()
			self:directionButtonPress( "left" )
		end)

	self.Button_Right:releaseFunc(
		function()
			self:directionButtonPress( "right" )
		end)
end

function NewDialogDodgeLayer:directionButtonPress(direction)
	--阶段2，只能按一个按钮


	self.LoadingBar:setVisible( false )

	self:hideButtonsAnim()

	--判断方向是否正确
	if self.correctDirection == direction then
		self:showDodgeSuccessfull( direction )
	else
		self:showDodgeFailed( direction )
	end
end

function NewDialogDodgeLayer:showDodgeFailed(direction)
	--阶段3
	if self.status == 1 then
		self.status = 2
	else
		return
	end

	if self.timeCounting == false then
		return
	end

	self:stopTime()

	-- local dodgeTexts = {
	-- 	["up"] = { "你身形陡然纵起，凌空一跃。" , "你身体向上笔直纵身，跃起数丈。" } ,
	-- 	["down"] = { "你足跟一支，全身后仰。" , "你飘然向下一闪，身体贴向地面。" } ,
	-- 	["left"] = { "你身体晃动，向左一偏。" , "你身随意转，向左一闪。" } ,
	-- 	["right"] = { "你向右，侧身一摆。" , "你足不点地，向右窜开。" } ,
	-- 	["still"] = { "你停留在原地，什么也没做！" , "你尚未回过神来！" }
	-- 	}

	-- local hurtTexts = {
	-- 	"你虽然反应极快，但$w还是擦伤了你，你受到了$z点伤害",
	-- 	"$w来势甚猛，你躲闪不及，受到了$z点伤害",
	-- 	"你一个躲避不及，还是被$w所击中，受到了$z点伤害",
	-- 	"你身法虽快，却未快过这$w，你受到了$z点伤害",
	-- 	"$w打中了你造成了$z点伤害，你痛苦不堪"
	-- 	}

	self.dodgeText = self.dodgeTextList[ direction ][ math.random( 1 , #self.dodgeTextList[ direction ] ) ]
	self.dodgeText = string.gsub( self.dodgeText , "$w" , self.anqiName )
	self.hurtText = self.hurtTextList[ math.random( 1 , #self.hurtTextList ) ]

	local damageNumber = 0
	if self.damagePercent > 0 then
		--受伤
		if self.damagePercent > 1 then
			self.damagePercent = 1
		end

		local role = User:getRole()
		--
		local maxHp = role:getFinalAttr( "qiMax" )
		local hp = role:getAttr( "qi" )
		local hpPercent = role:getAttr( "qiPercent" )

		damageNumber = maxHp * self.damagePercent

		print( "玩家中标，角色气血当前 " .. hp .. "/" .. maxHp .. " ".. hpPercent*100 .. "%" )

		role:addAttr( "qi" , - damageNumber )
		role:addAttr( "qiPercent" , - self.damagePercent )

		print( "打中了你造成了 " .. self.damagePercent*100 .. "%的 " .. damageNumber .. " 点伤害" )

		hp = role:getAttr( "qi" )
		hpPercent = role:getAttr( "qiPercent" )
		print( "还剩气血 " .. hp .. "/" .. maxHp .. " ".. hpPercent*100 .. "%" )

	end

	self.hurtText = string.gsub( self.hurtText , "$w" , self.anqiName )
	self.hurtText = string.gsub( self.hurtText , "$z" , tostring( math.floor( damageNumber ) ) )

	self:stopTime()
	self.Text_text:setColor( cc.c3b( 200 , 200 , 200 ) )
	self.Text_text:setString( self.dodgeText )
	self.Text_text:setAnchorPoint( 0.5 , 0.5 )
	self.Text_text:setPositionX( display.width/2 )
	self.Text_text:setPositionY( display.height/2 )
	self.Text_text:setScale( 0.5 , 0.5 )
	self.Text_text:runAction(
			 	cc.Sequence:create(
			 		YXEaseAction:create(cc.ScaleTo:create( 0.1 , 1.1 , 1.1 ) , Sine_EaseOut),
			 		cc.DelayTime:create( 0.15 ) ,
			 		YXEaseAction:create(cc.ScaleTo:create( 0.2 , 1.0 , 1.0 ) , Sine_EaseIn)
			 	)
			)

	if User:getRoleAttr("sex") == "男" then
		Audio:playEffect("ha_man")
	else
		Audio:playEffect("ha_woman")
	end

	self:delayFunc( 0.65 , function()
			Audio:playEffect("anqihit")
			self:delayFunc( 0.2 , function()
				if User:getRoleAttr("sex") == "男" then
					Audio:playEffect("hurt_man")
				else
					Audio:playEffect("hurt_woman")
				end
			end)

			self.Text_text:setColor( cc.c3b( 255 , 0 , 0 ) )
			self.Text_text:setString( self.hurtText )
			self.Text_text:setAnchorPoint( 0.5 , 0.5 )
			self.Text_text:setPositionX( display.width/2 )
			self.Text_text:setPositionY( display.height/2 )
			self.Text_text:setScale( 0.5 , 0.5 )
			self.Text_text:runAction(
					 	cc.Sequence:create(
					 		YXEaseAction:create(cc.ScaleTo:create( 0.1 , 1.1 , 1.1 ) , Sine_EaseOut),
					 		cc.DelayTime:create( 0.15 ) ,
					 		YXEaseAction:create(cc.ScaleTo:create( 0.2 , 1.0 , 1.0 ) , Sine_EaseIn)
					 	)
					)

			self:delayFunc( 1.0 , function()
				self:fadeOut(0.15 , function()
						self:hide()

						--完成阶段
						self.status = 3

						if self.failedResult ~= nil and type( self.failedResult ) == 'function' then
							self.failedResult()
						end

						if type( self.resultCallback ) == 'function' then
							 self.resultCallback( false )
						end
					end )
				end)
		end )

end

function NewDialogDodgeLayer:showDodgeSuccessfull(direction)
	--阶段3
	if self.status == 1 then
		self.status = 2
	else
		return
	end

	if self.timeCounting == false then
		return
	end

	self:stopTime()

	-- local dodgeTexts = {
	-- 	["up"] = { "你身形陡然纵起，凌空一跃" , "你身体向上笔直纵身，跃起数丈" } ,
	-- 	["down"] = { "你足跟一支，全身后仰" , "你飘然向下一闪，身体贴向地面" } ,
	-- 	["left"] = { "你身体晃动，向左一偏" , "你身随意转，向左一闪" } ,
	-- 	["right"] = { "你向右，侧身一摆" , "你足不点地，向右窜开" } ,
	-- 	["still"] = { "你停留在原地，什么也没做" , "你尚未回过神来" }
	-- 	}

	-- local succTexts = {
	-- 	"十分轻松地躲过了暗器！",
	-- 	"犹如鬼魅一般，十分利索地躲过了暗器！",
	-- 	"暗器擦着你的身体而过，你并没受到伤害！",
	-- 	"电光火石之间躲过了暗器的攻击",
	-- 	"暗器已然落空！"
	-- 	}

	self.dodgeText = self.dodgeTextList[ direction ][ math.random( 1 , #self.dodgeTextList[ direction ] ) ]
	self.dodgeText = string.gsub( self.dodgeText , "$w" , self.anqiName )

	self.succText = self.dodgeText .. "\n" .. self.succTextList[ math.random( 1 , #self.succTextList ) ]


	self.Text_text:setColor( cc.c3b( 200 , 200 , 200 ) )
	self.Text_text:setString( self.dodgeText )
	self.Text_text:setAnchorPoint( 0.5 , 0.5 )
	self.Text_text:setPositionX( display.width/2 )
	self.Text_text:setPositionY( display.height/2 )
	self.Text_text:setScale( 0.5 , 0.5 )
	self.Text_text:runAction(
			 	cc.Sequence:create(
			 		YXEaseAction:create(cc.ScaleTo:create( 0.1 , 1.1 , 1.1 ) , Sine_EaseOut),
			 		cc.DelayTime:create( 0.15 ) ,
			 		YXEaseAction:create(cc.ScaleTo:create( 0.2 , 1.0 , 1.0 ) , Sine_EaseIn)
			 	)
			)

	if User:getRoleAttr("sex") == "男" then
		Audio:playEffect("ha_man")
	else
		Audio:playEffect("ha_woman")
	end

	self:delayFunc( 0.65 , function()

			if User:getRoleAttr("sex") == "男" then
				Audio:playEffect("heng_man")
			else
				Audio:playEffect("heng_woman")
			end
			self.Text_text:setColor( cc.c3b( 200 , 200 , 200 ) )
			self.Text_text:setString( self.succText )
			self.Text_text:setAnchorPoint( 0.5 , 0.5 )
			self.Text_text:setPositionX( display.width/2 )
			self.Text_text:setPositionY( display.height/2 )
			self.Text_text:setScale( 0.5 , 0.5 )
			self.Text_text:runAction(
					 	cc.Sequence:create(
					 		YXEaseAction:create(cc.ScaleTo:create( 0.1 , 1.1 , 1.1 ) , Sine_EaseOut),
					 		cc.DelayTime:create( 0.15 ) ,
					 		YXEaseAction:create(cc.ScaleTo:create( 0.2 , 1.0 , 1.0 ) , Sine_EaseIn)
					 	)
					)

			self:delayFunc( 1.0 , function()
				self:fadeOut(0.15,
					function()
						self:hide()

						--完成阶段
						self.status = 3

						if self.succResult ~= nil and type( self.succResult ) == 'function' then
							self.succResult()
						end

						if type( self.resultCallback ) == 'function' then
							 self.resultCallback( true )
						end
					end )
				end)
		end)
end

function NewDialogDodgeLayer:hideButtons()
	self.Button_Down:setVisible( false )
	self.Button_Up:setVisible( false )
	self.Button_Left:setVisible( false )
	self.Button_Right:setVisible( false )
end

function NewDialogDodgeLayer:hideButtonsAnim()
	local animDuration = 0.25
	self.Button_Down:runAction(
			YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(animDuration, cc.p( 540.0000 , 320-200) ) ,
						cc.FadeOut:create(animDuration)
					),  Sine_EaseIn ) )

	self.Button_Up:runAction(
			YXEaseAction:create(
				cc.Spawn:create(
						cc.MoveTo:create(animDuration, cc.p( 540.0000 , 577-200) ) ,
						cc.FadeOut:create(animDuration)
					),  Sine_EaseIn ) )

	self.Button_Left:runAction(
			YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(animDuration, cc.p( 535.0000 -200, 451) ) ,
						cc.FadeOut:create(animDuration)
					),  Sine_EaseIn ) )

	self.Button_Right:runAction(
			cc.Sequence:create(
				YXEaseAction:create( cc.Spawn:create(
						cc.MoveTo:create(animDuration, cc.p( 545.0000 +200, 451) ) ,
						cc.FadeOut:create(animDuration)
					),  Sine_EaseIn ) ,
				cc.CallFunc:create( function()
						self:hideButtons()
					end)
				)
			)
end


function NewDialogDodgeLayer:show()
	-- local FireTexts = {
	-- 	[[$N单手一翻，$w散射而出，击向你的$d。]] ,
	-- 	[[$N向你的$d发射了一枚$w，快闪开！]] ,
	-- 	[[$N一个转身，$w飞快地向你的$d射来，快躲开！]] ,
	-- 	[[$N飞身而起，双手如散花般发射了数枚$w,暗器以极快的速度向你的$d袭来！]] ,
	-- 	[[$N手中$w激射而出，向你的$r飞来，只听“叮”地一声，暗器在空中突然转向，向你的$d射来！原来是$N再发一枚暗器，将先前暗器方向打偏！]] ,
	-- 	[[$N单手一翻，$w散射而出，快往$D！]] ,
	-- 	[[$N一个转身，$w飞快地向你射来，快$D！]] ,
	-- 	[[$N向你的头部发射了一枚$w，快$R！暗器飞至一半，却不知为何转向向你的$d打来！]],
	-- 	[[快$D！$N飞快地向你射出了数枚暗器！]] ,
	-- 	[[$N向你射出了数枚$w！快$R！不对不对！应该是$D]] ,


	-- 	[[$N腾空而起，手中$w飞速打向你的$d！]] ,
	-- 	[[$N眼中冷芒闪过，手中的$w已无踪迹，再看时，暗器已经离你$d半步之遥！]] ,
	-- 	[[$N微微一笑，$w脱手而出，只刹那便至$d！快闪开！]] ,
	-- 	[[$N凌空一掷！手中$w已经朝你的$r飞来，眼看就快靠近，暗器突地一转，打向你的$d！]] ,
	-- 	[[快闪开！$N手指弹出数枚$w,极快打向你的$r！不好！暗器在空中方向突变，打向了你的$d！]] ,
	-- 	[[$N腾空而起，手中$w飞速打向你，快$D！]] ,
	-- 	[[$N眼中冷芒闪过，手中的$w已无踪迹，再看时，暗器已经离你$d半步之遥！快$D！]] ,
	-- 	[[$N飞身而起，$w飞快地向你$d射来！快$R！不对不对！不能$B]] ,
	-- 	[[快$D！暗器已朝你飞速射来，只见$N冷笑一声，暗器竟然偏离方向朝你的$d射来！]]
	-- }

	if self.status == 0 then
		self.status = 1
	else
		print( "已经在show了")
		return
	end
	--show
	print(" NewDialogDodgeLayer:show()")
	local directions = { "up" , "down" , "left" , "right" }
	-- local directionToFireTexts = { "下身" , "头部", "右侧" , "左侧" }
	-- local directionToDodgeTexts = { "上跳" , "下蹲" , "左闪" , "右闪" }

	local correctI = 0
	-- 如果设置了正确的方向，那么就不随机方向
	if self.correctDirectionIndex ~= 0 then
		correctI = self.correctDirectionIndex
	else
		correctI = math.random( 1 , 4 )
	end

	self.correctDirection = directions[ correctI ]

	local _d = self.directionToFireTextList[ correctI ]
	local _r = self.directionToFireTextList[ ( correctI + 1 )%4 + 1 ]
	local _D = self.directionToDodgeTextList[ correctI ]
	local _R = self.directionToDodgeTextList[ ( correctI + 1 )%4 + 1 ]
	local _B = self.directionToDodgeTextList[ ( correctI + 2 )%4 + 1 ]
	local _C = self.directionToDodgeTextList[ ( correctI + 3 )%4 + 1 ]

	local K = math.random( 1 , #self.fireTextsList )
	local orgFireText = self.fireTextsList[ K ]
	orgFireText = string.gsub( orgFireText , "$N" , self.attackerName )
	orgFireText = string.gsub( orgFireText , "$w" , self.anqiName )
	orgFireText = string.gsub( orgFireText , "$d" , _d )
	orgFireText = string.gsub( orgFireText , "$D" , _D )
	orgFireText = string.gsub( orgFireText , "$r" , _r )
	orgFireText = string.gsub( orgFireText , "$R" , _R )
	orgFireText = string.gsub( orgFireText , "$B" , _B )

	self.fireText = orgFireText


	self.Button_Up.Text_name:setString(self.btnNameList[1])
	self.Button_Down.Text_name:setString(self.btnNameList[2])
	self.Button_Left.Text_name:setString(self.btnNameList[3])
	self.Button_Right.Text_name:setString(self.btnNameList[4])


	self:setCascadeOpacityEnabled(true)
	self:setOpacity(0)
	self:setVisible(true)

	self.LoadingBar:setVisible( false )
	self.Text_text:setString("")

	self:fadeIn(0.15 , function()
		self.Text_text:setColor( cc.c3b( 255 , 0 , 0 ) )
		self.Text_text:setString( self.fireText )
		self.Text_text:setAnchorPoint( 0.5 , 0.5 )
		self.Text_text:setPositionX( display.width/2 )
		self.Text_text:setPositionY( display.height/2 )
		self.Text_text:setScale( 0.5 , 0.5 )
		self.Text_text:runAction(
				 	cc.Sequence:create(
				 		YXEaseAction:create(cc.ScaleTo:create( 0.1 , 1.1 , 1.1 ) , Sine_EaseOut),
				 		cc.DelayTime:create( 0.15 ) ,
				 		YXEaseAction:create(cc.ScaleTo:create( 0.2 , 1.0 , 1.0 ) , Sine_EaseIn)
				 	)
				)

		self:delayFunc(0.5, function()
		 	--Audio:playEffect("anqishoot")
			local offset = cc.p( 0 , display.height*2/3 - display.height/2 )

			self.Text_text:runAction( YXEaseAction:create( cc.MoveBy:create( 0.25 , offset ) , Sine_EaseInOut )  )

			self:delayFunc(0.1, function()
				Audio:playEffect("anqishoot")

				self:showButtons()
				self.LoadingBar:setVisible(true)
		 		self.scheduleHandle = self:schedule( function(ft)
		    			self:update(ft)
		    		end, 30/1000 )
			end)


		end)

	end)

end



function NewDialogDodgeLayer:setTime( time )
	self.totalTicks = time * 1000 / 30
	self.ticksRemain = self.totalTicks

	self.LoadingBar:setPercent( 100 )

	--self:showButtons()

	self.timeCounting = true
end

function NewDialogDodgeLayer:stopTime()
	if self.scheduleHandle then
		self:unschedule( self.scheduleHandle )
		self.scheduleHandle = nil
	end

	self.timeCounting = false
end

function NewDialogDodgeLayer:update()
	self.ticksRemain = self.ticksRemain - 1

	self.LoadingBar:setPercent( self.ticksRemain * 100 / self.totalTicks )

	if self.ticksRemain <= 0 and self.timeCounting == true then

		--self:stopTime()

		self.LoadingBar:setVisible( false )

		self:hideButtonsAnim()

		self:showDodgeFailed("still")
	end
end


function NewDialogDodgeLayer:hide()
	PopupLayerController:hideLayer("NewDialogDodgeLayer")
	self.timeCounting = false
	self:setVisible(false)
	if self.scheduleHandle then
		self:unschedule( self.scheduleHandle )
		self.scheduleHandle = nil
	end
end

Helper:classDefNodeGetInstance(NewDialogDodgeLayer)
return NewDialogDodgeLayer00
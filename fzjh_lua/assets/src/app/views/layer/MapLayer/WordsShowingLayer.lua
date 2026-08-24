local WordsShowingLayer = class("WordsShowingLayer", require("app.views.base.BaseLayer"))


function WordsShowingLayer:createInRunningScene()

	local layer = WordsShowingLayer:getInstance()

	return layer

end

function WordsShowingLayer:create()
	local p = WordsShowingLayer:new()
	p:init()
	return p
end

function WordsShowingLayer:init()
	self.UI = require("Layer/DialogDodge.lua").create()['root']
	self.UI:addTo(self)
	Helper:convertUI(self) -- 获得所有子节点

	self.Button_Down:setVisible( false )
	self.Button_Up:setVisible( false )
	self.Button_Left:setVisible( false )
	self.Button_Right:setVisible( false )

	self:setCascadeOpacityEnabled(true)
	self:setOpacity(0)
	self:setVisible(true)

	self.Text_text:setVisible( false )
	self.LoadingBar:setVisible( false )


	local Image_1 = ccui.ImageView:create()
	Image_1:ignoreContentAdaptWithSize(false)
	Image_1:loadTexture("Anim/2.png",0)
	Image_1:setLayoutComponentEnabled(true)
	Image_1:setName("Image_1")
	Image_1:setTag(15)
	Image_1:setCascadeColorEnabled(true)
	Image_1:setCascadeOpacityEnabled(true)
	Image_1:setPosition(256.8112, 108.7996)
	Image_1:setVisible( false )
	local layout = ccui.LayoutComponent:bindLayoutComponent(Image_1)
	layout:setPositionPercentX(0.2653)
	layout:setPositionPercentY(0.5014)
	layout:setSize({width = 639.0000, height = 616.0000})
--	layout:setLeftMargin(140.8112)
--	layout:setRightMargin(595.1888)
--	layout:setTopMargin(68.2004)
--	layout:setBottomMargin(68.7996)
	self:addChild(Image_1)
	self.Image_1 = Image_1

	local Image_2 = ccui.ImageView:create()
	Image_2:ignoreContentAdaptWithSize(false)
	Image_2:loadTexture("Anim/1.png",0)
	Image_2:setLayoutComponentEnabled(true)
	Image_2:setName("Image_2")
	Image_2:setTag(15)
	Image_2:setCascadeColorEnabled(true)
	Image_2:setCascadeOpacityEnabled(true)
	Image_2:setPosition(256.8112, 108.7996)
	Image_2:setVisible( false )
	local layout2 = ccui.LayoutComponent:bindLayoutComponent(Image_2)
	layout2:setPositionPercentX(0.2653)
	layout2:setPositionPercentY(0.5014)
	layout2:setSize({width = 697.0000, height = 472.0000})
--	layout:setLeftMargin(140.8112)
--	layout:setRightMargin(595.1888)
--	layout:setTopMargin(68.2004)
--	layout:setBottomMargin(68.7996)
	self:addChild(Image_2)
	self.Image_2 = Image_2

	local layout3
	local Image_3 = ccui.ImageView:create()
	Image_3:ignoreContentAdaptWithSize(false)
	Image_3:loadTexture("Anim/3.png",0)
	Image_3:setLayoutComponentEnabled(true)
	Image_3:setName("Image_3")
	Image_3:setTag(15)
	Image_3:setCascadeColorEnabled(true)
	Image_3:setCascadeOpacityEnabled(true)
	Image_3:setPosition(256.8112, 108.7996)
	Image_3:setVisible( false )
	Image_3:setAnchorPoint( 0.5 , 0.5 )
	layout2 = ccui.LayoutComponent:bindLayoutComponent(Image_3)
	layout2:setPositionPercentX(0.2653)
	layout2:setPositionPercentY(0.5014)
	layout2:setSize({width = 980.0000, height = 184.0000})
--	layout:setLeftMargin(140.8112)
--	layout:setRightMargin(595.1888)
--	layout:setTopMargin(68.2004)
--	layout:setBottomMargin(68.7996)
	self:addChild(Image_3)
	self.Image_3 = Image_3


	local Image_4 = ccui.ImageView:create()
	Image_4:ignoreContentAdaptWithSize(false)
	Image_4:loadTexture("Anim/4.png",0)
	Image_4:setLayoutComponentEnabled(true)
	Image_4:setName("Image_4")
	Image_4:setTag(15)
	Image_4:setCascadeColorEnabled(true)
	Image_4:setCascadeOpacityEnabled(true)
	Image_4:setPosition(256.8112, 108.7996)
	Image_4:setVisible( false )
	Image_4:setAnchorPoint( 0.5 , 0.5 )
	layout2 = ccui.LayoutComponent:bindLayoutComponent(Image_4)
	layout2:setPositionPercentX(0.2653)
	layout2:setPositionPercentY(0.5014)
	layout2:setSize({width = 980.0000, height = 184.0000})
--	layout:setLeftMargin(140.8112)
--	layout:setRightMargin(595.1888)
--	layout:setTopMargin(68.2004)
--	layout:setBottomMargin(68.7996)
	self:addChild(Image_4)
	self.Image_4 = Image_4


	local Image_5 = ccui.ImageView:create()
	Image_5:ignoreContentAdaptWithSize(false)
	Image_5:loadTexture("Anim/5.png",0)
	Image_5:setLayoutComponentEnabled(true)
	Image_5:setName("Image_5")
	Image_5:setTag(15)
	Image_5:setCascadeColorEnabled(true)
	Image_5:setCascadeOpacityEnabled(true)
	Image_5:setPosition(256.8112, 108.7996)
	Image_5:setVisible( false )
	Image_5:setAnchorPoint( 0.5 , 0.5 )
	layout2 = ccui.LayoutComponent:bindLayoutComponent(Image_5)
	layout2:setPositionPercentX(0.2653)
	layout2:setPositionPercentY(0.5014)
	layout2:setSize({width = 652.0000, height = 184.0000})
--	layout:setLeftMargin(140.8112)
--	layout:setRightMargin(595.1888)
--	layout:setTopMargin(68.2004)
--	layout:setBottomMargin(68.7996)
	self:addChild(Image_5)
	self.Image_5 = Image_5	
end

function WordsShowingLayer:reinit()


end

function WordsShowingLayer:setResultCallback( resultCallback )
	self.resultCallback = resultCallback
end


function WordsShowingLayer:showVersion1Texts()

		self.Text_text:setSize({width = 1920.0000, height = 7000.0000})
		self.Text_text:setFontSize(120)
		self.Text_text:setVisible( true )
		self.Text_text:setColor( cc.c3b( 160 , 160 , 160 ) )
		self.Text_text:setTextHorizontalAlignment(0)
		self.Text_text:setTextVerticalAlignment(0)
		self.Text_text:setString( 
[[

　　只见柳玄风拳掌威猛无比，一手挥黑风顿起，一拳起劲气四射。

　　招式动作平平无奇，却凌厉优雅，发力时内劲竟透过发肤散发出来，真气缭绕落霞下宛如仙人。
　　
　　两人身手也是奇快，呼呼展开，风雨不透，几个回合下来，偌大的石室烟尘四起。
　　
　　众人皆为唏嘘，竟然无一人见识过这等神奇。一时风声咽呜，雨声哗然。
　　
　　柳玄风的身影已化为黑点消失在万丈深崖之中，江湖，就此平静了么？
　　
　　云雷啸，天际明，一行风雨伴谁行。你理了理散乱的头发，竟是一丝怅然。这正是：

　　　　追问江湖人浪游，
　　　　恩怨岂会说从头，
　　　　迷离扑朔总是恨。

　　　　青峰云海望迷眼，
　　　　周天罡气荡寒秋，
　　　　飘渺绝顶有人愁。

]] 
		)
		self.Text_text:setAnchorPoint( 0.5 , 1.0 )
		self.Text_text:setPositionX( display.width/2 )
		self.Text_text:setPositionY( 0 )
		self.Text_text:setScale( 0.5 , 0.5 )
		--self.Text_text:runAction( 				
		--		 	cc.Sequence:create(
		--		 		cc.MoveBy:create( 60 , cc.p( 0 , 4500) )
		--		 	)
		--		)
		self.Text_text:runAction( 				
				 	cc.Sequence:create(
				 		cc.MoveBy:create( 0.1 , cc.p( 0 , 4500) )
				 	)
				)

		self:delayFunc( 60.0 , function()
				self:fadeOut(2 , 
					function()
						self:hide()

						if type( self.resultCallback ) == 'function' then
							 self.resultCallback( false )
						end
					end)
				end)
end



function WordsShowingLayer:showVersion2Texts()

	self.Text_text:setFontSize(60)
	self.Text_text:setVisible( true )
	self.Text_text:setColor( cc.c3b( 160 , 160 , 160 ) )
	self.Text_text:setTextHorizontalAlignment(0)
	self.Text_text:setTextVerticalAlignment(0)
	self.Text_text:setString( )
	self.Text_text:setAnchorPoint( 0.5 , 1.0 )
	self.Text_text:setPositionX( display.width/2 )
	self.Text_text:setPositionY( 0 )

	
	
	self.Image_1:setVisible( true )
	self.Image_1:setAnchorPoint( 0.5 , 1.0 )
	self.Image_1:setPositionX( display.width/2 )
	self.Image_1:setPositionY( 0 )
	self.Image_1:runAction( 				
			 	cc.Sequence:create(
			 		cc.MoveBy:create( 10 , cc.p( 0 , 1550) ),
			 		cc.CallFunc:create( function()
--[[			 			self.Text_text:setTextHorizontalAlignment(1)
			 			self.Text_text:setPositionX( display.width/2 )
						self.Text_text:setPositionY( display.height*2/5 )
						self.Text_text:setOpacity(0)

						self.Text_text:setString( 
"然何为正，何为邪？
　　道中道，道不同。" )
						self.Text_text:runAction( 				]]
						self.Image_3:setVisible( true )
						self.Image_3:setOpacity(0)
						self.Image_3:setScale( 2.0 , 2.0 )
						self.Image_3:setPositionX( display.width/2 + 100 )
						self.Image_3:setPositionY( display.height*2/6 )
						self.Image_3:runAction( 	
								 	cc.Sequence:create(
								 		cc.Spawn:create(
								 			cc.FadeIn:create( 0.1 ) , 
					 						YXEaseAction:create(cc.ScaleTo:create( 0.2 , 1.3 , 1.3 ) , Sine_EaseOut)
					 					),								 		
								 		cc.DelayTime:create( 2 ),
								 		cc.FadeOut:create( 2 ) , 
								 		cc.CallFunc:create( function()
								 				self.Image_1:runAction( 				
												 	cc.Sequence:create(
												 		cc.MoveBy:create( 6 , cc.p( 0 , 1000) ) , 
												 		cc.CallFunc:create( function()
												 				self:showVersion3Texts()
												 			end)
												 	)
												)
								 			end)
								 	)
								)
			 			end)
			 	)
			)
end 



function WordsShowingLayer:showVersion3Texts()

	self.Text_text:setFontSize(60)
	self.Text_text:setVisible( true )
	self.Text_text:setColor( cc.c3b( 160 , 160 , 160 ) )
	self.Text_text:setTextHorizontalAlignment(0)
	self.Text_text:setTextVerticalAlignment(0)
	self.Text_text:setString( )
	self.Text_text:setAnchorPoint( 0.5 , 1.0 )
	self.Text_text:setPositionX( display.width/2 )
	self.Text_text:setPositionY( 0 )

	
	
	self.Image_2:setVisible( true )
	self.Image_2:setAnchorPoint( 0.5 , 1.0 )
	self.Image_2:setPositionX( display.width/2 )
	self.Image_2:setPositionY( 0 )
	self.Image_2:runAction( 				
			 	cc.Sequence:create(
			 		cc.MoveBy:create( 10 , cc.p( 0 , 1550) ),
			 		cc.CallFunc:create( function()
			 			
			 			self.Image_4:setVisible( true )
						self.Image_4:setOpacity(0)
						self.Image_4:setScale( 2.0 , 2.0 )
						self.Image_4:setPositionX( display.width/2 + 100 )
						self.Image_4:setPositionY( display.height*2/6 )
						self.Image_4:runAction( 			
								 	cc.Sequence:create(
								 		cc.Spawn:create(
								 			cc.FadeIn:create( 0.1 ) , 
					 						YXEaseAction:create(cc.ScaleTo:create( 0.2 , 1.3 , 1.3 ) , Sine_EaseOut)
					 					),
								 		--cc.FadeIn:create( 2 ) , 
								 		cc.DelayTime:create( 2 ),
								 		cc.FadeOut:create( 2 ) , 
								 		cc.CallFunc:create( function()
								 				self.Image_2:runAction( 				
												 	cc.Sequence:create(
												 		cc.MoveBy:create( 6 , cc.p( 0 , 1000) ),
												 		cc.CallFunc:create( function()
												 			
												 			self.Image_5:setVisible( true )
															self.Image_5:setOpacity(0)
															self.Image_5:setScale( 1.0 , 1.0 )
															self.Image_5:setPositionX( display.width/2 )
															self.Image_5:setPositionY( display.height/2 )
															self.Image_5:runAction(
																cc.Sequence:create(
																	cc.FadeIn:create( 3 ) , 			
																	--cc.DelayTime:create( 2 )
																	cc.CallFunc:create( function()
																			self:fadeOut(3 , function()
																				self:hide()

																				if type( self.resultCallback ) == 'function' then
																					 self.resultCallback( false )
																				end
																			end)
																		end)
																	)
																)
												 			end)
												 	)
												)
								 			end)
								 	)
								)
			 			end)
			 	)
			)
end

function WordsShowingLayer:show()

	self:setCascadeOpacityEnabled(true)
	self:setOpacity(0)
	self:setVisible(true)

	self.LoadingBar:setVisible( false )
	self.Text_text:setString("")
	
	self:fadeIn( 3 , function()
		Audio:playMusic( "jinzhang_outcave2" , false )


		self.Text_text:setSize({width = 860.0000, height = 1280.0000})
		self.Text_text:setFontSize(60)
		self.Text_text:setVisible( true )
		self.Text_text:setColor( cc.c3b( 196 , 196 , 196 ) )
		self.Text_text:setTextHorizontalAlignment(0)
		self.Text_text:setTextVerticalAlignment(1)
		self.Text_text:setAnchorPoint( 0.5 , 0.5 )
		self.Text_text:setPositionX( display.width/2 )
		self.Text_text:setPositionY( display.height/2 )
		self.Text_text:setOpacity(0)
		self.Text_text:setString( [[
　　只见柳玄风拳掌神勇无比，一手挥仙风顿起，一拳起劲气四射，真气缭绕落霞下宛如仙人。
　　
　　两人身手也是奇快，呼呼展开，风雨不透。
　　
　　众人皆为唏嘘，竟然无一人见识过这等神奇。
]])

		--self.Text_text:cc.MoveBy:create( 0.1 , cc.p( 0 , 4500) )

		self.Text_text:runAction(
			cc.Sequence:create(
				cc.FadeIn:create( 2 ) , 			
				cc.DelayTime:create( 8 ) ,
				cc.FadeOut:create( 1 ) , 			
				cc.CallFunc:create( function()

					self.Text_text:setString( [[　　一时风声咽呜，雨声哗然。]])
					self.Text_text:runAction( 
						cc.Sequence:create(
							cc.FadeIn:create( 2 ) , 			
							cc.DelayTime:create( 2 ) ,
							cc.FadeOut:create( 1 ) ,
							cc.CallFunc:create( function()

								self.Text_text:setString( [[　　柳玄风的身影已化为黑点消失在万丈深崖之中，江湖，就此平静了么？]])
								self.Text_text:runAction( 
									cc.Sequence:create(
										cc.FadeIn:create( 2 ) , 			
										cc.DelayTime:create( 2 ) ,
										cc.FadeOut:create( 1 ) ,
										cc.CallFunc:create( function()
											
											self.Text_text:setString( [[　　你理了理散乱的头发，竟是一丝怅然。]])
											self.Text_text:runAction( 
												cc.Sequence:create(
													cc.FadeIn:create( 2 ) , 			
													cc.DelayTime:create( 2 ) ,
													cc.FadeOut:create( 1 ) ,
													cc.CallFunc:create( function()

														--Create Image_1
														self:showVersion2Texts()
													end)
												)
											)
										end)
									)
								)
							end)							
						)
					)

				end)			
			)
		)

	end)

end


function WordsShowingLayer:fadeIn(duration, func)
    
    self:setVisible(true)
    self:resumeSelfAndChildren()
    
    self:setCascadeOpacityEnabled(true)
    self:callAllChild(
        function(child)
            child:setCascadeOpacityEnabled(true)
        end)
    
    self:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(duration)
            , cc.CallFunc:create(function()
                    -- self:pauseSelfAndChildren()
                    -- self:setVisible(false)
                    if type(func) == "function" then
                        func(self)
                    end
            end)))
end

function WordsShowingLayer:fadeOut(duration, func)
    self:setVisible(true)
    self:resumeSelfAndChildren()
    
    self:setCascadeOpacityEnabled(true)
    self:callAllChild(
        function(child)
            child:setCascadeOpacityEnabled(true)
        end)
    
    self:runAction(
        cc.Sequence:create(
            cc.FadeOut:create(duration)
            , cc.CallFunc:create(function()
                if func then
                    -- self:pauseSelfAndChildren()
                    -- self:setVisible(false)
                    if type(func) == "function" then
                        func(self)
                    end
                end
            end)))
end

function WordsShowingLayer:update()

end


function WordsShowingLayer:hide()
	PopupLayerController:hideLayer("WordsShowingLayer", function(layer)
		self:setVisible(false)
	end)
end

Helper:classDefNodeGetInstance(WordsShowingLayer)
return WordsShowingLayer0
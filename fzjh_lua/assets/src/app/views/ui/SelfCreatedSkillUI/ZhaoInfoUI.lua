local ZhaoInfoUI = class("ZhaoInfoUI", LayerEx)
local ZhaoInfoPresenter = require("app.presenters.selfCreatedSkill.zhaoInfo.ZhaoInfoPresenter")
local IZhaoInfoPresenterOutput = require("app.presenters.selfCreatedSkill.zhaoInfo.IZhaoInfoPresenterOutput")
local IZhaoInfoPresenterInput = require("app.presenters.selfCreatedSkill.zhaoInfo.IZhaoInfoPresenterInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function ZhaoInfoUI:create()
	local p = ZhaoInfoUI:new()
	p:init()
	return p
end

function ZhaoInfoUI:init()
    self._round = require("Layer/SelfCreatedSkillUI/zhaoInfoUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ZhaoInfoUI:showLayer(selfCreatedSkillSystem,zhaoIndex,func,presenter,skillId)
    self._IZhaoInfoPresenterInput = isImplement(presenter:create(self,selfCreatedSkillSystem,zhaoIndex,func), IZhaoInfoPresenterInput)

    self._IZhaoInfoPresenterInput:showLayer(skillId)
end

function ZhaoInfoUI:setShowLayer()
    self:show()
end

function ZhaoInfoUI:setTextZhaoNameAndColor(text,textColor)
	self.Text_zhaoName:setTextColor(textColor)
    self.Text_zhaoName:setString(text)
end

function ZhaoInfoUI:setTextZhaoIndex(text)
    self.Text_zhaoIndex:setString(text)
end

function ZhaoInfoUI:setTextZhaoType(text)
    self.Text_zhaoType:setString(text)
end

function ZhaoInfoUI:setTextZhaoDsc(text)
    self.Text_dsc:setString(text)
end

function ZhaoInfoUI:setTextZhaoNeed(text)
    self.Text_need:setString(text)
end

function ZhaoInfoUI:setPanelAttr(index,params)
	local panel_attr = self["Panel_attr"..index]
	if not panel_attr then
		return
	end
	panel_attr:setVisible(params.isVisible)
	if params.isVisible == false then
		return
	end
	panel_attr.Text_level1:setString(params.textLevel)
	panel_attr.Text_str1:setString(params.strLevel)
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	panel_attr:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			panel_attr.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			dialog:show(params.dsc)
			dialog:setPanelBack(function()
				panel_attr.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			panel_attr.Image_7:setVisible(true)
		end
	end)
end

function ZhaoInfoUI:setPanelTip(index,name,text)
	local panel_tip = self["Panel_tip"..index]
	if not panel_tip then
		return
	end
	panel_tip.Text_affixName:setString(name)
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	panel_tip:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			panel_tip.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			dialog:show(text)
			dialog:setPanelBack(function()
				panel_tip.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			panel_tip.Image_7:setVisible(true)
		end
	end)
end

function ZhaoInfoUI:setPanelTipIsVisible(index,isVisible)
	local panel_tip = self["Panel_tip"..index]
	if not panel_tip then
		return
	end
	panel_tip:setVisible(isVisible)
end

function ZhaoInfoUI:hideLayer()
	if self._animRoleLayer then
		local animRole = self._animRoleLayer:getRoleByTeamIdAndInTeamId(1, 1)
		if animRole then
			animRole._action = nil
			animRole:setVisible(false)
			self._playAnim = nil
		end
	end
    PopupLayerController:hideLayer("ZhaoInfoUI",function(layer)
        layer:hide()
    end)
end

function ZhaoInfoUI:setZhaoAttrImage(image)
    self.Panel_tital3.Image_2:loadTexture(image,0)
end

function ZhaoInfoUI:setZhaoAffixImage(image)
    self.Panel_tital4.Image_2:loadTexture(image,0)
end

function ZhaoInfoUI:setButton3(func)
    self.Button_3:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function ZhaoInfoUI:setButton4IsVisible(isVisible)
    self.Button_4:setVisible(isVisible)
end

function ZhaoInfoUI:setButton4(func)
    self.Button_4:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function ZhaoInfoUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function ZhaoInfoUI:popText(text)
    PopText(text)
end

function ZhaoInfoUI:playWuXueAnim(standAnim,jumpForwardAnim,animList,weaponName1,weaponName2)
	local leftPositions = {}
    local rightPositions = {}

	table.insert(leftPositions, cc.p(self.Panel_animFightArea.Panel_leftFightPos1:getPosition()))
	table.insert(rightPositions, cc.p(self.Panel_animFightArea.Panel_rightFightPos1:getPosition()))

    if self._animRoleLayer then
        self._animRoleLayer = nil
    end
    
	local AnimFightLayer = require("app.views.layer.FightLayer.AnimFightLayer")
	self._animRoleLayer = AnimFightLayer:createInPanel(self.Panel_animFightArea)
    self._animRoleLayer:FightStart(leftPositions, rightPositions)
	-- self._animRoleLayer:setMoveCameraEnabled(true)

	local animRole = self._animRoleLayer:getRoleByTeamIdAndInTeamId(1, 1)
	local daocaoren = self._animRoleLayer:getRoleByTeamIdAndInTeamId(2, 1)
    animRole:setVisible(true)
	daocaoren:setVisible(true)
	daocaoren.anim:setPositionX(daocaoren.anim:getPositionX() + 15)

	-- 武器
	animRole.anim:setAttachment("weapon", weaponName1)
    animRole.anim:setAttachment("weapon5", weaponName2)

	animRole.shadowSprite:setVisible(true)
	daocaoren.shadowSprite:setVisible(true)

    self._playAnim = true

	local function addAnimation(anims)
		if MapIsEmpty(anims) then
			return
		end

		local count = 0

		local function playRoleAnim(objectRole,animName,from,to,speed)
			objectRole.anim:playAnim(animName)

			if from or to then
				objectRole.anim:setAnimFrameFromTo(from, to)
			end
			if speed then
				objectRole.anim:setSpeedScale(speed)
			end
		end

		playRoleAnim(animRole,standAnim)
		playRoleAnim(daocaoren,"daocaoren-hurt-chest",1,2)

		animRole.anim:registerSpineEventHandler(function(event)
			if self._playAnim ~= true then
				return
			end
			
			local randomDelayTime = 0
			if count == 0 then
				randomDelayTime = 0.5
			end

			animRole:runActionWithName("playRoleAnim",
            cc.Sequence:create(
                cc.DelayTime:create(randomDelayTime),
				cc.CallFunc:create(function()
					local name,offsetX,duration
					if count > #anims then
						self._action =
						{
							name = "idle",
							elapsed = 0,
							duration = 0
						}
						playRoleAnim(animRole,standAnim)
						self._playAnim = nil
					else
						if count == 0 then
							duration = 10/30
							offsetX = anims[1]["offset"]
						else
							duration = 5/30
							offsetX = anims[count]["offset"]
						end
						local moveVecX = math.abs((daocaoren:getPositionX() - animRole:getPositionX())) + offsetX
						if moveVecX <= 50 then
							name = "move"
						else
							name = "jump"
						end
	
						animRole._action =
						{
							name = name,
							target = daocaoren,
							offsetX = offsetX,
							offsetY = 0,
							duration = duration,
							elapsed = 0
						}
	
						if count == 0 then
							self._animRoleLayer:delayFunc(duration,function()
								playRoleAnim(animRole,jumpForwardAnim)
								count = count + 1
							end)
						else
							local daocaorenAnims = "daocaoren-hurt-chest"
							self._animRoleLayer:delayFunc(duration,function()
								playRoleAnim(animRole,anims[count]["anim"])
								playRoleAnim(daocaoren,daocaorenAnims)
								count = count + 1
							end)
						end
					end
                end)))
		end, sp.EventType.ANIMATION_COMPLETE)
	end
	
	addAnimation(animList)
end

function ZhaoInfoUI:setPanelAnimAreaIsVisible(isVisible)
	if isVisible == true then
		self.Panel_animFightArea:setVisible(true)
	else
		self.Panel_animFightArea:setVisible(false)
	end
end

isImplement(ZhaoInfoUI,IZhaoInfoPresenterOutput)
Helper:classDefNodeGetInstance(ZhaoInfoUI)
return ZhaoInfoUI0000000000000000
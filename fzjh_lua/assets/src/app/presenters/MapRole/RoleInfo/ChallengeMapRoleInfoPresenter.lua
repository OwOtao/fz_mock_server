local class = require("third.class.NewClass")

local ChallengeMapRoleInfoPresenter = {}

function ChallengeMapRoleInfoPresenter:create()
    local p = ChallengeMapRoleInfoPresenter.new()
    return p
end

function ChallengeMapRoleInfoPresenter:setOutput(iRoleInfoView)
    self.__output = iRoleInfoView
end

function ChallengeMapRoleInfoPresenter:setInput(iRoleInfoModel)
    self.__input = iRoleInfoModel

    self.__role = self.__input:getRole()
end

function ChallengeMapRoleInfoPresenter:updata(elapsed)
    if self.__role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
        self.__input:daZuo()
    end
end

function ChallengeMapRoleInfoPresenter:showPresenter()
    PopupLayerController:showLayer("ChallengeMapRoleInfoUI",function(ui)
		self:setOutput(ui)

        self:__initRoleButtons()

        self:__showRoleInfoPanel()

        self.__output:scheduleUnique(
            function(elapsed)
                self:__refreshRoleAttr()
                
                self:__refreshHuiFuUI()
    
                self:__refreshLiaoShangUI()
                
                self:__refreshDaZuoUI()

				self:__refreshCsjUI()

				self:__refreshCsjHuiFu(elapsed)
            
                do  --刷新常态buff
                    local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
                    ChallengeMapSystem:getInstance():updateBuffs(self.__role)
                end
            end,
            0,
            "roleAttrSchedule"
        )
        
		self.__output:showUI()
	end)
end

function ChallengeMapRoleInfoPresenter:hidePresenter()
    PopupLayerController:hideLayer("ChallengeMapRoleInfoUI",function(ui)
        ui:unscheduleWithTag("roleAttrSchedule")
        
		ui:hideUI()
	end)
end

function ChallengeMapRoleInfoPresenter:__refreshRoleAttr()
    local qi, currQiMax, qiMax = self.__role:getNumAttr("qi"), self.__role:getCurrQiMax(), Helper:mathFloor(self.__role:getFinalAttr("qiMax"))

    local qiValue = qi .. "/" .. Helper:mathFloor(currQiMax) .. "(" .. Helper:mathFloor(self.__role:getAttr("qiPercent") * 100) .. "%)"

    local qiPercent = (qi / qiMax) * 100

    local neili, neiliMax = self.__role:getNumAttr("neili"), Helper:mathFloor(self.__role:getFinalAttr("neiliMax"))

    local neiliValue = neili .. "/" .. neiliMax .. "(" .. self.__role:getNumAttr("jiaLi") .. ")"

    local neiliPercent = (neili / neiliMax) * 100

    local percent = Helper:mathFloor(self.__role:getAttr("qiPercent") * 100)

    self.__output:setRoleQiMaxPercent(percent)

    self.__output:setRoleNeiLiValue(neiliValue)
    
    self.__output:setRoleNeiLiPercent(neiliPercent)
    
    self.__output:setRoleQiValue(qiValue)
    
    self.__output:setRoleQiPercent(qiPercent)
end

function ChallengeMapRoleInfoPresenter:__showRoleInfoPanel()
    self:__setRoleAge()
    self:__setRoleExp()
    self:__setRoleFamily()
    self:__setRoleLv()
    self:__setRoleName()
    self:__setDaZuo()
    self:__setHuiFu()
    self:__setLiaoShang()
	self:__setButtonCsj()
end

function ChallengeMapRoleInfoPresenter:__setRoleName()
    local chengHao = self.__input:getRoleChengHao()
    local name = self.__input:getRoleName()

    self.__output:setRoleName(chengHao.." "..name)
end

function ChallengeMapRoleInfoPresenter:__setRoleFamily()
    local familyName = self.__input:getRoleFamilyName()

    self.__output:setRoleFamily("【门派】"..familyName)
end

function ChallengeMapRoleInfoPresenter:__setRoleExp()
    local exp = self.__input:getRoleExp()

    self.__output:setRoleExp("经验："..tostring(math.floor(exp)))
end

function ChallengeMapRoleInfoPresenter:__setRoleLv()
    local lv = self.__input:getRoleLv()

    self.__output:setRoleLv("等级："..tostring(lv))
end

function ChallengeMapRoleInfoPresenter:__setRoleAge()
    local age = self.__input:getRoleAgeDesc()

    self.__output:setRoleAge("年龄："..tostring(age))
end

function ChallengeMapRoleInfoPresenter:__setHuiFu()
    self.__output:setButtonName(1,"回复气血")
    self.__output:setButtonTouchEnable(1,true)
    self.__output:setButtonVisible(1,true)
    self.__output:setButtonFunc(1,function()
        Audio:playEffect("xiaoAnNiu")

        if self.__huiFuTime then
            return
        end

        local canHuiFu,msg = self.__input:checkCanHuiFu()

        if canHuiFu then
            self.__input:huiFu()

            self.__huiFuTime = GetTime()
        else
            self:__popText(Helper:getDef(msg,""))
        end
    end)
end

function ChallengeMapRoleInfoPresenter:__setLiaoShang()
    self.__output:setButtonName(2,"疗伤")
    self.__output:setButtonTouchEnable(2,true)
    self.__output:setButtonVisible(2,true)
    self.__output:setButtonFunc(2,function()
        Audio:playEffect("xiaoAnNiu")

        if self.__liaoShangTime then
            return
        end

        local canLiaoShang,msg = self.__input:checkCanLiaoShang()

        if canLiaoShang then
            self.__input:liaoShang()

            self.__liaoShangTime = GetTime()
        else
            self:__popText(Helper:getDef(msg,""))
        end
    end)
end

function ChallengeMapRoleInfoPresenter:__setDaZuo()
    local isDaZuo = self.__input:getRoleIsDaZuo()
    if isDaZuo then
        self.__output:setButtonName(3,"正在打坐")
    else
        self.__output:setButtonName(3,"打坐")
    end

    self.__output:setButtonFunc(3,function()
        Audio:playEffect("xiaoAnNiu")
        local canDaZuo,msg = self.__input:checkCanDaZuo()
        if canDaZuo then
            self.__input:startDaZuo()
            
            self.__input:daZuo()
        else
            self:__popText(Helper:getDef(msg,""))
        end
    end)

    self.__output:setButtonTouchEnable(3,true)
    self.__output:setButtonVisible(3,true)
end

function ChallengeMapRoleInfoPresenter:__setButtonCsj()
	self.__output:setButtonName(5,"长生诀")

    self.__output:setButtonTouchEnable(5,true)

	local csjLv = self.__role:getSkillLv("changshengjueyin") > 0 and self.__role:getSkillLv("changshengjueyin") or self.__role:getSkillLv("changshengjueyang")

    self.__output:setButtonVisible(5,csjLv >= 600)

	self.__output:setButtonFunc(5,function()
        Audio:playEffect("xiaoAnNiu")

        if self.__role:getFlag("长生诀时间") > 0  then
            return
        end

        local canUseCsj,msg = self.__input:checkCanUseCsj()

        if canUseCsj then
            self.__input:useCsj()

            self.__csjHuiFuIng = true

            PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
				layer:setPopText("你正在运功，请稍后片刻")
				layer:showLayer()
			end)

            self.__role:setFlag("长生诀时间",GetTime())

            if self.__role:getSkill("changshengjueyin") then
				RichPrint("main","HIW你运起长生诀阴之内功，顿时灵台一片清明，内力缓慢流动，自行运转周天，待你回过神来，身上伤势已是荡然无存，内力也充溢无比，全无异样。")
			elseif self.__role:getSkill("changshengjueyang") then
				RichPrint("main","HIW你运起长生诀阳之内功，顿时丹田处生出一股热流，流遍奇经八脉，待你回过神来，身上伤势已是荡然无存，内力也充溢无比，全无异样。")
			end
        else
            self:__popText(Helper:getDef(msg,""))
        end
    end)
end

function ChallengeMapRoleInfoPresenter:__initRoleButtons()
    local buttons = {
        {posX = 50,posY = 58},
        {posX = 360,posY = 58},
        {posX = 670,posY = 58},
        {posX = 50,posY = 168},
        {posX = 360,posY = 168},
        {posX = 670,posY = 168},
    }

    for i ,v in ipairs(buttons) do
        self.__output:createButton(i,v.posX,v.posY)
    end
end

function ChallengeMapRoleInfoPresenter:__refreshHuiFuUI()
    if self.__huiFuTime then
		local currTime = GetTime()
		local needTime = currTime - self.__huiFuTime
		local percent
		percent = math.min(Helper:mathFloor(needTime / 2 * 100), 100)
        
        self.__output:setButtonPercent(1,percent)
        
		if percent == 100 then
			self.__huiFuTime = nil
		end
    else
        self.__output:setButtonPercent(1,100)
	end
end

function ChallengeMapRoleInfoPresenter:__refreshLiaoShangUI()
    if self.__liaoShangTime then
		local currTime = GetTime()
		local needTime = currTime - self.__liaoShangTime
		local percent
		percent = math.min(Helper:mathFloor(needTime / 4 * 100), 100)

		self.__output:setButtonPercent(2,percent)
		
        if percent == 100 then
			self.__liaoShangTime = nil
		end
    else
        self.__output:setButtonPercent(2,100)
	end
end

function ChallengeMapRoleInfoPresenter:__refreshDaZuoUI()
    if self.__role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
        self.__output:setButtonName(3,"正在打坐")
    else
        self.__output:setButtonName(3,"打坐")
    end
end

function ChallengeMapRoleInfoPresenter:__refreshCsjUI()
	if self.__role:getFlag("长生诀时间") > 0 then
		local currTime = GetTime()
        
		local needTime = currTime - self.__role:getFlag("长生诀时间")
		
        local percent = math.min(Helper:mathFloor(needTime / 300 * 100), 100)

		self.__output:setButtonPercent(5, percent)

		if percent == 100 then
			self.__role:setFlag("长生诀时间",0)
		end
	else
        self.__output:setButtonPercent(5, 100)
	end
end

function ChallengeMapRoleInfoPresenter:__refreshCsjHuiFu(elapsed)
    if self.__csjHuiFuIng ~= true then
        return
    end

    local speed = 0.01

	local qiPercentHuifuSpeed = speed

    local qiHuifuSpeed = self.__role:getFinalAttr("qiMax") * speed

    local neiliHuifuSpeed = self.__role:getFinalAttr("neiliMax") * 2 * speed

    self.__diffTime = Helper:getDef(self.__diffTime,0)  + elapsed

    if self.__diffTime >= 0.01 then
        self.__role:setAttr("qi", math.min(self.__role:getAttr("qi") + qiHuifuSpeed, self.__role:getFinalAttr("qiMax")))

        self.__role:setAttr("neili", math.min(self.__role:getAttr("neili") + neiliHuifuSpeed, self.__role:getFinalAttr("neiliMax")*2))

        self.__role:setAttr("qiPercent", math.min(self.__role:getAttr("qiPercent") + qiPercentHuifuSpeed, 1))
        
        self.__diffTime = nil

        if  self.__role:getAttr("qi") >= self.__role:getFinalAttr("qiMax") and 
            self.__role:getAttr("neili") >= self.__role:getFinalAttr("neiliMax")*2 and 
            self.__role:getAttr("qiPercent") >= 1 then
                PopupLayerController:hideLayer("GlobalShadeLayer",function (layer)
                    layer:hideLayer()
                end)
                self.__csjHuiFuIng = nil
        end
    end
end

function ChallengeMapRoleInfoPresenter:__popText(text)
    PopText(text)
end

return class("ChallengeMapRoleInfoPresenter", {}, ChallengeMapRoleInfoPresenter)
0000
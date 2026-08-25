--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-01-14 16:10:42
--]]
local class = require("third.class.NewClass")

local MapRoleAttrPresenter = {}

function MapRoleAttrPresenter:create()
    local p = MapRoleAttrPresenter.new()
    return p
end

--["src.app.models.MapRole.MapRoleAttr"]
function MapRoleAttrPresenter:setInput(iRoleAttrModel)
    self.__input = iRoleAttrModel

    self.__role = self.__input:getRole()
end

function MapRoleAttrPresenter:setUI(ui)
    self.__ui = ui
end

function MapRoleAttrPresenter:setMainPresenter(mainPresenter)
    self.__mainPresenter = mainPresenter
end

function MapRoleAttrPresenter:showPresenter()
    PopupLayerController:showLayer("MapRoleAttrUI",function(ui)
		self:setUI(ui)

        self:__setTextExp()
    
        self.__ui:setTextWeiWang("【威望】 " .. tostring(self.__role:getNumAttr("weiwang")))
    
        self.__ui:setTextMoney("【金钱】 " .. tostring(self.__role:getNumAttr("money")))
    
        self.__ui:setTextPot("【潜能】 " .. tostring(self.__role:getNumAttr("pot")))
    
        self:__setButton()
    
        self.__ui:scheduleUnique(
            function(elapsed)
                self:__refreshRoleAttr()
    
                self:__refreshCsjHuiFu(elapsed)
                
                self:__refreshButton()
            end,
            0,
            "roleAttrSchedule"
        )

		self.__ui:showUI()
	end)
end

function MapRoleAttrPresenter:hidePresenter()
    PopupLayerController:hideLayer("MapRoleAttrUI",function(ui)
        ui:unscheduleWithTag("roleAttrSchedule")

		ui:hideUI()
	end)
end

function MapRoleAttrPresenter:__setTextExp()
    self.__ui:setTextExp("【经验】 " .. tostring(Helper:mathFloor(self.__role:getExp())))
end

function MapRoleAttrPresenter:__refreshRoleAttr()
    local qi = Helper:mathFloor(self.__role:getNumAttr("qi"))

    local currQiMax = Helper:mathFloor(self.__role:getCurrQiMax())
    
    local qiMax = Helper:mathFloor(self.__role:getFinalAttr("qiMax"))

    local qiPercent = (qi / qiMax) * 100

    local neili = Helper:mathFloor(self.__role:getNumAttr("neili"))

    local neiliMax = Helper:mathFloor(self.__role:getFinalAttr("neiliMax"))

    local neiliPercent = (neili / neiliMax) * 100

    local qiMaxPercent = Helper:mathFloor(self.__role:getAttr("qiPercent") * 100)

    self.__ui:setTextDesc(self.__role:getChengHaoColorName() .. " " .. self.__role:getName())

    self.__ui:setTextQi(qi .. "/" .. currQiMax .. "(" .. Helper:mathFloor(self.__role:getAttr("qiPercent") * 100) .. "%)")

    self.__ui:setTextNeiLi(neili .. "/" .. neiliMax .. "(" .. self.__role:getNumAttr("jiaLi") .. ")")

    self.__ui:setQiPercent(qiPercent)

    self.__ui:setQimaxPercent(qiMaxPercent)

    self.__ui:setNeiLiPercent(neiliPercent)
end

function MapRoleAttrPresenter:__refreshButton()
    self:__refreshHuiFuButtonPercent()

    self:__refreshCsjButtonPercent()

    self:__refreshLiaoShangButtonPercent()

    self:__refreshButtonDaZuoName()
end

function MapRoleAttrPresenter:__setButton()
    self:__setButtonJiaLi()

    self:__setButtonCsj()

    self:__setButtonQieCuo()

    self:__setButtonHuiFu()

    self:__setButtonLiaoShang()

    self:__setButtonDaZuo()
end

function MapRoleAttrPresenter:__setButtonJiaLi()
    local buttonIndex = 1

    self.__ui:setButtonName(buttonIndex,"加力")

    self.__ui:setButtonVisible(buttonIndex,self.__role:getAttr("userid") == User:getRole():getAttr("userid"))

    self.__ui:setButtonFunc(buttonIndex,function()
        Audio:playEffect("xiaoAnNiu")

        PopupLayerController:showLayer(
            "JiaLiLayer",
            function(layer)
                layer:show()
            end
        )
    end)
end

function MapRoleAttrPresenter:__setButtonCsj()
    local buttonIndex = 2

    self.__ui:setButtonName(buttonIndex,"长生诀")

    local csjLv = self.__role:getSkillLv("changshengjueyin") > 0 and self.__role:getSkillLv("changshengjueyin") or self.__role:getSkillLv("changshengjueyang")

    self.__ui:setButtonVisible(buttonIndex,csjLv >= 600)

    self.__ui:setButtonFunc(buttonIndex,function()
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

            if self.__mainPresenter._biWuMainLayerMark == true then
				self.__mainPresenter._biWuMainLayer:print("CYN你深深吸了几口气， 脸色看起来好多了。")
			end
        else
            self:popText(Helper:getDef(msg,""))
        end
    end)
end

function MapRoleAttrPresenter:__setButtonQieCuo()
    local buttonIndex = 3

    self.__ui:setButtonName(buttonIndex,"江湖切磋")

    self.__ui:setButtonVisible(buttonIndex,Game:isOpenEncounter() == true)

    self.__ui:setButtonFunc(buttonIndex,function()
        Audio:playEffect("xiaoAnNiu")

		PopupLayerController:showLayer("PVPWaitingLayer", function(layer)
			layer:show()
			layer:setTitleText("江湖切磋")
			layer:showHistory(MapPVP:getData())
		end)
    end)
end

function MapRoleAttrPresenter:__setButtonHuiFu()
    local buttonIndex = 4

    self.__ui:setButtonName(buttonIndex,"回复气血")

    self.__ui:setButtonVisible(buttonIndex,true)

    self.__ui:setButtonFunc(buttonIndex,function()
        Audio:playEffect("xiaoAnNiu")

        if self.__huiFuTime then
            return
        end

        local canHuiFu,msg = self.__input:checkCanHuiFu()

        if canHuiFu then
            self.__input:huiFu()
            
            self.__huiFuTime = GetTime()

			RichPrint("main", "你深深吸了几口气， 脸色看起来好多了。")
			if self.__mainPresenter._biWuMainLayerMark == true then
				self.__mainPresenter._biWuMainLayer:print("CYN你深深吸了几口气， 脸色看起来好多了。")
			end
        else
            self:popText(Helper:getDef(msg,""))
        end
    end)
end

function MapRoleAttrPresenter:__setButtonLiaoShang()
    local buttonIndex = 5

    self.__ui:setButtonName(buttonIndex,"疗伤")

    self.__ui:setButtonVisible(buttonIndex,true)

    self.__ui:setButtonFunc(buttonIndex,function()
        Audio:playEffect("xiaoAnNiu")

        if self.__liaoShangTime then
            return
        end

        local canLiaoShang,msg = self.__input:checkCanLiaoShang()

        if canLiaoShang then
            self.__input:liaoShang()
            
            self.__liaoShangTime = GetTime()
        else
            self:popText(Helper:getDef(msg,""))
        end
    end)
end

function MapRoleAttrPresenter:__setButtonDaZuo()
    local buttonIndex = 6

    self.__ui:setButtonName(buttonIndex,"打坐")

    self.__ui:setButtonVisible(buttonIndex,true)
    
    self.__ui:setButtonFunc(buttonIndex,function()
        Audio:playEffect("xiaoAnNiu")

        if self.__input:getRoleIsDaZuo() then
            self.__role:setFlag("地图打坐", nil)
            
            self.__role:stopDaZuo()
        else
            local canDaZuo,msg = self.__input:checkCanDaZuo()

            if canDaZuo then
                self.__input:daZuo()
            else
                self:popText(Helper:getDef(msg,""))
            end
        end

    end)
end

function MapRoleAttrPresenter:__refreshButtonDaZuoName()
    local buttonIndex = 6

    if self.__input:getRoleIsDaZuo() then
        self.__ui:setButtonName(buttonIndex,"正在打坐")
    else
        self.__ui:setButtonName(buttonIndex,"打坐")
    end
end

function MapRoleAttrPresenter:__refreshHuiFuButtonPercent()
    local buttonIndex = 4

    if self.__huiFuTime then
        local currTime = GetTime()
        
        local needTime = currTime - self.__huiFuTime
        
        local percent = math.min(Helper:mathFloor(needTime / 2 * 100), 100)
        
        self.__ui:setButtonPercent(buttonIndex, percent)
        
        if percent == 100 then
            self.__huiFuTime = nil
        end
    else
        self.__ui:setButtonPercent(buttonIndex, 100)
    end
end

function MapRoleAttrPresenter:__refreshCsjButtonPercent()
	local buttonIndex = 2

	if self.__role:getFlag("长生诀时间") > 0 then
		local currTime = GetTime()
        
		local needTime = currTime - self.__role:getFlag("长生诀时间")
		
        local percent = math.min(Helper:mathFloor(needTime / 300 * 100), 100)

		self.__ui:setButtonPercent(buttonIndex, percent)

		if percent == 100 then
			self.__role:setFlag("长生诀时间",0)
		end
	else
        self.__ui:setButtonPercent(buttonIndex, 100)
	end
end

function MapRoleAttrPresenter:__refreshLiaoShangButtonPercent()
    local buttonIndex = 5

	if self.__liaoShangTime then
        local currTime = GetTime()
        
        local needTime = currTime - self.__liaoShangTime
        
        local percent = math.min(Helper:mathFloor(needTime / 4 * 100), 100)
        
        self.__ui:setButtonPercent(buttonIndex, percent)
        
        if percent == 100 then
            self.__liaoShangTime = nil
        end
    else
        self.__ui:setButtonPercent(buttonIndex, 100)
    end
end

function MapRoleAttrPresenter:__refreshCsjHuiFu(elapsed)
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

function MapRoleAttrPresenter:popText(text)
    PopText(text)
end

return class("MapRoleAttrPresenter", {}, MapRoleAttrPresenter)
00000000000
local SkillConst = require("app.models.skill.SkillConst")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local class = require("third.class.NewClass")

local ZouXueShiSiJingSkillInfoPresenter = {}

function ZouXueShiSiJingSkillInfoPresenter:create()
    local p = ZouXueShiSiJingSkillInfoPresenter:new()
    p:init()
    return p
end

function ZouXueShiSiJingSkillInfoPresenter:init()
end

function ZouXueShiSiJingSkillInfoPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skillExp = self.__role:getSkillExp(self.__skillId)

    self.__skill = Skill:getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local exp = Helper:mathFloor(self.__skillExp)

    local expDsc = exp.."/"..self.__role:getSkillLvWithRoleLvLimit(self.__skillId).."级"

    local btn1 = "详情"

    local func1 = function()
        Audio:playEffect("daAnNiu")

        self.__ui:hide(true)

        self:__showSkilInfo()
    end

    self:__initZouXueBut()

	self.__ui:setName(name)
	self.__ui:setSkillStageDsc(desc)
	self.__ui:setSkillDetailDsc(dsc)
	self.__ui:setSkillExpDsc(expDsc)
	self.__ui:setButton1(btn1, func1)
	self.__ui:setTextDesc1(false)
	-- self.__ui:setButton2(btn2, func2)
	self.__ui:setButton3(nil, nil)
	-- self.__ui:setTextDesc2(false)
    self.__ui:setThirdTypeVisible(false)
	self.__ui:setActiveZhaoList({})
    self.__ui:setUseTipVisible(false)
    -- self.__ui:unscheduleAll()
	self.__ui:setImageBackFunc(function()
        if self.__backFunc then
            self.__backFunc()
        end
        self.__ui:unscheduleAll()
        
		self.__ui:hide(true)
	end)

    self.__ui:show(true)
end

function ZouXueShiSiJingSkillInfoPresenter:__showSkilInfo()
    local name = self.__skill:getName()

    local dsc = self.__skill:getDsc()

    PopupLayerController:showLayer("TuJianSkillInFoPopLayer", function(layer)
        local TuJianUtil = require("app.models.TuJian.TuJianUtil")
    
        local titalIndex = TuJianUtil:getSkillDefalutTuJianType(self.__skillId)

        layer:setName(name)

        layer:setSkillDetailDsc(dsc)
        
        layer:setActiveZhaoList({})

        layer:playWuXueAnim(self.__skillId,titalIndex)
        
        layer:setAutoZhaoDsc(self.__skillId,titalIndex,true)
        
        layer:showLayer()
    end)
end

function ZouXueShiSiJingSkillInfoPresenter:__initZouXueBut()
    local XingZhen = require("app.models.XingZhenEffects.XingZhenEffects")

    local cdTime = XingZhen:getXingZhen("行针走穴CD时间")
    local endTime = XingZhen:getXingZhen("行针走穴结束时间")
    local sanZhenTime = XingZhen:getXingZhen("散针的效果CD")
    local failTime = XingZhen:getXingZhen("行针失败2分钟CD")
    local stopTime = XingZhen:getXingZhen("停针10分钟CD")

    local cdtime = cdTime - GetTime()
    local endtime = endTime - GetTime()
    local sanZhentime = sanZhenTime - GetTime()
    local failtime = failTime - GetTime()
    local stoptime = stopTime - GetTime()

    local butn2,func2,costDesc2,update

    if endtime > 0 then--可以看走穴效果时间
        local a,b,c = Helper:sec2timeDsc(cdTime - GetTime())
        local cdTimetext = a.."小时"..b.."分"..c.."秒"
        costDesc2 = "("..cdTimetext..")"
        butn2 = "正走\n在穴"
        update = function ()
            if cdTime-GetTime() > 0 then
                local a,b,c = Helper:sec2timeDsc(cdTime - GetTime())
                local cdTimetext = a.."小时"..b.."分"..c.."秒"
                costDesc2 = "("..cdTimetext..")"

                self.__ui:setTextDesc2(costDesc2)
            else
                self.__ui:hide(true)

                self.__ui:setTextDesc2(false)
            end
        end
        --跳转到奖励界面
        func2 = function ()
            Audio:playEffect("daAnNiu")
            
            self.__ui:hide(true)
            
            PopupLayerController:showLayer("XingZhenRewardLayer",function(layer)
                local npcDatas = require("script.others.zouxuejing")
                local npcZhenFa = npcDatas.zhenfa
                local id = XingZhen:getXingZhen("针法数据")
                local zhenfaData = npcZhenFa[id]
                layer:showLayer(zhenfaData)
            end)
        end
    elseif sanZhentime > 0 then --散针的效果的CD时间
        local a,b,c = Helper:sec2timeDsc(sanZhenTime - GetTime())
        local cdTimetext = a.."小时"..b.."分"..c.."秒"
        costDesc2 = "("..cdTimetext..")"
        butn2 = "正走\n在穴"
        update = function ()
            if sanZhenTime - GetTime() > 0 then
                local a,b,c = Helper:sec2timeDsc(sanZhenTime - GetTime())
                local cdTimetext = a.."小时"..b.."分"..c.."秒"
                costDesc2 = "("..cdTimetext..")"
                self.__ui:setTextDesc2(costDesc2)
            else
                self.__ui:hide(true)

                self.__ui:setTextDesc2(false)
            end
        end
        --跳转到奖励界面
        func2 = function ()
            Audio:playEffect("daAnNiu")

            self.__ui:hide()
            
            PopupLayerController:showLayer("XingZhenRewardLayer",function(layer)
                local npcDatas = require("script.others.zouxuejing")
                local npcZhenFa = npcDatas.zhenfa
                local id = XingZhen:getXingZhen("散针的效果")
                layer:showLayer(id,1)
            end)
        end
    elseif failtime > 0 then --试针失败2分钟CD
        local a,b,c = Helper:sec2timeDsc(failTime-GetTime())
        local cdTimetext = b.."分"..c.."秒"
        costDesc2 = "("..cdTimetext..")"
        butn2 = "行针"
        update = function ()
            if failTime-GetTime() > 0 then
                local a,b,c = Helper:sec2timeDsc(failTime-GetTime())
                cdTimetext = b.."分"..c.."秒"
                costDesc2 = "("..cdTimetext..")"
                self.__ui:setTextDesc2(costDesc2)
            else
                self.__ui:hide(true)

                self.__ui:setTextDesc2(false)
            end
        end
        func2 = function ()
            Audio:playEffect("daAnNiu")
            self.__ui:hide(true)
            PopText("行针还有"..cdTimetext.."可再次使用")
        end
    elseif stoptime > 0 then --停针10分钟CD
        local a,b,c = Helper:sec2timeDsc(stopTime-GetTime())
        local cdTimetext = b.."分"..c.."秒"
        costDesc2 = "("..cdTimetext..")"
        butn2 = "行针"
        update = function ()
            if stopTime-GetTime() > 0 then
                local a,b,c = Helper:sec2timeDsc(stopTime-GetTime())
                cdTimetext = b.."分"..c.."秒"
                costDesc2 = "("..cdTimetext..")"
                self.__ui:setTextDesc2(costDesc2)
            else
                self.__ui:hide(true)

                self.__ui:setTextDesc2(false)
            end
        end
        func2 = function ()
            Audio:playEffect("daAnNiu")

            self.__ui:hide(true)
            
            PopText("行针还有"..cdTimetext.."可再次使用")
        end
    else
        if cdtime > 0 then--行针针法CD
            local a,b,c = Helper:sec2timeDsc(cdTime-GetTime())
            local cdTimetext = a.."小时"..b.."分"..c.."秒"
            costDesc2 = "("..cdTimetext..")"
            butn2 = "行针"
            update = function ()
                if cdTime-GetTime() > 0 then
                    a,b,c = Helper:sec2timeDsc(cdTime-GetTime())
                    cdTimetext = a.."小时"..b.."分"..c.."秒"
                    costDesc2 = "("..cdTimetext..")"
                    self.__ui:setTextDesc2(costDesc2)
                else
                    self.__ui:hide(true)

                    self.__ui:setTextDesc2(false)
                end
            end
            func2 = function ()
                Audio:playEffect("daAnNiu")

                self.__ui:hide(true)
                
                PopText("行针还有"..cdTimetext.."可再次使用")
            end
        else
            self.__role:clearXingZhenFlag()
            butn2 = "行针"
            func2 = function ()
                Audio:playEffect("daAnNiu")

                local skillLv = self.__role:getSkillLv("zouxueshisijing")--走穴十四经的等级
                if skillLv < 100 then
                    PopText("行针需要走穴十四针达到100级！")
                    return 
                end
                
                self.__ui:hide()
                
                PopupLayerController:showLayer("XingZhenLayer",function(layer)
                    layer:showLayer()
                end)
            end
        end
    end

    self.__ui:setButton2(butn2, func2)

    self.__ui:setTextDesc2(costDesc2)

    self.__ui:unscheduleAll()

    if update then
        self.__ui:schedule(
            function(ft)
                update()
            end,
            1
        )
    end
end

return class("ZouXueShiSiJingSkillInfoPresenter", {BaseSkillInfoPopPresenter}, ZouXueShiSiJingSkillInfoPresenter)
00000000000000
local class = require("third.class.NewClass")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillConst = require("app.models.skill.SkillConst")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local NormalSkillInfoPresenter = {}

function NormalSkillInfoPresenter:create()
    local p = NormalSkillInfoPresenter:new()
    p:init()
    return p
end

function NormalSkillInfoPresenter:init()
end

function NormalSkillInfoPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skillExp = self.__role:getSkillExp(self.__skillId)

    self.__skill = Skill:getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local exp = Helper:mathFloor(self.__skillExp)

    local expDsc = exp.."/"..self.__role:getSkillLvWithRoleLvLimit(self.__skillId).."级"

    local zhaoList = self.__role:getSkillZhaoList(self.__skillId)

    local btn1,func1 = self:__getPrepareBtn()

    local btn2,func2 = self:__getLianGongBtn()

    local btn3 = "详情"

    local func3 = function()
        Audio:playEffect("daAnNiu")

        self.__ui:hide(true)

        self:__showSkilInfo()
    end

	self.__ui:setName(name)
	self.__ui:setSkillStageDsc(desc)
	self.__ui:setSkillDetailDsc(dsc)
	self.__ui:setSkillExpDsc(expDsc)
	self.__ui:setButton1(btn1, func1)
	self.__ui:setTextDesc1(false)
	self.__ui:setButton2(btn2, func2)
	self.__ui:setButton3(btn3, func3)
	self.__ui:setTextDesc2(false)
    self.__ui:setThirdTypeVisible(true)
    self.__ui:setSkillThirdTypes(self:getParentModel():getTextSkillThridTypes())
	self.__ui:setActiveZhaoList(zhaoList)
    self.__ui:setUseTipVisible(false)
    self.__ui:unscheduleAll()
	self.__ui:setImageBackFunc(function()
        if self.__backFunc then
            self.__backFunc()
        end
		self.__ui:hide(true)
	end)

    self.__ui:show(true)
end

function NormalSkillInfoPresenter:__getPrepareBtn()
    local btn1 = nil

    local func1 = EMPTY_FUNC

    if self:getParentModel():skillIsPrepared() == true then
        btn1 = "取装\n消备"

        func1 = function()

            Audio:playEffect("daAnNiu")
            
            self:getParentModel():cancelPrepareSkill()

            self.__parentPresenter:setSkillList()

            self.__ui:hide(true)
        end
    else
        btn1 = "装武\n备功"
        func1 = function()
            Audio:playEffect("daAnNiu")

            local isMulti,prepareTypes = self.__skill:isMultiAttackPrepareType()
            if isMulti == true then
                PopupLayerController:showLayer("SkillSelectPrepareTypePresenter",function (layer)
                    layer:setCallback(function(selectSkillType)
                        self.__role:prepareSkill(selectSkillType,self.__skillId)

                        self.__parentPresenter:setSkillList()

                        self.__ui:hide(true)
                    end)
                    layer:showLayer(self.__skill,prepareTypes)
                end)
                
            else
                self:getParentModel():prepareSkill()

                self.__parentPresenter:setSkillList()

                self.__ui:hide(true)
            end
        end
    end

    return btn1,func1
end

function NormalSkillInfoPresenter:__getLianGongBtn()
    local btn2 = "练功"

    local func2 = function()
        Audio:playEffect("daAnNiu")

        self.__ui:hide(true)

        local canLg,msg = self:getParentModel():canLianGong()

        if canLg == true then
            self:__showLianGongLayer()
        else
            PopText(msg)
        end
    end

    if self.__role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
        local currSkillId = self.__role:getLianGongSystem():getSkillId()
        if currSkillId == self.__skillId then
            btn2 = "正练\n在功"

            func2 = function()
                Audio:playEffect("daAnNiu")
        
                self.__ui:hide(true)
        
                self:__showLianGongingLayer()
            end
        end
    end

    return btn2,func2
end

function NormalSkillInfoPresenter:__showLianGongingLayer()
	self.__role:getXinShenSystem():getXinShenValue(function(ok, data)
		if ok then
			self.__role:getLianGongSystem():getLianGongTiLi(function(ok,errmsg,tiliData)
				if ok then
					PopupLayerController:showLayer("LianGongDetailPresenter",function(layer)
						layer:setXinShen(data.curr)
						layer:setXinShenMax(data.max)
						layer:setTiLi(tiliData.currTiLi)
						layer:setTiLiMax(tiliData.maxTiLi)
						layer:showLayer()
						layer:setCallBack(function()
                            self.__parentPresenter:setSkillList()
						end)
					end)
				else
					PopText(errmsg)
				end
			end)
		else
			local msg = data
			PopText(msg)
		end
	end)
end

function NormalSkillInfoPresenter:__showLianGongLayer()
    self.__role:getXinShenSystem():getXinShenValue(
        function(ok, data)
            if ok then
                self.__role:getLianGongSystem():getLianGongTiLi(function(ok,errmsg,tiliData)
                    if ok then
                        local prepareType = self:getParentModel():getCurrTabSkillType()

                        if prepareType == "bingqi" then
                            prepareType = self:getParentModel():getCurrBingQiPrepareType()
                        end

                        local jibenSkillId = SkillConst.PrepareList[prepareType]

                        local jiBenLv = self.__role:getSkillLv(jibenSkillId)

                        PopupLayerController:showLayer(
                            "LianGongPresenter",
                            function(layer)
                                layer:setXinShen(data.curr)
                                layer:setXinShenMax(data.max)
                                layer:setTiLi(tiliData.currTiLi)
                                layer:setTiLiMax(tiliData.maxTiLi)
                                layer:setJiBenSkillLv(jiBenLv)
                                layer:showLayer(self.__skillId)
                                layer:setCallBack(
                                    function()
                                        if data.curr <= 0 then
                                            PopText("你的心神不足，无法静下心来修习功法。")
                                            return
                                        end
                                        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                                        local dialog = DialogALayer:getInstance()
                                        dialog:hide()
                                        dialog:show("练功时长不足一分钟时手动结束无收益，开始练功时加速练功的精力会全部消耗，本次练功会上传存档，少侠是否确认开始练功？")
                                        dialog:setButton1(
                                            "确定",
                                            function()
                                                self:__startLianGong(prepareType)
                                            end
                                        )
                                        dialog:setButton2("取消")
                                        dialog:setWeChatVisible(false)
                                    end
                                )
                            end
                        )
                    else
                        PopText(errmsg)
                    end
                end)
            else
                local msg = data
                PopText(msg)
            end
        end
    )
end

function NormalSkillInfoPresenter:__showSkilInfo()
    local name = self.__skill:getName()

    local dsc = self.__skill:getDsc()

    PopupLayerController:showLayer("TuJianSkillInFoPopLayer", function(layer)
        layer:setName(name)

        layer:setSkillDetailDsc(dsc)
        
        layer:setActiveZhaoList(self.__role:getSkillZhaoList(self.__skillId))

        local TuJianUtil = require("app.models.TuJian.TuJianUtil")

		local titalIndex = TuJianUtil:getSkillDefalutTuJianType(self.__skillId)

        layer:playWuXueAnim(self.__skillId,titalIndex)
        
        layer:setAutoZhaoDsc(self.__skillId,titalIndex,self.__role:getSkillStatus(self.__skillId) == SKILL_STATE_GRASP)
        
        layer:showLayer()
    end)
end

function NormalSkillInfoPresenter:__startLianGong(prepareType)
    RoleTaskControllor:clickLianGongLayer(
        self.__skillId,
        function()
            HttpManagerEx:uploadUserData(
                "shangchuan",
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 and errcode == 0 then
                        self.__role:getLianGongSystem():startLianGongOnline(
                            prepareType,
                            function(ok, msg)
                                if ok then
                                    local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
                                    if HomelandUtil:isRoomByTypeFromFlag("tsfangjian009") then
                                        RichPrint("main", "你走入练功房，收拾心情，开始专心练习[" .. self.__skill:getName() .. "]")
                                    else
                                        RichPrint("main", "你试着开始练习[" .. self.__skill:getName() .. "]")
                                    end
                                else
                                    PopText(msg)
                                end
                            end
                        )
                        return true
                    else
                        PopText(errmsg)
                        return false
                    end
                end,
                IS_SHOW_WAITING,
                HTTP_MANAGER_RETRY_TYPE_RETRY
            )
        end,
        function()
            self:__showLianGongLayer()
        end,
        function()
            self.__parentPresenter:setSkillList()
        end,
        function()
            self.__parentPresenter:setSkillList()
        end
    )
end

return class("NormalSkillInfoPresenter", {BaseSkillInfoPopPresenter}, NormalSkillInfoPresenter)
000000000000
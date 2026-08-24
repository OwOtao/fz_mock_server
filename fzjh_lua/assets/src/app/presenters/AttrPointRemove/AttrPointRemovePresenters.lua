local class = require("third.class.NewClass")
local SkillConst = require("app.models.skill.SkillConst")

local desc_1 = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.DESC_TRANSFORM_MONEY)
local desc_2 = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.DESC_TRANSFORM_MONEYCOST)
local desc_3 = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.INFO_TRANSFORM_MONEY_SUCCESS)
local desc_4 = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TIPS_TRANSFORM_MONEY_SUCCESS)
local desc_5 = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.INFO_TRANSFORM_SKILLDSC)
local desc_6 = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.DESC_SKILLUSE)

local AttrPointRemovePresenters = {}

function AttrPointRemovePresenters:create()
    return AttrPointRemovePresenters:new()
end

function AttrPointRemovePresenters:ctor()
end

function AttrPointRemovePresenters:setRole(role)
    self.__input:setRole(role)
end

function AttrPointRemovePresenters:setViewModel(iViewModel)
    self.__output = iViewModel
end

function AttrPointRemovePresenters:setDataModel(iDataModel)
    self.__input = iDataModel
end

function AttrPointRemovePresenters:showLayer()
    self.__input:getInfo(function()
        PopupLayerController:showLayer("AttrPointRemoveLayer", function(layer)
            self:initUI()
            self.__output:showUI()
        end)
    end)
end

function AttrPointRemovePresenters:initUI()
    local attrMap = self.__input:getAttrList()
    for __, attr in pairs(attrMap) do
        self.__output:initAttrBtnFunc(attr,function()
            self:__confirmButton(attr)
        end)
    end

    self:__refreshUI()
end

function AttrPointRemovePresenters:__confirmButton(attr)
    if not attr then 
		return 
	end

	self.__input:setAttrType(attr)

	local attrName = self.__input:getAttrName(attr)
    local skillAdd = self.__input:getSkillRemovePoint()
	local skillName = self.__input:getSkillName()
    local attrPointRemoveNum = self.__input:getBaseRemovePoint()
    local unitPrice = self.__input:getUnitPrice()
    local npcName = self.__input:getNpcName()

	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()

	local str5,str6 = "",""
	if skillAdd > 0 then
		str5 = string.gsub(desc_5, "$(%w+)",{skillN = skillName,tranS = skillAdd})
		str6 = string.gsub(desc_6, "$(%w+)",{attrN = attrName,tranS = skillAdd})
	end

	local str1 = string.gsub(desc_1, "$(%w+)",{attrN = attrName,tran = attrPointRemoveNum})
	local str2 = string.gsub(desc_2, "$(%w+)",{cost = unitPrice})
	local str3 = string.gsub(desc_3, "$(%w+)",{cost = unitPrice,npcN = npcName,tranA = attrPointRemoveNum + skillAdd, attrN = attrName,skillDsc = str5})
	local str4 = string.gsub(desc_4, "$(%w+)",{attrN = attrName,tran = attrPointRemoveNum + skillAdd})

	dialog:show(str1,str2)
	dialog:setExtraDescVisible(true)
	dialog:setExtraDesc(str6)
    dialog:setButton1("确定", function()
        self.__input:doRemoveFunc(function()
            PopText(str4)
            RichPrint("main", str3)
            self:initUI()
            end,function()
                PopText(errmsg)
                RichPrint("main", "YEL"..npcName.."：少侠身上的元宝不足，还是带齐再来吧。")
            end)
    end)
    dialog:setButton2("取消", function()
    end)
    dialog:setWeChatVisible(false)
end

function AttrPointRemovePresenters:__refreshUI()
    self.__output:setXiSuiTimesText("可洗髓次数  "..tostring(self.__input:getTimes()))
	self.__output:setTotalAttrPointText("可分配先天属性点  "..tostring(self.__input:getTotalPoint()))

    local attrMap = self.__input:getAttrList()
    for k, attr in pairs(attrMap) do
        self.__output:setAttrPointText(attr,self.__input:getRoleAttr(attr))
    end

    self:__refreshBtn()

    if self.__input:checkIsCoolState() then
        self.__output:setCoolTimeVisible(true)
        self.__output:setUpdateFunc(function()
            self:__update()
        end)
        self.__output:startTimeSchedule()
    else
        self.__output:setCoolTimeVisible(false)
    end
end

function AttrPointRemovePresenters:__refreshBtn()
    local timesIsEnough = self.__input:checkTimesIsEnough()
    local attrMap = self.__input:getAttrList()

    for k, attr in pairs(attrMap) do
        local btn_enable = true
        local btn_texture = "Image/UI/AttrUI/neidan1.png"

        if timesIsEnough == false or (timesIsEnough and self.__input:checkAttrIsMeetTheConditions(attr) == false) then
            btn_enable = false
            btn_texture = "Image/UI/AttrUI/neidan1b.png"
        end

        self.__output:setAttrPointText(attr,self.__input:getRoleAttr(attr))
        self.__output:setAttrBtnTouchEnable(attr,btn_enable)
	    self.__output:setAttrBtnTexture(attr,btn_texture)
    end
end

function AttrPointRemovePresenters:__update(ft)
    local endTime = self.__input:getEndTime()
	local remainingTime = endTime - GetTime()

	if remainingTime <= 0 then 
		self.__output:endTimeSchedule()
        self.__input:getInfo(function()
            self:initUI()
        end)
	end

	local hourTime = math.floor(remainingTime / 3600)
	local minuteTime = math.floor(remainingTime % 3600 / 60)
	local secondTime = math.floor(remainingTime % 60)

	if hourTime < 10 then
		hourTime = "0"..tostring(hourTime) 
	end

	if minuteTime < 10 then
		minuteTime = "0"..tostring(minuteTime) 
	end

	if secondTime < 10 then
		secondTime = "0"..tostring(secondTime) 
	end

	local timeStr = hourTime..":"..minuteTime..":"..secondTime

	self.__output:setCoolTime("冷却时间："..timeStr)
end

return class("AttrPointRemovePresenters", {}, AttrPointRemovePresenters)
000000000
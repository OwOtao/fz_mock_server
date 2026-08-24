local LianGongDetailPresenter = class("LianGongDetailPresenter", cc.Layer)

local Role = require("app.models.role.Role")

function LianGongDetailPresenter:create()
    local p = LianGongDetailPresenter.new()
    p:__init()
    return p
end

function LianGongDetailPresenter:__init()
    self.__ui = require("app.views.ui.LianGongUI.LianGongDetailUI"):create()

    self.__ui:addTo(self)
end

function LianGongDetailPresenter:showLayer()
    self.__lianGongSystem = User:getRole():getLianGongSystem()

    self._player = self.__lianGongSystem:getPlayer()

    local skillId = self.__lianGongSystem:getSkillId()

    self._skillId = skillId

    self._skill = Skill:getSkill(skillId)

    --@desc 练功时否完成
    self.__isFinish = false

    if self.__lianGongSystem:checkLianGongIsFinish() then
        self.__isFinish = true
    end

    self:setTextTitle()

    self:setTextTip()

    self:setTextXinShenNum()

    self:setTextTiLiNum()

    self:setButton1()

    self:setButton2()

    self:setButton3()

    self:setListView()

    self.__ui:showUI()

    if self._handle then
        self:unschedule(self._handle)
        self._handle = nil
    end
    
    self._handle =
        self:schedule(
        function(ft)
            if self.__lianGongSystem:checkLianGongIsFinish() then
                self:unschedule(self._handle)
                self._handle = nil

                self.__isFinish = true
                
                self:setButton1()

                self:setButton2()

                self:setButton3()

                self:setTextTitle()

            end
            self:setTextTip()

            self:setListView()
        end,
        1
    )
end

function LianGongDetailPresenter:setXinShen(xinshen)
    self._xinshen = xinshen
end

function LianGongDetailPresenter:setXinShenMax(xinshenMax)
    self._xinshenMax = xinshenMax
end

function LianGongDetailPresenter:setTiLi(tili)
    self._tili = tili
end

function LianGongDetailPresenter:setTiLiMax(tiliMax)
    self._tiliMax = tiliMax
end

function LianGongDetailPresenter:setCallBack(callback)
    self.__callback = callback
end

function LianGongDetailPresenter:setTextTitle()
    if self.__isFinish then
        self.__ui:setTextTitle("练功完成")
    else
        self.__ui:setTextTitle("练功中")
    end
end

function LianGongDetailPresenter:setTextTip()
	if self.__isFinish then
        self.__ui:setTextTip("已完成练功，点击完成结算收益")
    else
        if self.__lianGongSystem:checkLianGongCanProfit() then
            self.__ui:setTextTip("取消动作将立即结算当前收益")
        else
            self.__ui:setTextTip("练功不足一分钟，取消动作无收益")
        end
    end
end

function LianGongDetailPresenter:setTextXinShenNum()
    self.__ui:setTextXinShenNum("心神：" .. self._xinshen .. "/" .. self._xinshenMax)
end

function LianGongDetailPresenter:setTextTiLiNum()
    self.__ui:setTextTiLiNum(Role:getCHAttrName("lianGongTiLi").."：" .. self._tili .. "/" .. self._tiliMax)
end

function LianGongDetailPresenter:setListView()
    local retArray = {}

    table.insert(retArray, {title = "练功剩余心神：", content = self.__lianGongSystem:getBackXinShen()})

    table.insert(retArray, {title = "练功剩余"..Role:getCHAttrName("lianGongTiLi").."：", content = self.__lianGongSystem:getBackTiLi()})

    local hour, min, sec = Helper:sec2timeDsc(self.__lianGongSystem:getResidueTime())

    table.insert(retArray, {title = "练功剩余时间：", content = hour .. "小时" .. min .. "分钟" .. sec .. "秒"})

    table.insert(retArray, {title = "武功：", content = self._skill.name})

    table.insert(retArray, {title = "等级变化：", content = self._player:getSkillLv(self._skillId) .. "→" .. self._player:getSkillLv(self._skillId, self.__lianGongSystem:getPredictExp())})

    local addExp,spillExp = self.__lianGongSystem:calLianGongExpAndSpillExp()

    table.insert(retArray, {title = "当前等级：", content = self._player:getSkillLv(self._skillId, addExp)})

    table.insert(retArray, {title = "增加经验：", content = addExp})

    if spillExp > 0 then
        table.insert(retArray, {title = "溢出经验：", content = spillExp})

		self.__ui:setTextSpillExpDsc("本次练功有溢出经验，建议突破武学等级后再完成练功")
	else
		self.__ui:setTextSpillExpDsc("")
    end

    self.__ui:setListView(retArray)
end

function LianGongDetailPresenter:setButton1()
    local buttonName = "结束练功"
    local callback = function()
        PopText("结束练功")
        self.__lianGongSystem:stopLianGongOnline(
            function(ok, msg)
                if ok then
                    if self.__callback then
                        self.__callback()
                    end

                    self:hideLayer()

                    if msg then
                        PopText(msg)
                    end
                else
                    PopText(msg)
                end
            end
        )
    end

    if self.__isFinish then
        buttonName = "完成练功"
    end

    self.__ui:setButton1(buttonName,callback)
end

function LianGongDetailPresenter:setButton2()
    local buttonName = "行功散"
    local callback = function()
        local item = Item:getOneItemByKey("xinggongsan")

        local xgsNum = self._player:getItemCount("xinggongsan")

        if item and xgsNum > 0 then
            if self.__lianGongSystem:checkLianGongIsFinish() then
                PopText("练功已完成，无法使用行功散")
                return
            end

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:hide()
            dialog:show(tostring(item.dsc), "将消耗一" .. tostring(item.unit) .. tostring(item.name) .. "，是否确定？")
            dialog:setButton1("是", function()
                self.__lianGongSystem:useXingGongSan(
                    1,
                    function(ok,msg)
                        if ok then 
                            item:storeItemUse(
                                function()
                                    PopText("你服用下行功散，减少练功时长")
                                end,
                                false
                            )
                        else
                            PopText(msg)
                        end
                    end
                )
            end)
            dialog:setButton2("否", function()
            end)
            dialog:setBack(false)
            dialog:setWeChatVisible(false)
        else
            PopText("行功散数量不足")
        end
    end

    if self.__isFinish then
        buttonName = "关闭"
        callback = function()
            self:hideLayer()
        end
    end

    self.__ui:setButton2(buttonName,callback)
end

function LianGongDetailPresenter:setButton3()
    local buttonName = "关闭"
    local callback = function()
        self:hideLayer()
    end

    if self.__isFinish then
        buttonName = nil
    end

    self.__ui:setButton3(buttonName,callback)
end

function LianGongDetailPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "LianGongDetailPresenter",
        function(layer)
            if self._handle ~= nil then
                self:unschedule(self._handle)
                self._handle = nil
            end
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(LianGongDetailPresenter)
return LianGongDetailPresenter
0000000
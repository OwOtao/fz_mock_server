local XuJuanStorePresent = class("XuJuanStorePresent", cc.Layer)

function XuJuanStorePresent:create()
    local p = XuJuanStorePresent:new()
    p:init()
    return p
end

function XuJuanStorePresent:init()
    self._UI = require("app.views.ui.ActionUI.StoreUI"):create()

    self._UI:addTo(self)

    local XuJuanStore = require("app.models.Store.XuJuanStore")

    self._interactor = XuJuanStore:create()
end

function XuJuanStorePresent:showLayer()
    self._interactor:getInfo(function()
        self:initUI()
        self._UI:showUI()
    end)
end

function XuJuanStorePresent:setNpcName(name)
    self._npcName = name
end

function XuJuanStorePresent:hideLayer()
    PopupLayerController:hideLayer("XuJuanStorePresent",function()
        self._UI:hideUI()
    end)
end 

function XuJuanStorePresent:initUI()
    self._UI:setDesc("")
    self._UI:setWeightText("")
    self._UI:setTipsVisible(true)
    self._UI:setTips("每天0点自动刷新\n此次刷新免费")
    self._UI:setLeftTitle("背包")
    self._UI:setRightTitle(self._npcName)
    self._UI:setCurrencyText(self._interactor:getCurrencyName().."："..self._interactor:getCurrencyNum())

    if self._interactor:getSpendYuanBao() > 0 then
        self._UI:setTips("每天0点自动刷新\n或花费"..tostring(self._interactor:getSpendYuanBao()).."元宝")
    end

    if self._interactor:getIsRefreshLimit() then
        self._UI:setTips("每天0点自动刷新\n已达到刷新上限")
    end

    self:__initLeftList()
    self:__initRightList()
    self:__initRefreshButton()
end

function XuJuanStorePresent:__initLeftList()
    self._UI:setLeftList(self._interactor:getLeftList())
end

function XuJuanStorePresent:__initRightList()
    local list = self._interactor:getRightList()
    for k,v in pairs(list) do
        v.func = function()
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()

            dialog:show(tostring(v.name).."\n\n"..tostring(v.dsc).."\n花费:"..tostring(v.price),"是否确定购买")
            dialog:setButton1("是", function() 
                self._interactor:buyGoods(v.goodsId,function()
                    self._interactor:getInfo(function()
                        self:initUI()
                    end)
                end)
            end)
            dialog:setButton2("否")
            dialog:setWeChatVisible(false)
        end
    end

    self._UI:setRightList(list)
end

function XuJuanStorePresent:__initRefreshButton()
    self._UI:setButton1Name("立即刷新")
    self._UI:setButton1Pos(270, 130)
    self._UI:setButton1Func(function()
        if self._interactor:getIsRefreshLimit() then
            PopText("已达到每日刷新次数上限。")
            return
        end

        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        local text = ""
        if self._interactor:getSpendYuanBao() == 0 then
            text = "此次刷新免费"
        else
            text = "刷新将消耗"..tostring(self._interactor:getSpendYuanBao()).."元宝"
        end

        dialog:show(text,"是否确定")
        dialog:setButton1("确定", function()
            self._interactor:refresh(function()
                self:initUI()
            end)
        end)
        dialog:setButton2("取消")
        dialog:setWeChatVisible(false)
    end)

    self._UI:setButton2Name("关闭")
    self._UI:setButton2Pos(810, 130)
    self._UI:setButton2Func(function()
        self:hideLayer()
    end)
end

Helper:classDefNodeGetInstance(XuJuanStorePresent)
return XuJuanStorePresent00000000
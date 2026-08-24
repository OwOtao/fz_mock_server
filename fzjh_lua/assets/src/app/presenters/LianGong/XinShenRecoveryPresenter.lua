local XinShenRecoveryPresenter = class("XinShenRecoveryPresenter", cc.Layer)

function XinShenRecoveryPresenter:create()
    local p = XinShenRecoveryPresenter.new()
    p:__init()
    return p
end

function XinShenRecoveryPresenter:__init()
    self.__ui = require("app.views.ui.LianGongUI.XinShenRecoveryUI"):create()

    self.__ui:addTo(self)
end

function XinShenRecoveryPresenter:showLayer()
    self.__xinShenSystem = User:getRole():getXinShenSystem()

    self.__player = self.__xinShenSystem:getPlayer()

    self.__nextRecoverTime = math.max(0,math.floor(self.__xinShenSystem:getXinShenRecoverInterval() - (GetTime() - self.__recoverTime) % self.__xinShenSystem:getXinShenRecoverInterval()))

    self:setCurrXinShenText()

    self:setCurrXinShenMaxText()

    self:setXinShenRecover()

    self:setItems()

    self:setPanelBack()

    self.__ui:showUI()

    if self._handle then
        self:unschedule(self._handle)
        self._handle = nil
    end

    self:createHandle()
end

function XinShenRecoveryPresenter:createHandle()
    if self._handle then
        return
    end
    
    self._handle =
        self:schedule(
        function(ft)
            if self.__xinshen >= self.__xinshenMax then
                self:unschedule(self._handle)
                self._handle = nil
                return
            end

            self.__nextRecoverTime = math.max(0,math.floor(self.__xinShenSystem:getXinShenRecoverInterval() - (GetTime() - self.__recoverTime) % self.__xinShenSystem:getXinShenRecoverInterval()))

            if self.__nextRecoverTime <= 0 then
                local newXinShen = math.min(self.__xinshen + self.__xinShenSystem:getXinShenRecoverValue(),self.__xinshenMax)

                self:setXinShen(newXinShen)

                self:setCurrXinShenText()

                if self.__callBack then
                    self.__callBack(newXinShen)
                end
            end

            self:setXinShenRecover()
        end,
        1
    )
end

function XinShenRecoveryPresenter:setRecoverTime(time)
    self.__recoverTime = time
end

function XinShenRecoveryPresenter:setXinShen(xinshen)
    self.__xinshen = xinshen
end

function XinShenRecoveryPresenter:setXinShenMax(xinshenMax)
    self.__xinshenMax = xinshenMax
end

function XinShenRecoveryPresenter:setRecoverItemMap(itemMap)
    self.__itemMap = itemMap
end

function XinShenRecoveryPresenter:setCallBack(callBack)
    self.__callBack = callBack
end

function XinShenRecoveryPresenter:setCurrXinShenText()
    self.__ui:setCurrXinShenText(self.__xinshen)
end

function XinShenRecoveryPresenter:setCurrXinShenMaxText()
    self.__ui:setCurrXinShenMaxText(self.__xinshenMax)
end

function XinShenRecoveryPresenter:setXinShenRecover()
    local text = ""

    if self.__xinshen >= self.__xinshenMax then
        text = "当前心神已达到心神上限"
    else
        local hour,min,sec = Helper:sec2timeDsc(self.__nextRecoverTime)

        local recoverValue = self.__xinShenSystem:getXinShenRecoverValue()

        text = min.."分钟"..sec.."秒后恢复"..recoverValue.."点心神"
    end

    self.__ui:setXinShenRecover(text)
end

function XinShenRecoveryPresenter:setItems()
    local itemIds = {"minditem1","minditem2","minditem3","minditem4"}

    for i,itemId in ipairs(itemIds) do
        local retData = {}
        local count = self:getItemCount(itemId)
        local itemIdData = self.__xinShenSystem:getItemData(itemId)

        retData["image"] = itemIdData.image
        retData["name"] = itemIdData.name.."x"..count
        retData["recovery"] = itemIdData.des
        retData["func"] = function()
            if count < 1 then
                PopText(itemIdData.name.."不足")
                return
            end

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:hide()
            dialog:show(itemIdData.text,"将消耗一个"..itemIdData.name.."，是否确定？")
            dialog:setButton1("确定",function()
                self.__xinShenSystem:useItem(itemId, function(ok,data)
                    if ok then
                        self:reduceItemCount(itemId)

                        local xinshen = math.min(self.__xinshen + itemIdData.effect, self.__xinshenMax)

                        self:setXinShen(xinshen)

                        self:setCurrXinShenText()

                        self:setXinShenRecover()

                        if self.__callBack then
                            self.__callBack(xinshen)
                        end

                        self.__ui:setPanelItemConut(i,itemIdData.name.."x"..self:getItemCount(itemId))

                        PopText("心神+"..itemIdData.effect)
                    else
                        PopText(data)
                    end
                end)
            end)
            dialog:setButton2("取消",function()
            end)
            dialog:setWeChatVisible(false)
        end

        self.__ui:setPanel(i,retData)
    end
end

function XinShenRecoveryPresenter:getItemCount(itemId)
    local count = 0
    
    if self.__itemMap[itemId] then
        count = self.__itemMap[itemId].count
    end

    return count
end

function XinShenRecoveryPresenter:reduceItemCount(itemId)
    if self.__itemMap[itemId] then
        self.__itemMap[itemId].count = self.__itemMap[itemId].count - 1
    end
end

function XinShenRecoveryPresenter:setPanelBack()
    self.__ui:setPanelBack(
        function()
            self:hideLayer()
        end
    )
end

function XinShenRecoveryPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "XinShenRecoveryPresenter",
        function(layer)
            if self._handle then
                self:unschedule(self._handle)
                self._handle = nil
            end
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(XinShenRecoveryPresenter)
return XinShenRecoveryPresenter
000000000
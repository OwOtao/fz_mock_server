local QiXiCheckInfoLayer = class("QiXiCheckInfoLayer", cc.Layer)

local MIANJUID = "mianju1068"

local USE_TYPE = {
    ITEM = 1,
    MIANJU = 2
}

function QiXiCheckInfoLayer:create()
    local p = QiXiCheckInfoLayer:new()
    p:init()
    return p
end

function QiXiCheckInfoLayer:init()
    self._UI = require("Layer/Dialog/DialogUI").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self.Image_weixin:setVisible(false)
    self.Text_desc:setVisible(false)
    self.Text_text:setFontSize(48)
end

function QiXiCheckInfoLayer:setText(text)
    self.Text_text:setString(text)
end

function QiXiCheckInfoLayer:setTextVisiable(bool)
    if bool == nil then
        bool = true
    end

    self.Text_text:setVisible(bool)
end

function QiXiCheckInfoLayer:showLayer(npc)
    self._npc = npc

    self.Text_text:setTextHorizontalAlignment(1)
    self.Text_text:setTextColor({r = 208, g = 208, b = 208})

    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    if role:getPortraitId() == MIANJUID then
        self._useType = USE_TYPE.MIANJU
    else
        self._useType = USE_TYPE.ITEM
    end

    local text = ""
    local itemAttr = Item:getOneItemByKey("shipodaoju")
    if self._useType == USE_TYPE.MIANJU then
        text = "你拥有桃花仙子面具，可以直接查看该人物真实信息，确定查看吗？"
    else
        text = "消耗一个" .. itemAttr.name .. "以查看该人物所有隐藏信息，确定要使用吗？"
    end

    self:setText(text)

    self.Button_1.Text_name:setString("确定")
    self.Button_1:releaseFunc(
        function()
            local itemCount = role:getItemCount("shipodaoju")
            if self._useType == USE_TYPE.ITEM then
                --@RefType [app.models.role.Role#Role]
                local role = User:getRole()
                if itemCount <= 0 then
                    PopText("您没有" .. itemAttr.name)
                    return
                end
            end
            
            self.Text_text:setTextHorizontalAlignment(0)
            local old_desc = self._npc.dsc
            self:setText(old_desc)
            self:setTextVisiable(true)
            
            self.Button_2:setVisible(false)
            
            self.Button_1.Text_name:setString("查看信息")
            self.Button_1:releaseFunc(
                function()
                    if  self._useType == USE_TYPE.ITEM and itemCount > 0 then
                        role:addItemCount("shipodaoju", -1)
                        PopText("你消耗了 " .. itemAttr.name .. " X1")
                    end

                    local role = User:getRole()

                    local QiXiUtil = require("app.models.Action.ChineseValentine.2018.QiXiUtil")

                    self._npc.dsc = QiXiUtil:getAllTrueInfo(self._npc)

                    local roleDayInfo = role:getDayFlag("qxnpcinfo")

                    local npc_info = roleDayInfo[self._npc.id]

                    if npc_info ~= nil and MapIsEmpty(npc_info) == false then
                        npc_info.isTrue = 1
                        self._npc.caozuo3 = 0
                        role:setDayFlag("qxnpcinfo", roleDayInfo)
                    end

                    self.Button_1:setVisible(false)
                    
                    self:startRunAction()
                end
            )
        end
    )

    self.Button_2:setVisible(true)
    self.Button_2.Text_name:setString("再想想")
    self.Button_2:releaseFunc(
        function()
            self:hideLayer()
        end
    )
    self:show()
end

function QiXiCheckInfoLayer:hideLayer()
    PopupLayerController:hideLayer(
        "QiXiCheckInfoLayer",
        function(layer)
            layer:hide()
        end
    )
end

function QiXiCheckInfoLayer:startRunAction()
    self.Button_1:setTouchEnabled(false)

    local fadeInAction = cc.FadeIn:create(1)

    local delayAction = cc.DelayTime:create(0.5)

    local fadeOutAction = cc.FadeOut:create(1)

    local secAnimEndAciton =
        cc.CallFunc:create(
        function()
            self.Button_1:setVisible(true)
            self.Button_1.Text_name:setString("确认")
            self.Button_1:setTouchEnabled(true)
            self.Button_1:releaseFunc(
                function()
                    self:hideLayer()
                end
            )
        end
    )

    local firstAnimEndAction =
        cc.CallFunc:create(
        function()
            local QiXiUtil = require("app.models.Action.ChineseValentine.2018.QiXiUtil")
            local new_desc = QiXiUtil:getAllTrueInfo(self._npc)
            self:setText("YEL"..new_desc)
        end
    )

    local action1 = cc.Sequence:create(cc.DelayTime:create(1.0), fadeOutAction, firstAnimEndAction)

    local action2 = cc.Sequence:create(delayAction, fadeInAction, secAnimEndAciton)

    local action = cc.Sequence:create(action1, action2)

    self.Text_text:runAction(action)
end

Helper:classDefNodeGetInstance(QiXiCheckInfoLayer)
return QiXiCheckInfoLayer
00
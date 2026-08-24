--房屋事务界面
local RoomAffairLayer = class("RoomAffairLayer", LayerEx)

--@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

--@RefType [app.models.HomelandModel.AffairModel.Affair#Affair]
local Affair = require("app.models.HomelandModel.AffairModel.Affair")

--@RefType [app.models.HomelandModel.AffairModel.AffairUtil#AffairUtil]
local AffairUtil = require("app.models.HomelandModel.AffairModel.AffairUtil")

local HomelandRoleTemplate = require("app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate")

function RoomAffairLayer:create()
    local p = RoomAffairLayer:new()
    p:init()
    return p
end

function RoomAffairLayer:init()
    local UI = require("Layer/HomelandUI/RoomAffairUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setShowAndHideAnimType("ROLL")
    self:setBack()
end

--设置返回
function RoomAffairLayer:setBack()
    self.Image_titleBack.Button_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

function RoomAffairLayer:hideLayer()
    PopupLayerController:hideLayer(
        "RoomAffairLayer",
        function(layer)
            if self.__operationAffair ~= nil then
                self.__operationAffair = nil
            end

            if self.__messageAffair ~= nil then
                self.__messageAffair = nil
            end

            AffairUtil:clearList()
            layer:hide()
        end
    )
end

function RoomAffairLayer:showLayer(server_data)
    self:initAffairList(server_data)

    self.__currTitleIndex = 1
    
    self:initPanelTitle()

    self:showCurrPanel()

    self:show()
end

function RoomAffairLayer:initAffairList(server_data)
    self.__affairList = {
        {name = "欠薪名册", list = {}},
        {name = "府务定夺", list = {}},
        {name = "家务简报", list = {}}
    }


    if MapIsEmpty(server_data) then
        return
    end

    table.sort(
        server_data,
        function(a, b)
            local rest = true
            if a.biz_type == 1 and b.biz_type == 1 then
                rest = a.affair_id < b.affair_id
            elseif a.biz_type == 1 and b.biz_type ~= 1 then
                rest = true
            elseif a.biz_type ~= 1 and b.biz_type == 1 then
                rest = false
            else
                print("a.createtime = ", a.createtime)
                print("b.createtime = ", b.createtime)
                rest = a.create_time < b.create_time
            end
            return rest
        end
    )

    for index, affair_data in ipairs(server_data) do
        local affair = Affair:create(affair_data)
        if affair:getType() == 1 then
            table.insert(self.__affairList[1].list,affair)
        elseif affair:getType() == 2 then
            table.insert(self.__affairList[2].list,affair)
        elseif affair:getType() == 3 then
            table.insert(self.__affairList[3].list,affair)
        else
            error("事务类型异常"..affair:getType())
        end
    end
end

function RoomAffairLayer:setPanelHighLight()
    for i = 1,3 do
        local panel = self.Panel_title["Panel_"..i]
        if i == self.__currTitleIndex then
            panel.Image_hongdi:setVisible(true)
        else
            panel.Image_hongdi:setVisible(false)
        end
    end
end

function RoomAffairLayer:initPanelTitle()
    for i,v in ipairs(self.__affairList) do
        local panel = self.Panel_title["Panel_"..i]
        panel.Text_name:setString(v.name)
        panel:releaseFunc(
            function()
                self.__currTitleIndex = i
                self:showCurrPanel()
            end
        )
    end
end

function RoomAffairLayer:showCurrPanel()
    self:setPanelHighLight()

    if self.__currTitleIndex == 1 then
        self:showPanelRegister()
        self.Panel_operation:setVisible(false)
        self.Panel_message:setVisible(false)
    elseif self.__currTitleIndex == 2 then
        self:showPanelOperation()
        self.Panel_register:setVisible(false)
        self.Panel_message:setVisible(false)
    elseif self.__currTitleIndex == 3 then
        self:showPanelMessage()
        self.Panel_register:setVisible(false)
        self.Panel_operation:setVisible(false)
    end
end

function RoomAffairLayer:setPanelShow(title,desc)
    self.Panel_Show:setVisible(true)
    self.Panel_Show.Text_title:setString(title)
    self.Panel_Show.Text_desc:setString(desc)
    self.Panel_Show:releaseFunc(
        function()
            self.Panel_Show:setVisible(false)
        end
    )
end

function RoomAffairLayer:initRegisterTextAndButtonComfirm()
    local isSelect = false
    local selectList = {}
    local sumYuanBao = 0
    local sumYinPiao = 0
    local role = User:getRole()
    local map = role:getCurrMap()

    local registerList = self.__affairList[1].list

    for i,affair in ipairs(registerList) do
        if affair.select == true then
            isSelect = true
            table.insert(selectList, affair.id)
            if affair.affair_val.pay_unit == "yinpiao" then
                sumYinPiao = sumYinPiao + affair.cost
            elseif affair.affair_val.pay_unit == "yuanbao" then
                sumYuanBao = sumYuanBao + affair.cost
            end
        end
    end

    local panel = self.Panel_register

    panel.Text_1:setString("总计发薪："..sumYuanBao.."元宝，"..sumYinPiao.."银票")

    if isSelect then
        panel.Button_confirm:setEnabled(true)
        panel.Button_confirm:releaseFunc(function()
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:hide()
            dialog:show("本次薪资发放共需"..sumYuanBao.."元宝，"..sumYinPiao.."银票，是否确认发薪？")
            dialog:setButton1(
                "同意",
                function()
                    HttpManagerEx:processPayAffairs(
                        selectList,
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    for i = #registerList,1,-1 do
                                        local affair = registerList[i]
                                        if affair.select == true then
                                            table.remove(registerList,i)
                                        end
                                        
                                        local npcId = affair.affair_val.rwId
                                        local npc = map:getRole(npcId)
                                        if npc and npc.extra and npc.extra.naoshi ~= 0 then
                                            npc.extra.naoshi = 0
                                            npc.conditionAndResults = {}
                                            HomelandRoleTemplate:initRoleConditions(npc, map)
                                        else
                                            print("副本没有这个人 id = " .. npcId)
                                        end
                                    end

                                    self:showPanelRegister()

                                    PopText("发薪成功")
                                else
                                    PopText(errmsg)
                                end
                            else
                                PopText(errmsg)
                            end
                        end,
                        IS_SHOW_WAITING
                    )
                end
            )
            dialog:setButton2(
                "取消",
                function()
                end
            )
            dialog:setWeChatVisible(false)
        end)
    else
        panel.Button_confirm:setEnabled(false)
    end
end

function RoomAffairLayer:showPanelRegister()
    local panel = self.Panel_register

    panel:setVisible(true)

    local registerList = self.__affairList[1].list

    if MapIsEmpty(registerList) then
        panel.Panel_none:setVisible(true)
        return
    end

    panel.Panel_none:setVisible(false)
    
    local text = "管家：#ch#，这是家中本次尚未发放薪资的仆人名册，请您过目，若欠薪太多未发，仆人恐怕会滋生事端，甚至离开。"
    text = HomelandDesc:subChengHuText(text)

    panel.Text_desc:setString(text)

    for i,affair in ipairs(registerList) do
        local panelItem = panel.ListView_registrt:getItem(i - 1)
        if panelItem == nil then
            panelItem = self.Panel_item:clone()
            Helper:convertUIByParent(panelItem)
            panel.ListView_registrt:pushBackCustomItem(panelItem)
        end

        panelItem.Panel_desc.Text_name:setString(affair.btnName)
        panelItem.Button_1:releaseFunc(function()
            self:setPanelShow(affair.titleName,affair.text)
        end)

        panelItem.Panel_select.Image_gou:setVisible(true)
        panelItem.Panel_select:releaseFunc(function()
            if affair.select == false then
                affair.select = true
                panelItem.Panel_select.Image_gou:setVisible(true)
            else
                affair.select = false
                panelItem.Panel_select.Image_gou:setVisible(false)
            end
            
            self:initRegisterTextAndButtonComfirm()
        end)
    end

    local listItemCount = #panel.ListView_registrt:getItems()
    local itemCount = #registerList
    if itemCount < listItemCount then
        for i = listItemCount - 1, itemCount, -1 do
            panel.ListView_registrt:removeItem(i)
        end
    end

    panel.ListView_registrt:jumpToTop()

    self:initRegisterTextAndButtonComfirm()
end

function RoomAffairLayer:showPanelOperation()
    local panel = self.Panel_operation

    panel:setVisible(true)

    local operationList = self.__affairList[2].list

    if MapIsEmpty(operationList) then
        panel.Panel_none:setVisible(true)
        return
    end

    panel.Panel_none:setVisible(false)
    
    local text = "管家：#ch#，您回来啦，我已将近期所有需要您处理的府中事务整理在此，请您过目。"
    text = HomelandDesc:subChengHuText(text)

    panel.Text_desc:setString(text)

    local affairUtil = AffairUtil:create()

    for index, affair in ipairs(operationList) do
        affairUtil:pushToList(affair)

        local row = panel.ListView_1:getItem(index - 1)
        if row == nil then
            row = self.Button_affair:clone()
            Helper:convertUIByParent(row)
            panel.ListView_1:pushBackCustomItem(row)
        end

        row.Text_buttonName:setString(affair.titleName)

        affairUtil:bindUi(
            index,
            "ui_state",
            function(value)
                if value ~= 0 then
                    row:setColor(cc.c3b(80, 246, 244))
                    row.Text_buttonName:setColor(cc.c3b(80, 246, 244))
                    panel.Panel_dsc.Text_dsc:setString(affair:getText())
                    panel.Panel_dsc.Button_3.Text_buttonName:setString(affair.btnName)
                    if affair.btnName1 then
                        panel.Panel_dsc.Button_4.Text_buttonName:setString(affair.btnName1)
                        panel.Panel_dsc.Button_4:setVisible(true)
                    else
                        panel.Panel_dsc.Button_4:setVisible(false)
                    end
                else
                    row:setColor(cc.c3b(149, 142, 142))
                    row.Text_buttonName:setColor(cc.c3b(255, 255, 255))
                end
            end
        )

        affairUtil:bindUi(
            index,
            "is_read",
            function(value)
                if value == 0 then
                    row.Image_hongdian:setVisible(true)
                else
                    row.Image_hongdian:setVisible(false)
                end
            end
        )

        affairUtil:bindUi(
            index,
            "is_handle",
            function(value)
                if value == 1 then
                    local row_index = panel.ListView_1:getIndex(row)
                    self.__operationAffair = nil
                    panel.ListView_1:removeItem(row_index)
                    affairUtil:popFromList(row_index + 1)
                    table.remove(operationList,row_index + 1)
                    panel.Panel_dsc:setVisible(false)
                end
            end
        )

        row:releaseFunc(
            function()
                if self.__operationAffair == affair then
                    return
                end

                affair:clickEvent(
                    function()
                        if self.__operationAffair ~= nil and self.__operationAffair ~= affair then
                            self.__operationAffair:setUiState(0)
                        end
                        self.__operationAffair = affair
                        self.__operationAffair:setUiState(1)

                        panel.Panel_dsc:setVisible(true)

                        panel.Panel_dsc.Button_3:releaseFunc(
                            function()
                                affair:handleEvent()
                            end
                        )

                        panel.Panel_dsc.Button_4:releaseFunc(
                            function()
                                affair:handleEvent1()
                            end
                        )
                    end
                )
            end
        )
    end

    local itemCount = #panel.ListView_1:getItems()
    local listCount = affairUtil:getListNum()
    if itemCount - listCount > 0 then
        local removePosition = itemCount - listCount
        for i = itemCount - 1, listCount, -1 do
            panel.ListView_1:removeItem(i)
        end
    end

    panel.ListView_1:jumpToTop()
end

function RoomAffairLayer:showPanelMessage()
    local panel = self.Panel_message

    panel:setVisible(true)

    local messageList = self.__affairList[3].list

    if MapIsEmpty(messageList) then
        panel.Panel_none:setVisible(true)
        return
    end

    panel.Panel_none:setVisible(false)
    
    local text = "管家：#ch#，我已将近日家中发生的大小事务记录于此，您可在此查阅了解家中情况。"
    text = HomelandDesc:subChengHuText(text)

    panel.Text_desc:setString(text)

    local affairUtil = AffairUtil:create()

    for index, affair in ipairs(messageList) do
        affairUtil:pushToList(affair)

        local row = panel.ListView_1:getItem(index - 1)
        if row == nil then
            row = self.Button_affair:clone()
            Helper:convertUIByParent(row)
            panel.ListView_1:pushBackCustomItem(row)
        end

        row.Text_buttonName:setString(affair.titleName)

        affairUtil:bindUi(
            index,
            "ui_state",
            function(value)
                if value ~= 0 then
                    row:setColor(cc.c3b(80, 246, 244))
                    row.Text_buttonName:setColor(cc.c3b(80, 246, 244))
                    panel.Panel_dsc.Text_dsc:setString(affair:getText())
                    panel.Panel_dsc.Button_3.Text_buttonName:setString(affair.btnName)
                    if affair.btnName1 then
                        panel.Panel_dsc.Button_4.Text_buttonName:setString(affair.btnName1)
                        panel.Panel_dsc.Button_4:setVisible(true)
                    else
                        panel.Panel_dsc.Button_4:setVisible(false)
                    end
                else
                    row:setColor(cc.c3b(149, 142, 142))
                    row.Text_buttonName:setColor(cc.c3b(255, 255, 255))
                end
            end
        )

        affairUtil:bindUi(
            index,
            "is_read",
            function(value)
                if value == 0 then
                    row.Image_hongdian:setVisible(true)
                else
                    row.Image_hongdian:setVisible(false)
                end
            end
        )

        affairUtil:bindUi(
            index,
            "is_handle",
            function(value)
                if value == 1 then
                    local row_index = panel.ListView_1:getIndex(row)
                    self.__messageAffair = nil
                    panel.ListView_1:removeItem(row_index)
                    affairUtil:popFromList(row_index + 1)
                    table.remove(messageList,row_index + 1)
                    panel.Panel_dsc:setVisible(false)
                end
            end
        )

        row:releaseFunc(
            function()
                if self.__messageAffair == affair then
                    return
                end

                affair:clickEvent(
                    function()
                        if self.__messageAffair ~= nil and self.__messageAffair ~= affair then
                            self.__messageAffair:setUiState(0)
                        end
                        self.__messageAffair = affair
                        self.__messageAffair:setUiState(1)

                        panel.Panel_dsc:setVisible(true)

                        panel.Panel_dsc.Button_3:releaseFunc(
                            function()
                                affair:handleEvent()
                            end
                        )

                        panel.Panel_dsc.Button_4:releaseFunc(
                            function()
                                affair:handleEvent1()
                            end
                        )
                    end
                )
            end
        )
    end

    local itemCount = #panel.ListView_1:getItems()
    local listCount = affairUtil:getListNum()
    if itemCount - listCount > 0 then
        local removePosition = itemCount - listCount
        for i = itemCount - 1, listCount, -1 do
            panel.ListView_1:removeItem(i)
        end
    end

    panel.ListView_1:jumpToTop()
end

Helper:classDefNodeGetInstance(RoomAffairLayer)
return RoomAffairLayer
00000
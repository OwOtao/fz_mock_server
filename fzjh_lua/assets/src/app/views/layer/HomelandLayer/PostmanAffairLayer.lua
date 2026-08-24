--信差事务界面
local PostmanAffairLayer = class("PostmanAffairLayer", LayerEx)

--@RefType [app.models.HomelandModel.AffairModel.Affair#Affair]
local Affair = require("app.models.HomelandModel.AffairModel.Affair")

--@RefType [app.models.HomelandModel.AffairModel.AffairUtil#AffairUtil]
local AffairUtil = require("app.models.HomelandModel.AffairModel.AffairUtil")

function PostmanAffairLayer:create()
    local p = PostmanAffairLayer:new()
    p:init()
    return p
end

function PostmanAffairLayer:init()
    local UI = require("Layer/HomelandUI/PostmanAffairUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setShowAndHideAnimType("ROLL")
    self:setBack()
end

--设置返回
function PostmanAffairLayer:setBack()
    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

--@desc: 处理完所有事务后的回调
--@author:Liang SongQiang
--@time:2018-08-30 15:21:02
function PostmanAffairLayer:setFinshHandleAllCallback(callback)
    if type(callback) ~= "function" then
        return
    end

    self._finishAll = callback
end

function PostmanAffairLayer:hideLayer()
    PopupLayerController:hideLayer(
        "PostmanAffairLayer",
        function(layer)
            if self._currAffair ~= nil then
                self._currAffair = nil
            end

            if self._finishAll then
                self._finishAll = nil
            end

            AffairUtil:clearList()
            layer:hide()
        end
    )
end

function PostmanAffairLayer:showLayer(server_data)
    self:initAffairList(server_data)
    self:show()
end

--@desc: 初始化列表,只有进入界面才会出现
--@author:Liang SongQiang
--@time:2018-08-09 19:29:33
function PostmanAffairLayer:initAffairList(server_data)
    self.Panel_dsc:setVisible(false)
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
        AffairUtil:pushToList(affair)

        local row = self.ListView_1:getItem(index - 1)
        if row == nil then
            row = self.Button_roomExtend:clone()
            Helper:convertUIByParent(row)
            self.ListView_1:pushBackCustomItem(row)
        end

        row.Text_button_text:setString(affair.titleName)

        AffairUtil:bindUi(
            index,
            "ui_state",
            function(value)
                if value ~= 0 then
                    row:setColor(cc.c3b(80, 246, 244))
                    row.Text_button_text:setColor(cc.c3b(80, 246, 244))
                    self.Panel_dsc.Text_dsc:setString(affair:getText())
                    self.Panel_dsc.Button_3.Text_buttonName:setString(affair.btnName)
                    if affair.btnName1 then
                        self.Panel_dsc.Button_4.Text_buttonName:setString(affair.btnName1)
                        self.Panel_dsc.Button_4:setVisible(true)
                    else
                        self.Panel_dsc.Button_4:setVisible(false)
                    end
                else
                    row:setColor(cc.c3b(149, 142, 142))
                    row.Text_button_text:setColor(cc.c3b(255, 255, 255))
                end
            end
        )

        AffairUtil:bindUi(
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

        AffairUtil:bindUi(
            index,
            "is_handle",
            function(value)
                if value == 1 then
                    local row_index = self.ListView_1:getIndex(row)
                    self._currAffair = nil
                    self.ListView_1:removeItem(row_index)
                    AffairUtil:popFromList(row_index + 1)
                    self.Panel_dsc:setVisible(false)

                    local affair_num = AffairUtil:getListNum()

                    if affair_num == 0 then
                        print(self._finishAll)
                        if self._finishAll ~= nil then
                            self._finishAll()
                        end
                        self:hideLayer()
                    end
                end
            end
        )

        row:releaseFunc(
            function()
                if self._currAffair == affair then
                    return
                end

                affair:clickEvent(
                    function()
                        if self._currAffair ~= nil and self._currAffair ~= affair then
                            self._currAffair:setUiState(0)
                        end
                        self._currAffair = affair
                        self._currAffair:setUiState(1)
                        self:showPanelDsc()
                    end
                )
            end
        )
    end

    local itemCount = #self.ListView_1:getItems()
    local listCount = AffairUtil:getListNum()
    if itemCount - listCount > 0 then
        local removePosition = itemCount - listCount
        for i = itemCount - 1, listCount, -1 do
            self.ListView_1:removeItem(i)
        end
    end

    self.ListView_1:jumpToTop()
end

function PostmanAffairLayer:showPanelDsc()
    --@RefType [app.models.HomelandModel.AffairModel.Affair#Affair]
    local affair = self._currAffair

    self.Panel_dsc:setVisible(true)

    self.Panel_dsc.Button_3:releaseFunc(
        function()
            -- print(affair.btnName)
            affair:handleEvent()
        end
    )

    self.Panel_dsc.Button_4:releaseFunc(
        function()
            print(affair.btnName1)
            affair:handleEvent1()
        end
    )
end

Helper:classDefNodeGetInstance(PostmanAffairLayer)
return PostmanAffairLayer
00000000000
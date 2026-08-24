local BuyHouseLayer = class("BuyHouseLayer", cc.Layer)
--@RefType [app.models.HomelandModel.FangQiModel#FangQiModel]
local FangQiModel = require("app.models.HomelandModel.FangQiModel")

local _baseId

local _currentPoint

local dis_img_path = {
	["0.9"] = "Image/UI/StoreUI/jiuzhe.png",
	["0.8"] = "Image/UI/StoreUI/bazhe.png",
	["0.6"] = "Image/UI/StoreUI/liuzhe.png",
	default = "Image/UI/StoreUI/jiuzhe.png"
}

function BuyHouseLayer:create()
    local p = BuyHouseLayer:new()
    p:init()
    return p
end

function BuyHouseLayer:init()
    self._UI = require("Layer/MapUI/MapBagUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:initButtons()
end

function BuyHouseLayer:initButtons()
    local createBtn = function()
        local roleButton = Resource:getUIByName("Button_4")
        Helper:convertUI(roleButton)
        roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
        return roleButton
    end

    local button_right = createBtn()
    -- local button_left = createBtn()
    self:addChild(button_right)
    -- self:addChild(button_left)
    -- button_left:move(cc.p(270, 200))
    button_right:move(cc.p(810, 130))

    button_right:setVisible(true)
    button_right.Text_buttonName:setString("确定")
    button_right:releaseFunc(
        function()
            Audio:playEffect("xiaoAnNiu")

            self:hideLayer()
        end
    )

    local button_left = createBtn()
    self:addChild(button_left)
    button_left:move(cc.p(270, 130))

    button_left:setVisible(true)
    button_left.Text_buttonName:setString("立即刷新")
    button_left:releaseFunc(
        function()
            Audio:playEffect("xiaoAnNiu")

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

            --@RefType [app.views.layer.DialogLayer.DialogALayer#DialogALayer]
            local dialog = DialogALayer:getInstance()

            local show_str = "刷新需要花费"..self.refreshYuanBao.."元宝，你确定吗？"

            local btn1,btn2 = "确定","取消"

            do
                local isCanBuy = true
                local reason_str = "房屋不可改造原因："
                local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")
                local SeedModel = require("app.models.HomelandModel.SeedModel")

                if DispatchTaskManager:checkHasDispatchTask() or DispatchTaskManager:checkHasReward() then
                    isCanBuy = false
                    reason_str = reason_str.."有派遣任务未 完成或奖励未领取。"
                end

                if SeedModel:checkHavePlant() then
                    isCanBuy = false
                    reason_str = reason_str.."有土地正在种植或者有植物未收取。"
                end

                if isCanBuy == false then
                    
                    show_str = show_str.."\n \nRED当前房屋不可改造，刷新后的房契不能购买，还要继续花费元宝刷新吗？NOR\n"..reason_str
                    btn1,btn2 = "继续刷新","取消刷新"
                end
            end
            

            dialog:show(show_str)
            dialog:setRichText(show_str)
            dialog:setWeChatVisible(false)
            dialog:setButton1(
                btn1,
                function()
                    self:refreshList("Y")
                end
            )
            dialog:setButton2(
                btn2,
                function()
                end
            )
        end
    )

end

local rightData = {}
local leftData = {}
local _costLimit = 1000
local _isBuy = false
local _mapId
function BuyHouseLayer:showLayer(baseId,mapId,costLimit)
    if not baseId then
        assert(false,"bassId 没传")
    end

    _baseId = baseId
    _mapId = mapId
    _costLimit = costLimit
    self.Text_money:setVisible(false)

    self:refreshList("N")
end

function BuyHouseLayer:refreshList(is_refresh)
    is_refresh = is_refresh or "N"
    
    HttpManagerEx:getHouseStoreList(
        _baseId,
        is_refresh,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                rightData = data.list
                _isBuy = data.isBuy

                if data.point then
                    self.Text_money:setVisible(true)
                    _currentPoint = data.point
                    self.Text_money:setString("银票：" .. _currentPoint)
                end

                Helper:print_lua_table(rightData)

                if is_refresh == "Y" then
                    PopText("刷新成功，消耗"..data.removeYb.."元宝。")
                end

                self:initRightList()
                self:initLeftList()

                self:setTextDesc(data.costYb)

                self:refreshUI()
                
                self:show()
                return true
            else
                PopText(errmsg)
                return true
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

--@desc: 检查购房限制。
--@author:Liang SongQiang
--@time:2018-06-20 11:34:30
function BuyHouseLayer:checkCanBuyHouse()
    local isCanBuy = true

    local msg
    local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")
    local SeedModel = require("app.models.HomelandModel.SeedModel")

    if DispatchTaskManager:checkHasDispatchTask() then
        isCanBuy = false
        msg = "有任务正在派遣中，不可购房。"
    end

    if DispatchTaskManager:checkHasReward() then
       isCanBuy = false
       msg = "您有派遣任务奖励未领取，无法购房。" 
    end

    if SeedModel:checkHavePlant() then
        isCanBuy = false
        msg = "您有土地正在种植或者有植物未收取，无法购房。"
    end

    return isCanBuy,msg
end


function BuyHouseLayer:initRightList()
    self.ListView_2:removeAllItems()

    if MapIsEmpty(rightData) then
        print("BuyHouseLayer rightData is empty")
        return
    end

    for index, itemData in ipairs(rightData) do
        local row = self.Panel_item2:clone()
        Helper:convertUI(row)
        row:setVisible(true)
        row.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
        row.Text_num:enableOutline(cc.c4b(0, 0, 0, 255), 5)


        local house = FangQiModel:getFangQiTemplateById(itemData.fqId)

        if house then
            row.Text_name:setColor(cc.c3b(255, 255, 255))
            row.Text_name:setString(house.name)

            if itemData.discount ~= nil then
                local img_path = switch(tostring(itemData.discount), dis_img_path)
                row.Image_DaZhe:loadTexture(img_path, 0)
                row.Image_DaZhe:setVisible(true)
            else
                row.Image_DaZhe:setVisible(false)
            end
                
            row.Text_num:setString(itemData.cost .. "银票")
            row.Text_status:setVisible(false)

            self.ListView_2:pushBackCustomItem(row)
            row:releaseFunc(
                function()
                    local bool ,msg = self:checkCanBuyHouse()
                    if not bool then
                        PopText(msg)
                        return
                    end

                    --@desc 房契初始信息。
                    local tempData = {
                        itemId = "fq100",
                        name = house.name,
                        type = "房契",
                        dsc = house.typedsc
                    }

                    local function buyHouse()
                        --@RefType [app.models.role.Role#Role]
                        local role = User:getRole()

                        --@desc 只为检查是否可以加入一件物品
                        if role:checkCanBuyTwoOrMoreThings({["jian111"] = 1}) == false then
                            return
                        end

                        HttpManagerEx:buyHomeland(
                            _baseId,
                            itemData.fqId,
                            function(status, errcode, errmsg, data)
                                if status == 200 and errcode == 0 then
                                    print("----------------- 购房成功 --------------------")

                                    Helper:print_lua_table(data)
                                    data.fqId = itemData.fqId
                                    data.mapId = _mapId

                                    _currentPoint = math.max(0, _currentPoint - data.remove_point)

                                    --@RefType [app.models.HomelandModel.FangQiModel#FangQiModel]
                                    local FangQiModel = require("app.models.HomelandModel.FangQiModel")
                                    FangQiModel:getFangQi(data)

                                    --@RefType [app.models.HomelandModel.HomelandUtil#HomelandUtil]
                                    local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
                                    HomelandUtil:clearRoomFlag()
                                    
                                    PopupLayerController:hideLayer(
                                        "DetialWithButtonPopLayer",
                                        function(layer)
                                            layer:hide()
                                        end
                                    )
                                    PopText("您获得了一张房契。")
                                    
                                    if _isBuy then
                                        RichPrint("main","你已经成功购买了新房，新房的房契已经放入你的背包。")
                                    else
                                        RichPrint("main","你已经成功购买了新房，新房的房契已经放入你的背包。择日不如撞日，现在就去新家看看吧！")
                                    end
                                    
                                    _isBuy = true
                                    
                                    self:hideLayer()
                                    print("==============================================")
                                else
                                    if DEBUG_MODE == 1 then
                                        print(errcode)
                                    end
                                    PopText(errmsg)
                                end
                            end,
                            IS_SHOW_WAITING
                        )
                    end

                    PopupLayerController:showLayer(
                        "DetialWithButtonPopLayer",
                        function(layer)
                            layer:showLayer(
                                house.name,
                                tempData.type,
                                tempData.dsc,
                                "确定购买",
                                function()
                                    if _isBuy then
                                        ConfirmLayer:createCustomInRunningScene(
                                            "购买新的房屋将会替换你之前的房屋，仆人、门客、管家家具将会保留，确定重复购房请输入“确定”。",
                                            "确定",
                                            function(conFirmLayer)
                                                local editBoxString = conFirmLayer:getEditBoxString()
                                                if editBoxString == "确定" then
                                                    buyHouse()
                                                    layer:hideLayer()
                                                else
                                                    PopText("输入有误")
                                                end
                                            end,
                                            "取消",
                                            function()
                                            end
                                        )
                                    else
                                        buyHouse()
                                        layer:hideLayer()
                                    end
                                end
                            )
                        end
                    )
                end
            )
        else
            if DEBUG_MODE == 1 then
                print("此户型资源不存在", itemData.fqId)
            end
        end
    end
end

function BuyHouseLayer:initLeftList()
    self.ListView_1:removeAllItems()
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()
    leftData = role:getItems()
    for index, itemData in ipairs(leftData) do
        self:pushItemToLeftList(itemData)
    end
end

function BuyHouseLayer:pushItemToLeftList(data)
    local tempData = {
        itemId = "",
        count = 1
    }

    tempData.itemId = data.itemId
    tempData.count = Helper:getDef(data.count, tempData.count)

    local row = self.Panel_item1:clone()
    Helper:convertUI(row)
    row.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)

    print("----------------", tempData.itemId)
    local item = Item:getOneItemByKey(tempData.itemId)

    local str_count = ""
    if tonumber(tempData.count) > 1 then
        str_count = " X" .. tempData.count
    end
    row.Text_name:setColor(cc.c3b(255, 255, 255))
    row.Text_name:setString(item.name .. str_count)

    row:releaseFunc(
        function()
            PopText("此处无法出售道具。")
        end
    )
    self.ListView_1:pushBackCustomItem(row)
end

function BuyHouseLayer:hideLayer()
    PopupLayerController:hideLayer(
        "BuyHouseLayer",
        function(layer)
            -- layer.ListView_1:removeAllItems()
            -- layer.ListView_2:removeAllItems()
            layer:hide()
        end
    )
end

function BuyHouseLayer:refreshUI()
    self.Image_title.Text_title2:setString("市侩")
    self.Text_money:setString("银票：" .. _currentPoint)
    self.Text_weight:setString((#leftData) .. "/" .. User:getRoleAttr("weight"))
end

function BuyHouseLayer:setTextDesc(yuanbao)
	yuanbao = Helper:getDef(yuanbao, 0)
	self.refreshYuanBao = yuanbao
	self.Text_desc:setVisible(true)
	if yuanbao == 0 then
		self.Text_desc:setString("每天0点自动刷新\n此次刷新免费")
	else
		self.Text_desc:setString("每天0点自动刷新\n或花费"..tostring(self.refreshYuanBao).."元宝")
	end
end

Helper:classDefNodeGetInstance(BuyHouseLayer)
return BuyHouseLayer
0
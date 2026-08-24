local MatchLayer = class("MatchLayer", cc.Layer)
local TOP_MARGIN = 150

function MatchLayer:create()
    local p = MatchLayer:new()
    p:init()
    return p
end

function MatchLayer:init()
    self._UI = require("Layer/ActionUI/QIXI2018/MatchUI").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setBack()
end

function MatchLayer:hideLayer()
    PopupLayerController:hideLayer(
        "MatchLayer",
        function(layer)
            for i, v in ipairs(self._rightBtnList) do
                self:removeChild(v)
            end
            for i, v in ipairs(self._leftBtnList) do
                self:removeChild(v)
            end
            
            if self._handle ~= nil then
                self:unschedule(self._handle)
            end
            
            User:getRole():setFlag("PVP活动状态", "空闲中")
            layer:hide()
        end
    )
end

function MatchLayer:setBack()
    self.Panel_back:releaseFunc(
        function()
            if self._isNeedHide then
                self:hideLayer()
            end
        end
    )
end

function MatchLayer:showLayer(npc, map)
    User:getRole():setFlag("PVP活动状态", "忙碌")
    self._isNeedHide = true
    self._startLoadingBar = false
    self._showImageAnim = false

    self.LoadingBar_line:setPercent(0)
    self.Image_Perfect:setVisible(false)
    self.Text_Finish:setVisible(false)

    self.Text_Desc:setVisible(true)
    self.Text_Desc:setString("请选择你认为般配的两人，为他们结缘。")
    self:setBtnList(npc, map)

    self._handle =
        self:schedule(
        function(ft)
            self:update(ft)
        end,
        0
    )

    self:show()
end

--@map: [app.models.map.BaseMap#BaseMap]
function MatchLayer:setBtnList(npc, map)
    self._npc = npc
    self._map = map
    self._maleList = {}
    self._fmaleList = {}

    local maleList = map._malelist
    local fmalelist = map._fmalelist

    if npc.realSex == "男" then
        table.insert(self._maleList, npc)

        for _, npcId in ipairs(fmalelist) do
            local _npc = map:getRole(npcId)

            table.insert(self._fmaleList, _npc)
        end
        self.LoadingBar_line:setDirection(0)
    elseif npc.realSex == "女" then
        table.insert(self._fmaleList, npc)
        for _, npcId in ipairs(maleList) do
            local _npc = map:getRole(npcId)

            table.insert(self._maleList, _npc)
        end
        self.LoadingBar_line:setDirection(1)
    else
        assert(false, npc.id)
    end

    self._leftBtnList = {}

    self._rightBtnList = {}

    for i, male in ipairs(self._maleList) do
        local btn = self.Panel_Button:clone()
        Helper:convertUIByParent(btn)
        table.insert(self._leftBtnList, btn)
        local preBtn = self._leftBtnList[i - 1]

        local pos = {x = 95.29, y = 0}
        if preBtn == nil then
            pos.y = 1493.33
        else
            pos.y = preBtn:getPositionY() - TOP_MARGIN
        end

        self:addChild(btn)

        btn:setPosition(pos.x, pos.y)

        btn.Button_1.Text_buttonName:setString(male.name)

        btn._index = i

        if self._npc.realSex == "男" then
            btn.Image_Frame:setVisible(true)
        else
            btn.Image_Frame:setVisible(false)
            btn:releaseFunc(
                function()
                    self:showClickDialog(btn._index)
                end
            )
        end
    end

    for i, fmale in ipairs(self._fmaleList) do
        local btn = self.Panel_Button:clone()
        Helper:convertUIByParent(btn)
        table.insert(self._rightBtnList, btn)
        local preBtn = self._rightBtnList[i - 1]

        local pos = {x = 662.13, y = 0}
        if preBtn == nil then
            pos.y = 1493.33
        else
            pos.y = preBtn:getPositionY() - TOP_MARGIN
        end

        btn._index = i

        btn.Button_1.Text_buttonName:setString(fmale.name)
        self:addChild(btn)

        btn:setPosition(pos.x, pos.y)

        if self._npc.realSex == "女" then
            btn.Image_Frame:setVisible(true)
        else
            btn.Image_Frame:setVisible(false)
            btn:releaseFunc(
                function()
                    self:showClickDialog(btn._index)
                end
            )
        end
    end
end

function MatchLayer:showClickDialog(index)
    local btn

    local oneBtn

    local list

    local leftNpc

    local rightNpc

    local end_pos = {x = 0, y = 1493.33}

    if self._npc.realSex == "男" then
        list = self._rightBtnList
        btn = list[index]

        oneBtn = self._leftBtnList[1]

        leftNpc = self._npc

        rightNpc = self._fmaleList[index]

        end_pos.x = 662.13
    elseif self._npc.realSex == "女" then
        list = self._leftBtnList
        btn = list[index]

        oneBtn = self._rightBtnList[1]

        leftNpc = self._maleList[index]

        rightNpc = self._npc
        end_pos.x = 95.29
    end

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    --@RefType [app.views.layer.DialogLayer.DialogALayer#DialogALayer]
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show("您确定要给" .. leftNpc.name .. "和" .. rightNpc.name .. "牵线吗？")
    dialog:setWeChatVisible(false)
    dialog:setButton1(
        "确定",
        function()
            --@desc 特殊人物和普通人物无法配对
            if (leftNpc.special == 1 and rightNpc.special == 0) or (leftNpc.special == 0 and rightNpc.special == 1)  then
                PopText("此二人命中无缘，你不要白费心机了。")
                return
            end


            --@RefType [app.models.Action.ChineseValentine.2018.QiXiUtil#QiXiUtil]
            local QiXiUtil = require("app.models.Action.ChineseValentine.2018.QiXiUtil")

            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local upload_str = QiXiUtil:calResultStr(leftNpc, rightNpc)
            local item_list = QiXiUtil:getMatchRewardList(leftNpc.id, rightNpc.id)
            if MapIsEmpty(item_list) == false then
                if role:checkCanBuyTwoOrMoreThings(item_list) == false then
                    print("背包空间不够")
                    return
                end
            end

            local comingMapTime = self._map.__createRoleTime

            local nowTime = GetTime()

            if Helper:diffWithDate(nowTime,comingMapTime) >= 1 then
                upload_str = upload_str..";"..math.floor(comingMapTime)
            else
                upload_str = upload_str..";"..math.floor(nowTime)
            end

            HttpManagerEx:addQiXiRecord(
                upload_str,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            QiXiUtil:recordInHand(leftNpc, rightNpc)

                            QiXiUtil:recordFinshTime(self._map)

                            QiXiUtil:removeNpc(leftNpc, self._map)
                            QiXiUtil:removeNpc(rightNpc, self._map)

                            self._map.__MapLayer:delayRefreshMap()
                            
                            if MapIsEmpty(item_list) == false then
                                for itemId, count in pairs(item_list) do
                                    role:addItemCount(itemId, count)
                                    local itemAttr = Item:getOneItemByKey(itemId)
                                    RichPrint("main", "您获得了 " .. itemAttr.name .. " X" .. count)
                                end
                                RichPrint("main", "你感到了一阵恍惚，手里突然多了些什么东西。")
                            else
                                local addExp = 7000
                                local addYueLi = 20
                                role:addAttr("exp", addExp)
                                role:addAttr("yueli", addYueLi)
                                RichPrint("main", "你获得了" .. addExp .. "经验")
                                RichPrint("main", "你获得了" .. addYueLi .. "江湖阅历")
                            end

                            self._level = QiXiUtil:getUploadLevel(upload_str)

                            if self._level == 1 then
                                role:setInheritFlag("qixi2018p", role:getInheritFlag("qixi2018p") + 1)
                            end

                            self._isNeedHide = false
                            btn:setTouchEnabled(false)
                            btn.Image_Frame:setVisible(true)

                            self.Text_Desc:setVisible(false)

                            local index = btn._index
                            for _index, _btn in ipairs(list) do
                                if _index ~= index then
                                    _btn:setVisible(false)
                                    _btn:setTouchEnabled(false)
                                end
                            end
                            local duration = 0.35 * (index - 1)

                            local moveToAction = cc.MoveTo:create(duration, cc.p(end_pos.x, end_pos.y))

                            local endFunc =
                                cc.CallFunc:create(
                                function()
                                    btn.Image_Frame:setVisible(true)
                                    self._startLoadingBar = true
                                end
                            )
                            local action = cc.Sequence:create(moveToAction, endFunc)
                            btn:runAction(action)
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
        "再想想",
        function()
        end
    )
end

function MatchLayer:update(dt)
    if self._startLoadingBar then
        local nowPercent = self.LoadingBar_line:getPercent()

        if nowPercent >= 100 then
            self._startLoadingBar = false

            self.Text_Finish:setOpacity(0)
            self.Text_Finish:setString("你促成了这段姻缘，不知前方有怎样的道路等待着他们。")
            self.Text_Finish:setVisible(true)

            local descAction = cc.FadeIn:create(1)

            local endFunc =
                cc.CallFunc:create(
                function()
                    self._isNeedHide = true
                end
            )

            local action = cc.Sequence:create(descAction, endFunc)

            self.Text_Finish:runAction(action)

            if self._level == 1 then
                self._showImageAnim = true
            end
        else
            self.LoadingBar_line:setPercent(nowPercent + 2)
        end
    end

    if self._showImageAnim then
        self._showImageAnim = false

        self.Image_Perfect:setScale(1.5)

        self.Image_Perfect:setVisible(true)

        local action = cc.ScaleTo:create(0.5, 1)
        self.Image_Perfect:runAction(action)
    end
end

Helper:classDefNodeGetInstance(MatchLayer)
return MatchLayer
0
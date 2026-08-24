local LogSystem = require("app.models.LogSystem.LogSystem")
local NewMapLayer = class("NewMapLayer", require("app.views.layer.MapLayer.MapLayer"))

local function print(...)
    return LogSystem:log("NewMapLayer", ...)
end

local MAP_SHOW_TYPE_NONE = 0
local MAP_SHOW_TYPE_9 = 1
local MAP_SHOW_TYPE_TOTAL = 2

local MapRoleLayerName = "NewMapRoleLayer"

function NewMapLayer:create()
    local p = NewMapLayer.new()
    p:init()
    return p
end

function NewMapLayer:init()
    self._mapShowType = MAP_SHOW_TYPE_NONE
    self._currRoom = nil
    self._currRoomUI = nil
    self._currMap = nil

    self.totalMapHide = false

    self._preMapId = nil

    -- 初始化地图UI
    self:initMapUI()

    -- 设置地图显示类型
    self:setMapShowType(MAP_SHOW_TYPE_9)

    -- 设置定时器
    self:schedule(
        function(ft)
            if self.__input then
                self.__input:update(ft)
            end
            -- 尝试刷新副本当前房间
            if self._needRefreshMap then
                self:refreshMap()
            end
        end
    )
end

function NewMapLayer:onResume()
    local MapRoleLayer = MainControllLayer:getLayer(MapRoleLayerName)

    MapRoleLayer:statusButtonFunc(true)

    MapRoleLayer:exitButtonFunc(
        nil,
        function()
            self:leaveMap()
        end
    )

    self:setUnmoveRoom(false)
    self:setConditonCallGuanjia()
end

-- 设置输入的Presenter
function NewMapLayer:setInput(input)
    self.__input = input
end

-- 主要方法 ----------------------------------------------------------------------------------
-- 设置地图
function NewMapLayer:setMap(map)
    assert(map, "NewMapLayer:setMap() - map is nil")
    map:init()

    self._currMap = map
    self._preMapId = map.id

    self._currRoom = assert(self:getDefaultRoom())
    map:setCurrRoomId(self._currRoom.id)

    self:delayRefreshMap()

    self.Text_totalMap:setVisible(true)
    map._mapLayer = self
    map.__MapLayer = self

    -- add by XiaoZhiWei 2018/05/10 21:45:38 地图属性改造之后再初始化全图, 全副本地图需要的修改
    self:initTotalMapUI(map.mapAppearance, map.mapAppearanceIndex)
    self.TotalMapBtn_IsInit = false

    -- 地图显示初始化设置
    self:setMapShowType(MAP_SHOW_TYPE_9)
    self.Text_totalMap:move(cc.p(915, 1365))

    self.Text_totalMap:setString("查看全图")
    self.totalMapHide = false

    -- 进入副本刷新条件结果
    local results =
        map:doRoomConditionAndResult(
        self._currRoom.id,
        {
            operation = "进入房间",
            roomId = self._currRoom.id,
            currRoomId = nil,
            mapLayer = self,
            currRole = nil
        }
    )
    map:refreshYongBingRole(self._currRoom.id)
    map:refreshFollowRoles(self._currRoom.id)
    map:refreshMapProbabilityFunc("进入房间") --

    --@desc 执行初始房间条件结果
    map:executeDefaultRoomAutoConditionAndResult()

    self:initMapUIByMapType()

    MainControllLayer:getLayer(MapRoleLayerName):resume()
    MainControllLayer:getLayer(MapRoleLayerName):setRole(self:getPlayer())
    MainControllLayer:getLayer(MapRoleLayerName):show()
end

function NewMapLayer:getPlayer()
    return self._currMap:getPlayer()
end

function NewMapLayer:setTextTotalMap()
    -- 切换地图显示模式按钮
    self.Text_totalMap:setTouchEnabled(true)
    self.Text_totalMap:releaseFunc(
        function()
            if self._mapShowType == MAP_SHOW_TYPE_9 then
                -- 显示全图
                self:setMapShowType(MAP_SHOW_TYPE_TOTAL)
                self:delayRefreshMap()
                self.Text_totalMap:move(cc.p(915, 877))
                self.Text_totalMap:setString("关闭全图")
            elseif self._mapShowType == MAP_SHOW_TYPE_TOTAL then
                -- 关闭全图
                self:setMapShowType(MAP_SHOW_TYPE_9)
                self:delayRefreshMap()
                self.Text_totalMap:move(cc.p(915, 1365))
                self.Text_totalMap:setString("查看全图")
            end
        end
    )
end

-- 刷新界面UI
function NewMapLayer:refreshUI()
    local roomName = self._currRoom.name

    self.Text_dsc:setColor(cc.c3b(102, 153, 153))
    self.Text_dsc_1:setColor(cc.c3b(102, 153, 153))
    -- 设置房间描述
    self:setText_dsc(self._currRoom.dsc)

    -- 设置标题显示当前房间名
    local mapRoleLayer = MainControllLayer:getLayer(MapRoleLayerName)
    mapRoleLayer:setTitle(Helper:getDef(roomName, "不知名的地方"))

    local UserMap = require("app.models.map.UserMap")

    mapRoleLayer:exitButtonFunc(
        nil,
        function()
            self:leaveMap()
        end
    )
end

function NewMapLayer:quit(showText)
    print("退出地图!")

    -- 停止音乐播放
    self:stopMusic()

    -- 界面切换
    if showText ~= false then
        PopText("你退出了副本")
    end

    if self._currRoomUI then
        self.Panel_map:removeChild(self._currRoomUI)
        self._currRoomUI = nil
    end

    -- 推出副本挑剔界面
    MainControllLayer:getLayer(MapRoleLayerName):beforeLeave()
    MainControllLayer:getLayer(MapRoleLayerName):setVisible(false)
    MainControllLayer:getLayer(MapRoleLayerName):onPause()
    MainControllLayer:removeLayer(MapRoleLayerName)

    -- 弹出副本页面
    MainControllLayer:popLayer()
end

-- 刷新地图
function NewMapLayer:refreshMap(atonce)
    self._needRefreshMap = false

    self.__input:refreshMap()
end

function NewMapLayer:showObjectButtonList(buttonList)
    self.Panel_item:removeAllChildren()

    do
        -- add by XiaoZhiWei 2018/06/05 14:20:59 按钮刷新的时候,扩建相关的按钮需要去除掉
        self.Panel_item.EnlargeCancel = nil
        self.Panel_item.EnlargeKongFang = nil
        self.Panel_item.EnlargeChangLang = nil
    end

    local currButtonIndex, buttonCountMax = 1, #buttonList

    Helper:foreachItemInMatrixArea(
        self.Panel_item:getContentSize(),
        self:createNpcButton():getContentSize(),
        3,
        3,
        80,
        10,
        function(index, ix, iy, x, y)
            -- add by XiaoZhiWei 2017/06/05 17:51:37 如果数量超过了9个则不需要继续显示,反正也显示不出来
            if currButtonIndex > buttonCountMax or currButtonIndex > 9 then
                return
            end

            currButtonIndex = self:__setRoomObjectButton(currButtonIndex, buttonList[currButtonIndex], x, y)
        end
    )
end

function NewMapLayer:__setRoomObjectButton(currButtonIndex, buttonData, posX, posY)
    local roleButton = self:__createRoomObjectButton(buttonData.buttonText, buttonData.buttonImageIndex)

    roleButton:releaseFunc(
        function()
            self.__input:clickRoomObjectButton(buttonData.id)
        end
    )

    self.Panel_item:addChild(roleButton)
    roleButton:move(posX, posY)
    return currButtonIndex + 1
end

--[[
    @desc: 
    author:TangJian
    time:2021-12-16 14:49:08
    --@buttonText:
	--@buttonImageIndex: 
    @return:
]]
function NewMapLayer:__createRoomObjectButton(buttonText, buttonImageIndex)
    --@RefType [app.views.layer.RoleLayer.RoleResConf#RoleResConf]
    local RoleResConf = require("app.views.layer.RoleLayer.RoleResConf")
    local btnName = RoleResConf:getBtnImgName(buttonImageIndex)
    local roleButton = Resource:getUIByName(btnName)
    Helper:convertUI(roleButton)
    roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    roleButton.Text_buttonName:setString(buttonText)
    return roleButton
end

-- 显示角色观察界面
function NewMapLayer:showRoleObserverLayer(role, functionList)
    PopupLayerController:showLayer(
        "RoleObserveLayer",
        function(layer)
            layer:showLayerWithParams(role, functionList)
        end
    )
end

function NewMapLayer:hideRoleObserverLayer()
    local layer = PopupLayerController:getLayer("RoleObserveLayer")
    layer:hideLayer(true)
end

-- 进入房间
function NewMapLayer:entryRoom(fromRoomId, roomId, direction)
    self.__input:entryRoom(fromRoomId, roomId, direction)
end

function NewMapLayer:leaveMap()
    self.__input:leaveMap()
end

--[[
    @desc: 切换房间
    author:TangJian
    time:2022-01-15 16:05:23
    --@roomId: 要切换到的房间ID
	--@direction: 方向
	--@isShowText: 是否显示进入房间文本
    @return: nil
]]
function NewMapLayer:replaceRoom(roomId, direction, isShowText)
    if direction == nil then
        direction = "center"
    end

    local lastRoomId = self._currRoom.id

    if self._mapShowType == MAP_SHOW_TYPE_9 then
        local animDuration = 0.2

        if self._currRoomUI == nil then
            self._currRoomUI = self:createRoom(roomId)
        else
            local oppDirection = Helper:getOppositeDirection(direction)
            local fromUI = self._currRoomUI
            local toUI = self:createRoom(roomId)

            local formButton = fromUI:getRoomButton(direction)
            local toButton = toUI:getRoomButton("center")

            local formButtonWordPos = formButton:convertToWorldSpace(cc.p(0, 0))
            local toButtonWordPos = toButton:convertToWorldSpace(cc.p(0, 0))
            local offsetPos = cc.pSub(formButtonWordPos, toButtonWordPos)
            local toStartPos = cc.pAdd(cc.p(toUI:getPosition()), offsetPos)

            toUI:setPosition(toStartPos)

            toUI:fadeIn(
                offsetPos,
                animDuration,
                function(ui)
                end
            )

            fromUI:fadeOut(
                offsetPos,
                animDuration,
                function(ui)
                    ui:removeFromParent()
                end
            )
            self._currRoomUI = toUI
        end

        self._currRoom = self:getRoom(roomId)
    elseif self._mapShowType == MAP_SHOW_TYPE_TOTAL then
        local toRoom = self:getRoom(roomId)

        self._currRoom = toRoom
        self._totalMapUI:scrollToRoom(self._currRoom.id)
        self._totalMapUI:setAllRoomColor(cc.c3b(255, 255, 255))
        self._totalMapUI:setRoomColor(self._currRoom.id, cc.c3b(255, 0, 0))
    end

    -- 设置房间状态为去过
    self._currRoom.haveBeenTo = true
    local lastRoom = self:getRoom(lastRoomId)

    -- 播放音效
    self:playStepSound(lastRoomId, roomId)
    self:playRoomMusic(self._currRoom)

    if isShowText == nil or isShowText then
        RichPrint("main", "WHT你进入了【" .. tostring(self._currRoom.name) .. "】。")
    end

    self._currMap:setCurrRoomId(roomId)
    self:delayRefreshMap()
end

return NewMapLayer
000000
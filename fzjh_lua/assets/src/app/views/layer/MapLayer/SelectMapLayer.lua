local EntryMapLayer = require("app.views.layer.MapLayer.EntryMapLayer")
local SelectMapTitle = require("app.views.ui.MapUI.SelectMapTitle")
local SelectMapLayer = class("SelectMapLayer", require("app.views.base.BaseLayer"))

--@RefType [src.app.models.map.SelectMapModel#SelectMapModel]
local SelectMapModel = require("app.models.map.SelectMapModel")

function SelectMapLayer:create()
    local p = SelectMapLayer:new()
    p:init()
    return p
end

function SelectMapLayer:init()
    self._UI = require("Layer/MapUI/SelectMapUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self:initMonitorPool()

	self.Button_otherMap:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
    self.Button_otherMap:releaseFunc(
        function()
            PopupLayerController:showLayer(
                "SelectMapDetailLayer",
                function(layer)
                    layer:showLayer()
                    layer:setDetailClickCallback(
                        function(mapId)
                            layer:hideLayer()
                            self:setMap(mapId)

                            self:ShowResetTime()
                        end
                    )
                end
            )
        end
    )

    -- 进入关卡
    self.Button_entryMap:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
    self.Button_entryMap:releaseFunc(
        function()
            SelectMapModel:entryMap()
        end
    )

    -- 左右按键切换关卡
    -- local startIndex ,endIndex = Map:getStartIndexAndEndIndex(index)
    self.Panel_mapSwitch.Button_left:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
    self.Panel_mapSwitch.Button_left:releaseFunc(
		function()

			local mapId = SelectMapModel:getPreMapId()

			if mapId ~= nil then
				self:setMap(mapId)
			end
        end
    )
    self.Panel_mapSwitch.Button_right:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
    self.Panel_mapSwitch.Button_right:releaseFunc(
		function()
			local mapId = SelectMapModel:getNextMapId()

			if mapId ~= nil then
				self:setMap(mapId)
			end
        end
    )

    self:schedule(
        function(ft)
            self:update()
        end,
        0.5
    )
    --进入副本界面先隐藏重置时间
    self.Text_Reset_Time:setVisible(false)
    -- --重置按钮消耗元宝
    self:ButtonReset()
end

-- --重置时间显示
function SelectMapLayer:ShowResetTime()
    local mapId = SelectMapModel:getCurrMapId()
    if Map:getMapVersionByMapId(mapId) == EDITOR_MAP_VERSION then
        self.Text_Reset_Time:setVisible(false)
        self.Panel_Reset:setVisible(true)
    else
        self.Panel_Reset:setVisible(false)
        local time = Map:getMapRefreshTime(mapId)
        if time > 0 then
            self.Text_Reset_Time:setVisible(true)
            self.Text_Reset_Time:setString("关卡刷新" .. SelectMapModel:getRefreshTimeDsc(time))
        else
            self.Text_Reset_Time:setVisible(false)
        end
    end

end

--手动重置关卡的按钮，消耗元宝
-- 4分钟以上40元宝
-- 3分钟以上30元宝
-- 2分钟以上20元宝
-- 1分钟以上10元宝
-- 1分钟以内5元宝
function SelectMapLayer:ButtonReset()
    self.Text_Reset_Time:releaseFunc(
        function()
            local mapId = SelectMapModel:getCurrMapId()
            if Map:getMapVersionByMapId(mapId) == EDITOR_MAP_VERSION then
            else
                local scheduler, myupdate
                local role = User:getRole()
                local DialogGLayer = require("app.views.layer.DialogLayer.DialogGLayer")
                -- local  Map = require("app.models.map.Map")
                local dialog = DialogGLayer:getInstance()
                dialog:initPanel("map")
    
                local Payyuanbao
                --定时器执行重置时间显示
                local function update()
                    
                    local mpaId = SelectMapModel:getCurrMapId()
                    local map = Map:getDefaultMapById(mpaId)
                    local time = Map:getMapRefreshTime(mpaId)
                    
                    --重置关卡消耗元宝计算
                    local itemId
                    if time >= 240 then
                        Payyuanbao = 40
                        itemId = "fubenshuaxin5"
                    elseif time >= 180 then
                        Payyuanbao = 30
                        itemId = "fubenshuaxin4"
                    elseif time >= 120 then
                        Payyuanbao = 20
                        itemId = "fubenshuaxin3"
                    elseif time >= 60 then
                        Payyuanbao = 10
                        itemId = "fubenshuaxin2"
                    elseif time >= 0 then
                        Payyuanbao = 5
                        itemId = "fubenshuaxin1"
                    else
                        Payyuanbao = 0
                    end
                    if tonumber(time) >= 0 then
                        dialog:setText_desc_1(
                            map.title .. map.name .. "\n\n" .. "刷新剩余时间" .. SelectMapModel:getRefreshTimeDsc(time)
                        )
                        dialog:setText_desc_4(tostring(Payyuanbao) .. "元宝")
                    else
                        dialog:setText_desc_1(map.title .. map.name .. "\n\n" .. "已经刷新")
                        dialog:setText_desc_4(tostring(Payyuanbao) .. "元宝")
                    end
    
                    -- 弹出框的弹出文本
                    dialog:setButton1(
                        function()
                            PopYuanBaoBuyItemLayer(
                                itemId,
                                function(eventType)
                                    if eventType == "success" then
                                        --本关卡刷新
                                        Map:clearMapCache(map.id)
                                        role:setFlag(map.id, role:getFlag(map.id) - MAP_REFRESH_INTERVAL)
                                        PopText("刷新" .. map.name .. "关卡成功，你现在可以进入了！")
                                        self:onResume()
                                    end
                                end
                            )
                            --退出这个界面的时候应该停止计时器，不然会影响背包那边的显示
                            scheduler:unscheduleScriptEntry(myupdate)
                        end
                    )
                end
                --调用这个方法先显示一次，就不会延迟
                update()
    
                -- 每1秒执行一次update，会无限执行
                scheduler = cc.Director:getInstance():getScheduler()
                myupdate = scheduler:scheduleScriptFunc(update, 1.0, false)
                dialog:setButton2(
                    function()
                        --这个界面退出，应该停止计时器。
                        scheduler:unscheduleScriptEntry(myupdate)
                    end
                )
            end
        end
    )

    self.Panel_Reset.Panel_tips:releaseFunc(function ()
        local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
        local dialog = DialogELayer:getInstance()
        self.Panel_Reset.Panel_tips.Image_7:setVisible(false)
        local str = "重置进度成功后，会使选定章节与其后续章节所有进度重置，可重新体验副本。每日可重置进度五次，首次免费，其次根据选定的章节数量扣费重置。传承成功当日进度重置次数清空。"
        .."\n例如：已通关第一章至第五章，选择第二章重置，即重置第二章至第五章，但不会改变第一章的副本进度。"

        dialog:show(str)
        dialog:setPanelBack(function()
            self.Panel_Reset.Panel_tips.Image_7:setVisible(true)
        end)
    end)

    self.Panel_Reset:releaseFunc(function ()
        SelectMapModel:resetNewMap()
    end)
end

function SelectMapLayer:setMap(mapId)
	local direction = SelectMapModel:getDirection(mapId)

    self:switchMapInfo(mapId,direction)

    -- 详细信息
    self.Text_detailDsc:setString(Map:getDefaultMapById(mapId).detailDsc)

    local volId = Map:getVolumeIdByMapId(mapId)
    SelectMapModel:setCurrVolumeId(volId)
    SelectMapModel:setCurrMapId(mapId)

    self:ShowResetTime()
end

function SelectMapLayer:createMapTitle(map)
    local mapTitle = SelectMapTitle:create()
    mapTitle:setPosition(cc.p(self.Panel_mapSwitch:getContentSize().width / 2, 0))
    self.Panel_mapSwitch:addChild(mapTitle, -1)

    mapTitle:setTitle(map.title)
    mapTitle:setDsc(map.summary)
    return mapTitle
end


function SelectMapLayer:refreshUI()
    local role = User:getRole()

    local jing, jingMax = role:getNumAttr("jing"), math.floor(role:getJingMax())
    local qi, qiMax = role:getNumAttr("qi"), role:getCurrQiMax()
    local neili, neiliMax = role:getNumAttr("neili"), role:getNumAttr("neiliMax")

    local qiPercent = role:getAttr("qiPercent")
    if not qiPercent then
        qiPercent = 1
    end

    self.Text_name:setString(role:getChengHaoColorName() .. " " .. role:getName())
    self.Text_jing:setString("『精力』" .. jing .. "/" .. jingMax)
    self.Text_qi:setString("『气血』" .. qi .. "/" .. math.floor(qiMax) .. " (" .. math.floor(qiPercent * 100) .. "%)")
    self.Text_neili:setString("『内力』" .. neili .. "/" .. neiliMax)
end

function SelectMapLayer:showLayer()
	self:setMap(SelectMapModel:getCurrMapId())
end

function SelectMapLayer:switchMapInfo(mapId, direction)
    local animDuration = 0.2

    local map = Map:getDefaultMapById(mapId)
    assert(map)

    if self._currMapTitle == nil then
        self._currMapTitle = self:createMapTitle(map)
    else
        local defaultPos = cc.p(cc.p(self.Panel_mapSwitch:getContentSize().width / 2, 0))

        local fromTitle = self._currMapTitle
        local toTitle = self:createMapTitle(map)
        self._currMapTitle = toTitle

        local moveWidth = display.width / 2

        toTitle:setPositionX(defaultPos.x + moveWidth * direction)

        local offset = cc.p(-moveWidth * direction, 0)

        local fromTitleActionTag = fromTitle:getActionTagByName("move")
        local toTitleActionTag = toTitle:getActionTagByName("move")

        fromTitle:setCascadeOpacityEnabled(true)
        fromTitle:callAllChild(
            function(child)
                child:setCascadeOpacityEnabled(true)
            end
        )
        local fromTitleAction =
            cc.Sequence:create(
            cc.Spawn:create(cc.MoveBy:create(animDuration, offset), cc.FadeOut:create(animDuration)),
            cc.RemoveSelf:create()
        )
        fromTitleAction:setTag(fromTitleActionTag)
        -- fromTitle:stopActionByTag(fromTitleActionTag)
        fromTitle:runAction(fromTitleAction)

        toTitle:setCascadeOpacityEnabled(true)
        toTitle:callAllChild(
            function(child)
                child:setCascadeOpacityEnabled(true)
            end
        )
        toTitle:setOpacity(0)
        local toTitleAction =
            cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(animDuration, offset), cc.FadeIn:create(animDuration)))
        toTitleAction:setTag(toTitleActionTag)
        -- toTitle:stopActionByTag(toTitleActionTag)
        toTitle:runAction(toTitleAction)
    end
end


function SelectMapLayer:initMonitorPool()
    local role = User:getRole()
    self.monitorPool = MonitorPool:create("SelectMapLayer")
    self.monitorPool:add(role.ignoreCloneTb._finalAttr, "jingMax", self, self.refreshUI)
    self.monitorPool:add(role.ignoreCloneTb._finalAttr, "qiMax", self, self.refreshUI)
    self.monitorPool:add(role.ignoreCloneTb._finalAttr, "neiliMax", self, self.refreshUI)
    self.monitorPool:add(role, "jing", self, self.refreshUI)
    self.monitorPool:add(role, "qi", self, self.refreshUI)
    self.monitorPool:add(role, "neili", self, self.refreshUI)
    self.monitorPool:add(role, "name", self, self.refreshUI)
end

function SelectMapLayer:update()
    -- self:refreshUI()
    self.monitorPool:update()
    -- local time = Map:getMapRefreshTime(SelectMapModel:getCurrMapId())
    -- if time >= 0 then
    --     self.Text_Reset_Time:setString("关卡刷新" .. SelectMapModel:getRefreshTimeDsc(time))
    -- end
    self:ShowResetTime()
end


function SelectMapLayer:onResume()

	self:showLayer()

end

return SelectMapLayer
000000000000000
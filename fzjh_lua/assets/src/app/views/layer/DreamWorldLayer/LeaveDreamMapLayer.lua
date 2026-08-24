local LeaveDreamMapLayer = class("LeaveDreamMapLayer", LayerEx)
local AnimTextUi = require("app.views.layer.TextAnimLayer.AnimTextUi")

function LeaveDreamMapLayer:create()
    local p = LeaveDreamMapLayer:new()
    p:init()
    return p
end

function LeaveDreamMapLayer:init()
    self._round = require("Layer/DreamWorldUI/DreamMapLeaveUI.lua").create()["root"]
    self._round:addTo(self)
    Helper:convertUIByParent(self)

    self.Text_10:setVisible(false)
    -- self.Text_Dsc:setString("香烟袅袅。。。。。。")
end

function LeaveDreamMapLayer:hideLayer()
    PopupLayerController:hideLayer(
        "LeaveDreamMapLayer",
        function(layer)
            layer:hide(
                function()
                    for i, text_ui in ipairs(self._ui_list) do
                        text_ui:unscheduleAll()
                    end
        
                    if self.musicName and self.effectId then
                        Audio:stopEffect(self.effectId)
                        self.effectId = nil
                    end
                    Audio:resumeMusic()
                    
                    self:unscheduleWithTag("LeaveDream")
                    self.__co = nil
                    self._curr_ui = nil
                    self._ui_list = nil
                end
            )
        end
    )
end

function LeaveDreamMapLayer:setBtn1Func(name, func)
    if name == nil or name == "" then
        self.Button_1:setVisible(false)
    else
        self.Button_1:setVisible(true)
    end
    
    func = func or EMPTY_FUNC
    self.Button_1.Text_buttonName:setString(name)
    self.Button_1:releaseFunc(
        function()
            func()
        end
    )
end

function LeaveDreamMapLayer:setBtn2Func(name, func)
    if name == nil or name == "" then
        self.Button_2:setVisible(false)
    else
        self.Button_2:setVisible(true)
    end
    
    func = func or EMPTY_FUNC
    self.Button_2.Text_buttonName:setString(name)
    self.Button_2:releaseFunc(
        function()
            func()
        end
    )
end

function LeaveDreamMapLayer:setText(desc)
    self.Text_Dsc:setString(desc)
end

function LeaveDreamMapLayer:showLayer()
    self._handle =
        self:scheduleUnique(
        function(ft)
            self:update(ft)
        end,
        1 / 30,
        "LeaveDream"
    )
    
    self:createTextListLeaveDream()

    self:show(
        function()
            self:startRunAnim()
        end
    )
end

function LeaveDreamMapLayer:setCurrfloorNum(desc)
    self.Text_9:setString(desc)
end

function LeaveDreamMapLayer:createTextListLeaveDream()
    local text_list = {
        "你听到一阵响动，",
        "无尽的黑暗挟裹着你，",
        "远方，你似乎感受到了光。",
        "再用用力，就可以从这一切中脱身……",
    }
    self._ui_list = {}

    for index = 1, 8 do
        local text_ui = self["Text_"..index]
        text_ui:setString(text_list[index])
        text_ui:setOpacity(0)
        text_ui.play_status = 0
        
        if text_list[index] then
            table.insert(self._ui_list, text_ui)
        end
    end

    return
end

function LeaveDreamMapLayer:startRunAnim()
    if MapIsEmpty(self._ui_list) then
        return
    end

    self.__co =
        coroutine.create(
        function()
            for index, ui in ipairs(self._ui_list) do
                self._curr_ui = ui

                if ui.play_status == 1 then
                    return
                end
            
                ui.play_status = 1
            
                ui:scheduleUnique(
                    function(ft)
                        self:runFadeInAndMove(ft,ui)
            
                        if ui.play_status == 2 then
                            ui:unscheduleWithTag("text_anim")
                        end
                    end,
                    1 / 30,
                    "text_anim"
                )
                coroutine.yield()
            end

            if self._afterFunc then
                self._afterFunc()
            end

            self.__co = nil
            self._curr_ui = nil
        end
    )

    coroutine.resume(self.__co)
end

local update_time = 0
function LeaveDreamMapLayer:update(ft)
    if self.__co then
        if self._curr_ui.play_status == 2 then
            --@desc 控件动画完成后，应该有一点延迟
            update_time = update_time + 1 / 30
            if update_time >= 1.5 then
                update_time = 0
                coroutine.resume(self.__co)
            end
        end
    end
end

function LeaveDreamMapLayer:runFadeInAndMove(ft,ui)
    local nowOpacity = ui:getOpacity()

    local isOpacityFish = false
    if nowOpacity >= 255 then
        isOpacityFish = true
    else
        ui:setOpacity(math.min(nowOpacity + (255 / 0.5) * ft, 255))
        isOpacityFish = false
    end

    if isOpacityFish then
        ui.play_status = 2
    end
end

Helper:classDefNodeGetInstance(LeaveDreamMapLayer)
return LeaveDreamMapLayer
0000000000000
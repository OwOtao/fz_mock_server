local AnimTextUi = class("AnimTextUi", ccui.Text)

local PLAY_TYPE = {
    FADEIN_MOVE = 0
}

local TAG_NAME = "text_anim"

--@desc text 控件宽度
AnimTextUi.TEXT_UI_WIDTH = 850

AnimTextUi._play_status = 0

AnimTextUi._play_type = nil

--@desc 每帧增加的透明度
local ADD_OPACITY_VALUE = 255 / 0.5


--@desc:创建普通text控件
--@author:Liang SongQiang
--@time:2018-08-24 11:43:24
--@text:文本
--@return [app.views.layer.TextAnimLayer.AnimTextUi#AnimTextUi]
function AnimTextUi:createNormalAnimText(text,config)
    local p = self:create()

    p:initDef(config)

    p:setString(text)

    return p
end

function AnimTextUi:initDef(config)
    local COLOR , SIZE_WIDTH , FONT, FONT_SIZE,FONTCOLOR
    if MapIsEmpty(config) then
        COLOR = cc.c3b(190, 170, 130)
        FONTCOLOR = cc.c4b(26, 26, 26, 255)
        SIZE_WIDTH = 850
        FONT = "Font/default.ttf"
        FONT_SIZE = 48
        self._speedRate = 1
    else
        COLOR = config.color or cc.c3b(190, 170, 130)
        FONTCOLOR = config.fontColor or cc.c4b(26, 26, 26, 255)
        SIZE_WIDTH = config.width or 850
        FONT = config.font or "Font/default.ttf"
        FONT_SIZE = config.fontSize or 48
        self._speedRate = config.speedRate or 1
    end

    ADD_OPACITY_VALUE = ADD_OPACITY_VALUE * (1/self._speedRate)

    self:setAnchorPoint(0.5, 1)
    self:ignoreContentAdaptWithSize(true)
    self:setTextAreaSize(cc.size(SIZE_WIDTH, 0))
    self:setFontName(FONT)
    self:setFontSize(FONT_SIZE)
    self:enableOutline(FONTCOLOR, 5)
    self:setTextColor(COLOR)
    self:setOpacity(0)
    self:setTouchEnabled(false)

    if self._play_type == nil then
        self._play_type = PLAY_TYPE.FADEIN_MOVE
    end
end

function AnimTextUi:setScheduleInterval(interval)
    self._interval = interval

    if self._play_status == 1 then
        local scheduler = self:getSchedulesWithTag(TAG_NAME)[1]

        if scheduler.interval ~= interval then
            scheduler.interval = interval
        end
    end
end


function AnimTextUi:getPlayStatus()
    return self._play_status
end

function AnimTextUi:setPlayType(play_type)
    if self._play_status == 1 then
        
    end
end

function AnimTextUi:startRun()
    if self._play_status == 1 then
        return
    end

    self._play_status = 1

    self:scheduleUnique(
        function(ft)
            switch(
                self._play_type,
                {
                    [PLAY_TYPE.FADEIN_MOVE] = function(ft)
                        return self:runFadeInAndMove(ft)
                    end
                },
                ft
            )

            if self._play_status == 2 then
                self:unscheduleWithTag(TAG_NAME)
            end
        end,
        self._interval,
        TAG_NAME
    )
end



--@desc: 淡入显示，每帧处理
--@author:Liang SongQiang
--@time:2018-08-24 10:45:44
function AnimTextUi:runFadeInAndMove(ft)
    local nowOpacity = self:getOpacity()

    local isOpacityFish = false
    if nowOpacity >= 255 then
        isOpacityFish = true
    else
        self:setOpacity(math.min(nowOpacity + ADD_OPACITY_VALUE * ft, 255))
        isOpacityFish = false
    end
    
    local curr_x, curr_y = self:getPosition()

    local final_y = self:getPositionY()

    local isPosFinish = false
    if final_y >= self._posY then
        isPosFinish = true
    else
        self:setPosition(cc.p(curr_x, curr_y + (Helper:getDef(self._move_offset,30) / (0.5 * self._speedRate)) * ft))
        isPosFinish = false
    end

    if isPosFinish and isOpacityFish then
        self._play_status = 2
    end
end

return AnimTextUi
000000000000
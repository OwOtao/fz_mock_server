--@SuperType [app.views.base.LayerEx#LayerEx]
local TextAnimLayer = class("TextAnimLayer", LayerEx)

--@RefType [app.views.layer.TextAnimLayer.AnimTextUi#AnimTextUi]
local AnimTextUi = require("app.views.layer.TextAnimLayer.AnimTextUi")

--@desc 最高的一个控件高度
TextAnimLayer.TEXT_TOP_MARGIN = 1775

--@desc 左边的距离
TextAnimLayer.TEXT_LEFT_MARGIN = cc.Director:getInstance():getWinSize().width / 2

--@desc 距离上一个文本控件的距离（0间距）
TextAnimLayer.TEXT_DISTANCE_NONE = 0

--@desc 距离上一个文本控件的距离（小间隔）
TextAnimLayer.TEXT_DISTANCE_SMALL = 20

--@desc 距离上一个文本控件的距离（大间隔）
TextAnimLayer.TEXT_DISTANCE_BIG = 40

TextAnimLayer.SCHEDULE_NORMAL_TIME = 1 / 30

TextAnimLayer.SCHEDULE_FAST_TIME = 1 / 60

TextAnimLayer.SCHEDULE_NAME = "PLAYACTION"

TextAnimLayer.TEXT_SHOW_ANIM_TYPE = {
    ONE_BY_ONE = 1,
    ONE_BY_MORE = 2, --需要换页 用符号 |||
    DREAM_COMPLETE = 3,
    DREAM_LEAVE = 4,
}

function TextAnimLayer:create()
    local p = TextAnimLayer:new()
    p:init()
    return p
end

function TextAnimLayer:init()
    local UI = require("Layer.TextAnimUI.TextAnimUI").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)

    self:setshowAndHideAnimDuration(2)

    self:setShowAndHideAnimType("FADE")

    -- --@desc 注册唯一调度器
    self._handle =
        self:scheduleUnique(
        function(ft)
            self:update(ft)
        end,
        TextAnimLayer.SCHEDULE_NORMAL_TIME,
        TextAnimLayer.SCHEDULE_NAME
    )

    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()

        end
    )
end

--@desc 初始化默认值
function TextAnimLayer:lazyShowInit()
    self:slowDownAction()
    if self._text_show_type == nil then
        self._text_show_type = TextAnimLayer.TEXT_SHOW_ANIM_TYPE.ONE_BY_ONE
    end
end

--@desc: 设置文本输出的动画类型方式
--@author:Liang SongQiang
--@time:2018-08-23 19:43:47
function TextAnimLayer:setShowAnimType(show_type)
    self._text_show_type = show_type
end

-- --@desc 当动画运行中
-- function TextAnimLayer:setAnimalRunningTouch(title, func)
--     if type(func) ~= "function" then
--         func = EMPTY_FUNC
--     end
--     self.Panel_Show:releaseFunc(
--         function()
--             self:pauseSelfAndChildren()
--             local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

--             local dialog = DialogALayer:getInstance()
--             dialog:show(title)
--             dialog:setButton1(
--                 "确定",
--                 function()
--                     func()
--                 end
--             )
--             dialog:setButton2(
--                 "取消",
--                 function()
--                     self:resumeSelfAndChildren()
--                 end
--             )
--             dialog:setWeChatVisible(false)
--         end
--     )
-- end

function TextAnimLayer:setAfterAnimCallback(func)
    if type(func) ~= "function" then
        func = EMPTY_FUNC
    end
    self._afterFunc = func
end

function TextAnimLayer:setHideCallbackFunc(func)
    if type(func) ~= "function" then
        func = EMPTY_FUNC
    end
    self._hideCallback = func
end

--@desc: 加快页面刷新速度
--@author:Liang SongQiang
--@time:2018-08-23 17:01:03
function TextAnimLayer:speedUpAction()
    local scheduler = self:getSchedulesWithTag(TextAnimLayer.SCHEDULE_NAME)[1]
    if scheduler and scheduler.interval > TextAnimLayer.SCHEDULE_FAST_TIME then
        scheduler.interval = TextAnimLayer.SCHEDULE_FAST_TIME
    end

    if not MapIsEmpty(self._ui_list) then
        for i, ui in ipairs(self._ui_list) do
            ui:setScheduleInterval(TextAnimLayer.SCHEDULE_FAST_TIME)
        end
    end
end

--@desc: 降低页面刷新速度
--@author:Liang SongQiang
--@time:2018-08-23 17:00:51
function TextAnimLayer:slowDownAction()
    local scheduler = self:getSchedulesWithTag(TextAnimLayer.SCHEDULE_NAME)[1]
    if scheduler and scheduler.interval < TextAnimLayer.SCHEDULE_NORMAL_TIME then
        scheduler.interval = TextAnimLayer.SCHEDULE_NORMAL_TIME
    end

    if not MapIsEmpty(self._ui_list) then
        for i, ui in ipairs(self._ui_list) do
            ui:setScheduleInterval(TextAnimLayer.SCHEDULE_NORMAL_TIME)
        end
    end
end

function TextAnimLayer:hideLayer()
    PopupLayerController:hideLayer(
        "TextAnimLayer",
        function(layer)
            layer:hide(
                function()
                    for i, text_ui in ipairs(self._ui_list) do
                        text_ui:unscheduleAll()
                    end
        
                    if self._hideCallback then
                        self._hideCallback()
                    end
        
                    if self.musicName and self.effectId then
                        -- Audio:stopMusic()
                        Audio:stopEffect(self.effectId)
                        self.effectId = nil
                    end
                    Audio:resumeMusic()
                    
                    self.__co = nil
                    self._curr_index = nil
                    self._curr_ui = nil
                    self._ui_list = nil
                    self.musicName = nil
                    self.isLoop = nil
                    self.Panel_Show:removeAllChildren()
                end
            )
        end
    )
end

function TextAnimLayer:showLayer(str)
    
    self.Image_back:setVisible(false)
    self.Image_1:setVisible(false)
    
    self:lazyShowInit()

    self:createShowTextList(str)

    local state = 0
    self.Button_5:releaseFunc(
        function()
            if state == 0 then
                self:speedUpAction()
                state = 1
            else
                self:slowDownAction()
                state = 0
            end
        end
    )

    self:show(
        function()
            self:startRunAnim()
        end
    )

    Audio:pauseMusic()

    if self.musicName then
        -- Audio:playMusic(self.musicName,Helper:getDef(self.isLoop,true))
        self.effectId = Audio:playEffect(self.musicName,Helper:getDef(self.isLoop,true))
    end
end

--@desc: 创建要展示的text控件
--@author:Liang SongQiang
--@time:2018-08-23 20:00:20
--@str: 创建文本
function TextAnimLayer:createShowTextList(str)
    if MapIsEmpty(self._ui_list) then
        self._ui_list = {}
    end


    self._ui_list =
        switch(
        self._text_show_type,
        {
            [TextAnimLayer.TEXT_SHOW_ANIM_TYPE.ONE_BY_ONE] = function()
                local text_list = string.split(str, "|")
                return self:createTextListOneByOne(text_list)
            end,
            [TextAnimLayer.TEXT_SHOW_ANIM_TYPE.ONE_BY_MORE] = function()
                local page_str_list = string.split(str,"|||")

                local text_list = string.split(page_str_list[1], "|")    

                self.Panel_back:releaseFunc(function()
                    table.remove(page_str_list,1)

                    if MapIsEmpty(page_str_list) then
                        self:hideLayer()
                    else
                        local text_list1 = string.split(page_str_list[1], "|")    

                        self.Panel_Show:removeAllChildren()
                        self._ui_list = self:createTextListOneByOne(text_list1)
                        self._afterFunc = nil --第一次已经运行过了，应该清空
                        self:startRunAnim()
                    end
                end)

                return self:createTextListOneByOne(text_list)
            end,
            [TextAnimLayer.TEXT_SHOW_ANIM_TYPE.DREAM_COMPLETE] = function()
                local text_list = string.split(str, "|")
                return self:createTextListDreamWord(text_list)
            end,
            [TextAnimLayer.TEXT_SHOW_ANIM_TYPE.DREAM_LEAVE] = function()
                local text_list = string.split(str, "|")
                return self:createTextListLeaveDream(text_list)
            end,
        }
    )
end

--@desc 字符串替换
function TextAnimLayer:subStr(str)
    str = string.gsub(str, "#aaaa", "")
    str = string.gsub(str, "#AAAA", "")
    return str
end

--@desc 根据字符串获取距离前一个控件的距离
function TextAnimLayer:getDistanceForPre(str)
    local distance_type = 0

    if string.find(str, "#aaaa") then
        distance_type = 1
    elseif string.find(str, "#AAAA") then
        distance_type = 2
    end

    local distance =
        switch(
        distance_type,
        {
            [0] = TextAnimLayer.TEXT_DISTANCE_NONE,
            [1] = TextAnimLayer.TEXT_DISTANCE_SMALL,
            [2] = TextAnimLayer.TEXT_DISTANCE_BIG,
            default = TextAnimLayer.TEXT_DISTANCE_NONE
        }
    )

    return distance
end

function TextAnimLayer:createTextListDreamWord(text_list)
    if MapIsEmpty(text_list) then
        assert(false, "数组为空。")
        return
    end

    if #text_list > 6 then
        assert(false,"不能超过六段。")
        return
    end

    self.Image_back:setVisible(true)
    self.Image_back:ignoreContentAdaptWithSize(true)
    self.Image_back:loadTexture("Image/UI/MapUI/back1.jpg")
    self.Image_back:setPosition(cc.p(0,0))

    self.Image_1:setVisible(true)
    self.Image_1:ignoreContentAdaptWithSize(true)
    self.Image_1:loadTexture("Image/UI/MapUI/fsrm.png")
    self.Image_1:setPosition(cc.p(855,17))

    local ui_list = {}

    local _posX = TextAnimLayer.TEXT_LEFT_MARGIN

    --@desc 第一个控件的Y轴坐标
    local _posY = TextAnimLayer.TEXT_TOP_MARGIN - 100

    local pre_ui

    local FontSizeList = {
        100,
        78,
        68,
        58,
        52,
        46,
    }

    for index, str in ipairs(text_list) do
        --@desc 处理字符串
        local distance_type = 0

        --@desc 距离前面文本控件最下面的距离
        local pre_distance = self:getDistanceForPre(str)

        str = self:subStr(str)

        local text_ui = AnimTextUi:createNormalAnimText(str,{
            width = 1060,
            font = "Font/HYCFS.ttf",
            fontSize = FontSizeList[index],
            color = cc.c3b(179, 179, 179),
            speedRate = 0.7,
        })

        self.Panel_Show:addChild(text_ui)

        --@desc 下移30像素，用于动画播放
        text_ui._move_offset = 30

        --@desc 设置位置
        if pre_ui then
            --@desc 前面控件的高度
            local pre_ui_height = pre_ui:getAutoRenderSize().height

            --@desc 前面控件的Y轴坐标
            local pre_ui_posY = pre_ui:getPositionY()

            --@desc 控件最终摆放的位置。
            text_ui._posY = pre_ui._posY - pre_ui_height - pre_distance
            text_ui:setPosition(cc.p(_posX, pre_ui_posY - pre_ui_height - pre_distance))
        else
            text_ui._posY = _posY
            text_ui:setPosition(cc.p(_posX, _posY - text_ui._move_offset))
        end

        pre_ui = text_ui

        print("index", index, text_ui:getPositionY(), pre_ui:getPositionY(), pre_ui:getAutoRenderSize().height)

        table.insert(ui_list, text_ui)
    end

    return ui_list
end

function TextAnimLayer:createTextListLeaveDream(text_list)
    if MapIsEmpty(text_list) then
        assert(false, "数组为空。")
        return
    end

    -- self.Image_back:setVisible(true)
    -- self.Image_back:ignoreContentAdaptWithSize(true)
    -- self.Image_back:loadTexture("Image/UI/MapUI/back1.jpg")
    -- self.Image_back:setPosition(cc.p(0,0))

    self.Image_1:setVisible(true)
    self.Image_1:ignoreContentAdaptWithSize(true)
    self.Image_1:loadTexture("Image/UI/MapUI/fsrm.png")
    self.Image_1:setPosition(cc.p(866,1240))

    local Image_4 = ccui.ImageView:create()
    Image_4:ignoreContentAdaptWithSize(false)
    Image_4:loadTexture("Image/UI/MapUI/xianglu.png",0)
    Image_4:setLayoutComponentEnabled(true)

    Image_4:setCascadeColorEnabled(true)
    Image_4:setCascadeOpacityEnabled(true)
    Image_4:setPosition(543.0001, 1390.0420)
    self:addChild(Image_4)

    local ui_list = {}

    local _posX = TextAnimLayer.TEXT_LEFT_MARGIN

    --@desc 第一个控件的Y轴坐标
    local _posY = TextAnimLayer.TEXT_TOP_MARGIN - 48

    local pre_ui


    for index, str in ipairs(text_list) do
        --@desc 处理字符串
        local distance_type = 0

        --@desc 距离前面文本控件最下面的距离
        local pre_distance = self:getDistanceForPre(str)

        str = self:subStr(str)

        local text_ui = AnimTextUi:createNormalAnimText(str,{
            width = 1060,
            font = "Font/default.ttf",
            fontSize = 40,
            color = cc.c3b(99, 92, 76),
            speedRate = 0.7,
        })

        self.Panel_Show:addChild(text_ui)

        --@desc 下移30像素，用于动画播放
        text_ui._move_offset = 30

        --@desc 设置位置
        if pre_ui then
            --@desc 前面控件的高度
            local pre_ui_height = pre_ui:getAutoRenderSize().height

            --@desc 前面控件的Y轴坐标
            local pre_ui_posY = pre_ui:getPositionY()

            --@desc 控件最终摆放的位置。
            text_ui._posY = pre_ui._posY - pre_ui_height - pre_distance
            text_ui:setPosition(cc.p(_posX, pre_ui_posY - pre_ui_height - pre_distance))
        else
            text_ui._posY = _posY
            text_ui:setPosition(cc.p(_posX, _posY - text_ui._move_offset))
        end

        pre_ui = text_ui

        print("index", index, text_ui:getPositionY(), pre_ui:getPositionY(), pre_ui:getAutoRenderSize().height)

        table.insert(ui_list, text_ui)
    end

    return ui_list
end


--@desc: 创建文本控件数组，一条一条的顺序播放
--@author:Liang SongQiang
--@time:2018-08-23 20:08:19
--@text_list: 文本数组
function TextAnimLayer:createTextListOneByOne(text_list)
    if MapIsEmpty(text_list) then
        assert(false, "数组为空。")
        return
    end

    local ui_list = {}

    local _posX = TextAnimLayer.TEXT_LEFT_MARGIN

    --@desc 第一个控件的Y轴坐标
    local _posY = TextAnimLayer.TEXT_TOP_MARGIN

    local pre_ui

    for index, str in ipairs(text_list) do
        --@desc 处理字符串
        local distance_type = 0

        --@desc 距离前面文本控件最下面的距离
        local pre_distance = self:getDistanceForPre(str)

        str = self:subStr(str)

        local text_ui = AnimTextUi:createNormalAnimText(str)
        self.Panel_Show:addChild(text_ui)

        --@desc 下移30像素，用于动画播放
        text_ui._move_offset = 30

        --@desc 设置位置
        if pre_ui then
            --@desc 前面控件的高度
            local pre_ui_height = pre_ui:getAutoRenderSize().height

            --@desc 前面控件的Y轴坐标
            local pre_ui_posY = pre_ui:getPositionY()

            --@desc 控件最终摆放的位置。
            text_ui._posY = pre_ui._posY - pre_ui_height - pre_distance
            text_ui:setPosition(cc.p(_posX, pre_ui_posY - pre_ui_height - pre_distance))
        else
            text_ui._posY = _posY
            text_ui:setPosition(cc.p(_posX, _posY - text_ui._move_offset))
        end

        pre_ui = text_ui

        print("index", index, text_ui:getPositionY(), pre_ui:getPositionY(), pre_ui:getAutoRenderSize().height)

        table.insert(ui_list, text_ui)
    end

    return ui_list
end

--@desc: 开始执行文本动画
--@author:Liang SongQiang
--@time:2018-08-23 15:14:42
function TextAnimLayer:startRunAnim()
    if MapIsEmpty(self._ui_list) then
        return
    end

    self.__co =
        coroutine.create(
        function()
            self.Panel_Show:setTouchEnabled(true)
            for index, ui in ipairs(self._ui_list) do
                self._curr_ui = ui
                ui:startRun()
                coroutine.yield()
            end

            if self._afterFunc then
                self._afterFunc()
            end

            self.__co = nil
            self._curr_ui = nil
            self.Panel_Show:setTouchEnabled(false)
        end
    )

    coroutine.resume(self.__co)
end

local update_time = 0
function TextAnimLayer:update(ft)
    if self.__co then
        if self._curr_ui:getPlayStatus() == 2 then
            --@desc 控件动画完成后，应该有一点延迟
            update_time = update_time + 1 / 30
            if update_time >= 1.5 then
                update_time = 0
                coroutine.resume(self.__co)
            end
        end
    end
end

--设置播放音乐
function TextAnimLayer:setMusicName(musicName)
    self.musicName = musicName
end

--设置音乐是否循环
function TextAnimLayer:setMusicIsLoop(isLoop)
    self.isLoop = isLoop
end

Helper:classDefNodeGetInstance(TextAnimLayer)
return TextAnimLayer
00000000000
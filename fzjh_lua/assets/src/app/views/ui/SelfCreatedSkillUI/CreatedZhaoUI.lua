local CreatedZhaoUI = class("CreatedZhaoUI", LayerEx)
local CreatedZhaoPresenter = require("app.presenters.selfCreatedSkill.createdZhao.CreatedZhaoPresenter")
local ICreatedZhaoPresenterOutput = require("app.presenters.selfCreatedSkill.createdZhao.ICreatedZhaoPresenterOutput")
local ICreatedZhaoPresenterInput = require("app.presenters.selfCreatedSkill.createdZhao.ICreatedZhaoPresenterInput")
local AnimTextUi = require("app.views.layer.TextAnimLayer.AnimTextUi")
local isImplement = require("third.assertIsInstance.assertIsInstance")

--@desc 最高的一个控件高度
CreatedZhaoUI.TEXT_TOP_MARGIN = 1775

--@desc 左边的距离
CreatedZhaoUI.TEXT_LEFT_MARGIN = cc.Director:getInstance():getWinSize().width / 2

--@desc 距离上一个文本控件的距离
CreatedZhaoUI.TEXT_DISTANCE_BIG = 40

CreatedZhaoUI.SCHEDULE_NORMAL_TIME = 1 / 30

CreatedZhaoUI.SCHEDULE_NAME = "PLAYACTION"

function CreatedZhaoUI:create()
    local p = CreatedZhaoUI:new()
    p:init()
    return p
end

function CreatedZhaoUI:init()
    self._round = require("Layer/SelfCreatedSkillUI/createdZhaoUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self)

    self:setshowAndHideAnimDuration(2)

    self:setShowAndHideAnimType("FADE")

    -- --@desc 注册唯一调度器
    self._handle =
        self:scheduleUnique(
        function(ft)
            self:update(ft)
        end,
        CreatedZhaoUI.SCHEDULE_NORMAL_TIME,
        CreatedZhaoUI.SCHEDULE_NAME
    )
end

function CreatedZhaoUI:showLayer(selfCreatedSkillSystem, zhaoCreateResult, callback)
    self._ICreatedZhaoPresenterInput = isImplement(CreatedZhaoPresenter:create(self, selfCreatedSkillSystem, zhaoCreateResult, callback), ICreatedZhaoPresenterInput)
    self._ICreatedZhaoPresenterInput:showLayer()
end

function CreatedZhaoUI:setShowLayer()
    self:show(
        function()
            self:startRunAnim()
        end
    )

    Audio:pauseMusic()

    self:__playBackgroundMusic()
    self:delayFunc(0.25, function()
        self:__playCreatingMusicEffect()
    end)
end

-- @desc 创建输入框
function CreatedZhaoUI:createEditBox()
    -- self.EditBoxArea:setTouchEnabled(true)
    local editBox
    local size = self.Panel_createZhaoName.EditBoxArea:getContentSize()
    if self.editBox == nil then
        editBox = ccui.EditBox:create(size, "请输入")
        self.editBox = editBox
        editBox:setFontColor(cc.c3b(255, 255, 255))
        editBox:setFontName("Font/default.ttf")
        editBox:setFontSize(54)
        editBox:setPlaceholderFontSize(54)
        editBox:setPlaceholderFontName("Font/default.ttf")
        editBox:setVisible(true)
        -- 设置输入类型
        editBox:setInputMode(6)
        editBox:setReturnType(1)

        editBox:onEditHandler(
            function(event)
                local eventName = event.name
                local eventTarget = event.target

                if PRINT_MODE == 1 then
                    print("eventName = " .. tostring(eventName))
                    print("eventTarget = " .. tostring(eventTarget))
                end

                if eventName == "began" then
                    self._isEditing = true
                elseif eventName == "changed" then
                    self._editBoxString = editBox:getText()
                    if PRINT_MODE == 1 then
                        print("self._editBoxString = " .. tostring(self._editBoxString))
                    end
                elseif eventName == "end" then
                elseif eventName == "return" then
                    self._isEditing = false
                end
            end
        )

        self.Panel_createZhaoName.EditBoxArea:getParent():addChild(editBox)
        editBox:setPosition(self.Panel_createZhaoName.EditBoxArea:getPositionX(), self.Panel_createZhaoName.EditBoxArea:getPositionY())
    end
end

-- @desc 还没想好取名按钮
function CreatedZhaoUI:setButtonCancel(func)
    self.Panel_createZhaoName.Button_Cancel:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function CreatedZhaoUI:setButtonOk(func)
    self.Panel_createZhaoName.Button_Yes:releaseFunc(
        function()
            if self.editBox ~= nil then
                self._editBoxString = self.editBox:getText()
                if func then
                    func(self._editBoxString)
                end
            else
            end
        end
    )
end

-- @desc 随机名称按钮
function CreatedZhaoUI:setRandomNameButton(func)
    self.Panel_createZhaoName.Button_randomName:releaseFunc(
        function()
            if self.editBox ~= nil and self._isEditing ~= true then
                local randomName = func()
                self.editBox:setText(randomName)
            end
        end
    )
end

function CreatedZhaoUI:setEditBoxText(text)
    if self.editBox ~= nil and self._isEditing ~= true then
        self.editBox:setText(text)
    end
end

function CreatedZhaoUI:setPanelCreateZhaoNameIsVisible(isVisible)
    self.Panel_createZhaoName:setVisible(isVisible)
end

function CreatedZhaoUI:hideLayer()
    PopupLayerController:hideLayer(
        "CreatedZhaoUI",
        function(layer)
            if self.editBox then
                self.editBox:setText("")
            end

            if not MapIsEmpty(self._ui_list) then
                for i, text_ui in ipairs(self._ui_list) do
                    text_ui:unscheduleAll()
                end
            end

            if self._hideCallback then
                self._hideCallback()
            end

            Audio:resumeMusic()

            self:__stopCreatingMusicEffect()
            self:__stopBackgroundMusic()

            self.__co = nil
            self._curr_index = nil
            self._curr_ui = nil
            self._ui_list = nil
            self.Panel_Show:removeAllChildren()
            self._animView = nil
            layer:hide()
        end
    )
end

function CreatedZhaoUI:popText(text)
    PopText(text)
end

function CreatedZhaoUI:setAfterAnimCallback(func)
    if type(func) ~= "function" then
        func = EMPTY_FUNC
    end
    self._afterFunc = func
end

function CreatedZhaoUI:setHideCallbackFunc(func)
    if type(func) ~= "function" then
        func = EMPTY_FUNC
    end
    self._hideCallback = func
end

function CreatedZhaoUI:createShowTextList(str, config, strTopMargin, strLeftMargin)
    if MapIsEmpty(self._ui_list) then
        self._ui_list = {}
    end

    local text_list = string.split(str, "|")

    if MapIsEmpty(text_list) then
        assert(false, "数组为空。")
        return
    end

    local ui_list = {}

    local _posX = Helper:getDef(strLeftMargin, CreatedZhaoUI.TEXT_LEFT_MARGIN)

    --@desc 第一个控件的Y轴坐标
    local _posY = Helper:getDef(strTopMargin, CreatedZhaoUI.TEXT_TOP_MARGIN)

    local pre_ui

    for index, str in ipairs(text_list) do
        --@desc 处理字符串
        local distance_type = 0

        --@desc 距离前面文本控件最下面的距离
        local pre_distance = CreatedZhaoUI.TEXT_DISTANCE_BIG

        local text_ui = AnimTextUi:createNormalAnimText(str, config)
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
    self._ui_list = ui_list
end

function CreatedZhaoUI:startRunAnim()
    if MapIsEmpty(self._ui_list) then
        return
    end

    self.__co =
        coroutine.create(
        function()
            for index, ui in ipairs(self._ui_list) do
                self._curr_ui = ui
                ui:startRun()
                coroutine.yield()
            end

            if self._afterFunc then
                self._afterFunc()
            end

            self._afterFunc = nil
            self.__co = nil
            self._curr_ui = nil
        end
    )

    coroutine.resume(self.__co)
end

function CreatedZhaoUI:setClickPanel(touchEnabled, func)
    self.Panel_back:setTouchEnabled(touchEnabled)
    self.Panel_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function CreatedZhaoUI:setButtonHide(isVisible, func)
    self.Button_Hide:setVisible(isVisible)
    self.Button_Hide:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function CreatedZhaoUI:setBackgroundMusic(backMusicName, isLoop)
    self.__bgMusicName = backMusicName
    self.__bgMusicLoop = Helper:getDef(isLoop, true)
end

function CreatedZhaoUI:__playBackgroundMusic()
    if self.__bgMusicName ~= nil then
        self.__bgMusicId = Audio:playEffect(self.__bgMusicName, self.__bgMusicLoop)
    end
end

function CreatedZhaoUI:__stopBackgroundMusic()
    if self.__bgMusicId ~= nil then
        Audio:stopEffect(self.__bgMusicId)
    end
end

function CreatedZhaoUI:__clearBackgroundMusicInfo()
    self.__bgMusicId = nil
    self.__bgMusicName = nil
    self.__bgMusicLoop = true
end

function CreatedZhaoUI:setCreatingMusicEffect(effectMusicName, isLoop)
    self.__creatingMusicName = effectMusicName
    self.__creatingMusicIsLoop = Helper:getDef(isLoop, false)
end

function CreatedZhaoUI:__playCreatingMusicEffect()
    if self.__creatingMusicName then
        self.__creatingMusicEffectId = Audio:playEffect(self.__creatingMusicName, self.__creatingMusicIsLoop)
    end
end

function CreatedZhaoUI:__stopCreatingMusicEffect()
    if self.__creatingMusicEffectId then
        Audio:stopEffect(self.__creatingMusicEffectId)
    end
end

function CreatedZhaoUI:__clearCreatingMusicEffectInfo()
    self.__creatingMusicEffectId = nil
    self.__creatingMusicName = nil
    self.__creatingMusicIsLoop = false
end

local update_time = 0
function CreatedZhaoUI:update(ft)
    if self.__co then
        if self._curr_ui:getPlayStatus() == 2 then
            --@desc 控件动画完成后，应该有一点延迟
            update_time = update_time + 1 / 30
            if update_time >= 0.6 then
                update_time = 0
                coroutine.resume(self.__co)
            end
        end
    end
end

function CreatedZhaoUI:richPrint(text)
    RichPrint("main", text)
end

function CreatedZhaoUI:playAnim(animName)
    if self._animView == nil then
        self._animView = Resource:getSkAnim("createZhao", 1)
        self.Panel_Show:addChild(self._animView)

        self._animView:setAnchorPoint(0, 0)
        self._animView:setPosition(cc.p(540, 960))
        self._animView:setLocalZOrder(-999)
    end
    self._animView:playAnim(animName)

    self._animView:registerSpineEventHandler(
        function(event)
            if self._afterFunc then
                self._afterFunc()
            end

            self._afterFunc = nil
        end,
        sp.EventType.ANIMATION_COMPLETE
    )
end

isImplement(CreatedZhaoUI, ICreatedZhaoPresenterOutput)
Helper:classDefNodeGetInstance(CreatedZhaoUI)
return CreatedZhaoUI
0000000
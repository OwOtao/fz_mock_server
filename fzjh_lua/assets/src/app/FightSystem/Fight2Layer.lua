local isTest = false

local BattleSceneRes = require("script.newbattle.demo.battleSceneConf")["战斗场景"]

local isImplement = require("third.assertIsInstance.assertIsInstance")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

--@RefType[src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
local CharacterUICtrl = require("app.FightSystem.UICtrl.CharacterUICtrl")

local CharacterInfoUI = require("app.FightSystem.UICtrl.UI.CharacterInfoUI")

local CharacterAnimUI = require("app.FightSystem.UICtrl.UI.CharacterAnimUI")

local ButtonsAreaCtrl = require("app.FightSystem.UICtrl.ButtonsAreaCtrl")

local CharacterCtrlFactory = require("app.FightSystem.UICtrl.CtrlFactory.CharacterCtrlFactory")

local FIGHT_AREA_UI_LAYER = {
    BACKGROUD = -1,
    ANIM_IDLE = 0
}

--@SuperType [LayerEx]
local Fight2Layer = class("Fight2Layer", LayerEx)

function Fight2Layer:create()
    local p = Fight2Layer.new()
    p:init()
    return p
end

function Fight2Layer:init()
    local ui = require("res.Layer.Fight2UI.Fight2UI").create()["root"]

    ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)

    --@desc 玩家id
    self.__playerId = nil

    --@desc 玩家角色的目标ID
    self.__targetId = nil

    self.__characterUICtrls = {}

    self.__leftUICtrls = {}

    self.__rightUICtrls = {}

    local leftCount = 1

    if isTest then
        -- self.PanelTest_Area:setVisible(true)
        -- self.PanelTest_Area.Button_1:releaseFunc(
        --     function()
        --         if leftCount > 3 then
        --             PopText("左边人数已满，无法添加")
        --             return
        --         end
        --         local FightCharacterFactory = require("app.FightSystem.Factory.CharacterFactory.FightCharacterFactory")
        --         local f_character = FightCharacterFactory:createTestFactoryCharacter(leftCount)
        --         self.__iFight:addCharacterToLeftTeam(f_character)
        --         leftCount = leftCount + 1
        --     end
        -- )
        -- local rightCount = 4
        -- self.PanelTest_Area.Button_2:releaseFunc(
        --     function()
        --         if rightCount > 6 then
        --             PopText("右边人数已满，无法添加")
        --             return
        --         end
        --         local FightCharacterFactory = require("app.FightSystem.Factory.CharacterFactory.FightCharacterFactory")
        --         local f_character = FightCharacterFactory:createTestNpcCharacter(rightCount)
        --         self.__iFight:addCharacterToRightTeam(f_character)
        --         rightCount = rightCount + 1
        --     end
        -- )
        -- self.PanelTest_Area.Button_3:releaseFunc(
        --     function()
        --         local buffNeeded = require("app.FightSystem.FightBuff.CustomBuffNeeded"):create()
        --         buffNeeded:setGetAttrFunc(
        --             function(attrName)
        --                 local attrs = {
        --                     zhengqi = 1,
        --                     currcon = 10,
        --                     conCondSkill = 1,
        --                     strCondSkill = 1,
        --                     qiLimit = 100
        --                 }
        --                 assert(attrs[attrName] ~= nil, "找不到属性:" .. tostring(attrName))
        --                 return attrs[attrName]
        --             end
        --         )
        --         buffNeeded:setDynamicArg1(0.011)
        --         buffNeeded:setDynamicArg2(2)
        --         buffNeeded:setDynamicArg3(100)
        --         buffNeeded:setSelfWeaponType("剑")
        --         buffNeeded:setTargetWeaponType("刀")
        --         self.__iFight:getBuffSystem():addBuff(self.__playerId, "101001", buffNeeded)
        --     end
        -- )
        -- self.PanelTest_Area.Button_4:releaseFunc(
        --     function()
        --         self.__iFight:addSendCommand(
        --             {
        --                 type = FightCommons.CMD_TYPE.CHARACTER_ACTIVE,
        --                 c_id = "1",
        --                 data = {
        --                     act_id = "diyulian"
        --                 }
        --             }
        --         )
        --     end
        -- )
    else
        self.PanelTest_Area:setVisible(false)
    end
end

function Fight2Layer:setBattleSceneId(sceneId)
    self.__battleSceneId = sceneId
end

function Fight2Layer:setBtnAreaCtrlClass(classFile)
    self.__btnAreaCtrlClass = classFile
end

--@desc: 战斗按钮区域初始化
--@author:Seven
--@time:2021-07-01 16:22:01
function Fight2Layer:__initBtnAreaCtrl()
    --@RefType [src.app.FightSystem.UICtrl.ButtonsAreaCtrl#ButtonsAreaCtrl]
    self.__btnAreaCtrl = self.__btnAreaCtrlClass:create()

    self.__btnAreaCtrl:setBtnAreaParent(self.ButtonsArea)

    self.__btnAreaCtrl:setBtnNode(self.UserCtrlBtn)

    self.__btnAreaCtrl:setFightUICtrl(self)

    self.__btnAreaCtrl:init()

    self.__btnAreaCtrl:setVisible(false)
end

function Fight2Layer:__initInfoAreaCtrl()
    local CharacterInfoAreaUI = require("app.FightSystem.UICtrl.UI.CharacterInfoAreaUI")

    local ui = CharacterInfoAreaUI:create(self.RolesInfoArea)

    local CharacterInfoAreaCtrl = require("app.FightSystem.UICtrl.CharacterInfoAreaCtrl")
    --@RefType [src.app.FightSystem.UICtrl.CharacterInfoAreaCtrl#CharacterInfoAreaCtrl]
    self.__infoAreaCtrl = CharacterInfoAreaCtrl:create()

    self.__infoAreaCtrl:setInfoAreaUI(ui)

    self.__infoAreaCtrl:setFightUICtrl(self)

    self.__infoAreaCtrl:init()
end

function Fight2Layer:__initScene()
    if self.__backImgView then
        self.__backImgView:removeFromParent()
    end

    self.__backImgView = ccui.ImageView:create(BattleSceneRes[self.__battleSceneId].fightBackground)

    self.__backImgView:setPositionY(0)

    self.__backImgView:setAnchorPoint(cc.p(0, 0))

    self.__backImgView:setLocalZOrder(FIGHT_AREA_UI_LAYER.BACKGROUD)

    self.FightArea:addChild(self.__backImgView)
end

function Fight2Layer:initLayer()
    self:setVisible(false)

    self:__initBtnAreaCtrl()

    self:__initInfoAreaCtrl()

    self:initPrintRichText()

    self.EndTextArea:setVisible(false)
end

function Fight2Layer:createPlayerCtlBtnUI()
    local CharacterControllerBtnUI = require("app.FightSystem.UICtrl.UI.CharacterControllerBtnUI")
    local btn_node = self.UserCtrlBtn:clone()
    Helper:convertUIByParent(btn_node)
    --@RefType [src.app.FightSystem.UICtrl.UI.CharacterControllerBtnUI#CharacterControllerBtnUI]
    local btnUI = CharacterControllerBtnUI:create(btn_node)

    return btnUI
end

--@desc: 左边玩家信息面板创建
--@author:Seven
--@time:2021-07-02 14:34:15
--@return [src.app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI#ICharacterInfoUI]
function Fight2Layer:createLeftPlayerUI()
    local uiNode = self.RoleInfoPanel_L:clone()
    Helper:convertUIByParent(uiNode)

    local PlayerInfoUI = require("app.FightSystem.UICtrl.UI.CharacterInfoUI.PlayerInfoUI")

    local p = PlayerInfoUI:create(uiNode)

    self:__initInfoLeftPanelIcons(p)

    return p
end

--@desc: 右边队友信息面板创建
--@author:Seven
--@time:2021-07-01 17:26:03
--@return [src.app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI#ICharacterInfoUI]
function Fight2Layer:createLeftPlayerTeammateUI()
    local uiNode = self.TeamRoleInfoPanel_L:clone()

    Helper:convertUIByParent(uiNode)

    local TeammateInfoUI = require("app.FightSystem.UICtrl.UI.CharacterInfoUI.TeammateInfoUI")

    local p = TeammateInfoUI:create(uiNode)

    self:__initInfoLeftPanelIcons(p)

    return p
end

--@desc: 右边目标信息面板创建
--@author:Seven
--@time:2021-07-02 14:34:28
--@return [src.app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI#ICharacterInfoUI]
function Fight2Layer:createRightTargetUI()
    local uiNode = self.RoleInfoPanel_R:clone()
    Helper:convertUIByParent(uiNode)

    local PlayerTargetInfoUI = require("app.FightSystem.UICtrl.UI.CharacterInfoUI.PlayerTargetInfoUI")

    local p = PlayerTargetInfoUI:create(uiNode)

    self:__initInfoRightPanelIcons(p)

    return p
end

--@return [src.app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI#ICharacterInfoUI]
function Fight2Layer:createRightTeammateUI()
    local uiNode = self.TeamRoleInfoPanel_R:clone()
    Helper:convertUIByParent(uiNode)

    local TeammateInfoUI = require("app.FightSystem.UICtrl.UI.CharacterInfoUI.TeammateInfoUI")

    local p = TeammateInfoUI:create(uiNode)

    self:__initInfoRightPanelIcons(p)

    return p
end

--@desc:
--@author:Seven
--@time:2022-04-21 12:04:48
--@infoUI: [src.app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI#ICharacterInfoUI]
function Fight2Layer:__initInfoLeftPanelIcons(infoUI)
    for j = 1, FightCommons.BUFFICON_MAXCOUNT do
        local buffIcon = self:createBufferIconNode()

        local buffIconPosX = 35.08 + (j - 1) * 59.96

        buffIcon:setPosition(cc.p(buffIconPosX, 31.05))

        buffIcon:setVisible(true)

        infoUI:addBuffIcon(buffIcon, j)
    end

    for i = 0, FightCommons.ALL_BUFFICON_MAXCOUNT - 1 do
        local buffIcon = self:createBigBuffIconNode()

        local x = math.fmod(i, 6) + 1

        local y = math.modf(i / 6) + 1

        local buffIconPosX = 65.62 + (x - 1) * 76.45

        local buffIconPosY = 391.08 - (y - 1) * 83.83

        buffIcon:setPosition(cc.p(buffIconPosX, buffIconPosY))

        buffIcon:setVisible(true)

        infoUI:addBuffBigIcon(buffIcon, i + 1)
    end
end

function Fight2Layer:__initInfoRightPanelIcons(infoUI)
    for j = 1, FightCommons.BUFFICON_MAXCOUNT do
        local buffIcon = self:createBufferIconNode()

        local buffIconPosX = 477.76 - (j - 1) * 59.96

        buffIcon:setPosition(cc.p(buffIconPosX, 31.05))

        buffIcon:setVisible(true)

        infoUI:addBuffIcon(buffIcon, j)
    end

    for i = 0, FightCommons.ALL_BUFFICON_MAXCOUNT - 1 do
        local buffIcon = self:createBigBuffIconNode()

        local x = math.fmod(i, 6) + 1

        local y = math.modf(i / 6) + 1

        local buffIconPosX = 447.87 - (x - 1) * 76.45

        local buffIconPosY = 391.08 - (y - 1) * 83.83

        buffIcon:setPosition(cc.p(buffIconPosX, buffIconPosY))

        buffIcon:setVisible(true)

        infoUI:addBuffBigIcon(buffIcon, i + 1)
    end
end

function Fight2Layer:createBufferIconNode()
    local uiNode = self.ImgIcon:clone()

    Helper:convertUIByParent(uiNode)

    return uiNode
end

function Fight2Layer:createBigBuffIconNode()
    local uiNode = self.ImgIconBig:clone()

    Helper:convertUIByParent(uiNode)

    return uiNode
end

function Fight2Layer:hideLayer()
    self:unscheduleAll()
    PopupLayerController:hideLayer(
        "Fight2Layer",
        function(layer)
            layer:hide(
                function()
                    --@desc 玩家id
                    self.__playerId = nil

                    --@desc 玩家角色的目标ID
                    self.__targetId = nil

                    self.__characterUICtrls = {}

                    self.__leftUICtrls = {}

                    self.__rightUICtrls = {}

                    print("Fight2Layer hide")
                    self.__infoAreaCtrl:onDestroy()
                    self.__btnAreaCtrl:onDestroy()
                    self.FightArea:removeAllChildren()
                    self.__backImgView = nil
                end
            )
        end
    )
end

function Fight2Layer:setIUpdate(update_sys)
    --@RefType [src.app.FightSystem.Updater.LocalUpdateSystem#LocalUpdateSystem]
    self.__iUpdateSys = update_sys
end

function Fight2Layer:setIFight(iFight)
    --@RefType[src.app.FightSystem.Fight.Fight#Fight]
    self.__iFight = iFight
end

function Fight2Layer:showLayer(callback)
    self:show(
        function()
            callback()
            self.__duration = 0
            self:schedule(
                function(ft)
                    self.__iUpdateSys:update(ft)
                end,
                1 / FightCommons.VIWE_FPS
            )
        end
    )
end

function Fight2Layer:getLeftUICtrls()
    return self.__leftUICtrls
end

function Fight2Layer:getRightUICtrls()
    return self.__rightUICtrls
end

function Fight2Layer:__showStarText()
    self.BeginText:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(
                function()
                    self.BeginText:setVisible(true)
                    self.BeginText:setOpacity(255)
                    self.BeginText:setScale(0.8)
                    self.BeginText:setString("开始战斗")
                end
            ),
            cc.ScaleTo:create(0.3, 1.2),
            cc.ScaleTo:create(0.2, 1.0),
            cc.FadeOut:create(0.1),
            cc.CallFunc:create(
                function()
                    self.BeginText:setVisible(false)
                end
            )
        )
    )
end

function Fight2Layer:__shadeHide()
    self.Panel_Shade:setOpacity(255)
    self.Panel_Shade:setVisible(true)
    self.Panel_Shade:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.6),
            cc.Spawn:create(
                cc.Sequence:create(
                    cc.FadeOut:create(0.3),
                    cc.CallFunc:create(
                        function()
                            self.Panel_Shade:setVisible(false)
                        end
                    )
                )
            )
        )
    )
end

function Fight2Layer:startFight(callback)
    self:__initScene()
    self.__infoAreaCtrl:startFight()
    self.__btnAreaCtrl:startFight()
    self:__updateCharacterTagView()
    self:showLayer(
        function()
            callback()
            self:__shadeHide()
            self:__showStarText()
            self.__btnAreaCtrl:setVisible(true)
        end
    )
end

function Fight2Layer:__addCharacterAnim(animNode)
    animNode:setLocalZOrder(FIGHT_AREA_UI_LAYER.ANIM_IDLE)
    self.FightArea:addChild(animNode)
end

function Fight2Layer:addLeftFightCharacter(f_character)
    local characterUIBuilderParams = CharacterCtrlFactory:getCtrlBuilderParams(f_character)

    local animNode, animInfoPanel

    animNode = self.AnimNode:clone()

    local ctrl = CharacterCtrlFactory:createCharterUICtrl(animNode, characterUIBuilderParams)

    ctrl:setFightUICtrl(self)

    ctrl:setAnimScaleX(1)

    f_character:setCharacterOutput(ctrl)

    self:__addCharacterAnim(ctrl:getAnimUI():getNode())

    table.insert(self.__characterUICtrls, ctrl)

    table.insert(self.__leftUICtrls, ctrl)

    self.__infoAreaCtrl:addLeftCharacterUICtrl(ctrl)

    --@desc 玩家视角只能在左边
    if ctrl:isPlayer() then
        ctrl:showAnimTagView("player")
        self:setPlayer(ctrl:getId())
        self:setTargetId(ctrl:getTargetId())
    end
end

function Fight2Layer:setPlayer(playerId)
    self.__playerId = playerId
    self.__infoAreaCtrl:setPlayerId(playerId)
    self.__btnAreaCtrl:setPlayerId(playerId)
end

function Fight2Layer:setTargetId(targetId)
    self.__targetId = targetId
    self.__infoAreaCtrl:setTargetId(targetId)
end

function Fight2Layer:addRightFightCharacter(f_character)
    local characterUIBuilderParams = CharacterCtrlFactory:getCtrlBuilderParams(f_character)

    local animNode, animInfoPanel

    animNode = self.AnimNode:clone()

    local ctrl = CharacterCtrlFactory:createCharterUICtrl(animNode, characterUIBuilderParams)

    ctrl:setFightUICtrl(self)

    ctrl:setAnimScaleX(-1)

    f_character:setCharacterOutput(ctrl)

    self:__addCharacterAnim(ctrl:getAnimUI():getNode())

    table.insert(self.__characterUICtrls, ctrl)

    table.insert(self.__rightUICtrls, ctrl)

    self.__infoAreaCtrl:addRightCharacterUICtrl(ctrl)
end

function Fight2Layer:getCharacterUICtrl(character_id)
    if not MapIsEmpty(self.__characterUICtrls) then
        for i = 1, #self.__characterUICtrls do
            --@RefType[src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
            local ctrl = self.__characterUICtrls[i]

            if ctrl:getVmAttr("id") == character_id then
                return ctrl
            end
        end
    end

    assert(false, "未找到 " .. character_id .. "对应的UICtrl")
end

function Fight2Layer:tryGetCharacterUICtrls(condition)
    if not MapIsEmpty(self.__characterUICtrls) then
        for i = 1, #self.__characterUICtrls do
            --@RefType[src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
            local ctrl = self.__characterUICtrls[i]

            if condition(ctrl) then
                return true, ctrl
            end
        end
    end

    return false
end

function Fight2Layer:__updateCharacterTagView()
    if #self.__characterUICtrls <= 0 then
        return
    end
    for _, characterCtrl in ipairs(self.__characterUICtrls) do
        local c_id = characterCtrl:getId()

        if c_id == self.__playerId then
            characterCtrl:showAnimTagView("player")
        elseif c_id == self.__targetId then
            characterCtrl:showAnimTagView("target")
        else
            characterCtrl:showAnimTagView("other")
        end
    end
end

function Fight2Layer:characterChangeTarget(chooserId, targetId)
    self.__infoAreaCtrl:characterChangeTarget(chooserId, targetId)
    if self.__playerId ~= chooserId then
        return
    end
    self.__targetId = targetId

    self:__updateCharacterTagView()
end

function Fight2Layer:sendPlayerCommand(cmd_type, data)
    self.__iFight:addSendCommand(
        {
            type = cmd_type,
            c_id = self.__playerId,
            data = data
        }
    )
end

function Fight2Layer:initPrintRichText()
    if self.richPrint then
        self.richPrint:removeFromParent()
        self.richPrint = nil
    end
    self.richPrint = ExtRichTextScroll:create()
    self.PrintArea:addChild(self.richPrint)
    local size = self.PrintArea.Text_print:getContentSize()
    local x, y = self.PrintArea.Text_print:getPosition()
    self.richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
    self.richPrint:setSize(size)
    self.richPrint:setScrollBarEnabled(false)
    self.richPrint:getRichText():setVerticalSpace(5)
    self.richPrint.fightStatusStringArray = {}
    -- 设置最大显示高度
    self.richPrint:setTextMaxHeight(size.height)

    self.richPrint:setTouchEnabled(false)

    self.richPrintTextArray = {}
end

local textColor = cc.c3b(159, 159, 159)
-- 战斗输出默认文字颜色
local textFont = Resource:getFontPath("default")
local RECORD_FIGHT_STATUS_STRING_LINE_MAX = 50

function Fight2Layer:printFightMsg(msg)
    if table.getn(self.richPrintTextArray) >= 50 then
        table.remove(self.richPrintTextArray, 1)
    end

    table.insert(self.richPrintTextArray, msg)

    msg = tostring(msg)
    self.richPrint:pushBackText(msg, textColor, 255, textFont, 42)
    self.richPrint:pushBackNewLine(0)
end

function Fight2Layer:richPrintFinish()
    local fightStatusString = table.concat(self.richPrintTextArray, "NOR\n")

    if self.richPrint then
        self.richPrint:removeFromParent()
        self.richPrint = nil
    end

    self.richPrint = ExtRichTextScroll:create()
    self.PrintArea:addChild(self.richPrint)
    local size = self.PrintArea.Text_print:getContentSize()
    local x, y = self.PrintArea.Text_print:getPosition()
    self.richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
    self.richPrint:setSize(size)
    self.richPrint:setScrollBarEnabled(false)
    self.richPrint:getRichText():setVerticalSpace(5)
    self.richPrint.fightStatusStringArray = {}
    -- 设置最大显示高度
    self.richPrint:setTextMaxHeight(size.height)

    -- 设置最大显示高度
    self.richPrint:setTextMaxHeight(9999999999)

    self:printFightMsg(fightStatusString)
end

function Fight2Layer:popMessage(msg)
    PopText(msg)
end

function Fight2Layer:showFinish(fightResult)
    self:richPrintFinish()

    self.__btnAreaCtrl:setVisible(false)
    self.EndTextArea:setVisible(true)
    self.EndTextArea:releaseFunc(
        function()
            self.__iFight:destoryFight()
        end
    )
    self.EndTextArea:setTouchEnabled(false)
    self.EndTextArea:setScale(0.8)
    self.EndTextArea:runActionWithName(
        "showFightEndTextArea",
        cc.Sequence:create(
            cc.ScaleTo:create(0.1, 1.2),
            cc.ScaleTo:create(0.1, 1),
            cc.CallFunc:create(
                function()
                    self.EndTextArea:setTouchEnabled(true)
                end
            )
        )
    )

    local text_1, text_2 = "", ""

    if fightResult == 3 then
        text_1 = "逃跑"
        text_2 = "你大喝一声：“三十六计，走为上计”，成功逃跑了"
    elseif fightResult == 4 then
        text_1 = "平局"
        text_2 = "你和双方同时倒在地上"
    elseif fightResult == 1 then
        local target_ctrls = self:getRightUICtrls()

        local charactersName = {}

        for __, ctrl in pairs(target_ctrls) do
            local name = ctrl:getVmAttr("name")
            table.insert(charactersName, name)
        end

        text_1 = "胜利"
        text_2 = "你成功战胜了：" .. charactersName[1]
        if #charactersName > 1 then
            for i = 2, #charactersName do
                text_2 = text_2 .. "\n" .. "                     " .. charactersName[i]
            end
        else
            text_2 = "\n你成功战胜了：" .. charactersName[1] .. "\n"
        end
    elseif fightResult == 2 then
        text_1 = "失败"
        text_2 = "\n你被对方打趴在地\n"
    end

    self.EndTextArea.Text_1:setString(text_1)
    self.EndTextArea.Text_2:setString(text_2)
end

function Fight2Layer:showPlayerActiveSkillInfoPanel(act_id)
    if self.__playerId == nil then
        error("Fight2Layer:showPlayerActiveSkillInfo 当前战斗没有主角，无法调用该方法。")
    end

    local character_ctrl = self:getCharacterUICtrl(self.__playerId)

    local act_skill_vm = character_ctrl:getVMActiveSkill(act_id)

    PopupLayerController:showLayer(
        "ActiveSkillInfoInBattlePresenters",
        function(layer)
            -- -- --@RefType [ActiveSkillInfoInBattlePresenters]
            -- local layer = layer
            layer:setName(act_skill_vm:getName())

            layer:setLevel(act_skill_vm:getLevel())

            layer:setDesc(act_skill_vm:getDesc())

            layer:setConditionTexts(act_skill_vm:getConditionTexts())

            layer:setNeiliCost(act_skill_vm:getCostNeili())

            layer:showLayer()
        end
    )
end

function Fight2Layer:hidePlayerActiveSkillInfoPanel()
    PopupLayerController:hideLayer(
        "ActiveSkillInfoInBattlePresenters",
        function(layer)
            layer:hideLayer()
        end
    )
end

function Fight2Layer:updateView(ft)
    if not MapIsEmpty(self.__characterUICtrls) then
        table.sort(
            self.__characterUICtrls,
            function(a, b)
                return a:getPosition().y > b:getPosition().y
            end
        )

        for i = 1, #self.__characterUICtrls do
            local ctrl = self.__characterUICtrls[i]
            ctrl:update(ft)
            ctrl:getAnimUI():setLocalZOrder(i)
        end
    end

    self.__infoAreaCtrl:onUpdate(ft)

    self.__btnAreaCtrl:onUpdate(ft)
end

function Fight2Layer:updatePlayerBtnProgress(c_id, btnId, value, maxValue)
    if c_id ~= self.__playerId then
        return
    end

    self.__btnAreaCtrl:setBtnProgress(btnId, value, maxValue)
end

function Fight2Layer:updateBtnVisible(c_id, btnId, bool)
    if c_id ~= self.__playerId then
        return
    end

    self.__btnAreaCtrl:setBtnVisible(btnId, bool)
end

function Fight2Layer:updateBtnEnable(c_id, btnId, bool)
    if c_id ~= self.__playerId then
        return
    end

    self.__btnAreaCtrl:setBtnEnable(btnId, bool)
end

function Fight2Layer:removeBtn(c_id, btnId)
    if c_id ~= self.__playerId then
        return
    end

    self.__btnAreaCtrl:removeBtn(btnId)
end

function Fight2Layer:updatePlayerActiveSkillBtns(c_id, activeSkillInfos)
    if c_id ~= self.__playerId then
        return
    end

    self.__btnAreaCtrl:addActiveSkills(activeSkillInfos)

    self.__btnAreaCtrl:updateBtnPos()
end

Helper:classDefNodeGetInstance(Fight2Layer)
return Fight2Layer
000
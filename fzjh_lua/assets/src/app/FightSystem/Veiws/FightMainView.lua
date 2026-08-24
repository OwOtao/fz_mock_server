--[[
    author:Seven
    time:2023-10-18 20:24:41
    desc:
]]
local isTest = false

local BattleSceneRes = require("script.newbattle.demo.battleSceneConf")["战斗场景"]

local isImplement = require("third.assertIsInstance.assertIsInstance")

local FightCommons = require("app.FightSystem.FightCommons")

local NodeActionManager = require("app.extends.NodeAction.NodeActionManager")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local Actions = require("app.extends.NodeAction.Actions")

local DoTween = require("third.dotween.DoTween")

local FIGHT_AREA_UI_LAYER = {
    BACKGROUD = -1,
    ANIM_IDLE = 0
}

--@SuperType [LayerEx]
local FightMainView = class("FightMainView", LayerEx)

function FightMainView:create(...)
    return FightMainView.new():__init(...)
end

function FightMainView:__init(bgSceneId, viewLayoutClass)
    self.__UI = require("res.Layer.Fight2UI.Fight2UI").create()["root"]

    self.__UI:addTo(self)

    self:setVisible(false)

    --@RefType [NodeActionManager]
    self.__actionManager = NodeActionManager:create()

    --@RefType [src.third.dotween.DoTween#DoTween]
    self.__doTweenManager = DoTween:create()

    --@RefType [src.app.FightSystem.Veiws.ViewEvents.ViewsEventsManager#ViewEventsManager]
    self.__viewEventManager = require("app.FightSystem.Veiws.ViewEvents.ViewsEventsManager"):create(self)

    self.__viewCharacters = {}

    --@desc 战场背景图片路径
    local sceneId = Helper:getDef(bgSceneId, BattleConstConf:get("fightBackgroundDefaultID"))

    self.__backgroundImgPath = BattleSceneRes[sceneId].fightBackground

    self:__createUIController()

    self:getUINode("EndTextArea"):setVisible(false)

    self:getUINode("Txt_Msg"):setVisible(true)

    self:hideReadyPanel()

    if viewLayoutClass == nil then
        self.__viewLayoutClass = require("app.FightSystem.Veiws.ViewsLayout.UserViewLayout")
    else
        self.__viewLayoutClass = viewLayoutClass
    end

    if isTest then
    else
        self:getUINode("PanelTest_Area"):setVisible(false)
    end

    return self
end

--@desc: 创建UI控制器
--@author:Seven
--@time:2023-10-20 20:38:18
function FightMainView:__createUIController()
    --@RefType [src.app.FightSystem.Veiws.CharacterInfoViews.CharactersInfoAreaViewCtrl#CharactersInfoAreaViewCtrl]
    self.__infoAreaController = require("app.FightSystem.Veiws.CharacterInfoViews.CharactersInfoAreaViewCtrl"):create(self)

    --@RefType [src.app.FightSystem.Veiws.BattleSceneAreaViews.BattleSceneAreaViewCtrl#BattleSceneAreaViewCtrl]
    self.__battleAreaController = require("app.FightSystem.Veiws.BattleSceneAreaViews.BattleSceneAreaViewCtrl"):create(self)

    --@RefType [src.app.FightSystem.Veiws.PlayerButtonCtrlAreaViews.PlayerButtonAreaViewCtrl#PlayerButtonAreaViewCtrl]
    self.__buttonsAreaController = require("app.FightSystem.Veiws.PlayerButtonCtrlAreaViews.PlayerButtonAreaViewCtrl"):create(self)

    --@RefType [src.app.FightSystem.Veiws.PrintAreaView.PrintAreaViewCtrl#PrintAreaViewCtrl]
    self.__printAreaController = require("app.FightSystem.Veiws.PrintAreaView.PrintAreaViewCtrl"):create(self)
end

function FightMainView:getUINode(name)
    return self.__UI:getChildByName(name)
end

function FightMainView:runUINodeAction(node, action)
    self.__actionManager:runAction(node, action)
end

--@desc: 执行插值类
--@author:Seven
--@time:2023-10-25 11:16:24
--@tween: [src.third.dotween.Tween#Tween]
function FightMainView:doUITween(tween)
    return self.__doTweenManager:doTween(tween)
end

function FightMainView:showReadyPanel()
    self.__readyPanelShowing = true
    self:getUINode("Panel_Ready"):setVisible(true)
end

function FightMainView:hideReadyPanel()
    self.__readyPanelShowing = false
    local uiNode = self:getUINode("Panel_Ready")

    uiNode:setOpacity(255)

    uiNode:setVisible(true)

    self:runUINodeAction(
        uiNode,
        Actions.Sequence:create(
            Actions.DelayTime:create(0.05),
            Actions.Spawn:create(
                Actions.Sequence:create(
                    Actions.FadeOut:create(0.15),
                    Actions.CallFunc:create(
                        function()
                            uiNode:setVisible(false)
                        end
                    )
                )
            )
        )
    )
end

function FightMainView:readyPanelIsShow()
    return self.__readyPanelShowing
end

--@desc: 执行数值插值
--@author:Seven
--@time:2023-10-25 11:15:05
--@getter: function 获取当前值的方法
--@setter: function 设置当前值得方法
--@endValue: 目标值
--@duration: 插值时间
--@return [src.third.dotween.NumberTween#NumberTween]
function FightMainView:doUINumberTween(getter, setter, endValue, duration)
    return self.__doTweenManager:doNumber(getter, setter, endValue, duration)
end

function FightMainView:getPlayerId()
    return self.__playerId
end

function FightMainView:playSound(audioName)
    Audio:playEffectWithFileName(audioName, false)
end

function FightMainView:showFightStart(fight, isOnlineFight, callback)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight

    self.__playerId = self.__fight:getPlayerId()

    local viewLayout = self.__viewLayoutClass:create(self, self.__fight)
    viewLayout:initLayout()

    self.__infoAreaController:startFightInit()

    self.__battleAreaController:startFightInit()

    self.__buttonsAreaController:startFightInit()

    if not isOnlineFight then
        self:getUINode("Txt_Msg"):setVisible(false)
    end

    self:show(
        function()
            self:maxZ()
            callback()
        end
    )
end

--@desc: 添加角色
--@author:Seven
--@time:2023-10-20 14:42:45
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
function FightMainView:addViewCharacter(viewCharacter)
    self.__viewCharacters[viewCharacter:getId()] = viewCharacter

    table.insert(self.__viewCharacters, viewCharacter)

    viewCharacter:setMainView(self)
end

--@desc: 获得角色
--@author:Seven
--@time:2023-10-20 14:44:49
--@id: 角色id
--@return [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
function FightMainView:getViewCharacter(id)
    if self.__viewCharacters[id] == nil then
        assert(false, "FightMainView:getViewCharacter() not found character - id:" .. tostring(id))
    end

    return self.__viewCharacters[id]
end

function FightMainView:walkViewCharacters(func)
    for i, v in ipairs(self.__viewCharacters) do
        if func(v) then
            break
        end
    end
end

function FightMainView:getBackgroundImgPath()
    return self.__backgroundImgPath
end

function FightMainView:updateView(dt)
    self.__infoAreaController:update(dt)
    self.__battleAreaController:update(dt)
    self.__buttonsAreaController:update(dt)
    self.__actionManager:update(dt)
    self.__doTweenManager:update(dt)
    self.__viewEventManager:updateEventActions(dt)
    self.__viewEventManager:doViewEvents()
end

--@region viewEvents 视图事件
function FightMainView:addViewEvent(event)
    self.__viewEventManager:addViewEvent(event)
end

function FightMainView:addViewEventAction(eventAction)
    self.__viewEventManager:addViewEventAction(eventAction)
end
--@endregion

--@region battleArea 战斗动画区域

--@desc: 设置战场翻转系数
--@author:Seven
--@time:2023-10-23 20:38:10
--@factor: 翻转系数
function FightMainView:setBattleAreaFilpFactor(factor)
    self.__battleAreaController:setFilpFactor(factor)
end

function FightMainView:addBattleCharacterAnimView(viewCharacter)
    self.__battleAreaController:addCharacterAnimView(viewCharacter)
end

--@desc: 角色动画头顶弹字
--@author:Seven
--@time:2023-10-24 11:01:09
--@id: 角色ID
--@text: 文本
function FightMainView:popHeadTextInAnimView(id, text)
    self.__battleAreaController:popOverHeadText(id, text)
end

function FightMainView:setAnimHeadTag(id, tagType)
    self.__battleAreaController:setAnimHeadTag(id, tagType)
end

--@desc: 播放动画
--@author:Seven
--@time:2023-10-24 11:02:27
--@id: 角色id
--@animName: 动画名
--@loop: 是否循环 true false
--@eventCallback: 事件回调
--@completeCallback: 动画播放完成回调
function FightMainView:playCharacterAnim(id, animName, loop, eventCallback, completeCallback)
    self.__battleAreaController:playAnimView(id, animName, loop, eventCallback, completeCallback)
end

--@desc: 播放角色入场或胜利动画
--@author:LvBin
--@time:2025-02-18 15:18:50
--@id:角色id
--@animName:动画名
--@loop: 是否循环 true false
--@eventCallback: 事件回调
--@completeCallback: 动画播放完成回调
function FightMainView:playCharacterEnterVictoryAnim(id, animName, loop, eventCallback, completeCallback)
    self.__battleAreaController:playEnterVictoryAnim(id, animName, loop, eventCallback, completeCallback)
end

function FightMainView:playOneOffEffectAnim(id, animName)
    self.__battleAreaController:playOneOffEffect(id, animName)
end

function FightMainView:getCharacterBonePosition(id, boneName)
    return self.__battleAreaController:getAnimBonePosition(id, boneName)
end

--@desc: 设置动画可见
--@author:Seven
--@time:2023-10-24 21:13:16
--@id: 角色id
--@bool: true | false
function FightMainView:setCharacterAnimVisible(id, bool)
    return self.__battleAreaController:setAnimVisible(id, bool)
end

function FightMainView:setCharacterAnimWeaponSkin(id, weaponSkin)
    return self.__battleAreaController:setAnimWeaponSkin(id, weaponSkin)
end

function FightMainView:setCharacterAnimPosition(id, x, y, h)
    return self.__battleAreaController:setAnimPosition(id, x, y, h)
end

function FightMainView:showCharacterShieldAnim(id, shieldName)
    return self.__battleAreaController:showAnimShield(id, shieldName)
end

function FightMainView:hideCharacterShieldAnim(id)
    return self.__battleAreaController:hideAnimShield(id)
end

function FightMainView:showCharacterShadowAnim(id, animName)
    return self.__battleAreaController:playShadowEffectAnim(id, animName)
end

function FightMainView:hideCharacterShadowAnim(id)
    return self.__battleAreaController:hideShadowEffectAnim(id)
end

function FightMainView:showStatusText(id, text)
    self.__battleAreaController:showStatusText(id, text)
end

function FightMainView:hideStatusText(id)
    self.__battleAreaController:hideStatusText(id)
end

--@endregion

--@region buttonsArea 按钮区域
function FightMainView:setButtonAreaVisible(bool)
    self.__buttonsAreaController:setAreaVisible(bool)
end

--@desc: 获取按钮视图UI
--@author:Seven
--@time:2023-10-25 11:38:27
--@index: 索引
--@return [src.app.FightSystem.Veiws.PlayerButtonCtrlAreaViews.UI.PlayerButtonViewUI#PlayerButtonViewUI]
function FightMainView:getPlayerButtonViewUI(index)
    return self.__buttonsAreaController:getBtnViewUI(tonumber(index))
end

--@desc: 显示主动技能面板信息接口
--@author:Seven
--@time:2023-11-07 16:21:03
--@viewActiveSkill: [src.app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewActiveSkill#ViewActiveSkill]
function FightMainView:showActiveSkillPanel(viewActiveSkill)
    PopupLayerController:showLayer(
        "ActiveSkillInfoInBattlePresenters",
        function(layer)
            -- -- --@RefType [ActiveSkillInfoInBattlePresenters]
            -- local layer = layer
            layer:setName(viewActiveSkill:getViewActiveName())

            layer:setLevel(viewActiveSkill:getLevel())

            layer:setDesc(viewActiveSkill:getDesc())

            layer:setConditionTexts(viewActiveSkill:getConditionText())

            layer:setNeiliCost(viewActiveSkill:getCostNeili())

            layer:showLayer()
        end
    )
end

function FightMainView:hideActiveSkillPanel()
    PopupLayerController:hideLayer(
        "ActiveSkillInfoInBattlePresenters",
        function(layer)
            layer:hideLayer()
        end
    )
end

function FightMainView:fightFinish(texts)
    self.__buttonsAreaController:setAreaVisible(false)

    self.__printAreaController:openTouch()

    local node = self:getUINode("EndTextArea")

    Helper:convertUIByParent(node)

    node:setVisible(true)
    node:setTouchEnabled(false)
    node:setScale(0.8)
    node:releaseFunc(
        function()
            self.__fight:fightEnd()
            self:hide(
                function()
                    self:destory()
                end
            )
        end
    )
    self:runUINodeAction(
        node,
        Actions.Sequence:create(
            Actions.ScaleTo:create(0.1, 1.2),
            Actions.ScaleTo:create(0.1, 1),
            Actions.CallFunc:create(
                function()
                    node:setTouchEnabled(true)
                end
            )
        )
    )
    node.Text_1:setString(texts.text1)
    node.Text_2:setString(texts.text2)
end

function FightMainView:destory()
    scheduler.performWithDelayGlobal(
        function()
            self:removeFromParent()
        end,
        0.01
    )
end
--@endregion

--@region infoArea 角色信息面板区域

--@desc: 获取界面信息列表Node节点
--@author:Seven
--@time:2023-10-24 17:51:58
--@dir: left or right
function FightMainView:getInfoListViewNode(dir)
    return self.__infoAreaController:getListViewUINode(dir)
end

--@desc: 绑定左边ui信息显示接口
--@author:Seven
--@time:2023-10-20 15:44:16
--@index: 索引
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
function FightMainView:bindLeftInfoPanel(index, viewCharacter)
    self.__infoAreaController:bindLeftUI(index, viewCharacter)
end

--@desc: 绑定右边ui信息显示接口
--@author:Seven
--@time:2023-10-20 15:44:16
--@index: 索引
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
function FightMainView:bindRightInfoPanel(index, viewCharacter)
    self.__infoAreaController:bindRightUI(index, viewCharacter)
end

function FightMainView:setInfoQiAnQiMaxView(id, qi, qiMax, qiLimit)
    self.__infoAreaController:setInfoQiAnQiMaxView(id, qi, qiMax, qiLimit)
end

function FightMainView:setInfoNeiliAndNeiliMaxView(id, neili, neiliMax)
    self.__infoAreaController:setInfoNeiliAndNeiliMaxView(id, neili, neiliMax)
end

--@desc: 设置角色面icon显示接口
--@author:Seven
--@time:2023-11-23 17:51:52
--@id: 角色id
--@icons: icon对象列表
function FightMainView:updateBuffIcons(id, icons)
    self.__infoAreaController:setIconsView(id, icons)
end

--@desc: 角色体力值和体力最大值UI刷新接口
--@author:Seven
--@time:2023-10-20 15:42:42
--@id: 角色id
--@tili: 体力值
--@tiliMax: 体力最大值
function FightMainView:setInfoTiliView(id, tili, tiliMax)
    self.__infoAreaController:setInfoTiliView(id, tili, tiliMax)
end

--@desc: 设置角色信息区域图标显示接口
--@author:Seven
--@time:2023-10-20 16:51:47
--@id: id
--@icons: 图标信息
function FightMainView:setIconsView(id, icons)
    self.__infoAreaController:setIconsView(id, icons)
end

function FightMainView:showCharacterCostNeiliView(id, value)
    self.__infoAreaController:showNeiliCost(id, value)
end

function FightMainView:showOperationName(id, name)
    self.__infoAreaController:showOperationName(id, name)
end

function FightMainView:removeOperationName(id, hideAnimStyle)
    self.__infoAreaController:removeOperationName(id, hideAnimStyle)
end

function FightMainView:removeAllOperation(id)
    self.__infoAreaController:removeAllOperationName(id)
end
--@endregion

--@region printArea 打印区域
function FightMainView:printText(msg)
    self.__printAreaController:printText(msg)
end
--@endregion

--@desc: 发送玩家操作接口
--@author:Seven
--@time:2023-11-08 17:02:12
--@inputType: 玩家操作
--@args: 操作参数
function FightMainView:sendPlayerInput(inputType, args)
    self.__fight:sendOperationMesaage(self.__fight:getPlayerId(), inputType, args)
end

function FightMainView:popTextTips(text)
    PopText(text)
end

function FightMainView:updateMs(ms)
    if ms >= 120 and ms < 200 then
        ms = "HIY" .. tostring(ms)
    elseif ms >= 200 then
        ms = "HIR" .. tostring(ms)
    else
        ms = "HIG" .. tostring(ms)
    end

    self:getUINode("Txt_Msg"):setString(ms .. "ms")
end

return FightMainView
0000000
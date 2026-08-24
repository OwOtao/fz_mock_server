--[[
    author:Seven
    time:2023-10-21 14:38:21
    desc: 战场区域视图控制器
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")
local Actions = require("app.extends.NodeAction.Actions")

local BattleSceneAreaViewCtrl = {}

function BattleSceneAreaViewCtrl:create(mainView)
    return BattleSceneAreaViewCtrl.new():__init(mainView)
end

function BattleSceneAreaViewCtrl:ctor()
end

function BattleSceneAreaViewCtrl:__init(mianView)
    --@RefType [FightMainView]
    self.__mainView = mianView

    self.__ui = self.__mainView:getUINode("FightArea")
    Helper:convertUIByParent(self.__ui)

    self:__initbattleContainerNode()

    --@desc 布局翻转系数，用于战场动画区域翻转相关逻辑
    self.__areaFlipFactor = 1

    self.__characterUIMap = {}

    return self
end

---@desc: 初始化背景
---@time:2023-10-21 14:39:59
function BattleSceneAreaViewCtrl:__initBackground()
    local backgroundImgPath = self.__mainView:getBackgroundImgPath()
    self.__bgImgView1 = ccui.ImageView:create(backgroundImgPath)
    self.__bgImgView1:setPositionX(0)
    self.__bgImgView1:setPositionY(0)
    self.__bgImgView1:setAnchorPoint(cc.p(0, 0))
    self.__bgImgView1:setLocalZOrder(-1)

    
    self.__bgImgView2 = ccui.ImageView:create(backgroundImgPath)
    self.__bgImgView2:setPositionX(0)
    self.__bgImgView2:setPositionY(0)
    self.__bgImgView2:setAnchorPoint(cc.p(0, 0))
    self.__bgImgView2:setLocalZOrder(-1)

    self.__ui:addChild(self.__bgImgView1)
    self.__ui:addChild(self.__bgImgView2)    
end

--@desc: 初始化背景能否移动
--@author:LvBin
--@time:2024-04-01 16:52:56
function BattleSceneAreaViewCtrl:__initBackGroundCanMove()
    local characterCount = 0

    for k, v in pairs(self.__characterUIMap) do
        characterCount = characterCount + 1
    end

    if characterCount == 2 then
        self.__moveBackGroundEnabled = true
    else
        self.__moveBackGroundEnabled = false
    end
end

--@desc: 刷新背景位置
--@author:LvBin
--@time:2024-04-01 15:24:05
--@ft:
--@return
function BattleSceneAreaViewCtrl:__updateBackGroundPos(ft)
    local offsetX = 0

    local currBgImgView1PosX = self.__ui:getPositionX()

    if self.__lastBgImgView1PosX then
        offsetX = currBgImgView1PosX - self.__lastBgImgView1PosX
    end

    self.__lastBgImgView1PosX = currBgImgView1PosX
    
    local width = self.__bgImgView1:getContentSize().width
    
    local imgView1, imgView2 = self.__bgImgView1, self.__bgImgView2

    if self.__bgImgView1:getPositionX() > self.__bgImgView2:getPositionX() then
        imgView1 = self.__bgImgView2
        imgView2 = self.__bgImgView1
    end
    
    local imgView1PosX = imgView1:getPositionX()

    local imgView2PosX = imgView2:getPositionX()
    
    imgView1PosX = imgView1PosX + offsetX

    imgView2PosX = imgView2PosX + offsetX
    
    if offsetX > 0 then
        if imgView1PosX >= 0 then
            imgView2PosX = imgView1PosX - width
        end
    elseif offsetX < 0 then
        if imgView2PosX <= 0 then
            imgView1PosX = imgView2PosX + width
        end
    end

    imgView1:setPositionX(imgView1PosX)
    
    imgView2:setPositionX(imgView2PosX)
end

function BattleSceneAreaViewCtrl:__updateScenePos()
    local rolePosX1,rolePosX2

    local posList = {}

    for k, v in pairs(self.__characterUIMap) do
        local x,y = v:getPosition()

        table.insert(posList,x) 
    end

    rolePosX1 = posList[1]

    rolePosX2 = posList[2]
    
    if rolePosX1 > rolePosX2 then
        rolePosX1 = posList[2]

        rolePosX2 = posList[1]
    end

    local viewPosX = -self.__ui:getPositionX()

    local roleWidth = 300

    if rolePosX1 - roleWidth/2 < viewPosX then
        self.__ui:setPositionX(-rolePosX1 + roleWidth/2)
    end
    
    if rolePosX2 > viewPosX + 1080 - roleWidth / 2 then
        self.__ui:setPositionX(-rolePosX2 + 1080 - roleWidth / 2)
    end

    if math.abs(rolePosX1 - rolePosX2) >= 1080 - roleWidth then
        self.__ui:setPositionX(-rolePosX1 + roleWidth / 2)
    end
end

--@desc: 创建战场容器节点，用于整体控制角色动画UI的翻转，缩放等操作
--@author:Seven
--@time:2023-10-21 15:43:50
function BattleSceneAreaViewCtrl:__initbattleContainerNode()
    self.__battleNode = ccui.Widget:create()
    self.__battleNode:ignoreContentAdaptWithSize(false)
    self.__battleNode:setAnchorPoint(cc.p(0, 0))
    self.__battleNode:setPosition(cc.p(0, 0))
    self.__ui:addChild(self.__battleNode)
end

--@desc: 获取一个新的动画UI
--@author:Seven
--@time:2023-10-21 16:09:39
--@return [src.app.FightSystem.Veiws.BattleSceneAreaViews.UI.CharacterAnimViewUI#CharacterAnimViewUI]
function BattleSceneAreaViewCtrl:__getNewCharacterAnimViewUI()
    return require("app.FightSystem.Veiws.BattleSceneAreaViews.UI.CharacterAnimViewUI"):create(self.__mainView:getUINode("AnimNode"):clone())
end

--@desc: 获取动画视图
--@author:Seven
--@time:2023-10-21 16:43:13
--@id: 角色id
--@return [src.app.FightSystem.Veiws.BattleSceneAreaViews.UI.CharacterAnimViewUI#CharacterAnimViewUI]
function BattleSceneAreaViewCtrl:getAnimUI(id)
    local animUI = self.__characterUIMap[id]
    if animUI == nil then
        assert(false, "can not find animUI by id:" .. tostring(id))
    end
    return animUI
end

function BattleSceneAreaViewCtrl:setFilpFactor(factor)
    self.__areaFlipFactor = factor
    self.__battleNode:setScaleX(factor)
    if factor == 1 then
        self.__battleNode:setPosition(cc.p(0, 0))
    else
        self.__battleNode:setPosition(cc.p(1080, 0))
    end
end

function BattleSceneAreaViewCtrl:startFightInit()
    self:__initBackground()

    self:__initBackGroundCanMove()
end

--@desc:给左边添加一个角色视图
--@author:Seven
--@time:2023-10-21 16:07:39
--@posIndex: 位置索引
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
function BattleSceneAreaViewCtrl:addCharacterAnimView(viewCharacter)
    local animViewUI = self:__getNewCharacterAnimViewUI()

    self.__battleNode:addChild(animViewUI:getNode())

    animViewUI:setMainView(self.__mainView)

    local posIndex = viewCharacter:getOriginPosIndex()

    local x, y = viewCharacter:getOriginStartPosition()

    local scaleX = viewCharacter:getScaleX()

    animViewUI:setBodyScaleX(scaleX)

    animViewUI:setPosition(x, y, 0)

    animViewUI:setFlipFactor(self.__areaFlipFactor)

    animViewUI:setVisible(false)

    animViewUI:setWeaponSkin(viewCharacter:getWeaponSkin())

    animViewUI:playAnim(viewCharacter:getIdleAnimName(), false)

    self.__characterUIMap[viewCharacter:getId()] = animViewUI

    return viewCharacter:getId()
end

--@desc: 播放动画
--@author:Seven
--@time:2023-10-21 16:42:22
--@id: 角色id
--@animName: 动画名
--@loop: 是否循环
--@eventCallback: 事件回调
--@completeCallback: 完成回调
function BattleSceneAreaViewCtrl:playAnimView(id, animName, loop, eventCallback, completeCallback)
    local animViewUI = self:getAnimUI(id)
    animViewUI:playAnim(animName, loop, eventCallback, completeCallback)
end

--@desc: 播放入场或胜利动画
--@author:LvBin
--@time:2025-02-18 15:16:36
--@id: 角色id
--@animName: 动画名
--@loop: 是否循环
--@eventCallback: 事件回调
--@completeCallback: 完成回调
function BattleSceneAreaViewCtrl:playEnterVictoryAnim(id, animName, loop, eventCallback, completeCallback)
    local animViewUI = self:getAnimUI(id)
    animViewUI:playEnterVictoryAnim(animName, loop, eventCallback, completeCallback)
end

function BattleSceneAreaViewCtrl:setAnimVisible(id, bool)
    self:getAnimUI(id):setVisible(bool)
end

function BattleSceneAreaViewCtrl:setAnimHeadTag(id, tagType)
    self:getAnimUI(id):setTagImgType(tagType)
end

function BattleSceneAreaViewCtrl:showAnimShield(id, shieldName)
    local ui = self:getAnimUI(id)
    ui:setShieldAnimVisible(true)
    ui:playShieldAnim(shieldName)
end

function BattleSceneAreaViewCtrl:hideAnimShield(id)
    self:getAnimUI(id):setShieldAnimVisible(false)
end

function BattleSceneAreaViewCtrl:playShadowEffectAnim(id, shadowName)
    local ui = self:getAnimUI(id)
    ui:setShadowEffectAnimVisible(true)
    ui:playShadowEffectAnim(shadowName)
end

function BattleSceneAreaViewCtrl:hideShadowEffectAnim(id)
    self:getAnimUI(id):setShadowEffectAnimVisible(false)
end

function BattleSceneAreaViewCtrl:playOneOffEffect(id, animName)
    self:getAnimUI(id):playOneOffEffect(animName)
end

function BattleSceneAreaViewCtrl:showStatusText(id, text)
    self:getAnimUI(id):showStatusText(text)
end

function BattleSceneAreaViewCtrl:hideStatusText(id)
    self:getAnimUI(id):hideStatusText()
end

function BattleSceneAreaViewCtrl:popOverHeadText(id, text)
    self:getAnimUI(id):popOverHeadText(text)
end

function BattleSceneAreaViewCtrl:setAnimWeaponSkin(id, weaponSkin)
    self:getAnimUI(id):setWeaponSkin(weaponSkin)
end

function BattleSceneAreaViewCtrl:setAnimPosition(id, x, y, h)
    self:getAnimUI(id):setPosition(x, y, h)
end

function BattleSceneAreaViewCtrl:getAnimBonePosition(id, boneName)
    return self:getAnimUI(id):getBonePosition(boneName)
end

function BattleSceneAreaViewCtrl:update(dt)
    for k, v in pairs(self.__characterUIMap) do
        v:onUpdate(dt)
    end

    if self.__moveBackGroundEnabled == true then
        self:__updateScenePos()
    
        self:__updateBackGroundPos(dt)
    end
end
return newClass("BattleSceneAreaViewCtrl", {}, BattleSceneAreaViewCtrl)
000
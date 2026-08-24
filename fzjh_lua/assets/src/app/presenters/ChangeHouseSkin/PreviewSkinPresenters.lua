local PreviewSkinPresenters = class("PreviewSkinPresenters", LayerEx)

local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")

PreviewSkinPresenters.SHOW_MODE = {
    -- 购买模式
    STORE = 1,
    -- 拥有模式
    OWNER = 2
}

local PANEL_NAME_LIST = {
    {
        paneName = "MainLayer",
        uiPath = "app.views.ui.MainUI"
    },
    {
        paneName = "MainTaskPresenter"
        -- uiPath = "app.views.ui.MainUI",
    },
    {
        paneName = "AttrLayer"
        -- uiPath = "app.views.ui.BagUI",
    }
}

function PreviewSkinPresenters:create(...)
    return PreviewSkinPresenters:new():__init(...)
end

function PreviewSkinPresenters:__init()
    --@RefType [ChangeHouseSkinReviewUI]
    self.__ui = require("app.views.ui.ChangeHouseSkinUI.ChangeHouseSkinReviewUI"):create()
    self.__ui:addTo(self)

    self.__panelList = {}

    self.__ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    return self
end

function PreviewSkinPresenters:hideLayer()
    if self.__closeCallback then
        self.__closeCallback()
    end

    self:hide(
        function()
            self:removeFromParent()
        end
    )
end

--@desc: 展示界面
--@author:Seven
--@time:2025-10-27 18:01:29
--@skinThemeView: [src.app.models.ChangeHouseSkin.ChangeHouseSkin#SkinThemeView]
function PreviewSkinPresenters:showLayer(skinThemeViewInfo, closeCallback)
    --@RefType [src.app.models.ChangeHouseSkin.ChangeHouseSkin#SkinThemeView]
    self.__skinThemeView = skinThemeViewInfo.skinThemeView
    local mode = skinThemeViewInfo.mode
    self.__canghuangling = skinThemeViewInfo.canghuangling
    --@RefType [src.app.models.ChangeHouseSkin.ChangeHouseSkin#ChangeHouseSkin]
    self.__changeHouseSkin = skinThemeViewInfo.changeHouseSkin

    if table.keyof(PreviewSkinPresenters.SHOW_MODE, mode) then
        self.__mode = mode
    else
        assert(false, "请检查未知的展示模式")
    end

    self.__closeCallback = closeCallback

    self:__resetUI()

    if self.__canghuangling then
        self.__ui:setText_1Str("拥有" .. Role:getCHAttrName("canghuangling") .. "：" .. tostring(self.__canghuangling))
    end

    if self.__mode == PreviewSkinPresenters.SHOW_MODE.STORE then
        if skinThemeViewInfo.buyFail then
            self.__buyFail = skinThemeViewInfo.buyFail
        end
        self:__showStoreMode()
    elseif self.__mode == PreviewSkinPresenters.SHOW_MODE.OWNER then
        self:__showOwnerMode()
    end

    self.__ui:showUI()
end

-- 重置UI
function PreviewSkinPresenters:__resetUI()
end

function PreviewSkinPresenters:__showStoreMode()
    self.__ui:setTextTitle("购买预览")

    self.__ui:setText_2Visible(true)
    self.__ui:setText_2Str("购买价格：" .. self.__skinThemeView:getCurrencyText())

    if self.__skinThemeView:getIsLimit() then
        self.__ui:setText_3Visible(true)
        self.__ui:setText_3Str("购买时间：")
        self.__ui:setText_4Visible(true)
        self.__ui:setText_4Str(self.__skinThemeView:getStartTime() .. " - " .. self.__skinThemeView:getEndTime())
    else
        self.__ui:setText_4Visible(false)
        self.__ui:setText_3Visible(false)
    end

    self.__ui:setText_5Visible(false)

    self.__ui:setButton_1Name("购买")
    self.__ui:setButton_1Func(
        function()
            self.__changeHouseSkin:buyUI(
                self.__skinThemeView:getSkinId(),
                function()
                    PopText("购买成功")

                    return self:hideLayer()
                end,
                function()
                    -- 购买失败也关闭
                    if self.__buyFail then
                        self.__buyFail()
                    end
                    return self:hideLayer()
                end
            )
        end
    )

    local skinId = self.__skinThemeView:getSkinId()
    self:__mainLayerReview(skinId)
    self:__attrLayerReview(skinId)
    self:__jiangHuAttrLayerReview(skinId)
    self:__taskLayerReview(skinId)
end

-- 已拥有，使用模式
function PreviewSkinPresenters:__showOwnerMode()
    self.__ui:setTextTitle("界面预览")
    self.__ui:setText_2Visible(false)
    self.__ui:setText_3Visible(false)
    self.__ui:setText_4Visible(false)
    self.__ui:setText_5Visible(true)
    self.__ui:setButton_1Name("使用")
    self.__ui:setButton_1Func(
        function()
            self.__changeHouseSkin:useUI(
                self.__skinThemeView:getSkinId(),
                function()
                    PopText("已切换")
                    return self:hideLayer()
                end
            )
        end
    )
    self.__ui:setText_5Str(self.__skinThemeView:getSkinName())

    local skinId = self.__skinThemeView:getSkinId()
    self:__mainLayerReview(skinId)
    self:__attrLayerReview(skinId)
    self:__jiangHuAttrLayerReview(skinId)
    self:__taskLayerReview(skinId)
end

function PreviewSkinPresenters:__createNewPanel(layerName, skinId)
    local panel = self.__ui:createNewPanel()
    local bgLayer = require("app.views.layer.Background.BackgroundLayer"):create()
    bgLayer:showBackground(layerName, skinId)
    panel:addChild(bgLayer)
    local printui = require("app.views.ui.PrintUI"):create()
    printui:updateSkinUI(layerName, skinId)
    printui:setVisible(true)
    panel:addChild(printui)

    return panel
end

function PreviewSkinPresenters:__mainLayerReview(skinId)
    local skin_config = HouseSkin:getSkinConfigFromLayerNameByCustomSkinId("MainLayer", skinId)
    local ui = require("app.views.ui.MainUI"):create()
    ui:updateSkinUI(skin_config)
    local panel = self:__createNewPanel("MainLayer", skinId)
    panel:addChild(ui)
    self.__ui:addPanel(panel)

    local role = User:getRole()

    --@region 名称
    local chenghao = role:getChengHaoColorName()
    local name = role:getName()
    ui:setTextUserName(name)
    ui:setTextName(chenghao)
    --@endregion

    --@region 属性
    local jing, jingMax = role:getNumAttr("jing"), math.floor(role:getJingMax())
    local qi, qiMax = role:getNumAttr("qi"), role:getCurrQiMax()
    local neili, neiliMax = role:getNumAttr("neili"), role:getNumAttr("neiliMax")
    local exp = role:getNumAttr("exp")
    local pot = role:getNumAttr("pot")
    local lv = role:getNumAttr("lv")
    local money = role:getNumAttr("money")
    local sex = role:getAttr("sex")
    local looks = role:getFinalAttr("looks")
    local qiPercent = role:getAttr("qiPercent")
    local jiaLi = role:getNumAttr("jiaLi")

    ui:setTextJing(jing, jingMax)
    ui:setTextQi(qi, qiMax, qiPercent)
    ui:setTextNeili("『内力』" .. neili .. "/" .. neiliMax)
    ui:setTextExp(exp)
    ui:setTextPot(pot)
    ui:setTextLv(lv)
    ui:setTextMoney(money)
    --@endregion

    --@region 按钮
    local btn = ui:getUINode("Button_quanJiao")
    btn:setTouchEnabled(false)
    btn:setPosition(988, 680)

    local btn = ui:getUINode("Button_shenbing")
    btn:setTouchEnabled(false)
    btn:setPosition(837, 680)

    local btn = ui:getUINode("Button_shangcheng")
    btn:setTouchEnabled(false)
    btn:setPosition(90, 680)

    local btn = ui:getUINode("Button_paihang")
    btn:setTouchEnabled(false)
    btn:setPosition(238, 680)

    local btn = ui:getUINode("Button_meridian")
    btn:setTouchEnabled(false)
    btn:setPosition(387, 680)

    local btn = ui:getUINode("Button_dream")
    btn:setTouchEnabled(false)
    btn:setPosition(688, 680)

    local btn = ui:getUINode("Button_selfCreatedSkill")
    btn:setTouchEnabled(false)
    btn:setPosition(538, 680)

    ui:getUINode("Button_task"):setTouchEnabled(false)
    ui:getUINode("Button_jianghu"):setTouchEnabled(false)
    ui:getUINode("Button_shimen"):setTouchEnabled(false)
    --@endregion

    --@region 头像
    local headUI = require("app.views.ui.HeadView.HeadView"):create()
    headUI:setPosition(cc.p(ui.Node_HeadViewPos:getPosition()))
    ui:addChild(headUI)
    local mainHeadpresenter = require("app.presenters.HeadView.HeadViewPresenter"):create(role, headUI)
    mainHeadpresenter:setClickEnable(false)
    mainHeadpresenter:showTheHead()
    --@endregion
end

function PreviewSkinPresenters:__attrLayerReview(skinId)
    local skin_config = HouseSkin:getSkinConfigFromLayerNameByCustomSkinId("AttrLayer", skinId)
    local panel = self:__createNewPanel("AttrLayer", skinId)

    local tabUI = require("app.views.ui.AttrUI.TableUI"):create()
    tabUI:updateSkin(skin_config)
    tabUI:lightTable("_AttrLayer")
    panel:addChild(tabUI)

    local ui = require("app.views.ui.AttrUI.AttrUI"):create()
    ui:updateSkin(skin_config)
    ui:disablePanelClick()
    panel:addChild(ui)

    self.__ui:addPanel(panel)

    local role = User:getRole()

    --@region 角色信息
    local name = role:getAttr("name")
    local sex = role:getAttr("sex")
    local age = role:getAgeWithChinese()
    local looks = role:getFinalAttr("looks")
    local luck = role:getFinalAttr("luck")

    local jing, jingMax = role:getNumAttr("jing"), math.floor(role:getJingMax())
    local qi, qiMax = role:getNumAttr("qi"), role:getCurrQiMax()
    local exp = role:getNumAttr("exp")
    local pot = role:getNumAttr("pot")
    local lv = role:getNumAttr("lv")

    local str = role:getFinalAttr("str")
    local int = role:getFinalAttr("int")
    local dex = role:getFinalAttr("dex")
    local con = role:getFinalAttr("con")

    local secStr = role:getFinalAttr("secStr")
    local secInt = role:getFinalAttr("secInt")
    local secDex = role:getFinalAttr("secDex")
    local secCon = role:getFinalAttr("secCon")

    local teacher = role:getAttr("teacherName")
    local qiPercent = role:getAttr("qiPercent")
    local chenghao = role:getChengHaoColorName()

    ui:setTextNameTitle(chenghao)
    ui:setTextName(name)
    ui:setTextSex(sex)
    ui:setTextAge(age)
    ui:setTextLooks(looks)
    ui:setTextLuck(luck)

    ui:setTextJing(jing, jingMax)
    ui:setTextQi(qi, qiMax, qiPercent)
    ui:setTextExp(exp)
    ui:setTextPot(pot)
    ui:setTextLv(lv)

    ui:setTextStr(secStr, str)
    ui:setTextInt(secInt, int)
    ui:setTextDex(secDex, dex)
    ui:setTextCon(secCon, con)
    ui:setTextMaster(teacher)
    ui:setTextChengzhang()

    ui.Button_attrPoint:setVisible(true)

    if lv >= role:GetInheritNeedExpLv() or role:getAttr("inheritCount") >= 1 then
        ui.Button_inherit:setVisible(true)
    else
        ui.Button_inherit:setVisible(false)
    end

    local SkillConst = require("app.models.skill.SkillConst")
    if role:getSkillExp(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)) > 0 then
        ui.Button_attrPoint:loadTextureNormal("Image/UI/AttrUI/xisui.png")
    end
    --@endregion

    --@region 头像
    local headUI = require("app.views.ui.HeadView.HeadView"):create()
    headUI:setPosition(cc.p(ui:getHeadNodePos()))
    ui:addChild(headUI)
    local mainHeadpresenter = require("app.presenters.HeadView.HeadViewPresenter"):create(role, headUI)
    mainHeadpresenter:setClickEnable(false)
    mainHeadpresenter:showTheHead()
    --@endregion
end

function PreviewSkinPresenters:__jiangHuAttrLayerReview(skinId)
    local skin_config = HouseSkin:getSkinConfigFromLayerNameByCustomSkinId("AttrLayer", skinId)
    local panel = self:__createNewPanel("AttrLayer", skinId)

    local tabUI = require("app.views.ui.AttrUI.TableUI"):create()
    tabUI:updateSkin(skin_config)
    tabUI:lightTable("_JiangHuLayer")
    panel:addChild(tabUI)

    local ui = require("app.views.ui.AttrUI.JiangHuAttrUI"):create(false)
    ui:updateSkin(skin_config)
    ui:disableAllBtnClick()
    panel:addChild(ui)

    local role = User:getRole()

    local zhengqi = math.floor(role:getFinalAttr("zhengqi")) --侠义正气
    local kill = role:getNumAttr("kill") --杀死人数
    local yueli = role:getNumAttr("yueli") --江湖阅历
    local killPlayer = role:getNumAttr("killPlayer") --杀玩家数
    local weiwang = role:getNumAttr("weiwang") --江湖威望
    local dead = role:getNumAttr("dead") --死亡次数
    local meili = role:getNumAttr("meili") --风度魅力
    local deadReason = role:getAttr("deadReason") --上次死因
    local lunhui = role:getNumAttr("inheritCount") --传承次数
    local mengjing = role:getNumAttr("mengjing") --梦境层数
    local panshi = role:getNumAttr("panshi") --叛师次数
    local zhengji = role:getNumAttr("officialAchievement") -- 为官政绩
    local gongji = math.floor(role:getAtk()) -- 攻击力
    local duoshan = math.floor(role:getDodge()) -- 躲闪力
    local fangyu = math.floor(role:getDef()) -- 防御力
    local shanghai = math.floor(role:getPowerDamage()) -- 伤害力
    local fanghu = math.floor(role:getFangHu()) -- 防护力
    local jindu = #Map:getCompletedMapList()

    ui:setZhengQiNum(zhengqi)
    ui:setKillNum(kill)
    ui:setYueLiNum(yueli)
    ui:setKillPlayerNum(killPlayer)
    ui:setWeiWangNum(weiwang)
    ui:setDeadNum(dead)
    ui:setMeiLiNum(meili)
    ui:setDeadReasonNum(deadReason)
    ui:setJinDuNum(jindu)
    ui:setLunHuiNum(lunhui)
    ui:setZhengJiNum(zhengji)
    ui:setMengJingNum(mengjing)
    ui:setPanShiNum(panshi)
    ui:setAtkNum(gongji)
    ui:setDodgeNum(duoshan)
    ui:setFangYuNum(fangyu)
    ui:setShangHaiNum(shanghai)
    ui:setFangHuNum(fanghu)

    local family = role:getFamily()

    local gjXiShu = family:getFamilyAttr("atkFamily") -- 攻击系数
    local dsXiShu = family:getFamilyAttr("dodgeFamily") -- 躲闪系数
    local fyXiShu = family:getFamilyAttr("defFamily") -- 防御系数
    local shXiShu = family:getFamilyAttr("damageFamily") -- 伤害系数
    local fhXiShu = family:getFamilyAttr("protectFamily") -- 防护系数

    ui:setAtkxNum(gjXiShu)
    ui:setDodgexNum(dsXiShu)
    ui:setFangYuxNum(fyXiShu)
    ui:setShangHaixNum(shXiShu)
    ui:setFangHuxNum(fhXiShu)

    self.__ui:addPanel(panel)
end

function PreviewSkinPresenters:__taskLayerReview(skinId)
    local skin_config = HouseSkin:getSkinConfigFromLayerNameByCustomSkinId("MainTaskPresenter", skinId)
    local panel = self:__createNewPanel("MainTaskPresenter", skinId)
    self.__ui:addPanel(panel)
    local player = Role:create()
    local hangUpTaskSystem = require("app.models.ChangeHouseSkin.PreReviewTaskSystem.PreReviewHangUpTaskSystem"):create(player)
    local liLianTaskSystem = require("app.models.ChangeHouseSkin.PreReviewTaskSystem.PreReviewLiLianTaskSystem"):create(player)

    local ui = require("app.presenters.Tasks.MainTaskPresenter"):create(hangUpTaskSystem, liLianTaskSystem)
    ui:updateLayerSkinUI(skin_config)
    panel:addChild(ui)
end

return PreviewSkinPresenters
00000000000000
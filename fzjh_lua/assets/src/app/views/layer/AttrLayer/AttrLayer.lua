local AttrUI = require("app.views.ui.AttrUI.AttrUI")
-- local Task = require("app.models.task.Task")
-- local Npc = require("app.models.npc.Npc")
-- local Item = require("app.models.item.Item")
local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local DialogBLayer = require("app.views.layer.DialogLayer.DialogBLayer")
local TitleLayer = require("app.views.layer.AttrLayer.TitleLayer")
-- local NeiDanLayer = require("app.views.layer.AttrLayer.NeiDanLayer")
-- local Resource = require("app.Resource")
local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local SkillConst = require("app.models.skill.SkillConst")

local CoroutinePool = require("third.coroutine.CoroutinePool")
local AsyncFunction = require("third.async.AsyncFunction")
local AttrLayer = class("AttrLayer", cc.Layer)

function AttrLayer:create()
    local p = AttrLayer:new()
    p:init()
    return p
end

function AttrLayer:init()
    self.__role = User:getRole()

    local AttrUI = AttrUI:create()

    self._UI = AttrUI
    AttrUI:addTo(self)

    self:initMonitorPool()

    --创建协程来刷新UI
    self.coroutinePool = CoroutinePool:create()
    self.coroutinePool:add(
        "AttrLayer",
        function()
            while true do
                self:__createAsyncUpdate():await()
            end
        end
    )

    self:setButtonDaZuo()
    self:setButtonJiaLi()
    -- self:setButtonNeiDan()
    self:setButtonInherit()
    self:setMySkillsButton()
    self:setButtonChangeTitle()

    local headUI = require("app.views.ui.HeadView.HeadView"):create()
    headUI:setPosition(cc.p(self._UI:getHeadNodePos()))
    self._UI:addChild(headUI)

    --@RefType [src.app.presenters.HeadView.HeadViewPresenter#HeadViewPresenter]
    self.__headpresenter = require("app.presenters.HeadView.HeadViewPresenter"):create(User:getRole(), headUI)
    self.__headpresenter:setClickEnable(false)

    self._UI:setHeadAreaClickFunc(
        function()
            PopupLayerController:showLayer(
                "RoleObserveLayer",
                function(layer)
                    layer:showLayer(User:getRole(), "PLAYER")
                    -- layer:setRole(role)
                end
            )
        end
    )

    self:schedule(
        function(ft)
            self:update(ft)
        end,
        0
    )
end

function AttrLayer:updateSkin(skin_config)
    self._UI:updateSkin(skin_config)
    --@TODO 2025-12-01 16:18:27 临时解决界面刷新问题，后续需要优化
    self:refreshUI() 
end

function AttrLayer:createDialog(dtype, params)
    local dialog
    if dtype == "A" then
        dialog = DialogALayer:getInstance()
        dialog:show(params.str)
        dialog:setButton1(params.name1, params.func1)
        dialog:setButton2(params.name2, params.func2)
        dialog:setButton3(params.name3, params.func3)
    elseif dtype == "B" then
        dialog = DialogBLayer:getInstance()
        dialog:show(params.list)
        dialog:setButton1(params.name1, params.func1)
        dialog:setButton2(params.name2, params.func2)
        dialog:setButton3(params.name3, params.func3)
    else
    end
end

function AttrLayer:daZuo()
    --NEEDTODO 效果需要调整
    -- local func = function(neili, neiliMax)
    -- 	self._UI:setTextNeiliJin(tostring(neili), tostring(neiliMax))
    -- 	self._UI:buttonJinShow()
    -- 	self._UI:delayFunc(0.1, function()
    -- 		self._UI:buttonJinHide()
    -- 	end)
    -- end
    local role = User:getRole()
    role:daZuo()
end

function AttrLayer:canDaZuo()
    local role = User:getRole()
    local neiliMax, neili = role:getNumAttr("neiliMax"), role:getNumAttr("neili")

    local neiGongState = false
    --你内功心法都没有学，还想学人家打坐？
    for k, v in pairs(role:getSkills()) do
        if k == "jibenneigong" then
            neiGongState = true
        end
    end
    if not neiGongState then
        PopText("你内功心法都没有学，还想学人家打坐？")
        return false
    end

    if role:getSkillPrepare()["neigong"] == nil then
        PopText("你必须先准备你要用来打坐的特殊内功，才能打坐！")
        return false
    end

    if Helper:mathFloor(neiliMax) >= Helper:mathFloor(role:getNeiLiLimit()) and neili >= 2 * neiliMax then
        PopText("你的内力修为已经无法靠打坐来提升了。")
        return false
    end

    --行针导致无法打坐
    if role:getBuffAttr("xingzhenDaZuo") >= 1 then
        PopText("受行针走穴影响，暂时无法运功打坐。")
        return false
    end

    return true
end

function AttrLayer:setButtonDaZuo()
    self._UI:setButtonDaZuo(
        function()
            Audio:playEffect("daAnNiu")
            if PRINT_MODE == 1 then
                print(User:getRole():isInCurrState(ROLE_CURR_STATE_DAZUO))
            end
            if User:getRole():isInCurrState(ROLE_CURR_STATE_DAZUO) then
                User:getRole():stopDaZuo()
                RichPrint("main", "你把正在运行的真气强行压回丹田，站了起来。")
            else
                if not self:canDaZuo() then
                    return
                end
                RoleTaskControllor:clickDaZuoLayer(
                    function()
                        self:daZuo()
                        self._UI.Button_dazuo.Text_buttonName:setString("取消\n打坐")
                        RichPrint("main", "你坐下来运气用功，一股内息开始在体内流动。")
                    end
                )
            end
        end
    )
end

function AttrLayer:setButtonJiaLi()
    self._UI:setButtonJiaLi(
        function()
            Audio:playEffect("daAnNiu")
            PopupLayerController:showLayer(
                "JiaLiLayer",
                function(layer)
                    layer:show()
                end
            )
        end
    )
end

function AttrLayer:setButtonChangeTitle()
    -- self._UI.Button_title:setVisible(false)
    -- self._UI.Image_title:setVisible(false)
    self._UI:setButtonChangeTitle(
        function()
            Audio:playEffect("daAnNiu")
            HttpManagerEx:getChenHao(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            if data then
                                local role = User:getRole()
                                -- 官职相关
                                if role:getAttr("officialType") ~= 0 and data.exam.guanzhi == 0 then
                                    RichPrint("main", "HIC因为政绩过低，你的官职已经被罢免了。想要重新踏上仕途，七日后可再参加科举、考取功名。")
                                end

                                role:setAttr("officialType", data.exam.guanzhi)
                                role:setAttr("officialAchievement", data.exam.zhengji)
                                role:updateOfficialChengHao()

                                -- 佳人称号
                                if data.jiaren then
                                    local pertyGirlTitleBasicId = RoleTitleConst.SpecialBasicTitleId.PertyGirl
                                    local isTrue = role:hasBasicTitle(pertyGirlTitleBasicId)

                                    if isTrue == true and data.jiaren.is_list == 0 then
                                        role:deleteBasicTitle(pertyGirlTitleBasicId)
                                    elseif isTrue == false and data.jiaren.is_list ~= 0 then
                                        role:addBasicTitle(pertyGirlTitleBasicId)
                                    end
                                end

                                -- 公子称号
                                if data.gongzi then
                                    local gongZiTitleBasicId = RoleTitleConst.SpecialBasicTitleId.GongZi
                                    local isTrue = role:hasBasicTitle(gongZiTitleBasicId)

                                    if isTrue == true and data.gongzi.is_list == 0 then
                                        role:deleteBasicTitle(gongZiTitleBasicId)
                                    elseif isTrue == false and data.gongzi.is_list ~= 0 then
                                        role:addBasicTitle(gongZiTitleBasicId)
                                    end
                                end

                                local FamilyPrestige = require("app.models.family.FamilyPrestige")
                                FamilyPrestige:getUserPrestige(
                                    function()
                                        TitleLayer:getInstance():showLayer()
                                    end
                                )
                            end
                        else
                            PopText(errmsg)
                        end
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )
end

function AttrLayer:setButtonNeiDan()
    self._UI.Button_neidan:setVisible(false)
    self._UI:setButtonNeiDan(
        function()
            if true then
                PopText("该功能暂未开放，敬请期待")
                return
            end
            Audio:playEffect("daAnNiu")
            PopupLayerController:showLayer(
                "NeiDanLayer",
                function(layer)
                    layer:show()
                end
            )
        end
    )
end

function AttrLayer:setButtonInherit()
    self._UI:setButtonInherit(
        function()
            Audio:playEffect("daAnNiu")

            local isInherit, msg = User:getRole():canInherit()

            if isInherit == false then
                PopText(msg)
                return
            end

            -- 未领养孤儿前显示传承介绍
            if User:getRoleAttr("inherit").isSetName == false then
                local role = User:getRole()
                if role:getAttr("isHaveOrphan") == false and role:getLv() >= role:GetInheritNeedExpLv() then
                    role:setFlag("传承开始", 1)
                end
                if role:getLv() < role:GetInheritNeedExpLv() then
                    PopText("需要达到" .. role:GetInheritNeedExpLv() .. "级方可开启")
                elseif role:getLv() >= role:GetInheritNeedExpLv() then
                    MainControllLayer:pushLayer("InheritLayer")
                    local InheritLayer = MainControllLayer:getLayer("InheritLayer")
                    InheritLayer:showDesc()
                end
            else
                local inherit = User:getRoleAttr("inherit")
                local n = math.ceil(inherit.intimacy / 4)
                if n == 0 then
                    n = 1
                end

                if n > inherit.eventCount then
                    -- 之前未处理的传承事件，先处理完
                    PopupLayerController:showLayer(
                        "InheritEventLayer",
                        function(layer)
                            layer:setText(inherit.eventCount)
                            layer:show()
                        end
                    )
                else
                    -- 领养后显示孤儿属性界面
                    local InheritAttrLayer = MainControllLayer:getLayer("InheritAttrLayer")
                    InheritAttrLayer:setHeadImg()
                    MainControllLayer:pushLayer("InheritAttrLayer")
                end
            end
        end
    )
end

function AttrLayer:setMySkillsButton()
    self._UI:setMySkillsButton(
        function()
            Audio:playEffect("daAnNiu")
            -- PopupLayerController:showLayer("AttrPointLayer", function(layer)
            -- 	layer:showLayer()
            -- end)

            local NaturalAttrUtil = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrUtil")
            local NaturalAttrAdjustmentConst = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst")
            NaturalAttrUtil:showPlayerCurrentNaturalAdjustmentPlanLayer()
        end
    )
end

function AttrLayer:__createAsyncUpdate()
    return AsyncFunction:create(
        function(thread)
            self:refreshNeiLi()
            thread:yield()

            self.monitorPool:update()
            thread:yield()

            local role = User:getRole()
            if role.neiliMax >= 100 and not self.Curr_Button_State1 then
                self.Curr_Button_State1 = true
                self._UI.Button_jiali:setVisible(true)
            end
            thread:yield()

            if role.exp >= 2000000 and not self.Curr_Button_State2 then
                self.Curr_Button_State2 = true
            -- self._UI.Button_neidan:setVisible(true)
            end

            -- 后天属性检查检验
            if self.Curr_Button_State3 == false then
                local RoleSecAttrHelper = require("app.models.role.RoleSecAttrHelper")
                RoleSecAttrHelper:updateAllSecAttr(role)
                self.Curr_Button_State3 = true
            end
            thread:finish()
        end
    )
end

function AttrLayer:initMonitorPool()
    local role = User:getRole()
    self.monitorPool = MonitorPool:create("AttrLayer")
    self.monitorPool:add(role.ignoreCloneTb._finalAttr, "jingMax", self, self.refreshUI)
    self.monitorPool:add(role.ignoreCloneTb._finalAttr, "qiMax", self, self.refreshUI)
    local list = {
        "name",
        "sex",
        "age",
        "looks",
        "luck",
        "jing",
        "qi",
        "exp",
        "pot",
        "lv",
        "str",
        "int",
        "dex",
        "con",
        "secStr",
        "secInt",
        "secDex",
        "secCon",
        "teacherName",
        "qiPercent"
    }
    self.monitorPool:addList(role, list, self, self.refreshUI)
end

function AttrLayer:refreshUI()
    local role = User:getRole()

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
    self._UI:setTextNameTitle(chenghao)
    self._UI:setTextName(name)
    self._UI:setTextSex(sex)
    self._UI:setTextAge(age)
    self._UI:setTextLooks(looks)
    self._UI:setTextLuck(luck)

    self._UI:setTextJing(jing, jingMax)
    self._UI:setTextQi(qi, qiMax, qiPercent)
    self._UI:setTextExp(exp)
    self._UI:setTextPot(pot)
    self._UI:setTextLv(lv)

    self._UI:setTextStr(secStr, str)
    self._UI:setTextInt(secInt, int)
    self._UI:setTextDex(secDex, dex)
    self._UI:setTextCon(secCon, con)
    self._UI:setTextMaster(teacher)
    self._UI:setTextChengzhang()

    if lv >= role:GetInheritNeedExpLv() or role:getAttr("inheritCount") >= 1 then
        self._UI.Button_inherit:setVisible(true)
    else
        self._UI.Button_inherit:setVisible(false)
    end

    if role:getSkillExp(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)) > 0 then
        self._UI.Button_attrPoint:loadTextureNormal("Image/UI/AttrUI/xisui.png")
    end

    self._UI.Button_attrPoint:setVisible(true)
end

function AttrLayer:refreshNeiLi()
    local role = User:getRole()

    if role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
        self._UI.Button_dazuo.Text_buttonName:setString("取消\n打坐")
        -- self:daZuo()
        if role:getNumAttr("jiaLi") ~= nil and role:getNumAttr("jiaLi") > 0 then
            self._UI:setTextNeiliNum(role:getNumAttr("neili"), role:getNumAttr("neiliMax") .. "(" .. tostring(role:getNumAttr("jiaLi")) .. ")打坐中")
        else
            self._UI:setTextNeiliNum(role:getNumAttr("neili"), role:getNumAttr("neiliMax") .. " 打坐中")
        end
    else
        self._UI.Button_dazuo.Text_buttonName:setString([[打坐]])
        -- role:stopDaZuo()
        self._UI:setTextNeiliNum(role:getNumAttr("neili"), role:getNumAttr("neiliMax"))
    end
end

function AttrLayer:update(ft)
    self.coroutinePool:update(ft)
end

function AttrLayer:onResume()
    self.Curr_Button_State1 = false
    self.Curr_Button_State2 = false
    self.Curr_Button_State3 = false -- 后天属性计算检查
    self._UI.Button_neidan:setVisible(false)
    self._UI.Button_jiali:setVisible(false)
end

function AttrLayer:changRoleTitle(titleType, titleId)
    self.__headpresenter:showTheHead()
    self:refreshUI()
end

function AttrLayer:changWearMask(maskId, lv)
    self.__headpresenter:showTheHead()
end

function AttrLayer:onEnable()
    self.__role:getTitleSystem():addOutput(self)
    self.__role:getMaskSystem():addOutput(self)
    self.__headpresenter:showTheHead()
    self:refreshUI()
end

function AttrLayer:onDisable()
    self.__role:getTitleSystem():deleteOutput(self)
    self.__role:getMaskSystem():deleteOutput(self)
end

Helper:classDefNodeGetInstance(AttrLayer)

-- 加密标记
AttrLayer.isEncrypted = true
return AttrLayer
000000000000000
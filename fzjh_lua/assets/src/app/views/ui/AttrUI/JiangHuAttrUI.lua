local Family = require("app.models.family.Family")
local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
local CoroutinePool = require("third.coroutine.CoroutinePool")
local AsyncFunction = require("third.async.AsyncFunction")

local JiangHuAttrUI = class("JiangHuAttrUI", cc.Layer)

function JiangHuAttrUI:create(...)
    local p = JiangHuAttrUI:new()
    p:init(...)
    return p
end

function JiangHuAttrUI:init(isAutoRefreshUserData)
    self._round = require("Layer/AttrUI/JiangHuAttrUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUI(self) -- 获得所有子节点

    do -- 隐藏某些不需要的UI
        self.Text_kill_player:setVisible(false)
        self.Text_kill_player_num:setVisible(false)

        self.Text_mengjing:setVisible(false)
        self.Text_mengjing_num:setVisible(false)

        self.Text_panshi:setVisible(false)
        self.Text_panshi_num:setVisible(false)
    end

    self:setPanelClick()

    isAutoRefreshUserData = isAutoRefreshUserData == nil and true or isAutoRefreshUserData

    if isAutoRefreshUserData == true then
        --创建协程来刷新UI
        self.coroutinePool = CoroutinePool:create()
        self.coroutinePool:add(
            "JiangHuAttrUI",
            function()
                while true do
                    self:__createAsyncRefreshUI():await()
                end
            end
        )

        self:__createAsyncRefreshUI():call()
    end

    self:setMySkillsButton()
    self:setTuJianButton()
    self:setGuideSystemButton()

    self:setXinShenButton()

    self:schedule(
        function(ft)
            self:update(ft)
        end,
        0
    )
end

function JiangHuAttrUI:updateSkin(skin_config)
    if skin_config.Rolebtnpic then
        self.Button_guide:loadTextureNormal(skin_config.Rolebtnpic, 0)
        self.Button_xinshen:loadTextureNormal(skin_config.Rolebtnpic, 0)
        self.Button_tujian:loadTextureNormal(skin_config.Rolebtnpic, 0)
        self.Button_skills:loadTextureNormal(skin_config.Rolebtnpic, 0)
    end
end

function JiangHuAttrUI:__createAsyncRefreshUI()
    return AsyncFunction:create(
        function(thread)
            local role = User:getRole()
            thread:yield()

            local zhengqi = math.floor(role:getFinalAttr("zhengqi")) --侠义正气
            thread:yield()
            local kill = role:getNumAttr("kill") --杀死人数
            thread:yield()
            local yueli = role:getNumAttr("yueli") --江湖阅历
            thread:yield()
            local killPlayer = role:getNumAttr("killPlayer") --杀玩家数
            thread:yield()
            local weiwang = role:getNumAttr("weiwang") --江湖威望
            thread:yield()
            local dead = role:getNumAttr("dead") --死亡次数
            thread:yield()
            local meili = role:getNumAttr("meili") --风度魅力
            thread:yield()
            local deadReason = role:getAttr("deadReason") --上次死因
            thread:yield()
            -- local jindu = role:getNumAttr("jindu")		--江湖进度
            local lunhui = role:getNumAttr("inheritCount") --传承次数
            thread:yield()
            local mengjing = role:getNumAttr("mengjing") --梦境层数
            thread:yield()
            local panshi = role:getNumAttr("panshi") --叛师次数
            thread:yield()
            local zhengji = role:getNumAttr("officialAchievement") -- 为官政绩
            thread:yield()

            local wpType = role:getCurrTypeByWeapon()
            thread:yield()

            local gongji = math.floor(role:getAtk()) -- 攻击力
            thread:yield()

            local duoshan = math.floor(role:getDodge()) -- 躲闪力
            thread:yield()

            local fangyu = math.floor(role:getDef()) -- 防御力
            thread:yield()

            local shanghai = math.floor(role:getPowerDamage()) -- 伤害力
            thread:yield()

            local fanghu = math.floor(role:getFangHu()) -- 防护力
            thread:yield()

            --@TODO 2019-01-12 14:19:35 此处暂时排除了新章节的副本
            local jindu = #Map:getCompletedMapList()
            thread:yield()

            self:setZhengQiNum(zhengqi)
            thread:yield()
            self:setKillNum(kill)
            thread:yield()
            self:setYueLiNum(yueli)
            thread:yield()
            self:setKillPlayerNum(killPlayer)
            thread:yield()
            self:setWeiWangNum(weiwang)
            thread:yield()
            self:setDeadNum(dead)
            thread:yield()
            self:setMeiLiNum(meili)
            thread:yield()
            self:setDeadReasonNum(deadReason)
            thread:yield()
            self:setJinDuNum(jindu)
            thread:yield()
            self:setLunHuiNum(lunhui)
            thread:yield()
            self:setZhengJiNum(zhengji)
            thread:yield()
            self:setMengJingNum(mengjing)
            thread:yield()
            self:setPanShiNum(panshi)
            thread:yield()

            self:setAtkNum(gongji)
            thread:yield()
            self:setDodgeNum(duoshan)
            thread:yield()
            self:setFangYuNum(fangyu)
            thread:yield()
            self:setShangHaiNum(shanghai)
            thread:yield()
            self:setFangHuNum(fanghu)
            thread:yield()

            local family = role:getFamily()
            if MapIsEmpty(family) then
                thread:finish()
            end
            thread:yield()

            local gjXiShu = family:getFamilyAttr("atkFamily") -- 攻击系数
            thread:yield()
            local dsXiShu = family:getFamilyAttr("dodgeFamily") -- 躲闪系数
            thread:yield()
            local fyXiShu = family:getFamilyAttr("defFamily") -- 防御系数
            thread:yield()
            local shXiShu = family:getFamilyAttr("damageFamily") -- 伤害系数
            thread:yield()
            local fhXiShu = family:getFamilyAttr("protectFamily") -- 防护系数
            thread:yield()
            self:setAtkxNum(gjXiShu)
            thread:yield()
            self:setDodgexNum(dsXiShu)
            thread:yield()
            self:setFangYuxNum(fyXiShu)
            thread:yield()
            self:setShangHaixNum(shXiShu)
            thread:yield()
            self:setFangHuxNum(fhXiShu)
            thread:finish()
        end
    )
end

function JiangHuAttrUI:setValue(name, num)
    if not name then
        return
    end
    if not num then
        num = 0
    end
    self[name]:setString(num)
end

function JiangHuAttrUI:setMySkillsButton() -- 我的技能
    self.Button_skills:releaseFunc(
        function()
            print("JiangHuAttrLayer:setMySkillsButton()")
            local teacher = Npc:getNpc(User:getRoleAttr("teacherId"))
            local cloneTeacher = Helper:tableCover(Role:create(), teacher)
            cloneTeacher:setAttr("skills", cloneTeacher:getAttr("tSkills"))
            MainControllLayer:pushLayer("SkillInfoLayer")
            local skillInfoLayer = MainControllLayer:getLayer("SkillInfoLayer")
            skillInfoLayer:setTeacherRole(cloneTeacher)
            skillInfoLayer:showMySelfSkillInfoPresenter()
        end
    )
end

function JiangHuAttrUI:setTuJianButton() -- 图鉴
    self.Button_tujian:releaseFunc(
        function()
            User:getRole():filtrateSeeSkill() --筛选已见闻的武学技能
            AchievementSystem:updateTujianTypeRecord() --刷新图鉴解锁

            MainControllLayer:pushLayer("TuJianMenuLayer")
            local layer = MainControllLayer:getLayer("TuJianMenuLayer")
            layer:showLayer()
        end
    )
end

function JiangHuAttrUI:setGuideSystemButton() -- 分级引导
    self.Button_guide:releaseFunc(
        function()
            PopupLayerController:showLayer(
                "GuideSystemPresenters",
                function(layer)
                    layer:showLayer()
                end
            )
        end
    )
end

--@desc: 心神按钮
--@author:LvBin
--@time:2022-04-10 11:11:55
--@return
function JiangHuAttrUI:setXinShenButton()
    self.Button_xinshen:releaseFunc(
        function()
            local role = User:getRole()
            role:getXinShenSystem():getXinShenValue(
                function(ok, xinshenData)
                    if ok then
                        role:getXinShenSystem():getXinShenLevel(
                            function(ok, levelData)
                                if ok then
                                    if xinshenData.curr < xinshenData.max then
                                        role:getXinShenSystem():getXinShenRecoverStartTime(
                                            function(ok, recoverData)
                                                if ok then
                                                    HttpManagerEx:getTime(
                                                        function(status, errcode, errmsg, data, isEncrypted)
                                                            if status == 200 and errcode == 0 and data.time ~= nil then
                                                                SetTime(tonumber(data.time))
                                                                PopupLayerController:showLayer(
                                                                    "XinShenPresenter",
                                                                    function(layer)
                                                                        layer:setXinShen(xinshenData.curr)
                                                                        layer:setXinShenMax(xinshenData.max)
                                                                        layer:setXinShenMaxLevel(levelData.level)
                                                                        layer:setRecoverTime(recoverData.time)
                                                                        layer:showLayer()
                                                                    end
                                                                )
                                                            else
                                                                PopText(errmsg)
                                                            end
                                                        end
                                                    )
                                                else
                                                    local msg = recoverData
                                                    PopText(msg)
                                                end
                                            end
                                        )
                                    else
                                        PopupLayerController:showLayer(
                                            "XinShenPresenter",
                                            function(layer)
                                                layer:setXinShen(xinshenData.curr)
                                                layer:setXinShenMax(xinshenData.max)
                                                layer:setXinShenMaxLevel(levelData.level)
                                                layer:setRecoverTime(0)
                                                layer:showLayer()
                                            end
                                        )
                                    end
                                else
                                    local msg = levelData
                                    PopText(msg)
                                end
                            end
                        )
                    else
                        local msg = xinshenData
                        PopText(msg)
                    end
                end
            )
        end
    )
end

function JiangHuAttrUI:setPanShi(text) --叛师次数
    self.Text_panshi:setString(text)
end

function JiangHuAttrUI:setPanShiNum(num) --叛师次数
    if not num then
        num = 0
    end
    self.Text_panshi_num:setString(num)
end

function JiangHuAttrUI:setMengJing(text) --梦境层数
    self.Text_mengjing:setString(text)
end

function JiangHuAttrUI:setMengJingNum(num) --梦境层数
    if not num then
        num = 0
    end
    self.Text_mengjing_num:setString(num)
end

function JiangHuAttrUI:setLunHui(text) --轮回次数
    self.Text_lunhui:setString(text)
end

function JiangHuAttrUI:setLunHuiNum(num) --轮回次数
    if not num then
        num = 0
    end
    self.Text_lunhui_num:setString(num)
end

function JiangHuAttrUI:setZhengJiNum(num) -- 为官政绩
    if not num then
        num = 0
    end
    self.Text_zhengji_num:setString(num)
end

function JiangHuAttrUI:setJinDu(text) --江湖进度
    self.Text_jindu:setString(text)
end

function JiangHuAttrUI:setJinDuNum(num) --江湖进度
    if not num then
        num = 0
    end
    self.Text_jindu_num:setString(num)
end

function JiangHuAttrUI:setDeadReason(text) --上次死因
    self.Text_dead_res:setString(text)
end

function JiangHuAttrUI:setDeadReasonNum(num) --上次死因
    if not num or num == 0 then
        num = "无"
    end
    self.Text_dead_res_num:setString(num)
end

function JiangHuAttrUI:setMeiLi(text) --风度魅力
    self.Text_meili:setString(text)
end

function JiangHuAttrUI:setMeiLiNum(num) --风度魅力
    if not num then
        num = 0
    end
    self.Text_meili_num:setString(num)
end

function JiangHuAttrUI:setDead(text) --死亡次数
    self.Text_dead:setString(text)
end

function JiangHuAttrUI:setDeadNum(num) --死亡次数
    if not num then
        num = 0
    end
    self.Text_dead_num:setString(num)
end

function JiangHuAttrUI:setWeiWang(text) --江湖威望
    self.Text_weiwang:setString(text)
end

function JiangHuAttrUI:setWeiWangNum(num) --江湖威望
    if not num then
        num = 0
    end
    self.Text_weiwang_num:setString(num)
end

function JiangHuAttrUI:setKillPlayer(text) --杀玩家数
    self.Text_kill_player:setString(text)
end

function JiangHuAttrUI:setKillPlayerNum(num) --杀玩家数
    if not num then
        num = 0
    end
    self.Text_kill_player_num:setString(num)
end

function JiangHuAttrUI:setYueLi(text) --江湖阅历
    self.Text_yueli:setString(text)
end

function JiangHuAttrUI:setYueLiNum(num) --江湖阅历
    if not num then
        num = 0
    end
    self.Text_yueli_num:setString(num)
end

function JiangHuAttrUI:setKill(text) --杀死人数
    self.Text_kill:setString(text)
end

function JiangHuAttrUI:setKillNum(num) --杀死人数
    if not num then
        num = 0
    end
    self.Text_kill_num:setString(num)
end

function JiangHuAttrUI:setZhengQi(text) --侠义正气
    self.Text_zhengqi:setString(text)
end

function JiangHuAttrUI:setZhengQiNum(num) --侠义正气
    if not num then
        num = 0
    end
    self.Text_zhengqi_num:setString(num)
end

function JiangHuAttrUI:setFangHu(text) --防护力
    self.Text_fanghu:setString(text)
end

function JiangHuAttrUI:setFangHuNum(num) --防护力
    if not num then
        num = 0
    end
    self.Text_fanghu_num:setString(num)
end

function JiangHuAttrUI:setFangHux(text) --防护系数
    self.Text_fanghux:setString(text)
end

function JiangHuAttrUI:setFangHuxNum(num) --防护系数
    if not num then
        num = 0
    end
    self.Text_fanghux_num:setString(num)
end

function JiangHuAttrUI:setShangHai(text) --伤害力
    self.Text_shanghai:setString(text)
end

function JiangHuAttrUI:setShangHaiNum(num) --伤害力
    if not num then
        num = 0
    end
    self.Text_shanghai_num:setString(num)
end

function JiangHuAttrUI:setShangHaix(text) --伤害系数
    self.Text_shanghaix:setString(text)
end

function JiangHuAttrUI:setShangHaixNum(num) --伤害系数
    if not num then
        num = 0
    end
    self.Text_shanghaix_num:setString(num)
end

function JiangHuAttrUI:setFangYu(text) --防御力
    self.Text_fangyu:setString(text)
end

function JiangHuAttrUI:setFangYuNum(num) --防御力
    if not num then
        num = 0
    end
    self.Text_fangyu_num:setString(num)
end

function JiangHuAttrUI:setFangYux(text) --防御系数
    self.Text_fangyux:setString(text)
end

function JiangHuAttrUI:setFangYuxNum(num) --防御系数
    if not num then
        num = 0
    end
    self.Text_fangyux_num:setString(num)
end

function JiangHuAttrUI:setDodge(text) --闪躲力
    self.Text_dodge:setString(text)
end

function JiangHuAttrUI:setDodgeNum(num) --闪躲力
    if not num then
        num = 0
    end
    self.Text_dodge_num:setString(num)
end

function JiangHuAttrUI:setDodgex(text) --闪躲系数
    self.Text_dodgex:setString(text)
end

function JiangHuAttrUI:setDodgexNum(num) --闪躲系数
    if not num then
        num = 0
    end
    self.Text_dodgex_num:setString(num)
end

function JiangHuAttrUI:setAtk(text) --攻击力
    self.Text_atk:setString(text)
end

function JiangHuAttrUI:setAtkNum(num) --攻击力
    if not num then
        num = 0
    end
    self.Text_atk_num:setString(num)
end

function JiangHuAttrUI:setAtkx(text) --攻击系数
    self.Text_atkx:setString(text)
end

function JiangHuAttrUI:setAtkxNum(num) --攻击系数
    if not num then
        num = 0
    end
    self.Text_atkx_num:setString(num)
end

function JiangHuAttrUI:setPanelClick()
    local panel = self.Panel_10
    if not panel then
        return
    end
    local dialog = DialogELayer:getInstance()
    panel:addTouchEventListener(
        function(ref, eventType)
            if eventType == ccui.TouchEventType.began then
                self.Image_7:setVisible(false)
            elseif eventType == ccui.TouchEventType.ended then
                -- dialog:show("侠义值，是很重要的参数，表示你的正邪立场。\n正派弟子必须要有正神，邪派弟子，则必须有负神。\n正神和负神会影响到你拜师学艺，江湖行走。\n杀人是得到侠义值的通常手段，杀正义之士得负神，杀奸恶之辈得正神。")
                dialog:show("侠义值，是很重要的参数，表示你的正邪立场。\n正派弟子必须要有正神，邪派弟子，则必须有负神。\n正神和负神会影响到你拜师学艺，江湖行走。\n决斗是获得侠义值的手段，与正义之士决斗得负神，与奸恶之辈决斗得正神。")
                dialog:setPanelBack(
                    function()
                        self.Image_7:setVisible(true)
                    end
                )
            elseif eventType == ccui.TouchEventType.canceled then
                self.Image_7:setVisible(true)
            end
        end
    )

    local panel_11 = self.Panel_11
    if not panel_11 then
        return
    end
    local dialog = DialogELayer:getInstance()
    panel_11:addTouchEventListener(
        function(ref, eventType)
            if eventType == ccui.TouchEventType.began then
                self.Image_10:setVisible(false)
            elseif eventType == ccui.TouchEventType.ended then
                dialog:show("政绩值是对你作为官员时的考核评价。要成为官员、获得官职，需参加科举考试并在殿试上名列前茅。\n完成拜访任务会增加政绩值，拒绝拜访任务会降低政绩值。")
                dialog:setPanelBack(
                    function()
                        self.Image_10:setVisible(true)
                    end
                )
            elseif eventType == ccui.TouchEventType.canceled then
                self.Image_10:setVisible(true)
            end
        end
    )
end

function JiangHuAttrUI:update(ft)
    if self.coroutinePool then
        self.coroutinePool:update(ft)
    end
end

function JiangHuAttrUI:onResume()
end

function JiangHuAttrUI:disableAllBtnClick()
    self.Panel_10:setTouchEnabled(false)
    self.Panel_11:setTouchEnabled(false)
    self.Button_skills:setTouchEnabled(false)
    self.Button_tujian:setTouchEnabled(false)
    self.Button_guide:setTouchEnabled(false)
    self.Button_xinshen:setTouchEnabled(false)
end

return JiangHuAttrUI
0000000
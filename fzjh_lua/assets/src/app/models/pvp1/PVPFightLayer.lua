local FightUI = require("app.views.ui.FightUI.FightUI")
local AnimFightLayer = require("app.views.layer.FightLayer.AnimFightLayer")
local Skill = require("app.models.skill.Skill")
local Role=require("app.models.role.Role")
local FightConfig = require("app.models.fight.FightConfig")
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 战斗层
local FightLayer = class("PVPFightLayer", LayerEx)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/02 17:56:17
-- @desc FightLayer 的事件
FightLayer.EVENT_TYPE_FIGHT_START = 1

function FightLayer:createFightLayer()
    FightLayer:destroyInstance()
    local fightLayer = FightLayer:getInstance()
    fightLayer:setShowAndHideAnimType("DARK")
    -- fightLayer:setOriginBackgroundId("擂台")
    -- fightLayer:setAnimFightBackground("擂台")
    fightLayer:hideFast()

    return fightLayer
end
-- end pvp
----------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/20 17:22:34
-- @params 
-- @desc 开始战斗前的动画
function FightLayer:beforeStartFightAmin(func)
    local delayTime = 0.2

    self:delayFunc(delayTime, function()
        local leftPanel = self._UI.Panel_stateArea.ListView_left
        local lPosition = cc.p(leftPanel:getPosition())
        local lSize = leftPanel:getSize()
        leftPanel:setPositionX(lPosition.x - lSize.width)
        
        local rightPanel = self._UI.Panel_stateArea.ListView_right
        local rPosition = cc.p(rightPanel:getPosition())
        local rSize = rightPanel:getSize()
        rightPanel:setPositionX(rPosition.x + rSize.width)

        self._UI.Panel_zhedang:runActionWithName("zhedangHide", cc.Spawn:create( 
            cc.Sequence:create(
                cc.FadeOut:create(0.3),
                cc.CallFunc:create(function()
                    self._UI.Panel_zhedang:setVisible(false)

                    leftPanel:runActionWithName("leftPanelMove", cc.MoveTo:create(0.5, lPosition))
                    rightPanel:runActionWithName("rightPanelMove", cc.MoveTo:create(0.5, rPosition))
    
                    local fight = self:getFight()
                    self:initRoleAnim()
                    self:refreshButtonArea()  --战斗回调后再刷新按钮区域
                    self:delayFunc(0.05, function()
                        -- add by XiaoZhiWei 2018/06/26 21:16:04 多加10帧感觉更流畅
                        self:delayFunc( fight:getLargestStartanimTime() + (10 / 30), function()
                            self:playFightBeginAnim(function()
                                if func then
                                    func()
                                end
                            end)
                        end )
                    end)
                end)
            )
        ))
    end)
end

function FightLayer:localShow()
    self:show(function()
        -- 注册调度器
        self:unscheduleAll()
        
        self._UI.Panel_buttonArea.Button_runaway:releaseFunc(function()
           -- self.fight:fightListener("runaway")
        end)
        
        -- 开始战斗
        self:beforeStartFightAmin(function()
            print("开始战斗回掉")
            self.fight:uiCallback("show")

        end)

        -- self:refreshButtonArea()
        -- 刷新UI
        self.fight:refreshUI()
        -- self:initRoleAnim()
    end)
end

function FightLayer:localHide(func)
    self:hide(function(...)
        func(...)
        self.fight:uiCallback("hide")
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建实例
function FightLayer:create()
    local p = FightLayer.new()
    p:init()
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 构造
function FightLayer:ctor()
    self.fight = nil
    self._eventListener = function(...) end
    
    -- 函数管理
    self._rolesEffectChangeFM = FunctionManager:create()

-- 效果设置 add by TangJian 2016/11/07 17:55:21
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化
function FightLayer:init()
    self:initUI()
    self:initAnimFight()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置当前战斗逻辑
function FightLayer:setFight(fight)
    self.fight = fight
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/02 19:33:43
-- @desc 得到战斗
function FightLayer:getFight()
    return self.fight
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化UI
function FightLayer:initUI()
    if self._UI == nil then
        self._UI = FightUI:create()
        self:addChild(self._UI)
    end
end

-- 变黑显示 add by TangJian 2016/11/26 17:06:05
function FightLayer:showWithDark(endFunc)
    -- self:resumeSelfAndChildren()-- 显示前恢复
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    layerColor:setSelfAndChildrenCascadeOpacityEnabled(true)
    self:getParent():addChild(layerColor)
    layerColor:maxZ()
    
    local text = ccui.Text:create()
    text:setFontName(Resource:getFontPath("default"))
    text:setTextColor(cc.c3b(203, 203, 203))
    text:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    text:setFontSize(48)
    text:setString("准备战斗")
    layerColor:addChild(text)
    text:setPositionX(display.width / 2)
    text:setPositionY(display.height / 2)
    
    layerColor:setOpacity(0)
    layerColor:runActionWithName("showAndHide",
        cc.Sequence:create(
            cc.FadeIn:create(self._showAndHideAnimDuration),
            cc.CallFunc:create(function()
                self:showFast(endFunc)
                self:showTouchSwallowLayer()
                
                -- 隐藏颜色层
                layerColor:runActionWithName("showAndHide", cc.Sequence:create(
                    cc.FadeOut:create(self._showAndHideAnimDuration),
                    cc.CallFunc:create(function()
                        self:hideTouchSwallowLayer()
                    end), cc.RemoveSelf:create()))
            end)))
end

-- 变黑隐藏 add by TangJian 2016/11/26 17:06:06
function FightLayer:hideWithDark(endFunc)
    self:hideWithFade(endFunc)
end

---设置角色影子颜色
function FightLayer:setRoleShadowSpriteEffectAnim(role,animId)
    local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())
    animRole:setRoleShadowSpriteEffectAnim(animId)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 16:30:31
-- @desc 调用战斗层的UI的方法
function FightLayer:callUIMemFunc(funcName, ...)
    if self._UI and self._UI[funcName] then
        return self._UI[funcName](self._UI, ...)
    else
        assert(false,"FightLayer:callUIMemFunc:"..funcName)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/08 11:25:30
-- @desc 设置角色附加动画显示或者隐藏
function FightLayer:setRoleAllAdditionalAnimEnabled(role, b)
    local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())
    animRole:setAllAdditionalAnimEnabled(b)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 15:21:43
-- @desc 播放开始战斗文字动画
function FightLayer:playFightBeginAnim(endFunc)
    endFunc = Helper:getDef(endFunc, EMPTY_FUNC)
    
    self._UI.Text_fightBeginText:runActionWithName("Text_fightBeginText",
        cc.Sequence:create(
            cc.DelayTime:create(0.2),
            -- cc.CallFunc:create(function()
            --     self._UI.Text_fightBeginText:setVisible(true)
            --     self._UI.Text_fightBeginText:setOpacity(255)
            --     self._UI.Text_fightBeginText:setScale(0.8)
            --     self._UI.Text_fightBeginText:setString("3")
            -- end),
            -- cc.ScaleTo:create(0.3, 1.2),
            -- cc.ScaleTo:create(0.2, 1.0),
            -- cc.FadeOut:create(0.05),
            -- cc.CallFunc:create(function()
            --     self._UI.Text_fightBeginText:setVisible(true)
            --     self._UI.Text_fightBeginText:setOpacity(255)
            --     self._UI.Text_fightBeginText:setScale(0.8)
            --     self._UI.Text_fightBeginText:setString("2")
            -- end),
            -- cc.ScaleTo:create(0.3, 1.2),
            -- cc.ScaleTo:create(0.2, 1.0),
            -- cc.FadeOut:create(0.05),
            -- cc.CallFunc:create(function()
            --     self._UI.Text_fightBeginText:setVisible(true)
            --     self._UI.Text_fightBeginText:setOpacity(255)
            --     self._UI.Text_fightBeginText:setScale(0.8)
            --     self._UI.Text_fightBeginText:setString("1")
            -- end),
            -- cc.ScaleTo:create(0.3, 1.2),
            -- cc.ScaleTo:create(0.2, 1.0),
            -- cc.FadeOut:create(0.05),
            cc.CallFunc:create(function()
                self._UI.Text_fightBeginText:setVisible(true)
                self._UI.Text_fightBeginText:setOpacity(255)
                self._UI.Text_fightBeginText:setScale(0.8)
                self._UI.Text_fightBeginText:setString("开始战斗")
            end),
            cc.ScaleTo:create(0.3, 1.2),
            cc.ScaleTo:create(0.2, 1.0),
            cc.FadeOut:create(0.05),
            
            cc.CallFunc:create(function()
                self._UI.Text_fightBeginText:setVisible(false)
                endFunc()
            end)))
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 20:50:58
-- @desc 输出开场白
-- @param teamId: 说开场白的队伍的编号
-- @param fightType: 切磋 or 杀死
function FightLayer:printRolePrologue(teamId, fightType)
    local enemyTeamId = 2
    if teamId == 2 then
        enemyTeamId = 1
    end
    local roles = self.fight:getTeamRoles(teamId)
    local enemys = self.fight:getTeamRoles(enemyTeamId)
    
    -- 队伍1的人对队伍2的人说开场白
    for k, role in pairs(roles) do
        for k, enemy in pairs(enemys) do
            local prologue = role:getRole():getFightPrologue(enemy:getRole(), fightType)
            self:printFightStatus(prologue, role:getName(), enemy:getName())
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 刷新UI
function FightLayer:refreshUI()
    -- 得到存在
    for roleTeamId = 1, 2 do
        for roleInTeamId = 1, 5 do
            local role = self.fight:getRoleByTeamIdAndInTeamId(roleTeamId, roleInTeamId)
            if role then
                self._UI:getRoleStatePanel(roleTeamId, roleInTeamId):setVisible(true)
                -- 设置角色名
                self._UI:setRoleName(role:getTeamId(), role:getInTeamId(), role:getAttr("name"))
                -- 设置角色气血
                self._UI:setRoleQi(role:getTeamId(), role:getInTeamId(), role:getAttr("qi"), role:getRole():getCurrQiMax(), role:getFinalAttr("qiMax"))
                -- 设置角色精力
                self._UI:setRoleNeili(role:getTeamId(), role:getInTeamId(), role:getAttr("neili"), role:getFinalAttr("neiliMax"))
                -- 设置角色体力
                self._UI:setRoleTili(role:getTeamId(), role:getInTeamId(), role:getAttr("tili"), role:getFinalAttr("tiliMax"))
            else
                -- print("roleTeamId", roleTeamId)
                -- print("roleInTeamId", roleInTeamId)
                self._UI:getRoleStatePanel(roleTeamId, roleInTeamId):setVisible(false)
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/13 15:59:59
-- @desc 设置技能按钮百分比
function FightLayer:setActiveButtonPercent(buttonName, percent)

end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/28 14:24:28
-- @desc 准备主动招式
function FightLayer:readyActiveZhao(roleId, activeZhaoId)
    print("roleId, activeZhaoId = ", roleId, activeZhaoId)
    
    local role = self.fight:getRole(roleId)
    if role:isForget() then
        return
    end

	if not role:isPartForgetCanUseActiveZhao(activeZhaoId) then
		return
	end
    
    local activeZhao = role:getActiveZhaoState(activeZhaoId)
    if not activeZhao then
        return
    end
    local activeZhaoName = activeZhao:getName()
    self:callUIMemFunc("roleReadyActiveZhao", role:getTeamId(), role:getInTeamId(), activeZhaoName)

-- local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())
-- animRole:setStatusText(role:getCurrState())
-- animRole:readyActiveZhao(activeZhaoName)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/28 14:24:45
-- @desc 使用主动招式
function FightLayer:useActiveZhao(roleId, targetId, activeZhaoId)
    local role = self.fight:getRole(roleId)
    local target = self.fight:getRole(targetId)
    local activeZhao = role:getActiveZhaoState(activeZhaoId)
    local activeZhaoName = activeZhao:getName()
    
    if self.fight:cheackCanTriggerSpecialBuff(role,activeZhaoId) == true then
        local text = ""
        if role._role:getSkill("changshengjueyang") then
            text = "HIW$N运起长生诀心法，脸上涌现出阵阵红光，不多时，$N伤势已是恢复了不少。"
        elseif role._role:getSkill("changshengjueyin") then
            text = "HIW$N运起长生诀心法，真气游走全身，脸上冷光涌现，不多时，$N伤势已是恢复了不少。"
        end
        role:setFlag("长生诀战斗恢复",{text=text})
    else
        self:printFightStatus(activeZhao:getUseDesc(), role:getName(), target:getName(), role:getCurrWeaponName(), target:getCurrWeaponName())
    end
    
    -- local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())
    -- animRole:unreadyActiveZhao()
    self:callUIMemFunc("roleUnreadyActiveZhao", role:getTeamId(), role:getInTeamId())
-- local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())
-- animRole:useActiveZhao(activeZhaoName)
end

-- 移除无效主动技能
function FightLayer:removeInvalidActiveZhao(roleId, targetId, activeZhaoId)
    local role = self.fight:getRole(roleId)

    self:callUIMemFunc("roleUnreadyActiveZhao", role:getTeamId(), role:getInTeamId())
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/15 21:46:25
-- @desc
function FightLayer:updateActiveZhaoButton(player)
    if player then
        for k, v in pairs(player:getCurrActiveZhaoStateMap()) do
            local percent = math.floor(100 * (v:getCD() - v:getCDLeft()) / v:getCD())
            if v:getCD() == 0 then
                percent = 100
            end
            self:callUIMemFunc("setActiveButtonPercent", k, percent)
            
            -- 刷新能否使用状态 add by TangJian 2017/03/13 16:12:05
            if player:canUseActiveZhao(k) then
                self:callUIMemFunc("setActiveButtonEnable", k, true)
            else
                self:callUIMemFunc("setActiveButtonEnable", k, false)
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/22 10:52:37
-- @desc 刷新玩家增益状态
function FightLayer:updateRoleBuff()
    self._rolesEffectChangeFM:addFunction(function()
        for roleTeamId = 1, 2 do
            for roleInTeamId = 1, 5 do
                local role = self.fight:getRoleByTeamIdAndInTeamId(roleTeamId, roleInTeamId)
                if role then
                    local effectArray = role:getEffectArray()
                    local effectMap = role:getEffectMap()
                    local effectForShowMap = {}
                    local effectForShowArray = {}
                    local index = 1
                    for k, v in pairs(effectMap) do
                        if v:getFinalDuration() ~= 0 then
                            local effectTag = v:getEffectTag()
                            if Resource:getBuffIconImageFileName(effectTag) then
                                if effectForShowMap[effectTag] == nil then
                                    effectForShowMap[effectTag] =
                                        {
                                            tag = effectTag,
                                            index = index,
                                            count = 0,
                                            leftUpNum = 0,
                                        }
                                    index = index + 1
                                end
                                
                                -- 层数 add by TangJian 2017/04/06 18:35:27
                                if (v:getId()=="SZJ002" or v:getId()=="SZJ001" or v:getType() == "属性叠加") and effectForShowMap[effectTag].count>=1 then 
                                else
                                    effectForShowMap[effectTag].count = effectForShowMap[effectTag].count + 1
                                end
                                
                                -- 左上角数字 add by TangJian 2017/04/06 18:33:21
                                local effectType = v:getType()
                                if effectType == "偏转" then
                                    effectForShowMap[effectTag].leftUpNum = effectForShowMap[effectTag].leftUpNum + v:getArg1()
                                elseif effectType == "反伤" then
                                    effectForShowMap[effectTag].leftUpNum = effectForShowMap[effectTag].leftUpNum + v:getArg1()
                                elseif effectType == "标记触发" then
                                    effectForShowMap[effectTag].leftUpNum = effectForShowMap[effectTag].leftUpNum + v:getArg3()
                                elseif effectType == "属性叠加" then
                                    effectForShowMap[effectTag].leftUpNum = effectForShowMap[effectTag].leftUpNum + v:getArg2()
								elseif effectType == "必中" then
                                    effectForShowMap[effectTag].leftUpNum = effectForShowMap[effectTag].leftUpNum + v:getArg1()
                                end
                            end
                        end
                    end

                    for k, v in pairs(effectForShowMap) do
                        effectForShowArray[v.index] = v
                    end
                    
                    --@region 易伤图标显示
                     for i = 1, FightConfig.Constant.FragileCount do
                        local fragileValue = role:getFragileValue(i)
                        local fragileInfo = FightConfig:getFragileInfoById(i)

                        if fragileInfo.icon and fragileValue > 0 then
                            table.insert(effectForShowArray, {tag = fragileInfo.icon, count = fragileValue, leftUpNum = 0})
                        end
                    end
                    --@endregion
                    
                    --@region 增伤图标显示
                    for i = 1, FightConfig.Constant.AugmentCount do
                        local augmentValue = role:getAugmentValue(i)
                        local augmentInfo = FightConfig:getAugmentInfoById(i)

                        if augmentInfo.icon and augmentValue > 0 then
                            table.insert(effectForShowArray, {tag = augmentInfo.icon, count = augmentValue, leftUpNum = 0})
                        end
                    end
                    --@endregion
                    
                    local despairForce = role:getDespairForce()
                    if despairForce > 0 then
                        table.insert(effectForShowArray, {tag = "绝b", count = despairForce, leftUpNum = 0})
                    end

                     --@endregion
                    if PRINT_MODE == 1 then
                        print("#effectForShowArray = ", #effectForShowArray)
                    end
                    
                    self:callUIMemFunc("setRoleStateIcons", roleTeamId, roleInTeamId, effectForShowArray)
                end
            end
        end
        return true
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/28 15:43:28
-- @desc 刷新按钮区域
function FightLayer:refreshButtonArea(btnType)
    local player = self.fight:getPlayer()
    local preparedActiveZhaoArray = player:getPreparedActiveZhaoArray()
    
    local buttonArray = {}
    local isHaveActiveZhao = false
    for i = 1, 6 do
        local activeZhao = preparedActiveZhaoArray[i]
        if activeZhao and activeZhao.id ~= "huifu" then
            table.insert(buttonArray,
            {
                id = activeZhao.id,
                name = activeZhao.name,
            })
            isHaveActiveZhao = true
        else
            table.insert(buttonArray,
            {
                id = 0,
                name = "",
                percent = 0
            })
        end
    end

    if isHaveActiveZhao == false then
        buttonArray = {}
    end

    if IS_OPEN_PVP_YIWU and player:getRole():getPrepareWeapon() then 
        buttonArray[8] =
            {
                id = "yiWu",
                name = "易武"
            }
    end

    if player.isInYiWu==true  then 
         buttonArray[8]=nil
    end

    --[[
        btnType 1 恢复 2 逃跑 3 恢复及逃跑
    ]]
    do
        btnType = Helper:getDef(btnType, 3)
        if btnType == 1 then
            buttonArray[7] =
                {
                    id = "huifu",
                    name = "恢复"
                }
        elseif btnType == 2 or btnType == 4 then
            buttonArray[9] =
                {
                    id = "逃跑",
                    name = "逃跑"
                }
        elseif btnType == 3 then
            buttonArray[7] =
                {
                    id = "huifu",
                    name = "恢复"
                }
                
            buttonArray[9] =
                {
                    id = "逃跑",
                    name = "逃跑"
                }
        end
    end
    
    self:callUIMemFunc("setActiveButtonArray", buttonArray,
        function(activeZhaoId)
            -- add by XiaoZhiWei 2018/06/29 10:23:12 必须是已经开始战斗了才能点击按钮
            if self.fight:isStart() == true then 
                switch(activeZhaoId,
                    {
                        ["逃跑"] = function()
                            self:onRunaway()
                        end,
                        ["恢复"] = function()
                        end,
                        ["yiWu"] =function()
                            player.isInYiWu=true
                            if player.isInYiWu then 
                                PopText("即将更换备用武器！")
                            end
                        end,
                        default = function()
                            local canUse, notice = self.fight:readyActiveZhao(player:getId(), activeZhaoId)
                            if canUse == false then
                                PopText(notice)
                            end
                        end,
                        
                        [0] = function()
                            PopText("未准备主动技能")
                        end,
                        
                        ["测试"] = function()
                            -- 武器掉落
                            local role = self.fight:getRoleByTeamIdAndInTeamId(2, 1)
                            local target = self.fight:getRoleByTeamIdAndInTeamId(1, 1)
                            
                            role:unloadWeapon()
                            
                            role:setAutoZhaos(target:getId(), role:createAutoZhaos(target))
                            
                            self:initRoleAnim()
                        end
                    })
            end
        end)
end

-- @desc 刷新玩家按钮区域主动技能
function FightLayer:refreshIsPlayerButtonArea(role,btnType)
    if not role or not role:isPlayer() then
        return 
    end
    return self:refreshButtonArea(btnType)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置监听方法
function FightLayer:setEventListener(eventListener)
    self._eventListener = Helper:getDef(eventListener, EMPTY_FUNC)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 调用监听方法
function FightLayer:callEventListener(eventType, ...)
    -- print([[function FightLayer:callEventListener(eventName, ...)]])
    -- logt("FightLayer:callEventListener", eventName, ...)
    self._eventListener(self, eventType, ...)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色属性
function FightLayer:setRoleState()

end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/02 18:13:05
-- @desc 战况输出
function FightLayer:printFightStatus(text, role1Name, role2Name, weapon1Name, weapon2Name, attackPart, customReplaceMap)

    if PRINT_MODE == 1 then
        print(text, role1Name, role2Name, weapon1Name, weapon2Name, attackPart)
    end
    
    if text == nil then
        return
    end
    
    local player = self.fight:getPlayer()
    if player then
        if role1Name == player:getName() then
            role1Name = "你"
        elseif role2Name == player:getName() then
            role2Name = "你"
        end
    end
    
    if role1Name then
        text = string.gsub(text, "$N", role1Name)
        text = string.gsub(text, "$P", role1Name)
    end
    
    if role2Name then
        text = string.gsub(text, "$n", role2Name)
        text = string.gsub(text, "$p", role2Name)
    end
    
    if weapon1Name then
        text = string.gsub(text, "$w", weapon1Name)
    end
    
    if weapon2Name then
        text = string.gsub(text, "$W", weapon2Name)
    end
    
    if attackPart then
        text = string.gsub(text, "$l", attackPart)
    end
    
    -- 自定义替换
    if type(customReplaceMap) == "table" then
        for k, v in pairs(customReplaceMap) do
            text = string.gsub(text, k, v)
        end
    end
    
    -- print("printFightStatus = ", text)
    self._UI:print(text)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/02 17:51:26
-- @desc 流程状态
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 开始游戏
function FightLayer:onStart()
    PopText("战斗开始!!!")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/02 17:51:39
-- @desc 结束游戏
function FightLayer:onFinish(value, localRole, targetRole)
    -- 显示战斗完整文本
    self:callUIMemFunc("richTextShowAllFightStatusString")
    
    -- 隐藏按钮区域
    self:callUIMemFunc("setButtonAreaVisble", false)
    -- 显示战斗结束文本区域
    self:callUIMemFunc("showFightEndTextArea")
    
    -- 设置战斗结束文本区域的文本
    if value == 1 then
        self:callUIMemFunc("setFightEndTextAreaText", 1, "胜利")
        self:callUIMemFunc("setFightEndTextAreaText", 2, "你战胜了" .. targetRole:getName())
    elseif value == 2 then
        self:callUIMemFunc("setFightEndTextAreaText", 1, "失败")
        self:callUIMemFunc("setFightEndTextAreaText", 2, "你被" .. targetRole:getName() .. "打趴在地")
    elseif value == 3 then
        self:callUIMemFunc("setFightEndTextAreaText", 1, "平局")
        self:callUIMemFunc("setFightEndTextAreaText", 2, "战斗不分伯仲！")
    elseif value == 4 then
        self:callUIMemFunc("setFightEndTextAreaText", 1, "胜利")
        self:callUIMemFunc("setFightEndTextAreaText", 2, "对方已经灰溜溜的逃走了！")
    elseif value == 5 then
        self:callUIMemFunc("setFightEndTextAreaText", 1, "逃跑")
        self:callUIMemFunc("setFightEndTextAreaText", 2, "你灰溜溜的逃走了！")
    end
    self:callUIMemFunc("setFightEndTextAreaReleaseFunc", function()
        self:localHide(function()
            self:destroyInstance()
        end)
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author LvBin
-- @time 2020-07-03 14:38:50
-- @desc 有胜利动画延时结束游戏
function FightLayer:delayOnFinish(value, localRole, targetRole)
    local winAnimName = nil
    local delay = 0
    local fight = self:getFight()

    if value == 1 or value == 4 then
        winAnimName = localRole:getWinAnimName()
    elseif value == 2 or value == 5 then
        winAnimName = targetRole:getWinAnimName()
    end

    if winAnimName then
        delay = 1
    end

    self:delayFunc(delay,function()
        if  DEBUG_MODE == 1 then
            print("--------------延时结束游戏---------------",delay)
        end
        self:onFinish(value, localRole, targetRole)
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author LvBin
-- @time 2020-06-10 19:38:50
-- @desc 播放胜利动画结束游戏
function FightLayer:playWinAnim(role,delay)
    if not role or role:isPlayWinAnim() then
        return
    end

    local winAnimName = role:getWinAnimName()
    local winAnimTime = role:getWinAminNeedTime()

    if DEBUG_MODE == 1 then
        print("winAnimName",winAnimName,"winAnimTime =",winAnimTime)
    end

    local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())

    if winAnimName and winAnimTime and animRole then
        role:setPlayWinAnim(true)
        
        delay = Helper:getDef(delay,0)

        self:delayFunc(delay,function()
            animRole.anim:setVisible(false)

            animRole:setEnterVictoryAnimVisible(true)
            animRole:playEnterVictoryAnim(winAnimName)
        end)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 16:05:05
-- @desc 逃跑
function FightLayer:onRunaway(teamId)
    self.fight:runaway()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/15 19:19:21
-- @desc 恢复
function FightLayer:onHuiFu()

end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/02 18:09:03
-- @desc 动画相关的方法
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化动画战斗界面
function FightLayer:initAnimFight()
    if self._animFightLayer == nil then
        -- 得到10个人的站位
        local leftPositions = {}
        local rightPositions = {}
        for i = 1, 5 do
            table.insert(leftPositions, cc.p(self._UI.Panel_animFightArea["Panel_leftFightPos" .. i]:getPosition()))
            table.insert(rightPositions, cc.p(self._UI.Panel_animFightArea["Panel_rightFightPos" .. i]:getPosition()))
        end
        if PRINT_MODE == 1 then
            logt("左边角色位置", leftPositions)
            logt("右边角色位置", rightPositions)
        end
        self._animFightLayer = AnimFightLayer:createInPanel(self._UI.Panel_animFightArea,"擂台")
        self._animFightLayer:FightStart(leftPositions, rightPositions)
    end
end

-- @desc 设置战斗背景
function FightLayer:setAnimFightBackground(backgroundId)
    if self._animFightLayer then
        self._animFightLayer:initBackGroundLayer(backgroundId)
    end
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化角色动画
function FightLayer:initRoleAnim()
    local team1RoleCount = 0
    local team2RoleCount = 0
    
    -- 得到存在
    for roleTeamId = 1, 2 do
        for roleInTeamId = 1, 5 do
            local role = self.fight:getRoleByTeamIdAndInTeamId(roleTeamId, roleInTeamId)
            local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(roleTeamId, roleInTeamId)

            if role then
                
                do -- 做队伍人数计数
                    if roleTeamId == 1 then
                        team1RoleCount = team1RoleCount + 1
                    elseif roleTeamId == 2 then
                        team2RoleCount = team2RoleCount + 1
                    else
                        if PRINT_MODE == 1 then
                            print("error: roleTeamId = ", roleTeamId)
                        end
                    end
                end
                
                animRole:setVisible(true)
                animRole.anim:setVisible(false)

                --播放入场动画
                if role:getStartAnimName() then
                    animRole:setEnterVictoryAnimVisible(true)
                    animRole:playEnterVictoryAnim(role:getStartAnimName())
                    
                    self:delayFunc(role:getStartAminNeedTime(), function()
                        animRole:setEnterVictoryAnimVisible(false)

                        self:initRoleWeaponImage(role)

                        animRole.anim:playAnim(role:getStandAnimName())
                    end)
                else
                    self:initRoleWeaponImage(role)

                    animRole.anim:playAnim(role:getStandAnimName())
                end
            else
                animRole:setVisible(false)
            end
        end
    end
    
    if team1RoleCount == 1 and team2RoleCount == 1 then
        self._animFightLayer:setMoveCameraEnabled(true)
    else
        self._animFightLayer:setMoveCameraEnabled(false)
    end
end

function FightLayer:initRoleWeaponImage(role)
    -- 设置武器
    local weaponAttachmentName = self:getCurrWeaponimage(role:getRole():getCurrSubtypeByWeapon())
    
    local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())
    
    animRole.anim:setVisible(true)

    -- 武器
    animRole.anim:setAttachment("weapon", weaponAttachmentName)
    
    if role:getAttackMethod() == SKILL_METHOD_TYPE_SHUANGCHI then
        animRole.anim:setAttachment("weapon5", weaponAttachmentName)
    else
        animRole.anim:setAttachment("weapon5", "")
    end
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/31 02:38:48
-- @desc 初始化角色动画
function FightLayer:roleInitAnim(roleId)
    local role = self.fight:getRole(roleId)
    if role then
        local roleTeamId = role:getTeamId()
        local roleInTeamId = role:getInTeamId()
        
        local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(roleTeamId, roleInTeamId)
        animRole:setVisible(true)
        
        self:initRoleWeaponImage(role)
        
        --@desc 战斗结束，有胜利动画就不播放待机姿势
        if self.fight:getState() == "gameover" and role:getWinAnimName() then
        elseif role:isDead() then -- add by LvBin 2020/09/09 12:02:21 人物死亡不播放待机姿势
        else  
            -- 待机姿势
            animRole.anim:playAnim(role:getStandAnimName())
        end
    else
        local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(roleTeamId, roleInTeamId)
        animRole:setVisible(false)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/23 15:04:03
-- @desc 得到角色动画时间
function FightLayer:getRoleAnimDuration(animName)
    local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(1, 1)
    return animRole.anim:getAnimDuration(animName)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/30 22:33:07
-- @desc 刷新额外动画
function FightLayer:refreshRoleEffectAnim()
    
    
    self._rolesEffectChangeFM:callFunctions()
end


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到角色动画id
function FightLayer:getRoleAnimId(role)
    return role:getFightId()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 角色弹出文本动画
function FightLayer:rolePopNumber(role, number, color)
    if number == nil then
        return
    end
    
    local roleId = self:getRoleAnimId(role)
    self._animFightLayer:rolePopNumber(roleId, number, color)
-- self._animFightLayer:rolePopNumber(roleId, number, cc.c4b(255, 0, 0, 255))
end
-----------------------------------------------------------------------------------------------------------
-- @desc 角色上方弹出文本动画
function FightLayer:rolePopNumberUP(role, number, color)
    if number == nil then
        return
    end

    local roleId = self:getRoleAnimId(role)
    self._animFightLayer:rolePopNumberUP(roleId, number, color)
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 播放角色动画
function FightLayer:rolePlayAnim(role, animName, frameFrom, frameTo, speed, delay)
    local roleId = self:getRoleAnimId(role)
    self._animFightLayer:playRoleAnim(roleId, animName, frameFrom, frameTo, speed, delay)
end

-----------------------------------------------------------------------------------------------------------
-- @desc 播放角色效果动画
function FightLayer:playRoleEffectAnim(role, animName)
    local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())
    animRole:playEffectAnim(animName)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 动画角色移动
function FightLayer:roleMove(role, target, duration, offset)
    local roleId = self:getRoleAnimId(role)
    local targetId = self:getRoleAnimId(target)
    local animRole, animTarget = self._animFightLayer:getRole(roleId), self._animFightLayer:getRole(targetId)
    
    local moveVecX = math.abs((animTarget:getPositionX() - animRole:getPositionX())) + offset
    if moveVecX <= 50 then
        self._animFightLayer:roleMoveTo(roleId, targetId, offset, 0, duration)
    else
        self._animFightLayer:roleJumpTo(roleId, targetId, offset, 0, duration)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 动画角色移动
function FightLayer:roleMoveBy(role, duration, offset)
    local roleId = self:getRoleAnimId(role)
    self._animFightLayer:roleMoveBy(roleId, offset, 0, duration)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/12 11:46:33
-- @desc 攻击后跳回初始位置
function FightLayer:roleAttackEndMoveToOrigin(role, target, isWaitingTili, duration)
    print("roleAttackEndMoveToOrigin")
    -- -- 有一支队伍的人数超过1人, 就需要归位 add by TangJian 2016/11/11 17:30:13
    -- if (self.fight:getTeamRoleCount(1) > 1 or self.fight:getTeamRoleCount(2) > 1) then
    --     print("roleAttackEndMoveToOrigin 111111111111111111111111")
    --     duration = Helper:getDef(duration, 5 / 30)
    --     local roleId = self:getRoleAnimId(role)
    --     self._animFightLayer:roleMoveToOrigin(roleId, duration)
    -- elseif isWaitingTili then -- 如果体力条正在回复, 也需要归位 add by TangJian 2016/11/11 17:30:29
    --     print("roleAttackEndMoveToOrigin 222222222222222222222222")
    --     -- -- 攻击放站立动画
    --     local roleId, targetId = self:getRoleAnimId(role), self:getRoleAnimId(target)
    --     local animRole, animTarget = self._animFightLayer:getRole(roleId), self._animFightLayer:getRole(targetId)
    --     -- local targetRoleOffset = cc.pMul(cc.p(animTarget:getPosition()), cc.p(animRole:getPosition()))
    --     local endPos = cc.p(animTarget:getPosition())
    --     endPos.x = endPos.x - animRole.direction * 500
    --     duration = Helper:getDef(duration, 5 / 30)
    --     self._animFightLayer:roleJump(roleId, endPos, duration)
    --     self:rolePlayAnim(role, role:getJumpBackwardAnimName())
    --     self:rolePlayAnim(role, role:getStandAnimName(), nil, nil, nil, 5 / 30)
    -- end
        -- -- 攻击放站立动画
        local roleId, targetId = self:getRoleAnimId(role), self:getRoleAnimId(target)
        local animRole, animTarget = self._animFightLayer:getRole(roleId), self._animFightLayer:getRole(targetId)
        -- local targetRoleOffset = cc.pMul(cc.p(animTarget:getPosition()), cc.p(animRole:getPosition()))
        local endPos = cc.p(animTarget:getPosition())
        endPos.x = endPos.x - animRole.direction * 500
        duration = Helper:getDef(duration, 5 / 30)
        self._animFightLayer:roleJump(roleId, endPos, duration)
        self:rolePlayAnim(role, role:getJumpBackwardAnimName())
        self:rolePlayAnim(role, role:getStandAnimName(), nil, nil, nil, 5 / 30)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 跳回初始位置
function FightLayer:roleMoveToOrigin(role, target, duration)
    -- 攻击放站立动画
    self:rolePlayAnim(role, role:getStandAnimName())
    
    -- 有一支队伍的人数超过1人, 就需要归位 add by TangJian 2016/11/11 17:30:13
    if (self.fight:getTeamRoleCount(1) > 1 or self.fight:getTeamRoleCount(2) > 1) then
        duration = Helper:getDef(duration, 5 / 30)
        local roleId = self:getRoleAnimId(role)
        self._animFightLayer:roleMoveToOrigin(roleId, duration)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 播放攻击动画
function FightLayer:playRoleAttackAnim(role, target, attackFunc, zhaoData)
    if type(attackFunc) ~= "function" then
        attackFunc = nil
    end
    
    local roleAttackSkill = role:getCurrAttackSkill()
    local roleAttackZhao = role:getCurrAttackZhao()
    local roleDoubleAttackSkill = role:getCurrDoubleAttackSkill()
    local roleDoubleAttackZhao = role:getCurrDoubleAttackZhao()
    
    local attackZhaoAnims = roleAttackZhao.anims
    -- 动画效果
    -- 获得当前攻击技能的攻击招式动画
    if roleDoubleAttackSkill then
        attackZhaoAnims = table.mergeArray(roleAttackZhao.anims, roleDoubleAttackZhao.anims)
    end
    local attackZhaoAnimCount = #attackZhaoAnims
    
    -- 最后攻击部位
    local lastHitPos = nil
    
    -- 开始攻击
    local frames = 0
    local FPS = 30
    if PRINT_MODE == 1 then
        print("ANIM : count = " .. attackZhaoAnimCount .. " ")
    end
    for i = 1, attackZhaoAnimCount do
        
        local anim = attackZhaoAnims[i]
        local animName = Helper:getDef(role:getAttackAnimName(), anim.anim)
        local offset = anim.offset
        local hitPos = anim.hitPos
        local speedScale = anim.speed
        -- FIGHT_JUMP_SPEED_SCALE = 1
        -- FIGHT_PRESWING_SPEED_SCALE = 1
        -- FIGHT_AFTSWING_SPEED_SCALE = 1
        local jumpingDuration = math.ceil(10 / speedScale / FIGHT_JUMP_SPEED_SCALE)
        local preSwingDuration = math.ceil(10 / speedScale / FIGHT_PRESWING_SPEED_SCALE)
        local aftSwingDuration = 10 -- math.ceil(10 / speedScale)
        
        -- local jumpingDuration = math.ceil(speedScale * 5)
        -- local preSwingDuration = math.ceil(speedScale * 5)
        -- local aftSwingDuration = math.ceil(speedScale * 10)
        lastHitPos = hitPos
        
        if PRINT_MODE == 1 then
            print("animName = " .. tostring(animName))
            -- 跳跃要花5帧
            print("\t\tanimName = " .. tostring(animName))
            
            print("role._currAutoZhaoTimes = ", role._currAutoZhaoTimes)
        end
        
        if i == 1 and role._currAutoZhaoTimes == 1 then
            -- 跳到目标位置, 跳跃时间是动画前摇的一半时间
            self:delayFunc(frames / FPS, function()
                self:roleMove(role, target, jumpingDuration / FPS, offset, 0)
                self:rolePlayAnim(role, Helper:getDef(role:getJumpForwardAnimName(), roleAttackSkill:getJumpForwardAnimName(role)), nil, nil, speedScale * FIGHT_JUMP_SPEED_SCALE)-- 播放跳跃动画
            end)
            
            frames = frames + jumpingDuration
            
            -- 攻击前摇，要计算前摇,跳跃半空就可以开始播放了
            self:delayFunc(frames / FPS, function()
                self:roleMove(role, target, preSwingDuration / FPS, offset, 0)
                self:rolePlayAnim(role, animName, 0, 10, speedScale * FIGHT_PRESWING_SPEED_SCALE)
            end)
            
            frames = frames + preSwingDuration
        else
            -- -- 攻击前摇，要计算前摇,跳跃半空就可以开始播放了
            -- self:delayFunc(frames / FPS, function()
            --     self:roleMove(role, target, (jumpingDuration + preSwingDuration) / FPS, offset, 0)
            --     self:rolePlayAnim(role, animName, 0, 10, 10 / (jumpingDuration + preSwingDuration))
            -- end)
            -- frames = frames + jumpingDuration + preSwingDuration
            -- 攻击前摇，要计算前摇,跳跃半空就可以开始播放了
            self:delayFunc(frames / FPS, function()
                self:roleMove(role, target, preSwingDuration / FPS, offset, 0)
                self:rolePlayAnim(role, animName, 0, 10, speedScale * FIGHT_PRESWING_SPEED_SCALE)
            end)
            
            frames = frames + preSwingDuration
        end
        
        --攻击和攻击后摇
        self:delayFunc(frames / FPS, function()
            self:rolePlayAnim(role, animName, 10, 20, 1.0)
            
            --攻击击中反馈
            if attackFunc then
                local isLastHit = (i == attackZhaoAnimCount)
                attackFunc("attack", hitPos, isLastHit, i)
            end
        end)
        
        
        --后摇时间
        frames = frames + aftSwingDuration
    
    --击中动画
    end
    
    --播完后恢复
    print("frames / FPS = " .. (frames / FPS))
    print("frames = " .. frames)
    self.__attactEndFunc = self:delayFunc(frames / FPS, function()
        attackFunc("attackEnd", lastHitPos, role:isDead(), target:isDead())
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 击中
function FightLayer:roleHit(role, target, zhaoData)
    -- print(role:getName().."击中了"..target:getName())
    -- 自己
    local roleName = role:getName()
    local roleWeaponName = role:getCurrWeaponName()
    local roleAttackSkill = role:getCurrAttackSkill()
    local roleAttackZhao = role:getCurrAttackZhao()
    local roleAttackAction = roleAttackZhao.action
    local damageClassName = Helper:getDef(roleAttackSkill:getDamageClassName(),"伤害")
    local roleDoubleAttackSkill = role:getCurrDoubleAttackSkill()
    local roleDoubleAttackZhao = role:getCurrDoubleAttackZhao()
    
    local hitPosName = zhaoData.hitPosName
    
    if PRINT_MODE == 1 then
        print("hitPosName = ", hitPosName)
    end
    
    -- 对手
    local targetName = target:getName()
    local targetWeaponName = target:getCurrWeaponName()
    
    --卸力百分比
    local xieLiPercent = Helper:getRange(Helper:getDef(zhaoData.xieLiPercent, 0), 0,1)

    --真罡值
    local zhenGangValue = Helper:getDef(zhaoData.isZhenGang, 0)
    if zhenGangValue and zhenGangValue > 0 then
        local beforeAtk = zhaoData.atk
        zhaoData.atk = Helper:getRange(zhaoData.atk - zhenGangValue, 0)
        if zhaoData.atk == 0 then
            zhenGangValue = beforeAtk
        end
    end

    zhaoData.atk = Helper:getRange(zhaoData.atk,0,zhaoData.damageMax)

    -- 攻击情况
    if roleDoubleAttackZhao then
        if PRINT_MODE == 1 then
            print("互备")
        end
        
        local absorbAtkLeft = Helper:getDef(zhaoData.absorbAtk, 0)
        local attackDamageWeightArray = getWeightArray(2, 50)-- 生成攻击伤害权重数组
        
        -- 拳脚1攻击 add by TangJian 2016/12/01 19:48:11
        do
            -- 攻击情况
            self:printFightStatus(roleAttackAction, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
            local atk = math.floor(zhaoData.atk * attackDamageWeightArray[1] / 100)
            
             local trueDamage = math.floor(Helper:getDef(zhaoData.trueDamage,0) * attackDamageWeightArray[1] / 100)
            -- 攻击会被吸收, 所以有个最终攻击 add by TangJian 2017/04/08 18:12:27
            local finalAttack = atk

            local atkStr
            
            if zhaoData.isCruor == true then
                finalAttack = 0
                atk = atk + trueDamage
                atkStr = math.floor(finalAttack) .. "(" .. "凝血" .. math.floor(atk) .. ")"
            elseif zhaoData.isFanShang == true then
                finalAttack = 0
                atk = atk + trueDamage
                atkStr = math.floor(finalAttack) .. "(" .. "反弹" .. math.floor(atk) .. ")"
            -- add by XiaoZhiWei 2017/07/27 11:18:25 偏转伤害文本
            elseif zhaoData.isZhuanYi == true then
                finalAttack = 0
                atk = atk + trueDamage
                atkStr = math.floor(finalAttack) .. "(" .. "偏转" .. math.floor(atk) .. ")"
            elseif absorbAtkLeft > 0 then
                if absorbAtkLeft >= atk then
                    finalAttack = 0
                    finalAttack = finalAttack + trueDamage
                    atkStr = finalAttack .. "(" .. "吸收" .. atk .. ")"
                    absorbAtkLeft = absorbAtkLeft - atk
                else
                    finalAttack = (atk - absorbAtkLeft)
                    finalAttack = finalAttack + trueDamage
                    atkStr = math.floor(finalAttack) .. "(" .. "吸收" .. math.floor(absorbAtkLeft) .. ")"
                    absorbAtkLeft = 0
                end
            elseif xieLiPercent > 0 then
                atk = atk*(1 - xieLiPercent)
                finalAttack = atk + trueDamage
                atkStr = math.floor(finalAttack) .. "(" .. "卸力" .. math.floor(atk*xieLiPercent) .. ")"
            elseif zhaoData.isSaveDamage == true then
                finalAttack = 0
                atk = atk + trueDamage
                atkStr = math.floor(finalAttack) .. "(" .. "凝伤" .. math.floor(atk) .. ")"
            elseif zhaoData.isZhenGang then
                atk = atk + trueDamage
                finalAttack = atk
                atkStr = math.floor(finalAttack) .. "(" .. "真罡" .. math.floor(zhenGangValue * attackDamageWeightArray[1] / 100) .. ")"
            else
                atk = atk + trueDamage
                finalAttack = atk
                atkStr = atk
            end
            if atk < 0 then
                atkStr = 0
            end
            -- 受伤情况
            local dmgType = roleAttackZhao.damageType
            local str = "WHT" .. tostring(Skill:getAttactResultDesc(dmgType, finalAttack))
            self:printFightStatus(str, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
            -- 输出伤害
            self._UI:print("HIR造成了HIW" .. atkStr .. "HIR点"..damageClassName.."。")
        end
        
        -- 拳脚2攻击 add by TangJian 2016/12/01 19:47:56
        do
            -- 攻击情况
            self:printFightStatus(roleDoubleAttackZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
            local atk = math.floor(zhaoData.atk * attackDamageWeightArray[2] / 100)
            
            local trueDamage = math.floor(Helper:getDef(zhaoData.trueDamage,0) * attackDamageWeightArray[2] / 100)

            -- 攻击会被吸收, 所以有个最终攻击 add by TangJian 2017/04/08 18:12:27
            local finalAttack = atk

            local atkStr
            if zhaoData.isCruor == true then
                finalAttack = 0
                atk = atk + trueDamage
                atkStr = math.floor(finalAttack) .. "(" .. "凝血" .. math.floor(atk) .. ")"
            elseif zhaoData.isFanShang == true then
                finalAttack = 0
                atk = atk + trueDamage
                atkStr = math.floor(finalAttack) .. "(" .. "反弹" .. math.floor(atk) .. ")"
            elseif zhaoData.isZhuanYi == true then
                finalAttack = 0
                atk = atk + trueDamage
                atkStr = math.floor(finalAttack) .. "(" .. "偏转" .. math.floor(atk) .. ")"
            elseif absorbAtkLeft > 0 then
                if absorbAtkLeft >= atk then
                    finalAttack = 0
                    finalAttack = finalAttack + trueDamage
                    atkStr = finalAttack .. "(" .. "吸收" .. atk .. ")"
                    absorbAtkLeft = absorbAtkLeft - atk
                else
                    finalAttack = (atk - absorbAtkLeft)
                    finalAttack = finalAttack + trueDamage
                    atkStr = math.floor(finalAttack) .. "(" .. "吸收" .. math.floor(absorbAtkLeft) .. ")"
                    absorbAtkLeft = 0
                end
            elseif xieLiPercent > 0 then
                atk = atk*(1 - xieLiPercent)
                finalAttack = atk + trueDamage
                atkStr = math.floor(finalAttack) .. "(" .. "卸力" .. math.floor(atk*xieLiPercent) .. ")"
            elseif zhaoData.isSaveDamage == true then
                finalAttack = 0
                atk = atk + trueDamage
                atkStr = math.floor(finalAttack) .. "(" .. "凝伤" .. math.floor(atk) .. ")"
            elseif zhaoData.isZhenGang then
                atk = atk + trueDamage
                finalAttack = atk
                atkStr = math.floor(finalAttack) .. "(" .. "真罡" .. math.floor(zhenGangValue * attackDamageWeightArray[2] / 100) .. ")"
            else
                atk = atk + trueDamage
                finalAttack = atk
                atkStr = atk
            end

            if atk < 0 then
                atkStr =0
            end
            
            -- 受伤情况
            local dmgType = roleDoubleAttackZhao.damageType
            local str = "WHT" .. tostring(Skill:getAttactResultDesc(dmgType, atkStr))
            self:printFightStatus(str, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
            if zhaoData.isFanShang == true then
                self:printFightStatus("结果被$n反弹了回去！", roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
            else
                -- 受伤情况
                local dmgType = roleAttackZhao.damageType
                local str = "WHT" .. tostring(Skill:getAttactResultDesc(dmgType, finalAttack))
                self:printFightStatus(str, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
            end
            
            local doubleDamageClassName = Helper:getDef(roleDoubleAttackSkill:getDamageClassName(),"伤害")

            -- 输出伤害
            self._UI:print("HIR造成了HIW" .. atkStr .. "HIR点"..doubleDamageClassName.."。")
        end
    else
        self:printFightStatus(roleAttackAction, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        
        -- 受伤情况
        local dmgType = roleAttackZhao.damageType
        
        -- 攻击会被吸收, 所以有个最终攻击 add by TangJian 2017/04/08 18:12:27
        local finalAttack = 0

        local trueDamage = Helper:getDef(zhaoData.trueDamage,0)
        local atkStr
        if zhaoData.isCruor == true then
            finalAttack = 0
            atkStr = math.floor(finalAttack) .. "(" .. "凝血" .. math.floor(zhaoData.atk + trueDamage) .. ")"
        elseif zhaoData.isFanShang == true then
            finalAttack = 0
            atkStr = math.floor(finalAttack) .. "(" .. "反弹" .. math.floor(zhaoData.atk + trueDamage) .. ")"
        elseif zhaoData.isZhuanYi == true then
            finalAttack = 0
            atkStr = math.floor(finalAttack) .. "(" .. "偏转" .. math.floor(zhaoData.atk + trueDamage) .. ")"
        elseif zhaoData.absorbAtk and zhaoData.absorbAtk > 0 then
            finalAttack = math.floor(zhaoData.atk - zhaoData.absorbAtk)
            finalAttack =  finalAttack + trueDamage
            if finalAttack <0 then
                finalAttack =0
            end
            
            atkStr = tostring(finalAttack) .. "(" .. "吸收" .. tostring(math.floor(zhaoData.absorbAtk)) .. ")"
        elseif xieLiPercent > 0 then
            finalAttack = math.floor(zhaoData.atk*(1 - xieLiPercent)) + trueDamage
            atkStr = math.floor(finalAttack) .. "(" .. "卸力" .. math.floor(zhaoData.atk*xieLiPercent) .. ")"
        elseif zhaoData.isSaveDamage == true then
            finalAttack = 0
            atkStr = math.floor(finalAttack) .. "(" .. "凝伤" .. math.floor(zhaoData.atk + trueDamage) .. ")"
        elseif zhaoData.isZhenGang then
            finalAttack = math.floor(zhaoData.atk) + trueDamage
            atkStr = math.floor(finalAttack) .. "(" .. "真罡" .. math.floor(zhenGangValue) .. ")"
        else
            finalAttack = math.floor(zhaoData.atk) + trueDamage
            atkStr = tostring(math.floor(zhaoData.atk)) + trueDamage
            if finalAttack < 0 then
                atkStr = "0"
            end
        end
        -- local str = "WHT" .. tostring(Skill:getAttactResultDesc(dmgType, finalAttack))
        -- self:printFightStatus(str, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)


        if zhaoData.isFanShang == true then
            self:printFightStatus("结果被$n反弹了回去！", roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        else
            -- 受伤情况
            local str = "WHT" .. tostring(Skill:getAttactResultDesc(dmgType, finalAttack))
            self:printFightStatus(str, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        end
        -- 输出伤害
        -- 输出伤害
        self._UI:print("HIR造成了HIW" .. (atkStr) .. "HIR点"..damageClassName.."。")
    end
    
    -- 打印状态
    self:printFightStatus("（" .. target:getFightQiDesc() .. "NOR）", role:getName(), target:getName())
    -- 得到攻击次数
    local attackTimes = #roleAttackZhao.anims
    local currAttackTimes = 0
    if roleDoubleAttackSkill then
        attackTimes = attackTimes + #roleDoubleAttackZhao.anims
    end
    local attackDamageWeightArray = getWeightArray(attackTimes, 50)-- 生成攻击伤害权重数组
    local absorbAtkLeft = Helper:getDef(zhaoData.absorbAtk, 0)
    
    -- 动画效果
    -- 获得当前攻击技能的攻击招式动画
    self:playRoleAttackAnim(role, target, function(eventName, ...)
        if eventName == "attack" then
            self:refreshRoleEffectAnim()-- 刷新角色效果动画

            local hitPos, isLastHit, animIndex = ...

            -- 显示掉血动画
            do
                currAttackTimes = currAttackTimes + 1
                local atk = math.floor(zhaoData.atk * attackDamageWeightArray[currAttackTimes] / 100)
                local trueDamage = math.floor(Helper:getDef(zhaoData.trueDamage,0) * attackDamageWeightArray[currAttackTimes] / 100)
                
                local finalDamage = atk + trueDamage
                local atkStr
                if absorbAtkLeft > 0 then
                    if absorbAtkLeft >= atk then
                        atkStr = 0 + trueDamage .. "(" .. "吸收" .. atk .. ")"
                        absorbAtkLeft = absorbAtkLeft - atk
                        finalDamage = 0
                    else
                        local atkAftAbsorb = math.floor(atk - absorbAtkLeft)
                        atkAftAbsorb = atkAftAbsorb + trueDamage
                        atkStr = atkAftAbsorb .. "(" .. "吸收" .. math.floor(absorbAtkLeft) .. ")"                        
                        absorbAtkLeft = 0
                        finalDamage = atkAftAbsorb
                    end
                elseif xieLiPercent > 0 then
                    atkStr = math.floor(atk*(1 - xieLiPercent) + trueDamage)
                else
                    atkStr = atk + trueDamage
                end

                if zhaoData.isCruor then
                    local cruorFactor = zhaoData.cruorFactor
                    self:rolePopNumber(target, "+" .. math.floor(finalDamage*cruorFactor),cc.c4b(51, 153, 51, 255))
                elseif zhaoData.isFanShang then
                    self:rolePopNumber(target, "反弹")
                    -- add by LvBin 吸收偏转伤害文本
                    if role:haveShield() then
                        local absorbAtk = 0 
                        if type(role.absorbAtk) == "table" and type(role.absorbAtk["FanShang"]) == "number" then
                            absorbAtk = role.absorbAtk["FanShang"]
                        end
                        local resultAtk = math.floor(zhaoData.atk - absorbAtk)
                        self:rolePopNumber(role, "-" .. resultAtk)
                    elseif zhaoData.roleHaveZhuanYi == true then
                        self:rolePopNumber(role, "偏转")
                    else
                        self:rolePopNumber(role, "-" .. atkStr)
                    end
                elseif zhaoData.isZhuanYi then
                    self:rolePopNumber(target, "偏转")
                elseif xieLiPercent > 0 then
                    self:rolePopNumber(target, "-" .. atkStr.. "(" .. "卸力" .. math.floor(xieLiPercent*atk) .. ")")

                    if zhaoData.isSuckBlood == true then
                        local SuckBloodPercen = zhaoData.SuckBloodPercen
                        local arg1 = zhaoData.arg1
                        local color = cc.c4b(255, 255, 255, 255)
                        if arg1 == "qi" then
                            color = cc.c4b(51, 153, 51, 255)
                        elseif arg1 == "neili" then
                            color = cc.c4b(28, 76, 163, 255)                  
                        end
                        local damage = math.floor(atk*(1 - xieLiPercent) + trueDamage)
                        self:rolePopNumber(role,"+"..math.floor(SuckBloodPercen*damage),color)
                    end
                elseif zhaoData.isSaveDamage == true then
                    self:rolePopNumber(target, "-" .. atkStr)
                else
                    -- 伤害出现"--x" 情况修正为-0
                    if atk <0 then
                        atkStr = 0
                    end

                    if zhaoData.isZhenGang then
                        atkStr = atkStr.. "(" .. "真罡" .. math.floor(zhenGangValue * attackDamageWeightArray[currAttackTimes] / 100) .. ")"
                    end

                    self:rolePopNumber(target, "-" .. atkStr)

                    if zhaoData.isSuckBlood == true then
                        local SuckBloodPercen = zhaoData.SuckBloodPercen
                        local arg1 = zhaoData.arg1
                        local color = cc.c4b(255, 255, 255, 255)
                        if arg1 == "qi" then
                            color = cc.c4b(51, 153, 51, 255)
                        elseif arg1 == "neili" then
                            color = cc.c4b(28, 76, 163, 255)                  
                        end
                        self:rolePopNumber(role,"+"..math.floor(SuckBloodPercen*finalDamage),color)
                    end
                end

            -- self._UI:print("HIR造成了HIW" .. atk .. "HIR点伤害。")
            end
            
            -- 播放击中音效 add by TangJian 2016/11/07 14:28:21
            self:playRandomHitSound(role:getCurrWeaponType(), role:getCurrWeaponType2())
            -- 播放随受伤音效 add by TangJian 2016/11/08 11:55:31
            self:playRandomHurtSound(target:getAttr("sex"))
            
            local isDead = false
            if isLastHit then
                if target:isDead() then
                    self:roleDie(target, hitPos)
                    isDead = true
                end

                if role:isDead() then
                    self:roleDie(role, "chest")
                    isDead = true
                end
            end
            
            if isDead == false then
                local hurtZhao = roleAttackSkill:getRandomHurtZhaoByPosition(hitPos, target:getAttackMethod())

                if zhaoData.isFanShang then
                    local targetAttackMethod = target:getAttackMethod()
                    local zhao = target:getRandomParryZhaoByPosition(hitPos)
                    local targetParrySkill = target:getCurrParrySkill()
                    local zhaoAnimName = targetParrySkill:getParryAnimNameWithAttackMethodAndHitPos(targetAttackMethod, hitPos)
                    self:roleMoveBy(target, 10 / 30, zhao.offset)
                    self:rolePlayAnim(target, Helper:getDef(target:getParryAnimName(hitPos), zhaoAnimName), nil, nil, 1)
                elseif zhaoData.isZhuanYi then
                    local targetAttackMethod = target:getAttackMethod()
                    local zhao = target:getRandomParryZhaoByPosition(hitPos)
                    local targetParrySkill = target:getCurrParrySkill()
                    local zhaoAnimName = targetParrySkill:getParryAnimNameWithAttackMethodAndHitPos(targetAttackMethod, hitPos)
                    self:roleMoveBy(target, 10 / 30, zhao.offset)
                    self:rolePlayAnim(target, Helper:getDef(target:getParryAnimName(hitPos), zhaoAnimName), nil, nil, 1)
                elseif xieLiPercent > 0 then
                    local targetAttackMethod = target:getAttackMethod()
                    local zhao = target:getRandomParryZhaoByPosition(hitPos)
                    local targetParrySkill = target:getCurrParrySkill()
                    local zhaoAnimName = targetParrySkill:getParryAnimNameWithAttackMethodAndHitPos(targetAttackMethod, hitPos)
                    self:roleMoveBy(target, 10 / 30, zhao.offset)
                    self:rolePlayAnim(target, Helper:getDef(target:getParryAnimName(hitPos), zhaoAnimName), nil, nil, 1)
                elseif zhaoData.isSaveDamage then
                    self:roleMoveBy(target, 10 / 30, hurtZhao.offset)
                    self:rolePlayAnim(target, target:getSaveDamageHitAnimName(hitPos), nil, nil, 1)
                else
                    self:roleMoveBy(target, 10 / 30, hurtZhao.offset)
                    self:rolePlayAnim(target, Helper:getDef(target:getHurtAnimName(hitPos), hurtZhao.anim), nil, nil, 1)
                end
            end
        elseif eventName == "attackEnd" then
            local lastHitPos, roleIsDead, targetIsDead = ...

            if roleIsDead and targetIsDead then
            elseif roleIsDead then
                self:playWinAnim(target,0.4)
                self:roleMoveToOrigin(target, role)
            elseif targetIsDead then
                self:rolePlayAnim(role, role:getStandAnimName())
                self:playWinAnim(role,0.4)
                self:roleAttackEndMoveToOrigin(role, target, zhaoData.isWaitingTili)
            else
                self:roleAttackEndMoveToOrigin(role, target, zhaoData.isWaitingTili)
                self:roleMoveToOrigin(target, role)
            end
        end
    end, zhaoData)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 被闪避
function FightLayer:roleDodged(role, target, zhaoData,EffectMapList)
    -- print(target:getName().."躲过了"..role:getName().."的攻击")
    -- 自己
    local roleName = role:getName()
    local roleWeaponName = role:getCurrWeaponName()
    local roleAttackSkill = role:getCurrAttackSkill()
    local roleAttackZhao = role:getCurrAttackZhao()
    local roleAttackAction = roleAttackZhao.action
    local roleDoubleAttackSkill = role:getCurrDoubleAttackSkill()
    local roleDoubleAttackZhao = role:getCurrDoubleAttackZhao()
    
    -- 攻击部位名字
    local hitPosName = zhaoData.hitPosName
    
    -- 对手
    local targetName = target:getName()
    local targetWeaponName = target:getCurrWeaponName()
    local targetDodgeSkill = target:getCurrDodgeSkill()
    local targetDodgeZhao = targetDodgeSkill:getRandomDodgeSkill(target:getRole())
    
    -- 攻击情况
    if roleDoubleAttackZhao then
        if PRINT_MODE == 1 then
            print("互备")
        end
        
        -- 攻击情况
        self:printFightStatus(roleAttackAction, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        -- 闪避成功
        local targetDodgeZhao = targetDodgeSkill:getRandomDodgeSkill(target:getRole())
        self:printFightStatus(targetDodgeZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        -- 攻击情况
        self:printFightStatus(roleDoubleAttackZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        -- 闪避成功
        local targetDodgeZhao = targetDodgeSkill:getRandomDodgeSkill(target:getRole())
        self:printFightStatus(targetDodgeZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
    else
        self:printFightStatus(roleAttackAction, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        -- 闪避成功
        local targetDodgeZhao = targetDodgeSkill:getRandomDodgeSkill(target:getRole())
        self:printFightStatus(targetDodgeZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
    end
    
    -- 动画效果
    self:playRoleAttackAnim(role, target, function(eventName, ...)
        if eventName == "attack" then
            self:refreshRoleEffectAnim()-- 刷新角色效果动画
            -- 播放音效 add by TangJian 2016/11/07 14:28:21
            self:playRandomDodgeSound(role:getCurrWeaponType(), role:getCurrWeaponType2())
            
            -- 显示闪避文字 add by TangJian 2016/11/26 15:17:35
            self:rolePopNumber(target, "WHT闪避")
            
            local hitPos = ...
            local zhao = target:getRandomDodgeZhaoByPosition(hitPos)
            self:roleMoveBy(target, 10 / 30, zhao.offset)
            self:rolePlayAnim(target, Helper:getDef(target:getDodgeAnimName(hitPos), zhao.anim), nil, nil, 1)
        elseif eventName == "attackEnd" then
            if MapIsEmpty(EffectMapList)then
                -- print("MapIsEmpty(EffectMapList) = true")
            else       
                for i,effect in ipairs(EffectMapList) do
                    local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
                    local effectType = effect:getType()
					local rolePopText = effect:getPopText()
                    switch(effectType,
                    {
                        ["闪耀"] = function()
                            --头顶冒字提示
                            self:rolePopNumber(target,rolePopText,effect:getNumberColor())
                        end,
                        ["闪烁"] = function ()
                            --头顶冒字提示
                            self:rolePopNumber(target,rolePopText,effect:getNumberColor())
                        end
                    })
                end
            end
            self:roleAttackEndMoveToOrigin(role, target, zhaoData.isWaitingTili)
            self:roleMoveToOrigin(target, role)
        end
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 被招架
function FightLayer:roleParried(role, target, zhaoData, EffectMapList, qiAtk)
    -- print(target:getName().."招架了"..role:getName().."的攻击")
    -- 自己
    local roleName = role:getName()
    local roleWeaponName = role:getCurrWeaponName()
    local roleAttackSkill = role:getCurrAttackSkill()
    local roleAttackZhao = role:getCurrAttackZhao()
    local roleAttackAction = roleAttackZhao.action
    local roleDoubleAttackSkill = role:getCurrDoubleAttackSkill()
    local roleDoubleAttackZhao = role:getCurrDoubleAttackZhao()
    
    -- 攻击部位名字
    local hitPosName = zhaoData.hitPosName
    
    -- 对手
    local targetName = target:getName()
    local targetAttackMethod = target:getAttackMethod()
    local targetWeaponName = target:getCurrWeaponName()
    local targetParrySkill = target:getCurrParrySkill()
    local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
    --卸力百分比
    local xieLiPercent = Helper:getRange(Helper:getDef(zhaoData.xieLiPercent, 0), 0,1)
    --真罡值
    local zhenGangValue = Helper:getDef(zhaoData.isZhenGang, 0)
    if zhenGangValue > zhaoData.atk then
        zhenGangValue = zhaoData.atk
    end

    -- 攻击情况
    if roleDoubleAttackZhao then
        local attackDamageWeightArray = getWeightArray(2, 50)-- 生成攻击伤害权重数组
        local atk1 = qiAtk * attackDamageWeightArray[1] / 100
        local atk2 = qiAtk * attackDamageWeightArray[2] / 100
        local str1, str2 = "", ""

        do
            local absorbAtkLeft = Helper:getDef(zhaoData.absorbAtk, 0)
            local trueDamage1 = Helper:getDef(zhaoData.trueDamage,0) * attackDamageWeightArray[1] / 100
            local trueDamage2 = Helper:getDef(zhaoData.trueDamage,0) * attackDamageWeightArray[2] / 100
            local zhaoAtk1 = zhaoData.atk * attackDamageWeightArray[1] / 100 + trueDamage1
            local zhaoAtk2 = zhaoData.atk * attackDamageWeightArray[2] / 100 + trueDamage2

            if zhaoData.isCruor then
                local value1 = math.floor(zhaoAtk1)
                local value2 = math.floor(zhaoAtk2)
                str1 = "(凝血"..value1..")"
                str2 = "(凝血"..value2..")"
            elseif zhaoData.isFanShang then
                local value1 = math.floor(zhaoAtk1)
                local value2 = math.floor(zhaoAtk2)
                str1 = "(反弹"..value1..")"
                str2 = "(反弹"..value2..")"
            elseif zhaoData.isZhuanYi then
                local value1 = math.floor(zhaoAtk1)
                local value2 = math.floor(zhaoAtk2)
                str1 = "(偏转"..value1..")"
                str2 = "(偏转"..value2..")"
            elseif absorbAtkLeft > 0 then
                if absorbAtkLeft >= (zhaoAtk1 - trueDamage1) then
                    local value1 = math.floor(zhaoAtk1 - trueDamage1)
                    str1 = "(吸收"..value1..")"
                    absorbAtkLeft = absorbAtkLeft - (zhaoAtk1 - trueDamage1)
                elseif absorbAtkLeft > 0 then
                    local value1 = math.floor(absorbAtkLeft)
                    str1 = "(吸收"..value1..")"
                    absorbAtkLeft = 0
                end
                
                if absorbAtkLeft >= (zhaoAtk2 - trueDamage2) then
                    local value2 = math.floor(zhaoAtk2 - trueDamage2)
                    str2 = "(吸收"..value2..")"
                    absorbAtkLeft = absorbAtkLeft - (zhaoAtk2 - trueDamage2)
                elseif absorbAtkLeft > 0 then
                    local value2 = math.floor(absorbAtkLeft)
                    str2 = "(吸收"..value2..")"
                    absorbAtkLeft = 0
                end
            elseif xieLiPercent > 0 then
                local value1 = math.floor((zhaoAtk1 - trueDamage1) * xieLiPercent)
                local value2 = math.floor((zhaoAtk2 - trueDamage2) * xieLiPercent)
                str1 = "(卸力"..value1..")"
                str2 = "(卸力"..value2..")"
            elseif zhaoData.isZhenGang then
                local value1 = math.floor(zhenGangValue * attackDamageWeightArray[1] / 100)
                local value2 = math.floor(zhenGangValue * attackDamageWeightArray[2] / 100)
                str1 = "(真罡"..value1..")"
                str2 = "(真罡"..value2..")" 
            end
        end
        
        -- 攻击情况
        self:printFightStatus(roleAttackAction, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        -- 招架成功
        local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
        self:printFightStatus(targetParryZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        self:printFightStatus("招架成功！削弱$N的攻击伤害后，$n受到"..tostring(math.floor(atk1))..str1.."伤害。", roleName, targetName)
        
        -- 攻击情况
        self:printFightStatus(roleDoubleAttackZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        
        -- 招架成功
        local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
        self:printFightStatus(targetParryZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        self:printFightStatus("招架成功！削弱$N的攻击伤害后，$n受到"..tostring(math.floor(atk2))..str2.."伤害。", roleName, targetName)
    else
        self:printFightStatus(roleAttackAction, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        -- 招架成功
        local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
        self:printFightStatus(targetParryZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)

        local str = ""

        do
            local absorbAtkLeft = Helper:getDef(zhaoData.absorbAtk, 0)
            local trueDamage = Helper:getDef(zhaoData.trueDamage,0)
            local zhaoAtk = zhaoData.atk  + trueDamage
            if zhaoData.isCruor then
                local value = math.floor(zhaoAtk)
                str = "(凝血"..value..")"
            elseif zhaoData.isFanShang then
                local value = math.floor(zhaoAtk)
                str = "(反弹"..value..")"
            elseif zhaoData.isZhuanYi then
                local value = math.floor(zhaoAtk)
                str = "(偏转"..value..")"
            elseif absorbAtkLeft > 0 then
                if absorbAtkLeft >= (zhaoAtk - trueDamage) then
                    local value = math.floor(zhaoAtk - trueDamage)
                    str = "(吸收"..value..")"
                    absorbAtkLeft = absorbAtkLeft - (zhaoAtk - trueDamage)
                elseif absorbAtkLeft > 0 then
                    local value = math.floor(absorbAtkLeft)
                    str = "(吸收"..value..")"
                    absorbAtkLeft = 0
                end
            elseif xieLiPercent > 0 then
                local value = math.floor((zhaoAtk - trueDamage) * xieLiPercent)
                str = "(卸力"..value..")"
            elseif zhaoData.isZhenGang then
                str = "(真罡"..math.floor(zhenGangValue)..")"
            end
        end
        
        self:printFightStatus("招架成功！削弱$N的攻击伤害后，$n受到"..tostring(math.floor(qiAtk))..str.."伤害。", roleName, targetName)
    end

    if qiAtk > 0 then
        self:printFightStatus("（" .. target:getFightQiDesc() .. "NOR）", role:getName(), target:getName())
    end

    local attackTimes = #roleAttackZhao.anims
    local currAttackTimes = 0
    if roleDoubleAttackSkill then
        attackTimes = attackTimes + #roleDoubleAttackZhao.anims
    end
    local attackDamageWeightArray = getWeightArray(attackTimes, 50)-- 生成攻击伤害权重数组
    local absorbAtkLeft = Helper:getDef(zhaoData.absorbAtk, 0)
    -- 动画效果
    self:playRoleAttackAnim(role, target, function(eventName, ...)
        if eventName == "attack" then
            currAttackTimes = currAttackTimes + 1
            local atk = math.floor(qiAtk * attackDamageWeightArray[currAttackTimes] / 100)
            -- 播放音效 add by TangJian 2016/11/07 14:28:21
            self:playRandomParrySound(role:getCurrWeaponType(), role:getCurrWeaponType2())
            
            if atk > 0 then
                self:playRandomHurtSound(target:getAttr("sex"))
                self:rolePopNumber(target, "招架-"..tostring(atk))
            else
                self:rolePopNumber(target, "招架")
            end

            self:refreshRoleEffectAnim()-- 刷新角色效果动画

            do
                local trueDamage = Helper:getDef(zhaoData.trueDamage,0) * attackDamageWeightArray[currAttackTimes] / 100
                local zhaoDataAtk = zhaoData.atk * attackDamageWeightArray[currAttackTimes] / 100
                if zhaoData.isCruor then
                    local cruorFactor = zhaoData.cruorFactor
                    self:rolePopNumber(target, "+" .. math.floor((trueDamage + zhaoDataAtk) * cruorFactor),cc.c4b(51, 153, 51, 255))
                elseif zhaoData.isFanShang then
                    self:rolePopNumber(target, "反弹")
                    if role:haveShield() then
                        local absorbAtk = 0 
                        if type(role.absorbAtk) == "table" and type(role.absorbAtk["FanShang"]) == "number" then
                            absorbAtk = role.absorbAtk["FanShang"]
                        end
                        local resultAtk = Helper:getRange(math.floor((zhaoData.atk - absorbAtk) * attackDamageWeightArray[currAttackTimes] / 100), 0)
                        self:rolePopNumber(role, "-" .. resultAtk)
                    elseif zhaoData.roleHaveZhuanYi == true then
                        self:rolePopNumber(role, "偏转")
                    else 
                        self:rolePopNumber(role, "-" .. math.floor(trueDamage + zhaoDataAtk))
                    end
                else
                    if absorbAtkLeft > 0 then
                        local str = ""
                        local absorbAtk,damage = zhaoDataAtk,trueDamage
                        if absorbAtkLeft < zhaoDataAtk then
                            absorbAtk = absorbAtkLeft
                            damage = trueDamage + zhaoDataAtk - absorbAtkLeft
                        end

                        str = "-" .. math.floor(damage).."(" .. "吸收" .. math.floor(absorbAtk) .. ")"
                        absorbAtkLeft = math.max(absorbAtkLeft - zhaoDataAtk, 0)

                        self:rolePopNumber(target, str)
                    end
                
                    if zhaoData.isZhuanYi then
                        self:rolePopNumber(target, "偏转")
                    end

                    if xieLiPercent > 0 then
                        self:rolePopNumber(target, "-" .. atk.. "(" .. "卸力" .. math.floor(xieLiPercent * zhaoDataAtk) .. ")")
                    end

                    if zhaoData.isZhenGang  then
                        self:rolePopNumber(target, "-" .. atk.. "(" .. "真罡" .. math.floor(zhenGangValue * attackDamageWeightArray[currAttackTimes] / 100) .. ")")
                    end
                    
                    if zhaoData.isSuckBlood == true then
                        local SuckBloodPercen = zhaoData.SuckBloodPercen
                        local arg1 = zhaoData.arg1
                        local color = cc.c4b(255, 255, 255, 255)
                        if arg1 == "qi" then
                            color = cc.c4b(51, 153, 51, 255)
                        elseif arg1 == "neili" then
                            color = cc.c4b(28, 76, 163, 255)                  
                        end
                        self:rolePopNumber(role,"+"..math.floor(SuckBloodPercen * atk),color)
                    end
                end
            end
            
            local hitPos = ...
            local zhao = target:getRandomParryZhaoByPosition(hitPos)
            local zhaoAnimName = targetParrySkill:getParryAnimNameWithAttackMethodAndHitPos(targetAttackMethod, hitPos)
            self:roleMoveBy(target, 10 / 30, zhao.offset)
            self:rolePlayAnim(target, Helper:getDef(zhao.anim, Helper:getDef(target:getParryAnimName(hitPos), zhaoAnimName)), nil, nil, 1)
        elseif eventName == "attackEnd" then
            if MapIsEmpty(EffectMapList)then
                -- print("MapIsEmpty(EffectMapList) = true")
            else       
                for i,effect in ipairs(EffectMapList) do
                    local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
                    local effectType = effect:getType()
					local rolePopText = effect:getPopText()
                    switch(effectType,
                    {
                        ["反震"] = function()
                            --填0则反弹原值
                            if arg2 == 0 then
                                local factors = {
                                    damageFactor = zhaoData.damageFactor,
                                    zhaoTimesFactor = zhaoData.zhaoTimesFactor,
                                }

                                local value = self.fight:getBeforeEffectAtkInHitResult(zhaoData.originalAtk, factors)
                                arg2 = -value
                            end
                            local text = effect:getRoleTopPopDesc(arg1, math.floor(arg2))

                            --头顶冒字提示
                            self:rolePopNumber(role,text,effect:getNumberColor())
                        end,
                        ["破招"] = function()
                        end,
                        ["架御"] = function ()
                            self:rolePopNumber(target,rolePopText,effect:getNumberColor())
                        end,
                        ["架势"] = function ()
                            self:rolePopNumber(target,rolePopText,effect:getNumberColor())
                        end
                    })
                end
            end

            if role:isDead() and target:isDead() then
                self:roleDie(role, "chest")
                self:roleDie(target, "chest")
            elseif role:isDead() then
                self:roleDie(role, "chest")
                self:roleMoveToOrigin(target, role)
                self:playWinAnim(target,0.4)
            elseif target:isDead() then
                self:roleDie(target, "chest")
                self:roleAttackEndMoveToOrigin(role, target, zhaoData.isWaitingTili)
                self:playWinAnim(role,0.4)
            else
                self:roleAttackEndMoveToOrigin(role, target, zhaoData.isWaitingTili)
                self:roleMoveToOrigin(target, role)
            end
        end
    end)
end

-----------------------------------------------------------------------------------------------------------
--@desc: 角色死亡
--@author:LvBin
--@time:2023-03-14 20:20:01
--@role:
--@hitPos:
--@return
function FightLayer:roleDie(role, hitPos)
    if role:isSelfKill() then
        role:triggerSelfKill(hitPos)
    else
        self:executeRoleDie(role, hitPos)
    end
end

--@desc: 以前的角色死亡(只改了个方法名字)
--@author:LvBin
--@time:2023-03-14 18:06:20
--@role:
	--@hitPos:
--@return
function FightLayer:executeRoleDie(role, hitPos)
    self:playRandomDieSound(role:getAttr("sex"))
    
    switch(role:getAnimType(),
        {
            human = function()
                if hitPos == "head" then
                    self:rolePlayAnim(role, "barehand-dead-head1", nil, nil, 1)
                elseif hitPos == "chest" then
                    self:rolePlayAnim(role, "barehand-dead-chest1", nil, nil, 1)
                elseif hitPos == "foot" then
                    self:rolePlayAnim(role, "barehand-dead-foot1", nil, nil, 1)
                else
                    if PRINT_MODE == 1 then
                        print("hitPos = " .. tostring(hitPos))
                    end
                end
            end,
            default = function()
                self:rolePlayAnim(role, role:getDeadAnimName(), nil, nil, 1)
            end
        })
end


--@desc: 角色立即死亡
--@author:LvBin
--@time:2023-03-14 17:18:57
--@return
function FightLayer:selfKillDie(role, hitPos, sound, animName, animFrame)
    self:playRandomDieSound(role:getAttr("sex"))
    
    local dieAnim =
        switch(
        role:getAnimType(),
        {
            human = function()
                if hitPos == "head" then
                    return "barehand-dead-head1"
                elseif hitPos == "chest" then
                    return "barehand-dead-chest1"
                elseif hitPos == "foot" then
                    return "barehand-dead-foot1"
                else
                    return "barehand-dead-chest1"
                end
            end,
            default = function()
                return role:getDeadAnimName()
            end
        }
    )

    self:rolePlayAnim(role, animName, nil, nil, 1)

    self:delayFunc(animFrame / 30, function()
        local saveDamageMax = Helper:mathFloor(role:getSaveDamageMax())

        local text = "-"..tostring(saveDamageMax)

        self:rolePopNumber(role,text,cc.c4b(255, 255, 255, 255))

        self:rolePlayAnim(role, dieAnim, nil, nil, 1)
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/16 16:54:04
-- @desc 主动招式攻击动画
function FightLayer:playRoleActiveZhaoAnim(role, target, activeZhao, hitType, activeZhaoType)
    local needPreJump = true
    local needAftJump = true
    
    if activeZhaoType == "攻击" then
        needPreJump = true
        needAftJump = true
    elseif activeZhaoType == "释放" then
        needPreJump = false
        needAftJump = false
    elseif activeZhaoType == "攻击不跳回" then
        needPreJump = true
        needAftJump = false
    end

    if self.__attactEndFunc then
        self:stopActionByTag(self.__attactEndFunc)
        self.__attactEndFunc = nil
    end
    
    local anim = clone(activeZhao:getAnim())
    
    if activeZhao.isSpecialAnim and not MapIsEmpty(activeZhao:getAnim2()) then
        anim = clone(activeZhao:getAnim2())
    end


    Skill:initActiveZhaoAttackAnim(anim,role)

    local effectUIInfos = activeZhao.immediateEffectUIArray

    do
        local totalDuration = 0
        
        -- 跳跃前动画
        if anim.preJumpAnim then
            self:delayFunc(totalDuration / 30, function()
                self:rolePlayAnim(role, anim.preJumpAnim.animName)
            end)
            totalDuration = totalDuration + anim.preJumpAnim.duration
        end
        
        -- 攻击
        if #anim.attackAnim > 0 then
            local currHitTime = 0 -- 当前攻击次数 add by TangJian 2017/03/18 15:29:37
            
            local hitTimes = 0 -- 计算出总得攻击次数 add by TangJian 2017/03/18 15:29:31
            for i, v in ipairs(anim.attackAnim) do
                hitTimes = hitTimes + #v.hits
            end
            
            local effectWeightArray = getWeightArray(hitTimes, 50)-- 生成攻击伤害权重数组
            print("hitTimes = ", hitTimes)
            print("effectWeightArray = ")
            for i, v in ipairs(effectWeightArray) do
                print(i, v)
            end
            
            -- print("effectWeightArray = ", unpack(effectWeightArray))
            for animIndex, attackAnim in ipairs(anim.attackAnim) do
                local jumpDuration = 5
                -- 跳跃
                if needPreJump then
                    self:delayFunc(totalDuration / 30, function()
                        local moveOffset = self:roleMove(role, target, jumpDuration / 30, attackAnim.offset)
                        if i == 1 then
                            self:rolePlayAnim(role, role:getJumpForwardAnimName())
                        end
                    end)
                    totalDuration = totalDuration + jumpDuration
                end
                
                -- 攻击
                self:delayFunc(totalDuration / 30, function()
                    self:rolePlayAnim(role, attackAnim.animName)
                    
                    if anim.defendAnimArray then
                        local defendAnim = anim.defendAnimArray[animIndex]
                        if defendAnim then
                            self:rolePlayAnim(target, defendAnim.animName)
                        end
                    end
                end)

                local effectFrames = attackAnim.effectFrames

                --效果动画
                if #effectFrames > 0 then
                    for i = 1, #effectFrames do
                        local currDuration  = totalDuration + effectFrames[i]
                        
                        local roleEffectAnims = role:getEffectAnims()

                        if #roleEffectAnims > 0 then
                            
                            for j =  #roleEffectAnims, 1, -1 do
                                local effectAnim = roleEffectAnims[i]
                                
                                self:delayFunc(currDuration / 30, function()
                                    self:playRoleEffectAnim(role, effectAnim)
                                    table.remove(roleEffectAnims, j)
                                end)
                            end
                        end

                        local targetEffectAnims = target:getEffectAnims()

                        if #targetEffectAnims > 0 then
                            
                            for j = #targetEffectAnims, 1, -1 do
                                local effectAnim = targetEffectAnims[i]
                                
                                self:delayFunc(currDuration / 30, function()
                                    self:playRoleEffectAnim(target, effectAnim)
                                    table.remove(targetEffectAnims, j)
                                end)
                            end
                        end
                    end
                    
                end
                
                -- 攻击
                do
                    -- -- -- 攻击方法
                    -- local hitType = switch(math.random(1, 3),
                    --     {
                    --         [1] = "hurt",
                    --         [2] = "dodge",
                    --         [3] = "parry",
                    --         default = "hurt",
                    --     })
                    -- 攻击
                    local hits = attackAnim.hits
                    if hits and #hits > 0 then
                        for hitIndex = 1, #hits do
                            
                            currHitTime = currHitTime + 1 -- 当前攻击次数 + 1 爱到底不用TangJian2017/03/18 15:29:53
                            local currHitTime = currHitTime -- 改变后要定义为局部变量, 这样才能通过闭包使用到当前值 add by TangJian 2017/03/18 15:30:17
                            
                            local hit = hits[hitIndex]
                            local hitPos = hit.hitPos
                            local hitOffset = hit.offset
                            local hitFrame = hit.frame
                            local duration = 10
                            if hits[hitIndex + 1] then
                                duration = hits[hitIndex + 1].frame - hitFrame
                            else
                                duration = 10
                            end
                            
                            self:delayFunc((totalDuration + (hitFrame - 1)) / 30, function()
                                self:refreshRoleEffectAnim()-- 刷新角色效果动画
                                
                                local hitPos = hit.hitPos
                                local hisOffset = hit.hisOffset
                                
                                local hitPosName = switch(hitPos,
                                    {
                                        head = "头",
                                        chest = "胸",
                                        foot = "腿"
                                    }
                                )

                                local effectIsShow = {}

                                for i, info in ipairs(effectUIInfos) do
                                    local effect = Skill:getSkillEffect(info:getEffectId()):clone()
                                    switch(effect:getType(),
                                        {
                                            ["属性变化"] = function()
                                                if hitType == "hurt" then
                                                    local effectObject = role
                                                    effect:setOwner(role)
                                                    if effect:getTarget() == "自己" then
                                                        effect:setObject(role)
                                                    else
                                                        effect:setObject(target)
                                                        effectObject = target
                                                    end
                                                    
                                                    if effect.id == "HF" and type(role:getFlag("长生诀战斗恢复")) == "table"  then
                                                        local tb = role:getFlag("长生诀战斗恢复")
                                                        self:printFightStatus(tb.text,role:getName(),switch(effect:getTarget(), {["自己"] = role, ["目标"] = target}):getName())
                                                        role:setFlag("长生诀战斗恢复", nil)
                                                    end
                                                    
                                                    local doEffectObjectUIInfo = info:getEffectObjectUIInfo()[1]
                                                    if MapIsEmpty(doEffectObjectUIInfo) == false then
                                                        local damage = math.floor(doEffectObjectUIInfo:getValue())
                                                        local popValue = math.floor(doEffectObjectUIInfo:getPopValue())
                                                        
                                                        -- 根据当前攻击次数, 获得该次显示的伤害
                                                        if effectWeightArray[currHitTime] then
                                                            damage = math.floor(damage * effectWeightArray[currHitTime] / 100)
                                                            popValue = math.floor(popValue * effectWeightArray[currHitTime] / 100)
                                                        end

                                                        local text = doEffectObjectUIInfo:getPopText()
                                                        if not text then
                                                            text = effect:getRoleTopPopDesc(doEffectObjectUIInfo:getAttrId(), popValue)
                                                        end

                                                        self:rolePopNumber(effectObject, text, doEffectObjectUIInfo:getPopTextColor())

                                                        local doEffectOwnerUIInfos = info:getEffectOwnerUIInfo()

                                                        if MapIsEmpty(doEffectOwnerUIInfos) == false then
                                                            for i = 1, #doEffectOwnerUIInfos, 1 do
                                                                local value = doEffectOwnerUIInfos[i]:getPopValue()
                                                                if effectWeightArray[currHitTime] then
                                                                    value = value * effectWeightArray[currHitTime] / 100
                                                                end

                                                                local text = doEffectOwnerUIInfos[i]:getPopText()
                                                                if not text then
                                                                    text = effect:getRoleTopPopDesc(doEffectOwnerUIInfos[i]:getAttrId(),  math.floor(value))
                                                                end

                                                                self:rolePopNumber(role, text, doEffectOwnerUIInfos[i]:getPopTextColor())
                                                            end
                                                        end
                                                        
                                                        -- 输出文本
                                                        self:printFightStatus(effect:getDoDesc(), role:getName(), effectObject:getName(), nil, nil, nil,
                                                        {
                                                            ["$arg2"] = math.abs(damage),
                                                        })
                                                    end     
                                                elseif hitType == "dodge" then
                                                    if effect:getTarget() == "目标" then
                                                        self:rolePopNumber(target, "闪避")
                                                    end
                                                elseif hitType == "parry" then
                                                    if effect:getTarget() == "目标" then
                                                        if activeZhaoType == "攻击" then
                                                            self:rolePopNumber(target, "招架")
                                                        else
                                                            self:rolePopNumber(target, "闪避")
                                                        end
                                                    end
                                                end
                                            end,
                                            

                                            ["汲取"] = function()
                                                effect:setOwner(role)
                                                local effectObject = role
                                                if effect:getTarget() == "自己" then
                                                    effect:setObject(role)
                                                else
                                                    effect:setObject(target)
                                                    effectObject = target
                                                end

                                                local targetReduceValue,roleAddValue = 0, 0

                                                local doEffectObjectUIInfo = info:getEffectObjectUIInfo()[1]
                                                if MapIsEmpty(doEffectObjectUIInfo) == false then
                                                    targetReduceValue = math.floor(doEffectObjectUIInfo:getValue())
                                                    
                                                    if effectWeightArray[currHitTime] then
                                                        targetReduceValue = targetReduceValue * effectWeightArray[currHitTime] / 100
                                                    end

                                                    self:rolePopNumber(effectObject,"-"..targetReduceValue,doEffectObjectUIInfo:getPopTextColor())
                                                end

                                                local doEffectOwnerUIInfo = info:getEffectOwnerUIInfo()[1]
                                                if MapIsEmpty(doEffectOwnerUIInfo) == false then
                                                    roleAddValue = math.floor(doEffectOwnerUIInfo:getValue())
                                                
                                                    if effectWeightArray[currHitTime] then
                                                        roleAddValue = roleAddValue * effectWeightArray[currHitTime] / 100
                                                    end

                                                    self:rolePopNumber(role, "+"..roleAddValue, doEffectOwnerUIInfo:getPopTextColor()) 
                                                end
 
                                                -- 输出文本
                                                self:printFightStatus(effect:getDoDesc(), role:getName(), effectObject:getName(), nil, nil, nil,
                                                {
                                                    ["$arg2"] = targetReduceValue,
                                                    ["$arg3"] = roleAddValue,
                                                })
                                            end
                                        })
                                end
                                
                                -- PopText("hitType = " .. hitType)
                                if animIndex == #anim.attackAnim and hitIndex == #hits and target:isDead() then
                                    -- self:roleDie(target, "chest")
                                elseif animIndex == #anim.attackAnim and hitIndex == #hits and role:isDead() then
                                    -- self:roleDie(role, "chest")
                                else
                                    if activeZhaoType == "攻击" then
                                        if hitType == "hurt" then
                                            local hurtZhao = target:getRandomHurtZhaoByPosition(hitPos)
                                            self:roleMoveBy(target, duration / 30, hisOffset)
                                            
                                            if anim.defendAnimArray == nil or anim.defendAnimArray[animIndex] == nil then
                                                self:rolePlayAnim(target, Helper:getDef(target:getHurtAnimName(hitPos), hurtZhao.anim), nil, nil, 10 / duration)
                                            end
                                        elseif hitType == "parry" then
                                            local parryZhao = target:getRandomParryZhaoByPosition(hitPos)
                                            self:roleMoveBy(target, duration / 30, hisOffset)
                                            self:rolePlayAnim(target, Helper:getDef(target:getParryAnimName(hitPos), parryZhao.anim), nil, nil, 10 / duration)
                                            
                                            local targetParrySkill = target:getCurrParrySkill()
                                            local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
                                            self:printFightStatus(targetParryZhao.action, role:getName(), target:getName(), role:getCurrWeaponName(), target:getCurrWeaponName(), hitPosName)
                                        elseif hitType == "dodge" then
                                            local dodgeZhao = target:getRandomDodgeZhaoByPosition(hitPos)
                                            self:roleMoveBy(target, duration / 30, hisOffset)
                                            self:rolePlayAnim(target, Helper:getDef(target:getDodgeAnimName(hitPos), dodgeZhao.anim), nil, nil, 10 / duration)
                                            
                                            local targetDodgeSkill = target:getCurrDodgeSkill()
                                            local targetDodgeZhao = targetDodgeSkill:getRandomDodgeSkill(target:getRole())
                                            self:printFightStatus(targetDodgeZhao.action, role:getName(), target:getName(), role:getCurrWeaponName(), target:getCurrWeaponName(), hitPosName)
                                        end
                                    end
                                end
                            end)
                            
                            -- 归位
                            if hitIndex == #hits then
                                -- 死亡动画 add by TangJian 2017/03/16 16:46:09
                                if animIndex == #anim.attackAnim and role:isDead() and target:isDead() then
                                    self:delayFunc((totalDuration + (hitFrame - 1) + duration) / 30, function()
                                        self:roleDie(role, "chest")
                                        self:roleDie(target, "chest")
                                    end)
                                    return
                                elseif animIndex == #anim.attackAnim and target:isDead() then
                                    self:delayFunc((totalDuration + (hitFrame - 1) + duration) / 30, function()
                                        self:roleDie(target, "chest")
                                    end)
                                elseif animIndex == #anim.attackAnim and role:isDead() then
                                    --@desc 播放胜利动画
                                    self:delayFunc((totalDuration + (hitFrame - 1) + duration) / 30, function()
                                        self:roleDie(role, "chest")
                                        self:playWinAnim(target)
                                    end)
                                    return
                                else
                                self:delayFunc((totalDuration + (hitFrame - 1) + duration) / 30, function()
                                    self:roleMoveToOrigin(target, role)
                                end)
                                end
                                totalDuration = totalDuration + duration / 30
                            end
                        end
                    end
                end
                -- 攻击完成
                totalDuration = totalDuration + attackAnim.duration
                
                if animIndex == #anim.attackAnim then
                    if needAftJump then
                        -- 退回去
                        self:delayFunc(totalDuration / 30, function()
                            self:roleAttackEndMoveToOrigin(role, target, true, jumpDuration / 30)
                        end)
                        totalDuration = totalDuration + jumpDuration
                    else
                        -- 退回去
                        self:delayFunc(totalDuration / 30, function()
                            self:rolePlayAnim(role, role:getStandAnimName(), nil, nil, nil, 5 / 30)
                        end)
                        totalDuration = totalDuration + jumpDuration
                    end

                    --@desc 胜利动画应该在回跳之后再播放
                    if target:isDead() then
                        --@desc 播放胜利动画
                        self:delayFunc((totalDuration + 5) / 30, function()
                            self:playWinAnim(role)
                        end)
                        return
                    end
                end
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 主动招式
function FightLayer:roleActiveZhao(role, target, activeZhao, hitType)
    switch(activeZhao:getType(),
        {
            ["攻击"] = function()
                self:playRoleActiveZhaoAnim(role, target, activeZhao, hitType, "攻击")
            -- self:playRoleActiveZhaoAnim(role, target, activeZhao, hitType, "释放")
            end,
            ["攻击不跳回"] = function()
                self:playRoleActiveZhaoAnim(role, target, activeZhao, hitType, "攻击不跳回")
            end,
            
            ["释放"] = function()
                self:playRoleActiveZhaoAnim(role, target, activeZhao, hitType, "释放")
            end
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/10 11:11:51
-- @desc 效果开始
function FightLayer:roleBeginEffect(role, effect, immediateEffectUIInfo)
    local abs = function(number)
        if number == nil then
            number = 0
        end
        return math.abs(number)
    end
    
    local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())
    
    -- 显示数值
    switch(effect:getType(),
        {
            ["属性变化"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()

                if MapIsEmpty(immediateEffectUIInfo) == false then
                    local objectInfo = immediateEffectUIInfo:getEffectObjectUIInfo()[1]
                    if MapIsEmpty(objectInfo) == false then
                        arg2 = objectInfo:getValue()
                    end
                end

                arg2 = math.floor(arg2)

                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["属性增益"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["控制"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })

                self:delayFunc(0.1, function()
                    animRole:setStatusText(role:getCurrState())
                end)
            end,
            
            ["护盾"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
                self._rolesEffectChangeFM:addFunction(function()
                    local colorName = effect:getArg2()
                    animRole:setShieldAnimVisible(role:haveShield(), colorName)
                    return true
                end)
            end,
            
            ["打掉兵器"] = function()
            end,

            ["净化"] = function()
               local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["解控"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
                self:rolePopNumber(role,math.floor(effect:getFinalArg2()),effect:getNumberColor())
            end,

            ["免疫控制"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["截脉"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["禁锢"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["抗毒"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["遗忘"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["闪耀"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["闪烁"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,  
            ["内省"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["投掷"] = function()
                self._rolesEffectChangeFM:addFunction(function()                    
                    self:delayFunc(2/6, function()
                        self:roleInitAnim(effect:getOwner():getId())
                    end)
                    return true
                end)
            end,
            ["窃取"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["凝血"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["汲取"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["吸血"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["反震"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["内伤"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["真伤"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = math.ceil(abs(arg2)),
                    })
            end,
            ["强招架"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["卸力"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["破招"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["平衡"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["架御"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["架势"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["抗增益"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["抗减益"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["延时生效"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["反噬"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["修武"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["延宕"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["真罡"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["致盲"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["拳脚武器切换"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 

            ["被动命中触发"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["伤害转气血"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end, 
            
            ["可取回缴械"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })

                self._rolesEffectChangeFM:addFunction(function()                    
                    self:delayFunc(1/3, function()
                        self:roleInitAnim(role:getId())
                    end)
                    return true
                end)
            end,

            ["类型抵抗"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,

            ["追加伤害"] = function()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["无法攻击"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end, 

            ["属性叠加"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end, 

            ["拳脚经脉增强"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end, 

            ["无法易武"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end, 
            ["冷却变化"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
            ["使用主动技能"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end, 
            ["单次伤害上限"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end, 
            ["记录承受伤害"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
            ["主动碎盾"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
            ["指定抵抗"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
            ["经脉天赋修正"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
            ["伤害抗性修正"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
			["反弹"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
			["恢复修正"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
			["加权随机触发"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
			["效果判断触发"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
			["必中"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
			["受伤回血"] = function()
                self:printFightStatus(effect:getBeginDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
        })
    
    
    self:updateRoleBuff()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/10 11:12:06
-- @desc 效果结束
function FightLayer:roleEndEffect(role, effect)
    local abs = function(number)
        if number == nil then
            number = 0
        end
        return math.abs(number)
    end
    
    local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())
    
    -- 显示数值
    switch(effect:getType(),
        {
            ["属性变化"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["属性增益"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["控制"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
                
                self:delayFunc(0.1, function()
                    animRole:setStatusText(role:getCurrState())
                end)
            end,
            
            ["护盾"] = function()
                self._rolesEffectChangeFM:addFunction(function()
                    local colorName = effect:getArg2()
                    animRole:setShieldAnimVisible(role:haveShield(), colorName)
                    return true
                end)
            end,

            ["净化"] = function()
               local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["解控"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,

            ["免疫控制"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["截脉"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["禁锢"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["抗毒"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["遗忘"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["闪耀"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["闪烁"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,  
            ["内省"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["窃取"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["凝血"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["汲取"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["吸血"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["反震"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["内伤"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["真伤"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = math.ceil(abs(arg2)),
                    })
            end,
            ["强招架"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["卸力"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["破招"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["平衡"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["架御"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["架势"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["抗增益"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["抗减益"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["延时生效"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["反噬"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["修武"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["延宕"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["真罡"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["致盲"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["被动命中触发"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["伤害转气血"] = function()
                local huiFuQi = effect:getPopText()

                self:rolePopNumber(role, "+" .. huiFuQi, cc.c4b(51, 153, 51, 255))

                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg2"] = huiFuQi,
                    })
            end, 
            
            ["可取回缴械"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
                    
                self._rolesEffectChangeFM:addFunction(function()                    
                    self:delayFunc(1/6, function()
                        self:roleInitAnim(role:getId())
                    end)
                    return true
                end)
            end,

            ["类型抵抗"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,

            ["追加伤害"] = function()
                local damage = effect:getEffectExtraValue()
                local qiRate = effect:getFinalArg1()
                local maxDamage = effect:getFinalArg2()

                if damage > maxDamage then
                    damage = maxDamage
                end

                local qi = math.floor(damage * qiRate)

                self:rolePopNumber(role, "-" .. tostring(qi), effect:getNumberColor())

                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg2"] = qi,
                    })
            end,
            
            ["无法攻击"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["属性叠加"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end, 

            ["拳脚经脉增强"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["无法易武"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["冷却变化"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
            
            ["使用主动技能"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["单次伤害上限"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["记录承受伤害"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["主动碎盾"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
            
            ["指定抵抗"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["经脉天赋修正"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["伤害抗性修正"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["反弹"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

			["加权随机触发"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

			["效果判断触发"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

			["恢复修正"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

			["必中"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

			["受伤回血"] = function()
                self:printFightStatus(effect:getEndDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,
        })
    
    
    self:updateRoleBuff()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/28 16:56:11
-- @desc
function FightLayer:roleDoEffect(role, effect, immediateEffectUIInfo)
    local abs = function(number)
        if number == nil then
            number = 0
        end
        return math.abs(number)
    end
    
    local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(role:getTeamId(), role:getInTeamId())
    
	local effectType = effect:getType()

    -- 显示数值
    switch(effectType,
        {
            ["属性变化"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()

                if MapIsEmpty(immediateEffectUIInfo) == false then
                    local objectInfo = immediateEffectUIInfo:getEffectObjectUIInfo()[1]
                    if MapIsEmpty(objectInfo) == false then
                        
                        arg2 = objectInfo:getValue()

                        arg2 = math.floor(arg2)
                    
                        local popValue = math.floor(objectInfo:getPopValue())                    

                        local text = objectInfo:getPopText()

                        if not text then
                            text = effect:getRoleTopPopDesc(objectInfo:getAttrId(), popValue)
                        end

                        self:rolePopNumber(role, text, objectInfo:getPopTextColor())
                    end

                    local doEffectOwnerUIInfos = immediateEffectUIInfo:getEffectOwnerUIInfo()

                    if MapIsEmpty(doEffectOwnerUIInfos) == false then
                        for i = 1, #doEffectOwnerUIInfos, 1 do
                            local value = doEffectOwnerUIInfos[i]:getPopValue()
                        
                            local text = doEffectOwnerUIInfos[i]:getPopText()
                            if not text then
                                text = effect:getRoleTopPopDesc(doEffectOwnerUIInfos[i]:getAttrId(),  math.floor(value))
                            end

                            self:rolePopNumber(effect:getOwner(), text, doEffectOwnerUIInfos[i]:getPopTextColor())
                        end
                    end
                else
                    if effect:getOwner() and effect:getObject() then
                        if arg1 == "qi" and arg2 < 0 and effect:getFinalDuration() == 0 then
                            if effect:getFinalArg3() == 5 then
                                local finalFactor = self.fight:calAutoDamageFinalFactor(effect:getOwner(),effect:getObject())

                                local damageAttrModifValueFactor = effect:getOwner():getRole():getDamageAttrModifValueFactor(effect:getActiveZhaoAtkDamageClass(),role:getRole())

                                arg2 = arg2 * finalFactor * damageAttrModifValueFactor
                            elseif effect:getFinalArg3() == 1 then
                                local finalFactor = self.fight:calActiveDamageFinalFactor(effect:getOwner(),effect:getObject())

                                local damageAttrModifValueFactor = effect:getOwner():getRole():getDamageAttrModifValueFactor(effect:getActiveZhaoAtkDamageClass(),role:getRole())

                                arg2 = arg2 * finalFactor * damageAttrModifValueFactor
                            else
                                local finalFactor = self.fight:calActiveDamageFinalFactor(effect:getOwner(),effect:getObject())
                                arg2 = arg2 * finalFactor
                            end
                        end
                    end

                    arg2 = math.floor(arg2)

                    if arg1 == "qi" then
                        if arg2 < 0 and effect:getTarget() == "目标" then
                            local text = effect:getRoleTopPopDesc(arg1, arg2)
                            self:rolePopNumber(role, text, effect:getNumberColor())

                            --自己回血
                            if effect:getOwner():isSuckBlood() and arg2 < 0 then
                                local roleEffectMap = effect:getOwner():getEffectMap()
                                for k,effect in pairs(roleEffectMap) do
                                    if effect:getType() == "吸血" then
                                        local param1 ,param2 = effect:getArg1(), effect:getFinalArg2()
                                        local SuckBloodValue = math.floor(math.abs(arg2*param2))
                                        self:rolePopNumber(effect:getOwner(),"+"..SuckBloodValue,effect:getNumberColor())
                                    end
                                end
                            end
                        else
                            if arg2 > 0 then
                                local huiFuNum = role:getHuiFuRatio("qi",effectType)
                                arg2 = math.floor(arg2 * huiFuNum)
                            end

                            -- 头上弹出文本
                            local text = effect:getRoleTopPopDesc(arg1, arg2)
                            self:rolePopNumber(role, text, effect:getNumberColor())
                        end
                    elseif arg1 == "neili" then
                        if arg2 > 0 then
                            local huiFuNum = role:getHuiFuRatio("neili",effectType)
                            arg2 = math.floor(arg2 * huiFuNum)
                        end
                        -- 头上弹出文本
                        local text = effect:getRoleTopPopDesc(arg1, arg2)
                        self:rolePopNumber(role, text, effect:getNumberColor()) 
                    else
                        local text = effect:getRoleTopPopDesc(arg1, arg2)
                        self:rolePopNumber(role, text, effect:getNumberColor())
                    end
                end

                -- 输出文本
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["属性增益"] = function()
            
            end,
            
            ["控制"] = function()
            
            end,
            
            ["护盾"] = function()
                self._rolesEffectChangeFM:addFunction(function()
                    local colorName = effect:getArg2()
                    animRole:setShieldAnimVisible(role:haveShield(), colorName)
                    return true
                end)
            end,
            ["净化"] = function()
               local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["解控"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,

            ["免疫控制"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["截脉"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["禁锢"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["抗毒"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["遗忘"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["闪耀"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["闪烁"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,  
            ["内省"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["窃取"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["凝血"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["汲取"] = function()
                local arg1, arg2, arg3 = effect:getArg1(), effect:getFinalArg2(), effect:getFinalArg3()
                arg3 = Helper:getDef(arg3, 0)
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                        ["$arg3"] = abs(arg2 * arg3),
                    })
            end,
            ["吸血"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["反震"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["内伤"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["真伤"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = math.ceil(abs(arg2)),
                    })
            end,
            ["强招架"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["卸力"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["破招"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["平衡"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["架御"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["架势"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["抗增益"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["抗减益"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["延时生效"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["反噬"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["修武"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["延宕"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end, 
            ["真罡"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["致盲"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["拳脚武器切换"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            
            ["被动命中触发"] = function()
                local arg1, arg2 = effect:getArg1(), effect:getFinalArg2()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
                    {
                        ["$arg1"] = arg1,
                        ["$arg2"] = abs(arg2),
                    })
            end,
            ["伤害转气血"] = function()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["伤害转持续自伤"] = function()
                local damageToHurtValue = role:getAttr("damageToHurt")
                local factor = effect:getFinalArg1()
                local value = Helper:mathFloor(damageToHurtValue * factor)
                local text = effect:getRoleTopPopDesc("qi", -value)

                self:rolePopNumber(role, text, effect:getNumberColor())
                
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["无法攻击"] = function()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

            ["伤害抗性修正"] = function()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

			["反弹"] = function()
				if MapIsEmpty(immediateEffectUIInfo) == false then
                    local objectInfo = immediateEffectUIInfo:getEffectObjectUIInfo()[1]

                    if MapIsEmpty(objectInfo) == false then
						local value = objectInfo:getValue()

						self:rolePopNumber(role, objectInfo:getPopValue(), objectInfo:getPopTextColor())

						self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
							{
								["$arg1"] = effect:getArg1(),
								["$arg2"] = abs(value),
							}
						)
					end
				end
            end,

			["加权随机触发"] = function()
                self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,{})
            end,

			["受伤回血"] = function()
				if MapIsEmpty(immediateEffectUIInfo) == false then
                    local objectInfo = immediateEffectUIInfo:getEffectObjectUIInfo()[1]

                    if MapIsEmpty(objectInfo) == false then
						local value = objectInfo:getValue()

						self:rolePopNumber(role, "+"..objectInfo:getPopValue(), objectInfo:getPopTextColor())

						self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil,
							{
								["$arg1"] = effect:getArg1(),
								["$arg2"] = abs(value),
							}
						)
					end
				end
            end,
        })
    
    
    self:updateRoleBuff()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 11:56:23
-- @desc 播放随机受伤音效
function FightLayer:playRandomHurtSound(sex)
    local fightSound = require("app.models.fight.FightSounds")
    fightSound:playRandomHurtSound(sex)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 11:56:57
-- @desc 播放随机死亡音效
function FightLayer:playRandomDieSound(sex)
    local fightSound = require("app.models.fight.FightSounds")
    fightSound:playRandomDieSound(sex)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 14:26:12
-- @desc 播放随机击中音效
function FightLayer:playRandomHitSound(type1, type2)
    local fightSound = require("app.models.fight.FightSounds")
    fightSound:playRandomHitSound(type1, type2)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 14:24:49
-- @desc 播放随招架音效
function FightLayer:playRandomParrySound(type1, type2)
    local fightSound = require("app.models.fight.FightSounds")
    fightSound:playRandomParrySound(type1, type2)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 14:26:44
-- @desc 播放随机闪避音效
function FightLayer:playRandomDodgeSound(type1, type2)
    local fightSound = require("app.models.fight.FightSounds")
    fightSound:playRandomDodgeSound(type1, type2)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @author TangJian --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @time 2017/05/04 20:21:51 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @desc 经脉印记 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 20:22:19
-- @desc 经脉印记激活
function FightLayer:activeJingMaiYinJi(id, name, desc,teamId)
    if IS_OPEN_PVP_JINGMAI == true then
        self:callUIMemFunc("playJinMaiYinJiActiveAnim", id, name,teamId)    
        if desc then
            self:callUIMemFunc("print", desc)
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 20:22:19
-- @desc 经脉印记反激活
function FightLayer:inactiveJingMaiYinJi(id, name, desc)
    if IS_OPEN_PVP_JINGMAI == true then
        self:callUIMemFunc("print", desc)
    end
end

-- @desc 打飞打断动画播放
--播放打飞兵器动画
function FightLayer:playjifeiWeaponAnim(role, target, zhaoData,targetWeaponType,targetWeaponType2)
    -- self:roleHit(role, target, zhao)
    -- print("99999999999999999999999999999999",weapontype)
     -- print(target:getName().."招架了"..role:getName().."的攻击")
    -- 自己
    local roleName = role:getName()
    local roleWeaponName = role:getCurrWeaponName()
    local roleAttackSkill = role:getCurrAttackSkill()
    local roleAttackZhao = role:getCurrAttackZhao()
    local roleAttackAction = roleAttackZhao.action
    local roleDoubleAttackSkill = role:getCurrDoubleAttackSkill()
    local roleDoubleAttackZhao = role:getCurrDoubleAttackZhao()

    -- 攻击部位名字
    local hitPosName = zhaoData.hitPosName

    -- 对手
    local targetName = target:getName()
    local targetAttackMethod = target:getAttackMethod()
    local targetWeaponName = target:getCurrWeaponName()
    local targetParrySkill = target:getCurrParrySkill()
    local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())

    -- 攻击情况
    if roleDoubleAttackZhao then
        if PRINT_MODE == 1 then
            print("互备")
        end

        -- 攻击情况
        self:printFightStatus(roleAttackAction, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        -- 招架成功
        local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
        self:printFightStatus(targetParryZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)

        -- 攻击情况
        self:printFightStatus(roleDoubleAttackZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)

        -- 招架成功
        local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
        self:printFightStatus(targetParryZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
    else
        self:printFightStatus(roleAttackAction, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        -- 招架成功
        local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
        self:printFightStatus(targetParryZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
    end

    -- 动画效果
    self:playRoleAttackAnim(role, target, function(eventName, ...)
        if eventName == "attack" then
            local hitPos, isLastHit, animIndex = ...            

            -- 播放音效 add by TangJian 2016/11/07 14:28:21
            self:playRandomParrySound(role:getCurrWeaponType(), role:getCurrWeaponType2())

            -- 显示招架文字 add by TangJian 2016/11/26 15:17:42
            self:rolePopNumber(target, "招架")

            local hitPos = ...
            local zhao = target:getRandomParryZhaoByPosition(hitPos)
            local zhaoAnimName = targetParrySkill:getParryAnimNameWithAttackMethodAndHitPos(targetAttackMethod, hitPos)
            self:roleMoveBy(target, 10 / 30, zhao.offset)
            self:rolePlayAnim(target, Helper:getDef(target:getParryAnimName(hitPos), zhaoAnimName), nil, nil, 1)

            if isLastHit then
            print("动画效果动画效果targetWeaponType=",targetWeaponType,"targetWeaponType2 = ",targetWeaponType2)
            -- self:rolePlayAnim(target, "c-flyknife", 0, 20, 1)
                if targetWeaponType == "刀" then
                    self:rolePlayAnim(target, "c-flyknife", 0, 20, 1)
                elseif targetWeaponType == "鞭" then
                    self:rolePlayAnim(target, "c-flybian", 0, 20, 1)
                elseif targetWeaponType == "剑" then
                    self:rolePlayAnim(target, "c-flysword", 0, 20, 1)
                elseif targetWeaponType == "棍" then
                    self:rolePlayAnim(target, "c-flygun", 0, 20, 1)
                elseif targetWeaponType == "双持" then
                    self:rolePlayAnim(target, "c-flysc", 0, 20, 1)
                elseif targetWeaponType == "乐器" then
                    if targetWeaponType2 == Item.ITEM_TYPE.WEAPON_SUBTYPE.GUQIN then
                        self:rolePlayAnim(target, "c-flyqin", 0, 20, 1)
                    elseif targetWeaponType2 == Item.ITEM_TYPE.WEAPON_SUBTYPE.DIZI then
                        self:rolePlayAnim(target, "c-flyflute", 0, 20, 1)
                    end
                elseif targetWeaponType == "暗器" then
                    self:rolePlayAnim(target, "c-flyanqi", 0, 20, 1)
                end
                
                self:delayFunc(2/3, function()
                    self:roleInitAnim(target:getId())
                end)
                
            end
        elseif eventName == "attackEnd" then
            -- self:roleInitAnim(target:getId())

            self:roleAttackEndMoveToOrigin(role, target, zhaoData.isWaitingTili)
            self:roleMoveToOrigin(target, role)
        end
    end)
end

--播放打断兵器动画
function FightLayer:playDaduanWeaponAnim(role, target, zhaoData,targetWeaponType,targetWeaponType2)
    local roleName = role:getName()
    local roleWeaponName = role:getCurrWeaponName()
    local roleAttackSkill = role:getCurrAttackSkill()
    local roleAttackZhao = role:getCurrAttackZhao()
    local roleAttackAction = roleAttackZhao.action
    local roleDoubleAttackSkill = role:getCurrDoubleAttackSkill()
    local roleDoubleAttackZhao = role:getCurrDoubleAttackZhao()

    -- 攻击部位名字
    local hitPosName = zhaoData.hitPosName

    -- 对手
    local targetName = target:getName()
    local targetAttackMethod = target:getAttackMethod()
    local targetWeaponName = target:getCurrWeaponName()
    local targetParrySkill = target:getCurrParrySkill()
    local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())

    -- 攻击情况
    if roleDoubleAttackZhao then
        if PRINT_MODE == 1 then
            print("互备")
        end

        -- 攻击情况
        self:printFightStatus(roleAttackAction, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        -- 招架成功
        local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
        self:printFightStatus(targetParryZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)

        -- 攻击情况
        self:printFightStatus(roleDoubleAttackZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)

        -- 招架成功
        local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
        self:printFightStatus(targetParryZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
    else
        self:printFightStatus(roleAttackAction, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
        -- 招架成功
        local targetParryZhao = targetParrySkill:getRandomParrySkill(target:getRole())
        self:printFightStatus(targetParryZhao.action, roleName, targetName, roleWeaponName, targetWeaponName, hitPosName)
    end

    -- 动画效果
    self:playRoleAttackAnim(role, target, function(eventName, ...)
        if eventName == "attack" then
            local hitPos, isLastHit, animIndex = ...            

            -- 播放音效 add by TangJian 2016/11/07 14:28:21
            self:playRandomParrySound(role:getCurrWeaponType(), role:getCurrWeaponType2())

            -- 显示招架文字 add by TangJian 2016/11/26 15:17:42
            self:rolePopNumber(target, "招架")

            local hitPos = ...
            local zhao = target:getRandomParryZhaoByPosition(hitPos)
            local zhaoAnimName = targetParrySkill:getParryAnimNameWithAttackMethodAndHitPos(targetAttackMethod, hitPos)
            self:roleMoveBy(target, 10 / 30, zhao.offset)
            self:rolePlayAnim(target, Helper:getDef(target:getParryAnimName(hitPos), zhaoAnimName), nil, nil, 1)

            if isLastHit then
            print("动画效果动画效果targetWeaponType=",targetWeaponType,"targetWeaponType2 = ",targetWeaponType2)
               if targetWeaponType == "刀" then
                    self:rolePlayAnim(target, "c-attknife", 0, 20, 1)
                elseif targetWeaponType == "鞭" then
                    self:rolePlayAnim(target, "c-attbian", 0, 20, 1)
                elseif targetWeaponType == "剑" then
                    self:rolePlayAnim(target, "c-attsword", 0, 20, 1)
                elseif targetWeaponType == "棍" then
                    self:rolePlayAnim(target, "c-attgun", 0, 20, 1)
                elseif targetWeaponType == "双持" then
                    self:rolePlayAnim(target, "c-dessc", 0, 12, 1)
                elseif targetWeaponType == "乐器" then
                    if targetWeaponType2 == Item.ITEM_TYPE.WEAPON_SUBTYPE.GUQIN then
                        self:rolePlayAnim(target, "c-dessqin", 0, 20, 1)
                    elseif targetWeaponType2 == Item.ITEM_TYPE.WEAPON_SUBTYPE.DIZI then
                        self:rolePlayAnim(target, "c-dessflute", 0, 12, 1)
                    end
                elseif targetWeaponType == "暗器" then
                    self:rolePlayAnim(target, "c-desanqi", 0, 20, 1)
                end     
                
                self:delayFunc(2/3, function()
                    self:roleInitAnim(target:getId())
                end)
                
            end
        elseif eventName == "attackEnd" then
            -- self:roleInitAnim(target:getId())

            self:roleAttackEndMoveToOrigin(role, target, zhaoData.isWaitingTili)
            self:roleMoveToOrigin(target, role)
        end
    end)
end

--播放切换兵器动画
function FightLayer:playchangeWeaponAnim(role, withoutAnim)
    local role = self.fight:getRole(role:getId())
    if role then
        local roleTeamId = role:getTeamId()
        local roleInTeamId = role:getInTeamId()

        local animRole = self._animFightLayer:getRoleByTeamIdAndInTeamId(roleTeamId, roleInTeamId)
        animRole:setVisible(true)

        self:initRoleWeaponImage(role)

        if not withoutAnim then
            self:delayFunc(1/3, function()
                       animRole.anim:playAnim("changeweapon")
                   end)
        end
    end
end

--播放缴械兵器动画(打掉兵器效果)
function FightLayer:playJiaoXieEffectAnim(role, effect)
    self._rolesEffectChangeFM:addFunction(function()
        self:roleInitAnim(role:getId())
        self:printFightStatus(effect:getDoDesc(), effect:getOwner():getName(), role:getName(), nil, nil, nil, {})
        return true
    end)
end


function FightLayer:getCurrWeaponimage(subType)
    if subType == nil then
        return ""
    end
    local weaponAttachmentName = switch(subType,
        {
            
            ["jianfa1"] = "images/weapon/sword1",
            ["jianfa2"] = "kk/duanjian",
            ["jianfa3"] = "kk/ruanjian",
            ["jianfa4"] = "kk/zhongjian",
            ["jianfa5"] = "kk/cijian",
            ["daofa1"] = "images/weapon/knife1",
            ["daofa2"] = "kk/duandao",
            ["daofa3"] = "kk/wandao",
            ["daofa4"] = "kk/dahuandao",
            ["daofa5"] = "kk/shuangrenfu",
            ["gunfa1"] = "images/weapon/gun1",
            ["gunfa2"] = "kk/changqiang",
            ["gunfa3"] = "kk/sanjiegun/sanjiegun",
            ["gunfa4"] = "kk/langyabang",
            ["gunfa5"] = "kk/zhanji",
            ["bianfa1"] = "images/weapon/bian1",
            ["bianfa2"] = "kk/ruanbian",
            ["bianfa3"] = "kk/jiujiebian",
            ["bianfa4"] = "kk/ganzibian",
            ["bianfa5"] = "kk/lianjia",
            ["shuangchi1"] = "kk/shuanghuanwuqi_1",
            ["shuangchi2"] = "kk/duijian",
            ["shuangchi3"] = "kk/shuanggou",
            ["anqi1"] = "kk/anqi/zhuixing",
            ["anqi2"] = "kk/anqi/yuanxing",
            ["anqi3"] = "kk/anqi/zhenxing",
            ["qinfa1"] = "kk/jichuqinfa/jichuqinfa_qin2",
            ["qinfa2"] = "kk/yueqi/Flute",
            ["quanjiao"] = "",
            default = function()
                return ""
            end

        })
    return weaponAttachmentName
end

function FightLayer:refreshRoleEffectText(role)
    local effectText = {"",""}
    local effectCount = 0

    local saveDamage = Helper:mathFloor(role:getAttr("saveDamage"))
    
    if saveDamage > 0 or role:isSaveDamage() == true then
        local text = "凝伤 "..saveDamage
        effectCount = effectCount + 1
        effectText[effectCount] = text
    end

    local damgae = Helper:mathFloor(role:getAttr("damageToHurt"))
    if damgae > 0 then
        local text = "业果 "..damgae
        effectCount = effectCount + 1
        effectText[effectCount] = text
    end

    local direction = role:getDirection()

    if direction == "left" then
        self:callUIMemFunc("refreshLeftRoleEffectText", effectText)
    elseif direction == "right" then 
        self:callUIMemFunc("refreshRightRoleEffectText", effectText)
    end
end

Helper:classDefNodeGetInstance(FightLayer)
return FightLayer
000000000000000
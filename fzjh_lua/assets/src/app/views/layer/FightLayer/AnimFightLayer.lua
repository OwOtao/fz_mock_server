local Helper = require("app.Helper")
local Skill = require("app.models.skill.Skill")
local Resource = require("app.Resource")
local RoleStatePanelActiveZhaoReadyItem = require("app.views.ui.FightUI.RoleStatePanelActiveZhaoReadyItem")
local SpineAnimationState = require("third.animator.SpineAnimator.SpineAnimationState")
local AnimFightLayer = class("AnimFightLayer", ccui.Widget)

local function ___log(msg)
    print(msg)
end

local ZhanSan =
    {
        name = "张三",
        family = "武当",
        exp = 30000,
        lv = 67,
        age = 24,
        force = 20,
        dex = 30,
        con = 30,
        int = 15,
        hp = 340,
        mp = 1000,
        maxMp = 1500,
        atk = 533,
        def = 843,
        hitRate = 945,
        dodge = 900,
        parry = 843,
        atkFactor = 100,
        dodgeFactor = 100,
        defFactor = 100,
        dmgFactor = 100,
        weaponType = "剑",
        skill =
        {
            unarmed = 100,
            sword = 100,
            force = 100,
            parry = 100,
            dodge = 100,
            literate = 100,
            cuff = 100
        },
        skillMap =
        {
            cuff = "paiyun"
        },
        skillPrepare =
        {
            cuff = "paiyun"
        }
    }

local LiSi =
    {
        name = "李四",
        family = "武当",
        exp = 30000,
        lv = 67,
        age = 24,
        force = 20,
        dex = 30,
        con = 30,
        int = 15,
        hp = 340,
        mp = 1000,
        maxMp = 1500,
        atk = 533,
        def = 843,
        hitRate = 945,
        dodge = 900,
        parry = 843,
        atkFactor = 100,
        dodgeFactor = 100,
        defFactor = 100,
        dmgFactor = 100,
        weaponType = "剑",
        skill =
        {
            unarmed = 100,
            sword = 100,
            force = 100,
            parry = 100,
            dodge = 100,
            literate = 100,
            cuff = 100
        },
        skillMap =
        {
            cuff = "paiyun"
        },
        skillPrepare =
        {
            cuff = "paiyun"
        }
    }

function AnimFightLayer:attack(me, he)

end

function AnimFightLayer:fight(me, he)
    local myExp = me.exp
    local myDodge = me.dodge
    local myHitRate = me.hitRate
    local myParry = me.parry
    local hisDodge = he.dodge
    local hisExp = he.exp
    local hisHitRate = he.hitRate
    local hisParry = he.parry
    
    if he.hp <= 0 or me.hp <= 0 then
        return
    end
    
    if math.random(myDodge + hisDodge) < myDodge then
        self:attack(me, he)
    else
        self:attack(he, me)
    end
end


-- 动画前后摇的攻速协调机制
-- 攻速影响普通攻击的全程时间，但播放的动画前后摇不会立即受到影响
-- |A攻击前摇开始 ----------------------  |B动画前摇------------- C 动画攻击瞬间 ------------------ 动画后摇结束|D ---------------------------攻击后摇结束|E
-- 攻速将从整体上影响 Tae ，例如1秒的Tae 在2倍攻速下 Tae = 2 Tae
-- 但是攻速会优先缩减 Tab和 Tde ，直到Tab Tde 为0 才会整体影响 Tbd的 时间
--
local Swordteck_HuashanJianfa =
    {
        name = "华山剑法",
        level = 100,
        weapon = "sword",
        idleZhao =
        {
            name = "苍松迎客",
            animName = "sword-stand01",
        },
        --自动攻击招式
        autoZhao =
        {
            {
                name = "第一式",
                readytime = 5,
                recovertime = 3,
                animName = "sword-attack01",
                frames = {
                    {name = "ready", duration = 5},
                    {
                        name = "attack",
                        duration = 2,
                        damage = {
                            {target = 1, dmg = 10, dmgfactor = 0.2, part = "chest"}
                        }
                    },
                    {name = "recover", duration = 1},
                }
            },
            {
                name = "第一式",
                animName = "sword-attack02",
                frames = {
                    {name = "ready", duration = 5},
                    {
                        name = "attack",
                        duration = 2,
                        damage = {
                            {target = 1, dmg = 10, dmgfactor = 0.2, part = "head"}
                        }
                    },
                    {name = "recover", duration = 1},
                }
            },
            {
                name = "第一式",
                animName = "barehand-attack01",
                frames = {
                    {name = "ready", duration = 4},
                    {
                        name = "attack",
                        duration = 2,
                        damage = {
                            {target = 1, dmg = 10, dmgfactor = 0.2, part = "head"}
                        }
                    },
                    {name = "recover", duration = 1},
                }
            },
            {
                name = "第一式",
                animName = "barehand-attack02",
                frames = {
                    {name = "ready", duration = 5},
                    {
                        name = "attack",
                        duration = 2,
                        damage = {
                            {target = 1, dmg = 10, dmgfactor = 0.2, part = "chest"}
                        }
                    },
                    {name = "recover", duration = 1},
                }
            },
        },
        
        --主动释放招式
        useZhao =
        {
            {
                --招式名字
                name = "亢龙有悔",
                
                --招式描述
                desc = "瞬间连打3次",
                
                --招式冷却时间
                cooldown = 3,
                
                --招式发动条件
                condition =
                {
                    manaNeed = 100
                },
                
                --招式触发动作
                onUse = function()
                
                end,
                
                
                --招式帧
                animName = "sword-attack01",
                frames = {
                    {name = "ready", duration = 1},
                    {
                        name = "attack",
                        duration = 6,
                        damage = {
                            {target = 1, dmg = 10, dmgfactor = 0.2, part = "head"}
                        }
                    },
                    {name = "recover", duration = 1},
                }
            },
            {
                name = "神龙摆尾",
                desc = "连打3次",
                condition =
                {
                    manaNeed = 100
                },
                --招式帧
                animName = "sword-attack02",
                frames = {
                    {name = "ready", duration = 1},
                    {
                        name = "attack",
                        duration = 6,
                        damage = {
                            {target = 1, dmg = 10, dmgfactor = 0.2, part = "head"}
                        }
                    },
                    {name = "recover", duration = 1},
                }
            }
        },
        
        
        --被动招式
        passiveZhao = {
        
        }
    }


local Player = class("Player", cc.Sprite)

function Player:create()
    local p = Player.new()
    p:init()
    return p
end


function Player:init()
    
    -- 设置角色状态
    self._action =
        {
            name = "idle",
            elapsed = 0,
            duration = 0
        }
    
    -- 名称
    self.name = "player"
    
    -- 所属阵营
    self.team = 0
    
    --当前状态 存活、死亡、无敌
    self.status = "alive"
    
    --当前动作
    self.action = "idle"
    
    --当前攻击对象 ,
    self.target = nil
    
    --基础战斗属性
    self.property = {
        hp = 100,
        grayHp = 100,
        maxHp = 100,
        mp = 1000,
        maxMp = 1000,
        atk = 5,
        def = 10,
        defType = "卸招",
        dodge = 0.5,
        accurate = 0.5,
        atkSpeed = 1.0,
    }
    
    --武功
    self.skill = {
            --空手招式
            barehand = nil,
            
            --剑法招式
            weapon = nil,
    }
    
    --装备
    self.equip = {
        weapon = {
            id = 1,
            type = "sword",
            name = "玄铁剑",
        },
        armor = nil,
    }
    
    
    --角色原点位置
    self.originPos = cc.p(0, 0)
    
    --角色面对的方向
    self.direction = DIRECTION_RIGHT
    
    --角色创建动画
    self.anim = Resource:getSkAnim("gongfu")
    self.anim:setPosition(cc.p(0, 0))
    
    self:addChild(self.anim, 1)
    
    --角色阴影
    self.shadowSprite = cc.Sprite:create("shadow.png")
    
    self:addChild(self.shadowSprite, 0)
    
    self.shadowSprite:setPosition(cc.p(0, 0))
    
    self:resetHpBar(100, 100, 100)
    
    self._currActiveZhaoReadyItem = nil
    
    self:initStatusText()
    
    -- 护盾测试 add by TangJian 2017/03/30 17:36:50
    do
        self._hudunAnim = assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/FightEffect/fanghu.skel", "Anim/FightEffect/fanghu.atlas", 1), "动画初始化出错")
        self:addChild(self._hudunAnim)
        self._hudunAnim.isVisible = false
        self._hudunAnim.isEnable = true
        self._hudunAnim:setVisible(false)

    end

    do  --角色阴影特效
        self._shadowSpriteEffectAnim = assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/specialEffect/specialEffect.skel", "Anim/specialEffect/specialEffect.atlas", 1), "动画初始化出错")
        self:addChild(self._shadowSpriteEffectAnim)
        self._shadowSpriteEffectAnim:setVisible(false)
    end

    --入场动画和胜利动画
    do
        self._enterVictoryAnim = assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/enterVictory/enterVictory.skel", "Anim/enterVictory/enterVictory.atlas", 1), "动画初始化出错")
        self._enterVictoryAnim:setSlotColor("body", cc.c4f(1, 1, 0, 1))
        self._enterVictoryAnim:setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
        self:addChild(self._enterVictoryAnim)
        self._enterVictoryAnim:setVisible(false)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/07 15:57:17
-- @desc 隐藏所有额外效果
function Player:setAllAdditionalAnimEnabled(b)
    self:setShieldAnimEnabled(b)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/07 16:42:18
-- @desc 设置玩家护盾动画是否可用
function Player:setShieldAnimEnabled(b)
    self._hudunAnim.isEnable = b
    
    if b == true then
        if self._hudunAnim.isVisible == true then
            self._hudunAnim:runActionWithName("fadeInAdnFadeOut", cc.FadeIn:create(0.3))
        else
            self._hudunAnim:runActionWithName("fadeInAdnFadeOut", cc.FadeOut:create(0.3))
        end
    else
        self._hudunAnim:runActionWithName("fadeInAdnFadeOut", cc.FadeOut:create(0.3))
    end

    self._hudunAnim:setVisible(b)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/30 18:18:18
-- @desc 给玩家设置护盾动画
function Player:setShieldAnimVisible(b, colorName)
    self._hudunAnim.isVisible = b
    
    if self._hudunAnim.isEnable == true then
        if b == true then
            self._hudunAnim:runActionWithName("fadeInAdnFadeOut", cc.FadeIn:create(0.3))
        else
            self._hudunAnim:runActionWithName("fadeInAdnFadeOut", cc.FadeOut:create(0.3))
        end
    else
        self._hudunAnim:runActionWithName("fadeInAdnFadeOut", cc.FadeOut:create(0.3))
    end

    self._hudunAnim:setVisible(b)
    
    self:setShieldAnimColor(colorName)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/07 16:43:11
-- @desc 设置护盾动画颜色
function Player:setShieldAnimColor(colorName)
    local animName =
        switch(
        colorName,
        {
            ["白"] = "bai",
            ["金"] = "jin",
            ["蓝"] = "lan",
            ["紫"] = "zi",
            ["绿"] = "lv",
            ["闪紫"] = "shanzi",
            ["红"] = "hong",
            default = "bai"
        }
    )

    self._hudunAnim:setSlotsToSetupPose()

    self._hudunAnim:setAnimation(0, animName, true)
end

---设置角色影子颜色
function Player:setRoleShadowSpriteEffectAnim(animName)
    if not animName then
        self._shadowSpriteEffectAnim:setVisible(false)
        return
    end

    if animName and animName ~= "" then
        self._shadowSpriteEffectAnim:setVisible(true)
        self._shadowSpriteEffectAnim:setAnimation(0,animName, true)
    end
end

--效果动画播放
function Player:playEffectAnim(animName)
    if animName and animName ~= "" then
        local skeletonAnimation = assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/specialEffect/specialEffect.skel", "Anim/specialEffect/specialEffect.atlas", 1), "动画初始化出错")
        if self.direction == DIRECTION_RIGHT then
            skeletonAnimation:setScaleX(1)
        else
            skeletonAnimation:setScaleX(-1)
        end
        
        self:addChild(skeletonAnimation)
        local state = SpineAnimationState:create(skeletonAnimation, animName, false)
        
        state:setCompleteCallback(function()
            self:delayFunc(0.001,function()
                skeletonAnimation:removeFromParent()
            end)
        end)

        state:start()

        skeletonAnimation:schedule(function(ft)
            state:update(self, ft)
        end, 0)
    end
end

function Player:setEnterVictoryAnimVisible(bool)
    self._enterVictoryAnim:setVisible(bool)
end

function Player:playEnterVictoryAnim(animName)
    if self.direction == DIRECTION_RIGHT then
        self._enterVictoryAnim:setScaleX(1)
    else
        self._enterVictoryAnim:setScaleX(-1)
    end
    self._enterVictoryAnim:setAnimation(0,animName,false)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 15:29:00
-- @desc 添加主动技能准备
function Player:readyActiveZhao(zhaoName)
    if zhaoName and self._currActiveZhaoReadyItem == nil then
        local roleStatePanelActiveZhaoReadyItem = RoleStatePanelActiveZhaoReadyItem:create()
        roleStatePanelActiveZhaoReadyItem:setDirection(-self.direction)
        self:addChild(roleStatePanelActiveZhaoReadyItem)
        
        switch(self.direction,
            {
                [1] = function()
                    roleStatePanelActiveZhaoReadyItem:setAnchorPoint(cc.p(0.5, 0.5))
                    roleStatePanelActiveZhaoReadyItem:move(0, 180)
                end,
                [-1] = function()
                    roleStatePanelActiveZhaoReadyItem:setAnchorPoint(cc.p(0.5, 0.5))
                    roleStatePanelActiveZhaoReadyItem:move(0, 180)
                end,
                default = function()
                    error("RoleStatePanel:addActiveZhaoReady()")
                end
            })
        
        self._currActiveZhaoReadyItem = roleStatePanelActiveZhaoReadyItem
        
        roleStatePanelActiveZhaoReadyItem:setTitle(zhaoName)
        
        self._currActiveZhaoReadyItem:show1(function()
            PopText("显示完成")
        end)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 17:36:19
-- @desc 移除按钮
function Player:unreadyActiveZhao()
    if self._currActiveZhaoReadyItem then
        self._currActiveZhaoReadyItem:hide1(function()
            PopText("隐藏完成")
            self._currActiveZhaoReadyItem:removeFromParent()
            self._currActiveZhaoReadyItem = nil
        end)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/28 15:35:57
-- @desc 角色播放释放招式动画
function Player:useActiveZhao(activeZhaoName)
    -- 角色头顶的释放招式效果
    local activeZhaoReadyItem = RoleStatePanelActiveZhaoReadyItem:create()
    self:addChild(activeZhaoReadyItem)
    activeZhaoReadyItem:setAnchorPoint(cc.p(0.5, 0.5))
    activeZhaoReadyItem:move(0, 180)
    activeZhaoReadyItem:setAnimDuration(0.3)
    
    activeZhaoReadyItem:setDirection(self.direction * -1)
    
    activeZhaoReadyItem:setScale(1.25)
    
    activeZhaoReadyItem:show1(function()
        activeZhaoReadyItem:hide(function()
            activeZhaoReadyItem:removeFromParent()
        end)
    end)
end

function Player:setDirection(direction)
    if direction > 0 then
        self.direction = DIRECTION_RIGHT
        self.anim:setScaleX(1)
    else
        self.direction = DIRECTION_LEFT
        self.anim:setScaleX(-1)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/06 11:43:39
-- @desc 初始化角色状态文本
function Player:initStatusText()
    self._statusText = ccui.Text:create()
    self._statusText:setFontName(Resource:getFontPath("default"))
    self._statusText:setFontSize(32)
    self._statusText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self._statusText:setString("测试状态")
    self:addChild(self._statusText, 1)
    
    
    self:setStatusText()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/06 11:23:49
-- @desc 设置角色当前状态文本
function Player:setStatusText(text)
    if type(text) ~= "string" or text == "" or text == "正常" then
        text = nil
    end
    
    if self._statusText then
        if text then
            self._statusText:setVisible(true)
            switch(self.direction,
                {
                    [1] = function()
                        self._statusText:setPositionX(-0)
                        self._statusText:setAnchorPoint(cc.p(1, 0.5))
                    end,
                    [-1] = function()
                        self._statusText:setPositionX(0)
                        self._statusText:setAnchorPoint(cc.p(0, 0.5))
                    end
                })
            self._statusText:setPositionY(100)
            
            self._statusText:setString(text)
        else
            self._statusText:setVisible(false)
        end
    else
        -- print("self._statusTex = ", self._statusText)
    end
end

function Player:resetHpBar(hp, grayHp, maxHp)
    
    local hpPerc = hp / maxHp
    local hpgrayPerc = grayHp / maxHp
    
    self.hpFrameSprite = cc.Sprite:create("hpframe_white.png")
    --self.hpFrameSprite = cc.Sprite:create()
    self.hpMaxSprite = cc.Sprite:create("hpframe_max.png")
    self.hpGreenSprite = cc.Sprite:create("hpframe_green.png")
    self.hpRedSprite = cc.Sprite:create("hpframe_red.png")
    
    self.hpFrameSprite:addChild(self.hpMaxSprite, 1)
    self.hpFrameSprite:addChild(self.hpRedSprite, 2)
    self.hpFrameSprite:addChild(self.hpGreenSprite, 3)
    
    self.hpFrameSprite:setVisible(false)
    
    self.hpMaxSprite:setAnchorPoint(cc.p(0, 0.5))
    self.hpGreenSprite:setAnchorPoint(cc.p(0, 0.5))
    self.hpRedSprite:setAnchorPoint(cc.p(0, 0.5))
    
    --self.hpMaxSprite:setPositionX( -129/2 )
    --self.hpGreenSprite:setPositionX( -129/2 )
    --self.hpRedSprite:setPositionX( -129/2 )
    self.hpMaxSprite:setPositionY(12 / 2)
    self.hpGreenSprite:setPositionY(12 / 2)
    self.hpRedSprite:setPositionY(12 / 2)
    
    self.hpGreenSprite:setScaleX(hpPerc)
    self.hpRedSprite:setScaleX(hpPerc)
    self.hpMaxSprite:setScaleX(hpgrayPerc)
    
    self:addChild(self.hpFrameSprite)
    self.hpFrameSprite:setPosition(cc.p(0, 150))
end

function Player:setHpBar(hp, grayHp, maxHp)
    
    local hpPerc = hp / maxHp
    local hpgrayPerc = grayHp / maxHp
    
    self.hpGreenSprite:setScaleX(hpPerc)
    --self.hpRedSprite:setScaleX( hpPerc )
    --self.hpMaxSprite:setScaleX( hpgrayPerc )
    self.hpMaxSprite:runAction(cc.ScaleTo:create(0.2, hpgrayPerc, 1.0))
    
    self.hpRedSprite:runAction(cc.ScaleTo:create(0.2, hpPerc, 1.0))
    self.hpRedSprite:runAction(cc.ScaleTo:create(0.2, hpPerc, 1.0))
end


function Player:showDamageTips(string)
    local src_pos
    local dst_pos
    local text = Resource:getTextByStyleName("taskDamageNum")
    text:setTextHorizontalAlignment(1)
    text:setTextVerticalAlignment(1)
    
    text:setString(string)
    self:addChild(text, 20)
    
    if self.direction == DIRECTION_RIGHT then
        src_pos = cc.p(-40, 80)
        dst_pos = cc.p(-90, 120)
    else
        src_pos = cc.p(40, 80)
        dst_pos = cc.p(90, 120)
    end
    
    text:move(src_pos)
    text:runAction(
        cc.Sequence:create(
            YXEaseAction:create(cc.MoveTo:create(0.15, dst_pos), Sine_EaseIn),
            cc.DelayTime:create(0.25),
            cc.FadeIn:create(0.1),
            cc.CallFunc:create(
                function()
                    text:removeFromParent()
                end
    )
    )
    )
    text:runAction(
        cc.Sequence:create(
            YXEaseAction:create(cc.ScaleTo:create(0.15, 1.5), Sine_EaseIn),
            YXEaseAction:create(cc.ScaleTo:create(0.1, 1.25), Sine_EaseOut)
)
)
end

local Skill = class("Skill", {})

function Skill:create(skilldata)
    local p = Skill:new()
    p:init(skilldata)
    return p
end

function Skill:init(skilldata)
    --技能名称
    self.name = skilldata.name
    
    --技能当前状态
    self.currStatus = 0 -- 0:disable ; 1:useable ; 2:cooldowning
    
    --冷却帧计时
    self.cooldownCount = 0
    
    --技能原始数据
    self.data = skilldata
    
    self.buttonObj = nil

end




local Damage = class("Damage", {})

function Damage:create()
    local p = Damage:new()
    p:init()
    return p
end


function Damage:init()
    
    self.type = "normal"
    
    --伤害状态
    self.status = 1 --0 : "disable",  1 : able
    
    --伤害来源
    self.source = nil
    
    --伤害来源的来源
    self.sourceParent = nil
    
    --伤害作用的目标列表
    self.targetList = nil
    
    --伤害数值
    self.atk = 1
    
    --伤害原始描述
    self.damageDesc = nil
end

function Player:equipSkill(weaponSkill, barehandSkill)
    
    if weaponSkill ~= nil then
        self.skill.weapon = weaponSkill
    end
    
    
    if barehandSkill ~= nil then
        self.skill.barehand = barehandSkill
    end
    
    --检查现在的武器是否能使用武功
    self.currSkill = self.skill.weapon
    
    --为技能创建结构体
    self.currUseSkills = {}
    
    for skillId, skillData in pairs(self.currSkill.useZhao) do
        
        --self:addUseSkillButton( skillData.name )
        local sk = Skill:create(skillData)
    
    
    end

end

function Player:useSkill(skill)
    --[[	local skill = nil
    
    for skillId , skillData in pairs( self.currSkill.useZhao ) do
    
    if skillData.name == name then
    skill = skillData
    break
    end
    end
    
    if skill == nil then
    --使用招式失败
    ___log( "["..self.name.."]使用招式失败 没有找到招式" .. name)
    return false
    end
    ]]
    -- ___log("[" .. self.name .. "]使用主动技能" .. skill.name)
    
    --条件判断是否能使用
    --执行use函数
    if skill.frames ~= nil then
        --执行本招
        self:runZhao(skill)
    end

end

function Player:update(elapsed)
    self:updateAction(elapsed)
end

function Player:updateAction(elapsed)
    -- print("elapsed = "..tostring(elapsed))
    local action = self._action
    if action then
        -- print("action.name = "..tostring(action.name))
        -- 时间增加
        action.elapsed = action.elapsed + elapsed
        -- print("action.elapsed = "..tostring(action.elapsed))
        -- print("action.duration = "..tostring(action.duration))
        if action.elapsed > action.duration then
            action.elapsed = action.duration
        end
        
        if action.name == "move1" then
            local percent = action.elapsed / action.duration
            local endPos = action.endPos
            local dx = (endPos.x - self:getPositionX()) * (math.sin(percent * 1.57))
            local dy = (endPos.y - self:getPositionY()) * (math.sin(percent * 1.57))
            self:setPosition(cc.pAdd(cc.p(self:getPosition()), cc.p(dx, dy)))
        elseif action.name == "jump1" then
            local percent = Helper:getRange(action.elapsed / action.duration, 0, 1)
            local endPos = action.endPos
            if action.jumpHeight == nil then
                action.jumpHeight = math.abs((endPos.x - self:getPositionX())) / 1080 * 30
            end
            local jumpY = (0.5 - math.abs(0.5 - percent)) * action.jumpHeight
            jumpY = jumpY * jumpY
            local dx = (endPos.x - self:getPositionX()) * (math.sin(percent * 1.57))
            local dy = (endPos.y - self:getPositionY()) * (math.sin(percent * 1.57))-- + jumpY
            self:setPosition(cc.pAdd(cc.p(self:getPosition()), cc.p(dx, dy)))
            
            self.anim:setPositionY(jumpY)
        -- self.shadowSprite:setPositionY(-jumpY)
        elseif action.name == "move" then
            local offsetX = action.offsetX
            local offsetY = action.offsetY
            
            local percent = action.elapsed / action.duration
            
            local target = self._action.target
            local targetPosX = target:getPositionX()
            local targetPosY = target:getPositionY()
            
            local targetDirection = targetPosX - self:getPositionX()
            if targetDirection >= 0 then
                targetDirection = 1
            else
                targetDirection = -1
            end
            
            -- local jumpY = (0.5 - math.abs(0.5 - percent)) * 100
            local dx = (targetPosX - self:getPositionX() + targetDirection * offsetX) * (math.sin(percent * 1.57))
            local dy = (targetPosY - self:getPositionY() + offsetY) * (math.sin(percent * 1.57))-- + jumpY
            
            local moveToPos = cc.pAdd(cc.p(self:getPosition()), cc.p(dx, dy))
            self:setPositionX(moveToPos.x)
            self:setPositionY(moveToPos.y)
        -- self:setPositionY(self.originPos.y + jumpY)
        -- self.anim:setPosition(cc.pAdd(cc.p(self.anim:getPosition()), cc.p(0, dy)))
        -- self.shadowSprite:setPositionY(-jumpY)
        elseif action.name == "moveby" then
            local targetX = action.offsetX
            local targetY = action.offsetY
            
            local percent = action.elapsed / action.duration
            
            -- local jumpY = (0.5 - math.abs(0.5 - percent)) * 100
            local currPosX = (action.offsetX) * (math.sin(percent * 1.57))
            --local dy = (self:getPositionY() - targetY ) * percent-- + jumpY
            if self.direction == DIRECTION_LEFT then
                currPosX = -currPosX
            end
            --local moveToPos = cc.p(dx, dy)
            self:setPositionX(action.originX + currPosX)
        -- self:setPositionY(self.originPos.y + jumpY)
        --self.anim:setPosition( cc.pAdd( cc.p( self.anim:getPosition() ) , cc.p(0, dy)))
        -- self.shadowSprite:setPositionY(-jumpY)
        elseif action.name == "jump" then
            local offsetX = action.offsetX
            local offsetY = action.offsetY
            
            local percent = action.elapsed / action.duration
            
            local target = self._action.target
            local targetPosX = target:getPositionX()
            local targetPosY = target:getPositionY()
            
            if action.jumpHeight == nil then
                action.jumpHeight = math.abs((targetPosX - self:getPositionX())) / 1080 * 30
            end
            
            local targetDirection = targetPosX - self:getPositionX()
            if targetDirection >= 0 then
                targetDirection = 1
            else
                targetDirection = -1
            end
            
            local jumpY = (0.5 - math.abs(0.5 - percent)) * action.jumpHeight
            jumpY = jumpY * jumpY
            
            local dx = (targetPosX - self:getPositionX() + targetDirection * offsetX) * (math.sin(percent * 1.57))--percent
            local dy = (targetPosY - self:getPositionY() + offsetY) * percent
            
            local moveToPos = cc.pAdd(cc.p(self:getPosition()), cc.p(dx, dy))
            self:setPositionX(moveToPos.x)
            self:setPositionY(moveToPos.y)-- self.originPos.y + jumpY)
            -- self.anim:setPosition(cc.pAdd(cc.p(self.anim:getPosition()), cc.p(0, dy)))
            self.anim:setPositionY(jumpY)
        -- self.shadowSprite:setPositionY(-jumpY)
        end
        
        -- 判断是否结束
        if action.elapsed >= action.duration then
            action.name = "idle"
        end
    end
end


function Player:runZhao(zhao)
    -- ___log("[" .. self.name .. "]使出招式" .. zhao.name)
    self.currZhao = zhao
    self.currZhaoEntryId = 1
    self.currZhaoEntryFrameId = 0
end

function AnimFightLayer:FightStart(leftPositions, rightPositions)
    -- 角色层
    self._roleLayer = cc.Node:create()
    self:addChild(self._roleLayer)
    
    -- 角色map
    self._roleMap = {}
    
    self._Fight = {
        frameIndex = 0,
        players = {},
        damages = {},
        pauseRenderPlayer = {},
        pauseStatus = 0
    }
    
    local colorProgram = Resource:getSkAnimColorShader(1.0, 0, 0, 1)
    
    -- print("#leftPositions = " .. #leftPositions)
    -- print("#rightPositions = " .. #rightPositions)
    
    for i, pos in ipairs(leftPositions) do
        local playerA = Player:create()
        playerA.teamId = 1
        playerA.inTeamId = i
        playerA.name = "left" .. i
        -- playerA:equipSkill( Swordteck_HuashanJianfa , nil )
        playerA.originPos = pos
        playerA:setPosition(pos)
        playerA:setDirection(DIRECTION_RIGHT)
        -- playerA.anim:setSlotColor( "body", cc.c4f( math.random(0, 255) / 255 , math.random(0, 255) / 255 , math.random(0, 255) / 255 , 1.0 ) )
        -- playerA.anim:setSlotColor( "body_back" , cc.c4f( math.random(0, 255) / 255 , math.random(0, 255) / 255 , math.random(0, 255) / 255 , 1.0 ) )
        playerA.anim:setSlotColor("body", cc.c4f(1, 1, 0, 1))
        playerA.anim:setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
        self._roleLayer:addChild(playerA)
        table.insert(self._Fight.players, playerA)
        self._roleMap[playerA.name] = playerA
        -- print("playerA.name = " .. playerA.name)
        
        playerA:setVisible(false)
    end
    
    for i, pos in ipairs(rightPositions) do
        local playerA = Player:create()
        playerA.teamId = 2
        playerA.inTeamId = i
        playerA.name = "right" .. i
        -- playerA:equipSkill( Swordteck_HuashanJianfa , nil )
        playerA.originPos = pos
        playerA:setPosition(pos)
        playerA:setDirection(DIRECTION_LEFT)
        playerA.anim:setSlotColor("body", cc.c4f(1, 1, 0, 1))
        playerA.anim:setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
        self._roleLayer:addChild(playerA)
        table.insert(self._Fight.players, playerA)
        self._roleMap[playerA.name] = playerA
        -- print("playerA.name = " .. playerA.name)
        
        playerA:setVisible(false)
    end



-- 	--准备玩家
-- 	--添加测试玩家
-- 	local playerA = Player:create()
--     -- playerA.property.atkSpeed = 10
--
-- 	playerA.team = 1
-- 	playerA.name = "A"
--
-- 	playerA:equipSkill( Swordteck_HuashanJianfa , nil )
--
-- 	playerA.originPos = cc.pAdd(self._center, cc.p( -200 , 0 ))
-- 	playerA:setPosition( playerA.originPos )
-- 	playerA:setDirection( DIRECTION_RIGHT )
-- 	playerA.anim:setSlotColor( "body" , cc.c4f( 1.0 , 1.0 , 0 , 1.0 ) )
-- 	playerA.anim:setSlotColor( "body_back" , cc.c4f( 1.0 , 1.0 , 0 , 1.0 ) )
--
-- 	self._roleLayer:addChild( playerA )
--
-- 	local playerA2 = Player:create()
-- 	playerA2.team = 2
-- 	playerA2.name = "A"
-- 	playerA2:equipSkill( Swordteck_HuashanJianfa , nil )
--
-- 	playerA2.originPos = cc.pAdd(self._center, cc.p(200 , 0))
-- 	playerA2:setPosition( playerA2.originPos )
-- 	playerA2:setDirection( DIRECTION_LEFT )
-- 	playerA2.anim:setSlotColor( "body" , cc.c4f( 1.0 , 1.0 , 0.0 , 1.0 ) )
-- 	playerA2.anim:setSlotColor( "body_back" , cc.c4f( 1.0 , 1.0 , 0.0 , 1.0 ) )
-- --	playerA2.anim:setScaleX( -1.2 )
-- --	playerA2.anim:setScaleY( 1.2 )
-- 	self._roleLayer:addChild( playerA2 )
--[[local playerB = Player:create()
playerB.team = 2
playerB.name = "B"
playerB:equipSkill( Swordteck_HuashanJianfa , nil )

playerB.originPos = cc.p( 700 , 1300 )
playerB:setPosition( playerB.originPos )
playerB:setDirection( DIRECTION_LEFT )
playerB.anim:setSlotColor( "body" , cc.c4f( 0.5 , 0.0 , 0.0 , 1.0 ) )
self:addChild( playerB )


local playerC = Player:create()
playerC.team = 2
playerC.name = "C"
playerC:equipSkill( Swordteck_HuashanJianfa , nil )

playerC.originPos = cc.p( 800 , 1100 )
playerC:setPosition( playerC.originPos )
playerC:setDirection( DIRECTION_LEFT )
playerC.anim:setSlotColor( "body" , cc.c4f( 0.75 , 0.5 , 0.0 , 1.0 ) )

self:addChild( playerC )


local playerD = Player:create()
playerD.team = 2
playerD.name = "D"
playerD:equipSkill( Swordteck_HuashanJianfa , nil )

playerD.originPos = cc.p( 800 , 1300 )
playerD:setPosition( playerD.originPos )
playerD:setDirection( DIRECTION_LEFT )
playerD.anim:setSlotColor( "body" , cc.c4f( 0.75 , 0.5 , 0.25 , 1.0 ) )
--playerD.anim:setSlotColor( "images/sword/sword_stand" , cc.c4f( 0.0 , 0.0 , 0.0 , 1.0 ) )
self:addChild( playerD )


local playerE= Player:create()
playerE.team = 2
playerE.name = "E"
playerE:equipSkill( Swordteck_HuashanJianfa , nil )

playerE.originPos = cc.p( 750 , 1100 )
playerE:setPosition( playerE.originPos )
playerE:setDirection( DIRECTION_LEFT )
--playerE.anim:setSlotColor( "images/sword/sword_stand" , cc.c4f( 0.0 , 0.0 , 0.0 , 1.0 ) )

self:addChild( playerE )]]
-- table.insert( self._Fight.players , playerA )
-- table.insert( self._Fight.players , playerA2 )
-- table.insert( self._Fight.players , playerB )
-- table.insert( self._Fight.players , playerC )
-- table.insert( self._Fight.players , playerD )
-- table.insert( self._Fight.players , playerE )
-- 将角色添加到角色map
-- self._roleMap["a"] = playerA
-- self._roleMap["b"] = playerA2
end

-- 通过id获得角色
function AnimFightLayer:getRole(id)
    return assert(self._roleMap[id])
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得角色通过队伍id和角色在队伍中的id
function AnimFightLayer:getRoleByTeamIdAndInTeamId(teamId, inTeamId)
    for roleId, role in pairs(self._roleMap) do
        if role.teamId == teamId and role.inTeamId == inTeamId then
            return role
        end
    end
    return nil
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 角色挨打
function AnimFightLayer:roleHurt(roleId)
-- local role = self:getRole(roleId)
-- --播放动画
-- local dmgPaOffsetY = 120
--
-- if self._animPa == nil then
-- 	self._animPa = Resource:getSkAnim("effects")
-- end
-- if self._animPa:getParent() then
-- 	-- self._animPa:removeFromParent(false)
-- 	self._animPa:retain()
-- 	self._animPa:getParent():removeChild(self._animPa, false)
-- 	role:addChild( self._animPa , 10 )
-- else
-- 	role:addChild( self._animPa , 10 )
-- end
--
-- self._animPa:playAnim( "pa-red" , false )
-- self._animPa:setSlotColor( "point" , cc.c4f( 1.0 , 0.0 , 0.0 , 1.0 ) )
-- self._animPa:setSpeedScale( 0.8 )
-- self._animPa:runAction(
-- 	cc.Sequence:create(
-- 		cc.DelayTime:create( 0.5 ) ,
-- 		cc.CallFunc:create(
--  			function()
-- 				-- 	self._animPa:removeFromParent()
--  			end
--  			)
-- 	)
-- )
--
-- if role.direction == DIRECTION_LEFT then
-- 	self._animPa:setPosition( cc.p( 0 , dmgPaOffsetY ) )
-- 	self._animPa:setScaleX( -1 )
-- else
-- 	self._animPa:setPosition( cc.p( 0 , dmgPaOffsetY ) )
-- 	self._animPa:setScaleX( 1 )
-- end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 播放掉血动画
function AnimFightLayer:rolePopNumber(roleId, number, color)
    color = Helper:getDef(color, cc.c4b(255, 255, 255, 255))
    
    local role = self:getRole(roleId)
    local text = ccui.Text:create()
    text:setFontName("Font/default.ttf")
    text:setFontSize(48)
    text:setTextColor(color)-- 文字颜色
    text:enableOutline(cc.c4b(0, 0, 0), 3)-- 气血文字描边
    
    text:setString(number)
    
    role:addChild(text)
    text:setLocalZOrder(99999)
    text:setPositionY(130)
    text:runAction(YXEaseAction:create(cc.Sequence:create(
            
            -- 显示
            cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(math.random(-20, 20), math.random(130, 170))), cc.Sequence:create(cc.ScaleTo:create(0.05, 1.2), cc.ScaleTo:create(0.05, 1))),
            
            -- 停留
            cc.DelayTime:create(0.3),
            
            -- 消失
            cc.Spawn:create(cc.FadeOut:create(0.5), cc.MoveBy:create(0.5, cc.p(0, 30))),
            
            -- 移除
            cc.RemoveSelf:create()), Sine_EaseOut))
-- text:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(math.random(-20, 20), math.random(130, 170))), cc.DelayTime:create(0.3), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
end

-- @author TangJian
-- @desc 播放掉血动画
function AnimFightLayer:rolePopNumberUP(roleId, number, color)
    color = Helper:getDef(color, cc.c4b(255, 255, 255, 255))
    
    local role = self:getRole(roleId)
    local text = ccui.Text:create()
    text:setFontName("Font/default.ttf")
    text:setFontSize(48)
    text:setTextColor(color)-- 文字颜色
    text:enableOutline(cc.c4b(0, 0, 0), 3)-- 气血文字描边
    
    text:setString(number)
    
    role:addChild(text)
    text:setLocalZOrder(99999)
    text:setPositionY(130)
    text:runAction(YXEaseAction:create(cc.Sequence:create(
            
            -- 显示
            cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(math.random(-20, 20), math.random(170, 230))), cc.Sequence:create(cc.ScaleTo:create(0.05, 1.2), cc.ScaleTo:create(0.05, 1))),
            
            -- 停留
            cc.DelayTime:create(0.3),
            
            -- 消失
            cc.Spawn:create(cc.FadeOut:create(0.5), cc.MoveBy:create(0.5, cc.p(0, 30))),
            
            -- 移除
            cc.RemoveSelf:create()), Sine_EaseOut))
-- text:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(math.random(-20, 20), math.random(130, 170))), cc.DelayTime:create(0.3), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
end


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得玩家相对对手的位置
function AnimFightLayer:roleGetRelativePos(roleId, targetId)
    local role1 = self:getRole(roleId)
    local role2 = self:getRole(targetId)
    
    local relativePos = cc.pMul(cc.pSub(cc.p(role1:getPosition()), cc.p(role2:getPosition())), role1.direction)
    return relativePos
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 角色移动到初始位置
function AnimFightLayer:roleMoveToOrigin(roleId, duration)
    local role = self:getRole(roleId)
    -- self:roleMove(roleId, role.originPos, duration)
    self:roleJump(roleId, role.originPos, duration)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 移动
function AnimFightLayer:roleMove(roleId, endPos, duration)
    logt("AnimFightLayer:roleMove(roleId, endPos, duration)", roleId, duration)
    local role1 = self:getRole(roleId)
    if role1.anim then
        role1.anim:setPositionY(0)
    end
    
    role1._action =
        {
            name = "move1",
            endPos = endPos,
            duration = duration,
            elapsed = 0
        }
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色跳跃
function AnimFightLayer:roleJump(roleId, endPos, duration)
    local role1 = self:getRole(roleId)
    if role1.anim then
        role1.anim:setPositionY(0)
    end
    
    role1._action =
        {
            name = "jump1",
            endPos = endPos,
            duration = duration,
            elapsed = 0
        }
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色移动
function AnimFightLayer:roleMoveTo(roleId, targetId, offsetX, offsetY, duration)
    local role1 = self:getRole(roleId)
    local role2 = self:getRole(targetId)
    if role1.anim then
        role1.anim:setPositionY(0)
    end
    
    role1._action =
        {
            name = "move",
            target = role2,
            offsetX = offsetX,
            offsetY = offsetY,
            duration = duration,
            elapsed = 0
        }
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色移动
function AnimFightLayer:roleMoveBy(roleId, offsetX, offsetY, duration)
    local role1 = self:getRole(roleId)
    if role1.anim then
        role1.anim:setPositionY(0)
    end
    
    role1._action =
        {
            name = "moveby",
            target = role1,
            originX = role1:getPositionX(),
            originY = role1:getPositionY(),
            offsetX = offsetX,
            offsetY = offsetY,
            duration = duration,
            elapsed = 0
        }
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色跳跃
function AnimFightLayer:roleJumpTo(roleId, targetId, offsetX, offsetY, duration)
    local role1 = self:getRole(roleId)
    local role2 = self:getRole(targetId)
    
    if role1.anim then
        role1.anim:setPositionY(0)
    end
    
    role1._action =
        {
            name = "jump",
            target = role2,
            offsetX = offsetX,
            offsetY = offsetY,
            duration = duration,
            elapsed = 0
        }
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 播放角色动画
function AnimFightLayer:playRoleAnim(roleId, animName, from, to, speed, delay)
    delay = Helper:getDef(delay, 0)
    
    local role = self:getRole(roleId)
    
    -- 重置影子位置
    role.shadowSprite:setPositionY(0)
    
    local function _playRoleAnim()
        speed = Helper:getDef(speed, 1)
        -- role.anim:setAttachment("weapon", "images/sword/sword")
        role.anim:playAnim(animName, false)
        -- role.anim:setAttachment("weapon", "images/sword/sword")
        if from or to then
            role.anim:setAnimFrameFromTo(from, to)
        end
        -- role.anim:setSpeedScale(speed * 1.1)
        role.anim:setSpeedScale(speed)
    end
    
    if delay == 0 then
        role:runActionWithName("playRoleAnim", cc.DelayTime:create(0))
        _playRoleAnim()
    else
        role:runActionWithName("playRoleAnim",
            cc.Sequence:create(
                cc.DelayTime:create(delay),
                cc.CallFunc:create(function()
                    _playRoleAnim()
                end)))
    end
end

function AnimFightLayer:loopaaa(player)
    player:runAction(
        cc.Sequence:create(YXEaseAction:create(cc.MoveTo:create(math.random(100, 2000) / 1000, cc.p(math.random(100, 1000), 1500)), Quad_EaseInOut),
            cc.Sequence:create(YXEaseAction:create(cc.MoveTo:create(0.68, cc.p(900, 200)), Quad_EaseInOut),
                cc.CallFunc:create(
                    function()
                        self:loopaaa(player)
                    end))))
end

function AnimFightLayer:FightPlayPauseFrame()
    
    local _Fight = self._Fight
    
    --暂停标志
    if self.pauseStatus == 0 then
        return false
    end
    
    --如果没有需要暂停渲染的角色
    if #_Fight.pauseRenderPlayer == 0 then
        return false
    end
    
    
    for i, renderPlayer in pairs(_Fight.pauseRenderPlayer) do
        
        
        
        end

end

function AnimFightLayer:FightPlayFrame(elapsed)
    
    for k, role in pairs(self._roleMap) do
        
        role:update(elapsed)
    
    end
    
    
    if true then
        return
    end
    local _Fight = self._Fight
    
    --清空伤害
    _Fight.damages = {}
    
    local render_players = {}
    
    for playerId, player in pairs(_Fight.players) do
        table.insert(render_players, player)
    end
    
    
    local function sortFunc(a, b)
        local aZ = a:getPositionY()
        local bZ = b:getPositionY()
        
        return aZ > bZ
    end
    
    table.sort(render_players, sortFunc)
    
    for i, v in ipairs(render_players) do
        v:setLocalZOrder(i)
    end
    
    --遍历角色列表中每个角色
    for playerId, player in pairs(_Fight.players) do
        
        local i = player.currZhaoEntryFrameId
        local n = 60
        local perc = (i + 1) / n
        
        --player.anim:stopAllActions()
        local dx
        if player.direction == DIRECTION_RIGHT then
            dx = (player.target:getPositionX() - math.random(90, 110) - player:getPositionX()) * perc
        else
            dx = (player.target:getPositionX() + math.random(90, 110) - player:getPositionX()) * perc
        end
        local dy = player.target:getPositionY() - player:getPositionY() + math.random(-40, 40)
        local dz = 250 * (1 - perc) * (1 - perc) * perc
        
        
        player:runAction(cc.MoveBy:create(0.05, cc.p(dx, dy)))
        player.anim:runAction(cc.MoveBy:create(0.05, cc.p(0, dz)))
    
    end
    
    --
    -- 	--local player = _Fight.players[ playerId ]
    --
    -- 	--___log( "player[" .. player.name .. "] status = " .. player.status .. "   action = " .. player.action )
    --
    -- 	--判断角色状态
    -- 	if player.status == "dead" then
    --
    -- 		___log( "player[" .. player.name .. "] is dead" )
    --
    -- 	else
    --
    -- 		if player.action == "idle" then
    --
    -- 			--___log( "player[" .. player.name .. "] is idle" )
    --
    -- 			-- 判断是否自动释放主动技能
    --
    -- 			-- 目标判断
    -- 			if player.target == nil or player.target.status ~= "alive" then
    --
    -- 				local isEnemyExists = false -- 检测是否所有敌人都死亡了
    --
    -- 				player.target = nil
    --
    -- 				-- 找一个攻击对象
    -- 				for enemyId , enemy in pairs( _Fight.players ) do
    --
    -- 					if enemy.team ~= player.team then
    --
    -- 						if enemy.status == "alive" then
    --
    -- 							isEnemyExists = true
    --
    -- 							___log( "player[" .. player.name .. "] 设置 " .. enemy.name .. " 为目标" )
    --
    -- 							player.target = enemy
    --
    -- 							break
    -- 						end
    -- 					end
    -- 				end
    --
    -- 				if isEnemyExists == false then
    --
    -- 					--敌人全部死亡了
    -- 					___log( player.name .. "胜利了" )
    -- 				end
    --
    -- 			end
    --
    -- 			--使用自动攻击招式
    -- 			if player.currSkill == nil or player.currSkill.autoZhao == nil then
    --
    -- 				--没有招式可用
    -- 				___log( "player[" .. player.name .. "] 没有招式可用" )
    --
    -- 			else
    --
    -- 				local randAutoZhaoId = math.random( 1 , #player.currSkill.autoZhao )
    --
    -- 				player:runZhao( player.currSkill.autoZhao[ randAutoZhaoId ] )
    --
    -- 				player.action = "attack"
    --
    -- 				--player.anim:setAnimation( 0 , "sword-attack01" , false )
    --
    -- 				--___log( "player[" .. player.name .. "] 开始使用招式 " .. player.currZhao.name )
    -- 			end
    --
    -- 		end
    --
    -- 		--当前处于攻击状态，则继续运行角色当前招式当前帧
    -- 		if player.action == "attack" then
    --
    -- 			player.currZhaoEntry = player.currZhao.frames[ player.currZhaoEntryId ];
    --
    -- 			--执行当前帧
    -- 			--___log( "player[" .. player.name .. "] " .. player.currZhaoEntry.name .. " " .. player.currZhaoEntryFrameId .. "/" .. player.currZhaoEntry.duration .. "   " .. player.currZhaoEntryId .. "/" .. #player.currZhao.frames );
    --
    -- 			if player.currZhaoEntry.damage ~= nil and player.currZhaoEntryFrameId == 0 then
    --
    -- 				--产生伤害
    -- 				for damageId , damageDesc in pairs( player.currZhaoEntry.damage ) do
    --
    -- 					local dmg = Damage:create()
    --
    -- 					dmg.targetList = {}
    -- 					dmg.source = player
    -- 					dmg.damageDesc = damageDesc
    --
    -- 					--计算本次伤害
    -- 					dmg.atk = player.property.atk;
    --
    -- 					if type(damageDesc.target) == "Array" then
    --
    -- 						--TODO 按数组中的排位设置目标列表
    -- 						table.insert( dmg.targetList , player.target )
    --
    -- 					elseif damageDesc.target == 0 then --自己
    --
    -- 						table.insert( dmg.targetList , player )
    --
    -- 					elseif damageDesc.target == 1 then --敌人
    --
    -- 						table.insert( dmg.targetList , player.target )
    --
    -- 					elseif damageDesc.target > 1 then --敌人目标和敌人目标周围的target个角色
    --
    -- 						table.insert( dmg.targetList , player.target )
    --
    -- 						--TODO 从敌人列表中再搜索出n个目标
    -- 					end
    --
    -- 					table.insert( _Fight.damages , dmg )
    -- 				end
    --
    -- 			end
    --
    --
    -- 			--动作第二阶段：位移，移动人物到施法攻击位置 移动到这里来了，因为它需要每一帧重新计算目标角色所在位置
    -- 			if player.currZhaoEntry.name == "go" then
    --
    -- 				local i = player.currZhaoEntryFrameId
    -- 				local n = player.currZhaoEntry.duration
    -- 				local perc = ( i + 1 ) / n
    --
    -- 				--player.anim:stopAllActions()
    -- 				local dx
    -- 				if player.direction == DIRECTION_RIGHT then
    -- 					dx = ( player.target:getPositionX() - math.random( 90 , 110 ) - player:getPositionX() ) * perc
    -- 				else
    -- 					dx = ( player.target:getPositionX() + math.random( 90 , 110 ) - player:getPositionX() ) * perc
    -- 				end
    -- 				local dy = player.target:getPositionY() - player:getPositionY() + math.random( -40 , 40 )
    -- 				local dz = 250 * ( 1 - perc ) * ( 1 - perc )  * perc
    --
    --
    -- 				player:runAction( cc.MoveBy:create( 0.05, cc.p( dx , dy ) ) )
    -- 				player.anim:runAction( cc.MoveBy:create( 0.05, cc.p( 0 , dz ) ) )
    --
    -- 			else
    --
    -- 				if player.currZhaoEntryFrameId == 0 then
    -- 					--第一招
    -- 					local entryDuration = player.currZhaoEntry.duration
    -- 					local entryAnimName = player.currZhao.animName
    -- 					if player.currZhaoEntry.animName ~= nil then
    -- 						entryAnimName = player.currZhaoEntry.animName
    -- 					end
    --
    -- 					--动作第一阶段：前摇，改变攻击动作为准备动作
    -- 					if player.currZhaoEntry.name == "ready" then
    --
    -- 						player.anim:playAnim(   , false )
    -- 						player.anim:setAnimFrameFromTo( 0 , 0 )
    --
    -- 					--动作第二阶段：位移，移动人物到施法攻击位置
    -- 					--[[
    -- 					elseif player.currZhaoEntry.name == "go" then
    -- 						if player.viewDirection == 0 then
    --
    -- 							local dx = player.target.anim:getPositionX()
    -- 							local dy = player.target.anim:getPositionY()
    --
    -- 							player.anim:runAction( YXEaseAction:create( cc.MoveTo:create( entryDuration * 0.075, cc.p( dx - 100 , dy ) ) , Quad_EaseInOut ) )
    -- 						else
    -- 							player.anim:runAction( YXEaseAction:create( cc.MoveTo:create( entryDuration * 0.075 , cc.p( dx + 100 , dy ) ) , Quad_EaseInOut ) )
    -- 						end
    -- 					]]
    --
    -- 					--动作第三阶段：攻击，攻击只有第一帧有伤害，攻击完停止原地僵直
    -- 					elseif player.currZhaoEntry.name == "attack" then
    -- 						local dx
    -- 						local dy
    -- 						if player.direction == DIRECTION_RIGHT then
    -- 							dx = player.target:getPositionX() - 100
    -- 						else
    -- 							dx = player.target:getPositionX() + 100
    -- 						end
    -- 						dy = player.target:getPositionY()
    --
    -- 						player:setPositionX( dx )
    -- 						player:setPositionY( dy )
    -- 						player.anim:setPosition( cc.p( 0 , 0 ) )
    --
    -- 						player.anim:playAnim( entryAnimName , false )
    -- 						player.anim:setAnimFrameFromTo( 10 , 20 )
    -- 						player.anim:setSpeedScale( 1.0 )
    --
    --                         self:pause()
    --                         cc.Director:getInstance():getRunningScene():runAction(cc.Sequence:create(cc.DelayTime:create(10 / 30), cc.CallFunc:create(function()
    --                             self:resume()
    --                         end)))
    --
    --
    -- 						--player.target.anim:runAction( TintBy:create( 0.1 , 255 , 0 , 0 ) )
    --
    --
    -- 					--动作第四阶段：归位，移动人物到原始位置
    -- 					elseif player.currZhaoEntry.name == "back" then
    --
    -- 						--player.originPos = cc.p( player:getPositionX() , player:getPositionY() )
    --
    -- 						player.anim:playAnim( player.currSkill.idleZhao.animName , false )
    -- 						player:runAction( YXEaseAction:create( cc.MoveTo:create( entryDuration * 0.05 , player.originPos ) , Quad_EaseInOut ) )
    --
    --
    -- 					--动作第五阶段：后摇，等待攻击间隔时间结束
    -- 					elseif player.currZhaoEntry.name == "recover" then
    --
    -- 						player.anim:playAnim( player.currSkill.idleZhao.animName , true )
    --
    -- 					end
    -- 				end
    -- 			end
    --
    -- 			--tick
    -- 			player.currZhaoEntryFrameId = player.currZhaoEntryFrameId + player.property.atkSpeed;
    --
    -- 			if player.currZhaoEntryFrameId >= player.currZhaoEntry.duration then
    --
    -- 				--执行下一个zhaoEntry
    -- 				player.currZhaoEntry = nil
    -- 				player.currZhaoEntryId = player.currZhaoEntryId + 1
    -- 				player.currZhaoEntryFrameId = 0
    --
    -- 				--判断招式是否已经完成
    -- 				if player.currZhaoEntryId > #player.currZhao.frames then
    --
    -- 					player.action = "idle"
    -- 					player.currZhao = nil
    --
    -- 					player.anim:playAnim( player.currSkill.idleZhao.animName , true )
    -- 				end
    -- 			end
    -- 		end
    -- 	end
    -- end
    --
    --
    -- --遍历伤害列表中的每个伤害
    -- for di , dmg in pairs( _Fight.damages ) do
    --
    -- 	if dmg.status == 1 then
    --
    -- 		dmg.status = 0
    --
    -- 		local target = dmg.targetList[1]
    --
    --         -- 打断动作
    --         target.action = "idle"
    --         target.currZhaoEntryId = 1
    --         target.currZhaoEntryFrameId = 0
    --
    -- 		--___log( "[DAMAGE] " .. dmg.targetList[1].name .. " 收到伤害 " .. dmg.atk .. " from " .. dmg.source.name  )
    -- 		local randomNum = math.random( 0 , 100 )
    -- 		if randomNum < 33 then
    -- 			--受伤
    -- 			target.property.hp = target.property.hp - dmg.atk
    --
    -- 			--播放动画
    -- 			local dmgPaOffsetY
    -- 			if dmg.damageDesc.part == "head" then
    -- 				target.anim:playAnim( "sword-hurt-head" , false )
    -- 				dmgPaOffsetY = 120
    -- 			elseif dmg.damageDesc.part == "chest" then
    -- 				target.anim:playAnim( "sword-hurt-chest" , false )
    -- 				dmgPaOffsetY = 75
    -- 			elseif dmg.damageDesc.part == "foot" then
    -- 				target.anim:playAnim( "sword-hurt-foot" , false )
    -- 				dmgPaOffsetY = 30
    -- 			end
    --
    --
    -- 			local animPa = Resource:getSkAnim("effects")
    -- 			animPa:playAnim( "pa-red" , false )
    -- 			animPa:setSlotColor( "point" , cc.c4f( 1.0 , 0.0 , 0.0 , 1.0 ) )
    -- 			animPa:setSpeedScale( 0.8 )
    -- 			animPa:runAction(
    -- 				cc.Sequence:create(
    -- 					cc.DelayTime:create( 0.5 ) ,
    -- 					cc.CallFunc:create(
    -- 			 			function()
    -- 			 				animPa:removeFromParent()
    -- 			 			end
    -- 			 			)
    -- 				)
    -- 			)
    -- 			target:addChild( animPa , 10 )
    -- 			if target.direction == DIRECTION_LEFT then
    -- 				animPa:setPosition( cc.p( 0 , dmgPaOffsetY ) )
    -- 				animPa:setScaleX( -1 )
    -- 			else
    -- 				animPa:setPosition( cc.p( 0 , dmgPaOffsetY ) )
    -- 				animPa:setScaleX( 1 )
    -- 			end
    --
    -- 			target.anim:runAction(
    --
    -- 			 	cc.Sequence:create(
    -- 			 		cc.CallFunc:create(
    -- 			 			function()
    -- 			 				target.anim:setGLProgram( Resource:getSkAnimColorShader( 1.0, 0, 0, 1 ) )
    -- 			 			end
    -- 			 		),
    -- 			 		cc.DelayTime:create( 0.1 ) ,
    -- 			 		cc.CallFunc:create(
    -- 			 			function()
    -- 			 				target.anim:setGLProgram( Resource:getSKAnimNormalShader() )
    -- 			 			end
    -- 			 		)
    --
    -- 			 		--cc.TintTo:create( 0.1 , 255 , 0 , 0 ) ,
    -- 			 		--cc.TintTo:create( 0.1 , 255 , 255 , 255 ) )
    -- 			 	)
    -- 			 )
    -- 			--player.target.anim:setColor(cc.c3b(255, 0, 0))
    --
    -- 			if target.property.hp <= 0 then
    -- 				target.property.grayHp = target.property.grayHp - 5
    --
    -- 				target.property.hp = target.property.grayHp
    --
    -- 				if target.property.grayHp <= 0 then
    -- 					target.property.grayHp = target.property.maxHp
    --
    -- 					target.property.hp = target.property.grayHp
    -- 				end
    -- 			end
    --
    -- 			target:setHpBar( target.property.hp , target.property.grayHp , target.property.maxHp )
    --
    -- 			target:showDamageTips( dmg.atk )
    --
    -- 		elseif randomNum < 66 then
    -- 			local animPa = Resource:getSkAnim("effects")
    -- 			local dmgPaOffset
    --
    -- 			if dmg.damageDesc.part == "head" then
    -- 				target.anim:playAnim( "sword-defend-head" , false )
    -- 				dmgPaOffset = cc.p( 25 , 105 )
    -- 			elseif dmg.damageDesc.part == "chest" then
    -- 				target.anim:playAnim( "sword-defend-chest" , false )
    -- 				dmgPaOffset = cc.p( 35 , 75 )
    -- 			elseif dmg.damageDesc.part == "foot" then
    -- 				target.anim:playAnim( "sword-defend-foot" , false )
    -- 				dmgPaOffset = cc.p( 25 , 30 )
    -- 			end
    -- 			target:addChild( animPa , 10 )
    -- 			animPa:playAnim( "pa-red" , false )
    -- 			animPa:setSlotColor( "point" , cc.c4f( 1.0 , 1.0 , 1.0 , 1.0 ) )
    -- 			animPa:setSpeedScale( 0.8 )
    -- 			animPa:runAction(
    -- 				cc.Sequence:create(
    -- 					cc.DelayTime:create( 0.5 ) ,
    -- 					cc.CallFunc:create(
    -- 			 			function()
    -- 			 				animPa:removeFromParent()
    -- 			 			end
    -- 			 			)
    -- 				)
    -- 			)
    --
    -- 			if target.direction == DIRECTION_LEFT then
    -- 				dmgPaOffset.x = - dmgPaOffset.x
    -- 				animPa:setPosition( dmgPaOffset )
    -- 				animPa:setScaleX( -1 )
    -- 			else
    -- 				animPa:setPosition( dmgPaOffset )
    -- 				animPa:setScaleX( 1 )
    -- 			end
    --
    -- 			target:showDamageTips( "格挡" )
    --
    -- 		else
    -- 			--闪躲
    -- 			--播放动画
    --
    -- 			if dmg.damageDesc.part == "head" then
    -- 				target.anim:playAnim( "sword-dodge-head" , false )
    --
    -- 			elseif dmg.damageDesc.part == "chest" then
    -- 				target.anim:playAnim( "sword-dodge-chest" , false )
    --
    -- 			elseif dmg.damageDesc.part == "foot" then
    -- 				target.anim:playAnim( "sword-dodge-foot" , false )
    --
    -- 			end
    --
    -- 			if target.direction == DIRECTION_LEFT then
    -- 				target:runAction( YXEaseAction:create(cc.MoveBy:create(0.1, cc.p(50, 0)), Sine_EaseIn) )
    -- 			else
    -- 				target:runAction( YXEaseAction:create(cc.MoveBy:create(0.1, cc.p(-50, 0)), Sine_EaseIn) )
    -- 			end
    --
    -- 			target:showDamageTips( "闪躲" )
    -- 		end
    -- 	end
    -- end
    --
    _Fight.frameIndex = _Fight.frameIndex + 1

end

function AnimFightLayer:create()
    local p = AnimFightLayer:new()
    p:init()
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 18:03:43
-- @desc 构造
function AnimFightLayer:ctor()
    self._moveCameraEnabled = false -- 能否移动摄像机
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc
function AnimFightLayer:createInPanel(parent,backgroundId)
    local p = AnimFightLayer:new()
    p:init(parent,backgroundId)
    return p
end

function AnimFightLayer:init(parent, backgroundId)
    self._size = self:getContentSize()
    self._center = cc.p(self._size.width / 2, self._size.height / 2)
    if parent then
        parent:addChild(self)
        self._size = parent:getContentSize()
        self._center = cc.p(self._size.width / 2, self._size.height / 2)
    end
    
    
    -- 初始化背景层
    self._orginBackgroundId = Helper:getDef(backgroundId,"default")
    self:initBackGroundLayer(backgroundId)
    
    self:schedule(
        function(elapsed)
            self:update(elapsed)
        end, 0)
    
    
    
    self:setFightEventListener()
end

function AnimFightLayer:getOriginBackgroundId()
    return self._orginBackgroundId
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化背景层
function AnimFightLayer:initBackGroundLayer(backgroundId)
    local background = switch(backgroundId,
        {
            ["城镇室内"] = "OtherImage/Fight/Scene/minjuhao.png",
            ["城镇室外"] = "OtherImage/Fight/Scene/dajie.png",
            ["村庄室内"] = "OtherImage/Fight/Scene/minjupo.png",
            ["村庄室外"] = "OtherImage/Fight/Scene/cunzhuang.png",
            ["森林内"] = "OtherImage/Fight/Scene/milin.png",
            ["森林外"] = "OtherImage/Fight/Scene/shulin.png",
            ["山内"] = "OtherImage/Fight/Scene/shandao.png",
            ["山外"] = "OtherImage/Fight/Scene/jiejianyan.png",
            ["擂台"] = "OtherImage/Fight/Scene/leitai.png",
            ["中秋比武台"] = "OtherImage/Fight/Scene/zhongqiuleitai.png",            
            ["振1"] = "OtherImage/Fight/Scene/szj1.png",  
            default = "OtherImage/Fight/Scene/default.png",
        })
    
    if self._backGroundLayer == nil then
        self._backGroundLayer = cc.Layer:create()
        self:addChild(self._backGroundLayer)
    end
    
    if self._backA or self._backB then
        self._backA:removeFromParent()
        self._backB:removeFromParent()
    end

    self._backA = ccui.ImageView:create(background)
    self._backB = ccui.ImageView:create(background)
    
    self._backGroundLayer:addChild(self._backA)
    self._backGroundLayer:addChild(self._backB)
    
    self._backA:setPositionY(0)
    self._backB:setPositionY(0)
    
    self._backA:setAnchorPoint(cc.p(0, 0))
    self._backB:setAnchorPoint(cc.p(0, 0))

    self._backWidth = self._backA:getContentSize().width
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 刷新背景层
function AnimFightLayer:updateBackGroundLayer(elapsed, posX)
    local offsetX = 0
    if self._lastBackGroundPosX then
        offsetX = posX - self._lastBackGroundPosX
    end
    self._lastBackGroundPosX = posX
    
    local width = self._backWidth
    
    local backA, backB = self._backA, self._backB
    
    if self._backA:getPositionX() > self._backB:getPositionX() then
        backA = self._backB
        backB = self._backA
    end
    
    local aX = backA:getPositionX()
    local bX = backB:getPositionX()
    
    aX = aX + offsetX
    bX = bX + offsetX
    
    if offsetX > 0 then
        
        if aX >= 0 then
            bX = aX - width
        end
    --
    -- local tmp = self._backA
    -- self._backA = self._backB
    -- self._backB = tmp
    elseif offsetX < 0 then
        
        if bX <= 0 then
            aX = bX + width
        end
    --
    -- local tmp = self._backA
    -- self._backA = self._backB
    -- self._backB = tmp
    end
    
    -- print("aX = "..aX)
    -- print("bX = "..bX)
    backA:setPositionX(aX)
    backB:setPositionX(bX)
end

function AnimFightLayer:update(elapsed)
    for k, role in pairs(self._roleMap) do
        role:update(elapsed)
    end
    
    self:updateScenePos()
    
    -- 镜头移动
    self:updateBackGroundLayer(elapsed, self._roleLayer:getPositionX())
    
    -- 刷新层级
    -- print("开始设置角色层次")
    for k, role in pairs(self._roleMap) do
        local y = role:getPositionY()
        local zorder = 1920 - y
        -- print("k = ", k, "zorder = ", zorder)
        role:setLocalZOrder(zorder)
    end
-- print("结束设置角色层次")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 18:09:42
-- @desc 设置摄像机能否移动
function AnimFightLayer:setMoveCameraEnabled(b)
    self._moveCameraEnabled = b
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 刷新镜头
function AnimFightLayer:updateScenePos()
    if self._moveCameraEnabled then
        local offsetA = 0
        local offsetB = 0
        
        local roleA = self:getRole("left1")
        local roleB = self:getRole("right1")
        
        if roleA:getPositionX() > roleB:getPositionX() then
            local tmp = roleA
            roleA = roleB
            roleB = roleA
        end
        
        local viewPosX = -self._roleLayer:getPositionX()
        
        local aX = roleA:getPositionX()
        local bX = roleB:getPositionX()
        local roleWidth = 300
        
        if aX < viewPosX + roleWidth / 2 then
            self._roleLayer:setPositionX(-aX + roleWidth / 2)
        end
        if bX > viewPosX + self._size.width - roleWidth / 2 then
            self._roleLayer:setPositionX(-bX + self._size.width - roleWidth / 2)
        end
        if math.abs(aX - bX) >= display.width - roleWidth then
            self._roleLayer:setPositionX(-aX + roleWidth / 2)
        end
    else
        self._roleLayer:setPositionX(0)
    end
end

function AnimFightLayer:moveToFocusPos(focusPos)
    local duration = 0.2
    local actionTag = self._roleLayer:getActionTagByName("moveToFocusPos")
    self._roleLayer:stopActionByTag(actionTag)
    
    local moveToPos = cc.p(-focusPos.x + self._size.width / 2, -focusPos.y + self._size.height / 2)
    
    local action = YXEaseAction:create(cc.MoveTo:create(duration, moveToPos), Quad_EaseOut)
    action:setTag(actionTag)
    self._roleLayer:runAction(action)
end

function AnimFightLayer:setControllingPlayer(player)
    
    --为主动技能创建按钮
    self:resetUseSkillButtons()
    
    --[[
    self:addUseSkillButton( "苍松迎客" )
    self:addUseSkillButton( "九阴白骨爪" )
    self:addUseSkillButton( "八荒六合唯我独尊功" )
    self:addUseSkillButton( "六脉神剑·少阴剑" )
    self:addUseSkillButton( "亢龙有悔" )
    self:addUseSkillButton( "打狗棒法·关门打狗" )
    ]]
    self.controllingPlayer = player
    
    
    
    for skillId, skillData in pairs(player.currSkill.useZhao) do
        
        self:addUseSkillButton(skillData.name,
            function()
                
                -- ___log(player.name .. " 使用招式 " .. skillData.name)
                
                player:useSkill(skillData)
            end)
    
    
    end

end

function AnimFightLayer:resetUseSkillButtons()
    self._useSkillButtons = {}
    self._useSkillButtonCount = 0
end

function AnimFightLayer:addUseSkillButton(name, func)
    
    --为主动技能创建按钮
    local button = ccui.Button:create(Resource:getImgPath("button3"))
    local buttonSize = button:getContentSize()
    local text = Resource:getTextByStyleName("taskButton")
    text:setTextAreaSize(cc.size(300, buttonSize.height))
    text:setTextHorizontalAlignment(1)
    text:setTextVerticalAlignment(1)
    
    text:setString(name)
    button:addChild(text)
    text:move(cc.p(buttonSize.width / 2, buttonSize.height / 2))
    
    
    button.useSkillButtonIndex = self._useSkillButtonCount
    button:setPosition(cc.p(200 + 350 * (button.useSkillButtonIndex % 3), 400 - 80 * math.floor(button.useSkillButtonIndex / 3)))
    
    button:releaseFunc(func)
    
    table.insert(self._useSkillButtons, button)
    self:addChild(button)
    
    
    self._useSkillButtonCount = self._useSkillButtonCount + 1
end



-- 按键注册 -----------------------------------------------------------------------------------
function AnimFightLayer:setFightEventListener()
    
    
    
    -- 以下为按键监听
    local eventDispatcher = self:getEventDispatcher()
    
    if self.touchListener ~= nil then
        eventDispatcher:removeEventListener(self.touchListener)
        self.touchListener = nil
    end
    
    self.touchListener = cc.EventListenerKeyboard:create()
    
    local listener = self.touchListener
    
    listener:registerScriptHandler(
        function(keyCode)
            --keyCode = keyCode - 3
            --print("keyCode = "..keyCode.." cc.KeyCode.KEY_Q" ..cc.KeyCode.KEY_Q)
            -- 调试按键
            -- 玩家按键
            if keyCode == cc.KeyCode.KEY_D then
                for i = 1, 5 do
                    -- self:roleMoveTo("left" .. i, "right" .. (6 - i), -100, 0, 5)
                    self:roleMoveTo("left" .. i, "right" .. math.random(1, 5), -100, 0, 5)
                end
            elseif keyCode == cc.KeyCode.KEY_A then
                for i = 1, 5 do
                    local role = self:getRole("left" .. i)
                    self:roleMove("left" .. i, role.originPos, 5)
                -- self:roleMoveTo("left" .. i, "right" .. i, -500, 0, 5)
                end
            elseif keyCode == cc.KeyCode.KEY_J then
                self:playRoleAnim("left1", "sword-attack01")
            elseif keyCode == cc.KeyCode.KEY_F then
                
                -- local roleA = self:getRole("a")
                -- local roleB = self:getRole("b")
                -- local focusPos = cc.pMidpoint(cc.p(roleA:getPosition()), cc.p(roleB:getPosition()))
                -- self:moveToFocusPos(focusPos)
                elseif keyCode == cc.KeyCode.KEY_3 then
                elseif keyCode == cc.KeyCode.KEY_4 then
                    elseif keyCode == cc.KeyCode.KEY_Z then
                    
                    end
        end, cc.Handler.EVENT_KEYBOARD_PRESSED)
    
    listener:registerScriptHandler(
        function(keyCode)
            keyCode = keyCode - 3
        
        -- -- 玩家按键
        -- if keyCode == cc.KeyCode.KEY_W then
        -- elseif keyCode == cc.KeyCode.KEY_S then
        -- elseif keyCode == cc.KeyCode.KEY_A then
        --     FightWorld:releaseKey(self._player, KEY_LEFT)
        -- elseif keyCode == cc.KeyCode.KEY_D then
        --     FightWorld:releaseKey(self._player, KEY_FRONT)
        -- elseif keyCode == cc.KeyCode.KEY_J then
        --     FightWorld:releaseKey(self._player, KEY_RIGHT)
        -- elseif keyCode == cc.KeyCode.KEY_K then
        --     FightWorld:releaseKey(self._player, KEY_JUMP)
        -- end
        end, cc.Handler.EVENT_KEYBOARD_PRESSED + 1)
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.touchListener, self)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色可见性
function AnimFightLayer:setRoleVisible(roleId, b)
    local role = self:getRole(roleId)
    role:setVisible(b)
end

Helper:classDefNodeGetInstance(AnimFightLayer)
return AnimFightLayer
000
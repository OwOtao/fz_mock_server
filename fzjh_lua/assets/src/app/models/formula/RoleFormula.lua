local function assert(isTrue, msg)
    if isTrue == false then
        print("error RoleFormula 公式调用出错：", msg)
    end
end

local function getRange(value, min, max)
    if value == nil then
    elseif min and value < min then
        value = min
    elseif max and value > max then
        value = max
    end
    return value
end

local RoleFormula = {
    caches = {},
    formulas = {
        qiMax = function(params)
            assert(type(params.age) == "number","qiMax age参数类型不对 type params.age:"..type(params.age))
            assert(type(params.neiliMax) == "number","qiMax neiliMax参数类型不对 type params.neiliMax:"..type(params.neiliMax))
            assert(type(params.factor) == "number","qiMax factor参数类型不对 type params.factor:"..type(params.factor))
            assert(type(params.factor) == "number","qiMax factor参数类型不对 type params.factor:"..type(params.factor))
            assert(type(params.effectCon) == "number","qiMax effectCon参数类型不对 type params.effectCon:"..type(params.effectCon))
            assert(type(params.con) == "number","qiMax con参数类型不对 type params.con:"..type(params.con))
            local age = params.age
            local neiliMax = params.neiliMax
            local factor = params.factor
            local neiLiLimit = params.neiLiLimit
            local effectCon = params.effectCon
            local con = params.con

            if age <= 140 then
                return ((neiliMax - 50) * (factor + 20) / 700 + neiLiLimit * (factor - 30) / 1000) * (1 + effectCon * 0.02) + con * 10 + 5 * (age - 14) ^ 2 + 45 * (age - 14)
            else
                return ((neiliMax - 50) * (factor + 20) / 700 + neiLiLimit * (factor - 30) / 1000) * (1 + effectCon * 0.02) + con * 10 + 85050 + (age - 140) * 50
            end
        end,

        lv = function(params)
            assert(type(params.exp) == "number","lv exp参数类型不对 type params.exp:"..type(params.exp))
            local exp = params.exp --当前人物经验

            if exp <= 1 then
                return 1
            end

            return math.max(math.floor(((exp - 1) / 0.1) ^ (1 / 3) - 4), 1)
        end,
        exp = function(params)
            assert(type(params.lv) == "number","exp lv参数类型不对 type params.lv:"..type(params.lv))
            local lv = params.lv    --当前人物等级

            if lv <= 0 then
                return 1
            end

            return math.floor((0.1 * (lv + 4) ^ 3 + 1))
        end,

        kongfu = function(params)

            assert(type(params.realNeigong) == "number","kongfu realNeigong参数类型不对 type params.realNeigong:"..type(params.realNeigong))
            assert(type(params.realQinggong) == "number","kongfu realQinggong参数类型不对 type params.realQinggong:"..type(params.realQinggong))
            assert(type(params.realZhaojia) == "number","kongfu realZhaojia参数类型不对 type params.realZhaojia:"..type(params.realZhaojia))
            assert(type(params.realWugong) == "number","kongfu realWugong参数类型不对 type params.realWugong:"..type(params.realWugong))
            assert(type(params.lv) == "number","kongfu lv参数类型不对 type params.lv:"..type(params.lv))

            local realNeigong = params.realNeigong --内功有效等级
            local realQinggong = params.realQinggong
            local realZhaojia = params.realZhaojia
            local realWugong = params.realWugong
            local lv = params.lv --人物等级

            realNeigong = math.max(realNeigong,0)
            realQinggong = math.max(realQinggong,0)
            realZhaojia = math.max(realZhaojia,0)
            realWugong = math.max(realWugong,0)
            lv = math.max(lv,1)

            return (realNeigong + realQinggong + realWugong + realZhaojia + 3 * lv) / 9
        end,
        jiaLiMax = function(params)
            local neigongLv = params.neigongLv --基本内功等级
            local prepareNeigongLv = params.prepareNeigongLv --准备内功等级经验

            if not neigongLv or not prepareNeigongLv then
                return 0
            end

            assert(type(params.neigongLv) == "number","获取jialiMax neigongLv参数类型不对 type params.neigongLv:"..type(params.neigongLv))
            assert(type(params.prepareNeigongLv) == "number","获取jialiMax neigongLv参数类型不对 type params.prepareNeigongLv:"..type(params.prepareNeigongLv))

            neigongLv = math.max(neigongLv,0)
            prepareNeigongLv = math.max(prepareNeigongLv,0)

            return math.floor((neigongLv * 0.5 + prepareNeigongLv) * 0.5)
        end,
        baseJingMax = function(params)
            local xfLv = params.xfLv --特殊技能等级
            local age = params.age  --玩家年龄
            if not xfLv then
                xfLv = 0
            end

            assert(type(params.xfLv) == "number","baseJingMax xfLv参数类型不对 type params.xfLv:"..type(params.xfLv))
            assert(type(params.age) == "number","baseJingMax age参数类型不对 type params.age:"..type(params.age))

            xfLv = math.max(xfLv,0)
            -- 年龄分段加成精力
            --[[
                14-32 一岁加成24点
                32-50 一岁加成10点
                50-60 一岁加成5点
                60-10000 一岁加成1点
            ]]
            local value_1 = getRange(age - 14, 0, 18) * 24
            local value_2 = getRange(age - 32, 0, 18) * 10
            local value_3 = getRange(age - 50, 0, 10) * 5
            local value_4 = getRange(age - 60, 0, 10000) * 1

            return 100 + xfLv / 2 + value_1 + value_2 + value_3 + value_4
        end,
        --玩家加力攻击力
        jiaLiAtk = function(params)
            local skillLv = params.skillLv --武功技能有效等级(受角色等级限制）
            local factor = params.factor --武功系数
            local jiaLi = params.jiaLi --当前加力
            local effectStr = params.effectStr --等效臂力

            assert(type(params.skillLv) == "number","jiaLiAtk skillLv参数类型不对 type params.skillLv:"..type(params.skillLv))
            assert(type(params.factor) == "number","jiaLiAtk factor参数类型不对 type params.factor:"..type(params.factor))
            assert(type(params.jiaLi) == "number","jiaLiAtk jiaLi参数类型不对 type params.jiaLi:"..type(params.jiaLi))
            assert(type(params.effectStr) == "number","jiaLiAtk effectStr参数类型不对 type params.effectStr:"..type(params.effectStr))

            skillLv = math.max(skillLv,0)
            jiaLi = math.max(jiaLi,0)
            effectStr = math.max(effectStr,1)


            return jiaLi * factor * (1 + skillLv / 500) * (0.49 + 0.001 * effectStr)
        end,
        --玩家闪躲力
        hitRate = function(params)
            local skillLv = params.skillLv --武功技能有效等级(受角色等级限制）
            local factor = params.factor --武功系数
            local effectStr = params.effectStr --等效臂力
            local exp = params.exp --角色经验

            assert(type(params.skillLv) == "number","hitRate skillLv参数类型不对 type params.skillLv:"..type(params.skillLv))
            assert(type(params.factor) == "number","hitRate factor参数类型不对 type params.factor:"..type(params.factor))
            assert(type(params.exp) == "number","hitRate exp参数类型不对 type params.exp:"..type(params.exp))
            assert(type(params.effectStr) == "number","hitRate effectStr参数类型不对 type params.effectStr:"..type(params.effectStr))

            skillLv = math.max(skillLv,0)
            effectStr = math.max(effectStr,1)
            exp = math.max(exp,1)

            return (skillLv * 15 * factor / 100 + 1000 + 0.5 * exp^0.5) * (1 + effectStr * 0.02)
        end,
        potFromExp =function(params)
            --潜能奖励公式
            assert(type(params.exp) == "number","potFromExp 参数类型不对 type(params.exp):  "..tostring(type(params.exp)))
            assert(type(params.fy) == "number","potFromExp 参数类型不对 type(params.fy):  "..tostring(type(params.fy)))
            assert(type(params.sklv) == "number","potFromExp 参数类型不对 type(params.sklv):  "..tostring(type(params.sklv)))

            local exp = params.exp      --经验
            local fy = params.fy        --福缘
            local sklv = params.sklv    --武功
            local pot = 0

            exp = math.max(exp,1)
            fy = math.max(fy,0)
            sklv = math.max(sklv,0)

            if exp > 1000 and exp < 2000 then
                pot = 18000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            elseif exp > 2000 and exp < 5000 then
                pot = 12000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            elseif exp > 5000 and exp < 15000 then
                pot = 10000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            elseif exp > 15000 and exp < 80000 then
                pot = 8000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            elseif exp > 80000 and exp < 300000 then
                pot = 4500 * 2 ^ (sklv / 140) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            elseif exp > 300000 and exp < 500000 then
                pot = 4860 * ((sklv - 46) ^ 2 / 14400 + 1) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            elseif exp > 500000 and exp < 1000000 then
                pot = 5249 * ((sklv - 55) ^ 2 / 24336 + 1) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            elseif exp > 1000000 and exp < 5000000 then
                pot = 5668 * (2 ^ (sklv / 364)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            elseif exp > 5000000 and exp < 15000000 then
                pot = 6122 * (2 ^ (sklv / 527)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            elseif exp > 15000000 and exp < 30000000 then
                pot = 6612 * (2 ^ (sklv / 665)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            elseif exp > 30000000 then
                pot = 7141 * ( 2 ^ (sklv / 1200)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / 3600 * 360
            end
            return math.floor(pot)
        end,
        --碎银奖励公式
        moneyFromExp = function(params)
            assert(type(params.exp) == "number","moneyFromExp 参数类型不对 type(params.exp):  "..tostring(type(params.exp)))
            assert(type(params.fy) == "number","moneyFromExp 参数类型不对 type(params.fy):  "..tostring(type(params.fy)))
            assert(type(params.sklv) == "number","moneyFromExp 参数类型不对 type(params.sklv):  "..tostring(type(params.sklv)))

            local money = 0
            local exp = params.exp      --经验
            local fy = params.fy        --福缘
            local sklv = params.sklv    --武功

            exp = math.max(exp,1)
            fy = math.max(fy,0)
            sklv = math.max(sklv,0)

            if 1000 < exp and exp < 2000 then
            elseif 2000 < exp and exp < 5000 then
            elseif 5000 < exp and exp <15000 then
                money = 2500 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
            elseif 15000 < exp and exp < 80000 then
                money = 3000 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
            elseif 80000 < exp and exp < 300000 then
                money = 3500 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
            elseif 300000 < exp and exp < 500000 then
                money = 4000 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
            elseif 500000 < exp and exp < 1000000 then
                money = 4800 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
            elseif 1000000 < exp and exp < 5000000 then
                money = 5500 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
            elseif 5000000 < exp and exp < 15000000 then
                money = 6000 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
            elseif 15000000 < exp and exp < 30000000 then
                money = 6000 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
            elseif 30000000 < exp then
                money = 6500 / 3600 * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
            end

            return math.floor(money)
        end,
        --打坐内力回复速度 (每秒)
        neiLiSpeed = function(params)
            assert(type(params.neigongLv) == "number","neiLiSpeed 参数类型不对 type(params.neigongLv):  "..tostring(type(params.neigongLv)))
            assert(type(params.factor) == "number","neiLiSpeed 参数类型不对 type(params.factor):  "..tostring(type(params.factor)))
            assert(type(params.effectCon) == "number","neiLiSpeed 参数类型不对 type(params.effectCon):  "..tostring(type(params.effectCon)))

            local neigongLv = params.neigongLv  --有效内功等级（受人物等级限制）
            local factor = params.factor        --内力系数
            local effectCon = params.effectCon  --等效根骨

            neigongLv = math.max(neigongLv,0)
            effectCon = math.max(effectCon,1)

            return (neigongLv * factor * 0.0015 + 5) * (1 + 0.005 * effectCon)
        end,
        --内力上限
        neiLiLimit = function(params)
            -- body
            -- assert(type(params.neigongLv) == "number","neiLiLimit 参数类型不对 type(params.neigongLv):  "..tostring(type(params.neigongLv)))
            assert(type(params.effectCon) == "number","neiLiLimit 参数类型不对 type(params.effectCon):  "..tostring(type(params.effectCon)))
            assert(type(params.effectStr) == "number","neiLiLimit 参数类型不对 type(params.effectStr):  "..tostring(type(params.effectStr)))
            assert(type(params.effectDex) == "number","neiLiLimit 参数类型不对 type(params.effectDex):  "..tostring(type(params.effectDex)))

            local neigongLv = params.neigongLv      --基本内功等级
            local effectCon = params.effectCon      --等效根骨
            local effectStr = params.effectStr      --等效臂力
            local effectDex = params.effectDex      --等效身法

            effectCon = math.max(effectCon,1)
            effectStr = math.max(effectStr,1)
            effectDex = math.max(effectDex,1)
            neigongLv = math.max(neigongLv,0)

            if not neigongLv or type(neigongLv) ~= "number" then
                return 50
            end

            return math.max((neigongLv * 10) * (2 + (0.01 * effectCon)+(0.003 * effectStr)+(0.003 * effectDex)),50)
        end,
        --血气上限伤害
        qiMaxAtk = function(params)
            assert(type(params.wpAtk) == "number","qiMaxAtk 参数类型不对 type(params.wpAtk):  "..tostring(type(params.wpAtk)))
            assert(type(params.jiaLiAtk) == "number","qiMaxAtk 参数类型不对 type(params.jiaLiAtk):  "..tostring(type(params.jiaLiAtk)))
            assert(type(params.zhaoAtk) == "number","qiMaxAtk 参数类型不对 type(params.zhaoAtk):  "..tostring(type(params.zhaoAtk)))
            assert(type(params.protect) == "number","qiMaxAtk 参数类型不对 type(params.protect):  "..tostring(type(params.protect)))
            assert(type(params.partFactor) == "number","qiMaxAtk 参数类型不对 type(params.partFactor):  "..tostring(type(params.partFactor)))

            local wpAtk = params.wpAtk              --兵器攻击
            local jiaLiAtk = params.jiaLiAtk        --加力攻击
            local zhaoAtk = params.zhaoAtk          --招式攻击
            local protect = params.protect          --攻击部位防护
            local partFactor = params.partFactor    --攻击部位防护系数

            return math.max(math.floor((wpAtk + jiaLiAtk + zhaoAtk - protect * 0.3) / (1 + protect / 100) * partFactor),0)
        end,
        --气血伤害
        qiAtk = function(params)
            assert(type(params.zhaoAtkDamage) == "number","qiAtk 参数类型不对 type(params.zhaoAtkDamage):  "..tostring(type(params.zhaoAtkDamage)))
            assert(type(params.targetDef) == "number","qiAtk 参数类型不对 type(params.targetDef):  "..tostring(type(params.targetDef)))
            assert(type(params.partFactor) == "number","qiAtk 参数类型不对 type(params.partFactor):  "..tostring(type(params.partFactor)))

            local zhaoAtkDamage = params.zhaoAtkDamage      --招式伤害
            local targetDef = params.targetDef       --对方防御
            local partFactor = params.partFactor    --攻击部位防护系数

            return math.floor(zhaoAtkDamage * (1 / (1 + targetDef / 1000)) * partFactor)
        end,
        --平均气血伤害
        avgQiAtk = function(params)
            assert(type(params.zhaoAtkDamage) == "number","avgQiAtk 参数类型不对 type(params.zhaoAtkDamage):  "..tostring(type(params.zhaoAtkDamage)))
            assert(type(params.targetDef) == "number","avgQiAtk 参数类型不对 type(params.targetDef):  "..tostring(type(params.targetDef)))

            local zhaoAtkDamage = params.zhaoAtkDamage      --招式伤害
            local targetDef = params.targetDef       --对方防御

            return math.floor(zhaoAtkDamage * ( 1 / (1 + targetDef / 1000)) * 1)
        end,
        --单位时间气血恢复
        addQi = function(params)
            assert(type(params.finalQiMax) == "number","addQi 参数类型不对 type(params.finalQiMax):  "..tostring(type(params.finalQiMax)))
            assert(type(params.effectCon) == "number","addQi 参数类型不对 type(params.effectCon):  "..tostring(type(params.effectCon)))

            local finalQiMax = params.finalQiMax
            local effectCon = params.effectCon

            return ((1/25) * math.floor(finalQiMax) + effectCon * 0.2) / 10
        end,
        --单位时间气血最大值回复
        addQiMax = function(params)
            assert(type(params.finalQiMax) == "number","addQiMax 参数类型不对 type(params.finalQiMax):  "..tostring(type(params.finalQiMax)))

            local finalQiMax = params.finalQiMax

            return ((1/2880) * finalQiMax + 0.5) / 10
        end,
        --npc恢复气血数值
        npcAddQi = function(params)
            assert(type(params.finalQiMax) == "number","npcAddQi 参数类型不对 type(params.finalQiMax):  "..tostring(type(params.finalQiMax)))
            assert(type(params.finalNeiliMax) == "number","npcAddQi 参数类型不对 type(params.finalNeiliMax):  "..tostring(type(params.finalNeiliMax)))
            assert(type(params.time) == "number","npcAddQi 参数类型不对 type(params.time):  "..tostring(type(params.time)))
            assert(type(params.qi) == "number","npcAddQi 参数类型不对 type(params.qi):  "..tostring(type(params.qi)))

            local finalQiMax = params.finalQiMax
            local qi = params.qi
            local finalNeiliMax = params.finalNeiliMax
            local time = params.time

            return math.min(finalQiMax,math.max(0.2,qi) + 0.04 * finalNeiliMax + (time / 2) * (18 + 0.018 * finalNeiliMax))
        end,
        --npc恢复气血百分比数值
        npcAddQiPercent = function(params)
            assert(type(params.finalQiMax) == "number","npcAddQiPercent 参数类型不对 type(params.finalQiMax):  "..tostring(type(params.finalQiMax)))
            assert(type(params.finalNeiliMax) == "number","npcAddQiPercent 参数类型不对 type(params.finalNeiliMax):  "..tostring(type(params.finalNeiliMax)))
            assert(type(params.time) == "number","npcAddQiPercent 参数类型不对 type(params.time):  "..tostring(type(params.time)))
            assert(type(params.qi) == "number","npcAddQiPercent 参数类型不对 type(params.qi):  "..tostring(type(params.qi)))

            local finalQiMax = params.finalQiMax
            local qi = params.qi
            local finalNeiliMax = params.finalNeiliMax
            local time = params.time

            return math.min(finalQiMax,math.max(0.2,qi)+0.04*finalNeiliMax+(time/2)*(18+0.018*finalNeiliMax))/finalQiMax
        end,
        --npc恢复气血
        npcAddNeili = function(params)
            assert(type(params.finalNeiliMax) == "number","npcAddNeili 参数类型不对 type(params.finalNeiliMax):  "..tostring(type(params.finalNeiliMax)))
            assert(type(params.time) == "number","npcAddNeili 参数类型不对 type(params.time):  "..tostring(type(params.time)))
            assert(type(params.qi) == "number","npcAddNeili 参数类型不对 type(params.qi):  "..tostring(type(params.qi)))
            assert(type(params.neili) == "number","npcAddNeili 参数类型不对 type(params.neili):  "..tostring(type(params.neili)))
            assert(type(params.afterQi) == "number","npcAddNeili 参数类型不对 type(params.afterQi):  "..tostring(type(params.afterQi)))

            local qi = params.qi
            local neili = params.neili
            local afterQi = params.afterQi
            local finalNeiliMax = params.finalNeiliMax
            local time = params.time

            return math.min(finalNeiliMax,neili+(time-2*(afterQi-math.max(0.2,qi))/(18+0.018*finalNeiliMax)*2)*(0.02*finalNeiliMax+10))
        end,
        --当前招式攻击前摇
        zhaoBeginDuration = function(params)
            assert(type(params.preDuration) == "number","zhaoBeginDuration 参数类型不对 type(params.preDuration):  "..tostring(type(params.preDuration)))
            assert(type(params.skillLv) == "number","zhaoBeginDuration 参数类型不对 type(params.skillLv):  "..tostring(type(params.skillLv)))
            assert(type(params.factor) == "number","zhaoBeginDuration 参数类型不对 type(params.factor):  "..tostring(type(params.factor)))
            assert(type(params.effectDex) == "number","zhaoBeginDuration 参数类型不对 type(params.effectDex):  "..tostring(type(params.effectDex)))

            local preDuration = params.preDuration
            local skillLv = params.skillLv
            local factor = params.factor
            local effectDex = params.effectDex

            return preDuration * 1.5 / math.min((1.08 + skillLv * factor * 0.00001 + effectDex / 270), 3.6)
        end,
        --当前招式攻击后摇
        zhaoAfterDuration = function(params)
            assert(type(params.aftDuration) == "number","zhaoAfterDuration 参数类型不对 type(params.aftDuration):  "..tostring(type(params.aftDuration)))
            assert(type(params.skillLv) == "number","zhaoAfterDuration 参数类型不对 type(params.skillLv):  "..tostring(type(params.skillLv)))
            assert(type(params.factor) == "number","zhaoAfterDuration 参数类型不对 type(params.factor):  "..tostring(type(params.factor)))
            assert(type(params.effectDex) == "number","zhaoAfterDuration 参数类型不对 type(params.effectDex):  "..tostring(type(params.effectDex)))

            local aftDuration = params.aftDuration
            local skillLv = params.skillLv
            local factor = params.factor
            local effectDex = params.effectDex

            return aftDuration *1.5 / math.min((1 + skillLv * factor * 0.00001 + effectDex / 200), 3)
        end,
        --出招伤害
        zhaoAtkDamage = function(params)
            assert(type(params.zhaoAtk) == "number","zhaoAtkDamage 参数类型不对 type(params.zhaoAtk):  "..tostring(type(params.zhaoAtk)))
            assert(type(params.skillDamRate) == "number","zhaoAtkDamage 参数类型不对 type(params.skillDamRate):  "..tostring(type(params.skillDamRate)))
            assert(type(params.roleAtk) == "number","zhaoAtkDamage 参数类型不对 type(params.roleAtk):  "..tostring(type(params.roleAtk)))

            local roleAtk = params.roleAtk  --玩家攻击力
            local zhaoAtk = params.zhaoAtk  --招式攻击力
            local skillDamRate = params.skillDamRate --招式伤害系数

            return math.min((2 * math.log(150 + roleAtk * (1 + zhaoAtk)) -8.5), 8) * (skillDamRate + roleAtk * (1 + zhaoAtk) / 1000 * skillDamRate)
        end,
            }
}

function RoleFormula:call(name, params)
    params = self:map(params)
    return self:get(name)(params)
end

function RoleFormula:map(params)
    for k, v in pairs(params) do
        if type(v) == "function" then
            params[k] = v()
        end
    end
    return params
end

function RoleFormula:get(name)
    return self.formulas[name]
end

return RoleFormula
000000
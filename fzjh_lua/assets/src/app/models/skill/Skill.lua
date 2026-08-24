local SkillConst = require("app.models.skill.SkillConst")
local SkillFactory = require("app.models.skill.factory.SkillFactory")
local StringUtil = require("app.extends.StringUtil")
local SkillResManager = require("app.models.skill.SkillResManager")
local LogSystem = require("app.models.LogSystem.LogSystem")
local ErrmsgRecord = require("app.models.Record.ErrmsgRecord.ErrmsgRecord")

local function print()
end
local skillMap = {}

local skillNameDict = {}

-- 各种系数
local function initFactors(skill)
    if not skill then
        return
    end
    local factors =
        {
            neili = skill.neili,
            atk = skill.atk,
            hitRate = skill.hitRate,
            def = skill.def,
            parry = skill.parry,
            dodge = skill.dodge,
            atkSpd = skill.atkSpd,
            HpRate = skill.HpRate,
            powerDamRate = skill.powerDamRate,
            powerAtkRate = skill.powerAtkRate
        }
    -- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 技能伤害)
    skill.factors = createEncryptTable(factors)
end

-- 学习条件
local function initLearn(skill)
    if not skill then
        return
    end
    local learn =
        {
            potEfficiency = skill.potEfficiency
        }
    local requirement = {}
    for i = 1, 10 do
        -- 解析10个条件， 必须在属性及属性名都存在才算一个条件
        if skill["conditionType_" .. i] and skill["ConditionId_" .. i] then
            local tab =
                {
                    type = skill["conditionType_" .. i],
                    name = skill["ConditionId_" .. i],
                    cond = skill["Logic_" .. i],
                    count = skill["conditonValue_" .. i]
                }
            table.insert(requirement, tab)
        end
    end
    -- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 条件)
    learn.requirement = createEncryptTable(requirement)
    
    -- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 潜能转换率)
    skill.learn = createEncryptTable(learn)
end

-- 技能类型
local function initMethods(skill)
    if not skill then
        return
    end
    local method = {}
    if skill.methods then
        local index = 0
        local str = tostring(skill.methods)
        if string.find(str, ",", index) == nil then
            method = {tonumber(str)}
        else
            -- while string.find(str, ",", index) ~= nil do
            --     local sStart, sEnd = string.find(str, ",", index)
            --     table.insert(method, tonumber(string.sub(str, sStart - 1, sEnd - 1)))
            --     index = sEnd + 1
            -- end
            -- table.insert(method, tonumber(string.sub(str, -1, -1)))

            local array = string.split(skill.methods,",")
            for i,v in ipairs(array) do
                table.insert(method, tonumber(v))
            end
        end
    end
    -- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 技能类型)
    skill.methods = createEncryptTable(method)
end

local function initWxclassify(skill)
    if not skill then
        return
    end
    local wxclassify = {}
    if skill.wxclassify then
        local array = string.split(skill.wxclassify,",")
        for i,v in ipairs(array) do
            table.insert(wxclassify, v)
        end
    end
    -- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 技能类型)
    skill.wxclassify = createEncryptTable(wxclassify)
end

-- 武器类型
local function initWeapontype(skill)
    if not skill then
        return
    end
    local weapontype = {}
    if skill.weapontype then
        if skill.weapontype == 0 then
            -- print("skill.weapontype == 0 ",skill.id)
            weapontype = {}
        else
            local index = 0
            local str = tostring(skill.weapontype)
            if string.find(str, ",", index) == nil then
                weapontype = {str}
            else
                local array = string.split(skill.weapontype,",")
                for i,v in ipairs(array) do
                    table.insert(weapontype, v)
                end
            end
        end
    end

    skill.weapontype = weapontype
end

-- 初始化技能自动招式
local autoSkillMap = nil
local newSkillanim = nil
local function initAutoSkill(skill)
    if autoSkillMap == nil then
        autoSkillMap = assert(requireWithEncrypt("script.skill.skillAuto"))
        newSkillanim = assert(require("script.skill.newSkillanim").Sheet1)
    end
    
    local autoSkills = autoSkillMap[skill.id]
    if autoSkills == nil then
        -- print("技能[" .. skill.name .. "]没有主动招式")
        return
    end
    -- print("技能[" .. skill.name .. "]有主动招式")
    -- print("技能[" .. skill.id .. "]有主动招式")
    skill.autoSkills = {}
    for k, autoSkill in pairs(autoSkills) do
        assert(type(autoSkill.action) == "string", "autoSkill.action = " .. tostring(autoSkill.action))
        
        table.insert(skill.autoSkills, autoSkill)
        
        -----------------------------------------------------------------------------------------------------------
        -- @author TangJian
        -- @time 2016/11/01 11:06:05
        -- @desc
        do
            -- autoSkill.id = #skill.autoSkills
            
            -- 初始化攻击动画
            local anims = {}

            if #skill.weapontype == 0 then
                for i = 1, 10 do
                    local anim = autoSkill["anim" .. i]
                    local hitPos = autoSkill["hitPos" .. i]
                    local offset = autoSkill["offset" .. i]
                    local speed = autoSkill["speed" .. i]
                    if anim and hitPos and offset then
                        table.insert(anims,
                            {
                                anim = anim,
                                hitPos = hitPos,
                                offset = offset,
                                speed = Helper:getDef(speed, 1)
                            })
                    else
                        break
                    end
                end
            else
                for i = 1, 10 do
                    local anim = autoSkill["anim" .. i]
                    local speed = autoSkill["speed" .. i]
                    if anim then
                        local tab = {}
                       
                        for index,value in ipairs(skill.weapontype) do
                            local weaponTypeNum = StringUtil:subNum(value)
                            -- print("anim =",anim,"weaponTypeNum = ",weaponTypeNum)
                            local newAnimId = anim..weaponTypeNum
                            
                            local newSkillanimParam = newSkillanim[newAnimId]
                            local hitPos = newSkillanimParam["location"]
                            local offset = newSkillanimParam["offset"]


                            tab[value] = {
                                anim = newAnimId,
                                hitPos = hitPos,
                                offset = offset,
                                speed = Helper:getDef(speed, 1) 

                            }
                        end
                        table.insert(anims,tab)  
                    else
                        break
                    end
                    
                end    
            end

            if #anims > 0 then
                autoSkill.anims = anims
            end
        end
    end
    
    table.sort(skill.autoSkills, function(a, b)
        if not a.lv then
            return false
        elseif not b.lv then
            return true
        elseif a.lv == b.lv then
            return a.id < b.id
        else
            return a.lv < b.lv
        end
    end)


-- if skill.id == "raozhiroujianfa" then
-- 	Helper:print_lua_table(skill.autoSkills)
-- 	assert(nil)
-- end
end

-- 初始化闪避招式
local dodgeSkillMap
local function initDodgeSkill(skill)
    -- print("初始化闪避招式")
    if dodgeSkillMap == nil then
        -- local jsonData = assert(cc.FileUtils:getInstance():getStringFromFile("script/skill/skillDodge.json"))
        -- dodgeSkillMap = assert(json.decode(jsonData))
        dodgeSkillMap = assert(require("script.skill.skillDodge"))
    -- Helper:print_lua_table(dodgeSkillMap)
    end
    
    local dodgeSkills = dodgeSkillMap[skill.id]
    if dodgeSkills == nil then
        -- print("技能[" .. skill.name .. "]没有闪避招式")
        return
    end
    -- print("技能[" .. skill.name .. "]有闪避招式")
    for k, dodgeSkill in pairs(dodgeSkills) do
        if skill.dodgeSkills == nil then
            skill.dodgeSkills = {}
        end
        table.insert(skill.dodgeSkills, dodgeSkill)
    end
end

-- 初始化招架招式
local parrySkillMap
local function initParrySkill(skill)
    -- print("初始化招架招式")
    if parrySkillMap == nil then
        parrySkillMap = assert(require("script.skill.skillParry"))
    -- Helper:print_lua_table(parrySkillMap)
    end
    
    local parrySkills = parrySkillMap[skill.id]
    if parrySkills == nil then
        -- print("技能[" .. skill.name .. "]没有招架招式")
        return
    end
    -- print("技能[" .. skill.name .. "]有招架招式")
    for k, parrySkill in pairs(parrySkills) do
        if skill.parrySkills == nil then
            skill.parrySkills = {}
        end
        table.insert(skill.parrySkills, parrySkill)
    end
end

-- 初始化攻击部位
local attackPositionMap
local function initAttackPosition(skill)
    -- print("初始化技能攻击部位")
    if attackPositionMap == nil then
        attackPositionMap = assert(require("script.skill.skillAttackPosition"))
        attackPositionMap = attackPositionMap["部位表示"]
        
        -- Helper:print_lua_table(attackPositionMap)
        for k, attackPosition in pairs(attackPositionMap) do
            local parts = {}
            local realParts = {}
            for i = 1, 99 do
                local part = attackPosition["Part" .. i]
                if part ~= nil and part ~= "" then
                    table.insert(parts, part)
                end
                local realPart = attackPosition["realPart" .. i]
                if realPart ~= nil and realPart ~= "" then
                    table.insert(realParts, realPart)
                end
            end
            attackPosition.parts = parts
            attackPosition.realParts = realParts
        -- attackPositionMap[attackPosition.Id] = attackPosition
        end
    
    end
    local attackPositions = attackPositionMap[skill.id]
    if attackPositions == nil then
        -- print("技能["..skill.name.."]没有攻击部位")
        return
    end
    -- print("技能["..skill.name.."]有攻击部位")
    for k, attackPosition in pairs(attackPositions) do
        if skill.attackPositions == nil then
            skill.attackPositions = {}
        end
        table.insert(skill.attackPositions, attackPosition)
    end
end

-- 伤害类型结果初始化
local attackResultMap
local function initAttackResult()
    attackResultMap = assert(require("script.skill.skillAttackResult"))
    attackResultMap = attackResultMap["伤害描述"]
end

local function initSkillDsc(skill)
    if not skill.dsc then
        return
    end

    if skill:getAtkDamageClass() and skill:getDamageClassName() then
        if skill:isQuanJiaoAttack() or skill:isWeaponAttack() then
            skill.dsc = skill.dsc .. "\n武学攻击属性："..skill:getDamageClassName()
        end
    end

    if skill:getDefDamageClass() and skill:getDefClassName() then
        if skill:isParrySkill() then
            skill.dsc = skill.dsc .. "\n招架防御属性："..skill:getDefClassName()
        end
    end
end

-- 技能初始化
local function initSkill(skill)
    skill.onlyId = Helper:getOnlyId()
    initFactors(skill)
    initLearn(skill)
    initMethods(skill)
    initWxclassify(skill)
    
    if WEAPONSUBTYPE_IS_OPEN == true then
        initWeapontype(skill)
    end

    initAutoSkill(skill)
    initDodgeSkill(skill)
    initParrySkill(skill)
    initAttackPosition(skill)
    initSkillDsc(skill)
    local skillColor = ""
    if skill.type == SKILL_TYPE_BASE or skill.type == SKILL_TYPE_SPECIAL or skill.type == SKILL_TYPE_DUSHU then
        skillColor = "HIW"
    else
        for i, v in ipairs(skill.methods) do
            if v == SKILL_METHOD_TYPE_NEIGONG then
                break
            elseif v == SKILL_METHOD_TYPE_QUANJIAO then
                skillColor = "HIY"
                break
            elseif v == SKILL_METHOD_TYPE_QINGGONG then
                skillColor = "HIG"
                break
            elseif v == SKILL_METHOD_TYPE_JIAN or v == SKILL_METHOD_TYPE_DAO or v == SKILL_METHOD_TYPE_GUN or v == SKILL_METHOD_TYPE_ANQI or v == SKILL_METHOD_TYPE_BIANFA or v == SKILL_METHOD_TYPE_SHUANGCHI or v == SKILL_METHOD_TYPE_QIN then
                skillColor = "HIC"
                break
            end
        end
    end
    
    if skillColor == "" then
        skillColor = skill.nameColor
        if skillColor == nil then
            skillColor = "HIW"
        end
    end
    skill._NoColorName = skill.name
    skill.name = skillColor .. skill.name .. "NOR"
    
    -- add by XiaoZhiWei 2017/03/14 16:53:33 如果是内功的话默认给他们加一个招式 回复
    skill.zhaoList = Helper:getDef(skill.zhaoList, {})
-- if skill:canPrepareType(SKILL_METHOD_TYPE_NEIGONG) == true then
--     table.insert(skill.zhaoList, "huifu")
-- end
end

-- @desc 创建技能
local function createSkill(skillData)
    
    local skill
    if skillData.id == "zhougongzhishu" then
         skill = SkillFactory:createSkill(SkillConst.SkillType.ZHOU_GONG_ZHI_SHU)
    elseif skillData.id == SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM) then
        skill = SkillFactory:createSkill(SkillConst.SkillType.XI_SUI_JING)
    elseif skillData.id == SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_MERIDIAN) then
        skill = SkillFactory:createSkill(SkillConst.SkillType.DONG_YUAN_LU)
    else
        skill = SkillFactory:createSkillById(skillData.id)
    end

    return inherit(skillData, skill)
end

local function initSkillMap()
    local mapData = assert(requireWithEncrypt("script.skill.skill"))

    -- Helper:print_lua_table(mapData)
    local TuJianUtil = require("app.models.TuJian.TuJianUtil")
    
    for key, skill in pairs(mapData.skills) do
        if skill.type and type(skill.type) ~= "number" then
            skill.type = tonumber(skill.type)
        end
        skillMap[key] = createSkill(skill)
        skillMap[key].id = key
        initSkill(skillMap[key])
        
        TuJianUtil:initTuJianTable(skill)
        
        -- 名字 ID
        skillMap[skill.name] = skillMap[key]
        skillNameDict[skill._NoColorName] = skillMap[key]
    end

    skillMap["jibenqianjiao1"] = skillMap["jibenquanjiao"]
    skillMap["jibenqianjiao2"] = skillMap["jibenquanjiao"]
end

initSkillMap()-- 初始化技能列表
initAttackResult()-- 初始化伤害类型结果

local Skill =
    {
        activeZhaoMap = {}, -- 主动招式map
        skillEffectMap = {}, -- 技能效果map
        skillRelationMap = {}, -- 技能与招式关系map
        zhaosRelationMap = {}, -- 技能招式之间关系map
        _stageDesc = {      -- 阶段描述
            {lv = 10, dsc = "BLU不堪一击"},
            {lv = 20, dsc = "BLU毫不足虑"},
            {lv = 30, dsc = "BLU不足挂齿"},
            {lv = 40, dsc = "BLU初学乍练"},
            {lv = 50, dsc = "BLU勉勉强强"},
            {lv = 60, dsc = "HIB初窥门径"},
            {lv = 70, dsc = "HIB初出茅庐"},
            {lv = 80, dsc = "HIB略知一二"},
            {lv = 90, dsc = "HIB普普通通"},
            {lv = 100, dsc = "HIB平平淡淡"},
            {lv = 110, dsc = "CYN平淡无奇"},
            {lv = 120, dsc = "CYN粗通皮毛"},
            {lv = 130, dsc = "CYN半生不熟"},
            {lv = 140, dsc = "CYN马马虎虎"},
            {lv = 150, dsc = "CYN略有小成"},
            {lv = 160, dsc = "HIC已有小成"},
            {lv = 170, dsc = "HIC鹤立鸡群"},
            {lv = 180, dsc = "HIC驾轻就熟"},
            {lv = 190, dsc = "HIC青出于蓝"},
            {lv = 200, dsc = "HIC融会贯通"},
            {lv = 210, dsc = "GRN心领神会"},
            {lv = 220, dsc = "GRN炉火纯青"},
            {lv = 230, dsc = "GRN了然于胸"},
            {lv = 240, dsc = "GRN略有大成"},
            {lv = 250, dsc = "GRN已有大成"},
            {lv = 270, dsc = "YEL豁然贯通"},
            {lv = 290, dsc = "YEL出类拔萃"},
            {lv = 310, dsc = "YEL无可匹敌"},
            {lv = 330, dsc = "YEL技冠群雄"},
            {lv = 350, dsc = "YEL神乎其技"},
            {lv = 370, dsc = "HIY出神入化"},
            {lv = 390, dsc = "HIY非同凡响"},
            {lv = 410, dsc = "HIY傲视群雄"},
            {lv = 430, dsc = "HIY登峰造极"},
            {lv = 450, dsc = "HIY无与伦比"},
            {lv = 470, dsc = "RED所向披靡"},
            {lv = 500, dsc = "RED一代宗师"},
            {lv = 525, dsc = "RED精深奥妙"},
            {lv = 550, dsc = "RED神功盖世"},
            {lv = 575, dsc = "RED举世无双"},
            {lv = 600, dsc = "WHT惊世骇俗"},
            {lv = 625, dsc = "WHT撼天动地"},
            {lv = 650, dsc = "WHT震古铄今"},
            {lv = 675, dsc = "WHT超凡入圣"},
            {lv = 700, dsc = "WHT威镇寰宇"},
            {lv = 725, dsc = "HIW空前绝后"},
            {lv = 750, dsc = "HIW天人合一"},
            {lv = 775, dsc = "HIW深藏不露"},
            {lv = 800, dsc = "HIW深不可测"},
            {lv = 850, dsc = "HIW返璞归真"}
        },
        _stageDesc2 = -- 门派心法，读书识字
        {
            {lv = 10, dsc = "BLU新学乍用"},
            {lv = 20, dsc = "BLU不甚了了"},
            {lv = 40, dsc = "BLU不知端倪"},
            {lv = 60, dsc = "BLU平淡无奇"},
            {lv = 70, dsc = "HIB司空见惯"},
            {lv = 80, dsc = "HIB初窥门径"},
            {lv = 100, dsc = "HIB略知一二"},
            {lv = 130, dsc = "CYN茅塞顿开"},
            {lv = 150, dsc = "CYN略识之无"},
            {lv = 180, dsc = "CYN滚瓜烂熟"},
            {lv = 200, dsc = "HIC马马虎虎"},
            {lv = 230, dsc = "HIC轻车熟路"},
            {lv = 250, dsc = "HIC运用自如"},
            {lv = 280, dsc = "GRN触类旁通"},
            {lv = 300, dsc = "GRN深入浅出"},
            {lv = 320, dsc = "GRN已有小成"},
            {lv = 350, dsc = "YEL心领神会"},
            {lv = 380, dsc = "YEL了然於胸"},
            {lv = 400, dsc = "YEL见多识广"},
            {lv = 430, dsc = "HIY无所不通"},
            {lv = 450, dsc = "HIY卓尔不群"},
            {lv = 480, dsc = "HIY满腹经纶"},
            {lv = 500, dsc = "RED豁然贯通"},
            {lv = 530, dsc = "RED博古通今"},
            {lv = 560, dsc = "RED博大精深"},
            {lv = 600, dsc = "WHT超群绝伦"},
            {lv = 630, dsc = "WHT举世无双"},
            {lv = 670, dsc = "WHT独步天下"},
            {lv = 700, dsc = "HIW震古铄今"},
            {lv = 750, dsc = "HIW超凡入圣"},
            {lv = 800, dsc = "HIW深不可测"}
        }

    }

-- 技能map, 外部可以接入
local self_create_skillmap = {}

function Skill:getSkillsNameDict()
    return skillNameDict
end

-- 设置一个技能, 在getskill的时候可以查询到
function Skill:setSkillNewData(skillId, skill)
    self_create_skillmap[skillId] = skill
end

function Skill:getSkillNew(skillId)
    return self_create_skillmap[skillId]
end

function Skill:getSkill(skillId)
    local skill = self:getSkillNew(skillId)
    if skill then
        return skill
    end
    
    local success, result = pcall(function()
        return assert(skillMap[skillId], "Skill:getSkill error, skillId is " .. tostring(skillId))
    end)
    
    if not success then
        local traceback_msg = debug.traceback()
        print(result)
        print(traceback_msg)
        ErrmsgRecord:addErrmsg(result .. " ; " .. traceback_msg)
        return nil
    end
    
    return result
end

function Skill:getSkillMap()
    return skillMap
end

function Skill:getAutoSkill(id)
    return assert(autoSkillMap[id])
end

function Skill:getAttackPosition(id)
    if attackPositionMap[id] == nil then
        return attackPositionMap["通用"]
    else
        return assert(attackPositionMap[id])
    end
end

function Skill:consult(role, skillId, times)-- 请教
    if times == nil then
        times = 1
    end
    local roleSkill = role:getSkill(skillId)
    if roleSkill == nil then
        roleSkill = {id = skillId, exp = 0}
    end
    
    local skill = Skill:getSkill(skillId)
    local skillExp = roleSkill.exp
    local skillLv = skill:getLv(skillExp)
    
    local roleLv = math.floor(role:getLv())
    
    local Npc = require("app.models.npc.Npc")
    local teacher = Npc:getNpc(role:getAttr("teacherId"))
    
    local tSkillLv = self:getLv(teacher:getAttr("tSkills")[skillId].exp)
    
    if (skillLv + times) > tSkillLv then
        PopText("这项技能你的程度已经不输你师父了。")
        return false
    end
    
    if roleLv < (skillLv + times) then
        PopText("也许是缺乏实战经验，你对[" .. tostring(role:getAttr("teacherName")) .. "]的回答总是无法领会。")
        return false
    end
    
    if skill.qingjiaojuexuedengjixianzhi ~= nil and tonumber(skillLv + times) > tonumber(skill.qingjiaojuexuedengjixianzhi) then
        PopText("这个武功已经无法通过请教来提升了")
        return false
    end
    
    if self:canLevelUp(role, skill, skillLv + times) ~= true then
        PopText(self:canLevelUp(role, skill, skillLv + times))
        return false
    end
    -- local upgradeNeedExp = (math.ceil(skill:getExp(skillLv + times)) - skillExp)/ skill:getPotEfficiency(role) * 100
    local upgradeNeedExp = math.ceil((skill:getExp(skillLv + times) - skillExp) / skill:getPotEfficiency(role) * 100)
    
    if role.pot >= upgradeNeedExp then
        local pot = role:getNumAttr("pot") - (upgradeNeedExp)
        role:setAttr("pot", pot)
        roleSkill.exp = math.ceil(roleSkill.exp + (skill:getExp(skillLv + times) - skillExp))
        role:setSkill(skillId, roleSkill)
        
        if skill.type == SKILL_TYPE_SPECIAL then
            role:setJingMax()
        end

        --@desc 判断是否解锁毒药配方)
        PoisonFormula:unlockPoisonFormulaBySkillLvUp(skillId)
        --@RefType [app.models.Poison.PoisonUtil#PoisonUtil]
        local PoisonUtil = require("app.models.Poison.PoisonUtil")
        PoisonUtil:openPoisonSysFromSkill(role,skillId)
        
        if times > 0 then
            RichPrint("main", "HIC你向[" .. tostring(role:getAttr("teacherName")) .. "]请教了有关「" .. tostring(skill.name) .. "HIC」的疑问。")
            RichPrint("main", "你听了[" .. tostring(role:getAttr("teacherName")) .. "]的指导，似乎有些心得。")
            RichPrint("main", "HIC你的[" .. tostring(skill.name) .. "HIC]进步了！")
        end
        return true
    else
        PopText("你的潜能不够这次学习了。")
        return false
    end
end


local attrList =
    {
        name = "无名",
        sex = "性别",
        age = "年龄",
        looks = "容貌",
        luck = "福缘",
        str = "臂力",
        int = "悟性",
        con = "根骨",
        dex = "身法",
        secStr = "臂力",
        secInt = "悟性",
        secCon = "根骨",
        secDex = "身法",
        currStr = "臂力", -- 臂力
        currInt = "悟性", -- 悟性
        currCon = "根骨", -- 根骨
        currDex = "身法", -- 身法
        jing = "精力",
        jingMax = "最大精力",
        qi = "气血",
        qiMax = "最大气血",
        neili = "内力",
        neiliMax = "最大内力",
        exp = "经验",
        pot = "潜能",
        money = "金钱",
        lv = "等级",
        zhengqi = "正气"
    }

function Skill:getBaseAutoSkillList()
    return {
        "jibenquanjiao", -- 拳脚
        "jibenneigong", -- 内功
        "jibenqinggong", -- 轻功
        "jibenzhaojia", -- 招架
        "jibenjianfa", -- 剑法
        "jibendaofa", -- 刀法
        "jibengunfa", -- 棍法
        "jibenanqi", -- 暗器
        "jibenbianfa", -- 鞭法
        "jibenshuangchi", -- 双持
        "jibenqinfa" -- 琴法
    }
end

function Skill:isBaseAutoSkill(skillId)
    local autoSkillList = self:getBaseAutoSkillList()
    for i=1,#autoSkillList do
        local baseSkillId = autoSkillList[i]

        if skillId == baseSkillId then
            return true
        end
    end
    return false
end


-- 判断学习条件是否成立
function Skill:canLevelUp(role, skill, sklv)
    -- print("Skill:canLevelUp(role, skill, sklv)")
    -- 检查基本内功等级是否足够
    local function checkJiBenSkill()
        local methodList =
            {
                "jibenquanjiao", -- 拳脚
                "jibenneigong", -- 内功
                "jibenqinggong", -- 轻功
                "jibenzhaojia", -- 招架
                "jibenjianfa", -- 剑法
                "jibendaofa", -- 刀法
                "jibengunfa", -- 棍法
                "jibenanqi", -- 暗器
                "jibenbianfa", -- 鞭法
                "jibenshuangchi", -- 双持
                "jibenqinfa" -- 琴法
            }
        
        local status = false
        for k, v in pairs(skill.methods) do
            local jiBenLv = role:getSkillLv(methodList[v])
            -- 技能所属类型中,只要有一个基本符合条件则基本技能等级校验通过
            if jiBenLv + 1 >= sklv then
                status = true
                break
            end
        end
        return status
    end
    
    -- 只有普通招式需要判断基本功法等级, 基本武功,门派技能,读书识字不需要判断基本功法等级
    if checkJiBenSkill() == false and skill.type == SKILL_TYPE_NORMAL then
        return "你的基本功火候未到，必须先打好基础才能继续提高。"
    end
    
    
    local requirement = skill:getRequirement()
    if MapIsEmpty(requirement) then
        return true
    end
    local status, str = true, ""
    
    for i, condition in ipairs(requirement) do
        if condition.name then
            local result1, result2
            
            local skillName = skill.name
            if condition.type == "技能" then
                local roleSkill = role:getSkills()[condition.name]
                if not roleSkill then
                    result1 = 0
                else
                    result1 = Skill:getLv(roleSkill.exp)
                end
                if not condition.name then
                    skillName = "Error"
                else
                    skillName = Skill:getSkill(condition.name).name
                end
            elseif condition.type == "属性" then
                result1 = role:getFinalAttr(condition.name)
            end
            
            if result1 and condition.count and condition.cond then
                if tonumber(condition.count) ~= nil then
                    result2 = tonumber(condition.count)
                else
                    result2 = Helper:GetValueFromScript(condition.count, {sklv = sklv})
                end
                
                if condition.cond then
                    if condition.name == "zhengqi" then
                        local zq = tonumber(string.sub(condition.count, 1, 2))
                        local zhengQi = Helper:GetValueFromScript(condition.count, {sklv = sklv})
                        local rZhengQi = role:getFinalAttr("zhengqi")
                        if not zq or not zhengQi then
                            zq, zhengQi = 0, 0
                        end

                        if zq >= 0 and rZhengQi >= 0 then
                            --同为正气并正气值不足时
                            if result1 < result2 then
                                str = "你的正气不足，无法修炼[" .. tostring(skillName) .. "]。"
                                status = false
                            end
                        elseif zq >= 0 and rZhengQi <= 0 then
                            --技能为正派，角色是邪派时
                            str = "你的邪念太重，无法修炼[" .. tostring(skillName) .. "]。"
                            status = false
                        elseif zq <= 0 and rZhengQi >= 0 then
                            -- 技能是邪派，角色是正派时
                            str = "你的正气太重，无法修炼[" .. tostring(skillName) .. "]。"
                            status = false
                        elseif zq <= 0 and rZhengQi <= 0 then
                            
                            -- 同为邪派，并邪气值不足时
                            if result1 > result2 then
                                str = "你的邪念不深，无法修炼[" .. tostring(skillName) .. "]。"
                                status = false
                            end
                        end
                    elseif condition.name == "sex" and result1 ~= result2 then
                        if role:getAttr("sex") == "男" then
                            str = "你纯阳之体，无法修炼此等阴柔武功。"
                        elseif role:getAttr("sex") == "女" then
                            str = "你女儿之身，无法修炼此等纯阳武学。"
                        else
                            str = "你没有阳刚之气，无根无性，无法领会里面的乾坤阴阳变化之道。"
                        end
                        status = false
                    else
                        if condition.cond == "小于" then
                            status = tonumber(result1) < tonumber(result2)
                        elseif condition.cond == "大于等于" then
                            status = tonumber(result1) >= tonumber(result2)
                        end
                    end
                end
            end
            
            if not status then
                if condition.type == "技能" then
                    return "你的[" .. tostring(skillName) .. "]火候太浅。"
                end
                if condition.name ~= "zhengqi" and condition.name ~= "sex" then
                    if condition.cond == "小于" then
                        if condition.name == "int" then
                            str = "你的悟性太高，成见太深，无法学习。"
                        end
                        str = "你的[" .. tostring(attrList[condition.name]) .. "]太高，无法学习。"
                    else
                        str = "你的[" .. tostring(attrList[condition.name]) .. "]太低，无法学习。"
                    end
                end
                return str
            end
        end
    end
    
    return true
end

function Skill:learn(role, skillId, times)--　学习
    if times == nil then
        times = 1
    end
    local roleSkill = role:getSkill(skillId)
    if roleSkill == nil then
        roleSkill = {id = skillId, exp = 0}
    end
    
    local skill = Skill:getSkill(skillId)
    local skillExp = roleSkill.exp
    local skillLv = skill:getLv(skillExp)
    
    local upgradeNeedExp = math.ceil(skill:getExp(skillLv + times)) - skillExp
    if role.pot >= upgradeNeedExp then
        role.pot = role.pot - upgradeNeedExp
        roleSkill.exp = math.ceil(roleSkill.exp + upgradeNeedExp)
        role:setSkill(skillId, roleSkill)
        
        RichPrint("main", "感觉" .. tostring(skill.name) .. "又有精进")
        return true
    else
        RichPrint("main", "当前悟性不够学习" .. tostring(skill.name))
        return false
    end
end

function Skill:getExp(lv)
    if not lv or type(lv) ~= "number" then
        -- print("Skill:等级不存在或者不是数字类型")
        return
    end
    local exp
    if lv < 8 then
        exp = lv
    else
        exp = math.ceil((0.015 * lv ^ 3 + 1), 1)
    end
    return exp
end

function Skill:getLv(exp)
    if not exp or type(exp) ~= "number" then
        -- print("Skill:经验值不存在或者不是数字类型")
        return 0
    end
    local lv
    if exp < 8 then
        lv = exp
    else
        lv = ((exp - 1) / 0.015) ^ (1 / 3)
    end
    if Helper:isNan(lv) then
        lv = 0
    end
    lv = tonumber(tostring(lv))
    return Helper:mathFloor(lv)
end

-- 获取伤害结果描述
function Skill:getAttactResultDesc(dType, atk)
    if not dType then
        dType = "伤害"
    end
    if not atk or type(atk) ~= "number" then
        atk = 0
    end
    
    local str, step
    if atk <= 0 then
        step = "num1"
    elseif atk <= 20 then
        step = "num2"
    elseif atk <= 80 then
        step = "num3"
    elseif atk <= 150 then
        step = "num4"
    elseif atk <= 300 then
        step = "num5"
    elseif atk <= 500 then
        step = "num6"
    elseif atk <= 1000 then
        step = "num7"
    elseif atk <= 1500 then
        step = "num8"
    elseif atk <= 2400 then
        step = "num9"
    elseif atk <= 3000 then
        step = "num10"
    else
        end
    
    -- 没有伤害类型
    if attackResultMap[dType] == nil then
        -- 没有伤害类型,取默认的“伤害”类型,并且伤害值对应的描述为空
        if attackResultMap["伤害"][step] == nil then
            str = attackResultMap["伤害"]["other"]
        else
            -- 没有伤害类型,但是对应的伤害值的描述不为空
            str = attackResultMap["伤害"][step]
        end
    else
        -- 有伤害类型但是伤害值的描述为空
        if attackResultMap[dType][step] == nil then
            str = attackResultMap[dType]["other"]
        -- 有伤害类型并且伤害值的描述不为空
        else
            str = attackResultMap[dType][step]
        end
    end
    
    if str == nil then
        str = ""
    end
    
    return str
end

-- 获取需要潜能点
function Skill:getNeedExp(lv, num)
    assert((lv and num), "Skill:getNeedExp(lv, num) ->  参数不能为空")
    local needExp = self:getExp(lv + num) - self:getExp(lv)
    if not needExp then
        return
    end
    return needExp
end

-- SKILL_METHOD_TYPE_QUANJIAO = 1	-- 拳脚
-- SKILL_METHOD_TYPE_NEIGONG = 2 	-- 内功
-- SKILL_METHOD_TYPE_QINGGONG = 3	-- 轻功
-- SKILL_METHOD_TYPE_ZHAOJIA = 4	-- 招架
-- SKILL_METHOD_TYPE_JIAN = 5    	-- 剑法
-- SKILL_METHOD_TYPE_DAO = 6    	-- 刀法
-- SKILL_METHOD_TYPE_GUN = 7   	-- 棍法
-- SKILL_METHOD_TYPE_ANQI = 8    	-- 暗器
-- SKILL_METHOD_TYPE_BIANFA = 9    -- 鞭法
-----------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/19 14:38:30
-- @desc 初始化主动技能战斗音效
local function changeSounds(sounds)
    local hitSound, hurtSound, dieSound, parrySound, DodgeSound
    if type(sounds) ~= "string" then
        return {}
    end
    local soundList = string.split(sounds, ";")
    if #soundList == 1 then
        for i=2,5 do
            soundList[i] = soundList[1]
        end
    else
    end

    hitSound = soundList[1] == "0" and nil or soundList[1]
    hurtSound = soundList[2] == "0" and nil or soundList[2]
    dieSound = soundList[3] == "0" and nil or soundList[3]
    parrySound = soundList[4] == "0" and nil or soundList[4]
    DodgeSound = soundList[5] == "0" and nil or soundList[5]
    return {hitSound, hurtSound, dieSound, parrySound, DodgeSound}
    -- return {"刀", "刀", "刀", "刀", "刀"}
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/23 16:02:13
-- @desc 初始化主动招式
function Skill:initActiveZhao()    
    local ActiveZhao = require("app.models.skill.ActiveZhao")
    local activeZhaoRes = requireWithEncrypt("script.skill.activeZhao")
    local activeZhaoMap = activeZhaoRes.ActiveZhao
    local activeZhaoAnimMap = activeZhaoRes.ActiveZhaoAnim
    local animationMap = activeZhaoRes.Animation
    
    for k, v in pairs(activeZhaoMap) do
        local activeZhao = ActiveZhao:create(v)
        -- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 招式CD等) 
        self.activeZhaoMap[k] = activeZhao
        
        local activeZhaoAnim = activeZhaoAnimMap[k]
        if activeZhaoAnim == nil then
            activeZhaoAnim = {readyAnim = "liumaishenjian-ready", attackAnim = "liumaishenjian-attack1"}
        end
        
        if activeZhaoAnim then
            local totalDuration = 0
            local anim = {}
            if activeZhaoAnim.readyAnim then
                local animInfo = animationMap[activeZhaoAnim.readyAnim]
                if animInfo then
                    -- animInfo.duration = getAnimDuration(animInfo.anim) * 30
                    anim.preJumpAnim = {}
                    anim.preJumpAnim.animName = animInfo.anim
                    anim.preJumpAnim.duration = animInfo.duration
                    totalDuration = totalDuration + animInfo.duration
                    if animInfo.animType == 0 then
                        local args = changeSounds(animInfo.normalSound)
                        anim.preJumpAnim.soundType = animInfo.normalSoundType
                        anim.preJumpAnim.hitSound = args[1]
                        anim.preJumpAnim.hurtSound = args[2]
                        anim.preJumpAnim.dieSound = args[3]
                        anim.preJumpAnim.parrySound = args[4]
                        anim.preJumpAnim.dodgeSound = args[5]
                    elseif animInfo.animType == 1 then
                        local args = changeSounds(animInfo.specialSound1)
                        anim.preJumpAnim.soundType = animInfo.specialSoundType1
                        anim.preJumpAnim.hitSound = args[1]
                        anim.preJumpAnim.hurtSound = args[2]
                        anim.preJumpAnim.dieSound = args[3]
                        anim.preJumpAnim.parrySound = args[4]
                        anim.preJumpAnim.dodgeSound = args[5]
                    end
                end
            end
            
            if activeZhaoAnim.attackAnim then
                -- print("activeZhaoAnim.attackAnim = ", activeZhaoAnim.attackAnim)
                local animArray = string.split(activeZhaoAnim.attackAnim, ";")
                
                if #animArray > 0 then
                    local attackAnim = {}
                    for i, v in ipairs(animArray) do
                        local animInfo = animationMap[v]
                        if animInfo then
                            local animItem = {}
                            animItem.animName = animInfo.anim
                            animItem.duration = animInfo.duration
                            animItem.offset = animInfo.offset

                            animItem.effectFrames = {}
                            if animInfo.effectFrame then
                                local effectFrames = string.split(animInfo.effectFrame, "#")
                                for k,frame in pairs(effectFrames) do
                                    table.insert(animItem.effectFrames, frame)
                                end

                                table.sort(animItem.effectFrames,function(a, b)
                                    return a < b
                                end)
                            end

                            if animInfo.animType == 0 then
                                local args = changeSounds(animInfo.normalSound)
                                local hits =
                                    {
                                        {
                                            frame = 10,
                                            hitPos = animInfo.hitPos,
                                            hisOffset = -50,
                                            soundType = animInfo.normalSoundType,
                                            hitSound = args[1],
                                            hurtSound = args[2],
                                            dieSound = args[3],
                                            parrySound = args[4],
                                            dodgeSound = args[5]
                                        }
                                    }
                                if #hits > 0 then
                                    animItem.hits = hits
                                end
                                table.insert(attackAnim, animItem)
                                totalDuration = totalDuration + animItem.duration + 10
                            elseif animInfo.animType == 1 then
                                -- 解析攻击部位 add by TangJian 2017/03/08 15:43:03
                                local hits = {}
                                for i = 1, 999 do
                                    local sHitFrame = animInfo["sHitFrame" .. i]
                                    local sHitPos = animInfo["sHitPos" .. i]
                                    local sHitOffset = animInfo["sHitOffset" .. i]
                                    local sounds = animInfo["specialSound" .. i]
                                    local soundType = animInfo["specialSoundType" .. i]
                                    -- add by XiaoZhiWei 2017/07/12 16:30:41 主动技能战斗音效
                                    do
                                        local sounds = animInfo["specialSound" .. i]
                                        local hitSound
                                        if type(sounds) == "string" then

                                        end
                                    end
                                    local args = changeSounds(sounds)

                                    if sHitFrame and sHitPos and sHitOffset then
                                        table.insert(hits, 
                                            {
                                                frame = sHitFrame, 
                                                hitPos = sHitPos, 
                                                hisOffset = sHitOffset,
                                                soundType = soundType,
                                                hitSound = args[1],
                                                hurtSound = args[2],
                                                dieSound = args[3],
                                                parrySound = args[4],
                                                dodgeSound = args[5]
                                            })
                                    else
                                        break
                                    end
                                end
                                if #hits > 0 then
                                    animItem.hits = hits
                                else
                                    animItem.hits =
                                        {
                                            {
                                                frame = 10,
                                                hitPos = "chest",
                                                hisOffset = -0
                                            }
                                        }
                                end
                                table.insert(attackAnim, animItem)
                                totalDuration = totalDuration + animItem.duration + 10
                            else
                                error("initActiveZhao, animInfo.animType = " .. animInfo.animType)
                            end
                        end
                    end
                    if #attackAnim > 0 then
                        anim.attackAnim = attackAnim
                    end
                end
                
                -- 计算动画总时间
                anim.duration = totalDuration
                -- print("anim.duration = ", anim.duration)
                activeZhao:setAnim(anim)
            end
            
            -- 防守动画 add by TangJian 2017/03/18 11:43:36ssss
            if activeZhaoAnim.defendAnim then
                local animArray = string.split(activeZhaoAnim.defendAnim, ";")
                if #animArray > 0 then
                    local defendAnimArray = {}
                    for i, animName in ipairs(animArray) do
                        local animInfo = animationMap[animName]
                        if animInfo then
                            local animItem = {}
                            animItem.animName = animInfo.anim
                            animItem.duration = animInfo.duration
                            if animInfo.animType == 0 then
                                local args = changeSounds(animInfo.normalSound)
                                animItem.soundType = animInfo.normalSoundType
                                animItem.hitSound = args[1]
                                animItem.hurtSound = args[2]
                                animItem.dieSound = args[3]
                                animItem.parrySound = args[4]
                                animItem.dodgeSound = args[5]
                            elseif animInfo.animType == 1 then
                                local args = changeSounds(animInfo.specialSound1)
                                animItem.soundType = animInfo.specialSoundType1
                                animItem.hitSound = args[1]
                                animItem.hurtSound = args[2]
                                animItem.dieSound = args[3]
                                animItem.parrySound = args[4]
                                animItem.dodgeSound = args[5]
                            end
                            table.insert(defendAnimArray, animItem)
                        end
                    end
                    if #defendAnimArray > 0 then
                        anim.defendAnimArray = defendAnimArray
                    end
                end
            end

            self:__initActiveZhaoSpecialAnim(animationMap,activeZhao,activeZhaoAnim)
        end
    end
end

function Skill:__initActiveZhaoSpecialAnim(animationMap,activeZhao,activeZhaoAnim)
    local totalDuration = 0
    local anim = {}
    if activeZhaoAnim.readyAnim2 then
        local animInfo = animationMap[activeZhaoAnim.readyAnim2]
        if animInfo then
            anim.preJumpAnim = {}
            anim.preJumpAnim.animName = animInfo.anim
            anim.preJumpAnim.duration = animInfo.duration
            totalDuration = totalDuration + animInfo.duration
            if animInfo.animType == 0 then
                local args = changeSounds(animInfo.normalSound)
                anim.preJumpAnim.soundType = animInfo.normalSoundType
                anim.preJumpAnim.hitSound = args[1]
                anim.preJumpAnim.hurtSound = args[2]
                anim.preJumpAnim.dieSound = args[3]
                anim.preJumpAnim.parrySound = args[4]
                anim.preJumpAnim.dodgeSound = args[5]
            elseif animInfo.animType == 1 then
                local args = changeSounds(animInfo.specialSound1)
                anim.preJumpAnim.soundType = animInfo.specialSoundType1
                anim.preJumpAnim.hitSound = args[1]
                anim.preJumpAnim.hurtSound = args[2]
                anim.preJumpAnim.dieSound = args[3]
                anim.preJumpAnim.parrySound = args[4]
                anim.preJumpAnim.dodgeSound = args[5]
            end
        end
    end
    
    if activeZhaoAnim.attackAnim2 then
        local animArray = string.split(activeZhaoAnim.attackAnim2, ";")
        
        if #animArray > 0 then
            local attackAnim = {}
            for i, v in ipairs(animArray) do
                local animInfo = animationMap[v]
                if animInfo then
                    local animItem = {}
                    animItem.animName = animInfo.anim
                    animItem.duration = animInfo.duration
                    animItem.offset = animInfo.offset

                    animItem.effectFrames = {}
                    if animInfo.effectFrame then
                        local effectFrames = string.split(animInfo.effectFrame, "#")
                        for k,frame in pairs(effectFrames) do
                            table.insert(animItem.effectFrames, frame)
                        end

                        table.sort(animItem.effectFrames,function(a, b)
                            return a < b
                        end)
                    end

                    if animInfo.animType == 0 then
                        local args = changeSounds(animInfo.normalSound)
                        local hits =
                            {
                                {
                                    frame = 10,
                                    hitPos = animInfo.hitPos,
                                    hisOffset = -50,
                                    soundType = animInfo.normalSoundType,
                                    hitSound = args[1],
                                    hurtSound = args[2],
                                    dieSound = args[3],
                                    parrySound = args[4],
                                    dodgeSound = args[5]
                                }
                            }
                        if #hits > 0 then
                            animItem.hits = hits
                        end
                        table.insert(attackAnim, animItem)
                        totalDuration = totalDuration + animItem.duration + 10
                    elseif animInfo.animType == 1 then
                        -- 解析攻击部位 add by TangJian 2017/03/08 15:43:03
                        local hits = {}
                        for i = 1, 999 do
                            local sHitFrame = animInfo["sHitFrame" .. i]
                            local sHitPos = animInfo["sHitPos" .. i]
                            local sHitOffset = animInfo["sHitOffset" .. i]
                            local sounds = animInfo["specialSound" .. i]
                            local soundType = animInfo["specialSoundType" .. i]
                            -- add by XiaoZhiWei 2017/07/12 16:30:41 主动技能战斗音效
                            do
                                local sounds = animInfo["specialSound" .. i]
                                local hitSound
                                if type(sounds) == "string" then

                                end
                            end
                            local args = changeSounds(sounds)

                            if sHitFrame and sHitPos and sHitOffset then
                                table.insert(hits, 
                                    {
                                        frame = sHitFrame, 
                                        hitPos = sHitPos, 
                                        hisOffset = sHitOffset,
                                        soundType = soundType,
                                        hitSound = args[1],
                                        hurtSound = args[2],
                                        dieSound = args[3],
                                        parrySound = args[4],
                                        dodgeSound = args[5]
                                    })
                            else
                                break
                            end
                        end
                        if #hits > 0 then
                            animItem.hits = hits
                        else
                            animItem.hits =
                                {
                                    {
                                        frame = 10,
                                        hitPos = "chest",
                                        hisOffset = -0
                                    }
                                }
                        end
                        table.insert(attackAnim, animItem)
                        totalDuration = totalDuration + animItem.duration + 10
                    else
                        error("initActiveZhao, animInfo.animType = " .. animInfo.animType)
                    end
                end
            end
            if #attackAnim > 0 then
                anim.attackAnim = attackAnim
            end
        end
        
        -- 计算动画总时间
        anim.duration = totalDuration
        activeZhao:setAnim2(anim)
    end
    
    -- 防守动画 add by TangJian 2017/03/18 11:43:36ssss
    if activeZhaoAnim.defendAnim2 then
        local animArray = string.split(activeZhaoAnim.defendAnim2, ";")
        if #animArray > 0 then
            local defendAnimArray = {}
            for i, animName in ipairs(animArray) do
                local animInfo = animationMap[animName]
                if animInfo then
                    local animItem = {}
                    animItem.animName = animInfo.anim
                    animItem.duration = animInfo.duration
                    if animInfo.animType == 0 then
                        local args = changeSounds(animInfo.normalSound)
                        animItem.soundType = animInfo.normalSoundType
                        animItem.hitSound = args[1]
                        animItem.hurtSound = args[2]
                        animItem.dieSound = args[3]
                        animItem.parrySound = args[4]
                        animItem.dodgeSound = args[5]
                    elseif animInfo.animType == 1 then
                        local args = changeSounds(animInfo.specialSound1)
                        animItem.soundType = animInfo.specialSoundType1
                        animItem.hitSound = args[1]
                        animItem.hurtSound = args[2]
                        animItem.dieSound = args[3]
                        animItem.parrySound = args[4]
                        animItem.dodgeSound = args[5]
                    end
                    table.insert(defendAnimArray, animItem)
                end
            end
            if #defendAnimArray > 0 then
                anim.defendAnimArray = defendAnimArray
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/22 18:14:06
-- @desc 获得主动技能
function Skill:getActiveZhao(id)
    if self.activeZhaoMap[id] == nil then
        error("没有找到招式: " .. "[" .. tostring(id) .. "]")

        -- for k, v in pairs(self.activeZhaoMap) do
        --     print("Skill:getActiveZhao(id)", 3)
        --     print(k, v)
        -- end
    end
    
    return self.activeZhaoMap[id]
end

-- 获得pvp中使用的主动技能
function Skill:getActiveZhaoInPVP(id)
    local activeZhao = self.activeZhaoMap[id]
    if activeZhao == nil then
        error("没有找到招式: " .. "[" .. tostring(id) .. "]")
    end
    return inherit({cd = activeZhao.pvpcd}, activeZhao)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 15:31:19
-- @desc 初始化技能效果
function Skill:initSkillEffect()
    local SkillEffect = require("app.models.skill.SkillEffect")
    local skillEffectMap = require("script.skill.activeZhao").Effect

    -- 初始化效果 add by TangJian 2017/05/09 11:23:45
    for k, v in pairs(skillEffectMap) do
        self.skillEffectMap[k] = SkillEffect:create(v)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 15:32:59
-- @desc 得到技能效果
function Skill:getSkillEffect(id)
    local skillEffect = self.skillEffectMap[id]
    -- assert(skillEffect, "Skill:getSkillEffect(id)" .. tostring(id))
    return skillEffect
end

-- 属性中午转英文表 add by TangJian 2017/02/20 16:01:38
local propertyCNToENMap =
    {
        ["阳性"] = "yangxing",
        ["阴性"] = "yinxing",
        ["混元"] = "hunyuan",
        ["毒性"] = "duxing",
        ["外功"] = "waigong",
        ["无"] = "wu",
    }

-- 属性英文转中文表 add by TangJian 2017/02/20 16:01:52
local propertyENToCNMap = {}
for k, v in pairs(propertyCNToENMap) do
    propertyENToCNMap[v] = k
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/21 21:23:34
-- @desc 获取技能招式Map
function Skill:getSkillZhaoMap(skillId)
    if skillId == nil or skillMap[skillId] == nil then
        return {}
    end
    local retMap = {}
    local skillZhaoList = self:getSkillZhaoList(skillId)
    for i, zhao in ipairs(skillZhaoList) do
        retMap[zhao:getId()] = zhao
    end
    return retMap
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/02 09:35:49
-- @desc 通过招式ID获取所属技能ID
function Skill:getSkillIdByZhaoId(zhaoId)
    if Helper:checkParamsError("Skill:getSkillIdByZhaoId(zhaoId)", 1, zhaoId, "string") == true then
        return
    end
    local skillRelation = Helper:getDef(self.skillRelationMap, {})
    if MapIsEmpty(skillRelation) == true or skillRelation[zhaoId] == nil then
        return
    end
    return skillRelation[zhaoId]
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/21 21:34:10
-- @desc 获取技能招式列表
function Skill:getSkillZhaoList(skillId)
    if skillId == nil or skillMap[skillId] == nil then
        return {}
    end
    if skillMap[skillId]._baseZhaoList == nil then
        local retList = {}
        local zhaoList = skillMap[skillId].zhaoList
        if MapIsEmpty(zhaoList) == true then
            
        else
            for i, zhaoId in ipairs(zhaoList) do
                table.insert(retList, self:getActiveZhao(zhaoId))
            end
        end
        skillMap[skillId]._baseZhaoList = retList
    else
        end
    
    return skillMap[skillId]._baseZhaoList
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/20 15:54:40
-- @desc 属性名中文转英文
function Skill:getPropertyENName(name)
    return propertyCNToENMap[name]
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/20 16:02:42
-- @desc 属性英文转中文
function Skill:getPropertyCNName(name)
    return propertyENToCNMap[name]
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/21 20:53:03
-- @desc 技能招式初始化
function Skill:initSkillZhaoRelation()
    local SkillZhaorelation = Helper:getDef(require("script.skill.activeZhao")["skillRelation"], {})
    if MapIsEmpty(SkillZhaorelation) == true then
        return
    end
    for zhaoId, zhao in pairs(SkillZhaorelation) do
        local skill = self:getSkill(zhao.skillId)
        if MapIsEmpty(skill) == false then
            skill.zhaoList = Helper:getDef(skill.zhaoList, {})
            table.insert(skill.zhaoList, zhaoId)
            self.skillRelationMap[zhaoId] = skill.id
            self.zhaosRelationMap[zhaoId] = zhaoId
            skillMap[skill.name] = skill
            for i = 2, 10 do
                self.skillRelationMap[zhaoId .. tostring(i)] = skill.id
                self.zhaosRelationMap[zhaoId .. tostring(i)] = zhaoId
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/16 17:43:42
-- @desc 获取关联招式Id
function Skill:getBaseZhaoId(zhaoId)
    if zhaoId == nil then
        return
    end
    local zhaosRelation = Helper:getDef(self.zhaosRelationMap, {})
    if MapIsEmpty(zhaosRelation) == true then
        -- print("招式之间的关系列表为空,请检查")
        return
    else
        return zhaosRelation[zhaoId]
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 16:14:14
-- @desc 技能初初始化
function Skill:init()
    self:initActiveZhao()
    self:initSkillEffect()
    self:initSkillZhaoRelation()
    self:checkError()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/14 18:50:36
-- @desc 检查错误
function Skill:checkError()
    if Game:isTesting() then
        local errorArray = {}
        
        local isError = false
        for activeZhaoId, activeZhao in pairs(self.activeZhaoMap) do
            local isError, msg = activeZhao:checkEffectsError()
            if isError then
                table.insert(errorArray, msg)
                table.insert(errorArray, "\n")
            end
        end

        LogSystem:log("武学效果检测","-----------------------------主动技能参数检测开始-----------------------------")

        if #errorArray > 0 then
            table.concat(errorArray, "")
            isError = true
            LogSystem:log("武学效果检测","-----------------------------主动技能参数检测异常-----------------------------")
            LogSystem:log("武学效果检测",errorArray)
        else
            LogSystem:log("武学效果检测","-----------------------------主动技能参数检测正常-----------------------------")
        end

        LogSystem:log("武学效果检测","-----------------------------主动技能参数检测结束-----------------------------")

        LogSystem:log("武学效果检测","-----------------------------效果参数检测开始-----------------------------")

        local SkillEffectCheckError = require("app.views.layer.DebugLayer.CheckUtil.SkillEffectCheckError")

        local isTrue = true

        for k, effect in pairs(self.skillEffectMap) do
            local result = SkillEffectCheckError:checkError(effect)

            if isTrue and result == false then
                isTrue = false
            end
        end

        if isTrue then
            LogSystem:log("武学效果检测","-----------------------------效果参数检测正常-----------------------------")
        end
        
        LogSystem:log("武学效果检测","-----------------------------效果参数检测结束-----------------------------")
    end
end

-- add by XiaoZhiWei 2017/07/10 17:54:59 不受等级限制的技能列表
local unLimitskills = 
{
    changshengjue = true,
    changshengjueyin = true,
    changshengjueyang = true,
    duanzaozhishu = true,
    jianghudushu = true,
    tangmenmishu = true,
    xingxiududian = true,
    wuxianshu = true,
    xiyudujing = true,
    shengsibu = true,
    yirongshu = true,
    zouxueshisijing = true,
    zhongzhizhishu = true,
    shenzhaojing001= true,
    shenzhaojing002= true,
    shenzhaojing003= true,
    
    xiangmashu = true,
    zhanxingshu = true,
    zhuizongshu = true,
    lubanshu = true,
    xiangmianshu = true,
    wuzuoshu = true,
    qihuangzhishu = true,
    mojiajiguanshu = true,
    miaosuanzhishu = true,

    zhengaoxuanjing = true,
    dankuixuangong = true,
}
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/10 16:01:47
-- @desc 不受升级条件限制的技能
function Skill:checkSkillIsUnlimited(skillId)
    if unLimitskills[skillId] == true then
        return true
    else
        return false
    end
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/04 17:22:28
-- @desc 获取有效等级描述列表
function Skill:getStageDscs()
    return SkillResManager:getNormalSkillStageDescMap()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/04 17:25:58
-- @desc 获取读书心法阶段描述
function Skill:getStageDscs2()
    return SkillResManager:getSpecialSkillStageDescMap()
end

--根据人物兵器子类型初始化主动招式攻击动画
function Skill:initActiveZhaoAttackAnim(anim,role)
    if anim == nil then
        return
    end
    if #anim.attackAnim > 0 then
        local weaponType2 = role._role:getCurrWeaponType2()
        for i, v in ipairs(anim.attackAnim) do
        
            local str = string.sub(v.animName,-1)
            if str == "_" then
                local newSkillanim = assert(require("script.skill.newSkillanim").Sheet1)

                local animName = v.animName..weaponType2
                local offset = newSkillanim[animName]["offset"]
                local hitPos = newSkillanim[animName]["location"]

                v["animName"] = animName
                v["offset"] = offset
                
                v["hits"][1]["hitPos"] = hitPos
                
            end
        end
    end
end

-- 加密标志
Skill.isEncrypted = true
return Skill
00000000000000
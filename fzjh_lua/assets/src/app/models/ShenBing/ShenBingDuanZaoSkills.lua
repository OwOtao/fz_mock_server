local ShenBingDuanZaoSkills = {}
-- 锻造技艺 暂时于书页数据相同
-- 编号;atlasid  名称;atlasname   图谱详细描述;atlasdsc   图谱学习条件;learnatlas      图谱对应知识集（相当于残页）;atlasknowledge
local res = require("script.others.godweapon")

local godweaponSkillData = {}
function ShenBingDuanZaoSkills:initShenBingDuanZaoSkills()
    -- local dataList = assert(require("script.book.BookSkills"))
    local godweaponSkill = res["forgeKnowledges"]
	if type(godweapon) ~= "table" then
		if DEBUG_MODE == 1 then
			error("解析书页数据出错")
		end
		return
	end


	for id,skill in pairs(godweaponSkill) do
        godweaponSkillData[id] = {}
        godweaponSkillData[id].name = Helper:getDef(skill["atlasname"], "")
        godweaponSkillData[id].skillId = Helper:getDef(skill["atlasid"], "")
        godweaponSkillData[id].dsc = Helper:getDef(skill["atlasdsc"], "")
        godweaponSkillData[id].knowledge = string.split(Helper:getDef(skill["atlasknowledge"], "") ,";") --图谱对应的知识点 集
        godweaponSkillData[id].learnatlas = Helper:getDef(skill["learnatlas"], "")  -- 学习需要条件
    end
end
function ShenBingDuanZaoSkills:getShenBingDuanZaoSkill()
    if MapIsEmpty(godweaponSkillData) == true then
	   self:initShenBingDuanZaoSkills()
    end
    return godweaponSkillData
end

-----------------------------------------------------------------------------------------------------------

-- 玩家锻造技术等级最高1000级；
-- 需求技能经验= math.ceil((0.015*锻造技能等级^3+1),1)；
-- 熔炼成功获得经验=math.min(锻造技能等级*2,500)
-- 熔炼失败获得经验=math.random(20,45)
-- 淬炼成功获得经验=math.floor((锻造技能等级^1.5)/3+80)
-- 淬炼失败获得经验=math.min(锻造技能等级*2.5,1500)
-- 锻造成功获得经验=math.floor((锻造技能等级^2)/8+50)
-- 锻造失败获得经验=math.min(锻造技能等级*5,2400)

-- 注：
-- 每日通过锻造能够获得的经验有上限，最多可获得250000经验；
-- 每日通过熔炼能够获得的经验有上限，最多可获得50000经验；
-- 每日通过淬炼能够获得的经验有上限，最多可获得100000经验

-- 锻造技术 id  duanzaozhishu 

local DuanZao = {
    ["duanzao"] ={
        dayExpMax = 12000
    },
    ["ronglian"] ={
        dayExpMax = 12000
    },
    ["cuilian"] ={
        dayExpMax = 40000
    },
} 

--  神兵锻造技术 经验获取
function ShenBingDuanZaoSkills:addDuanZaoExp(addExp,type)
    if not type then
        return
    end
    if  MapIsEmpty(DuanZao[type]) == true   then
        return
    end

    local role = User:getRole()
    local skillId = "duanzaozhishu"
    -- local addExp = 0
 

    if role:getDayFlag(type) < DuanZao[type].dayExpMax then
        if role:getDayFlag(type) + addExp >= DuanZao[type].dayExpMax then
            addExp = role:getDayFlag(type) + addExp - DuanZao[type].dayExpMax
        end
        -- addExp = getaddExp(type)
        role:addSkillExp(skillId, addExp)
        role:setDayFlag(type,role:getDayFlag(type)+addExp)
    else
        PopText("今日锻造经验达到最大值")
    end
    
    -- --获得增加的技术经验
    -- local function getaddExp( mytype )
    --     local skillLv = role:getSkillLv("duanzaozhishu")
    --     local exp
    --     if mytype == "duanzao"  then
    --         if condition then
    --             exp = math.min(skillLv*2,500)
    --         else
    --             exp = math.random(20,45)
    --         end  
    --     end
    --     if mytype == "ronglian"  then
    --         if condition then
    --             exp = math.floor((skillLv^1.5)/3+80)
    --         else
    --             exp = math.min(skillLv*2.5,1500)
    --         end  
    --     end
    --     if mytype == "cuilian"  then
    --         if condition then
    --             exp = math.floor((skillLv^2)/8+50)
    --         else
    --             exp = math.min(skillLv*5,2400)
    --         end  
    --     end
    --     return Helper:getDef(exp,0) 
    -- end
    
end


-- 加密标记
ShenBingDuanZaoSkills.isEncrypted = true
return ShenBingDuanZaoSkills
0
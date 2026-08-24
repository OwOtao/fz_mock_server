local NewClass = require("third.class.NewClass")
local ISelfCreatedZhao = require("app.models.SelfCreatedSkillSystem.ISelfCreatedZhao")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local SelfCreatedZhaoAffix = require("app.models.SelfCreatedSkillSystem.SelfCreatedZhaoAffix.SelfCreatedZhaoAffix")
local SelfCreatedZhaoDsc = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedDsc.SelfCreatedZhaoDsc")
local ZhaoInfo = require("app.FightSystem.FightSkill.ZhaoInfo")

local SelfCreatedZhao = {}

function SelfCreatedZhao:create(data)
    local p = SelfCreatedZhao.new(data)
    p._data = SelfCreatedSkillManager:getZhao(data.templateId)
    p._selfCreatedZhaoDsc = SelfCreatedZhaoDsc:create()
    p._selfCreatedZhaoDsc:setZhao(p)
    p._attack_all = {}
    return p
end

function SelfCreatedZhao:getId()
    return self.index
end

function SelfCreatedZhao:getTemplateId()
    return self.templateId
end

function SelfCreatedZhao:getIndex()
    return self.index
end

function SelfCreatedZhao:getName()
    return self.name
end

function SelfCreatedZhao:getColorId()
    return self.colorId
end

function SelfCreatedZhao:getQuality()
    return self.quality
end

function SelfCreatedZhao:getMaxLv()
    return self.lv
end

function SelfCreatedZhao:getQualityText()
    return switch(self.quality,{
        [SelfCreatedSkillConstants.ZhaoQuality.Normal] = "普通招式",
        [SelfCreatedSkillConstants.ZhaoQuality.Delicate] = "精妙招式",
        [SelfCreatedSkillConstants.ZhaoQuality.Extraordinary] = "超凡招式",
        [SelfCreatedSkillConstants.ZhaoQuality.Supernatural] = "神通招式",
        default = "普通招式"}
    )
end

function SelfCreatedZhao:getUseType()
    return self.useType
end

function SelfCreatedZhao:getUseTypeText()
    return switch(tostring(self.useType),{["0"] = "被动招式",["1"] = "主动招式",default = "被动招式"})
end

function SelfCreatedZhao:getDscId()
    return self.dscId
end

function SelfCreatedZhao:getColor()
    local colorId = self:getColorId()
    local colorData = SelfCreatedSkillManager:getZhaoColorMap(colorId)
    local color = {r = colorData.field1, g = colorData.field2, b = colorData.field3}
    return color
end

function SelfCreatedZhao:getAffixs()
    return table.mergeArray(self:getAtkAffixs(),self:getDefAffixs())
end

function SelfCreatedZhao:getAtkAffixs()
    local retAffixs = {}
    for i, affix in ipairs(self.atkAffixs) do
        table.insert(retAffixs, SelfCreatedZhaoAffix:create(affix))
    end
    return retAffixs
end

function SelfCreatedZhao:getDefAffixs()
    local retAffixs = {}
    for i, affix in ipairs(self.defAffixs) do
        table.insert(retAffixs, SelfCreatedZhaoAffix:create(affix))
    end
    return retAffixs
end

function SelfCreatedZhao:getAction()
    local text = SelfCreatedSkillManager:getZhaoDescByActionId(self:getDscId())
    local colorId = self:getColorId()
    local colorData = SelfCreatedSkillManager:getZhaoColorMap(colorId)
    local colorStr = colorData.ywName
     
    if string.find(text,"$M") then
        text = string.gsub(text, "$M",colorStr..self:getName().."NOR")
    end
    return text
end

function SelfCreatedZhao:getData()
    return self._data
end

--@desc 获取需求等级
function SelfCreatedZhao:getGrade()
    local grade = self._data.grade
    local affixs = self:getAffixs()
    if MapIsEmpty(affixs) == false then
        for i,affix in ipairs(affixs) do
            grade = math.max(grade,affix:getGrade())
        end
    end
    return grade
end


--@desc: 获取招式模板最大需求等级
--@author:LvBin
--@time:2025-09-03 11:59:08
--@return
function SelfCreatedZhao:getMaxGrade()
	local zhaoGradeList = {}

	local zhaoMap = SelfCreatedSkillManager:getZhaoMap()

	for zhaoId,zhaoData in pairs(zhaoMap) do
		if zhaoData.type == self:getType() and zhaoData.outputType == self:getOutputType() then
			table.insert(zhaoGradeList, zhaoData.grade)
		end
	end

	table.sort(zhaoGradeList)

	return zhaoGradeList[#zhaoGradeList]
end

--@desc 获取需武学类型
function SelfCreatedZhao:getType()
    return self._data.type
end

--获取招式产出类型 1自创  2历练
function SelfCreatedZhao:getOutputType()
    return self._data.outputType
end

--武学全域属性，和所有招式有关，需要武学设置这个数据
function SelfCreatedZhao:setSkillUniverseValue(param,value)
    self._attack_all[param] = value
end

function SelfCreatedZhao:getSkillUniverseValue(param)
    return Helper:getDef(self._attack_all[param],0)
end

function SelfCreatedZhao:getAffixValue(type,param)
    local value = 0
    local affixs = self:getAffixs()
    if MapIsEmpty(affixs) == false then
        for i,affix in ipairs(affixs) do
            value = value + affix:getAffixValue(type,param)
        end
    end
    return value
end

--@desc 招式全域xx性能加成 = 基础全域xx性能加成*(1+全域xx性能特性加成百分比)+全域xx性能特性加成固值
--无基础全域xx性能加成的就是0
function SelfCreatedZhao:getUniverseValue(param)
    local universeValue = switch(param,{
        ["attack"] = self:getAttackAdd()*(1 + self:getAffixValue(2,"attackAdd")) + self:getAffixValue(1,"attackAdd"),
        ["hit"] = self:getHitAdd()*(1 + self:getAffixValue(2,"hitAdd")) + self:getAffixValue(1,"hitAdd"),
        -- ["parry"] = self:getParryAdd()*(1 + self:getAffixValue(2,"parryAdd")) + self:getAffixValue(1,"parryAdd"),
        -- ["defense"] = self:getDefenseAdd()*(1 + self:getAffixValue(2,"defenseAdd")) + self:getAffixValue(1,"defenseAdd"),
        -- ["dodge"] = self:getDodgeAdd()*(1 + self:getAffixValue(2,"dodgeAdd")) + self:getAffixValue(1,"dodgeAdd"),
        -- ["speed"] = self:getSpeedAdd()*(1 + self:getAffixValue(2,"speedAdd")) + self:getAffixValue(1,"speedAdd"),
        -- ["recovery"] = self:getRecoveryAdd()*(1 + self:getAffixValue(2,"recoveryAdd")) + self:getAffixValue(1,"recoveryAdd"),
        -- ["blood"] = self:getBloodAdd()*(1 + self:getAffixValue(2,"bloodAdd")) + self:getAffixValue(1,"bloodAdd"),
        default = 0
    })

    return universeValue
end

--@desc 获取攻击性能 ( (基础攻击性能*(1+攻击性能特性加成百分比+实际全域攻击性能加成)+攻击性能特性加成固值+攻击性能的特性加成N))*攻击性能转换系数
function SelfCreatedZhao:getAttack()
    local baseAtk = self._data.attack
    local attack = baseAtk * (1 + self:getAffixValue(2,"attack") + self:getSkillUniverseValue("attack"))+ self:getAffixValue(1,"attack")+self:getAttrAttackAdd()

    return attack
end

--@desc 全域攻击性能加成
function SelfCreatedZhao:getAttackAdd()
    return self._data.attackAdd
end

--@desc 全域命中性能加成
function SelfCreatedZhao:getHitAdd()
    return self._data.hitAdd
end

--@desc 全域招架性能加成
function SelfCreatedZhao:getParryAdd()
    return self._data.parryAdd
end

--@desc 全域防御性能加成
function SelfCreatedZhao:getDefenseAdd()
    return self._data.defenseAdd
end

--@desc 全域闪避性能加成
function SelfCreatedZhao:getDodgeAdd()
    return self._data.dodgeAdd
end

--@desc 全域攻速性能加成
function SelfCreatedZhao:getSpeedAdd()
    return self._data.speedAdd
end

--@desc 全域内功治疗性能加成
function SelfCreatedZhao:getRecoveryAdd()
    return self._data.recoveryAdd
end

--@desc 全域内功气血性能加成
function SelfCreatedZhao:getBloodAdd()
    return self._data.bloodAdd
end

-- 攻击性能的特性加成N = 附带属性内功攻击^属性内功攻击系数/(附带属性内功攻击+抵御属性内功攻击*属性内功抵御系数)
function SelfCreatedZhao:getAttrAttackAdd()
    local atkFactor = SelfCreatedSkillManager:getParamsById("affix_sAtk")
    local attrAttackAdds = 0
    for i,v in pairs(SelfCreatedSkillConstants.ZhaoTraitAtkType) do
        local attrAttackAdd = self:getAffixValue(3,v) --附带属性内功攻击
        if attrAttackAdd ~= 0 then
            attrAttackAdds = attrAttackAdds + (attrAttackAdd^atkFactor/attrAttackAdd)
        end
    end
    return attrAttackAdds
end

--@desc 获取命中性能
function SelfCreatedZhao:getHit()
    local baseHit = self._data.hit
    local hit = baseHit * (1 + self:getAffixValue(2,"hit") + self:getSkillUniverseValue("hit"))+ self:getAffixValue(1,"hit")

    return hit
end

--@desc 获取上限伤害
function SelfCreatedZhao:getTopLimit()
    local baseTopLimit = self._data.topLimit
    local topLimit = baseTopLimit * (1 + self:getAffixValue(2,"topLimit") + self:getSkillUniverseValue("topLimit"))+ self:getAffixValue(1,"topLimit")

    return topLimit
end

--@desc 获取体力消耗
function SelfCreatedZhao:getSpirit()
    local baseSpirit = self._data.spirit
    local spirit = baseSpirit * (1 + self:getAffixValue(2,"spirit") + self:getSkillUniverseValue("spirit"))+ self:getAffixValue(1,"spirit")

    return spirit
end

--@desc 获取闪避性能
function SelfCreatedZhao:getDodge()
    return self._data.dodge
end

--@desc 获取攻速性能
function SelfCreatedZhao:getAttackSpeed()
    return self._data.attackSpeed
end

--@desc 防御性能
function SelfCreatedZhao:getDefense()
    return self._data.defense
end

--@desc 招架性能
function SelfCreatedZhao:getParry()
    return self._data.parry
end

--@desc 回复性能
function SelfCreatedZhao:getRecovery()
    return self._data.recovery
end

--@desc 气血性能
function SelfCreatedZhao:getBlood()
    return self._data.blood
end

--@desc 内力性能
function SelfCreatedZhao:getNeiLi()
    return self._data.recoveryNeili
end

--@desc 攻击次数
function SelfCreatedZhao:getAttackNumber()
    return self._data.attackNumber
end

--@desc 主动化编号
function SelfCreatedZhao:getActiveId()
    return self._data.activeId
end

--@desc 主动化描述
function SelfCreatedZhao:getActivetext()
    return self._data.activetext
end

--@desc 动画名1
function SelfCreatedZhao:getAnim1()
    return self._data.anim1
end

--@desc 速度1
function SelfCreatedZhao:getSpeed1()
    return self._data.speed1
end

--@desc 位移1
function SelfCreatedZhao:getOffset1()
    return self._data.offset1
end

--@desc 攻击位置1
function SelfCreatedZhao:getHitPos1()
    return self._data.hitPos1
end

--@desc 动画名2
function SelfCreatedZhao:getAnim2()
    return self._data.anim2
end

--@desc 速度2
function SelfCreatedZhao:getSpeed2()
    return self._data.speed2
end

--@desc 位移2
function SelfCreatedZhao:getOffset2()
    return self._data.offset2
end

--@desc 攻击位置2
function SelfCreatedZhao:getHitPos2()
    return self._data.hitPos2
end

--@desc 动画名3
function SelfCreatedZhao:getAnim3()
    return self._data.anim3
end

--@desc 速度3
function SelfCreatedZhao:getSpeed3()
    return self._data.speed3
end

--@desc 位移3
function SelfCreatedZhao:getOffset3()
    return self._data.offset3
end

--@desc 攻击位置3
function SelfCreatedZhao:getHitPos3()
    return self._data.hitPos3
end

--@desc 伤害类型
function SelfCreatedZhao:getDamageType()
    return self._data.damageType
end

--@desc 文字颜色
function SelfCreatedZhao:getTextColor()
    return self._data.textColor
end

--@desc 攻击位置中文名
function SelfCreatedZhao:getHitPosName(hitPos)
    local hitPosName = switch(hitPos,
        {
            head = "头",
            chest = "胸",
            foot = "腿"
        }
    )
    return hitPosName
end

function SelfCreatedZhao:getAttackLevel()
    return self._selfCreatedZhaoDsc:getAttackLevel()
end

function SelfCreatedZhao:getHitLevel()
    return self._selfCreatedZhaoDsc:getHitLevel()
end

function SelfCreatedZhao:getTopLimitLevel()
    return self._selfCreatedZhaoDsc:getTopLimitLevel()
end

function SelfCreatedZhao:getSpiritLevel()
    return self._selfCreatedZhaoDsc:getSpiritLevel()
end

function SelfCreatedZhao:getDodgeLevel()
    return self._selfCreatedZhaoDsc:getDodgeLevel()
end

function SelfCreatedZhao:getAttackSpeedLevel()
    return self._selfCreatedZhaoDsc:getAttackSpeedLevel()
end

function SelfCreatedZhao:getDefenseLevel()
    return self._selfCreatedZhaoDsc:getDefenseLevel()
end

function SelfCreatedZhao:getParryLevel()
    return self._selfCreatedZhaoDsc:getParryLevel()
end

function SelfCreatedZhao:getRecoveryLevel()
    return self._selfCreatedZhaoDsc:getRecoveryLevel()
end

function SelfCreatedZhao:getBloodLevel()
    return self._selfCreatedZhaoDsc:getBloodLevel()
end

function SelfCreatedZhao:getNeiLiLevel()
    return self._selfCreatedZhaoDsc:getNeiLiLevel()
end

function SelfCreatedZhao:getAttackAddLevel()
    return self._selfCreatedZhaoDsc:getAttackAddLevel()
end

function SelfCreatedZhao:getHitAddLevel()
    return self._selfCreatedZhaoDsc:getHitAddLevel()
end

function SelfCreatedZhao:getParryAddLevel()
    return self._selfCreatedZhaoDsc:getParryAddLevel()
end

function SelfCreatedZhao:getDefenseAddLevel()
    return self._selfCreatedZhaoDsc:getDefenseAddLevel()
end

function SelfCreatedZhao:getDodgeAddLevel()
    return self._selfCreatedZhaoDsc:getDodgeAddLevel()
end

function SelfCreatedZhao:getSpeedAddLevel()
    return self._selfCreatedZhaoDsc:getSpeedAddLevel()
end

function SelfCreatedZhao:getRecoveryAddLevel()
    return self._selfCreatedZhaoDsc:getRecoveryAddLevel()
end

function SelfCreatedZhao:getBloodAddLevel()
    return self._selfCreatedZhaoDsc:getBloodAddLevel()
end

------------------------------------------------------------------------------------------------------------------
-- 直接用于新版战斗的数据
function SelfCreatedZhao:getDamageTypeLv()
    return self._data.damageTypeLv
end

function SelfCreatedZhao:getHurtPosClass()
    return self._data.hurtPosClass
end

function SelfCreatedZhao:getAtkList()
    local atkList = {}
    local list = string.split(self._data.atkList, "#")
    if MapIsEmpty(list) == false then
        for i, zhaoInfoId in ipairs(list) do
            local zhaoInfoRes = SelfCreatedSkillManager:getSelfAutoZhaoInfoById(zhaoInfoId)
            local zhaoInfo = ZhaoInfo:create(zhaoInfoRes)
            
            table.insert(atkList, zhaoInfo)
        end
    else
        assert(false, "自创招式组合:" .. self:getId() .. " 的atkList 解析错误")
    end
    return atkList
end
------------------------------------------------------------------------------------------------------------------

return NewClass("SelfCreatedZhao", { ISelfCreatedZhao }, SelfCreatedZhao)000000000
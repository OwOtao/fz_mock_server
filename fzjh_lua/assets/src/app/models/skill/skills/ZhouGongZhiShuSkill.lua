local BaseSkill = require("app.models.skill.BaseSkill")
local ZhouGongZhiShuSkill = inherit({}, BaseSkill)

local ZhouGongZhiShuLvLimit = {
    ["1"]=1367553,
    ["2"]=2976353,
    ["3"]=4825153,
    ["4"]=6913953,
    ["5"]=9242753,
}

local MaxLvStatus = 5
--增加周公之术经验
function ZhouGongZhiShuSkill:addExp(exp)
    if type(exp) ~= "number" then
        return false
    end

    local lvStatus,currMaxExp = self:getZhouGongZhiShuLvStatus(self.exp)

    if self.exp >= currMaxExp then
        return false
    end

    local addExp = math.min(exp ,currMaxExp - self.exp)

    self.exp = self.exp + addExp

    return addExp
end

local function getSkillLv(exp)
    -- 经验系数A = 3
    -- 经验系数B = 6250
    -- 经验系数C = 5000
    --周公之术等级=((经验系数B^2-4*经验系数A*经验系数C+4*经验系数A*(升级需求总经验 - 1))^0.5-经验系数B)/(2*经验系数A)+2
    return math.floor(((6250 ^ 2 - 4 * 3 * 5000 + 4 * 3 * (exp - 1 )) ^ 0.5 - 6250) / ( 2 * 3) + 2)
end

local function getSkillExp(lv)
    return (((lv - 2) * (2 * 3) + 6250) ^ 2 - 6250 ^ 2 + 4 * 3 * 5000) / (4 * 3) + 1 
end

--获取周公之术等级
function ZhouGongZhiShuSkill:getLv(exp)
    return getSkillLv(exp)
end

function ZhouGongZhiShuSkill:getExp(lv)
    return getSkillExp(lv)
end

function ZhouGongZhiShuSkill:getMaxExp()
    return ZhouGongZhiShuLvLimit[tostring(MaxLvStatus)]
end

function ZhouGongZhiShuSkill:getMaxLv()
    return self:getLv(self:getMaxExp())
end

--获取周公之术当前阶段
function ZhouGongZhiShuSkill:getZhouGongZhiShuLvStatus(exp)
	local curLvStatus,curExp = 1
	for k,v in pairs(ZhouGongZhiShuLvLimit) do
		if exp > v then
			curLvStatus = math.max(curLvStatus,tonumber(k) + 1)
		end
    end
    curLvStatus = math.min(curLvStatus,MaxLvStatus)
	curExp = ZhouGongZhiShuLvLimit[tostring(curLvStatus)]
	return curLvStatus,curExp
end

--突破周公之术 前提是经验必须达到当前阶段经验最大值
function ZhouGongZhiShuSkill:breakZhouGongZhiShuLvLimit()
	local currLv,currMaxExp = self:getZhouGongZhiShuLvStatus(self.exp)
	if currLv >= MaxLvStatus then
		return false
	end
	if self.exp ~= currMaxExp then
		return false
	end
	self.exp = self.exp + 1
	return true
end

return ZhouGongZhiShuSkill0000000000000000
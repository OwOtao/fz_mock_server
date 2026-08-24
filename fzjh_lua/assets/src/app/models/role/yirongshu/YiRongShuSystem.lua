local NewClass = require("third.class.NewClass")

local YiRongShuResManager = require("app.models.role.yirongshu.YiRongShuResManager")

local YiRongShuEffect = require("app.models.role.yirongshu.YiRongShuEffect")

local Record = require("app.models.Record.Record")

local YiRongShuSystem = {}

function YiRongShuSystem:create(role)
    local p = YiRongShuSystem.new()
    p:__init(role)
    return p
end

function YiRongShuSystem:__init(role)
    self.__role = role
end

--@desc: 开始易容
--@author:LvBin
--@time:2024-07-08 18:17:41
--@list: 易容选择数据
--@return
function YiRongShuSystem:doPolymorph(list)
    local polymorph = self.__role:getAttr("polymorph")
    
    polymorph._yirongSelectList = list

	local currAge = self.__role:getAge()

	if list.age == 1 then
		local changeAges = self:getEffectAttr():getYouth()

		local changeAge = math.random(changeAges[1],changeAges[2])

		polymorph.age = math.max(5,currAge - changeAge)
	elseif list.age == 2 then
		local changeAges = self:getEffectAttr():getOlder()

		local changeAge = math.random(changeAges[1],changeAges[2])

		polymorph.age = math.min(ROLE_AGE_LIMIT,currAge + changeAge)
	else
		polymorph.age = currAge
	end

	local currLooks = self.__role:getFinalAttr("looks")

	if list.looks == 1 then
		local changeLooks = self:getEffectAttr():getBeautify()

		local changeLook = math.random(changeLooks[1],changeLooks[2])

		polymorph.pLooks = currLooks + changeLook
    elseif list.looks == 2 then
		local changeLooks = self:getEffectAttr():getUgly()

		polymorph.pLooks = math.random(changeLooks[1], math.min(currLooks,changeLooks[2]))
	else
		polymorph.pLooks = currLooks
	end

	polymorph.lastLooks = self.__role:getAttr("looks") -- 记录易容之前的长相（易容结束要设回来）

	self.__role:setAttr("looks",polymorph.pLooks)	-- 易容之后的长相
	
	if list.sex == 1 then		--性别
		polymorph.sex = "男"
	elseif list.sex == 2 then
		polymorph.sex = "女"
	else
		polymorph.sex = self.__role:getAttr("sex")
	end
	
	local hurtPercent = math.random(1,99)

	local currQiPercent = (self.__role:getAttr("qi") / self.__role:getCurrQiMax()) * 100

	currQiPercent = math.floor(currQiPercent)
	
    if list.qi == 1 then   --气血状态
		polymorph.qi = 100 - hurtPercent
	else
		polymorph.qi = currQiPercent
	end

	local addexp = self:__getAddExp()

	local cdDurationTime = self:__getCdDurationTime()

    local keepTime = self:__getKeepTime()

	local startTime = GetTime() 	--开始时间

	local endTime = startTime + keepTime 	--结束时间
	
    local cdTime = endTime + cdDurationTime

	polymorph.endTime = endTime

	polymorph.cdTime = cdTime
	
    polymorph.keepTime = keepTime

    self.__role:setAttr("polymorph",polymorph)

	Record:addLogData(
		Record.RECORD_TYPE.YiRONGSHU, 
		{
			skillLv = self.__role:getSkillLv("yirongshu"),
			age = currAge,
			polymorphAge = polymorph.age,
			looks = currLooks,
			polymorphLooks = polymorph.pLooks,
			sex = self.__role:getAttr("sex"),
			polymorphSex = polymorph.sex,
			qiPercent = currQiPercent,
			polymorphQiPercent = polymorph.qi,
		}
	)
end


--@desc: 结束易容
--@author:LvBin
--@time:2024-07-09 10:43:50
--@return
function YiRongShuSystem:stopPolymorph()
	local polymorph = self.__role:getAttr("polymorph")

	polymorph.endTime = 0

	polymorph.keepTime = 0

	self.__role:setAttr("looks",polymorph.lastLooks)

	local addExp = self:__getAddExp()
	
	self.__role:addSkillExp("yirongshu",addExp) 	--增加易容术经验

	--文本输出
	local text = "你的易容之术效力消失了，你恢复了之前的容貌。"

	RichPrint("main",text)
end


--@desc: 取消易容
--@author:LvBin
--@time:2024-07-09 10:52:24
--@func: 
--@return
function YiRongShuSystem:cancelPolymorph()
	local polymorph = self.__role:getAttr("polymorph")

	polymorph.endTime = 0

	polymorph.keepTime = 0

	self.__role:setAttr("looks",polymorph.lastLooks)

	local cdDurationTime = self:__getCdDurationTime()
	
	polymorph.cdTime = cdDurationTime + GetTime()  --主动取消易容，重新设置CD时间

	local addExp = self:__getAddExp()

	self.__role:addSkillExp("yirongshu",addExp) 	--增加易容术经验
end

--@desc: 检查角色是否易容
--@author:LvBin
--@time:2024-07-09 11:10:30
--@return
function YiRongShuSystem:checkRoleIsPolymorph()
	local polymorph = self.__role:getAttr("polymorph")

	local endTime = polymorph.endTime
	
	if endTime == 0 then
		return false
	end

	if GetTime() - endTime > 0 then
		-- 玩家角色才停止易容
		if self.__role:getAttr("onlyId") == User:getRoleAttr("onlyId") then
			self:stopPolymorph()
		end

        return false
    end
	
	return true
end

--@desc: 检查易容术是否在cd中
--@author:LvBin
--@time:2024-07-09 11:13:20
--@return
function YiRongShuSystem:checkPolymorphIsCd()
	local polymorph = self.__role:getAttr("polymorph")
	
	local cdtime = polymorph.cdTime

	local endTime = polymorph.endTime
	
	local currTime = GetTime()
	
	if currTime > cdtime or currTime < endTime then
        return false
    end

	return true
end

--@desc: 易容期间，容貌发生改变
--@author:LvBin
--@time:2024-07-09 11:15:46
--@value: 
--@return
function YiRongShuSystem:addPolymorphLastLooks(value)
	if type(value) ~= "number" then
		return
	end

	if self:checkRoleIsPolymorph() then
		local polymorph = self.__role:getAttr("polymorph")

		polymorph.lastLooks = polymorph.lastLooks + value
	end
end

--@desc: 阴阳嬗变
--@author:LvBin
--@time:2024-07-09 11:59:06
--@return
function YiRongShuSystem:genderTransition()
	local polymorph = self.__role:getAttr("polymorph")

	local sexBef = self.__role:getAttr("sex")
	
	local sexAft = ""

	if sexBef == "男" then
		sexAft = "女"
	elseif sexBef == "女" then
		sexAft = "男"
	else
		error("性别错误"..sexBef)
	end

	self.__role:setAttr("sex",sexAft)

	polymorph.genderTransCdTime = GetTime() + self:__getGenderCdDuration()

	Record:addLogData(Record.RECORD_TYPE.GENDER_TRANSITION, {sexbef = sexBef, sexAft = sexAft, family = self.__role:getFamilyId()})
end

--@desc: 能否进行阴阳嬗变
--@author:LvBin
--@time:2024-07-09 12:01:26
--@return
function YiRongShuSystem:isGenderTransition()
	local isResult = true
	
	local msg = ""

	if self:genderTransitionIsCd() then
		isResult = false

		local polymorph = self.__role:getAttr("polymorph")

		local genderTransCdTime = polymorph.genderTransCdTime

		local residueTime = math.max(genderTransCdTime - GetTime(),0)

		local a,b,c = Helper:sec2timeDsc(residueTime)

		msg = "阴阳嬗变还有"..a.."时"..b.."分"..c.."秒后才能再次使用"
	elseif self.__role:hasFamily() then
		isResult = false
		
		msg = "已加入门派无法使用阴阳嬗变"
	end

	return isResult,msg
end

--@desc: 阴阳嬗变是否在cd
--@author:LvBin
--@time:2024-07-09 12:03:40
--@return
function YiRongShuSystem:genderTransitionIsCd()
	local polymorph = self.__role:getAttr("polymorph")

	local genderTransCdTime = polymorph.genderTransCdTime

	if type(genderTransCdTime) == "number" and GetTime() < genderTransCdTime then
		return true
	end
	
	return false
end

--@desc: 获取易容术效果对象
--@author:LvBin
--@time:2024-07-10 18:16:25
--@return  [src.app.models.role.yirongshu.YiRongShuEffect#YiRongShuEffect]
function YiRongShuSystem:getEffectAttr()
	local skillLv = self.__role:getSkillLv("yirongshu")

	local yiRongShuEffectAttr = YiRongShuResManager:getEffectAttrMap()

	for k,v in pairs(yiRongShuEffectAttr) do
        if skillLv >= v.levelMin and skillLv <= v.levelMax then
            return YiRongShuEffect:create(v.id)
        end
    end

	error("易容术效果对象不存在"..skillLv)
end

--@desc: 获取易容术持续时间
--@author:LvBin
--@time:2024-07-09 11:01:22
--@return
function YiRongShuSystem:__getKeepTime()
	local skillLv = self.__role:getSkillLv("yirongshu")

	local keepTime = self:getEffectAttr():getLooksDuration(skillLv)

	return keepTime
end

--@desc: 获取易容术cd持续时间
--@author:LvBin
--@time:2024-07-09 11:01:22
--@return
function YiRongShuSystem:__getCdDurationTime()
	local skillLv = self.__role:getSkillLv("yirongshu")

	local cdDurationTime = self:getEffectAttr():getLooksCd(skillLv)

	return cdDurationTime
end

--@desc: 获取阴阳嬗变冷却时间
--@author:LvBin
--@time:2024-07-10 18:37:01
--@return
function YiRongShuSystem:__getGenderCdDuration()
	local skillLv = self.__role:getSkillLv("yirongshu")

	local cdDurationTime = self:getEffectAttr():getGenderDuration(skillLv)

	return cdDurationTime
end


--@desc: 获取易容术增加经验值
--@author:LvBin
--@time:2024-07-09 11:04:05
--@return
function YiRongShuSystem:__getAddExp()
	local skillLv = self.__role:getSkillLv("yirongshu")
	
	local addExp = self:getEffectAttr():getAddExp(skillLv)

	return addExp
end

--@desc: 获取阴阳嬗变提示文本
--@author:LvBin
--@time:2024-07-10 18:37:01
--@return
function YiRongShuSystem:getGenderTransitionText()
	local cdDurationTime = self:__getGenderCdDuration()

	local timeText = math.floor(cdDurationTime/3600)

	local text = "只有未加入门派的时候才能阴阳嬗变永久改变性别，成功后需要等待"..timeText.."小时才能再次进行切换，请问是否确认进行切换？"
	
	return text
end


return NewClass("YiRongShuSystem", {}, YiRongShuSystem)
00000000000
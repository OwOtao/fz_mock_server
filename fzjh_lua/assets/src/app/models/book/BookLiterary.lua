
-- 书籍系统
local BookLiterary = {}

local Literary = require("script.book.literary.lua")["Sheet1"]

local ExamLiterary = {}

local ReadConstans = TableProxy:createEncryptedTableRecursive({
	theSecondOfOneHour = 3600,
	theFactorOfRead = 200,
})

local function init()
    -- 无字神书不在殿试考试范围内
    for k,v in pairs(Literary) do
        if v.id ~= "wuzishenshu" then
            table.insert(ExamLiterary, v)
        end
    end
end

init()

local stageDesc = -- 阶段描述
{
    {lv = 0, 	dsc = "BLU一窍不通"},
    {lv = 21, 	dsc = "BLU囫囵吞枣"},
    {lv = 51, 	dsc = "HIB不求甚解"},
    {lv = 101, 	dsc = "HIB浅尝辄止"},
    {lv = 151, 	dsc = "CYN一知半解"},
    {lv = 201, 	dsc = "CYN初窥门道"},
    {lv = 251, 	dsc = "HIC略有心得"},
    {lv = 301, 	dsc = "HIC轻车熟路"},
    {lv = 351, 	dsc = "GRN滚瓜烂熟"},
    {lv = 401, 	dsc = "GRN倒背如流"},
    {lv = 451, 	dsc = "YEL了然于心"},
    {lv = 501, 	dsc = "YEL了如指掌"},
    {lv = 601, 	dsc = "HIY如数家珍"},
    {lv = 701, 	dsc = "HIY融会贯通"},
    {lv = 801, 	dsc = "RED举一反三"},
    {lv = 901, 	dsc = "WHT运用自如"},
    {lv = 1001, dsc = "HIW登峰造极"},
}

function BookLiterary:getLiteraryByItemId(itemId)
	for k,v in pairs(Literary) do
		if v.itemId == itemId then
			return v
		end
	end
	return nil
end

function BookLiterary:getLiteraryById(id)
	return Literary[id]
end

--
function BookLiterary:getLiteraryExp(role, literaryId)
end

-- 随机获取一个殿试用到的文学典籍
function BookLiterary:getExamLiterary()
    if MapIsEmpty(ExamLiterary) then
        return nil
    end

    local literary  = ExamLiterary[math.random(1,#ExamLiterary)]

    return literary
end

-- 获得描述
function BookLiterary:getStageDesc(lv)
	local str = "BLU一窍不通"
	for i,v in ipairs(stageDesc) do
		if lv >= v.lv then
			str = v.dsc
		end
	end
	return str
end

-- 获取书籍经验
function BookLiterary:getExp(lv)
	if not lv or type(lv) ~= "number" then
        print("Literary:等级不存在或者不是数字类型")
        return
    end
    local exp
    if lv < 8 then
        exp = lv
    else
        exp = math.ceil((0.015 * lv ^ 3 + 1), 1)
    end
    -- exp = math.ceil((0.015 * lv ^ 3 + 1), 1)
    -- exp = math.ceil((5 * (lv + 1) ^ 1.5 ) + 100, 1)
    return exp
end

-- 获取书籍等级
function BookLiterary:getLv(exp)
	if not exp or type(exp) ~= "number" then
        print("Literary:经验值不存在或者不是数字类型")
        return 0
    end
    local lv
    if exp < 8 then
        lv = exp
    else
        lv = ((exp - 1) / 0.015) ^ (1 / 3)
    end
    -- lv = ((exp - 1) / 0.015) ^ (1 / 3)
    -- lv = ((exp - 100) / 5) ^ (1 / 1.5) - 1
    if Helper:isNan(lv) then
        lv = 0
    end
    lv = tonumber(tostring(lv))
    return math.floor(lv)
end

-- 获得研读每秒提升读书识字的经验
function BookLiterary:getReadExpForSkill(literaryId,shuTongLv)
    local literary = self:getLiteraryById(literaryId) 
    shuTongLv = shuTongLv or 0
    if literary then
        local exp = literary.exp
        if shuTongLv > 2 then
            exp = exp + shuTongLv / 4
        end
        return exp
    end

    return 0
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/05 14:55:20
-- @desc 获取研读每秒提升锻造之术的经验
function BookLiterary:getReadExpForForgeSkill(literaryId)
    local literary = self:getLiteraryById(literaryId)
    if literary then
        return literary.duanzaoexp 
    end
    return 0

end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/05 15:00:50
-- @desc 获取研读每秒提升江湖毒术的经验
function BookLiterary:getReadExpForPoisonSkill(literaryId)
    local literary = self:getLiteraryById(literaryId)
    if literary then
        return literary.dushuexp
    end
    return 0
end

--@desc: 振槁玄经经验
--@author:Liang SongQiang
--@time:2019-07-16 10:50:39
function BookLiterary:getReadExpForZhenGaoXuanJingSkill(literaryId)
    local literary = self:getLiteraryById(literaryId)
    if literary then
        return Helper:getDef(literary.zgxjexp, 0)
    end
    return 0
end


-- 获得每100级对读书识字上限提升的值
function BookLiterary:getReadLvForSkill(literaryId)
    local literary = self:getLiteraryById(literaryId)
    if literary then
        return literary.addLevel
    end
    return 0
end

-- 研读需要读书识字的等级
function BookLiterary:getReadNeedLv(literaryId)
    local literary = self:getLiteraryById(literaryId)
    if literary then
        return literary.needLevel
    end
    return 0
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/05 14:50:59
-- @desc 研读锻造图谱需求锻造之术等级
function BookLiterary:getReadNeedForgeLv(literaryId)
    local literary = self:getLiteraryById(literaryId)
    if literary then
        return literary.duanzaolevel
    end
    return 0
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/05 14:53:01
-- @desc 研读毒经需求江湖毒术等级
function BookLiterary:getReadNeedPoisonLv(literaryId)
    local literary = self:getLiteraryById(literaryId)
    if literary then
        return literary.dushulevel
    end
    return 0
end

-- 获得研读每秒提升的经验 需要悟性
function BookLiterary:getReadSecExp(int,lvByShuTong)
    if int == nil then
        print("BookLiterary:getReadSecExp(int) int is nil")
        return 0
    end
    
    lvByShuTong = lvByShuTong or 0

    local rate = 100 * (ReadConstans.theFactorOfRead + int) / ReadConstans.theFactorOfRead

    local exp = ((ReadConstans.theFactorOfRead * rate / ReadConstans.theSecondOfOneHour) * ( lvByShuTong^2 /10+6))

    if PRINT_MODE == 1 then
        print("BookLiterary:getReadSecExp : ",exp,rate,int,lvByShuTong)
    end

    return exp
end


--判断是否有书童
function BookLiterary:ShuTongIsRoom()
    local role = User:getRole()

    --@desc 首先判断有没有书房，没书房直接为false
    local isHouse = role:getInheritFlag("isBookHouse")
    if isHouse ~= 1 then
        return false
    end

    local roleData = role:getAttr("homeLandRoleData")

    if not roleData or MapIsEmpty(roleData) then
        return false
    end

    if roleData["shutong001"] then
        return true
    end

    return false
end

--@desc: 获取藏书评价
--@author:Liang SongQiang
--@time:2018-06-14 24:04:34
function BookLiterary:getEvaluateDesc()
	local totalPoint = self:getBookPoint(User:getRole())

	local EvaluateDesc =
	{
        {name = "BLU大浪淘沙", point = 0},
        {name = "HIB兼收并蓄", point = 1001},
        {name = "CYN充箱盈架", point = 3001},
        {name = "HIC五花八门", point = 5001},
        {name = "GRN汗牛充栋", point = 7001},
        {name = "YEL书盈四壁", point = 10001},
        {name = "HIY包罗万象", point = 20001},
        {name = "RED坐拥百城", point = 30001},
        {name = "WHT浩如烟海", point = 80001},
        {name = "HIW灿若星河", point = 100001},
	}

	local str = ""

	for i,v in ipairs(EvaluateDesc) do
		if totalPoint >= v.point then
			str = v.name
		end
    end
    
    return str
end

--@desc: 获取藏书积分
--@author:LvBin
--@time:2025-03-18 16:48:33
--@role: 
--@return
function BookLiterary:getBookPoint(role)
    role = role or User:getRole()
	local literaryBox = role:getAttr("literaryBox")
    local totalPoint = 0
	local totalLevel = 0

    for i,v in ipairs(literaryBox) do
		local literary = self:getLiteraryById(v.literaryId)
		local point = literary.jifen * v.count
		if point > literary.jifenlimit then
			point = literary.jifenlimit
		end
		totalPoint = totalPoint + point
		totalLevel = totalLevel + self:getLv(v.exp)
	end

    totalPoint = totalPoint + math.ceil(totalLevel / 10)

    print("藏书积分 bookPoint：".. totalPoint)

    return totalPoint
end

return BookLiterary00
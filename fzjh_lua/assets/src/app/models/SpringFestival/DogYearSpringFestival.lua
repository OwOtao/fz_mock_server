local DogYearSpringFestival = {}

function DogYearSpringFestival:getDogYearSpringFestivalBuff()

	if not self:getDogYearSpringFestivalState() then
		return 0
	else
		return 1
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/16 18:17:57
-- @desc 春节活动开关
function DogYearSpringFestival:getDogYearSpringFestivalState()
	local startTime = os.time({year = 2019,month = 1, day = 7, hour = 0})	-- 起始时间 
	local overTime = os.time({year = 2019,month = 3, day = 3, hour = 0})	-- 结束时间
	if DEBUG_MODE == 1 then
		-- print("---------------2018春节活动开始时间DEBUG_MODE模式为当前时间----------------------------")
		startTime = GetTime() -10
		-- overTime = os.time({year = 2018,month = 1, day = 19, hour = 16})
	end
	local currTime = GetTime()
	if currTime > overTime or currTime < startTime then
		return false
	else
		return true
	end
end





return DogYearSpringFestival00000000
--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-07-09 17:07:16
--]]
local newClass = require("third.class.NewClass")

local YiRongShuResManager = require("app.models.role.yirongshu.YiRongShuResManager")

local HeadViewBasePresent = {}

function HeadViewBasePresent:create()
    return HeadViewBasePresent.new()
end

function HeadViewBasePresent:checkIsPolymorphByParam(polymorph)
	if MapIsEmpty(polymorph) then
		return false
	end

	local currTime = GetTime()
	local endTime = polymorph.endTime
	if endTime == 0 then
		return false
	end
	if currTime - endTime > 0 then
        return false
    end
	return true
end

--@desc: 获取特殊容貌
--@author:LvBin
--@time:2024-07-11 15:26:07
--@list: 
--@return
function HeadViewBasePresent:getSpecialRongMao(list)
    if not MapIsEmpty(list) and YIRONGSHU == true then
		local specialHeadMap = YiRongShuResManager:getSpecialHeadMap()
		for k,v in pairs(specialHeadMap) do
			if v.age == list.age and v.looks == list.looks and v.sex == list.sex and v.injured == list.qi and v.getMaskProbability >= list.luckNum then
				return v.maskid
			end
		end
    end
end

function HeadViewBasePresent:getLookMaskId(looks,sex)
	if sex == "男" then
		sex = 1
	elseif sex == "女" then
		sex = 2
	else
		error("sex is error"..sex)
	end

	local lookMaskMap = YiRongShuResManager:getLookMaskMap()
	
	for k,v in pairs(lookMaskMap) do
		if looks >= v.looksMin and looks <= v.looksMax and sex == v.sex then
			return v.maskid
		end
	end

	error("looks is error"..looks.." sex is error"..sex)
end

return newClass("HeadViewBasePresent", {}, HeadViewBasePresent)0000000000000000
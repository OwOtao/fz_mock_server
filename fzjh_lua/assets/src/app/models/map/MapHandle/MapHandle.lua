local MapHandle = {
	conditionResults = {}
}

local common_list = {
	["baseResults"] = "app.models.map.MapHandle.Modules.BaseResults",
	["CustomNpcUtil"] = "app.models.map.MapHandle.Modules.CommonModule.CustomNpcUtil",
}

local list = {
	-- ["测试模块"] = require("app.models.map.MapHandle.Modules.BaseModule"),
	["CommonResults"] = "app.models.map.MapHandle.Modules.CommonModule.CommonResults",
	["FightResult"] = "app.models.map.MapHandle.Modules.CommonModule.FightResult",
	["SpecialModule"] = "app.models.map.MapHandle.Modules.SpecialModule.SpecialModule",
	["FestivalModule"] = "app.models.map.MapHandle.Modules.FestivalModule.FestivalModule",
	["TaskModule"] = "app.models.map.MapHandle.Modules.TaskModule.TaskModule",
	["HomelandModule"] = "app.models.map.MapHandle.Modules.HomelandModule.HomelandModule",
	["SelfCreatedSkillModule"] = "app.models.map.MapHandle.Modules.SelfCreatedSkillModule.SelfCreatedSkillModule"
}


local emap_list = {
	["EMapResults"] = "app.models.map.MapHandle.Modules.EMapModule.EMapResults",
	["TeacherFamilyModule"] = "app.models.map.MapHandle.Modules.EMapModule.TeacherFamilyModule",
	["MiniGameResults"] = "app.models.map.MapHandle.Modules.EMapModule.MiniGameResults",

	["DreamWorldModule"] = "app.models.map.MapHandle.Modules.EMapModule.DreamWorldModule",

	["FondDrResults"] = "app.models.map.MapHandle.Modules.EMapModule.FondDrResults",
}


--@desc: 进入副本时调用，对副本再次初始化，并把当前副本涉及的条件结果载入副本中
--@author:Liang SongQiang
--@time:2017-11-14 11:36:27
--@map: [src.app.models.map.BaseMap#BaseMap]
--@return 返回初始化后的副本
function MapHandle:entryMap(map)
	local currTime = GetTime()
	local importList = {}

	for k,v in pairs(common_list) do
		importList[k] = v
	end

	if Map:getMapVersionByMapId(map.id) == EDITOR_MAP_VERSION then
		for k,v in pairs(emap_list) do
			importList[k] = v
		end
	else
		for k,v in pairs(list) do
			importList[k] = v
		end
	end

	for k, m_name in pairs(importList) do
		local m = require(m_name)

		if m.status == 0 then
			print(k .. "还未开启")
		else
			if PRINT_MODE == 1 then
				print("----------------- map init --------------------")
			end
			
			m:init(map)
			
			if PRINT_MODE == 1 then
				print("---------------- map init end --------------------")
			end
		end
	end
	
	for k,m_name in pairs(importList) do
		local m = require(m_name)
		if m.status == 0 then
			print(k .. "还未开启")
		else
			if PRINT_MODE == 1 then
				print("----------------- map loadCR --------------------")
			end

			m:loadMap(map,currTime)
			
			if PRINT_MODE == 1 then
				print("---------------- map loadCR end --------------------")
			end
		end
	end
	User:getRole():setFlag(map.id,currTime)
	return map
end


--@desc: 离开副本
--@author:Liang SongQiang
--@time:2017-11-14 16:37:07
-- function MapHandle:leaveMap()
-- 	for k, m in pairs(list) do
-- 		m:leaveMap()
-- 		m._crrMap = {}
-- 	end
-- end


return MapHandle
000000000000
--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local ExamModule = class("ExamModule", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 条件结果的方法
ExamModule.doResult = {
	["乡试"] = function(map, result, environment)
		HttpManagerEx:checkCanExam(0, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					local role = User:getRole()
					
					if role:getTimeLimitFlag("乡试") == 0 then
						PopupLayerController:showLayer("VillageExamLayer", function(layer)
							layer:showLayer()
						end)
					else
						PopText("本周已经参加过乡试了")
					end
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end,
	
	["乡试发榜"] = function(map, result, environment)
		local role = User:getRole()
		if role:getTimeLimitFlag("乡试") == 0 then
			PopText("本周还未参加乡试")
		else
			PopupLayerController:showLayer("ExamScoreLayer", function(layer)
				layer:showLayer("乡试", nil, map.__MapLayer)
			end)
		end
	end,
	
	["省试"] = function(map, result, environment)
		HttpManagerEx:checkCanExam(1, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					local role = User:getRole()
					local Exam = require("app.models.Exam.Exam")
					local state = Exam:checkCanProvinceExam()
					
					-- 1 能参加 2 未参加乡试 3 乡试未通过
					if state == 1 then
						PopupLayerController:showLayer("ProvinceExamLayer", function(layer)
							layer:showLayer(true)
						end)
					elseif state == 2 then
						PopText("乡试未通过，无法参加省试")
					elseif state == 3 then
						PopText("乡试未通过，无法参加省试")
					end
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end,
	
	["省试测试"] = function(map, result, environment)
		PopupLayerController:showLayer("ProvinceExamLayer", function(layer)
			layer:showLayer(false)
		end)
	end,
	
	["省试发榜"] = function(map, result, environment)
		local role = User:getRole()
		HttpManagerEx:getExamPoint(1, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data and data.flag ~= nil then
						if data.cheat == 0 then
							PopupLayerController:showLayer("ExamScoreLayer", function(layer)
								layer:showLayer("省试", data, map.__MapLayer)
							end)
						elseif data.cheat == 1 then
							PopText("考场舞弊者，无法查看！")
						end
					end
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end,
	
	["殿试"] = function(map, result, environment)
		HttpManagerEx:checkCanExam(2, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data and data.id then
						PopupLayerController:showLayer("PalaceExamEntranceLayer", function(layer)
							layer:showLayer(data.id)
						end)
					end
					
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end,
	
	["殿试发榜"] = function(map, result, environment)
		HttpManagerEx:getExamPoint(2, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data and data.flag ~= nil then
						PopupLayerController:showLayer("ExamScoreLayer", function(layer)
							layer:showLayer("殿试", data)
						end)
					end
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end,
	
}




return ExamModule000
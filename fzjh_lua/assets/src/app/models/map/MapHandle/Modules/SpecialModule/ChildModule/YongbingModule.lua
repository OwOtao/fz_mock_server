--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local YongbingModule = class("YongbingModule", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 条件结果的方法
YongbingModule.doResult = {
	
	-- add by XiaoZhiWei 2017/04/25 21:22:53
	["开启佣兵模式"] = function(map, result, environment)
		local player = User:getRole()
		player:setFlag("佣兵模式", "开启")
		map:refreshYongBingRole(environment.currRoomId)
	end,
	
	-- add by XiaoZhiWei 2017/04/25 21:22:53
	["关闭佣兵模式"] = function(map, result, environment)
		local player = User:getRole()
		player:setFlag("佣兵模式", "关闭")
		map:refreshYongBingRole(environment.currRoomId)
	end,
	
	-- add by XiaoZhiWei 2017/04/25 21:22:53
	["佣兵处罚模式"] = function(map, result, environment)
		local player = User:getRole()
		player:setFlag("佣兵模式", "处罚")
		map:refreshYongBingRole(environment.currRoomId)
	end,
	
	["佣兵给予"] = function(map, result, environment)
		local player = User:getRole()
		PopupLayerController:showLayer("YongBingBagLayer", function(layer)
			layer:showLayer(player, map:getYongBingRole())
		end)
	end,
	
}



return YongbingModule0
--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local JianZhen = class("JianZhen", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
JianZhen.mapId = {["fb33"] = true}


--@desc 条件结果的方法
JianZhen.doResult = {
	["开启剑阵"] = function(map, result, environment)
		--result.arg3
		--fb33专用
		--把fb33r36_1~fb33r36_8 随机放到 fb33_36~fb33_44,40不要放
		local tmp_roomlist = { "fb33_36" , "fb33_37" , "fb33_38" , "fb33_39" , "fb33_41" , "fb33_42" , "fb33_43" , "fb33_44" }

		--起始位置
		local start_index = math.random( 0 , 7 )
		for i = 1 , 8 do
			print( "addRoomRole " .. ((start_index + i)%8 + 1 ) .. " fb33r36_"..i )
			map:addRoomRole( tmp_roomlist[ (start_index + i)%8 + 1 ] , "fb33r36_"..i )
		end

		local direction_word = {"西北","正北","东北","正东","东南","正南","西南","正西"}
		--local door_word = {"惊","开","生","景","伤","休","死","杜"}
		local door_word = {"惊","开","休","生","伤","杜","景","死"}

		local right_index = ( start_index + math.random( 1 , 8 ) ) % 8 + 1 --生成对的词
		local err_index = ( right_index + math.random( 1 , 7 ) ) % 8 + 1 --生成错的词1
		local err2_index = ( err_index + math.random( 1 , 7 ) ) % 8 + 1 --生成错的词2

		RichPrint( "main" , "YEL棠以斐：尔等贼子，居然敢犯我无量山，今日让你有来无回，来人，布阵！" )
		if math.random( 1 , 2 ) == 1 then
			RichPrint( "main" , "YEL棠以斐：八门加身，无量无我！"..door_word[right_index].."水无望是"..direction_word[(right_index+start_index)%8+ 1 ].."，"..direction_word[err_index].."且随天成"..door_word[err2_index].."!" )
		else
			RichPrint( "main" , "YEL棠以斐：八门加身，无量无我！"..door_word[err_index].."水无望是"..direction_word[err2_index].."，"..direction_word[right_index].."且随天成"..door_word[(right_index+start_index)%8+ 1 ].."!" )
		end
	end,
}



return JianZhen00000000000
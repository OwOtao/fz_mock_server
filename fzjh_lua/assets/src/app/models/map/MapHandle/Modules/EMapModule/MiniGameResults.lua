--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local MiniGameResults = class("MiniGameResults", require("app.models.map.MapHandle.Modules.BaseModule"))


--@desc 条件结果的方法
MiniGameResults.doResult = {
	["华容道"] = function(map, result, environment)

		local game_time = result.arg2

		local succResult = result.arg3

		local failedResult = result.arg4

		PopupLayerController:showLayer("HuaRongDaoLayer",function (layer)
			local currRole = environment.currRole
			local operations = nil
			if currRole ~= nil then
				operations = currRole.operations
			end
			
			if MapIsEmpty(operations) then
				operations = environment.currRoom.operations
			end
			
			layer:setSuccessCallBack(function ()
				if operations == nil then
					return
				end
				map:doOperationById(succResult, operations, environment)
			end)
			
			layer:setFailCallBack(function ()
				if operations == nil then
					return
				end
				map:doOperationById(failedResult, operations, environment)
			end)
			
			layer:showLayer(tonumber(game_time))
		end)
	end,

	["云梯采灯"] = function(map, result, environment )
    --arg1=云梯采灯 arg2=每日免费次数 arg3=购买每次花费元宝数量 arg4=进入文本 arg5=离开文本

        local maxFreeTimes = result.arg2 or 3
        local freeTimes = maxFreeTimes - User:getRole():getDayFlag("采灯免费次数")
        HttpManagerEx:getActionTimes("LadderLantern",function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local startText,endText,desText
                local LanternDate ={}
                LanternDate.currYuanBao = data.yuanbao
                LanternDate.currTimes = data.num + freeTimes
                LanternDate.maxFreeTimes = maxFreeTimes
                LanternDate.currBuyPrice = result.arg3 or 10
                startText = result.arg4 or "你伸手抓住了云梯上面垂下的彩绸，脚下如生羽翼，唰唰几下便踏着梯木三步并两，抵达了云梯最顶层。"
                endText = result.arg5 or "你半掀衣袍，提气而纵，从云梯顶端飞速的降了下来。"
                desText = "不同的彩灯藏有不同颜色的纸签，所获得的奖励也不同，请少侠谨慎选择。" 
                PopupLayerController:showLayer("LadderLanternLayer",function (layer)
                    layer:showLayer(LanternDate,startText,endText,desText)
                end)
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING)
    end,

    ["纸签兑换"] = function(map, result, environment )
        PopupLayerController:showLayer("LadderLanternRewardLayer",function (layer)
            layer:showLayer()
        end)
    end,
	
	["琴音助功"] = function(map, result, environment)
		local questionTime = result.arg2 --每题时间（秒）
		local questionNum = result.arg3 --题目数量
		local needNum = result.arg4 --成功需要答对的题目数量
        local succResult = result.arg5 --成功结果
        local failedResult = result.arg6 --失败结果
		PopupLayerController:showLayer("SoundAssistsLayer", function(layer)
			layer:showLayer(map,environment,questionTime,questionNum,needNum,succResult,failedResult)
		end)
    end,
}



--@desc: 
--@author:Liang SongQiang
--@time:2019-08-27 14:41:52
function MiniGameResults:entryMap(map,currTime)
	if PRINT_MODE == 1 then
		print("EntryMap(): id: " .. map.id, "name: " .. map.name)
	end
end

return MiniGameResults000000000
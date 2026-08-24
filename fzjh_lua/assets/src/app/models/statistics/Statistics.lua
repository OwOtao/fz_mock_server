local Statistics = 
{
}

-- 保存统计数据
local statisticsData = 
{
	items = {}, 	-- 物品记录列表
	itemsUpTime = 0, -- 上次上传的时间
	itemsUpData = {} -- 正在上传的数据, 可能上传响应过程中也有新的记录产生,直接全部移除会造成误差
}

-- 保存到本地的luatable的key
local LUATABLE_KEY = md5:getMd5("statisticsData")
-- local LUATABLE_KEY = "statisticsData"

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/17 18:56:55
-- @desc 统计物品获得数量
function Statistics:recordItemCount(itemId, count)
	if itemId == nil or count == nil or type(count) ~= "number" then
		return
	end
	statisticsData.items[itemId] = Helper:getDef(statisticsData.items[itemId], 0)
	statisticsData.items[itemId] = statisticsData.items[itemId] + count
	self:save()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/18 10:03:09
-- @desc 上传记录的物品数据到服务器
function Statistics:uploadItemStatisticsData()
	local lastUploadTime = Helper:getDef(statisticsData.itemsUpTime, 0) 
	if GetTime() - lastUploadTime <= 10800 then -- 3小时上传一次
		if PRINT_MODE == 1 then
			print("上传时间间隔太短了", GetTime(), lastUploadTime)
		end
		return
	end
	local data = Helper:getDef(statisticsData.items, {})
	local upLoadData = Helper:getDef(statisticsData.itemsUpData, {})
	if MapIsEmpty(data) == true and MapIsEmpty(upLoadData) == true then
		if PRINT_MODE == 1 then
			print("没有需要上传数据")
		end
		return
	end
	for k,v in pairs(upLoadData) do
		if data[k] ~= nil then
			data[k] = data[k] + v
		else
			data[k] = v
		end
	end
	-- 将上传的数据存到上传列表,再清空本地列表.如果在响应完成后再情况,有可能会引起误差
	statisticsData.itemsUpData = data
    statisticsData.items = {}
    self:save()
	HttpManagerEx:retryPostWithHeader("collect_spring_data", clone(data), nil,--NEEDTOCHECK
    function(response, status)
    	local responseData = json.decode(JMForLua:decrypt(response))
        if status == 200 and responseData.errcode == 0 then
        	-- 确保上传成功了,再清空本地数据并且更新上传时间
        	statisticsData.itemsUpData = {}
            statisticsData.itemsUpTime = GetTime()
            self:save()
        else
        end
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/18 10:17:17
-- @desc 初始化数据
function Statistics:init()
	self:load()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/17 20:10:08
-- @desc 统计从本地读取
function Statistics:load()
    local data = DataBase:getLuaTable(LUATABLE_KEY)
    Helper:tableCover(statisticsData, data) -- 通过存档覆盖当前结构
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/17 21:37:18
-- @desc 保存统计数据
function Statistics:save()
	DataBase:setLuaTable(LUATABLE_KEY, statisticsData)
end

return Statistics00000000
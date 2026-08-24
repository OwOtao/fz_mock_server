local  RongLianDialogLayer = class("FurnaceLayer",cc.Layer)
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
function RongLianDialogLayer:create()
	local p = RongLianDialogLayer:new()
	p:init()
	return p
end

function RongLianDialogLayer:init()
	self._UI = require("Layer/ShenBing/RongLianDialogUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setVisible(false)
end

function RongLianDialogLayer:showLayer(func,temperature,upperTemperature)
	if func then
		self.backFunc = func
	else
		self.backFunc = function()

		end
	end

	self.musicId = Audio:playEffect("RongLian",true)

	self:setPanelAnimation(temperature,upperTemperature)
	self:show()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/03 15:57:01
-- @desc 界面动画
function RongLianDialogLayer:setPanelAnimation(temperature,upperTemperature)
	print(temperature, type(temperature))
	-- self.Panel_1:setVisible(false)
	self.Text_time:setVisible(false)
	self.Text_state:setVisible(false)
	self.ListView_1:setPosition(537,1086)
	self.Panel_1:setPosition(537,1086)
	self.Button_ranliao:setOpacity(0)
	self.Button_neili:setOpacity(0)
	local MOVE_TIME = 0.5
	local FADE_TIME = 1
	local animation = cc.Sequence:create(cc.CallFunc:create(function()
		local moveTo = cc.MoveTo:create(MOVE_TIME,cc.p(330,928))
		self.ListView_1:runActionWithName("moveTo",moveTo)
		moveTo = cc.MoveTo:create(MOVE_TIME,cc.p(330,928))
		self.Panel_1:runActionWithName("moveTo",moveTo)
	end),cc.DelayTime:create(MOVE_TIME),cc.CallFunc:create(function()
		local fadeIn = cc.FadeTo:create(FADE_TIME,255)
		self.Button_ranliao:runActionWithName("fadeIn",fadeIn)
		self:delayFunc(FADE_TIME,function()
			fadeIn = cc.FadeTo:create(FADE_TIME,255)
			self.Button_neili:runActionWithName("fadeIn",fadeIn)
		end)
	end),cc.DelayTime:create(FADE_TIME*2),cc.CallFunc:create(function()
		self:setInitValue(temperature,upperTemperature)
		self:setSchedule()
		self:setTanLiaoButton()
		self:setAddNeiLiButton()
		self.Text_time:setVisible(true)
		self.Text_state:setVisible(true)
	end))
	self:runActionWithName("animation",animation)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 19:59:53
-- @desc 初始值
function RongLianDialogLayer:setInitValue(temperature,upperTemperature)
	self.time = 20--煅烧持续时间
	-- if DEBUG_MODE == 1 then
	-- 	self.time = 5
	-- end
	self.temperature = temperature--初始温度
	self.upperTemperature = upperTemperature --上线温度
	print("-------------------------self.temperature,self.upperTemperature-------------------------------------",self.temperature,self.upperTemperature)
	self.extraSmelt = 0
	self.printTime = 2
	self.itemCount = 0
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 21:11:28
-- @desc 设置熔炉内熔点最高的物品Id
function RongLianDialogLayer:setForging(itemId,forgeTemp)
	self.forging = assert(itemId)
	self.forgeTemp = forgeTemp
end


function RongLianDialogLayer:setRefreshNeiLiAndGoldFunc(func)
	if func then
		self.nlFunc = func
	end
end

function RongLianDialogLayer:setPrintFunc(func)
	if func then
		self.printFunc = func
	end
end

--熔炼状态
function RongLianDialogLayer:getRongLianState()
	local state = ""
	if self.temperature < 1200 then
		state = "普通"
	elseif self.temperature >= 1200 and self.temperature < 1800 then
		state = "颇高"
	elseif self.temperature >= 1800 and self.temperature < 2500 then
		state = "高"
	elseif self.temperature >= 2500 then
		state = "极高"
	end
	return state
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 21:00:39
-- @desc


function RongLianDialogLayer:setSchedule()
	self:setTime()
	self.time = self.time - 1
	local count = 0
	local itemAttr = Item:getOneItemByKey(self.forging)
	self:print("HIC你点燃熔炉，将材料投入炉中，熊熊火焰吞没了材料，你只得从熔炉隐约见到炉内的情景。")

	print("-----------------------------------------",self.temperature,type(self.temperature))
	if itemAttr.melting ~= nil then
		self:setDuanShaoState("【熔炼程度】"..self:getRongLianState())
	end
	self.handle = self:schedule(function()
		if self.time > 0 then
			count = count + 1
			self.time = self.time - 1
			self:printText(count)
		else
			PopupLayerController:hideLayer("RongLianDialogLayer",function(layer)
				layer:unschedule(self.handle)
				self.handle = nil
				layer:print("HIW煅烧时间已到，炉火渐熄，温度渐渐降了下来。")
				layer:getResult()
				layer:hide()
			end,0)
		end
	
		self:setTime()
	end,1.0)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 14:08:27
-- @desc 熔炼文本
function RongLianDialogLayer:printText(count)
	--炉温文本
	local tempText = {
		[1] = "CYN熔炉内火焰正在煅烧，火势较好。",
		[2] = "HIB熔炉中的火熊熊燃烧，你站在周围亦感到十分炎热。",
		[3] = "HIC熔炉中的火熊熊燃烧，你站在周围不禁感到汗流浃背。",
		[4] = "HIW熔炉周围温度极高，你根本无法靠近，只能在一旁等着。"
	}
	--炉温大于所有材料的熔点
	local forgeText = {
		"HIC你看着炉内，炉内全部被烈火所覆，想必此次熔炼应该无甚问题。",
		"HIC炉火熊熊燃烧，里面的材料已经快被熔炼完全，接下来只需等待时间即可。",
		"HIC炉火吞噬着材料，让你看不清炉内的情况，不过看这势头，这次熔炼应该会成功。"
	}
	--炉中还有材料未融化
	local unForgeText = {
		"HIR炉火虽然一直在煅烧着材料，但炉中似乎还有材料未被熔炼完全。",
		"HIR你通过风口看向熔炉内，似乎材料未能煅烧完全，看来这炉温仍是不够。"
	}



	if count % (self.printTime * 2) == 0 then
		local random = math.random(1,#tempText)
		self:print(tempText[random])
	elseif count % (self.printTime * 2) ~= 0 and count % self.printTime == 0 then
		if self.temperature >= self.forgeTemp then
			local random = math.random(1,#forgeText)
			self:print(forgeText[random])
		else
			local random = math.random(1,#unForgeText)
			self:print(unForgeText[random])
		end
	end
end


function RongLianDialogLayer:getResult()
	if self.printFunc then
		self.printFunc("熔炼完成")
	end
	if self.musicId then
		Audio:stopEffect(self.musicId)
		self.musicId = nil
	end
	if self.backFunc then
		self.backFunc(self.temperature)
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 21:01:41
-- @desc 投放燃料
function RongLianDialogLayer:setTanLiaoButton()
	self.Button_ranliao:releaseFunc(function()
		if self.handle ~= nil then
			self:pauseSchedulerAndActions(self.handle)
		end
		PopupLayerController:showLayer("ShenBingBagLayer",function(layer)

			layer:btnLeftClickFunc(function()
				if self.handle ~= nil then
					self:resumeSchedulerAndActions(self.handle)
				end
				layer:destory()
			end, "取消")
			layer:btnRightClickFunc(function(leftList,rightList)
				if self.handle ~= nil then
					self:resumeSchedulerAndActions(self.handle)
				end
				local addTemp = 0
				for k,itemData in pairs(rightList) do 
					User:getRole():addItemCount(itemData.itemId,0-itemData.count)
					self.temperature = self.temperature + itemData.temperature * itemData.count
					addTemp = addTemp + itemData.temperature * itemData.count
					self.extraSmelt = self.extraSmelt + itemData.itemmelting * itemData.count
				end
				if DEBUG_MODE == 1 then
					print("---------------------投入的材料信息--------------------------------")
					Helper:print_lua_table(rightList)
					print("--------------------------本次投入材料增加温度-------------------------------------",addTemp)
				end
				self:addRanLiaoText(addTemp)
				local itemAttr = Item:getOneItemByKey(self.forging)
				if itemAttr.melting ~= nil then
					self:setDuanShaoState("【熔炼程度】"..self:getRongLianState())
				end
				layer:destory()
			end, "确定")
			local temperature = self.temperature
			layer:setCondiPushRightList(function(leftList, rightList,item)--从左向右放
				if DEBUG_MODE == 1 then
					print(self.upperTemperature,"---温度上限，当前温度,材料使用温度的下限和上限-------------------------",temperature,item.downTemp,item.upTemp)
				end
				if item.downTemp <= temperature and item.upTemp >= temperature then
					if self.upperTemperature >= temperature +item.temperature then
						temperature = temperature +item.temperature
						if DEBUG_MODE == 1 then
							print("----------------------------------投入材料后炉温:",temperature)
						end
						return true
					else
						PopText("此炉已无法再承受更高的温度")
						return
					end
				end
				PopText("此材料已经无法影响熔炉温度")
				return false
			end)
			layer:setCondiPushLeftList(function(leftList, rightList,item)--从右向左放
				temperature = temperature - item.temperature
				return true
			end)
			 for k,itemData in pairs(User:getRole():getItems()) do 
			 	local itemmelting = ShenBingDuanZao:getItemmelting(itemData.itemId)
			 	if itemmelting ~= nil and User:getRole():checkItemIsEquip(itemData.id) == false then
			 		Helper:tableCover(itemData,itemmelting)
			 		Helper:print_lua_table(itemData)
					layer:pushItemToLeftList(itemData,function(item,func)
						if func then
							func()
						end
					end)
			 	end
			 end
			layer:setRightName("铁匠")
			layer:setTextMoney("黄金："..User:getRole():getAttr("gold"))
			
			layer:show()
		end)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 14:37:52
-- @desc 投入燃料文本
function RongLianDialogLayer:addRanLiaoText(addTemp)
	addTemp = Helper:getDef(addTemp,0)
	if DEBUG_MODE == 1 then
		print("———————————————————————投入燃料炉温增加—————————————————————————————————",addTemp)
	end
	local lowText = {
		"GRN你将燃料一股脑投入火炉，火炉瞬间便将其吞噬殆尽，但似乎效果不是很好。",
		"GRN你将燃料投入火炉，但火炉温度似乎没有什么变化。"
	}
	local midText = {
		"HIG你将燃料放入炉中，熔炉的温度提高了，而且火焰颜色居然也发生了变化，不知是什么情况。",
		"HIG你将燃料放入炉中，炉火似乎大了不少，而且火焰颜色居然也发生了变化，不知是什么情况，看来效果不错。"
	}
	local highText = {
		"HIC你将燃料投入火炉，火炉温度骤然提升，火苗几乎要从炉中蹿出来，火焰颜色居然也发生了变化，不知是什么情况。",
	}
	local text = ""
	if addTemp < 20 then
		local random = math.random(1,#lowText)
		text = lowText[random]
	elseif addTemp >= 20 and addTemp < 100 then
		local random = math.random(1,#midText)
		text = midText[random]
	else
		local random = math.random(1,#highText)
		text = highText[random]
	end
	self:print(text)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 21:05:45
-- @desc 注入内力
function RongLianDialogLayer:setAddNeiLiButton()
	self.Button_neili:releaseFunc(function()
		local role = User:getRole()
		self.addNeiliTime = Helper:getDef(self.addNeiliTime,0)
		local neiliMax = math.floor(role:getFinalAttr("neiliMax"))
		if GetTime() - self.addNeiliTime >= 0.5 then
			self.addNeiliTime = GetTime()
			local cost,add,needMax = 0,0,10000
			if self.temperature >= self.upperTemperature then
				PopText("注入内力已经无法影响熔炉温度了")
				return
			end
			if self.temperature >= 800 and self.temperature <= 1000 then
				cost,add,needMax = 100,40,3000
			elseif self.temperature >= 1001 and self.temperature <= 1200 then
				cost,add,needMax = 150,35,5000
			elseif self.temperature >= 1201 and self.temperature <= 1500 then
				cost,add,needMax = 180,30,8000
			elseif self.temperature >= 1501 and self.temperature <= 2000 then
				cost,add,needMax = 200,25,10000
			elseif self.temperature >= 2001 and self.temperature <= 2300 then
				cost,add,needMax = 300,20,12000
			elseif self.temperature >= 2301 and self.temperature <= 30000 then
				cost,add,needMax = 400,10,16000
			else
				PopText("内力已经无法提升熔炉温度")
				return 
			end
			if neiliMax <= needMax then
				PopText("内力最大值低于内力需求最大值，不能注入内力")
				return
			end
			if neiliMax >= cost then
				self.temperature = self.temperature + add
				role:addAttr("neiliMax",0-cost)
				self:print("内力消耗"..tostring(cost))
				self:setNeiLiAndGold()
				local itemAttr = Item:getOneItemByKey(self.forging)
				if itemAttr.melting ~= nil then
					self:setDuanShaoState("【熔炼程度】"..self:getRongLianState())
				end
				local text = {
					"你将一股内力注入熔炉，熔炉温度骤然提升。",
					"你运起真气，灌入炉中，在你的内力催动下，炉温提高了。",
					"你提功运气，将一股精纯真气灌入炉中，却见炉火刹那间变大，温度骤然提升。"
				}
				if add <= 100 then
					text = {
						"GRN你将一股内力注入熔炉，熔炉温度骤然提升。",
						"GRN你运起真气，灌入炉中，在你的内力催动下，炉温提高了。"
					}
				elseif add >=101 and add <= 200 then
					text = {"HIG你提功运气，将一股精纯真气灌入炉中，却见炉火刹那间变大，温度骤然提升。"}
				else
					text = {"HIC你猛运一股真气，将其注入炉中，只见炉火猛然变大，炉温骤然提升。"}
				end

				self:print(text[math.random(1,#text)])
			else
				PopText("内力不足")
			end
		else
			PopText("真气运转不流畅，还是等一下吧")
		end
	end)

end



-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 21:09:31
-- @desc 熔炼情况
function RongLianDialogLayer:setDuanShaoState(str)
	assert(str)
	self.Text_state:setString(str)
end

function RongLianDialogLayer:setNeiLiAndGold()
	if self.nlFunc then
		self.nlFunc()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/21 12:28:02
-- @desc 文本输出
function RongLianDialogLayer:print(str)
	if self.printFunc then
		self.printFunc(str)
	end
end
-- function 
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 20:55:55
-- @desc 设置剩余时间
function RongLianDialogLayer:setTime()
	self.Text_time:setString("【剩余时间】"..tostring(self.time).."s")
end
Helper:classDefNodeGetInstance(RongLianDialogLayer)
return  RongLianDialogLayer000000000000000
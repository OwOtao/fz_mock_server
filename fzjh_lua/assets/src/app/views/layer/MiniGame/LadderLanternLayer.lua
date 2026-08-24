--
-- Author: TanQinJian
-- Date: 2019-10-29 11:08:48
--
-- 钓鱼玩法
local LadderLanternLayer = class("LadderLanternLayer", LayerEx)
local LadderLanternPaperUtil = require("app.models.LadderLantern.LadderLanternPaperUtil")

function LadderLanternLayer:create()
	local p = LadderLanternLayer:new()
	p:init()
	return p
end

function LadderLanternLayer:init()
	self._UI = require("Layer/MiniGame/LadderLanternUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
    self.startText = ""
	self.endText = ""
	self.desText = ""
end

function LadderLanternLayer:showText(str)
	self.Text_ActionDesc:setVisible(true)
	self.Text_ActionDesc:setString(str)
	self.Text_ActionDesc:setScale( 0.5 , 0.5 )
	self.Text_ActionDesc:runAction( 				
				 	cc.Sequence:create(
				 		YXEaseAction:create(cc.ScaleTo:create( 0.1 , 1.1 , 1.1 ) , Sine_EaseOut),
				 		cc.DelayTime:create( 0.15 ),
				 		YXEaseAction:create(cc.ScaleTo:create( 0.2 , 1.0 , 1.0 ) , Sine_EaseIn)
				 	)
				)
end

function LadderLanternLayer:initUIAndButtonFunc()
	self.Panel_Bg:releaseFunc(
		function()
			self:setCanGetLantern(false)
		end
	)

	self.Panel_Game.Image_titleBack.Button_back:releaseFunc(
		function()
			self:setCanGetLantern(false)
			self:hideLayer()
		end
	)
	
	self.Panel_Game.Button_Up:releaseFunc(
		function()
			local function DoLadderLantern()
				local currPaper = LadderLanternPaperUtil:getRandomPaper()
				PopText("你获得了"..currPaper.paperName)
				LadderLanternPaperUtil:setRolePaperData(currPaper.id,1)
				self.currTimes = self.currTimes - 1
				self:refreshTimes()
			end

			if self.currTimes > 0 then 
				if self.maxFreeTimes - User:getRole():getDayFlag("采灯免费次数") > 0 then 
					DoLadderLantern()
					User:getRole():setDayFlag("采灯免费次数",User:getRole():getDayFlag("采灯免费次数")+1)
				else
					HttpManagerEx:checkItemIsCanUse(
						"LadderLantern",1,
						function(status, errcode, errmsg, data)
							if status == 200 and errcode == 0 then
								DoLadderLantern()
							else
								PopText(errmsg)
							end
						end,
					IS_SHOW_WAITING)
				end
			else
				PopText("你采灯的次数不足")
			end
		end
	)

	self.Panel_Game.Button_Buy:releaseFunc(
		function()
			self:setCanGetLantern(false)
			if self.currYuanBao < self.currBuyPrice then 
				PopText("元宝不足")
				return
			end
			PopupLayerController:showLayer("BatchProcessLayer",function(batchLayer)
				batchLayer:showLayer()
				batchLayer:setCurrencyUnit("元宝")
				batchLayer:setBuyPrice(self.currBuyPrice)
				batchLayer:setInitNum(1)
				batchLayer:setMinNum(1)
				batchLayer:setMaxNum(math.min(99,math.floor(self.currYuanBao/self.currBuyPrice)))
				batchLayer:setTextDesc("采灯次数")
				batchLayer:setTextDesc4("选择你要购买的数量")
				batchLayer:setTextDesc5("售价："..self.currBuyPrice.."元宝")
				batchLayer:setButtonConfirm(function(batchBuyNum)
					local text = "确定花费"..tostring(self.currBuyPrice*batchBuyNum).."元宝购买"..tostring(batchBuyNum).."次采灯机会？"
					local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			        local dialog = DialogALayer:getInstance()
			        dialog:hide()
			        dialog:show(text)
			        dialog:setRichText(text)
			        dialog:setButton1("确定", function()
			           HttpManagerEx:submitAction("LadderLantern",tonumber(batchBuyNum),function(status, errcode, errmsg, data)
	                        if status == 200 and errcode == 0 then
								PopText("购买成功")
								self.currTimes = self.currTimes + tonumber(batchBuyNum)
								self.currYuanBao = data.yuanbao
								self:refreshTimes()
							else
								PopText(errmsg)
							end
	                    end, IS_SHOW_WAITING)
			        end)
			        dialog:setButton2("取消", function()
			        end)
			        dialog:setWeChatVisible(false)
					
				end)
			end)
		end
	)

	self.Panel_Game.Button_Down:releaseFunc(
		function()
			self:setCanGetLantern(false)
			self.Text_ActionDesc:setVisible(true)
			self.Panel_Game:setVisible(false)
			self:showText(self.endText)
			self:delayFunc(1,function()
				self:hideLayer()
			end)
		end
	)

	for i=1,6 do
		self.Panel_Game["Image_"..tostring(i)]:setTouchEnabled(true)
		self.Panel_Game["Image_"..tostring(i)]:releaseFunc(
			function()
				self:setCanGetLantern(true)
				self.Panel_Game.Image_Select:setPosition(self.Panel_Game["Image_"..tostring(i)]:getPosition())
			end
		)
	end 

	self.Panel_Game.Button_Down.Text_Down:setString("下梯")
	self.Panel_Game.Button_Buy.Text_Buy:setString("购买")
	self.Panel_Game.Button_Up.Text_Up:setString("采灯")
	self.Panel_Game.Text_times:setString("剩余次数："..tostring(self.currTimes))
	self.Panel_Game.Text_desc:setString(self.desText)

end

function LadderLanternLayer:refreshTimes()
    self.Panel_Game.Text_times:setString("剩余次数："..tostring(self.currTimes))
end

function LadderLanternLayer:setCanGetLantern(enabled)
	if not enabled then 
		enabled = false
	end
	self.Panel_Game.Button_Up:setTouchEnabled(enabled)
	self.Panel_Game.Image_Select:setVisible(enabled)
	if enabled then 
		self.Panel_Game.Button_Up:loadTextureNormal("Image/UI/TaskUI/anniu.png")
	else
		self.Panel_Game.Button_Up:loadTextureNormal("Image/UI/TaskUI/anniuhui.png")
	end

end

function LadderLanternLayer:hideLayer()
	if self.rolePVPState == "空闲中" then 
        User:getRole():setFlag("PVP活动状态","空闲中")
    end
    PopupLayerController:hideLayer("LadderLanternLayer", function(layer)
        layer:hide()
    end)
end

function LadderLanternLayer:startShow()
	self:showText(self.startText)
	self.Panel_Game:setVisible(false)
	self:setCanGetLantern(false)
	self:delayFunc(1,function()
			self.Text_ActionDesc:setVisible(false)
			self.Panel_Game:setVisible(true)
			self:initUIAndButtonFunc()
		end)
end

--LanternDate 彩灯数据 type:table {currYuanBao,currTimes,currBuyPrice,maxFreeTimes}  玩家当前元宝;剩余次数;价格;免费次数
function LadderLanternLayer:showLayer(LanternDate,startText,endText,desText)
	LadderLanternPaperUtil:fixPaperData()
	self:show()
	self.startText = startText or ""
	self.endText = endText or ""
	self.desText = desText or ""
	if MapIsEmpty(LanternDate) then 
		self.currYuanBao = 0
		self.currTimes = 0
		self.currBuyPrice = 0
		self.maxFreeTimes = 0
	else
		self.currYuanBao = LanternDate.currYuanBao
		self.currTimes = LanternDate.currTimes
		self.currBuyPrice = LanternDate.currBuyPrice
		self.maxFreeTimes = LanternDate.maxFreeTimes
	end

	self:startShow()
	self.rolePVPState = User:getRole():getFlag("PVP活动状态")
    if self.rolePVPState == "空闲中" then 
        User:getRole():setFlag("PVP活动状态","忙碌")
    end
end

Helper:classDefNodeGetInstance(LadderLanternLayer)

return LadderLanternLayer00000000000000
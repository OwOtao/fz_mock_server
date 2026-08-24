local MeridianDiseaseLayer = class("MeridianDiseaseLayer", LayerEx)
function MeridianDiseaseLayer:create()
	local p = MeridianDiseaseLayer:new()
	p:init()
	return p
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 16:08:09
-- @desc 奖励列表

local posTable = {
	[1] = {
		x = 202,
		y =1315
	},
	[2] = {
		x = 540,
		y =1315
	},
	[3] = {
		x = 878,
		y =1315
	},
	[4] = {
		x = 202,
		y =1150
	},
	[5] = {
		x = 540,
		y =1150
	},
	[6] = {
		x = 878,
		y =1150
	},
	[7] = {
		x = 202,
		y =985
	},
	[8] = {
		x = 540,
		y =985
	},
	[9] = {
		x = 878,
		y =985
	},
	[10] = {
		x = 202,
		y =820
	},
	[11] = {
		x = 540,
		y =820
	},
	[12] = {
		x = 878,
		y =820
	},
	[13] = {
		x = 202,
		y =655
	},
	[14] = {
		x = 540,
		y =655
	},
	[15] = {
		x = 878,
		y =655
	},
}
local numTable = {
	[1] = 0,
	[2] = 1500,
	[3] = 1000,
	[4] = 500,
	[5] = 200,
	[6] = 100,
	[7] = 50
}
local countTable ={
	[1] = {
		maxlv = 5,
		minlv = 1,
		count1 = 2,
		count2 = 1,
		count3 = 1,
		count4 = 2,
		count5 = 3,
		count6 = 3,
		count7 = 3,
		needScore = 3000,
	},
	[2] = {
		maxlv = 10,
		minlv = 6,
		count1 = 2,
		count2 = 1,
		count3 = 1,
		count4 = 2,
		count5 = 3,
		count6 = 3,
		count7 = 3,
		needScore = 3300,
	},
	[3] = {
		maxlv = 15,
		minlv = 11,
		count1 = 3,
		count2 = 1,
		count3 = 1,
		count4 = 2,
		count5 = 3,
		count6 = 2,
		count7 = 3,
		needScore = 3500,
	},
	[4] = {
		maxlv = 20,
		minlv = 16,
		count1 = 3,
		count2 = 1,
		count3 = 1,
		count4 = 2,
		count5 = 3,
		count6 = 3,
		count7 = 2,
		needScore = 3500,
	},
	[5] = {
		maxlv = 25,
		minlv = 21,
		count1 = 3,
		count2 = 1,
		count3 = 1,
		count4 = 3,
		count5 = 3,
		count6 = 2,
		count7 = 2,
		needScore = 3600,
	},
	[6] = {
		maxlv = 30,
		minlv = 26,
		count1 = 4,
		count2 = 1,
		count3 = 1,
		count4 = 3,
		count5 = 3,
		count6 = 2,
		count7 = 1,
		needScore = 3600,
	},
	[7] = {
		maxlv = 36,
		minlv = 30,
		count1 = 4,
		count2 = 1,
		count3 = 1,
		count4 = 3,
		count5 = 4,
		count6 = 1,
		count7 = 1,
		needScore = 3800,
	},
}
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:03:50
-- @desc 首充页面测试方法
function MeridianDiseaseLayer:test(lv,str,backFunc,succeddFunc,defeatFunc,takePillFunc)
	local layer = self:getInstance()
	layer:show()
	layer.isMap = false
	self.Button_back:setTouchEnabled(true)
	layer:initUI(lv,str,backFunc,succeddFunc,defeatFunc,takePillFunc)
end

function MeridianDiseaseLayer:init()
	local UI = require("Layer/MeridianUI/JingXiuUI.lua").create()['root']
	UI:addTo(self)
	self._rowTbale = {}
	self._turnTab = {}
	Helper:convertUIByParent(self)
end

-- 副本结果调用 add by ZhangShengTang 2017/06/14 18:26:06
function MeridianDiseaseLayer:showLayer(succeddFunc, defeatFunc)
	self:show()
	-- 副本结果调用
	self.isMap = true
	self:initUI(1, "", defeatFunc, succeddFunc, defeatFunc, function()end)
end

function MeridianDiseaseLayer:buttonClick(backFunc)
	self.Button_back:releaseFunc(function()
		self.Panel_defeat:setVisible(false)
		self.Panel_back:setVisible(true)
		backFunc()
		local scheduler =  cc.Director:getInstance():getScheduler()
		if self._myupdate then
			print("_________________________________________________________________")
			scheduler:unscheduleScriptEntry(self._myupdate)
		end
		PopupLayerController:hideLayer("MeridianDiseaseLayer", function(layer)
			self:hide()
		end, 0)
	end)
end
function MeridianDiseaseLayer:initUI(lv,str,backFunc,succeddFunc,defeatFunc,takePillFunc)
	for k,v in pairs(self._rowTbale) do
		v.panel:removeFromParent()
	end
	local hongImage = "Image/UI/TeacherUI/hong.png"
	local huangImage = "Image/UI/TeacherUI/huang.png"
	local reTable = self:getRandomTable(lv)
	for k,v in pairs(posTable) do
		local row  = self:clonePanle(self.Panel_back.Panel_button)
		if row ~= nil then
			row:setPosition(v.x,v.y)
			if reTable[k] == 0 then
				row.Text_num:setString("暗疾")
				--暗疾背景图片
				row.Image_1:loadTexture(hongImage,0)
			else
				row.Text_num:setString(tostring(reTable[k]))
				row.Image_1:loadTexture(huangImage,0)
				--非暗疾的背景图片
			end

			local tab = {}
			tab.panel = row
			tab.turn = false
			self._rowTbale[k] = tab
			row:setTouchEnabled(true)
		end
	end
	self.Panel_back.Text_2:setString("0/"..reTable["needScore"])
	self:initTextValue()
	local scheduler =  cc.Director:getInstance():getScheduler()
	self:buttonClick(function()
		if scheduler ~= nil then
			scheduler:unscheduleScriptEntry(self._myupdate)
		end
		backFunc()
	end)
	local function update()
		local tab = {"yi.png","er.png","san.png"}
		self._count =self._count -1
		if self._count == 0 then
			if scheduler ~= nil then
				scheduler:unscheduleScriptEntry(self._myupdate)
			end
			for k,v in pairs(self._rowTbale) do
			    self:createAction(v.panel,nil,huangImage)
				self.Panel_back.Text_num:setVisible(false)
				v.panel:releaseFunc(function()
					if self._num ~= 0 then
						if reTable[k] == 0 then
							self:createAction(v.panel,"暗疾",hongImage)
							v.turn = true
							self._num = self._num -1
							self.Panel_back.Text_4:setString(tostring(self._num).."/5")
							--PopText("失败!")
							self._num = 0

							local action = nil
							if self.isMap == true then
								action = cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
									PopText("治疗失败！")
								end),cc.DelayTime:create(2.0),cc.CallFunc:create(
							    function()
							    	defeatFunc()
							        PopupLayerController:hideLayer("MeridianDiseaseLayer", function(layer)
										self:hide()
									end)
							    end))
							else
								action = cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
									PopText("治疗失败！")
								end),cc.DelayTime:create(2.0),cc.CallFunc:create(
							    function()
							        self:gameDefeat(lv,str,backFunc,succeddFunc,defeatFunc,takePillFunc)
							        --self:hide()
							    end))
							end


						    self:runAction(action)
						else
							self:createAction(v.panel,tostring(reTable[k]),huangImage)
							v.turn = true
							self._score = self._score + reTable[k]
							self.Panel_back.Text_2:setString(tostring(self._score).."/"..reTable["needScore"])
							self._num = self._num -1
							if self._num == 0 and self._score>reTable["needScore"]-1 then

								-- 统计数据 治疗暗疾成功
								if self.isMap ~= true then
									local Record = require("app.models.Record.Record")
									Record:addRecordCount("jingmai", "event", "disease")
								end
								self.Button_back:setTouchEnabled(false)
								local action = cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
									PopText("治疗成功！")
							end),cc.DelayTime:create(2.0),cc.CallFunc:create(
						   		function()
						       		succeddFunc(self._score-reTable["needScore"])
						       		PopupLayerController:hideLayer("MeridianDiseaseLayer", function(layer)
						       			self.Button_back:setTouchEnabled(true)
										self:hide()
									end, 0)
									-- self:delayFunc(0, function()
									-- 	self:destroyInstance()
									-- end)
						   		 end))
						    self:runAction(action)
							elseif self._num == 0 then
								local action = nil
								if self.isMap == true then
									action = cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
									PopText("治疗失败！")end),
									cc.DelayTime:create(2.0),
									cc.CallFunc:create(function()
										defeatFunc()
							        	PopupLayerController:hideLayer("MeridianDiseaseLayer", function(layer)
											self:hide()
										end)
						   			end))
						   		else
						   			action = cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
									PopText("治疗失败！")end),
									cc.DelayTime:create(2.0),
									cc.CallFunc:create(function()
						    			self:gameDefeat(lv,str,backFunc,succeddFunc,defeatFunc,takePillFunc)
						   			end))
						   		end

						    	self:runAction(action)
							end
							self.Panel_back.Text_4:setString(tostring(self._num).."/5")
						end
						v.panel:setTouchEnabled(false)
					end

				end)
			end
			for i=1,4 do
				self.Panel_back["Text_"..tostring(i)]:setVisible(true)
			end
		else
			self.Panel_back.Text_num:loadTexture("Image/UI/TeacherUI/"..tab[self._count],0)
		end
	end
	self._myupdate = scheduler:scheduleScriptFunc(update, 1.0, false)
	update()
end
function MeridianDiseaseLayer:gameDefeat(lv,str,backFunc,succeddFunc,defeatFunc,takePillFunc)
	self.Panel_defeat:setVisible(true)
	self.Panel_back:setVisible(false)
	self:createRichText(str)
	self.Panel_defeat.Text_injection:setString(str)
	self.Panel_defeat.Button_try:releaseFunc(function()
		self.Panel_defeat:setVisible(false)
		self.Panel_back:setVisible(true)
		self:initUI(lv,str,backFunc,succeddFunc,defeatFunc,takePillFunc)

	end)
	self.Panel_defeat.Button_chiyao:releaseFunc(function()
		local role = User:getRole()
		if role:getItem("jingmai104") ~= nil then
			self.Panel_defeat:setVisible(false)
			self.Panel_back:setVisible(true)
			takePillFunc()--先执行服用春元丹效果函数，后扣除丹药数量
			PopupLayerController:hideLayer("MeridianDiseaseLayer", function(layer)
				self:hide()
			end)
			role:addItemCount("jingmai104",-1)

			-- 统计数据 使用春元丹
			local Record = require("app.models.Record.Record")
			Record:addRecordCount("jingmai", "useItem", "jingmai104")
		else
			PopText("春元丹数量不足")
		end
		-- if role:addItemCount("jingmai104", -1) then
		-- 	self.Panel_defeat:setVisible(false)
		-- 	self.Panel_back:setVisible(true)
		-- 	self:hide()
		-- 	takePillFunc()
		-- else
		-- 	PopText("春元丹数量不足")
		-- end
	end)
	self:buttonClick(defeatFunc)
end
function MeridianDiseaseLayer:createRichText(str1)
	local str = "看来积累在HIM"..str1.."NOR的暗疾已经有些时日了，一时间你竟然无法将其消除！你寻思着要不要再试试......"
	self.Panel_defeat.Text_dsc:setVisible(false)
	local x, y = self.Panel_defeat.Text_dsc:getPosition()
	local size = self.Panel_defeat.Text_dsc:getContentSize()
	size.height = size.height +100
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_defeat.Text_dsc:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_defeat.Text_dsc:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setTouchEnabled(false)
   	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_Print:getRichText():getNewContentSizeHeight()
	if textHeight >= 4000 then
		-- self:createRichText()
		-- add by XiaoZhiWei 2018/07/04 08:42:34 逻辑错误,修改为清空文本即可
		self.RichText_Print:getRichText():removeAllElement()
	end
	self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
end
function MeridianDiseaseLayer:turnPanel(reTable)
	for i,t in pairs(self._rowTbale) do
		if t.turn == false then
			if reTable[i] == 0 then
				self:createAction(t.panel,"暗疾",hongImage)
			else
				self:createAction(t.panel,tostring(reTable[i]),huangImage)
			end
			t.turn = true
		end
	end
end
function MeridianDiseaseLayer:createAction(node,str1,iamge)
	local scale1 = cc.ScaleTo:create(0.25, 0 , 1.0 )
	local scale2 = cc.ScaleTo:create(0.25, 1 , 1.0 )
    local action = cc.Sequence:create(scale1,cc.CallFunc:create(
    function()
    	if str1 == nil then
        	node.Image_wenhao:setVisible(true)
        	node.Text_num:setVisible(false)
        else
        	--node.Text_num:setString(str1)
        	node.Image_wenhao:setVisible(false)
        	node.Text_num:setVisible(true)
        end
        node.Image_1:loadTexture(iamge,0)
    end),scale2)
    node:runAction(action)
end

function MeridianDiseaseLayer:getRandomTable(jmLv)
	if jmLv>36 or jmLv < 1 then
		return
	end
	local tab = {}
	local reTab = {}
	for k,v in pairs(countTable) do
		if (v.maxlv - jmLv)>-1 and (v.minlv -jmLv)<1 then
			tab = clone(v)
		end
	end
	reTab["needScore"] = tab.needScore
	local num = 1
	for i=1,7 do
		if tab["count"..tostring(i)]>0 then
			for j=1,tab["count"..tostring(i)] do
				reTab[num] = numTable[i]
				num = num+1
			end
		end
	end
	local backTable = {}
	for i=1,15 do
		local num = math.random(1,16-i)
		backTable[i] = reTab[num]
		table.remove(reTab,num)
	end
	backTable["needScore"] = reTab.needScore
	Helper:print_lua_table(backTable)
	return backTable
end
function MeridianDiseaseLayer:initTextValue()
	self._count = 4
	self._myupdate = nil
	self._score = 0
	self._num = 5
	self.Panel_back.Text_num:setVisible(true)
	for i=1,4 do
		self.Panel_back["Text_"..tostring(i)]:setVisible(false)
	end
	self.Panel_back.Text_4:setString("5/5")
end
function MeridianDiseaseLayer:clonePanle(panle)
	if panle == nil then
		return
	end
	local row = panle:clone()
	row:addTo(self.Panel_back)
	row:setAnchorPoint(cc.p(0.5, 0.5))
	Helper:convertUI(row)
	row.Text_num:setFontName("Font/default.ttf")
	row.Text_num:setFontSize(48)
	row.Text_num:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	return row
end
Helper:classDefNodeGetInstance(MeridianDiseaseLayer)
return MeridianDiseaseLayer
00000000000000
local XingZhenLayer = class("XingZhenLayer", cc.Layer)

local XingZhen = require("app.models.XingZhenEffects.XingZhenEffects")

function XingZhenLayer:create()
	local p = XingZhenLayer:new()
	p:init()
	return p
end

--几种行针方法
-- local xingZhenList = {}

local needDeblockingList = {}

function XingZhenLayer:init()
	self._UI = require("Layer/ZouXueShiSiJingUI/XingZhenUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)	

end

function XingZhenLayer:showLayer(skill,afterCallback)
	self.skill = skill
	self.afterCallback = afterCallback

	-- xingZhenList = {}
	self:logicButton()

	self:show()
end

function XingZhenLayer:logicButton()
    local npcDatas = require("script.others.zouxuejing")
    local npcZhenFa = npcDatas.zhenfa
    local npcEffect = npcDatas.effect
    local npcXuewei= npcDatas.xuewei

	XingZhen:insertShiZhenResult()
	
	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
	self.Panel_back_1:setVisible(false)

	self:buttonListView(Helper:getDef(User:getRole():getInheritFlag("行针针法Skills"), {}) ,npcXuewei,npcZhenFa, npcEffect)
end

--符合行针的就在列表显示出来
function XingZhenLayer:buttonListView(rewardList,npcXuewei,npcZhenFa, npcEffect)
	self.ListView_1:removeAllItems()
	-- table.sort(rewardList,function (a,b)
	-- 	local num1 = string.gsub(a,"zhenfa","")
	-- 	local num2 = string.gsub(b,"zhenfa","")
	-- 	return tonumber(num1) < tonumber(num2)
	-- end)
	-- Helper:print_lua_table(npcZhenFa)
	--读取表里面数据数量
	local nums = table.nums(npcZhenFa)
	local tmpRewardList = {}
	for i=1,nums do
		tmpRewardList[i] = "？"
	end
	for k,v in pairs(rewardList) do
		local num = string.gsub(v,"zhenfa","")
		tmpRewardList[tonumber(num)] = v
	end

	rewardList = tmpRewardList
	for i=1,nums do --19是针法的个数，后期可以考虑读表读表
		local zhenfaId = rewardList[i]
		local panel =self:clonePanel(self.Panel_item)
		panel.Text_nameImage:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)

		if zhenfaId ~= "？" then
			panel.Text_image:setVisible(true)
			panel.Text_nameImage:setString(npcZhenFa[zhenfaId].name)
		else
			panel.Text_image:setVisible(false)
			panel.Text_nameImage:setEnabled(false)
			panel.Text_nameImage:setString("？")
		end
		-- local panel =self:clonePanel(self.Panel_item)
		-- if npcZhenFa[rewardList[i]] and (#rewardList >= 3 or npcZhenFa[rewardList[i]].unlocklevel >= 100) then
		-- 	panel.Text_image:setVisible(true)
		-- 	panel.Text_nameImage:setString(npcZhenFa[rewardList[i]].name)
		-- else
		-- 	panel.Text_image:setVisible(false)
		-- 	panel.Text_nameImage:setEnabled(false)
		-- 	panel.Text_nameImage:setString("？")
		-- end
		
		self.ListView_1:pushBackCustomItem(panel)

		--点击button
		panel.Text_nameImage:releaseFunc(function()
			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			local dialog = DialogALayer:getInstance()
			dialog:show("确定要使用"..npcZhenFa[rewardList[i]].name.."行针吗？")
			dialog:setRichText("确定要使用"..npcZhenFa[rewardList[i]].name.."行针吗？")
			dialog:setButton1("确定", function()      
				-- self:clickButton(rewardList[i],npcXuewei,npcZhenFa, npcEffect)
				XingZhen:setXingZhen("行针走穴结束时间", npcZhenFa[rewardList[i]].showtime + GetTime())
				self:jumpReward(rewardList[i],npcXuewei,npcZhenFa, npcEffect)
			end)
			dialog:setButton2("取消", function()
				dialog:hide()
			end)
		end)
		--点击感叹号
		panel.Text_image:releaseFunc(function()
			-- print("-----------------------------------------")
			self.Panel_back_1.Text_text:setString(npcZhenFa[rewardList[i]].name)
			self:initRichTextPreview()
			local textColor = cc.c3b(208,208,208)
			self.RichText_Print:pushBackText(npcZhenFa[rewardList[i]].text, textColor, 255, Resource:getFontPath("default"), 58)


			--穴位的名称 string.split(npcZhenFa[zhenfa].xuewei, ";")
			local xueweis = ""
			local xueweiData = string.split(npcZhenFa[rewardList[i]].xuewei,";")
			for k,v in pairs(xueweiData) do
				local xueWeiName = npcXuewei[v].name
				xueweis = xueWeiName..","..xueweis
			end
			xueweis = string.sub(xueweis, 1, string.len(xueweis) - 1)


			self.Panel_back_1.Text_xuewei_name:setString("核心穴位：\n"..xueweis)
			self.Panel_back_1:setVisible(true)
			self.Panel_back_1:releaseFunc(function()
				self.Panel_back_1:setVisible(false)
			end)	
		end)		
	end
	--点击试炼的按钮
	self.Button_Practice:releaseFunc(function()
		local role = User:getRole()
		local skillLv = role:getSkillLv("zouxueshisijing")--走穴十四经的等级
		if skillLv < 500 then
			PopText("走穴十四经等级不足，暂无法试针!")
		else
			self:tryButton(rewardList, npcXuewei,npcZhenFa, npcEffect)
		end
	end)
end

--试炼
function XingZhenLayer:tryButton(rewardList, npcXuewei,npcZhenFa, npcEffect)
	PopupLayerController:showLayer("XingZhenTryLayer",function(layer)
	    layer:showLayer(npcXuewei,npcZhenFa, npcEffect,rewardList, function ()
	    	self:updateList(rewardList, npcZhenFa)
	    end)
	end)
	self:hide()
end

function XingZhenLayer:updateList(rewardList, npcZhenFa)
	self.ListView_1:removeAllItems()
	self:logicButton()
	local role = User:getRole()
	local xingzhenSkill = Helper:getDef(role:getInheritFlag("行针针法Skills"),{})

	for k,v in pairs(npcZhenFa) do
		local id = v.id
		table.insert(rewardList, id)
	end	
	self:buttonListView(rewardList,npcXuewei,npcZhenFa, npcEffect)
end

--跳转到结算界面
function XingZhenLayer:jumpReward(id, npcXuewei,npcZhenFa, npcEffect)
	local role = User:getRole()
	local zhenfaData = npcZhenFa[id]
	XingZhen:calcEffect(id)

	role:updateRoleBuff()
	--增加经验
	local skillLv = role:getSkillLv("zouxueshisijing")
	local exp = (role:getSkillExp("zouxueshisijing") * (0.09 + role:getFinalAttr("currInt")/8000) + 10000) *(zhenfaData.coldtime/64800)
	if skillLv >= 1 and skillLv < 500 then
		exp = (role:getSkillExp("zouxueshisijing") * (0.05 + role:getFinalAttr("currInt")/8000) + 10000) *(zhenfaData.coldtime/64800)
	elseif skillLv >= 500 and skillLv < 800 then
		exp = role:getSkillExp("zouxueshisijing") * (0.01 + role:getFinalAttr("currInt")/9000)  *(zhenfaData.coldtime/64800)
	else
		exp = role:getSkillExp("zouxueshisijing") * (0.006 + role:getFinalAttr("currInt")/12000)  * (zhenfaData.coldtime/64800)
	end
	
	role:addSkillExp("zouxueshisijing", exp)

	self:hide()
	if self.afterCallback then
		self.afterCallback(self.skill)
	end
	PopupLayerController:showLayer("XingZhenRewardLayer",function(layer)
	    layer:showLayer(zhenfaData,0,function()
			--提交行针效果
			XingZhen:submitXingZhenEffects(role)

			PopText(zhenfaData.name.."行针成功!")
		end)
	end)
end

function XingZhenLayer:clonePanel(panel)
	if panel == nil then
		return
	end
	local row = panel:clone() 
	Helper:convertUI(row)
	return row
end

function XingZhenLayer:initRichTextPreview()
	local x, y = self.Panel_back_1.Text_dcs:getPosition()
	local size = self.Panel_back_1.Text_dcs:getContentSize()
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_back_1.Text_dcs:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_back_1.Text_dcs:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
   	self.RichText_Print:setTouchEnabled(false)
end

Helper:classDefNodeGetInstance(XingZhenLayer)

return XingZhenLayer0
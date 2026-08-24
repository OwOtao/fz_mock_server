local ShiZhenTextLayer = class("ShiZhenTextLayer", cc.Layer)
local XingZhen = require("app.models.XingZhenEffects.XingZhenEffects")

function ShiZhenTextLayer:create()
	local p = ShiZhenTextLayer:new()
	p:init()
	return p
end

function ShiZhenTextLayer:init()
	self._UI = require("Layer/ZouXueShiSiJingUI/XingZhenDialogUILayer.lua").create()['root']
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
end

function ShiZhenTextLayer:showLayer(num, zhenfa, func)
	local role = User:getRole()
	local npcDatas = require("script.others.zouxuejing")
	local npcXuewei = npcDatas.xuewei
	local npcZhenFa = npcDatas.zhenfa
	local npcEffect = npcDatas.effect
	--num1通针的针法，是新的针法，没有重复
	self.Image_xin:setVisible(true)
	--针法对应的穴位
	local xueweistring = ""
	local xueweis =  string.split(npcZhenFa[zhenfa].xuewei, ";")
	for k,v in pairs(xueweis) do
		local xueWeiName = npcDatas.xuewei[v].name
		xueweistring = xueWeiName .. "," .. xueweistring
	end
	self.Text_name:setString(npcZhenFa[zhenfa].name)
	self:initRichTextPreview()
	local textColor = cc.c3b(208,208,208)
	self.RichText_Print:pushBackText(npcZhenFa[zhenfa].text, textColor, 255, Resource:getFontPath("default"), 58)
	-- self.Text_dcs:setString(npcZhenFa[zhenfa].text)
	--穴位名称
	xueweistring = string.sub(xueweistring, 1, string.len(xueweistring) - 1)
	self.Text_xue_name:setString("核心穴位：\n"..xueweistring)

	self.Panel_back:releaseFunc(function()
		self:hide()
		if func then
			func(2)
		end
		--新的通针的针法加入到列表
		local xingzhenSkills = Helper:getDef(role:getInheritFlag("行针针法Skills"),{})
		--新的针法的id，正在走穴的时候会用到
		local xingzhenId = XingZhen:getXingZhen("针法数据")
		local found = false
		for k,v in pairs(xingzhenSkills) do
			if v == zhenfa then
				found = true
				break
			end
		end

		if not found then
			table.insert(xingzhenSkills,zhenfa)
			-- table.insert(xingzhenId,zhenfa)
			role:setInheritFlag("行针针法Skills",xingzhenSkills)
			XingZhen:setXingZhen("针法数据",xingzhenId)
		end
		-- self:jumpReward(zhenfa,npcXuewei,npcZhenFa, npcEffect)
		self:jumpReward(zhenfa,npcZhenFa[zhenfa])
		XingZhen:setXingZhen("行针走穴结束时间",npcZhenFa[zhenfa].showtime + GetTime())
		
	end)
	self:show()
end

function ShiZhenTextLayer:initRichTextPreview()
	local x, y = self.Text_dcs:getPosition()
	local size = self.Text_dcs:getContentSize()
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Text_dcs:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Text_dcs:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
   	self.RichText_Print:setTouchEnabled(false)
end

--跳转到结算界面
function ShiZhenTextLayer:jumpReward(id,npcZhenFa)
	local role = User:getRole()
	XingZhen:calcEffect(id)

	--增加经验
	local exp = role:getSkillExp("zouxueshisijing") * (0.09 + role:getFinalAttr("currInt")/8000)
	role:addSkillExp("zouxueshisijing", exp)

	self:hide()
	if self.afterCallback then
		self.afterCallback(self.skill)
	end
	PopupLayerController:showLayer("XingZhenRewardLayer",function(layer)
	    layer:showLayer(npcZhenFa,0,function()
			--提交行针效果
			XingZhen:submitXingZhenEffects(role)
			XingZhen:setXingZhen("行针走穴CD时间",  GetTime() + npcZhenFa.coldtime)
			PopText(npcZhenFa.name.."行针成功!")
		end)
	end)
end

Helper:classDefNodeGetInstance(ShiZhenTextLayer)

return ShiZhenTextLayer000000000
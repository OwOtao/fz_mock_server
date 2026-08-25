--
-- Author: TanQinJian
-- Date: 2019-07-01 17:32:01
--


local LimitDiscountLayer = class("LimitDiscountLayer", cc.Layer)

function LimitDiscountLayer:create()
	local p = LimitDiscountLayer:new()
	p:init()
	return p
end

function LimitDiscountLayer:init()
	local UI = require("Layer/ActionUI/ActionDescUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUI(self)
	self.closeBtn=nil
	self.goInvestBtn=nil
	self:setButton()
	self:setPanelBack()
end

function LimitDiscountLayer:showLayer(actionId)
	HttpManagerEx:getActionState(actionId,nil,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
            	if type(data) == "table" and data.is_open == 1 and data.status == 1 then

            		self:setVisible(true)
					self.Text_title:setString(data.name)
					self:setDesc(data)
            	end
            else
                --PopText(errmsg)
            end
    	end
	end, IS_SHOW_WAITING)
end

function LimitDiscountLayer:hide()
	self:setVisible(false)
end

function LimitDiscountLayer:setImageKuang()
	self.Image_kuang:releaseFunc(function()
			if PRINT_MODE == 1 then
				print("进入活动页面")
			end
		end)
end

function LimitDiscountLayer:setButton()
	self.Button_close:setVisible(false)
	if not self.goInvestBtn then 
		self.goInvestBtn=self.Button_close:clone()
		self.goInvestBtn:addTo(self)
		Helper:convertUIByParent(self.goInvestBtn)
		self.goInvestBtn.Text_buttonName:setString("去充值")
		self.goInvestBtn.Text_buttonName:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
		self.goInvestBtn.Text_buttonName:setPositionX(self.goInvestBtn.Text_buttonName:getPositionX()-20)
		self.goInvestBtn.Text_buttonName:setTextHorizontalAlignment(1)
		self.goInvestBtn.Text_buttonName:setTextVerticalAlignment(1)
		self.goInvestBtn:setPositionX(145)
		self.goInvestBtn:setVisible(true)
		self.goInvestBtn:releaseFunc(function()
				MainControllLayer:pushLayer("StoreLayer")
				local StoreLayer=MainControllLayer:getLayer("StoreLayer")
				StoreLayer:showWithAction(function()
					self:show()
					self:maxZ()
				end)
				self:hide()
			end)
	end
	if not self.closeBtn then 
		self.closeBtn=self.Button_close:clone()
		self.closeBtn:addTo(self)
		Helper:convertUIByParent(self.closeBtn)
		self.closeBtn.Text_buttonName:setTextHorizontalAlignment(1)
		self.closeBtn.Text_buttonName:setTextVerticalAlignment(1)
		self.closeBtn.Text_buttonName:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
		self.closeBtn.Text_buttonName:setString("关闭")
		self.closeBtn:setPositionX(615)
		self.closeBtn:setVisible(true)
		self.closeBtn:releaseFunc(function()
				self:hide()
				self:destroyInstance()
			end)
	end
	
end

function LimitDiscountLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
			self:hide()
			self:destroyInstance()
		end)
end

function LimitDiscountLayer:setDesc(action)
	if not MapIsEmpty(action.detail_desc) and action.detail_time ~= nil then
		local desc = "活动时间:\n" .. action.detail_time .. "\n活动内容:\n"

		local index = 1
		for k,v in pairs(action.detail_desc) do
			desc = desc .. v .. "\n"
			index = index + 1
		end
		-- self.Text_desc:setString(desc)
		local textColor = cc.c3b(255,255,255)
		self:initRichTextPreview("dsc",self.Text_desc,self,desc,textColor)
	else
		-- self.Text_desc:setString("")
		local textColor = cc.c3b(255,255,255)
		self:initRichTextPreview("dsc",self.Text_desc,self,"",textColor)
	end
end
function LimitDiscountLayer:initRichTextPreview(name,DscArea,parent,str,textColor,verticalSpace)
	local size = self.Text_desc:getContentSize()
	Helper:print_lua_table(size)
		local x, y = DscArea:getPosition()
	local size = DscArea:getContentSize()
	DscArea:setVisible(false)
	if parent[name] then
		parent[name]:removeFromParent()
		parent[name] = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	DscArea:getParent():addChild(richTextScroll)
   	local point = cc.p(DscArea:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	parent[name] = richTextScroll
   	parent[name]:setBounceEnabled(true)
   	parent[name]:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 48)
   	parent[name]:pushBackNewLine()
	parent[name]:pushBackNewLine(verticalSpace)
	parent[name]:setCascadeOpacity(0)
	parent[name]:setTouchEnabled(true)
	self:delayFunc(0.3,function ()
		parent[name]:jumpToTop()
		parent[name]:setCascadeOpacity(255)
	end)
end
Helper:classDefNodeGetInstance(LimitDiscountLayer)

return LimitDiscountLayer
0
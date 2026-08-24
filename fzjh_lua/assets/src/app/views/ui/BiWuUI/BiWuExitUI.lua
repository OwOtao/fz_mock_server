local Resource = require("app.Resource")
local BiWu = require("app.models.BiWu.BiWu")
local BiWuExitUI = class("BiWuExitUI", LayerEx)

function BiWuExitUI:create()
	local p = BiWuExitUI:new()
	p:init()
	return p
end


function BiWuExitUI:init()
	self._UI = require("Layer.BiWuUI.BiWuExitUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setVisible(true)
end



--设置气血
function BiWuExitUI:setQiXueNeiLiPersent(QiPercent, CurrQiPercent, NlPercent)
	if not QiPercent or not CurrQiPercent or not NlPercent then
		return
	end
	
	local role = clone( User:getRole() )
	role._roleBuff = nil
	 
	-- 去掉经脉加成后 最大值小于当前最大气血
	if role:getCurrQiMax() <  role:getAttr("qi")  then
		role:setAttr("qi",role:getCurrQiMax())
	end

	self.Panel_back.Panel_Role_Attr_Back.Panel_QiXue.Image_QiXue.LoadingBar_2:setPercent(CurrQiPercent)
	self.Panel_back.Panel_Role_Attr_Back.Panel_QiXue.Image_QiXue.LoadingBar_3:setPercent(QiPercent)
	self.Panel_back.Panel_Role_Attr_Back.Panel_NeiLi.Image_NeiLi.LoadingBar_3:setPercent(NlPercent)

	self.Panel_back.Panel_Role_Attr_Back.Panel_QiXue.Image_QiXue.Text_num:setString(math.floor(role:getAttr("qi")).."/"..math.floor(role:getCurrQiMax()))
	self.Panel_back.Panel_Role_Attr_Back.Panel_NeiLi.Image_NeiLi.Text_num:setString(math.floor(role:getAttr("neili")).."/"..math.floor(role:getFinalAttr("neiliMax")))
end


----观看人数 或者 本场人气
function BiWuExitUI:setPeopleNumber(num,func)
	if not num then
		return
	end
	-- self.Panel_back.Panel_Role_Attr_Back.Text_People:setString([[【本场人气】]])
	self.Panel_back.Panel_Role_Attr_Back.Text_People.Text_People_Number:setString(tostring(num))
	if func then
		fucn()
	end
end

----今日最高人气
function BiWuExitUI:setPeopleMaxNumber(num,func)
	if not num then
		return
	end
	self.Panel_back.Panel_Role_Attr_Back.Text_People_Max.Text_People_Max_Number:setString(tostring(num))
	if func then
		fucn()
	end
end

function BiWuExitUI:runActionRoleAttr()
	self:showTouchSwallowLayer()
	local point = cc.p(self.Panel_back.Panel_Role_Attr_Back:getPosition())
	local pointSize = self.Panel_back.Panel_Role_Attr_Back:getContentSize()
	local viewsize = cc.Director:getInstance():getWinSize()
	local titleSize = self.Panel_back.Panel_Role_Attr_Back.Image_title:getContentSize()
	if point.y <= viewsize.height then
		self.Panel_back.Panel_Role_Attr_Back:setPosition(point.x,viewsize.height + pointSize.height)
	end

	self.Panel_back.Panel_Role_Attr_Back:runAction(cc.Sequence:create(YXEaseAction:create(cc.MoveTo:create(0.3, cc.p(point.x, viewsize.height - titleSize.height)), Sine_EaseOut), 
		cc.CallFunc:create(
			function()
				self:hideTouchSwallowLayer()
			end)) )
end

----设置头像图片
-- function BiWuExitUI:setImageHead()
-- 	local role = User:getRole()
-- 	local sex = role:getAttr("sex")
-- 	local looks = role:getAttr("looks")
-- 	local isYueKa = role:yueKaIsValid()
-- 	---拥有月卡
-- 	if isYueKa then
-- 		self.Panel_back.Image_di.Image_frame:loadTexture(Resource:getImgPath("headFrame02"))
-- 	else
-- 		self.Panel_back.Image_di.Image_frame:loadTexture(Resource:getImgPath("headFrame01"))
-- 	end


----设置称号。名字
function BiWuExitUI:setChengHaoName(str1,str2,func)
	if not str1 or not str2 then
		return
	end
	self.Panel_back.Panel_Role_Attr_Back.Button_title.Text_nameTitle:setString(str1)
	self.Panel_back.Panel_Role_Attr_Back.Button_title.Text_name:setString(str2)
	if func then
		fucn()
	end
end
----设置金钱
function BiWuExitUI:setMoney(str2,func)
	if not str2 then
		return
	end

	self.Panel_back.Panel_Role_Attr_Back.Text_Gold.Text_Gold_Number:setString(tostring(math.ceil(str2)))
	if func then
		fucn()
	end
end

----设置经验
function BiWuExitUI:setExp(str2,func)
	if not str2 then
		return
	end
	self.Panel_back.Panel_Role_Attr_Back.Text_Exp.Text_Exp_Number:setString(tostring(math.ceil(str2)))
	if func then
		fucn()
	end
end


---激战
function BiWuExitUI:setButtonBattle(str,func)
	self.Button_Battle:setTouchInterval(2)
	if str ~= nil then
		self.Button_Battle.Text_buttonName:setString(str)
	end
	self.Button_Battle:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
	end)
end



---挑衅
function BiWuExitUI:setButtonProvoke(str,func)
	-- self.Button_Provoke:setTouchInterval(2)
	-- if str ~= nil then
	-- 	self.Button_Provoke.Text_buttonName:setString(str)
	-- end
	-- self.Button_Provoke:releaseFunc(function ()
	-- 	Audio:playEffect("xiaoAnNiu")
	-- 	if func then
	-- 		func()
	-- 	end
	-- end)
end
---告辞
function BiWuExitUI:setButtonByeBye(times,func)
	self.Button_ByeBye:setTouchInterval(2)
	if type(times) == "number" then
		self.Button_ByeBye:setString("剩余次数："..tostring(times))
	end
	self.Button_ByeBye:releaseFunc(function ()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
	end)
end





Helper:classDefNodeGetInstance(BiWuExitUI)

return BiWuExitUI00000000000000
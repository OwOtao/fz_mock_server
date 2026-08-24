local  ShenBingNameLayer = class("ShenBingNameLayer",cc.Layer)
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
function ShenBingNameLayer:create()
	local p = ShenBingNameLayer:new()
	p:init()
	return p
end

function ShenBingNameLayer:init()
	self._UI = require("Layer/ShenBing/ShenBingReNameUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setVisible(false)

	self.Panel_DaZao.Button_Yes:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
end
local colorType = -- 字体颜色改变格式
{	
	[1]  = 
	{
		name = "RED",
		color =	cc.c3b(219,57,57)
	},
	[2] = 
	{
		name = "GRN",
		color =	cc.c3b(51,153,51)
	},
	[3] = 
	{
		name = "YEL",
		color =	cc.c3b(175,145,25)
	},
	[4] = 
	{
		name = "BLU",
		color =	cc.c3b(28,76,163)
	},
	[5] = 
	{
		name = "MAG",
		color =	cc.c3b(153,51,153)
	},
	[6] = 
	{
		name = "CYN",
		color =	cc.c3b(102,153,153)
	},

	[7] = 
	{
		name = "HIR",
		color =	cc.c3b(241,16,16)
	},
	[8] = 
	{
		name = "HIG",
		color =	cc.c3b(88,244,117)
	},
	[9] = 
	{
		name = "HIY",
		color =	cc.c3b(246,244,80)
	},
	[10] = 
	{
		name = "HIB",
		color =	cc.c3b(11,128,246)
	},
	[11] = 
	{
		name = "HIM",
		color =	cc.c3b(204,51,204)
	},
	[12] = 
	{
		name = "HIC",
		color =	cc.c3b(80,246,244)
	},
	[13] = 
	{
		name = "HIW",
		color =	cc.c3b(255,255,255)
	},
	[14] = 
	{
		name = "DWT",
		color = cc.c3b(208,208,208)
	},
	[15] = 
	{
		name = "PNK",
		color = cc.c3b(255, 128, 192),
	}

}

local function deleteNameColor(weapon)
	if weapon.name ~= nil then
		for k,v in pairs(colorType) do 
			weapon.name = string.gsub(weapon.name,v.name,"")
		end
	end
	weapon.name = string.gsub(weapon.name,"NOR","")
	return weapon
end

function ShenBingNameLayer:showLayer(flag,weapen,func)--flag == 1 起名，2改名
	flag = Helper:getDef(flag,1)
	assert(type(weapen) == "table")
	
	self:setLayerType(flag)
	self:setCurrWeapon(weapen)
	self:initWeaponColorId()
	self:setBackCallFunc(func)

	self:initUI()
	self:show()
end

function ShenBingNameLayer:setCurrWeapon(weapon)
	weapon = deleteNameColor(weapon)
	self._currWeapon = weapon
end

function ShenBingNameLayer:setBackCallFunc(func)
	self._backCallFunc = func
end

function ShenBingNameLayer:initUI()
	self:createEditBox()
	self:setEditBoxFontColor(self:getColorByComm(self._currWeapon.nameColor))

	if self._layerType == 1 then
		self:setWeapenName()
		self:setWeapenTypeText()
		self:setChangeDefaultShenBingBtnVisible(false)
	else
		self:setChangeDefaultShenBingBtnVisible(true)
		self:setWeapenReName()
		self:setButtonCancel()
		self:setWeaponName(self._currWeapon.name)
	end

	local lookDesc = ShenBingDesc:getWeaponFacade(self._currWeapon)
	local descList = ShenBingDesc:getWeaponWeardes(self._currWeapon)

	self:setWeapenLookDesc(lookDesc)
	self:setEquipDesc(descList.Weardes,self._currWeapon.name)
	self:setTakeOffDesc(descList.Takedes,self._currWeapon.name)
	self:setBackButton()
	self:setRandomNameButton()
	self:setWeapenColorFunc()
	self:initChangeDefaultShenBingBtnFunc()
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/15 14:58:13
-- @desc  找到颜色列表中与当前神兵颜色相同的配置
function ShenBingNameLayer:initWeaponColorId()
	print("-----------------------------------",self._currWeapon.nameColor)
	assert(type(self._currWeapon) == "table" and type(self._currWeapon.nameColor) == "string")
	for k,color in pairs(colorType) do 
		if color.name == self._currWeapon.nameColor then
			self.colorId = k
			return
		end
	end
	assert(nil)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/15 14:22:20
-- @desc 改名输入框初始显示神兵名称
function ShenBingNameLayer:setWeaponName(name)
	assert(type(name) == "string")
	self.editBox:setText(name)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 15:39:02
-- @desc 创建输入框
function ShenBingNameLayer:createEditBox()
	-- self.EditBoxArea:setTouchEnabled(true)
	local editBox
	local size = self.Panel_DaZao.EditBoxArea:getContentSize()
	if self.editBox == nil then
		editBox = ccui.EditBox:create(size, "请输入")
		self.editBox = editBox
		editBox:setFontName("Font/default.ttf")
		editBox:setFontSize(54)
		editBox:setPlaceholderFontSize(54)
		editBox:setPlaceholderFontName("Font/default.ttf")
		editBox:setVisible(true)
		-- 设置输入类型
		editBox:setInputMode(6)
		editBox:setReturnType(1)

		editBox:onEditHandler(
			function(event)
				local eventName = event.name
				local eventTarget = event.target

				if PRINT_MODE == 1 then
					print("eventName = " .. tostring(eventName))
					print("eventTarget = " .. tostring(eventTarget))
				end

				if eventName == "began" then
					self._isEditing = true
				elseif eventName == "changed" then
					self._editBoxString = editBox:getText()
					if PRINT_MODE == 1 then
						print("self._editBoxString = " .. tostring(self._editBoxString))
					end
				elseif eventName == "end" then
				elseif eventName == "return" then
					self._isEditing = false
				end
			end
		)

		self.Panel_DaZao.EditBoxArea:getParent():addChild(editBox)
		editBox:setPosition(self.Panel_DaZao.EditBoxArea:getPositionX(), self.Panel_DaZao.EditBoxArea:getPositionY())
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/15 14:04:07
-- @desc 取消按钮
function ShenBingNameLayer:setButtonCancel()
	self.Panel_DaZao.Button_Cancel:releaseFunc(function()
		self:hide()
	end)
end	
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 15:49:10
-- @desc 设置输入框文本颜色
function ShenBingNameLayer:setEditBoxFontColor(color)
	if self.editBox then
		self.editBox:setFontColor(color)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 15:58:56
-- @desc 随机名称按钮
function ShenBingNameLayer:setRandomNameButton()
	self.Panel_DaZao.Button_randomName:releaseFunc(function()
		if self.editBox ~= nil and self._isEditing ~= true then
			local num = math.random(1,5)
			local role = User:getRole()
	    	self.editBox:setText(self:getRandomName(self._currWeapon.type,num))
	    end
	end)
end



-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 16:07:45
-- @desc 拔剑描述
function ShenBingNameLayer:setEquipDesc(desc,name)
	assert(desc and name)



	desc = string.gsub(desc,"$N",User:getRole():getName())	

	desc = string.gsub(desc,"$w",name)	

	-- desc = string.gsub(desc,"$N",User:getRole():getName())				
	-- desc = string.gsub(desc,"$N",name)
	self.Panel_DaZao.Image_back_BaJian.Text_BaJian_desc:setString(desc)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 16:09:30
-- @desc 脱下描述

function ShenBingNameLayer:setTakeOffDesc(desc,name)
	assert(desc and name)
	desc = string.gsub(desc,"$N",User:getRole():getName())	
	desc = string.gsub(desc,"$w",name)
	self.Panel_DaZao.Image_back_HuiQiao.Text_HuiQiao_Desc:setString(desc)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 16:23:20
-- @desc 外观描述
function ShenBingNameLayer:setWeapenLookDesc(desc)
	desc = Helper:getDef(desc,"暂无描述")

	self.Panel_DaZao.Image_back_Appearance.Text_Appearance_Desc:setString(desc)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 16:04:29
-- @desc 随机名称
function ShenBingNameLayer:getRandomName(Type,num)
	if Type == "双持" or Type == "暗器" or Type == "乐器" then
		Type = ""
	end
	local A, B, C,name,canNot= {}, {}, {} ,{},{}
	A = {"天","地","玄","皇","宇","宙","洪","荒","月","辰","宿","岁","阳","云","雨","金","木","水","火","土","寒","玉","魔","巨","夜","光","珍","重","海","淡","羽","鱼","龙","师","帝","文","国","七","唐","民","罪","周","汤","朝","道","问","平","章","伏","凤","万","良","知","墨","靖","景","贤","圣","名","宝","空","君","庆","严","松","川","渊","定","诚","荣","政","棠","乐","易","怀","守","真","雁","州","武","古","银","琴","忠","越","义","宋","山","冷","霜","广","鸿","冰"} 
	B ={"杀","灭","电","光","明","七","灵","幻","环","清","常","风","阴","残","眉","峰","锋","池","钢","宫","泉","神","珠","洋","狼","虎","空","丝","河","牙","雷","曲","龙","意","叶","柳","纹","王","陈","华","罗","一","熊","月","凤","问","霜","寒","玄","岁","羽","文","圣","命","真","云","星","定","松","古","渊","川","皇","武","墨","虹","魂","殇"}
	C = {"八宝","亮银","夜明","八卦","紫金","青铜","白龙","白云","白虎","白鹤","七星","碧光","开山","金鼎","金顶","如意","盘龙","飞龙","柳叶","盘竹","熟铜","昆吾","青鸿","青萍","秋风","秋水","落叶","天罡","灵云","渗金","鎏金","乌金","银龙","阴阳","无极","无双","游龙","惊龙","紫烟","紫霜","紫霞","朽木","废铁","乌木","盘石","青竹","残岩","枯木","流金","梧桐","白银","黄金","钻石","黄龙","风云","断龙","灵枢","无魂","乌铁","红木","紫檀","青冥","幽冥","谷雨","春分","惊蛰","白露","四象","熟铁","镔铁","黄铜","生铁","铁木","青钢","梨木","松木","橡木","枫木","柏木","黑檀","纯铁","纯钢","白铜","纯铜","粗铜","粗铁","粗钢"}
	canNot = {"请名字","请输", "输入", "请输入", "请输入名字","光光","七七","空空","龙龙","月月","凤凤","问问","霜霜","寒寒","玄玄","岁岁","羽羽","问问","圣圣","真真","云云","定定","松松","古古","渊渊","川川","皇皇","武武","墨墨","金金","云云","明明","宝宝","雨雨"}

	if num ==1 then
		name = A[math.random(1,#A)]..B[math.random(1,#B)]..Type
	elseif num ==2 then
		name = C[math.random(1,#C)]..A[math.random(1,#A)]..Type
	elseif num ==3 then
		name = C[math.random(1,#C)]..B[math.random(1,#B)]..Type
	elseif num ==4 then
		name = C[math.random(1,#C)]..A[math.random(1,#A)]..B[math.random(1,#B)]..Type
	elseif num ==5 then
		name = C[math.random(1,#C)]..Type
	end

	for i=1,#canNot do
		if name == canNot[i]..Type then
			local numA = math.random(1,5)
			self:getRandomName(Type,numA)
			break
		else
			return name
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 15:45:40
-- @desc 将颜色字符串转换成c3b
function ShenBingNameLayer:getColorByComm(comm)
	-- assert(type(comm) == "table")
	for k,colorList in pairs(colorType) do 
		if colorList.name == comm then
			return colorList.color
		end
	end
	return cc.c3b(159,159,159)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 17:43:04
-- @desc 起名初始化页面
function ShenBingNameLayer:setWeapenName()
	self.Panel_DaZao.Text_Rename:setVisible(false)
	self.Panel_DaZao.Text_Weapon_type:setVisible(true)
	self.Panel_DaZao.Text_Weapon:setVisible(true)
	self.Panel_DaZao.Button_Cancel:setVisible(false)
	self.Panel_DaZao.Button_Yes:setPositionX(501)
	self.Text_Declare:setVisible(false)

end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 18:03:19
-- @desc 改名初始化页面
function ShenBingNameLayer:setWeapenReName()
	self.Panel_DaZao.Text_Rename:setVisible(true)
	self.Panel_DaZao.Text_Weapon_type:setVisible(false)
	self.Panel_DaZao.Text_Weapon:setVisible(false)
	self.Panel_DaZao.Button_Cancel:setVisible(true)
	self.Panel_DaZao.Button_Yes:setPositionX(792)
	self.Text_Declare:setVisible(true)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 10:45:48
-- @desc 神兵类型
function ShenBingNameLayer:setWeapenTypeText()
	self.Panel_DaZao.Text_Weapon_type:setString(Helper:getDef(self._currWeapon.type,"剑").."类")
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 10:52:55
-- @desc 神兵颜色
function ShenBingNameLayer:setWeapenColorFunc()
    self.Panel_DaZao.Text_Weapon_color:setString(Helper:getDef(self._currWeapon.nameColor, "WHT") .. "颜色")
    if self._layerType == 1 then
        self.Panel_DaZao.Text_Weapon_color:setTouchEnabled(false)
        self.Panel_DaZao.Button_Weapon_color:setTouchEnabled(false)
    else
        self.Panel_DaZao.Button_Weapon_color:setTouchEnabled(true)
        self.Panel_DaZao.Button_Weapon_color:releaseFunc(
            function()
                self.colorId = self.colorId + 1
                if self.colorId > #colorType then
                    self.colorId = 1
                end
                self.Panel_DaZao.Text_Weapon_color:setString(colorType[self.colorId].name .. "颜色")
                self:setEditBoxFontColor(colorType[self.colorId].color)
            end
        )
    end
end

local isName = true

function ShenBingNameLayer:setBackButton()
    self.Panel_DaZao.Button_Yes:releaseFunc(
        function()
			if isName then
				isName = false
				if self.editBox ~= nil then
					self._editBoxString = self.editBox:getText()
	
					HttpManagerEx:containsBlockedWord(
						self._editBoxString,
						function(status, errcode, errmsg, data)
							if errcode == 0 then
								if self:checkName(self._currWeapon) == false then
								else
									if self._layerType == 1 then
										self._currWeapon.name = self._editBoxString
										if self._backCallFunc then
											self._backCallFunc(self._currWeapon)
										end
										self.editBox:removeFromParent()
										self.editBox = nil
										self:hide()
									else
										if self:checkIsRename(self._currWeapon) == false then
											PopText("神兵名称与颜色均未修改")
											isName = true
											return
										end
										if User:getRole():getInheritFlag("神兵改名") == 0 then
											self._currWeapon.name = self._editBoxString
											self._currWeapon.nameColor = colorType[self.colorId].name
											if self._backCallFunc then
												self._backCallFunc(self._currWeapon)
											end
											User:getRole():setInheritFlag("神兵改名", 1)
											local str = "HIC你将化金粉涂抹在兵器之上，不过多时，抹过化金粉的地方已是软化了，你将原先的名字抹去，用食指在兵器上写上了龙飞凤舞的数个大字“" .. self._currWeapon.nameColor .. self._currWeapon.name .. "NOR”。"
											self:print(str)
											self.editBox:removeFromParent()
											self.editBox = nil
											self:hide()
										else
											PopYuanBaoBuyItemLayer(
												"gaimingwupin1",
												function(eventType)
													if eventType == "success" then
														self._currWeapon.name = self._editBoxString
														self._currWeapon.nameColor = colorType[self.colorId].name
														if self._backCallFunc then
															self._backCallFunc(self._currWeapon)
														end
	
														local str = "HIC你用元宝买来化金粉涂抹在兵器之上，不过多时，抹过化金粉的地方已是软化了，你将原先的名字抹去，用食指在兵器上写上了龙飞凤舞的数个大字“" .. self._currWeapon.nameColor .. self._currWeapon.name .. "NOR”。"
														self.editBox:removeFromParent()
														self.editBox = nil
														self:print(str)
														self:hide()
													else
														PopText("神兵改名失败，请重试。")
													end
												end
											)
										end
									end
								end
								isName = true
							elseif errcode == 1 then
								local isUse,sensitiveWord = self:checkNameCanUse(self._editBoxString)
								
								PopText(sensitiveWord .. " 是非法词汇，请更换后再试。")
								isName = true
							else
								PopText(errmsg)
								isName = true
							end
						end,
						IS_SHOW_WAITING
					)
				else
					isName = true
				end
			end
        end
    )
end




function ShenBingNameLayer:print(str)
	local currLayer = MainControllLayer:getCurrLayer()
	
	if currLayer == "ShenBingLayer" then
		local maplayer = MainControllLayer:getLayer(currLayer)
		maplayer:print(str)
		maplayer:isShow()
	else
		RichPrint("main",str)
	end
end

function ShenBingNameLayer:checkIsRename(weapen)
	if self.editBox:getText() ~= weapen.name then
		return true
	end
	if colorType[self.colorId].name ~= weapen.nameColor then
		return true
	end
	return false
end

function ShenBingNameLayer:checkName(weapen)
	    if self._editBoxString == nil or self._editBoxString == "" then
		    PopText("名称不能为空，请填写后再次尝试")
	    	return false
	    end

	    if not Helper:isChinese(self._editBoxString) then
	      	PopText("修改名称必须为中文，不能使用英文或符号")
	      	return false
	    end

	     -- 一个 utf－8的中文字，占3个字节
	    if string.len(self._editBoxString) > 5 * 3 then		
	    	if PRINT_MODE == 1 then    	
	    		print("string.len(self._editBoxString) = "..tostring(string.len(self._editBoxString)))
	    	end
	    	PopText("名称最多为5个中文字符，请更改后再试")
	    	return false
	    end
	    -- ---名字居中显示

		local isUse,sensitiveWord = self:checkNameCanUse(self._editBoxString,weapen.type)
	    if isUse then
	    	return true
	    else
	    	PopText(sensitiveWord .. " 是非法词汇，请更换后再试。")
	    	return false
	    end

end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 17:29:02
-- @desc 名字中是否有不合法字
function  ShenBingNameLayer:checkNameCanUse(name,type)
	local isSensitiveWord,sensitiveWord = Helper:isMaskOff(name)
	local isUse = not isSensitiveWord
	return isUse, sensitiveWord
end

function ShenBingNameLayer:setLayerType(layerType)
	self._layerType = layerType
end

function ShenBingNameLayer:setChangeDefaultShenBingBtnVisible(visible)
	self.Image_back_ChangeWeapon:setVisible(visible)
end

function ShenBingNameLayer:initChangeDefaultShenBingBtnFunc()
	self.Image_back_ChangeWeapon:releaseFunc(function()
		PopupLayerController:showLayer("ShenBingWareHouseLayer",function(layer)
			layer:setBackConditionFunc(function()
				local role = User:getRole()
				local shenBing = role:getDefaultShenBing()
				if shenBing then
					self:setCurrWeapon(shenBing)
					self:initWeaponColorId()
					self:initUI()
					return true
				else
					PopText("请设置默认神兵，否则无法进行操作！")
					return false
				end
			end)
			layer:showUI()
		end)
	end)
end

Helper:classDefNodeGetInstance(ShenBingNameLayer)
return  ShenBingNameLayer0000000000000
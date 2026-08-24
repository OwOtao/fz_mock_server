local AttrSkinUI = class("AttrSkinUI", cc.Layer)

function AttrSkinUI:create(resPath)
	local p = AttrSkinUI:new()
	p:init(resPath)
	return p
end

function AttrSkinUI:init(resPath)
	local resPath = resPath
	self._round = require(resPath).create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点
	self.Text_neili_jin:setVisible(false)
	self.Button_neidan:setVisible(false)

	self:addBgUI()
end

function AttrSkinUI:setTextNameTitle(chenghao)
	self.Text_nameTitle:setColor(cc.c3b(208, 208, 208)) --默认白色
	self.Text_nameTitle:setString(chenghao)
end

function AttrSkinUI:setTextName(name)
	self.Text_name:setString(name)
end

function AttrSkinUI:setTextJing(curr, max)
	curr, max = tostring(curr), tostring(max)
	self.Text_jing:setString("『精神』"..curr.."/"..max)
end

function AttrSkinUI:setTextQi(curr, max, percent)
	curr, max = Helper:getDef(curr, User:getRoleAttr("qi")), Helper:getDef(max, User:getRole():getCurrQiMax())
	if not percent then
		percent = 1
	end
	self.Text_qi:setString("『气血』"..curr.."/"..Helper:mathFloor(max).." ("..tostring(math.floor(percent*100)).."%)")
end

function AttrSkinUI:setTextNeili(curr, max)
	self:setTextNeiliNum(curr, max)
end

function AttrSkinUI:setTextNeiliNum(curr, max)
	curr, max = tostring(curr), tostring(max)
	self.Text_neili_num:setString(curr.."/"..max)
end

function AttrSkinUI:setTextNeiliJin(curr, max)
	curr, max = tostring(curr), tostring(max)
	self.Text_neili_jin:setString("『内力』"..curr.."/"..max)
end

function AttrSkinUI:setTextExp(exp)
	exp = tostring(exp)
	self.Text_exp:setString("『经验』"..exp)
end

function AttrSkinUI:setTextPot(pot)
	pot = tostring(pot)
	self.Text_pot:setString("『潜能』"..pot)
end

function AttrSkinUI:setTextLv(lv)
	lv = tostring(lv)
	self.Text_lv:setString("『等级』"..lv)
end

function AttrSkinUI:setTextMoney(money)
	money = tostring(money)
	self.Text_money:setString("『金钱』"..money)
end

function AttrSkinUI:setTextSex(sex)
	sex = tostring(sex)
	self.Text_sex:setString("『性别』"..sex)
end

function AttrSkinUI:setTextAge(age)
	age = tostring(age)
	self.Text_age:setString("『年龄』"..age)
end

function AttrSkinUI:setTextSpouse(spouse)
	spouse = tostring(spouse)
	self.Text_spouse:setString("『缘分』"..spouse)
end

function AttrSkinUI:setTextMaster(master)
	if not master then
		master = "无"
	end
	self.Text_master:setString("『师父』"..master)
end

function AttrSkinUI:setTextStr(secStr, str)
	if not str or type(str) ~= "number" then
		str = 0
	end
	if not secStr or type(secStr) ~= "number" then
		secStr = 0
	end
	self.Text_str:setString("【臂力】"..tostring(secStr+str).."/"..str)
end

function AttrSkinUI:setTextDex(secDex, dex)
	if not dex or type(dex) ~= "number" then
		dex = 0
	end
	if not secDex or type(secDex) ~= "number" then
		secDex = 0
	end
	self.Text_dex:setString("【身法】"..tostring(secDex+dex).."/"..dex)
end

function AttrSkinUI:setTextInt(secInt, int)
	if not int or type(int) ~= "number" then
		int = 0
	end
	if not secInt or type(secInt) ~= "number" then
		secInt = 0
	end
	self.Text_int:setString("【悟性】"..tostring(secInt+int).."/"..int)
end

function AttrSkinUI:setTextCon(secCon, con)
	if not con or type(con) ~= "number" then
		con = 0
	end
	if not secCon or type(secCon) ~= "number" then
		secCon = 0
	end
	self.Text_con:setString("【根骨】"..tostring(secCon+con).."/"..con)
end

function AttrSkinUI:setTextLooks(looks)
	looks = tostring(looks)
	self.Text_looks:setString("【容貌】"..looks)
end

function AttrSkinUI:setTextLuck(luck)
	luck = tostring(luck)
	self.Text_luck:setString("【福缘】"..luck)
end

function AttrSkinUI:setTextChengzhang()
	self.Text_chengzhang:setVisible(false)
end

function AttrSkinUI:getHeadNodePos()
	return self.Node_HeadViewPos:getPosition()
end

function AttrSkinUI:addTitleUI()

end

function AttrSkinUI:addBgUI()
    local sprite_1 = cc.Sprite:create("Image/UI/MainUI/backgurand.jpg")
    sprite_1:setPosition(540.0000, 960.0000)
    self._round:addChild(sprite_1,-99)

    local sprite_2 = cc.Sprite:create("Image/UI/MainUI/changjing01.png")
    sprite_2:setAnchorPoint(0.0000, 0.0000)
    sprite_2:setPosition(0.0000, 0.0000)
    self._round:addChild(sprite_2,-98)
end

function AttrSkinUI:addTabUI(node)
	if node then
		self._round:addChild(node)
	end
end

function AttrSkinUI:initSkinAnimator(animResPath, animName)
	if not animResPath then
		return
	end
	
    local SpineAnimator = require("third.animator.SpineAnimator.SpineAnimator")
    if self.__animator == nil then
        self.__animator = SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile(animResPath..animName..".skel", animResPath..animName..".atlas", 1), "动画初始化出错"))
        self.Panel_anim:addChild(self.__animator:getSkeletonAnimation())
        self.__animator:getSkeletonAnimation():setPosition(self.Panel_anim:getSizeWidth()/2, self.Panel_anim:getSizeHeight()/2)
		self.__animName = animName
    end
    return self.__animator
end

function AttrSkinUI:playSkinAnim()
	if self.__animator then
		self.__animator:play(self.__animName, true)
	end
end

function AttrSkinUI:updataSkinAnim(ft)
	if self.__animator then
		self.__animator:update(ft)
	end
end

return AttrSkinUI
000000000000
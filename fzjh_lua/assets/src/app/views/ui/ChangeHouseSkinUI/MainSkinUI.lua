local MainSkinUI = class("MainSkinUI", cc.Layer)

function MainSkinUI:create(resPath)
	local p = MainSkinUI:new()
	p:init(resPath)
	return p
end

function MainSkinUI:init(resPath)
	local resPath = resPath or "Layer/MainUI.lua"
	self._round = require(resPath).create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点

	if resPath == "Layer/MainUI.lua" then
		self:addBgUI()
	end

	self.Text_chengzhang:setVisible(false)
end


function MainSkinUI:setTextName(chenghao,name)
	self.Text_name:setColor(cc.c3b(208, 208, 208)) --默认颜色
	self.Text_name:setString(chenghao)
	self.Text_userName:setString(name)
end

function MainSkinUI:setTextJing(curr, max)
	curr, max = tostring(Helper:mathFloor(curr)), tostring(Helper:mathFloor(max))
	self.Text_jing:setString("『精神』"..curr.."/"..max)
end

function MainSkinUI:setTextQi(curr, max, percent)
	curr, max = Helper:getDef(curr, User:getRoleAttr("qi")), Helper:getDef(max, User:getRole():getCurrQiMax())
	if not percent then
		percent = 1
	end
	self.Text_qi:setString("『气血』"..curr.."/"..Helper:mathFloor(max).." ("..tostring(math.floor(percent*100)).."%)")
end

function MainSkinUI:setTextNeili(str)
	self.Text_neili:setString(str)
end

function MainSkinUI:setTextExp(exp)
	exp = tostring(exp)
	self.Text_exp:setString("『经验』"..exp)
end

function MainSkinUI:setTextPot(pot)
	pot = tostring(pot)
	self.Text_pot:setString("『潜能』"..pot)
end

function MainSkinUI:setTextLv(lv)
	lv = tostring(lv)
	self.Text_lv:setString("『等级』"..lv)
end

function MainSkinUI:setTextMoney(money)
	money = tostring(money)
	self.Text_money:setString("『金钱』"..money)
end

function MainSkinUI:setTextChengzhang(var)
	var = tostring(var)
	self.Text_chengzhang:setString("『成长』"..var.."/小时")
end

function MainSkinUI:addBgUI()
    local sprite_1 = cc.Sprite:create("Image/UI/MainUI/backgurand.jpg")
    sprite_1:setPosition(540.0000, 960.0000)
    self._round:addChild(sprite_1,-99)

    local sprite_2 = cc.Sprite:create("Image/UI/MainUI/changjing01.png")
    sprite_2:setAnchorPoint(0.0000, 0.0000)
    sprite_2:setPosition(0.0000, 0.0000)
    self._round:addChild(sprite_2,-98)
end

function MainSkinUI:initSkinAnimator(animResPath, animName)
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

function MainSkinUI:playSkinAnim()
	if self.__animator then
		self.__animator:play(self.__animName, true)
	end
end

function MainSkinUI:updataSkinAnim(ft)
	if self.__animator then
		self.__animator:update(ft)
	end
end

return MainSkinUI
000000000
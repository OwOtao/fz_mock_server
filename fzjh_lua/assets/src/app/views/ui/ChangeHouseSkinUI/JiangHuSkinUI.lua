
local Family = require("app.models.family.Family")
local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
local CoroutinePool = require("third.coroutine.CoroutinePool")
local AsyncFunction = require("third.async.AsyncFunction")

local JiangHuSkinUI = class("JiangHuSkinUI", cc.Layer)

function JiangHuSkinUI:create(resPath)
	local p = JiangHuSkinUI:new()
	p:init(resPath)
	return p
end

function JiangHuSkinUI:init(resPath)
	local resPath = resPath or "Layer/AttrUI/JiangHuAttrUI.lua"
	self._round = require(resPath).create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点

	do -- 隐藏某些不需要的UI
		self.Text_kill_player:setVisible(false)
		self.Text_kill_player_num:setVisible(false)

		self.Text_mengjing:setVisible(false)
		self.Text_mengjing_num:setVisible(false)

		self.Text_panshi:setVisible(false)
		self.Text_panshi_num:setVisible(false)
	end

	self:addBgUI()
end

function JiangHuSkinUI:addBgUI()
    local sprite_1 = cc.Sprite:create("Image/UI/MainUI/backgurand.jpg")
    sprite_1:setPosition(540.0000, 960.0000)
    self._round:addChild(sprite_1,-99)

    local sprite_2 = cc.Sprite:create("Image/UI/MainUI/changjing01.png")
    sprite_2:setAnchorPoint(0.0000, 0.0000)
    sprite_2:setPosition(0.0000, 0.0000)
    self._round:addChild(sprite_2,-98)
end

function JiangHuSkinUI:setPanShi(text)		--叛师次数
	self.Text_panshi:setString(text)
end

function JiangHuSkinUI:setPanShiNum(num)	--叛师次数
	if not num then
		num = 0
	end
	self.Text_panshi_num:setString(num)
end

function JiangHuSkinUI:setMengJing(text)	--梦境层数
	self.Text_mengjing:setString(text)
end

function JiangHuSkinUI:setMengJingNum(num)	--梦境层数
	if not num then
		num = 0
	end
	self.Text_mengjing_num:setString(num)
end

function JiangHuSkinUI:setLunHui(text)		--轮回次数
	self.Text_lunhui:setString(text)
end

function JiangHuSkinUI:setLunHuiNum(num)	--轮回次数
	if not num then
		num = 0
	end
	self.Text_lunhui_num:setString(num)
end

function JiangHuSkinUI:setZhengJiNum(num)		-- 为官政绩
	if not num then
		num = 0
	end
	self.Text_zhengji_num:setString(num)
end

function JiangHuSkinUI:setJinDu(text)		--江湖进度
	self.Text_jindu:setString(text)
end

function JiangHuSkinUI:setJinDuNum(num)		--江湖进度
	if not num then
		num = 0
	end
	self.Text_jindu_num:setString(num)
end

function JiangHuSkinUI:setDeadReason(text)		--上次死因
	self.Text_dead_res:setString(text)
end

function JiangHuSkinUI:setDeadReasonNum(num)	--上次死因
	if not num or num == 0 then
		num = "无"
	end
	self.Text_dead_res_num:setString(num)
end

function JiangHuSkinUI:setMeiLi(text)		--风度魅力
	self.Text_meili:setString(text)
end

function JiangHuSkinUI:setMeiLiNum(num)		--风度魅力
	if not num then
		num = 0
	end
	self.Text_meili_num:setString(num)
end

function JiangHuSkinUI:setDead(text)		--死亡次数
	self.Text_dead:setString(text)
end

function JiangHuSkinUI:setDeadNum(num)		--死亡次数
	if not num then
		num = 0
	end
	self.Text_dead_num:setString(num)
end

function JiangHuSkinUI:setWeiWang(text)		--江湖威望
	self.Text_weiwang:setString(text)
end

function JiangHuSkinUI:setWeiWangNum(num)		--江湖威望
	if not num then
		num = 0
	end
	self.Text_weiwang_num:setString(num)
end

function JiangHuSkinUI:setKillPlayer(text)		--杀玩家数
	self.Text_kill_player:setString(text)
end

function JiangHuSkinUI:setKillPlayerNum(num)		--杀玩家数
	if not num then
		num = 0
	end
	self.Text_kill_player_num:setString(num)
end

function JiangHuSkinUI:setYueLi(text)		--江湖阅历
	self.Text_yueli:setString(text)
end

function JiangHuSkinUI:setYueLiNum(num)		--江湖阅历
	if not num then
		num = 0
	end
	self.Text_yueli_num:setString(num)
end

function JiangHuSkinUI:setKill(text)		--杀死人数
	self.Text_kill:setString(text)
end

function JiangHuSkinUI:setKillNum(num)		--杀死人数
	if not num then
		num = 0
	end
	self.Text_kill_num:setString(num)
end

function JiangHuSkinUI:setZhengQi(text)		--侠义正气
	self.Text_zhengqi:setString(text)
end

function JiangHuSkinUI:setZhengQiNum(num)		--侠义正气
	if not num then
		num = 0
	end
	self.Text_zhengqi_num:setString(num)
end

function JiangHuSkinUI:setFangHu(text)		--防护力
	self.Text_fanghu:setString(text)
end

function JiangHuSkinUI:setFangHuNum(num)		--防护力
	if not num then
		num = 0
	end
	self.Text_fanghu_num:setString(num)
end

function JiangHuSkinUI:setFangHux(text)		--防护系数
	self.Text_fanghux:setString(text)
end

function JiangHuSkinUI:setFangHuxNum(num)		--防护系数
	if not num then
		num = 0
	end
	self.Text_fanghux_num:setString(num)
end

function JiangHuSkinUI:setShangHai(text)		--伤害力
	self.Text_shanghai:setString(text)
end

function JiangHuSkinUI:setShangHaiNum(num)		--伤害力
	if not num then
		num = 0
	end
	self.Text_shanghai_num:setString(num)
end

function JiangHuSkinUI:setShangHaix(text)		--伤害系数
	self.Text_shanghaix:setString(text)
end

function JiangHuSkinUI:setShangHaixNum(num)		--伤害系数
	if not num then
		num = 0
	end
	self.Text_shanghaix_num:setString(num)
end

function JiangHuSkinUI:setFangYu(text)		--防御力
	self.Text_fangyu:setString(text)
end

function JiangHuSkinUI:setFangYuNum(num)		--防御力
	if not num then
		num = 0
	end
	self.Text_fangyu_num:setString(num)
end

function JiangHuSkinUI:setFangYux(text)		--防御系数
	self.Text_fangyux:setString(text)
end

function JiangHuSkinUI:setFangYuxNum(num)		--防御系数
	if not num then
		num = 0
	end
	self.Text_fangyux_num:setString(num)
end

function JiangHuSkinUI:setDodge(text)		--闪躲力
	self.Text_dodge:setString(text)
end

function JiangHuSkinUI:setDodgeNum(num)		--闪躲力
	if not num then
		num = 0
	end
	self.Text_dodge_num:setString(num)
end

function JiangHuSkinUI:setDodgex(text)		--闪躲系数
	self.Text_dodgex:setString(text)
end

function JiangHuSkinUI:setDodgexNum(num)		--闪躲系数
	if not num then
		num = 0
	end
	self.Text_dodgex_num:setString(num)
end

function JiangHuSkinUI:setAtk(text)		--攻击力
	self.Text_atk:setString(text)
end

function JiangHuSkinUI:setAtkNum(num)		--攻击力
	if not num then
		num = 0
	end
	self.Text_atk_num:setString(num)
end

function JiangHuSkinUI:setAtkx(text)		--攻击系数
	self.Text_atkx:setString(text)
end

function JiangHuSkinUI:setAtkxNum(num)		--攻击系数
	if not num then
		num = 0
	end
	self.Text_atkx_num:setString(num)
end

function JiangHuSkinUI:addTabUI(node)
	if node then
		self._round:addChild(node)
	end
end

function JiangHuSkinUI:initSkinAnimator(animResPath, animName)
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

function JiangHuSkinUI:playSkinAnim()
	if self.__animator then
		self.__animator:play(self.__animName, true)
	end
end

function JiangHuSkinUI:updataSkinAnim(ft)
	if self.__animator then
		self.__animator:update(ft)
	end
end

return JiangHuSkinUI00000
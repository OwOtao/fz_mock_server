local NewMapRoleLayer = class("NewMapRoleLayer", require("app.views.layer.MapLayer.MapRoleLayer"))

function NewMapRoleLayer:create()
    local p = NewMapRoleLayer.new()
    p:init()
    return p
end

-- 重写覆盖父类方法
function NewMapRoleLayer:onResume()
end

-- 重写覆盖父类方法
function NewMapRoleLayer:onPause()
end

function NewMapRoleLayer:onEnable()
	self:setSchedule()
end

function NewMapRoleLayer:onDisable()
	self:unscheduleAll()
end

function NewMapRoleLayer:setRole(role)
    self._role = role
end

function NewMapRoleLayer:beforeLeave()
    if self._role:getFlag("地图打坐") == true then
        self._role:setFlag("地图打坐", nil)
        self._role:stopDaZuo()
    end

    self:hideBagItemInfo()

    local title = MainControllLayer:getLayer("TitleLayer")
	title:setTitleBack()

    self:hide(true)
    self:setVisible(false)
    
end

function NewMapRoleLayer:setSchedule()
    self:scheduleUnique(
        function(elapsed)
			if self.__challengeMapRoleInfoPresenter then
				self.__challengeMapRoleInfoPresenter:updata()
			end
        end,
        0,
        "schedule"
    )
end

----离开按钮功能的实现
function NewMapRoleLayer:exitButtonFunc(itype, func, name)
    name = Helper:getDef(name, "HIW离开")

    self.Text_leave:setString(name)
    self.Panel_leave:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function NewMapRoleLayer:__initDreamButtonTitle()
end

function NewMapRoleLayer:__initButtonTitle()
    	--信息
	self.Panel_info_title_1:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(1)
	end)
	--属性
	self.Panel_attr_title_1:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(2)
	end)

	--背包
	self.Panel_bag_title_1:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(3)
	end)

	--技能
	self.Panel_skill_title_1:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		self:changeTab(4)
	end)


	-- 背景点击
	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
end

function NewMapRoleLayer:changeTab(num)
    if not num or type(num) ~= "number" then
		num = 1
	end
	self.__currNum = num 	-- 记录当前栏目

	self:hidePanelAttr()
	self:hidePanelBag()
	self:hidePanelSkill()
    self:hideRoleInfoPanel()
    self:setWeight()

	if num == 1 then
        self:showRoleInfoPanel() 
    elseif num == 2 then
        self:showPanelAttr()
    elseif num == 3 then
        self:showPanelBag()
    elseif num == 4 then
        self:showPanelSkill()
    end
end

function NewMapRoleLayer:__showTitle()
	self.Panel_title:setVisible(false)
	self.Panel_title_1:setVisible(true)	
end

function NewMapRoleLayer:showPanelSkill()
	self.Text_skill_1:setColor(cc.c3b(242, 255, 32))

	local skillInfoViewModel = require("app.models.skill.SkillInfoViewModel.ChallengeMapSkillInfoViewModel"):create(self._role)

	self.__mapSkillInfoPresenter = require("app.presenters.Skill.SkillInfo.ChallengeMapSkillInfoPresenter"):create(self,skillInfoViewModel)

	self.__mapSkillInfoPresenter:showPresenter()
end

-- 背包相关代码 -------------------------------------------------------------------------------------
function NewMapRoleLayer:showPanelBag()
	self.Text_bag_1:setColor(cc.c3b(242, 255, 32))
    local ChallengeMapRoleBagPresenter = require("app.presenters.MapRole.Bag.ChallengeMapRoleBagPresenter"):create()
    local ChallengeMapBag = require("app.models.bag.ChallengeMapBag"):create()

    ChallengeMapBag:setRole(self._role)
    ChallengeMapRoleBagPresenter:setInput(ChallengeMapBag)
	ChallengeMapRoleBagPresenter:setMainPresenter(self)
	ChallengeMapRoleBagPresenter:showPresenter()

	self.__mapBagPresenter = ChallengeMapRoleBagPresenter
end

function NewMapRoleLayer:setWeight()
    local items = self._role:getItems()
    local weight = self._role:getAttr("weight")

    if MapIsEmpty(items) then
		items = {}
	end

	if tonumber(weight) == nil or tonumber(weight) < 0 then
		weight = 0
	end

    self:setWeightUI(tostring(#items) .. "/" .. tostring(weight))
end

function NewMapRoleLayer:setWeightUI(weight)
    self.Text_weight_1:setString(weight)
end

function NewMapRoleLayer:popText(text)
    PopText(text)
end

function NewMapRoleLayer:richPrint(arg1,arg2)
    RichPrint(arg1,arg2)
end

--装备
function NewMapRoleLayer:equipOneItem(desc)
	self:richPrint("main", "WHT" .. tostring(desc))
end

------------------------------------------------------------------
-------------------信息--------------------------------------------
function NewMapRoleLayer:showRoleInfoPanel()
    self.Text_info:setColor(cc.c3b(242, 255, 32))

	if self.__challengeMapRoleInfoPresenter == nil then
		local ChallengeMapRoleInfo = require("app.models.ChallengeMap.ChallengeMapRoleInfo"):create()
		ChallengeMapRoleInfo:setRole(self._role)
		local ChallengeMapRoleInfoPresenter = require("app.presenters.MapRole.RoleInfo.ChallengeMapRoleInfoPresenter"):create()
		ChallengeMapRoleInfoPresenter:setInput(ChallengeMapRoleInfo)
		self.__challengeMapRoleInfoPresenter = ChallengeMapRoleInfoPresenter
	end
	
	self.__challengeMapRoleInfoPresenter:showPresenter()
end

function NewMapRoleLayer:hideRoleInfoPanel()
    self.Text_info:setColor(cc.c3b(255, 255, 255))

    if self.__challengeMapRoleInfoPresenter then
		self.__challengeMapRoleInfoPresenter:hidePresenter()
	end
end

------------------------------------------------------------------
-------------------属性--------------------------------------------
function NewMapRoleLayer:showPanelAttr()
    self.Text_attr_1:setColor(cc.c3b(242, 255, 32))
	local ChallengeMapRoleAttr = require("app.models.ChallengeMap.ChallengeMapRoleAttr"):create()
    ChallengeMapRoleAttr:setRole(self._role)
    local ChallengeMapRoleAttrPresenter = require("app.presenters.MapRole.RoleAttr.ChallengeMapRoleAttrPresenter"):create()
    ChallengeMapRoleAttrPresenter:setInput(ChallengeMapRoleAttr)
	ChallengeMapRoleAttrPresenter:showPresenter()

    self.__challengeMapRoleAttrPresenter = ChallengeMapRoleAttrPresenter
end

function NewMapRoleLayer:hidePanelAttr()
    self.Text_attr_1:setColor(cc.c3b(255, 255, 255))
    if self.__challengeMapRoleAttrPresenter then
		self.__challengeMapRoleAttrPresenter:hidePresenter()

		self.__challengeMapRoleAttrPresenter = nil
	end
end

return NewMapRoleLayer
0000000000
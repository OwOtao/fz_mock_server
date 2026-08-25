local ActiveZhaoMeditateMenuPresenter = class("ActiveZhaoMeditateMenuPresenter", cc.Layer)

function ActiveZhaoMeditateMenuPresenter:create()
    local p = ActiveZhaoMeditateMenuPresenter:new()
    p:init()
    return p
end

function ActiveZhaoMeditateMenuPresenter:init()
    self.__ui = require("app.views.ui.SkillUI.ActiveZhaoMeditateUI.ActiveZhaoMeditateMenuUI"):create()
    self.__ui:addTo(self)
end

function ActiveZhaoMeditateMenuPresenter:onResume()
	self:showLayer()
end

function ActiveZhaoMeditateMenuPresenter:showLayer()
	self.__role = User:getRole()
	
	self.__sys = self.__role:getActiveZhaoMeditateSystem()

    self.__index = 1

	self.__zhao = nil

	self:__clearHandle()

	self:__setRuleFunc()

	self:__refreshActiveZhaoMeditatePanel()

    self:__initSkillTitleList()
    
    self:__setTitleListView()

	self:__lightTab()

	self:__sortSkillList()

    self:__setSkillListView()
    
    self:setTextNum()

	self:__setButton1()
	
	self:__setButton2()

	self:__setButtonBack()
end

function ActiveZhaoMeditateMenuPresenter:setTextNum()
    self.__ui:setText1("尘世感悟："..self.__sys:getCsgwNum().."/"..self.__sys:getCsgwNumLimit())

    self.__ui:setText2("领悟境界："..self.__sys:getMeditateLv())
end

function ActiveZhaoMeditateMenuPresenter:__initSkillTitleList()
    local skillList = self.__sys:getActiveZhaoMeditateList()
    self.__skillTitleList = {
        {name = "拳脚", list = {} ,isSort = false},
        {name = "兵器", list = {} ,isSort = false},
        {name = "轻功", list = {} ,isSort = false},
        {name = "内功", list = {} ,isSort = false},
        {name = "招架", list = {} ,isSort = false}
    }

    for i,skill in ipairs(skillList) do
        if skill.methods then
            for i,vtype in ipairs(skill.methods) do
                if vtype == SKILL_METHOD_TYPE_QUANJIAO then
                    table.insert(self.__skillTitleList[1].list,skill)
                elseif vtype == SKILL_METHOD_TYPE_NEIGONG then
                    table.insert(self.__skillTitleList[4].list,skill)
                elseif vtype == SKILL_METHOD_TYPE_QINGGONG then
                    table.insert(self.__skillTitleList[3].list,skill)
                elseif vtype == SKILL_METHOD_TYPE_ZHAOJIA then
                    table.insert(self.__skillTitleList[5].list,skill)
                elseif vtype == SKILL_METHOD_TYPE_JIAN or vtype == SKILL_METHOD_TYPE_DAO or vtype == SKILL_METHOD_TYPE_GUN or vtype == SKILL_METHOD_TYPE_ANQI or vtype == SKILL_METHOD_TYPE_BIANFA or vtype == SKILL_METHOD_TYPE_SHUANGCHI or vtype == SKILL_METHOD_TYPE_QIN then
                    local temp = false
                    for _,tempSkill in ipairs(self.__skillTitleList[2].list) do
                        if tempSkill.id == skill.id then
                            temp = true
                        end
                    end

                    if temp == false then
                        table.insert(self.__skillTitleList[2].list, skill)
                    end
                end
            end
        end
    end
end

function ActiveZhaoMeditateMenuPresenter:__setTitleListView()
    local retArray = {}
    for i,skillTab in ipairs(self.__skillTitleList) do
        local tab = {
            name = "",
            func = EMPTY_FUNC
        }
        tab["title"] = skillTab.name

        tab["func"] = function()
            self.__index = i

			self.__zhao = nil
			
			self:__lightTab()
            
			self:__sortSkillList()

			self:__setSkillListView()
			
			self:__refreshActiveZhaoMeditatePanel()
			
			self.__ui:skillListViewJumpToTop()
        end

        table.insert(retArray, tab)
    end
    
    self.__ui:setTitleListView(retArray)
end

function ActiveZhaoMeditateMenuPresenter:__lightTab()
	self.__ui:lightTab(self.__skillTitleList[self.__index].name)
end

function ActiveZhaoMeditateMenuPresenter:__sortSkillList()
	local skillTab = self.__skillTitleList[self.__index]
	if skillTab.isSort == true then
		return
	end
	skillTab.isSort = true
    if #skillTab.list > 1 then
        table.sort(skillTab.list, function(a, b)
            local a_islimit = self:__zhaoListIsLimitExp(a.id)

            local b_islimit = self:__zhaoListIsLimitExp(b.id)

			local a_exp = self.__role:getSkillExp(a.id)

			local b_exp = self.__role:getSkillExp(b.id)

			-- 情况1：一个满级、一个未满级 → 未满级放前面
			if a_islimit ~= b_islimit then
				return b_islimit -- b是满级则a排前
			end

			-- 情况2：两者都未满级
			if not a_islimit then
				if a_exp ~= b_exp then
					return a_exp > b_exp -- 等级高靠前
				else
					return a.id < b.id -- 同等级ID升序
				end
			end

			--情况3：两者都是满级，仅按ID升序
			return a.id < b.id
        end)
    end
end

--招式列表的所有主动技能熟练度是否都达到上限
function ActiveZhaoMeditateMenuPresenter:__zhaoListIsLimitExp(skillId)
    local zhaos = self.__role:getSkillZhaoList(skillId)

    for i,zhao in ipairs(zhaos) do
		local zhaoId = zhao:getId()

		if not self:__zhaoIsMaxExp(zhaoId) then
			return false
		end
    end

    return true
end

function ActiveZhaoMeditateMenuPresenter:__zhaoIsMaxExp(zhaoId)
	local zhaoExp = self.__role:getSkillZhaoExp(zhaoId)

	local maxZhaoLv = self.__role:getZhaoLvLimit(zhaoId)
	
	local maxExp = self.__role:getZhaoExpLimit(zhaoId,maxZhaoLv) 

	return zhaoExp >= maxExp
end

function ActiveZhaoMeditateMenuPresenter:__setSkillListView()
    local retArray = {}

	local currList = self.__skillTitleList[self.__index].list

    if MapIsEmpty(currList) == false then

		self.__ui:setNotSkillTextVisible(false)
        
		for index,v in ipairs(currList) do
			local tab = {
                name = v.name,

                lvText = self.__role:getSkillLv(v.id).."级",
                
				namePosX = 58,
				
				textColor = {r = 255, g = 255, b = 255},
				
				func = function()
					self.__zhao = nil

					self.__activePanels = {}
					
					self:__refreshActiveZhaoMeditatePanel()

					self:__setSkillListView()

                    local zhaoList = self:__getShowZhaoList(v.id)
					
					for i,zhao in ipairs(zhaoList) do
						local zhaoName,textColor,func

						local zhaoId = zhao:getId()

						local zhaoExp = self.__role:getSkillZhaoExp(zhaoId)

						local maxZhaoLv = self.__role:getZhaoLvLimit(zhaoId)
						
						local maxExp = self.__role:getZhaoExpLimit(zhaoId,maxZhaoLv) 

						if zhaoExp >= maxExp then
							zhaoName = zhao:getName().."（满级）"

							textColor = {r = 142, g = 142, b = 142}

							func = function()
								PopText("当前武学招式熟练度已满，无法领悟")
								return
							end
						else
							zhaoName = zhao:getName()
							
							textColor = {r = 255, g = 255, b = 255}

							func = function()
								self.__zhao = zhao

								self:__refreshActivePanel()

								self:__refreshActiveZhaoMeditatePanel()
							end
						end

						self:__insertActive(
							index,
							zhaoId,
							{   
								name = zhaoName,

								lvText = Helper:mathFloor(zhaoExp).."/"..maxExp,
								
								namePosX = 104,

								textColor = textColor,

								func = func
							}
						)
					end
                end
            }

            table.insert(retArray, tab)
        end
	else
		self.__ui:setNotSkillTextVisible(true)
    end

    self.__ui:setSkillListView(retArray)
end

function ActiveZhaoMeditateMenuPresenter:__getShowZhaoList(skillId)
	local showZhaoList = {}

	local zhaoList = self.__role:getSkillZhaoList(skillId)

	for i,zhao in ipairs(zhaoList) do
		if self.__role:getSkillZhaoExp(zhao:getId()) > 0 then
			table.insert(showZhaoList,zhao)
		end
	end

	if #showZhaoList > 1 then
		table.sort(showZhaoList, function(a, b)
			local a_zhaoId = a:getId()
	
			local b_zhaoId = b:getId()
			
			local a_zhaoExp = self.__role:getSkillZhaoExp(a_zhaoId)
	
			local a_maxExp = self.__role:getZhaoExpLimit(a_zhaoId,self.__role:getZhaoLvLimit(a_zhaoId)) 
			
			local b_zhaoExp = self.__role:getSkillZhaoExp(b_zhaoId)
	
			local b_maxExp = self.__role:getZhaoExpLimit(b_zhaoId,self.__role:getZhaoLvLimit(b_zhaoId)) 
	
			local a_islimit = a_zhaoExp >= a_maxExp
	
			local b_islimit = b_zhaoExp >= b_maxExp

			if a_islimit ~= b_islimit then
				return a_islimit
			end
	

			if not a_islimit then
				if a_zhaoExp ~= b_zhaoExp then
					return a_zhaoExp > b_zhaoExp
				else
					return a_zhaoId > b_zhaoId
				end
			end
	
			return a_zhaoId > b_zhaoId
		end)
	end
	

	return showZhaoList
end

function ActiveZhaoMeditateMenuPresenter:__insertActive(insetPos,zhaoId,data)
	local activePanel = self.__ui:createActivePanel(data)

	self.__activePanels[zhaoId] = activePanel

	self.__ui:insertActivePanel(insetPos,activePanel)
end

function ActiveZhaoMeditateMenuPresenter:__refreshActivePanel()
	if not MapIsEmpty(self.__activePanels) then
		for zhaoId,activePanel in pairs(self.__activePanels) do
			local textColor = {r = 255, g = 255, b = 255}

			if self:__zhaoIsMaxExp(zhaoId) then
				textColor = {r = 142, g = 142, b = 142}
			end

			if zhaoId == self.__zhao:getId() then
				textColor = {r = 249, g = 249, b = 0}
			end

			self.__ui:refreshActivePanelTextColor(activePanel,textColor)
		end
	end
end

function ActiveZhaoMeditateMenuPresenter:__clearHandle()
    if self.__handle ~= nil then
        self:unschedule(self.__handle)
        self.__handle = nil
    end
end

function ActiveZhaoMeditateMenuPresenter:__refreshActiveZhaoMeditatePanel()
	local text1 = ""
	
	local text2 = ""
	
	local text3 = ""

	local text4 = ""

	local buttonVisible = false

	local buttonName = ""

	local buttonFunc = EMPTY_FUNC

	if self.__sys:isMeditating() then
		local zhaoId = self.__sys:getMeditatingInfo().zhaoId

		local zhaoName = Skill:getActiveZhao(zhaoId):getName()

		text1 = "领悟中招式："..zhaoName

		buttonVisible = true

		if self.__sys:isCompleteMeditate() then
			self:__clearHandle()

			buttonName = "领悟完成"

			buttonFunc = function()
				self:__showGuaJiUI()
			end
		else
			if not self.__zhao then
				local hour, min, sec = Helper:sec2timeDsc(self.__sys:getResidueTime())
		
				text2 = "所需时间："..hour .. "小时" .. min .. "分钟" .. sec .. "秒"
			end

			buttonName = "领悟中"

			buttonFunc = function()
				self:__showGuaJiUI()
			end
			
			if self.__handle == nil then
				self.__handle =
					self:schedule(
					function(ft)
						self:__refreshActiveZhaoMeditatePanel()
					end,
					0
				)
			end
		end
	else
		self:__clearHandle()

		if not self.__zhao then
			text4 = "请选择需要领悟的武学"
		end
	end

	if self.__zhao then
		buttonVisible = true

		local zhaoExp = self.__role:getSkillZhaoExp(self.__zhao.id)

		local maxExp = self.__role:getZhaoExpLimit(self.__zhao.id,self.__role:getZhaoLvLimit(self.__zhao.id))
		
		local canyeId = self.__zhao.id.."canye"

		local itemName = Item:getOneItemByKey(canyeId).name

		local canyeNum = self.__sys:getCanYeNum(canyeId)
		
		text1 = self.__zhao.name

		text2 = "熟练度："..Helper:mathFloor(zhaoExp).."/"..Helper:mathFloor(maxExp)
	
		text3 = itemName.."："..canyeNum

		if not self.__sys:isMeditating() then
			buttonName = "领悟"

			buttonFunc = function()
				self:__showMeditateInfoUI()
			end
		end
	end

	self.__ui:setMeditateText1(text1)

	self.__ui:setMeditateText2(text2)
	
	self.__ui:setMeditateText3(text3)
	
	self.__ui:setMeditateText4(text4)

	self.__ui:setMeditateButtonVisible(buttonVisible)

	self.__ui:setMeditateButtonName(buttonName)

	self.__ui:setMeditateButtonFunc(buttonFunc)
end

function ActiveZhaoMeditateMenuPresenter:__setRuleFunc()
	self.__ui:setButtonRuleFunc(function()
        PopupLayerController:showLayer("ActionRuleUI",function(layer)
			layer:showUI()
			layer:setTextTitle("领悟规则")
			layer:showPanel_1("1、领悟招式时，可通过消耗对应残页或尘世感悟完成领悟挂机来获得熟练度。每次领悟招式时，需要消耗对应的指定残页，若无对应残页则可用尘世感悟替代。\n2、领悟后获得的招式熟练度和当前境界等级有关，境界等级越高，可以获得的熟练度越高。\n3、尘世感悟可以通过融汇多余残页获得，每周可获得尘世感悟数量有限，当周获得尘世感悟超出最大值后，则无法通过融汇获得更多的尘世感悟。\n4、提升境界可强化以下四项：使用残页领悟时的额外熟练度加成、使用尘世感悟领悟时的额外熟练度加成、融汇残页时的额外尘世感悟产出、每周融汇获取尘世感悟的上限。\n5、领悟招式时可提升境界，但当次提升的境界效果无法应用于正在领悟中的招式，只能应用于下一次招式领悟或融汇。\n6、若主动终止领悟，不返还已消耗资源，并且也不会获得对应熟练度，请慎重考虑后再决定终止领悟。\n7、领悟招式所获得的熟练度，和战斗获得熟练度，家园陪练获得的熟练度分开独立计算，不会影响后两者的获取。但当获取熟练度时，出现超出最大熟练度的部分会被抹除，请谨慎操作。\n8、每周通过融汇获得的尘世感悟设有数量上限，每周已获取数量将在每周一0点清零，清零后可继续融汇获取。\n9、可通过「-/+」按钮调整投放数量，或使用「最小」「最大」按钮快速填入当前可投放的上下限数量。")
			layer:setButtonBack(function()
				PopupLayerController:hideLayer("ActionRuleUI",function(layer)
					layer:hideUI()
				end)
			end)
		end)
    end)
end

function ActiveZhaoMeditateMenuPresenter:__setButton1()
	self.__ui:setButton1(function()
        PopupLayerController:showLayer("ActiveZhaoMergePresenter",function(layer)
			layer:setRole(self.__role)
			layer:setCallback(
				function()
					self:setTextNum()
					
					self:__refreshActiveZhaoMeditatePanel()
				end
			)
			layer:showLayer()
		end)  
    end)
end

function ActiveZhaoMeditateMenuPresenter:__setButton2()
	self.__ui:setButton2(function()
        PopupLayerController:showLayer("ActiveZhaoLevelPresenter",function(layer)
			layer:setRole(self.__role)
			layer:setCallback(
				function()
					self:setTextNum()
					
					self:__refreshActiveZhaoMeditatePanel()
				end
			)
			layer:showLayer()
		end)  
    end)
end

function ActiveZhaoMeditateMenuPresenter:__setButtonBack()
	self.__ui:setButtonBack(function()
		self:__clearHandle()

		MainControllLayer:popLayer()
	end)
end

function ActiveZhaoMeditateMenuPresenter:__showMeditateInfoUI()
	PopupLayerController:showLayer("ActiveZhaoMeditateInfoPresenter",function(layer)
		layer:setRole(self.__role)
		layer:setCallback(function()
			self:setTextNum()
			
			self:__refreshActiveZhaoMeditatePanel()

			self:__showGuaJiUI()
		end)
		layer:showLayer(self.__zhao)
	end)
end

function ActiveZhaoMeditateMenuPresenter:__showGuaJiUI()
	PopupLayerController:showLayer("ActiveZhaoGuaJiPresenter",function(layer)
		layer:setRole(self.__role)
		layer:setCallback(function()
			self:setTextNum()
			
			self:__refreshActiveZhaoMeditatePanel()

			self:__setSkillListView()
		end)
		layer:showLayer()
	end)
	
end

Helper:classDefNodeGetInstance(ActiveZhaoMeditateMenuPresenter)
return ActiveZhaoMeditateMenuPresenter
000000000
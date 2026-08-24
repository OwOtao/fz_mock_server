--   已学锻造技艺界面
local ShenBingSkilledLayer = class("ShenBingSkilledLayer", cc.Layer)
-- local res = require("script.others.godweapon")
-- local duanzaoList =  res["itemOfFurnaceWeaponType"]
local  ForgeSkill = require("app.models.ShenBing.ForgeSkill.ForgeSkill")

function ShenBingSkilledLayer:create()
	local p = ShenBingSkilledLayer:new()
	p:init()
	return p
end

function ShenBingSkilledLayer:init()
	self._round = require("Layer/ShenBing/ShenBingSkilled.lua").create()['root']
	self._round:addTo(self)

	self._titleVector = {}

    Helper:convertUIByParent(self) -- 获得所有子节点
	self.Panel_Text:setVisible(false)	

	self.weapon= {}  -- 解锁的全部兵器
	self.unpfSkill = {}

	self:initTabView()
	
end

-- 初始化全部锻造术
function ShenBingSkilledLayer:initTabView( )

	local duanzaoList = ShenBingDesc:getTextMapAttr("knowledgeList") 
	local textColor = cc.c3b(141,101, 4)
	local outlineColor = cc.c4b(44, 51, 54, 255)
	local tag = 999
		for index,it in ipairs( duanzaoList ) do
		  
			local panel = self.Panel_Text:clone()
			Helper:convertUIByParent(panel)
			panel:setTag(tag)
			panel.Text_name:enableOutline(cc.c4b(17, 18, 18, 255), 5)
			panel:setVisible(true)
			panel.Image_back:setVisible(false)
			panel.Text_name:setString(it.itemname1.."锻造")		
			local know_number  = Helper:getDef(it.weaponAll,{} ) 
			local weaponlist = Helper:getDef(self.weapon[tonumber(index)],{})
        
			panel.Text_name:setColor(textColor)
			-- panel.Text_number:setString("（"..Helper:getDef(#weaponlist,0).."/"..#know_number.."）")
	
			self.ListView_duanzao:pushBackCustomItem(panel)
			panel:releaseFunc(function()
				-- 右边可以锻造的 兵器按钮边框变蓝
				self:initWeaponTypeList(self.weapon[tonumber(index)],self.unpfSkill[tonumber(index)])
				-- self.skillListItems = {}
				
				self:setTitleImageShow(panel)
			end)
			self._titleVector[#self._titleVector + 1 ] = panel
			tag = tag + 1
		end
end


-- 高亮选择标题
function ShenBingSkilledLayer:setTitleImageShow(panel)
	if panel then
		local tag = panel:getTag()
		if not MapIsEmpty(self._titleVector) and tag then
			for i,v in ipairs(self._titleVector) do
				if v:getTag() and v:getTag()  == tag then
					v.Image_back:setVisible(true)
				else
					v.Image_back:setVisible(false)
				end
			end
		end
	else
		if not MapIsEmpty(self._titleVector) then
			for i,v in ipairs(self._titleVector) do
				if i == 1 then
					self._titleVector[i].Image_back:setVisible(true)
				else
					self._titleVector[i].Image_back:setVisible(false)
				end
			end
		end
	end
end

-- 初始化已拥有的锻造知识 所有  在左边     用已拥有的锻造知识点查找 对应的可打造的武器
function ShenBingSkilledLayer:initSkills()
	local pfSkill = ForgeSkill:getUserFoegeKnowledge()  -- 获得已拥有的锻造知识点
	-- 获得已拥有的锻造知识点id  集
	local knowledgeIdList = {}
	for forgeId,knowledges in pairs(pfSkill) do 
			for k,knowledge in pairs(knowledges) do 
				table.insert( knowledgeIdList, knowledge )
			end
	end
	local unpfSkill = ForgeSkill:getUserForgeUnLearnKnowledge()
	local unknowledgeIdList = {}
	for forgeId,knowledges in pairs(unpfSkill) do 
			for k,knowledge in pairs(knowledges) do 
				table.insert( unknowledgeIdList, knowledge )
			end
	end

	local allknowledgeList =  ShenBingDesc:getTextMapAttr("knowledgeList") 
 
	if  type(allknowledgeList) ~= "table"then
		print("getTextMapAttr  knowledgeList 此接口返回不为table ！")
	end
	for id,knowledgeList in  pairs(allknowledgeList) do
		self.weapon[id] = {}
		self.unpfSkill[id] = {}
        --遍历每一行数据中的知识点
		for index,allknowledgeid in  pairs(knowledgeList.knowledgeAll) do
			for i,knowledgeid in  pairs(knowledgeIdList) do
				--	用已拥有锻造知识id 匹配 锻造对应的 全部知识点  得到index 获得对应武器 (只获取一条)
				-- print("allknowledgeid    "..allknowledgeid)
				if knowledgeid == allknowledgeid then 
                    table.insert( self.weapon[id] , knowledgeList.weaponAll[index] )
				end
			end
		end

		for index,allknowledgeid in  pairs(knowledgeList.knowledgeAll) do
			for i,knowledgeid in  pairs(unknowledgeIdList) do
				--	用已拥有锻造知识id 匹配 锻造对应的 全部知识点  得到index 获得对应武器 (只获取一条)
				-- print("allknowledgeid    "..allknowledgeid)
				if knowledgeid == allknowledgeid then 
                    table.insert( self.unpfSkill[id] , knowledgeList.weaponAll[index] )
				end
			end
		end
	end 
end

function ShenBingSkilledLayer:initWeaponTypeList(list1,list2)
	if MapIsEmpty(list1) and MapIsEmpty(list2) then
		self.Text_1:setVisible(true)
		self.ListView_weaponType:setVisible(false)
		return
	else
		self.Text_1:setVisible(false)
		self.ListView_weaponType:setVisible(true)
	end

	self.ListView_weaponType:removeAllItems()

	local learnedSkillNum = #list1
	local notLearnedSkillNum = #list2
	local weaponTypeNum = learnedSkillNum + notLearnedSkillNum
	local panelNum = 0

	for i = 1, weaponTypeNum do
		local itemPanel,posX
		if math.mod(i, 2) == 0 then
			itemPanel = self.ListView_weaponType:getItem(panelNum)
			posX = 458
			panelNum = panelNum + 1
		else
			itemPanel = self:__getWeaponTypeItemPanel()
			self.ListView_weaponType:pushBackCustomItem(itemPanel)
			posX = 200
		end

		local item = self:__getWeaponTypeItem()
		self:__addWeaponTypeItem(itemPanel, item, posX)

		local name,color,visible,func

		if i <= learnedSkillNum then
			name = list1[i]
			color = cc.c3b(0, 255, 255)
			visible = true
			func = function()
				PopText("该技艺你已习得")
			end
		elseif i <= learnedSkillNum + notLearnedSkillNum then
			name = list2[i - learnedSkillNum]
			color = cc.c3b(159, 159, 159)
			visible = true
			func = function()
				PopText("该技艺你还未习得")
			end
		end

		self:__setWeaponTypeItemName(item, name)
		self:__setWeaponTypeItemColor(item, color)
		self:__setWeaponTypeItemVisible(item, visible)
		self:__setWeaponTypeItemFunc(item,func)
	end
end

function ShenBingSkilledLayer:onResume( ... )
	-- body
	self:initSkills()
	self:setTitleImageShow()
	self:initWeaponTypeList(self.weapon[1],self.unpfSkill[1])

	self:ShenBingSkilledDsc()
end

--锻造技艺描述
function ShenBingSkilledLayer:ShenBingSkilledDsc()
	local titleLayer = MainControllLayer:getLayer("TitleLayer")
    if titleLayer then
        titleLayer:setTipFunc(
            function(func)
                local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
				local dialog = DialogELayer:getInstance()
							
				dialog:show("研读锻造书籍、熔炼材料、淬炼、锻造兵器可提升锻造之术的等级。锻造技艺可通过研读锻造书籍掌握。\n已拥有锻造书籍传承保留，书籍等级降为一级，锻造之术传承保留一半经验值。如传承后锻造神兵时发现已学技艺少了，请勿担心，这是因为锻造书籍等级过低，通过研读锻造书籍即可再次掌握锻造技艺。")
				dialog:setPanelBack(function()
					if func then
						func()
					end
					
				end)
            end
        )
    end
end

function ShenBingSkilledLayer:__getWeaponTypeItemPanel()
	local item = self.Panel_weaponType:clone()
	Helper:convertUIByParent(item)

	return item
end

function ShenBingSkilledLayer:__getWeaponTypeItem()
	local item = self.Button_celebrity:clone()
	Helper:convertUIByParent(item)

	return item
end

function ShenBingSkilledLayer:__setWeaponTypeItemVisible(item, visible)
	visible = Helper:getDef(visible, false)
	item:setVisible(visible)
end

function ShenBingSkilledLayer:__setWeaponTypeItemName(item, name)
	name = Helper:getDef(name, "")
	item.Text_celebrity_button_text:setString(name)
end

function ShenBingSkilledLayer:__setWeaponTypeItemColor(item, color)
	color = Helper:getDef(color, cc.c3b(159, 159, 159))
	item:setColor(color)
end 

function ShenBingSkilledLayer:__setWeaponTypeItemFunc(item, func)
	item:releaseFunc(function()
		if func then
			func()
		end
	end)
end  

function ShenBingSkilledLayer:__addWeaponTypeItem(panel, item, posX)
	panel:addChild(item)
	item:setPosition(posX,40)
	item:setName(chlidName)
	item:setVisible(false)
end

Helper:classDefNodeGetInstance(ShenBingSkilledLayer)
return  ShenBingSkilledLayer
00000000000000
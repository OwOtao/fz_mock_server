--
-- Author: TanQinJian
-- Date: 2019-04-24 17:57:48
--
local CrossingRiverLayer=class("CrossingRiverLayer", cc.Layer)
local sideRoleNum={     --记录button数量
	[1]={[1]=3,[2]=3}, --河岸 1--"soldier"  2--"prisoner"
	[2]={[1]=0,[2]=0}, --对岸
	[3]={[1]=0,[2]=0}, --船上
}
function CrossingRiverLayer:create()
	local p = CrossingRiverLayer:new()
	p:init()
	return p
end

function CrossingRiverLayer:init()
	local UI = require("Layer/ActionUI/CrossingRiverUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)
	self:initData()
	self:initUI()
end

function CrossingRiverLayer:initData()
	self.fisrtRiverBank_prisonerNum=3  --河岸
	self.fisrtRiverBank_soldierNum=3	
	self.otherRiverBank_prisonerNum=0	--对岸
	self.otherRiverBank_soldierNum=0

	  --1 船下 2 船上
	self.boatState=1    --1 河岸  2  对岸
end

function CrossingRiverLayer:initUI()
	self.Panel_rule.Text_rule:setString("现有官兵三人、囚犯三人，船一次可渡两人，且必须有人划船，河两岸囚犯不能多于官兵，否则囚犯会杀死官兵，渡河失败。")
	self.Button_confirm:releaseFunc(function ()
		self:crossingRiverButtonFunc()
	end)
	self.Button_back:releaseFunc(function ()
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()

		dialog:show("是否确定退出兵囚渡河玩法，退出玩法会当作失败处理。")
		dialog:setButton1("是", function()
			self:hideLayer()
		end)
		dialog:setButton2("否", function()
		end)
		
	end)
	self.Panel_result:setVisible(false)
	self:refreshOneRiverBankButton()
	self:refreshBoatButton()
	self:refreshOtherRiverBankButton()
	
end

--peopleState 1 在初始岸  2 在对岸 3 在船上
function CrossingRiverLayer:initRoleInfo(roleType,peopleState)
	if not roleType or not peopleState  then 
		print("检查下参数")
		return 
	end
	
	local roleName="官兵"
	local roleDes="他是官兵，他手持长枪，一脸正气，看上去刚正不阿。"
	local roleStateStr="河岸"
	if roleType == 2 then 
		roleName="囚犯"
		roleDes="他是囚犯，手上被长长的铁链锁住，看起来孔武有力。"
	end
	if peopleState == 2 then 
		roleStateStr="对岸"
	elseif peopleState == 3 then 
		if self.boatState == 1 then 
			roleStateStr="河岸"
		else
			roleStateStr="对岸"
		end
	end
	 
	self.Panel_roleBG.Text_roleName:setString(roleName)
	self.Panel_roleBG.Text_des:setString(roleDes)
	self.Panel_roleBG.Text_roleState:setString("他此时位于"..roleStateStr)
	if peopleState~=3 then 
		self.Panel_roleBG.Button_boat.Text_boatType:setString("上船")
	elseif peopleState==3 then 
		self.Panel_roleBG.Button_boat.Text_boatType:setString("下船")
	end
	self.Panel_roleBG:releaseFunc(function ()
		self.Panel_roleBG:setVisible(false)
	end)
	self.Panel_roleBG.Button_boat:releaseFunc(function ()
		self:boatButtonFunc(roleType,peopleState)
		self.Panel_roleBG:setVisible(false)
	end)
end
--每次渡河结果
function CrossingRiverLayer:crossingRiverResult()
	print("self.fisrtRiverBank_prisonerNum:",self.fisrtRiverBank_prisonerNum,"self.fisrtRiverBank_soldierNum:",self.fisrtRiverBank_soldierNum)
	print("self.otherRiverBank_prisonerNum:",self.otherRiverBank_prisonerNum,"self.otherRiverBank_soldierNum:",self.otherRiverBank_soldierNum)
	if self.fisrtRiverBank_prisonerNum>self.fisrtRiverBank_soldierNum and self.fisrtRiverBank_soldierNum >0 then 
		return false,"河岸"
	end
	if self.otherRiverBank_prisonerNum>self.otherRiverBank_soldierNum and self.otherRiverBank_soldierNum >0 then 
		return false,"对岸"
	end
	return true
end
--渡河按钮
function CrossingRiverLayer:crossingRiverButtonFunc()
	if sideRoleNum[3][1]+sideRoleNum[3][2]<1 then 
		PopText("必须有一人划船方能渡河。")
		return 
	elseif sideRoleNum[3][1]+sideRoleNum[3][2]>2 then 
		PopText("船上仅可乘坐两人。")
		return
	end
	if self.boatState==1 then  --1 河岸  2 对岸 
		self.fisrtRiverBank_prisonerNum=self.fisrtRiverBank_prisonerNum-sideRoleNum[3][2]
		self.fisrtRiverBank_soldierNum=self.fisrtRiverBank_soldierNum-sideRoleNum[3][1]
		self.otherRiverBank_prisonerNum=self.otherRiverBank_prisonerNum+sideRoleNum[3][2]
		self.otherRiverBank_soldierNum=self.otherRiverBank_soldierNum+sideRoleNum[3][1]
	else
		self.otherRiverBank_prisonerNum=self.otherRiverBank_prisonerNum-sideRoleNum[3][2]
		self.otherRiverBank_soldierNum=self.otherRiverBank_soldierNum-sideRoleNum[3][1]
		self.fisrtRiverBank_prisonerNum=self.fisrtRiverBank_prisonerNum+sideRoleNum[3][2]
		self.fisrtRiverBank_soldierNum=self.fisrtRiverBank_soldierNum+sideRoleNum[3][1]
	end
	local theResult,strResult=self:crossingRiverResult()
	if theResult then 
		--默认自动下船
		if self.boatState==1 then 
			self.boatState=2 
		elseif self.boatState==2 then
			self.boatState=1
		end
		-- sideRoleNum[self.boatState][1]=sideRoleNum[3][1]+sideRoleNum[self.boatState][1]
		-- sideRoleNum[self.boatState][2]=sideRoleNum[3][2]+sideRoleNum[self.boatState][2]
		-- sideRoleNum[3][1]=0
		-- sideRoleNum[3][2]=0
		if self.boatState==2 then 
			PopText("船划过河流，抵达至了对岸。")
			self.Image_bg3.Text_boatState:setString("船靠于对岸")
		else
			PopText("船划过河流，抵达至了河岸。")
			self.Image_bg3.Text_boatState:setString("船靠于河岸")
		end
	else  --失败
		PopText("渡河失败")
		self.Panel_result:setVisible(true)
		self.Panel_result.Panel_bg.Text_title:setString("渡河失败")
		self.Panel_result.Panel_bg.Text_des:setString(strResult.."囚犯数量大于官兵，囚犯合伙杀死了官兵。")
		self.Panel_result.Panel_bg.Button_close:releaseFunc(function()
			self.failFunc()
			self:hideLayer()
		end)
	end
	self:refreshOneRiverBankButton()
	self:refreshOtherRiverBankButton()
	self:refreshBoatButton()
end

function CrossingRiverLayer:refreshOneRiverBankButton()  --1
	--220  550  880 200 100 
	if #self.Image_bg.ListView_oneRiverBank:getItems()>0 then 
		self.Image_bg.ListView_oneRiverBank:removeAllItems() 
	end
	
	local soldierNum=sideRoleNum[1][1]
	local prisonerNum=sideRoleNum[1][2]
	
	for i=1,soldierNum do 
		local panel=self.Image_role:clone()
		Helper:convertUIByParent(panel)
		panel.Text_name:setString("官兵")
		self.Image_bg.ListView_oneRiverBank:pushBackCustomItem(panel)
		panel:releaseFunc(function ()
			self.Panel_roleBG:setVisible(true)
			self:initRoleInfo(1,1)
		end)
	end
	for i=1,prisonerNum do 
		local panel=self.Image_role:clone()
		Helper:convertUIByParent(panel)
		panel.Text_name:setString("囚犯")
		self.Image_bg.ListView_oneRiverBank:pushBackCustomItem(panel)
		panel:releaseFunc(function ()
			self.Panel_roleBG:setVisible(true)
			self:initRoleInfo(2,1)
		end)
	end
	self.Image_bg.ListView_oneRiverBank:jumpToTop()
end

function CrossingRiverLayer:refreshOtherRiverBankButton()
	if #self.Image_bg2.ListView_otherRiverBank:getItems()>0 then 
		self.Image_bg2.ListView_otherRiverBank:removeAllItems() 
	end

	local panel_bg=self.Panel_otherRiverBankPeople:clone()
	self.Image_bg2.ListView_otherRiverBank:pushBackCustomItem(panel_bg)
	
	local soldierNum=sideRoleNum[2][1]  
	local prisonerNum=sideRoleNum[2][2]
	local peopleNum=0
	for i=1,soldierNum do 
		local panel=self.Image_role:clone()
		Helper:convertUIByParent(panel)
		panel.Text_name:setString("官兵")
		panel_bg:addChild(panel)
		panel:setPosition(190+(peopleNum%3)*330,200-100*(math.floor(peopleNum/3)))
		peopleNum=peopleNum+1
		panel:releaseFunc(function ()
			self.Panel_roleBG:setVisible(true)
			self:initRoleInfo(1,2)
		end)
		
	end

	for i=1,prisonerNum do 
		local panel=self.Image_role:clone()
		Helper:convertUIByParent(panel)
		panel.Text_name:setString("囚犯")
		panel_bg:addChild(panel)
		panel:setPosition(190+(peopleNum%3)*330,200-100*(math.floor(peopleNum/3)))
		peopleNum=peopleNum+1
		panel:releaseFunc(function ()
			self.Panel_roleBG:setVisible(true)
			self:initRoleInfo(2,2)
		end)
	end
	self.Image_bg2.ListView_otherRiverBank:jumpToTop()
end

function CrossingRiverLayer:refreshBoatButton()
	if #self.Image_bg3.ListView_boat:getItems()>0 then 
		self.Image_bg3.ListView_boat:removeAllItems() 
	end
	--self.Image_bg3.ListView_boat:jumpToTop()
	local soldierNum=sideRoleNum[3][1]
	local prisonerNum=sideRoleNum[3][2]
	for i=1,soldierNum do 
		local panel=self.Image_role:clone()
		Helper:convertUIByParent(panel)
		panel.Text_name:setString("官兵")
		self.Image_bg3.ListView_boat:pushBackCustomItem(panel)
		panel:releaseFunc(function ()
			self.Panel_roleBG:setVisible(true)
			self:initRoleInfo(1,3)
		end)
	end
	
	for i=1,prisonerNum do 
		local panel=self.Image_role:clone()
		Helper:convertUIByParent(panel)
		panel.Text_name:setString("囚犯")
		self.Image_bg3.ListView_boat:pushBackCustomItem(panel)
		panel:releaseFunc(function ()
			self.Panel_roleBG:setVisible(true)
			self:initRoleInfo(2,3)
		end)
	end
	self.Image_bg3.ListView_boat:jumpToTop()
end

function CrossingRiverLayer:boatButtonFunc(roleType,peopleState)
	if not roleType or not peopleState then 
		print("检查下参数")
		return 
	end
	if sideRoleNum[3][1]+sideRoleNum[3][2]>=2 and peopleState~=3 then 
		PopText("船上仅可乘坐两人。")
		return
	end
	print("self.boatState:",self.boatState,"peopleState:",peopleState,"roleType:",roleType)
	if peopleState~=3 and peopleState~=self.boatState then 
		if self.boatState==2 then 
			PopText("船现在停靠在对岸，河岸的人无法上船。")
		else
			PopText("船现在停靠在河岸，对岸的人无法上船。")
		end
		return 
	elseif peopleState~=3 then 
		sideRoleNum[3][roleType]=sideRoleNum[3][roleType]+1
		sideRoleNum[self.boatState][roleType]=sideRoleNum[self.boatState][roleType]-1
	elseif peopleState==3 then
		if sideRoleNum[3][roleType]>0 then 
			sideRoleNum[3][roleType]=sideRoleNum[3][roleType]-1
			sideRoleNum[self.boatState][roleType]=sideRoleNum[self.boatState][roleType]+1
		end
	end

	if self.otherRiverBank_prisonerNum+self.otherRiverBank_soldierNum==6 and sideRoleNum[3][1]+sideRoleNum[3][2]==0 then 
		PopText("渡河成功")
		self.Panel_result:setVisible(true)
		self.Panel_result.Panel_bg.Text_title:setString("渡河成功")
		self.Panel_result.Panel_bg.Text_des:setString("兵囚六人顺利抵达对岸，渡河成功。")
		self.Panel_result.Panel_bg.Button_close:releaseFunc(function()
			self.successFunc()
			self:hideLayer()
		end)
	end

	self:refreshOneRiverBankButton()
	self:refreshBoatButton()
	self:refreshOtherRiverBankButton()
end

function CrossingRiverLayer:showLayer(successFunc,failFunc)
	self.successFunc=successFunc or EMPTY_FUNC
	self.failFunc=failFunc or EMPTY_FUNC
	self:setVisible(true)
	self:initData()
	self:initUI()
end

function CrossingRiverLayer:hideLayer()
	sideRoleNum={     --记录button数量
	[1]={[1]=3,[2]=3}, --河岸 1--"soldier"  2--"prisoner"
	[2]={[1]=0,[2]=0}, --对岸
	[3]={[1]=0,[2]=0}, --船上
	}
	PopupLayerController:hideLayer("CrossingRiverLayer",function (layer)
     	self:setVisible(false)
    end)
end

Helper:classDefNodeGetInstance(CrossingRiverLayer)
return CrossingRiverLayer0000000000000
--雇佣详情界面

local EmployDscLayer = class("EmployDscLayer", LayerEx)
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
function EmployDscLayer:create()
	local p = EmployDscLayer:new()
	p:init()
	return p
end

function EmployDscLayer:init()
	local UI = require("Layer/HomelandUI/EmployDscUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self:setBackButton()
	
end

--设置返回
function EmployDscLayer:setBackButton()
    self.Panel_back:releaseFunc(function()
		self:hide()
	end)
end

-- function EmployDscLayer:setSuccessCallback( s_callback )
-- 	if type(s_callback) ~= "function" then
-- 		return
-- 	end

-- 	self._successCallback = s_callback
-- end

-- function EmployDscLayer:setFailCallback( f_callback )
-- 	if type(f_callback) ~= "function" then
-- 		return
-- 	end

-- 	self._failCallback = f_callback
-- end


function EmployDscLayer:hideLayer()
	PopupLayerController:hideLayer("EmployDscLayer",function (layer)
		-- if self._successCallback then
		-- 	self._successCallback = nil
		-- end

		-- if self._failCallback then
		-- 	self._failCallback = nil
		-- end

		layer:hide()
	end)
end


function EmployDscLayer:setButtonFunc(func)
	self.Button_Employ:releaseFunc(function ()
		func()
	end)
end

function EmployDscLayer:showLayer(data)
	-- self:setEmployButton(data,hidId,npcId)
	self:initRichTextPreview()
    self:initData(data)
	self:setXiangXiButton()
	self:show()
end

--初始化数据
function EmployDscLayer:initData(data)
	-- Helper:print_lua_table(data)
	
    self.Text_name:setString(data.name)

	local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
	local role
	local roleAttr = {}
	if data.job then
        data.jobType = data.job
    end 
    local roleAttr = table.mergeMap(data, HomelandRoleUtil:getMobanRoleAttr(data.modal))
    local role = clone(roleAttr)
    role.canSee = true
    role.type = "role"
    role.id = role.rwId
    role.dsc = HomelandRoleUtil:createRoleDsc(role)
    role.cType = HomelandRoleUtil:getCHAJobTypeName(role.jobType)
    HomelandRoleUtil:initMapRoleNameByJobtypeAndZcLv(role)

	-- Npc:initRoleWithRandomAttr(role)
    -- Map:initNpcEquipsAndItems(role)
	-- Map:initNpcActiveZhao(role)
	Npc:initNpc(role)

    role = Helper:tableCover(Role:create(), role)
    role:updateRoleBuff()
    HomelandRoleUtil:initSkillLv(role)
   
	local roleDetailsStr = HomelandDesc:getRoleDcs(role)
	self.RichText_Print:pushBackText(roleDetailsStr, cc.c3b(208,208,208), 255, Resource:getFontPath("default"), 42)

	--npc的血量和内力回满
	role.qi = role:getCurrQiMax()
	role.neili = role:getFinalAttr("neiliMax")
	
	self._role = role
end

function EmployDscLayer:setXiangXiButton()
	local role = self._role
	self.Button_DecorativeBox:releaseFunc(function()
		PopupLayerController:showLayer("HomelandRoleInfoLayer", function(layer)
			layer:setMiaoShuCallback(function ()
				self:show()
			end)
			
			layer:showLayer(role)
		end)
		
		self:hide()
	end)
end

function EmployDscLayer:initRichTextPreview()
	local x, y = self.Text_desc:getPosition()
	local size = self.Text_desc:getContentSize()
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Text_desc:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Text_desc:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
   	self.RichText_Print:setTouchEnabled(false)
end


Helper:classDefNodeGetInstance(EmployDscLayer)
return EmployDscLayer00000000000
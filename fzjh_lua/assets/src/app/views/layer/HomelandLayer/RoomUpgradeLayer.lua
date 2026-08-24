--房屋升级界面
local RoomUpgradeLayer = class("RoomUpgradeLayer", LayerEx)
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
local RoomUpgradeModel = require("app.models.HomelandModel.RoomModel.RoomUpgradeModel")
function RoomUpgradeLayer:create()
	local p = RoomUpgradeLayer:new()
	p:init()
	return p
end

function RoomUpgradeLayer:init()
	local UI = require("Layer/HomelandUI/RoomUpgradeUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self:setBackButton()
    
end

function RoomUpgradeLayer:showLayer(lastData,data,layer)
	self:show()
    -- Helper:print_lua_table(data)
	self:initFurnitureLimitPanel(lastData)
    self:initData(lastData,data)
	self:setUpgradeButton(lastData,data,layer)
	self:getYinPiao()
end

--初始化数据显示
function RoomUpgradeLayer:initData(lastData,data)
	self.Panel_5.Text_lastdsc:setTextColor({r = 208, g = 208, b = 208})
	self.Panel_6.Text_lastdsc:setTextColor({r = 208, g = 208, b = 208})
	self.Panel_5.Text_currdsc:setTextColor({r = 175, g = 145, b = 25})
    self.Panel_6.Text_currdsc:setTextColor({r = 175, g = 145, b = 25})
    self.Panel_2.Text_lastname:setString(lastData.name)
    self.Panel_2.Text_currname:setString(data.name)
    self.Panel_3.Text_lastlimt:setString(lastData.furniturelimit)
    self.Panel_3.Text_currlimt:setString(data.furniturelimit)
	self.Panel_5.Text_lastdsc:setString(lastData.roomdsc)
    self.Panel_5.Text_currdsc:setString(data.roomdsc)
    self.Panel_6.Text_lastdsc:setString(lastData.fundsc)
	self.Panel_6.Text_currdsc:setString(data.fundsc)
	self.Text_money:setString("花费"..data.upgradecost.."银票")
end

function RoomUpgradeLayer:setBackButton()
    self.Button_leave:releaseFunc(function()
		self:hide()
	end)
end

function RoomUpgradeLayer:setUpgradeButton(lastData,attr,layer)
	if MapIsEmpty(attr) then
		return 
	end
	local point = attr.upgradecost
	
	local currMap = User:getRole():getCurrMap()
	if MapIsEmpty(currMap) then
		return 
	end

	local mid = currMap.mid
	local fjId = currMap:getCurrRoomId()
    self.Button_upgrad:releaseFunc(function()
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
			local dialog = DialogALayer:getInstance()
			dialog:show("你确定要改造吗？")
			dialog:setWeChatVisible(false)
			dialog:setButton1("确定", function()
				Helper:print_lua_table(attr)

				RoomUpgradeModel:upgradeRoom(currMap,attr,lastData,function(data)
					self:hide()
					layer:hide()
				end)
			end)
			dialog:setButton2("取消", function()
				dialog:hide()
			end)
	end)

end

--获取当前银票数量
function RoomUpgradeLayer:getYinPiao()
	HttpManagerEx:viewCurrencyByType("yinpiao", User:getRole():getCurrencyVersion(),function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                self._currYinPiao = data.number
                self.Text_yinpiao:setString("『银票』"..self._currYinPiao)
            else
               PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

--初始化UI家具上限栏
function RoomUpgradeLayer:initFurnitureLimitPanel(lastData)
	if HomelandRoomUtil:roomIsSpecial(lastData.roomid) then
		self.Panel_3:setVisible(true)
	else
		self.Panel_3:setVisible(false)
	end
end

Helper:classDefNodeGetInstance(RoomUpgradeLayer)
return RoomUpgradeLayer00000000
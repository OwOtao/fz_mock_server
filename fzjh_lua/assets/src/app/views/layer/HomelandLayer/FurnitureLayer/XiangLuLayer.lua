--
-- Author: TanQinJian
-- Date: 2020-03-21 15:20:42
--
local XiangLuModel = require("app.models.HomelandModel.XiangLuModel")
local XiangLuLayer = class("XiangLuLayer", LayerEx)

function XiangLuLayer:create()
	local p = XiangLuLayer:new()
	p:init()
	return p
end

function XiangLuLayer:init()
	self._UI = require("Layer/HomelandUI/XiangLuUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
    self:setBackButton()
end

function XiangLuLayer:showLayer(xiangLu)
	self.currXiangLu = xiangLu
	self.currXiangInfo = XiangLuModel:getXiangInfoInXiangLu(xiangLu)

	self:initShowUI()
	if XiangLuModel:checkFireXiangIsNormal(XiangLuModel:getFireXiangType(xiangLu)) then
		self._handle = self:schedule(function (ft)
			self:refreshUI(ft)
		end)
	end
	self:show()
end

function XiangLuLayer:hideLayer()
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end
	self.startTime = nil
	self.currXiangInfo = nil
	self:hide()
end

function XiangLuLayer:refreshXiangList()
	self.ListView_xiang:removeAllItems()
	local roleXiangData = XiangLuModel:getRoleBagXiang()

	if MapIsEmpty(roleXiangData) == false then
		for xiangId,xiangNum in pairs(roleXiangData) do
			local panel = self.Panel_item:clone()
			Helper:convertUIByParent(panel)
			local xiangAttr = Item:getOneItemByKey(xiangId)
			panel.Image_nameBg.Text_name:setString(xiangAttr.name)
			panel.Text_num:setString(xiangNum)
			self.ListView_xiang:pushBackCustomItem(panel)
			panel.Panel_btn.Text_btnName:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
			panel.Panel_btn:releaseFunc(function ()
				if XiangLuModel:isCanFire(self.currXiangLu.jjId,xiangId) then
					local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
					local dialog = DialogALayer:getInstance()
					dialog:hide()
					local firXiang = XiangLuModel:getXiangInfo(xiangId)
			        dialog:show(xiangAttr.name.."入梦概率"..tostring(firXiang.drgl).."%，确定点燃"..xiangAttr.name.."么？","RED目前正在燃烧"..self.currXiangInfo.name)
			        dialog:setButton1("确定", function()
			          	XiangLuModel:fireXiang(self.currXiangLu.fid,xiangId,function(xiangLu)
			          		User:getRole():addItemCount(xiangId, -1)
							self.currXiangLu = xiangLu
							self.currXiangInfo = XiangLuModel:getXiangInfoInXiangLu(xiangLu)
			          		self:initShowUI()
			          		if not self._handle then
				          		self._handle = self:schedule(function (ft)
									self:refreshUI(ft)
								end)
				          	end
			          	end)
			        end)
			        dialog:setButton2("取消", function()
			        end)
			        dialog:setWeChatVisible(false)
			    else
			    	PopText("该香炉不支持这类型香")
			    end
			end)
		end
	end

end

function XiangLuLayer:initShowUI()
	local xiangType = XiangLuModel:getFireXiangType(self.currXiangLu)
	if XiangLuModel:checkFireXiangIsNormal(xiangType) == false then
		self.Text_desc2:setString("")
		self.Text_desc3:setString("")
	end
	self.Text_desc1:setString(self.currXiangInfo.rxtext)
	self.Text_name:setString("【"..self.currXiangLu.name.."】")

	self:refreshXiangList()
end

function XiangLuLayer:setBackButton()
	self.Panel_back:releaseFunc(function ()
		PopupLayerController:hideLayer("XiangLuLayer", function(layer)
			self:hideLayer()
		end, 0)
	end)
end

-- 刷新UI
function XiangLuLayer:refreshUI(dt)
	local time = self.currXiangInfo.startTime + self.currXiangInfo.rxtime - GetTime()
	local text_desc2,text_desc3 = "",""
	if time > 0 then
		local year, month, day, hour, minute, second = Helper:getExpiredTime(time, 0)
		text_desc3 = hour .. "小时" .. minute .. "分" .. second .. "秒"
		text_desc2 = "距"..self.currXiangInfo.name.."熄灭还有："
	else
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end
		XiangLuModel:updateXiangLuState(self.currXiangLu,function(xiangLu)
			self.currXiangLu = xiangLu
			self.currXiangInfo = XiangLuModel:getXiangInfoInXiangLu(xiangLu)
			self:initShowUI()
		end)
	end
	self.Text_desc3:setString(text_desc3)
	self.Text_desc2:setString(text_desc2)
end

Helper:classDefNodeGetInstance(XiangLuLayer)
return XiangLuLayer00000
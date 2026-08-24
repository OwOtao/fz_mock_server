-- 香薰炉
local MerdianAromaBurnerLayer = class("MerdianAromaBurnerLayer", LayerEx)

local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Role = require("app.models.role.Role")

local Meridian = require("app.models.Meridian.Meridian")

function MerdianAromaBurnerLayer:create()
	local p = MerdianAromaBurnerLayer:new()
	p:init()
	return p
end

function MerdianAromaBurnerLayer:init()
	self._UI = require("Layer/MeridianUI/MerdianAromaBurnerUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setButton()
end

-- 显示界面
function MerdianAromaBurnerLayer:showLayer(parentsLayer)
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self.parentsLayer = parentsLayer

	self._handle = self:schedule(function (ft)
		self:refreshUI(ft)
	end,1/30)

	self:show()
	self:refreshUI()
end

function MerdianAromaBurnerLayer:setButton()
	-- 关闭
	self.Button2:releaseFunc(function()
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end
		PopupLayerController:hideLayer("MerdianAromaBurnerLayer", function(layer)
			self:hide()
		end, 0)
	end)

	-- 添香
	self.Button1:releaseFunc(function()
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show("消耗一个特制檀香进行添香(效果持续12小时，重复使用不叠加)")
		dialog:setButton1("确定", function()
			local role = User:getRole()
			if role:getItemCount("jingmai100") > 0 then
				role:addItemCount("jingmai100", - 1)
				role:setTimeLimitFlag("真气加成", 1, 3600 * 12)
				PopText("消耗特制檀香")
				-- PopText("特制檀香在香薰炉中点燃了，好闻的味道渐渐弥漫开来，让人心旷神怡。")
				if self.parentsLayer ~= nil then
					self.parentsLayer:print("HIC特制檀香在香薰炉中点燃了，好闻的味道渐渐弥漫开来，让人心旷神怡。")
				else
					local currLayer = MainControllLayer:getCurrLayer()
					if currLayer == "MapLayer" then
						RichPrint("main","HIC特制檀香在香薰炉中点燃了，好闻的味道渐渐弥漫开来，让人心旷神怡。")
					end
				end
				-- 使用香薰炉统计
				local Record = require("app.models.Record.Record")
				Record:addRecordCount("jingmai", "useItem", "jingmai100")
			else
				PopText("道具数量不足")
			end
		end)

		dialog:setButton2("取消", function()
			dialog:hide()
		end)
	end)
end

-- 刷新UI
function MerdianAromaBurnerLayer:refreshUI(dt)
	local role = User:getRole()
	local time = role:getTimeLimitFlagTime("真气加成")

	if time > 0 then
		self.Image_back.Text_desc1:setString("香薰炉正在燃烧，空气中萦绕着一股特殊的香氛，让调息事半功倍。")
		self.Image_back.Text_desc2:setString("距离香薰炉熄灭还有：")
		local year, month, day, hour, minute, second = Helper:getExpiredTime(time, 0)
		self.Image_back.Text_desc3:setString( hour .. "小时" .. minute .. "分" .. second .. "秒")
	else
		self.Image_back.Text_desc1:setString("香薰炉用于点燃特制的檀香，用于辅助调息。")
		self.Image_back.Text_desc2:setString("香薰炉现在是冷的，没有点燃。")
		self.Image_back.Text_desc3:setString("")
	end
end

Helper:classDefNodeGetInstance(MerdianAromaBurnerLayer)

return MerdianAromaBurnerLayer0
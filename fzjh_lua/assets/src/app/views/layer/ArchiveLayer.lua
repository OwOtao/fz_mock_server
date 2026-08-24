local ArchiveLayer = class("ArchiveLayer", cc.Layer)
local BiWu = require("app.models.BiWu.BiWu")

-- 下载存档
function ArchiveLayer:create()
	local p = ArchiveLayer:new()
	p:init()
	return p
end

function ArchiveLayer:init()
	local LoadingUI = require("Layer/ArchiveUI.lua").create()['root']
	LoadingUI:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点
	self.mailAddr = ""
	self.Panel_info:setVisible(false)
	self:setPanelBack()
	self:lookArchuveInfo()
end

--list, isBuy, yuanbao
function ArchiveLayer:show(mailAddr)
	if mailAddr == nil or  mailAddr =="" then 
		mailAddr = "未绑定"
	end
	self.mailAddr = mailAddr
	self:getArchiveList()
	self:initArchuveInfo()
end

-- 获取存档列表
function ArchiveLayer:getArchiveList()
	local yuanbao = 300
	HttpManagerEx:getArchiveList(function(status, errcode, errmsg, data)
		if 200 == status then
			if errcode == 0 then
				self:setListView(data, true)
				self:setVisible(true)
			elseif errcode == 1 then
				if data.yuanbao then
					yuanbao = data.yuanbao
				end
				self:setListView(data, false, yuanbao)
				self:setVisible(true)
			else
				if errmsg ~= nil then
					PopText(tostring(errmsg))
				else
					PopText("- - - - - -")
				end
			end
		else
			PopText("网络请求失败，请检查网络状况再尝试")
		end
	end, IS_SHOW_WAITING)
end

-- 设置存档位列表
function ArchiveLayer:setListView(list, isBuy, yuanbao)
	if MapIsEmpty(list) then
		return
	end
	self.ListView_list:removeAllItems()
	if isBuy == true then
		self:setListIsBuy(list)
	else
		self:setListIsNotBuy(list, yuanbao)
	end
	-- add by XiaoZhiWei 2018/01/13 15:16:29 出现渲染异常的情况, 暂时跳至顶部处理异常
	self.ListView_list:jumpToTop()
end

-- 已购列表
function ArchiveLayer:setListIsBuy(list)
	for k,params in pairs(list) do
		local row
		if params.userid == nil then
			row = self:createPanelItem2("-- -- --", nil,  params)
		else
			row = self:createOneArchiveItem(params)
		end
		if row ~= nil then
			self.ListView_list:pushBackCustomItem(row)
		end
	end
end

-- 未购列表
function ArchiveLayer:setListIsNotBuy(list, yuanbao)
	local row =	self:createOneArchiveItem(list)
	if row ~= nil then
		self.ListView_list:pushBackCustomItem(row)
	end

	local row2 = self:createPanelItem2("未启用", "将花费 "..tostring(yuanbao).." 元宝", {index = 2, yuanbao = yuanbao})
	if row2 then
		self.ListView_list:pushBackCustomItem(row2)
	end
end

-- 切换存档
function ArchiveLayer:changeArchive(switchTo, userid)
	if switchTo == nil then
		return
	end

	HttpManagerEx:switchArchive(switchTo, function(status, errcode, errmsg, data)
		if 200 == status then
			User:reset()
			if 0 == errcode  then
				-- 友盟统计 登出
				Mob.profileSignOff()

				Game:restart(
					function()
						cc.Director:getInstance():getRunningScene():delayFunc(0.5, function()
								PopText("切换成功")
							end)
					end)
				-------切换存档后，论剑界面的相应处理（初始化输出框）
				BiWu:setChangFIleIsTrue()
			else
				Game:restart(
					function()
						cc.Director:getInstance():getRunningScene():delayFunc(0.5, function()
								PopText("切换失败")
							end)
					end)
			end
			return true
		else
			PopText("切换失败，请检查网络环境")
		end
	end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-- 创建一个存档位栏目
function ArchiveLayer:createOneArchiveItem(params)
	if MapIsEmpty(params) then
		return
	end
	local panel = self.Panel_item:clone()
	Helper:convertUI(panel)
	panel:setVisible(true)

	local headUI = require("app.views.ui.HeadView.HeadView"):create()
	panel:addChild(headUI)
	headUI:setPosition(cc.p(self.Node_HeadPos:getPosition()))
	headUI:setScaleX(0.9)
	headUI:setScaleY(0.9)
	
	local headpresenter = require("app.presenters.HeadView.HeadDataHeadViewPresenter"):create(params,headUI)
	headpresenter:showTheHead()
	headpresenter:setClickEnable(false)
	
	panel.Text_name:setString(params.name)
	panel.Text_menpai:setString(params.menpai)
	panel.Text_exp:setString(math.floor(params.exp))
	panel.Text_year:setString(params.year)
	panel.Text_time:setString(params.time)

	panel:releaseFunc(function()
		if PRINT_MODE == 1 then
			print("params.userid = "..tostring(params.userid))
			print("userid = "..tostring(User:getRoleAttr("userid")))
			print(params.userid == User:getRoleAttr("userid"))
		end
		if tostring(params.userid) == tostring(User:getRoleAttr("userid")) then
			PopText("该档案正在使用")
			return
		end
		self:changeArchive(params.index, params.userid)
	end)

	if tostring(params.userid) == tostring(User:getRoleAttr("userid")) then
		panel.Image_kuang:setColor(cc.c3b(51,153,51))
	end

	return panel
end

-- 创建一个栏目（空或者未购买时使用）
function ArchiveLayer:createPanelItem2(str1, str2, params)
	if str1 == nil or MapIsEmpty(params) then
		return
	end
	local panel = self.Panel_item2:clone()
	Helper:convertUI(panel)

	panel.Text_title2:setString(str1)
	if str2 == nil then
		panel.Text_desc2:setString("")
		panel:releaseFunc(function()
			self:changeArchive(params.index, params.userid)
		end)
	else
		panel.Text_desc2:setString(str2)
		panel:releaseFunc(function()
			-- self:changeArchive(params.index, params.userid)
			self:buyOneArchiveItem(params)
		end)
	end
	return panel
end

-- 购买一个存档栏目
function ArchiveLayer:buyOneArchiveItem(params)
	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
	local dialog = DialogALayer:getInstance()
	dialog:show("是否确定购买存档位？", "将花费 "..tostring(params.yuanbao).." 元宝")
	dialog:setButton1("确定", function()
		PopYuanBaoBuyItemLayer("cundangwei", function(eventType)
			if eventType == "success" then
				self:getArchiveList()
			end
		end)
	end)
	dialog:setButton2("取消")
end

-- 点击背景隐藏
function ArchiveLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("ArchiveLayer", function(layer)
			self:hide()
		end)
		
	end)
end

function ArchiveLayer:lookArchuveInfo()
	self.Text_capture:setString("确定")
	self.Text_infoDesc:setString("为防止您遗忘存档信息，建议您将此页面手动截图保存，并妥善保管。")
	self.Button_info:releaseFunc(function()
		self.Panel_info:setVisible(true)
	end)
	self.Panel_info:releaseFunc(function()
		self.Panel_info:setVisible(false)
	end)
	self.Button_capture:releaseFunc(function()
		self.Panel_info:setVisible(false)
	end)
end

function ArchiveLayer:initArchuveInfo()
	local role = User:getRole()
	if string.len(self.mailAddr)>30 then 
		local str1 = string.sub(self.mailAddr,1,30)
		local str2 = string.sub(self.mailAddr,31)
		self.mailAddr = str1.."\n"..str2
	end

	self.Text_emailDesc:setString("绑定邮箱："..self.mailAddr)
	self.Text_nameDesc:setString("游戏角色ID："..role.userid)
	self.Text_idDesc:setString("游戏角色名称："..role.name)
end


Helper:classDefNodeGetInstance(ArchiveLayer)
return ArchiveLayer
00000000
local User = require("app.models.user.User")
local Resource = require("app.Resource")
local FamilyPrestige=require("app.models.family.FamilyPrestige")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local BorderConfigManager = require("app.models.HeadViewSystem.BorderConfigManager")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

local TitleLayer = class("TitleLayer", LayerEx)

function TitleLayer:create()
	local p = TitleLayer:new()
	p:init()
	return p
end

function TitleLayer:init()
	local UI = require("Layer/AttrUI/TitleUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	local basicTitleGroup = self:__getBasicTitleGroup()

    for i, v in ipairs(basicTitleGroup) do
        local ui_Node_flod_state = "newTitleUI_" .. i .. "_flod"
        self[ui_Node_flod_state] = false
    end
	self._changeTitleCallback = nil
end

function TitleLayer:showLayer()
	local role = User:getRole()
	role:updateRoleTitle()

	self:setBack()
	self:setCelebrity()
	self:initTitleListItem()
	self:setButton()
	self:show()
end

function TitleLayer:setButton()
	--会员按钮
	self.Button_celebrity:releaseFunc(function()
		local role = User:getRole()
		if role:yueKaIsValid() == false then
			if device.platform == "android" then
				-----------------------------------------------------------------------------------------------------------
				-- @author XiaoZhiWei
				-- @time 2017/02/21 09:45:42
				-- @desc  判断是否绑定邮箱
				Account:getEmail(
				function(eventName, errmsg, email, isBind, isLogout)
					if eventName == "有邮箱" then
						-- isBind 为true的时候 才是已绑定邮箱
						if isBind == true then
							--不是会员时显示购买界面
							PopupLayerController:showLayer("YueKaLayer", function(layer)
								layer:show()
							end)
							self:hide()
							return
						else
						end
					elseif eventName == "找不到帐号" then
					elseif eventName == "无邮箱" then
					else
					end
					PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
				end)
			elseif device.platform == "ios" then
				--不是会员时显示购买界面
				PopupLayerController:showLayer("YueKaLayer", function(layer)
					layer:show()
				end)
				self:hide()
			else
			end
		else
			local titleId = RoleTitleConst.SpecialBasicTitleId.YueKa
			local title = role:getBasicTitle(titleId)
			self._changeTitleCallback = function()
				PopText("你换成了称号"..title:getColorName())
			end
			self:__showAffirmLayer(title)
		end
	end)
	

	local basicTitleGroup = self:__getBasicTitleGroup()
	for i = 1, #basicTitleGroup, 1 do
		local ui_Node = "newTitleUI_"..i
		local ui_Node_flod = "newTitleUI_"..i.."_flod" 
		self[ui_Node].Image_title_bg_1:setTouchEnabled(true)
		self[ui_Node].Image_title_bg_1:releaseFunc(function()
			self[ui_Node_flod] = not self[ui_Node_flod]
			if self[ui_Node_flod] then
				self[ui_Node].Image_flod:loadTexture(Resource:getImgPath("title_flod"))
			else
				self[ui_Node].Image_flod:loadTexture(Resource:getImgPath("title_unflod"))
			end
			self:initTitleListItem()
			self:setButton()
		end)
	end 
end

--初始化滚动区列表
function TitleLayer:initTitleListItem()
    local role = User:getRole()

    self.ListView_titlelistArea:removeAllItems()

	--[[
		panelInfo = {
			isSelect = true, --是否为当前选择
			name = "门派称号",
			titleIdList = {}
		}
	]]
    local createBasicPanel = function(panelInfo, flod)
        local panel = self.Panel_title:clone()
        self:setTitleListItem(panel)
        panel.Text_title_name:setString(panelInfo.name)

        self.ListView_titlelistArea:pushBackCustomItem(panel)

        if not flod then
            local frame = self:__createBasicTitleFrame(panelInfo.titleIdList)
            if frame then
                self.ListView_titlelistArea:pushBackCustomItem(frame)
            end
            panel.Image_flod:loadTexture(Resource:getImgPath("title_unflod"))
        else
            panel.Image_flod:loadTexture(Resource:getImgPath("title_flod"))
        end

        --选择不同称号时隐藏显示控件
        panel.Text_title_use:setVisible(panelInfo.isSelect)
        panel.Button_title:setVisible(false)
        panel.Image_title_bg_2:setVisible(panelInfo.isSelect)
        panel.Image_title_bg_3:setVisible(panelInfo.isSelect)

        return panel
    end

	local basicTitleGroup = self:__getBasicTitleGroup()
	local useTitleType = self:__getUseTitleType()

    for i, v in ipairs(basicTitleGroup) do
        --@RefType [src.app.models.role.titleSystem.BasicTitleGroup#BasicTitleGroup]
        v = v
        local ui_Node = "newTitleUI_" .. i
        local ui_Node_flod = "newTitleUI_" .. i .. "_flod"

		local groupId = tonumber(v:getId())
		local groupName = v:getName()

		local panelInfo = {
			isSelect = groupId == useTitleType,
			name = groupName,
			titleIdList = v:getTitleIdList()
		}

		self[ui_Node] = createBasicPanel(panelInfo, self[ui_Node_flod])
    end
end

function TitleLayer:setTitleListItem(item)
    Helper:convertUIByParent(item)
    local color = {r = 26, g = 26, b = 26, a = 255}
    item.Text_title_name:enableOutline(color, 5)
    item.Text_title_data:enableOutline(color, 5)
    item.Text_title_use:enableOutline(color, 5)
    item.Button_title.Text_title_button_text:enableOutline(color, 5)
    item.Text_title_use:setVisible(false)
    item.Text_title_data:setVisible(false)
end

function TitleLayer:__getBasicTitleGroup()
    local list = {}

	local GroupMap = RoleTitleResManager:getBasicTitleGroupMap()

    for k, v in pairs(GroupMap) do
		local groupId = tonumber(v:getId())

		if groupId ~= RoleTitleConst.BasicTitleType.YueKa then --江湖名士有专门按钮
			table.insert(list, v)
		end
    end

    table.sort(
        list,
        function(a, b)
			return tonumber(a:getId()) < tonumber(b:getId())
        end
    )

	return list
end

function TitleLayer:__createBasicTitleFrame(idList)
	local titleList = {}
	local role = User:getRole()

    for i = 1, #idList, 1 do
		if role:hasBasicTitle(idList[i]) then
			local basicTitle = role:getBasicTitle(idList[i])
			table.insert(titleList, basicTitle)
		end
	end

	table.sort(titleList, function(a, b)
		return a:getNumber() < b:getNumber()
	end)

	if #titleList == 0 then
		return nil
	end

	local frame = self.title_frame:clone()
	--设置列表大小
	frame:setContentSize(frame:getContentSize().width, 80 * math.floor((#titleList - 1) / 3 + 1))
	
	local frame_size = frame:getContentSize()

	local useTitleId = self:__getUseTitleId()
	
	for i = 1, #titleList do
		local title = titleList[i]
		local text = self.Text_name:clone()
		text:addTo(frame)
		text:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
		text:setString(title:getColorName())
		text:setTouchEnabled(true)
		text:releaseFunc(function ()
			if useTitleId == title:getId() then
				return
			end

			self._changeTitleCallback = function()
				PopText("你换成了称号"..title:getColorName())
			end
			self:__showAffirmLayer(title)
		end)

		text:move(200 + ((i - 1) % 3 * 350 ), (frame_size.height - 40) - 70 * math.floor((i - 1) / 3) )
	end

	return frame
end

--@basicTitle: [src.app.models.role.titleSystem.BasicTitle#BasicTitle]
function TitleLayer:__showAffirmLayer(basicTitle)
    --@desc 有新框体需要更换时，弹出提示
    local role = User:getRole()

    local borderId = basicTitle:getBorderId()

    local currBorderId = role:getRoleViewBorderSys():getBorderId()

    if borderId and borderId ~= currBorderId then
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        local text = "佩戴此称号会改变当前主界面头像框，排行榜头像框，个人简介背景框，是否确认更换？"
        dialog:show(text)
        dialog:setButton1(
            "确定",
            function()
                self:__changeTitle(basicTitle)
            end
        )
        dialog:setButton2("取消")
        dialog:setWeChatVisible(false)
    else
        self:__changeTitle(basicTitle)
    end
end

--@desc:
--@author:Seven
--@time:2024-04-16 16:56:15
--@basicTitle: [src.app.models.role.titleSystem.BasicTitle#BasicTitle]
function TitleLayer:__changeTitle(basicTitle)
    local role = User:getRole()
    role:useBasicTitle(basicTitle:getId())

    self:setCelebrity()
    self:initTitleListItem()
    self:setButton()

    if self._changeTitleCallback then
        self._changeTitleCallback()
        self._changeTitleCallback = nil
    end
end

function TitleLayer:__getUseTitleType()
	local role = User:getRole()
	local title = role:getCurrBasicTitle()

	return title:getType()
end

function TitleLayer:__getUseTitleId()
	local role = User:getRole()
	local title = role:getCurrBasicTitle()
	
	return title:getId()
end

--设置会员称号
function TitleLayer:setCelebrity()
	local role = User:getRole()
	self.Text_celebrity_use:setVisible(false)
	self.Image_celebrity_bg_2:setVisible(false)
	self.Image_celebrity_bg_3:setVisible(false)
	self.Button_celebrity:setVisible(true)

	--是否拥有会员
	if role:yueKaIsValid() == true then
		self.Text_celebrity_data:setColor({r = 208, g = 208, b = 208, a = 255})
		self.Button_celebrity.Text_celebrity_button_text:setString("使用")
	elseif role:yueKaIsValid() == false then
		self.Text_celebrity_data:setColor({r = 127, g = 127, b = 127, a = 255})
		self.Button_celebrity.Text_celebrity_button_text:setString("未获取")
	end

	--是否在使用中
	local titleType = self:__getUseTitleType()
	if titleType == RoleTitleConst.BasicTitleType.YueKa then
		self.Text_celebrity_use:setVisible(true)
		self.Image_celebrity_bg_2:setVisible(true)
		self.Image_celebrity_bg_3:setVisible(true)
		self.Button_celebrity:setVisible(false)
	end
end

function TitleLayer:setBack()
	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
end


Helper:classDefNodeGetInstance(TitleLayer)

return TitleLayer0000000000000000
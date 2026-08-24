local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local DialogDLayer = require("app.views.layer.DialogLayer.DialogDLayer")
local DataBase = require("app.DataBase")
local AgreementLayer = require("app.views.layer.AgreementLayer")
local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local SetupUI = class("SetupUI", cc.Layer)

local Text_xiao = false

local IsShowMailBox = false

function SetupUI:create()
	local p = SetupUI:new()
	p:init()
	return p
end

function SetupUI:ctor()
	self.mailAddr = ""				--绑定邮箱地址
	self.isBind = false             --是否已经绑定了邮箱
	self.isLogout = false           --是否已经登出了设备
end

function SetupUI:init()
	self._round = require("Layer/SetupUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUI(self)

	self:setButton_Voice()
	self:setButton_back()

	self:setImage_weixin()
	self:setButton_Question()
	self:setButton_RestGame()
	self:setButton_MailBox()
	self:setButton_Help()

	self:setButtonChoise()
	self:setButtonProperty()
	self:setPropertyBack()
	-- add by XiaoZhiWei 2017/06/30 13:26:14 add with ios 1.0
	self:setButtonMianDaRao()
	self:setButtonGongGaoHistory()
	self:setButton_Save_Game()
	self:showSkin()

	self:refreshUI()
	-- self:setButton_Binding_mail()


	self:setVisible(true)

	self.mailAddr = ""				--绑定邮箱地址
	self.isBind = false             --是否已经绑定了邮箱
	self.isLogout = false           --是否已经登出了设备
	self.isShiMing=false 			--是否实名认证

	self.Text_QQ_Tile_Property:setString("官方客服：")
	self.Text_QQ_Tile:setString("官方客服：")
	self.Text_QQ:setString(Game:getKFQQ())
	self.Text_QQ_Property:setString(Game:getKFQQ())

	if Game:isOpenKFQQ() == true or Game:isCheckNewPackage() == NEED_CHECK_AND_IS_OPEN then
		self.Text_QQ_Tile_Property:setVisible(false)
		self.Text_QQ_Tile:setVisible(false)
		self.Text_QQ:setVisible(false)
		self.Text_QQ_Property:setVisible(false)
	end
	
	self.Image_titleBack:setVisible(false)


	if Game:isOpenWeiXinShare() == true then
		self.Image_weixin:setVisible(true)
		self.Text_weixinfenxian:setVisible(true)
	else
		self.Image_weixin:setVisible(false)
		self.Text_weixinfenxian:setVisible(false)
	end

	self.Binding_zhiZuoZu:releaseFunc(function()
		self:setCeHuaZu()
	end)

	if Game:isCheckNewPackage() == NEED_CHECK_AND_IS_OPEN then
		self.Button_MailBox:setPosition(307, 931)
		self.Button_RestGame:setPosition(307, 791)
		self.Button_Choise:setPosition(307, 651)
		self.Button_Question:setPosition(307, 511)
		self.Button_Save_Game:setPosition(307, 371)
		self.Button_Help:setPosition(307, 231)

		self.Button_Voice:setPosition(307, 911)
		self.Button_Property:setPosition(307, 691)
		self.Button_Mian_Da_Rao:setPosition(307, 471)
		self.Button_gonggao_history:setPosition(307, 511)
		self.Button_Binding_Mail:setPosition(307, 371)
		self.Button_Property_Back:setPosition(307, 231)

		self.Button_gonggao_history:setVisible(false)
		self.Button_Binding_Mail:setVisible(false)
		self.Text_BindMail:setVisible(false)
		self.Image_shiming:setVisible(false)
		self.Text_shimingjiangli:setVisible(false)
	elseif Game:isCheckNewPackage() == NEED_CHECK_AND_NOT_OPEN then
		self.Button_MailBox:setPosition(307, 931)
		self.Button_RestGame:setPosition(307, 791)
		self.Button_Choise:setPosition(307, 651)
		self.Button_Question:setPosition(307, 511)
		self.Button_Save_Game:setPosition(307, 371)
		self.Button_Help:setPosition(307, 231)

		self.Button_Voice:setPosition(307, 931)
		self.Button_Property:setPosition(307, 791)
		self.Button_Mian_Da_Rao:setPosition(307, 651)
		self.Button_gonggao_history:setPosition(307, 511)
		self.Button_Binding_Mail:setPosition(307, 371)
		self.Button_Property_Back:setPosition(307, 231)

		self.Button_gonggao_history:setVisible(true)
		self.Button_Binding_Mail:setVisible(true)
		self.Text_BindMail:setVisible(true)
		self.Image_shiming:setVisible(true)
		self.Text_shimingjiangli:setVisible(true)
	else
		self.Button_MailBox:setPosition(307, 931)
		self.Button_RestGame:setPosition(307, 791)
		self.Button_Choise:setPosition(307, 651)
		self.Button_Question:setPosition(307, 511)
		self.Button_Save_Game:setPosition(307, 371)
		self.Button_Help:setPosition(307, 231)

		self.Button_Voice:setPosition(307, 931)
		self.Button_gonggao_history:setPosition(307, 791)
		self.Button_Property:setPosition(307, 651)
		self.Button_Mian_Da_Rao:setPosition(307, 511)
		self.Button_Binding_Mail:setPosition(307, 371)
		self.Button_Property_Back:setPosition(307, 231)

		self.Button_gonggao_history:setVisible(true)
		self.Button_Binding_Mail:setVisible(true)
	end

	self.Text_QQ_Tile_Property:setPosition(40, 96)
	self.Text_QQ_Property:setPosition(274, 96)

	-- 查看隐私政策
	self.Text_Policy:releaseFunc(
		function()
			local layer = require("app.views.layer.CommunityLayer.CommunityLayer"):getInstance()
			layer:setUrl("http://fzjh.xiaohoutiaotiao.com/privacyPolicy")
			layer:setTitle("隐私政策")
			layer:show()
		end
	)

	self.Text_UserAgreement:releaseFunc(
		function()
			local layer = require("app.views.layer.CommunityLayer.CommunityLayer"):getInstance()
			layer:setUrl("http://fzjh.xiaohoutiaotiao.com/userAgreement")
			layer:setTitle("用户协议")
			layer:show()
		end
	)

	-- if Game:isOpenShiMing() == true then
		self.Image_shiming:setVisible(false)
		self.Text_shimingjiangli:setVisible(false)
	-- end
	self:init4399()

	self:setAccountButton()
end

function SetupUI:onAwake()
    self:setTextBindMail()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/27 11:14:55
-- @desc  UI刷新
function SetupUI:refreshUI()
	local voice=DataBase:getDataWithString("voice")
	if voice ==nil then
		DataBase:setDataByString("voice","Y")
	elseif voice=="Y" then
		self.Image_voice_close:setVisible(false)
		self.Text_Voice:setString("声音 开")
	else
		self.Image_voice_close:setVisible(true)
		self.Text_Voice:setString("声音 关")
	end
	
	-- add by XiaoZhiWei 2017/06/30 13:26:14 add with ios 1.0
	local MapPvp = DataBase:getDataWithString("MapPvp")
	if MapPvp == nil then
		DataBase:setDataByString("MapPvp", "ONLINE")
		self.Text_Mian_Da_Rao:setString("江湖浪客")
	elseif MapPvp == "ONLINE" then
		self.Text_Mian_Da_Rao:setString("江湖浪客")
	elseif MapPvp == "OFFLINE" then
		self.Text_Mian_Da_Rao:setString("江湖隐士")
	elseif MapPvp == "SILENT" then
		self.Text_Mian_Da_Rao:setString("江湖贤者")
	end

end

function SetupUI:afterShiMing()
	self.Text_shimingjiangli:setVisible(false)
	self.Image_shiming:setVisible(false)
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/19 16:28:15
-- @desc 策划组按钮点击效果
function SetupUI:setCeHuaZu()
	-- local map = Map:getMapById("fb200")

	-- 地图刷新
	local role = User:getRole()
	if RoleTaskControllor:clickMapLayer(role, function() self:setCeHuaZu() end) == false then
		return
	end

	local ZhiZuoZu = require("app.models.ZhiZuoZu.ZhiZuoZu")
	ZhiZuoZu:getZhiZuoZuList(function()
		local map = ZhiZuoZu:getZhiZhuZuMap()

		if map == nil then
			print("获取制作组副本信息失败")
			return
		end
		-- map:setCallBackAndConnect(function()

			MainControllLayer:getLayer("PrintLayer"):initRichText()
			-- 输出文本
			-- RichPrint("main", "HIW你掏出"..tostring(price).."两银子给车夫，车夫在手里掂了掂，高兴的收了起来。")
			RichPrint("main", "HIC你跳入黑洞中，一块块地图的碎片从你眼前闪过，一阵强烈的眩晕感不断侵袭你的大脑，当你清醒时已躺在结实的土地上，周围的一切都十分的陌生。")

			-- 播放进入地图动画
			local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
			entryMapLayer:maxZ()
			entryMapLayer:setCenterText("突然间，天塌地陷，空间竟然裂\n开，一硕大黑洞出现在你的眼前。")
			entryMapLayer:show()

			local titleLayer = MainControllLayer:getLayer("TitleLayer")
			local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
			mapRoleLayer:onResume()
			titleLayer:hide(true)

			-- 隐藏当前层
			-- self:fadeOut(0.3)

			self:delayFunc(1,
			function(obj)
				entryMapLayer:hide(function()
					RichPrint("main", "HIC你身形一转，跃下马来，姿势十分优美。")
				end) -- 隐藏界面

				-- 释放地图动画层
				MainControllLayer:removeLayer("EntryMapLayer")

				local mapLayer = MainControllLayer:getLayer("MapLayer")
				-- map:setMapForTask()	--主动任务，地图调整
				mapLayer:setMap(map)
				
				MainControllLayer:pushLayer("MapLayer")
				
				MessageCenter:notify("EnterMap",{map=map})
				-- titleLayer:changeTitleUI()
			end)
		-- end)
	end)
end

function SetupUI:show()
	self:setVisible(true)
	local role=User:getRole()
	if not role then
		return
	end

	-- self.Text_QQ:setString("5761854")

	--版本号
	local ver = Game:getVersion()
	local hotver = Game:getHotVersion()
	self.Text_Version:setString("V" .. ver .. "." .. hotver)
	self.Text_Version:setVisible(true)
	self.Text_ID_Input:setString(tostring(role.userid))
	self.Text_weixinfenxian:setString("分享微信获得10元宝")

	--显示是否绑定邮箱，已绑定则显示邮箱地址
	-- self:setTextBindMail()

	--设置界面点击返回
	self:setPropertyBack()

	--每次进入界面都显示第一个界面
	self.Steup_panel_Property:setVisible(false)
	self.Steup_panel:setVisible(true)

	-- 刷新邮箱相关
	if PRINT_MODE == 1 then
		print("刷新邮箱相关")
	end
	self:setTextBindMail(
	function(eventName)
		self:setButton_Binding_mail()
		if Game:isCheckNewPackage() ~= NOT_NEED_CHECK then
			self:setButtonGongGaoHistory()
		else
			self:setButton_Save_Game()
		end
	end)

	self.Binding_zhiZuoZu:setVisible(true)
end

function SetupUI:setImage_weixin()
	self.Image_weixin:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Image_weixin:releaseFunc(function()
		local WXShare = require("app.models.wxShare.WXShare")
		WXShare:doShare()
	end)
end

--点击选项按钮。选项界面显示
function SetupUI:setButtonChoise()
	self.Button_Choise:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_Choise:releaseFunc(function()
		self.Steup_panel_Property:setVisible(true)
		self.Steup_panel:setVisible(false)
		--self.Button_Question_Property:setVisible(false)
		-- add by XiaoZhiWei 2017/06/30 13:26:14 add with ios 1.0
		if Game:isCheckNewPackage() ~= NOT_NEED_CHECK then
			self:showButtonAim({self.Button_Voice, self.Button_Property, self.Button_Mian_Da_Rao, self.Button_gonggao_history, self.Button_Binding_Mail, self.Button_Property_Back}, 1)
		else
			self:showButtonAim({self.Button_Voice, self.Button_gonggao_history, self.Button_Property, self.Button_Mian_Da_Rao, self.Button_Binding_Mail, self.Button_Property_Back}, 1)
		end
	end)
end

--切换性能模式
function SetupUI:setButtonProperty()
	switch(device.platform,
	{
		["ios"] = function() self:setButtonPropertyIos() end,
		["android"] = function() self:setButtonPropertyAndroid() end,
		["windows"] = function() self:setButtonPropertyAndroid() end,
		default = nil
	})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/22 14:41:06
-- @desc 切换性能模式 IOS 接口
function SetupUI:setButtonPropertyIos()
	local state = DataBase:getDataWithString("AnimationInterval")
	if state == "Low" then
		self._Property = "low"
		self.Text_Property:setString("低性能模式")
	else
		self._Property = "normal"
		self.Text_Property:setString("正常模式")
	end

	self.Button_Property:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_Property:releaseFunc(function()
		if self._Property ~= "low" then
			self._Property = "low"
			self.Text_Property:setString("低性能模式")
			Game:setAnimationInterval("Low")
		else
			self._Property = "normal"
			self.Text_Property:setString("正常模式")
			Game:setAnimationInterval("Normal")
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/22 14:43:48
-- @desc  切换性能模式 ANDROID 接口
function SetupUI:setButtonPropertyAndroid()
	local state = DataBase:getDataWithString("AnimationInterval")
	if state == "Low" then
		self._Property = "low"
		self.Text_Property:setString("低性能模式")
	elseif state == "Normal" then
		self._Property = "normal"
		self.Text_Property:setString("正常模式")
	else
		self._Property = "high"
		self.Text_Property:setString("高性能模式")
	end

	self.Button_Property:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_Property:releaseFunc(function()
		if self._Property == "low" then
			self._Property = "normal"
			self.Text_Property:setString("正常模式")
			Game:setAnimationInterval("Normal")
		elseif self._Property == "normal" then
			self._Property = "high"
			self.Text_Property:setString("高性能模式")
			Game:setAnimationInterval("High")
		else
			self._Property = "low"
			self.Text_Property:setString("低性能模式")
			Game:setAnimationInterval("Low")
		end
		self:refreshUI() -- add by XiaoZhiWei 2017/02/27 11:27:21 用于刷新声音按钮
	end)
end

--选项界面返回
function SetupUI:setPropertyBack()
	self.Button_Property_Back:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BACKBUTTON)
	self.Button_Property_Back:releaseFunc(function ()
		self.Steup_panel_Property:setVisible(false)
		self.Steup_panel:setVisible(true)
		self:showButtonAim({self.Button_MailBox,self.Button_RestGame, self.Button_Choise, self.Button_Question, self.Button_Save_Game , self.Button_Help},  -1)
	end)
end

--从主界面打开的设置 点返回直接隐藏
function SetupUI:setPropertyHide()
	self.Steup_panel_Property:setVisible(true)
	self.Steup_panel:setVisible(false)
	self.Binding_zhiZuoZu:setVisible(false)
	self.Button_Property_Back:releaseFunc(function()
		MainControllLayer:popLayer()
		-- self:hide()
	end)
end


--声音控制界面
function SetupUI:setButton_Voice()
	self.Button_Voice:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local voice=DataBase:getDataWithString("voice")
		if voice =="Y" then
			Game:setGameVoice("N")
		else
			Game:setGameVoice("Y")
		end
		self:refreshUI() -- add by XiaoZhiWei 2017/02/27 11:33:13 声音按钮UI的刷新在该方法内
	end)
end
function SetupUI:setButton_yes()
	self.Button_yes:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
	end)
end

function SetupUI:setButton_back()
	self.Button_back:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_back:releaseFunc(function()
		MainControllLayer:popLayer()
		-- self:hide()
	end)
end

--邮箱界面
function SetupUI:setButton_MailBox()
	self.Button_MailBox:setVisible(true)
	self.Button_MailBox:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Text_MailBox:setString("江湖邮驿")
	local role = User:getRole()

	if role:getMailBoxState() == 1 and IsShowMailBox == false then
		self.Image_mbHongdian:setVisible(true)
	else
		self.Image_mbHongdian:setVisible(false)
	end
	self.Button_MailBox:releaseFunc(function()
		PopupLayerController:showLayer("MailBoxLayer", function(layer)
			layer:showLayer(function()
				self.Image_mbHongdian:setVisible(false)
				IsShowMailBox = true
			end)
		end)
	end)
end

function SetupUI:setButton_RestGame()
	self.Button_RestGame:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("HIW重置将抹除【"..User:getRoleAttr("name").."】所有游戏记录，仅保留当前剩余元宝数量，剩余江湖名士天数，购买的关卡，其他所有数据将随存档一并抹除，传承信息亦会被重置，游戏将从零次传承重新开始。\n是否确定重置角色？", "继续重置",
		function()
			ConfirmLayer:createCustomInRunningScene("重置后将无法恢复数据,请慎重考虑。如果需要重置请输入 \"YES\"", "重置",
			function(conFirmLayer)
				local editBoxString = conFirmLayer:getEditBoxString()
				if editBoxString == "YES" then

					HttpManagerEx:uploadUserData("chongzhi", function(status, errcode, errmsg, data, isEncrypted)

				        if status == 200 then
				            if errcode == 0 then
				                self:hide()
								local CreateRoleLayer = require("app.views.layer.CreateRoleLayer")
								local createRoleLayer = CreateRoleLayer:getInstance()
								createRoleLayer:setSuccessCallBack(function()
									-- User:reset()
									Game:restart(
									function()
										cc.Director:getInstance():getRunningScene():delayFunc(0.5, function()
											PopText("重置成功")
										end)
									end)
								end)
								createRoleLayer:show()
							elseif errcode == 7 then
								--@desc 邮箱附件未领取
								PopText(errmsg)
				            else
				               PopText(errmsg)
				            end
				            return true
						else
    						PopText("网络请求出错,请换个网络环境再试!")
				        end
				    end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
					-- Account:uploadUserData(
					-- function(eventName, errmsg)
					-- 	if eventName == "上传成功" then

					-- 	elseif eventName == "上传失败" then

					-- 	end
					-- end)
				else
					PopText("输入有误")
				end
			end,
			"不重置了",
			function()
			end)
		end,
		"不重置了",
		function()
		end)
	end)
end
function SetupUI:setButton_Help()
	self.Button_Help:setVisible(true)
	self.Button_Help:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Text_Help:setString("攻略客栈")
	self.Button_Help:loadTextureNormal("Image/UI/HomelandUI/doorplate_3.png")
	self.Button_Help:loadTexturePressed("Image/UI/HomelandUI/doorplate_3.png")
	self.Button_Help:releaseFunc(function()
		HttpManagerEx:getHelpDocument(function(status, errcode, errmsg, data)
			if status == 200 and errcode == 0  and MapIsEmpty(data) == false and data.url ~= nil then
				PopupLayerController:showLayer("GameHelpLayer", function(layer)
					layer:setUrl(data.url)
					layer:setTitle("放置江湖攻略客栈")
					layer:show()	
				end)
			else
				PopText(errmsg)
			end
		end)
	end)
end
function SetupUI:setButton_Question()
	self.Button_Question:setVisible(true)
	self.Button_Question:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Text_Question:setString("切换存档")
	self.Button_Question:releaseFunc(function()
		if PRINT_MODE == 1 then
			print("测试下载存档")
		end
		local function qiehuancundang(  )
			-- 必须上传成功才能下载
			HttpManagerEx:uploadUserData("qiehuan", function(status, errcode, errmsg, data, isEncrypted)
				if status == 200 and errcode == 0 then
					PopupLayerController:showLayer("ArchiveLayer", function(layer)
						layer:show(self.mailAddr)
					end)
				else
					if errmsg then
						PopText(errmsg)
					else
						PopText("网络异常，请确认网络后再做切换")
					end
				end
			end, IS_SHOW_WAITING)
		end
		---显示用户协议界面
		do
			if User:getRole():getFlag("isShowAgreement",false) == false then
				local agreementLayer = AgreementLayer:getInstance()
				agreementLayer:show()
				agreementLayer:setButtonDisagree(function ()
					----不同意,
					return
				end)
				agreementLayer:setButtonAgree(function ()
					---同意，继续游戏
					qiehuancundang()
				end)
			else
				qiehuancundang()
			end
		end

	end)
end

function SetupUI:setButton_Save_Game()
	-- add by XiaoZhiWei 2018/03/06 11:33:26 oppo渠道历史公告提出一级
	if Game:isCheckNewPackage() ~= NOT_NEED_CHECK then
		self.Text_Save_Game:setString("历史公告")
		self.Button_Save_Game:releaseFunc(function()
			local function notice()
				HttpManagerEx:getHistoryNotice(function(status, errcode, errmsg, data)
					if status == 200 and errcode == 0  and MapIsEmpty(data) == false and data.url ~= nil then
						local layer = require("app.views.layer.CommunityLayer.CommunityLayer"):getInstance()
						layer:setUrl(data.url)
						layer:setTitle("历史公告")
						layer:show()
						-- MainControllLayer:pushLayer("CommunityLayer")
					else
						PopText("没有历史公告")
					end
				end)
			end
			---显示用户协议界面
			do
				if User:getRole():getFlag("isShowAgreement",false) == false then
					local agreementLayer = AgreementLayer:getInstance()
					agreementLayer:show()
					agreementLayer:setButtonDisagree(function ()
						----不同意,
						return
					end)
					agreementLayer:setButtonAgree(function ()
						---同意，继续游戏
						notice()
					end)
				else
					notice()
				end
			end
		end)
	else
		if self.isBind == true then
			self.Text_Save_Game:setString("上传存档")
		else
			self.Text_Save_Game:setString("绑定邮箱")
		end
		self.Button_Save_Game:releaseFunc(function()
			-- if true then
			-- 	PopText("该功能暂未开放，敬请期待")
			-- 	return
			-- end

			local function bind()
				-- 是否已绑定过邮箱，没有则先绑定邮箱
				if self.isBind == false then
					Audio:playEffect("xiaoAnNiu")
					PopupLayerController:showLayer("BindingMailLayer", function(layer)
						layer:show()
						layer:addCallback(
						function(eventName)
							if eventName == "绑定成功" then
								self:show()
								return true
							end
						end)
					end)
					return
				end

				if self.Save_Time and GetTime() - self.Save_Time <= 300 then
					PopText("上传太频繁了，服务器承载不过来")
					return
				end
				Audio:playEffect("xiaoAnNiu")
				--物品记录更新
				Record:submitLog()

				HttpManagerEx:uploadUserData("shangchuan", function(status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						PopText("数据上传成功")
						self.Save_Time = GetTime()
					else
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING)
			end

			---显示用户协议界面
			do
				if User:getRole():getFlag("isShowAgreement",false) == false then
					local agreementLayer = AgreementLayer:getInstance()
					agreementLayer:show()
					agreementLayer:setButtonDisagree(function ()
						----不同意,
						return
					end)
					agreementLayer:setButtonAgree(function ()
						---同意，继续游戏
						bind()
					end)
				else
					bind()
				end
			end
		end)
	end
end

--显示绑定邮箱地址
function SetupUI:setTextBindMail(callback)
	callback = Helper:getDef(callback, EMPTY_FUNC)

	Account:getBindInfo(
	function(eventName, errmsg, email, phone, isBind, isLogout)
		if eventName == "有邮箱" then
			self.isBindEmail = true
		elseif eventName == "有手机号" then
			self.isBindPhone = true
		else
		end
		
		if tonumber(email) == 0 or email ==nil then
			self.Text_BindMail:setString("未绑定邮箱")	
		else
			self.isBind = true
			self.Text_BindMail:setString("已绑定邮箱:"..email)	
			self.mailAddr = email
		end

		self.isLogout = isLogout
		if callback then
			callback()
		end
	end)
end

--转移设备按钮
function SetupUI:setButton_Binding_mail()
	self.Binding_Mail_Property:setString(switch(self.isLogout, {[true] = "登录设备", [false] = "登出设备", default = "异常, 请联系客服"}))
	self.Button_Binding_Mail:releaseFunc(function()
		print('self.isLogout = '..tostring(self.isLogout))
		if self.isLogout == true then
			Audio:playEffect("xiaoAnNiu")
			PopupLayerController:showLayer("RetrieveArchiveLayer", function(layer)
				layer:show()
			end)
		elseif self.isLogout == false then
			if self.isBind == true then
				ConfirmLayer:createCustomInRunningScene([[RED请注意: 该帐号在下次登录之后的72小时内将无法登出. 如果需要登出, 请输入 "YES"]], "继续登出",
				function(conFirmLayer)
					local editBoxString = conFirmLayer:getEditBoxString()
					if editBoxString == "YES" then
						PopLogoutLayer()
					else
						PopText("输入有误")
					end
				end,
				"不登出了",
				function()
				end)
			elseif self.isBind == false then
				local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene([[RED警告: 您当前帐号尚未绑定邮箱, 请到设置界面绑定邮箱. 不绑定邮箱直接登出将永久丢失当前角色和帐号以及帐号绑定的所有商品, 并且无法找回, 请谨慎操作.]], "继续登出",
				function()
					ConfirmLayer:createCustomInRunningScene([[RED警告: 您当前帐号尚未绑定邮箱, 请到设置界面绑定邮箱. 不绑定邮箱直接登出将永久丢失当前角色和帐号以及帐号绑定的所有商品, 并且无法找回, 请谨慎操作. 如果需要登出请输入 "YES"]], "登出",
					function(conFirmLayer)
						local editBoxString = conFirmLayer:getEditBoxString()
						if editBoxString == "YES" then
							Account:logoutUnbindDevice(
							function(eventName, errmsg)
								if eventName == "登出成功" then
									-- 友盟统计 登出
									Mob.profileSignOff()

									User:reset()
									Game:restart(
									function()
										cc.Director:getInstance():getRunningScene():delayFunc(0.5, function()
											PopText("登出成功")
										end)
									end)
								elseif eventName == "登出失败" then
									PopText(errmsg)
								end
							end)
						else
							PopText("输入有误")
						end
					end,
					"不登出了",
					function()
					end)
				end,
				"不登出了",
				function()
				end)
			end
		end
	end)
end

-- 历史公告按钮
function SetupUI:setButtonGongGaoHistory()
	-- self.Button_gonggao_history:setVisible(true)
	if Game:isCheckNewPackage() ~= NOT_NEED_CHECK then
		if self.isBind == true then
			self.Text_gonggao_history:setString("上传存档")
		else
			self.Text_gonggao_history:setString("绑定邮箱")
		end
		self.Button_gonggao_history:releaseFunc(function()
			-- if true then
			-- 	PopText("该功能暂未开放，敬请期待")
			-- 	return
			-- end

			local function bind()
				-- 是否已绑定过邮箱，没有则先绑定邮箱
				if self.isBind == false then
					Audio:playEffect("xiaoAnNiu")
					PopupLayerController:showLayer("BindingMailLayer", function(layer)
						layer:show()
						layer:addCallback(
						function(eventName)
							if eventName == "绑定成功" then
								self:show()
								return true
							end
						end)
					end)
					return
				end

				if self.Save_Time and GetTime() - self.Save_Time <= 300 then
					PopText("上传太频繁了，服务器承载不过来")
					return
				end
				Audio:playEffect("xiaoAnNiu")
				HttpManagerEx:uploadUserData("shangchuan", function(status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						PopText("数据上传成功")
						self.Save_Time = GetTime()
					else
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING)
			end

			---显示用户协议界面
			do
				if User:getRole():getFlag("isShowAgreement",false) == false then
					local agreementLayer = AgreementLayer:getInstance()
					agreementLayer:show()
					agreementLayer:setButtonDisagree(function ()
						----不同意,
						return
					end)
					agreementLayer:setButtonAgree(function ()
						---同意，继续游戏
						bind()
					end)
				else
					bind()
				end
			end
		end)
	else
		self.Button_gonggao_history:releaseFunc(function()
			local function notice()
				HttpManagerEx:getHistoryNotice(function(status, errcode, errmsg, data)
					if status == 200 and errcode == 0  and MapIsEmpty(data) == false and data.url ~= nil then
						local layer = require("app.views.layer.CommunityLayer.CommunityLayer"):getInstance()
						layer:setUrl(data.url)
						layer:setTitle("历史公告")
						layer:show()
						-- MainControllLayer:pushLayer("CommunityLayer")
					else
						PopText("没有历史公告")
					end
				end)
			end
			---显示用户协议界面
			do
				if User:getRole():getFlag("isShowAgreement",false) == false then
					local agreementLayer = AgreementLayer:getInstance()
					agreementLayer:show()
					agreementLayer:setButtonDisagree(function ()
						----不同意,
						return
					end)
					agreementLayer:setButtonAgree(function ()
						---同意，继续游戏
						notice()
					end)
				else
					notice()
				end
			end
		end)
	end
end

-- add by XiaoZhiWei 2017/06/30 13:26:14 add with ios 1.0
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/20 15:17:17
-- @desc 江湖切磋免打扰切换
function SetupUI:setButtonMianDaRao()
	self.Button_Mian_Da_Rao:setVisible(true)
	self.Button_Mian_Da_Rao:releaseFunc(function()
		if self.isBind == true or Game:isCheckNewPackage() == NEED_CHECK_AND_IS_OPEN or DEBUG_MODE == 1 then
			-- add by XiaoZhiWei 2017/07/18 18:30:05 有一个特殊情况,如果是作弊玩家直接切换到隐士模式(离线)
			if User:getRoleAttr("role_is_cheat") == true then
				DataBase:setDataByString("MapPvp", "OFFLINE")
				User:getRole():setFlag("PVP战斗状态", "离线模式")
				self:refreshUI()
				PopText("由于你的数据异常，已经自动切换成江湖隐者模式！")
			elseif Map:getMapState("fb15") ~= MAP_STATE.COMPLETE then
				DataBase:setDataByString("MapPvp", "OFFLINE")
				User:getRole():setFlag("PVP战斗状态", "离线模式")
				self:refreshUI()
				PopText("开启江湖浪客模式需要先通关“声震武林卷”第五章！")
			--@desc 修改成创建账号3天后才能开启江湖浪客模式 2018/01/03
			elseif GetTime() - User:getRoleAttr("createTime") <= 3600 * 72 then
				DataBase:setDataByString("MapPvp", "OFFLINE")
				User:getRole():setFlag("PVP战斗状态", "离线模式")
				self:refreshUI()
				PopText("角色创建时间不足三天，无法开启江湖浪客模式！")
			elseif Game:isOpenEncounter() == true then
				Audio:playEffect("xiaoAnNiu")
				local MapPvp = DataBase:getDataWithString("MapPvp")
				local status = ""
				-- add by XiaoZhiWei 2017/06/20 15:37:30 副本偶遇状态 在线 -> 免打扰 -> 离线 -> 在线
				if MapPvp == "ONLINE" then
					MapPvp = "SILENT"
					status = "免打扰模式"
				elseif MapPvp == "OFFLINE" then
					MapPvp = "ONLINE"
					status = "战斗结束"
				else
					MapPvp = "OFFLINE"
					status = "离线模式"
				end
				DataBase:setDataByString("MapPvp", MapPvp)
				User:getRole():setFlag("PVP战斗状态", status)
				self:refreshUI()
			else
				PopText("该功能暂未开放，敬请期待")
			end
		else
			DataBase:setDataByString("MapPvp", "OFFLINE")
			User:getRole():setFlag("PVP战斗状态", "离线模式")
			self:refreshUI()
			PopText("请先绑定邮箱")
		end
	end)
end

--显示按钮动画
function SetupUI:showButtonAim(buttonList, duration)
	if MapIsEmpty(buttonList) == true then
		return
	end
	if duration == nil then
		duration = 1
	end
	local animDuration = 0.25
	local function buttonAnim(button, duration)
		button:setOpacity( 0 )
		button:setPosition(cc.p(307.000 + (duration * 200), button:getPositionY()))
		button:runAction(
			YXEaseAction:create( cc.Spawn:create(
				cc.MoveTo:create(animDuration, cc.p( 307.0000, button:getPositionY()) ) ,
				cc.FadeIn:create(animDuration)
			),  Sine_EaseOut ) )
	end

	for i,button in ipairs(buttonList) do
		duration = -1 * duration
		buttonAnim(button, duration)
	end


	-- btn1:setOpacity( 0 )
	-- btn2:setOpacity( 0 )
	-- btn3:setOpacity( 0 )
	-- btn4:setOpacity( 0 )
	-- btn5:setOpacity( 0 )


	-- btn1:setPosition(cc.p(307.000 - (dir * 200), btn1:getPositionY()))
	-- btn2:setPosition(cc.p(307.000 + (dir * 200), btn2:getPositionY()))
	-- btn3:setPosition(cc.p(307.000 - (dir * 200), btn3:getPositionY()))
	-- btn4:setPosition(cc.p(307.000 + (dir * 200), btn4:getPositionY()))
	-- btn5:setPosition(cc.p(307.000 - (dir * 200), btn5:getPositionY()))

	-- btn1:runAction(
	-- 	YXEaseAction:create( cc.Spawn:create(
	-- 					cc.MoveTo:create(animDuration, cc.p( 307.0000, btn1:getPositionY()) ) ,
	-- 					cc.FadeIn:create(animDuration)
	-- 				),  Sine_EaseOut ) )
	-- btn2:runAction(
	-- 	YXEaseAction:create( cc.Spawn:create(
	-- 					cc.MoveTo:create(animDuration, cc.p( 307.0000, btn2:getPositionY()) ) ,
	-- 					cc.FadeIn:create(animDuration)
	-- 				),  Sine_EaseOut ) )
	-- btn3:runAction(
	-- 	YXEaseAction:create( cc.Spawn:create(
	-- 					cc.MoveTo:create(animDuration, cc.p( 307.0000, btn3:getPositionY()) ) ,
	-- 					cc.FadeIn:create(animDuration)
	-- 				),  Sine_EaseOut ) )
	-- btn4:runAction(
	-- 	YXEaseAction:create( cc.Spawn:create(
	-- 					cc.MoveTo:create(animDuration, cc.p( 307.0000, btn4:getPositionY()) ) ,
	-- 					cc.FadeIn:create(animDuration)
	-- 				),  Sine_EaseOut ) )

	-- btn5:runAction(
	-- 	YXEaseAction:create( cc.Spawn:create(
	-- 					cc.MoveTo:create(animDuration, cc.p( 307.0000, btn5:getPositionY()) ) ,
	-- 					cc.FadeIn:create(animDuration)
	-- 				),  Sine_EaseOut ) )
end

function SetupUI:popText(str)
	PopText(str)
end

function SetupUI:showSkin()
	self.Button_skin:releaseFunc(function()
		PopupLayerController:showLayer("ChangeHouseSkinPresenters",function(layer)
			layer:setRole(User:getRole())
			layer:showLayer()
		end)
	end)
end

function SetupUI:init4399()
	local ActionOf4399 = require("src.app.models.Action.ActionOf4399")
	local isOpen = ActionOf4399:getActionOpen()
	self.Panel_4399:setVisible(isOpen)

	if isOpen then
		local role = User:getRole()
		local value = role:getTimeLimitFlag("4399Qudao")
		local currTime = GetTime()
		local dateStr = tonumber(Helper:date("%Y%m%d", tonumber(currTime)))
		if value == nil or value == 0 then
			self.Image_2:setVisible(true)
			self.Panel_4399:releaseFunc(function()
				dateStr = tonumber(Helper:date("%Y%m%d", GetTime()))
				role:setTimeLimitFlag("4399Qudao",dateStr,3600*24)
				self.Image_2:setVisible(false)
				local RedeemActivityLayer = require("app.views.layer.ActionLayer.RedeemActivityLayer")	
				RedeemActivityLayer:showLayer(ActionOf4399:getActionId())
			end)
		else
			if tonumber(value) ~= tonumber(dateStr) then
				self.Image_2:setVisible(true)
				self.Panel_4399:releaseFunc(function()
					dateStr = tonumber(Helper:date("%Y%m%d", GetTime()))
					role:setTimeLimitFlag("4399Qudao",dateStr,24*3600)
					self.Image_2:setVisible(false)
					local RedeemActivityLayer = require("app.views.layer.ActionLayer.RedeemActivityLayer")	
					RedeemActivityLayer:showLayer(ActionOf4399:getActionId())
				end)
			else
				self.Image_2:setVisible(false)
				self.Panel_4399:releaseFunc(function()
					local RedeemActivityLayer = require("app.views.layer.ActionLayer.RedeemActivityLayer")	
					RedeemActivityLayer:showLayer(ActionOf4399:getActionId())
				end)
			end
		end
	end
end

function SetupUI:setAccountButton()
	self.Button_account:setVisible(false)
end

Helper:classDefNodeGetInstance(SetupUI)
return SetupUI
0000000000000
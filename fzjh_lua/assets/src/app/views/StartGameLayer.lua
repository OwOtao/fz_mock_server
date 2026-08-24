local StartGameLayer = class("StartGameLayer", cc.Layer)
local Game = require("app.models.game.Game")

function StartGameLayer:create()
	local p = StartGameLayer:new()
	return p
end

function StartGameLayer:startGame()
	print("StartGameLayer:startGame()")

	-- 载入游戏界面
	local text = ccui.Text:create("游戏载入中...", "Font/default.ttf", 46)
	self:addChild(text)
	text:move(display.center)

	-- 延时载入资源
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0), cc.CallFunc:create(
	function()
		g_startGameLayer = self

		-- 初始化游戏
		Game:init(function()
			
			-------------------------------------------------------

			-- 获得角色数据
			local roleData = DataBase:getRoleData()

			-- 有角色数据
			if type(roleData) == "table" then
				if PRINT_MODE == 1 then
					print("存档存在")
				end

				-- userid必须为数字, 而且不能小于0
				if type(roleData.userid) == "number" and roleData.userid > 0 then
					if PRINT_MODE == 1 then
						print("有用户id")
					end
					-- 有存档, 有userid
					HttpManagerEx:PostStr("create_account", "", function(str, status)
						if status == 200 then
							local responseData = json.decode(str)
							if type(responseData) == "table" then
								if responseData.errcode == 0 then
									User:getRole().isReset = "N"
									self:checkLogin()
								elseif responseData.errcode == 4 then -- 创建帐号失败
									PopText(responseData.errmsg)
								elseif responseData.errcode == 552 then -- 用户不存在
									self:resetGame()
								elseif responseData.errcode == 201 then
									local data = responseData.data
									if data and data.title and data.body then
										self:showPopPanel(data.title, data.body)
									else
										PopText("数据异常, 请联系客服")
									end
								else
									PopText("数据异常, 请联系客服")
								end
							else
								PopText("请检查网络是否正常5")
							end
						else
							PopText("请检查网络是否正常8:"..tostring(status))
						end
					end)
				else
					if PRINT_MODE == 1 then
						print("无用户id")
						-- 设置userid为 -3 , 服务器会返回userid
						print("1 userid = "..tostring(User:getRoleAttr("userid")))
					end
					HttpManagerEx:PostStrWithHeader("create_account", {roleData}, {userid = -3}, function(str, status)
						if status == 200 then
							local responseData = json.decode(str)
							local data = responseData.data
							if type(responseData) == "table" then
								if responseData.errcode == 0 then
									if data and data.userid then
										User:getRole().userid = data.userid
										User:getRole().isReset = "N"
										self:checkLogin()
									else
										PopText("数据异常, 请联系客服")
									end
								elseif responseData.errcode == 2 then -- 用户数据异常
									self:resetGame()
								elseif responseData.errcode == 6 then -- 用户数据异常
									self:resetGame()
								elseif responseData.errcode == 3 then -- 插入数据库错误
									PopText(responseData.errmsg)
								elseif responseData.errcode == 4 then -- 创建帐号失败
									PopText(responseData.errmsg)
								elseif responseData.errcode == 552 then -- 用户不存在
									self:resetGame()
								elseif responseData.errcode == 201 then
									local data = responseData.data
									if data and data.title and data.body then
										self:showPopPanel(data.title, data.body)
									else
										PopText("数据异常, 请联系客服")
									end
								else
									PopText("数据异常, 请联系客服")
								end
							else
								PopText("请检查网络是否正常9")
							end
						else
							PopText("请检查网络是否正常10")
						end
					end)
				end
			else
				if PRINT_MODE == 1 then
					print("存档不存在")
				end

				-- 没存档
				HttpManagerEx:PostStrWithHeader("create_account", "", {userid = -1}, function(str, status)
					if status == 200 then
						local responseData = json.decode(str)
						if type(responseData) == "table" then
							if responseData.errcode == 0 then
								self:downloadSaveData(function()
									self:checkTime()
								end)
							elseif responseData.errcode == 4 then -- 更新账户元宝失败
								PopText("更新账户元宝失败, 请联系客服")
								self:downloadSaveData(function()
									self:checkTime()
								end)
							elseif responseData.errcode == 551 then -- uuid非法..
								self:resetGame()

							elseif responseData.errcode == 201 then
								local data = responseData.data
								if data and data.title and data.body then
									self:showPopPanel(data.title, data.body)
								else
									PopText("数据异常, 请联系客服")
								end
							else
								PopText("数据异常, 请联系客服")
							end
						else
							PopText("请检查网络是否正常11")
						end
					else
						PopText("请检查网络是否正常12")
					end
				end)
			end
		end)
	end)))
end

-- 显示弹窗
function StartGameLayer:showPopPanel(title, text)
	local DialogHLayer = require("app.views.layer.DialogLayer.DialogHLayer")
	local dialog = DialogHLayer:getInstance()
	dialog:show()
	dialog:setText(text)
	dialog:setTitle(title)
	dialog.Button_1:hide()
end

-- 下载存档
function StartGameLayer:downloadSaveData(callback)
	HttpManagerEx:downloadUserData(function(str, status)
		-- 网络请求成功
		if status == 200 then
			local responseData = json.decode(str)
			-- 判断服务器返回数据
			if type(responseData) == "table" then
				if PRINT_MODE == 1 then
					print("responseData:")
				end
				Helper:print_lua_table(responseData)
				-- 判断返回值状态
				if responseData.errcode == 0 then
					local decryptString = JMForLua:decrypt(responseData.data)
					if PRINT_MODE == 1 then
						print("decryptString = "..decryptString)
					end
					responseData.data = json.decode(decryptString)

					-- 判断返回数据是否正确
					if type(responseData.data) == "table" and type(responseData.data[1]) == "table" then
						-- 使用存档开始游戏
						DataBase:setRoleData(responseData.data[1])
						User:init()
						User:loadRole()

						-- 设置为无需重置
						User:setRoleAttr("isReset", "N")
						if callback then
							callback()
						end
					else
						self:resetGame()
						-- PopText("重启游戏, 或者联系客服")
					end
				else
					User:setRoleAttr("isReset", "Y")
					self:checkTime()
					-- print("下载存档失败")
					-- PopText("下载存档失败, 请联系客服")
				end
			else
				-- 服务器响应失败
				-- PopText("服务器响应失败")
				PopText("网络请求失败")
			end
		else
			-- 网络请求失败需要统一的处理
			-- PopText("下载人物存档请求失败")
			PopText("网络请求失败")
		end
	end)
end

-- 重置游戏
function StartGameLayer:resetGame()
	-- User:resetRole()
	User:setRoleAttr("isReset", "Y")
	self:checkTime()
end

function StartGameLayer:checkLogin()
	-- 检查登录
	local userid = User:getRoleAttr("userid")

	-- 提供支付接口使用，不要注释----------------------------------------------------
	---------------------------------------------------------------------------------
	DataBase:setData("userid", User:getRoleAttr("userid"), false) ---------------------
	DataBase:setData("hotver", UpdateManager:getVersion(), false) ---------------------
	---------------------------------------------------------------------------------
	---------------------------------------------------------------------------------

	-- 获取角色数据
	local roleData = DataBase:getRoleData()
	local roleExp, rolePot, roleMoney
	if type(roleData) == "table" then
		if roleData.exp then
			roleExp = roleData.exp
		end
		if roleData.pot then
			rolePot = roleData.pot
		end
		if roleData.money then
			roleMoney = roleData.money
		end
	end
	if PRINT_MODE == 1 then
		print("roleExp = "..tostring(roleExp))
		print("rolePot = "..tostring(rolePot))
		print("roleMoney = "..tostring(roleMoney))
	end

	if type(userid) == "number" and userid > 0 then
		HttpManagerEx:checkLogin({exp = roleExp, pot = rolePot, money = roleMoney}, function(str)
			local responseData = json.decode(str)
			if PRINT_MODE == 1 then
				print("HttpManagerEx:checkLogin")
			end
			Helper:print_lua_table(responseData)

			if responseData.errcode == 550 then -- invalid userid
				-- User:resetRole()
				User:setRoleAttr("isReset", "Y")
				self:checkTime()
				return
			elseif responseData.errcode == 551 then -- invalid uuid
				PopText("您的uuid为空, 请检查您的设备, 官方客服: 800184002")
				return
			elseif responseData.errcode == 552 then -- userid not exists
				-- User:resetRole()
				User:setRoleAttr("isReset", "Y")
				self:checkTime()
				return
			elseif responseData.errcode == 0 then -- ok

				-- 根据服务器数据情况 初始化 用户数据
				local function initUserDataFromWeb(data)
					if MapIsEmpty(data) == true then
						return
					end
					--[[
					暂时初始化属性
					account: guankaLimit 关卡上限
					role: yueka expired_time 月卡及剩余时间
					]]

					-- 账户相关数据
					if MapIsEmpty(data.account) == false then
						local account = data.account
						local guankaLimit = User:getRoleAttr("guanqiaLimit") -- 服务器返回的是guankaLimit 本地为guanqiaLimit
						-- 只有服务器的关卡上限大于本地的关卡上限时,才能将服务器的覆盖本地
						if account.guankaLimit ~= nil and tonumber(guankaLimit) < tonumber(account.guankaLimit) then
							User:setRoleAttr("guankaLimit", account.guankaLimit)
						end
						-- 角色相关数据
					elseif MapIsEmpty(data.role) == false then
						local webRoleData = data.role
						-- 月卡存在并且过期时间大于当前时间 更新月卡状态
						if webRoleData.yueka == true and GetTime() < webRoleData.expired_time then
							User:getRole():updateYueKaStatus(webRoleData.expired_time)
						end
					else
					end
				end

				initUserDataFromWeb(responseData.data)
				self:checkTime()
			elseif responseData.errcode == 1 then -- 黑名单
				local DialogHLayer = require("app.views.layer.DialogLayer.DialogHLayer")
				local dialog = DialogHLayer:getInstance()
				dialog:show()
				dialog:setText("经过系统检测，您的数据存在异常，我们将对您进行封号处理，如有疑问，请联系客服人员。")
				dialog:setTitle("系统提示")
				dialog:setButton1("重置游戏", function()
					Audio:playEffect("xiaoAnNiu")
					local userid = User:getRoleAttr("userid")
					local yuanbao = User:getRoleAttr("yuanbao")
					local guanqiaLimit = User:getRoleAttr("guanqiaLimit")
					DataBase:setRoleData("")
					User:init()
					User:setRoleAttr("yuanbao", yuanbao)
					User:setRoleAttr("guanqiaLimit", guanqiaLimit)
					User:setRoleAttr("userid", userid)
					User:setRoleAttr("isReset", "Y")
					self:checkTime()
				end)
			else
				PopText("网络出错, 检查网络")
			end
		end)
	else
		self:checkTime()
	end
end

function StartGameLayer:checkTime()
	HttpManagerEx:getTime(function(str, status)
		if status == 200 then
			local rData = assert(json.decode(str))
			if rData.errcode == 0 then
				BACKGROUND_TIME = tonumber(rData.data.time) - WEB_TIME
				WEB_TIME = tonumber(rData.data.time)
				NETWORK_STATE = 1
				self:startGames()
				return true
			else
				return false
			end
		end
	end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-- --处理神兵服务器丢弃了，本地数据还存在的情况
-- function StartGameLayer:disposeThrowedShenBingButLocalExist()
-- --处理如果本地网络不好，服务器埋藏了兵器。本地没有清除的情况、、
-- HttpManagerEx:getThrowWeaponData(function(str, status)
-- local role = User:getRole()
-- local shenBingweapon = role.shenBingweapon
-- local state, data = Helper:getResponseData(str, status)
-- if state == true then
-- local role = User:getRole()
-- Helper:print_lua_table(data)
-- for i,v in pairs(data) do
-- --判断条件：服务器下载的数据不为空，并且名字等于本地神兵的名字，这时候清空本地神兵的数据（如果已经装备了，等下一次，知道不装备）
-- if v.type == 1 and v.data ~= nil and v.data.data ~= nil then
-- local vData = v.data.data
-- if shenBingweapon.status == "2" and ((vData.onlyId ~= nil and vData.onlyId == shenBingweapon.onlyId) or (vData.beginDazaoTime == shenBingweapon.beginDazaoTime)) then
-- local shenBingItem = role:getItem(shenBingweapon.id)
-- if role:checkItemIsEquip(shenBingItem.id) then
-- role:setEquipByName(shenBingweapon.equipPart, nil) --卸下
-- end
-- local RoleObserveLayer = require("app.views.layer.RoleLayer.RoleObserveLayer")
-- role:addItemCount(shenBingweapon.id,-1)
-- RoleObserveLayer:getInstance():deleteShenBingData(shenBingweapon)
-- end
-- end
-- end
-- if func then
-- func()
-- end
-- else
-- --访问错误
-- PopText(data)
-- end
-- end)
-- end

function StartGameLayer:startGames()
	if PRINT_MODE == 1 then
		print("StartGameLayer:startGames()")
	end

	-- 显示菜单界面
	local ControllLayer = require("app.views.layer.ControllLayer")
	local controllLayer = ControllLayer:getInstance()
	local menuLayer = controllLayer:getLayer("MenuLayer")

	-- 设置开始游戏按钮的回调方法
	menuLayer:setStartGameFunc(function()
		-- 判断角色是否需要重置
		local isReset = User:getRoleAttr("isReset")
		if isReset == "Y" then
			local CreateRoleLayer = require("app.views.layer.CreateRoleLayer")
			local createRoleLayer = CreateRoleLayer:getInstance()
			createRoleLayer:show()
		else
			controllLayer:startGame()
		end
	end)

	-- self:disposeThrowedShenBingButLocalExist()
end

-- 加密标记
StartGameLayer.isEncrypted = true
return StartGameLayer
0
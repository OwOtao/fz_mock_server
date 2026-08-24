-- 所有子节点执行相同动作
function callChildren(parent, callback)
	local function _callChildren(parent, callback)
		local children = parent:getChildren()
		for key, var in pairs(children) do
			callback(var)
			_callChildren(var, callback)
		end
	end
	return _callChildren(parent, callback)
end

-- UI
function convertUI(root)
	callChildren(root,
	function(child)
		local childType = tolua.type(child)
		root[child:getName()] = child
	end)
end

--
local UpdateLayer = class("UpdateLayer", cc.Layer)

function UpdateLayer:create(successFunc, failedFunc)
	local p = UpdateLayer:new()
	p:init(successFunc, failedFunc)
	return p
end

function UpdateLayer:httpGet(url, func)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open( "get", url, true )

	xhr:registerScriptHandler(
	function()
		local response = xhr.response
		if PRINT_MODE == 1 then
			print( "url = "..url )
			print( "rcvData = "..response )
		end
		if func then
			func(response)
		end
		xhr:release()
	end
	)
	xhr.timeout = 15
	xhr:send("")
end

function UpdateLayer:getTime(func)
	self:httpGet("http://120.76.45.120:1809/api/v1/get_time", func)
end

function UpdateLayer:getGamingVersion(func)
	self:httpGet("http://120.76.45.120:1809/api/v1/get_game_version/MUD", func)
end

function UpdateLayer:init(successFunc, failedFunc)
	assert(type(successFunc) == "function", "successFunc 必须是function")
	assert(type(failedFunc) == "function", "failedFunc 必须是function")

	self._UI = require("Layer/UpdateUI.lua").create()['root']
	self._UI:addTo(self)
	convertUI(self)

	-- 添加重试按钮
	self:setText("链接服务器...")
	self:getTime(function(str)
		if not str or string.len(str) <=0 then
			self:setText("服务器链接失败，请检查您的网络。")
			self:setButton1(successFunc, failedFunc)
		else
			if PRINT_MODE == 1 then
				print("网络链接成功")
			end
			self:setText("检查更新")
			self:getGamingVersion(function(str)
				if not str or string.len(str) <= 0 then
					self:setText("服务器链接失败，请检查您的网络。")
					self:setButton1(successFunc, failedFunc)
				else
					local list = assert(json.decode(str))
					if list.data[1].canUpdate == "Y" then
						if PRINT_MODE == 1 then
							print("开始更新服务器数据")
						end
						self:updating(successFunc, failedFunc)
					else
						if PRINT_MODE == 1 then
							print("直接跳过服务器更新")
						end
						self:setText("加载资源...")
						successFunc()
					end
				end
			end)
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 更新
function UpdateLayer:updating(successFunc, failedFunc)
	--
	self:setText("正在连接...")
	self:setPercent(50)

	if device.platform ==  "windows" then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(
		function()
			self:setPercent(100)
			self:setText("升级完成")

			successFunc()
		end)))
		return
	end

	-- 可写目录
	local storagePath = cc.FileUtils:getInstance():getWritablePath()
	local assetsManagerEx = cc.AssetsManagerEx:create("project.manifest", storagePath)
	assetsManagerEx:retain()
	--设置下载消息listener
	local function handleAssetsManagerEx(event)
		if (cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE == event:getEventCode()) then
			if PRINT_MODE == 1 then
				print("已经是最新版本了，进入游戏主界面")
			end
			finishUpdate()
			successFunc()
		end

		if (cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND == event:getEventCode()) then
			if PRINT_MODE == 1 then
				print("发现新版本，开始升级")
			end
			startUpdate() -- 开始更新
			self:setText("发现新版本，开始升级")
		end

		if (cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION == event:getEventCode()) then
			if PRINT_MODE == 1 then
				print("更新进度="..event:getPercentByFile())	
			end
			self:setPercent(event:getPercentByFile())
			self:setText("更新中... （"..tostring(math.floor(event:getPercentByFile())).."%)")
		end

		if (cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED == event:getEventCode()) then
			if finishUpdate() then
				if PRINT_MODE == 1 then
					print("更新完毕，开始载入资源")
				end
				successFunc()
				self:setText("更新完毕，开始载入资源")
			else
				-- 提示玩家重启
				self:setText("请重启游戏,完成更新.")
			end
		end

		if (cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST == event:getEventCode()) then
			if PRINT_MODE == 1 then
				print("发生错误:本地找不到manifest文件")
			end
			failedFunc()
			self:setText("发生错误:错误原因 ERROR1!")
		end

		if (cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST == event:getEventCode()) then
			if PRINT_MODE == 1 then
				print("发生错误:下载manifest文件失败")
			end
			failedFunc()
			self:setText("发生错误:错误原因 ERROR2!")
		end

		if (cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST == event:getEventCode()) then
			if PRINT_MODE == 1 then
				print("发生错误:解析manifest文件失败")
			end
			resetUpdate()
			failedFunc()
			self:setText("发生错误:错误原因 ERROR3!")
		end

		if (cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING == event:getEventCode()) then
			if PRINT_MODE == 1 then
				print("发生错误:更新出错")
			end
			failedFunc()
			self:setText("发生错误:错误原因 ERROR4!")

			-- 下载下载失败的文件
			-- assetsManagerEx:downloadFailedAssets()
		end

		if (cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED == event:getEventCode()) then
			if PRINT_MODE == 1 then
				print("发生错误:更新失败")
			end
			failedFunc()
			self:setText("更新失败")
		end
	end

	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	local eventListenerAssetsManagerEx = cc.EventListenerAssetsManagerEx:create(assetsManagerEx, handleAssetsManagerEx)
	dispatcher:addEventListenerWithFixedPriority(eventListenerAssetsManagerEx, 1)
	assetsManagerEx:update()
end

function UpdateLayer:setText(text)
	self.Text:setString(text)
end

function UpdateLayer:setPercent(percent)
	self.LoadingBar:setPercent(percent)
end

function UpdateLayer:setButton1(successFunc, failedFunc, func)
	self.Button_1:setVisible(true)
	self.Button_1:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:setText("正在链接服务器...")
			self.Button_1:setVisible(false)
			self:getTime(function(str)
				if not str or string.len(str) <=0 then
					self:setText("服务器链接失败，请检查您的网络。")
					self:setButton1(successFunc, failedFunc)
				else
					if PRINT_MODE == 1 then
						print("网络链接成功")
					end
					self:updating(successFunc, failedFunc)
				end
			end)

			if func then
				func()
			end
		end
	end)
end

return UpdateLayer
0000000000000000

local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.randomseed(os.time())
end

function MyApp:onEnterBackground()
	if FILE_IS_LOADING == true then
		Record:updateUpload()

		User:save()
		-- 友盟统计 登出
		Mob.profileSignOff()
	end
end

function MyApp:onEnterForeground()
	if FILE_IS_LOADING == true then
		-- add by XiaoZhiWei 2017/12/05 10:19:08 华为手机白屏的问题
		MainControllLayer:uniqueDelayFunc("foreground", 0.5, function()
			HttpManagerEx:getTime(function(status, errcode, errmsg, data, isEncrypted)
				if status == 200 and errcode == 0 and data.time ~= nil then
					BACKGROUND_TIME = BACKGROUND_TIME + tonumber(data.time) - WEB_TIME
					WEB_TIME = tonumber(data.time)
					if device.platform == "android" then
						YXHelper:setWebTime(WEB_TIME)
					else
					end
					NETWORK_STATE = 1
		    		return true
				end
			end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
		end)

		-- 友盟统计 登入
		if User:getUserId() > 0 then
			Mob.profileSignIn(User:getUserId())
		end
	end
end

-- 加密标记
MyApp.isEncrypted = true
return MyApp
000000000
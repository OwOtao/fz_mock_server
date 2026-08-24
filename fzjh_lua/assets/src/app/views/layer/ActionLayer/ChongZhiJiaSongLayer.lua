local ChongZhiJiaSongLayer = class("ChongZhiJiaSongLayer",LayerEx)

function ChongZhiJiaSongLayer:create()
	local p = ChongZhiJiaSongLayer:new()
	p:init()
	return p
end

function ChongZhiJiaSongLayer:init()
	local  UI = require("Layer/ActionUI/JiangHuMingShiChongZhiJiaSongUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

	self.Button_lingqujiangli:setTouchEnabled(true)

	self:setButtonClose()
end

function ChongZhiJiaSongLayer:showLayer(actionId,desc)
	local layer = self:getInstance()
	layer:show()
	layer:setDesc(desc)
end

function ChongZhiJiaSongLayer:onAwake()
	self:setActionTime()
end

function ChongZhiJiaSongLayer:setActionTime()
	HttpManagerEx:getActionTime(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0  then
        	self.Text_chishu:setString("本角色活动期间内已充江湖名士次数：".. data.num)
   			self:setButtonLingQuJiangLi(data.ctime)
   			self:setButtonQianWang(data.ctime)
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end

function ChongZhiJiaSongLayer:setDesc(desc)
	self.Text_shuoming:setString(desc)
end

--领取按钮
function ChongZhiJiaSongLayer:setButtonLingQuJiangLi(endtime)
	if GetTime() < endtime then
    else
        self.Button_lingqujiangli:setEnabled(true)
    end

    self.Button_lingqujiangli:releaseFunc(function()
    	if  GetTime() < endtime then
    		PopText("江湖名士加送奖励在活动结束后7日内领取。")
		else
			if GetTime() < endtime + 7*(60*60*24) then
				PopupLayerController:showLayer(
					"GlobalShadeLayer",
					function(layer)
						layer:showLayer()
						layer:setPopText("")
					end
				)
	    		HttpManagerEx:getActionAward(function(status, errcode, errmsg, data)
	    			if status == 200 and errcode == 0 then
	        			PopText(errmsg)
	            	else
	               		PopText(errmsg)
					end
					PopupLayerController:hideLayer(
						"GlobalShadeLayer",
						function(layer)
							layer:hideLayer()
						end
					)
	    		end,IS_SHOW_WAITING)
	    	end
    	end
    	end)

end

--前往充值  江湖人士界面
function ChongZhiJiaSongLayer:setButtonQianWang(endtime)

	if GetTime() > endtime then
		self.Button_gotopay:setVisible(false)
		return
	end
	self.Button_gotopay:setVisible(true)
	self.Button_gotopay:releaseFunc(function()

		if device.platform == "android" then
			-----------------------------------------------------------------------------------------------------------
			-- @author moxiaoxia
			-- @time 2018/12/07
			-- @desc  判断是否绑定邮箱
			Account:getEmail(
			function(eventName, errmsg, email, isBind, isLogout)
				if eventName == "有邮箱" then
					-- isBind 为true的时候 才是已绑定邮箱
					if isBind == true then
						PopupLayerController:showLayer("YueKaLayer",function(layer)
						layer:show(self,2)
						MainControllLayer:pushLayer("StoreLayer")
						local StoreLayer=MainControllLayer:getLayer("StoreLayer")
						StoreLayer:showWithAction()
						self:hide()
						self:destroyInstance() -- 弹出类窗口,隐藏时删除自身
					end)
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
			PopupLayerController:showLayer("YueKaLayer",function(layer)
			layer:show(self,2)
			MainControllLayer:pushLayer("StoreLayer")
			local StoreLayer=MainControllLayer:getLayer("StoreLayer")
			StoreLayer:showWithAction()
			self:hide()
			self:destroyInstance() -- 弹出类窗口,隐藏时删除自身
			end)
		elseif device.platform == "windows" then
			PopupLayerController:showLayer("YueKaLayer",function(layer)
			layer:show(self,2)
			MainControllLayer:pushLayer("StoreLayer")
			local StoreLayer=MainControllLayer:getLayer("StoreLayer")
			StoreLayer:showWithAction()
			self:hide()
			self:destroyInstance() -- 弹出类窗口,隐藏时删除自身
			end)
		else
		end
	end)	
end

function ChongZhiJiaSongLayer:setButtonClose()
	self.Button_close:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- 弹出类窗口,隐藏时删除自身
	end)
end

Helper:classDefNodeGetInstance(ChongZhiJiaSongLayer)
return ChongZhiJiaSongLayer000000000
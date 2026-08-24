local Helper = require("app.Helper")
require("app.extends.NodeEx")
local LoadingLayer = class("LoadingLayer", cc.Layer)


local GameStarImagePath = {
	bg_1 = "Image/UI/GameStarUI/bg_1.png",
    bg_2 = "Image/UI/GameStarUI/bg_2.png",
    bg_3 = "Image/UI/GameStarUI/bg_3.png",
    bg_4 = "Image/UI/GameStarUI/bg_4.png",
    renWu_1 = "Image/UI/GameStarUI/renWu_1.png",
    renWu_2 = "Image/UI/GameStarUI/renWu_2.png",
    renWu_3 = "Image/UI/GameStarUI/renWu_3.png",
    renWu_4 = "Image/UI/GameStarUI/renWu_4.png",
    renWu_5 = "Image/UI/GameStarUI/renWu_5.png",
    renWu_6 = "Image/UI/GameStarUI/renWu_6.png",
    renWu_7 = "Image/UI/GameStarUI/renWu_7.png",
}

local beginFunc, successFunc, ButNum
local biaoJi = {true,true,true,true,true,true,true,true,true,true,true,true,true}
function LoadingLayer:create()
	local p = LoadingLayer:new()
	p:init()
	return p
end


function LoadingLayer:init()
	local LoadingUI = require("Layer/LoadingUI.lua").create()['root']
	local xiaobao = require("script.others.xiaobao")["Sheet1"]


	local suiJiKey1 = math.random(1,40)
	LoadingUI:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点
	--self:setButton2()
	self:setVisible(true)

	self.funcTab = nil
	self.currIndex = 1
	self.currParentIndex = 1
	self.pctList = nil
	self._updateTime = 0

	self.successFunc = nil
	self.isSuccess = false

	self.Image_1:setOpacity(0)
	self.Image_2:setOpacity(0)
	self.Image_3:setOpacity(0)
	self.Image_4:setOpacity(0)
	self.Image_5:setOpacity(0)
	self.Image_6:setOpacity(0)
	self.Image_7:setOpacity(0)
	self.Image_Bg:loadTexture(GameStarImagePath["bg_"..math.random(1,4)])
	self.Image_RenWu:loadTexture(GameStarImagePath["renWu_"..math.random(1,7)])


	self.jiangHuXiaoBao:setOpacity(0)
	self.Button_chaKan:setOpacity(0)
	self.Button_chaKan:releaseFunc(function()
		--self.Button_chaKan:TouchEnabled(true)
		self.Button_chaKan:setVisible(false)
		self.Button_chaKan:runAction(cc.FadeOut:create(0.5))
		local sequence = cc.Sequence:create(cc.FadeOut:create(0.3),cc.CallFunc:create(function()
			local suiJiKey2 = math.random(1,40)
			while suiJiKey2 == suiJiKey1 do
				suiJiKey2 = math.random(1,40)
			end
			self.jiangHuXiaoBao:setString(xiaobao[tostring(suiJiKey2)].text)
			self.jiangHuXiaoBao:runAction(cc.FadeIn:create(0.2))	
			suiJiKey1 = suiJiKey2
		end))
		self.jiangHuXiaoBao:runAction(sequence)	
	end)
	self.jiangHuXiaoBao:setString(xiaobao[tostring(suiJiKey1)].text) 
	self.jiangHuXiaoBao:runAction(cc.FadeIn:create(0.5))


	self:schedule(
	function(ft)
		self:update(ft)
	end, 0)
end

function LoadingLayer:show(funcTab, func, precentList)
	self.funcTab = funcTab
	self.pctList = precentList
	self:setVisible(true)
	if type(func) ~= "function" then
		func = function() end
	end
	self.successFunc = func
end

function LoadingLayer:hide()
	self:delayFunc(1, function()
		self:destroyInstance()
	end)
	-- self:setVisible(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/16 16:37:31
-- @params 具体需要更新的协程
-- @desc 协程更新方法
local updateFunc = function(cor)
	local time, result = GetLocalTime(), false
    while true do
        if (GetLocalTime() - time) > cc.Director:getInstance():getAnimationInterval() or result == true then
            break
        end
        local a
        a, result = coroutine.resume(cor)
    end
    return result
end

function LoadingLayer:loadFile()
	if self.funcTab[self.currParentIndex] ~= nil and self.currIndex <= #self.funcTab[self.currParentIndex] then
		local currV = self.funcTab[self.currParentIndex][self.currIndex]
		if type(currV) == "function" then
			currV()
			self.currIndex = self.currIndex + 1
		elseif type(currV) == "table" then
			if currV.isStart ~= true then
				currV.cor = currV.start()
				currV.isStart = true;
			end

			local result = updateFunc(currV.cor)
			self._loadingIndex = self._lastIndex + currV.percent(currV.needPercent)

			if result == true then
				self._lastIndex = self._loadingIndex
				self.currIndex = self.currIndex + 1
			end
		end
	end
end

function LoadingLayer:setPercent(percent)
	self.LoadingBar:setPercent(percent)
end

function LoadingLayer:setTotalCount(count)
	self._loadingIndex = 0
	self._lastIndex = 0
	self._totalCount = count
end

function LoadingLayer:update(ft)
	self:showLoadingBar(ft)
	if self._updateTime < 4 then
		return
	end
	if self.isSuccess == true or self.funcTab == nil or self.pctList == nil then
		return
	end
	if self.currIndex == #self.funcTab[self.currParentIndex] + 1 then
		if self.currParentIndex == #self.funcTab then
			self.isSuccess = true
			self.successFunc()
			self:pauseSelfAndChildren()
			self:hide()
			return
		else
			self.currParentIndex = self.currParentIndex + 1
			self.currIndex = 1
		end
	end

	--每次调用require一次
	self:loadFile()
	local percent = Helper:getRange(((self.currIndex + self._loadingIndex) / (#self.funcTab[self.currParentIndex] + self._totalCount)) * 100, 0, 100) * self.pctList[self.currParentIndex].factor + self.pctList[self.currParentIndex].addCount
	percent = 85 + (percent * 0.15)
	self:setPercent(percent)
	--self.Text:setString("载入中...(" .. tostring(math.floor(percent)) .. "%)")
	self.Text_zaiRuZhong:setString("载入中...(" .. tostring(math.floor(percent) .. "%)"))

	-- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    -- print(self.currIndex , " == 当前内存情况 = ", collectgarbage("count"))
end

-- 检查response
function LoadingLayer:checkResponse(str, status)
	if status == 200 then
		local rData = assert(json.decode(str))
		if rData.errcode == 0 then
			self:success(rData.data)
		else
			self:failed()
		end
	else
		self:failed()
	end
end

-- 成功处理
function LoadingLayer:success(data)
	if successFunc then
		successFunc(data)
	end
	self:hide()
end

-- 失败处理
function LoadingLayer:failed()
	self:maxZ()
	self:buttonShow()
	self:setButton1(beginFunc)
end

--[[
使用示例
local beginFunc = function()
HttpManagerEx:getTime(function(str, status)
loadingLayer:checkResponse(str, status)
end)
end

local successFunc = function(data)
	WEB_TIME = tonumber(data.time)
	if device.platform == "android" then
		YXHelper:setWebTime(WEB_TIME)
	else
	end
end
self:setFunctions(beginFunc, successFunc)

]]

-- 设置初始函数
-- butNum : 可选择填充，不填则为1
function LoadingLayer:setFunctions(func1, func2, butNum)
	self:show()
	if func1 == nil or type(func1) ~= "function" or func2 == nil or type(func2) ~= "function" then
		return
	end
	beginFunc = func1
	successFunc = func2
	if butNum == nil then
		butNum = 1
	end
	ButNum = butNum

	beginFunc()
	self:maxZ()
end

--  按钮显示
function LoadingLayer:buttonShow()
	self.Button_1:setVisible(true)
	local y = self.Button_1:getPositionY()
	if ButNum == 2 then
		self.Button_1:move(cc.p(300, y))
		self.Button_2:move(cc.p(780, y))
		self.Button_2:setVisible(true)
	else
		self.Button_1:move(cc.p(540, y))
	end
	self.Text_desc:setVisible(true)
	self.Text_desc2:setVisible(false)
end

-- 按钮隐藏
function LoadingLayer:buttonHide()
	self.Button_1:setVisible(false)
	if ButNum == 2 then
		self.Button_2:setVisible(false)
	end
	self.Text_desc:setVisible(false)
	self.Text_desc2:setVisible(true)
end

-- 设置按钮1
function LoadingLayer:setButton1(func)
	self.Button_1:releaseFunc(function()
		self:buttonHide()
		if func then
			func()
		end
	end)
end

--  设置按钮2
function LoadingLayer:setButton2(func)
	self.Button_2:releaseFunc(function()
		self:hide()
		if func then
			func()
		end
	end) 

end

function LoadingLayer:setTextDesc(str)
	self.Text_desc:setString(str)
end

function LoadingLayer:setTextDesc2(str)
	self.Text_desc2:setString(str)
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/10 15:09:01
-- @params 
-- @desc 
function LoadingLayer:ImageAction(index, interval)
	if Helper:getDef(biaoJi[index], true) == true then
		if self["Image_"..index] ~= nil then
			self["Image_"..index]:setVisible(true)
			self["Image_"..index]:runAction(cc.FadeIn:create(interval))
		else
			self.Button_chaKan:setVisible(true)
			self.Button_chaKan:runAction(cc.FadeIn:create(0.5))
		end
		biaoJi[index] = false
	end

end

local list = {
	[1] = {
		startTime = 0.3,
		interval = 0.08
	},
	[2] = {
		startTime = 0.5,
		interval = 0.84
	},
	[3] = {
		startTime = 0.8,
		interval = 0.84
	},
	[4] = {
		startTime = 1.2,
		interval = 0.84
	},
	[5] = {
		startTime = 1.7,
		interval = 0.84
	},
	[6] = {
		startTime = 1.9,
		interval = 1.5
	},
	[7] = {
		startTime = 2.3,
		interval = 1
	}
}
function LoadingLayer:showLoadingBar(ft)
	self._updateTime = self._updateTime + ft
	if self._updateTime <  1.5 then
		self.LoadingBar:setPercent((self._updateTime/1.5) * 50)
	elseif	self._updateTime < 3 then
		self.LoadingBar:setPercent(((self._updateTime - 1.5)/(3 - 1.5)) * 35 + 50)
	end
	for i=1,1000 do
		if list[i] ~= nil then
		else
			list[i] = {}
			list[i].startTime = (i - 7) * 5
		end

		if self._updateTime < list[i].startTime then
			break
		end

		self:ImageAction(i, list[i].interval)
	end
	local JinDuPercent = self.LoadingBar:getPercent()
	self.Text_zaiRuZhong:setString("载入中...(" .. tostring(math.floor(JinDuPercent) .. "%)"))
end



Helper:classDefNodeGetInstance(LoadingLayer)
return LoadingLayer
00000
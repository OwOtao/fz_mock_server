local Widget = ccui.Widget

local ErrmsgRecord = require("app.models.Record.ErrmsgRecord.ErrmsgRecord")

-- 当前控件列表
local WidgetMap = {}
local WidgetMapCount = 0
local function addToWidgetMap(id, widget)
	WidgetMapCount = WidgetMapCount + 1

	if PRINT_MODE == 1 then
		print("添加到控件地图 id = "..tostring(id))
		print("当前地图中的控件数目为 "..tostring(WidgetMapCount))
	end
	WidgetMap[id] = widget
end
local function removeFromWidgetMap(id)
	WidgetMapCount = WidgetMapCount - 1

	if PRINT_MODE == 1 then
		print("从控件地图中移除 id = "..tostring(id))
		print("当前地图中的控件数目为 "..tostring(WidgetMapCount))
	end
	WidgetMap[id] = nil
end
local function getWidgetMap()
	return Helper:getDef(WidgetMap, {})
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 移除其他所有点击效果
local function setAllWidgetTouchEnabled(b)
	local widgetMap = getWidgetMap()
	for k, v in pairs(widgetMap) do
		if pcall(function() v:setTouchEnabled(b) return true end, false) == false then
			removeFromWidgetMap(k)
		end
	end
end

local function callWidgetReleaseFunc(self, func)
	if true then
		func(self)
		return
	end

	local modifyMap = {}
	local widgetMap = getWidgetMap()

	for k, v in pairs(widgetMap) do
		if v.onlyId == nil or v.isTouchEnabled == nil or v.setTouchEnabled == nil or pcall(function()
			if v:isTouchEnabled() == true then
				v:setTouchEnabled(false)
				modifyMap[k] = v
			end
		end) == false then
			removeFromWidgetMap(k)
		end
	end

	-- 还原修改
	for k, v in pairs(modifyMap) do
		if v.onlyId == nil or v.setTouchEnabled == nil or pcall(function()
			v:setTouchEnabled(true)
		end) == false then
			removeFromWidgetMap(k)
		end
	end

	pcall(function() func(self) end)
end

function Widget:lazyInit()
	if self.onlyId == nil then
		self.onlyId = Helper:getOnlyId()
	end
	if self._touchAnimState == nil then
		self._touchAnimState = false
	end
	if self._touchInterval == nil then
		self._touchInterval = 0.2
	end
	if self._touchAnimEnabled == nil then
		self._touchAnimEnabled = true
	end

end

function Widget:setButtonType(buttontype)
	self._buttontype = buttontype
end
-- 8/1
--按钮声音类型
local voicetypeMap =
{
	[WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON] = "daAnNiu",
	[WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON] = "xiaoAnNiu",
	[WIDGET_TOUCH_VOICE_TYPE_BACKBUTTON] = "fanHuiQuXiao",
	[WIDGET_TOUCH_VOICE_TYPE_DASUANPANBUTTON] = "daSuanPan",
	[WIDGET_TOUCH_VOICE_TYPE_GOUMAIBUTTON]="gouMai"
}
function Widget:playVoice()
	if self._buttontype then
		Audio:playEffect(voicetypeMap[self._buttontype])
	end
end

function Widget:setTouchInterval(interval)
	self._touchInterval = interval
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc
-- @params func 点击的时候调用, cdFunc 冷却中点击调用
function Widget:pressFunc(func, cdFunc)
	self:lazyInit()
	self:moveChildrenWithButton(
	function()
        if CoroutineStack:count() > 0 then  
            return
        end
		local currTime = GetLocalTime()
		if (self._releaseTime == nil or currTime - self._releaseTime >= self._touchInterval ) and self.__result ~= false then
            self.__result = false
            Game:addBlockAsyncFunc("pressFunc.func.", function()
                func(self)

                self.__result = true
                self._releaseTime = currTime
            end)
		else
			if cdFunc then
                Game:addBlockAsyncFunc("pressFunc.cdFunc.", function()
                    cdFunc(self)
                end)
			end
		end
	end, nil, nil)
end

-- 全局点击频率限制
local pressTime = 0
local touchInterval = 0.3
local pressFrame = 0
local pressFrameInterval = 10

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc
-- @params func 点击的时候调用, cdFunc 冷却中点击调用
function Widget:releaseFunc(func, cdFunc)
    self:lazyInit()

    self:moveChildrenWithButton(
        nil,
        function()
            if CoroutineStack:count() > 0 then
                return
            end
            self:playVoice()
            local currTime = GetLocalTime()
            local currFrame = Game:getCurrFrame()
            -- add by XiaoZhiWei 2018/01/09 21:04:33 必须执行完前一个按钮事件,才能继续下一次按钮事件
            if
                (self._pressTime == nil or currTime - self._pressTime >= self._touchInterval) and (pressFrame == nil or currFrame - pressFrame >= pressFrameInterval) and
                    (pressTime == nil or currTime - pressTime >= touchInterval) and
                    self.__result ~= false
             then
                self.__result = false
                Game:addBlockAsyncFunc(
                    "releaseFunc.func.",
                    function()
                        xpcall(
                            function()
                                func(self)
                            end,
                            function(errmsg)
                                local msg = errmsg
                                local traceback_msg = debug.traceback()
                                print(msg)
                                print(traceback_msg)

                                ErrmsgRecord:addErrmsg(msg .. " ; " ..traceback_msg)
                            end
                        )
                        self.__result = true
                        self._pressTime = currTime
                        pressTime = currTime
                        pressFrame = currFrame
                    end
                )
            else
                if cdFunc then
                    Game:addBlockAsyncFunc(
                        "releaseFunc.cdFunc.",
                        function()
                            cdFunc(self)
                        end
                    )
                end
            end
        end,
        nil
    )
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/07/01 09:51:33
-- @desc releaseFunc 增加began canceled响应
function Widget:releaseFuncTotally(beganFunc, endedFunc, canceledFunc, cdFunc)
    self:lazyInit()

    -- addToWidgetMap(self.onlyId, self) -- 添加到控件地图

    self:moveChildrenWithButton(
        beganFunc,
        function()
            if CoroutineStack:count() > 0 then
                return
            end
            self:playVoice()

            local currTime = GetLocalTime()
            local currFrame = Game:getCurrFrame()
            if
                (self._pressTime == nil or currTime - self._pressTime >= self._touchInterval) and (pressFrame == nil or currFrame - pressFrame >= pressFrameInterval) and
                    (pressTime == nil or currTime - pressTime >= touchInterval) and
                    self.__result ~= false
             then
                self.__result = false
                Game:addBlockAsyncFunc(
                    "releaseFuncTotally.func.",
                    function()
                        xpcall(
                            function()
                                endedFunc(self)
                            end,
                            function(errmsg)
                                print(errmsg)
                                print(debug.traceback())
                            end
                        )
                        self.__result = true
                        self._pressTime = currTime
                        pressTime = currTime
                        pressFrame = currFrame
                    end
                )
            else
                if cdFunc then
                    Game:addBlockAsyncFunc(
                        "releaseFuncTotally.cdFunc.",
                        function()
                            cdFunc(self)
                        end
                    )
                end
            end
        end,
        canceledFunc
    )
end


function Widget:setTouchAnimEnabled(b)
	self._touchAnimEnabled = b
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @desc
-- @params func 播放 按钮事件触发后上下移动效果
function Widget:playTouchAnim(atype)
	if self._touchAnimEnabled == false then
		return
	end

	-- 控件及其字控件同步移动
	local function moveChildren(parent, atype)
		local children = parent:getChildren()
		local posY
		if atype == "up" then
			posY = 5
		elseif atype == "down" then
			posY = -5
		end
		if not children then
			return
		end
		for k,child in pairs(children) do
			local x,y = child:getPositionX(), child:getPositionY()
			child:move(x, y + posY)
			if child:getChildrenCount() > 0 then
				moveChildren(child, atype)
			end
		end
	end

	-- _touchAnimState 为true 代表 已向下移动过,下次只能向上移动 为false 则相反 (如果状况不匹配,则不做任何移动处理)
	if self._touchAnimState == true then
		if atype == "up" then
			moveChildren(self, "up")
			self._touchAnimState = false
		elseif atype == "down" then
			-- 不移动不处理
		else
			if PRINT_MODE == 1 then
				print("按钮移动参数有错误")
			end
		end
	elseif self._touchAnimState == false then
		if atype == "up" then
			-- 不移动不做处理
		elseif atype == "down" then
			moveChildren(self, "down")
			self._touchAnimState = true
		else
			if PRINT_MODE == 1 then
				print("按钮移动参数有错误")
			end
		end
	else
		if PRINT_MODE == 1 then
			print(" Widget:playTouchAnim(atype) -> 控件出现异常")
		end
	end
end

-- 处理点击按钮时，子节点不移动情况
function Widget:moveChildrenWithButton(beganFunc, endedFunc, canceledFunc)
	self:addTouchEventListener(
	function(ref, eventType)
        if self.__touchEvents == nil then
            self.__touchEvents = {}
        end

        for i = 1, math.max(#self.__touchEvents - 10, 0)  do
            table.remove(self.__touchEvents, 1)
        end

        table.insert(self.__touchEvents, eventType)

        if eventType == ccui.TouchEventType.began then
            self:playTouchAnim("down")
            if beganFunc then
                beganFunc(ref, eventType)
            end
        elseif eventType == ccui.TouchEventType.ended then
            self:playTouchAnim("up")
            if endedFunc then
                endedFunc(ref, eventType)
            end
        elseif eventType == ccui.TouchEventType.canceled then
            self:playTouchAnim("up")
            if canceledFunc then
                canceledFunc(ref, eventType)
            end
        end
	end)
end

function Widget:getCurrTouchEvent()
    if self.__touchEvents == nil then
        self.__touchEvents = {}
    end
    
    if #self.__touchEvents > 0 then
        local touchEventType = self.__touchEvents[1]
        table.remove(self.__touchEvents, 1)
        return touchEventType
    end
    return nil
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置所有的空间为不能触摸状态
function Widget:setSelfAndChildrenTouchEnabled(b)
	self:setTouchEnabled(b)
	self:callAllChild(
	function(child)
		child:setTouchEnabled(b)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 15:38:28
-- @desc 得到宽度
function Widget:getSizeWidth()
	return self:getContentSize().width
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 15:33:15
-- @desc 设置宽度
function Widget:setSizeWidth(width)
	self:setContentSize(cc.size(width, self:getContentSize().height))
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 15:38:59
-- @desc 得到高度
function Widget:getSizeHeight()
	return self:getContentSize().height
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 15:34:22
-- @desc 设置高度
function Widget:setSizeHeight(height)
	self:setContentSize(cc.size(self:getContentSize().width, height))
end
00000000
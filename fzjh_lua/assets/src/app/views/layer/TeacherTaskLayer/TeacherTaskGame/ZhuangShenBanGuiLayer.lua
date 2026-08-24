local ZhuangShenBanGuiLayer = class("ZhuangShenBanGuiLayer", cc.Layer)
local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
function ZhuangShenBanGuiLayer:create()
	local p = ZhuangShenBanGuiLayer:new()
	p:init()
	return p
end
function ZhuangShenBanGuiLayer:init()
	local UI= require("Layer/TeacherTask/TeacherTaskGame/ZhuangShenBanGuiUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点

end
local tab = {
	[1] = {
		str = "吊死鬼",
	},
	[2] = {
		str = "吊死鬼",
	},
	[3] = {
		str = "吊死鬼",
	},
}
function ZhuangShenBanGuiLayer:enterLayer(map,role,roomId)
	local layer = self:getInstance()
	layer:show()
	layer:initLayer(map,role,roomId)
end
function ZhuangShenBanGuiLayer:initLayer(map,role,roomId)
	self:setBack()
	self:setButton1(map,role,roomId)
	self:setButton2(map,role,roomId)
	self:setButton3(map,role,roomId)

	self:setDscText(role)
end
function ZhuangShenBanGuiLayer:setBack()
	self.Image_back:releaseFunc(function()
		self:hide()
	end)
end
function ZhuangShenBanGuiLayer:setDscText(role)
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	local str = ""
	print(">>>>>>>>>>>>>>",role.id)
	Helper:print_lua_table(receiveTask.npcId)
	for k, v in pairs(receiveTask.npcId) do 
		if v == role.id then
			str = receiveTask.words[k]
		end
	end
	-- str = str.."\n\nHIY针对此人的黑历史，最好的办法是装神弄鬼来吓唬他，从而攻破其心防。你决定打扮成：NOR"
	self.Text_dsc:setString("HIY针对此人的黑历史，最好的办法是装神弄鬼来吓唬他，从而攻破其心防。你决定打扮成：NOR")
	self:initRichText()
    local textColor = cc.c3b(208, 208, 208)
    self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
end
function ZhuangShenBanGuiLayer:initRichText()
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end
    local x, y = self.Panel_dscArea:getPosition()
    
    print(x,y)
    self.Panel_dscArea:setVisible(false)
    local size = self.Panel_dscArea:getContentSize()
    self.RichText_print = ExtRichTextScroll:create()
    self.Panel_dscArea:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:pushBackNewLine()
	self.RichText_print:pushBackNewLine(verticalSpace)
	self.RichText_print:setCascadeOpacity(255)
	self.RichText_print:setAnchorPoint(0.5000, 0.5000)
	self.RichText_print:setTouchEnabled(false)
end
function ZhuangShenBanGuiLayer:setButton1(map,role,roomId)
	self.Button_DiaoSiGui:releaseFunc(function()
		local tab =
			{
				{
					conditionRelation = "and",
					conditions =
					{
						{
							type = "玩家操作",
							arg1 = "玩家操作",
							arg2 = "操作",
						}
					},
					results =
					{
						{
							type = "装神扮鬼",
							arg1 = "装神扮鬼",
							arg2 = "吊死鬼",
						},
					}
				},
			}
		local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
		if User:getRole():checkCanBuyThings(receiveTask.daoju[1],1) == false then
			PopText("请先腾出1个背包格子！")
			return
		end
		map:doConditionAndResult(tab,
                    {
                        operation = "操作",
                        result = "装神扮鬼",
                        currRole = role,
                        currRoomId = roomId,
                        mapLayer = map,
                        func = function()
                        	self:hide()
                    	end
                    })
	end)
end
function ZhuangShenBanGuiLayer:setButton2(map,role,roomId)
	self.Button_WuTouGui:releaseFunc(function()
		local tab =
			{
				{
					conditionRelation = "and",
					conditions =
					{
						{
							type = "玩家操作",
							arg1 = "玩家操作",
							arg2 = "操作",
						}
					},
					results =
					{
						{
							type = "装神扮鬼",
							arg1 = "装神扮鬼",
							arg2 = "无头鬼",
						},
					}
				},
			}
		local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
		if User:getRole():checkCanBuyThings(receiveTask.daoju[1],1) == false then
			PopText("请先腾出1个背包格子！")
			return
		end
		map:doConditionAndResult(tab,
                    {
                        operation = "操作",
                        result = "装神扮鬼",
                        currRole = role,
                        currRoomId = roomId,
                        mapLayer = map,
                        func = function()
                        	self:hide()
                    	end
                    })
	end)
end
function ZhuangShenBanGuiLayer:setButton3(map,role,roomId)
	self.Button_YanSiGui:releaseFunc(function()
		local tab =
			{
				{
					conditionRelation = "and",
					conditions =
					{
						{
							type = "玩家操作",
							arg1 = "玩家操作",
							arg2 = "操作",
						}
					},
					results =
					{
						{
							type = "装神扮鬼",
							arg1 = "装神扮鬼",
							arg2 = "淹死鬼",
						},
					}
				},
			}
		local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
		if User:getRole():checkCanBuyThings(receiveTask.daoju[1],1) == false then
			PopText("请先腾出1个背包格子！")
			return
		end
		map:doConditionAndResult(tab,
                    {
                        operation = "操作",
                        result = "装神扮鬼",
                        currRole = role,
                        currRoomId = roomId,
                        mapLayer = map,
                        func = function()
                        	self:hide()
                    	end
                    })
	end)
end
Helper:classDefNodeGetInstance(ZhuangShenBanGuiLayer)
return ZhuangShenBanGuiLayer
00000000000000
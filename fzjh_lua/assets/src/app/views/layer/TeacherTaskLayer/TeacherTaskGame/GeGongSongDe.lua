local GeGongSongDe = class("GeGongSongDe", cc.Layer)
local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
function GeGongSongDe:create()
	local p = GeGongSongDe:new()
	p:init()
	return p
end
function GeGongSongDe:init()
	local UI= require("Layer/TeacherTask/TeacherTaskGame/GeGongSongDeGameUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点

end
function GeGongSongDe:enterLayer(map,currRole)
	local layer = self:getInstance()
	layer:show()
	layer:initLayer(map,currRole)
end
function GeGongSongDe:initLayer(map,currRole)
	self.successCount = 0
	self:setBack()
	self:setStartButton(map,currRole)
	self:setDscText(currRole)
end
function GeGongSongDe:setBack()
	self.Image_back:releaseFunc(function()
		self:hide()
	end)
end
function GeGongSongDe:setDscText(currRole)
	local str_dsc = {
		[1] = "他就是星宿派的名宿RED$NNOR，他出身豪门，相貌堂堂，然而脾气却很暴躁，对自己的轻功有着迷之自恋。",
		[2] = "他就是星宿派的RED$NNOR，他出身贫贱，少年时吃过很多苦，发迹后尤喜美食和穿衣打扮，就自己的穿着品味有着迷之自恋。",
		[3] = "他就是星宿派的RED$NNOR，他出自书香门第，年轻时饱读诗书、用功甚勤，虽然投入我门后早就学业荒废，还一直以读书人自居。",
	}
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	self.Image_back.Text_title:setString(currRole.name)
	self:initRichText()
    local textColor = cc.c3b(208, 208, 208)
    local str = string.gsub(str_dsc[math.random(1,#str_dsc)],"$N",currRole.name)
    self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
end
function GeGongSongDe:startGame(map,currRole)
	self.Image_back.Panel_move:setPosition(164,486)
	local random = math.random(500,881)
	self.time = 0
	self.Image_back.Panel_kuang:setPosition(random,486)
	self:setButton(map,currRole)
	self:movePanel(map,currRole)

end
function GeGongSongDe:movePanel(map,currRole)
	local action = cc.Sequence:create(cc.MoveTo:create(1.0, cc.p(908, 486)),
		 cc.MoveTo:create(1.0, cc.p(160, 486)),cc.CallFunc:create(
        function()
            self:setStartButton(map,currRole)
        end))
	self.Image_back.Panel_move:runActionWithName("movePanel",action)
end
function GeGongSongDe:finishGame(map,currRole)
	local pos_move = self.Image_back.Panel_move:getPositionX()
	local pos_kuang = self.Image_back.Panel_kuang:getPositionX()
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	local success = {
		[1] = "RED你的马屁拍得恰到好处，逗得$N眉开眼笑心花怒放。",
		[2] = "RED你的马屁正好挠到了他心头的痒处，让他顿生知己之感，恨不得抱住你亲一口。",
	}
	local defeat = {
		[1] = "你的马屁拍得平平无奇，他表情淡然，不为所动。",
		[2] = "你的马屁毫无新意，他听了没有任何表示。",
	}

	if math.abs(pos_kuang - pos_move) <= 42 then
		local str = string.gsub(success[math.random(1,#success)],"$N",receiveTask.name)
		RichPrint("main",str)
		self.successCount = self.successCount + 1
	else
		local str = string.gsub(defeat[math.random(1,#defeat)],"$N",receiveTask.name)
		RichPrint("main",str)
	end
	self:setStartButton(map,currRole)
end
function GeGongSongDe:setStartButton(map,currRole)
	if self.successCount ~= 3 then
		self.Image_back.Button_paimapi.Text_pokedex_button_text:setString("开始")
		self.Image_back.Button_paimapi:releaseFunc(function()
			self:startGame(map,currRole)
		end)
	else
		self.Image_back.Button_paimapi.Text_pokedex_button_text:setString("关闭")
		self.Image_back.Button_paimapi:releaseFunc(function()
			self:hide()
			local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
			TeacherTask:setTeacherTaskAttr("isComplete","Y")
			map:removeRoomRole(receiveTask.roomId,currRole.id)
			map.__MapLayer:setNeedRefreshMap()
			receiveTask.roomId = {}
			TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
			--设置任务完成
		end)
	end
end
function GeGongSongDe:setButton(map,currRole)
	self.Image_back.Button_paimapi.Text_pokedex_button_text:setString("拍马屁")
	self.Image_back.Button_paimapi:releaseFunc(function()
		self.Image_back.Panel_move:stopActionByName("movePanel")
		self:finishGame(map,currRole)
	end)
end
function GeGongSongDe:initRichText()
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end
    local x, y = self.Image_back.Panel_dscArea:getPosition()
    y = y - 250
    print(x,y)
    local size = self.Image_back.Panel_dscArea:getContentSize()
    self.RichText_print = ExtRichTextScroll:create()
    self.Image_back.Panel_dscArea:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:pushBackNewLine()
	self.RichText_print:pushBackNewLine(verticalSpace)
	self.RichText_print:setCascadeOpacity(255)
	self.RichText_print:setAnchorPoint(0.5000, 0.5000)
	self.RichText_print:setTouchEnabled(false)
end

Helper:classDefNodeGetInstance(GeGongSongDe)
return GeGongSongDe
000000
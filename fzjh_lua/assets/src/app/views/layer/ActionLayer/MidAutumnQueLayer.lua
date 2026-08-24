--@SuperType [app.views.layer.ActionLayer.ActionDescLayer#ActionDescLayer]
local MidAutumnQue = class("MidAutumnQue", require("app.views.layer.ActionLayer.ActionDescLayer"))

function MidAutumnQue:create()
	local p = MidAutumnQue:new()
	p:init()
	return p
end


function MidAutumnQue:setButtonClose()
	self.Text_buttonName:setString("参加")
	self.Button_close:releaseFunc(function()
		local role = User:getRole()
		-- local flag = role:getFlag("问卷调查次数")
		if flag == 1 then
			PopText("您已参加过此次问卷调查。")
			return 
		end

		--[[ 
			参数1：调查问卷
			参数2：调查内容：游戏内容调查
			参数3：题库内容   1;2;3;4;5;6;7
			参数4：结果1;结果2
			参数5：全部题目做完之后的条件结果
			参数6：每日问卷做完次数
			参数7：是否每次答完后关闭界面 （0 | 1，可选，默认为0）
		]]
		-- local Q = "1;2;3;4;5;6;7;8;9;10"
		-- local Q = "11"
		local Q = "11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34"
		-- local Q = "1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34"
		
		-- local role = User:getRole()
		
		local qs = require("app.models.QAModel.qs")
		local questions = {}		
		if Q then
			questions = string.split(Q, ";")
		end
		
		local doCurrResults = {
		--[[ 		{		
		preFunc = function()end      --答案上传前执行
		runFunc = function()end      --答案上传成功后运行
		afterFunc = function()end    --无论答案上传成功与否都执行
		} ]]
		}
		
		print("-------------------" .. #questions)
		if not MapIsEmpty(doCurrResults) then
			doCurrResults = {}
		end
		
		--奖励逻辑
		-- local doCurrResults = {
		-- 	preFunc = function()
		-- 		-- local map = {["item204_60"] = 10,["fenshenfu"] = 10,["dundifu"] = 10}
		-- 		local map = {["wjgift1"] = 1}
		-- 		--@RefType [app.models.role.Role#Role]
		-- 		local role = User:getRole()
		-- 		local check = role:checkCanBuyTwoOrMoreThings(map)
		-- 		return check
		-- 	end,
		-- 	runFunc = function()
		-- 		--@RefType [app.models.item.BaseItem2#BaseItem]
		-- 		local role = User:getRole()
		-- 		-- role:addItemCount("item204_60", 10)
		-- 		-- role:addItemCount("fenshenfu", 10)
		-- 		-- role:addItemCount("dundifu", 10)
		-- 		-- local item = Item:getOneItemByKey("item204_60")
		-- 		-- local item1 = Item:getOneItemByKey("fenshenfu")
		-- 		-- local item2 = Item:getOneItemByKey("dundifu")
		-- 		-- PopText("您获得 " .. item.name .. " x10")
		-- 		-- PopText("您获得 " .. item1.name .. " x10")
		-- 		-- PopText("您获得 " .. item2.name .. " x10")
		-- 		role:addItemCount("wjgift1",1)
		-- 		local item = Item:getOneItemByKey("wjgift1")
		-- 		PopText("您获得 " .. item.name .. " x1")
		-- 	end,
		-- }
		
		qs:initQuestionMap(questions, doCurrResults)
		local qsLayer = require("app.views.layer.QALayer.QSLayer")
		-- qsLayer:getInstance():showLayer("MidAutumn", {isHide = Helper:getDef(tonumber(1), 0), fprize = Helper:getDef(nil, "")})
		qsLayer:getInstance():showLayer("Question", {isHide = Helper:getDef(tonumber(1), 0), fprize = Helper:getDef(nil, "")})
		--判断背包状态是否已满
		-- local role = User:getRole()
		local rwdTab = {["wjgift1"] = 1}
		-- local rwdTab = {["dao120"] = 1}
		if role:checkCanBuyTwoOrMoreThings(rwdTab) == true then
		else
			-- PopText("背包已满，建议先清理背包在参与问卷调查。")
		end
		self:hide()
	end)
end

function MidAutumnQue:setDesc(text)
	if type(text) ~= "string" then
		return
	end
	local textColor = cc.c3b(255, 255, 255)
	self:initRichTextPreview("dsc", self.Text_desc, self, text, textColor)
	self.dsc:setTouchEnabled(false)
end


Helper:classDefNodeGetInstance(MidAutumnQue)
return MidAutumnQue 00
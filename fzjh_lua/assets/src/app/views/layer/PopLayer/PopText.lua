local Resource = require("app.Resource")
local PopText = class(PopText, require("app.views.base.BaseLayer"))

function PopText:create(text, color, font, fontSize)
	local p = PopText:new()
	p:init(text, color, font, fontSize)
	return p
end

--10/21  修改 by  lijie
---保存弹出信息的数组
local popTextArray = {}
function PopText:pop(text, color, font, fontSize)
	local runningScene = cc.Director:getInstance():getRunningScene()
    if runningScene then

    		local p = PopText:create(text, color, font, fontSize)
	    	runningScene:addChild(p)

	    	---加入一条信息，加入到数组的最后一条
	    	table.insert(popTextArray,#popTextArray + 1,p)
    	local function popRunAction( p)
    		p:move(display.cx, display.cy + 200)
    		p:maxZ()

    		p:setCascadeOpacityEnabled(true)
    		p:setOpacity(0)
    		local duration1 = 3
    		local action1 = cc.Spawn:create(cc.MoveBy:create(duration1, cc.p(0, -400))
    			, cc.Sequence:create(cc.FadeIn:create(duration1 / 6 ), cc.DelayTime:create(duration1 * 2 / 3), cc.FadeOut:create(duration1 / 6)))
    		p:runAction(cc.Sequence:create(action1, cc.RemoveSelf:create()))

    		runningScene.lastPopTextTime = GetTime()
    	end

    	local currTime = GetTime()
    	local lastTime = runningScene.lastPopTextTime

        --弹出一条必须删除一条信息
    	if lastTime == nil then
    		popRunAction(popTextArray[1])
    		table.remove(popTextArray,1)
    	else
    		local popTextDuration = 0.5
    		local duration = currTime - runningScene.lastPopTextTime
    		if duration > popTextDuration then
    			popRunAction(popTextArray[1])
    			table.remove(popTextArray,1)
    		else
    			runningScene:delayFunc(popTextDuration - duration + (popTextDuration * ( #popTextArray - 1 )),
    				function()
						popRunAction(popTextArray[1])
						table.remove(popTextArray,1)
    				end)
    		end
    	end

    end
end

function PopText:init(text, color, font, fontSize)
	text = Helper:getDef(text, "")
	color = Helper:getDef(color, cc.c3b(255, 255, 255))
	font = Helper:getDef(font, Resource:getFontPath("default"))
	fontSize = Helper:getDef(fontSize, 48)

	local text = ccui.Text:create(text, font, fontSize)
	self:addChild(text)
	text:setTextHorizontalAlignment(1)
	text:setTextVerticalAlignment(1)
	text:setTextAreaSize(cc.size(display.width, display.height))
	text:setTextColor(color)
   	text:enableOutline(cc.c4b(0, 0, 0, 255), 5)	
end

return PopText
0000000000000
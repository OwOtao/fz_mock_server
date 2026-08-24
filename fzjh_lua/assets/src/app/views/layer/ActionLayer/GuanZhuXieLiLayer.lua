--馆主谢礼界面
local GuanZhuXieLiLayer = class("GuanZhuXieLiLayer", LayerEx)

function GuanZhuXieLiLayer:create()
	local p = GuanZhuXieLiLayer:new()
	p:init()
	return p
end

function GuanZhuXieLiLayer:init()
	local UI = require("Layer/ActionUI/GzxlUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
    
    self:setBack()
end

function GuanZhuXieLiLayer:showLayer(actionId)
	
    self:initRichTextPreview()
	self:setActionTime(actionId)

    self:show()
end

function GuanZhuXieLiLayer:setGainButton(timeStart)
    local role = User:getRole()
    if role:getDayFlag("馆主谢礼奖励") == 0 then
        self.Panel_1.Button_lingqu:setEnabled(true)
    else
        self.Panel_1.Button_lingqu:setEnabled(false)
    end
   
    self.Panel_1.Button_lingqu:releaseFunc(function()
		-- 先判断背包空间数量
		if not role:checkCanBuyTwoOrMoreThings({["dao101"] = 1}) then
			return
		end

        print(tonumber(Helper:diffWithDate(GetTime(),timeStart)))

        local transTime = tonumber(Helper:diffWithDate(GetTime(),timeStart))

        if transTime == 2 or transTime == 6 or transTime == 13 then
            role:addItemCount("znqjndj2", 1)
        else
            role:addItemCount("znqjndj1", 1)
        end
        PopText("获得物品金牛帖X1")
        
        role:setDayFlag("馆主谢礼奖励",1)

        self:setGainButton()
    end)

    

end

function GuanZhuXieLiLayer:setBack()
	self.Panel_1.Button_guanbi:releaseFunc(function()
		self:hide()
	end)
end

-- @desc 设置活动时间
local textColor = cc.c3b(208,208,208)
function GuanZhuXieLiLayer:setActionTime(actionId)
	if actionId == nil then
		return
	end
	
	HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
        Helper:print_lua_table(data)
        if status == 200 and errcode == 0  then
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
                self:setGainButton(data.start)

        		local year,month,day,time
				year = tonumber(Helper:date("%Y", tonumber(data.start)))
        		month = tonumber(Helper:date("%m", tonumber(data.start)))
        		day = tonumber(Helper:date("%d", tonumber(data.start)))
        		time = month.."月"..day.."日更新后至"
				year =  tonumber(Helper:date("%Y", tonumber(data["end"])))
        		month = tonumber(Helper:date("%m", tonumber(data["end"])))
        		day = tonumber(Helper:date("%d", tonumber(data["end"])))

        		time = time..month.."月"..day.."日".."期间，华为、vivo、oppo、应用宝这四个平台，YEL每日登录即可领取NOR一份金牛贴，将金牛贴交给金牛武馆馆长朱宇，可获得一份神秘奖励，活动开启后的第三、七、十四天可领取一份丰厚大礼。"
				self.RichText_Print:pushBackText(time, textColor, 255, Resource:getFontPath("default"), 48)
            end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end

function GuanZhuXieLiLayer:initRichTextPreview()
	local x, y = self.Text_desc:getPosition()
	local size = self.Text_desc:getContentSize()
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Text_desc:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Text_desc:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
   	self.RichText_Print:setTouchEnabled(false)
end

Helper:classDefNodeGetInstance(GuanZhuXieLiLayer)

return GuanZhuXieLiLayer00000000000
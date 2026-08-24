local JiangHuSanYouVoteLayer = class("JiangHuSanYouVoteLayer", LayerEx)
function JiangHuSanYouVoteLayer:create()
	local p = JiangHuSanYouVoteLayer:new()
	p:init()
	return p
end

-----------------------------------------------------------------------------------------------------------
function JiangHuSanYouVoteLayer:test(data,name,count1,count2, afterVoteCallback)
	self:initUI(data,name,count1,count2, afterVoteCallback)
  
end

function JiangHuSanYouVoteLayer:init()
	local UI = require("Layer/ActionUI/JiangHuSanYouVoteUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
end

function JiangHuSanYouVoteLayer:initUI(data,name,count1,count2, afterVoteCallback)
  local role = User:getRole()

	--容我考虑按钮处理
	self.Button_back:setTouchEnabled(true)
	self.Button_back:setBright(true)

	--设置字体的颜色
	self:initRichText()
	self:setRoleDsc("你将要投票给"..name.."。请问你打算用何种令牌投票？")
	self.Text_name:setVisible(false)
	self.Text_num1:setString("当前拥有"..count1.."个")
	self.Text_num2:setString("当前拥有"..count2.."个")

  if count1 <= 0 then 
    -- self.Text_num1:setEnabled(true)
    self.Button_shengzhen:setTouchEnabled(false)
    self.Button_shengzhen:setBright(false)--变灰色
  else
    self.Button_shengzhen:setTouchEnabled(true)
    self.Button_shengzhen:setBright(true)
  end

  if count2 <=0 then
    self.Button_yangming:setTouchEnabled(false)
    self.Button_yangming:setBright(false)--变灰色
  else
    self.Button_yangming:setTouchEnabled(true)
    self.Button_yangming:setBright(true)
  end

  
	self.Button_shengzhen:releaseFunc(function()
		HttpManagerEx:voteToJhsanyou(1,data.id,function(status, errcode, errmsg, data)
      if status == 200 and errcode == 0 then
      	--设置背包的声震风云令减1
			  role:addItemCount("voteitem1",-1)
  			if self.Text_num1 then
  			    self.Text_num1:setString("当前拥有"..(count1 - 1).."个")
  			end
  	    if afterVoteCallback then--这里投票完，发送数据之后回调刷新数据
  		    afterVoteCallback()
  	    end
  	    self:getReward(1)--奖励
  	    self:hideLayer()
      else
          PopText(errmsg)
      end
		end,IS_SHOW_WAITING)
	end)

	self.Button_yangming:releaseFunc(function()
		HttpManagerEx:voteToJhsanyou(2,data.id,function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                --设置背包的扬名风云令减1
      			role:addItemCount("voteitem2",-1)
      			if self.Text_num2 then
      			    self.Text_num2:setString("当前拥有"..(count2 - 1).."个")
      			end
				if afterVoteCallback then--这里投票完，发送数据之后回调刷新数据
					afterVoteCallback()
				end
				self:getReward(2)--奖励

				self:hideLayer()
            else
                PopText(errmsg)
            end
		end,IS_SHOW_WAITING)
	end)

	self.Button_back:releaseFunc(function()
		self:hideLayer()
	end)

	self:show()
end

--解决一句文字中，名字显示其他颜色
function JiangHuSanYouVoteLayer:initRichText()
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

    local x, y = self.Text_name:getPosition()
    local size = self.Text_name:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    self.Text_name:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
    self.RichText_print:setBounceEnabled(false)
end
function JiangHuSanYouVoteLayer:setRoleDsc(dsc)
    -- add by tangjian, 临时解决 richText 问题
    self:initRichText()

    local textColor = cc.c3b(208, 208, 208)
    -- self.RichText_print:getRichText():removeAllElement()
    self.RichText_print:pushBackText(dsc, textColor, 255, Resource:getFontPath("default"),58)

    -- self:delayFunc(0, function()
    --     self:setViewPage()
    -- end)
end

function JiangHuSanYouVoteLayer:hideLayer()
	PopupLayerController:hideLayer("JiangHuSanYouVoteLayer",function (layer)
		layer:hide()
	end)
end 

--奖励领取
function JiangHuSanYouVoteLayer:getReward(num)
	PopText("投票成功")
	local role = User:getRole()
	local item = Item:getOneItemByKey("voteaward1")
    --投票的时候选择声震江湖令 一定得一份奖励
    if num == 1 then
    	role:addItemCount("voteaward1",1)
    	PopText("您获得 " .. item.name .. " x1")
    end
    --投票的时候选择扬名江湖令百分之二十五概率获得奖品
    if num == 2 then
    	local chance = math.random(1,100) 
    	if chance <= 35 then
    		role:addItemCount("voteaward1",1)
    	    PopText("您获得 " .. item.name .. " x1")
    	end
    end
end

function JiangHuSanYouVoteLayer:setBack()
	self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)
end

Helper:classDefNodeGetInstance(JiangHuSanYouVoteLayer)

return JiangHuSanYouVoteLayer
000000000000000